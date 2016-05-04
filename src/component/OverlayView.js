/**
 * OverlayView
 */

import React, {
  Component,
  StyleSheet,
  Text,
  View,
  TouchableHighlight,
} from 'react-native';

export default class OverlayView extends Component {

     static propTypes = {
       onPressPlay: React.PropTypes.func.isRequired,
       oldGameOptions: React.PropTypes.object,
       newGameOptions: React.PropTypes.object,
     };

  constructor(props) {
    super(props);
    this.state = {
    };
  }

  render() {
    const message = this.renderMessage();
    const style = StyleSheet.flatten([this.props.style,styles.container])
    return (
      <View style={style}>
        {message}
        <TouchableHighlight style={styles.touchable} onPress={this.props.onPressPlay}>
          <Text style={styles.button}>Play</Text>
        </TouchableHighlight>
      </View>
    );

  }

  renderMessage() {

    const oldGameOptions = this.props.oldGameOptions ||
      {level:1,failCount:0,successCount:0};
    const {newGameOptions} = this.props;

    if( newGameOptions == null ){
      return null;
    }

    const oldLevel = oldGameOptions.level;
    const newLevel = newGameOptions.level;

    if( oldLevel < newLevel ){
      return (<Text style={styles.message}>(aweseome!) level {oldLevel} -> {newLevel}</Text>);
    }else if( newLevel < oldLevel){
      return (<Text style={styles.message}>(no worries!) level {oldLevel} -> {newLevel}</Text>);
    }else if( oldGameOptions.failCount < newGameOptions.failCount ){
      return (<Text style={styles.message}>(no problem!) level {newLevel}</Text>);
    }else{
      return (<Text style={styles.message}>(nice work!)</Text>);
    }

  }

}


const styles = StyleSheet.create({
  message: {
    textShadowColor:"#000000",
    textShadowOffset:{width:2,height:2},
    textShadowRadius:1,
    fontWeight:"bold",
    paddingTop:10,
    paddingBottom:10,
    fontSize:16,
    color:"#FFFFFF",
  },
  container: {
    backgroundColor:"#00000088",
    alignItems:"center",
    justifyContent:"center",
  },
  button: {
    borderWidth:1,
    borderColor:"#FFFFFF",
    backgroundColor:"#00000088",
    color:"#FFFFFF",
    paddingTop:10,
    paddingBottom:10,
    width:200,
    fontSize:20,
    fontWeight:"bold",
    textAlign:"center",
  }

});
