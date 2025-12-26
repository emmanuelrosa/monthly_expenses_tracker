{ lib
, flutter
, xdg-user-dirs
, targetFlutterPlatform ? "linux"
}:
flutter.buildFlutterApplication rec {
  pname = "monthly-expenses-tracker-${targetFlutterPlatform}";
  version = "1.0.0";
  src = ../..;
  inherit targetFlutterPlatform;
  pubspecLock = lib.importJSON "${src}/pubspec.lock.json";
  extraWrapProgramArgs = if targetFlutterPlatform == "linux" then "--set PATH ${lib.makeBinPath [ xdg-user-dirs ]}" else "";

  postInstall = if targetFlutterPlatform == "linux" then "mv $out/bin/monthly_expenses_tracker $out/bin/monthly-expenses-tracker" else "";

  meta = {
    homepage = "https://github.com/emmanuelrosa/monthly_expenses_tracker";
    description = "A simple expenses tracker, written in Flutter";
    mainProgram = "monthly-expenses-tracker";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ emmanuelrosa ];
  };
}
