//
//  LoginViewController.h
//  Instalike
//
//  Created by Rigoberto Vides on 5/28/11.
//  Copyright 2011 personal. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoginViewController : UIViewController 
{
    
    
}

@property (nonatomic, retain) IBOutlet UILabel *logoLabel;

- (void)signInToInstagram;
-(void) signInWithSafari;
- (IBAction) signInAction:(id)sender;


@end
