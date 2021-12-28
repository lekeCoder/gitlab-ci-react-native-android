# gitlab-ci-react-native-android
This Docker image contains react-native and the Android SDK and most common packages necessary for building Android apps in a CI tool like GitLab CI.

## Build Environment
Ubuntu=20.0.4</br>ANDROID_BUILD_VERSION=30<br> ANDROID_TOOLS_VERSION=30.0.3</br>NDK_VERSION=20.1.5948944 NODE_VERSION=14.x</br> WATCHMAN_VERSION=4.9.0<br> JAVA_VERION=11</br> FASTLANE

## TODO
Whenever a new commit is pushed, a new image is automatically built on docker hub as (branch master):

lekedocker/gitlab-ci-react-native_image:latest

## Appreciations
<a href="https://github.com/liven-tech/dockerfile-gitlab-ci-react-native-android">liven-tech</a><br/>
<a href="https://github.com/SimonSimya/gitlab-ci-react-native-android">SimonSimya</a>
