/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 */

import React, {
  AppRegistry,
  Component,
  StyleSheet,
  Text,
  View,
  WebView,
  Dimensions,
  NativeAppEventEmitter,
} from 'react-native';

import GameView from './src/native/GameView'
import GameOptions from './src/lib/GameOptions'

class OpenBrain extends Component {

  constructor(props) {
    super(props);
    this.state = {
      gameCount: 0,
      currentGame: this.nextGame(props)
    };
    GameOptions.load(this._didLoadOptions)
  }

  _didLoadOptions = (error, result) => {
    const options = result == null ? {} : result;

    this.setState({
      ...this.state,
      options:options
    });
  }

  nextGame(props) {
    const {manifest} = props;
    if(manifest && manifest.length > 0){
      const index = Math.floor(Math.random()*manifest.length)
      return manifest[index];
    }
    return null;
  }

  componentWillMount() {

    NativeAppEventEmitter.addListener(
      "GameViewDidComplete",
      this.gameViewDidComplete
    )
  }

  render() {

    const width = Dimensions.get('window').width;
    const height = Dimensions.get('window').height;

    const styles = StyleSheet.create({
      container: {
        height: height,
        width: width,
      },
      webview: {
        height: height,
        width: width,
      },
    });
    const options = {level:2};
    const data = {
      game:this.state.currentGame,
      options:{level:2},
      count:this.state.gameCount
    };
    return (
      <View style={styles.container}>
        <GameView style={styles.webview}
          data={data}
        />
      </View>
    );
  }

  gameViewDidComplete = (body) => {

    var {options, currentGame} = this.state;

    options[currentGame.name] = body;

    GameOptions.save(options);

    // console.log(body)
    this.setState({
      ...this.state,
      gameCount:this.state.gameCount + 1,
      currentGame:this.nextGame(this.props),
    });
  }
}

AppRegistry.registerComponent('OpenBrain', () => OpenBrain);
