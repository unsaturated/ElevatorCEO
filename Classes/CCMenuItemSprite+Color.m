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

@implementation CCMenuItemSprite(Color)

-(void) setMenuItemColor:(ccColor4B)color
{
    [self setColor:ccc3(color.r,color.g,color.b)];
    for(CCSprite* s in self.children)
    {
        [s setColor:ccc3(color.r,color.g,color.b)];
        [s setOpacity:color.a];
    }
    [self setOpacity:color.a];
}

-(void) setMenuItemDisabled
{
    [self setMenuItemColor:ccc4(100, 100, 100, 255)];
    [self setIsEnabled:NO];
}

-(void) setMenuItemEnabled
{
    [self setMenuItemColor:ccc4(255, 255, 255, 255)];
    [self setIsEnabled:YES];
}

@end
