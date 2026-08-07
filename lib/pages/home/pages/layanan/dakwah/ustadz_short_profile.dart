import 'package:flutter/material.dart';
import 'package:puldapii/models/ustadz_model.dart';
import 'package:puldapii/pages/home/pages/dakwah_sdm/ustadz_profile.dart';
import 'package:puldapii/utils/services/home/ustadz_service.dart';

class UstadzShortProfile extends StatelessWidget {
  const UstadzShortProfile({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final service = UstadzService();

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.pop(context),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: FutureBuilder<UstadzModel>(
                future: service.getUstadzDetailByCode(code),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 220,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 36),
                        const SizedBox(height: 10),
                        Text(
                          'Gagal memuat profil:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    );
                  }

                  final profile = snapshot.data!;
                  final roles = profile.roles; // List<UstadzRole>

                  final nama = (profile.name ?? '').trim();
                  final gelar = (profile.title ?? '').trim();

                  final namaLengkap = [
                    if (nama.isNotEmpty) nama,
                    if (gelar.isNotEmpty) gelar,
                  ].join(' ').trim();

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipOval(child: _buildImage(profile.imageUrl ?? '')),
                      const SizedBox(height: 12),

                      // Nama
                      Text(
                        namaLengkap.isEmpty ? '-' : namaLengkap,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      if (roles.isNotEmpty)
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          children: roles.map((role) {
                            final roleName = (role.name ?? '').trim();
                            final isAvailable =
                                role.pivot?.isAvailable ??
                                1; // default anggap available
                            final isOff = isAvailable == 0;

                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isOff
                                    ? const Color.fromRGBO(
                                        255,
                                        0,
                                        0,
                                        0.18,
                                      ) // merah soft
                                    : const Color.fromRGBO(148, 226, 210, 0.35),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isOff
                                      ? const Color.fromRGBO(255, 0, 0, 0.45)
                                      : const Color.fromRGBO(
                                          148,
                                          226,
                                          210,
                                          0.6,
                                        ),
                                ),
                              ),
                              child: Text(
                                roleName.isEmpty ? '-' : roleName,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isOff
                                      ? const Color.fromRGBO(160, 0, 0, 1)
                                      : null,
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 14),

                      // Contact
                      _infoItem(
                        icon: Icons.phone,
                        label: 'No. Kontak',
                        value: '(Silahkan Hubungi Admin)',
                      ),
                      _divider(),

                      // Email
                      _infoItem(
                        icon: Icons.email,
                        label: 'Email',
                        value: profile.email ?? '',
                      ),

                      const SizedBox(height: 14),

                      // Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(
                              68,
                              174,
                              183,
                              1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.pop(context); // tutup dialog
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    UstadzDetailPage(ustadz: profile),
                              ),
                            );
                          },
                          child: const Text(
                            'Lihat Detail',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    final url = imageUrl.trim();

    if (url.isEmpty) {
      return Image.asset(
        'assets/images/dakwahImgDefault.png',
        width: 90,
        height: 90,
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      url,
      width: 90,
      height: 90,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(
        'assets/images/dakwahImgDefault.png',
        width: 90,
        height: 90,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _infoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final v = value.trim().isEmpty ? '-' : value.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: const Color.fromRGBO(68, 174, 183, 1)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 2),
                Text(v, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Divider(color: Colors.grey.shade300, thickness: 1, height: 1);
}
