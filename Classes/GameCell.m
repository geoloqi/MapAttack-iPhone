//
//  GameCell.m
//  MapAttack
//
//  Created by Aaron Parecki on 2011-09-01.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "GameCell.h"


@implementation GameCell

@synthesize name, description;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)setNameText:(NSString *)text {
	name.text = text;
}

- (void)setDescriptionText:(NSString *)text {
	description.text = text;
}



- (void)dealloc {
    [super dealloc];
}


@end
