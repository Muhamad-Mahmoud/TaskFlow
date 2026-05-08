class ApiPaths {
	static const auth = '/api/v1/Auth';
	static const usersMe = '/api/v1/users/me';
	static const usersSearch = '/api/v1/users/search';
	static const projects = '/api/v1/projects';
	static String project(String id) => '$projects/$id';
	static String projectStats(String id) => '$projects/$id/stats';
	static String projectMembers(String id) => '$projects/$id/members';
	static String projectMember(String id, String uid) => '$projects/$id/members/$uid';
	static String projectTasks(String id) => '$projects/$id/tasks';
	static String projectAttachments(String id) => '$projects/$id/attachments';
	static const tasks = '/api/v1/tasks';
	static String task(String id) => '$tasks/$id';
	static String taskStatus(String id) => '$tasks/$id/status';
	static String taskPosition(String id) => '$tasks/$id/position';
	static String subtasks(String id) => '$tasks/$id/subtasks';
	static String subtask(String id, String sid) => '$tasks/$id/subtasks/$sid';
	static String comments(String id) => '$tasks/$id/comments';
	static String comment(String id, String cid) => '$tasks/$id/comments/$cid';
	static String taskAttachments(String id) => '$tasks/$id/attachments';
	static String taskAttachment(String id, String aid) => '$tasks/$id/attachments/$aid';
	static const tags = '/api/v1/tags';
	static String tag(String id) => '$tags/$id';
	static const notifications = '/api/v1/notifications';
	static String notification(String id) => '$notifications/$id';
	static String notificationRead(String id) => '$notifications/$id/read';
	static const notificationsReadAll = '$notifications/read-all';
	static const notificationsPushToken = '$notifications/push-token';
}

