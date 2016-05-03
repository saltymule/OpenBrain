/**
 * OpenBrain
 */

import React, {
  Component,
  Dimensions,
  StyleSheet,
  Text,
  View,
  NativeAppEventEmitter,
} from 'react-native';

import OverlayView from '../component/OverlayView'
import GameView from '../native/GameView'
import GameOptions from '../lib/GameOptions'

const UI_STATE_GAME = "UI_STATE_GAME"
const UI_STATE_CHROME = "UI_STATE_CHROME"

export default class OpenBrain extends Component {

  constructor(props) {
    super(props);
    this.state = {
      gameCount: 0,
      uiState:UI_STATE_CHROME,
    };
    GameOptions.load(this._didLoadOptions)
  }

  _didLoadOptions = (result, error) => {
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
    return (
      <View style={styles.container}>
        {this.renderGameView()}
        {this.renderOverlay()}
      </View>
    )
  }

  renderOverlay() {
    if(this.state.uiState == UI_STATE_GAME){
      return null
    }else{
      return (<OverlayView
        oldGameOptions={this.state.oldGameOptions}
        newGameOptions={this.state.newGameOptions}
        style={styles.overlay}
        onPressPlay={this.onPressPlay} />)
    }
  }

  renderGameView() {
    const data = this.currentGameData()
    const webviewStyles = this.state.uiState == UI_STATE_GAME ? styles.webview :
      StyleSheet.flatten([styles.webview,styles.webviewInactive]);
    return (<GameView style={webviewStyles} data={data} /> )
  }

  currentGameData() {
    const {options, gameCount, currentGame} = this.state;

    if(this.state.uiState == UI_STATE_GAME
      && options != null
      && gameCount != null
      && currentGame != null){
      const data = {
        game:currentGame,
        options:options[currentGame.name],
        count:gameCount
      };
      return data;
    }else{
      return {}
    }
  }

  onPressPlay = () => {
    this.setState({
      uiState:UI_STATE_GAME,
      currentGame:this.nextGame(this.props)
    })
  }

  gameViewDidComplete = (newGameOptions) => {

    const {options, currentGame} = this.state;
    const oldGameOptions = options[currentGame.name];
    options[currentGame.name] = newGameOptions;

    GameOptions.save(options);

    this.setState({
      ...this.state,
      oldGameOptions,
      newGameOptions,
      options:options,
      gameCount:this.state.gameCount + 1,
      uiState:UI_STATE_CHROME,
    });
  }
}

const styles = StyleSheet.create({
  container: {
    position:'absolute',
    top:0,
    left:0,
    bottom:0,
    right:0,
    backgroundColor:"#AAAAAA",
  },
  webview: {
    position:'absolute',
    top:0,
    left:0,
    bottom:0,
    right:0,
  },
  overlay: {
    position:'absolute',
    top:0,
    left:0,
    bottom:0,
    right:0,
  },
  webviewInactive: {
    transform:[{
      scaleX:0.8,
    },{
      scaleY:0.8,
    },],
  }
});
