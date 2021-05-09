## DYFSwiftRuntimeProvider

`DYFRuntimeProvider`包装了 Runtime，可以快速用于字典和模型的转换、存档和取消归档、添加方法、交换两个方法、替换方法以及获取类的所有变量名、属性名和方法名。

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](LICENSE)&nbsp;
[![CocoaPods Version](http://img.shields.io/cocoapods/v/DYFSwiftRuntimeProvider.svg?style=flat)](http://cocoapods.org/pods/DYFSwiftRuntimeProvider)&nbsp;
![CocoaPods Platform](http://img.shields.io/cocoapods/p/DYFSwiftRuntimeProvider.svg?style=flat)&nbsp;


## QQ群 (ID:614799921)

<div align=left>
&emsp; <img src="https://github.com/dgynfi/DYFSwiftRuntimeProvider/raw/master/images/g614799921.jpg" width="30%" />
</div>


## 安装

使用 [CocoaPods](https://cocoapods.org):

``` 
use_frameworks!
target 'Your target name'

pod 'DYFSwiftRuntimeProvider', '~> 1.0.3'
```


## 使用

将 `import DYFSwiftRuntimeProvider` 添加到源代码中。

### 获取某类的所有方法名

**1. 获取实例的所有方法名**

```
let methodNames = DYFSwiftRuntimeProvider.methodList(withClass: UITableView.self)
for name in methodNames {
    print("The method name: \(name)")
}
```

**2. 获取类的所有方法名**

```
let clsMethodNames = DYFSwiftRuntimeProvider.classMethodList(self)
for name in clsMethodNames {
    print("The class method name: \(name)")
}
```

### 获取某类所有的变量名

```
let ivarNames = DYFSwiftRuntimeProvider.ivarList(withClass: UILabel.self)
for name in ivarNames {
    print("The var name: \(name)")
}
```

### 获取某类所有的属性名

```
let propertyNames = DYFSwiftRuntimeProvider.propertyList(withClass: UILabel.self)
for name in propertyNames {
    print("The property name: \(name)")
}
```

### 添加一个方法

```
override func loadView() {
    super.loadView()
    
    let ret = DYFSwiftRuntimeProvider.addMethod(withClass: XXViewController.self, selector: NSSelectorFromString("verifyCode"), impClass: XXViewController.self, impSelector: #selector(XXViewController.verifyQRCode))
    
    print("The result of adding method is \(ret)")
}

@objc func verifyQRCode() {
    print("Verifies QRCode")
}

override func viewDidLoad() {
    super.viewDidLoad()
    self.perform(NSSelectorFromString("verifyCode"))
}
```

### 交换两个方法

```
override func viewDidLoad() {
    super.viewDidLoad()
    
    DYFSwiftRuntimeProvider.exchangeMethod(withClass: XXViewController.self, selector: #selector(XXViewController.verifyCode1), targetClass: XXViewController.self, targetSelector: #selector(XXViewController.verifyQRCode))
    
    verifyCode1()
    verifyQRCode()
}

@objc func verifyCode1() {
    print("Verifies Code1")
}

@objc func verifyQRCode() {
    print("Verifies QRCode")
}
```

### 替换一个方法

```
override func viewDidLoad() {
    super.viewDidLoad()
    
    DYFSwiftRuntimeProvider.replaceMethod(withClass: XXViewController.self, selector: #selector(XXViewController.verifyCode2), targetClass: XXViewController.self, targetSelector: #selector(XXViewController.verifyQRCode))
    
    verifyCode2()
    verifyQRCode()
}

@objc func verifyCode2() {
    print("Verifies Code2")
}

@objc func verifyQRCode() {
    print("Verifies QRCode")
}
```

### 字典和模型互转

**1. 字典转模型**

```
// e.g.: DYFStoreTransaction: NSObject
let transaction = DYFSwiftRuntimeProvider.model(withDictionary: itemDict, forClass: DYFStoreTransaction.self)
```

**2. 模型转字典**

```
let transaction = DYFStoreTransaction()
let dict = DYFSwiftRuntimeProvider.dictionary(withModel: transaction)
```

### 归档解档

**1. 归档**

```
// e.g.: DYFStoreTransaction: NSObject, NSCoding
open class DYFStoreTransaction: NSObject, NSCoding {

    public func encode(with aCoder: NSCoder) {
        DYFSwiftRuntimeProvider.encode(aCoder, forObject: self)
    }
    
}
```

**2. 解档**

```
// e.g.: DYFStoreTransaction: NSObject, NSCoding 
open class DYFStoreTransaction: NSObject, NSCoding {

    public required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        DYFSwiftRuntimeProvider.decode(aDecoder, forObject: self)
    }
    
}
```


## 演示

`DYFSwiftRuntimeProvider` 在此 [演示](https://github.com/dgynfi/DYFStore) 下学习如何使用。


## 欢迎反馈

如果你注意到任何问题，被卡住或只是想聊天，请随意制造一个问题。我乐意帮助你。
