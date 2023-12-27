import { Platform } from 'react-native';

export class FileHelper {
  static async copyAssets() {
    if (Platform.OS !== 'android') {
      return;
    }
    const RNFS = require('react-native-fs');

    // 1. make resource dir.
    const resourceDir = RNFS.ExternalCachesDirectoryPath + '/resource';
    const exist = await RNFS.exists(resourceDir);
    if (!exist) {
      console.log('Resource dir not exist, creating....');
      await RNFS.mkdir(resourceDir);
    }

    // 2. copy files from assets to caches.
    console.log(`start copy assets files to caches folder..., folder: ${resourceDir}`);
    RNFS.readDirAssets('resource').then(async (items) => {
      for (const item of items) {
        let filePath = RNFS.ExternalCachesDirectoryPath + '/' + item.path;
        if (!await RNFS.exists(filePath)) {
          console.log(`item, name: ${item.name}, path: ${item.path}, isFile: ${item.isFile()}, isDir: ${item.isDirectory()}`);
          await RNFS.copyFileAssets(item.path, filePath);
        }
      }
    });
  }

  static getResourceFolder() {
    const RNFS = require('react-native-fs');
    if (Platform.OS === 'android') {
      return RNFS.ExternalCachesDirectoryPath + '/resource/';
    } else {
      return RNFS.MainBundlePath + '/resource/';
    }
  }
}