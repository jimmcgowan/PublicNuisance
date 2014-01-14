//
//  UsernameViewController.m
//  Public Nuisance
//
//  Created by Jim McGowan on 18/11/13.
//  Copyright (c) 2013 Jim McGowan. All rights reserved.
//

#import "UsernameViewController.h"

@implementation UsernameViewController

- (IBAction)textChanged:(id)sender
{
    self.doneButton.enabled = ([self.usernameField.text length] > 0);
}

- (IBAction)done:(id)sender
{
    [self.delegate controller:self didEndEditingWithUsername:self.usernameField.text];
}

@end
