/**
 * OpenBrain
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

import GameView from '../native/GameView'
import GameOptions from '../lib/GameOptions'

export default class OpenBrain extends Component {

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

    const {options, gameCount, currentGame} = this.state;

    if(options != null && gameCount != null && currentGame != null){
      const data = {
        game:currentGame,
        options:options[currentGame.name],
        count:gameCount
      };
      console.log(data);
      return this.renderGame(data);
    }else{
      return this.renderLoading();
    }

  }

  renderLoading(){
    return(
      <View><Text>Loading</Text></View>
    );
  }

  renderGame(data){
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
      options:options,
      gameCount:this.state.gameCount + 1,
      currentGame:this.nextGame(this.props),
    });
  }
}
