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

#import "GameController.h"
#import "GameLevelMaker.h"
#import "AudioController.h"

/**
 * Button tap and press delegate.
 */
@protocol ButtonUpDownDelegate <NSObject>
@optional

/**
 * Up button delegate for elevator.
 * @param tap button was tapped
 * @param speed button held with specified speed
 */
- (void) buttonUpEvent:(BOOL) tap hold:(char)speed;

/**
 * Down button delegate for elevator.
 * @param tap button was tapped
 * @param speed button held with specified speed
 */
- (void) buttonDownEvent:(BOOL) tap hold:(char)speed;

@end

/**
 * Custom control for the up/down button that forms a central
 * part of the game experience and elevator control. Touch
 * is the main reason for this subclass.
 */
@interface GameUpDownButton : CCLayer 
{
	@protected
	CCSprite *mTouchedSprite;
	CCSprite *mNormalSprite;
	BOOL mIsUpButton;
    id<ButtonUpDownDelegate> delegate; 
	BOOL mTouchDown;
	ccTime mSumTouchTime;
	UInt8 mCurrentValue;
	UInt8 mMinValue;
	UInt8 mMaxValue;
	BOOL mPressAllowable;
}

/**
 * Creates a new button with the "up" arrow.
 */
+(id)initUpButton;

/**
 * Creates a new button with the "down" arrow.
 */
+(id)initDownButton;

/**
 * Central function to use for cleaning up any selectors 
 * used in the game.
 */
-(void)unscheduleSelectors;

/**
 * Sets the direction of the button. Function should only 
 * be called during initialization.
 * @param up Set to YES if up arrow button is desired
 */
-(void)setUpDirection: (BOOL) up;

/**
 * Sets whether the button press is allowable. Depending 
 * upon the allowable state, the sprite may change and the 
 * sound played may change.
 * @param allowable Whether pressing is allowable
 */
-(void)setPressIsAllowable: (BOOL) allowable;

/**
 * Button delegate for button callback events.
 */
@property (assign) id<ButtonUpDownDelegate> delegate;

/**
 * Tests whether a point is within the circular radius of the button.
 * @param point The point to test
 * @returns YES if point is within button
 */
-(BOOL)isTouchInButton: (UITouch*) touch;

/**
 * Gets whether the button is up or down.
 * @returns YES if an up button
 */
@property (nonatomic,readonly) BOOL isUpButton;

/**
 * Gets the current value of the button (in relation to the 
 * time it has been held down. Button taps have a value of zero.
 */
@property (nonatomic,readonly) UInt8 value;

/**
 * Called by framework timer that tests the duration
 * of the button press. Input is different based upon the
 * total time pressed.
 * @param dt Time internal
 */
-(void) update: (ccTime) dt;

@end
