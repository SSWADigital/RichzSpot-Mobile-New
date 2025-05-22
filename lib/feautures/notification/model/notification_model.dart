import 'dart:convert';

class NotificationModel {
  final int id;
  final String? userId;
  final String title;
  final String body;
  final String type;
  final String? action;
  final String? menu;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final String? departemenId;
  final String? recipientUserId;

  NotificationModel({
    required this.id,
    this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.action,
    this.menu,
    this.data,
    required this.isRead,
    required this.createdAt,
    this.departemenId,
    this.recipientUserId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    dynamic decodedData;
    if (json['data'] != null) {
      try {
        decodedData = jsonDecode(json['data']);
      } catch (e) {
        print('Error decoding data: $e');
        decodedData = null;
      }
    }

    Map<String, dynamic>? finalData;
    if (decodedData is Map<String, dynamic>) {
      finalData = decodedData;
    } else if (decodedData is List) {
      // Jika data adalah list, Anda mungkin ingin mengambil elemen pertama atau
      // melakukan logika lain sesuai dengan struktur data notifikasi Anda.
      // Contoh: mengambil elemen pertama jika diharapkan hanya ada satu objek di dalamnya.
      finalData = decodedData.isNotEmpty ? decodedData.first as Map<String, dynamic>? : null;
      // Atau, jika Anda mengharapkan list, Anda bisa mengubah tipe 'data' di model.
      print('Warning: Data is a List: $decodedData');
    } else {
      finalData = null;
    }

    return NotificationModel(
      id: int.parse(json['id'].toString()),
      userId: json['user_id']?.toString(),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? '',
      action: json['action']?.toString(),
      menu: json['menu']?.toString(),
      data: finalData,
      isRead: json['is_read'] == 't' || json['is_read'] == true,
      createdAt: DateTime.parse(json['created_at']),
      departemenId: json['departemen_id']?.toString(),
      recipientUserId: json['reciepent_user_id']?.toString(),
    );
  }
  NotificationModel copyWith({
    int? id,
    String? userId,
    String? title,
    String? body,
    String? type,
    String? action,
    String? menu,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    String? departemenId,
    String? recipientUserId,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      action: action ?? this.action,
      menu: menu ?? this.menu,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      departemenId: departemenId ?? this.departemenId,
      recipientUserId: recipientUserId ?? this.recipientUserId,
    );
  }
}