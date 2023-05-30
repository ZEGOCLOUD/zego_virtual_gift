import commonFilter from "../../lib/filter";
import GenerateUASignature from "../../lib/zego_auth";
import axios from "axios";
const crypto = require("crypto");

// Use unreliable message channel
export default async function sendGift(req, resp) {
  await commonFilter(req, resp);
  let {
    app_id,
    server_secret,
    room_id,
    user_id,
    user_name,
    gift_type,
    gift_count,
    timestamp,
  } = req.body;

  console.log(req.body, req.query);

  if (!app_id) {
    return resp.status(500).json({ error: "app_id is required" });
  } else if (!server_secret) {
    return resp.status(500).json({ error: "server_secret is required" });
  } else if (!room_id) {
    return resp.status(500).json({ error: "room_id is required" });
  } else if (!user_id) {
    return resp.status(500).json({ error: "user_id is required" });
  } else if (!user_name) {
    return resp.status(500).json({ error: "user_name is required" });
  } else if (!gift_type) {
    return resp.status(500).json({ error: "gift_type is required" });
  } else if (!gift_count) {
    return resp.status(500).json({ error: "gift_count is required" });
  } else if (!timestamp) {
    return resp.status(500).json({ error: "timestamp is required" });
  }

  const signatureNonce = crypto.randomBytes(8).toString("hex");

  const serverTimeStamp = Math.round(Date.now() / 1000);
  app_id = app_id * 1;
  const signature = GenerateUASignature(
    app_id,
    signatureNonce,
    server_secret,
    serverTimeStamp
  );

  const url = `https://zim-api.zego.im/?Action=SendRoomMessage&AppId=${app_id}&Timestamp=${serverTimeStamp}&Signature=${signature}&SignatureVersion=2.0&SignatureNonce=${signatureNonce}`;
  const Message = JSON.stringify({
    room_id, // Room ID
    user_id, // The user ID of the sender
    user_name, // The user name of the sender
    gift_type, // Gift type
    gift_count, // Number of gifts
    timestamp,
  });
  
  const formData = {
    FromUserId: user_id,
    RoomId: room_id,
    MessageType: 2,
    Priority: 3,
    MessageBody: { Message },
  };

  let result;
  try {
    result = await axios.post(url, formData);
    return resp.json(result.data);
  } catch (error) {
    result = error;
    return resp.json(error);
  }
}

// Use reliable message channel

/*
export default async function sendGift(req, resp) {
  await commonFilter(req, resp);
  let {
    app_id,
    server_secret,
    room_id,
    user_id,
    user_name,
    gift_type,
    gift_count,
    timestamp,
  } = req.body;

  console.log(req.body, req.query);

  if (!app_id) {
    return resp.status(500).json({ error: "app_id is required" });
  } else if (!server_secret) {
    return resp.status(500).json({ error: "server_secret is required" });
  } else if (!room_id) {
    return resp.status(500).json({ error: "room_id is required" });
  } else if (!user_id) {
    return resp.status(500).json({ error: "user_id is required" });
  } else if (!user_name) {
    return resp.status(500).json({ error: "user_name is required" });
  } else if (!gift_type) {
    return resp.status(500).json({ error: "gift_type is required" });
  } else if (!gift_count) {
    return resp.status(500).json({ error: "gift_count is required" });
  } else if (!timestamp) {
    return resp.status(500).json({ error: "timestamp is required" });
  }

  const signatureNonce = crypto.randomBytes(8).toString("hex");

  const serverTimeStamp = Math.round(Date.now() / 1000);
  app_id = app_id * 1;
  const signature = GenerateUASignature(
    app_id,
    signatureNonce,
    server_secret,
    serverTimeStamp
  );

  const url = `https://zim-api.zego.im/?Action=SendRoomMessage&AppId=${app_id}&Timestamp=${serverTimeStamp}&Signature=${signature}&SignatureVersion=2.0&SignatureNonce=${signatureNonce}`;
  const Message = JSON.stringify({
    room_id, // Room ID
    user_id, // The user ID of the sender
    user_name, // The user name of the sender
    gift_type, // Gift type
    gift_count, // Number of gifts
    timestamp,
  });
  
  const formData = {
    FromUserId: user_id,
    RoomId: room_id,
    MessageType: 1,
    Priority: 3,
    MessageBody: { Message },
  };

  let result;
  try {
    result = await axios.post(url, formData);
    return resp.json(result.data);
  } catch (error) {
    result = error;
    return resp.json(error);
  }
}
*/
