//
//  ASViewController.m
//  ASCoreDataManager
//
//  Created by iOS on 09.07.14.
//  Copyright (c) 2014 stilo-studio. All rights reserved.
//

#import "ASViewController.h"
#import "ASCoreDataManager.h"
#import "Profile.h"

@interface ASViewController ()
{
    UILabel *promptLabel;
}

@end

@implementation ASViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    promptLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
    promptLabel.numberOfLines = 10;
    [self.view addSubview:promptLabel];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    

    
    [[ASCoreDataManager sharedManager] retriveProfile:^(NSObject *obj) {
        Profile *profile = (Profile*)obj;
        NSLog(@"Profile2 %@ - %@",profile.userMail,profile.userPassword);
        promptLabel.text = [NSString stringWithFormat:@"%@\n\n%@",profile.userMail,profile.userPassword];
    }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
