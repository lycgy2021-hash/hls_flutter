# 快速参考手册和功能转换指南

## 📋 目录
1. [API 端点快速参考](#api-端点快速参考)
2. [核心功能转换](#核心功能转换)
3. [事件和消息系统](#事件和消息系统)
4. [WebSocket 连接](#websocket-连接)
5. [常见转换模式](#常见转换模式)
6. [调试和日志](#调试和日志)

---

## API 端点快速参考

### 后端服务地址

| 服务 | 地址 | 说明 |
|------|------|------|
| 主服务 | http://192.168.0.107:8080 | 核心业务 API |
| 算法服务 | http://192.168.0.107:8083 | 推荐算法 |
| 长视频集群 | http://192.168.0.107:8081 | 长视频存储 |

### 用户相关 API

```dart
// 登录
POST /user/login
{
  "uid": "用户名",
  "password": "密码",
  "mode": "login"
}
Response: { "token": "...", "user": {...} }

// 获取用户信息
GET /user/userinfo
Response: { "user": {...} }

// 用户视频列表
GET /user/video_list?offset=0&count=10
Response: { "videos": [...] }

// 用户面板数据
GET /user/panel
Response: { "followers": 0, "following": 0, "videos": 0, ... }

// 好友列表
GET /user/friends?offset=0&count=10
Response: { "friends": [...] }

// 粉丝列表
GET /user/followers?offset=0&count=10
Response: { "followers": [...] }

// 用户收藏
GET /user/collect?offset=0&count=10
Response: { "videos": [...] }
```

### 视频相关 API

```dart
// 视频流 (首页)
GET /post/video/feed?offset=0&count=10&sort_type=0
Response: { "videos": [...] }

// 视频搜索
GET /post/video/search?q=keywords&offset=0&count=10
Response: { "videos": [...] }

// 推荐视频
GET /post/recommended?offset=0&count=10
Response: { "posts": [...] }

// 点赞视频
POST /post/video/{video_id}/like
Response: { "success": true, "like_count": 100 }

// 取消点赞
POST /post/video/{video_id}/unlike
Response: { "success": true, "like_count": 99 }

// 获取评论列表
GET /post/video/{video_id}/comments?offset=0&count=20
Response: { "comments": [...] }

// 发布评论
POST /post/video/{video_id}/comment
{
  "content": "评论内容",
  "reply_to": null  // 回复的评论 ID
}
Response: { "comment": {...} }
```

### 消息相关 API

```dart
// 获取消息列表
GET /message/list?offset=0&count=10
Response: { "messages": [...] }

// 获取聊天记录
GET /message/chat?user_id={userId}&offset=0&count=20
Response: { "messages": [...] }

// 发送消息
POST /message/send
{
  "receiver_id": "用户ID",
  "content": "消息内容",
  "type": "text"  // text, image, video
}
Response: { "message": {...} }

// WebSocket 连接 (实时消息)
WebSocket /ws/message?token=...
Event: { "type": "msg", "data": {...} }
```

### 商城 API

```dart
// 推荐商品
GET /shop/recommended?offset=0&count=10
Response: { "products": [...] }

// 商品详情
GET /shop/product/{product_id}
Response: { "product": {...} }

// 购买商品
POST /shop/product/{product_id}/buy
{
  "quantity": 1,
  "payment_method": "alipay"
}
Response: { "order": {...} }
```

---

## 核心功能转换

### 1. 用户认证流程

#### Vue 实现原理
```typescript
// src/utils/request.ts
const request = (config) => {
  return axiosInstance(config)
}

// 拦截器处理授权
axiosInstance.interceptors.request.use((config) => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers['Authorization'] = `Bearer ${token}`
  }
  return config
})

// src/api/user.ts
export function apiLogin(uid: string, password: string) {
  return request({
    url: '/user/login',
    method: 'post',
    data: { uid, password, mode: 'login' }
  })
}
```

#### Flutter 完整实现

```dart
// lib/models/auth_response.dart
class AuthResponse {
  final String token;
  final UserModel user;
  
  AuthResponse({
    required this.token,
    required this.user,
  });
  
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }
}

// lib/services/auth_service.dart
class AuthService {
  final apiService = ApiService();
  final storageService = StorageService();
  
  Future<void> login(String username, String password) async {
    try {
      final response = await apiService.login(username, password);
      
      // 保存 Token
      await storageService.saveToken(response.token);
      
      // 保存用户信息
      await storageService.saveUser(response.user);
      
      // 更新 API 服务的请求头
      apiService.setAuthToken(response.token);
    } catch (e) {
      throw AuthException('Login failed: $e');
    }
  }
  
  Future<void> logout() async {
    await storageService.clearAll();
    apiService.clearAuthToken();
  }
  
  Future<bool> isLoggedIn() async {
    final token = await storageService.getToken();
    return token != null && token.isNotEmpty;
  }
}

// lib/services/api_service.dart
class ApiService {
  String? _authToken;
  
  void setAuthToken(String token) {
    _authToken = token;
    dio.options.headers['Authorization'] = 'Bearer $token';
  }
  
  void clearAuthToken() {
    _authToken = null;
    dio.options.headers.remove('Authorization');
  }
  
  Future<AuthResponse> login(String uid, String password) async {
    final formData = FormData.fromMap({
      'uid': uid,
      'password': password,
      'mode': 'login',
    });
    
    final response = await dio.post('/user/login', data: formData);
    return AuthResponse.fromJson(response.data);
  }
}

// lib/controllers/auth_controller.dart
class AuthController extends GetxController {
  final authService = AuthService();
  
  final isLoading = false.obs;
  final currentUser = RxnObject<UserModel>();
  
  Future<void> login(String username, String password) async {
    try {
      isLoading.value = true;
      await authService.login(username, password);
      
      // 获取用户信息
      final user = await authService.getCurrentUser();
      currentUser.value = user;
      
      // 导航到首页
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar('错误', '登录失败: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> logout() async {
    await authService.logout();
    Get.offAllNamed('/login');
  }
}
```

---

### 2. 视频流加载和无限滚动

#### Vue 实现
```vue
<template>
  <div class="feed">
    <div v-for="video in videos" :key="video.id">
      <BaseVideo :item="video" />
    </div>
    <Loading v-if="isLoading" />
  </div>
</template>

<script setup>
const videos = ref([])
const isLoading = ref(false)
const page = ref(1)

const loadMore = async () => {
  if (isLoading.value) return
  isLoading.value = true
  
  try {
    const res = await apiService.getVideoFeed({
      offset: (page.value - 1) * 10,
      count: 10
    })
    videos.value.push(...res)
    page.value++
  } finally {
    isLoading.value = false
  }
}
</script>
```

#### Flutter 完整实现

```dart
// lib/controllers/home_controller.dart
class HomeController extends GetxController {
  final apiService = ApiService();
  
  final videos = <VideoModel>[].obs;
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  
  int _page = 1;
  static const int _pageSize = 10;
  
  @override
  void onInit() {
    super.onInit();
    loadMore();
  }
  
  Future<void> loadMore() async {
    if (isLoading.value) return;
    
    try {
      isLoading.value = true;
      
      final newVideos = await apiService.getVideoFeed(
        offset: (_page - 1) * _pageSize,
        count: _pageSize,
      );
      
      if (newVideos.isEmpty) {
        // 没有更多数据
        return;
      }
      
      videos.addAll(newVideos);
      _page++;
    } catch (e) {
      Get.snackbar('错误', '加载视频失败: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> refreshVideos() async {
    try {
      isRefreshing.value = true;
      videos.clear();
      _page = 1;
      await loadMore();
    } finally {
      isRefreshing.value = false;
    }
  }
}

// lib/views/home/home_page.dart
class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => RefreshIndicator(
          onRefresh: controller.refreshVideos,
          child: ListView.builder(
            itemCount: controller.videos.length + 1,
            itemBuilder: (context, index) {
              // 加载完成或正在加载
              if (index == controller.videos.length) {
                if (controller.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }
                // 加载更多
                if (controller.videos.isNotEmpty) {
                  Future.microtask(() => controller.loadMore());
                }
                return SizedBox.shrink();
              }
              
              return VideoPlayerWidget(
                item: controller.videos[index],
                active: index == 0,  // 只显示第一个
              );
            },
          ),
        ),
      ),
    );
  }
}
```

---

### 3. 实时消息系统

#### WebSocket 连接管理

```dart
// lib/services/websocket_service.dart
class WebSocketService {
  late WebSocketChannel _channel;
  final _messageController = StreamController<MessageModel>.broadcast();
  
  Stream<MessageModel> get messageStream => _messageController.stream;
  
  Future<void> connect(String token) async {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://192.168.0.107:8080/ws/message?token=$token'),
      );
      
      _channel.stream.listen(
        (message) => _handleMessage(message),
        onError: (e) => _handleError(e),
        onDone: () => _handleDone(),
      );
    } catch (e) {
      throw WebSocketException('Failed to connect: $e');
    }
  }
  
  void _handleMessage(dynamic data) {
    try {
      final json = jsonDecode(data);
      
      switch (json['type']) {
        case 'msg':
          final message = MessageModel.fromJson(json['data']);
          _messageController.add(message);
          break;
          
        case 'pong':
          // 心跳响应
          break;
          
        case 'error':
          Get.snackbar('错误', json['message']);
          break;
      }
    } catch (e) {
      print('Error parsing message: $e');
    }
  }
  
  void _handleError(dynamic error) {
    print('WebSocket error: $error');
    // 尝试重新连接
    Future.delayed(Duration(seconds: 3), () {
      connect(_getStoredToken());
    });
  }
  
  void _handleDone() {
    print('WebSocket closed');
  }
  
  void sendMessage(String receiverId, String content) {
    final message = {
      'type': 'msg',
      'data': {
        'receiver_id': receiverId,
        'content': content,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    };
    
    _channel.sink.add(jsonEncode(message));
  }
  
  void disconnect() {
    _channel.sink.close();
    _messageController.close();
  }
  
  String _getStoredToken() {
    // 从存储中获取 token
    return '';
  }
}

// lib/controllers/message_controller.dart
class MessageController extends GetxController {
  final wsService = WebSocketService();
  final apiService = ApiService();
  
  final messages = <MessageModel>[].obs;
  final isConnected = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initWebSocket();
    _loadMessages();
  }
  
  Future<void> _initWebSocket() async {
    try {
      final token = await _getStoredToken();
      await wsService.connect(token);
      
      isConnected.value = true;
      
      wsService.messageStream.listen((message) {
        messages.insert(0, message);
        _playNotificationSound();
      });
    } catch (e) {
      Get.snackbar('错误', '连接失败: $e');
    }
  }
  
  Future<void> _loadMessages() async {
    try {
      final loadedMessages = await apiService.getMessages(
        offset: 0,
        count: 50,
      );
      messages.value = loadedMessages;
    } catch (e) {
      Get.snackbar('错误', '加载消息失败: $e');
    }
  }
  
  Future<void> sendMessage(String receiverId, String content) async {
    try {
      // 首先通过 HTTP 发送
      await apiService.sendMessage(receiverId, content);
      
      // 然后通过 WebSocket 发送
      wsService.sendMessage(receiverId, content);
    } catch (e) {
      Get.snackbar('错误', '发送失败: $e');
    }
  }
  
  void _playNotificationSound() {
    // 播放通知声音
  }
  
  @override
  void onClose() {
    wsService.disconnect();
    super.onClose();
  }
}
```

---

### 4. 图片上传处理

#### Vue 实现
```typescript
// src/components/Upload.vue
async function uploadImage(file: File) {
  const formData = new FormData()
  formData.append('file', file)
  
  return request({
    url: '/upload',
    method: 'post',
    data: formData,
    headers: {
      'Content-Type': 'multipart/form-data'
    },
    onUploadProgress: (ProgressEvent) => {
      progressPercent.value = Math.round(
        (ProgressEvent.loaded / ProgressEvent.total) * 100
      )
    }
  })
}
```

#### Flutter 完整实现

```dart
// lib/services/upload_service.dart
class UploadService {
  final dio = Dio();
  final uploadProgress = 0.0.obs;
  
  Future<String> uploadImage(File imageFile) async {
    try {
      final fileName = imageFile.path.split('/').last;
      
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });
      
      final response = await dio.post(
        'http://192.168.0.107:8080/upload',
        data: formData,
        onSendProgress: (sent, total) {
          uploadProgress.value = sent / total;
        },
      );
      
      return response.data['url'] ?? '';
    } catch (e) {
      throw UploadException('Upload failed: $e');
    }
  }
  
  Future<List<String>> uploadMultipleImages(List<File> files) async {
    final results = <String>[];
    
    for (var file in files) {
      try {
        final url = await uploadImage(file);
        results.add(url);
      } catch (e) {
        print('Failed to upload: $e');
      }
    }
    
    return results;
  }
}

// lib/views/publish/publish_page.dart
class PublishPage extends StatefulWidget {
  @override
  State<PublishPage> createState() => _PublishPageState();
}

class _PublishPageState extends State<PublishPage> {
  final uploadService = UploadService();
  final controller = TextEditingController();
  final selectedImages = <File>[].obs;
  
  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    
    for (var image in images) {
      selectedImages.add(File(image.path));
    }
  }
  
  Future<void> _publishPost() async {
    if (controller.text.isEmpty) {
      Get.snackbar('错误', '请输入内容');
      return;
    }
    
    try {
      // 上传图片
      final imageUrls = await uploadService.uploadMultipleImages(
        selectedImages.toList(),
      );
      
      // 发布文章
      await apiService.publishPost(
        content: controller.text,
        images: imageUrls,
      );
      
      Get.back();
      Get.snackbar('成功', '发布成功');
    } catch (e) {
      Get.snackbar('错误', '发布失败: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('发布')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 文本输入
            TextField(
              controller: controller,
              decoration: InputDecoration(hintText: '说点什么...'),
              maxLines: 5,
            ),
            
            // 图片选择
            Obx(
              () => Wrap(
                children: [
                  ...selectedImages.map((image) {
                    return Stack(
                      children: [
                        Image.file(image, width: 100, height: 100),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => selectedImages.remove(image),
                          ),
                        ),
                      ],
                    );
                  }),
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(),
                      ),
                      child: Icon(Icons.add),
                    ),
                  ),
                ],
              ),
            ),
            
            // 发布按钮
            ElevatedButton(
              onPressed: _publishPost,
              child: Text('发布'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 5. 本地缓存和持久化

```dart
// lib/services/cache_service.dart
class CacheService {
  static const String userKey = 'user_cache';
  static const String videoKey = 'video_cache';
  static const String messageKey = 'message_cache';
  
  final box = Hive.box('app_cache');
  
  // 用户数据缓存
  Future<void> cacheUser(UserModel user) async {
    await box.put(userKey, user.toJson());
  }
  
  Future<UserModel?> getCachedUser() async {
    final data = box.get(userKey);
    if (data == null) return null;
    return UserModel.fromJson(data);
  }
  
  // 视频列表缓存
  Future<void> cacheVideos(List<VideoModel> videos, {int page = 1}) async {
    final key = '$videoKey$page';
    final data = videos.map((v) => v.toJson()).toList();
    await box.put(key, data);
  }
  
  Future<List<VideoModel>?> getCachedVideos({int page = 1}) async {
    final key = '$videoKey$page';
    final data = box.get(key);
    if (data == null) return null;
    return (data as List).map((e) => VideoModel.fromJson(e)).toList();
  }
  
  // 消息缓存
  Future<void> cacheMessage(MessageModel message) async {
    final messages = getCachedMessages() ?? [];
    messages.insert(0, message);
    await box.put(messageKey, messages.map((m) => m.toJson()).toList());
  }
  
  List<MessageModel>? getCachedMessages() {
    final data = box.get(messageKey);
    if (data == null) return null;
    return (data as List).map((e) => MessageModel.fromJson(e)).toList();
  }
  
  // 清空缓存
  Future<void> clearCache() async {
    await box.clear();
  }
}

// 使用示例
class HomeController extends GetxController {
  final cacheService = CacheService();
  final apiService = ApiService();
  
  final videos = <VideoModel>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadVideos();
  }
  
  Future<void> _loadVideos() async {
    // 先加载缓存
    final cached = await cacheService.getCachedVideos();
    if (cached != null) {
      videos.value = cached;
    }
    
    // 从网络加载新数据
    try {
      final fresh = await apiService.getVideoFeed(
        offset: 0,
        count: 10,
      );
      
      videos.value = fresh;
      await cacheService.cacheVideos(fresh);
    } catch (e) {
      // 使用缓存数据
      if (videos.isEmpty) {
        Get.snackbar('错误', '加载失败');
      }
    }
  }
}
```

---

## 事件和消息系统

### 事件总线模式

#### Vue 中的事件系统
```typescript
// src/utils/bus.ts
import { EventEmitter } from 'eventemitter3'

const bus = new EventEmitter()

export const EVENT_KEY = {
  VIDEO_LIKE: 'video_like',
  VIDEO_COMMENT: 'video_comment',
  USER_FOLLOW: 'user_follow',
  MESSAGE_NEW: 'message_new'
}

export default bus

// 发送事件
bus.emit(EVENT_KEY.VIDEO_LIKE, { videoId, liked })

// 监听事件
bus.on(EVENT_KEY.VIDEO_LIKE, (data) => {
  console.log('Video liked:', data)
})
```

#### Flutter 事件系统

```dart
// lib/utils/event_bus.dart
class EventBus {
  static final EventBus _instance = EventBus._internal();
  
  factory EventBus() {
    return _instance;
  }
  
  EventBus._internal();
  
  final _eventController = StreamController<Event>.broadcast();
  
  Stream<Event> get events => _eventController.stream;
  
  void emit<T>(T event) {
    _eventController.add(Event(event));
  }
  
  StreamSubscription<Event> on(
    Type eventType,
    void Function(Event event) onData,
  ) {
    return _eventController.stream
        .where((event) => event.data.runtimeType == eventType)
        .listen(onData);
  }
  
  void dispose() {
    _eventController.close();
  }
}

class Event {
  final dynamic data;
  Event(this.data);
}

// 定义事件类型
class VideoLikeEvent {
  final String videoId;
  final bool liked;
  
  VideoLikeEvent({
    required this.videoId,
    required this.liked,
  });
}

class UserFollowEvent {
  final String userId;
  final bool following;
  
  UserFollowEvent({
    required this.userId,
    required this.following,
  });
}

// 使用示例
final eventBus = EventBus();

// 发送事件
eventBus.emit(VideoLikeEvent(
  videoId: '123',
  liked: true,
));

// 监听事件
class VideoDetailController extends GetxController {
  late StreamSubscription<Event> likeListener;
  
  @override
  void onInit() {
    super.onInit();
    likeListener = eventBus.on(VideoLikeEvent, (event) {
      final likeEvent = event.data as VideoLikeEvent;
      print('Video was liked: ${likeEvent.videoId}');
    });
  }
  
  @override
  void onClose() {
    likeListener.cancel();
    super.onClose();
  }
}
```

---

## WebSocket 连接

### 心跳保活机制

```dart
// lib/services/websocket_service.dart
class WebSocketService {
  late WebSocketChannel _channel;
  Timer? _heartbeatTimer;
  static const heartbeatInterval = Duration(seconds: 30);
  
  Future<void> connect(String token) async {
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://192.168.0.107:8080/ws/message?token=$token'),
      );
      
      _channel.stream.listen(
        (message) => _handleMessage(message),
        onError: (e) => _handleError(e),
        onDone: () => _handleDone(),
      );
      
      // 启动心跳
      _startHeartbeat();
    } catch (e) {
      throw WebSocketException('Failed to connect: $e');
    }
  }
  
  void _startHeartbeat() {
    _heartbeatTimer = Timer.periodic(heartbeatInterval, (_) {
      _sendHeartbeat();
    });
  }
  
  void _sendHeartbeat() {
    try {
      _channel.sink.add(jsonEncode({'type': 'ping'}));
    } catch (e) {
      print('Heartbeat failed: $e');
      _reconnect();
    }
  }
  
  void _handleError(dynamic error) {
    print('WebSocket error: $error');
    _reconnect();
  }
  
  void _handleDone() {
    print('WebSocket closed');
    _heartbeatTimer?.cancel();
    _reconnect();
  }
  
  void _reconnect() {
    Future.delayed(Duration(seconds: 5), () {
      // 重新连接逻辑
      _startHeartbeat();
    });
  }
  
  void disconnect() {
    _heartbeatTimer?.cancel();
    _channel.sink.close();
  }
}
```

---

## 常见转换模式

### 模式 1: Vue 组件 Props → Flutter 构造参数

```dart
// Vue: <VideoCard :video="video" :onLike="handleLike" />
// Flutter:
class VideoCard extends StatefulWidget {
  final VideoModel video;
  final Function(bool) onLike;
  
  const VideoCard({
    required this.video,
    required this.onLike,
  });
  
  @override
  State<VideoCard> createState() => _VideoCardState();
}
```

### 模式 2: Vue v-if → Flutter 条件

```dart
// Vue: <div v-if="isLoading">Loading...</div>
// Flutter:
Stack(
  children: [
    Content(),
    if (isLoading) LoadingWidget(),
  ],
)
```

### 模式 3: Vue v-for → Flutter ListView.builder

```dart
// Vue: <div v-for="item in items" :key="item.id">{{item.name}}</div>
// Flutter:
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return Text(items[index].name);
  },
)
```

### 模式 4: Vue 计算属性 → Flutter 方法/Getter

```dart
// Vue: computed: { selectFriends() { return ... } }
// Flutter:
class UserController extends GetxController {
  List<UserModel> get selectFriends {
    return friends.where((u) => u.isSelected).toList();
  }
}
```

---

## 调试和日志

### 日志系统

```dart
// lib/utils/logger.dart
class AppLogger {
  static final logger = Logger();
  
  static void info(String message) {
    logger.i(message);
  }
  
  static void warning(String message) {
    logger.w(message);
  }
  
  static void error(String message, {dynamic error, StackTrace? stackTrace}) {
    logger.e(message, error: error, stackTrace: stackTrace);
  }
  
  static void debug(String message) {
    logger.d(message);
  }
}

// 使用
AppLogger.info('User logged in');
AppLogger.error('Network error', error: e, stackTrace: st);
```

### DevTools 使用

```bash
# 启动 DevTools
flutter pub global activate devtools
devtools

# 在应用运行时连接
# Dart DevTools 将在 http://127.0.0.1:9100 打开

# 主要功能:
# - Inspector: 查看 Widget 树
# - Performance: 性能分析
# - Network: 网络请求监控
# - Dart DevTools: Dart 调试
# - Logging: 查看日志
```

---

**参考手册版本**: 1.0  
**最后更新**: 2026-02-16
