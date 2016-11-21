//
//  ViewController.h
//  RNCryptor
//
//  Created by liwei on 2016/11/21.
//  Copyright © 2016年 liwei. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, weak) IBOutlet NSTableView *filesTableView;
@property (nonatomic, weak) IBOutlet NSTextField *pwTextField;
@property (nonatomic, weak) IBOutlet NSTextField *extTextField;
@property (nonatomic, weak) IBOutlet NSButton *importButton;
@property (nonatomic, weak) IBOutlet NSButton *delButton;

@property (nonatomic, strong) NSMutableArray *fileArray;

- (IBAction)importFiles:(id)sender;
- (IBAction)delFiles:(id)sender;

@end

