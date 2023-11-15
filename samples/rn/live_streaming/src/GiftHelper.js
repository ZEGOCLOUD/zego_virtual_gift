import ZegoUIKit from '@zegocloud/zego-uikit-rn';
import { Alert } from 'react-native';

export class GiftHelper {  
  static onGiftReceived() {
    ZegoUIKit.getSignalingPlugin().onInRoomCommandMessageReceived('callbackID', (messageData) => {
      const {roomID, message, senderUserID, timestamp} = messageData;
        console.log(`onInRoomCommandMessageReceived, roomID:${roomID}, message:${message}, senderUserID:${senderUserID}, timestamp:${timestamp}`);
        Alert.alert('Gift', `Receive a Gift from ${senderUserID}`);
    });
  }
}