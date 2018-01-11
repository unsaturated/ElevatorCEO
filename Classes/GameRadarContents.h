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

#import "CCNode+clipVisit.h"
#import "Elevator.h"
#import "AudioController.h"

@class CeoElevator, OwnGameElevator;

/**
 * Because the radar background should not be clipped, this 
 * object is used to store the elevators (or contents) and
 * do the actual clipping, leaving the border itself untouched.
 */
@interface GameRadarContents : CCLayer 
{
	@protected
	// References to in-game elevators
	CCArray* mShaft1;
	CCArray* mShaft2;
	CCArray* mShaft3;
	CCArray* mShaft4;
	OwnGameElevator* mOwnEl;
	CeoElevator* mCeoEl;
	
	// Sprite objects used to represent elevators
	CCArray* mShaft0Sprites;
	CCArray* mShaft1Sprites;
	CCArray* mShaft2Sprites;
	CCArray* mShaft3Sprites;
	CCArray* mShaft4Sprites;	
	CCNode* mAllRadarSprites;
	
	// Sprite objects used to represent no-radar countdown
	CCNode* mRadarCountdownSprites;
	CCLabelBMFont* mFloorsRemainLabel;
	CCSprite* mLockSprite;
	CCArray* mCircleSprites;
	
	// Points and clipping
	CGRect mVisibleRect;
	CGSize mClippingSize;
	UInt8 mShaft0X, mShaft1X, mShaft2X, mShaft3X, mShaft4X;
	
	UInt8 mElevatorCountValid;
	
	UInt16 mFloorMin, mFloorMax;
	
	UInt16 mNumberOfFloorsToHide;
	UInt16 mNumberOfFloorsToHideTotal;
	UInt16 mLastOwnElevatorFloor;
}

/**
 * Gets the size of the radar background less the size of the 
 * clipping region.
 */
@property (nonatomic, readonly) CGSize clippingSize;

/**
 * Sets the array object of elevators for a specific floor. This should
 * be called before the radar is used.
 */
-(void) setShaftElevatorsOn:(UInt8)floor with:(CCArray*)array;

/**
 * Sets the own elevator and CEO elevator objects. This should be called 
 * before the radar is used.
 */
-(void) setOwnElevator:(OwnGameElevator*)own ceoElevator:(CeoElevator*)ceo;

/**
 * Sets the floor minimum and maximum.
 * @param max Maximum floor
 */
-(void) setFloorMinimum:(UInt16)min maximum:(UInt16)max;

/**
 * Hides the elevator display for a total number of floors.
 * @param total Number of floors to hide the radar
 */
-(void) hideRadarForFloors:(UInt16)total;

/**
 * Shows all radar objects using animation.
 */
-(void) showRadar;

/**
 * Flashes the lock and number with an animation.
 */
-(void) flashLockAndNumber;

/**
 * Rotates the lock/circle sprites by progressively hiding then showing them.
 */
-(void) rotateLockCircle;

/**
 * Gets the color necessary to gradually change tint based upon 
 * a percentage from red -> yellow -> green.
 * @param percent Percent (0 = fully red, 1.0 = fully green)
 * @returns Color bytes
 */
+(ccColor3B) colorFromRedToGreen:(float)percent;

@end
