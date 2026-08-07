import 'package:dio/dio.dart';
import 'package:puldapii/config/api_client.dart';

class AppSettingService {
  final Dio dio;

  AppSettingService({Dio? dio}) : dio = dio ?? ApiClient.dio;

  Future<String?> getAdminWhatsapp() async {
    final response = await dio.get('/app-settings');

    final data = response.data;

    if (data is Map<String, dynamic>) {
      final settingData = data['data'];

      if (settingData is Map<String, dynamic>) {
        return settingData['admin_whatsapp']?.toString();
      }
    }

    return null;
  }
}
