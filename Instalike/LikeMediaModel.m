//
//  LikeMediaModel.m
//  Instalike
//
//  Created by Rigoberto Vides on 5/30/11.
//  Copyright 2011 personal. All rights reserved.
//

#import "LikeMediaModel.h"


@implementation LikeMediaModel

@synthesize jsonData, userImage, picture, userImageURL, pictureURL;

- (void)dealloc
{
    [userImageURL release];
    [pictureURL release];
    [jsonData release];
    [userImage release];
    [picture release];
}

@end
