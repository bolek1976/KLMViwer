//
//  MKPolygon+PointInPolygon.h
//  KMLViewer
//
//  Created by Boris Chirino on 23/02/16.
//
//

#import <MapKit/MapKit.h>

@interface MKPolygon (PointInPolygon)
-(BOOL) pointInPolygon:(CLLocationCoordinate2D) point mapView: (MKMapView*) mapView;
@end
