class URLs {
  static const host = 'http://192.168.1.11:8082';
  static String image(String fileName) => '$host/attachments/$fileName';
}
