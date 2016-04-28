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
     };

  constructor(props) {
    super(props);
    this.state = {
    };
  }

  render() {

    return (
      <View style={this.props.style}>
        <TouchableHighlight onPress={this.props.onPressPlay}>
          <Text style={styles.button}>Play</Text>
        </TouchableHighlight>
      </View>
    );

  }

}


const styles = StyleSheet.create({
  button: {
    width:100,
    height:100,
    backgroundColor:"#88FF88"
  }

});
