import 'package:flutter/material.dart';
//dart_amqp & provider Consumer 有重疊，故要區分命名
import 'package:dart_amqp/dart_amqp.dart' as dart_amqp;
import 'package:flutter_amqp/provider.dart' as provider;
import 'dart:io';

import 'package:provider/provider.dart';

class AMQPFunction{

  // amqp ConnectionSettings
  final dart_amqp.ConnectionSettings _settings = dart_amqp.ConnectionSettings(
      host : "ip",
      authProvider : const dart_amqp.PlainAuthenticator("account", "password")
  );
  late dart_amqp.Client _client;
  late dart_amqp.Channel _channel;
  late dart_amqp.Exchange _exchange;
  late dart_amqp.Consumer _consumer;

  Future<void> sendMessage(message) async {

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
  }

  Future<void> receive(context) async {
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

    // receive Ctrl+C close client
    ProcessSignal.sigint.watch().listen((_) async {
      await _client.close();
      exit(0);
    });
  }

  Future<void> dispose()async {
    // close consumer
    _consumer.cancel();

    // close client
    await _client.close();

    debugPrint("AMQP Received OFF!");
  }
}