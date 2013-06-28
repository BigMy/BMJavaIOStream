//
//  BMJavaObjSerializeAdapter.m
//  BMJavaIOStream
//
//  Created by 李 岩 on 13-6-29.
//  Copyright (c) 2013年 BigMy. All rights reserved.
//

#import "BMJavaObjSerializeAdapter.h"
#import "BMJavaDataInputStream.h"
#import "BMJavaDataOutputStream.h"
#include <objc/message.h>
#import <Foundation/NSObjCRuntime.h>
@implementation BMJavaObjSerializeAdapter

static const char * getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    //printf("attributes=%s\n", attributes);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            //
            /*
             */
            return (const char *)[[NSData dataWithBytes:(attribute + 1) length:strlen(attribute) - 1] bytes];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            //
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            //
            return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
        }
    }
    return "";
}

+(NSData *)serializeForObj:(id)anObj
{
    BMJavaDataOutputStream *dataOutputStream=[[BMJavaDataOutputStream alloc] init];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([anObj class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        const char *propType = getPropertyType(property);
        NSString *propertyName = [NSString stringWithUTF8String:propName];
        NSString *propertyType = [NSString stringWithUTF8String:propType];
        
        if ([propertyType isEqualToString:@"NSString"]) {
            [dataOutputStream writeUTF:[anObj valueForKey:propertyName]];
        }
        else if([propertyType isEqualToString:@"i"]){
            [dataOutputStream writeInt:(int)[anObj valueForKey:propertyName]];
        }
        else if([propertyType isEqualToString:@"f"]){
            [dataOutputStream writeFloat:[[anObj valueForKey:propertyName] floatValue]];
        }
        else if ([propertyType isEqualToString:@"B"]) {
            [dataOutputStream  writeBoolaen:(bool)[anObj valueForKey:propertyName]];
        }
        else if([propertyType isEqualToString:@"NSData"]) {
            
            [dataOutputStream writeBytes:[anObj valueForKey:propertyName]];
            
        }
    }
    free(properties);
    NSData *resultData=[dataOutputStream toByteArray];
    return resultData;
}


+(void)deserializeForObj:(id)anObj withBinaray:(NSData *)sourceBin
{
    Class class =[anObj class];
    BMJavaDataInputStream *dataInputStream;
    if (sourceBin) {
        dataInputStream=  [[BMJavaDataInputStream alloc] initWithData:sourceBin];
    }
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(class, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        const char *propType = getPropertyType(property);
        NSString *propertyName = [NSString stringWithUTF8String:propName];
        NSString *propertyType = [NSString stringWithUTF8String:propType];
        
        if ([propertyType isEqualToString:@"NSString"]) {
            [anObj  setValue:[dataInputStream readUTF] forKey:propertyName];
        }
        else if([propertyType isEqualToString:@"i"]){
            [anObj  setValue:[NSNumber numberWithInt:[dataInputStream readInt]] forKey:propertyName];
        }
        else if([propertyType isEqualToString:@"NSData"]) {
            [anObj setValue:[dataInputStream readData] forKey:propertyName];
        }
        else if ([propertyType isEqualToString:@"B"]) {
            [anObj setValue:[NSNumber numberWithInt:[dataInputStream read]] forKey:propertyName];
        }
        else if([propertyType isEqualToString:@"f"]) {
            [anObj setValue:[NSNumber numberWithFloat:[dataInputStream readFloat]] forKey:propertyName];
        }
    }
    free(properties);
}

@end
