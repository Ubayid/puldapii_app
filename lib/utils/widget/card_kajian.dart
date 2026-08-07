import 'package:flutter/material.dart';
import 'package:puldapii/models/dakwah_model.dart';
import 'package:puldapii/pages/home/pages/layanan/dakwah/ustadz_short_profile.dart';
import 'package:puldapii/pages/home/pages/layanan/dakwah/kajian_detail.dart';
import 'package:puldapii/utils/helper/format_date.dart';

Widget dakwahItemFromApi(DakwahModel d, BuildContext context) {
  // dari API: d.ustadz?.image bisa berupa URL atau path/asset string.
  final imgUrl = d.ustadz?.imageUrl ?? '';

  final tags = (d.tags); // pastikan model kamu punya d.tags

  final Widget avatar = (imgUrl.isNotEmpty)
      ? Image.network(
          imgUrl,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/images/dakwahImgDefault.png',
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        )
      : Image.asset(
          'assets/images/dakwahImgDefault.png',
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        );

  return GestureDetector(
    onTap: () => _openKajianDetail(context, d),
    child: Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 6),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage('assets/images/dakwahItemBg.png'),
          fit: BoxFit.cover,
          alignment: Alignment.topRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  final code = (d.ustadzCode).trim();
                  if (code.isNotEmpty) _openDakwahProfile(context, code);
                },
                child: ClipOval(child: avatar),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      d.ustadz?.name ?? '-',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.date_range,
                          size: 12,
                          color: Color.fromRGBO(68, 174, 183, 1),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formatTanggalIndo(d.date),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.watch_later_outlined,
                          size: 12,
                          color: Color.fromRGBO(68, 174, 183, 1),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          d.islamicDate,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(
            color: Colors.grey.shade600,
            thickness: 0.2,
            indent: 0.2,
            endIndent: 0.2,
          ),
          Row(
            children: [
              Expanded(
                child: tags.isEmpty
                    ? Text(
                        '',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      )
                    : Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          ...tags.take(3).map((t) => _tagChip(t.name)),
                          if (tags.length > 3) _tagChip('+${tags.length - 3}'),
                        ],
                      ),
              ),
              const SizedBox(width: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 12,
                    color: Color.fromRGBO(68, 174, 183, 1),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    d.location,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

void _openDakwahProfile(BuildContext context, String code) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (_, __, ___) {
      return UstadzShortProfile(code: code);
    },
    transitionBuilder: (_, animation, __, child) {
      return Transform.scale(
        scale: animation.value,
        child: Opacity(opacity: animation.value, child: child),
      );
    },
  );
}

void _openKajianDetail(BuildContext context, DakwahModel d) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => KajianDetailPage(d: d)),
  );
}

Widget _tagChip(String text) {
  const primary = Color.fromRGBO(68, 174, 183, 1);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: primary.withOpacity(0.12),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: primary.withOpacity(0.35)),
    ),
    child: Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 8,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
    ),
  );
}
