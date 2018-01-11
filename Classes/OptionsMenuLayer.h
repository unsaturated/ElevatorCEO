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

#import "IMenuHandler.h"

@interface OptionsMenuLayer : CCLayer <IMenuHandler> 
{
	@private
	CCMenuItem *mBackButton;
    CCMenuItem *mRemoveAdsButton;
    CCMenuItem *mRestorePurchaseButton;
	CCArray *mStringArray;
    CCArray *mStringIsEasternScriptReady;
	UInt8 mCreditSlideNumber;
	UInt8 mCreditRows;
    BOOL mFirstShowing;
}

-(void)unscheduleSelectors;

/**
 * Called by the node's action to update the credits text. 
 */
-(void)flashCredits;

@end
