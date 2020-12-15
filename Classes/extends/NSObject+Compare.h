// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2019 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2019 Albert Moky
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// =============================================================================
//
//  NSObject+Compare.h
//  MingKeMing
//
//  Created by Albert Moky on 2019/3/12.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*
 *  Compare objects
 *      when the two objects can be empty at the same time,
 *      use these functions to compare them
 *
 *  Cases:
 *      +============+============+============+
 *      |  String 1  |  String 2  |   Result   |
 *      +============+============+============+
 *      |  nil       |  nil       |    YES     |
 *      |  nil       |  ""        |    YES     |
 *      |  nil       |  "string"  |    NO      |
 *      +------------+------------+------------+
 *      |  ""        |  nil       |    YES     |
 *      |  ""        |  ""        |    YES     |
 *      |  ""        |  "string"  |    NO      |
 *      +------------+------------+------------+
 *      |  "string"  |  nil       |    NO      |
 *      |  "string"  |  ""        |    NO      |
 *      |  "string"  |  "string"  |    YES     |
 *      +------------+------------+------------+
 *      |  "string"  |  "other"   |    NO      |
 *      +============+============+============+
 */

// compare objects
#define NSObjectEquals(obj1, obj2)          (!obj1 ? !obj2 :                   \
                                             (!obj2 ? !obj1 :                  \
                                              [obj1 isEqual:obj2]))
#define NSObjectNotEquals(obj1, obj2)       (!NSObjectEquals(obj1, obj2))

// compare strings
#define NSStringEquals(str1, str2)          (str1 == nil ? str2.length == 0 :  \
                                             (str2 == nil ? str1.length == 0 : \
                                              [str1 isEqualToString:str2]))
#define NSStringNotEquals(str1, str2)       (!NSStringEquals(str1, str2))

// compare arrays
#define NSArrayEquals(arr1, arr2)           (arr1 == nil ? arr2.count == 0 :   \
                                             (arr2 == nil ? arr1.count == 0 :  \
                                              [arr1 isEqualToArray:arr2]))
#define NSArrayNotEquals(arr1, arr2)        (!NSArrayEquals(arr1, arr2))

// compare dictionaries
#define NSDictionaryEquals(dict1, dict2)    (dict1 == nil ? dict2.count == 0 : \
                                             (dict2 == nil ? dict1.count == 0 :\
                                              [dict1 isEqualToDictionary:dict2]))
#define NSDictionaryNotEquals(dict1, dict2) (!NSDictionaryEquals(dict1, dict2))

NS_ASSUME_NONNULL_END
