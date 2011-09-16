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
#import "sqlite3.h"            // Import SQLITE3 header file


@interface MapViewController : UIViewController <UIWebViewDelegate> {
	UIWebView *webView;
	GeoloqiReadClient *read;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIView *activityIndicator;

- (void)loadURL:(NSString *)url;

@end
