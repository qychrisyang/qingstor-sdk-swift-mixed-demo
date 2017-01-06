//
//  TheObjcViewController.m
//  QingStorSDKDemo
//
//  Created by Chris on 17/1/6.
//  Copyright © 2017年 Yunify. All rights reserved.
//

#import "TheObjcViewController.h"
#import "QingStorSDKDemo-Swift.h"

@interface TheObjcViewController ()

@end

@implementation TheObjcViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Buckets" style:UIBarButtonItemStylePlain target:self action:@selector(toBucketList)];
}

- (void)toBucketList {
    BucketListController *bucketListController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"buckets"];
    [self.navigationController pushViewController:bucketListController animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
