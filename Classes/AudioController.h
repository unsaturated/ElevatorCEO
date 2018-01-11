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
#import "AudioEnumerations.h"
#import "SimpleAudioEngine.h"
#import "CDXPropertyModifierAction.h"

#define AC_NEW_LEVEL_DURATION   2.056f

#define AC_EL_CRASH_DURATION    9.849f
#define AC_EL_CRASH_SNAP_SPAN   2.000f
#define AC_EL_CRASH_FALL_SPAN   4.000f

#define AC_BOOSTER_DURATION     3.266f

#define AC_EL_STARTUP_DURATION  1.611f
#define AC_EL_STOP_DURATION     1.141f
#define AC_EL_HUM_DURATION      1.521f

#define AC_STINGER              3.725f

/**
 * Uses both the SimpleAudioEngine (SAE) and the CDAudioManager (CDAM); the former
 * for simplicity, the latter for control. Features like mute and play 
 * are passed through the SAE since it's a wrapper for the CDAM.
 *
 * The AudioController is a simplified interface for start/stopping sounds effects
 * and music. 
 */
@interface AudioController : NSObject <CDLongAudioSourceDelegate>
{
    CDLongAudioSource *mLongAudioSource;
    
    CDSoundSource* mClickMenuButton;
	CDSoundSource* mSwapControlSides;
    CDSoundSource* mTapElevatorButton;
    CDSoundSource* mBooster;
    CDSoundSource* mLifeBonus;
    CDSoundSource* mSynergyBonus;
    CDSoundSource* mPassengerBonus;
    CDSoundSource* mTreasureChestOpening;
    CDSoundSource* mInvalidElevatorButton;
    CDSoundSource* mPensionBonus;
    CDSoundSource* mNoRadarBonus;
    CDSoundSource* mNewLevelTransition;
    CDSoundSource* mStinger;
    CDSoundSource* mIntroLoop;
    CDSoundSource* mLowSynergyWarning;
    CDSoundSource* mElevatorCrash;
    CDSoundSource* mElevatorStarting;
    CDSoundSource* mElevatorMoving;
    CDSoundSource* mElevatorStopping;
    CDSoundSource* mRecoverRadar;

	SimpleAudioEngine *mSae;
    
	CDXPropertyModifierAction* mFaderAction;
	CDSoundSourceFader *mSourceFader;
	CCActionManager *mActionManager;
    
    BOOL mMusicWasPaused;
}

#pragma mark High Level Audio Control _________________

/**
 * Pauses audio.
 */
-(void) pause;

/**
 * Resumes audio.
 */
-(void) resume;

/**
 * Pauses all music and sound.
 */
-(void) pauseMusic;

/**
 * Resumes all music and sound.
 */
-(void) resumeMusic;

/**
 * Turns ON all sounds, excluding music.
 */
-(void) soundOn;

/**
 * Turns OFF all sounds, excluding music.
 */
-(void) soundOff;

/**
 * Gets whether the sound is on.
 */
-(BOOL) isSoundOn;

/**
 * Turns ON the music.
 */
-(void) musicOn;

/**
 * Turns OFF the music.
 */
-(void) musicOff;

/**
 * Gets whether the music is on.
 */
-(BOOL) isMusicOn;

/**
 * Plays the sound specified by the argument.
 * @param effect Enumeration value for the desired effect
 */
-(void) playSound:(SoundEffect) effect;

/**
 * Plays the new level transition.
 */
-(void) playNewLevelTransition;

/**
 * Stops the sound specified by the argument.
 * @param effect Enumeration value for the desired effect
 */
-(void) stopSound:(SoundEffect) effect;

#pragma mark Singleton Methods ________________________

/**
 * Gets the shared instance of the GameController object.
 */
+(AudioController*) sharedInstance;

+(id) allocWithZone:(NSZone *)zone;

-(id) copyWithZone:(NSZone *)zone;

-(id) retain;

-(unsigned) retainCount;

-(void) release;

-(id) autorelease;

@end
