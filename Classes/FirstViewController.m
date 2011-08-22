//
//  FirstViewController.m
//  MapAttack
//
//  Created by Aaron Parecki on 2011-08-11.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "FirstViewController.h"
#import "CJSONSerializer.h"

@implementation FirstViewController

@synthesize webView;


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:LQMapAttackWebURL]]];

	read = [[GeoloqiReadClient alloc] init];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(mapAttackDataBroadcastReceived:)
												 name:LQMapAttackDataNotification
											   object:nil];
}

- (void)mapAttackDataBroadcastReceived:(NSNotification *)notification {
	NSLog(@"got data broadcast");
	
//	[[CJSONSerializer serializer] serializeDictionary:[notification userInfo]];

	NSLog(@"%@", [NSString stringWithFormat:@"if(typeof LQHandlePushData != \"undefined\") { "
				  "LQHandlePushData(%@); }", [[notification userInfo] objectForKey:@"json"]]);
	[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"if(typeof LQHandlePushData != \"undefined\") { "
													 "LQHandlePushData(%@); }", [[notification userInfo] objectForKey:@"json"]]];
	
	
//	NSLog(@"%@", [NSString stringWithFormat:@"if(typeof LQHandlePushData != \"undefined\") { "
//		   "LQHandlePushData(%@); }", [[CJSONSerializer serializer] serializeDictionary:[notification userInfo]]]);
//	[webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"if(typeof LQHandlePushData != \"undefined\") { "
//													 "LQHandlePushData(%@); }", [[CJSONSerializer serializer] serializeDictionary:[notification userInfo]]]];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

/*
- (void)zoomMapToLocation:(CLLocation *)location
{
    MKCoordinateSpan span;
    span.latitudeDelta  = 0.03;
    span.longitudeDelta = 0.03;
    
    MKCoordinateRegion region;
    
    [map setCenterCoordinate:location.coordinate animated:YES];
    
    region.center = location.coordinate;
    region.span   = span;
    
    [map setRegion:region animated:YES];
}

- (IBAction)tappedLocate:(id)sender
{
    CLLocation *location;
    
	//    if(location = [[Geoloqi sharedInstance] currentLocation])
	//    {
	//        [self zoomMapToLocation:location];
	//    }
	//    else if(mapView.userLocationVisible)
	//    {
	location = map.userLocation.location;
	[self zoomMapToLocation:location];
	//    }
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	[read disconnect];
}


- (void)dealloc {
	[webView release];
	[read release];
    [super dealloc];
}

@end
