//
//  FirstViewController.h
//  MapAttack
//
//  Created by Aaron Parecki on 2011-08-11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface FirstViewController : UIViewController <MKMapViewDelegate> {
	MKMapView *map;
}

@property (nonatomic, retain) IBOutlet MKMapView *map;

@end
