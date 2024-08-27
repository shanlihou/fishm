import 'package:flutter/material.dart';
import '../../api/flutter_call_lua/method.dart';
import '../../common/log.dart';


class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}


class _ExploreTabState extends State<ExploreTab> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    getGallery();
  }

  void getGallery() async {
    String ret = await gallery();
    Log.instance.d(ret);
  }


  @override
  Widget build(BuildContext context) {
    return Text('Hello, World!');
  }
}
