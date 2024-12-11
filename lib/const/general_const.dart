const int extensionStatusRemote = 1;
const int extensionStatusInstalled = 2;
const yamlExtensionKey = 'extensions';
const tempImageDir = 'img_tmp';
const archiveImageDir = 'archive_img';
const archiveCbzImageDir = 'archive_cbz_img';
const cbzDir = 'cbz';
const cbzOutputDir = 'cbz_output';
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

const bool isDebug = true;

enum ComicChapterStatus {
  loading,
  downloading,
  downloaded,
  normal,
}

enum TaskStatus {
  ready,
  pending,
  running,
  finished,
  failed,
  deleted,
}

const downloadImageRetry = 5;

const taskTypeDownload = 1;

const int tabExtension = 0;
const int tabSearch = 1;
const int tabShelf = 2;
const int tabImport = 3;
const int tabMy = 4;
