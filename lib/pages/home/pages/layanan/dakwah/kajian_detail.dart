import 'package:flutter/material.dart';
import 'package:puldapii/models/dakwah_model.dart';
import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:puldapii/utils/widget/background.dart';
import 'package:puldapii/utils/helper/format_date.dart';
import 'package:puldapii/utils/widget/header.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class KajianDetailPage extends StatelessWidget {
  final DakwahModel d;

  const KajianDetailPage({super.key, required this.d});

  @override
  Widget build(BuildContext context) {
    final imgUrl = (d.ustadz?.imageUrl ?? '').trim();

    final Widget avatar = (imgUrl.isNotEmpty)
        ? Image.network(
            imgUrl,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Image.asset(
              'assets/images/dakwahImgDefault.png',
              width: 56,
              height: 56,
              fit: BoxFit.cover,
            ),
          )
        : Image.asset(
            'assets/images/dakwahImgDefault.png',
            width: 56,
            height: 56,
            fit: BoxFit.cover,
          );

    final locationText = (d.location).trim();

    final addressText = (d.locationAddress ?? '').trim();
    final lat = d.locationLat;
    final lng = d.locationLng;
    final hasCoord = lat != null && lng != null;

    return Scaffold(
      body: Column(
        children: [
          SecondaryHeader(
            title: "Detail Kajian",
            // centerTitle: true, // kalau mau title di tengah
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
            ],
          ),
          Expanded(
            child: GradientPage(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(height: 6),

                    // 1) Judul + Ustadz
                    _CardContainer(
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipOval(child: avatar),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      d.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: 14,
                                          color: Colors.grey.shade700,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            d.ustadz?.name ?? '-',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade700,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // SizedBox(height: 16),
                          // ProfileButton(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 2) Jadwal
                    _CardContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle(
                            icon: Icons.event,
                            title: 'Jadwal',
                          ),
                          const SizedBox(height: 10),
                          _InfoRow(
                            icon: Icons.date_range,
                            label: 'Tanggal',
                            value: formatTanggalIndo(d.date),
                          ),
                          const SizedBox(height: 8),
                          _InfoRow(
                            icon: Icons.access_time,
                            label: 'Waktu',
                            value: d.time,
                          ),
                          const SizedBox(height: 8),
                          _InfoRow(
                            icon: Icons.calendar_month,
                            label: 'Hijriah',
                            value: d.islamicDate,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 3) Deskripsi + Tags (Chip) + Description bg abu-abu
                    _CardContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle(
                            icon: Icons.description,
                            title: 'Deskripsi',
                          ),
                          const SizedBox(height: 10),

                          // TAGS CHIPS (di bawah title "Deskripsi")
                          if (d.tags.isNotEmpty)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: d.tags.map((t) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    t.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                );
                              }).toList(),
                            )
                          else
                            Text(
                              '-',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),

                          const SizedBox(height: 12),

                          // DESCRIPTION dengan background abu-abu
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              (d.description).trim().isEmpty
                                  ? '-'
                                  : d.description,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.5,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 4) Lokasi + map inline
                    _CardContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _SectionTitle(
                            icon: Icons.location_on,
                            title: 'Lokasi',
                          ),
                          const SizedBox(height: 10),

                          Text(
                            locationText.isEmpty ? '-' : locationText,
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.4,
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          if (addressText.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              addressText,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.4,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],

                          if (hasCoord) ...[
                            const SizedBox(height: 12),

                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                height: 180,
                                child: FlutterMap(
                                  options: MapOptions(
                                    initialCenter: LatLng(lat, lng),
                                    initialZoom: 16,

                                    // biar nyaman di dalam SingleChildScrollView (nggak “rebutan” scroll)
                                    interactionOptions:
                                        const InteractionOptions(
                                          flags:
                                              InteractiveFlag.drag |
                                              InteractiveFlag.pinchZoom,
                                        ),
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate:
                                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      userAgentPackageName:
                                          'com.puldapii.app', // ganti sesuai package kamu
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          point: LatLng(lat, lng),
                                          width: 44,
                                          height: 44,
                                          child: const Icon(
                                            Icons.location_pin,
                                            size: 44,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final uri = Uri.parse(
                                    'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
                                  );
                                  if (!await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                  )) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Gagal membuka Google Maps',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Icons.map_outlined,
                                  color: Color.fromRGBO(24, 100, 80, 1),
                                ),
                                label: const Text(
                                  'Buka di Google Maps',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(24, 100, 80, 1),
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  backgroundColor: const Color.fromRGBO(
                                    251,
                                    205,
                                    76,
                                    1,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 10),
                            Text(
                              'Koordinat belum tersedia',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final Widget child;
  const _CardContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color.fromRGBO(68, 174, 183, 1)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final v = value.trim().isEmpty ? '-' : value.trim();
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ),
        Expanded(
          child: Text(
            ': $v',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileButton extends StatelessWidget {
  const ProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Expanded(
        //   child: OutlinedButton.icon(
        //     onPressed: () => _addToCalendar(context, ),
        //     label: const Text(
        //       'Tambah ke Kalender',
        //       style: TextStyle(color: Colors.grey),
        //     ),
        //     style: OutlinedButton.styleFrom(
        //       padding: const EdgeInsets.symmetric(vertical: 12),
        //       overlayColor: Colors.grey,
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(12),
        //       ),
        //     ),
        //   ),
        // ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            label: const Text(
              'Daftar',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(24, 100, 80, 1),
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: const Color.fromRGBO(251, 205, 76, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

DateTime? _dateOnly(String isoDate) {
  final dt = DateTime.tryParse(isoDate.trim()); // "2024-05-20"
  if (dt == null) return null;
  return DateTime(dt.year, dt.month, dt.day);
}

void _addToCalendar(BuildContext context, DakwahModel d) {
  final start = _dateOnly(d.date);
  if (start == null) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tanggal kajian tidak valid')));
    return;
  }

  // all-day event: biasanya end = start + 1 hari
  final end = start.add(const Duration(days: 1));

  final event = Event(
    title: d.title,
    description:
        'Ustadz: ${d.ustadz?.name ?? "-"}\nTanggal Hijriah: ${d.islamicDate}\nJam: ${d.time}',
    location: d.location, // di model kamu namanya "location"
    startDate: start,
    endDate: end,
    allDay: true, // ✅ tanpa jam
  );

  Add2Calendar.addEvent2Cal(event);
}
