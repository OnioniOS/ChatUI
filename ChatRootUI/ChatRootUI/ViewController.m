//
//  ViewController.m
//  ChatRootUI
//
//  Created by Onion on 2019/2/19.
//  Copyright © 2019年 com.youpin. All rights reserved.
//

#import "ViewController.h"
#import "ChatRootViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ChatRootViewController *vc = [[ChatRootViewController alloc] initWithNibName:@"" bundle:nil];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
