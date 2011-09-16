//
//  AuthView.m
//  MapAttack
//
//  Created by Aaron Parecki on 2011-09-01.
//  Copyright 2011 Geoloqi.com. All rights reserved.
//

#import "AuthView.h"
#import "LQClient.h"
#import "MapAttackAuth.h"
#import "MapAttack.h"

@implementation AuthView

@synthesize initialPicker, initial1, initial2, emailField, activityIndicator;

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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	alphabet = [[NSString alloc] initWithString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ"];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (IBAction)tappedInitials {
	[self.emailField resignFirstResponder];
}

- (IBAction)signIn {
	NSString *initials = [NSString stringWithFormat:@"%@%@", self.initial1.text, self.initial2.text];
	self.activityIndicator.alpha = 1.0;
	[[LQClient single] createNewAccountWithEmail:self.emailField.text initials:initials callback:^(NSError *error, NSDictionary *response){
		[[NSNotificationCenter defaultCenter] postNotificationName:LQAuthenticationSucceededNotification
															object:nil
														  userInfo:nil];
		[[self parentViewController] dismissModalViewControllerAnimated:YES];
	}];
}

#pragma mark -
#pragma mark UIPickerView methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return 26;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
	return [alphabet substringWithRange:NSMakeRange(row, 1)];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	if(component == 0) {
		self.initial1.text = [alphabet substringWithRange:NSMakeRange(row, 1)];
	} else {
		self.initial2.text = [alphabet substringWithRange:NSMakeRange(row, 1)];
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


- (void)dealloc {
	[initial1 release];
	[initial2 release];
	[initialPicker release];
	[emailField release];
	[activityIndicator release];
    [super dealloc];
}


@end
