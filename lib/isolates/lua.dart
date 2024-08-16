

void luaLoop(void _) async {
  while (true) {
    print('Hello, World!');
    await Future.delayed(const Duration(seconds: 1));
  }
}
