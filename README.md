# CRuby Interpreter for macOS and iOS

This library allows you to embed CRuby interpreter to your macOS or iOS app.

![Build](https://github.com/xord/cruby/workflows/Build/badge.svg)

# How To Use

Prepare the following podfile for the Xcode project you want to use CRuby in.

```
platform :ios, '10.0'
pod 'CRuby', git: 'https://github.com/xord/cruby'
```

Run the following in a terminal.

```sh
$ CRUBY_OS=ios pod install --verbose
```
(Due to the long compile time, it is recommended to use the --verbose option)

Where you want to use CRuby, you can evaluate the string as follows.

```objc
CRBValue *result = [CRuby eval:@"[1, 2, 3].map {|n| n ** 2}"];
NSString *string = result.inspect;
NSLog(@"result: %@", string);
```
