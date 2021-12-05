library config.global;

import 'package:shared_preferences/shared_preferences.dart';

import 'package:chuckapi/theme.dart';

MyTheme currentTheme = MyTheme();
SharedPreferences prefs = SharedPreferences.getInstance() as SharedPreferences;
