//
//  GameList.h
//  MapAttack
//
//  Created by Aaron Parecki on 2011-08-31.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameCell.h"
#import <CoreLocation/CoreLocation.h>

@interface GameListViewController : UIViewController <UITableViewDelegate, CLLocationManagerDelegate> {
	IBOutlet GameCell *gameCell;
	NSMutableArray *games;
#ifdef FAKE_CORE_LOCATION
	FTLocationSimulator *locationManager;
#else
	CLLocationManager *locationManager;
#endif
}

@property (nonatomic, retain) IBOutlet UIButton *reloadBtn;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet GameCell *gameCell;
@property (nonatomic, retain) NSMutableArray *games;
@property (nonatomic, retain) NSIndexPath *selectedIndex;

- (IBAction)reloadBtnPressed;
- (IBAction)logoutBtnPressed;
- (void)refreshNearbyLayers;

@end
