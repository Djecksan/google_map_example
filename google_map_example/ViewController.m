//
//  ViewController.m
//  google_map_example
//
//  Created by Evgenyi Tyulenev on 27.01.14.
//  Copyright (c) 2014 Евгений Тюленев. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
     _path = [[GMSMutablePath alloc] init];
    _manager = [[CLLocationManager alloc] init];
    _manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [_manager setDelegate:self];
    [_manager startUpdatingLocation];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:_manager.location.coordinate.latitude
                                                            longitude:_manager.location.coordinate.longitude
                                                                 zoom:10];
    
    
    _mapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, 320, _mView.frame.size.height) camera:camera];
    _mapView.delegate = self;
    _mapView.myLocationEnabled = YES;
    _mapView.settings.myLocationButton = YES;
    
    //Иконка по координатам базы
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake([@"56.76548" doubleValue], [@"35.964281" doubleValue]);
    marker.snippet = @"Терема";
    marker.icon = [UIImage imageNamed:@"end.png"];
    marker.map = _mapView;
    
    //Вмещаем путь на экран
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:camera.target coordinate:CLLocationCoordinate2DMake([@"56.76548" doubleValue], [@"35.964281" doubleValue])];
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds];
    [_mapView moveCamera:update];

    [self.mView addSubview:_mapView];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[APIClient client] GET:[NSString stringWithFormat:@"origin=%f,%f&destination=56.76548,35.964281&sensor=false", _manager.location.coordinate.latitude, _manager.location.coordinate.longitude] parameters:nil success:^(NSDictionary *jObject) {
        //Очищаем координаты
        [_path removeAllCoordinates];
        
        NSString *distance = jObject[@"routes"][0][@"legs"][0][@"distance"][@"text"];
        [_lKm setText:[NSString stringWithFormat:@"Дистанция %@ километров", distance]];
        
        for (NSDictionary *item in jObject[@"routes"][0][@"legs"][0][@"steps"]) {
            [self polylineWithEncodedString:item[@"polyline"][@"points"] :_path];
        }
        
        // Use the modified category to get a polyline from the points.
        GMSPolyline *polyline = [GMSPolyline polylineWithPath:_path];
        
        polyline.strokeColor = [UIColor blueColor];
        polyline.strokeWidth = 6.f;
        polyline.geodesic = YES;
        polyline.map = _mapView;
        
    } fail:nil];
}

-(void) dealloc {
    [_manager stopUpdatingLocation];
}

#pragma mark - GMSMapViewDelegate


#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
//    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:newLocation.coordinate.latitude
//                                                            longitude:newLocation.coordinate.longitude
//                                                                 zoom:17.0];
    //[_mapView animateToCameraPosition:camera];
    CLLocationDistance distance = [newLocation distanceFromLocation:oldLocation];
    NSLog(@"Расстояние между = %f",distance);
}


#pragma mark - encode points

-(void)polylineWithEncodedString:(NSString *)encodedString :(GMSMutablePath *)path {
    const char *bytes = [encodedString UTF8String];
    NSUInteger length = [encodedString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger idx = 0;
    
    NSUInteger count = length / 4;
    CLLocationCoordinate2D *coords = calloc(count, sizeof(CLLocationCoordinate2D));
    NSUInteger coordIdx = 0;
    
    float latitude = 0;
    float longitude = 0;
    while (idx < length) {
        char byte = 0;
        int res = 0;
        char shift = 0;
        
        do {
            byte = bytes[idx++] - 63;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLat = ((res & 1) ? ~(res >> 1) : (res >> 1));
        latitude += deltaLat;
        
        shift = 0;
        res = 0;
        
        do {
            byte = bytes[idx++] - 0x3F;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
        
        float deltaLon = ((res & 1) ? ~(res >> 1) : (res >> 1));
        longitude += deltaLon;
        
        float finalLat = latitude * 1E-5;
        float finalLon = longitude * 1E-5;
        
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(finalLat, finalLon);
        coords[coordIdx++] = coord;
        
        if (coordIdx == count) {
            NSUInteger newCount = count + 10;
            coords = realloc(coords, newCount * sizeof(CLLocationCoordinate2D));
            count = newCount;
        }
    }
    
    int i;
    for (i = 0; i < coordIdx; i++)
    {
        [path addCoordinate:coords[i]];
    }
    
    free(coords);
}

@end