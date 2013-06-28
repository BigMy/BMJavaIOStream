//
//  BMJavaObjSerializeAdapter.h
//  BMJavaIOStream
//
//  Created by 李 岩 on 13-6-29.
//  Copyright (c) 2013年 BigMy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMJavaObjSerializeAdapter : NSObject

+(NSData *)serializeForObj:(id)anObj;
+(void)deserializeForObj:(id)anObj withBinaray:(NSData *)sourceBin;

@end
