//
//  DIMCASubject.h
//  DIMCore
//
//  Created by Albert Moky on 2018/11/25.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "dimMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMCASubject : DIMDictionary

@property (strong, nonatomic) NSString *country;  // C:  CN, US, ...
@property (strong, nonatomic) NSString *state;    // ST: province
@property (strong, nonatomic) NSString *locality; // L:  city

@property (strong, nonatomic) NSString *organization;     // O:  Co., Ltd.
@property (strong, nonatomic) NSString *organizationUnit; // OU: Department
@property (strong, nonatomic) NSString *commonName;       // CN: domain/ip

+ (instancetype)subjectWithSubject:(id)subject;

@end

NS_ASSUME_NONNULL_END
