/*
 * JNI methods the Leica port's MorphoPanoramaGP3 class declares but the
 * available libmorpho_panorama_gp3.so doesn't export. They get/set the
 * panorama direction-reversal parameters; leave the engine defaults and
 * report MORPHO_OK (0). Found by the JNI lookup through
 * libmorpho_panorama_gp3.so's DT_NEEDED on this library.
 */
#include <jni.h>

JNIEXPORT jint JNICALL
Java_com_android_camera_panorama_MorphoPanoramaGP3_nativeGetReverseParam(
        JNIEnv *env, jobject thiz, jlong handle, jdoubleArray out) {
    (void)env; (void)thiz; (void)handle; (void)out;
    return 0;
}

JNIEXPORT jint JNICALL
Java_com_android_camera_panorama_MorphoPanoramaGP3_nativeSetReverseParam(
        JNIEnv *env, jobject thiz, jlong handle, jdouble a, jdouble b) {
    (void)env; (void)thiz; (void)handle; (void)a; (void)b;
    return 0;
}
