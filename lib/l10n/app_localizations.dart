import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ku.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('ku'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'سوق العراق'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// No description provided for @favorites.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get favorites;

  /// No description provided for @messages.
  ///
  /// In ar, this message translates to:
  /// **'الرسائل'**
  String get messages;

  /// No description provided for @profile.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get profile;

  /// No description provided for @addListing.
  ///
  /// In ar, this message translates to:
  /// **'أضف إعلان'**
  String get addListing;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @signInWithGoogle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول بـ Google'**
  String get signInWithGoogle;

  /// No description provided for @browseAsGuest.
  ///
  /// In ar, this message translates to:
  /// **'تصفح بدون تسجيل'**
  String get browseAsGuest;

  /// No description provided for @guestSignInPrompt.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك للمتابعة'**
  String get guestSignInPrompt;

  /// No description provided for @guestSignInBody.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ حساباً أو سجّل الدخول لاستخدام هذه الميزة'**
  String get guestSignInBody;

  /// No description provided for @orDivider.
  ///
  /// In ar, this message translates to:
  /// **'أو'**
  String get orDivider;

  /// No description provided for @sendOtp.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الرمز'**
  String get sendOtp;

  /// No description provided for @resendOtp.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال'**
  String get resendOtp;

  /// No description provided for @verifyOtp.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز التحقق'**
  String get verifyOtp;

  /// No description provided for @confirmOtp.
  ///
  /// In ar, this message translates to:
  /// **'تحقق ومتابعة'**
  String get confirmOtp;

  /// No description provided for @enterPhone.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم هاتفك'**
  String get enterPhone;

  /// No description provided for @startNow.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الآن'**
  String get startNow;

  /// No description provided for @loginRequired.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول مطلوب'**
  String get loginRequired;

  /// No description provided for @loginRequiredBody.
  ///
  /// In ar, this message translates to:
  /// **'يجب تسجيل الدخول للمتابعة'**
  String get loginRequiredBody;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get all;

  /// No description provided for @noListings.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إعلانات حالياً'**
  String get noListings;

  /// No description provided for @noResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get noResults;

  /// No description provided for @noFavorites.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد عناصر في المفضلة'**
  String get noFavorites;

  /// No description provided for @noConversations.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد محادثات'**
  String get noConversations;

  /// No description provided for @noMyListings.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إعلانات'**
  String get noMyListings;

  /// No description provided for @contactSeller.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع البائع'**
  String get contactSeller;

  /// No description provided for @myListings.
  ///
  /// In ar, this message translates to:
  /// **'إعلاناتي'**
  String get myListings;

  /// No description provided for @postListing.
  ///
  /// In ar, this message translates to:
  /// **'نشر الإعلان'**
  String get postListing;

  /// No description provided for @profileSetup.
  ///
  /// In ar, this message translates to:
  /// **'إكمال الملف الشخصي'**
  String get profileSetup;

  /// No description provided for @profileSetupWelcome.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً! أكمل بياناتك للمتابعة'**
  String get profileSetupWelcome;

  /// No description provided for @setupRequiredTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعداد Supabase مطلوب'**
  String get setupRequiredTitle;

  /// No description provided for @pageNotFound.
  ///
  /// In ar, this message translates to:
  /// **'الصفحة غير موجودة'**
  String get pageNotFound;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @editProfile.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف الشخصي'**
  String get editProfile;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// No description provided for @changeLanguage.
  ///
  /// In ar, this message translates to:
  /// **'تغيير اللغة'**
  String get changeLanguage;

  /// No description provided for @chooseLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اختر اللغة'**
  String get chooseLanguage;

  /// No description provided for @languageArabic.
  ///
  /// In ar, this message translates to:
  /// **'🇮🇶 العربية'**
  String get languageArabic;

  /// No description provided for @languageKurdish.
  ///
  /// In ar, this message translates to:
  /// **'🇹🇯 کوردی'**
  String get languageKurdish;

  /// No description provided for @languageEnglish.
  ///
  /// In ar, this message translates to:
  /// **'🇬🇧 English'**
  String get languageEnglish;

  /// No description provided for @accountSection.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get accountSection;

  /// No description provided for @supportSection.
  ///
  /// In ar, this message translates to:
  /// **'الدعم'**
  String get supportSection;

  /// No description provided for @appSection.
  ///
  /// In ar, this message translates to:
  /// **'التطبيق'**
  String get appSection;

  /// No description provided for @actionsSection.
  ///
  /// In ar, this message translates to:
  /// **'إجراءات'**
  String get actionsSection;

  /// No description provided for @contactUs.
  ///
  /// In ar, this message translates to:
  /// **'تواصل معنا'**
  String get contactUs;

  /// No description provided for @rateApp.
  ///
  /// In ar, this message translates to:
  /// **'تقييم التطبيق'**
  String get rateApp;

  /// No description provided for @faq.
  ///
  /// In ar, this message translates to:
  /// **'الأسئلة الشائعة'**
  String get faq;

  /// No description provided for @privacyPolicy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In ar, this message translates to:
  /// **'شروط الاستخدام'**
  String get termsOfUse;

  /// No description provided for @version.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار'**
  String get version;

  /// No description provided for @darkMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الداكن'**
  String get darkMode;

  /// No description provided for @comingSoon.
  ///
  /// In ar, this message translates to:
  /// **'قريباً'**
  String get comingSoon;

  /// No description provided for @deleteAccount.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get deleteAccount;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تسجيل الخروج؟'**
  String get logoutConfirmBody;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In ar, this message translates to:
  /// **'سيتم حذف حسابك ولن تتمكن من استرجاعه. هل أنت متأكد؟'**
  String get deleteAccountBody;

  /// No description provided for @continueAction.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get continueAction;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحذف'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب \"حذف\" للتأكيد'**
  String get deleteConfirmHint;

  /// No description provided for @deleteConfirmWord.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get deleteConfirmWord;

  /// No description provided for @pushNotifications.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات الدفع'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'رسائل جديدة وتحديثات الإعلانات'**
  String get pushNotificationsSubtitle;

  /// No description provided for @emailNotifications.
  ///
  /// In ar, this message translates to:
  /// **'إشعارات البريد'**
  String get emailNotifications;

  /// No description provided for @loginToAccessProfile.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول للوصول إلى حسابك'**
  String get loginToAccessProfile;

  /// No description provided for @loginToViewFavorites.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول لعرض المفضلة'**
  String get loginToViewFavorites;

  /// No description provided for @loginRequiredShort.
  ///
  /// In ar, this message translates to:
  /// **'يجب تسجيل الدخول'**
  String get loginRequiredShort;

  /// No description provided for @browseListings.
  ///
  /// In ar, this message translates to:
  /// **'تصفح الإعلانات'**
  String get browseListings;

  /// No description provided for @myAccount.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get myAccount;

  /// No description provided for @viewAllListings.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل وإدارتها'**
  String get viewAllListings;

  /// No description provided for @addFirstListing.
  ///
  /// In ar, this message translates to:
  /// **'أضف أول إعلان'**
  String get addFirstListing;

  /// No description provided for @addListingButton.
  ///
  /// In ar, this message translates to:
  /// **'أضف إعلان'**
  String get addListingButton;

  /// No description provided for @noListingsYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إعلانات بعد'**
  String get noListingsYet;

  /// No description provided for @noActiveListings.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إعلانات نشطة'**
  String get noActiveListings;

  /// No description provided for @listingsLabel.
  ///
  /// In ar, this message translates to:
  /// **'إعلان'**
  String get listingsLabel;

  /// No description provided for @viewsLabel.
  ///
  /// In ar, this message translates to:
  /// **'مشاهدة'**
  String get viewsLabel;

  /// No description provided for @activeLabel.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get activeLabel;

  /// No description provided for @memberSince.
  ///
  /// In ar, this message translates to:
  /// **'عضو منذ {date}'**
  String memberSince(String date);

  /// No description provided for @listingsOf.
  ///
  /// In ar, this message translates to:
  /// **'إعلانات {name}'**
  String listingsOf(String name);

  /// No description provided for @profileNotFound.
  ///
  /// In ar, this message translates to:
  /// **'الملف غير موجود'**
  String get profileNotFound;

  /// No description provided for @camera.
  ///
  /// In ar, this message translates to:
  /// **'الكاميرا'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In ar, this message translates to:
  /// **'المعرض'**
  String get gallery;

  /// No description provided for @removePhoto.
  ///
  /// In ar, this message translates to:
  /// **'إزالة الصورة'**
  String get removePhoto;

  /// No description provided for @fullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get phoneNumber;

  /// No description provided for @governorate.
  ///
  /// In ar, this message translates to:
  /// **'المحافظة'**
  String get governorate;

  /// No description provided for @city.
  ///
  /// In ar, this message translates to:
  /// **'المدينة'**
  String get city;

  /// No description provided for @selectGovernorate.
  ///
  /// In ar, this message translates to:
  /// **'اختر المحافظة'**
  String get selectGovernorate;

  /// No description provided for @profileUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الملف الشخصي'**
  String get profileUpdated;

  /// No description provided for @myListingsActive.
  ///
  /// In ar, this message translates to:
  /// **'النشطة'**
  String get myListingsActive;

  /// No description provided for @myListingsPending.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get myListingsPending;

  /// No description provided for @myListingsSold.
  ///
  /// In ar, this message translates to:
  /// **'المباعة'**
  String get myListingsSold;

  /// No description provided for @myListingsDeleted.
  ///
  /// In ar, this message translates to:
  /// **'المحذوفة'**
  String get myListingsDeleted;

  /// No description provided for @noActiveListingsTab.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إعلانات نشطة'**
  String get noActiveListingsTab;

  /// No description provided for @noPendingListingsTab.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إعلانات قيد المراجعة'**
  String get noPendingListingsTab;

  /// No description provided for @noSoldListingsTab.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إعلانات مباعة'**
  String get noSoldListingsTab;

  /// No description provided for @noDeletedListingsTab.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إعلانات محذوفة'**
  String get noDeletedListingsTab;

  /// No description provided for @categories.
  ///
  /// In ar, this message translates to:
  /// **'الفئات'**
  String get categories;

  /// No description provided for @featured.
  ///
  /// In ar, this message translates to:
  /// **'مميز'**
  String get featured;

  /// No description provided for @sold.
  ///
  /// In ar, this message translates to:
  /// **'مباع'**
  String get sold;

  /// No description provided for @searchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في سوق العراق...'**
  String get searchHint;

  /// No description provided for @otpSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رمز التحقق. تحقق من رسائلك.'**
  String get otpSent;

  /// No description provided for @newOtpSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رمز جديد'**
  String get newOtpSent;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'ku'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'ku':
      return AppLocalizationsKu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
