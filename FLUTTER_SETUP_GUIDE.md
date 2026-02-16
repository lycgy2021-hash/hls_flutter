# Flutter 项目初始化和环境设置指南

## 📝 目录
1. [环境要求](#环境要求)
2. [项目初始化](#项目初始化)
3. [依赖配置](#依赖配置)
4. [平台特定配置](#平台特定配置)
5. [开发工具链](#开发工具链)
6. [快速启动](#快速启动)

---

## 环境要求

### 系统要求

| 要求 | 推荐 | 说明 |
|-----|------|------|
| Flutter SDK | 3.16+ | 支持 Dart 3.0+ |
| Dart SDK | 3.0+ | 包含在 Flutter SDK 中 |
| Java | JDK 11+ | Android 开发必需 |
| Android SDK | API 34 | 最新版本 |
| Android NDK | r23+ | 某些包需要 |
| Xcode | 15+ | iOS 开发必需 |
| iOS Deployment | 11.0+ | iOS 最低版本 |
| macOS | 13.0+ | 用于 iOS/Mac 开发 |
| Windows | 10+ | 用于 Windows 开发 |

### 硬件要求

- RAM: 最少 8GB (推荐 16GB+)
- 存储: 最少 20GB (推荐 50GB+)
- 网络: 稳定的互联网连接 (下载SDK)

---

## 项目初始化

### 1️⃣ 创建 Flutter 项目

```bash
# 基础项目创建
flutter create --org com.douyin.app douyin_flutter

# 进入项目目录
cd douyin_flutter

# 或使用高级选项
flutter create \
  --org com.douyin \
  --project-name douyin_flutter \
  --template app \
  .
```

### 2️⃣ 项目结构设置

```
douyin_flutter/
├── lib/
│   ├── main.dart                    # 应用入口
│   ├── config/
│   │   ├── app_config.dart          # 应用配置
│   │   ├── routes.dart              # 路由配置
│   │   ├── theme.dart               # 主题配置
│   │   └── constants.dart           # 常量定义
│   ├── models/                       # 数据模型
│   │   ├── user_model.dart
│   │   ├── video_model.dart
│   │   ├── message_model.dart
│   │   ├── comment_model.dart
│   │   └── ...
│   ├── services/                     # 业务服务
│   │   ├── api_service.dart         # HTTP API
│   │   ├── websocket_service.dart   # WebSocket
│   │   ├── auth_service.dart        # 认证
│   │   ├── storage_service.dart     # 本地存储
│   │   └── image_service.dart       # 图片处理
│   ├── controllers/                  # GetX 控制器
│   │   ├── app_controller.dart
│   │   ├── auth_controller.dart
│   │   ├── home_controller.dart
│   │   ├── user_controller.dart
│   │   ├── message_controller.dart
│   │   └── ...
│   ├── views/                        # 页面视图
│   │   ├── auth/
│   │   │   ├── login_page.dart
│   │   │   └── register_page.dart
│   │   ├── home/
│   │   │   ├── home_page.dart
│   │   │   ├── video_player_page.dart
│   │   │   └── music_page.dart
│   │   ├── user/
│   │   │   ├── me_page.dart
│   │   │   ├── edit_profile_page.dart
│   │   │   └── my_videos_page.dart
│   │   ├── message/
│   │   │   ├── message_page.dart
│   │   │   ├── chat_page.dart
│   │   │   └── group_chat_page.dart
│   │   ├── shop/
│   │   │   ├── shop_page.dart
│   │   │   └── product_detail_page.dart
│   │   └── ...
│   ├── widgets/                      # 可复用组件
│   │   ├── common/
│   │   │   ├── app_button.dart
│   │   │   ├── app_text_field.dart
│   │   │   ├── app_bar.dart
│   │   │   ├── loading_widget.dart
│   │   │   └── error_widget.dart
│   │   ├── video/
│   │   │   ├── video_player_widget.dart
│   │   │   ├── video_card.dart
│   │   │   └── item_toolbar.dart
│   │   ├── user/
│   │   │   ├── user_avatar.dart
│   │   │   └── user_card.dart
│   │   └── ...
│   ├── utils/                        # 工具类
│   │   ├── logger.dart              # 日志
│   │   ├── validators.dart          # 验证器
│   │   ├── format_helper.dart       # 格式化
│   │   ├── date_helper.dart         # 日期处理
│   │   ├── image_helper.dart        # 图片处理
│   │   ├── string_extensions.dart   # 字符串扩展
│   │   └── constants.dart           # 常量
│   ├── bindings/                     # GetX 绑定
│   │   ├── app_binding.dart
│   │   ├── auth_binding.dart
│   │   └── ...
│   └── providers/                    # 数据提供者
│       └── app_provider.dart
├── android/                          # Android 原生代码
│   └── app/
│       ├── src/
│       │   ├── debug/
│       │   ├── main/
│       │   │   ├── AndroidManifest.xml
│       │   │   ├── java/
│       │   │   ├── kotlin/
│       │   │   └── res/
│       │   └── profile/
│       └── build.gradle.kts
├── ios/                              # iOS 原生代码
│   └── Runner/
│       ├── Runner.xcodeproj
│       ├── Runner.xcworkspace
│       ├── GeneratedPluginRegistrant.h
│       └── Info.plist
├── test/                             # 单元测试
├── integration_test/                 # 集成测试
├── pubspec.yaml                      # 依赖配置
├── analysis_options.yaml             # Lint 分析配置
├── .env                              # 环境变量
├── .env.example                      # 环境变量示例
└── README.md
```

---

## 依赖配置

### pubspec.yaml 完整配置

```yaml
name: douyin_flutter
description: "A new Flutter project - Douyin Clone"

publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # HTTP 与网络
  dio: ^5.3.0                    # HTTP 客户端
  web_socket_channel: ^2.4.0     # WebSocket
  connectivity_plus: ^5.0.0      # 网络状态检测

  # 状态管理
  get: ^4.6.0                    # GetX 框架
  flutter_riverpod: ^2.4.0       # Riverpod (备选)
  provider: ^6.2.0               # Provider (备选)

  # 路由管理
  get_router: ^4.6.0             # GetX Router

  # 本地存储
  shared_preferences: ^2.2.0     # Key-Value 存储
  hive: ^2.2.0                   # 本地数据库
  hive_flutter: ^1.1.0           # Hive Flutter 绑定
  path_provider: ^2.1.0          # 路径管理

  # 视频播放
  video_player: ^2.7.0           # 视频播放器
  chewie: ^1.7.0                 # 视频播放器 UI

  # 图片处理
  cached_network_image: ^3.3.0   # 网络图片缓存
  image_picker: ^1.0.0           # 图片选择
  image_gallery_saver: ^2.0.0    # 保存图片到相册
  photo_view: ^0.14.0            # 照片查看器

  # JSON 序列化
  json_annotation: ^4.8.0
  freezed_annotation: ^2.4.0

  # 日期时间
  intl: ^0.19.0                  # 国际化
  jiffy: ^6.2.0                  # 日期处理

  # UI 组件库
  flutter_staggered_grid_view: ^0.7.0  # 瀑布流
  pull_to_refresh: ^2.0.0        # 下拉刷新
  infinite_scroll_pagination: ^4.0.0  # 无限滚动分页
  shimmer: ^3.0.0                # 骨架屏
  overlay_support: ^2.2.0        # 浮层

  # 动画
  animate_do: ^3.1.0             # 动画库
  lottie: ^2.7.0                 # Lottie 动画

  # 权限管理
  permission_handler: ^11.4.0    # 权限申请

  # 日志
  logger: ^2.1.0                 # 日志库
  firebase_crashlytics: ^8.0.0   # 崩溃报告 (可选)

  # 工具
  uuid: ^4.0.0                   # UUID 生成
  equatable: ^2.0.5              # 对象相等性比较
  
  # 国际化
  flutter_localizations:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_lints: ^3.0.0
  build_runner: ^2.4.0
  json_serializable: ^6.7.0
  freezed: ^2.4.0

flutter:
  uses-material-design: true

  # 资源文件
  assets:
    - assets/images/
    - assets/icons/
    - assets/data/
    - assets/animations/

  # 字体
  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Regular.ttf
          weight: 400
        - asset: assets/fonts/Poppins-Bold.ttf
          weight: 700
        - asset: assets/fonts/Poppins-SemiBold.ttf
          weight: 600

# 完全排除某些依赖
dependency_overrides:
  # 如果需要覆盖某些包的版本
```

### 依赖安装

```bash
# 获取依赖
flutter pub get

# 升级依赖
flutter pub upgrade

# 清理依赖缓存
flutter clean
flutter pub get

# 生成代码 (如果使用 json_serializable 等)
flutter pub run build_runner build

# 监听并自动生成代码
flutter pub run build_runner watch
```

---

## 平台特定配置

### Android 配置

#### 1. build.gradle (Project)
```gradle
buildscript {
    ext.kotlin_version = '1.9.10'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

#### 2. build.gradle (App)
```gradle
android {
    compileSdkVersion 34
    ndkVersion "23.2.8768475"

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        applicationId "com.douyin.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0"
        
        // 多dex支持
        multiDexEnabled true
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

#### 3. AndroidManifest.xml
```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- 权限声明 -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    
    <!-- 存储权限 -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.ACCESS_MEDIA_LOCATION" />

    <application
        android:label="抖音"
        android:icon="@mipmap/ic_launcher">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

#### 4. proguard-rules.pro
```
#Flutter Wrapper
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

#Dart
-keep class com.example.** { *; }

#WebSocket
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**

#JSON
-keep class com.google.gson.** { *; }
-keepclassmembers class ** {
    @com.google.gson.annotations.SerializedName <fields>;
}
```

### iOS 配置

#### 1. Podfile
```ruby
platform :ios, '11.0'

# CocoaPods analytics sends network stats synchronously affecting flutter build latency.
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_CAMERA=1',
      ]
    end
  end
end
```

#### 2. Info.plist
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"...>
<plist version="1.0">
<dict>
    <!-- 基础配置 -->
    <key>CFBundleName</key>
    <string>抖音</string>
    <key>CFBundleIdentifier</key>
    <string>com.douyin.app</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    
    <!-- 权限说明 -->
    <key>NSCameraUsageDescription</key>
    <string>需要访问摄像头以拍摄视频</string>
    
    <key>NSMicrophoneUsageDescription</key>
    <string>需要访问麦克风以录制音频</string>
    
    <key>NSPhotoLibraryUsageDescription</key>
    <string>需要访问照片库以选择图片或视频</string>
    
    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>需要保存照片或视频到您的照片库</string>
    
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>需要获取您的位置信息</string>
    
    <key>NSCalendarsUsageDescription</key>
    <string>需要访问您的日历</string>
    
    <!-- HTTP 连接 (开发时) -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
    
    <!-- 支持的方向 -->
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    
    <!-- 后台模式 -->
    <key>UIBackgroundModes</key>
    <array>
        <string>audio</string>
        <string>fetch</string>
    </array>
    
</dict>
</plist>
```

---

## 开发工具链

### 代码生成配置

#### build.yaml
```yaml
targets:
  $default:
    builders:
      json_serializable:
        options:
          # JSON 序列化配置
          create_to_json: true
          nullable: true
          
      freezed:
        options:
          # Freezed 配置
          map_public: true
```

#### 生成命令
```bash
# 一次性生成所有代码
flutter pub run build_runner build

# 清除生成的部分
flutter pub run build_runner build --delete-conflicting-outputs

# 持续监听并生成
flutter pub run build_runner watch

# 清除所有生成的文件
flutter pub run build_runner clean
```

### 代码分析配置

#### analysis_options.yaml
```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - always_declare_return_types
    - always_put_control_body_on_new_line
    - annotate_overrides
    - avoid_bool_literals_in_conditional_expressions
    - avoid_classes_with_only_static_members
    - avoid_double_and_int_checks
    - avoid_empty_else
    - avoid_equals_and_hash_code_on_mutable_classes
    - avoid_field_initializers_in_const_classes
    - avoid_function_literals_in_foreach_calls
    - avoid_init_to_null
    - avoid_null_checks_in_equality_operators
    - avoid_positional_boolean_parameters
    - avoid_private_typedef_functions
    - avoid_relative_lib_imports
    - avoid_renaming_method_parameters
    - avoid_returning_null
    - avoid_returning_null_for_future
    - avoid_returning_null_for_void
    - avoid_returning_this
    - avoid_shadowing_type_parameters
    - avoid_single_cascade_in_expression_statements
    - avoid_slow_async_io
    - avoid_types_as_parameter_names
    - avoid_types_unrelated_to_declaration
    - avoid_unnecessary_containers
    - avoid_void_async
    - await_only_futures
    - camel_case_extensions
    - camel_case_types
    - cascade_invocations
    - cast_nullable_to_non_nullable
    - close_sinks
    - comment_references
    - conditional_uri_does_not_exist
    - constant_identifier_names
    - curly_braces_in_flow_control_structures
    - directives_ordering
    - empty_catches
    - empty_constructor_bodies
    - eol_only_unix_line_endings
    - file_names
    - implementation_imports
    - invariant_booleans
    - iterable_contains_unrelated_type
    - library_names
    - library_prefixes
    - library_private_types_in_public_api
    - lines_longer_than_80_chars
    - list_remove_unrelated_type
    - literal_only_boolean_expressions
    - no_adjacent_strings_in_list
    - no_leading_underscores_for_library_prefixes
    - no_leading_underscores_for_local_variables
    - null_closures
    - null_check_on_nullable_type_parameter
    - omit_local_variable_types
    - one_member_abstracts
    - only_throw_errors
    - overridden_fields
    - package_api_docs
    - package_names
    - package_prefixed_library_names
    - parameter_assignments
    - prefer_adjacent_string_concatenation
    - prefer_asserts_in_initializer_lists
    - prefer_asserts_with_message
    - prefer_collection_literals
    - prefer_conditional_assignment
    - prefer_const_constructors
    - prefer_const_constructors_in_immutables
    - prefer_const_declarations
    - prefer_const_literals_to_create_immutables
    - prefer_constructors_over_static_methods
    - prefer_contains
    - prefer_equal_for_default_values
    - prefer_expression_function_bodies
    - prefer_final_fields
    - prefer_final_in_for_each
    - prefer_final_locals
    - prefer_for_elements_to_map_fromIterable
    - prefer_foreach
    - prefer_function_declarations_over_variables
    - prefer_generic_function_type_aliases
    - prefer_getters_setters
    - prefer_if_elements_to_conditional_expressions
    - prefer_if_null_to_conditional_expressions
    - prefer_if_on_single_line_blocks
    - prefer_initializing_formals
    - prefer_inlined_adds
    - prefer_int_literals
    - prefer_interpolation_to_compose_strings
    - prefer_is_empty
    - prefer_is_not_empty
    - prefer_is_not_operator
    - prefer_is_operator
    - prefer_iterable_whereType
    - prefer_null_aware_operators
    - prefer_null_coalescing_operators
    - prefer_relative_import_paths
    - prefer_relative_imports
    - prefer_single_quotes
    - provide_deprecation_message
    - recursive_getters
    - sized_box_for_whitespace
    - sized_box_shrink_to_const
    - slash_for_doc_comments
    - sort_child_properties_last
    - sort_constructors_first
    - sort_pub_dependencies
    - sort_unnamed_constructors_first
    - tighten_type_of_initializing_formals
    - type_annotate_public_apis
    - type_init_formals
    - unawaited_futures
    - unnecessary_await_in_return
    - unnecessary_brace_in_string_interp
    - unnecessary_const
    - unnecessary_constructor_name
    - unnecessary_foreach
    - unnecessary_getters_setters
    - unnecessary_lambdas
    - unnecessary_null_aware_assignments
    - unnecessary_null_checks
    - unnecessary_null_in_if_null_operators
    - unnecessary_null_on_extension_on_nullable_type
    - unnecessary_nullable_for_final_variable_declarations
    - unnecessary_overrides
    - unnecessary_parenthesis
    - unnecessary_statements
    - unnecessary_string_escapes
    - unnecessary_string_interpolations
    - unnecessary_sync_in_async_function
    - unnecessary_to_list_in_spreads
    - unnecessary_tolist_in_spreads
    - unrelated_type_equality_checks
    - unsafe_html
    - use_build_context_synchronously
    - use_full_hex_values_for_flutter_colors
    - use_function_type_syntax_for_parameters
    - use_getters_to_return_values_that_dont_change
    - use_if_null_to_convert_nulls
    - use_is_even_rather_than_modulo
    - use_key_in_widget_constructors
    - use_late_for_private_fields_and_variables
    - use_late_for_private_fields_and_variables
    - use_named_constants
    - use_raw_strings
    - use_rethrow_when_possible
    - use_setters_to_change_properties
    - use_string_buffers
    - use_test_throws_matchers
    - use_to_json_string_for_diagnostics
    - use_to_json_string_for_diagnostics
    - void_checks

analyzer:
  strong-mode:
    implicit-dynamic: false
```

---

## 快速启动

### 本地开发流程

```bash
# 1. 克隆并进入项目
cd douyin_flutter

# 2. 获取依赖
flutter pub get

# 3. 连接设备或启动模拟器
# Android: flutter emulators --launch Pixel_6_Pro_API_34
# iOS: 打开 Xcode 或使用 Simulator

# 4. 运行应用
flutter run

# 5. 调试模式
flutter run --debug

# 6. Release 模式
flutter run --release

# 7. 特定设备
flutter run -d <device_id>

# 8. 热重载 (在运行状态下按 'r')
# 或使用 IDE 快捷键
```

### 构建产物

```bash
# Android APK
flutter build apk --release
# 输出: build/app/outputs/flutter-apk/app-release.apk

# Android App Bundle (推荐用于 Play Store)
flutter build appbundle --release
# 输出: build/app/outputs/bundle/release/app-release.aab

# iOS
flutter build ios --release
# 输出: build/ios/iphoneos/Runner.app

# iOS 框架 (用于 CocoaPods 集成)
flutter build ios-framework --release
```

### iOS 手动编译和发布

```bash
# 1. 构建 iOS 项目
flutter build ios --release

# 2. 打开 Xcode 工程
open ios/Runner.xcworkspace

# 3. 在 Xcode 中:
#    - 选择 Runner scheme
#    - 选择 Any iOS Device (arm64)
#    - Product → Archive
#    - 选择证书和提供文件
#    - Upload to App Store
```

---

## 📱 运行在不同平台

### Android 模拟器
```bash
# 列出可用模拟器
flutter emulators

# 启动特定模拟器
flutter emulators --launch Pixel_6_Pro_API_34

# 运行
flutter run
```

### iOS 模拟器
```bash
# 打开 iOS 模拟器
open -a Simulator

# 列出可用设备
flutter devices

# 在模拟器上运行
flutter run -d 'iPhone 15 Pro'
```

### 真实设备

#### Android 真机
```bash
# 启用开发者模式和USB调试
# 连接 USB 线

flutter devices          # 列出设备
flutter run -d <device_id>
```

#### iOS 真机
```bash
# 需要:
# 1. Apple 开发者账号
# 2. Code Signing 证书
# 3. Provisioning Profile

# 在 Xcode 中设置 Team ID 和证书
# 或使用命令行:
flutter run -d 'iPhone (Device ID)'
```

---

## 性能优化建议

### 开发时
```bash
# 使用 profile 模式进行性能测试
flutter run --profile

# 使用 DevTools 进行性能分析
flutter pub global activate devtools
devtools
```

### 打包前
```bash
# 分析应用大小
flutter build apk --analyze-size

# 启用 shrinking
flutter build apk --target-platform android-arm64 --shrink
```

---

## 常见问题

### 依赖冲突
```bash
# 阻止版本冲突
flutter pub upgrade --major-versions

# 查看依赖树
flutter pub deps
```

### 清理缓存
```bash
flutter clean
flutter pub get
cd ios && rm -rf Pods Podfile.lock && cd ..
flutter run
```

---

**版本**: 1.0  
**更新时间**: 2026-02-16
