"""Materialize CI signing inputs without exposing passwords in commands or logs."""
import base64
import os
from pathlib import Path

names = ['RTCI_KEYSTORE_BASE64', 'RTCI_STORE_PASSWORD', 'RTCI_KEY_PASSWORD', 'RTCI_KEY_ALIAS']
values = {name: os.environ.get(name, '') for name in names}
if not all(values.values()):
    raise SystemExit('Configure the Android release signing secrets in the protected GitHub environment.')
for name in names[1:]:
    if any(character in values[name] for character in ['\r', '\n', '\0']):
        raise SystemExit('Signing inputs must be single-line values.')
try:
    keystore = base64.b64decode(values['RTCI_KEYSTORE_BASE64'], validate=True)
except ValueError:
    raise SystemExit('The release keystore must be valid base64.') from None
if not keystore:
    raise SystemExit('An empty keystore cannot sign a release.')
root = Path(__file__).resolve().parents[1]
store = root / 'android/app/ci-upload-keystore.jks'
config = root / 'android/key.properties'
# Refuse to replace a developer's existing local signing configuration.
if config.exists() or store.exists():
    raise SystemExit('Refusing to overwrite existing signing files.')

def properties(value):
    return ''.join('\\u%04x' % ord(char) if ord(char) > 126 or char in '\\=:#! ' else char for char in value)

store.write_bytes(keystore)
store.chmod(0o600)
config.write_text('\n'.join([
    'storeFile=ci-upload-keystore.jks',
    'storePassword=' + properties(values['RTCI_STORE_PASSWORD']),
    'keyPassword=' + properties(values['RTCI_KEY_PASSWORD']),
    'keyAlias=' + properties(values['RTCI_KEY_ALIAS']),
]) + '\n')
config.chmod(0o600)
print('Temporary release signing files prepared.')
