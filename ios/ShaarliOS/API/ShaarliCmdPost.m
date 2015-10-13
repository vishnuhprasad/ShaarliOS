//
// ShaarliCmdPost.m
// ShaarliOS
//
// Created by Marcus Rohrmoser on 12.10.15.
// Copyright (c) 2015 Marcus Rohrmoser. All rights reserved.
//

#import "ShaarliCmdPost.h"


#define POST_SOURCE @"http://app.mro.name/ShaarliOS"

@implementation ShaarliCmdPost


#pragma mark Internal Helpers


-(NSMutableDictionary *)parseLoginForm:(NSURL *)location error:(NSError **)error
{
    NSParameterAssert(error);
    NSData *d = [NSData dataWithContentsOfURL:location options:0 error:error];
    if( *error )
        return nil;
    if( ![self parseAnyResponse:nil data:d error:error] )
        return nil;
    return [self fetchForm:@"loginform" error:error];
}


-(void)postLoginForm:(NSMutableDictionary *)form toURL:(NSURL *)url
{
    MRLogD(@"foo", nil);
    NSParameterAssert(self.session);
    NSParameterAssert(self.endpointUrl);
    NSParameterAssert(self.delegate);

    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    req.HTTPMethod = @"POST";
    // post[@"returnurl"] = task.originalRequest.URL.absoluteString;
    req.HTTPBody = [form postData];
    NSURLSessionTask *dt = [self.session downloadTaskWithRequest:req completionHandler:^(NSURL * location, NSURLResponse * response, NSError * error) {
                                MRLogD (@"%@", response.URL, nil);
                                MRLogD (@"%@", location, nil);
                                MRLogD (@"%@", error, nil);
                                NSMutableDictionary *form = error ? nil:[self fetchPostFormForPostURLParse:location error:&error];
                                [self.delegate didPostLoginForm:form toURL:response.URL error:error];
                            }
                           ];
    [dt resume];
}


-(NSMutableDictionary *)fetchPostFormForPostURLParse:(NSURL *)location error:(NSError **)error
{
    NSParameterAssert(error);
    NSData *d = [NSData dataWithContentsOfURL:location options:0 error:error];
    if( *error )
        return nil;
    if( ![self parseAnyResponse:nil data:d error:error] )
        return nil;
    return [self fetchForm:@"linkform" error:error];
}


-(BOOL)parsePostResult:(NSURL *)location url:(NSString *)lf_url error:(NSError **)error
{
    NSParameterAssert(error);
    NSData *d = [NSData dataWithContentsOfURL:location options:0 error:error];
    if( *error )
        return NO;
    if( ![self parseAnyResponse:nil data:d error:error] )
        return NO;
    NSString *xpath = [NSString stringWithFormat:@"boolean(0 < count(/html/body//a[@href='%@']))", lf_url];
    return [self booleanForXPath:xpath error:error];
}


#pragma mark Public API


-(void)startPostForURL:(NSURL *)url title:(NSString *)title desc:(NSString *)desc
{
    MRLogD(@"-", nil);
    NSParameterAssert(self.session);
    NSParameterAssert(self.endpointUrl);
    NSParameterAssert(self.delegate);

    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:3];
    d[@"source"] = POST_SOURCE;
    d[@"post"] = url ? url.absoluteString : @"";
    if( title )
        d[@"title"] = title;
    if( desc )
        d[@"description"] = desc;

    NSString *par = @"?";
    par = [par stringByAppendingString:[d stringByAddingPercentEscapesForHttpFormUrl]];
    NSURL *cmd = [NSURL URLWithString:par relativeToURL:self.endpointUrl];
    NSURLSessionTask *dt = [self.session downloadTaskWithURL:cmd completionHandler:^(NSURL * location, NSURLResponse * response, NSError * error) {
                                MRLogD (@"%@", response.URL, nil);
                                MRLogD (@"%@", location, nil);
                                MRLogD (@"%@", error, nil);
                                if( !error ) {
                                    NSMutableDictionary *form = [self parseLoginForm:location error:&error];

                                    NSURLProtectionSpace *ps = [self.endpointUrl protectionSpace];
                                    NSURLCredential *cre0 = [self.session.configuration.URLCredentialStorage defaultCredentialForProtectionSpace:ps];
                                    NSParameterAssert (cre0);
                                    NSParameterAssert (cre0.user);
                                    NSParameterAssert (cre0.password);

                                    form[@"login"] = cre0.user;
                                    form[@"password"] = cre0.password;
                                    form[@"returnurl"] = [cmd absoluteString];
                                    [self postLoginForm:form toURL:response.URL];
                                } else
                                    [self.delegate didPostLoginForm:nil toURL:response.URL error:error];
                            }
                           ];
    [dt resume];
}


-(void)finishPostForm:(NSMutableDictionary *)form toURL:(NSURL *)url
{
    MRLogD(@"foo", nil);
    NSParameterAssert(self.session);
    NSParameterAssert(self.endpointUrl);
    NSParameterAssert(self.delegate);

    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    req.HTTPMethod = @"POST";
    form[@"lf_source"] = POST_SOURCE;
    form[@"save_edit"] = @"Save";
    req.HTTPBody = [form postData];

    NSURLSessionTask *dt = [self.session downloadTaskWithRequest:req completionHandler:^(NSURL * location, NSURLResponse * response, NSError * error) {
                                MRLogD (@"%@", response.URL, nil);
                                MRLogD (@"%@", location, nil);
                                MRLogD (@"%@", error, nil);
                                if( !error ) {
                                    NSURL *newUrl = [NSURL URLWithString:[form[@"lf_url"] stringByReplacingOccurrencesOfString:@"?" withString:@"/?#"] relativeToURL:self.endpointUrl];
                                    if( ![response.URL.absoluteString isEqualToString:[newUrl absoluteString]] ) {
                                        // look for the lf_url in the results list (see https://github.com/shaarli/Shaarli/issues/356 ).
                                        const BOOL ok = [self parsePostResult:location url:form[@"lf_url"] error:&error];
                                        if( !ok ) {
                                            error = [NSError errorWithDomain:SHAARLI_ERROR_DOMAIN code:SHAARLI_ERROR_NO_LINK_ADDED userInfo:@ { NSURLErrorKey:url, NSLocalizedDescriptionKey:NSLocalizedString (@"Couldn't find added link in shaarli API reply.", @"ShaarliPostCmd.m") }
                                                    ];
                                        }
                                    }
                                }
                                [self.delegate didFinishPostFormToURL:response.URL error:error];
                            }
                           ];
    [dt resume];
}


@end