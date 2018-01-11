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

#import "IAPHelper.h"

@interface IAPHelper () <SKProductsRequestDelegate, SKPaymentTransactionObserver>
@end

@implementation IAPHelper
{
    SKProductsRequest * _productsRequest;
    RequestProductsCompletionHandler _completionHandler;
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;
    NSArray* _products;
}

+ (IAPHelper *)sharedInstance
{
    static dispatch_once_t once;
    static IAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:IAP_REMOVE_ADS_KEY, nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers
{
    if ((self = [super init]))
    {
        // Store product identifiers
        _productIdentifiers = productIdentifiers;
        
        // Check for previously purchased products
        _purchasedProductIdentifiers = [[NSMutableSet alloc] init];
        for(NSString * productIdentifier in _productIdentifiers)
        {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if(productPurchased)
            {
                [_purchasedProductIdentifiers addObject:productIdentifier];
                NSLog(@"StoreKit: Previously purchased: %@", productIdentifier);
            }
            else
            {
                NSLog(@"StoreKit: Not purchased: %@", productIdentifier);
            }
        }
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (BOOL)productPurchased:(NSString *)productIdentifier
{
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product
{
    if(product == nil)
        return;
    
    CCLOG(@"StoreKit: Buying %@...", product.productIdentifier);
    
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restoreCompletedTransactions
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler
{
    _completionHandler = [completionHandler copy];
    
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    _productsRequest.delegate = self;
    [_productsRequest start];
}

-(NSArray*) productList
{
    return _products;
}

-(SKProduct *)productObjectFromList:(NSString *)usingKey
{
    SKProduct* result = nil;
    
    if(_products == nil)
        return result;
    
    for(SKProduct* p in self.productList)
    {
        if([p.productIdentifier isEqualToString:usingKey])
        {
            result = p;
            break;
        }
    }
    
    return result;
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    CCLOG(@"StoreKit: Loaded list of products...");
    _productsRequest = nil;
    NSArray * skProducts = response.products;
#ifdef DEBUG
    for(SKProduct * skProduct in skProducts)
	{
        CCLOG(@"StoreKit: Found product: %@ %@ %0.2f",
              skProduct.productIdentifier,
              skProduct.localizedTitle,
              skProduct.price.floatValue);
    }
#endif
    _products = [skProducts copy];
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    CCLOG(@"StoreKit: Failed to load list of products.");
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    _completionHandler = nil;
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions)
	{
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing:
                [[NSNotificationCenter defaultCenter] postNotificationName:IAP_PURCHASE_INPROG_NOTIFICATION object:nil userInfo:nil];
                break;
            case SKPaymentTransactionStateFailed:
                [[NSNotificationCenter defaultCenter] postNotificationName:IAP_PURCHASE_FAILED_NOTIFICATION object:nil userInfo:nil];
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [[NSNotificationCenter defaultCenter] postNotificationName:IAP_PURCHASE_INPROG_NOTIFICATION object:nil userInfo:nil];
                [self restoreTransaction:transaction];
                break;
            default:
                break;
        }
    };
}

-(void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
}

#pragma mark - SKPaymentTransactionObserver Helpers

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    CCLOG(@"StoreKit: completeTransaction...");
    
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    CCLOG(@"StoreKit: restoreTransaction...");
    
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    CCLOG(@"StoreKit: failedTransaction...");
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        CCLOG(@"StoreKit: Transaction error: %@", transaction.error.localizedDescription);
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier
{
    if(![_purchasedProductIdentifiers containsObject:productIdentifier])
    {
        [_purchasedProductIdentifiers addObject:productIdentifier];
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if([productIdentifier isEqualToString:IAP_REMOVE_ADS_KEY])
    {
        [[GameController sharedInstance] removeAds];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:IAP_PURCHASE_SUCCESS_NOTIFICATION object:productIdentifier userInfo:nil];
}

@end
