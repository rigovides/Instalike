//
//  LikeMediaModel.h
//  Instalike
//
//  Created by Rigoberto Vides on 5/30/11.
//  Copyright 2011 personal. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LikeMediaModel : NSObject 
{
    
    NSDictionary *jsonData;
    UIImage *userImage;
    UIImage *picture;
    NSString *userImageURL;
    NSString *pictureURL;
    
}

@property (nonatomic, retain) NSDictionary *jsonData;
@property (nonatomic, retain) UIImage *userImage;
@property (nonatomic, retain) UIImage *picture;
@property (nonatomic, retain) NSString *userImageURL;
@property (nonatomic, retain) NSString *pictureURL;

@end
