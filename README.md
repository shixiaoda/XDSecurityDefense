# XDSecurityDefense

[![CI Status](https://img.shields.io/travis/shixiaoda/XDSecurityDefense.svg?style=flat)](https://travis-ci.org/shixiaoda/XDSecurityDefense)
[![Version](https://img.shields.io/cocoapods/v/XDSecurityDefense.svg?style=flat)](https://cocoapods.org/pods/XDSecurityDefense)
[![License](https://img.shields.io/cocoapods/l/XDSecurityDefense.svg?style=flat)](https://cocoapods.org/pods/XDSecurityDefense)
[![Platform](https://img.shields.io/cocoapods/p/XDSecurityDefense.svg?style=flat)](https://cocoapods.org/pods/XDSecurityDefense)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

### 1.
运行程序，生成待混淆的字符片段文件 func.list，然后将func.list 拷贝到工程目录
```
[XDSecurityDefenseManager initWithClassPrefix:@[@"XD"] ignoreFragment:nil];
```

### 2.
修改securityDefense.sh  HEAD_FILE  设置正确的XDSecurityDefense.h 路径
修改混淆逻辑 加前缀 后缀等等
执行工程目录下的  securityDefense.sh
```
sh securityDefense.sh
```

### 3.
在主工程  以及 相关的Pod工程 的 Prefix.pch 添加
```
#import "XDSecurityDefense.h"
```

### 4.
然后正常编译打包
出现编译错误 或者 运行错误，请过滤掉 或者 直接删除 导致出错的混淆片段

## Requirements

## Installation

XDSecurityDefense is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'XDSecurityDefense'
```

## Author

shixiaoda, shixiaoda@babybus.com

## License

XDSecurityDefense is available under the MIT license. See the LICENSE file for more info.
