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

#import "ButtonsTip.h"
#import "GreenElevatorTip.h"
#import "GamePlayLayer.h"

@implementation ButtonsTip

-(id) init
{
    if( (self = [super init]) )
    {
        // Setup strings
        [mLine1 setString:NSLocalizedString(@"TIP_BUTTONS_LINE1", nil)];
        [mLine2 setString:NSLocalizedString(@"TIP_BUTTONS_LINE2", nil)];
        [mLine3 setString:NSLocalizedString(@"TIP_BUTTONS_LINE3", nil)];
        [mLine4 setString:NSLocalizedString(@"TIP_BUTTONS_LINE4", nil)];
        
        // Setup graphics
		CCNode* wUp = [CCSprite spriteWithSpriteFrameName:@"up-off-game.png"];
        wUp.scale = 0.4f;
		wUp.position = ccp(21, 66);
		[self addChild: wUp z:2];
		
		CCNode* wDown = [CCSprite spriteWithSpriteFrameName:@"down-off-game.png"];
        wDown.scale = 0.4f;
		wDown.position = ccp(21, 34);
		[self addChild: wDown z:2];
        
        CCLOG(@"+++INIT %@", self);
    }
    
    return self;
}

-(void) showNextTip
{
    GamePlayLayer* gp = [self gamePlayLayer];
    [gp showTip:[GreenElevatorTip node]];
}

@end
