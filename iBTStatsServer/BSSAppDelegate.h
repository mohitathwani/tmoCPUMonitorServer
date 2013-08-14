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

/**
 * Browser to look for services nearby
 */
@property (nonatomic, retain) NSNetServiceBrowser *browser;

/** 
 * Array to hold all services (iPhones) available
 */
@property (nonatomic, retain) NSMutableArray *services;

/**
 * The dictionary data that is to be sent to the iPhone
 */
@property (nonatomic, retain) NSDictionary *infoDictionary;

/**
 * Array that holds the fan speed values
 * Can hold either 1 or 2 values depending on the number of fans available
 */
@property (nonatomic, retain) NSMutableArray *fanSpeeds;

/**
 * Holds the CPU temperature
 */
@property (nonatomic, retain) NSNumber *cpuTemp;

/**
 * Textfield where CPU temperature is displayed
 */
@property (assign) IBOutlet NSTextField *cpuTempField;

/**
 * Textfield to show the value of one fan
 */
@property (assign) IBOutlet NSTextField *fanSpeed1;

/**
 * Textfield to show the value of the other fan
 */
@property (assign) IBOutlet NSTextField *fanSpeed2;

/**
 * Textfield to show the service name
 */
@property (assign) IBOutlet NSTextField *serviceNameTextField;

/**
 * Connect Button
 */
@property (assign) IBOutlet NSButton *connectButton;

/**
 * Timer that will send data to the iPhone every second
 */
@property (nonatomic, retain) NSTimer *dataTransmitTimer;

/**
 * Scan sheet window
 */
@property (assign) IBOutlet NSWindow *scanWindow;

/**
 * Table view to show all iPhones nearby
 */
@property (assign) IBOutlet NSTableView *iphoneTableView;

/**
 * Array controller for binding with table view
 */
@property (assign) IBOutlet NSArrayController *arrayController;

/**
 * Selected row in Table view
 */
@property (nonatomic) NSInteger selectedRow;

/**
 * the NSNetService object we want to connect to
 */
@property (nonatomic, retain) NSNetService *service;

/**
 * Temperature returned from C
 */
@property (nonatomic) float c_temp;

/**
 * Invoked when user presses the "Search" button
 */
- (IBAction)connectButtonPressed:(id)sender;

/**
 * Invoked when Cancel button is pressed in the scan sheet
 */
- (IBAction)cancelButtonPressed:(id)sender;

/**
 * Invoked when "Connect" button pressed in the scan sheet
 */
- (IBAction)closeScanSheet:(id)sender;

@end
