//
//  BTSAppDelegate.h
//  iBTStatsServer
//
//  Created by Labs on 5/11/13.
//  Copyright (c) 2013 TeraMoLabs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BSSAppDelegate : NSObject <NSApplicationDelegate, NSNetServiceBrowserDelegate>

@property (assign) IBOutlet NSWindow *window;
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
- (IBAction)connectButtonPressed:(id)sender;

@end
