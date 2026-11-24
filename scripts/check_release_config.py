"""Checks committed release settings without reading signing secrets or live data."""
from pathlib import Path
import json
import plistlib
import re
import xml.etree.ElementTree as ET

root = Path(__file__).resolve().parents[1]
errors = []
def check(condition, message):
    if not condition:
        errors.append(message)

manifest = ET.parse(root / 'android/app/src/main/AndroidManifest.xml').getroot()
android = '{http://schemas.android.com/apk/res/android}'
app = manifest.find('application')
check(app.get(android + 'allowBackup') == 'false', 'Android backup must be disabled for account data.')
check(app.get(android + 'usesCleartextTraffic') == 'false', 'Android cleartext network traffic must be disabled.')
permissions = {p.get(android + 'name') for p in manifest.findall('uses-permission')}
check('android.permission.POST_NOTIFICATIONS' in permissions, 'Declare Android notification permission.')
plist = plistlib.loads((root / 'ios/Runner/Info.plist').read_bytes())
for key in ['NSCameraUsageDescription', 'NSPhotoLibraryUsageDescription']:
    check(bool(plist.get(key)), f'iOS needs {key} for photo uploads.')
check(plist.get('CFBundleDisplayName') == 'RTCI Connect', 'Use the release display name on iOS.')
project = (root / 'ios/Runner.xcodeproj/project.pbxproj').read_text()
check(all(float(v) >= 15 for v in re.findall(r'IPHONEOS_DEPLOYMENT_TARGET = ([\d.]+)', project)), 'Firebase requires iOS 15+.')
check('CODE_SIGN_ENTITLEMENTS = Runner/Runner.entitlements;' in project, 'Configure iOS push entitlement.')
config = json.loads((root / 'firebase.json').read_text())
check(config.get('storage', {}).get('rules') == 'storage.rules', 'Storage rules must be deployed explicitly.')
check(config.get('firestore', {}).get('rules') == 'firestore.rules', 'Firestore rules must be deployed explicitly.')
gradle = (root / 'android/app/build.gradle.kts').read_text()
check('signingConfigs.getByName("debug")' not in gradle, 'A release cannot fall back to debug signing.')
check('keystorePropertiesFile.exists()' in gradle, 'Fail release builds without signing configuration.')
check(
    'A9:70:60:36:51:26:B2:9A:F5:21:B6:30:89:00:A6:E0:8E:F3:2A:97' in gradle,
    'Pin release builds to the Google Play upload certificate.',
)
check((root / 'assets/fonts/OFL.txt').is_file(), 'Include the bundled font license.')
if errors:
    raise SystemExit('\n'.join(errors))

# Keep store-facing policy pages and in-app support links aligned.
assert (root / 'public/privacy/index.html').read_bytes() == (root / 'privacy_policy.html').read_bytes(), 'Privacy policy copies must match.'
for path in (root / 'public').rglob('*.html'):
    text = path.read_text()
    assert 'ea6971684@gmail.com' in text, f'Missing configured support contact: {path.name}'
    assert 'support@rtci.org' not in text, 'Remove the former placeholder contact.'

print('Release source configuration checks passed. Live setup and signed-device QA are separate gates.')
