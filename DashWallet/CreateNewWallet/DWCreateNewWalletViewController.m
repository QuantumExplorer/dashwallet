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

#import "DWCreateNewWalletViewController.h"

#import "DWAmountKeyboard.h"
#import "DWPinView.h"
#import "UIFont+DWFont.h"

NS_ASSUME_NONNULL_BEGIN

@interface DWCreateNewWalletViewController () <DWPinViewDelegate>

@property (strong, nonatomic) IBOutlet DWPinView *pinView;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet DWAmountKeyboard *keyboardView;

@end

@implementation DWCreateNewWalletViewController

+ (instancetype)controller {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"CreateNewWallet" bundle:nil];
    DWCreateNewWalletViewController *controller = [storyboard instantiateInitialViewController];
    controller.title = NSLocalizedString(@"Create a New Wallet", nil);

    return controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.pinView activatePinView];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - DWPinViewDelegate

- (void)pinView:(DWPinView *)pinView didFinishWithPin:(NSString *)pin {
    NSLog(@">>>>> %@", pin);
}

#pragma mark - Private

- (void)setupView {
    self.title = NSLocalizedString(@"Create a New Wallet", nil);

    self.descriptionLabel.text = NSLocalizedString(@"This PIN will be required to unlock your app everytime when you use it.", nil);
    self.descriptionLabel.font = [UIFont dw_fontForTextStyle:UIFontTextStyleBody];

    [self.pinView configureWithKeyboard:self.keyboardView];
    self.pinView.delegate = self;
}

@end

NS_ASSUME_NONNULL_END
