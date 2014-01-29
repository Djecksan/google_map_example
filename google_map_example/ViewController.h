//
//  ViewController.h
//  google_map_example
//
//  Created by Evgenyi Tyulenev on 27.01.14.
//  Copyright (c) 2014 Евгений Тюленев. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface ViewController : UIViewController<GMSMapViewDelegate, CLLocationManagerDelegate>
@property(retain, nonatomic) GMSMapView *mapView;
@property(weak, nonatomic) IBOutlet UILabel *lKm;
@property(strong, nonatomic) IBOutlet UIView *mView;
@property(retain, nonatomic) CLLocationManager *manager;
@property(retain, nonatomic) GMSMutablePath *path;

@end
