var RNFS = require('react-native-fs');
var AsyncStorage = require('react-native').AsyncStorage;
var STORAGE_KEY = "AssetManager.AsyncStorage.manifest.15"

var AssetManager = {

  localBasePath(){
    return RNFS.DocumentDirectoryPath + "/"
  },

  relativeLocalPath(asset){
      return asset.filename +
      "/" +
      asset.checksum +
      "/" +
      asset.filename
  },

  getBasePath(fullPath){
    return fullPath.substring(0,fullPath.lastIndexOf("/")+1)
  },

  getAssets(){
    return AsyncStorage.getItem(STORAGE_KEY).then(
      (item) => JSON.parse(item)
    )
  },
  setAssets(assets){
    if(assets == null){
      throw "AssetManager.setAssets must receive a non null parameter"
    }
    const assetsString = JSON.stringify(assets);
    return AsyncStorage.setItem(STORAGE_KEY,assetsString)
  },

  // returns the last cached assets
  // or loads the assets from the store
  getCachedAssets(localURL, forceLocal){
    return this.getAssets().then(
      (assets) => {
        //if we aren't forcing local, and we have assets, use those
        if(!forceLocal && assets && assets.length){
          return assets;
        }else{
          return AssetManager.loadLocal(localURL)
        }
      }
    ).catch(
      (error) => console.log("getCachedAssets - "+error)
    )
  },

  loadLocal(localURL) {
    var base = AssetManager.getBasePath( localURL )
    return RNFS.readFile(localURL).then(
      (fileData) => JSON.parse(fileData)
    ).then(
      (assets) => AssetManager.copyLocalAssets(assets, base)
    ).then(
      (assets) => AssetManager.setAssets(assets)
    ).then(
      () => AssetManager.getAssets()
    ).catch(
      (error) => console.log("loadLocal - ", error)
    )
  },



  downloadRemote(remoteURL) {
    var base = AssetManager.getBasePath( localURL )
    fetch(remoteURL).then(
      (result) => result.json()
    ).then(
      (allAssets) => AssetManager.filterAssets(allAssets)
    ).then(
      (assets) => AssetManager.downloadAssets(assets, base)
    ).then(
      (assets) => AssetManager.setAssets(assets)
    ).catch(
      (error) => console.log("downloadRemote - ", error)
    )
  },
  filterAssets(assets){
    var promises = [];
    for(asset of assets){
      var path = this.localBasePath() + this.relativeLocalPath(asset);
      var promise = RNFS.exists(path).then(
        (doesExist) => {
          asset.needsDownload = !doesExist;
          return asset;
        }
      )
      promises.push( promise )
    }
    return Promise.all(promises).then(
      (assets) => assets.filter((asset) => asset.needsDownload)
    )
  },
  downloadAssets(assets, base){
    var promises = [];
    for(asset of assets){
      promises.push( this.downloadAsset(asset,base) )
    }
    //return Promise.all that renders the assets file
    return Promise.all(promises).then( (jobs) => assets).catch(
      (error) => console.log("downloadAssets - ", error)
    )
  },
  downloadAsset(asset,base){
    var url = base + asset.relativePath;
    asset.relativeLocalPath = this.relativeLocalPath(asset);
    var path = this.localBasePath() + asset.relativeLocalPath;
    return RNFS.downloadFile(url,path)
  },
  copyLocalAssets(assets, base){
    var promises = [];
    for(asset of assets){
      promises.push(AssetManager.copyLocalAsset(asset, base))
    }
    //return Promise.all that renders the assets file
    return Promise.all(promises).then( (jobs) => assets).catch(
      (error) => console.log("copyLocalAssets - ", error)
    )
  },
  copyLocalAsset(asset, base){
    var sourcePath = base+asset.relativePath
    asset.relativeLocalPath = this.relativeLocalPath(asset);
    var destPath = this.localBasePath() + asset.relativeLocalPath;

    var destBase = AssetManager.getBasePath( destPath )
    //no copy available in RNFS, so we read then write
    return RNFS.mkdir(destBase).then(
      () => RNFS.readFile(sourcePath)
    ).then(
      (data) => RNFS.writeFile(destPath, data)
    )
  }
}

module.exports = AssetManager
