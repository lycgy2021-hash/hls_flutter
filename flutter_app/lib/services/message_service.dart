class MessageService {
  const MessageService();

  // TODO(M4): Implement websocket/polling message flow compatible with Vue message APIs.
  // Safe fallback for now: feature explicitly unavailable, no crash path.
  String get unavailableReason => '消息功能将在 M4 交付（当前版本仅实现登录与视频流核心能力）';
}
