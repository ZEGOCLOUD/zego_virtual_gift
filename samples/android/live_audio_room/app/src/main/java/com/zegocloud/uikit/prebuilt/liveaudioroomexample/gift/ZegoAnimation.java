package com.zegocloud.uikit.prebuilt.liveaudioroomexample.gift;

import android.content.Context;
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
import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;

public class ZegoAnimation implements GiftAnimation {

    private final SurfaceView mediaPlayerView;
    private ZegoMediaPlayer mediaPlayer;
    private ViewGroup parentView;

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

        //        String giftUrl = "https://storage.zego.im/sdk-doc/Pics/zegocloud/gift/music_box.mp4";
        copyFileFromAssets(parent.getContext(), "music_box.mp4",
            parent.getContext().getExternalFilesDir(null) + "/music_box.mp4");
        String giftUrl = parent.getContext().getExternalFilesDir(null) + "/music_box.mp4";

        loadResourceFile(giftUrl);

        mediaPlayer.setEventHandler(new IZegoMediaPlayerEventHandler() {

            @Override
            public void onMediaPlayerStateUpdate(ZegoMediaPlayer mediaPlayer, ZegoMediaPlayerState state,
                int errorCode) {
                super.onMediaPlayerStateUpdate(mediaPlayer, state, errorCode);
                if (state == ZegoMediaPlayerState.PLAY_ENDED) {
                    parentView.removeView(mediaPlayerView);
                }
            }
        });
    }

    private void loadResourceFile(String url) {
        ZegoMediaPlayerResource resource = new ZegoMediaPlayerResource();
        resource.loadType = ZegoMultimediaLoadType.FILE_PATH;
        resource.filePath = url;
        resource.alphaLayout = ZegoAlphaLayoutType.LEFT;
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
        if (mediaPlayerView.getParent() == null) {
            parentView.addView(mediaPlayerView);
            mediaPlayer.start();
        }

        //        mediaPlayer.start();
        //        // pause
        //        mediaPlayer.pause();
        //        // resume
        //        mediaPlayer.resume();
        //        // stop
        //        mediaPlayer.stop();
    }

    /**
     * @param context
     * @param assetsFilePath
     * @param targetFileFullPath
     */
    public static void copyFileFromAssets(Context context, String assetsFilePath, String targetFileFullPath) {

        try {
            if (assetsFilePath.endsWith(File.separator)) {
                assetsFilePath = assetsFilePath.substring(0, assetsFilePath.length() - 1);
            }
            String fileNames[] = context.getAssets().list(assetsFilePath);
            if (fileNames.length > 0) {
                File file = new File(targetFileFullPath);
                file.mkdirs();
                for (String fileName : fileNames) {
                    copyFileFromAssets(context, assetsFilePath + File.separator + fileName,
                        targetFileFullPath + File.separator + fileName);
                }
            } else {

                File file = new File(targetFileFullPath);
                file.getParentFile().mkdir();

                InputStream is = context.getAssets().open(assetsFilePath);

                FileOutputStream fos = new FileOutputStream(file);
                byte[] buffer = new byte[1024];
                int byteCount = 0;
                while ((byteCount = is.read(buffer)) != -1) {
                    fos.write(buffer, 0, byteCount);
                }
                fos.flush();
                is.close();
                fos.close();
            }

        } catch (Exception e) {
            Log.d("Tag", "copyFileFromAssets " + "IOException-" + e.getMessage());
        }
    }
}
