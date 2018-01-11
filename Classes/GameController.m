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
#import "GameController.h"
#import "AudioController.h"
#import "GameLayer.h"
#import "GameScore.h"
#import "ElevatorCEOAppDelegate.h"
#import "GCHelper.h"
#import "IAPHelper.h"

static GameController* mInstance = nil;

@implementation GameController

@synthesize controlIsOnLeft;

@synthesize tutorialViewed;

@synthesize gameCenterWasPreviouslyAuthenticated;

@synthesize highScoreArray;

@synthesize adsRemovedByUser;

- (BOOL) setPension:(int)pension withLevel:(int)level
{
    // If the pension or level is zero then escape early - it's not worthy of the top 3
    if(pension == 0)
        return NO;
    
    // Loop through highScoresArray and check if pension exceeds any of the values
    // If one is found then insert a new GameScore object at that index 
    BOOL wFoundHighScore = NO;
    
    // If the highScoreArray is nil, it means there were no previous games loaded
    // Thus, high score by default!
    if(highScoreArray == nil)
        highScoreArray = [[CCArray arrayWithCapacity:MAX_GAME_HIGH_SCORES] retain];
    
    // There's nothing in the array so it's a high score by default
    if(highScoreArray.count == 0)
    {
        // High score by default!
        GameScore* wHigherScore = [GameScore fromDate:[NSDate date] level:level pension:pension];
        [highScoreArray insertObject:wHigherScore atIndex:highScoreArray.count];
        wFoundHighScore = YES;
    }
    
    CCLOG(@"High score array has capacity %lu", (unsigned long)highScoreArray.capacity);
    CCLOG(@"High score array has count %lu", (unsigned long)highScoreArray.count);
    
    for(UInt8 i = 0; (i < highScoreArray.capacity) && !wFoundHighScore && (i <= (MAX_GAME_HIGH_SCORES - 1)); i++)
    {
        if(i <= (highScoreArray.count - 1))
        {
            // Compare against existing scores
            GameScore* wExistingScore = (GameScore*)[highScoreArray objectAtIndex:i];
            CCLOG(@"   Found existing score pension %d", (int)wExistingScore.pension);
            if(wExistingScore.pension <= pension)
            {
                // Found a high score!
                wFoundHighScore = YES;
                GameScore* wHigherScore = [GameScore fromDate:[NSDate date] level:level pension:pension];
                [highScoreArray insertObject:wHigherScore atIndex:i];
            }
        }
        else
        {
            CCLOG(@"   i exceeded highScoreArray.count so it's a high score!");
            // i >= highScoreArray.count and we haven't found a high score yet then just insert
            wFoundHighScore = YES;
            GameScore* wHigherScore = [GameScore fromDate:[NSDate date] level:level pension:pension];
            [highScoreArray insertObject:wHigherScore atIndex:i];
        }
    }
    
    // Clean up any scores beyond the allowable limit
    if(highScoreArray.count > MAX_GAME_HIGH_SCORES)
        [highScoreArray removeObjectAtIndex:MAX_GAME_HIGH_SCORES];
    
    return wFoundHighScore;
}

- (void) setDefaultAppSettings
{
	NSDictionary *wAppDefaults = [NSDictionary
                                  dictionaryWithObjects:[NSArray arrayWithObjects:
                                                         [NSNumber numberWithBool:YES], 
                                                         [NSNumber numberWithChar:0],
                                                         [NSNumber numberWithBool:NO],
                                                         nil]
								 forKeys:[NSArray arrayWithObjects:
										  @"controlIsOnLeft",      // Default location of user controls
                                          @"tutorialViewed", // Tutorial has been completely viewed (up to CEO tip)
                                          @"gameCenterWasAuthenticated",
										  nil]];
    [[NSUserDefaults standardUserDefaults] registerDefaults:wAppDefaults];
}

- (void) saveAppSettings
{
    CCLOG(@">>>> SAVING Elevator CEO app settings to NSUserDefaults <<<<");
	[[NSUserDefaults standardUserDefaults] setBool:self.controlIsOnLeft forKey:@"controlIsOnLeft"];
    [[NSUserDefaults standardUserDefaults] setBool:self.tutorialViewed forKey:@"tutorialViewed"];
    GCHelper* gcHelper = (GCHelper*)[GCHelper sharedGCHelper];
    [[NSUserDefaults standardUserDefaults] setBool:gcHelper.gameCenterFeaturesEnabled forKey:@"gameCenterWasAuthenticated"];
    [GameScore saveGameScoresLocally:self.highScoreArray];
}

- (void) restoreAppSettings
{
    CCLOG(@">>>> RESTORING Elevator CEO app settings to NSUserDefaults <<<<");
	self.controlIsOnLeft = [[NSUserDefaults standardUserDefaults] boolForKey:@"controlIsOnLeft"];
    self.tutorialViewed = [[NSUserDefaults standardUserDefaults] integerForKey:@"tutorialViewed"];
    self.gameCenterWasPreviouslyAuthenticated = [[NSUserDefaults standardUserDefaults] boolForKey:@"gameCenterWasAuthenticated"];
    
    // Get all locally stored game scores (if any)
    self.highScoreArray = [[GameScore loadGameScoresLocally] retain];
    
    self.adsRemovedByUser = [[NSUserDefaults standardUserDefaults] boolForKey:IAP_REMOVE_ADS_KEY];
}

- (void) debug: (BOOL)on
{
	if(on)
	{
		mIsDebugging = YES;
		[CCDirector sharedDirector].displayFPS = YES;
	}
	else 
	{
		mIsDebugging = NO;
		[CCDirector sharedDirector].displayFPS = NO;
	}
}

-(CGRect)gamingAreaRectForPlay:(BOOL)playing
{
    CGSize wSize = [CCDirector sharedDirector].winSize;
    CGRect wRect = CGRectZero;
    
    if(self.adsRemovedByUser)
    {
        // Full size gaming!
        wRect = CGRectMake(0.0f, 0.0f, wSize.width, wSize.height);
    }
    else
    {
        // Only display ads during game play
        if(playing)
        {
            if(self.is16x9Device)
            {
                wRect = CGRectMake(GAMING_START_LOCATION_X, VERTICAL_AD_SPACE, HORIZONTAL_MAX_SIZE, VERTICAL_MAX_SIZE - VERTICAL_AD_SPACE);
            }
            else
            {
                wRect = CGRectMake(GAMING_START_LOCATION_X, 0.0f, HORIZONTAL_MAX_SIZE, VERTICAL_MIN_SIZE);
            }
        }
        else
        {
            if(self.is16x9Device)
            {
                wRect = CGRectMake(GAMING_START_LOCATION_X, 0.0f, HORIZONTAL_MAX_SIZE, VERTICAL_MAX_SIZE);
            }
            else
            {
                // At this point it's an older device
                wRect = CGRectMake(GAMING_START_LOCATION_X, 0.0f, HORIZONTAL_MAX_SIZE, VERTICAL_MIN_SIZE);
            }
        }
    }
    
    return wRect;
}

-(CGRect)gamingAreaRect
{
    return [self gamingAreaRectForPlay:NO];
}

-(CGRect) adAreaRect
{
    CGRect wRect = CGRectZero;
    
    if(self.adsRemovedByUser)
        return wRect;
    
    // Only display ads during game play on 16x9 devices
    if(self.is16x9Device)
        wRect = CGRectMake(0, 0, HORIZONTAL_MAX_SIZE, VERTICAL_AD_SPACE);

    return wRect;
}

@synthesize isPaused = mIsPaused;

@synthesize isDebugging = mIsDebugging;

- (BOOL) isPlaying
{
    CCDirector* dir = [CCDirector sharedDirector];
    if([dir.runningScene isKindOfClass:[GameLayer class]])
        return YES;
    else
        return NO;
}

- (BOOL) is16x9Device
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    //if( (size.width == 320) && (size.height >= 568) )
    if( size.height >= 568 )
        return YES;
    else
        return NO;
}

- (BOOL) is16x9
{
    CGSize size = [[CCDirector sharedDirector] winSize];
    
    if(!self.adsRemovedByUser)
        return NO;
    
    if( (size.width == 320) && (size.height >= 568) )
        return YES;
    else
        return NO;
}

-(void)removeAds
{
    [self animateAdBannerIntoView:NO];
    self.adsRemovedByUser = YES;
}

-(BOOL)shouldDisplayAd
{
    // Always return fast if the user bought an ad-free
    if(self.adsRemovedByUser)
        return NO;
    
    if(self.isPlaying && self.adLoaded)
        return YES;
    
    return NO;
}

@synthesize adVisible = mAdVisible;

@synthesize adLoaded = mAdBannerLoaded;

-(void)animateAdBannerIntoView:(BOOL)intoView
{
    [self animateAdBannerIntoView:intoView withDuration:AD_TRANSITION_ANIMATION_SEC];
}

-(void)animateAdBannerIntoView:(BOOL)intoView withDuration:(double)duration
{
    // Don't hide if the request is meaningless
    if(intoView == mAdVisible)
        return;
    
    id<UIApplicationDelegate> wDelegate = [UIApplication sharedApplication].delegate;
    if([wDelegate isKindOfClass:[ElevatorCEOAppDelegate class]])
    {
        ElevatorCEOAppDelegate* wElevatorCeo = (ElevatorCEOAppDelegate*)wDelegate;
        [wElevatorCeo animateAdBannerIntoView:intoView withDuration:duration];
        mAdVisible = intoView;
    }
}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    CCLOG(@"Tried to load an ad to make some money!!");
    mAdBannerLoaded = YES;
    
    if(self.shouldDisplayAd)
    {
        // Plant the money tree and make some cash!
        [self animateAdBannerIntoView:YES];
    }
}

-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    // Only pause the game if play is ongoing, otherwise just
    if(self.isPlaying)
    {
        [self pause:YES];
    }
    
    return YES;
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    // Aww, no money
    CCLOG(@"Tried to load an ad banner but got the error: %@", error.description);
    
    mAdBannerLoaded = NO;
    
    // iAd requires the banner be hidden until another one is available
    [self animateAdBannerIntoView:NO];
}

-(UIViewController*) rootViewController
{
    id<UIApplicationDelegate> wDelegate = [UIApplication sharedApplication].delegate;
    if([wDelegate isKindOfClass:[ElevatorCEOAppDelegate class]])
    {
        ElevatorCEOAppDelegate* wElevatorCeo = (ElevatorCEOAppDelegate*)wDelegate;
        return (UIViewController*)wElevatorCeo.rootViewController;
    }
    
    return nil;
}

+(BOOL) isChineseLang
{
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    return [language isEqualToString:@"zh-Hans"];
}

+(BOOL) isChineseLocale
{
    NSString* wLocale = [[NSLocale currentLocale] localeIdentifier];
    NSRange wRange = [wLocale rangeOfString:@"zh"];
    return (wRange.length == 2);
}

+(NSString*) selectFont:(CeoFonts)font forceDefault:(BOOL)force
{
    NSString* wFontFile;
    
    switch(font)
    {
            // Used for values of text fields under Synergy, Pension, etc.
        case kDroidSans11White:
            wFontFile = @"DroidSans-11-White.fnt";
            break;
            
            // Used for tutorial tips
        case kDroidSansBold11Black:
            if([GameController isChineseLang] && !force)
                wFontFile = @"STHeiti-13-Black.fnt";
            else
                wFontFile = @"DroidSans-Bold-11-Black.fnt";
            break;
            
            // Used for floor numbers on each floor section
        case kDroidSansBold12White:
            wFontFile = @"DroidSans-Bold-12-White.fnt";
            break;
            
            // Used for Game Status text fields like Synergy, Pension, etc, and for floor countdown on Radar Bonus, also for credits text)
        case kDroidSansBold13White:
            if([GameController isChineseLang] && !force)
                wFontFile = @"STHeiti-13-White.fnt";
            else
                wFontFile = @"DroidSans-Bold-13-White.fnt";
            break;
            
            // Used for elevator passenger count
        case kDroidSansBold20Black:
            wFontFile = @"DroidSans-Bold-20-Black.fnt";
            break;
            
            // Used for primary and secondary menu items
        case kDroidSansBold28White:
            if([GameController isChineseLang] && !force)
                wFontFile = @"STHeiti-30-White.fnt";
            else
                wFontFile = @"DroidSans-Bold-28-White.fnt";
            break;
            
            // Used for floor display on transition, score values on Scores screen, result on Game Over screen)
        case kLeague24White:
            if([GameController isChineseLang] && !force)
                wFontFile = @"STHeiti-24-White.fnt";
            else
                wFontFile = @"League-24-White.fnt";
            break;
            
            // Used for "Level" label on transition screen, Game Over, and game title "Elevator Chief Executive Officer"
        case kLeague72White:
            if([GameController isChineseLang] && !force)
                wFontFile = @"STHeiti-82-White.fnt";
            else
                wFontFile = @"League-72-White.fnt";
            break;
            
        default:
            break;
    }
    
    return wFontFile;
}

+(NSString*) selectFont:(CeoFonts)font
{
    return [GameController selectFont:font forceDefault:NO];
}

+ (NSString *)convertToAscii:(NSString *)unicode
{
    NSData* dataFormatted = [unicode dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    return [[NSString alloc] initWithData:dataFormatted encoding:NSASCIIStringEncoding];
}

- (void) togglePause
{
    if(mIsPaused)
    {
        // Remove pause
        
        [[CCDirector sharedDirector] resume];
        CCNode* wGame = [CCDirector sharedDirector].runningScene;
        
        if([wGame isKindOfClass:[GameLayer class]])
        {
            // Cast wGame as GameLayer and control pause
            GameLayer* wLayer = (GameLayer*)wGame;
            [wLayer pause:NO];
        }
        
        [[AudioController sharedInstance] resume];
        mIsPaused = NO;
    }
    else
    {
        // Activate pause
        
        CCNode* wGame = [CCDirector sharedDirector].runningScene;
        
        if([wGame isKindOfClass:[GameLayer class]])
        {
            // Cast wGame as GameLayer and control pause
            GameLayer* wLayer = (GameLayer*)wGame;
            [wLayer pause:YES];
        }
        
        [[CCDirector sharedDirector] pause];
        [[AudioController sharedInstance] pause];
        mIsPaused = YES;
    }
}

- (void) pause:(BOOL)pause
{
    if(mIsPaused != pause)
    {
        [self togglePause];
    }
}

-(id) init
{
    if( (self=[super init] )) 
	{
        mAdVisible = NO;
        mAdBannerLoaded = NO;
        mIsPaused = NO;
        mShouldDisplayAd = NO;
		CCLOG(@"+++INIT %@", self);
	}
	
	return self;
}

+ (GameController*)sharedInstance
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

+ (id)allocWithZone:(NSZone *)zone 
{
    @synchronized(self) 
	{
        if (mInstance == nil) 
		{
            mInstance = [super allocWithZone:zone];
			
			// Perform other initialization here
			[[AudioController sharedInstance] soundOn];
            
            [[IAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products){
                if(success)
                {
                    CCLOG(@"IAP product list was retrieved.");
                }
                else
                {
                    CCLOG(@"IAP product list was NOT retrieved.");
                }
            }];
			
            return mInstance;
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain 
{
    return self;
}

- (unsigned)retainCount 
{
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release 
{
    //do nothing
}

- (id)autorelease 
{
    return self;
}

@end
