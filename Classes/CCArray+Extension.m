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

#import "CCArray+Extension.h"

@implementation CCArray (ClassName)

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject 
{
	if([self count] > index)
	{
		[self removeObjectAtIndex: index];
		[self insertObject:anObject atIndex:index];		
	}
	else 
	{
		[self insertObject:anObject atIndex:index];
	}
}

@end
