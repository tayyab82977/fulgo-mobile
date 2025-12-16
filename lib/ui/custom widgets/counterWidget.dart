import 'package:flutter/material.dart';

class CounterWidget extends StatefulWidget {
  final ValueChanged<int> counter ;
  final Color backgroundColor ;
  int? initialValue ;
  bool acceptZero = false ;

  CounterWidget({required this.counter, required this.backgroundColor,this.initialValue , this.acceptZero = false });

  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(12)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(onPressed: (){
            setState(() {
              widget.initialValue =  widget.initialValue! + 1 ;
              widget.counter(widget.initialValue!);

            });
          }, icon: Icon(Icons.add,size: 20,)),
          Text(widget.initialValue.toString() , style: TextStyle(fontSize: 24,fontWeight: FontWeight.w600),),
          IconButton(onPressed: (){
            setState(() {
              if(widget.initialValue! > (widget.acceptZero ? 0 : 1)){
                widget.initialValue =  widget.initialValue! - 1 ;
                widget.counter(widget.initialValue!);
              }
            });
          }, icon: Icon(Icons.remove,size: 20,)),
        ],
      ),
    );
  }
}
