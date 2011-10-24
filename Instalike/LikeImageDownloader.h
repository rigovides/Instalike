//
//  LikeImageDownloader.h
//  Instalike
//
//  Created by Rigoberto Vides on 5/30/11.
//  Copyright 2011 personal. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LikeMediaModel;

@protocol LikeImageDownloaderDelegate;

@interface LikeImageDownloader : NSObject
{
    LikeMediaModel *appRecord;
    NSIndexPath *indexPathInTableView;
    id <LikeImageDownloaderDelegate> delegate;
    
    NSMutableData *activeDownload;
    NSURLConnection *imageConnection;
}

@property (nonatomic, retain) LikeMediaModel *appRecord;
@property (nonatomic, retain) NSIndexPath *indexPathInTableView;
@property (nonatomic, assign) id <LikeImageDownloaderDelegate> delegate;

@property (nonatomic, retain) NSMutableData *activeDownload;
@property (nonatomic, retain) NSURLConnection *imageConnection;

- (void)startDownload;
- (void)cancelDownload;

@end

@protocol LikeImageDownloaderDelegate 

- (void)appImageDidLoad:(NSIndexPath *)indexPath;
@end
