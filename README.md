[![Build Status](https://travis-ci.org/payfort/start-ios-sdk.svg?branch=master)](https://travis-ci.org/payfort/start-ios-sdk)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
# Start iOS SDK
*Start is a payment gateway for Startups*

This iOS SDK makes it easy for developers to accept payments inside mobile application.
## Intro
Due to security rules from Visa/MasterCard developers can’t transmit card details directly to their server and have to use PCI DSS certified environment for this. Instead, card details are sent directly to our server and we return a card token in the response. The card token uniquely identifies each card, and can be used in all API calls that require a card e.g. create charge or customer.

Sometimes, during the payment process an additional 3D Secure verification may be required. This adds more complexity to payment flow. With mobile SDK we hide this complexity from developer.
## Getting Started
Before you start you have to sign up for a Start account [here](https://dashboard.start.payfort.com/#/public/sign_up?secretLink=true) and get API keys for SDK following the [instruction](https://docs.start.payfort.com/guides/api_keys/#how-to-get-api-keys).
## Installation
#### Using CocoaPods
Install SDK usign [CocoaPods](https://guides.cocoapods.org/using/getting-started.html) by adding the following pod to your [Podfile](https://guides.cocoapods.org/using/using-cocoapods.html):

	pod 'StartSDK', :git => 'https://github.com/payfort/start-ios-sdk.git'
#### Using Carthage
You can also intall SDK using [Carthage](https://github.com/Carthage/Carthage#adding-frameworks-to-an-application) by adding the following statement to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

	github "payfort/start-ios-sdk"
## Usage
#### Objective-C
```objc
@import StartSDK;

...

NSInteger centsToPay = 100; // 1 USD

StartCard *card = [StartCard cardWithCardholder:@"John Smith"
                                         number:@"4242424242424242"
                                            cvc:@"123"
                                expirationMonth:10
                                 expirationYear:2020
                                          error:nil];

Start *start = [Start startWithAPIKey:@"your API key goes here"];

[start createTokenForCard:card amount:centsToPay currency:@"USD" successBlock:^(id <StartToken> token) {
	// Use token.tokenId when performing payments through API
} errorBlock:^(NSError *error) {
	// Process error
} cancelBlock:^{
	// User cancelled payment verification
}];
```
See [Demo view controller](Demo/Demo/ViewController.m) for more detailed example.
#### Swift
```swift
import StartSDK

...

let centsToPay = 100 // 1 USD

let card = try! StartCard(cardholder: "John Smith",
                              number: "4242424242424242",
                                 cvc: "123",
                     expirationMonth: 10,
                      expirationYear: 2020)

let start = Start(apiKey: "your API key goes here")

start.createToken(for: card, amount: centsToPay, currency: "USD", successBlock: { token in
	// Use token.tokenId when performing payments through API
}, errorBlock: { error in
	// Process error
}, cancel: {
	// User cancelled payment verification
})
```
See [Demo view controller](DemoSwift/DemoSwift/ViewController.swift) for more detailed example.
#### Note
`Start` shows alert telling user about additional verification if required. To provide custom texts for the alert, [localize](https://www.oneskyapp.com/academy/learn-ios-localization/) the [following keys](StartSDK/StartSDK/Models/Start.h):
- `payfort_start_verification_message`
- `payfort_start_verification_button`

## License
MIT License

Copyright (c) 2016 Payfort (http://payfort.com)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
