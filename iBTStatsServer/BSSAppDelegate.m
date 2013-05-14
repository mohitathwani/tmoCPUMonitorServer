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

#define EMPTY_STRING @""

@implementation BSSAppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    [smcWrapper init];
    
    self.fanSpeeds = [[NSMutableArray alloc] init];
    
    


}

#pragma mark NSNetServiceBrowser delegates

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    
    [self.services addObject:aNetService];
    NSLog(@"%@",aNetService);
    [aNetService resolveWithTimeout:5.0];
    
    NSString *serviceNameString = [NSString stringWithFormat:@"%@", aNetService];
    if ([serviceNameString rangeOfString:self.serviceNameTextField.stringValue].location == NSNotFound) {
        NSLog(@"string does not contain bla");
        self.connectButton.enabled = !self.connectButton.isEnabled;
    } else {
        NSLog(@"string contains bla!");
        
        [NSTimer scheduledTimerWithTimeInterval:1.0 block:^(NSTimeInterval time) {
            float c_temp=[smcWrapper get_maintemp];
            self.cpuTemp = [NSNumber numberWithFloat:c_temp];
            //printf("%f\n",c_temp);
            
            [self.fanSpeeds removeAllObjects];
            int i;
            for(i=0;i<[smcWrapper get_fan_num];i++){
                int x = [smcWrapper get_fan_rpm:i];
                [self.fanSpeeds addObject: [NSNumber numberWithInt:x]];
                
            }
            
            self.infoDictionary = [NSDictionary dictionaryWithObjectsAndKeys:self.cpuTemp,@"cpuTemp",self.fanSpeeds,@"fanSpeeds", nil];
            
            [self.cpuTempField setStringValue: [NSString stringWithFormat:@"%@",self.cpuTemp]];
            
            if ([self.fanSpeeds count] == 2) {
                [self.fanSpeed1 setStringValue: [NSString stringWithFormat:@"%@",[self.fanSpeeds objectAtIndex:0]]];
                [self.fanSpeed2 setStringValue: [NSString stringWithFormat:@"%@",[self.fanSpeeds objectAtIndex:1]]];
            }
            
            else {
                [self.fanSpeed2 setHidden:YES];
                [self.rpm2 setHidden:YES];
            }
            
            NSData *appData = [NSKeyedArchiver archivedDataWithRootObject:self.infoDictionary];
            //        NSDictionary *myDictionary = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:appData];
            //        NSLog(@"%@", myDictionary);
            NSNetService *service = [self.services objectAtIndex: 0];
            if(service) {
                NSOutputStream *outStream;
                [service getInputStream:nil outputStream:&outStream];
                [outStream open];
                NSInteger bytes = [outStream write:[appData bytes] maxLength: [appData length]];
                [outStream close];
                
                //NSLog(@"Wrote %ld bytes", (long)bytes);
            }
        } repeats:YES];
        
        [self.serviceNameTextField setEditable:NO];
        self.connectButton.enabled = !self.connectButton.isEnabled;
        [self.connectButton setTitle:@"Stop"];
    }
    


    
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    [self.services removeObject:aNetService];
//    self.connectButton.enabled = !self.connectButton.isEnabled;
}

- (IBAction)connectButtonPressed:(id)sender {
    
    if (![self.serviceNameTextField.stringValue isEqualToString:EMPTY_STRING] && [[sender title] isEqualToString:@"Connect"]) {
        self.connectButton.enabled = !self.connectButton.isEnabled;
        self.browser = [[NSNetServiceBrowser alloc] init];
        self.services = [[NSMutableArray array] retain];
        [self.browser setDelegate:self];
        [self.browser searchForServicesOfType:@"_iPhoneSyncService._tcp." inDomain:@""];
        NSLog(@"Service Name: %@", self.serviceNameTextField.stringValue);
    }
    
    else if ([[sender title] isEqualToString:@"Stop"]) {
        [self.services removeAllObjects];
        [sender setTitle:@"Connect"];
        [self.serviceNameTextField setEditable:YES];
        
    }

}
@end
