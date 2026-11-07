# system_source_test_app

A minimal Flutter app, used only by CI, that runs the platform-agnostic
`SystemDateTimeZoneSource` checks (`../system_source_checks`) with
Time Machine initialized from Flutter's asset bundle, on every platform Flutter
supports: Android, iOS, Windows, Linux, macOS and the web.

```sh
flutter pub get
# Android, iOS and desktop
flutter test integration_test -d <device> \
  --dart-define=TIME_MACHINE_EXPECT_SYSTEM_TIME_ZONE=<the device's zone>
# Web (needs chromedriver, or safaridriver on macOS, on port 4444)
flutter drive -d web-server --browser-name=chrome \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/system_source_test.dart
```

See `azure-pipelines.yaml` and `.github/workflows/sanity.yaml`. It isn't part of
the published package.
