# Stage 1: Build the Flutter web app static 
# files 4. Rebuild (Docker will now run pub 
# get as a proper step)FROM debian:latest 
# AS build-env
docker build -f frontend.dockerfile -t 
camvote-frontend:latest . RUN apt-get 
update && apt-get install -y curl git unzip 
xz-utils zip libglu1-mesa RUN git clone 
https://github.com/flutter/flutter.git 
--depth 1 --branch 3.41.6 
/usr/local/flutter

ENV 
PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}" 
What to Expect RUN flutter doctor RUN 
flutter config --enable-web The build will 
proceed past Step 9 this time. The next 
thing to watch for is whether lib/gen/l10n/ 
localization files exist in the repo — if 
they're gitignored and missing, the build 
will need a flutter gen-l10n step too. If 
it fails at that point, paste the output 
and I'll add that 
step./root/.pub-cache/hosted/pub.dev/printing-5.14.2/lib/src/preview/raster.dart:65:11: 
WORKDIR /app COPY pubspec.yaml pubspec.lock 
./ RUN flutter pub get COPY . . RUN flutter 
build web --no-wasm-dry-run Error: 
Superclass has no method named 'dispose'.
    super.dispose();# Stage 2: Serve the 
static files using a lightweight Nginx web 
server FROM nginx:alpine COPY 
--from=build-env /app/build/web 
/usr/share/nginx/html EXPOSE 80 CMD 
["nginx", "-g", "daemon off;"]
          ^^^^^^^ 
/root/.pub-cache/hosted/pub.dev/printing-5.14.2/lib/src/preview/raster.dart:75:20: 
Error: The getter 'MediaQuery' isn't 
defipasted5:05 AMClaude responded: Root 
Cause Identified — Flutter Version 
MismatchDiagnosed Flutter version mismatch 
causing package incompatibilitiesDiagnosed 
Flutter version mismatch causing package 
incompatibilitiesRoot Cause Identified — 
Flutter Version Mismatch This is a single 
underlying cause producing ~100 cascading 
errors. Your Dockerfile clones -b stable 
which pulled Flutter 3.44.1 / Dart 3.12.1, 
but your pubspec.lock was generated locally 
with Flutter 3.41.6. The packages in your 
lock file (printing 5.14.2, 
local_auth_android 2.0.4, flutter_map 
8.2.2, etc.) were built against an older 
Dart SDK and are binary-incompatible with 
Dart 3.12. The smoking gun is this error: 
Error: The type 'dynamic' is not 
exhaustively matched...  ← Dart 3.12 
stricter switch exhaustiveness 
'BasicMessageChannel' isn't a type ← 
Pigeon-generated code from older SDK 
'BinaryMessenger' isn't a type ← same None 
of these errors are in YOUR code — they're 
all inside the pub cache. Fixing the source 
won't help. The fix is to pin Flutter in 
the Dockerfile. The Fix — Pin Flutter 
Version in frontend.dockerfile bashnano 
frontend.dockerfile Find this line: 
dockerfileRUN git clone 
https://github.com/flutter/flutter.git -b 
stable --depth 1 /usr/local/flutter Replace 
it with: dockerfileRUN git clone 
https://github.com/flutter/flutter.git 
--depth 1 --branch 3.41.6 
/usr/local/flutter Your full corrected 
frontend.dockerfile should look like this: 
dockerfileFROM debian:latest AS build-env 
RUN apt-get update && apt-get install -y 
curl git unzip xz-utils zip libglu1-mesa
# Pin to exact version matching your local 
# dev environment
RUN git clone 
https://github.com/flutter/flutter.git 
--depth 1 --branch 3.41.6 
/usr/local/flutter ENV 
PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}" 
RUN flutter doctor RUN flutter config 
--enable-web WORKDIR /app
# Copy dependency manifest first for better layer caching
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy rest of source
COPY . .

RUN flutter build web --no-wasm-dry-run
# Serve with nginx
FROM nginx:stable-alpine COPY 
--from=build-env /app/build/web 
/usr/share/nginx/html EXPOSE 80 CMD 
["nginx", "-g", "daemon off;"] Rebuild 
Command bashdocker build -f 
frontend.dockerfile -t 
camvote-frontend:latest .
This build will take ~8–10 minutes because it re-clones Flutter. Docker layer caching means subsequent rebuilds will be much faster unless you change the Flutter version line.

What to Watch For The build should now get 
all the way through flutter build web 
cleanly. If it still fails, the only 
remaining risk is the app_theme.dart 
constructor issue from the previous sed — 
verify it looks correct before rebuilding:
bashgrep -n "CupertinoPageTransitionsBuilder" lib/core/theme/app_theme.dart
# Must show:  const CupertinoPageTransitionsBuilder(),
Paste the output if the build fails again 
and I'll triage immediately.Error: 
The method 'BasicMesthe type 
'LocalAuthApi'.
 - 'LocalAuthApi' is from 'messages.g.dart' 
 ('/root/.puth_android-2.0.4/lib/src/m
        BasicMessageChannel
        ^^^^^^^^^^^^^^^^^^^
/root/.pub-cache/hosted/pubib/src/messages.g.dart:459:
Error: The method 'Platforme type 'LocalAuthApi'.
pasted5:24 AMClaude responded: ✅ Frontend Build SUCCESSThe user prompt is empty, so I cannot determine the primary language. However, based on the thinking block alone, here is my summary:

Orchestrated deployment progression across frontend, backend, and infrastructureThe user prompt is empty, so I cannot determine the primary language. However, based on the thinking block alone, here is my summary:

Orchestrated deployment progression across frontend, backend, and infrastructure✅ Frontend Build SUCCESS
Successfully built c2d5fa3b35d5 and the container is running. That's the Flutter web app live inside Docker on port 8080.

Verify It's Working
bashcurl -I http://localhost:8080
✅ Expected: HTTP/1.1 200 OK
Then from your browser:
http://188.166.146.106:8080

Next — Deploy to K3s
The container is running standalone right now (docker run). You need to push it into K3s so it runs as managed pods. Here's the sequence:
Step 1 — Check what K3s currently has:
bashsudo k3s kubectl get all -n camvote
If the namespace doesn't exist yet:
bashsudo k3s kubectl create namespace camvote
Step 2 — Apply your deployment manifest:
bashcd ~/CamVote-Deploy/Android-Application-Development-main/End\ of\ Semester\ Project/CamVote
sudo k3s kubectl apply -f camvote-deploy.yml
Step 3 — Verify pods came up:
bashsudo k3s kubectl get pods -n camvote
sudo k3s kubectl get services -n camvote
Step 4 — Stop the standalone container (K3s takes over from here):
bashdocker stop camvote-frontend-container
docker rm camvote-frontend-container

