# 代码模块详细转换指南

## 📖 目录
1. [Vue组件转Flutter Widget](#vue组件转flutter-widget)
2. [API层转换](#api层转换)
3. [状态管理转换](#状态管理转换)
4. [路由系统转换](#路由系统转换)
5. [工具函数转换](#工具函数转换)
6. [CSS样式转换](#css样式转换)
7. [TypeScript类型转换](#typescript类型转换)

---

## Vue组件转Flutter Widget

### 1️⃣ BaseVideo.vue → VideoPlayerWidget (1213行)

**核心任务**: 视频播放、进度控制、手势交互

```dart
// Flutter 实现框架
class VideoPlayerWidget extends StatefulWidget {
  final VideoModel item;
  final bool active;
  final Function onVideoEnd;
  
  const VideoPlayerWidget({
    required this.item,
    required this.active,
    required this.onVideoEnd,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget>
    with TickerProviderStateMixin {
  late VideoPlayerController _controller;
  late ChewieController _chewieController;
  
  bool _isMuted = false;
  bool _isPlaying = false;
  Duration _currentTime = Duration.zero;
  Duration _duration = Duration.zero;
  
  // 手势相关
  bool _isMoving = false;
  double _lastX = 0;
  
  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }
  
  Future<void> _initializeVideo() async {
    final cleanUrl = _cleanPlayUrl(widget.item.playUrl);
    _controller = VideoPlayerController.network(cleanUrl)
      ..addListener(_videoListener)
      ..initialize().then((_) {
        setState(() {
          _duration = _controller.value.duration;
        });
        
        if (widget.active) {
          _controller.play();
        }
      });
    
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: widget.active,
      looping: true,
      allowFullScreen: false,
      allowMuting: true,
      showControlsOnInitialize: false,
    );
  }
  
  void _videoListener() {
    setState(() {
      _currentTime = _controller.value.position;
      _isPlaying = _controller.value.isPlaying;
    });
  }
  
  String _cleanPlayUrl(dynamic url) {
    // 实现 Vue 中的 cleanPlayUrl 逻辑
    if (url is String) {
      return _isAdUrl(url) ? '' : url;
    }
    if (url is List) {
      for (var u in url) {
        if (!_isAdUrl(u)) return u;
      }
    }
    return '';
  }
  
  bool _isAdUrl(String url) {
    const adDomains = [
      'mediav.com', 'live-s3m', 'doubleclick.net',
      'ads.', 'ad.', 'adv.', 'beacon', 'tracking'
    ];
    return adDomains.any((d) => url.toLowerCase().contains(d.toLowerCase()));
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Stack(
        children: [
          // 视频播放器
          Chewie(controller: _chewieController),
          
          // 暂停图标
          if (!_isPlaying)
            Center(
              child: Icon(Icons.play_arrow, size: 60, color: Colors.white),
            ),
          
          // 进度控制
          _buildProgressBar(),
          
          // 其他UI层
        ],
      ),
    );
  }
  
  Widget _buildProgressBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTapDown: (details) => _seekTo(details),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: _duration.inSeconds > 0
                  ? _currentTime.inSeconds / _duration.inSeconds
                  : 0,
            ),
            if (_isMoving)
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  '${_formatDuration(_currentTime)} / ${_formatDuration(_duration)}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  void _onDragStart(DragStartDetails details) {
    setState(() => _isMoving = true);
    _lastX = details.globalPosition.dx;
  }
  
  void _onDragUpdate(DragUpdateDetails details) {
    final delta = details.globalPosition.dx - _lastX;
    final seekSeconds = (delta / 100) * 15; // 快进/快退秒数
    
    final newPosition = _currentTime + Duration(seconds: seekSeconds.toInt());
    _controller.seekTo(newPosition);
  }
  
  void _onDragEnd(DragEndDetails details) {
    setState(() => _isMoving = false);
  }
  
  void _seekTo(TapDownDetails details) {
    // 点击进度条跳转
    final box = context.findRenderObject() as RenderBox;
    final percent = details.localPosition.dx / box.size.width;
    final newPosition = Duration(seconds: (_duration.inSeconds * percent).toInt());
    _controller.seekTo(newPosition);
  }
  
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _chewieController.dispose();
    super.dispose();
  }
}
```

**需要的Package**:
- `video_player: ^2.7.0`
- `chewie: ^1.7.0`

---

### 2️⃣ Scroll/ScrollList.vue → InfiniteScrollView

**Vue 代码示例**:
```vue
<template>
  <div class="scroll-container" @scroll="onScroll">
    <div v-for="item in items" :key="item.id">
      {{ item.content }}
    </div>
  </div>
</template>

<script setup>
const items = ref([])
const page = ref(1)
const isLoading = ref(false)

const onScroll = async (e) => {
  if (isNearBottom(e.target)) {
    if (!isLoading.value) {
      isLoading.value = true
      const data = await fetchMore(page.value++)
      items.value.push(...data)
      isLoading.value = false
    }
  }
}

const isNearBottom = (el) => {
  return el.scrollHeight - el.scrollTop - el.clientHeight < 100
}
</script>
```

**Flutter 等价实现**:
```dart
class InfiniteScrollView extends StatefulWidget {
  @override
  State<InfiniteScrollView> createState() => _InfiniteScrollViewState();
}

class _InfiniteScrollViewState extends State<InfiniteScrollView> {
  late ScrollController _scrollController;
  List<VideoModel> items = [];
  int page = 1;
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadMore();
  }
  
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _loadMore();
    }
  }
  
  Future<void> _loadMore() async {
    if (!isLoading) {
      setState(() => isLoading = true);
      try {
        final newItems = await apiService.fetchVideos(page);
        setState(() {
          items.addAll(newItems);
          page++;
          isLoading = false;
        });
      } catch (e) {
        setState(() => isLoading = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        page = 1;
        items.clear();
        await _loadMore();
      },
      child: ListView.builder(
        controller: _scrollController,
        itemCount: items.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return Center(child: CircularProgressIndicator());
          }
          return VideoCard(item: items[index]);
        },
      ),
    );
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

---

### 3️⃣ WaterfallList.vue → GridView (瀑布流)

```dart
class WaterfallListView extends StatelessWidget {
  final List<PhotoModel> photos;
  
  const WaterfallListView({required this.photos});
  
  @override
  Widget build(BuildContext context) {
    return StaggeredGridView.countBuilder(
      crossAxisCount: 2,
      itemCount: photos.length,
      itemBuilder: (context, index) {
        return PhotoCard(photo: photos[index]);
      },
      staggeredTileBuilder: (index) {
        // 随机高度比例，模拟瀑布流效果
        return StaggeredTile.count(1, 
          1.0 + (index % 3) * 0.2
        );
      },
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
    );
  }
}
```

需要: `flutter_staggered_grid_view: ^0.7.0`

---

### 4️⃣ Comment.vue / CommentNew.vue → CommentWidget

**Flutter 实现**:
```dart
class CommentWidget extends StatefulWidget {
  final VideoModel video;
  
  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  List<CommentModel> comments = [];
  TextEditingController _commentController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadComments();
  }
  
  Future<void> _loadComments() async {
    final data = await apiService.getComments(widget.video.id);
    setState(() => comments = data);
  }
  
  Future<void> _postComment() async {
    if (_commentController.text.isEmpty) return;
    
    await apiService.postComment(
      videoId: widget.video.id,
      content: _commentController.text,
    );
    
    _commentController.clear();
    await _loadComments();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 评论列表
        ListView.builder(
          itemCount: comments.length,
          itemBuilder: (context, index) {
            return CommentCard(comment: comments[index]);
          },
        ),
        
        // 输入框
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(
                  authService.currentUser.avatar,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: '发表评论...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: _postComment,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
```

---

## API层转换

### Vue 中的 API 调用

```typescript
// src/api/videos.ts
export function getVideoFeed(params?: any) {
  return request({
    url: '/post/video/feed',
    method: 'get',
    params: {
      offset: params?.offset || 0,
      count: params?.count || 10,
      sort_type: params?.sort_type || 0
    }
  })
}

export function likeVideo(video_id: string) {
  return request({
    url: `/post/video/${video_id}/like`,
    method: 'post'
  })
}
```

### Flutter 中的等价实现

```dart
// lib/services/api_service.dart
class ApiService {
  static const String baseUrl = 'http://192.168.0.107:8080';
  static const String algoUrl = 'http://192.168.0.107:8083';
  
  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
  ));
  
  // 视频流
  Future<List<VideoModel>> getVideoFeed({
    int offset = 0,
    int count = 10,
    int sortType = 0,
  }) async {
    try {
      final response = await dio.get(
        '/post/video/feed',
        queryParameters: {
          'offset': offset,
          'count': count,
          'sort_type': sortType,
        },
      );
      
      return (response.data['data'] as List)
          .map((e) => VideoModel.fromJson(e))
          .toList();
    } catch (e) {
      throw ApiException('Failed to fetch video feed: $e');
    }
  }
  
  // 点赞视频
  Future<void> likeVideo(String videoId) async {
    await dio.post('/post/video/$videoId/like');
  }
  
  // 取消点赞
  Future<void> unlikeVideo(String videoId) async {
    await dio.post('/post/video/$videoId/unlike');
  }
  
  // 用户登录
  Future<LoginResponse> login(String uid, String password) async {
    final formData = FormData.fromMap({
      'uid': uid,
      'password': password,
      'mode': 'login',
    });
    
    final response = await dio.post('/user/login', data: formData);
    return LoginResponse.fromJson(response.data);
  }
  
  // 获取用户信息
  Future<UserModel> getUserInfo() async {
    final response = await dio.get('/user/userinfo');
    return UserModel.fromJson(response.data);
  }
}
```

**错误处理**:
```dart
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  
  @override
  String toString() => message;
}

// 拦截器示例
dio.interceptors.add(
  InterceptorsWrapper(
    onError: (e, handler) {
      if (e.response?.statusCode == 401) {
        // 处理未授权
        authService.logout();
      }
      return handler.next(e);
    },
  ),
);
```

---

## 状态管理转换

### Vue Pinia Store

```typescript
// src/store/pinia.ts
export const useBaseStore = defineStore('base', {
  state: () => {
    return {
      bodyHeight: 0,
      bodyWidth: 0,
      userinfo: { /*...*/ },
      loading: false,
      maskDialog: false,
    }
  },
  
  getters: {
    selectFriends() {
      return this.friends.all.filter((v) => v.select)
    }
  },
  
  actions: {
    setMaskDialog(state: any) {
      this.maskDialog = state.state
      this.maskDialogMode = state.mode
    },
    
    async fetchUserInfo() {
      const data = await userinfo()
      this.userinfo = data
    }
  }
})
```

### Flutter GetX Controller

```dart
// lib/controllers/app_controller.dart
import 'package:get/get.dart';

class AppController extends GetxController {
  // Reactive variables
  final bodyHeight = 0.0.obs;
  final bodyWidth = 0.0.obs;
  final isLoading = false.obs;
  final userInfo = UserModel().obs;
  
  final friends = <UserModel>[].obs;
  
  // Getters
  List<UserModel> get selectFriends {
    return friends.where((u) => u.isSelected).toList();
  }
  
  // Methods
  void setMaskDialog({required bool state, required String mode}) {
    Get.defaultDialog(
      // ... dialog configuration
    );
  }
  
  Future<void> fetchUserInfo() async {
    try {
      isLoading.value = true;
      final data = await apiService.getUserInfo();
      userInfo.value = data;
    } finally {
      isLoading.value = false;
    }
  }
  
  void updateUser(UserModel user) {
    userInfo.value = user;
  }
}

// 在页面中使用
class MyPage extends StatelessWidget {
  final controller = Get.find<AppController>();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => controller.isLoading.value
            ? CircularProgressIndicator()
            : UserProfile(user: controller.userInfo.value),
      ),
    );
  }
}
```

### 本地存储示例

```dart
class StorageService {
  static const String userKey = 'user_info';
  static const String tokenKey = 'auth_token';
  
  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, jsonEncode(user.toJson()));
  }
  
  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(userKey);
    if (json == null) return null;
    return UserModel.fromJson(jsonDecode(json));
  }
  
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }
  
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }
}
```

---

## 路由系统转换

### Vue Router

```typescript
// src/router/routes.ts
const routes: RouteRecordRaw[] = [
  { path: '/', redirect: '/home' },
  { path: '/home', component: Home },
  { path: '/me', component: Me },
  { path: '/me/edit-userinfo', component: EditUserInfo },
  { path: '/message', component: Message },
  { path: '/shop', component: Shop },
  { path: '/login', component: LoginRegister },
]
```

### Flutter Navigator 2.0 (go_router)

```dart
// lib/config/routes.dart
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => '/home',
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      path: '/me',
      builder: (context, state) => MePage(),
      routes: [
        GoRoute(
          path: 'edit-userinfo',
          builder: (context, state) => EditUserInfoPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/message',
      builder: (context, state) => MessagePage(),
    ),
    GoRoute(
      path: '/shop',
      builder: (context, state) => ShopPage(),
    ),
  ],
);

// 在 main.dart 中使用
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'Douyin Flutter',
    );
  }
}

// 页面跳转
context.push('/me/edit-userinfo');
context.go('/home');
```

---

## 工具函数转换

### 常用工具函数映射

| Vue 工具 | Flutter 等价 |
|---------|-------------|
| `formatDate(date, format)` | `DateFormat` (intl package) |
| `getAvatarByUserId(id)` | 自定义 `AvatarHelper` 类 |
| `debounce()` | `Timer` 或 `throttle` |
| `throttle()` | `Timer` 或自定义实现 |
| `urlToBase64()` | `Image.file().readAsBytes()` |
| `deepClone()` | `copyWith()` 或 JSON 序列化 |
| `bytesToSize()` | 自定义格式化函数 |

**示例实现**:

```dart
// lib/utils/helpers.dart
class FormatHelper {
  static String bytesToSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    const factor = 1024;
    var index = 0;
    var size = bytes.toDouble();
    
    while (size > factor && index < suffixes.length - 1) {
      size /= factor;
      index++;
    }
    
    return "${size.toStringAsFixed(2)} ${suffixes[index]}";
  }
  
  static String formatDate(DateTime date, {String format = 'yyyy-MM-dd'}) {
    return DateFormat(format, 'zh_CN').format(date);
  }
  
  static String getAvatarByUserId(String userId) {
    // 根据userId获取头像URL或从本地集合中轮询
    final index = userId.hashCode % 28;
    return 'assets/images/avatar/$index.png';
  }
}

// 防抖函数
class Debounce {
  Timer? _timer;
  
  void call(Duration duration, VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(duration, callback);
  }
  
  void cancel() => _timer?.cancel();
}

// 使用
final debounce = Debounce();
TextField(
  onChanged: (value) {
    debounce(Duration(milliseconds: 300), () {
      _searchVideos(value);
    });
  },
)
```

---

## CSS 样式转换

### Vue CSS

```vue
<style scoped>
.video-wrapper {
  width: 100%;
  height: 100vh;
  background: linear-gradient(45deg, #FF6B6B, #4ECDC4);
  position: fixed;
  top: 0;
  left: 0;
  z-index: 10;
}

.video-wrapper.playing {
  opacity: 1;
}

.progress {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: rgba(0, 0, 0, 0.3);
}

@media (max-width: 768px) {
  .video-wrapper {
    height: 100%;
  }
}
</style>
```

### Flutter 样式

```dart
class VideoWrapper extends StatelessWidget {
  final bool isPlaying;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6B6B),
            Color(0xFF4ECDC4),
          ],
        ),
      ),
      child: Stack(
        children: [
          // 视频内容
          Positioned.fill(
            child: Opacity(
              opacity: isPlaying ? 1.0 : 0.5,
              child: VideoPlayerWidget(),
            ),
          ),
          
          // 进度条
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              color: Colors.black.withOpacity(0.3),
              child: LinearProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}

// 响应式设计
class ResponsiveBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 768;
    
    return Container(
      width: isMobile ? size.width : 300,
      height: isMobile ? size.height : 600,
    );
  }
}
```

---

## TypeScript 类型转换

### 用户模型

```typescript
// Vue: src/models/user.ts
interface User {
  nickname: string
  unique_id: string
  desc: string
  signature: string
  avatar_168x168: { url_list: string[] }
  avatar_300x300: { url_list: string[] }
  cover_url: Array<{ url_list: string[] }>
  province: string
  city: string
  gender: string
}
```

```dart
// Flutter: lib/models/user_model.dart
class UserModel {
  final String nickname;
  final String uniqueId;
  final String desc;
  final String signature;
  final AvatarInfo avatar168x168;
  final AvatarInfo avatar300x300;
  final List<CoverInfo> coverUrl;
  final String province;
  final String city;
  final String gender;
  
  UserModel({
    required this.nickname,
    required this.uniqueId,
    required this.desc,
    required this.signature,
    required this.avatar168x168,
    required this.avatar300x300,
    required this.coverUrl,
    required this.province,
    required this.city,
    required this.gender,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      nickname: json['nickname'] ?? '',
      uniqueId: json['unique_id'] ?? '',
      desc: json['desc'] ?? '',
      signature: json['signature'] ?? '',
      avatar168x168: AvatarInfo.fromJson(json['avatar_168x168']),
      avatar300x300: AvatarInfo.fromJson(json['avatar_300x300']),
      coverUrl: (json['cover_url'] as List?)
          ?.map((e) => CoverInfo.fromJson(e))
          .toList() ?? [],
      province: json['province'] ?? '',
      city: json['city'] ?? '',
      gender: json['gender'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() => {
    'nickname': nickname,
    'unique_id': uniqueId,
    'desc': desc,
    'signature': signature,
    'avatar_168x168': avatar168x168.toJson(),
    'avatar_300x300': avatar300x300.toJson(),
    'cover_url': coverUrl.map((e) => e.toJson()).toList(),
    'province': province,
    'city': city,
    'gender': gender,
  };
}

class AvatarInfo {
  final List<String> urlList;
  
  AvatarInfo({required this.urlList});
  
  factory AvatarInfo.fromJson(Map<String, dynamic> json) {
    return AvatarInfo(
      urlList: List<String>.from(json['url_list'] ?? []),
    );
  }
  
  Map<String, dynamic> toJson() => {'url_list': urlList};
}

class CoverInfo {
  final List<String> urlList;
  
  CoverInfo({required this.urlList});
  
  factory CoverInfo.fromJson(Map<String, dynamic> json) {
    return CoverInfo(
      urlList: List<String>.from(json['url_list'] ?? []),
    );
  }
  
  Map<String, dynamic> toJson() => {'url_list': urlList};
}
```

### 视频模型

```dart
// lib/models/video_model.dart
class VideoModel {
  final String videoId;
  final List<String> playUrl;
  final String poster;
  final String title;
  final String desc;
  final UserModel author;
  final int commentCount;
  final int likeCount;
  final int shareCount;
  final int createTime;
  final bool liked;
  
  VideoModel({
    required this.videoId,
    required this.playUrl,
    required this.poster,
    required this.title,
    required this.desc,
    required this.author,
    this.commentCount = 0,
    this.likeCount = 0,
    this.shareCount = 0,
    required this.createTime,
    this.liked = false,
  });
  
  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      videoId: json['video_id'] ?? '',
      playUrl: (json['play_url'] is String)
          ? [json['play_url']]
          : List<String>.from(json['play_url'] ?? []),
      poster: json['poster'] ?? '',
      title: json['title'] ?? '',
      desc: json['desc'] ?? '',
      author: UserModel.fromJson(json['author'] ?? {}),
      commentCount: json['comment_count'] ?? 0,
      likeCount: json['like_count'] ?? 0,
      shareCount: json['share_count'] ?? 0,
      createTime: json['create_time'] ?? 0,
      liked: json['liked'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'video_id': videoId,
    'play_url': playUrl,
    'poster': poster,
    'title': title,
    'desc': desc,
    'author': author.toJson(),
    'comment_count': commentCount,
    'like_count': likeCount,
    'share_count': shareCount,
    'create_time': createTime,
    'liked': liked,
  };
  
  // copyWith 方法用于更新某些字段
  VideoModel copyWith({
    String? videoId,
    List<String>? playUrl,
    String? poster,
    String? title,
    String? desc,
    UserModel? author,
    int? commentCount,
    int? likeCount,
    int? shareCount,
    int? createTime,
    bool? liked,
  }) {
    return VideoModel(
      videoId: videoId ?? this.videoId,
      playUrl: playUrl ?? this.playUrl,
      poster: poster ?? this.poster,
      title: title ?? this.title,
      desc: desc ?? this.desc,
      author: author ?? this.author,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      shareCount: shareCount ?? this.shareCount,
      createTime: createTime ?? this.createTime,
      liked: liked ?? this.liked,
    );
  }
}
```

---

## 📋 转换检查清单

为每个模块检查以下项目:

- [ ] 所有数据模型已定义
- [ ] 所有API端点已实现
- [ ] 路由配置完成
- [ ] 状态管理已设置
- [ ] 页面已转换
- [ ] 组件已转换
- [ ] 工具函数已实现
- [ ] 样式已应用
- [ ] 功能测试通过
- [ ] 性能优化完成

---

**文档版本**: 1.0  
**最后更新**: 2026-02-16
