const int extensionStatusRemote = 1;
const int extensionStatusInstalled = 2;
const yamlExtensionKey = 'extensions';
const tempImageDir = 'img_tmp';
const archiveImageDir = 'archive_img';

enum NetImageType {
  normal,
  cover,
  reader,
}

enum GestureResult {
  prevTap,
  nextTap,
  none,
}

const double tapThreshold = 10;
