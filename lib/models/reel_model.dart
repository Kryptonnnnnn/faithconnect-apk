class ReelModel {
  final String id;
  final String videoUrl;
  final String leaderId;
  final String caption;
  final DateTime createdAt;

  ReelModel({
    required this.id,
    required this.videoUrl,
    required this.leaderId,
    required this.caption,
    required this.createdAt,
  });

  factory ReelModel.fromMap(String id, Map<String, dynamic> data) {
    return ReelModel(
      id: id,
      videoUrl: data['videoUrl'] as String,
      leaderId: data['leaderId'] as String,
      caption: data['caption'] as String,
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }
}