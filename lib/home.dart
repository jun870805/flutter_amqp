import 'package:flutter/material.dart';
import 'package:flutter_amqp/amqp.dart';
import 'package:flutter_amqp/provider.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final TextEditingController _inputController = TextEditingController();
  bool receiveOnHome = false;
  var amqpFunction = AMQPFunction();

  changeStatus(){
    setState(() {
      receiveOnHome = !receiveOnHome;
    });
    if(receiveOnHome){
      amqpFunction.receive(context);
    }
    else{
      amqpFunction.dispose();
      //clear message
      Provider.of<AMQPMessage>(context, listen: false).changeReceiveMessage("");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              controller: _inputController,
              decoration: const InputDecoration(
                  labelText: '輸入你要傳送的資訊'
              ),),
            TextButton(
              child: const Text('傳送'),
              onPressed:()=> amqpFunction.sendMessage(_inputController.text),),
            receiveOnHome?
            Consumer<AMQPMessage>(
                builder: (context, AMQPMessage amqp, _) => Text(
                  '接收到的資料: '+amqp.receiveMessage,)
            ):const Text(
              '請按下方按鈕打開接收',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: changeStatus,
        tooltip: 'amqp receive turn on/off',
        child: const Icon(Icons.cached),
      ),
    );
  }
}
