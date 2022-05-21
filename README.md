# Xperia X Android 10.0 Docker build

> Forked from https://github.com/chris42/android_build

Scripts and Docker image to build Sony AOSP for Sony Xperia X (platform: Loire, codename: suzu).

* https://github.com/sonyxperiadev/device-sony-loire
* https://github.com/sonyxperiadev/device-sony-suzu
* https://github.com/sonyxperiadev/local_manifests

## Instructions

* https://developer.sony.com/develop/open-devices/guides/aosp-build-instructions/build-aosp-android-android-10-0-0
* https://github.com/sonyxperiadev/bug_tracker/issues/536

## Building

```bash
docker build \
  --tag android:10.0-xperia \
  --build-arg GIT_USER=github \
  --build-arg GIT_EMAIL=github@linskeseder.com \
  ./xperia

docker run \
  --interactive \
  --tty \
  --volume ${PWD}/android/aosp:/root/aosp \
  --volume ${PWD}/android/ccache:/root/ccache \
  android:10.0-xperia bash
  
./build-10-4.9.sh
```

## Flashing

```bash
docker run \
  --interactive \
  --tty \
  --privileged \
  --volume ${PWD}/android/aosp:/root/aosp \
  --volume /dev/bus/usb:/dev/bus/usb \
  android:10.0-xperia bash
```

In order to install Gapps, a custom recovery image has to be flashed:

* Download `twrp-3.6.1_9-0-suzu.img` from https://twrp.me/sony/sonyxperiax.html
* Download NikGApps from https://nikgapps.com/downloads
* Start device in fastboot mode by pressing volume up while inserting the USB cable
* Flash image via `fastboot flash recovery twrp-3.6.1_9-0-suzu.img`
* Boot in recovery by pressing volume down while pressing power
* Go to "Advanced" and sideload: `adb sideload NikGapps-omni-arm64-10-20220421-signed.zip`

Software binaries: https://developer.sony.com/file/download/software-binaries-for-aosp-pie-android-9-0-kernel-4-9-loire/

```bash
# Start device in fastboot mode by pressing volume up while inserting the USB cable
# When the device is in fastboot-mode, the LED on the device will be illuminated in blue.
fastboot devices
# Follow instructions on https://developer.sony.com/develop/open-devices/guides/aosp-build-instructions/build-aosp-android-android-10-0-0#tutorial-step-8
fastboot reboot
```
