//
//  Created by Andrew Podkovyrin
//  Copyright © 2020 Dash Core Group. All rights reserved.
//
//  Licensed under the MIT License (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  https://opensource.org/licenses/MIT
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DWTitleDetailItem;
@class UIFont;
@class UIColor;

@protocol DWConfirmPaymentViewProtocol <NSObject>

- (BOOL)hasCommonName;
- (uint64_t)amountToDisplay;
- (nullable id<DWTitleDetailItem>)nameInfo;
- (nullable id<DWTitleDetailItem>)generalInfo;

// Attributed data
- (nullable id<DWTitleDetailItem>)addressWithFont:(UIFont *)font tintColor:(UIColor *)tintColor;
- (nullable id<DWTitleDetailItem>)feeWithFont:(UIFont *)font tintColor:(UIColor *)tintColor;
- (id<DWTitleDetailItem>)totalWithFont:(UIFont *)font tintColor:(UIColor *)tintColor;

// Actions

- (BOOL)copyAddressToPasteboard;

@end

NS_ASSUME_NONNULL_END
