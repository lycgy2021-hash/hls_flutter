class Endpoints {
  const Endpoints._();

  static const String userLogin = '/user/login';
  static const String userInfo = '/user/userinfo';
  static const String userVideoList = '/user/video_list';
  static const String userPanel = '/user/panel';
  static const String userFriends = '/user/friends';
  static const String userCollect = '/user/collect';
  static const String userFollowers = '/user/followers';
  static const String userFollow = '/user/follow';
  static const String userVisitors = '/user/visitors';
  static const String userVideoListByUpid = '/user/video_list_by_upid';

  static const String postRecommended = '/post/recommended';
  static const String postRecommendedByUpid = '/post/recommended/by-upid';
  static const String postRecommendedList = '/post/recommended/list';

  static const String apiNext = '/api/next';
  static const String apiHistory = '/api/history';
  static const String apiSessionState = '/api/session_state';
  static const String apiAck = '/api/ack';
  static const String apiAction = '/api/action';

  static const String videoLike = '/video/like';
  static const String videoCollect = '/video/collect';
  static const String videoComments = '/video/comments';

  static const String messageList = '/message/list';
  static const String messageConversations = '/message/conversations';
  static const String messageMarkRead = '/message/mark-read';
  static const String messageSend = '/message/send';

  static const String groupList = '/group/list';

  static String groupDetail(String groupId) => '/group/$groupId';
  static String groupMembers(String groupId) => '/group/$groupId/members';
  static String groupLeave(String groupId) => '/group/$groupId/leave';
  static String groupMessages(String groupId) => '/group/$groupId/messages';
}
