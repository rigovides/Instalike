//
//  LikeMediaTableViewCell.m
//  Instalike
//
//  Created by Rigoberto Vides on 5/30/11.
//  Copyright 2011 personal. All rights reserved.
//

#import "LikeMediaTableViewCell.h"

@implementation LikeMediaTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        //resize the cell
        self.frame = CGRectMake(0, 0, 310, 400);
        
        //construct the elemets
        UIImageView *userPicture = [[UIImageView alloc] initWithFrame:CGRectMake(7, 4, 42, 42)];
        userPicture.tag = 100;
        UILabel *userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(47, 5, 130, 21)];
        userNameLabel.tag = 200;
        UILabel *likesLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 5, 130, 21)];
        likesLabel.tag = 300;
        UIImageView *mediaImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 49, 306, 306)];
        mediaImageView.tag = 400;
        UITextView *captionTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 355, 320, 45)];
        captionTextView.tag = 500;
        [captionTextView setEditable:NO];
        
        //add the elements to the cell
        [self.contentView addSubview:userPicture];
        [self.contentView addSubview:userNameLabel];
        [self.contentView addSubview:likesLabel];
        [self.contentView addSubview:mediaImageView];
        [self.contentView addSubview:captionTextView];
        
        [userPicture release];
        [userNameLabel release];
        [likesLabel release];
        [mediaImageView release];
        [captionTextView release];
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc
{
    [super dealloc];
}

@end
