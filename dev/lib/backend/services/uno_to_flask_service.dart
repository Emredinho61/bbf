import 'package:http/http.dart' as http;

class UnoToFlaskService {
  Future<http.Response> fetchAlbum() {
    return http.get(Uri.parse('http://192.168.1.10:5000'));
  }
}
