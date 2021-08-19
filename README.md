# Flutter 高級消息隊列協議(AMQP) 實作

Flutter AMQP（Advanced Message Queuing Protocol）

傳送及接收訊息，並利用 狀態管理(provider) 同步訊息

***使用套件：[dart_amqp ^0.1.4](https://pub.dev/packages/dart_amqp/versions/0.1.4) 、 [provider ^5.0.0](https://pub.dev/packages/provider/versions/5.0.0)***

## Step1 添加庫至 pubspec.yaml ：

pubspec.yaml

    dart_amqp: ^0.1.4
    provider: ^5.0.0

## Step2 dart 程式碼 ：

provider.dart 

    class AMQPMessage with ChangeNotifier {
        String _receiveMessage = "";
        get receiveMessage => _receiveMessage;
        // Change receive message
        void changeReceiveMessage(String message){
            _receiveMessage = message;
            notifyListeners();
        }
    }

main.dart 設定整個app provider

    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AMQPMessage()),
      ],
      child: MaterialApp()
    )

home.dart 建立 widget 時利用Consumer做到訊息同步

    Consumer<AMQPMessage>(
        builder: (context, AMQPMessage amqp, _) => Text(amqp.receiveMessage,)
    )

amqp.dart 傳送訊息

    // create client,channel
    dart_amqp.Client client = dart_amqp.Client(settings : _settings);
    dart_amqp.Channel channel = await client.channel();

    // Queue publish message
    //Queue queue = await channel.queue("queue_name");
    //queue.publish(message);

    // Exchange publish message
    dart_amqp.Exchange exchange = await channel.exchange('exchange_name',dart_amqp.ExchangeType.DIRECT );
    exchange.publish(message, "routing_key");

    debugPrint(" [x] Sent '$message'");

    // close client
    await client.close();

amqp.dart 接收訊息

    // create client,channel
    _client = dart_amqp.Client(settings : _settings);
    _channel = await _client.channel();

    // Queue receive
    //dart_amqp.Queue queue = await channel.queue("queue_name");
    //dart_amqp.Consumer consumer = await queue.consume();

    // Exchange receive
    _exchange = await _channel.exchange('exchange_name',dart_amqp.ExchangeType.DIRECT );
    _consumer = await _exchange.bindPrivateQueueConsumer(["routing_key"]);

    // listen receive message
    _consumer.listen((message) async {
      var amqp = Provider.of<provider.AMQPMessage>(context, listen: false);
      debugPrint(" [x] Received ${message.payloadAsString}");
      // Change provider
      amqp.changeReceiveMessage(message.payloadAsString);
    });

    debugPrint("AMQP Received ON!");