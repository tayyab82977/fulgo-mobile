class URL {
  static const String SERVICE_BASE_URL =
      "https://Fulgox.byte-s.com/api/mobile/";
  static const String LIVE_SERVER = "https://Fulgox.byte-s.com/api/mobile/";
  // static const String Anas_SERVER = "http:// 172.20.10.8:8000/api/mobile/";
  static const String Anas_SERVER = "http://127.0.0.1:8000/api/mobile/";
  // static const String Anas_SERVER = "http://192.168.1.23:80/api/mobile/";
  // static const String Old_Server = "http://172.20.10.4/FulgoAPI/";
  // static const String usama_Server = "192.168.100.19:8000/";

  static const List<String> serverLists = [LIVE_SERVER];

  static String getURL({required String functionName}) {
    return SERVICE_BASE_URL + functionName;
  }
}
