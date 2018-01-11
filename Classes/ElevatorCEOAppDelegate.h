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

#import <UIKit/UIKit.h>

@class RootViewController;

@interface ElevatorCEOAppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow *window;
	RootViewController *viewController;
    ADBannerView *adView;
}

/**
 * Gets or sets the UIWindow associated with app delegate.
 */
@property (nonatomic, retain) UIWindow *window;

/**
 * Gets the root viewcontroller of the app delegate.
 */
@property (nonatomic, readonly) RootViewController *rootViewController;

/**
 * Banner view object for displaying advertisements.
 */
@property (nonatomic, retain) ADBannerView *adView;

/**
 * Animates the ad banner UIView into or out of view.
 * @param intoView sends ad view into visible area of viewcontroller
 * @param duration (s) of animation; set to 0 for immediate
 */
-(void) animateAdBannerIntoView:(BOOL)intoView withDuration:(double)duration;

/**
 Used to establish application-level settings.
 */
+ (void) initialize;

@end



