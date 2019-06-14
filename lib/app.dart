import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:journal/apis/git.dart';
import 'package:journal/screens/home_screen.dart';
import 'package:journal/screens/settings_screen.dart';
import 'package:journal/settings.dart';
import 'package:journal/state_container.dart';
import 'package:journal/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/githostsetup_screens.dart';
import 'screens/onboarding_screens.dart';

class JournalApp extends StatelessWidget {
  static Future main() async {
    var pref = await SharedPreferences.getInstance();
    JournalApp.preferences = pref;

    var localGitRepoConfigured =
        pref.getBool("localGitRepoConfigured") ?? false;
    var remoteGitRepoConfigured =
        pref.getBool("remoteGitRepoConfigured") ?? false;
    var localGitRepoPath = pref.getString("localGitRepoPath") ?? "";
    var remoteGitRepoFolderName = pref.getString("remoteGitRepoPath") ?? "";
    var remoteGitRepoSubFolder = pref.getString("remoteGitRepoSubFolder") ?? "";
    var onBoardingCompleted = pref.getBool("onBoardingCompleted") ?? false;

    print(" ---- Settings ---- ");
    print("localGitRepoConfigured: $localGitRepoConfigured");
    print("remoteGitRepoConfigured: $remoteGitRepoConfigured");
    print("localGitRepoPath: $localGitRepoPath");
    print("remoteGitRepoFolderName: $remoteGitRepoFolderName");
    print("remoteGitRepoSubFolder: $remoteGitRepoSubFolder");
    print("onBoardingCompleted: $onBoardingCompleted");
    print(" ------------------ ");

    _enableAnalyticsIfPossible();

    if (localGitRepoConfigured == false) {
      // FIXME: What about exceptions!
      localGitRepoPath = "journal_local";
      await gitInit(localGitRepoPath);

      localGitRepoConfigured = true;

      pref.setBool("localGitRepoConfigured", localGitRepoConfigured);
      pref.setString("localGitRepoPath", localGitRepoPath);
    }

    var dir = await getGitBaseDirectory();

    Settings.instance.load(pref);

    runApp(StateContainer(
      localGitRepoConfigured: localGitRepoConfigured,
      remoteGitRepoConfigured: remoteGitRepoConfigured,
      localGitRepoPath: localGitRepoPath,
      remoteGitRepoFolderName: remoteGitRepoFolderName,
      remoteGitRepoSubFolder: remoteGitRepoSubFolder,
      gitBaseDirectory: dir.path,
      onBoardingCompleted: onBoardingCompleted,
      child: JournalApp(),
    ));
  }

  static void _enableAnalyticsIfPossible() async {
    //
    // Check if in debugMode or not a real device
    //
    assert(JournalApp.isInDebugMode = true);

    var isPhysicalDevice = true;
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        var info = await deviceInfo.androidInfo;
        isPhysicalDevice = info.isPhysicalDevice;
      } else if (Platform.isIOS) {
        var info = await deviceInfo.iosInfo;
        isPhysicalDevice = info.isPhysicalDevice;
      }
    } catch (e) {
      print(e);
    }

    if (isPhysicalDevice == false) {
      print("Not running in a physcial device");
      JournalApp.isInDebugMode = true;
    }

    bool should = (JournalApp.isInDebugMode == false);
    should = should && (await shouldEnableAnalytics());

    print("Analytics Collection: $should");
    JournalApp.analytics.setAnalyticsCollectionEnabled(should);
  }

  static FirebaseAnalytics analytics = FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  static bool isInDebugMode = false;
  static SharedPreferences preferences;

  @override
  Widget build(BuildContext context) {
    var stateContainer = StateContainer.of(context);

    var initialRoute = '/';
    if (!stateContainer.appState.onBoardingCompleted) {
      initialRoute = '/onBoarding';
    }

    return MaterialApp(
      key: ValueKey("App"),
      title: 'GitJournal',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xFF66bb6a),
        primaryColorLight: Color(0xFF98ee99),
        primaryColorDark: Color(0xFF338a3e),
        accentColor: Color(0xff6d4c41),
      ),
      navigatorObservers: <NavigatorObserver>[JournalApp.observer],
      initialRoute: initialRoute,
      routes: {
        '/': (context) => HomeScreen(),
        '/settings': (context) => SettingsScreen(),
        '/setupRemoteGit': (context) =>
            GitHostSetupScreen(stateContainer.completeGitHostSetup),
        '/onBoarding': (context) =>
            OnBoardingScreen(stateContainer.completeOnBoarding),
      },
      debugShowCheckedModeBanner: false,
      //debugShowMaterialGrid: true,
    );
  }
}
