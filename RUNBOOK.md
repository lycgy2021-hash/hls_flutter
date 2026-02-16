# RUNBOOK

## M0 - Flutter skeleton + env + logging
### 如何运行
1. 进入 `flutter_app` 目录。
2. 执行 `flutter pub get`。
3. 通过 `flutter run` 启动。
4. 可用 `dart-define` 切换环境：
   - `--dart-define=API_BASE=http://<host>:8080`
   - `--dart-define=API_NEW_BASE=http://<host>:8099`
   - `--dart-define=ALGO_BASE=http://<host>:8083`
   - `--dart-define=LONG_VIDEO_BASE=http://<host>:8081`

### 手工测试
- 启动后应进入登录或视频页（取决于本地登录态）。
- 日志可在控制台看到 `APP` 前缀输出。

### 已知限制
- 当前环境未检测到 `flutter` CLI，需要在本机安装 Flutter SDK 后执行上述命令。

---

## M1 - ApiClient + Auth + Storage + error mapping
### 如何运行
- 与 M0 相同，重点验证登录请求和 Header 注入。

### 手工测试
1. 输入 `uid/password` 后点击登录。
2. 抓包确认：`POST /user/login`，包含 `uid/password/mode/did`。
3. 抓包确认 Header 包含 `X-Actor-ID` 和 `X-DID`。
4. 抓包确认登录请求 `Content-Type` 为 `application/x-www-form-urlencoded; charset=UTF-8`。
5. 断网或关闭后端后重试，确认错误被映射为可读文案且不崩溃。

### API 契约对照（来自 `E:\hls\webdemo` 只读扫描）
- Header：`X-Actor-ID`、`X-DID`，消息条件请求支持 `If-None-Match`。
- 登录字段：`uid/password/mode/did`。
- 分页风格并存：
   - 内容流：`offset/limit`
   - 群聊：`pageNo/pageSize`
   - 推荐流：`index/dir/step`

### 已知限制
- M1 仅实现最小登录态持久化；复杂用户信息页不在当前里程碑。

---

## M2 - Feed + video lifecycle core
### 如何运行
- 登录后自动进入 `/home` 垂直视频流页面。

### 手工测试
1. 上下滑动页面：应切换视频。
2. 检查内存/日志：应仅保持当前+下一条控制器，旧控制器被释放。
3. App 切后台再回前台：当前视频恢复，且不出现多视频同时播放。
4. 服务端返回广告 URL 或空 URL：该条应被过滤，不导致崩溃。

### 已知限制
- M3（点赞/收藏/评论）与 M4（消息）仅保留 TODO 安全占位。
- 反馈上报目前实现 `shown/started/progress` 最小闭环。
