# CRuby (MRI) interpreter module for CocoaPods.

CRuby のインタプリタを簡単に OSX/iOS アプリ内で利用出来るようにする
CocoaPod です。

# 使い方

CRuby を使いたい Xcode プロジェクトに以下の Podfile を用意します。

```
platform :ios, '7.0'
pod 'CRuby', git: 'https://github.com/xord/cruby'
```

ターミナルで以下を実行し、

```sh
$ pod install
```

CRuby を使いたい所で以下のように文字列を評価することができます。

```objc
CRBValue *result = [CRuby eval:@"[1, 2, 3].map {|n| n ** 2}"];
NSString *string = result.inspect;
NSLog(@"result: %@", string);
```
