//
//  ViewController.m
//  RNCryptor
//
//  Created by liwei on 2016/11/21.
//  Copyright © 2016年 liwei. All rights reserved.
//

#import "ViewController.h"
#import "RNCryptor.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.filesTableView.delegate = self;
    self.filesTableView.dataSource = self;
    
    _fileArray = [[NSMutableArray alloc] init];
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark - button action

- (IBAction)importFiles:(id)sender
{
    if ([_pwTextField.stringValue length] == 0) {
        _pwTextField.placeholderString = @"请设置密码";
        [_pwTextField becomeFirstResponder];
        return;
    }
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:yearMask];
    [panel beginSheetModalForWindow:[self.view window] completionHandler:^(NSInteger result) {
        
        if (result == NSModalResponseOK) {
            
            NSArray *urls = [panel URLs];
            [_fileArray addObjectsFromArray:urls];
            
            [self.filesTableView reloadData];
        }
    }];
}

- (IBAction)delFiles:(id)sender
{
    NSInteger index = _filesTableView.selectedRow;
    
    if ([_fileArray count] > index && index >= 0) {
        [_fileArray removeObjectAtIndex:index];
        [_filesTableView removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:index]
                               withAnimation:NSTableViewAnimationEffectGap];
    }
}

#pragma mark - tableview delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_fileArray count];
}

- (NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"fileCell" owner:self];
    
    NSString *path = _fileArray[row];
    cellView.textField.stringValue = [path lastPathComponent];

    return cellView;
}

@end
