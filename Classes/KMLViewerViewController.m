/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
  See LICENSE.txt for this sample’s licensing information
  
  Abstract:
  Displays an MKMapView and demonstrates how to use the included KMLParser class to place annotations and overlays from a parsed KML file on top of the MKMapView. 
 */


/*
 BORIS NOTE:
 This is an adaptation of the original KMLViwer from Apple. Add MKPolygon category to detect whether the current location is within certain polygon. Tested on simulated locacions in
    London, Moscow, Johaneburgo, Rio de janeiro
 
 */


@import MapKit;

#import "KMLParser.h"
#import "KMLViewerViewController.h"
#import "MKPolygon+PointInPolygon.h"


@interface KMLViewerViewController ()<CLLocationManagerDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *map;
@property (nonatomic, strong) KMLParser *kmlParser;
@property CLLocationManager *locationManager;
@property NSMutableArray *overlays;
@property NSMutableArray *annotations;

@end

@implementation KMLViewerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if (status != kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    // Locate the path to the route.kml file in the application's bundle
    // and parse it with the KMLParser.
    NSString *path = [[NSBundle mainBundle] pathForResource:@"world-stripped" ofType:@"kml"];
    NSURL *url = [NSURL fileURLWithPath:path];
    self.kmlParser = [[KMLParser alloc] initWithURL:url];
    [self.kmlParser parseKML];
    
    // Add all of the MKOverlay objects parsed from the KML file to the map.
    _overlays =  [NSMutableArray arrayWithArray:[self.kmlParser overlays]] ;
    [self.map addOverlays:self.overlays];
    
    // Add all of the MKAnnotation objects parsed from the KML file to the map.
    _annotations = [NSMutableArray arrayWithArray:[self.kmlParser points]];
    
}

- (void)centermapinLocation:(CLLocationCoordinate2D)coordinate{
    MKMapRect flyTo = MKMapRectNull;
    for (MKPolygon *poligon in self.overlays)
    {
        BOOL p = [poligon pointInPolygon:coordinate mapView:self.map];
        if (p) {
            flyTo = [poligon boundingMapRect];
            self.map.visibleMapRect = flyTo;
            break;
    }
  }
    
    for (id <MKAnnotation> anotation in self.annotations) {
       BOOL contain =  [(MKPolygon*)anotation pointInPolygon:coordinate mapView:self.map];
        if (contain) {
            [self.map addAnnotation:anotation];
            break;
        }
    }
    
    [self.locationManager stopUpdatingLocation];
    _locationManager = nil;
}

#pragma Mark LocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [manager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation *lastLocationReceived = [locations lastObject];
    if ( !(lastLocationReceived.horizontalAccuracy > 1000) ) {
        [self centermapinLocation:lastLocationReceived.coordinate];
        
    }
}

#pragma mark MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    return [self.kmlParser rendererForOverlay:overlay];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    return [self.kmlParser viewForAnnotation:annotation];
}

@end
