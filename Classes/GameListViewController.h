//
//  GameList.h
//  MapAttack
//
//  Created by Aaron Parecki on 2011-08-31.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GameListViewController : UIViewController {

}

@property (nonatomic, retain) IBOutlet UITextView *text;
@property (nonatomic, retain) IBOutlet UIButton *reloadBtn;

- (IBAction)reloadBtnPressed;
- (void)getNearbyLayers;

@end
