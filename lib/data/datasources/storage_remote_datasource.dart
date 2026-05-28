// lib/data/datasources/storage_remote_datasource.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

abstract class StorageRemoteDataSource {
  /// Mengunggah banyak foto bukti keluhan pelanggan ke server ImgBB API secara bersamaan.
  /// Mengembalikan daftar list URL digital String.
  Future<List<String>> uploadMultipleComplaintImages({required List<File> imageFiles});
}

@LazySingleton(as: StorageRemoteDataSource)
class StorageRemoteDataSourceImpl implements StorageRemoteDataSource {
  final String _imgBbApiKey = const String.fromEnvironment('IMGBB_API_KEY');

  @override
  Future<List<String>> uploadMultipleComplaintImages({required List<File> imageFiles}) async {
    if (_imgBbApiKey.isEmpty) {
      throw Exception('Konfigurasi Gagal: API Key ImgBB belum disuntikkan ke dalam aplikasi!');
    }

    // Menggunakan Future.wait agar proses upload berjalan paralel (bersamaan) demi menghemat durasi loading
    final uploadFutures = imageFiles.map((file) async {
      try {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('https://api.imgbb.com/1/upload?key=$_imgBbApiKey'),
        );

        request.files.add(await http.MultipartFile.fromPath('image', file.path));

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          return responseData['data']['url'] as String;
        } else {
          throw Exception('Server ImgBB menolak berkas: ${response.body}');
        }
      } catch (e) {
        throw Exception('Gagal mengunggah gambar ${file.path}: $e');
      }
    }).toList();

    // Menunggu seluruh request selesai bersamaan
    return await Future.wait(uploadFutures);
  }
}