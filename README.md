# rzpaas_sdk_demo_apple
a demo shows how to use rzpaas sdk in iOS/macOS platform.


## sdk 所在目录
- ios `sdks/RZPaas_iOS.xcframework`, 包含真机和模拟器
- mac `RZPaas_macOS.framework`

## 运行demo
1. 替换 AppId , 在文件 `KeyCenter.swift`
    ```
    import Foundation
    //MARK: - replace me
    public let kAppId = ""
    ```
2. 执行`pod install`
3. 运行demo, ios/mac 
    - `rzpaas_sdk_demo_ios`
    - `rzpaas_sdk_demo_macos`



