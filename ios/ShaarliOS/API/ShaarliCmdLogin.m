//
// ShaarliCmdLogin.m
// ShaarliOS
//
// Created by Marcus Rohrmoser on 12.10.15.
// Copyright (c) 2015-2016 Marcus Rohrmoser http://mro.name/me. All rights reserved.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "ShaarliCmdLogin.h"

@interface ShaarliCmdLogin()
@end

@implementation ShaarliCmdLogin

-(instancetype)initWithResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError **)error
{
    if( self = [super initWithResponse:response data:data error:error] ) {
        self.form = @"loginform";
        if( ![self fetchToken:error] ) {
            if( error )
                *error = [NSError errorWithDomain:SHAARLI_ERROR_DOMAIN code:SHAARLI_ERROR_NO_TOKEN userInfo:@ { NSURLErrorKey:response.URL, NSLocalizedDescriptionKey:NSLocalizedString(@"No token found.", @"ShaarliM") }
                         ];
            return nil;
        }
    }
    return self;
}


-(BOOL)receivedPost1Response:(NSURLResponse *)response data:(NSData *)data error:(NSError **)error
{
    self.form = nil; // there's no more to come
    return [super receivedPost1Response:response data:data error:error];
}


@end
