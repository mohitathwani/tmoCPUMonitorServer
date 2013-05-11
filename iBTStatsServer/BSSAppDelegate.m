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

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    [smcWrapper init];
    
    self.fanSpeeds = [[NSMutableArray alloc] init];
    
    self.browser = [[NSNetServiceBrowser alloc] init];
    self.services = [[NSMutableArray array] retain];
    [self.browser setDelegate:self];
    [self.browser searchForServicesOfType:@"_iPhoneSyncService._tcp." inDomain:@""];


}

#pragma mark NSNetServiceBrowser delegates

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    
    [self.services addObject:aNetService];
    [aNetService resolveWithTimeout:5.0];
    
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

    
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
    [self.services removeObject:aNetService];
}

@end
