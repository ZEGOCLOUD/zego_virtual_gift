package com.zegocloud.uikit.livestreaming.gift;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout.LayoutParams;
import com.zegocloud.uikit.ZegoUIKit;
import com.zegocloud.uikit.livestreaming.R;
import com.zegocloud.uikit.plugin.adapter.plugins.signaling.SendRoomMessageCallback;
import com.zegocloud.uikit.plugin.adapter.plugins.signaling.ZegoSignalingInRoomCommandMessage;
import com.zegocloud.uikit.service.defines.ZegoUIKitSignalingPluginInRoomCommandMessageListener;
import com.zegocloud.uikit.utils.Utils;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.List;
import org.json.JSONException;
import org.json.JSONObject;

public class GiftHelper {

    private Handler handler = new Handler(Looper.getMainLooper());
    private GiftAnimation giftAnimation;
    private String userID;
    private String userName;

    public GiftHelper(ViewGroup animationViewParent, String userID, String userName) {
        giftAnimation = new ZegoAnimation(animationViewParent);
        this.userID = userID;
        this.userName = userName;

        // when someone send gift in room,everyone will receive InRoomCommand
        ZegoUIKit.getSignalingPlugin().addInRoomCommandMessageListener(new ZegoUIKitSignalingPluginInRoomCommandMessageListener() {
                @Override
                public void onInRoomCommandMessageReceived(List<ZegoSignalingInRoomCommandMessage> messages,
                    String roomID) {
                    for (ZegoSignalingInRoomCommandMessage message : messages) {
                        Log.d("TAG",
                            "onInRoomCommandMessageReceived() called with: message = [" + message + "], roomID = ["
                                + roomID + "]");
                        if (!message.senderUserID.equals(userID) && message.text.contains("gift_type")) {
                            showAnimation();
                        }
                    }

                }
            });
    }

    public View getGiftButton(Context context, long appID, String serverSecret, String roomID) {
        ImageView imageView = new ImageView(context);
        imageView.setImageResource(R.drawable.presents_icon);
        int size = Utils.dp2px(36f, context.getResources().getDisplayMetrics());
        int marginTop = Utils.dp2px(10f, context.getResources().getDisplayMetrics());
        int marginBottom = Utils.dp2px(16f, context.getResources().getDisplayMetrics());
        int marginEnd = Utils.dp2px(8, context.getResources().getDisplayMetrics());
        LayoutParams layoutParams = new LayoutParams(size, size);
        layoutParams.topMargin = marginTop;
        layoutParams.bottomMargin = marginBottom;
        layoutParams.rightMargin = marginEnd;
        imageView.setLayoutParams(layoutParams);
        // click will post json to server
        imageView.setOnClickListener(v -> {
            // !In the demo, gifts are sent directly by sending commands. However, 
            // !when you integrate, you need to forward the commands through your business server 
            // !in order to handle settlement-related logic.
            // !like this:
            // final String path = "https://zego-example-server-nextjs.vercel.app/api/send_gift";
            // JSONObject jsonObject = new JSONObject();
            // try {
            //     jsonObject.put("app_id", appID);
            //     jsonObject.put("server_secret", serverSecret);
            //     jsonObject.put("room_id", roomID);
            //     jsonObject.put("user_id", userID);
            //     jsonObject.put("user_name", userName);
            //     jsonObject.put("gift_type", 1001);
            //     jsonObject.put("gift_count", 1);
            //     jsonObject.put("timestamp", System.currentTimeMillis());
            // } catch (JSONException e) {
            //     e.printStackTrace();
            // }
            // String jsonString = jsonObject.toString();
            // new Thread() {
            //     public void run() {
            //         httpPost(path, jsonString, () -> showAnimation());
            //     }
            // }.start();

            // !In the demo, gifts are sent directly by sending commands. However, 
            // !when you integrate, you need to forward the commands through your business server 
            // !in order to handle settlement-related logic.
            ZegoUIKit.getSignalingPlugin().sendInRoomCommandMessage(jsonObject.toString(), roomID,
                new SendRoomMessageCallback() {
                    @Override
                    public void onResult(int errorCode, String errorMessage) {
                        showAnimation();
                    }
                }
            );
        });
        return imageView;
    }


    /**
     * post json to server,will receive InRoomCommand or InRoomTextMessage callback
     *
     * @param path
     * @param jsonString
     * @param successCallback
     */
    private void httpPost(String path, String jsonString, Runnable successCallback) {
        try {
            URL url = new URL(path);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setReadTimeout(5000);
            conn.setRequestProperty("Charset", "UTF-8");
            conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
            conn.setDoOutput(true);
            byte[] writebytes = jsonString.getBytes();
            conn.setRequestProperty("Content-Length", String.valueOf(writebytes.length));
            OutputStream outwritestream = conn.getOutputStream();
            outwritestream.write(jsonString.getBytes());
            outwritestream.flush();
            outwritestream.close();
            int code = conn.getResponseCode();
            if (code == 200) {
                InputStream is = conn.getInputStream();
                ByteArrayOutputStream baos = new ByteArrayOutputStream();
                int len = -1;
                byte[] buffer = new byte[1024]; //1kb
                while ((len = is.read(buffer)) != -1) {
                    baos.write(buffer, 0, len);
                }
                is.close();
                String content = baos.toString();
                handler.post(successCallback);
            } else {
            }
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();

        }
    }

    private void showAnimation() {
        giftAnimation.startPlay();
    }
}
