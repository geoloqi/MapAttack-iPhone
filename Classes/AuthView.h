//
//  AuthView.h
//  MapAttack
//
//  Created by Aaron Parecki on 2011-09-01.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AuthView : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
	NSString *alphabet;
}

@property (nonatomic, retain) IBOutlet UIPickerView *initialPicker;
@property (nonatomic, retain) IBOutlet UILabel *initial1;
@property (nonatomic, retain) IBOutlet UILabel *initial2;
@property (nonatomic, retain) IBOutlet UITextField *emailField;
@property (nonatomic, retain) IBOutlet UIView *activityIndicator;

- (IBAction)tappedInitials;
- (IBAction)signIn;

@end
