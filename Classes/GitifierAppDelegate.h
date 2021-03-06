// -------------------------------------------------------
// GitifierAppDelegate.h
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Cocoa/Cocoa.h>

@class Monitor;
@class PreferencesWindowController;
@class RepositoryListController;
@class StatusBarController;

@interface GitifierAppDelegate : NSObject <NSApplicationDelegate> {
  NSString *userEmail;
  NSMutableArray *repositoryList;
  Monitor *monitor;
  StatusBarController *statusBarController;
  PreferencesWindowController *preferencesWindowController;
  RepositoryListController *repositoryListController;
}

@property (readonly) NSString *userEmail;
@property (assign) NSMutableArray *repositoryList;
@property IBOutlet Monitor *monitor;
@property IBOutlet StatusBarController *statusBarController;
@property IBOutlet PreferencesWindowController *preferencesWindowController;
@property IBOutlet RepositoryListController *repositoryListController;

- (IBAction) showPreferences: (id) sender;
- (IBAction) quit: (id) sender;
- (void) showGrowlWithError: (NSString *) message;

// private
- (void) updateUserEmail;
- (void) loadGitPath;
- (void) findGitPath;
- (void) validateGitPath;
- (void) showGrowlWithTitle: (NSString *) title
                    message: (NSString *) message
                       type: (NSString *) type
                     sticky: (BOOL) sticky;

@end
