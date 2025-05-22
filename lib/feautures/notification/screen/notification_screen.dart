import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:richzspot/core/constant/app_colors.dart';
import 'package:richzspot/feautures/notification/model/notification_model.dart';
import 'package:richzspot/feautures/notification/service/notification_service.dart';
import 'package:intl/intl.dart';
import 'package:richzspot/feautures/notification/widgets/notification_items.dart';
import 'package:richzspot/shared/widgets/show_messages.dart';
import 'package:richzspot/main.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  List<NotificationModel> _allNotifications = [];
  List<NotificationModel> _filteredNotifications = [];
  bool _isLoading = true;
  String _filter = 'all'; // Default filter
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _searchController.addListener(_onSearchChanged);
     notificationTypeNotifier.addListener(_handleNotificationRefresh);

  }

  @override
  void dispose() {
    _searchController.dispose();
    notificationTypeNotifier.removeListener(_handleNotificationRefresh);

    super.dispose();
  }


 void _handleNotificationRefresh() {
      _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
    });
    final notifications = await _notificationService.getNotifications();
    setState(() {
      _allNotifications = notifications;
      _filterNotifications(_filter, _searchController.text);
      _isLoading = false;
    });
  }

  void _filterNotifications(String filter, String searchText) {
    setState(() {
      _filter = filter;
      List<NotificationModel> tempNotifications = _allNotifications;

      if (filter == 'unread') {
        tempNotifications = tempNotifications.where((n) => !n.isRead).toList();
      } else if (filter == 'read') {
        tempNotifications = tempNotifications.where((n) => n.isRead).toList();
      }

      if (searchText.isNotEmpty) {
        searchText = searchText.toLowerCase();
        tempNotifications = tempNotifications.where((n) =>
            n.title.toLowerCase().contains(searchText) ||
            n.body.toLowerCase().contains(searchText)).toList();
      }

      _filteredNotifications = tempNotifications;
    });
  }

  void _onSearchChanged() {
    _filterNotifications(_filter, _searchController.text);
  }

  Future<void> _markAsRead(int notificationId) async {
    final success = await _notificationService.markAsRead(notificationId);
    if (success) {
      setState(() {
        final index = _allNotifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _allNotifications[index] = _allNotifications[index].copyWith(isRead: true);
        }
        _filterNotifications(_filter, _searchController.text); // Re-filter
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to mark as read')),
      );
    }
  }

  Future<void> _deleteNotification(int notificationId) async {
    final success = await _notificationService.deleteNotification(notificationId);
    if (success) {
      setState(() {
        _allNotifications.removeWhere((n) => n.id == notificationId);
        _filterNotifications(_filter, _searchController.text); // Re-filter
      });
      ShowMessage.successNotification(
        'Notification deleted successfully',
        context,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete notification')),
      );
    }
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.backgroundColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppColors.defaultPadding,
              vertical: AppColors.defaultPadding,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.borderColor,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: GoogleFonts.inter(
                    textStyle: AppColors.headerStyle,
                  ),
                ),
                const SizedBox(height: AppColors.smallSpacing),
                TextField(
                  controller: _searchController,
                  style: GoogleFonts.inter(textStyle: AppColors.descriptionStyle),
                  decoration: InputDecoration(
                    hintText: 'Search notifications...',
                    hintStyle: GoogleFonts.inter(textStyle: AppColors.inputTextStyle),
                    prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: AppColors.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: AppColors.primaryBlue),
                    ),
                  ),
                ),
                const SizedBox(height: AppColors.smallSpacing),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _filterNotifications('unread', _searchController.text),
                      child: Text(
                        'Unread',
                        style: TextStyle(
                          color: _filter == 'unread' ? AppColors.primaryBlue : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _filterNotifications('read', _searchController.text),
                      child: Text(
                        'Read',
                        style: TextStyle(
                          color: _filter == 'read' ? AppColors.primaryBlue : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _filterNotifications('all', _searchController.text),
                      child: Text(
                        'All',
                        style: TextStyle(
                          color: _filter == 'all' ? AppColors.primaryBlue : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(
                    color: AppColors.primaryBlue,
                ))
                : _filteredNotifications.isEmpty
                    ? Center(child: Text('No $_filter notifications found.'))
                    : SingleChildScrollView(
                        child: Column(
                          children: _filteredNotifications.map((notification) {
                            IconData iconData;
                            Color iconColor;

                            switch (notification.type) {
                              case 'pengajuan':
                                iconData = Icons.assignment;
                                iconColor = AppColors.primaryBlue;
                                break;
                              case 'pengumuman':
                                iconData = Icons.announcement;
                                iconColor = AppColors.successGreen;
                                break;
                              case 'test':
                                iconData = Icons.check_circle_outline;
                                iconColor = AppColors.accent;
                                break;
                              default:
                                iconData = Icons.notifications;
                                iconColor = AppColors.textTertiary;
                            }

                            return Dismissible(
                              key: Key(notification.id.toString()),
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: AppColors.defaultPadding),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {
                                _deleteNotification(notification.id);
                              },
                              child: NotificationItem(
                                icon: iconData,
                                iconColor: iconColor,
                                title: notification.title,
                                description: notification.body,
                                timeAgo: _timeAgo(notification.createdAt),
                                isUnread: !notification.isRead,
                                onTap: () {
                                  _markAsRead(notification.id);
                                  print('Tapped notification: ${notification.id}');
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}