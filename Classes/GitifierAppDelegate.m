// -------------------------------------------------------
// GitifierAppDelegate.m
//
// Copyright (c) 2010 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import <Growl/GrowlApplicationBridge.h>

#import "Commit.h"
#import "Defaults.h"
#import "Git.h"
#import "GitifierAppDelegate.h"
#import "PreferencesWindowController.h"
#import "Repository.h"
#import "RepositoryListController.h"
#import "StatusBarController.h"
#import "Utils.h"

@implementation GitifierAppDelegate

@synthesize monitor, userEmail, preferencesWindowController, statusBarController,
  repositoryListController, repositoryList;

- (void) applicationDidFinishLaunching: (NSNotification *) aNotification {
  repositoryList = [NSMutableArray array];
  [Defaults registerDefaults];
  [GrowlApplicationBridge setGrowlDelegate: (id) @""];
  [self updateUserEmail];
  [repositoryListController loadRepositories];
  [statusBarController createStatusBarItem];
  [monitor startMonitoring];

  if ([[repositoryListController repositoryList] count] == 0) {
    [preferencesWindowController showPreferences: self];
  }
}

- (void) applicationWillTerminate: (NSNotification *) notification {
  [repositoryListController saveRepositories];
}

- (void) updateUserEmail {
  Git *git = [[Git alloc] initWithDelegate: self];
  [git runCommand: @"config" withArguments: PSArray(@"user.email") inPath: NSHomeDirectory()];
}

- (void) commandCompleted: (NSString *) command output: (NSString *) output {
  if ([command isEqual: @"config"] && output && output.length > 0) {
    userEmail = [output psTrimmedString];
    PSNotifyWithData(UserEmailChangedNotification, PSDict(userEmail, @"email"));
  }
}

- (void) commitsReceived: (NSArray *) commits inRepository: (Repository *) repository {
  BOOL ignoreMerges = [GitifierDefaults boolForKey: IGNORE_MERGES_KEY];
  BOOL ignoreOwnCommits = [GitifierDefaults boolForKey: IGNORE_OWN_COMMITS];
  for (Commit *commit in [commits reverseObjectEnumerator]) {
    if (ignoreMerges && [commit isMergeCommit]) {
      return;
    }
    if (ignoreOwnCommits && [commit.authorEmail isEqual: userEmail]) {
      return;
    }
    [GrowlApplicationBridge notifyWithTitle: PSFormat(@"%@ – %@", commit.authorName, repository.name)
                                description: commit.subject
                           notificationName: @"Commit received"
                                   iconData: nil
                                   priority: 0
                                   isSticky: NO
                               clickContext: nil];
  }
}

@end
