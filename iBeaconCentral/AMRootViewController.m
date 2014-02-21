//
//  AMRootViewController.m
//  iBeaconCentral
//
//  Created by Akinori Machino on 2014/02/19.
//  Copyright (c) 2014年 Akinori Machino. All rights reserved.
//

#import "AMRootViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>
#import "BCMBeaconManager.h"
#import "DPHue.h"
#import "DPHueLight.h"

static NSString * const kUUID = @"CD789C1A-D6E2-40C6-A255-ADD1E3AE8207";
static NSString * const kIdentifier = @"com.akinori-machino.iBeaconSample";

@implementation AMRootViewController
{
    AVAudioPlayer *_audioPlayer;
    CLLocationManager *_locationManager;
    NSUUID *_proximityUUID;
    CLBeaconRegion *_beaconRegion;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"tomita-theme" ofType:@"mp3"]];
        _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        
        if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
            _proximityUUID = [[NSUUID alloc] initWithUUIDString:kUUID];
            _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:_proximityUUID identifier:kIdentifier];

//            _locationManager = [CLLocationManager new];
//            _locationManager.delegate = self;
//            [_locationMafanager startMonitoringForRegion:_beaconRegion];
            
            [[BCMBeaconManager defaultManager] registerRegion:_beaconRegion enter:^(CLBeaconRegion *region){
                NSLog(@"Enter Region");
            } exit:^(CLBeaconRegion *region){
                NSLog(@"Exit Region");
            }];
            
            [[BCMBeaconManager defaultManager] notifyRegionFar:_beaconRegion
                                                        repeat:NO
                                                      interval:0
                                                    usingBlock:^(CLBeacon *beacon) {
                                                        [self playMusic];
                                                        [self lightHue];
                                                    }];
        }
    }
    return self;
}

//#pragma mark - CLLocationManagerDelegate methods
//
//- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
//{
//    [self sendLocalNotificationForMessage:@"Start Monitoring Region"];
//}
//
//- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
//{
//    [self sendLocalNotificationForMessage:@"Enter Region"];
//    
//    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
//        [_locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
//    }
//}
//
//- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
//{
//    [self sendLocalNotificationForMessage:@"Exit Region"];
//    
//    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
//        [_locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
//    }
//}
//
//- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
//{
//    if (beacons.count > 0) {
//        CLBeacon *nearestBeacon = beacons.firstObject;
//        
//        NSString *rangeMessage;
//        
//        switch (nearestBeacon.proximity) {
//            case CLProximityImmediate:
//                rangeMessage = @"Range Immediate: ";
//               [self playMusic];
//                break;
//            case CLProximityNear:
//                rangeMessage = @"Range Near: ";
//                break;
//            case CLProximityFar:
//                rangeMessage = @"Range Far: ";
//                [self playMusic];
//                break;
//            default:
//                rangeMessage = @"Range Unknown: ";
//                break;
//        }
//        
//        NSString *message = [NSString stringWithFormat:@"major:%@, minor:%@, accuracy:%f, rssi:%d",
//                             nearestBeacon.major, nearestBeacon.minor, nearestBeacon.accuracy, nearestBeacon.rssi];
//        [self sendLocalNotificationForMessage:[rangeMessage stringByAppendingString:message]];
//    }
//}
//
//- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
//{
//    [self sendLocalNotificationForMessage:@"Exit Region"];
//}

#pragma mark - Private methods

- (void)playMusic
{
    if (_audioPlayer != nil) {
        NSLog(@"Play Music!");
        [_audioPlayer prepareToPlay];
        [_audioPlayer play];
    }
}

- (void)lightHue
{
    DPHue *hue = [[DPHue alloc] initWithHueHost:@"192.168.100.3" username:@"1234567890"];
    [hue readWithCompletion:^(DPHue *hue, NSError *err) {
        for (DPHueLight *light in hue.lights) {
            light.brightness = @255;
            light.hue = @25500;
            light.saturation = @255;
            [light write];
        }
    }];
}

- (void)sendLocalNotificationForMessage:(NSString *)message
{
    NSLog(@"%@", message);
    UILocalNotification *localNotification = [UILocalNotification new];
    localNotification.alertBody = message;
    localNotification.fireDate = [NSDate date];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

@end
