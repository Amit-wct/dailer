import 'package:flutter/material.dart';

class Dailpad extends StatefulWidget {
  const Dailpad(this.number, this.callFun);
  final number;
  final callFun;
  @override
  State<Dailpad> createState() => _DailpadState();
}

class _DailpadState extends State<Dailpad> {
  var special_char = ['*', '0', '#'];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
          children: [
            // Text(widget.number.text),
            for (int i = 1; i < 4; i++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int j = 1; j < 4; j++)
                    Column(
                      children: [
                        RoundIconButton(
                          childText: Text(
                            ((i - 1) * 3 + j).toString(),
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              widget.number.text = widget.number.text +
                                  ((i - 1) * 3 + j).toString();
                            });
                          },
                        )
                      ],
                    )
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i in special_char)
                  RoundIconButton(
                    childText: Text(
                      i,
                      style: TextStyle(fontSize: 24),
                    ),
                    onPressed: () {
                      setState(() {
                        widget.number.text = widget.number.text + i;
                      });
                    },
                  )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RoundIconButton(
                  childText: Text(
                    "+",
                    style: TextStyle(fontSize: 24),
                  ),
                  onPressed: () {
                    setState(() {
                      widget.number.text = widget.number.text + "+";
                    });
                  },
                ),

                // RoundIconButton(
                //   childText: Icon(Icons.call),
                //   onPressed: widget.callFun,
                // ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  child: RawMaterialButton(
                    elevation: 6,
                    child: Icon(
                      Icons.call_rounded,
                      color: Colors.white,
                    ),
                    onPressed: widget.callFun,
                    constraints: BoxConstraints.tightFor(width: 56, height: 56),
                    shape: CircleBorder(),
                    fillColor: Colors.green,
                  ),
                ),
                RoundIconButton(
                  childText: Icon(Icons.backspace_rounded),
                  onPressed: () {
                    setState(() {
                      if (widget.number.text.length > 0)
                        widget.number.text = widget.number.text
                            .substring(0, widget.number.text.length - 1);
                    });
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({this.onPressed, this.childText, this.onLongPress});
  final onPressed;
  final onLongPress;

  final childText;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: RawMaterialButton(
        elevation: 6,
        child: childText,
        onPressed: onPressed,
        onLongPress: onLongPress,
        constraints: BoxConstraints.tightFor(width: 56, height: 56),
        shape: CircleBorder(),
        fillColor: Color.fromRGBO(210, 227, 191, 1),
      ),
    );
  }
}
