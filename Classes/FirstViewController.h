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


@interface FirstViewController : UIViewController {
	UIWebView *webView;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;

@end
