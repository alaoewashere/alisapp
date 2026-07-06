#!/usr/bin/env python3
"""Merge shared UI l10n keys into all ARB files."""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent / "lib" / "l10n"

NEW_KEYS = {
    "homeHeroBuySell": {
        "ar": "اشتري و بيع",
        "en": "Buy & sell",
        "ku": "بکڕە و بفرۆشە",
        "tr": "Al ve sat",
    },
    "homeHeroEasily": {
        "ar": "بسهولة.",
        "en": "with ease.",
        "ku": "بە ئاسانی.",
        "tr": "kolayca.",
    },
    "homeHeroSubtitle": {
        "ar": "اعثر على أفضل العروض بين يديك",
        "en": "Find the best deals at your fingertips",
        "ku": "باشترین دەستکەوتەکان بدۆزەرەوە",
        "tr": "En iyi fırsatları avucunuzun içinde bulun",
    },
    "homeExtendedSearchHint": {
        "ar": "ابحث عن سيارات، شقق، إلكترونيات...",
        "en": "Search cars, apartments, electronics...",
        "ku": "گەڕان بۆ ئۆتۆمبێل، شوقە، ئەلیکترۆنی...",
        "tr": "Araç, daire, elektronik ara...",
    },
    "browseCategories": {
        "ar": "تصفح الفئات",
        "en": "Browse categories",
        "ku": "گەڕان لە پۆلەکان",
        "tr": "Kategorilere göz at",
    },
    "viewAll": {
        "ar": "عرض الكل",
        "en": "View all",
        "ku": "هەمووی ببینە",
        "tr": "Tümünü gör",
    },
    "featuredListingsTitle": {
        "ar": "إعلانات مميزة",
        "en": "Featured listings",
        "ku": "ڕێکلامە تایبەتەکان",
        "tr": "Öne çıkan ilanlar",
    },
    "latestListingsTitle": {
        "ar": "أحدث النشرات والمعروضات",
        "en": "Latest listings",
        "ku": "نوێترین ڕێکلامەکان",
        "tr": "En yeni ilanlar",
    },
    "failedLoadCategories": {
        "ar": "فشل تحميل التصنيفات",
        "en": "Failed to load categories",
        "ku": "بارکردنی پۆلەکان سەرکەوتوو نەبوو",
        "tr": "Kategoriler yüklenemedi",
    },
    "failedLoadListings": {
        "ar": "فشل تحميل الإعلانات",
        "en": "Failed to load listings",
        "ku": "بارکردنی ڕێکلامەکان سەرکەوتوو نەبوو",
        "tr": "İlanlar yüklenemedi",
    },
    "searchResultsCount": {
        "ar": "{count} نتائج",
        "en": "{count} results",
        "ku": "{count} ئەنجام",
        "tr": "{count} sonuç",
        "placeholders": {"count": {"type": "String"}},
    },
    "heatmapTooltip": {
        "ar": "كثافة الإعلانات",
        "en": "Listing density map",
        "ku": "چڕی ڕێکلامەکان",
        "tr": "İlan yoğunluğu",
    },
    "favoritesTooltip": {
        "ar": "المفضلة",
        "en": "Favorites",
        "ku": "دڵخوازەکان",
        "tr": "Favoriler",
    },
    "splashTagline": {
        "ar": "تطبيقك الأول للبيع والشراء",
        "en": "Your go-to app for buying and selling",
        "ku": "ئەپەکەت بۆ کڕین و فرۆشتن",
        "tr": "Alım satım için birinci uygulamanız",
    },
    "welcomeToSouqak": {
        "ar": "مرحباً بك في سـوقك",
        "en": "Welcome to SOUQAK",
        "ku": "بەخێربێیت بۆ SOUQAK",
        "tr": "SOUQAK'a hoş geldiniz",
    },
    "chooseYourLanguage": {
        "ar": "اختر لغتك",
        "en": "Choose your language",
        "ku": "زمانەکەت هەڵبژێرە",
        "tr": "Dilinizi seçin",
    },
    "languageChangeHint": {
        "ar": "يمكنك تغيير اللغة في أي وقت من الإعدادات",
        "en": "You can change the language anytime in Settings",
        "ku": "دەتوانیت زمان لە هەر کاتێکدا لە ڕێکخستنەکان بگۆڕیت",
        "tr": "Dili istediğiniz zaman Ayarlar'dan değiştirebilirsiniz",
    },
    "skip": {
        "ar": "تخطي",
        "en": "Skip",
        "ku": "تێپەڕاندن",
        "tr": "Atla",
    },
    "createAccount": {
        "ar": "إنشاء حساب",
        "en": "Create account",
        "ku": "دروستکردنی هەژمار",
        "tr": "Hesap oluştur",
    },
    "signUpOverline": {
        "ar": "أنشئ حسابك",
        "en": "Create your account",
        "ku": "هەژمارەکەت دروست بکە",
        "tr": "Hesabını oluştur",
    },
    "createAccountTitle": {
        "ar": "إنشاء حساب",
        "en": "Create account",
        "ku": "دروستکردنی هەژمار",
        "tr": "Hesap oluştur",
    },
    "firstName": {
        "ar": "الاسم الأول",
        "en": "First name",
        "ku": "ناوی یەکەم",
        "tr": "Ad",
    },
    "lastName": {
        "ar": "الاسم الأخير",
        "en": "Last name",
        "ku": "ناوی کۆتایی",
        "tr": "Soyad",
    },
    "emailLabel": {
        "ar": "البريد الإلكتروني",
        "en": "Email",
        "ku": "ئیمەیڵ",
        "tr": "E-posta",
    },
    "passwordLabel": {
        "ar": "كلمة المرور",
        "en": "Password",
        "ku": "وشەی نهێنی",
        "tr": "Şifre",
    },
    "confirmPasswordLabel": {
        "ar": "تأكيد كلمة المرور",
        "en": "Confirm password",
        "ku": "پشتڕاستکردنەوەی وشەی نهێنی",
        "tr": "Şifreyi onayla",
    },
    "alreadyHaveAccount": {
        "ar": "لديك حساب بالفعل؟ ",
        "en": "Already have an account? ",
        "ku": "هەژمارت هەیە؟ ",
        "tr": "Zaten hesabın var mı? ",
    },
    "signInLink": {
        "ar": "سجّل دخولك",
        "en": "Sign in",
        "ku": "بچۆ ژوورەوە",
        "tr": "Giriş yap",
    },
    "signUpAgreementPrefix": {
        "ar": "بالتسجيل، أنت توافق على ",
        "en": "By signing up, you agree to the ",
        "ku": "بە تۆمارکردن، ڕازیت لە ",
        "tr": "Kaydolarak şunları kabul etmiş olursunuz: ",
    },
    "termsLink": {
        "ar": "شروط الاستخدام",
        "en": "Terms of Use",
        "ku": "مەرجەکانی بەکارهێنان",
        "tr": "Kullanım Şartları",
    },
    "andConnector": {
        "ar": " و",
        "en": " and ",
        "ku": " و ",
        "tr": " ve ",
    },
    "privacyLink": {
        "ar": "سياسة الخصوصية",
        "en": "Privacy Policy",
        "ku": "سیاسەتی تایبەتمەندی",
        "tr": "Gizlilik Politikası",
    },
    "welcomeBack": {
        "ar": "مرحباً بك",
        "en": "Welcome back",
        "ku": "بەخێربێیتەوە",
        "tr": "Tekrar hoş geldin",
    },
    "forgotPassword": {
        "ar": "نسيت كلمة المرور؟",
        "en": "Forgot password?",
        "ku": "وشەی نهێنیت لەبیرچووە؟",
        "tr": "Şifreni mi unuttun?",
    },
    "noAccountYet": {
        "ar": "ليس لديك حساب؟ ",
        "en": "Don't have an account? ",
        "ku": "هەژمارت نییە؟ ",
        "tr": "Hesabın yok mu? ",
    },
    "signUpNow": {
        "ar": "سجّل الآن",
        "en": "Sign up now",
        "ku": "ئێستا تۆمار ببە",
        "tr": "Hemen kaydol",
    },
    "firstNameHint": {
        "ar": "محمد",
        "en": "Mohammed",
        "ku": "محمد",
        "tr": "Mehmet",
    },
    "lastNameHint": {
        "ar": "أحمد",
        "en": "Ahmed",
        "ku": "ئەحمەد",
        "tr": "Ahmet",
    },
    "understood": {
        "ar": "فهمت",
        "en": "Got it",
        "ku": "تێگەیشتم",
        "tr": "Anladım",
    },
    "heatmapTutorialTitle": {
        "ar": "اكتشف كثافة الإعلانات في منطقتك على الخريطة",
        "en": "See listing density in your area on the map",
        "ku": "چڕی ڕێکلامەکان لە ناوچەکەت لەسەر نەخشە ببینە",
        "tr": "Bölgenizdeki ilan yoğunluğunu haritada keşfedin",
    },
    "heatmapTutorialSubtitle": {
        "ar": "اضغط على أيقونة الخريطة لعرض المناطق الأكثر نشاطاً",
        "en": "Tap the map icon to view the most active areas",
        "ku": "ئایکۆنی نەخشە دابگرە بۆ بینینی چالاکترین ناوچەکان",
        "tr": "En aktif bölgeleri görmek için harita simgesine dokunun",
    },
    "smartAlertsTutorialTitle": {
        "ar": "حدد معايير بحثك مرة واحدة واستلم إشعاراً فورياً عند نشر إعلان جديد يطابقها",
        "en": "Set your search criteria once and get notified when a matching listing is posted",
        "ku": "پێوەرەکانی گەڕان یەکجار دابنێ و ئاگادار ببەرەوە کاتێک ڕێکلامێکی نوێ دەگونجێت",
        "tr": "Arama kriterlerinizi bir kez belirleyin; eşleşen ilan yayınlandığında bildirim alın",
    },
    "smartAlertsTutorialSubtitle": {
        "ar": "اضغط على أيقونة الجرس لإدارة تنبيهاتك الذكية",
        "en": "Tap the bell icon to manage your smart alerts",
        "ku": "ئایکۆنی زەنگ دابگرە بۆ بەڕێوەبردنی ئاگادارکردنەوەکان",
        "tr": "Akıllı uyarılarınızı yönetmek için zil simgesine dokunun",
    },
    "agreeToTerms": {
        "ar": "أوافق على الشروط",
        "en": "I agree to the terms",
        "ku": "ڕازیم بە مەرجەکان",
        "tr": "Şartları kabul ediyorum",
    },
    "agreeToPrivacy": {
        "ar": "أوافق على سياسة الخصوصية",
        "en": "I agree to the privacy policy",
        "ku": "ڕازیم بە سیاسەتی تایبەتمەندی",
        "tr": "Gizlilik politikasını kabul ediyorum",
    },
    "continueWithPhone": {
        "ar": "متابعة برقم الهاتف",
        "en": "Continue with phone",
        "ku": "بەردەوامبوون بە ژمارەی مۆبایل",
        "tr": "Telefonla devam et",
    },
    "phoneOtpHint": {
        "ar": "سنرسل لك رمز تحقق عبر واتساب",
        "en": "We will send you a verification code via WhatsApp",
        "ku": "کۆدی پشتڕاستکردنەوە لە ڕێگەی واتساپ دەنێرین",
        "tr": "WhatsApp üzerinden doğrulama kodu göndereceğiz",
    },
    "sendCode": {
        "ar": "إرسال الرمز",
        "en": "Send code",
        "ku": "ناردنی کۆد",
        "tr": "Kodu gönder",
    },
    "otpSentTo": {
        "ar": "أرسلنا رمزاً إلى\n{phone}",
        "en": "We sent a code to\n{phone}",
        "ku": "کۆدێکمان نارد بۆ\n{phone}",
        "tr": "Kodu şu numaraya gönderdik:\n{phone}",
        "placeholders": {"phone": {"type": "String"}},
    },
    "otpResendIn": {
        "ar": "إعادة الإرسال خلال {seconds} ث",
        "en": "Resend in {seconds}s",
        "ku": "دووبارە ناردن لە {seconds} چ",
        "tr": "{seconds} sn içinde tekrar gönder",
        "placeholders": {"seconds": {"type": "String"}},
    },
    "otpCanResendNow": {
        "ar": "يمكنك إعادة إرسال الرمز",
        "en": "You can resend the code",
        "ku": "دەتوانیت کۆد دووبارە بنێریت",
        "tr": "Kodu tekrar gönderebilirsiniz",
    },
    "otpNotReceived": {
        "ar": "لم يصلك الرمز؟",
        "en": "Didn't receive the code?",
        "ku": "کۆدەکەت نەگەیشت؟",
        "tr": "Kod gelmedi mi?",
    },
    "otpHelpText": {
        "ar": "• تأكد أن الرقم {phone} صحيح\n• انتظر حتى دقيقة — قد يتأخر SMS\n• Twilio: أضف رقمك في Sender Pool لخدمة souqiq-otp\n• يجب تفعيل مزود SMS (Twilio أو MessageBird) في Supabase\n• للتطوير: أضف رقمك كـ Test OTP في لوحة Supabase\n• راجع supabase/README.md — قسم Phone OTP",
        "en": "• Make sure {phone} is correct\n• Wait up to a minute — SMS may be delayed\n• Twilio: add your number to the souqiq-otp Sender Pool\n• Enable an SMS provider (Twilio or MessageBird) in Supabase\n• For development: add your number as Test OTP in Supabase\n• See supabase/README.md — Phone OTP section",
        "ku": "• دڵنیابە {phone} دروستە\n• چەند خولەکێک چاوەڕێ بکە — SMS دەکرێت دواکەوت بێت\n• Twilio: ژمارەکەت زیاد بکە بۆ Sender Pool بۆ souqiq-otp\n• دابینکەری SMS (Twilio یان MessageBird) لە Supabase چالاک بکە\n• بۆ گەشەپێدان: ژمارەکەت وەک Test OTP لە Supabase زیاد بکە\n• supabase/README.md — بەشی Phone OTP ببینە",
        "tr": "• {phone} numarasının doğru olduğundan emin olun\n• Bir dakika bekleyin — SMS gecikebilir\n• Twilio: souqiq-otp için numaranızı Sender Pool'a ekleyin\n• Supabase'de SMS sağlayıcısını (Twilio veya MessageBird) etkinleştirin\n• Geliştirme için: numaranızı Supabase'de Test OTP olarak ekleyin\n• supabase/README.md — Phone OTP bölümüne bakın",
        "placeholders": {"phone": {"type": "String"}},
    },
    "completeProfileTitle": {
        "ar": "أكمل ملفك الشخصي",
        "en": "Complete your profile",
        "ku": "پرۆفایلەکەت تەواو بکە",
        "tr": "Profilinizi tamamlayın",
    },
    "tapToChooseAvatar": {
        "ar": "اضغط لاختيار صورتك الرمزية",
        "en": "Tap to choose your avatar",
        "ku": "دابگرە بۆ هەڵبژاردنی وێنەی خۆت",
        "tr": "Avatarınızı seçmek için dokunun",
    },
    "profileNameReadError": {
        "ar": "تعذّر قراءة الاسم من الحساب. سجّل الدخول مجدداً.",
        "en": "Could not read your name from the account. Please sign in again.",
        "ku": "نەتوانرا ناو لە هەژمارەوە بخوێنرێتەوە. دووبارە بچۆ ژوورەوە.",
        "tr": "Hesaptan ad okunamadı. Lütfen tekrar giriş yapın.",
    },
    "sessionExpiredPleaseLogin": {
        "ar": "انتهت جلستك، يرجى تسجيل الدخول مجدداً",
        "en": "Your session expired. Please sign in again.",
        "ku": "دانیشتنەکەت بەسەرچوو، تکایە دووبارە بچۆ ژوورەوە",
        "tr": "Oturumunuz sona erdi. Lütfen tekrar giriş yapın.",
    },
    "back": {
        "ar": "رجوع",
        "en": "Back",
        "ku": "گەڕانەوە",
        "tr": "Geri",
    },
    "searchInSouqak": {
        "ar": "ابحث في سـوقك",
        "en": "Search SOUQAK",
        "ku": "لە SOUQAK بگەڕێ",
        "tr": "SOUQAK'ta ara",
    },
    "mySmartAlertsTooltip": {
        "ar": "تنبيهاتي الذكية",
        "en": "My smart alerts",
        "ku": "ئاگادارکردنەوەکانی من",
        "tr": "Akıllı uyarılarım",
    },
    "filtersTooltip": {
        "ar": "الفلاتر",
        "en": "Filters",
        "ku": "فلتەرەکان",
        "tr": "Filtreler",
    },
    "noSuggestions": {
        "ar": "لا توجد اقتراحات",
        "en": "No suggestions",
        "ku": "پێشنیار نییە",
        "tr": "Öneri yok",
    },
    "searchForQuery": {
        "ar": "بحث عن \"{query}\"",
        "en": "Search for \"{query}\"",
        "ku": "گەڕان بۆ \"{query}\"",
        "tr": "\"{query}\" ara",
        "placeholders": {"query": {"type": "String"}},
    },
    "shareCardFailed": {
        "ar": "تعذّر إنشاء البطاقة، حاول مرة أخرى",
        "en": "Could not create share card. Try again.",
        "ku": "نەتوانرا کارت دروست بکرێت، دووبارە هەوڵ بدەرەوە",
        "tr": "Paylaşım kartı oluşturulamadı. Tekrar deneyin.",
    },
    "followersLabel": {
        "ar": "متابع",
        "en": "Followers",
        "ku": "شوێنکەوتوو",
        "tr": "Takipçi",
    },
    "myListedAds": {
        "ar": "إعلاناتي المعروضة",
        "en": "My listings",
        "ku": "ڕێکلامەکانم",
        "tr": "İlanlarım",
    },
    "mySmartAlerts": {
        "ar": "تنبيهاتي الذكية",
        "en": "My smart alerts",
        "ku": "ئاگادارکردنەوەکانی من",
        "tr": "Akıllı uyarılarım",
    },
    "defaultUser": {
        "ar": "مستخدم",
        "en": "User",
        "ku": "بەکارهێنەر",
        "tr": "Kullanıcı",
    },
    "otherSettings": {
        "ar": "إعدادات أخرى",
        "en": "Other settings",
        "ku": "ڕێکخستنەکانی تر",
        "tr": "Diğer ayarlar",
    },
    "accountDetails": {
        "ar": "تفاصيل الحساب",
        "en": "Account details",
        "ku": "وردەکاری هەژمار",
        "tr": "Hesap detayları",
    },
    "passwordSettings": {
        "ar": "كلمة المرور",
        "en": "Password",
        "ku": "وشەی نهێنی",
        "tr": "Şifre",
    },
    "aboutApp": {
        "ar": "عن التطبيق",
        "en": "About the app",
        "ku": "دەربارەی ئەپ",
        "tr": "Uygulama hakkında",
    },
    "aboutAppDescription": {
        "ar": "SOUQAK — سـوقك المحلي للإعلانات المبوبة في العراق. اشترِ وبيع بسهولة عبر تطبيق واحد.",
        "en": "SOUQAK — your local classifieds marketplace in Iraq. Buy and sell easily in one app.",
        "ku": "SOUQAK — بازاڕی ڕێکلامی ناوخۆییت لە عێراق. بە ئاسانی بکڕە و بفرۆشە لە یەک ئەپدا.",
        "tr": "SOUQAK — Irak'taki yerel ilan pazarınız. Tek uygulamada kolayca alın ve satın.",
    },
    "versionLabel": {
        "ar": "الإصدار {version}",
        "en": "Version {version}",
        "ku": "وەشان {version}",
        "tr": "Sürüm {version}",
        "placeholders": {"version": {"type": "String"}},
    },
    "helpFaq": {
        "ar": "المساعدة / الأسئلة الشائعة",
        "en": "Help / FAQ",
        "ku": "یارمەتی / پرسیارە باوەکان",
        "tr": "Yardım / SSS",
    },
    "logoutAction": {
        "ar": "خروج",
        "en": "Sign out",
        "ku": "چوونەدەرەوە",
        "tr": "Çıkış",
    },
    "logoutConfirmBodyExtended": {
        "ar": "هل أنت متأكد أنك تريد تسجيل الخروج؟",
        "en": "Are you sure you want to sign out?",
        "ku": "دڵنیایت دەتەوێت بچیتە دەرەوە؟",
        "tr": "Çıkış yapmak istediğinize emin misiniz?",
    },
    "deleteAccountConfirmBody": {
        "ar": "هل أنت متأكد أنك تريد حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.",
        "en": "Are you sure you want to delete your account? This cannot be undone.",
        "ku": "دڵنیایت دەتەوێت هەژمارەکەت بسڕیتەوە؟ ناتوانرێت ئەم کارە بگەڕێنرێتەوە.",
        "tr": "Hesabınızı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.",
    },
    "startConversation": {
        "ar": "ابدأ المحادثة",
        "en": "Start the conversation",
        "ku": "گفتوگۆ دەستپێبکە",
        "tr": "Sohbete başlayın",
    },
    "conversation": {
        "ar": "محادثة",
        "en": "Conversation",
        "ku": "گفتوگۆ",
        "tr": "Sohbet",
    },
    "viewListing": {
        "ar": "عرض الإعلان",
        "en": "View listing",
        "ku": "ڕێکلام ببینە",
        "tr": "İlanı görüntüle",
    },
    "blockUser": {
        "ar": "حظر المستخدم",
        "en": "Block user",
        "ku": "بەکارهێنەر بلۆک بکە",
        "tr": "Kullanıcıyı engelle",
    },
    "blockFeatureComingSoon": {
        "ar": "ميزة الحظر قريباً",
        "en": "Block feature coming soon",
        "ku": "تایبەتمەندی بلۆککردن بەمزوانە",
        "tr": "Engelleme özelliği yakında",
    },
    "reportConversation": {
        "ar": "الإبلاغ عن المحادثة",
        "en": "Report conversation",
        "ku": "گفتوگۆ ڕاپۆرت بکە",
        "tr": "Sohbeti bildir",
    },
    "reportReceived": {
        "ar": "تم استلام بلاغك",
        "en": "Your report was received",
        "ku": "ڕاپۆرتەکەت وەرگیرا",
        "tr": "Bildiriminiz alındı",
    },
    "onlineNow": {
        "ar": "متصل الآن",
        "en": "Online now",
        "ku": "ئێستا سەرهێڵە",
        "tr": "Şu an çevrimiçi",
    },
    "typeMessage": {
        "ar": "اكتب رسالة...",
        "en": "Type a message...",
        "ku": "پەیام بنووسە...",
        "tr": "Mesaj yazın...",
    },
    "reconnecting": {
        "ar": "جاري إعادة الاتصال...",
        "en": "Reconnecting...",
        "ku": "دووبارە پەیوەستبوونەوە...",
        "tr": "Yeniden bağlanılıyor...",
    },
    "chooseRecoveryMethod": {
        "ar": "اختر طريقة استعادة حسابك",
        "en": "Choose how to recover your account",
        "ku": "ڕێگای گەڕاندنەوەی هەژمار هەڵبژێرە",
        "tr": "Hesabınızı kurtarma yöntemini seçin",
    },
    "continueViaEmail": {
        "ar": "متابعة عبر البريد الإلكتروني",
        "en": "Continue with email",
        "ku": "بەردەوامبوون بە ئیمەیڵ",
        "tr": "E-posta ile devam et",
    },
    "linkedEmailHint": {
        "ar": "بريدك المرتبط بالحساب",
        "en": "Email linked to your account",
        "ku": "ئیمەیڵی پەیوەست بە هەژمار",
        "tr": "Hesabınıza bağlı e-posta",
    },
    "continueViaPhone": {
        "ar": "متابعة عبر الهاتف",
        "en": "Continue with phone",
        "ku": "بەردەوامبوون بە مۆبایل",
        "tr": "Telefonla devam et",
    },
    "linkedPhoneHint": {
        "ar": "هاتفك المرتبط بالحساب",
        "en": "Phone linked to your account",
        "ku": "مۆبایلی پەیوەست بە هەژمار",
        "tr": "Hesabınıza bağlı telefon",
    },
    "sendAction": {
        "ar": "إرسال",
        "en": "Send",
        "ku": "ناردن",
        "tr": "Gönder",
    },
    "emailNotRegistered": {
        "ar": "هذا البريد غير مسجل لدينا",
        "en": "This email is not registered",
        "ku": "ئەم ئیمەیڵە تۆمار نەکراوە",
        "tr": "Bu e-posta kayıtlı değil",
    },
    "phoneNotRegistered": {
        "ar": "هذا الرقم غير مسجل لدينا",
        "en": "This phone number is not registered",
        "ku": "ئەم ژمارەیە تۆمار نەکراوە",
        "tr": "Bu telefon numarası kayıtlı değil",
    },
    "otpSentViaWhatsapp": {
        "ar": "تم إرسال الرمز عبر واتساب إلى",
        "en": "A verification code was sent via WhatsApp to",
        "ku": "کۆد لە ڕێگەی واتساپ نێردرا بۆ",
        "tr": "Doğrulama kodu WhatsApp ile şuraya gönderildi:",
    },
    "otpResendCode": {
        "ar": "إعادة إرسال الرمز",
        "en": "Resend code",
        "ku": "دووبارە ناردنی کۆد",
        "tr": "Kodu tekrar gönder",
    },
    "otpVerifyButton": {
        "ar": "التحقق",
        "en": "Verify",
        "ku": "پشتڕاستکردنەوە",
        "tr": "Doğrula",
    },
    "otpInvalidCode": {
        "ar": "رمز غير صحيح",
        "en": "Incorrect code",
        "ku": "کۆد هەڵەیە",
        "tr": "Hatalı kod",
    },
    "otpVerifiedSuccess": {
        "ar": "تم التحقق بنجاح!",
        "en": "Verified successfully!",
        "ku": "بە سەرکەوتوویی پشتڕاستکرایەوە!",
        "tr": "Başarıyla doğrulandı!",
    },
    "otpSigningIn": {
        "ar": "جارٍ تسجيل الدخول...",
        "en": "Signing you in...",
        "ku": "چوونەژوورەوە...",
        "tr": "Giriş yapılıyor...",
    },
    "listingPostedToday": {
        "ar": "اليوم",
        "en": "Today",
        "ku": "ئەمڕۆ",
        "tr": "Bugün",
    },
    "listingPostedOneDayAgo": {
        "ar": "يوم واحد",
        "en": "1 day ago",
        "ku": "١ ڕۆژ",
        "tr": "1 gün önce",
    },
    "listingPostedDaysAgo": {
        "ar": "{count} يوم",
        "en": "{count} days ago",
        "ku": "{count} ڕۆژ",
        "tr": "{count} gün önce",
        "placeholders": {"count": {"type": "String"}},
    },
    "homeFeedLatestTitle": {
        "ar": "أحدث الإعلانات",
        "en": "Latest listings",
        "ku": "نوێترین ڕێکلامەکان",
        "tr": "En yeni ilanlar",
    },
}


def merge(locale: str) -> None:
    path = ROOT / f"app_{locale}.arb"
    data = json.loads(path.read_text(encoding="utf-8"))
    for key, translations in NEW_KEYS.items():
        if key.startswith("@"):
            continue
        data[key] = translations[locale]
        placeholders = translations.get("placeholders")
        if placeholders:
            data[f"@{key}"] = {"placeholders": placeholders}
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


for loc in ("ar", "en", "ku", "tr"):
    merge(loc)

print(f"Merged {len(NEW_KEYS)} keys into 4 ARB files")
