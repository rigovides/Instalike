//
//  LoginViewController.m
//  Instalike
//
//  Created by Rigoberto Vides on 5/28/11.
//  Copyright 2011 personal. All rights reserved.
//

#import "LoginViewController.h"
#import "InstalikeAppDelegate.h"

#import "LikesViewController.h"

@implementation LoginViewController

@synthesize logoLabel;

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
    [logoLabel release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Welcome";
    [self.logoLabel setFont:[UIFont fontWithName:@"HoneyScript-SemiBold" size:110]];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Class methods
-(void) signInWithSafari
{
    
//    LikesViewController *aViewController = [[LikesViewController alloc] initWithNibName:@"LikesViewController" bundle:[NSBundle mainBundle]];
//    
//    aViewController.view = aViewController.view;
//    
//    [self.navigationController pushViewController:aViewController animated:YES];
//    
//    [aViewController release];
//    
//    return;
    
    //use your custom client id here, 
    //oh and please, don´t be evil with these one. Thanks.
    NSURL *url = [NSURL URLWithString:@"https://instagram.com/oauth/authorize/?client_id=5bec4ee3aee2493a8779aa6758f3ba5c&display=touch&redirect_uri=instalike://&response_type=token"];
    
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - IBActions
- (IBAction) signInAction:(id)sender
{
    [self signInWithSafari];
}

@end
