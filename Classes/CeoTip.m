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

#import "CeoTip.h"

@implementation CeoTip

-(id) init
{
    if( (self = [super init]) )
    {
        // Setup strings
        [mLine1 setString:NSLocalizedString(@"TIP_CEO_LINE1", nil)];
        [mLine2 setString:NSLocalizedString(@"TIP_CEO_LINE2", nil)];
        [mLine3 setString:NSLocalizedString(@"TIP_CEO_LINE3", nil)];
        [mLine4 setString:NSLocalizedString(@"TIP_CEO_LINE4", nil)];
        
        // Setup graphics
        // The red elevator
		CCNode* wCar = [CCSprite spriteWithSpriteFrameName:@"el-red-game.png"];
        [wCar setAnchorPoint:CGPointMake(0.5f, 0.0f)];
		wCar.position = ccp(20, 16);
        wCar.scale = 0.7f;
		[self addChild: wCar z:2];
		
		// Passenger balloon indicator
		CCNode* wBalloon = [CCSprite spriteWithSpriteFrameName:@"dialog.png"];
		wBalloon.position = ccp(wCar.position.x, wCar.contentSize.height + wCar.position.y);
        wBalloon.scale = 0.7f;
		[self addChild:wBalloon z:3];
		
        // Passenger count
		CCLabelBMFont* wLabelPassengers = [CCLabelBMFont labelWithString:@"1" fntFile:[GameController selectFont:kDroidSansBold20Black forceDefault:YES]];
		wLabelPassengers.position = ccp(wBalloon.contentSize.width / 2.0f, wBalloon.contentSize.height / 2.0f);
        wLabelPassengers.scale = 0.8f;
		[wBalloon addChild:wLabelPassengers z:4];
        
        CCLOG(@"+++INIT %@", self);
    }
    
    return self;
}

@end
