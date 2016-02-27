//
//  MKPolygon+PointInPolygon.m
//  KMLViewer
//
//  Created by Boris Chirino on 23/02/16.
//
//

#import "MKPolygon+PointInPolygon.h"

@implementation MKPolygon (PointInPolygon)
-(BOOL) pointInPolygon:(CLLocationCoordinate2D) point mapView: (MKMapView*) mapView {
    MKMapPoint mapPoint = MKMapPointForCoordinate(point);
    
    CGMutablePathRef mpr = CGPathCreateMutable();
    MKMapPoint *polygonPoints = self.points;
    
    
    
    for (NSUInteger p=0; p < self.pointCount; p++)
    {
        MKMapPoint mp = polygonPoints[p];
        CLLocationDistance distance = MKMetersBetweenMapPoints(mapPoint,mp);
        //NSLog(@"%f",distance);
        if (p == 0)
            CGPathMoveToPoint(mpr, NULL, mp.x, mp.y);
        else
            CGPathAddLineToPoint(mpr, NULL, mp.x, mp.y);
        if (distance < 1000) {
            return YES;
           // break;
        }
    }
        
    CGPoint mapPointAsCGP = CGPointMake(mapPoint.x, mapPoint.y);
    BOOL pointIsInPolygon = CGPathContainsPoint(mpr, NULL, mapPointAsCGP, TRUE);

    return pointIsInPolygon;
   

    //MKPolygonView * polygonView = (MKPolygonView*)[MKPolygonRenderer]
    //[mapView viewForOverlay:self];
//    return CGPathContainsPoint(polygonView.path, NULL, polygonViewPoint, NO) &&
//    ![self pointInInteriorPolygons:point mapView:mapView];
}

-(BOOL) pointInInteriorPolygons:(CLLocationCoordinate2D) point mapView: (MKMapView*) mapView {
    return [self pointInInteriorPolygonIndex:0 point:point mapView:mapView];
}

-(BOOL) pointInInteriorPolygonIndex:(unsigned int) index point:(CLLocationCoordinate2D) point mapView: (MKMapView*) mapView {
    if(index >= [self.interiorPolygons count])
        return NO;
    return [[self.interiorPolygons objectAtIndex:index] pointInPolygon:point mapView:mapView] || [self pointInInteriorPolygonIndex:(index+1) point:point mapView:mapView];
}
@end
