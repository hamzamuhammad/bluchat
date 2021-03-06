//
//  SCRequest.h
//  syncano-ios
//
//  Created by Jan Lipmann on 08/12/15.
//  Copyright © 2015 Syncano. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCConstants.h"

typedef NS_ENUM(NSUInteger, SCRequestMethod) {
    SCRequestMethodUndefined,
    SCRequestMethodGET,
    SCRequestMethodPOST,
    SCRequestMethodPATCH,
    SCRequestMethodDELETE,
    SCRequestMethodPUT
};

NS_ASSUME_NONNULL_BEGIN

@interface SCRequest : NSObject
@property (nullable,nonatomic,retain) NSString *identifier;
@property (nullable,nonatomic,retain) NSString *path;
@property (nonatomic) SCRequestMethod method;
@property (nullable,nonatomic,retain) NSDictionary *params;
@property (nullable,nonatomic,strong) SCAPICompletionBlock callback;
@property (nonatomic) BOOL save;

/**
 *  Initializes SCRequest
 *
 *  @param path     URI of the request
 *  @param method   method of the request (GET,POST,PUT,PATCH,DELETE)
 *  @param params   parameters
 *  @param callback callback block
 *  @param save     boolean which determines if this request should be stored on disk
 *
 *  @return SCRequest instance
 */
- (instancetype)initWithPath:(NSString *)path method:(SCRequestMethod)method params:(nullable NSDictionary *)params callback:(nullable SCAPICompletionBlock)callback save:(BOOL)save;

/**
 *  Initializes SCRequest
 *
 *  @param dictionaryRepresentation NSDictionary representation of a request
 *
 *  @return SCRequest instance
 */
- (instancetype)initFromDictionaryRepresentation:(NSDictionary *)dictionaryRepresentation;

/**
 *  Creates SCRequest
 *
 *  @param path     URI of the request
 *  @param method   method of the request (GET,POST,PUT,PATCH,DELETE)
 *  @param params   parameters
 *  @param callback callback block
 *  @param save     boolean which determines if this request should be stored on disk
 *
 *  @return SCRequest instance
 */
+ (SCRequest *)requestWithPath:(NSString *)path method:(SCRequestMethod)method params:(nullable NSDictionary *)params callback:(nullable SCAPICompletionBlock)callback save:(BOOL)save;

/**
 *  Dictionary representation of a request for saving on disk use
 *
 *  @return NSDictionary
 */
- (NSDictionary *)dictionaryRepresentation;
@end
NS_ASSUME_NONNULL_END