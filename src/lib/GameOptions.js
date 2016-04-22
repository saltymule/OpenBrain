import React, {
  AsyncStorage,
} from 'react-native';

const STORAGE_KEY = "GameOptions"

export default class GameOptions {
  static load(callback) {
    AsyncStorage.getItem(STORAGE_KEY).then(
      (error, value) => JSON.parse(value)
    ).then(
      (options) => callback(options,null)
    ).catch(
      error => callback(null,error)
    );
  }
  static save(options) {
    const value = JSON.stringify(options);
    AsyncStorage.setItem(STORAGE_KEY,value)
  }
}
