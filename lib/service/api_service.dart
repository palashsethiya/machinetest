import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:machinetest/model/SuccessModel.dart';
import 'package:machinetest/service/cert_reader.dart';

class ApiService {
  static const baseUrl = "https://uat-nftbe.metaspacechain.com/nftmarketplace/api/v1";

  Future<SuccessModel> callAPIUsingSSL() async {
    final http.Client client = await getSSLPinningClient();
    final uri = Uri.parse('$baseUrl/test/get_all_nfts');
    final response = await client.get(uri);
    print("Response ${response.body}");
    if (response.statusCode == 200) {
      return SuccessModel.fromJson(json.decode(response.body));
    } else {
      throw Error();
    }
  }
}
