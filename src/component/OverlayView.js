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
          <Text>Play</Text>
        </TouchableHighlight>
      </View>
    );

  }

}


const styles = StyleSheet.create({
  container: {
    position:'absolute',
    top:0,
    left:0,
    bottom:0,
    right:0,
  }
});
