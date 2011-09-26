//
//  GameList.m
//  MapAttack
//
//  Created by Aaron Parecki on 2011-08-31.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "GameListViewController.h"
#import "LQClient.h"
#import "LQConfig.h"
#import "MapAttackAppDelegate.h"
#import "FTLocationSimulator.h"

@implementation GameListViewController

@synthesize reloadBtn, logoutBtn, tableView, noGamesView, gameCell, games, selectedIndex, loadingView, loadingStatus, spinnerView, gamesNearLabel;

- (void)dealloc {
	[games release];
	[gameCell release];
	[selectedIndex release];
	[tableView release];
	[loadingView release];
	[noGamesView release];
	[spinnerView release];
	[reloadBtn release];
	[logoutBtn release];
	[locationManager release];
    [super dealloc];
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
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
	games = [[NSMutableArray alloc] init];
	[self refreshNearbyLayers];
}

- (void)viewWillAppear:(BOOL)animated {
	if([[LQClient single] isLoggedIn]) {
		self.logoutBtn.hidden = NO;
	} else {
		self.logoutBtn.hidden = YES;
	}
}

- (IBAction)reloadBtnPressed {
	[self refreshNearbyLayers];
}

- (IBAction)logoutBtnPressed {
	[[LQClient single] logout];
}

- (IBAction)emailBtnPressed {
	NSLog(@"email tapped");
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:games@mapattack.org"]];
}

- (void)refreshNearbyLayers {
	self.loadingStatus.text = @"Finding your location...";
	self.loadingView.alpha = 0.85;
	self.noGamesView.hidden = YES;
	self.spinnerView.hidden = NO;
	self.loadingStatus.hidden = NO;
	self.gamesNearLabel.text = @"";
	
#ifdef FAKE_CORE_LOCATION
    [self locationManager:locationManager 
      didUpdateToLocation:[[CLLocation alloc] initWithLatitude:37.33095 longitude:-122.03066] fromLocation:nil];
#else
	if (!locationManager) {
		locationManager = [[CLLocationManager alloc] init];
		locationManager.distanceFilter = 1.0;
		locationManager.delegate = self;
        [locationManager startUpdatingLocation];
	}
#endif
	
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {

    //[locationManager stopUpdatingLocation];

	NSLog(@"Got location update! %@", newLocation);
	
	[[LQClient single] getPlaceContext:newLocation withCallback:^(NSError *error, NSDictionary *response){
		NSLog(@"Found place context: %@", response);
		if([response objectForKey:@"best_name"] != nil) {
			self.gamesNearLabel.text = [NSString stringWithFormat:@"Games near %@", [response objectForKey:@"best_name"]];
		} else {
			self.gamesNearLabel.text = @"";
		}
										
		self.loadingStatus.text = @"Finding nearby games...";

		[[LQClient single] getNearbyLayers:newLocation withCallback:^(NSError *error, NSDictionary *response){
			if([response objectForKey:@"nearby"] != nil)
				self.games = [response objectForKey:@"nearby"];
			else
				self.games = nil;

			NSLog(@"Found games: %@", self.games);

			if(self.games == nil || [self.games count] == 0) {
				self.noGamesView.hidden = NO;
				self.spinnerView.hidden = YES;
				self.loadingStatus.hidden = YES;
				[UIView beginAnimations:@"alpha" context:nil];
				[UIView setAnimationDuration:0.3];
				[self.noGamesView setAlpha:1.0];
				[UIView commitAnimations];
			} else {
				self.loadingStatus.text = @"Reticulating splines...";
				[UIView beginAnimations:@"alpha" context:nil];
				[UIView setAnimationDuration:0.4];
				[self.loadingView setAlpha:0.0];
				[UIView commitAnimations];
			}

			[self.tableView reloadData];
		}];
	}];
	
}

- (NSString *)urlForGameAtIndex:(NSInteger)index {
	return [[self.games objectAtIndex:index] objectForKey:@"url"];
}

- (NSString *)layerIDForGameAtIndex:(NSInteger)index {
	return [[self.games objectAtIndex:index] objectForKey:@"layer_id"];
}

- (NSString *)groupTokenForGameAtIndex:(NSInteger)index {
	return [[self.games objectAtIndex:index] objectForKey:@"group_token"];
}

#pragma mark -
#pragma mark Table View

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 65;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		default:
			return [self.games count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)t cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *myIdentifier = @"GameCell";
	
	GameCell *cell = (GameCell *)[t dequeueReusableCellWithIdentifier:myIdentifier];
	
	if(cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"GameCell" owner:self options:nil];
		cell = gameCell;
	}

	id game = [self.games objectAtIndex:indexPath.row];
	[cell setNameText:[game objectForKey:@"name"]];
	[cell setDescriptionText:[game objectForKey:@"description"]];
	 
	return cell;
}

- (void)authenticationDidSucceed:(NSNotificationCenter *)notification {

	self.loadingStatus.text = @"Joining game...";
	[UIView beginAnimations:@"alpha" context:nil];
	[UIView setAnimationDuration:0.4];
	[self.loadingView setAlpha:0.85];
	[UIView commitAnimations];

	[[LQClient single] joinGame:[self layerIDForGameAtIndex:selectedIndex.row] 
					  withToken:[self groupTokenForGameAtIndex:self.selectedIndex.row] 
				   withCallback:^(NSError *error, NSDictionary *response){
		DLog(@"Joined game: %@", response);

	   self.loadingStatus.text = @"Reticulating splines...";
	   [UIView beginAnimations:@"alpha" context:nil];
	   [UIView setAnimationDuration:0.4];
	   [self.loadingView setAlpha:0.0];
	   [UIView commitAnimations];
					   
	   // If they're not logged in, then loadGameWithURL will have already popped up a login screen
	   [lqAppDelegate loadGameWithURL:[NSString stringWithFormat:MapAttackGameURLFormat, [self layerIDForGameAtIndex:self.selectedIndex.row]]];
	}];


    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:LQAuthenticationSucceededNotification 
                                                  object:nil];
}

- (void)tableView:(UITableView *)t didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	DLog(@"Selected game %d", indexPath.row);
	[t deselectRowAtIndexPath:indexPath animated:NO];
	self.selectedIndex = indexPath;

	// If they're not logged in, wait until after the authentication succeed broadcast received, then join the game
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(authenticationDidSucceed:)
												 name:LQAuthenticationSucceededNotification
											   object:nil];		
	
	if([[LQClient single] isLoggedIn]) {
		// If they're logged in, immediately make a call to the game server to join the game
		[self authenticationDidSucceed:nil];
	} else {
		[lqAppDelegate.tabBarController presentModalViewController:[[AuthView alloc] init] animated:YES];
	}
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


@end
