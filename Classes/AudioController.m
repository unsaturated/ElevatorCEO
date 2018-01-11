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

#import "cocos2d.h"
#import "AudioController.h"
#import "GameController.h"

static AudioController* mInstance = nil;

@implementation AudioController

-(void) pause
{
    [[CDAudioManager sharedManager] pauseBackgroundMusic];
}

-(void) resume
{
    // Only resume music if it wasn't paused
    if(!mMusicWasPaused && [GameController sharedInstance].isPlaying)
        [[CDAudioManager sharedManager] resumeBackgroundMusic];
}

-(void) pauseMusic
{
    mMusicWasPaused = YES;
	[[CDAudioManager sharedManager] pauseBackgroundMusic];
}

-(void) resumeMusic
{
    mMusicWasPaused = NO;
	[[CDAudioManager sharedManager] resumeBackgroundMusic];
}

-(void) soundOn
{
	[SimpleAudioEngine sharedEngine].mute = NO;
}

-(void) soundOff
{
	[SimpleAudioEngine sharedEngine].mute = YES;
}

-(BOOL) isSoundOn
{
	return ![SimpleAudioEngine sharedEngine].mute;
}

-(void) musicOn
{
	if (![self isMusicOn]) 
	{
		[[CDAudioManager sharedManager] rewindBackgroundMusic];
        [mSae playBackgroundMusic:@"happyelevator.caf" loop:YES];

		//[[CDAudioManager sharedManager] resumeBackgroundMusic];
	}
}

-(void) musicOff
{
	if ([self isMusicOn]) 
	{
		[[CDAudioManager sharedManager] stopBackgroundMusic];
	}
}

-(BOOL) isMusicOn
{
    return [CDAudioManager sharedManager].isBackgroundMusicPlaying;
}

-(void) playSound:(SoundEffect) effect
{
    if(!self.isSoundOn)
        return;
    
	switch (effect) 
	{
        case kInvalidElevatorButton:
            [mInvalidElevatorButton play];
            break;
        case kPensionBonus:
            [mPensionBonus play];
            break;
        case kNewLevelTransition:
            [mNewLevelTransition play];
            break;
		case kTapElevatorButton:
			[mTapElevatorButton play];
			break;
        case kElevatorCrash:
            [mElevatorCrash play];
            break;
        case kElevatorMoving:
            mElevatorMoving.looping = YES;
            mElevatorMoving.gain = 1.1f;
            [mElevatorMoving play];
            break;
        case kElevatorStopping:
            [mElevatorStopping play];
            break;
        case kElevatorStarting:
            [mElevatorStarting play];
            break;            
        case kTreasureChestOpening:
            [mTreasureChestOpening play];
            break;
        case kIntroLoop:
            mIntroLoop.looping = YES;
            mIntroLoop.gain = 1.0f;
            [mIntroLoop play];
            break;
		case kClickMenuButton:
			[mClickMenuButton play];
			break; 
        case kNoRadarBonus:
            [mNoRadarBonus play];
            break;
        case kLifeBonus:
            [mLifeBonus play];
            break;
        case kSynergyBonus:
            [mSynergyBonus play];
            break;
        case kBooster:
            [mBooster play];
            break;
        case kRecoverRadar:
            [mRecoverRadar play];
            break;
        case kStinger:
            mStinger.gain = 0.5f;
            [mStinger play];
            break;
        case kPassengerBonus:
            [mPassengerBonus play];
            break;
        case kSwapControlSides:
            //mSwapControlSides.looping = YES;
            //mSwapControlSides.gain = 0.0f;
            [mSwapControlSides play];
            //[CDXPropertyModifierAction fadeSoundEffect:2.0f finalVolume:1.0f curveType:kIT_SCurve shouldStop:YES effect:mSwapControlSides];
            break;
        case kLowSynergyWarning:
            [mLowSynergyWarning play];
            break;
		default:
			// Don't play anything
			break;
	}
}

-(void) playNewLevelTransition
{
    [self playSound:kNewLevelTransition];
}

-(void) stopSound:(SoundEffect) effect
{
    switch (effect)
    {
        case kIntroLoop:
            [CDXPropertyModifierAction fadeSoundEffect:1.0f finalVolume:0.0f curveType:kIT_SCurve shouldStop:YES effect:mIntroLoop];
            break;
        case kElevatorMoving:
            [mElevatorMoving stop];
            break;
        default:
            break;
    }
}

#pragma mark Delegate Methods  _______________________

-(void) cdAudioSourceDidFinishPlaying:(CDLongAudioSource *)audioSource
{
}


#pragma mark Singleton Methods ______________________________________

-(id) init
{
    if( (self=[super init]) ) 
    {        
        mSae = [SimpleAudioEngine sharedEngine];
        mActionManager = [CCActionManager sharedManager];
        mMusicWasPaused = NO;
                
        // Let the user's music take priority if it's playing
        [CDAudioManager configure:kAMM_FxPlusMusicIfNoOtherAudio];
        
        // Resume music when the app is resumed
        [[CDAudioManager sharedManager] setResignBehavior:kAMRBStopPlay autoHandle:YES];
        
        
        // Background Music
        // ------------------
        [mSae preloadBackgroundMusic:@"happyelevator.caf"];
        mSae.backgroundMusicVolume = 0.5f;
        
        
        // Sound effects
        // ------------------
        // Set fx volume to 100%
        mSae.effectsVolume = 1.0f;
        
        // Preload all the effects here
        [mSae preloadEffect:@"menubutton.wav"];
        mClickMenuButton = [[mSae soundSourceForFile:@"menubutton.wav"] retain];
        
        [mSae preloadEffect:@"swap.wav"];
        mSwapControlSides = [[mSae soundSourceForFile:@"swap.wav"] retain];
        
        [mSae preloadEffect:@"elevator-button.wav"];
        mTapElevatorButton = [[mSae soundSourceForFile:@"elevator-button.wav"] retain];
        
        [mSae preloadEffect:@"rocket.wav"];
        mBooster = [[mSae soundSourceForFile:@"rocket.wav"] retain];
        
        [mSae preloadEffect:@"recharge-big.wav"];
        mLifeBonus = [[mSae soundSourceForFile:@"recharge-big.wav"] retain];
        
        [mSae preloadEffect:@"recharge-small.wav"];
        mSynergyBonus = [[mSae soundSourceForFile:@"recharge-small.wav"] retain];
        
        [mSae preloadEffect:@"successful.wav"];
        mPassengerBonus = [[mSae soundSourceForFile:@"successful.wav"] retain];
        
        [mSae preloadEffect:@"glockenspiel.wav"];
        mTreasureChestOpening = [[mSae soundSourceForFile:@"glockenspiel.wav"] retain];
        
        [mSae preloadEffect:@"buzzer.wav"];
        mInvalidElevatorButton = [[mSae soundSourceForFile:@"buzzer.wav"] retain];
        
        [mSae preloadEffect:@"coins.wav"];
        mPensionBonus = [[mSae soundSourceForFile:@"coins.wav"] retain];
        
        [mSae preloadEffect:@"powerdown.wav"];
        mNoRadarBonus = [[mSae soundSourceForFile:@"powerdown.wav"] retain];
        
        [mSae preloadEffect:@"dingdong.wav"];
        mNewLevelTransition = [[mSae soundSourceForFile:@"dingdong.wav"] retain];

        [mSae preloadEffect:@"stinger.wav"];
        mStinger = [[mSae soundSourceForFile:@"stinger.wav"] retain];
        
        [mSae preloadEffect:@"livemusic.caf"];
        mIntroLoop = [[mSae soundSourceForFile:@"livemusic.caf"] retain];
        
        [mSae preloadEffect:@"warning.wav"];
        mLowSynergyWarning = [[mSae soundSourceForFile:@"warning.wav"] retain];
        
        [mSae preloadEffect:@"elevator-crash.wav"];
        mElevatorCrash = [[mSae soundSourceForFile:@"elevator-crash.wav"] retain];

        [mSae preloadEffect:@"elevator-startup.wav"];
        mElevatorStarting = [[mSae soundSourceForFile:@"elevator-startup.wav"] retain];
        
        [mSae preloadEffect:@"elevator-hum.wav"];
        mElevatorMoving = [[mSae soundSourceForFile:@"elevator-hum.wav"] retain];
        
        [mSae preloadEffect:@"elevator-shutdown.wav"];
        mElevatorStopping = [[mSae soundSourceForFile:@"elevator-shutdown.wav"] retain];
        
        [mSae preloadEffect:@"staticdischarge.wav"];
        mRecoverRadar = [[mSae soundSourceForFile:@"staticdischarge.wav"] retain];
    }
    
    return self;
}

-(void) dealloc 
{
	//Stop any actions we may have started
	[mActionManager removeAllActionsFromTarget:mClickMenuButton];
	[mActionManager removeAllActionsFromTarget:[[CDAudioManager sharedManager] audioSourceForChannel:kASC_Left]];
    
	//This is to stop any actions that may be running against the sound engine i.e. fade sound effects
	[mActionManager removeAllActionsFromTarget:[CDAudioManager sharedManager].soundEngine];
    
	//Release all our retained objects
	[mClickMenuButton release];
    [mSwapControlSides release];
    [mTapElevatorButton release];
    [mBooster release];
    [mLifeBonus release];
    [mSynergyBonus release];
    [mPassengerBonus release];
    [mTreasureChestOpening release];
    [mInvalidElevatorButton release];
    [mPensionBonus release];
    [mNoRadarBonus release];
    [mNewLevelTransition release];
    [mStinger release];
    [mIntroLoop release];
    [mLowSynergyWarning release];
    [mElevatorCrash release];
    [mElevatorStarting release];
    [mElevatorMoving release];
    [mElevatorStopping release];
    [mRecoverRadar release];
    
	[mSourceFader release];
	[mFaderAction release];
    
	//Tell the simple audio engine to shutdown
	[SimpleAudioEngine end];
	mSae = nil;
    
	[super dealloc];
}	


+(AudioController*) sharedInstance
{
	if(mInstance)
		return mInstance;
	
    @synchronized(self)
    {
        if (mInstance == nil)
			mInstance = [[self alloc] init];
    }
    return mInstance;
}

+(id) allocWithZone:(NSZone *)zone 
{
    @synchronized(self) 
	{
        if (mInstance == nil) 
		{
            mInstance = [super allocWithZone:zone];
			

			
            return mInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

-(id) copyWithZone:(NSZone *)zone
{
    return self;
}

-(id) retain 
{
    return self;
}

-(unsigned) retainCount 
{
    return UINT_MAX;  // denotes an object that cannot be released
}

-(void) release 
{
    //do nothing
}

-(id) autorelease 
{
    return self;
}

@end
