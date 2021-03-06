import 'package:flutter/material.dart';
import 'package:seeds/v2/design/app_theme.dart';

class AmountEntryWidget extends StatelessWidget {
  final String? fiatAmount;
  final ValueSetter<String> onValueChange;
  final String enteringCurrencyName;
  final bool autoFocus;

  const AmountEntryWidget({
    Key? key,
    this.fiatAmount,
    required this.onValueChange,
    required this.enteringCurrencyName,
    required this.autoFocus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextFormField(
                textAlign: TextAlign.right,
                maxLines: 1,
                style: Theme.of(context).textTheme.headline4,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "0.0",
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
                autofocus: autoFocus,
                onChanged: (String value) => onValueChange(value),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                enteringCurrencyName,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ),
          ],
        ),
        Text(
          fiatAmount ?? "",
          style: Theme.of(context).textTheme.subtitle2OpacityEmphasis,
        ),
      ],
    );
  }
}
