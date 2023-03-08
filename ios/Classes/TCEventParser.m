//
//  TCEventParser.m
//  tc_serverside_plugin
//
//  Created by Abdelhakim SAID on 14/02/2023.
//

#import <Foundation/Foundation.h>
#import "TCEventParser.h"


@implementation TCEventParser

- (instancetype) init
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (TCEvent *) parseEvent: (NSMutableDictionary *) eventDict withName: eventName
{
    TCEvent *event;
    
    if ([eventName isEqualToString: @"add_shipping_info"])
    {
        event = [self parseEcommerceEvent: eventDict withClass: TCAddShippingInfoEvent.class];
    }
    else if ([eventName isEqualToString: @"purchase"])
    {
        event = [self parseEcommerceEvent: eventDict withClass: TCPurchaseEvent.class];
    }
    else if ([eventName isEqualToString: @"add_payement_info"])
    {
        event = [self parseEcommerceEvent: eventDict withClass: TCAddPaymentInfoEvent.class];
    }
    else if ([eventName isEqualToString: @"add_to_cart"])
    {
        event = [self parseEcommerceEvent: eventDict withClass: TCAddToCartEvent.class];
    }
    else if ([eventName isEqualToString: @"add_to_wishlist"])
    {
        event = [self parseEcommerceEvent: eventDict withClass: TCAddToWishlistEvent.class];
    }
    else if ([eventName isEqualToString: @"refund"])
    {
        event = [self parseEcommerceEvent: eventDict withClass: TCRefundEvent.class];
    }
    else if ([eventName isEqualToString: @"remove_from_cart"])
    {
        event = [self parseEcommerceEvent: eventDict withClass: TCRemoveFromCartEvent.class];
    }
    else if ([eventName isEqualToString: @"begin_checkout"])
    {
        event = [self parseEcommerceEvent: eventDict withClass: TCBeginCheckoutEvent.class];
    }
    else if ([eventName isEqualToString: @"view_cart"])
    {
        event = [self parseEcommerceEvent: eventDict withClass: TCViewCartEvent.class];
    }
    else if ([eventName isEqualToString: @"view_item"])
    {
        event = [self parseEcommerceEvent: eventDict withClass: TCViewItem.class];
    }
    else if ([eventName isEqualToString: @"view_item_list"])
    {
        event = [self parseEcommerceEvent: eventDict withClass: TCViewItemListEvent.class];
    }
    else if ([eventName isEqualToString: @"select_item"])
    {
        event = [self parseEcommerceEvent: eventDict withClass: TCSelectItemEvent.class];
    }
    else if ([eventName isEqualToString: @"generate_lead"])
    {
        event = [self parseEvent: eventDict withClass: TCGenerateLeadEvent.class];
    }
    else if ([eventName isEqualToString: @"login"])
    {
        event = [self parseEvent: eventDict withClass: TCLoginEvent.class];
    }
    else if ([eventName isEqualToString: @"page_view"])
    {
        event = [self parseEvent: eventDict withClass: TCPageViewEvent.class];
    }
    else if ([eventName isEqualToString: @"search"])
    {
        event = [self parseEvent: eventDict withClass: TCSearchEvent.class];
    }
    else if ([eventName isEqualToString: @"sign_up"])
    {
        event = [self parseEvent: eventDict withClass: TCSignUpEvent.class];
    }
    else if ([eventName isEqualToString: @"select_content"])
    {
        event = [self parseEvent: eventDict withClass: TCSelectContentEvent.class];
    }
    else
    {
        event = [self parseCustomEvent: eventDict withName: eventName];
    }

    return event;
}

- (void) setAdditionalProperty: (id) value forKey: (NSString *) key forCalss: (NSString *) className methodName: (NSString *) method;
{
    if([className isEqualToString: @"TCDevice"])
    {
        if (value && ![value isEqual: [NSNull null]])
        {
            if ([method isEqualToString: @"addAdditionalProperty"])
            {
                [[TCDevice sharedInstance] addAdditionalProperty: key withStringValue: value];
            }
            else if ([method isEqualToString: @"addAdditionalPropertyWithMapValue"])
            {
                [[TCDevice sharedInstance] addAdditionalProperty: key withDictValue: value];
            }
            else if ([method isEqualToString: @"addAdditionalPropertyWithBooleanValue"])
            {
                [[TCDevice sharedInstance] addAdditionalProperty: key withBoolValue: [value boolValue]];
            }
            else if ([method isEqualToString: @"addAdditionalPropertyWithDoubleValue"] || [method isEqualToString: @"addAdditionalPropertyWithIntValue"])
            {
                [[TCDevice sharedInstance] addAdditionalProperty: key withNumberValue: value];
            }
            else if ([method isEqualToString: @"addAdditionalPropertyWithListValue"])
            {
                [[TCDevice sharedInstance] addAdditionalProperty: key withArrayValue: value];
            }
        }
    }
}

- (TCEvent *) parseCustomEvent: (NSMutableDictionary *) eventDict withName: (NSString *) eventName
{
    TCCustomEvent *event = [[TCCustomEvent alloc] initWithName: eventName];
    
    for (NSString *key in eventDict.allKeys)
    {
        if (![[eventDict objectForKey: key] isEqual: [NSNull null]])
        {
            [event setValue: [eventDict objectForKey: key] forKey: key];
        }
    }

    return event;
}

- (TCEvent *) parseEcommerceEvent: (NSMutableDictionary *) eventDict withClass: (Class) cls
{
    TCECommerceEvent *event = [[cls alloc] init];
    [self setItems: eventDict forEvent: event];
    
    for (NSString *key in eventDict.allKeys)
    {
        if (![[eventDict objectForKey: key] isEqual: [NSNull null]])
        {
            [event setValue: [eventDict objectForKey: key] forKey: key];
        }
    }

    return event;
}

- (TCEvent *) parseEvent: (NSMutableDictionary *) eventDict withClass: (Class) cls
{
    TCEvent *event = [[cls alloc] init];
    
    for (NSString *key in eventDict.allKeys)
    {
        if (![[eventDict objectForKey: key] isEqual: [NSNull null]])
        {
            [event setValue: [eventDict objectForKey: key] forKey: key];
        }
    }

    return event;
}

- (void) setItems: (NSMutableDictionary *) eventDict forEvent: (TCECommerceEvent *) event
{
    NSArray *items = [eventDict objectForKey: @"items"];
    
    if (![items isEqual: [NSNull null]])
    {
        for (NSMutableDictionary *itemDict in items)
        {
            TCItem *tc_item = [[TCItem alloc] init];
            [self setProduct: itemDict forTCItem: tc_item];

            for (NSString *key in itemDict.allKeys)
            {
                if (![[itemDict objectForKey: key] isEqual: [NSNull null]])
                {
                    [tc_item setValue: [itemDict objectForKey: key] forKey: key];
                }
            }
            
            [event.items addObject: tc_item];
        }
        
        [eventDict removeObjectForKey: @"items"];
    }
}

- (void) setProduct: (NSMutableDictionary *) itemDict forTCItem: (TCItem *) item
{
    NSDictionary *productDict = [itemDict objectForKey: @"product"];
    TCProduct *tc_product = [[TCProduct alloc] init];

    for (NSString *key in productDict.allKeys)
    {
        if (![[productDict objectForKey: key] isEqual: [NSNull null]])
        {
            [tc_product setValue: [productDict objectForKey: key] forKey: key];
        }
    }
    
    item.product = tc_product;
    [itemDict removeObjectForKey: @"product"];
}

@end
