//
//  BTSAppDelegate.h
//  iBTStatsServer
//
//  Created by Labs on 5/11/13.
//  Copyright (c) 2013 TeraMoLabs. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KBButton.h"

@interface BSSAppDelegate : NSObject <NSApplicationDelegate, NSNetServiceBrowserDelegate, NSTableViewDataSource, NSTableViewDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSView *view;
@property (nonatomic, retain) NSNetServiceBrowser *browser;
@property (nonatomic, retain) NSMutableArray *services;
@property (nonatomic, retain) NSDictionary *infoDictionary;
@property (nonatomic, retain) NSMutableArray *fanSpeeds;
@property (nonatomic, retain) NSNumber *cpuTemp;
@property (assign) IBOutlet NSTextField *cpuTempField;
@property (assign) IBOutlet NSTextField *fanSpeed1;
@property (assign) IBOutlet NSTextField *fanSpeed2;
@property (assign) IBOutlet NSTextField *rpm2;
@property (assign) IBOutlet NSTextField *serviceNameTextField;
@property (assign) IBOutlet NSButton *connectButton;
@property (nonatomic, retain) NSTimer *connectButtonTimer;
@property (assign) IBOutlet NSWindow *scanWindow;
@property (assign) IBOutlet NSTableView *iphoneTableView;
@property (assign) IBOutlet NSArrayController *arrayController;

- (IBAction)connectButtonPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)closeScanSheet:(id)sender;

@end
