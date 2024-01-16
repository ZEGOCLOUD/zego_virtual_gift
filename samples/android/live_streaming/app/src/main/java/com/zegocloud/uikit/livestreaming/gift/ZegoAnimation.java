package com.zegocloud.uikit.livestreaming.gift;

import android.graphics.PixelFormat;
import android.util.Log;
import android.view.SurfaceView;
import android.view.ViewGroup;
import im.zego.zegoexpress.ZegoExpressEngine;
import im.zego.zegoexpress.ZegoMediaPlayer;
import im.zego.zegoexpress.callback.IZegoMediaPlayerEventHandler;
import im.zego.zegoexpress.callback.IZegoMediaPlayerLoadResourceCallback;
import im.zego.zegoexpress.constants.ZegoAlphaLayoutType;
import im.zego.zegoexpress.constants.ZegoMediaPlayerState;
import im.zego.zegoexpress.constants.ZegoMultimediaLoadType;
import im.zego.zegoexpress.entity.ZegoCanvas;
import im.zego.zegoexpress.entity.ZegoMediaPlayerResource;
import java.util.HashMap;
import java.util.Map;

public class ZegoAnimation implements GiftAnimation {

    private final SurfaceView mediaPlayerView;
    private ZegoMediaPlayer mediaPlayer;
    private ViewGroup parentView;
    private Map<String, String> cachedResourceMap = new HashMap<>();

    public ZegoAnimation(ViewGroup parent) {
        this.parentView = parent;

        // 'view' for play animation
        mediaPlayerView = new SurfaceView(parent.getContext());
        mediaPlayerView.getHolder().setFormat(PixelFormat.TRANSLUCENT);
        mediaPlayerView.setZOrderOnTop(true); // Place the SurfaceView at the top layer of the display window.

        mediaPlayer = ZegoExpressEngine.getEngine().createMediaPlayer();
        ZegoCanvas canvas = new ZegoCanvas(mediaPlayerView);
        canvas.alphaBlend = true; // Support for Alpha channel rendering.
        mediaPlayer.setPlayerCanvas(canvas);

        // demo gift resource
        loadResourceFile("https://storage.zego.im/sdk-doc/Pics/zegocloud/gift/music_box.mp4");

        mediaPlayer.setEventHandler(new IZegoMediaPlayerEventHandler() {

            @Override
            public void onMediaPlayerStateUpdate(ZegoMediaPlayer mediaPlayer, ZegoMediaPlayerState state,
                int errorCode) {
                super.onMediaPlayerStateUpdate(mediaPlayer, state, errorCode);
                Log.d("TAG",
                    "onMediaPlayerStateUpdate() called with: mediaPlayer = [" + mediaPlayer + "], state = [" + state
                        + "], errorCode = [" + errorCode + "]");
                if (state == ZegoMediaPlayerState.PLAY_ENDED) {
                    parentView.removeView(mediaPlayerView);
                }
            }

            @Override
            public void onMediaPlayerLocalCache(ZegoMediaPlayer mediaPlayer, int errorCode, String resource,
                String cachedFile) {
                super.onMediaPlayerLocalCache(mediaPlayer, errorCode, resource, cachedFile);
                if (errorCode == 0) {
                    cachedResourceMap.put(resource, cachedFile);
                }
            }
        });
    }

    private void loadResourceFile(String url) {
        ZegoMediaPlayerResource resource = new ZegoMediaPlayerResource();
        resource.loadType = ZegoMultimediaLoadType.FILE_PATH; // Choose file path for loading
        if (cachedResourceMap.containsKey(url)) {
            resource.filePath = cachedResourceMap.get(url);//file path
        } else {
            resource.filePath = url;
        }
        resource.alphaLayout = ZegoAlphaLayoutType.LEFT; // Choose Alpha channel layout based on available resources
        mediaPlayer.loadResourceWithConfig(resource, new IZegoMediaPlayerLoadResourceCallback() {
            @Override
            public void onLoadResourceCallback(int errorCode) {
                // Resource loading result
                // Can execute logic such as updating UI
                if (errorCode == 0) {
                    // The file is loaded successfully, and now you can start playing the media resource by startPlay().
                    // 
                }
            }
        });
    }

    @Override
    public void startPlay() {
        Log.d("TAG", "startPlay() called");
        if (mediaPlayerView.getParent() == null) {
            parentView.addView(mediaPlayerView);
            mediaPlayer.start();
        }
    }
}
