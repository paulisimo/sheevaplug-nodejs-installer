#!/usr/bin/env bash
# install packages
sudo aptitude install build-essential openssl libssl-dev
# download nodejs source code
orig_dir=$(pwd)
work_dir=/tmp
cd $work_dir
rm -rf $work_dir/node-v0.10.10
wget -O - http://nodejs.org/dist/v0.10.10/node-v0.10.10.tar.gz|tar xz
# patch files
patch_dir=$work_dir/node-v0.10.10/deps/v8/
p1=$patch_dir/SConstruct.patch
p2=$patch_dir/src_arm_macro.patch
echo "--- SConstruct	2013-06-04 15:13:46.000000000 -0400
+++ ../../../node-v0.10.10-custom/deps/v8/SConstruct	2013-06-04 15:13:46.000000000 -0400
@@ -80,8 +80,8 @@
   },
   'gcc': {
     'all': {
-      'CCFLAGS':      ['\$DIALECTFLAGS', '\$WARNINGFLAGS'],
-      'CXXFLAGS':     ['-fno-rtti', '-fno-exceptions'],
+      'CCFLAGS':      ['\$DIALECTFLAGS', '\$WARNINGFLAGS', '-march=armv5t', '-mthumb-interwork'],
+      'CXXFLAGS':     ['-fno-rtti', '-fno-exceptions', '-march=armv5t', '-mthumb-interwork'],
     },
     'visibility:hidden': {
       # Use visibility=default to disable this.
@@ -159,11 +159,11 @@
       },
       'armeabi:softfp' : {
         'CPPDEFINES' : ['USE_EABI_HARDFLOAT=0'],
-        'vfp3:on': {
-          'CPPDEFINES' : ['CAN_USE_VFP_INSTRUCTIONS']
-        },
+#        'vfp3:on': {
+#          'CPPDEFINES' : ['CAN_USE_VFP_INSTRUCTIONS']
+#        },
         'simulator:none': {
-          'CCFLAGS':     ['-mfloat-abi=softfp'],
+          'CCFLAGS':     ['-mfloat-abi=soft'],
         }
       },
       'armeabi:hard' : {
" > $p1

echo "--- src/arm/macro-assembler-arm.cc	2013-06-04 15:13:46.000000000 -0400
+++ ../../../node-v0.10.10-custom/deps/v8/src/arm/macro-assembler-arm.cc	2013-06-04 15:13:46.000000000 -0400
@@ -61,9 +61,9 @@
 // We do not support thumb inter-working with an arm architecture not supporting
 // the blx instruction (below v5t).  If you know what CPU you are compiling for
 // you can use -march=armv7 or similar.
-#if defined(USE_THUMB_INTERWORK) && !defined(CAN_USE_THUMB_INSTRUCTIONS)
-# error \"For thumb inter-working we require an architecture which supports blx\"
-#endif
+//#if defined(USE_THUMB_INTERWORK) && !defined(CAN_USE_THUMB_INSTRUCTIONS)
+//# error \"For thumb inter-working we require an architecture which supports blx\"
+//#endif
 
 
 // Using bx does not yield better code, so use it only when required
" > $p2
cd $patch_dir
patch -p0 < $p1
patch -p0 < $p2

# configure, make and install
cd ../..
./configure && make && sudo make install
cd $orig_dir
