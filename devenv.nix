{ pkgs, ... }:

let
  android-comp     = pkgs.androidenv.composeAndroidPackages {
    buildToolsVersions = [ "30.0.3" ];
    platformVersions   = [ "29" "30" "31" "33" ];
  };
  android-sdk      = android-comp.androidsdk;
  android-sdk-root = "${android-sdk}/libexec/android-sdk";
in {
  env = {
    ANDROID_HOME     = "${android-sdk-root}";
    ANDROID_SDK_ROOT = "${android-sdk-root}";
  };

  languages.java = {
    enable      = true;
    jdk.package = pkgs.jdk11;
  };

  name = "mm-flutter-app";

  packages = with pkgs; [ entr android-sdk ];

  scripts.flutter-run.exec = ''
    PID_FILE="/tmp/flutter.pid"
    rm -f "$PID_FILE"

    # https://stackoverflow.com/a/2173421
    trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT
    (
        sleep 5

        while [ ! -f "$PID_FILE" ]; do
            echo "Waiting for $PID_FILE to appear..."
            sleep 5
        done

        while true; do
            find ./lib -name '*.dart' | entr -p kill -USR1 "$(cat "$PID_FILE")"
        done
    ) &

    flutter run --pid-file "$PID_FILE" </dev/tty
  '';
}
