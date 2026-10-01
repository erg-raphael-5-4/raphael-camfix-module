# raphael MIUI Camera fix (test module)

KernelSU module used to test fixes for the Leica 5.0 port of MIUI Camera on
raphael without rebuilding the ROM. KernelSU Next 3.x only mounts module
files through a metamodule, so one (e.g. meta-overlayfs) must be installed.

    ./build.sh
    adb push out/raphael-camfix-<ver>.zip /data/local/tmp/
    adb shell su -c 'ksud module install /data/local/tmp/raphael-camfix-<ver>.zip'

Once a fix is confirmed it moves into the ROM trees.
