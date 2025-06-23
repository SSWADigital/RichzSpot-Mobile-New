# Add any additional ProGuard rules for your application.
#
# For more information on how to specify ProGuard rules, please go to the
# official Android developer documentation:
# https://developer.android.com/studio/build/shrink-code

# Contoh aturan untuk flutter_local_notifications jika diperlukan (jarang)
-keep class io.flutter.plugins.localnotifications.* { *; }

# Aturan untuk menyimpan sumber daya raw (jika diperlukan, untuk jaga-jaga)
# Anda bisa hapus baris ini, atau komentar seperti di bawah:
#-keepresources raw/**