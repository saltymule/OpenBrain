'use strict';
/**
 * This exposes the native BundlePreferences module as a JS module. This has a
 * function 'setBundleAsset' which takes the following parameter:
 *
 * 1. Object asset : an object that represents the bundle to load
 *
 */
var { NativeModules } = require('react-native');
module.exports = NativeModules.BundlePreferences;
