import 'package:flutter/material.dart';
import 'package:dio/dio.dart';


class ExploreTab extends StatefulWidget {
  const ExploreTab({Key? key}) : super(key: key);

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}


class _ExploreTabState extends State<ExploreTab> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    test();
  }

  void test() async {
    String url = "https://comic.idmzj.com";
    Dio dio = Dio();
    print('will get');
    var ret = await dio.get(url);
    print(ret);
  }

  @override
  Widget build(BuildContext context) {
    return Text('Hello, World!');
  }
}
