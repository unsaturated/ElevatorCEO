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

// iTunesConnect Data
// ----------------------------------------------
#define SCORE_ARCHIVE_KEY  @"com.unsaturated.elevatorceo.highscores"
#define IAP_REMOVE_ADS_KEY @"com.unsaturated.elevatorceo.removeads"
// ----------------------------------------------

// Global Events
// ----------------------------------------------
#define IAP_PURCHASE_SUCCESS_NOTIFICATION @"IAPPurchaseSuccessNotification"
#define IAP_PURCHASE_INPROG_NOTIFICATION  @"IAPPurchaseInProgNotification"
#define IAP_PURCHASE_FAILED_NOTIFICATION  @"IAPPurchaseFailedNotification"
// ----------------------------------------------

// Utilized fonts
typedef enum
{
    kDroidSans11White,
    kDroidSansBold11Black,
    kDroidSansBold12White,
    kDroidSansBold13White,
    kDroidSansBold20Black,
    kDroidSansBold28White,
    kLeague24White,
    kLeague72White
} CeoFonts;

// Overall Transition and Animation Properties
// ----------------------------------------------
#define TRANSITION_DURATION          1.2f
#define SWAP_CONTROL_DURATION        0.3f
#define TRANSITION_LAYER_DISPLAY_SEC 5.0f
#define TRANSITION_DELAY_AFTER_CEO   2.5f
#define CREDIT_FADE_SEC              0.5f
#define CREDIT_HANG_SEC              4.5f
#define PENSION_ANIMATION_SEC        0.7f
#define AD_TRANSITION_ANIMATION_SEC  0.8f
// ----------------------------------------------

// Device-specific Properties
// ----------------------------------------------
#define VERTICAL_BUMP_FOR_16X9        30
#define VERTICAL_AD_SIZE              50
#define VERTICAL_MAX_SIZE             568
#define VERTICAL_MIN_SIZE             480
#define VERTICAL_AD_SPACE             (VERTICAL_MAX_SIZE - VERTICAL_MIN_SIZE)
#define HORIZONTAL_MAX_SIZE           320
#define GAMING_START_LOCATION_X       0
// ----------------------------------------------

// Tutorial
// ----------------------------------------------
#define TUTORIAL_ANIMATION_SEC  0.2f
// Ensure tutorial tip is shown after the level transition
// plus a short duration that's greater than AC_NEW_LEVEL_DURATION
#define TUTORIAL_DISPLAY_DELAY_SEC (TRANSITION_LAYER_DISPLAY_SEC + 4.2f)
// ----------------------------------------------


// Pension Properties
// ----------------------------------------------
#define GAME_MIN_PENSION                 0.0f
#define GAME_MAX_PENSION          95000000.0f
#define GAME_MIN_RATE_APP_PENSION    29999.9f
// ----------------------------------------------


// Up-Down Button Properties
// ----------------------------------------------
#define BUTTON_MAX_UP_VALUE    8
#define BUTTON_MAX_DOWN_VALUE  8
#define BUTTON_MAX_TAP_TIME    0.3f
#define BUTTON_TIME_INTERVAL   0.5f
#define SPEED_FOR_BUTTON_TAP   2
#define BUTTON_MIN_SPEED       3
// ----------------------------------------------


// Life Indicators
// ----------------------------------------------
#define NUM_LIFE_INDICATORS       3
#define GAME_STARTING_LIVES       3
#define NUM_BLINKS_LIFE_DECREASE 10
#define LIFE_INDICATOR_BLINK_TIME 1.0f
// ----------------------------------------------

// Radar Indicator
// ----------------------------------------------
#define NUM_BLINKS_RADAR_HIDDEN 10
#define RADAR_INDICATOR_BLINK_TIME 1.0f
#define NUM_NO_RADAR_INDICATORS 8
#define RADAR_LOCK_DISPLAY_SEC 2.0f
#define CEO_RADAR_FLASH_SEC 0.5f
// ----------------------------------------------

// Game Play Area Layout
// ----------------------------------------------
#define PLAY_AREA_MARGIN      4
#define NUM_LEVEL_SPRITES_PER_SCREEN       8
#define NUM_LEVEL_SPRITES_PER_SCREEN_16x9 10
#define NUM_LEVEL_SPRITES   (NUM_LEVEL_SPRITES_PER_SCREEN + 4)
#define NUM_LEVEL_SPRITES_16x9  (NUM_LEVEL_SPRITES_PER_SCREEN_16x9 + 4)
#define FLOOR_HEIGHT         60.0f
#define FLOORS_PER_SCREEN                  8
#define FLOORS_PER_SCREEN_16x9            10
#define BEGIN_SCROLL_UP_ON_FLOOR   5
#define BEGIN_SCROLL_UP_ON_FLOOR_16x9   6
#define BEGIN_SCROLL_DOWN_ON_FLOOR 4
#define BEGIN_SCROLL_DOWN_ON_FLOOR_16x9 5
#define ELEVATOR_SHAFT_WIDTH 48
#define NUM_ELEVATOR_SHAFTS   5
#define FLOOR_BOTTOM_GAP      4.0f
#define PAUSE_BG_COLOR        ccc4(0, 0, 0, 125)
// ----------------------------------------------


// Synergy Indicator Properties
// ----------------------------------------------
#define RED_SYNERGY_BARS    4
#define YELLOW_SYNERGY_BARS 5
#define GREEN_SYNERGY_BARS 10
#define GRAY_SYNERGY_BARS  (RED_SYNERGY_BARS + YELLOW_SYNERGY_BARS + GREEN_SYNERGY_BARS)
#define COLOR_SYNERGY_BARS (RED_SYNERGY_BARS + YELLOW_SYNERGY_BARS + GREEN_SYNERGY_BARS)
#define LOW_SYNERGY_COUNT   4
#define COUNT_SYNERGY_BARS (RED_SYNERGY_BARS + YELLOW_SYNERGY_BARS + GREEN_SYNERGY_BARS)
// ----------------------------------------------


// Elevators Properties 
// ---------------------------------------------
#define MAX_TRANSFER_EL_SPEED    BUTTON_MAX_UP_VALUE
#define MIN_TRANSFER_EL_SPEED    3
#define ELEVATOR_SETTLE_TIME     0.6f
#define NUM_BARS_TRANSFER_TIME   8
// ----------------------------------------------


// Transfer Elevator Shaft Properties
// ----------------------------------------------
#define MIN_FLOORS_BETWEEN_ELS   2
#define MAX_FLOOR_DIFF           8
#define MAX_ELS_IN_SHAFT         6
#define MIN_PAUSE_AT_FLOOR       3.0f
#define MAX_PAUSE_AT_FLOOR       5.0f
#define TRANSFER_PAUSE_INCREMENT 0.2f
// ----------------------------------------------


// Level-based Properties
// ----------------------------------------------
#define POSSIBLE_BONUSES 6

#define HEART_P     0.05f
#define PENSION_P   0.25f
#define DEATH_P     0.05f
#define PASSENGER_P 0.30f
#define NO_RADAR_P  0.10f
#define SYNERGY_P   0.25f

#define STARTING_SYNERGY 100.0f
// ----------------------------------------------


// Translation from Elevator Design Spreadsheet
// ----------------------------------------------

#define STARTING_LEVEL      1
#define MAX_ELEVATORS	   24
#define MAX_PASSENGERS	   99
#define INITIAL_PASSENGERS	6
#define LEVEL_PASSENGER_BUMP_DIVISOR  5
#define LEVEL_SLOT_DECREASE_DIVISOR	  4
#define STARTING_SLOT_BUFFER         10
#define POSSIBLE_TRANSFERS_MULTIPLIER 1.4f
#define SLOT_LEVEL_MULTIPLIER	      0.5f
#define TRANSFER_VALUE	         1250
#define EVEN_START_PERCENTAGE  0.8f
#define ODD_START_PERCENTAGE   0.8f
#define START_FLOOR 1
#define INITIAL_FLOORS  50
#define FLOOR_INCREMENT_PERCENT	0.11f
#define FLOOR_INCREMENT_FOR_PASSENGER_BUMP	0.2f
#define INITIAL_ELEVATORS	    7
#define ELEVATOR_BUMP_DIVISOR	4
#define ELEVATOR_BUMP_INCREMENT 3
#define CEO_STOP_DIVISOR 120
#define CEO_STOP_TIME_MAX_SECONDS 10.0f
#define CEO_STOP_TIME_MIN_SECONDS  2.0f
#define BONUSES_BEGIN_AT_LEVEL 2
#define MAX_BONUSES_PER_LEVEL  2
#define MAX_BONUS_PASSENGER 2
#define MIN_BONUS_PASSENGER 1
#define MIN_PENSION_BONUS 2000
#define PENSION_BONUS_MULTIPLIER 1.2f
#define RADAR_FLOORS_HIDDEN_MIN 10
#define RADAR_FLOOR_HIDDEN_MULTIPLIER 0.10f
#define SYNERGY_BONUS 10
#define SYNERGY_BUMP 1.5f
#define SYNERGY_PER_FLOOR 0.575f
#define BUTTON_SPEED_FLOOR_DIVISOR 5
// ----------------------------------------------


// Game Extras like Scores and More -------------
#define MAX_GAME_HIGH_SCORES 3

// Functions
// ----------------------------------------------
#define POSITIVEF(x) ((x) < 0.0f) ? (x) * -1.0f : (x)
#define MROUND(x,rn) (((UInt16)((x) / (rn)) + 0.5f) * rn)
#define RANDBETWEEN(min,max) ((UInt16)((arc4random() % ((max)-(min)+1)) + min))
#define ISBETWEEN(minInclusive,maxExclusive,value) ( ((value) >= minInclusive) && ((value) < maxExclusive) )
#define EVEN(x) (UInt16) ((x) % 2 == 0) ? (x) : (x)++
#define ODD(x) (UInt16) ((x) % 2 == 0) ? (x++) : (x)
#define ISEVEN(x) ((x) % 2 == 0) ? YES : NO
#define ISODD(x) ((x) % 2 == 0) ? NO : YES
// ----------------------------------------------




@interface GameController : NSObject <ADBannerViewDelegate>
{
	@private 
	BOOL mIsDebugging;
    BOOL mIsPaused;
    BOOL mShouldDisplayAd;
    BOOL mAdVisible;
    BOOL mAdBannerLoaded;
}

/**
 Gets or sets the location of the user controls. This does
 not change the location during runtime. It is only used
 for storing the location.
 */
@property (nonatomic, readwrite) BOOL controlIsOnLeft;

/**
 * Gets or sets whether the tutorial has been fully viewed.
 */
@property (nonatomic, readwrite) char tutorialViewed;

/**
 * Gets whether Game Center was previously authenticated. There is no guarantee
 * when the app is restored that authentication is still valid. This property 
 * is used for a smarter re-authentication timing.
 */
@property (nonatomic, readwrite) BOOL gameCenterWasPreviouslyAuthenticated;

/**
 Gets the array containing up to the top three high scores GameScore objects.
 */
@property (nonatomic, retain) CCArray* highScoreArray;

/**
 Records the pension and high level for a game if it's within the top three.
 It uses the current date.
 @param pension Pension to set
 @param level Level to set
 @return Yes if the pension is in the top three.
 */
- (BOOL) setPension:(int)pension withLevel:(int)level;

/**
 Sets the default game settings in the local user dictionary.
 */
- (void) setDefaultAppSettings;

/**
 Saves the game settings in the local user dictionary.
 */
- (void) saveAppSettings;

/**
 Restores settings to the GameController using the local user dictionary.
 */
- (void) restoreAppSettings;

/**
 * Turns debugging on or off.
 * @param on Set to YES to activate debugging.
 */
- (void) debug: (BOOL)on;

/**
 * Toggles the state of game pause.
 */
- (void) togglePause;

/**
 * Sets the game's pause status.
 * @param pause Set to YES to pause
 */
- (void) pause:(BOOL)pause;

/**
 * Gets whether game is paused.
 * @return YES if paused
 */
@property (nonatomic, readonly) BOOL isPaused;

/**
 * Gets whether the controller is in debug mode.
 */
@property (nonatomic, readonly) BOOL isDebugging;

/**
 * Gets whether the game is in the GameLayer. If so, then 
 * the user should have control over resuming the GameDirector
 * since there is no pause menu.
 */
@property (nonatomic, readonly) BOOL isPlaying;

/**
 * Gets whether the device is returning the new iPhone 5 screen ratio.
 * This returns a value independent of features like ads or similar.
 */
@property (nonatomic, readonly) BOOL is16x9Device;

/**
 * Gets whether the device is returning the new iPhone 5 screen ratio. If ad
 * banners should be displayed then it always returns NO.
 * Supported screen point sizes are: points  | retina
 *                                   320x480 | 640x960
 *                                   320x568 | 640x1136
 */
@property (nonatomic, readonly) BOOL is16x9;

/**
 * Gets the absolute gaming area. Surrounding areas are reserved for ads or 
 * other non-gaming content.
 */
@property (nonatomic, readonly) CGRect gamingAreaRect;

/**
 * Gets the absolute gaming area during play. Surrounding areas are reserved for ads or
 * other non-gaming content.
 */
-(CGRect) gamingAreaRectForPlay:(BOOL)playing;

/**
 * Gets the ad banner area during play.
 * @return banner area or CGRectZero if no ads should be displayed
 */
@property (nonatomic, readonly) CGRect adAreaRect;

/**
 * Remove ads from the application.
 */
-(void) removeAds;

/**
 * Gets whether iAd should be displayed in the current context. 
 * It should not be displayed on the Options, More, or Title scene. 
 * This also includes logic if the user has removed the ads, which 
 * ensures they are no longer displayed.
 */
@property (nonatomic, readonly) BOOL shouldDisplayAd;

/**
 * Gets whether the ads have been removed by the user (purchased).
 */
@property (nonatomic, readwrite) BOOL adsRemovedByUser;

/**
 * Whether the advertising banner is currently displayed.
 */
@property (nonatomic, readwrite) BOOL adVisible;

/**
 * Whether the advertising banner is loaded by the iAd framework. The
 * ad may be displayed only during play.
 */
@property (nonatomic, readonly) BOOL adLoaded;

/**
 * Animates the ad banner UIView into or out of view. The duration
 * of the animation is the default.
 * @param intoView sends ad view into visible area of viewcontroller
 */
-(void) animateAdBannerIntoView:(BOOL)intoView;

/**
 * Animates the ad banner UIView into or out of view.
 * @param intoView sends ad view into visible area of viewcontroller
 * @param duration (s) of animation; set to 0 for immediate
 */
-(void) animateAdBannerIntoView:(BOOL)intoView withDuration:(double)duration;

/**
 * Gets the root viewcontroller for the application.
 * @return root viewcontroller
 */
@property (nonatomic, readonly) UIViewController* rootViewController;

/**
 * Gets whether the Chinese language is in use.
 */
+(BOOL) isChineseLang;

/**
 * Gets whether the Chinese locale is in use.
 */
+(BOOL) isChineseLocale;

/**
 * Gets a font file based upon the locale. Alternatively, the default
 * font file can be returned for cases where the font would not support
 * a specific character.
 * @param font preferred font type
 * @param force forces the default font
 * @return Font (fnt) file selected
 */
+(NSString*) selectFont:(CeoFonts)font forceDefault:(BOOL)force;

/**
 * Gets a font file based upon the locale. The requested font may be returned or a 
 * substitute depending on the locale.
 * @param font preferred font type
 * @return Font (fnt) file selected
 */
+(NSString*) selectFont:(CeoFonts)font;

/**
 Converts (downgrades) a Unicode string to ASCII encoding. This is so the font
 sprites can be mapped properly according to values.
 @param unicode String in Unicode
 @return string in ASCII encoding
 */
+(NSString*) convertToAscii:(NSString*)unicode;

/**
 Gets the shared instance of the GameController object.
 */
+ (GameController*) sharedInstance;

+ (id)allocWithZone:(NSZone *)zone;

- (id)copyWithZone:(NSZone *)zone;

- (id)retain;

- (unsigned)retainCount;

- (void)release;

- (id)autorelease;

@end
