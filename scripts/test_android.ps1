param(
    [string]$Device = 'emulator-5554',
    [string]$TargetPlatform = 'android-x64'
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
Push-Location -LiteralPath $projectRoot
try {
    flutter build apk --debug --target integration_test/booking_app_test.dart --target-platform $TargetPlatform
    if ($LASTEXITCODE -ne 0) { throw 'Could not build the QA APK.' }

    $manifestPath = Join-Path $projectRoot 'build/app/intermediates/merged_manifests/debug/processDebugManifest/AndroidManifest.xml'
    $manifest = [xml](Get-Content -LiteralPath $manifestPath -Raw)
    if ($manifest.manifest.package -ne 'com.example.service_booking_flutter.qa') {
        throw 'Refusing to run integration tests with the main application ID.'
    }
    $builtApk = Join-Path $projectRoot 'build/app/outputs/flutter-apk/app-debug.apk'
    $qaApk = Join-Path $projectRoot 'build/app/outputs/flutter-apk/henio-qa-debug.apk'
    Copy-Item -LiteralPath $builtApk -Destination $qaApk -Force

    # Use the APK's actual package metadata, and bypass Flutter drive's uninstall
    # cleanup. Only the QA process is stopped explicitly in the finally block.
    flutter drive --driver=test_driver/integration_test.dart --target=integration_test/booking_app_test.dart --use-application-binary $qaApk --keep-app-running -d $Device
    if ($LASTEXITCODE -ne 0) { throw 'Android integration tests failed.' }
} finally {
    adb -s $Device shell am force-stop com.example.service_booking_flutter.qa
    Pop-Location
}
