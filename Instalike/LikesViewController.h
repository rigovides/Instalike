//
//  LikesViewController.h
//  Instalike
//
//  Created by Rigoberto Vides on 5/30/11.
//  Copyright 2011 personal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LikeImageDownloader.h"
#import "UserIconDownloader.h"

@class LikeMediaModel;

@interface LikesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, LikeImageDownloaderDelegate, UserIconDownloaderDelegate, UIAlertViewDelegate>
{
    NSData *receivedData;
    NSMutableArray *likeItems;
    UITableView *myTableView;
    
    NSMutableDictionary *imageDownloadsInProgress;
    NSMutableDictionary *userImageDownloadsInProgress; //TODO, SINCE USERS CAN BE REPEATED, THIS CAN BE OPTIMIZED
    
    UIImage *likePlaceholder;
    
    NSString *nextPageRequest;
    
    BOOL isLoading;
    
}

@property (nonatomic, retain) NSMutableArray *likeItems;
@property (nonatomic, retain) IBOutlet UITableView *myTableView;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, retain) NSMutableDictionary *userImageDownloadsInProgress;
@property (nonatomic, retain) NSString *nextPageRequest;

- (void)startIconDownload:(LikeMediaModel *)appRecord forIndexPath:(NSIndexPath *)indexPath;
- (void)startUserIconDownload:(LikeMediaModel *)appRecord forIndexPath:(NSIndexPath *)indexPath;
- (void)appImageDidLoad:(NSIndexPath *)indexPath;
- (void)userImageDidLoad:(NSIndexPath *)indexPath;
-(void)requestNextPageForURL:(NSString*)nextPage;

-(void)logout;

-(IBAction)refreshFeed:(id)sender;
-(IBAction)logoutAction:(id)sender;

@end
