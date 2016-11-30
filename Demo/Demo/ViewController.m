//
//  ViewController.m
//  Demo
//
//  Created by drif on 11/27/16.
//  Copyright © 2016 Payfort (https://start.payfort.com). All rights reserved.
//

@import StartSDK;

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, weak) IBOutlet UILabel *amountLabel;
@property (nonatomic, weak) IBOutlet UITextField *numberTextField;
@property (nonatomic, weak) IBOutlet UITextField *monthTextField;
@property (nonatomic, weak) IBOutlet UITextField *yearTextField;
@property (nonatomic, weak) IBOutlet UITextField *cvcTextField;
@property (nonatomic, weak) IBOutlet UITextField *cardholderTextField;
@property (nonatomic, weak) IBOutlet UILabel *errorsLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) IBOutletCollection(UITextField) NSArray *textFields;

@end

@implementation ViewController {
    Start *_start;
    NSInteger _amount;
    NSString *_currency;
}

#pragma mark - Private methods

- (NSString *)amountString {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    formatter.currencyCode = _currency;
    return [formatter stringFromNumber:@(_amount / 100.0f)];
}

- (StartCard *)card {
    StartCard *card;
    NSString *errorText = nil;

    @try {
        NSString *expirationYearString = [@"20" stringByAppendingString:(NSString *_Nonnull) self.yearTextField.text];

        card = [[StartCard alloc] initWithCardholder:(NSString *_Nonnull) self.cardholderTextField.text
                                              number:(NSString *_Nonnull) self.numberTextField.text
                                                 cvc:(NSString *_Nonnull) self.cvcTextField.text
                                     expirationMonth:self.monthTextField.text.integerValue
                                      expirationYear:expirationYearString.integerValue];
    }
    @catch (StartException *exception) {
        NSDictionary *fields = @{
                @(StartCardErrorCodeInvalidCardholder): self.cardholderTextField.placeholder,
                @(StartCardErrorCodeInvalidNumber): self.numberTextField.placeholder,
                @(StartCardErrorCodeInvalidCVC): self.cvcTextField.placeholder,
                @(StartCardErrorCodeInvalidExpirationYear): self.yearTextField.placeholder,
                @(StartCardErrorCodeInvalidExpirationMonth): self.monthTextField.placeholder
        };

        NSMutableString *text = [NSMutableString stringWithString:@"The following fields are invalid:"];
        for (NSError *error in exception.userInfo[StartExceptionKeyErrors]) {
            [text appendFormat:@"\n%@", fields[@(error.code)]];
        }
        errorText = text;
    }

    self.errorsLabel.text = errorText;

    return card;
}

- (void)pay {
    StartCard *card = self.card;
    if (!card) {
        return;
    }

    [self resignFirstResponder];

    [self.activityIndicatorView startAnimating];
    [_start createTokenForCard:card amount:_amount currency:_currency successBlock:^(id <StartToken> token) {
        [self showAlertWithText:[NSString stringWithFormat:@"Token ID received from server:\n%@", token.tokenId]];
        [self.activityIndicatorView stopAnimating];
    } errorBlock:^(NSError *error) {
        [self showAlertWithText:[NSString stringWithFormat:@"Error occurred:\n%@", error]];
        [self.activityIndicatorView stopAnimating];
    } cancelBlock:^{
        [self showAlertWithText:@"Cancelled"];
        [self.activityIndicatorView stopAnimating];
    }];
}

- (void)showAlertWithText:(NSString *)text {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:text preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)onPay:(UIButton *)sender {
    [self pay];
}

- (IBAction)onTap:(UITapGestureRecognizer *)sender {
    [self resignFirstResponder];
}

#pragma mark - UIViewController methods

- (void)viewDidLoad {
    [super viewDidLoad];

    _start = [[Start alloc] initWithAPIKey:@"test_open_k_46dd87e36d3a5949aa68"];
    _amount = 100;
    _currency = @"USD";
    
    self.amountLabel.text = [@"Pay " stringByAppendingString:self.amountString];

#if DEBUG
    self.numberTextField.text = @"4242424242424242";
    self.monthTextField.text = @"11";
    self.yearTextField.text = @"16";
    self.cvcTextField.text = @"123";
    self.cardholderTextField.text = @"John Smith";
#endif
}

- (BOOL)resignFirstResponder {
    for (UITextField *textField in self.textFields) {
        [textField resignFirstResponder];
    }
    return [super resignFirstResponder];
}

@end
