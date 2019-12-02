//
//  Created by Andrew Podkovyrin
//  Copyright © 2019 Dash Core Group. All rights reserved.
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

#import "DWAdvancedSecurityModel.h"

#import <DashSync/DashSync.h>

#import "DWGlobalOptions.h"
#import "NSAttributedString+DWBuilder.h"
#import "UIColor+DWStyle.h"

NS_ASSUME_NONNULL_BEGIN

static uint64_t const BIOMETRICS_ENABLED_SPENDING_LIMIT = 1; // 1 DUFF

@interface DWAdvancedSecurityModel ()

@property (readonly, assign, nonatomic) BOOL hasTouchID;
@property (readonly, assign, nonatomic) BOOL hasFaceID;

@end

@implementation DWAdvancedSecurityModel

@synthesize lockTimerTimeIntervals = _lockTimerTimeIntervals;
@synthesize spendingConfirmationValues = _spendingConfirmationValues;

- (instancetype)init {
    self = [super init];
    if (self) {
        DSAuthenticationManager *authManager = [DSAuthenticationManager sharedInstance];
        _hasTouchID = authManager.touchIdEnabled;
        _hasFaceID = authManager.faceIdEnabled;

        DWGlobalOptions *globalOptions = [DWGlobalOptions sharedInstance];
        _lockTimerTimeInterval = @(globalOptions.autoLockAppInterval);
        NSAssert([self.lockTimerTimeIntervals indexOfObject:_lockTimerTimeInterval] != NSNotFound,
                 @"Internal inconsistency");
    }
    return self;
}

- (DWSecurityLevel)securityLevel {
    NSInteger lockTime;
    if (!self.autoLogout) {
        lockTime = NSIntegerMax;
    }
    else {
        lockTime = self.lockTimerTimeInterval.integerValue;
    }

    uint64_t spendingConfirmation;
    if (!self.spendingConfirmationEnabled) {
        spendingConfirmation = UINT64_MAX;
    }
    else {
        spendingConfirmation = self.spendingConfirmationLimit.longLongValue;
    }

    return [self securityLevelForLockTime:lockTime spendingConfirmation:spendingConfirmation];
}

#pragma mark - Lock Screen

- (BOOL)autoLogout {
    return ![[DWGlobalOptions sharedInstance] lockScreenDisabled];
}

- (void)setAutoLogout:(BOOL)autoLogout {
    [[DWGlobalOptions sharedInstance] setLockScreenDisabled:!autoLogout];
}

- (NSArray<NSNumber *> *)lockTimerTimeIntervals {
    if (!_lockTimerTimeIntervals) {
        // Immediately (lock timer is off) / 1 min / 5 min / 1 hr / 1 day
        _lockTimerTimeIntervals = @[ @0, @60, @(60 * 5), @(60 * 60), @(60 * 60 * 24) ];
    }

    return _lockTimerTimeIntervals;
}

- (void)setLockTimerTimeInterval:(NSNumber *)lockTimerTimeInterval {
    _lockTimerTimeInterval = lockTimerTimeInterval;

    [DWGlobalOptions sharedInstance].autoLockAppInterval = lockTimerTimeInterval.integerValue;
}

- (NSString *)titleForCurrentLockTimerTimeInterval {
    if (self.lockTimerTimeInterval.integerValue == 0) {
        return NSLocalizedString(@"Logout", nil);
    }
    else {
        return NSLocalizedString(@"Logout after", nil);
    }
}

- (NSString *)stringForLockTimerTimeInterval:(NSNumber *)number {
    const NSInteger value = number.integerValue;
    switch (value) {
        case 0:
            return NSLocalizedString(@"Immediately", nil);
        case 60:
            return NSLocalizedString(@"1 min", @"Shorten version of minute");
        case (60 * 5):
            return NSLocalizedString(@"5 min", @"Shorten version of minutes");
        case (60 * 60):
            return NSLocalizedString(@"1 hour", nil);
        case (60 * 60 * 24):
            return NSLocalizedString(@"24 hours", nil);
        default:
            NSAssert(NO, @"Unhandled time interval");
            return @"Unknown";
    }
}

- (NSAttributedString *)currentLockTimerTimeIntervalWithFont:(UIFont *)font
                                                       color:(UIColor *)color {
    NSNumber *number = self.lockTimerTimeInterval;
    NSString *string = [self stringForLockTimerTimeInterval:number];

    NSDictionary<NSAttributedStringKey, id> *attributes = @{
        NSFontAttributeName : font,
        NSForegroundColorAttributeName : color,
    };

    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string
                                                                           attributes:attributes];

    return attributedString;
}

#pragma mark - Spending Confirmation

// TODO: impl

//- (BOOL)spendingConfirmationEnabled {
//
//}
//
//- (void)setSpendingConfirmationEnabled:(BOOL)spendingConfirmationEnabled {
//
//}

- (BOOL)canConfigureSpendingConfirmation {
    NSAssert(self.hasTouchID || self.hasFaceID, @"Inconsistent state");
    return [DWGlobalOptions sharedInstance].biometricAuthEnabled;
}

- (NSArray<NSNumber *> *)spendingConfirmationValues {
    if (!_spendingConfirmationValues) {
        // Dash values: 0 / 0.1 / 0.5 / 1 / 5
        // BIOMETRICS_DISABLED_SPENDING_LIMIT is a hack here
        _spendingConfirmationValues = @[ @(BIOMETRICS_ENABLED_SPENDING_LIMIT), @(DUFFS / 10), @(DUFFS / 2), @(DUFFS), @(DUFFS * 5) ];
    }

    return _spendingConfirmationValues;
}

- (NSNumber *)spendingConfirmationLimit {
    DSChainsManager *chainsManager = [DSChainsManager sharedInstance];
    uint64_t value = chainsManager.spendingLimit;
    if (value == BIOMETRICS_ENABLED_SPENDING_LIMIT) {
        // display it as 0
        value = 0;
    }

    return @(value);
}

- (void)setSpendingConfirmationLimit:(NSNumber *)spendingConfirmationLimit {
    const long long limit = spendingConfirmationLimit.longLongValue;
    [[DSChainsManager sharedInstance] setSpendingLimitIfAuthenticated:limit];
}

- (NSAttributedString *)spendingConfirmationString:(NSNumber *)number
                                              font:(UIFont *)font
                                             color:(UIColor *)color {
    long long value = number.longLongValue;
    if (value == BIOMETRICS_ENABLED_SPENDING_LIMIT) {
        value = 0;
    }
    return [NSAttributedString dw_dashAttributedStringForAmount:value tintColor:color font:font];
}

- (NSAttributedString *)currentSpendingConfirmationWithFont:(UIFont *)font
                                                      color:(UIColor *)color {
    return [self spendingConfirmationString:self.spendingConfirmationLimit
                                       font:font
                                      color:color];
}

- (NSAttributedString *)currentSpendingConfirmationDescriptionWithFont:(UIFont *)font
                                                                 color:(UIColor *)color {
    NSDictionary<NSAttributedStringKey, id> *attributes = @{
        NSFontAttributeName : font,
        NSForegroundColorAttributeName : color,
    };

    if (self.spendingConfirmationLimit.longLongValue == 0) {
        NSString *string = NSLocalizedString(@"PIN is always required to make a payment", nil);
        string = [string stringByAppendingString:@"\n"]; // to force the same height of label in both cases

        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string
                                                                               attributes:attributes];

        return attributedString;
    }
    else {
        NSString *string = nil;
        if (self.hasTouchID) {
            string = NSLocalizedString(@"You can authenticate with Touch ID for payments below", nil);
        }
        else if (self.hasFaceID) {
            string = NSLocalizedString(@"You can authenticate with Face ID for payments below", nil);
        }
        NSParameterAssert(string);

        string = [string stringByAppendingString:@" "];

        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:string
                                                                                 attributes:attributes]];

        NSAttributedString *valueString = [self currentSpendingConfirmationWithFont:font
                                                                              color:[UIColor dw_darkTitleColor]];
        [attributedString appendAttributedString:valueString];

        return [attributedString copy];
    }
}

- (NSString *)titleForSpendingConfirmationOption {
    if (self.hasTouchID) {
        return NSLocalizedString(@"Touch ID limit", nil);
    }
    else if (self.hasFaceID) {
        return NSLocalizedString(@"Face ID limit", nil);
    }
    else {
        return @"";
    }
}

#pragma mark - Private

/// Max value for a type considered as Disabled state
- (DWSecurityLevel)securityLevelForLockTime:(NSInteger)lockTime
                       spendingConfirmation:(uint64_t)spendingConfirmation {
    // Lock screen and spending confirmation BOTH are disabled
    if (lockTime == NSIntegerMax && spendingConfirmation == UINT64_MAX) {
        return DWSecurityLevel_None;
    }

    // Lock screen = Immediately AND Spending confirmation every time
    if (lockTime == 0 && spendingConfirmation <= BIOMETRICS_ENABLED_SPENDING_LIMIT) {
        return DWSecurityLevel_VeryHigh;
    }

    // Lock screen is not disabled AND spending confirmation <= 0.5 Dash
    if (lockTime != NSIntegerMax && spendingConfirmation <= DUFFS / 2) {
        return DWSecurityLevel_High;
    }

    // Just spending confirmation enabled
    if (spendingConfirmation != UINT64_MAX) {
        return DWSecurityLevel_Medium;
    }

    return DWSecurityLevel_Low;
}

@end

NS_ASSUME_NONNULL_END
