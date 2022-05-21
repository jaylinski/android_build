#!/bin/bash
set -e
set -x

prepare_sources() {

    # ----------------------------------------------------------------------
    # Cleanup old patching
    # ----------------------------------------------------------------------

    if [ -d device/sony/customization ]; then
        rm -r device/sony/customization
    fi

    for path in \
        frameworks/base \
        frameworks/opt/net/wifi \
        device/sony/loire \
        device/sony/suzu \
        device/sony/common \
        device/sony/sepolicy \
        kernel/sony/msm-4.9/kernel \
        kernel/sony/msm-4.9/common-kernel
    do
        if [ -d $path ]; then
            pushd $path
                git clean -d -f -e "*dtb*"
                git reset --hard m/$TARGET_ANDROID_VERSION
            popd
        fi
    done

    # ----------------------------------------------------------------------
    # Local manifest cleanup
    # ----------------------------------------------------------------------

    pushd .repo/local_manifests
        git clean -d -f
        git fetch
        git reset --hard origin/android-10_legacy
    popd

    ./repo_update.sh

    # --------------------------------------------------------------------
    # Additional patching
    # --------------------------------------------------------------------

    pushd frameworks/opt/net/wifi
        # Prevent WifiLayerLinkStatsError
        git fetch https://github.com/LineageOS/android_frameworks_opt_net_wifi refs/changes/24/260124/3
        git cherry-pick 119f4e61cd2164a56ebc4caba8ec735e36f70422
    popd

}

# --------------------------------------------------------------------
# Main
# --------------------------------------------------------------------

start=`date +%s`

cd $WORK_DIR

# Read android branch from initialized repo
CURRENT_ANDROID_VERSION=`cat .repo/manifests/default.xml|grep default\ revision|sed 's#^.*refs/tags/\(.*\)"#\1#1'`
# See https://source.android.com/setup/start/build-numbers
TARGET_ANDROID_VERSION=android-10.0.0_r41

# Cleanup on branch change
if [[ $CURRENT_ANDROID_VERSION != $TARGET_ANDROID_VERSION ]]; then
    echo "Warning! Clean repo before continuing!"
fi

mkdir -p $WORK_DIR
cd $WORK_DIR
repo init -u https://android.googlesource.com/platform/manifest -b $TARGET_ANDROID_VERSION
pushd .repo
    git -C local_manifests pull || git clone https://github.com/sonyxperiadev/local_manifests -b android-10_legacy
popd
repo sync --current-branch --no-tags

# Only sync sources when needed
if [ $PREPARE_SOURCES = true ]; then
    prepare_sources
fi

. build/envsetup.sh
lunch $DEVICE_FLAVOUR

# Only cleanup when needed
if [ $CLEAN_BUILD = true ]; then
    make clean
fi

# Only rebuild kernel when needed
if [ $REBUILD_KERNEL = true ]; then
    pushd kernel/sony/msm-4.9/common-kernel
        PLATFORM_UPPER=`echo $PLATFORM|tr '[:lower:]' '[:upper:]'`
        sed -i "s/PLATFORMS=.*/PLATFORMS=$PLATFORM/1" build-kernels-gcc.sh
        sed -i "s/$PLATFORM_UPPER=.*/$PLATFORM_UPPER=$DEVICE/1" build-kernels-gcc.sh
        find . -name "*dtb*" -exec rm "{}" \;
        bash ./build-kernels-gcc.sh
    popd
fi

ccache make -j8 dist

echo "Compiled branch '$TARGET_ANDROID_VERSION' in: $((($(date +%s)-$start)/60)) minutes"
