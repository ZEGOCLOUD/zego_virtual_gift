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

        //用于播放的 view
        mediaPlayerView = new SurfaceView(parent.getContext());
        mediaPlayerView.getHolder().setFormat(PixelFormat.TRANSLUCENT);
        mediaPlayerView.setZOrderOnTop(true);//把 SurfaceView 置于显示窗口的最顶层

        mediaPlayer = ZegoExpressEngine.getEngine().createMediaPlayer();
        ZegoCanvas canvas = new ZegoCanvas(mediaPlayerView);
        canvas.alphaBlend = true;//支持 Alpha 通道渲染
        mediaPlayer.setPlayerCanvas(canvas);

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
        resource.loadType = ZegoMultimediaLoadType.FILE_PATH; // 加载方式选择文件路径加载
        if (cachedResourceMap.containsKey(url)) {
            resource.filePath = cachedResourceMap.get(url);//文件路径
        } else {
            resource.filePath = url;
        }
        resource.alphaLayout = ZegoAlphaLayoutType.LEFT; // 根据实际资源选择 Alpha 通道布局
        mediaPlayer.loadResourceWithConfig(resource, new IZegoMediaPlayerLoadResourceCallback() {
            @Override
            public void onLoadResourceCallback(int errorCode) {
                //资源加载结果
                // 可执行更新 UI 等逻辑
                if (errorCode == 0) {
                    //加载文件成功，此时可以开始播放媒体资源
                    //                    mediaPlayer.start();
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
