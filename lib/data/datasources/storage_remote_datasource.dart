// lib/data/datasources/storage_remote_datasource.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http; // Memuat client http multipart
import 'package:injectable/injectable.dart';

abstract class StorageRemoteDataSource {
  /// Mengunggah foto bukti keluhan pelanggan ke server ImgBB API.
  Future<String> uploadComplaintImage({required String customerUid, required File imageFile});
}

@LazySingleton(as: StorageRemoteDataSource)
class StorageRemoteDataSourceImpl implements StorageRemoteDataSource {
  
  // SOLUSI KEAMANAN: Membaca API Key dari environment compile-time.
  // Token rahasia tidak ditulis hardcode di sini sehingga aman dari commit GitHub!
  final String _imgBbApiKey = const String.fromEnvironment('IMGBB_API_KEY');

  @override
  Future<String> uploadComplaintImage({required String customerUid, required File imageFile}) async {
    // Proteksi awal jika kamu lupa memasukkan token saat running aplikasi
    if (_imgBbApiKey.isEmpty) {
      throw Exception('Konfigurasi Gagal: API Key ImgBB belum disuntikkan ke dalam aplikasi!');
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.imgbb.com/1/upload?key=$_imgBbApiKey'),
      );

      // Memasukkan berkas gambar fisik dari kamera/galeri HP
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        // Mengambil string download URL langsung dari skema json respon ImgBB
        final String downloadUrl = responseData['data']['url'];
        return downloadUrl;
      } else {
        throw Exception('Server ImgBB menolak unggahan bukti: ${response.body}');
      }
    } catch (e) {
      throw Exception('Gagal melakukan unggah gambar keluhan via HTTP: $e');
    }
  }
}