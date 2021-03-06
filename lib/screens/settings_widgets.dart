import 'package:flutter/material.dart';
import 'package:gitjournal/settings.dart';

class ListPreference extends StatelessWidget {
  final String title;
  final String currentOption;
  final List<String> options;
  final Function onChange;
  final bool enabled;

  ListPreference({
    @required this.title,
    @required this.currentOption,
    @required this.options,
    @required this.onChange,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(currentOption),
      onTap: () async {
        var option = await showDialog<String>(
            context: context,
            builder: (BuildContext context) {
              var children = <Widget>[];
              for (var o in options) {
                var tile = RadioListTile<String>(
                  title: Text(o),
                  value: o,
                  groupValue: currentOption,
                  onChanged: (String val) {
                    Navigator.of(context).pop(val);
                  },
                );
                children.add(tile);
              }
              return AlertDialog(
                title: Text(title),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: children,
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: const Text('CANCEL'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  )
                ],
              );
            });

        if (option != null) {
          onChange(option);
        }
      },
      enabled: enabled,
    );
  }
}

class ProListTile extends StatelessWidget {
  final Widget title;
  final Widget subtitle;
  final Function onTap;

  ProListTile({this.title, this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    var isPro = Settings.instance.proMode;
    var tile = ListTile(
      title: title,
      subtitle: subtitle,
      onTap: onTap,
    );

    if (isPro) {
      return tile;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Banner(
        message: 'Pro',
        location: BannerLocation.topStart,
        color: Colors.purple,
        child: IgnorePointer(child: tile),
      ),
      onTap: () {
        Navigator.pushNamed(context, "/purchase");
      },
    );
  }
}
