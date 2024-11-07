const int extensionStatusRemote = 1;
const int extensionStatusInstalled = 2;
const yamlExtensionKey = 'extensions';
const tempImageDir = 'img_tmp';
const archiveImageDir = 'archive_img';
const yamlMainKey = 'main';

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

enum ExtensionStatus {
  installed,
  needUpdate,
  notInstalled,
}

const double tapThreshold = 10;

const int readerFlagsFinger = 0;
const int readerFlagsScale = 1;

const bool isDebug = false;

enum ComicChapterStatus {
  normal,
  downloading,
}

enum TaskStatus {
  ready,
  pending,
  running,
  finished,
  failed,
}

const downloadImageRetry = 5;

const taskTypeDownload = 1;
