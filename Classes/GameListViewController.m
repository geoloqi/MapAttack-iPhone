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

@implementation GameListViewController

@synthesize reloadBtn, tableView, gameCell, games;

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
	[self getNearbyLayers];
}

- (IBAction)reloadBtnPressed {
	[self getNearbyLayers];
}

- (void)getNearbyLayers {
	[[LQClient single] getNearbyLayers:^(NSError *error, NSDictionary *response){
		self.games = [response objectForKey:@"nearby"];
		
		NSLog(@"%@", [self.games objectAtIndex:1]);
		[self.tableView reloadData];
	}];
}

- (NSString *)urlForGameAtIndex:(NSInteger)index {
	return [[self.games objectAtIndex:index] objectForKey:@"url"];
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
	
	NSLog(@"cellForRowAtIndexPath: %@", indexPath);
	
	GameCell *cell = (GameCell *)[t dequeueReusableCellWithIdentifier:myIdentifier];
	
	if(cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"GameCell" owner:self options:nil];
		cell = gameCell;
	}

//	NSLog(@"Game: %@", games);
	id game = [self.games objectAtIndex:indexPath.row];
	[cell setNameText:[game objectForKey:@"name"]];
	[cell setDescriptionText:[game objectForKey:@"description"]];
	 
	return cell;
}

- (void)tableView:(UITableView *)t didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"Selected game %d", indexPath.row);
	[t deselectRowAtIndexPath:indexPath animated:NO];
	[lqAppDelegate loadGameWithURL:[self urlForGameAtIndex:indexPath.row]];
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


- (void)dealloc {
	[games release];
	[gameCell release];
    [super dealloc];
}


@end
