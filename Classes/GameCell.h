//
//  GameCell.h
//  MapAttack
//
//  Created by Aaron Parecki on 2011-09-01.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GameCell : UITableViewCell {
	IBOutlet UILabel *name;
	IBOutlet UILabel *description;
}

@property (nonatomic, retain) IBOutlet UILabel *name;
@property (nonatomic, retain) IBOutlet UILabel *description;

- (void)setNameText:(NSString *)text;
- (void)setDescriptionText:(NSString *)text;

@end
