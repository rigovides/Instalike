//
//  UserIconDownloader.h
//  Instalike
//
//  Created by Rigoberto Vides on 5/30/11.
//  Copyright 2011 personal. All rights reserved.
//

#import <Foundation/Foundation.h>


@class LikeMediaModel;

@protocol UserIconDownloaderDelegate;

@interface UserIconDownloader : NSObject
{
    LikeMediaModel *appRecord;
    NSIndexPath *indexPathInTableView;
    id <UserIconDownloaderDelegate> delegate;
    
    NSMutableData *activeDownload;
    NSURLConnection *imageConnection;
}

@property (nonatomic, retain) LikeMediaModel *appRecord;
@property (nonatomic, retain) NSIndexPath *indexPathInTableView;
@property (nonatomic, assign) id <UserIconDownloaderDelegate> delegate;

@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;

- (void)startDownload;
- (void)cancelDownload;

@end

@protocol UserIconDownloaderDelegate 

- (void)userImageDidLoad:(NSIndexPath *)indexPath;
@end
