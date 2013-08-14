//
//  BTSAppDelegate.m
//  iBTStatsServer
//
//  Created by Labs on 5/11/13.
//  Copyright (c) 2013 TeraMoLabs. All rights reserved.
//

#import "BSSAppDelegate.h"
#import "smcWrapper.h"
#import "NSTimer+BlocksKit.h"

@implementation BSSAppDelegate

#pragma mark Standard App code
- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    [smcWrapper init];
    
    self.fanSpeeds = [[NSMutableArray alloc] init];
        
    NSImage *windowBG = [NSImage imageNamed:@"greenBG.png"];
    [[self.window contentView] setWantsLayer:YES];
    [[self.window contentView] layer].contents = windowBG;
    
    [[self.connectButton cell] setKBButtonType:BButtonTypeInverse];
    
    [self.serviceNameTextField setBezeled:NO];
    [self.serviceNameTextField setDrawsBackground:NO];
    
    self.iphoneTableView.dataSource = self;
    self.iphoneTableView.delegate = self;
    
//    NSLog(@"%f",[smcWrapper get_maintemp]);
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 block:^(NSTimeInterval time) {
        self.c_temp=[smcWrapper get_maintemp];
        self.cpuTemp = [NSNumber numberWithFloat:self.c_temp];
        
        [self.fanSpeeds removeAllObjects];
        int i;
        for(i=0;i<[smcWrapper get_fan_num];i++){
            int x = [smcWrapper get_fan_rpm:i];
            [self.fanSpeeds addObject: [NSNumber numberWithInt:x]];
            
        }
        
        [self.cpuTempField setStringValue: [NSString stringWithFormat:@"%@",self.cpuTemp]];
        
        if ([self.fanSpeeds count] == 2) {
            [self.fanSpeed1 setStringValue: [NSString stringWithFormat:@"%@",[self.fanSpeeds objectAtIndex:0]]];
            [self.fanSpeed2 setStringValue: [NSString stringWithFormat:@"%@",[self.fanSpeeds objectAtIndex:1]]];
        }
        
        else {
            [self.fanSpeed1 setStringValue: [NSString stringWithFormat:@"%@",[self.fanSpeeds objectAtIndex:0]]];
        }
    } repeats:YES];

}

#pragma mark NSNetServiceBrowser delegates

/**
 * Called when the browser finds a service(s)
 */
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    
    [self.services addObject:aNetService];
    
    [self.arrayController addObject:@{@"iPhones": [NSString stringWithFormat:@"%@", [aNetService name]]}];
    NSLog(@"%@",aNetService);
    
    [aNetService resolveWithTimeout:5.0];
}

/**
 * Called when the browser looses/removes a service
 */
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    [self.arrayController removeObject:@{@"iPhones":[aNetService name]}];
    self.service = nil;
    [self.browser stop];
    [self.services removeAllObjects];
    [self.connectButton setTitle:@"Search"];
}

- (IBAction)connectButtonPressed:(id)sender {
        
    if ([[sender title] isEqualToString:@"Search"]) {
        [NSApp beginSheet:self.scanWindow modalForWindow:self.window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
        self.browser = [[NSNetServiceBrowser alloc] init];
        self.services = [[NSMutableArray alloc] init];
        [self.browser setDelegate:self];
        [self.browser searchForServicesOfType:@"_tmoCPUMon._tcp." inDomain:@""];
    }
    else if ([[sender title] isEqualToString:@"Stop"]) {
        self.service = nil;
        [self.browser stop];
        
        [sender setTitle:@"Search"];
        [self.serviceNameTextField setEditable:YES];
        [self.dataTransmitTimer invalidate];
        
        NSRange range = NSMakeRange(0, [[self.arrayController arrangedObjects] count]);
        [self.arrayController removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];

        [self.services removeAllObjects];
        
    }

}

/*
 This method is called when Scan sheet is closed. Initiate connection to selected service
 */
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    if( returnCode == NSAlertDefaultReturn )
    {
        NSLog(@"Initiate connection here : %ld", (long)self.selectedRow);
         
         self.dataTransmitTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 block:^(NSTimeInterval time) {
//         float c_temp=[smcWrapper get_maintemp];
//         self.cpuTemp = [NSNumber numberWithFloat:c_temp];
         
//         [self.fanSpeeds removeAllObjects];
//         int i;
//         for(i=0;i<[smcWrapper get_fan_num];i++){
//         int x = [smcWrapper get_fan_rpm:i];
//         [self.fanSpeeds addObject: [NSNumber numberWithInt:x]];
         
//         }
         
         self.infoDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.cpuTemp,@"cpuTemp",self.fanSpeeds,@"fanSpeeds", nil];
         
//         [self.cpuTempField setStringValue: [NSString stringWithFormat:@"%@",self.cpuTemp]];
         
//         if ([self.fanSpeeds count] == 2) {
//         [self.fanSpeed1 setStringValue: [NSString stringWithFormat:@"%@",[self.fanSpeeds objectAtIndex:0]]];
//         [self.fanSpeed2 setStringValue: [NSString stringWithFormat:@"%@",[self.fanSpeeds objectAtIndex:1]]];
//         }
//         
//         else {
//         [self.fanSpeed1 setStringValue: [NSString stringWithFormat:@"%@",[self.fanSpeeds objectAtIndex:0]]];
//         }
         
         NSData *appData = [NSKeyedArchiver archivedDataWithRootObject:self.infoDictionary];
         self.service = [self.services objectAtIndex: self.selectedRow];
         if(self.service) {
             self.serviceNameTextField.stringValue = [self.service name];
         NSOutputStream *outStream;
         [self.service getInputStream:nil outputStream:&outStream];
         [outStream open];
         NSInteger bytes = [outStream write:[appData bytes] maxLength: [appData length]];
         [outStream close];
         
         NSLog(@"Wrote %ld bytes", (long)bytes);
         }
         
         if (self.c_temp < 65) {
         NSImage *windowBG = [NSImage imageNamed:@"greenBG.png"];
         [[self.window contentView] setWantsLayer:YES];
         [[self.window contentView] layer].contents = windowBG;
         }
         
         else if (self.c_temp >= 65 && self.c_temp <79) {
         NSImage *windowBG = [NSImage imageNamed:@"yellowBG.png"];
         [[self.window contentView] setWantsLayer:YES];
         [[self.window contentView] layer].contents = windowBG;
         }
         
         else if (self.c_temp >= 80) {
         NSImage *windowBG = [NSImage imageNamed:@"redBG.png"];
         [[self.window contentView] setWantsLayer:YES];
         [[self.window contentView] layer].contents = windowBG;
         }
         } repeats:YES];
         
         [self.serviceNameTextField setEditable:NO];
         [self.connectButton setTitle:@"Stop"];
         }
}

/*
 Close scan sheet once device is selected
 */
- (IBAction)closeScanSheet:(id)sender
{
    [NSApp endSheet:self.scanWindow returnCode:NSAlertDefaultReturn];
    [self.scanWindow orderOut:self];
    
    self.selectedRow = [self.iphoneTableView selectedRow];
}
/*
 Close scan sheet without choosing any device
 */
- (IBAction)cancelButtonPressed:(id)sender {

    [self.browser stop];
    NSRange range = NSMakeRange(0, [[self.arrayController arrangedObjects] count]);
    [self.arrayController removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
    [self.services removeAllObjects];
    [NSApp endSheet:self.scanWindow returnCode:NSAlertAlternateReturn];
    [self.scanWindow orderOut:self];

}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [self.services count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    return [@[@1,@2,@3] objectAtIndex:rowIndex];
//    return TRUE;
    
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    
}

@end
