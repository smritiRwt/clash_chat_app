
import 'package:chat_app/utils/constants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connect(String accessToken) {
    socket = IO.io(
   Constants.socketUrl, // your Node.js local IP
      IO.OptionBuilder()
          .setTransports(['websocket']) // required for Flutter
          .enableAutoConnect()
          .setAuth({
            'token': accessToken, // 👈 sent during connection
          })
          .build(),
    );

    socket.onConnect((_) {

      print('✅ Connected to socket');
              sendMessage('1','Hello',type:'text');

    });

    socket.onDisconnect((_) {
      print('❌ Disconnected from socket');
    });

    socket.onConnectError((err) {
      print('⚠️ Connection error: $err');
    });

    socket.on('message', (data) {
      print('📩 Message: $data');
    });

    socket.on('send_message', (data) {
      print('Auth: $data');
    });


  }

  void sendMessage(String receiverId,String message,{String? type}) {
    var data={
      'receiver_id':receiverId,
      'content':message,
      'type':type
    };
    print('before: $data');
    socket.emit('send_message', data);
    socket.on('send_message', (data) {
      print('after: $data');
    });
  }



  void disconnect() {
    socket.disconnect();
  }
}