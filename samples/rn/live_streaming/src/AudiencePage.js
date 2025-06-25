import React, { useEffect, useRef, useState } from 'react';
import { TouchableOpacity, findNodeHandle } from 'react-native';
import { StyleSheet, View, Text } from 'react-native';
import ZegoUIKitPrebuiltLiveStreaming, {
  AUDIENCE_DEFAULT_CONFIG,
  ZegoMenuBarButtonName,
} from '@zegocloud/zego-uikit-prebuilt-live-streaming-rn';
import * as ZIM from 'zego-zim-react-native';
import KeyCenter from "../KeyCenter";
import ZegoUIKit from '@zegocloud/zego-uikit-rn';
import ZegoExpressEngine, { ZegoAlphaLayoutType, ZegoMediaPlayerResource, ZegoMediaPlayerState, ZegoMultimediaLoadType, ZegoTextureView } from 'zego-express-engine-reactnative';
import { FileHelper } from './FileHelper';

export default function AudiencePage(props) {
  const { route } = props;
  const { params } = route;
  const { userID, userName, liveID } = params;
  const mediaViewRef = useRef();
  const [showGift, setShowGift] = useState(false);

  useEffect(() => {

    const callbackID = 'callbackID'
    ZegoUIKit.getSignalingPlugin().onInRoomTextMessageReceived(callbackID, (messageData) => {
      const {roomID, message, senderUserID, timestamp} = messageData;
        console.log(`Audience onInRoomTextMessageReceived, roomID:${roomID}, message:${message}, senderUserID:${senderUserID}, timestamp:${timestamp}`);
        setShowGift(true);
      }
    );

    return () => {
      if (this.mediaPlayer) {
        ZegoExpressEngine.instance().destroyMediaPlayer(this.mediaPlayer);
        this.mediaPlayer = null;
      }
      ZegoUIKit.getSignalingPlugin().onInRoomTextMessageReceived(callbackID);
    }
  }, []);

  useEffect(() => {
    if (!showGift) {
      return;
    }
    
    console.log('will showGiftAnimation');
    showGiftAnimation();
  }, [showGift]);

  const showGiftAnimation = async () => {
    if (!this.mediaPlayer) {
      this.mediaPlayer = await ZegoExpressEngine.instance().createMediaPlayer();

      this.mediaPlayer.on('mediaPlayerStateUpdate', (player, state, errorCode) => {
        if (state === ZegoMediaPlayerState.PlayEnded) {
          console.log('Gift animation Play Ended');
          setShowGift(false);
        }
      });
    }
    // this.mediaPlayer.enableRepeat = true;
    this.mediaPlayer.setPlayerView({ 'reactTag': findNodeHandle(mediaViewRef.current), 'viewMode': 0, 'backgroundColor': 0, 'alphaBlend': true});

    let resource = new ZegoMediaPlayerResource();
    resource.loadType = ZegoMultimediaLoadType.FilePath;
    resource.alphaLayout = ZegoAlphaLayoutType.Left;

    // 1. For local resource.
    // resource.filePath = FileHelper.getResourceFolder() + '1.mp4';

    // 2. For online resource.
    resource.filePath = 'https://storage.zego.im/sdk-doc/Pics/zegocloud/oss/1.mp4';

    console.log(`File Path: ${resource.filePath}`);
    
    this.mediaPlayer.loadResourceWithConfig(resource).then((ret) => {
      console.log("load resource error: " + ret.errorCode)
      if (ret.errorCode === 0) {
        this.mediaPlayer.start();
      }
    });
  };

  return (
    <View style={styles.container}>
      <ZegoUIKitPrebuiltLiveStreaming
        appID={KeyCenter.appID}
        appSign={KeyCenter.appSign}
        userID={userID}
        userName={userName}
        liveID={liveID}
        config={{
          ...AUDIENCE_DEFAULT_CONFIG,
          onLeaveLiveStreaming: () => {
            props.navigation.navigate('HomePage');
          },
          topMenuBarConfig: {
            buttons: [ZegoMenuBarButtonName.minimizingButton, ZegoMenuBarButtonName.leaveButton],
          },
          bottomMenuBarConfig: {
            coHostExtendButtons: [<GiftButton onPress={SendGift} />],
            audienceExtendButtons: [<GiftButton onPress={SendGift} />],
          },
          onWindowMinimized: () => {
            console.log('[Demo]AudiencePage onWindowMinimized');
            props.navigation.navigate('HomePage');
          },
          onWindowMaximized: () => {
              console.log('[Demo]AudiencePage onWindowMaximized');
              props.navigation.navigate('AudiencePage', {
                userID: userID,
                userName: userName,
                liveID: liveID,
              });
          }
        }}
        plugins={[ZIM]}
      />
      {showGift ? 
        <View style={{height: 350, width: 350, backgroundColor: 0}}>
          <ZegoTextureView
          // @ts-ignore
          style={{ flex: 1, width: '100%', height: '100%', position: 'absolute' }}
          ref={mediaViewRef}
          collapsable={false}
          />
        </View> : null
      }
    </View>
  );

  function SendGift() {
      setShowGift(true);

      const message = JSON.stringify({
        roomID: liveID,
        message: "gift_name",
        senderUserID: userID,
        timestamp: Date.parse(new Date())   // millisecond
      })
      ZegoUIKit.getSignalingPlugin().sendInRoomTextMessage(liveID, message)
  }
}

const GiftButton = ({ onPress }) => {
  return (
    <TouchableOpacity
      style={buttonStyles.button}
      onPress={onPress}
    >
      <Text style={buttonStyles.buttonText}>{'Gift'}</Text>
    </TouchableOpacity>
  );
};

const buttonStyles = StyleSheet.create({
  button: {
    backgroundColor: 'red',
    paddingVertical: 10,
    paddingHorizontal: 20,
    borderRadius: 5,
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: 'bold',
    textAlign: 'center',
  },
});

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    zIndex: 0,
  },
  avView: {
    flex: 1,
    width: '100%',
    height: '100%',
    zIndex: 1,
    position: 'absolute',
    right: 0,
    top: 0,
    backgroundColor: 'red',
  },
  ctrlBar: {
    flex: 1,
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'flex-end',
    marginBottom: 50,
    width: '100%',
    height: 50,
    zIndex: 2,
  },
  ctrlBtn: {
    flex: 1,
    width: 48,
    height: 48,
    marginLeft: 37 / 2,
    position: 'absolute',
  },
});
