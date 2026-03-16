import 'package:flutter/material.dart';

class Mybutton extends StatelessWidget{

final color;
final textColor;
final String buttonText;
final buttontapped;
Mybutton ({this.color, this.textColor, required this.buttonText, this.buttontapped});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: buttontapped,
      child: ClipRRect(
      borderRadius: BorderRadius.circular(60), 
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            color: color,
            child: Center(child: Text(buttonText, style: TextStyle(color: textColor,
              fontSize: 30,
            ),),),
          ),
        ),
      
      
      ),
    );
  }
}