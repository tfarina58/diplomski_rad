import 'package:diplomski_rad/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:diplomski_rad/other/pallete.dart';

class CalendarField extends StatelessWidget {
  final String labelText;
  DateTime selectedDate = DateTime.now();
  DateTime tmpDate = DateTime.now();
  final Function callback;
  final String presetText;

  CalendarField({
    Key? key,
    required this.labelText,
    required this.callback,
    this.presetText = "",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width * 0.3;
    final double height = MediaQuery.of(context).size.height * 0.55;
    final textController = TextEditingController();
    textController.text = presetText;

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 400,
      ),
      child: TextFormField(
        controller: textController,
        readOnly: true,
        onTap: () => showDialog<String>(
          context: context,
          builder: (BuildContext context) => Dialog(
            backgroundColor: PalleteCommon.backgroundColor,
            alignment: Alignment.center,
            child: SizedBox(
              width: width + 20,
              height: height,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            child: const Icon(
                              Icons.close,
                              color: PalleteCommon.gradient2,
                            ),
                            onTap: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: PalleteCommon.borderColor)),
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.height * 0.4,
                    padding: const EdgeInsets.all(16),
                    child: CalendarDatePicker(
                      firstDate: DateTime.utc(1998, 3, 12),
                      initialDate: DateTime.now(),
                      lastDate: DateTime.now(),
                      onDateChanged: (DateTime value) => tmpDate = value,
                    ),
                  ),
                  const SizedBox(height: 30),
                  GradientButton(
                    buttonText: 'Set date',
                    callback: () {
                      selectedDate = tmpDate;
                      textController.text =
                          DateFormat('dd.MM.yyyy').format(tmpDate);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        decoration: InputDecoration(
          labelText: labelText,
          contentPadding: const EdgeInsets.all(27),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: PalleteCommon.borderColor,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: PalleteCommon.gradient2,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
