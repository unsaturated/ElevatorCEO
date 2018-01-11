/**
 * Elevator CEO is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *  
 * Elevator CEO is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *  
 * You should have received a copy of the GNU General Public License
 * along with Elevator CEO. If not, see 
 * https://github.com/unsaturated/ElevatorCEO/blob/master/LICENSE.
 */

#import "GameControlLayer.h"
#import "GameLevelMaker.h"
#import "AudioController.h"
#import "ShaftControl.h"
#import "OwnGameElevator.h"

@implementation GameControlLayer

-(id) init
{
	if( (self = [super init]) )
	{
        // Ensure all necessary sprites are loaded into the frame cache
        //CGSize winSize = [[CCDirector sharedDirector] winSize];
        CGRect winRect = [[GameController sharedInstance] gamingAreaRectForPlay:YES];
		CGSize winSize = winRect.size;
        
        CGFloat wViewHeight = winSize.height;
        
		// Establish properties of control layer itself
		[self setAnchorPoint:ccp(0, 0.5)];
		[self scheduleUpdate];
		
		// Set to nav size
		[self setContentSize:CGSizeMake(80, wViewHeight)];
		
		// Add a background color to the layer
        CCSprite *wColorLayer = [CCSprite spriteWithSpriteFrameName:@"navbar-bg.png"];
        if([GameController sharedInstance].is16x9)
        {
            // iPhone 5 can just re-use the existing graphic with the only change being the y-scale
            // but it's fine since the gradient is vertical
            [wColorLayer setScaleY:1.1833f];
        }
        
        [wColorLayer setContentSize:CGSizeMake(80, wViewHeight)];
        [wColorLayer setAnchorPoint:CGPointZero];
        [self addChild: wColorLayer z:0];
		
		// Synergy or health status bar
		mStatus = [GameStatus node];
		mStatus.position = ccp(-2, 2);
		[self addChild:mStatus z:5];
		
		// Radar layer
		mRadar = [GameRadar node];
        if([GameController sharedInstance].is16x9)
            mRadar.position = ccp(-2, wViewHeight - 154);
        else
            mRadar.position = ccp(-2, wViewHeight - 122);
		[self addChild:mRadar z:5];
		
		// Music and sound buttons
		// -----------------------
		CCSprite *wMusicOnItem = [CCSprite spriteWithSpriteFrameName:@"music-on.png"];
		CCSprite *wMusicOffItem = [CCSprite spriteWithSpriteFrameName:@"music-off.png"];
		CCSprite *wSoundOnItem = [CCSprite spriteWithSpriteFrameName:@"sound-on.png"];
		CCSprite *wSoundOffItem = [CCSprite spriteWithSpriteFrameName:@"sound-off.png"];
		
		mMusicOnMenuItem = [CCMenuItemImage itemFromNormalSprite:wMusicOnItem selectedSprite:nil];
		mMusicOffMenuItem = [CCMenuItemImage itemFromNormalSprite:wMusicOffItem selectedSprite:nil];
		
		mSoundOnMenuItem = [CCMenuItemImage itemFromNormalSprite:wSoundOnItem selectedSprite:nil];
		mSoundOffMenuItem = [CCMenuItemImage itemFromNormalSprite:wSoundOffItem selectedSprite:nil];
		
		mSoundItem = [CCMenuItemToggle
					  itemWithTarget:self 
					  selector:@selector(soundButtonTapped:) 
					  items:mSoundOnMenuItem, mSoundOffMenuItem, nil];
		
		mMusicItem = [CCMenuItemToggle 
					  itemWithTarget:self
					  selector:@selector(musicButtonTapped:)
					  items:mMusicOnMenuItem, mMusicOffMenuItem, nil];
		
		CCMenu *wMusicMenu = [CCMenu menuWithItems:mMusicItem, nil];
		[self addChild:wMusicMenu z:101];
        if([GameController sharedInstance].is16x9)
            wMusicMenu.position = ccp(20, wViewHeight - 154 - 20);
        else
            wMusicMenu.position = ccp(20, 342);
        
		// Check with GameController what the music state is and select appropriate index
		mMusicItem.selectedIndex = [[AudioController sharedInstance] isMusicOn] ? 0 : 1;
		
		
		CCMenu *wSoundMenu = [CCMenu menuWithItems:mSoundItem, nil];
		[self addChild:wSoundMenu z:101];
        if([GameController sharedInstance].is16x9)
            wSoundMenu.position = ccp(60, wViewHeight - 154 - 20);
        else
            wSoundMenu.position = ccp(60, 342);
		mSoundItem.selectedIndex = [[AudioController sharedInstance] isSoundOn] ? 0 : 1;
		
		// Pause button
		// ------------
		CCSprite *wPauseItem = [CCSprite spriteWithSpriteFrameName:@"pause.png"];
		
		mPauseMenuItem = [CCMenuItemImage itemFromNormalSprite:wPauseItem selectedSprite: nil 
														target:self 
													  selector:@selector(menuButtonTapped:)];
		
		CCMenu *wPauseMenu = [CCMenu menuWithItems:mPauseMenuItem, nil];
		[self addChild:wPauseMenu z:101];
        if([GameController sharedInstance].is16x9)
            wPauseMenu.position = ccp(20, 154 + 20);
        else
            wPauseMenu.position = ccp(20, 150);
        
        // Swap button
        // -----------
		CCSprite *wSwapItem = [CCSprite spriteWithSpriteFrameName:@"swap.png"];
		
		mSwapMenuItem = [CCMenuItemImage itemFromNormalSprite:wSwapItem selectedSprite: nil 
														target:self 
													  selector:@selector(menuButtonTapped:)];
		
		CCMenu *wSwapMenu = [CCMenu menuWithItems:mSwapMenuItem, nil];
		[self addChild:wSwapMenu z:101];
        if([GameController sharedInstance].is16x9)
            wSwapMenu.position = ccp(60, 154 + 20);
        else
            wSwapMenu.position = ccp(60, 150);
		
		
		// Up and Down Elevator Buttons
		// ----------------------------
		mUpButton = [GameUpDownButton initUpButton];
		[self addChild:mUpButton z:101];
        if([GameController sharedInstance].is16x9)
            mUpButton.position = ccp(40, (wViewHeight / 2.0f) + 40);
        else
            mUpButton.position = ccp(40, 287);
        mUpButton.delegate = self;
		
		mDownButton = [GameUpDownButton initDownButton];
		[self addChild:mDownButton z:101];
        if([GameController sharedInstance].is16x9)
            mDownButton.position = ccp(40, (wViewHeight / 2.0f) - 40);
        else
            mDownButton.position = ccp(40, 207);
		mDownButton.delegate = self;
		
		CCLOG(@"+++INIT %@", self);
	}
	
	return self;
}

- (void) dealloc
{
	CCLOG(@"---DEALLOC %@", self);
    //[self unscheduleSelectors];
	[super dealloc];
}

- (void) onExit
{
    [self unscheduleSelectors];
	[super onExit];
}

-(void) update:(ccTime) dt
{
	if(mPlayLayer.ownElevator.passengersOnboard == 1)
	{
		[mPlayLayer.transferShaft4 clearForCEO];
	}
	
	// Get the own elevator and match up the synergy
	OwnGameElevator* wOwn = (OwnGameElevator*)mPlayLayer.ownElevator;
	mStatus.synergyLevel = wOwn.synergy;
	[mStatus setLives:wOwn.lives];
    
    [mUpButton setPressIsAllowable:[wOwn isUpControlAllowable]];
    [mDownButton setPressIsAllowable:[wOwn isDownControlAllowable]];
	
	[mStatus setLevel:[GameLevelMaker sharedInstance].level];
}

#pragma mark UpDown Button Handlers

-(void) buttonUpEvent:(BOOL)tap hold:(char)speed
{
	if(mPlayLayer)
	{
		[mPlayLayer moveFloorSpeed:tap withSpeed:speed directionDown:NO];
	}
}

-(void) buttonDownEvent:(BOOL)tap hold:(char)speed
{    
	if(mPlayLayer)
	{
		[mPlayLayer moveFloorSpeed:tap withSpeed:speed directionDown:YES];
	}  
}

#pragma mark Implementation of IMenuHandler

- (void)menuButtonTapped:(id)sender 
{
	CCMenuItem *wItem = (CCMenuItem *)sender;
	if(wItem == mPauseMenuItem)
	{
        if(![GameController sharedInstance].isPaused)
        {
            [[GameController sharedInstance] pause:YES];
        }
	}
    if(wItem == mSwapMenuItem)
    {
        if(![GameController sharedInstance].isPaused)
        {
            [self swapControlSide];
        }
    }
}

-(void)unscheduleSelectors
{
    [mUpButton unscheduleSelectors];
    [mDownButton unscheduleSelectors];
	[mMusicItem unschedule:@selector(musicButtonTapped:)];
	[mSoundItem unschedule:@selector(soundButtonTapped:)];
	[mPauseMenuItem unschedule:@selector(menuButtonTapped:)];
    [self unscheduleUpdate];
    [self unscheduleAllSelectors];
}

-(void)swapControlSide
{
	if(mPlayLayer)
	{
		CGPoint wPointForControl;
		CGPoint wPointForPlay;
        
        CGRect winRect = [[GameController sharedInstance] gamingAreaRectForPlay:YES];
		
		BOOL wPlayLayerNowOnLeft = ccpFuzzyEqual(mPlayLayer.position, ccp(-PLAY_AREA_MARGIN, winRect.origin.y), 1.0f);
		if(wPlayLayerNowOnLeft)
		{
			// Move play area to the right
			wPointForControl = winRect.origin;
			wPointForPlay    = ccp(80, winRect.origin.y);
		}
		else 
		{
			// Move play area to the left
			wPointForControl = ccp(240, winRect.origin.y);
			wPointForPlay    = ccp(-PLAY_AREA_MARGIN, winRect.origin.y);
		}
        
        // We just swapped sides, so it's NOT on the left
        [GameController sharedInstance].controlIsOnLeft = wPlayLayerNowOnLeft;
		
        if(wPlayLayerNowOnLeft)
            [mSwapMenuItem runAction:[CCRotateTo actionWithDuration:(SWAP_CONTROL_DURATION*1.3f) angle:180.0f]];
        else
            [mSwapMenuItem runAction:[CCRotateTo actionWithDuration:(SWAP_CONTROL_DURATION*1.3f) angle:0.0f]];
        
		[self runAction:
         [CCSpawn actions:
          [CCMoveTo actionWithDuration:SWAP_CONTROL_DURATION position:wPointForControl],
          [CCSequence actions:
           [CCScaleTo actionWithDuration:(SWAP_CONTROL_DURATION/2.0f) scale:0.8f],
           [CCScaleTo actionWithDuration:(SWAP_CONTROL_DURATION/2.0f) scale:1.0f],
           nil], 
          nil]];
        
		[mPlayLayer runAction:[CCMoveTo actionWithDuration:SWAP_CONTROL_DURATION position:wPointForPlay]];
        [[AudioController sharedInstance] playSound:kSwapControlSides];
	}
}


-(void)setLevel:(UInt8)level
{
	// Get stats from GameLevelMaker
	// Update GamePlayLayer with stats
	// Stats are set on each ShaftControl object
	GameLevelMaker *maker = [GameLevelMaker sharedInstance];
	
	[mPlayLayer.transferShaft1 reset];
	[mPlayLayer.transferShaft2 reset];
	[mPlayLayer.transferShaft3 reset];
	[mPlayLayer.transferShaft4 reset];
    
    // OwnElevator is somewhat easy - just set the passengers

    
	[mPlayLayer.ownElevator initializePassengers:maker.passengers];
	[mPlayLayer.ownElevator setToBottomFloor];
    [mPlayLayer.ownElevator setFloorMin:maker.startFloor max:maker.stopFloor];
    	
	// First setup the floors
	[mPlayLayer setFloorMinimum:maker.startFloor maximum:maker.stopFloor];
	
	// Inform the radar display
	[mRadar setFloorMinimum:maker.startFloor maximum:maker.stopFloor];
	
	// Elevator CEO is also easy
	[mPlayLayer.ceoElevator initializePassengers:1];
	
	// First determine how to divide up the total transfer elevators between the available shafts
	// by first getting the truncated value of simple division (truncated)
    
	UInt8 wElsInEach = (UInt8)truncf((maker.numberOfElevators + maker.bonuses) / (NUM_ELEVATOR_SHAFTS-1));
	UInt8 wElsInShaft1 = wElsInEach;
	UInt8 wElsInShaft2 = wElsInEach;
	UInt8 wElsInShaft3 = wElsInEach;
	UInt8 wElsInShaft4 = wElsInEach;
	    
	// Then add the 1 elevator until the modulus (remainder) is gone
    // Remember, an unsigned value won't remain at zero, it overflows
	UInt8 wElsMod = (UInt8)((maker.numberOfElevators + maker.bonuses) % (NUM_ELEVATOR_SHAFTS-1));
    
    while(wElsMod != 0)
    {
        UInt8 wRandShaft = RANDBETWEEN(1, 4);
        switch (wRandShaft) 
        {
            case 1:
                if(wElsInShaft1 + 1 <= MAX_ELS_IN_SHAFT)
                {
                    wElsInShaft1++;
                    wElsMod--;
                }
                break;
            case 2:
                if(wElsInShaft2 + 1 <= MAX_ELS_IN_SHAFT)
                {
                    wElsInShaft2++;
                    wElsMod--;
                }
                break;
            case 3:
                if(wElsInShaft3 + 1 <= MAX_ELS_IN_SHAFT)
                {
                    wElsInShaft3++;
                    wElsMod--;
                }
                break;
            case 4:
                if(wElsInShaft4 + 1 <= MAX_ELS_IN_SHAFT)
                {
                    wElsInShaft4++;
                    wElsMod--;
                }
                break;
            default:
                break;
        }
        
    }
	
	// Set the active number of elevators for each shaft
	[mPlayLayer.transferShaft1 setActiveElevators:wElsInShaft1];
	[mPlayLayer.transferShaft2 setActiveElevators:wElsInShaft2];
	[mPlayLayer.transferShaft3 setActiveElevators:wElsInShaft3];
	[mPlayLayer.transferShaft4 setActiveElevators:wElsInShaft4];
	
	// Set the bonus count for each shaft
	if(maker.bonuses > 0)
	{
		UInt8 wBonusesRemain = maker.bonuses;
		while(wBonusesRemain > 0)
		{
			// Get random number of bonuses to assign and decrement available count
			UInt8 wRand = 1;
			wBonusesRemain -= wRand;
			
			// Assign the random number of bonuses to a random shaft (number of shafts excludes the own elevator)
			UInt8 wRandShaft = RANDBETWEEN(1,(NUM_ELEVATOR_SHAFTS-1));
			switch (wRandShaft) 
			{
				case 1:
					if( (mPlayLayer.transferShaft1.bonusCount + wRand) <= mPlayLayer.transferShaft1.activeElevators)
						mPlayLayer.transferShaft1.bonusCount += wRand;
					else
						wBonusesRemain += wRand;
					break;
				case 2:
					if( (mPlayLayer.transferShaft2.bonusCount + wRand) <= mPlayLayer.transferShaft2.activeElevators)
						mPlayLayer.transferShaft2.bonusCount += wRand;
					else
						wBonusesRemain += wRand;
					break;
				case 3:
					if( (mPlayLayer.transferShaft3.bonusCount + wRand) <= mPlayLayer.transferShaft3.activeElevators)
						mPlayLayer.transferShaft3.bonusCount += wRand;
					else
						wBonusesRemain += wRand;
					break;
				case 4:
					if( (mPlayLayer.transferShaft4.bonusCount + wRand) <= mPlayLayer.transferShaft4.activeElevators)
						mPlayLayer.transferShaft4.bonusCount += wRand;
					else
						wBonusesRemain += wRand;
					break;
				default:
					break;
			}
		}
	}
    
	CCLOG(@"------ setLevel (%d) ----------------", maker.level);
	CCLOG(@" %d shaft 1 bonuses.", mPlayLayer.transferShaft1.bonusCount);
    CCLOG(@" %d shaft 2 bonuses.", mPlayLayer.transferShaft2.bonusCount);
    CCLOG(@" %d shaft 3 bonuses.", mPlayLayer.transferShaft3.bonusCount);
    CCLOG(@" %d shaft 4 bonuses.", mPlayLayer.transferShaft4.bonusCount);
    
    // Note: slotsForElevatorIndex is only valid for non-bonus elevators. In other words, 
    // the index 'q' needs to be reduced by the number of bonuses to accurately function
    for (UInt8 q = 0; q < (wElsInShaft1 + wElsInShaft2 + wElsInShaft3 + wElsInShaft4 - maker.bonuses); q++) 
    {
        CCLOG(@"Elevator slot %d = %d", q, [maker slotsForElevatorIndex:q]);
    }
	CCLOG(@"-------------------------------------------");
	
	// Then set the individual count for each elevator in the shafts
    // To denote a bonus elevator the passenger count will be initialized to UINT8_MAX

    CCArray* wBonusIndexes = [CCArray array];
    
    [GameControlLayer getRandomValues:wBonusIndexes minimum:0 maximum:(wElsInShaft1-1) totalValues:mPlayLayer.transferShaft1.bonusCount];
    
    // Used to match passenger array index
    UInt8 wActualElIndex = 0;
    
    // Get array with random indexes between (0) and (wElsInShaft1 - 1) to use for the bonus elevator

	for(UInt8 elIndex = 0; elIndex < wElsInShaft1; elIndex++)
	{
        Elevator *wEl = [mPlayLayer.transferShaft1.elevatorArray objectAtIndex:elIndex];
        
        // Loop through bonus array and see if current index is matched
        // If matched then mark this as a bonus elevator
        NSNumber* wBonusIndexNumber;
        BOOL wThisIsBonusIndex = NO;
        CCARRAY_FOREACH(wBonusIndexes, wBonusIndexNumber)
        {
            if(wBonusIndexNumber.intValue == elIndex)
                wThisIsBonusIndex = YES;
        }
        
        if(wThisIsBonusIndex)
        {
            CCLOG(@"Initializing Shaft 1 elevator at %d with bonus.",elIndex);
            [wEl initializePassengers:UINT8_MAX]; 
        }
        else 
        {
            CCLOG(@"Initializing Shaft 1 elevator at %d <- %d",elIndex, [maker slotsForElevatorIndex:wActualElIndex]);
            [wEl initializePassengers:[maker slotsForElevatorIndex:wActualElIndex]];
            wActualElIndex++;
        }
	}
    
    [GameControlLayer getRandomValues:wBonusIndexes minimum:0 maximum:(wElsInShaft2-1) totalValues:mPlayLayer.transferShaft2.bonusCount];
    
	for(UInt8 elIndex = 0; elIndex < wElsInShaft2; elIndex++)
	{
		Elevator *wEl = [mPlayLayer.transferShaft2.elevatorArray objectAtIndex:elIndex];
        
        // Loop through bonus array and see if current index is matched
        // If matched then mark this as a bonus elevator
        NSNumber* wBonusIndexNumber;
        BOOL wThisIsBonusIndex = NO;
        CCARRAY_FOREACH(wBonusIndexes, wBonusIndexNumber)
        {
            if(wBonusIndexNumber.intValue == elIndex)
                wThisIsBonusIndex = YES;
        }
        
        if(wThisIsBonusIndex)
        {
            CCLOG(@"Initializing Shaft 2 elevator at %d with bonus.",elIndex);
            [wEl initializePassengers:UINT8_MAX]; 
        }
        else 
        {
            // Adjust for index differences - GameLevelMaker doesn't have a concept of shafts (so add the wElsInShaft1)
            CCLOG(@"Initializing Shaft 2 elevator at %d <- %d",elIndex+wElsInShaft1, [maker slotsForElevatorIndex:wActualElIndex]);
            [wEl initializePassengers:[maker slotsForElevatorIndex:wActualElIndex]];
            wActualElIndex++;
        }
	}

    [GameControlLayer getRandomValues:wBonusIndexes minimum:0 maximum:(wElsInShaft3-1) totalValues:mPlayLayer.transferShaft3.bonusCount];
    
	for(UInt8 elIndex = 0; elIndex < wElsInShaft3; elIndex++)
	{
		Elevator *wEl = [mPlayLayer.transferShaft3.elevatorArray objectAtIndex:elIndex];
        
        // Loop through bonus array and see if current index is matched
        // If matched then mark this as a bonus elevator
        NSNumber* wBonusIndexNumber;
        BOOL wThisIsBonusIndex = NO;
        CCARRAY_FOREACH(wBonusIndexes, wBonusIndexNumber)
        {
            if(wBonusIndexNumber.intValue == elIndex)
                wThisIsBonusIndex = YES;
        }
        
        if(wThisIsBonusIndex)
        {
            CCLOG(@"Initializing Shaft 3 elevator at %d with bonus.",elIndex);
            [wEl initializePassengers:UINT8_MAX]; 
        }
        else 
        {
            // Adjust for index differences - GameLevelMaker doesn't have a concept of shafts (so add the wElsInShaft2)
            CCLOG(@"Initializing Shaft 3 elevator at %d <- %d",elIndex+wElsInShaft1+wElsInShaft2, [maker slotsForElevatorIndex:wActualElIndex]);
            [wEl initializePassengers:[maker slotsForElevatorIndex:wActualElIndex]];
            wActualElIndex++;
        }
	}
    
    [GameControlLayer getRandomValues:wBonusIndexes minimum:0 maximum:(wElsInShaft4-1) totalValues:mPlayLayer.transferShaft4.bonusCount];
    
	for(UInt8 elIndex = 0; elIndex < wElsInShaft4; elIndex++)
	{
		Elevator *wEl = [mPlayLayer.transferShaft4.elevatorArray objectAtIndex:elIndex];
        
        // Loop through bonus array and see if current index is matched
        // If matched then mark this as a bonus elevator
        NSNumber* wBonusIndexNumber;
        BOOL wThisIsBonusIndex = NO;
        CCARRAY_FOREACH(wBonusIndexes, wBonusIndexNumber)
        {
            if(wBonusIndexNumber.intValue == elIndex)
                wThisIsBonusIndex = YES;
        }
        
        if(wThisIsBonusIndex)
        {
            CCLOG(@"Initializing Shaft 4 elevator at %d with bonus.",elIndex);
            [wEl initializePassengers:UINT8_MAX]; 
        }
        else 
        {
            // Adjust for index differences - GameLevelMaker doesn't have a concept of shafts
            CCLOG(@"Initializing Shaft 4 elevator at %d <- %d",elIndex+wElsInShaft1+wElsInShaft2+wElsInShaft3, [maker slotsForElevatorIndex:wActualElIndex]);
            [wEl initializePassengers:[maker slotsForElevatorIndex:wActualElIndex]];
            wActualElIndex++;
        }
	}
	
	// Finally, initialize the shaft
	[mPlayLayer.transferShaft1 initializeShaft];
	[mPlayLayer.transferShaft2 initializeShaft];
	[mPlayLayer.transferShaft3 initializeShaft];
	[mPlayLayer.transferShaft4 initializeShaft];
	
	// Okay...really finally...present the transition scene and we're done
	[mPlayLayer initializeWithLevel];
}

-(void) showPauseMenu
{
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CCLayerColor* wBg = [CCLayerColor layerWithColor:PAUSE_BG_COLOR width:80.0f height:winSize.height];
    [self addChild:wBg z:1000 tag:1000];
    [mMusicItem setIsEnabled:NO];
    [mSoundItem setIsEnabled:NO];
}

-(void) clearPauseMenu
{
    [self removeChildByTag:1000 cleanup:YES];
    [mMusicItem setIsEnabled:YES];
    [mSoundItem setIsEnabled:YES];
}

-(void)setGamePlayLayer:(GamePlayLayer*)layer
{
	mPlayLayer = [layer retain];
	
	// The radar needs to mirror the players in the game layer
	[mRadar setOwnElevator:mPlayLayer.ownElevator ceoElevator:mPlayLayer.ceoElevator];
	[mRadar setShaftElevatorsOn:1 with:mPlayLayer.transferShaft1.elevatorArray];
	[mRadar setShaftElevatorsOn:2 with:mPlayLayer.transferShaft2.elevatorArray];
	[mRadar setShaftElevatorsOn:3 with:mPlayLayer.transferShaft3.elevatorArray];
	[mRadar setShaftElevatorsOn:4 with:mPlayLayer.transferShaft4.elevatorArray];
}

- (void)musicButtonTapped:(id)sender 
{
	CCMenuItem *wItem = [((CCMenuItemToggle *)sender) selectedItem];
	if (wItem == mMusicOnMenuItem) 
		[[AudioController sharedInstance] resumeMusic];
	
	if(wItem == mMusicOffMenuItem)
		[[AudioController sharedInstance] pauseMusic];
}

- (void)soundButtonTapped:(id)sender 
{    
	CCMenuItem *wItem = [((CCMenuItemToggle *)sender) selectedItem];
	if (wItem == mSoundOnMenuItem) 
		[[AudioController sharedInstance] soundOn];
	
	if(wItem == mSoundOffMenuItem)
		[[AudioController sharedInstance] soundOff];
}

@synthesize status = mStatus;

@synthesize radar = mRadar;

+(void) getRandomValues:(CCArray*)array minimum:(UInt8)min maximum:(UInt8)max totalValues:(UInt8)count
{
    // Temp value store (all initialized to -1)
    int wValues[MAX_BONUSES_PER_LEVEL];
    for(UInt8 init = 0; init < MAX_BONUSES_PER_LEVEL; init++)
        wValues[init] = -1;
    
    UInt8 wFound = 0;
    
    if(count != 0)
    {
        while(wFound != count)
        {
            UInt8 wNextValue = (UInt8)RANDBETWEEN(min, max);
            BOOL wNextValueIsDuplicate = NO;
            for(UInt8 i = 0; i < MAX_BONUSES_PER_LEVEL; i++)
            {
                // If wNextValue already exists in wValues array then skip out 
                // of array and generate the next value
                if(wValues[i] == (int)wNextValue)
                {
                    wNextValueIsDuplicate = YES;
                    break;
                }
            }
            if(!wNextValueIsDuplicate)
            {
                wValues[wFound] = wNextValue;
                wFound++;
            }
        }

        // Now sort the array with ascending values
        for(UInt8 a = 0; a < MAX_BONUSES_PER_LEVEL; a++)
        {
            for(UInt8 b = a; b < MAX_BONUSES_PER_LEVEL; b++)
            {
                UInt8 x = wValues[a];
                
                // Swap if necessary
                if(x > wValues[b])
                {
                    wValues[a] = wValues[b];
                    wValues[b] = x;
                }
            }
        }
    }
    
    // Copy from the temp to the destination array
    for(UInt8 i = 0; i < MAX_BONUSES_PER_LEVEL; i++)
        [array replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:wValues[i]]];
}

@end
