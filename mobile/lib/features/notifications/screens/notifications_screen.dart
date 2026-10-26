import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unify/core/routes/route_names.dart';
import 'package:unify/core/services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];
  String _filter = 'ALL'; // ALL, UNREAD, APPLICATION

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getNotifications();
      if (response.statusCode == 200 && response.data['success'] == true) {
        final list = (response.data['data'] as List<dynamic>?) ?? [];
        setState(() {
          _notifications = list.map((e) => Map<String, dynamic>.from(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      await _apiService.markNotificationAsRead(id);
      setState(() {
        final idx = _notifications.indexWhere((n) => n['id'] == id);
        if (idx != -1) {
          _notifications[idx]['isRead'] = true;
        }
      });
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _apiService.markAllNotificationsAsRead();
      setState(() {
        for (final n in _notifications) {
          n['isRead'] = true;
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications marked as read'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return 'Recently';
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return 'Recently';
    }
  }

  Color _getBadgeColor(String? type) {
    switch (type) {
      case 'APPLICATION_ACCEPTED':
        return const Color(0xFF10B981);
      case 'APPLICATION_SHORTLISTED':
        return const Color(0xFF6366F1);
      case 'APPLICATION_REJECTED':
        return const Color(0xFFEF4444);
      case 'NEW_MATCH':
        return const Color(0xFFF59E0B);
      case 'RESUME_VERIFIED':
        return const Color(0xFF0EA5E9);
      default:
        return const Color(0xFF4F46E5);
    }
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'APPLICATION_ACCEPTED':
        return Icons.verified_rounded;
      case 'APPLICATION_SHORTLISTED':
        return Icons.stars_rounded;
      case 'APPLICATION_REJECTED':
        return Icons.cancel_outlined;
      case 'NEW_MATCH':
        return Icons.auto_awesome_rounded;
      case 'RESUME_VERIFIED':
        return Icons.shield_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => n['isRead'] == false).length;

    final filteredList = _notifications.where((n) {
      if (_filter == 'UNREAD') return n['isRead'] == false;
      if (_filter == 'APPLICATION') {
        final t = n['type'] as String? ?? '';
        return t.startsWith('APPLICATION');
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all_rounded, size: 16, color: Color(0xFF4F46E5)),
              label: const Text(
                'Read all',
                style: TextStyle(
                  color: Color(0xFF4F46E5),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                _buildFilterChip('All', 'ALL', _notifications.length),
                const SizedBox(width: 8),
                _buildFilterChip('Unread', 'UNREAD', unreadCount),
                const SizedBox(width: 8),
                _buildFilterChip('Applications', 'APPLICATION', null),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          // List content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                  )
                : filteredList.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _fetchNotifications,
                        color: const Color(0xFF4F46E5),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          itemCount: filteredList.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = filteredList[index];
                            final id = item['id'] as int;
                            final isRead = item['isRead'] == true;
                            final type = item['type'] as String? ?? 'SYSTEM';
                            final title = item['title'] as String? ?? 'Notification';
                            final message = item['message'] as String? ?? '';
                            final createdAt = item['createdAt'] as String?;
                            final badgeColor = _getBadgeColor(type);

                            return InkWell(
                              onTap: () {
                                if (!isRead) _markAsRead(id);
                                if (type.startsWith('APPLICATION')) {
                                  context.push(RouteNames.opportunities, extra: {'initialTab': 1});
                                }
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isRead ? Colors.white : const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isRead ? const Color(0xFFE2E8F0) : const Color(0xFFC7D2FE),
                                    width: isRead ? 1 : 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: badgeColor.withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        _getIcon(type),
                                        size: 20,
                                        color: badgeColor,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  title,
                                                  style: TextStyle(
                                                    fontWeight: isRead ? FontWeight.w600 : FontWeight.w700,
                                                    fontSize: 14,
                                                    color: const Color(0xFF1E293B),
                                                  ),
                                                ),
                                              ),
                                              if (!isRead)
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  margin: const EdgeInsets.only(left: 6),
                                                  decoration: const BoxDecoration(
                                                    color: Color(0xFF4F46E5),
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            message,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF475569),
                                              height: 1.35,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                _formatTime(createdAt),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF94A3B8),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              if (type.startsWith('APPLICATION'))
                                                const Row(
                                                  children: [
                                                    Text(
                                                      'View Application',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Color(0xFF4F46E5),
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    SizedBox(width: 2),
                                                    Icon(
                                                      Icons.arrow_forward_ios_rounded,
                                                      size: 10,
                                                      color: Color(0xFF4F46E5),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, int? count) {
    final isSelected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
            if (count != null && count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withValues(alpha: 0.25) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 48,
                color: Color(0xFF4F46E5),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Notifications',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You are all caught up! Updates regarding your job applications, profile reviews, and matching roles will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
