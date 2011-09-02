//
//  GameList.h
//  MapAttack
//
//  Created by Aaron Parecki on 2011-08-31.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameCell.h"

@interface GameListViewController : UIViewController <UITableViewDelegate> {
	IBOutlet GameCell *gameCell;
	NSMutableArray *games;
}

@property (nonatomic, retain) IBOutlet UIButton *reloadBtn;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet GameCell *gameCell;
@property (nonatomic, retain) NSMutableArray *games;

- (IBAction)reloadBtnPressed;
- (void)getNearbyLayers;

@end
