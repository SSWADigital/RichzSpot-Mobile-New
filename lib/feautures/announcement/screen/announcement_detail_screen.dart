import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../widgets/announcement_info_row.dart';

class AnnouncementDetailScreen extends StatelessWidget {
  final Map<String, dynamic> announcement;

  const AnnouncementDetailScreen({Key? key, required this.announcement}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String imageUrl = announcement['berita_foto'] ??
        'https://cdn.builder.io/api/v1/image/assets/TEMP/f770349de31204b642cbd0d3354ee779bdfbb80a?placeholderIfAbsent=true&apiKey=5cfd598a63bc427284be972a709d3cb8'; // Default image if null
    final String title = announcement['berita_judul'] ?? 'No Title';
    final String keterangan = announcement['berita_keterangan'] ?? 'No Description';
    final String updateDate = announcement['berita_when_update'] ?? 'N/A';

    return Material(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // Full Width Banner Image with Gradient Overlay
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.width / 1.33, // Adjusted height for a fuller image
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => const Center(child: Icon(Icons.image_not_supported)),
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.1),
                              Colors.black.withOpacity(0.6),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 156, 24, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                height: 1.33,
                              ),
                            ),
                            const SizedBox(height: 11),
                            Text(
                              updateDate,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 30,
                        left: 16,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Content Card
                // Positioned(
                //   left: 0,
                //   right: 0,
                //   bottom: 84,
                //   child: Container(
                //     margin: const EdgeInsets.symmetric(horizontal: 20),
                //     decoration: BoxDecoration(
                //       color: Colors.white,
                //       borderRadius: const BorderRadius.vertical(
                //         top: Radius.circular(24),
                //       ),
                //       boxShadow: [
                //         BoxShadow(
                //           color: Colors.black.withOpacity(0.1),
                //           blurRadius: 10,
                //           offset: const Offset(0, -5),
                //         ),
                //       ],
                //     ),
                //     child: Padding(
                //       padding: const EdgeInsets.fromLTRB(24, 24, 24, 32), // Reduced bottom padding
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           AnnouncementInfoRow(announcement: announcement), // You might need to adapt this to use announcement data
                //           const SizedBox(height: 32),
                //           Text(
                //             keterangan,
                //             style: const TextStyle(
                //               fontSize: 15,
                //               color: Color(0xFF333333),
                //               height: 1.6,
                //             ),
                //           ),
                //           // You can parse the keterangan and display bullet points if needed
                //           // This example assumes the keterangan is plain text
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
             
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                keterangan, // Display full keterangan below the card for longer content
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF333333),
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF333333),
              height: 1.6,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF333333),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}