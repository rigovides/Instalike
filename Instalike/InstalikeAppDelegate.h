//
//  InstalikeAppDelegate.h
//  Instalike
//
//  Created by Rigoberto Vides on 5/28/11.
//  Copyright 2011 personal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GTMOAuthAuthentication;
@class Reachability;

@interface InstalikeAppDelegate : NSObject <UIApplicationDelegate> {
    
    Reachability* internetReachable;

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (GTMOAuthAuthentication *)myCustomAuth;
- (void) checkNetworkStatus:(NSNotification *)notice;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end
