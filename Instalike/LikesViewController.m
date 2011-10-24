//
//  LikesViewController.m
//  Instalike
//
//  Created by Rigoberto Vides on 5/30/11.
//  Copyright 2011 personal. All rights reserved.
//

#import "LikesViewController.h"
#import "LikeMediaTableViewCell.h"
#import "LikeMediaModel.h"
#import "JSON.h"
#import "InstalikeAppDelegate.h"

@implementation LikesViewController

@synthesize myTableView;
@synthesize likeItems;
@synthesize imageDownloadsInProgress;
@synthesize userImageDownloadsInProgress;
@synthesize nextPageRequest;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [nextPageRequest release];
    [likePlaceholder release];
    [likeItems release];
    [myTableView release];
    [imageDownloadsInProgress release];
    [userImageDownloadsInProgress release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    
    // terminate all pending download connections
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
    NSArray *allUserDownloads = [self.userImageDownloadsInProgress allValues];
    [allUserDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    self.userImageDownloadsInProgress = [NSMutableDictionary dictionary];
    
    likePlaceholder = [[UIImage imageNamed:@"instalike_placeholder.png"] retain];
    
//    [self.myTableView setScrollsToTop:YES];
    
    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshFeed:)];
    
    [self.navigationItem setRightBarButtonItem:reloadButton];
    
    [reloadButton release];
    
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonItemStyleBordered target:self action:@selector(logoutAction:)];
    
    logoutButton.title = @"Logout";
    
    [self.navigationItem setLeftBarButtonItem:logoutButton];
    
    [logoutButton release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIApplication *app = [UIApplication sharedApplication];
    
    app.networkActivityIndicatorVisible = YES;
    
    //Do the async request here
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *authKey = [userDefaults objectForKey:@"authKey"];
    
    NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/media/liked?access_token=%@", authKey]];
    
    // Create the request.
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:requestURL
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    // create the connection with the request
    // and start loading the data
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        receivedData = [[NSMutableData data] retain];
    } else {
        // Inform the user that the connection failed.
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return ( [likeItems count] + 1 ) ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSString *LoadMoreCellIdentifier = @"LoadMore";
    
    LikeMediaTableViewCell *cell = (LikeMediaTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[LikeMediaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UITableViewCell *loadMoreCell = [tableView dequeueReusableCellWithIdentifier:LoadMoreCellIdentifier];
    if(loadMoreCell == nil)
    {
        loadMoreCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LoadMoreCellIdentifier] autorelease];
    }
    
    if(indexPath.row == [likeItems count])
    {
        loadMoreCell.textLabel.text = @"Load More";
        return loadMoreCell;
    }
    
    // Configure the cell...
    LikeMediaModel *model = (LikeMediaModel *)[self.likeItems objectAtIndex:indexPath.row];
    //cell.textLabel.text = [[model.jsonData valueForKey:@"user"] valueForKey:@"username"];
    
    UILabel *aLabel = (UILabel *)[cell.contentView viewWithTag:200];
    aLabel.text = [[model.jsonData valueForKey:@"user"] valueForKey:@"username"];
    
    aLabel = (UILabel *)[cell.contentView viewWithTag:300];
    aLabel.text = [NSString stringWithFormat:@"%d", [[[model.jsonData valueForKey:@"likes"] valueForKey:@"count"] intValue]];
    
    UITextView *aTextView = (UITextView *)[cell.contentView viewWithTag:500];
    
    id jsonCaption = [model.jsonData valueForKey:@"caption"];

    if(!(jsonCaption == [NSNull null]))
    {
        
        aTextView.text = (NSString *)[[model.jsonData valueForKey:@"caption"] valueForKey:@"text"];
    }
    else
    {
        aTextView.text = @"";
    }
    
    //da pictures
    int nodeCount = [self.likeItems count];
    // Leave cells empty if there's no data yet, we could send nil to the downloaders
    if (nodeCount > 0)
	{
        // Only load cached images; defer new downloads until scrolling ends
        if (!model.picture)
        {
            if (self.myTableView.dragging == NO && self.myTableView.decelerating == NO)
            {
                [self startIconDownload:model forIndexPath:indexPath];
            }
            // if a download is deferred or in progress, return a placeholder image
            //cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
            UIImageView *anImageView = (UIImageView *)[cell.contentView viewWithTag:400];
            anImageView.image = likePlaceholder; 
            
        }
        else
        {
//            cell.imageView.image = appRecord.appIcon;
            UIImageView *anImageView = (UIImageView *)[cell.contentView viewWithTag:400];
            anImageView.image = model.picture;
            
        }
        
        //LAZY LOAD THE USER IMAGES
        if (!model.userImage)
        {
            if (self.myTableView.dragging == NO && self.myTableView.decelerating == NO)
            {
                [self startUserIconDownload:model forIndexPath:indexPath];
            }
            // if a download is deferred or in progress, return a placeholder image
            //cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];
            UIImageView *anImageView = (UIImageView *)[cell.contentView viewWithTag:100];
            anImageView.image = nil; 
            
        }
        else
        {
            //            cell.imageView.image = appRecord.appIcon;
            UIImageView *anImageView = (UIImageView *)[cell.contentView viewWithTag:100];
            anImageView.image = model.userImage;
            
        }
    }
    
    NSLog(@"returning cell");
    return cell;
}


#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row == [self.likeItems count])
    {
        [self requestNextPageForURL:self.nextPageRequest];
    }
    
    //probably good place to load more (I´d love a button tho)
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //load more cell
    if(indexPath.row == [self.likeItems count])
    {
        return 50;
    }
    
    return 400.0;
    
}


#pragma mark - NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    isLoading = NO;
    
    UIApplication *app = [UIApplication sharedApplication];
    
    app.networkActivityIndicatorVisible = NO;
    
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    isLoading = NO;
    
    UIApplication *app = [UIApplication sharedApplication];
    
    app.networkActivityIndicatorVisible = NO;
    
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
    
    NSString *receivedString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    
    NSLog(@"RESPONSE FROM IG:%@", receivedString);
    
    NSArray *jsonData = [[receivedString JSONValue] valueForKey:@"data"];
    
    NSDictionary *jsonPagination = [[receivedString JSONValue] valueForKey:@"pagination"];
    
    
    
    if (![jsonPagination objectForKey:@"next_url"]) 
    {
        self.nextPageRequest = @"END";
    }
    else
    {
        
        self.nextPageRequest = (NSString *)[jsonPagination objectForKey:@"next_url"];
        NSLog(@"HAS MORE PAGES:%@", self.nextPageRequest);
    }
    
    //if our items array is not initialized yet
    if (self.likeItems == nil) 
    {
        NSLog(@"INIT THE ARRAY DATA WITH:%d", [jsonData count]);
        self.likeItems = [[NSMutableArray alloc] initWithCapacity:[jsonData count]];
    }
    
    for(id element in jsonData)
    {
        
        NSLog(@"MEDIA TO ADD:%@", [[element valueForKey:@"user"] valueForKey:@"username"]);
        
        LikeMediaModel *model = [[LikeMediaModel alloc] init];
        model.pictureURL =  [[[element valueForKey:@"images"] valueForKey:@"low_resolution"] valueForKey:@"url"];
        model.userImageURL = [[element valueForKey:@"user"] valueForKey:@"profile_picture"];
        model.jsonData = element;
        
        [self.likeItems addObject:model];
        
        [model release];
    }
    
    NSLog(@"finished parsing!");
    
    [receivedString release];
    
    // release the connection, and the data object
    [connection release];
    [receivedData release];
    
    [self.myTableView reloadData];
}


#pragma mark - LazyLoad methods

- (void)startIconDownload:(LikeMediaModel *)appRecord forIndexPath:(NSIndexPath *)indexPath
{
    LikeImageDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil) 
    {
        iconDownloader = [[LikeImageDownloader alloc] init];
        iconDownloader.appRecord = appRecord;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
        [iconDownloader release];   
    }
}

- (void)startUserIconDownload:(LikeMediaModel *)appRecord forIndexPath:(NSIndexPath *)indexPath
{
    UserIconDownloader *iconDownloader = [userImageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil) 
    {
        iconDownloader = [[UserIconDownloader alloc] init];
        iconDownloader.appRecord = appRecord;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [userImageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
        [iconDownloader release];   
    }
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if ([self.likeItems count] > 0)
    {
        NSArray *visiblePaths = [self.myTableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            if(indexPath.row == [self.likeItems count])
            {
                continue;
            }
            
            LikeMediaModel *appRecord = [self.likeItems objectAtIndex:indexPath.row];
            
            if (!appRecord.picture) // avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:appRecord forIndexPath:indexPath];
            }
        }
    }
}

- (void)loadUserImagesForOnscreenRows
{
    if ([self.likeItems count] > 0)
    {
        NSArray *visiblePaths = [self.myTableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            if(indexPath.row == [self.likeItems count])
            {
                continue;
            }
            
            LikeMediaModel *appRecord = [self.likeItems objectAtIndex:indexPath.row];
            
            if (!appRecord.userImage) // avoid the app icon download if the app already has an icon
            {
                [self startUserIconDownload:appRecord forIndexPath:indexPath];
            }
        }
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    NSLog(@"IMAGE DID LOAD");
    LikeImageDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
    {
        NSLog(@"THE DOWNLOADER IS NOT NIL");
        LikeMediaTableViewCell *cell = (LikeMediaTableViewCell *)[self.myTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        
        // Display the newly loaded image
        
        UIImageView *anImageView = (UIImageView *)[cell.contentView viewWithTag:400];
        anImageView.image = iconDownloader.appRecord.picture;
    }
    
    //check if the next index path exists... (auto download)
    if (indexPath.row == ([self.likeItems count] - 1)) 
    {
        return;
    }
    
    NSLog(@"LAZY LOADING NEXT INDEX (%d)", indexPath.row+1);
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];

    
    [self startIconDownload:[self.likeItems objectAtIndex:indexPath.row+1] forIndexPath:nextIndexPath];
    
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)userImageDidLoad:(NSIndexPath *)indexPath
{
    NSLog(@"USER IMAGE DID LOAD");
    UserIconDownloader *iconDownloader = [userImageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
    {
        NSLog(@"THE USER DOWNLOADER IS NOT NIL");
        LikeMediaTableViewCell *cell = (LikeMediaTableViewCell *)[self.myTableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        
        // Display the newly loaded image
        
        UIImageView *anImageView = (UIImageView *)[cell.contentView viewWithTag:100];
        anImageView.image = iconDownloader.appRecord.userImage;
    }
    
    //check if the next index path exists... (auto download)
    if (indexPath.row == ([self.likeItems count] - 1)) 
    {
        return;
    }
    
    NSLog(@"LAZY LOADING NEXT INDEX FOR USER AT (%d)", indexPath.row+1);
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
    
    
    [self startUserIconDownload:[self.likeItems objectAtIndex:indexPath.row+1] forIndexPath:nextIndexPath];
    
}


#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
        [self loadUserImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
    [self loadUserImagesForOnscreenRows];
}

#pragma mark - Class methods
-(void)requestNextPageForURL:(NSString*)nextPage
{
    
    if(isLoading == YES)
    {
        NSLog(@"IS LOADING A REQUEST");
        return;
    }
    
    isLoading = YES;
    
    if ([nextPage isEqualToString:@"END"]) 
    {
        NSLog(@"END TRYING TO REQUEST WITH url:%@", nextPage);
        return;
    }
    
    UIApplication *app = [UIApplication sharedApplication];
    
    app.networkActivityIndicatorVisible = YES;
    
    NSLog(@"NOT END TRYING TO REQUEST WITH url:%@", nextPage);
    
    NSURL *requestURL = [NSURL URLWithString:nextPage];
    
    // Create the request.
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:requestURL
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    // create the connection with the request
    // and start loading the data
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        receivedData = [[NSMutableData data] retain];
    } else {
        // Inform the user that the connection failed.
    }
}

-(void)logout
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setBool:NO forKey:@"authenticated"];
    [userDefaults removeObjectForKey:@"authKey"];
    
    [userDefaults synchronize];
    
    // terminate all pending download connections
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
    NSArray *allUserDownloads = [self.userImageDownloadsInProgress allValues];
    [allUserDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
    
    [self.navigationController popViewControllerAnimated:NO];
    
}

#pragma mark - UIAlertViewDelegate protocol methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
   if(buttonIndex == 1)
   {
       [self logout];
   }
}

#pragma mark - IBActions
-(IBAction)refreshFeed:(id)sender
{
    
    NSLog(@"REFRESH FEED");
    
    // terminate all pending download connections for lazyloads
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
    [self.imageDownloadsInProgress removeAllObjects];
    
    NSArray *allUserDownloads = [self.userImageDownloadsInProgress allValues];
    [allUserDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
    [self.userImageDownloadsInProgress removeAllObjects];
    
    [self.likeItems removeAllObjects];
    
    [self.myTableView reloadData];
    
    //scroll tableView to top
    [self.myTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    
    
    UIApplication *app = [UIApplication sharedApplication];
    
    app.networkActivityIndicatorVisible = YES;
    
    //Do the async request here
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *authKey = [userDefaults objectForKey:@"authKey"];
    
    NSURL *requestURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.instagram.com/v1/users/self/media/liked?access_token=%@", authKey]];
    
    // Create the request.
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:requestURL
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    // create the connection with the request
    // and start loading the data
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        receivedData = [[NSMutableData data] retain];
    } else {
        // Inform the user that the connection failed.
    }
    
}

-(IBAction)logoutAction:(id)sender
{
    UIAlertView *anAlertView = [[UIAlertView alloc] initWithTitle:@"Just a sec!" message:@"This will unlink your Instagram account from Instalike, are you sure?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Logout", nil];
    
    [anAlertView show];
    
    [anAlertView release];
}


@end
