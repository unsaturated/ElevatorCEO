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

/**
 * Restricts (clips) drawing of all children to a specific region.
 * Refer to URL: http://www.cocos2d-iphone.org/forum/topic/3993
 */
@interface CCNode(clipVisit)

-(void)preVisitWithClippingRect:(CGRect)rect;
-(void)postVisit;

@end
