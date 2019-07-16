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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DWSeedPhraseTitledModel;
@class DWSeedPhraseModel;
@class DWSeedWordModel;

@interface DWVerifySeedPhraseModel : NSObject

@property (readonly, nonatomic, strong) DWSeedPhraseTitledModel *titledSeedPhrase;
@property (readonly, nonatomic, strong) DWSeedPhraseModel *shuffledSeedPhrase;
@property (readonly, nonatomic, assign) BOOL seedPhraseHasBeenVerified;

- (instancetype)initWithSeedPhrase:(DWSeedPhraseModel *)seedPhrase;

- (BOOL)allowedToSelectWord:(DWSeedWordModel *)sampleWordModel;
- (void)selectWord:(DWSeedWordModel *)sampleWordModel;

@end

NS_ASSUME_NONNULL_END
