import 'package:http/http.dart' as http;

class UnoToFlaskService {
  Future<http.Response> fetchAlbum() {
    var response = http.get(Uri.parse('http://192.168.1.10:5000'));
    print("Response");
    print(response.then((data) => {print(data.body), print(data.statusCode)}));
    return http.get(Uri.parse('http://192.168.1.10:5000'));
  }
}
