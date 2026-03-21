#!/usr/bin/env bash
set -euo pipefail

flutter create . --platforms=web,ios,android
flutter pub get
flutterfire configure --project=gtrain-73d1b

echo "Next: copy generated Firebase values into lib/config/firebase_project_config.dart if you keep the custom config wrapper."
