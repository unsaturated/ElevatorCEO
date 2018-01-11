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

#import <GameKit/GameKit.h>

/**
 * Protocol to notify external objects when Game Center events occur or
 * when Game Center async tasks are completed.
 */
@protocol GCHelperProtocol<NSObject>
@optional
/**
 * Called when scores are submitted.
 * @param success whether attempt was accepted by GC.
 */
-(void) onScoresSubmitted:(bool)success;
@end


@interface GCHelper : NSObject

@property (nonatomic, assign) id<GCHelperProtocol> delegate;

/**
 * Gets the last known error that occured while using the Game Center API.
 */
@property (nonatomic, readonly) NSError* lastError;

/**
 * Gets the shared instance of the GCHelper.
 */
+(id) sharedGCHelper;

/**
 * Gets whether the player is authenticated, thus enabling features.
 */
@property (nonatomic, readonly) BOOL gameCenterFeaturesEnabled;

/**
 * Attempts to authenticate the local player.
 */
-(void) authenticateLocalPlayer;

/**
 * Displays the Game Center unified view-controller. It ensures
 * only one controller is displayed at a time.
 */
-(void) displayUnifiedController;

/**
 * Submits a score to Game Center.
 * @param score the score to submit
 * @param category the category to use
 */
-(void) submitScore:(int64_t)score category:(NSString*)category;

@end
