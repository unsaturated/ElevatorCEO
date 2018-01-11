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

@class GamePlayLayer;

/**
 * Base class for displaying tutorial tips. It contains a background
 * image and four lines of text. Sub-classes should set the lines of
 * text and supplement with any relevant graphics.
 */
@interface BaseTutorialTip : CCNode <CCTargetedTouchDelegate>
{
    CCLabelBMFont* mLine1;
    CCLabelBMFont* mLine2;
    CCLabelBMFont* mLine3;
    CCLabelBMFont* mLine4;
}

/**
 * Creates the tip and informs the GameController it is the last of the tutorial.
 * @param tutorialViewed True if tutorials are complete
 */
+(id) lastTip:(BOOL)tutorialViewed;

/**
 * Internal function to create instance and mark as final tip.
 */
-(id) initWithTutorialViewed;

/**
 * Animates in the tip, displays for a few seconds, then scrolls out.
 */
-(void) showTip;

/**
 * Gets the GamePlayLayer where tips are displayed.
 */
-(GamePlayLayer*) gamePlayLayer;

/**
 * Called when the next game tip should be displayed.
 */
-(void) showNextTip;

/**
 * Animates out tip or immediately clears tip and if requested.
 */
-(void) exitTip:(BOOL)immediate;

/**
 * Function is called when the layer is out of view and should be removed from 
 * the parent object.
 */
-(void) transitionCleanup;

/**
 * Sets the state of the GameController so the tutorial is saved as viewed. 
 */
@property (readwrite, nonatomic) BOOL tutorialViewed;

@end
