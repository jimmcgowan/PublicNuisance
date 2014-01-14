//
//  UsernameViewController.h
//  Public Nuisance
//
//  Created by Jim McGowan on 18/11/13.
//  Copyright (c) 2013 Jim McGowan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UsernameViewController;

@protocol UsernameViewControllerDelegate <NSObject>

- (void)controller:(UsernameViewController *)controller didEndEditingWithUsername:(NSString *)username;

@end


@interface UsernameViewController : UIViewController

@property (assign, nonatomic) id<UsernameViewControllerDelegate> delegate;

@property (weak) IBOutlet UIButton *doneButton;
@property (weak) IBOutlet UITextField *usernameField;

- (IBAction)textChanged:(id)sender;
- (IBAction)done:(id)sender;

@end
