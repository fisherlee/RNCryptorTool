//
//  ViewController.m
//  RNCryptor
//
//  Created by liwei on 2016/11/21.
//  Copyright © 2016年 liwei. All rights reserved.
//

#import "ViewController.h"

#import "RNEncryptor.h"
#import "RNDecryptor.h"


typedef NS_ENUM(NSInteger, FileType) {
    FileTypeEncryptor = 0,
    FileTypeDecryptor
};

static NSString * const kEncryptFloder = @"加密文件";
static NSString * const kDecryptFloder = @"解密文件";

static NSString * const kEncryptURLKey = @"解密文件";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.filesTableView.delegate = self;
    self.filesTableView.dataSource = self;
    
    _fileArray = [[NSMutableArray alloc] init];
    
    NSLog(@"_filesTableView.tableColumns[%@] = %@", @(_filesTableView.numberOfColumns), _filesTableView.tableColumns);
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark - button action
//------ 加密 ------
- (IBAction)importFiles:(id)sender
{
    if ([_pwTextField.stringValue length] == 0) {
        _pwTextField.placeholderString = @"请设置密码";
        [_pwTextField becomeFirstResponder];
        return;
    }
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseDirectories = NO;
    panel.allowsMultipleSelection = YES;
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

- (IBAction)encryptAction:(id)sender
{
    [self saveFilesType:FileTypeEncryptor floderName:kEncryptFloder files:_fileArray];
    [self.filesTableView reloadData];
}

//------ 解密 ------
- (IBAction)decryptAction:(id)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    NSString *path = [userDefaults objectForKey:kEncryptURLKey];
    if ([path length] <= 0) {
        return;
    }
    
    NSURL *url = [NSURL fileURLWithPath:path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error = nil;
    NSArray *fileURLs = [fileManager contentsOfDirectoryAtURL:url includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:NULL];
    if (!error && [fileURLs count] > 0) {
        [self saveFilesType:FileTypeDecryptor floderName:kDecryptFloder files:fileURLs];
    }
}

#pragma mark - save path
- (void)saveFilesType:(NSInteger)type floderName:(NSString *)floderName files:(NSArray *)files
{
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    savePanel.nameFieldStringValue = floderName;
    savePanel.message = @"选择保存路径";
    savePanel.extensionHidden = NO;
    savePanel.canCreateDirectories = YES;
    [savePanel beginSheetModalForWindow:[self.view window]
                      completionHandler:^(NSInteger result) {
                          
                          if (result == NSFileHandlingPanelOKButton) {
                              NSString *fileName = [[savePanel nameFieldStringValue] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                              
                              NSString *savePath = @"";
                              if ([fileName length] > 0) {
                                  NSString *path = [[[savePanel URL] URLByDeletingPathExtension] path];
                                  
                                  NSFileManager *fileManager = [NSFileManager defaultManager];
                                  [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
                                  savePath = path;
                              }else {
                                  savePath = [[[savePanel URL] URLByDeletingPathExtension] path];
                              }
                              
                              for (NSURL *url in files) {
                                  NSData *data = [NSData dataWithContentsOfURL:url];
                                  
                                  NSError *error = nil;
                                  NSData *cryptData = nil;
                                  if (type == FileTypeEncryptor) {
                                      cryptData = [RNEncryptor encryptData:data
                                                              withSettings:kRNCryptorAES256Settings
                                                                  password:_pwTextField.stringValue
                                                                     error:&error];
                                  }
                                  if (type == FileTypeDecryptor) {
                                      cryptData = [RNDecryptor decryptData:data
                                                              withSettings:kRNCryptorAES256Settings
                                                                  password:_pwTextField.stringValue
                                                                     error:&error];
                                  }

                                  if (!error && data != nil) {
                                      NSString *fileName = [url lastPathComponent];
                                      NSString *filePath = [savePath stringByAppendingPathComponent:fileName];
                                      
                                      [cryptData writeToFile:filePath atomically:YES];
                                      NSLog(@"save success");
                                      if (type == FileTypeEncryptor) {
                                          _encryptFilePath.stringValue = savePath;
                                          
                                          NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                                          [userDefaults setObject:savePath forKey:kEncryptURLKey];
                                      }
                                      if (type == FileTypeDecryptor) {
                                          _decryptFilePath.stringValue = savePath;
                                      }
                                  }
                              }
                          }
                      }];
}

#pragma mark - tableview delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [_fileArray count];
}

- (NSView*)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"encryptCellId" owner:self];
    
    NSString *path = _fileArray[row];
    cellView.textField.stringValue = [path lastPathComponent];
    
    return cellView;
}

@end
