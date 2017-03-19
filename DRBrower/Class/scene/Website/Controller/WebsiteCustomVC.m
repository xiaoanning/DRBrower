//
//  WebsiteCustomVC.m
//  DRBrower
//
//  Created by QiQi on 2017/3/13.
//  Copyright © 2017年 QiQi. All rights reserved.
//

#import "WebsiteCustomVC.h"
#import "WebsiteModel.h"

#define BUTTON_ENABLE @"buttonEnable"
@interface WebsiteCustomVC ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UITextField *titleTF;
@property (weak, nonatomic) IBOutlet UITextField *urlTF;

@property (strong, nonatomic) NSString *titleStr;
@property (strong, nonatomic) NSString *urlStr;

@end

@implementation WebsiteCustomVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"自定义" image:nil tag:0];
    self.titleTF.delegate = self;
    self.urlTF.delegate =  self;
    [self.saveButton setBackgroundColor:colorWithvalue(@"999999")];
    self.saveButton.enabled = NO;
    self.saveButton.layer.cornerRadius = 5;
    self.saveButton.layer.masksToBounds = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(buttonEnable)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self.titleTF];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(buttonEnable)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self.urlTF];
    
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField.text length]>0) {
        if (textField == self.titleTF) {
            self.titleStr = textField.text;
        }
        if (textField == self.urlTF) {
            self.urlStr = textField.text;
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField.text length]>0) {
        if (textField == self.titleTF) {
            self.titleStr = textField.text;
        }
        if (textField == self.urlTF) {
            self.urlStr = textField.text;
        }
    }
    return YES;
}

- (void)buttonEnable {
    if ([self.titleTF.text length]>0&&[self.urlTF.text length]>0) {
        [self.saveButton setBackgroundColor:colorWithvalue(@"007AFF")];
        self.saveButton.enabled = YES;
    }else {
        [self.saveButton setBackgroundColor:colorWithvalue(@"999999")];
        self.saveButton.enabled = NO;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
    
}

- (IBAction)didClickSaveButtonAction:(id)sender {
    WebsiteModel *website = [[WebsiteModel alloc] init];
    website.name = self.titleTF.text;
    website.url = self.urlTF.text;
    website.icon = @"icon";
    website.isAdd = YES;
    NSMutableArray *websiteArray = [NSMutableArray arrayWithArray:[DRLocaldData achieveWebsiteData]];
    [websiteArray addObject:website];
    [DRLocaldData saveWebsiteData:websiteArray];
    [self.titleTF resignFirstResponder];
    [self.urlTF resignFirstResponder];
    self.titleTF.text = @"";
    self.urlTF.text = @"";

    [Tools showView:@"已添加到主页"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
