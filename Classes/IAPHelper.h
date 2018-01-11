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

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface IAPHelper : NSObject

/**
 Gets the instance of the IAP Helper. The singleton has a fixed
 set of IAP identifiers.
 */
+ (IAPHelper*) sharedInstance;

/**
 Initializes an IAPHelper object with the list of identifiers.
 @param productIdentifiers list of product identifier strings
 @return new object instance
 */
- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;

/**
 Queues the requested product for purchase from Apple.
 @param product object from list of available items
 */
- (void)buyProduct:(SKProduct *)product;

/**
 Restores any previously purchased items.
 */
- (void)restoreCompletedTransactions;

/**
 Gets whether a product with the identifier has been purchased.
 */
- (BOOL)productPurchased:(NSString *)productIdentifier;

/**
 Requests a list of IAP products from Apple.
 */
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
/**
 List of all SKProduct items available.
 */
- (NSArray*) productList;

/**
 Searches the productList for a match.
 @param usingKey Search list for product key identifier
 @return product object or nil
 */
- (SKProduct*) productObjectFromList:(NSString*)usingKey;
@end
