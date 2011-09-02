//
//  FirstViewController.h
//  MapAttack
//
//  Created by Aaron Parecki on 2011-08-11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapAttack.h"
#import "LQConfig.h"
#import "GeoloqiReadClient.h"


@interface MapViewController : UIViewController {
	UIWebView *webView;
	GeoloqiReadClient *read;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;

- (void)loadURL:(NSString *)url;

@end
