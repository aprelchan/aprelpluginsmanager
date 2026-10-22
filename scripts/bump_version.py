import sys
import json
import re

if len(sys.argv) < 3:
    print("Usage: python bump_version.py <metainfo_path> <version> [codename]")
    sys.exit(1)

metainfo_path = sys.argv[1]
new_version = sys.argv[2]
new_codename = sys.argv[3] if len(sys.argv) > 3 else ""

with open(metainfo_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

old_version = data.get('version', '?')
old_codename = data.get('codename', '')
data['version'] = new_version
if new_codename:
    data['codename'] = new_codename

with open(metainfo_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write('\n')

files_to_update = ['apmplugin/src/methods.py', 'apmplugin/src/main.py']
for path in files_to_update:
    try:
        with open(path, 'r', encoding='utf-8') as f:
            content = f.read()

        updated = re.sub(
            r'_metainfo\.get\(\s*[\"|\']version[\"|\']\s*,\s*[\"|\'][^\"|\']+[\"|\']\s*\)',
            f'_metainfo.get("version", "{new_version}")',
            content
        )
        updated = re.sub(
            r'__version__\s*=\s*[\"|\'][^\"|\']+[\"|\']',
            f'__version__ = "{new_version}"',
            updated
        )

        if new_codename:
            escaped_codename = new_codename.replace('\\', '\\\\').replace('"', '\\"')
            updated = re.sub(
                r'_metainfo\.get\(\s*[\"|\']codename[\"|\']\s*,\s*[\"|\'][^\"|\']+[\"|\']\s*\)',
                f'_metainfo.get("codename", "{escaped_codename}")',
                updated
            )
            updated = re.sub(
                r'__codename__\s*=\s*(?:\"(?:\\.|[^\"])*\"|\'(?:\\.|[^\'])*\')',
                f'__codename__ = "{escaped_codename}"',
                updated
            )

        if updated != content:
            with open(path, 'w', encoding='utf-8') as f:
                f.write(updated)
            print(f'  updated {path}')
    except Exception as e:
        print(f'  error updating {path}: {e}')

if new_codename:
    print(f'{old_version} ({old_codename}) → {new_version} ({new_codename})')
else:
    print(f'{old_version} → {new_version}')
