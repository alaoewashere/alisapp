import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ku.dart';
import 'app_localizations_tr.dart';

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
    Locale('tr'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'سـوقك'**
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

  /// No description provided for @languageTurkish.
  ///
  /// In ar, this message translates to:
  /// **'🇹🇷 Türkçe'**
  String get languageTurkish;

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
  /// **'ابحث في سـوقك...'**
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

  /// No description provided for @homeHeroBuySell.
  ///
  /// In ar, this message translates to:
  /// **'اشتري و بيع'**
  String get homeHeroBuySell;

  /// No description provided for @homeHeroEasily.
  ///
  /// In ar, this message translates to:
  /// **'بسهولة.'**
  String get homeHeroEasily;

  /// No description provided for @homeHeroSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اعثر على أفضل العروض بين يديك'**
  String get homeHeroSubtitle;

  /// No description provided for @homeExtendedSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن سيارات، شقق، إلكترونيات...'**
  String get homeExtendedSearchHint;

  /// No description provided for @browseCategories.
  ///
  /// In ar, this message translates to:
  /// **'تصفح الفئات'**
  String get browseCategories;

  /// No description provided for @viewAll.
  ///
  /// In ar, this message translates to:
  /// **'عرض الكل'**
  String get viewAll;

  /// No description provided for @featuredListingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعلانات مميزة'**
  String get featuredListingsTitle;

  /// No description provided for @latestListingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'أحدث النشرات والمعروضات'**
  String get latestListingsTitle;

  /// No description provided for @failedLoadCategories.
  ///
  /// In ar, this message translates to:
  /// **'فشل تحميل التصنيفات'**
  String get failedLoadCategories;

  /// No description provided for @failedLoadListings.
  ///
  /// In ar, this message translates to:
  /// **'فشل تحميل الإعلانات'**
  String get failedLoadListings;

  /// No description provided for @searchResultsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} نتائج'**
  String searchResultsCount(String count);

  /// No description provided for @heatmapTooltip.
  ///
  /// In ar, this message translates to:
  /// **'كثافة الإعلانات'**
  String get heatmapTooltip;

  /// No description provided for @favoritesTooltip.
  ///
  /// In ar, this message translates to:
  /// **'المفضلة'**
  String get favoritesTooltip;

  /// No description provided for @splashTagline.
  ///
  /// In ar, this message translates to:
  /// **'تطبيقك الأول للبيع والشراء'**
  String get splashTagline;

  /// No description provided for @welcomeToSouqak.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك في سـوقك'**
  String get welcomeToSouqak;

  /// No description provided for @chooseYourLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اختر لغتك'**
  String get chooseYourLanguage;

  /// No description provided for @languageChangeHint.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك تغيير اللغة في أي وقت من الإعدادات'**
  String get languageChangeHint;

  /// No description provided for @skip.
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get skip;

  /// No description provided for @createAccount.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get createAccount;

  /// No description provided for @signUpOverline.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ حسابك'**
  String get signUpOverline;

  /// No description provided for @createAccountTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get createAccountTitle;

  /// No description provided for @firstName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الأول'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الأخير'**
  String get lastName;

  /// No description provided for @emailLabel.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get passwordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get confirmPasswordLabel;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب بالفعل؟ '**
  String get alreadyHaveAccount;

  /// No description provided for @signInLink.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك'**
  String get signInLink;

  /// No description provided for @signUpAgreementPrefix.
  ///
  /// In ar, this message translates to:
  /// **'بالتسجيل، أنت توافق على '**
  String get signUpAgreementPrefix;

  /// No description provided for @termsLink.
  ///
  /// In ar, this message translates to:
  /// **'شروط الاستخدام'**
  String get termsLink;

  /// No description provided for @andConnector.
  ///
  /// In ar, this message translates to:
  /// **' و'**
  String get andConnector;

  /// No description provided for @privacyLink.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacyLink;

  /// No description provided for @welcomeBack.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك'**
  String get welcomeBack;

  /// No description provided for @forgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get forgotPassword;

  /// No description provided for @noAccountYet.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟ '**
  String get noAccountYet;

  /// No description provided for @signUpNow.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الآن'**
  String get signUpNow;

  /// No description provided for @firstNameHint.
  ///
  /// In ar, this message translates to:
  /// **'محمد'**
  String get firstNameHint;

  /// No description provided for @lastNameHint.
  ///
  /// In ar, this message translates to:
  /// **'أحمد'**
  String get lastNameHint;

  /// No description provided for @understood.
  ///
  /// In ar, this message translates to:
  /// **'فهمت'**
  String get understood;

  /// No description provided for @heatmapTutorialTitle.
  ///
  /// In ar, this message translates to:
  /// **'اكتشف كثافة الإعلانات في منطقتك على الخريطة'**
  String get heatmapTutorialTitle;

  /// No description provided for @heatmapTutorialSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على أيقونة الخريطة لعرض المناطق الأكثر نشاطاً'**
  String get heatmapTutorialSubtitle;

  /// No description provided for @smartAlertsTutorialTitle.
  ///
  /// In ar, this message translates to:
  /// **'حدد معايير بحثك مرة واحدة واستلم إشعاراً فورياً عند نشر إعلان جديد يطابقها'**
  String get smartAlertsTutorialTitle;

  /// No description provided for @smartAlertsTutorialSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اضغط على أيقونة الجرس لإدارة تنبيهاتك الذكية'**
  String get smartAlertsTutorialSubtitle;

  /// No description provided for @agreeToTerms.
  ///
  /// In ar, this message translates to:
  /// **'أوافق على الشروط'**
  String get agreeToTerms;

  /// No description provided for @agreeToPrivacy.
  ///
  /// In ar, this message translates to:
  /// **'أوافق على سياسة الخصوصية'**
  String get agreeToPrivacy;

  /// No description provided for @continueWithPhone.
  ///
  /// In ar, this message translates to:
  /// **'متابعة برقم الهاتف'**
  String get continueWithPhone;

  /// No description provided for @phoneOtpHint.
  ///
  /// In ar, this message translates to:
  /// **'سنرسل لك رمز تحقق عبر واتساب'**
  String get phoneOtpHint;

  /// No description provided for @sendCode.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الرمز'**
  String get sendCode;

  /// No description provided for @otpSentTo.
  ///
  /// In ar, this message translates to:
  /// **'أرسلنا رمزاً إلى\n{phone}'**
  String otpSentTo(String phone);

  /// No description provided for @otpResendIn.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال خلال {seconds} ث'**
  String otpResendIn(String seconds);

  /// No description provided for @otpCanResendNow.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك إعادة إرسال الرمز'**
  String get otpCanResendNow;

  /// No description provided for @otpNotReceived.
  ///
  /// In ar, this message translates to:
  /// **'لم يصلك الرمز؟'**
  String get otpNotReceived;

  /// No description provided for @otpHelpText.
  ///
  /// In ar, this message translates to:
  /// **'• تأكد أن الرقم {phone} صحيح\n• انتظر حتى دقيقة — قد يتأخر SMS\n• Twilio: أضف رقمك في Sender Pool لخدمة souqiq-otp\n• يجب تفعيل مزود SMS (Twilio أو MessageBird) في Supabase\n• للتطوير: أضف رقمك كـ Test OTP في لوحة Supabase\n• راجع supabase/README.md — قسم Phone OTP'**
  String otpHelpText(String phone);

  /// No description provided for @completeProfileTitle.
  ///
  /// In ar, this message translates to:
  /// **'أكمل ملفك الشخصي'**
  String get completeProfileTitle;

  /// No description provided for @tapToChooseAvatar.
  ///
  /// In ar, this message translates to:
  /// **'اضغط لاختيار صورتك الرمزية'**
  String get tapToChooseAvatar;

  /// No description provided for @profileNameReadError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر قراءة الاسم من الحساب. سجّل الدخول مجدداً.'**
  String get profileNameReadError;

  /// No description provided for @sessionExpiredPleaseLogin.
  ///
  /// In ar, this message translates to:
  /// **'انتهت جلستك، يرجى تسجيل الدخول مجدداً'**
  String get sessionExpiredPleaseLogin;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @searchInSouqak.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في سـوقك'**
  String get searchInSouqak;

  /// No description provided for @mySmartAlertsTooltip.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهاتي الذكية'**
  String get mySmartAlertsTooltip;

  /// No description provided for @filtersTooltip.
  ///
  /// In ar, this message translates to:
  /// **'الفلاتر'**
  String get filtersTooltip;

  /// No description provided for @noSuggestions.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد اقتراحات'**
  String get noSuggestions;

  /// No description provided for @searchForQuery.
  ///
  /// In ar, this message translates to:
  /// **'بحث عن \"{query}\"'**
  String searchForQuery(String query);

  /// No description provided for @shareCardFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إنشاء البطاقة، حاول مرة أخرى'**
  String get shareCardFailed;

  /// No description provided for @followersLabel.
  ///
  /// In ar, this message translates to:
  /// **'متابع'**
  String get followersLabel;

  /// No description provided for @myListedAds.
  ///
  /// In ar, this message translates to:
  /// **'إعلاناتي المعروضة'**
  String get myListedAds;

  /// No description provided for @mySmartAlerts.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهاتي الذكية'**
  String get mySmartAlerts;

  /// No description provided for @defaultUser.
  ///
  /// In ar, this message translates to:
  /// **'مستخدم'**
  String get defaultUser;

  /// No description provided for @otherSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات أخرى'**
  String get otherSettings;

  /// No description provided for @accountDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الحساب'**
  String get accountDetails;

  /// No description provided for @passwordSettings.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get passwordSettings;

  /// No description provided for @aboutApp.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get aboutApp;

  /// No description provided for @aboutAppDescription.
  ///
  /// In ar, this message translates to:
  /// **'SOUQAK — سـوقك المحلي للإعلانات المبوبة في العراق. اشترِ وبيع بسهولة عبر تطبيق واحد.'**
  String get aboutAppDescription;

  /// No description provided for @versionLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإصدار {version}'**
  String versionLabel(String version);

  /// No description provided for @helpFaq.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة / الأسئلة الشائعة'**
  String get helpFaq;

  /// No description provided for @contactSupport.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع الدعم'**
  String get contactSupport;

  /// No description provided for @supportChatIntro.
  ///
  /// In ar, this message translates to:
  /// **'هل تحتاج مساعدة؟ راسل فريق الدعم وسنرد عليك في أقرب وقت.'**
  String get supportChatIntro;

  /// No description provided for @logoutAction.
  ///
  /// In ar, this message translates to:
  /// **'خروج'**
  String get logoutAction;

  /// No description provided for @logoutConfirmBodyExtended.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد تسجيل الخروج؟'**
  String get logoutConfirmBodyExtended;

  /// No description provided for @deleteAccountConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.'**
  String get deleteAccountConfirmBody;

  /// No description provided for @startConversation.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ المحادثة'**
  String get startConversation;

  /// No description provided for @conversation.
  ///
  /// In ar, this message translates to:
  /// **'محادثة'**
  String get conversation;

  /// No description provided for @viewListing.
  ///
  /// In ar, this message translates to:
  /// **'عرض الإعلان'**
  String get viewListing;

  /// No description provided for @blockUser.
  ///
  /// In ar, this message translates to:
  /// **'حظر المستخدم'**
  String get blockUser;

  /// No description provided for @blockFeatureComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'ميزة الحظر قريباً'**
  String get blockFeatureComingSoon;

  /// No description provided for @reportConversation.
  ///
  /// In ar, this message translates to:
  /// **'الإبلاغ عن المحادثة'**
  String get reportConversation;

  /// No description provided for @reportReceived.
  ///
  /// In ar, this message translates to:
  /// **'تم استلام بلاغك'**
  String get reportReceived;

  /// No description provided for @onlineNow.
  ///
  /// In ar, this message translates to:
  /// **'متصل الآن'**
  String get onlineNow;

  /// No description provided for @typeMessage.
  ///
  /// In ar, this message translates to:
  /// **'اكتب رسالة...'**
  String get typeMessage;

  /// No description provided for @reconnecting.
  ///
  /// In ar, this message translates to:
  /// **'جاري إعادة الاتصال...'**
  String get reconnecting;

  /// No description provided for @chooseRecoveryMethod.
  ///
  /// In ar, this message translates to:
  /// **'اختر طريقة استعادة حسابك'**
  String get chooseRecoveryMethod;

  /// No description provided for @continueViaEmail.
  ///
  /// In ar, this message translates to:
  /// **'متابعة عبر البريد الإلكتروني'**
  String get continueViaEmail;

  /// No description provided for @linkedEmailHint.
  ///
  /// In ar, this message translates to:
  /// **'بريدك المرتبط بالحساب'**
  String get linkedEmailHint;

  /// No description provided for @continueViaPhone.
  ///
  /// In ar, this message translates to:
  /// **'متابعة عبر الهاتف'**
  String get continueViaPhone;

  /// No description provided for @linkedPhoneHint.
  ///
  /// In ar, this message translates to:
  /// **'هاتفك المرتبط بالحساب'**
  String get linkedPhoneHint;

  /// No description provided for @sendAction.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get sendAction;

  /// No description provided for @emailNotRegistered.
  ///
  /// In ar, this message translates to:
  /// **'هذا البريد غير مسجل لدينا'**
  String get emailNotRegistered;

  /// No description provided for @phoneNotRegistered.
  ///
  /// In ar, this message translates to:
  /// **'هذا الرقم غير مسجل لدينا'**
  String get phoneNotRegistered;

  /// No description provided for @listingPostedToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get listingPostedToday;

  /// No description provided for @listingPostedOneDayAgo.
  ///
  /// In ar, this message translates to:
  /// **'يوم واحد'**
  String get listingPostedOneDayAgo;

  /// No description provided for @listingPostedDaysAgo.
  ///
  /// In ar, this message translates to:
  /// **'{count} يوم'**
  String listingPostedDaysAgo(String count);

  /// No description provided for @homeFeedLatestTitle.
  ///
  /// In ar, this message translates to:
  /// **'أحدث الإعلانات'**
  String get homeFeedLatestTitle;

  /// No description provided for @otpSentViaWhatsapp.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الرمز عبر واتساب إلى'**
  String get otpSentViaWhatsapp;

  /// No description provided for @otpResendCode.
  ///
  /// In ar, this message translates to:
  /// **'إعادة إرسال الرمز'**
  String get otpResendCode;

  /// No description provided for @otpVerifyButton.
  ///
  /// In ar, this message translates to:
  /// **'التحقق'**
  String get otpVerifyButton;

  /// No description provided for @otpInvalidCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز غير صحيح'**
  String get otpInvalidCode;

  /// No description provided for @otpVerifiedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم التحقق بنجاح!'**
  String get otpVerifiedSuccess;

  /// No description provided for @otpSigningIn.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تسجيل الدخول...'**
  String get otpSigningIn;

  /// No description provided for @today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get yesterday;

  /// No description provided for @now.
  ///
  /// In ar, this message translates to:
  /// **'الآن'**
  String get now;

  /// No description provided for @oneMinuteAgo.
  ///
  /// In ar, this message translates to:
  /// **'دقيقة واحدة'**
  String get oneMinuteAgo;

  /// No description provided for @twoMinutesAgo.
  ///
  /// In ar, this message translates to:
  /// **'دقيقتان'**
  String get twoMinutesAgo;

  /// No description provided for @minutesAgo.
  ///
  /// In ar, this message translates to:
  /// **'{count} دقيقة'**
  String minutesAgo(String count);

  /// No description provided for @oneHourAgo.
  ///
  /// In ar, this message translates to:
  /// **'ساعة واحدة'**
  String get oneHourAgo;

  /// No description provided for @twoHoursAgo.
  ///
  /// In ar, this message translates to:
  /// **'ساعتان'**
  String get twoHoursAgo;

  /// No description provided for @hoursAgo.
  ///
  /// In ar, this message translates to:
  /// **'{count} ساعة'**
  String hoursAgo(String count);

  /// No description provided for @twoDaysAgo.
  ///
  /// In ar, this message translates to:
  /// **'يومان'**
  String get twoDaysAgo;

  /// No description provided for @daysAgo.
  ///
  /// In ar, this message translates to:
  /// **'{count} أيام'**
  String daysAgo(String count);

  /// No description provided for @myMessages.
  ///
  /// In ar, this message translates to:
  /// **'رسائلي'**
  String get myMessages;

  /// No description provided for @loginToViewMessages.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول لعرض الرسائل'**
  String get loginToViewMessages;

  /// No description provided for @noMessagesYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد رسائل بعد'**
  String get noMessagesYet;

  /// No description provided for @contactSellersPrompt.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ بالتواصل مع البائعين'**
  String get contactSellersPrompt;

  /// No description provided for @deleteConversationTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف المحادثة'**
  String get deleteConversationTitle;

  /// No description provided for @deleteConversationBody.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف هذه المحادثة؟'**
  String get deleteConversationBody;

  /// No description provided for @chatMessagesHeader.
  ///
  /// In ar, this message translates to:
  /// **'الرسائل والمحادثات'**
  String get chatMessagesHeader;

  /// No description provided for @chatDirectContact.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مباشرة مع المشترين والبائعين'**
  String get chatDirectContact;

  /// No description provided for @activeUsersCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} نشط'**
  String activeUsersCount(String count);

  /// No description provided for @listingBadge.
  ///
  /// In ar, this message translates to:
  /// **'إعلان'**
  String get listingBadge;

  /// No description provided for @startChatDefault.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ المحادثة'**
  String get startChatDefault;

  /// No description provided for @categoryRealEstate.
  ///
  /// In ar, this message translates to:
  /// **'العقارات'**
  String get categoryRealEstate;

  /// No description provided for @categoryVehicles.
  ///
  /// In ar, this message translates to:
  /// **'المركبات'**
  String get categoryVehicles;

  /// No description provided for @categoryElectronics.
  ///
  /// In ar, this message translates to:
  /// **'الإلكترونيات'**
  String get categoryElectronics;

  /// No description provided for @categoryBuySell.
  ///
  /// In ar, this message translates to:
  /// **'سوق المستعمل والجديد'**
  String get categoryBuySell;

  /// No description provided for @categoryTutoring.
  ///
  /// In ar, this message translates to:
  /// **'دروس خصوصية'**
  String get categoryTutoring;

  /// No description provided for @categoryJobs.
  ///
  /// In ar, this message translates to:
  /// **'فرص العمل'**
  String get categoryJobs;

  /// No description provided for @categoryPets.
  ///
  /// In ar, this message translates to:
  /// **'الحيوانات'**
  String get categoryPets;

  /// No description provided for @categoryHomeHelp.
  ///
  /// In ar, this message translates to:
  /// **'مساعدة منزلية'**
  String get categoryHomeHelp;

  /// No description provided for @categorySubtitleRealEstate.
  ///
  /// In ar, this message translates to:
  /// **'سكني ، أراضi ، محلات تجارية...'**
  String get categorySubtitleRealEstate;

  /// No description provided for @categorySubtitleVehicles.
  ///
  /// In ar, this message translates to:
  /// **'سيارات ، سيارات للإيجار ، دراجات...'**
  String get categorySubtitleVehicles;

  /// No description provided for @categorySubtitleElectronics.
  ///
  /// In ar, this message translates to:
  /// **'جوالات ، لابتوب ، تلفزيونات...'**
  String get categorySubtitleElectronics;

  /// No description provided for @categorySubtitleBuySell.
  ///
  /// In ar, this message translates to:
  /// **'موبايلات ، كمبيوتر ، ملابس ، أثاث...'**
  String get categorySubtitleBuySell;

  /// No description provided for @categorySubtitleTutoring.
  ///
  /// In ar, this message translates to:
  /// **'مدرسة ، جامعة ، لغات ، قرآن...'**
  String get categorySubtitleTutoring;

  /// No description provided for @categorySubtitleJobs.
  ///
  /// In ar, this message translates to:
  /// **'تقنية ، هندسة ، طب ، نفط...'**
  String get categorySubtitleJobs;

  /// No description provided for @categorySubtitlePets.
  ///
  /// In ar, this message translates to:
  /// **'كلاب ، قطط ، طيور ، مزرعة...'**
  String get categorySubtitlePets;

  /// No description provided for @categorySubtitleHomeHelp.
  ///
  /// In ar, this message translates to:
  /// **'تنظيف ، طبخ ، مربيات ، سائق...'**
  String get categorySubtitleHomeHelp;

  /// No description provided for @listingNotFound.
  ///
  /// In ar, this message translates to:
  /// **'الإعلان غير موجود'**
  String get listingNotFound;

  /// No description provided for @tabListing.
  ///
  /// In ar, this message translates to:
  /// **'إعلان'**
  String get tabListing;

  /// No description provided for @tabDescription.
  ///
  /// In ar, this message translates to:
  /// **'الوصف'**
  String get tabDescription;

  /// No description provided for @tabLocation.
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get tabLocation;

  /// No description provided for @sellerOtherListings.
  ///
  /// In ar, this message translates to:
  /// **'إعلانات أخرى للبائع'**
  String get sellerOtherListings;

  /// No description provided for @reportThisListing.
  ///
  /// In ar, this message translates to:
  /// **'الإبلاغ عن هذا الإعلان'**
  String get reportThisListing;

  /// No description provided for @negotiable.
  ///
  /// In ar, this message translates to:
  /// **'قابل للتفاوض'**
  String get negotiable;

  /// No description provided for @videoTour.
  ///
  /// In ar, this message translates to:
  /// **'🎥 جولة بالفيديو'**
  String get videoTour;

  /// No description provided for @paintConditionTitle.
  ///
  /// In ar, this message translates to:
  /// **'حالة الهيكل والطلاء'**
  String get paintConditionTitle;

  /// No description provided for @allPartsOriginal.
  ///
  /// In ar, this message translates to:
  /// **'جميع الأجزاء أصلية'**
  String get allPartsOriginal;

  /// No description provided for @viewsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} مشاهدة'**
  String viewsCount(String count);

  /// No description provided for @listingNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الإعلان'**
  String get listingNumber;

  /// No description provided for @listingDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الإعلان'**
  String get listingDate;

  /// No description provided for @noDescriptionAdded.
  ///
  /// In ar, this message translates to:
  /// **'لم يضف صاحب الإعلان وصفاً'**
  String get noDescriptionAdded;

  /// No description provided for @locationNotSet.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم تحديد الموقع'**
  String get locationNotSet;

  /// No description provided for @selectedLocation.
  ///
  /// In ar, this message translates to:
  /// **'الموقع المحدد'**
  String get selectedLocation;

  /// No description provided for @sellerLabel.
  ///
  /// In ar, this message translates to:
  /// **'بائع'**
  String get sellerLabel;

  /// No description provided for @theSeller.
  ///
  /// In ar, this message translates to:
  /// **'البائع'**
  String get theSeller;

  /// No description provided for @memberSinceYear.
  ///
  /// In ar, this message translates to:
  /// **'عضو منذ {year}'**
  String memberSinceYear(String year);

  /// No description provided for @listingsCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'{count} إعلان'**
  String listingsCountLabel(String count);

  /// No description provided for @viewAllSellerListings.
  ///
  /// In ar, this message translates to:
  /// **'عرض جميع إعلاناته'**
  String get viewAllSellerListings;

  /// No description provided for @safetyTipsTitle.
  ///
  /// In ar, this message translates to:
  /// **'نصائح الأمان'**
  String get safetyTipsTitle;

  /// No description provided for @safetyTipPublicPlace.
  ///
  /// In ar, this message translates to:
  /// **'قابل البائع في مكان عام'**
  String get safetyTipPublicPlace;

  /// No description provided for @safetyTipNoPrepay.
  ///
  /// In ar, this message translates to:
  /// **'لا تدفع مقدماً قبل معاينة المنتج'**
  String get safetyTipNoPrepay;

  /// No description provided for @safetyTipInspect.
  ///
  /// In ar, this message translates to:
  /// **'تحقّق من حالة المنتج قبل الشراء'**
  String get safetyTipInspect;

  /// No description provided for @rateSeller.
  ///
  /// In ar, this message translates to:
  /// **'قيّم البائع'**
  String get rateSeller;

  /// No description provided for @priceLabel.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get priceLabel;

  /// No description provided for @locationLabel.
  ///
  /// In ar, this message translates to:
  /// **'الموقع'**
  String get locationLabel;

  /// No description provided for @conditionLabel.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get conditionLabel;

  /// No description provided for @packageFree.
  ///
  /// In ar, this message translates to:
  /// **'مجاني'**
  String get packageFree;

  /// No description provided for @packagePro.
  ///
  /// In ar, this message translates to:
  /// **'برو'**
  String get packagePro;

  /// No description provided for @packagePremium.
  ///
  /// In ar, this message translates to:
  /// **'مميز'**
  String get packagePremium;

  /// No description provided for @statusActive.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get statusActive;

  /// No description provided for @statusExpired.
  ///
  /// In ar, this message translates to:
  /// **'منتهي'**
  String get statusExpired;

  /// No description provided for @statusPending.
  ///
  /// In ar, this message translates to:
  /// **'معلق'**
  String get statusPending;

  /// No description provided for @chooseOption.
  ///
  /// In ar, this message translates to:
  /// **'اختر'**
  String get chooseOption;

  /// No description provided for @allCategories.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get allCategories;

  /// No description provided for @noCategories.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فئات'**
  String get noCategories;

  /// No description provided for @noSubcategories.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد فئات فرعية'**
  String get noSubcategories;

  /// No description provided for @allCategoryListings.
  ///
  /// In ar, this message translates to:
  /// **'كل إعلانات {name}'**
  String allCategoryListings(String name);

  /// No description provided for @allGovernorates.
  ///
  /// In ar, this message translates to:
  /// **'جميع المحافظات'**
  String get allGovernorates;

  /// No description provided for @postListingStep1.
  ///
  /// In ar, this message translates to:
  /// **'الخطوة الأولى'**
  String get postListingStep1;

  /// No description provided for @postListingStep2.
  ///
  /// In ar, this message translates to:
  /// **'الخطوة الثانية'**
  String get postListingStep2;

  /// No description provided for @postListingStep3.
  ///
  /// In ar, this message translates to:
  /// **'الخطوة الثالثة'**
  String get postListingStep3;

  /// No description provided for @postListingStep4.
  ///
  /// In ar, this message translates to:
  /// **'الخطوة الرابعة'**
  String get postListingStep4;

  /// No description provided for @postListingStep5.
  ///
  /// In ar, this message translates to:
  /// **'الخطوة الخامسة'**
  String get postListingStep5;

  /// No description provided for @postListingStep6.
  ///
  /// In ar, this message translates to:
  /// **'الخطوة السادسة'**
  String get postListingStep6;

  /// No description provided for @postListingStep7.
  ///
  /// In ar, this message translates to:
  /// **'الخطوة السابعة'**
  String get postListingStep7;

  /// No description provided for @postListingStep8.
  ///
  /// In ar, this message translates to:
  /// **'الخطوة الثامنة'**
  String get postListingStep8;

  /// No description provided for @postListingStepFallback.
  ///
  /// In ar, this message translates to:
  /// **'الخطوة {step}'**
  String postListingStepFallback(String step);

  /// No description provided for @nextStep.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get nextStep;

  /// No description provided for @saveAsDraft.
  ///
  /// In ar, this message translates to:
  /// **'حفظ كمسودة'**
  String get saveAsDraft;

  /// No description provided for @titleMinLengthError.
  ///
  /// In ar, this message translates to:
  /// **'العنوان يجب أن يكون 5 أحرف على الأقل'**
  String get titleMinLengthError;

  /// No description provided for @addPhotoRequired.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إضافة صورة واحدة على الأقل'**
  String get addPhotoRequired;

  /// No description provided for @draftSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ المسودة'**
  String get draftSaved;

  /// No description provided for @confirmListingFeeTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد رسوم الإعلان'**
  String get confirmListingFeeTitle;

  /// No description provided for @confirmListingFeeBody.
  ///
  /// In ar, this message translates to:
  /// **'لقد استخدمت إعلانيك المجانيين هذا الشهر. سيتم تحصيل رسوم الإعلان العادي ({price}) لهذا الإعلان.'**
  String confirmListingFeeBody(String price);

  /// No description provided for @confirmAndPay.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد ودفع {price}'**
  String confirmAndPay(String price);

  /// No description provided for @publishingListing.
  ///
  /// In ar, this message translates to:
  /// **'جاري نشر الإعلان...'**
  String get publishingListing;

  /// No description provided for @uploadingPhotos.
  ///
  /// In ar, this message translates to:
  /// **'جاري رفع الصور... ({current}/{total})'**
  String uploadingPhotos(String current, String total);

  /// No description provided for @searchEllipsis.
  ///
  /// In ar, this message translates to:
  /// **'بحث...'**
  String get searchEllipsis;

  /// No description provided for @specifyValue.
  ///
  /// In ar, this message translates to:
  /// **'حدد القيمة'**
  String get specifyValue;

  /// No description provided for @specifyType.
  ///
  /// In ar, this message translates to:
  /// **'حدد النوع'**
  String get specifyType;

  /// No description provided for @choosePickerTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر {label}'**
  String choosePickerTitle(String label);

  /// No description provided for @governorateRequired.
  ///
  /// In ar, this message translates to:
  /// **'المحافظة *'**
  String get governorateRequired;

  /// No description provided for @neighborhoodOptional.
  ///
  /// In ar, this message translates to:
  /// **'المنطقة / الحي (اختياري)'**
  String get neighborhoodOptional;

  /// No description provided for @neighborhoodLabel.
  ///
  /// In ar, this message translates to:
  /// **'المنطقة / الحي'**
  String get neighborhoodLabel;

  /// No description provided for @chooseGovernorateFirst.
  ///
  /// In ar, this message translates to:
  /// **'اختر المحافظة أولاً لعرض المناطق المتاحة'**
  String get chooseGovernorateFirst;

  /// No description provided for @currencyIqd.
  ///
  /// In ar, this message translates to:
  /// **'د.ع'**
  String get currencyIqd;

  /// No description provided for @listingDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الإعلان'**
  String get listingDetailsTitle;

  /// No description provided for @optionalLabel.
  ///
  /// In ar, this message translates to:
  /// **'اختياري'**
  String get optionalLabel;

  /// No description provided for @listingTypeLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع الإعلان *'**
  String get listingTypeLabel;

  /// No description provided for @conditionNew.
  ///
  /// In ar, this message translates to:
  /// **'جديد'**
  String get conditionNew;

  /// No description provided for @conditionUsed.
  ///
  /// In ar, this message translates to:
  /// **'مستعمل'**
  String get conditionUsed;

  /// No description provided for @listingTitleLabel.
  ///
  /// In ar, this message translates to:
  /// **'عنوان الإعلان'**
  String get listingTitleLabel;

  /// No description provided for @listingTitleHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب عنوان إعلانك هنا'**
  String get listingTitleHint;

  /// No description provided for @listingDescriptionLabel.
  ///
  /// In ar, this message translates to:
  /// **'وصف الإعلان'**
  String get listingDescriptionLabel;

  /// No description provided for @listingDescriptionHint.
  ///
  /// In ar, this message translates to:
  /// **'أضف وصفاً تفصيلياً لإعلانك...'**
  String get listingDescriptionHint;

  /// No description provided for @removeArea.
  ///
  /// In ar, this message translates to:
  /// **'إزالة المنطقة'**
  String get removeArea;

  /// No description provided for @pickLocationOnMap.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الموقع على الخريطة'**
  String get pickLocationOnMap;

  /// No description provided for @coordinatesLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإحداثيات: {coords}'**
  String coordinatesLabel(String coords);

  /// No description provided for @selectedAreaLabel.
  ///
  /// In ar, this message translates to:
  /// **'المنطقة المختارة: {area}'**
  String selectedAreaLabel(String area);

  /// No description provided for @suggestedAreaLabel.
  ///
  /// In ar, this message translates to:
  /// **'المنطقة المقترحة: {area}'**
  String suggestedAreaLabel(String area);

  /// No description provided for @removeLocation.
  ///
  /// In ar, this message translates to:
  /// **'إزالة الموقع'**
  String get removeLocation;

  /// No description provided for @mapNotConfigured.
  ///
  /// In ar, this message translates to:
  /// **'الخريطة غير مهيّأة. أضف GOOGLE_MAPS_API_KEY أو اختر المحافظة فقط.'**
  String get mapNotConfigured;

  /// No description provided for @mapOpenFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر فتح الخريطة. يمكنك المتابعة باختيار المحافظة فقط.'**
  String get mapOpenFailed;

  /// No description provided for @photosTitle.
  ///
  /// In ar, this message translates to:
  /// **'الصور'**
  String get photosTitle;

  /// No description provided for @photosSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أضف حتى {max} صور — اسحب لإعادة الترتيب'**
  String photosSubtitle(String max);

  /// No description provided for @firstPhotoIsCover.
  ///
  /// In ar, this message translates to:
  /// **'الصورة الأولى هي الغلاف'**
  String get firstPhotoIsCover;

  /// No description provided for @maxPhotosLimit.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأقصى {max} صور'**
  String maxPhotosLimit(String max);

  /// No description provided for @noPhotosYet.
  ///
  /// In ar, this message translates to:
  /// **'لم تضف أي صور بعد'**
  String get noPhotosYet;

  /// No description provided for @photosHelpSell.
  ///
  /// In ar, this message translates to:
  /// **'الصور تزيد من فرصة بيع إعلانك'**
  String get photosHelpSell;

  /// No description provided for @photoTipGoodLight.
  ///
  /// In ar, this message translates to:
  /// **'إضاءة جيدة'**
  String get photoTipGoodLight;

  /// No description provided for @photoTipClearPhotos.
  ///
  /// In ar, this message translates to:
  /// **'صور واضحة'**
  String get photoTipClearPhotos;

  /// No description provided for @photoTipMultipleAngles.
  ///
  /// In ar, this message translates to:
  /// **'زوايا متعددة'**
  String get photoTipMultipleAngles;

  /// No description provided for @reviewListingTitle.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة الإعلان'**
  String get reviewListingTitle;

  /// No description provided for @detailsSection.
  ///
  /// In ar, this message translates to:
  /// **'التفاصيل'**
  String get detailsSection;

  /// No description provided for @categorySection.
  ///
  /// In ar, this message translates to:
  /// **'الفئة'**
  String get categorySection;

  /// No description provided for @editAction.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get editAction;

  /// No description provided for @showMore.
  ///
  /// In ar, this message translates to:
  /// **'عرض المزيد'**
  String get showMore;

  /// No description provided for @showLess.
  ///
  /// In ar, this message translates to:
  /// **'عرض أقل'**
  String get showLess;

  /// No description provided for @retryAction.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retryAction;

  /// No description provided for @selectedSpecsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} مواصفة مختارة'**
  String selectedSpecsCount(String count);

  /// No description provided for @selectedFeaturesCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} ميزة مختارة'**
  String selectedFeaturesCount(String count);

  /// No description provided for @exchangePossible.
  ///
  /// In ar, this message translates to:
  /// **'قابل للتبادل'**
  String get exchangePossible;

  /// No description provided for @deliveryAvailable.
  ///
  /// In ar, this message translates to:
  /// **'توصيل متاح'**
  String get deliveryAvailable;

  /// No description provided for @smartTvBadge.
  ///
  /// In ar, this message translates to:
  /// **'سمارت TV'**
  String get smartTvBadge;

  /// No description provided for @contactTitle.
  ///
  /// In ar, this message translates to:
  /// **'التواصل'**
  String get contactTitle;

  /// No description provided for @contactInfoSection.
  ///
  /// In ar, this message translates to:
  /// **'معلومات التواصل'**
  String get contactInfoSection;

  /// No description provided for @contactPreferencesTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفضيلات التواصل'**
  String get contactPreferencesTitle;

  /// No description provided for @contactPreferencesHelp.
  ///
  /// In ar, this message translates to:
  /// **'اختر الطريقة التي يمكن للمشترين التواصل معك من خلالها على هذا الإعلان.\n\n• هاتف ورسائل: يمكن التواصل عبر الهاتف والرسائل داخل التطبيق\n• هاتف فقط: يظهر رقم الهاتف دون رسائل داخل التطبيق\n• رسائل فقط: التواصل عبر الرسائل داخل التطبيق فقط'**
  String get contactPreferencesHelp;

  /// No description provided for @choosePackage.
  ///
  /// In ar, this message translates to:
  /// **'اختر الباقة'**
  String get choosePackage;

  /// No description provided for @freePostsRemainingLabel.
  ///
  /// In ar, this message translates to:
  /// **'0 د.ع (متبقي {remaining} إعلان مجاني هذا الأسبوع)'**
  String freePostsRemainingLabel(String remaining);

  /// No description provided for @freePostsUsedWarning.
  ///
  /// In ar, this message translates to:
  /// **'تم استخدام إعلانيك المجانيين. سيتم تحصيل رسوم الإعلان العادي.'**
  String get freePostsUsedWarning;

  /// No description provided for @roomsCountBadge.
  ///
  /// In ar, this message translates to:
  /// **'{count} غرف'**
  String roomsCountBadge(String count);

  /// No description provided for @profileLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل الملف الشخصي'**
  String get profileLoadFailed;

  /// No description provided for @changesSavedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ التغييرات بنجاح'**
  String get changesSavedSuccess;

  /// No description provided for @saveError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء الحفظ'**
  String get saveError;

  /// No description provided for @enterName.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الاسم'**
  String get enterName;

  /// No description provided for @usernameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم'**
  String get usernameLabel;

  /// No description provided for @usernameCannotChange.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن تغيير اسم المستخدم'**
  String get usernameCannotChange;

  /// No description provided for @changePhoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الرقم'**
  String get changePhoneNumber;

  /// No description provided for @verifyPhoneAction.
  ///
  /// In ar, this message translates to:
  /// **'✓ تحقق من الرقم'**
  String get verifyPhoneAction;

  /// No description provided for @notVerified.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم التحقق'**
  String get notVerified;

  /// No description provided for @changePhoto.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الصورة'**
  String get changePhoto;

  /// No description provided for @verifyPhoneTitle.
  ///
  /// In ar, this message translates to:
  /// **'التحقق من رقم الهاتف'**
  String get verifyPhoneTitle;

  /// No description provided for @whatsappSixDigitHint.
  ///
  /// In ar, this message translates to:
  /// **'سنرسل رمزاً مكوناً من 6 أرقام عبر واتساب'**
  String get whatsappSixDigitHint;

  /// No description provided for @sendWhatsappCode.
  ///
  /// In ar, this message translates to:
  /// **'إرسال رمز واتساب'**
  String get sendWhatsappCode;

  /// No description provided for @enterValidPhone.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم هاتف صحيح'**
  String get enterValidPhone;

  /// No description provided for @phoneVerifiedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم التحقق من رقم الهاتف بنجاح'**
  String get phoneVerifiedSuccess;

  /// No description provided for @ratingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'التقييمات'**
  String get ratingsTitle;

  /// No description provided for @noRatingsYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تقييمات بعد'**
  String get noRatingsYet;

  /// No description provided for @loadMore.
  ///
  /// In ar, this message translates to:
  /// **'تحميل المزيد'**
  String get loadMore;

  /// No description provided for @noReviewLeft.
  ///
  /// In ar, this message translates to:
  /// **'لم يترك تعليقاً'**
  String get noReviewLeft;

  /// No description provided for @ratingSubmitFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إرسال التقييم، حاول مرة أخرى'**
  String get ratingSubmitFailed;

  /// No description provided for @rateExperienceTitle.
  ///
  /// In ar, this message translates to:
  /// **'كيف كانت تجربتك؟'**
  String get rateExperienceTitle;

  /// No description provided for @addCommentOptional.
  ///
  /// In ar, this message translates to:
  /// **'أضف تعليقاً (اختياري)'**
  String get addCommentOptional;

  /// No description provided for @submitRating.
  ///
  /// In ar, this message translates to:
  /// **'إرسال التقييم'**
  String get submitRating;

  /// No description provided for @ratingsHelpCommunity.
  ///
  /// In ar, this message translates to:
  /// **'تقييماتك تساعد المجتمع على الثقة بالبائعين'**
  String get ratingsHelpCommunity;

  /// No description provided for @chooseAvatarTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر صورتك الرمزية'**
  String get chooseAvatarTitle;

  /// No description provided for @priceHistoryTitle.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ السعر'**
  String get priceHistoryTitle;

  /// No description provided for @priceDroppedSummary.
  ///
  /// In ar, this message translates to:
  /// **'انخفض السعر من {from} إلى {to} خلال {duration}'**
  String priceDroppedSummary(String from, String to, String duration);

  /// No description provided for @priceIncreasedSummary.
  ///
  /// In ar, this message translates to:
  /// **'ارتفع السعر من {from} إلى {to}'**
  String priceIncreasedSummary(String from, String to);

  /// No description provided for @originalPriceLabel.
  ///
  /// In ar, this message translates to:
  /// **'السعر الأصلي'**
  String get originalPriceLabel;

  /// No description provided for @currentPriceLabel.
  ///
  /// In ar, this message translates to:
  /// **'السعر الحالي'**
  String get currentPriceLabel;

  /// No description provided for @lessThanOneWeek.
  ///
  /// In ar, this message translates to:
  /// **'أقل من أسبوع'**
  String get lessThanOneWeek;

  /// No description provided for @oneWeek.
  ///
  /// In ar, this message translates to:
  /// **'أسبوع واحد'**
  String get oneWeek;

  /// No description provided for @twoWeeks.
  ///
  /// In ar, this message translates to:
  /// **'أسبوعين'**
  String get twoWeeks;

  /// No description provided for @weeksCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} أسابيع'**
  String weeksCount(String count);

  /// No description provided for @moderationYouAreBanned.
  ///
  /// In ar, this message translates to:
  /// **'أنت محظور'**
  String get moderationYouAreBanned;

  /// No description provided for @moderationBannedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم الحظر'**
  String get moderationBannedTitle;

  /// No description provided for @moderationWarningTitle.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه'**
  String get moderationWarningTitle;

  /// No description provided for @moderationPostingBanDefault.
  ///
  /// In ar, this message translates to:
  /// **'أنت محظور من الدردشة والنشر حالياً.'**
  String get moderationPostingBanDefault;

  /// No description provided for @moderationBlockedBody.
  ///
  /// In ar, this message translates to:
  /// **'لقد تجاوزت الحد المسموح به من المخالفات ولم يتم إرسال رسالتك.'**
  String get moderationBlockedBody;

  /// No description provided for @moderationCensoredBody.
  ///
  /// In ar, this message translates to:
  /// **'تم استخدام كلمة غير لائقة في رسالتك وتمت إزالتها. يرجى الالتزام بقواعد الاستخدام.'**
  String get moderationCensoredBody;

  /// No description provided for @postingBanPermanent.
  ///
  /// In ar, this message translates to:
  /// **'أنت محظور بشكل دائم من الدردشة والنشر'**
  String get postingBanPermanent;

  /// No description provided for @postingBanUntil.
  ///
  /// In ar, this message translates to:
  /// **'أنت محظور من الدردشة والنشر حتى {date}'**
  String postingBanUntil(String date);

  /// No description provided for @postingBanPermanentReason.
  ///
  /// In ar, this message translates to:
  /// **'تم حظرك بشكل دائم من الدردشة والنشر بسبب تكرار استخدام لغة غير لائقة.'**
  String get postingBanPermanentReason;

  /// No description provided for @postingBanFirstReason.
  ///
  /// In ar, this message translates to:
  /// **'تم حظرك من الدردشة والنشر لمدة يومين بسبب استخدام لغة غير لائقة. في حال التكرار ستُحظر لمدة شهر كامل.'**
  String get postingBanFirstReason;

  /// No description provided for @postingBanRepeatReason.
  ///
  /// In ar, this message translates to:
  /// **'تم حظرك من الدردشة والنشر لمدة شهر كامل بسبب تكرار استخدام لغة غير لائقة.'**
  String get postingBanRepeatReason;

  /// No description provided for @usernameSetupTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر اسم مستخدمك'**
  String get usernameSetupTitle;

  /// No description provided for @usernameSetupSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سيظهر هذا الاسم في ملفك الشخصي وإعلاناتك'**
  String get usernameSetupSubtitle;

  /// No description provided for @usernameHint.
  ///
  /// In ar, this message translates to:
  /// **'اسم_المستخدم'**
  String get usernameHint;

  /// No description provided for @usernameFormatRules.
  ///
  /// In ar, this message translates to:
  /// **'يمكن استخدام الأحرف الإنجليزية والأرقام والشرطة السفلية فقط'**
  String get usernameFormatRules;

  /// No description provided for @skipForNow.
  ///
  /// In ar, this message translates to:
  /// **'تخطى الآن'**
  String get skipForNow;

  /// No description provided for @genericErrorRetry.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ، حاول مجدداً'**
  String get genericErrorRetry;

  /// No description provided for @emailVerifyTitle.
  ///
  /// In ar, this message translates to:
  /// **'التحقق من البريد'**
  String get emailVerifyTitle;

  /// No description provided for @otpSentToEmailPrompt.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الرمز الذي أرسلناه إلى'**
  String get otpSentToEmailPrompt;

  /// No description provided for @newPasswordTitle.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة'**
  String get newPasswordTitle;

  /// No description provided for @newPasswordSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة مرور جديدة لحسابك'**
  String get newPasswordSubtitle;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير كلمة المرور'**
  String get passwordChangedSuccess;

  /// No description provided for @allListings.
  ///
  /// In ar, this message translates to:
  /// **'جميع الإعلانات'**
  String get allListings;

  /// No description provided for @categoryNotFoundMigration.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على \"{name}\" في قاعدة البيانات. طبّق migrations في Supabase ثم أعد تحميل التطبيق.'**
  String categoryNotFoundMigration(String name);

  /// No description provided for @verifyAccountTitle.
  ///
  /// In ar, this message translates to:
  /// **'توثيق الحساب'**
  String get verifyAccountTitle;

  /// No description provided for @verifyAccountSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'قبل المتابعة، يرجى توثيق هويتك'**
  String get verifyAccountSubtitle;

  /// No description provided for @whyVerification.
  ///
  /// In ar, this message translates to:
  /// **'لماذا التوثيق؟'**
  String get whyVerification;

  /// No description provided for @verificationBenefitsBody.
  ///
  /// In ar, this message translates to:
  /// **'توثيق حسابك يمنحك شارة الثقة الزرقاء ويزيد من ثقة المشترين في إعلاناتك. نراجع وثائقك بسرية تامة ولا نشاركها مع أي طرف.'**
  String get verificationBenefitsBody;

  /// No description provided for @verifiedSellerBadge.
  ///
  /// In ar, this message translates to:
  /// **'شارة «بائع موثّق» على ملفك وإعلاناتك'**
  String get verifiedSellerBadge;

  /// No description provided for @reviewWithin24Hours.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة خلال 24 ساعة'**
  String get reviewWithin24Hours;

  /// No description provided for @documentsStoredSecurely.
  ///
  /// In ar, this message translates to:
  /// **'وثائقك محفوظة بشكل آمن'**
  String get documentsStoredSecurely;

  /// No description provided for @verifyIdentityAction.
  ///
  /// In ar, this message translates to:
  /// **'توثيق الهوية ←'**
  String get verifyIdentityAction;

  /// No description provided for @chooseDocumentType.
  ///
  /// In ar, this message translates to:
  /// **'اختر نوع الوثيقة'**
  String get chooseDocumentType;

  /// No description provided for @nationalId.
  ///
  /// In ar, this message translates to:
  /// **'الهوية الوطنية'**
  String get nationalId;

  /// No description provided for @drivingLicense.
  ///
  /// In ar, this message translates to:
  /// **'رخصة القيادة'**
  String get drivingLicense;

  /// No description provided for @passport.
  ///
  /// In ar, this message translates to:
  /// **'جواز السفر'**
  String get passport;

  /// No description provided for @captureDocumentTitle.
  ///
  /// In ar, this message translates to:
  /// **'صوّر الوثيقة'**
  String get captureDocumentTitle;

  /// No description provided for @documentFront.
  ///
  /// In ar, this message translates to:
  /// **'الوجه الأمامي'**
  String get documentFront;

  /// No description provided for @documentBack.
  ///
  /// In ar, this message translates to:
  /// **'الوجه الخلفي'**
  String get documentBack;

  /// No description provided for @submitForReview.
  ///
  /// In ar, this message translates to:
  /// **'إرسال للمراجعة'**
  String get submitForReview;

  /// No description provided for @capturePhoto.
  ///
  /// In ar, this message translates to:
  /// **'التقاط صورة'**
  String get capturePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In ar, this message translates to:
  /// **'اختيار من المعرض'**
  String get chooseFromGallery;

  /// No description provided for @documentBackRequired.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تصوير الوجه الخلفي للوثيقة'**
  String get documentBackRequired;

  /// No description provided for @verificationSubmitFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إرسال الطلب، حاول مرة أخرى'**
  String get verificationSubmitFailed;

  /// No description provided for @verificationSentSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم الإرسال بنجاح'**
  String get verificationSentSuccess;

  /// No description provided for @verificationReviewNotice.
  ///
  /// In ar, this message translates to:
  /// **'سيتم مراجعة طلبك خلال 24 ساعة وسيصلك إشعار عند الموافقة'**
  String get verificationReviewNotice;

  /// No description provided for @backToHome.
  ///
  /// In ar, this message translates to:
  /// **'العودة للرئيسية'**
  String get backToHome;

  /// No description provided for @newSmartAlert.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه ذكي جديد'**
  String get newSmartAlert;

  /// No description provided for @alertNameHint.
  ///
  /// In ar, this message translates to:
  /// **'اسم التنبيه *'**
  String get alertNameHint;

  /// No description provided for @alertNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'اسم التنبيه مطلوب'**
  String get alertNameRequired;

  /// No description provided for @modelYear.
  ///
  /// In ar, this message translates to:
  /// **'سنة الصنع'**
  String get modelYear;

  /// No description provided for @fromLabel.
  ///
  /// In ar, this message translates to:
  /// **'من'**
  String get fromLabel;

  /// No description provided for @toLabel.
  ///
  /// In ar, this message translates to:
  /// **'إلى'**
  String get toLabel;

  /// No description provided for @allIraq.
  ///
  /// In ar, this message translates to:
  /// **'كل العراق'**
  String get allIraq;

  /// No description provided for @saveAlert.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التنبيه'**
  String get saveAlert;

  /// No description provided for @alertSavedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ التنبيه ✓ سنخبرك فور نشر إعلان مطابق'**
  String get alertSavedSuccess;

  /// No description provided for @alertSaveFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر حفظ التنبيه: {error}'**
  String alertSaveFailed(String error);

  /// No description provided for @newAlert.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه جديد'**
  String get newAlert;

  /// No description provided for @loginToManageAlerts.
  ///
  /// In ar, this message translates to:
  /// **'سجّل الدخول لإدارة التنبيهات'**
  String get loginToManageAlerts;

  /// No description provided for @noAlertsYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد تنبيهات بعد'**
  String get noAlertsYet;

  /// No description provided for @createAlertNow.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ تنبيهاً الآن'**
  String get createAlertNow;

  /// No description provided for @saveSearchAsAlert.
  ///
  /// In ar, this message translates to:
  /// **'احفظ هذا البحث كتنبيه ذكي 🔔'**
  String get saveSearchAsAlert;

  /// No description provided for @alertLimitFreeReached.
  ///
  /// In ar, this message translates to:
  /// **'وصلت للحد الأقصى للمستخدمين المجانيين (3 تنبيهات)'**
  String get alertLimitFreeReached;

  /// No description provided for @upgradeProUnlimitedAlerts.
  ///
  /// In ar, this message translates to:
  /// **'ترقّ إلى Pro للحصول على تنبيهات غير محدودة'**
  String get upgradeProUnlimitedAlerts;

  /// No description provided for @listingBoostedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم ترقية إعلانك بنجاح'**
  String get listingBoostedSuccess;

  /// No description provided for @boostYourListing.
  ///
  /// In ar, this message translates to:
  /// **'ترقية إعلانك'**
  String get boostYourListing;

  /// No description provided for @boostListingSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر الباقة المناسبة لزيادة ظهور إعلانك في أعلى الأقسام'**
  String get boostListingSubtitle;

  /// No description provided for @markAsSoldAction.
  ///
  /// In ar, this message translates to:
  /// **'مباع'**
  String get markAsSoldAction;

  /// No description provided for @markAsSoldTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعليم كمباع'**
  String get markAsSoldTitle;

  /// No description provided for @markAsSoldBody.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تعليم هذا الإعلان كمباع؟'**
  String get markAsSoldBody;

  /// No description provided for @deleteListingTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الإعلان'**
  String get deleteListingTitle;

  /// No description provided for @deleteListingBody.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد حذف هذا الإعلان؟'**
  String get deleteListingBody;

  /// No description provided for @promoteListing.
  ///
  /// In ar, this message translates to:
  /// **'ترويج'**
  String get promoteListing;

  /// No description provided for @republishListing.
  ///
  /// In ar, this message translates to:
  /// **'إعادة نشر'**
  String get republishListing;

  /// No description provided for @restoreListing.
  ///
  /// In ar, this message translates to:
  /// **'استعادة'**
  String get restoreListing;

  /// No description provided for @listingNumberWithRef.
  ///
  /// In ar, this message translates to:
  /// **'رقم الإعلان: #{ref}'**
  String listingNumberWithRef(String ref);

  /// No description provided for @listingNumberDash.
  ///
  /// In ar, this message translates to:
  /// **'رقم الإعلان: —'**
  String get listingNumberDash;

  /// No description provided for @contactUsOnSouqak.
  ///
  /// In ar, this message translates to:
  /// **'تواصل معنا على سـوقك'**
  String get contactUsOnSouqak;

  /// No description provided for @pendingApprovalTitle.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار موافقة الإدارة'**
  String get pendingApprovalTitle;

  /// No description provided for @pendingApprovalBody.
  ///
  /// In ar, this message translates to:
  /// **'تعديل، حذف، تم البيع، وواتساب ستظهر بعد الموافقة'**
  String get pendingApprovalBody;

  /// No description provided for @messageSeller.
  ///
  /// In ar, this message translates to:
  /// **'راسل البائع'**
  String get messageSeller;

  /// No description provided for @cannotMessageSelf.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكنك مراسلة نفسك'**
  String get cannotMessageSelf;

  /// No description provided for @openChatFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر فتح المحادثة'**
  String get openChatFailed;

  /// No description provided for @markedAsSoldSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم وضع علامة مباع'**
  String get markedAsSoldSuccess;

  /// No description provided for @rateBuyer.
  ///
  /// In ar, this message translates to:
  /// **'قيّم المشتري'**
  String get rateBuyer;

  /// No description provided for @deleteListingConfirmBody.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد؟ لا يمكن التراجع عن هذا الإجراء.'**
  String get deleteListingConfirmBody;

  /// No description provided for @listingDeletedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف الإعلان'**
  String get listingDeletedSuccess;

  /// No description provided for @reportChooseReason.
  ///
  /// In ar, this message translates to:
  /// **'اختر سبباً أو اكتب تفاصيل البلاغ'**
  String get reportChooseReason;

  /// No description provided for @reportSubmittedThanks.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال البلاغ. شكراً لمساعدتك.'**
  String get reportSubmittedThanks;

  /// No description provided for @reportSubmitFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إرسال البلاغ'**
  String get reportSubmitFailed;

  /// No description provided for @reportDetailsLabel.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل البلاغ'**
  String get reportDetailsLabel;

  /// No description provided for @submitReport.
  ///
  /// In ar, this message translates to:
  /// **'إرسال البلاغ'**
  String get submitReport;

  /// No description provided for @reportReasonDuplicate.
  ///
  /// In ar, this message translates to:
  /// **'إعلان مكرر'**
  String get reportReasonDuplicate;

  /// No description provided for @reportReasonMisleadingPrice.
  ///
  /// In ar, this message translates to:
  /// **'سعر مضلل'**
  String get reportReasonMisleadingPrice;

  /// No description provided for @reportReasonFakePhotos.
  ///
  /// In ar, this message translates to:
  /// **'صور مزيفة'**
  String get reportReasonFakePhotos;

  /// No description provided for @reportReasonInappropriate.
  ///
  /// In ar, this message translates to:
  /// **'محتوى غير لائق'**
  String get reportReasonInappropriate;

  /// No description provided for @reportReasonFraud.
  ///
  /// In ar, this message translates to:
  /// **'احتيال أو نصب'**
  String get reportReasonFraud;

  /// No description provided for @reportReasonOther.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get reportReasonOther;

  /// No description provided for @filtersTitle.
  ///
  /// In ar, this message translates to:
  /// **'الفلاتر'**
  String get filtersTitle;

  /// No description provided for @clearAll.
  ///
  /// In ar, this message translates to:
  /// **'مسح الكل'**
  String get clearAll;

  /// No description provided for @priceRangeLabel.
  ///
  /// In ar, this message translates to:
  /// **'نطاق السعر'**
  String get priceRangeLabel;

  /// No description provided for @additionalOptions.
  ///
  /// In ar, this message translates to:
  /// **'خيارات إضافية'**
  String get additionalOptions;

  /// No description provided for @featuredOnlyLabel.
  ///
  /// In ar, this message translates to:
  /// **'إعلانات مميزة فقط'**
  String get featuredOnlyLabel;

  /// No description provided for @negotiableOnlyLabel.
  ///
  /// In ar, this message translates to:
  /// **'قابل للتفاوض فقط'**
  String get negotiableOnlyLabel;

  /// No description provided for @showResultsCount.
  ///
  /// In ar, this message translates to:
  /// **'عرض {count} نتيجة'**
  String showResultsCount(String count);

  /// No description provided for @showResultsLoading.
  ///
  /// In ar, this message translates to:
  /// **'عرض النتائج...'**
  String get showResultsLoading;

  /// No description provided for @showResults.
  ///
  /// In ar, this message translates to:
  /// **'عرض النتائج'**
  String get showResults;

  /// No description provided for @editChangesSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ التعديلات ✓'**
  String get editChangesSaved;

  /// No description provided for @editListingTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الإعلان'**
  String get editListingTitle;

  /// No description provided for @saveEdits.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التعديلات'**
  String get saveEdits;

  /// No description provided for @heatmapTitle.
  ///
  /// In ar, this message translates to:
  /// **'خريطة الإعلانات'**
  String get heatmapTitle;

  /// No description provided for @heatmapLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل بيانات الكثافة'**
  String get heatmapLoadFailed;

  /// No description provided for @heatmapNoActiveListings.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إعلانات نشطة في المناطق المعروضة حالياً'**
  String get heatmapNoActiveListings;

  /// No description provided for @heatmapClusterSummary.
  ///
  /// In ar, this message translates to:
  /// **'{areas} مناطق · {total} إعلان'**
  String heatmapClusterSummary(String areas, String total);

  /// No description provided for @heatmapSelectArea.
  ///
  /// In ar, this message translates to:
  /// **'اختر منطقة لعرض الإعلانات'**
  String get heatmapSelectArea;

  /// No description provided for @showListingsAction.
  ///
  /// In ar, this message translates to:
  /// **'عرض الإعلانات'**
  String get showListingsAction;

  /// No description provided for @heatmapFilterCars.
  ///
  /// In ar, this message translates to:
  /// **'سيارات'**
  String get heatmapFilterCars;

  /// No description provided for @heatmapDensityCars.
  ///
  /// In ar, this message translates to:
  /// **'يوجد {count} سيارة للبيع الآن في {area}'**
  String heatmapDensityCars(String count, String area);

  /// No description provided for @heatmapDensityRealEstate.
  ///
  /// In ar, this message translates to:
  /// **'يوجد {count} إعلان عقاري الآن في {area}'**
  String heatmapDensityRealEstate(String count, String area);

  /// No description provided for @heatmapDensityElectronics.
  ///
  /// In ar, this message translates to:
  /// **'يوجد {count} إعلان إلكترونيات الآن في {area}'**
  String heatmapDensityElectronics(String count, String area);

  /// No description provided for @heatmapDensityGeneric.
  ///
  /// In ar, this message translates to:
  /// **'يوجد {count} إعلان نشط حالياً في {area}'**
  String heatmapDensityGeneric(String count, String area);

  /// No description provided for @listingPendingReviewStats.
  ///
  /// In ar, this message translates to:
  /// **'إعلانك قيد المراجعة — الإحصائيات تُحدَّث تلقائياً بعد النشر'**
  String get listingPendingReviewStats;

  /// No description provided for @contactStatLabel.
  ///
  /// In ar, this message translates to:
  /// **'تواصل'**
  String get contactStatLabel;

  /// No description provided for @autoRenewLabel.
  ///
  /// In ar, this message translates to:
  /// **'التجديد التلقائي'**
  String get autoRenewLabel;

  /// No description provided for @autoRenewAfterApproval.
  ///
  /// In ar, this message translates to:
  /// **'يُفعَّل بعد موافقة الإدارة على الإعلان'**
  String get autoRenewAfterApproval;

  /// No description provided for @expiresInDays.
  ///
  /// In ar, this message translates to:
  /// **'ينتهي بعد {days} يوم'**
  String expiresInDays(String days);

  /// No description provided for @priceChangeTitle.
  ///
  /// In ar, this message translates to:
  /// **'تغيير السعر'**
  String get priceChangeTitle;

  /// No description provided for @priceChangeWarning.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه: تغيير السعر سيظهر لجميع المشترين في تاريخ السعر'**
  String get priceChangeWarning;

  /// No description provided for @confirmChange.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد التغيير'**
  String get confirmChange;

  /// No description provided for @publishSuccessDone.
  ///
  /// In ar, this message translates to:
  /// **'تم ✓'**
  String get publishSuccessDone;

  /// No description provided for @listingPendingReviewTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعلانك قيد المراجعة'**
  String get listingPendingReviewTitle;

  /// No description provided for @listingVisibleAfterApproval.
  ///
  /// In ar, this message translates to:
  /// **'سيظهر للجميع بعد الموافقة'**
  String get listingVisibleAfterApproval;

  /// No description provided for @okAction.
  ///
  /// In ar, this message translates to:
  /// **'موافق'**
  String get okAction;

  /// No description provided for @closeTooltip.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get closeTooltip;

  /// No description provided for @addPhotoLabel.
  ///
  /// In ar, this message translates to:
  /// **'إضافة صورة'**
  String get addPhotoLabel;

  /// No description provided for @coverPhotoLabel.
  ///
  /// In ar, this message translates to:
  /// **'الغلاف'**
  String get coverPhotoLabel;

  /// No description provided for @priceEstimateFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تقدير السعر، حاول مرة أخرى'**
  String get priceEstimateFailed;

  /// No description provided for @calculateSuggestedPrice.
  ///
  /// In ar, this message translates to:
  /// **'✨ احسب السعر المقترح'**
  String get calculateSuggestedPrice;

  /// No description provided for @confidenceHigh.
  ///
  /// In ar, this message translates to:
  /// **'عالية'**
  String get confidenceHigh;

  /// No description provided for @confidenceMedium.
  ///
  /// In ar, this message translates to:
  /// **'متوسطة'**
  String get confidenceMedium;

  /// No description provided for @confidenceLow.
  ///
  /// In ar, this message translates to:
  /// **'منخفضة'**
  String get confidenceLow;

  /// No description provided for @aiPriceEstimateTitle.
  ///
  /// In ar, this message translates to:
  /// **'تقدير الذكاء الاصطناعي'**
  String get aiPriceEstimateTitle;

  /// No description provided for @priceEstimateDisclaimer.
  ///
  /// In ar, this message translates to:
  /// **'هذا تقدير تقريبي وليس سعراً نهائياً'**
  String get priceEstimateDisclaimer;

  /// No description provided for @phoneOtpWhatsappHint.
  ///
  /// In ar, this message translates to:
  /// **'سنرسل لك رمز تحقق عبر واتساب'**
  String get phoneOtpWhatsappHint;

  /// No description provided for @passwordResetResent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الرابط مرة أخرى'**
  String get passwordResetResent;

  /// No description provided for @passwordResetSentTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الرابط'**
  String get passwordResetSentTitle;

  /// No description provided for @passwordResetSentSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رابط إعادة التعيين إلى بريدك'**
  String get passwordResetSentSubtitle;

  /// No description provided for @passwordResetInstructions.
  ///
  /// In ar, this message translates to:
  /// **'افتح الرابط في بريدك لإنشاء كلمة مرور جديدة. قد يستغرق وصول الرسالة بضع دقائق.'**
  String get passwordResetInstructions;

  /// No description provided for @resendLink.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال'**
  String get resendLink;

  /// No description provided for @backToLogin.
  ///
  /// In ar, this message translates to:
  /// **'العودة لتسجيل الدخول'**
  String get backToLogin;

  /// No description provided for @videoLoadFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل الفيديو'**
  String get videoLoadFailed;

  /// No description provided for @listingsOnSouqakCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} إعلاناً على سـوقك'**
  String listingsOnSouqakCount(String count);

  /// No description provided for @vehicleDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المركبة'**
  String get vehicleDetailsTitle;

  /// No description provided for @basicInfoTitle.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الأساسية'**
  String get basicInfoTitle;

  /// No description provided for @vehicleTrimLabel.
  ///
  /// In ar, this message translates to:
  /// **'الفئة'**
  String get vehicleTrimLabel;

  /// No description provided for @trimExampleHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: SE'**
  String get trimExampleHint;

  /// No description provided for @mileageLabel.
  ///
  /// In ar, this message translates to:
  /// **'المسافة'**
  String get mileageLabel;

  /// No description provided for @engineLabel.
  ///
  /// In ar, this message translates to:
  /// **'المحرك'**
  String get engineLabel;

  /// No description provided for @cylindersLabel.
  ///
  /// In ar, this message translates to:
  /// **'الأسطوانات'**
  String get cylindersLabel;

  /// No description provided for @paintStatusLabel.
  ///
  /// In ar, this message translates to:
  /// **'وضع الطلاء'**
  String get paintStatusLabel;

  /// No description provided for @fuelRequiredLabel.
  ///
  /// In ar, this message translates to:
  /// **'الوقود *'**
  String get fuelRequiredLabel;

  /// No description provided for @importCountryLabel.
  ///
  /// In ar, this message translates to:
  /// **'بلد الاستيراد'**
  String get importCountryLabel;

  /// No description provided for @plateLabel.
  ///
  /// In ar, this message translates to:
  /// **'اللوحة'**
  String get plateLabel;

  /// No description provided for @transmissionRequiredLabel.
  ///
  /// In ar, this message translates to:
  /// **'ناقل الحركة *'**
  String get transmissionRequiredLabel;

  /// No description provided for @seatCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'عدد المقاعد'**
  String get seatCountLabel;

  /// No description provided for @seatMaterialLabel.
  ///
  /// In ar, this message translates to:
  /// **'مادة المقاعد'**
  String get seatMaterialLabel;

  /// No description provided for @specsSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'المواصفات'**
  String get specsSectionTitle;

  /// No description provided for @priceRequiredLabel.
  ///
  /// In ar, this message translates to:
  /// **'السعر *'**
  String get priceRequiredLabel;

  /// No description provided for @conditionRequiredLabel.
  ///
  /// In ar, this message translates to:
  /// **'الحالة *'**
  String get conditionRequiredLabel;

  /// No description provided for @yearLabel.
  ///
  /// In ar, this message translates to:
  /// **'السنة'**
  String get yearLabel;

  /// No description provided for @chooseColorPlaceholder.
  ///
  /// In ar, this message translates to:
  /// **'اختر اللون'**
  String get chooseColorPlaceholder;

  /// No description provided for @chooseCustomColorTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر لوناً مخصصاً'**
  String get chooseCustomColorTitle;

  /// No description provided for @colorLabel.
  ///
  /// In ar, this message translates to:
  /// **'اللون'**
  String get colorLabel;

  /// No description provided for @paintOriginalLabel.
  ///
  /// In ar, this message translates to:
  /// **'أصلي'**
  String get paintOriginalLabel;

  /// No description provided for @paintLocalLabel.
  ///
  /// In ar, this message translates to:
  /// **'بوية محلية'**
  String get paintLocalLabel;

  /// No description provided for @paintPaintedLabel.
  ///
  /// In ar, this message translates to:
  /// **'مصبوغة'**
  String get paintPaintedLabel;

  /// No description provided for @paintReplacedLabel.
  ///
  /// In ar, this message translates to:
  /// **'مستبدلة'**
  String get paintReplacedLabel;

  /// No description provided for @vehicleSpecsSelectedCount.
  ///
  /// In ar, this message translates to:
  /// **'تم اختيار {count} مواصفة'**
  String vehicleSpecsSelectedCount(String count);

  /// No description provided for @electronicsPhoneDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الهاتف'**
  String get electronicsPhoneDetailsTitle;

  /// No description provided for @electronicsLaptopDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل اللابتوب'**
  String get electronicsLaptopDetailsTitle;

  /// No description provided for @electronicsTvDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل التلفزيون'**
  String get electronicsTvDetailsTitle;

  /// No description provided for @electronicsDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الإلكترونيات'**
  String get electronicsDetailsTitle;

  /// No description provided for @brandLabel.
  ///
  /// In ar, this message translates to:
  /// **'الماركة'**
  String get brandLabel;

  /// No description provided for @modelLabel.
  ///
  /// In ar, this message translates to:
  /// **'الموديل'**
  String get modelLabel;

  /// No description provided for @storageLabel.
  ///
  /// In ar, this message translates to:
  /// **'التخزين'**
  String get storageLabel;

  /// No description provided for @ramLabel.
  ///
  /// In ar, this message translates to:
  /// **'الرام'**
  String get ramLabel;

  /// No description provided for @batteryHealthLabel.
  ///
  /// In ar, this message translates to:
  /// **'صحة البطارية'**
  String get batteryHealthLabel;

  /// No description provided for @withBoxLabel.
  ///
  /// In ar, this message translates to:
  /// **'مع العلبة'**
  String get withBoxLabel;

  /// No description provided for @withChargerLabel.
  ///
  /// In ar, this message translates to:
  /// **'مع الشاحن'**
  String get withChargerLabel;

  /// No description provided for @warrantyLabel.
  ///
  /// In ar, this message translates to:
  /// **'الضمان'**
  String get warrantyLabel;

  /// No description provided for @processorLabel.
  ///
  /// In ar, this message translates to:
  /// **'المعالج'**
  String get processorLabel;

  /// No description provided for @screenSizeInchesLabel.
  ///
  /// In ar, this message translates to:
  /// **'حجم الشاشة (بوصة)'**
  String get screenSizeInchesLabel;

  /// No description provided for @resolutionLabel.
  ///
  /// In ar, this message translates to:
  /// **'الدقة'**
  String get resolutionLabel;

  /// No description provided for @realEstateDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل العقار'**
  String get realEstateDetailsTitle;

  /// No description provided for @propertyTypeRequiredLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع العقار *'**
  String get propertyTypeRequiredLabel;

  /// No description provided for @offerTypeRequiredLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع العرض *'**
  String get offerTypeRequiredLabel;

  /// No description provided for @areaSqmRequiredLabel.
  ///
  /// In ar, this message translates to:
  /// **'المساحة (م²) *'**
  String get areaSqmRequiredLabel;

  /// No description provided for @sqmUnit.
  ///
  /// In ar, this message translates to:
  /// **'م²'**
  String get sqmUnit;

  /// No description provided for @floorLabel.
  ///
  /// In ar, this message translates to:
  /// **'الطابق'**
  String get floorLabel;

  /// No description provided for @roomsCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'عدد الغرف'**
  String get roomsCountLabel;

  /// No description provided for @bathroomsCountLabel.
  ///
  /// In ar, this message translates to:
  /// **'عدد الحمامات'**
  String get bathroomsCountLabel;

  /// No description provided for @buildingAgeYearsLabel.
  ///
  /// In ar, this message translates to:
  /// **'عمر البناء (سنة)'**
  String get buildingAgeYearsLabel;

  /// No description provided for @finishingLabel.
  ///
  /// In ar, this message translates to:
  /// **'التشطيب'**
  String get finishingLabel;

  /// No description provided for @deedTypeLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع الصك'**
  String get deedTypeLabel;

  /// No description provided for @featuresSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'المميزات'**
  String get featuresSectionTitle;

  /// No description provided for @brandOptionalLabel.
  ///
  /// In ar, this message translates to:
  /// **'الماركة (اختياري)'**
  String get brandOptionalLabel;

  /// No description provided for @exchangePossibleQuestion.
  ///
  /// In ar, this message translates to:
  /// **'قابل للتبادل؟'**
  String get exchangePossibleQuestion;

  /// No description provided for @deliveryAvailableQuestion.
  ///
  /// In ar, this message translates to:
  /// **'توصيل متاح؟'**
  String get deliveryAvailableQuestion;

  /// No description provided for @deliveryCostRequiredLabel.
  ///
  /// In ar, this message translates to:
  /// **'تكلفة التوصيل *'**
  String get deliveryCostRequiredLabel;

  /// No description provided for @jobDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الوظيفة'**
  String get jobDetailsTitle;

  /// No description provided for @jobTypeRequiredLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع الدوام *'**
  String get jobTypeRequiredLabel;

  /// No description provided for @sectorRequiredLabel.
  ///
  /// In ar, this message translates to:
  /// **'القطاع *'**
  String get sectorRequiredLabel;

  /// No description provided for @experienceRequiredLabel.
  ///
  /// In ar, this message translates to:
  /// **'الخبرة المطلوبة'**
  String get experienceRequiredLabel;

  /// No description provided for @educationRequiredLabel.
  ///
  /// In ar, this message translates to:
  /// **'المؤهل المطلوب'**
  String get educationRequiredLabel;

  /// No description provided for @genderPreferenceLabel.
  ///
  /// In ar, this message translates to:
  /// **'تفضيل الجنس'**
  String get genderPreferenceLabel;

  /// No description provided for @salaryTypeLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع الراتب'**
  String get salaryTypeLabel;

  /// No description provided for @salaryMinRequiredLabel.
  ///
  /// In ar, this message translates to:
  /// **'الراتب الأدنى *'**
  String get salaryMinRequiredLabel;

  /// No description provided for @salaryMaxLabel.
  ///
  /// In ar, this message translates to:
  /// **'الراتب الأعلى'**
  String get salaryMaxLabel;

  /// No description provided for @benefitsSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'المزايا'**
  String get benefitsSectionTitle;

  /// No description provided for @serviceDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الخدمة'**
  String get serviceDetailsTitle;

  /// No description provided for @genderLabel.
  ///
  /// In ar, this message translates to:
  /// **'الجنس'**
  String get genderLabel;

  /// No description provided for @nationalityLabel.
  ///
  /// In ar, this message translates to:
  /// **'الجنسية'**
  String get nationalityLabel;

  /// No description provided for @workHoursRequiredLabel.
  ///
  /// In ar, this message translates to:
  /// **'أوقات العمل *'**
  String get workHoursRequiredLabel;

  /// No description provided for @weekDaysLabel.
  ///
  /// In ar, this message translates to:
  /// **'أيام الأسبوع'**
  String get weekDaysLabel;

  /// No description provided for @yearsExperienceLabel.
  ///
  /// In ar, this message translates to:
  /// **'سنوات الخبرة'**
  String get yearsExperienceLabel;

  /// No description provided for @expectedSalaryRequiredLabel.
  ///
  /// In ar, this message translates to:
  /// **'الراتب المتوقع *'**
  String get expectedSalaryRequiredLabel;

  /// No description provided for @languagesSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'اللغات'**
  String get languagesSectionTitle;

  /// No description provided for @animalDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الحيوان'**
  String get animalDetailsTitle;

  /// No description provided for @ageMonthsLabel.
  ///
  /// In ar, this message translates to:
  /// **'العمر (بالأشهر)'**
  String get ageMonthsLabel;

  /// No description provided for @vaccinatedQuestion.
  ///
  /// In ar, this message translates to:
  /// **'ملقح؟'**
  String get vaccinatedQuestion;

  /// No description provided for @hasDocumentsQuestion.
  ///
  /// In ar, this message translates to:
  /// **'يمتلك وثائق؟'**
  String get hasDocumentsQuestion;

  /// No description provided for @trainedQuestion.
  ///
  /// In ar, this message translates to:
  /// **'مدرب؟'**
  String get trainedQuestion;

  /// No description provided for @tutoringDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الدرس'**
  String get tutoringDetailsTitle;

  /// No description provided for @subjectRequiredLabel.
  ///
  /// In ar, this message translates to:
  /// **'المادة *'**
  String get subjectRequiredLabel;

  /// No description provided for @studyStageRequiredLabel.
  ///
  /// In ar, this message translates to:
  /// **'المرحلة الدراسية *'**
  String get studyStageRequiredLabel;

  /// No description provided for @curriculumLabel.
  ///
  /// In ar, this message translates to:
  /// **'المنهج'**
  String get curriculumLabel;

  /// No description provided for @teachingMethodRequiredLabel.
  ///
  /// In ar, this message translates to:
  /// **'طريقة التدريس *'**
  String get teachingMethodRequiredLabel;

  /// No description provided for @acceptedGenderLabel.
  ///
  /// In ar, this message translates to:
  /// **'الجنس المقبول'**
  String get acceptedGenderLabel;

  /// No description provided for @pricePerHourRequiredLabel.
  ///
  /// In ar, this message translates to:
  /// **'السعر/ساعة *'**
  String get pricePerHourRequiredLabel;

  /// No description provided for @educationQualificationLabel.
  ///
  /// In ar, this message translates to:
  /// **'المؤهل العلمي'**
  String get educationQualificationLabel;

  /// No description provided for @viewOnMapLabel.
  ///
  /// In ar, this message translates to:
  /// **'عرض على الخريطة'**
  String get viewOnMapLabel;

  /// No description provided for @videoSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'الفيديو'**
  String get videoSectionTitle;

  /// No description provided for @currentVideoReplaceHint.
  ///
  /// In ar, this message translates to:
  /// **'الفيديو الحالي — يمكنك استبداله بفيديو جديد أدناه'**
  String get currentVideoReplaceHint;

  /// No description provided for @addDemoVideoTitle.
  ///
  /// In ar, this message translates to:
  /// **'أضف فيديو توضيحي (حتى 60 ثانية)'**
  String get addDemoVideoTitle;

  /// No description provided for @proSubscribersOnly.
  ///
  /// In ar, this message translates to:
  /// **'متاح لمشتركي Pro و Premium فقط'**
  String get proSubscribersOnly;

  /// No description provided for @upgradeToProLock.
  ///
  /// In ar, this message translates to:
  /// **'ترقّ إلى Pro 🔒'**
  String get upgradeToProLock;

  /// No description provided for @processingVideoProgress.
  ///
  /// In ar, this message translates to:
  /// **'جاري معالجة الفيديو... {percent}%'**
  String processingVideoProgress(String percent);

  /// No description provided for @chooseVideoLabel.
  ///
  /// In ar, this message translates to:
  /// **'اختر فيديو'**
  String get chooseVideoLabel;

  /// No description provided for @recordVideoLabel.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل فيديو'**
  String get recordVideoLabel;

  /// No description provided for @videoProcessFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر معالجة الفيديو'**
  String get videoProcessFailed;

  /// No description provided for @invalidVideoError.
  ///
  /// In ar, this message translates to:
  /// **'فيديو غير صالح'**
  String get invalidVideoError;

  /// No description provided for @imageProcessFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر معالجة الصورة'**
  String get imageProcessFailed;

  /// No description provided for @chooseCategoryError.
  ///
  /// In ar, this message translates to:
  /// **'اختر الفئة'**
  String get chooseCategoryError;

  /// No description provided for @chooseContactPreferenceError.
  ///
  /// In ar, this message translates to:
  /// **'اختر تفضيل التواصل'**
  String get chooseContactPreferenceError;

  /// No description provided for @chooseGovernorateError.
  ///
  /// In ar, this message translates to:
  /// **'اختر المحافظة'**
  String get chooseGovernorateError;

  /// No description provided for @enterValidPriceError.
  ///
  /// In ar, this message translates to:
  /// **'أدخل سعراً صالحاً'**
  String get enterValidPriceError;

  /// No description provided for @chooseProductConditionError.
  ///
  /// In ar, this message translates to:
  /// **'اختر حالة المنتج'**
  String get chooseProductConditionError;

  /// No description provided for @chooseConditionError.
  ///
  /// In ar, this message translates to:
  /// **'اختر الحالة'**
  String get chooseConditionError;

  /// No description provided for @chooseFuelTypeError.
  ///
  /// In ar, this message translates to:
  /// **'اختر نوع الوقود'**
  String get chooseFuelTypeError;

  /// No description provided for @chooseTransmissionError.
  ///
  /// In ar, this message translates to:
  /// **'اختر ناقل الحركة'**
  String get chooseTransmissionError;

  /// No description provided for @choosePropertyTypeError.
  ///
  /// In ar, this message translates to:
  /// **'اختر نوع العقار'**
  String get choosePropertyTypeError;

  /// No description provided for @chooseOfferTypeError.
  ///
  /// In ar, this message translates to:
  /// **'اختر نوع العرض'**
  String get chooseOfferTypeError;

  /// No description provided for @enterAreaSqmError.
  ///
  /// In ar, this message translates to:
  /// **'أدخل المساحة بالمتر المربع'**
  String get enterAreaSqmError;

  /// No description provided for @chooseDeliveryCostError.
  ///
  /// In ar, this message translates to:
  /// **'اختر تكلفة التوصيل'**
  String get chooseDeliveryCostError;

  /// No description provided for @chooseSubjectError.
  ///
  /// In ar, this message translates to:
  /// **'اختر المادة'**
  String get chooseSubjectError;

  /// No description provided for @chooseStudyStageError.
  ///
  /// In ar, this message translates to:
  /// **'اختر المرحلة الدراسية'**
  String get chooseStudyStageError;

  /// No description provided for @chooseTeachingMethodError.
  ///
  /// In ar, this message translates to:
  /// **'اختر طريقة التدريس'**
  String get chooseTeachingMethodError;

  /// No description provided for @enterValidHourlyPriceError.
  ///
  /// In ar, this message translates to:
  /// **'أدخل سعراً صالحاً للساعة'**
  String get enterValidHourlyPriceError;

  /// No description provided for @chooseJobTypeError.
  ///
  /// In ar, this message translates to:
  /// **'اختر نوع الدوام'**
  String get chooseJobTypeError;

  /// No description provided for @chooseSectorError.
  ///
  /// In ar, this message translates to:
  /// **'اختر القطاع'**
  String get chooseSectorError;

  /// No description provided for @enterMinSalaryError.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الراتب الأدنى'**
  String get enterMinSalaryError;

  /// No description provided for @salaryMaxMustExceedMinError.
  ///
  /// In ar, this message translates to:
  /// **'الراتب الأعلى يجب أن يكون أكبر من الأدنى'**
  String get salaryMaxMustExceedMinError;

  /// No description provided for @chooseAnimalTypeFromCategoriesError.
  ///
  /// In ar, this message translates to:
  /// **'اختر نوع الحيوان من الفئات'**
  String get chooseAnimalTypeFromCategoriesError;

  /// No description provided for @chooseServiceTypeFromCategoriesError.
  ///
  /// In ar, this message translates to:
  /// **'اختر نوع الخدمة من الفئات'**
  String get chooseServiceTypeFromCategoriesError;

  /// No description provided for @chooseWorkHoursError.
  ///
  /// In ar, this message translates to:
  /// **'اختر أوقات العمل'**
  String get chooseWorkHoursError;

  /// No description provided for @enterExpectedSalaryError.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الراتب المتوقع'**
  String get enterExpectedSalaryError;

  /// No description provided for @titleTooLongError.
  ///
  /// In ar, this message translates to:
  /// **'العنوان طويل جداً (100 حرف كحد أقصى)'**
  String get titleTooLongError;

  /// No description provided for @descriptionTooLongError.
  ///
  /// In ar, this message translates to:
  /// **'الوصف طويل جداً (2000 حرف كحد أقصى)'**
  String get descriptionTooLongError;

  /// No description provided for @uploadingPhotosSimple.
  ///
  /// In ar, this message translates to:
  /// **'جاري رفع الصور...'**
  String get uploadingPhotosSimple;

  /// No description provided for @uploadingVideoProgress.
  ///
  /// In ar, this message translates to:
  /// **'جاري رفع الفيديو... {percent}%'**
  String uploadingVideoProgress(String percent);

  /// No description provided for @publishListingFailedError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر نشر الإعلان. حاول مرة أخرى.'**
  String get publishListingFailedError;

  /// No description provided for @chooseCategoryMinimumError.
  ///
  /// In ar, this message translates to:
  /// **'اختر الفئة على الأقل'**
  String get chooseCategoryMinimumError;

  /// No description provided for @draftTitleFallback.
  ///
  /// In ar, this message translates to:
  /// **'مسودة'**
  String get draftTitleFallback;

  /// No description provided for @saveDraftFailedError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر حفظ المسودة'**
  String get saveDraftFailedError;

  /// No description provided for @cannotEditListingError.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكنك تعديل هذا الإعلان'**
  String get cannotEditListingError;

  /// No description provided for @loadListingFailedError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل الإعلان'**
  String get loadListingFailedError;

  /// No description provided for @enterListingTitleError.
  ///
  /// In ar, this message translates to:
  /// **'أدخل عنوان الإعلان'**
  String get enterListingTitleError;

  /// No description provided for @addAtLeastOnePhotoError.
  ///
  /// In ar, this message translates to:
  /// **'أضف صورة واحدة على الأقل'**
  String get addAtLeastOnePhotoError;

  /// No description provided for @saveEditsFailedError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر حفظ التعديلات'**
  String get saveEditsFailedError;

  /// No description provided for @chatListingIntro.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً، أنا مهتم بإعلانك: {title}'**
  String chatListingIntro(String title);

  /// No description provided for @usernameChecking.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحقق...'**
  String get usernameChecking;

  /// No description provided for @usernameAvailable.
  ///
  /// In ar, this message translates to:
  /// **'متاح ✓'**
  String get usernameAvailable;

  /// No description provided for @usernameTaken.
  ///
  /// In ar, this message translates to:
  /// **'مستخدم بالفعل ✗'**
  String get usernameTaken;

  /// No description provided for @usernameRules.
  ///
  /// In ar, this message translates to:
  /// **'3–20 حرفاً: أحرف إنجليزية وأرقام و _ فقط'**
  String get usernameRules;

  /// No description provided for @ratingsCount.
  ///
  /// In ar, this message translates to:
  /// **'({count} تقييم)'**
  String ratingsCount(String count);

  /// No description provided for @authSessionFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تسجيل الدخول. حاول مرة أخرى.'**
  String get authSessionFailed;

  /// No description provided for @chooseAvatar.
  ///
  /// In ar, this message translates to:
  /// **'اختر صورتك'**
  String get chooseAvatar;

  /// No description provided for @avatarIconsSection.
  ///
  /// In ar, this message translates to:
  /// **'الصور الرمزية'**
  String get avatarIconsSection;

  /// No description provided for @chooseDefaultAvatar.
  ///
  /// In ar, this message translates to:
  /// **'اختر صورة افتراضية'**
  String get chooseDefaultAvatar;

  /// No description provided for @orUploadPhotoHint.
  ///
  /// In ar, this message translates to:
  /// **'أو ارفع صورتك من الكاميرا / المعرض أعلاه'**
  String get orUploadPhotoHint;

  /// No description provided for @countryIraq.
  ///
  /// In ar, this message translates to:
  /// **'العراق'**
  String get countryIraq;

  /// No description provided for @matchingListingsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} إعلان مطابق'**
  String matchingListingsCount(String count);

  /// No description provided for @searchResultsTitle.
  ///
  /// In ar, this message translates to:
  /// **'نتائج البحث'**
  String get searchResultsTitle;

  /// No description provided for @searchResultCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} نتيجة'**
  String searchResultCount(String count);

  /// No description provided for @filterCategoryLabel.
  ///
  /// In ar, this message translates to:
  /// **'فئة'**
  String get filterCategoryLabel;

  /// No description provided for @filterPriceLabel.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get filterPriceLabel;

  /// No description provided for @filterFeaturedLabel.
  ///
  /// In ar, this message translates to:
  /// **'مميز'**
  String get filterFeaturedLabel;

  /// No description provided for @accountVerifiedBanner.
  ///
  /// In ar, this message translates to:
  /// **'حسابك موثّق ✓'**
  String get accountVerifiedBanner;

  /// No description provided for @verificationPendingBanner.
  ///
  /// In ar, this message translates to:
  /// **'طلب التوثيق قيد المراجعة ⏳'**
  String get verificationPendingBanner;

  /// No description provided for @verificationRejectedWithReason.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض طلبك — {reason}'**
  String verificationRejectedWithReason(String reason);

  /// No description provided for @verificationRejectedBanner.
  ///
  /// In ar, this message translates to:
  /// **'تم رفض طلب التوثيق'**
  String get verificationRejectedBanner;

  /// No description provided for @verifyAccountPrompt.
  ///
  /// In ar, this message translates to:
  /// **'وثّق حسابك للحصول على شارة الثقة 🔒'**
  String get verifyAccountPrompt;

  /// No description provided for @vehicleYearLabel.
  ///
  /// In ar, this message translates to:
  /// **'السنة'**
  String get vehicleYearLabel;

  /// No description provided for @vehicleTrimShortLabel.
  ///
  /// In ar, this message translates to:
  /// **'الفئة'**
  String get vehicleTrimShortLabel;

  /// No description provided for @vehicleEngineShortLabel.
  ///
  /// In ar, this message translates to:
  /// **'محرك'**
  String get vehicleEngineShortLabel;

  /// No description provided for @vehicleCylinderShortLabel.
  ///
  /// In ar, this message translates to:
  /// **'أسطوانة'**
  String get vehicleCylinderShortLabel;

  /// No description provided for @photosSectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'الصور'**
  String get photosSectionTitle;

  /// No description provided for @currentPhotosTitle.
  ///
  /// In ar, this message translates to:
  /// **'الصور الحالية'**
  String get currentPhotosTitle;

  /// No description provided for @clearAllFilters.
  ///
  /// In ar, this message translates to:
  /// **'مسح الكل'**
  String get clearAllFilters;

  /// No description provided for @noResultsForQuery.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على نتائج لـ «{query}»'**
  String noResultsForQuery(String query);

  /// No description provided for @tryChangingSearchOrFilters.
  ///
  /// In ar, this message translates to:
  /// **'حاول تغيير كلمة البحث أو الفلاتر'**
  String get tryChangingSearchOrFilters;

  /// No description provided for @clearFilters.
  ///
  /// In ar, this message translates to:
  /// **'مسح الفلاتر'**
  String get clearFilters;

  /// No description provided for @loadingMore.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل المزيد...'**
  String get loadingMore;

  /// No description provided for @noResultsFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على نتائج'**
  String get noResultsFound;

  /// No description provided for @attr_1aae214b.
  ///
  /// In ar, this message translates to:
  /// **'8 وسائد هوائية'**
  String get attr_1aae214b;

  /// No description provided for @colorOther.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get colorOther;

  /// No description provided for @colorWhite.
  ///
  /// In ar, this message translates to:
  /// **'أبيض'**
  String get colorWhite;

  /// No description provided for @attr_1a93e294.
  ///
  /// In ar, this message translates to:
  /// **'أجنبي'**
  String get attr_1a93e294;

  /// No description provided for @colorRed.
  ///
  /// In ar, this message translates to:
  /// **'أحمر'**
  String get colorRed;

  /// No description provided for @colorGreen.
  ///
  /// In ar, this message translates to:
  /// **'أخضر'**
  String get colorGreen;

  /// No description provided for @attr_10f56232.
  ///
  /// In ar, this message translates to:
  /// **'أربيل'**
  String get attr_10f56232;

  /// No description provided for @propLand.
  ///
  /// In ar, this message translates to:
  /// **'أرض'**
  String get propLand;

  /// No description provided for @attr_60b69dc6.
  ///
  /// In ar, this message translates to:
  /// **'أرنب'**
  String get attr_60b69dc6;

  /// No description provided for @colorBlue.
  ///
  /// In ar, this message translates to:
  /// **'أزرق'**
  String get colorBlue;

  /// No description provided for @colorBlack.
  ///
  /// In ar, this message translates to:
  /// **'أسود'**
  String get colorBlack;

  /// No description provided for @attr_97418f6f.
  ///
  /// In ar, this message translates to:
  /// **'ألماني'**
  String get attr_97418f6f;

  /// No description provided for @attr_dd1fbe22.
  ///
  /// In ar, this message translates to:
  /// **'أمريكي'**
  String get attr_dd1fbe22;

  /// No description provided for @genderFemale.
  ///
  /// In ar, this message translates to:
  /// **'أنثى'**
  String get genderFemale;

  /// No description provided for @transAutomatic.
  ///
  /// In ar, this message translates to:
  /// **'أوتوماتيك'**
  String get transAutomatic;

  /// No description provided for @attr_0d67ce95.
  ///
  /// In ar, this message translates to:
  /// **'أوروبي'**
  String get attr_0d67ce95;

  /// No description provided for @attr_ea410cd6.
  ///
  /// In ar, this message translates to:
  /// **'أونلاين'**
  String get attr_ea410cd6;

  /// No description provided for @attr_9967c75e.
  ///
  /// In ar, this message translates to:
  /// **'إجازة سنوية'**
  String get attr_9967c75e;

  /// No description provided for @attr_fd5a68db.
  ///
  /// In ar, this message translates to:
  /// **'إضاءة LED'**
  String get attr_fd5a68db;

  /// No description provided for @attr_cfb972ef.
  ///
  /// In ar, this message translates to:
  /// **'إضاءة تكيفية'**
  String get attr_cfb972ef;

  /// No description provided for @attr_0d092cb1.
  ///
  /// In ar, this message translates to:
  /// **'إضاءة عالية تلقائية'**
  String get attr_0d092cb1;

  /// No description provided for @attr_407ad989.
  ///
  /// In ar, this message translates to:
  /// **'إضاءة ليزر'**
  String get attr_407ad989;

  /// No description provided for @attr_8c495f8e.
  ///
  /// In ar, this message translates to:
  /// **'إضاءة محيطية'**
  String get attr_8c495f8e;

  /// No description provided for @attr_367395e4.
  ///
  /// In ar, this message translates to:
  /// **'إعداد IELTS'**
  String get attr_367395e4;

  /// No description provided for @attr_9f6457d2.
  ///
  /// In ar, this message translates to:
  /// **'إعداد TOEFL'**
  String get attr_9f6457d2;

  /// No description provided for @attr_00f135f8.
  ///
  /// In ar, this message translates to:
  /// **'إعدادي'**
  String get attr_00f135f8;

  /// No description provided for @genderFemales.
  ///
  /// In ar, this message translates to:
  /// **'إناث'**
  String get genderFemales;

  /// No description provided for @attr_0402b2d3.
  ///
  /// In ar, this message translates to:
  /// **'إنجليزي'**
  String get attr_0402b2d3;

  /// No description provided for @offerRent.
  ///
  /// In ar, this message translates to:
  /// **'إيجار'**
  String get offerRent;

  /// No description provided for @offerDailyRent.
  ///
  /// In ar, this message translates to:
  /// **'إيجار يومي'**
  String get offerDailyRent;

  /// No description provided for @attr_5c22c7bc.
  ///
  /// In ar, this message translates to:
  /// **'ابتدائي'**
  String get attr_5c22c7bc;

  /// No description provided for @attr_a910430c.
  ///
  /// In ar, this message translates to:
  /// **'الأحياء'**
  String get attr_a910430c;

  /// No description provided for @attr_b1a8fcf3.
  ///
  /// In ar, this message translates to:
  /// **'الأعمال والإدارة والمال'**
  String get attr_b1a8fcf3;

  /// No description provided for @attr_127a0207.
  ///
  /// In ar, this message translates to:
  /// **'الأمان'**
  String get attr_127a0207;

  /// No description provided for @attr_e8ade886.
  ///
  /// In ar, this message translates to:
  /// **'الأمن والحراسة'**
  String get attr_e8ade886;

  /// No description provided for @attr_782faf71.
  ///
  /// In ar, this message translates to:
  /// **'الاقتصاد'**
  String get attr_782faf71;

  /// No description provided for @attr_6466c2b3.
  ///
  /// In ar, this message translates to:
  /// **'البرمجة'**
  String get attr_6466c2b3;

  /// No description provided for @attr_7b2d355f.
  ///
  /// In ar, this message translates to:
  /// **'البصرة'**
  String get attr_7b2d355f;

  /// No description provided for @attr_3659f4ca.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ والجغرافية'**
  String get attr_3659f4ca;

  /// No description provided for @attr_3dbbe072.
  ///
  /// In ar, this message translates to:
  /// **'التجويد'**
  String get attr_3dbbe072;

  /// No description provided for @attr_5fa7f4ab.
  ///
  /// In ar, this message translates to:
  /// **'التربية الإسلامية'**
  String get attr_5fa7f4ab;

  /// No description provided for @attr_68b31032.
  ///
  /// In ar, this message translates to:
  /// **'التصميم'**
  String get attr_68b31032;

  /// No description provided for @attr_595073bb.
  ///
  /// In ar, this message translates to:
  /// **'التعرف على إشارات المرور'**
  String get attr_595073bb;

  /// No description provided for @attr_a8071737.
  ///
  /// In ar, this message translates to:
  /// **'التعليم والتدريب'**
  String get attr_a8071737;

  /// No description provided for @attr_2f29a34b.
  ///
  /// In ar, this message translates to:
  /// **'الحاسوب والتقنية'**
  String get attr_2f29a34b;

  /// No description provided for @attr_b5bf961a.
  ///
  /// In ar, this message translates to:
  /// **'الحلة'**
  String get attr_b5bf961a;

  /// No description provided for @attr_6f5c12c4.
  ///
  /// In ar, this message translates to:
  /// **'الخارج'**
  String get attr_6f5c12c4;

  /// No description provided for @attr_479c9dd4.
  ///
  /// In ar, this message translates to:
  /// **'الديوانية'**
  String get attr_479c9dd4;

  /// No description provided for @attr_d10c7f46.
  ///
  /// In ar, this message translates to:
  /// **'الراحة'**
  String get attr_d10c7f46;

  /// No description provided for @attr_a8590e6c.
  ///
  /// In ar, this message translates to:
  /// **'الرمادي'**
  String get attr_a8590e6c;

  /// No description provided for @attr_ec996beb.
  ///
  /// In ar, this message translates to:
  /// **'الرياضيات'**
  String get attr_ec996beb;

  /// No description provided for @attr_2ad56620.
  ///
  /// In ar, this message translates to:
  /// **'الزراعة'**
  String get attr_2ad56620;

  /// No description provided for @attr_b23b84b6.
  ///
  /// In ar, this message translates to:
  /// **'السليمانية'**
  String get attr_b23b84b6;

  /// No description provided for @attr_47499b9d.
  ///
  /// In ar, this message translates to:
  /// **'الصيدلة'**
  String get attr_47499b9d;

  /// No description provided for @attr_df03b4c2.
  ///
  /// In ar, this message translates to:
  /// **'الضيافة والمطاعم'**
  String get attr_df03b4c2;

  /// No description provided for @attr_dbdc9141.
  ///
  /// In ar, this message translates to:
  /// **'الطب'**
  String get attr_dbdc9141;

  /// No description provided for @attr_2f1f707b.
  ///
  /// In ar, this message translates to:
  /// **'الطب والصحة'**
  String get attr_2f1f707b;

  /// No description provided for @attr_a23d2f98.
  ///
  /// In ar, this message translates to:
  /// **'العلوم العامة'**
  String get attr_a23d2f98;

  /// No description provided for @attr_fc2fc74a.
  ///
  /// In ar, this message translates to:
  /// **'العمارة'**
  String get attr_fc2fc74a;

  /// No description provided for @attr_308b4c85.
  ///
  /// In ar, this message translates to:
  /// **'الفقه'**
  String get attr_308b4c85;

  /// No description provided for @attr_057cd7d5.
  ///
  /// In ar, this message translates to:
  /// **'الفيزياء'**
  String get attr_057cd7d5;

  /// No description provided for @attr_4cfcf3c2.
  ///
  /// In ar, this message translates to:
  /// **'القانون'**
  String get attr_4cfcf3c2;

  /// No description provided for @attr_1429981f.
  ///
  /// In ar, this message translates to:
  /// **'القرآن الكريم'**
  String get attr_1429981f;

  /// No description provided for @attr_c8f1808b.
  ///
  /// In ar, this message translates to:
  /// **'الكوت'**
  String get attr_c8f1808b;

  /// No description provided for @attr_569ec1ad.
  ///
  /// In ar, this message translates to:
  /// **'الكيمياء'**
  String get attr_569ec1ad;

  /// No description provided for @attr_4469156a.
  ///
  /// In ar, this message translates to:
  /// **'اللغة الألمانية'**
  String get attr_4469156a;

  /// No description provided for @attr_8bcb4c90.
  ///
  /// In ar, this message translates to:
  /// **'اللغة الإنجليزية'**
  String get attr_8bcb4c90;

  /// No description provided for @attr_51a02272.
  ///
  /// In ar, this message translates to:
  /// **'اللغة التركية'**
  String get attr_51a02272;

  /// No description provided for @attr_b99f79d6.
  ///
  /// In ar, this message translates to:
  /// **'اللغة العربية'**
  String get attr_b99f79d6;

  /// No description provided for @attr_37ae3826.
  ///
  /// In ar, this message translates to:
  /// **'اللغة الفرنسية'**
  String get attr_37ae3826;

  /// No description provided for @attr_568f6457.
  ///
  /// In ar, this message translates to:
  /// **'اللغة الكردية'**
  String get attr_568f6457;

  /// No description provided for @attr_00ea8179.
  ///
  /// In ar, this message translates to:
  /// **'المبيعات والتسويق'**
  String get attr_00ea8179;

  /// No description provided for @attr_3f2ef321.
  ///
  /// In ar, this message translates to:
  /// **'المحاسبة'**
  String get attr_3f2ef321;

  /// No description provided for @attr_f3a2d580.
  ///
  /// In ar, this message translates to:
  /// **'المحاسبة المالية'**
  String get attr_f3a2d580;

  /// No description provided for @attr_b4a66258.
  ///
  /// In ar, this message translates to:
  /// **'المنهج العراقي'**
  String get attr_b4a66258;

  /// No description provided for @attr_878d6350.
  ///
  /// In ar, this message translates to:
  /// **'الموصل'**
  String get attr_878d6350;

  /// No description provided for @attr_8f465ea8.
  ///
  /// In ar, this message translates to:
  /// **'الناصرية'**
  String get attr_8f465ea8;

  /// No description provided for @attr_1c675f3a.
  ///
  /// In ar, this message translates to:
  /// **'النجف'**
  String get attr_1c675f3a;

  /// No description provided for @attr_1ace1501.
  ///
  /// In ar, this message translates to:
  /// **'النفط والطاقة'**
  String get attr_1ace1501;

  /// No description provided for @attr_d83c25fb.
  ///
  /// In ar, this message translates to:
  /// **'النقل واللوجستيات'**
  String get attr_d83c25fb;

  /// No description provided for @attr_45fbf259.
  ///
  /// In ar, this message translates to:
  /// **'الهندسة والبناء'**
  String get attr_45fbf259;

  /// No description provided for @attr_4bfb21c0.
  ///
  /// In ar, this message translates to:
  /// **'بالغين'**
  String get attr_4bfb21c0;

  /// No description provided for @attr_b7e8e36b.
  ///
  /// In ar, this message translates to:
  /// **'بدون خبرة'**
  String get attr_b7e8e36b;

  /// No description provided for @warrantyNo.
  ///
  /// In ar, this message translates to:
  /// **'بدون ضمان'**
  String get warrantyNo;

  /// No description provided for @attr_1fbfc2a7.
  ///
  /// In ar, this message translates to:
  /// **'بدون لوحة'**
  String get attr_1fbfc2a7;

  /// No description provided for @colorOrange.
  ///
  /// In ar, this message translates to:
  /// **'برتقالي'**
  String get colorOrange;

  /// No description provided for @attr_f8104802.
  ///
  /// In ar, this message translates to:
  /// **'بريطاني'**
  String get attr_f8104802;

  /// No description provided for @attr_40153b66.
  ///
  /// In ar, this message translates to:
  /// **'بغداد'**
  String get attr_40153b66;

  /// No description provided for @attr_13ac665b.
  ///
  /// In ar, this message translates to:
  /// **'بكالوريوس'**
  String get attr_13ac665b;

  /// No description provided for @attr_7acac848.
  ///
  /// In ar, this message translates to:
  /// **'بلكون'**
  String get attr_7acac848;

  /// No description provided for @fuelPetrol.
  ///
  /// In ar, this message translates to:
  /// **'بنزين'**
  String get fuelPetrol;

  /// No description provided for @colorPurple.
  ///
  /// In ar, this message translates to:
  /// **'بنفسجي'**
  String get colorPurple;

  /// No description provided for @colorBrown.
  ///
  /// In ar, this message translates to:
  /// **'بني'**
  String get colorBrown;

  /// No description provided for @colorBeige.
  ///
  /// In ar, this message translates to:
  /// **'بيج'**
  String get colorBeige;

  /// No description provided for @offerSale.
  ///
  /// In ar, this message translates to:
  /// **'بيع'**
  String get offerSale;

  /// No description provided for @attr_d1c3aa46.
  ///
  /// In ar, this message translates to:
  /// **'تأمين صحي'**
  String get attr_d1c3aa46;

  /// No description provided for @attr_8fe0629c.
  ///
  /// In ar, this message translates to:
  /// **'تثبيت تلقائي'**
  String get attr_8fe0629c;

  /// No description provided for @attr_6ef15709.
  ///
  /// In ar, this message translates to:
  /// **'تحكم تلقائي بالحرارة'**
  String get attr_6ef15709;

  /// No description provided for @attr_36db3f98.
  ///
  /// In ar, this message translates to:
  /// **'تحكم في الجر'**
  String get attr_36db3f98;

  /// No description provided for @attr_674fb279.
  ///
  /// In ar, this message translates to:
  /// **'تدريب'**
  String get attr_674fb279;

  /// No description provided for @attr_f730823c.
  ///
  /// In ar, this message translates to:
  /// **'تدفئة المقاعد'**
  String get attr_f730823c;

  /// No description provided for @attr_2751dcce.
  ///
  /// In ar, this message translates to:
  /// **'تركي'**
  String get attr_2751dcce;

  /// No description provided for @attr_5e98ac49.
  ///
  /// In ar, this message translates to:
  /// **'تشغيل عن بعد'**
  String get attr_5e98ac49;

  /// No description provided for @attr_0e8965c7.
  ///
  /// In ar, this message translates to:
  /// **'تقنية المعلومات والبرمجة'**
  String get attr_0e8965c7;

  /// No description provided for @attr_39990cf8.
  ///
  /// In ar, this message translates to:
  /// **'تكريت'**
  String get attr_39990cf8;

  /// No description provided for @attr_b3d78ccb.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه انتباه السائق'**
  String get attr_b3d78ccb;

  /// No description provided for @attr_ece0d086.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه حركة المرور الخلفية'**
  String get attr_ece0d086;

  /// No description provided for @attr_30ad1cb0.
  ///
  /// In ar, this message translates to:
  /// **'تنظيف'**
  String get attr_30ad1cb0;

  /// No description provided for @attr_61ff3500.
  ///
  /// In ar, this message translates to:
  /// **'توجيه كهربائي'**
  String get attr_61ff3500;

  /// No description provided for @colorTitanium.
  ///
  /// In ar, this message translates to:
  /// **'تيتانيوم'**
  String get colorTitanium;

  /// No description provided for @attr_5dfc333a.
  ///
  /// In ar, this message translates to:
  /// **'ثانوية'**
  String get attr_5dfc333a;

  /// No description provided for @colorTricolor.
  ///
  /// In ar, this message translates to:
  /// **'ثلاثي الألوان'**
  String get colorTricolor;

  /// No description provided for @attr_2b649c53.
  ///
  /// In ar, this message translates to:
  /// **'جامعي'**
  String get attr_2b649c53;

  /// No description provided for @attr_3f0a5345.
  ///
  /// In ar, this message translates to:
  /// **'جلد'**
  String get attr_3f0a5345;

  /// No description provided for @attr_596cc57e.
  ///
  /// In ar, this message translates to:
  /// **'جنريتر'**
  String get attr_596cc57e;

  /// No description provided for @conditionGood.
  ///
  /// In ar, this message translates to:
  /// **'جيد'**
  String get conditionGood;

  /// No description provided for @attr_e7873977.
  ///
  /// In ar, this message translates to:
  /// **'حدائق'**
  String get attr_e7873977;

  /// No description provided for @attr_6c532953.
  ///
  /// In ar, this message translates to:
  /// **'حديقة'**
  String get attr_6c532953;

  /// No description provided for @attr_57bf3353.
  ///
  /// In ar, this message translates to:
  /// **'حراسة'**
  String get attr_57bf3353;

  /// No description provided for @attr_9e07c1b5.
  ///
  /// In ar, this message translates to:
  /// **'حوادث'**
  String get attr_9e07c1b5;

  /// No description provided for @attr_e4439193.
  ///
  /// In ar, this message translates to:
  /// **'خزان ماء'**
  String get attr_e4439193;

  /// No description provided for @attr_c6c026c9.
  ///
  /// In ar, this message translates to:
  /// **'خليجي'**
  String get attr_c6c026c9;

  /// No description provided for @attr_b3371774.
  ///
  /// In ar, this message translates to:
  /// **'خيل'**
  String get attr_b3371774;

  /// No description provided for @attr_bf2575b9.
  ///
  /// In ar, this message translates to:
  /// **'دبلوم'**
  String get attr_bf2575b9;

  /// No description provided for @attr_f7fc7de3.
  ///
  /// In ar, this message translates to:
  /// **'دخول بدون مفتاح'**
  String get attr_f7fc7de3;

  /// No description provided for @attr_eebeffb8.
  ///
  /// In ar, this message translates to:
  /// **'دفة مدفأة'**
  String get attr_eebeffb8;

  /// No description provided for @attr_bc432f3e.
  ///
  /// In ar, this message translates to:
  /// **'دكتوراه'**
  String get attr_bc432f3e;

  /// No description provided for @attr_c114e728.
  ///
  /// In ar, this message translates to:
  /// **'دهوك'**
  String get attr_c114e728;

  /// No description provided for @attr_166ce8c7.
  ///
  /// In ar, this message translates to:
  /// **'دوام جزئي'**
  String get attr_166ce8c7;

  /// No description provided for @attr_03e6fabe.
  ///
  /// In ar, this message translates to:
  /// **'دوام كامل'**
  String get attr_03e6fabe;

  /// No description provided for @fuelDiesel.
  ///
  /// In ar, this message translates to:
  /// **'ديزل'**
  String get fuelDiesel;

  /// No description provided for @genderMale.
  ///
  /// In ar, this message translates to:
  /// **'ذكر'**
  String get genderMale;

  /// No description provided for @genderMales.
  ///
  /// In ar, this message translates to:
  /// **'ذكور'**
  String get genderMales;

  /// No description provided for @colorGold.
  ///
  /// In ar, this message translates to:
  /// **'ذهبي'**
  String get colorGold;

  /// No description provided for @attr_ed91d68c.
  ///
  /// In ar, this message translates to:
  /// **'راتب + عمولة'**
  String get attr_ed91d68c;

  /// No description provided for @attr_4bd160a2.
  ///
  /// In ar, this message translates to:
  /// **'راتب ثابت'**
  String get attr_4bd160a2;

  /// No description provided for @attr_d9033ee1.
  ///
  /// In ar, this message translates to:
  /// **'رادار'**
  String get attr_d9033ee1;

  /// No description provided for @attr_d021c755.
  ///
  /// In ar, this message translates to:
  /// **'رعاية أطفال'**
  String get attr_d021c755;

  /// No description provided for @attr_f730c844.
  ///
  /// In ar, this message translates to:
  /// **'رعاية مسنين'**
  String get attr_f730c844;

  /// No description provided for @attr_20484d19.
  ///
  /// In ar, this message translates to:
  /// **'ركن عن بعد'**
  String get attr_20484d19;

  /// No description provided for @colorGray.
  ///
  /// In ar, this message translates to:
  /// **'رمادي'**
  String get colorGray;

  /// No description provided for @attr_9863b154.
  ///
  /// In ar, this message translates to:
  /// **'زر تشغيل'**
  String get attr_9863b154;

  /// No description provided for @attr_91d7a73d.
  ///
  /// In ar, this message translates to:
  /// **'زواحف'**
  String get attr_91d7a73d;

  /// No description provided for @attr_603ab93b.
  ///
  /// In ar, this message translates to:
  /// **'سائق'**
  String get attr_603ab93b;

  /// No description provided for @attr_fe80509e.
  ///
  /// In ar, this message translates to:
  /// **'سامراء'**
  String get attr_fe80509e;

  /// No description provided for @attr_ec4f948f.
  ///
  /// In ar, this message translates to:
  /// **'سكن'**
  String get attr_ec4f948f;

  /// No description provided for @attr_5ae5476a.
  ///
  /// In ar, this message translates to:
  /// **'سمك'**
  String get attr_5ae5476a;

  /// No description provided for @attr_48c1891a.
  ///
  /// In ar, this message translates to:
  /// **'شاحن لاسلكي'**
  String get attr_48c1891a;

  /// No description provided for @attr_5f5265a7.
  ///
  /// In ar, this message translates to:
  /// **'شاشة'**
  String get attr_5f5265a7;

  /// No description provided for @propApartment.
  ///
  /// In ar, this message translates to:
  /// **'شقة'**
  String get propApartment;

  /// No description provided for @attr_1fcda818.
  ///
  /// In ar, this message translates to:
  /// **'صباحي'**
  String get attr_1fcda818;

  /// No description provided for @attr_1980be67.
  ///
  /// In ar, this message translates to:
  /// **'صيانة منزلية'**
  String get attr_1980be67;

  /// No description provided for @attr_a78786af.
  ///
  /// In ar, this message translates to:
  /// **'صيني'**
  String get attr_a78786af;

  /// No description provided for @attr_adfa037c.
  ///
  /// In ar, this message translates to:
  /// **'ضباب أمامي'**
  String get attr_adfa037c;

  /// No description provided for @warrantyYes.
  ///
  /// In ar, this message translates to:
  /// **'ضمان'**
  String get warrantyYes;

  /// No description provided for @attr_e579ab86.
  ///
  /// In ar, this message translates to:
  /// **'طائر'**
  String get attr_e579ab86;

  /// No description provided for @attr_71c665ee.
  ///
  /// In ar, this message translates to:
  /// **'طابو'**
  String get attr_71c665ee;

  /// No description provided for @attr_7a206f76.
  ///
  /// In ar, this message translates to:
  /// **'طبخ'**
  String get attr_7a206f76;

  /// No description provided for @attr_e5dbc387.
  ///
  /// In ar, this message translates to:
  /// **'عراقي'**
  String get attr_e5dbc387;

  /// No description provided for @attr_da88eccb.
  ///
  /// In ar, this message translates to:
  /// **'عربي'**
  String get attr_da88eccb;

  /// No description provided for @attr_aa4460d5.
  ///
  /// In ar, this message translates to:
  /// **'عرض رأسي HUD'**
  String get attr_aa4460d5;

  /// No description provided for @attr_8127bee7.
  ///
  /// In ar, this message translates to:
  /// **'عقد'**
  String get attr_8127bee7;

  /// No description provided for @attr_571581cc.
  ///
  /// In ar, this message translates to:
  /// **'عقد بيع'**
  String get attr_571581cc;

  /// No description provided for @attr_155ac5cf.
  ///
  /// In ar, this message translates to:
  /// **'علوم الحاسوب'**
  String get attr_155ac5cf;

  /// No description provided for @attr_7173aff1.
  ///
  /// In ar, this message translates to:
  /// **'عمولة'**
  String get attr_7173aff1;

  /// No description provided for @attr_e3668c0d.
  ///
  /// In ar, this message translates to:
  /// **'عن بُعد'**
  String get attr_e3668c0d;

  /// No description provided for @fuelGas.
  ///
  /// In ar, this message translates to:
  /// **'غاز'**
  String get fuelGas;

  /// No description provided for @attr_a1a423e6.
  ///
  /// In ar, this message translates to:
  /// **'غسيل وكي'**
  String get attr_a1a423e6;

  /// No description provided for @furnishedNo.
  ///
  /// In ar, this message translates to:
  /// **'غير مفروش'**
  String get furnishedNo;

  /// No description provided for @attr_1a0bd9b9.
  ///
  /// In ar, this message translates to:
  /// **'فارسي'**
  String get attr_1a0bd9b9;

  /// No description provided for @attr_29519ce6.
  ///
  /// In ar, this message translates to:
  /// **'فتحة سقف'**
  String get attr_29519ce6;

  /// No description provided for @attr_aa282cda.
  ///
  /// In ar, this message translates to:
  /// **'فرنسي'**
  String get attr_aa282cda;

  /// No description provided for @colorSilver.
  ///
  /// In ar, this message translates to:
  /// **'فضي'**
  String get colorSilver;

  /// No description provided for @propHotel.
  ///
  /// In ar, this message translates to:
  /// **'فندق'**
  String get propHotel;

  /// No description provided for @attr_eda90053.
  ///
  /// In ar, this message translates to:
  /// **'في المنزل'**
  String get attr_eda90053;

  /// No description provided for @attr_d2157926.
  ///
  /// In ar, this message translates to:
  /// **'في مكتبي'**
  String get attr_d2157926;

  /// No description provided for @propVilla.
  ///
  /// In ar, this message translates to:
  /// **'فيلا'**
  String get propVilla;

  /// No description provided for @attr_a826a507.
  ///
  /// In ar, this message translates to:
  /// **'قطة'**
  String get attr_a826a507;

  /// No description provided for @attr_4b021528.
  ///
  /// In ar, this message translates to:
  /// **'قفل أطفال'**
  String get attr_4b021528;

  /// No description provided for @attr_60cbec0a.
  ///
  /// In ar, this message translates to:
  /// **'قفل مركزي'**
  String get attr_60cbec0a;

  /// No description provided for @attr_f283f661.
  ///
  /// In ar, this message translates to:
  /// **'قماش'**
  String get attr_f283f661;

  /// No description provided for @attr_df6d261d.
  ///
  /// In ar, this message translates to:
  /// **'كاميرا 360'**
  String get attr_df6d261d;

  /// No description provided for @attr_1f94f275.
  ///
  /// In ar, this message translates to:
  /// **'كاميرا خلفية'**
  String get attr_1f94f275;

  /// No description provided for @attr_ea2d0f4a.
  ///
  /// In ar, this message translates to:
  /// **'كاميرات'**
  String get attr_ea2d0f4a;

  /// No description provided for @attr_8d564a08.
  ///
  /// In ar, this message translates to:
  /// **'كربلاء'**
  String get attr_8d564a08;

  /// No description provided for @attr_aa03d946.
  ///
  /// In ar, this message translates to:
  /// **'كردي'**
  String get attr_aa03d946;

  /// No description provided for @attr_4e1a505f.
  ///
  /// In ar, this message translates to:
  /// **'كركوك'**
  String get attr_4e1a505f;

  /// No description provided for @genderBoth.
  ///
  /// In ar, this message translates to:
  /// **'كلاهما'**
  String get genderBoth;

  /// No description provided for @attr_f6ec7e07.
  ///
  /// In ar, this message translates to:
  /// **'كلب'**
  String get attr_f6ec7e07;

  /// No description provided for @fuelElectric.
  ///
  /// In ar, this message translates to:
  /// **'كهربائي'**
  String get fuelElectric;

  /// No description provided for @attr_38ad1ced.
  ///
  /// In ar, this message translates to:
  /// **'كوري'**
  String get attr_38ad1ced;

  /// No description provided for @attr_10da4bc1.
  ///
  /// In ar, this message translates to:
  /// **'كوكبيت رقمي'**
  String get attr_10da4bc1;

  /// No description provided for @attr_3a1306fc.
  ///
  /// In ar, this message translates to:
  /// **'مؤقت'**
  String get attr_3a1306fc;

  /// No description provided for @attr_0cfe7e2c.
  ///
  /// In ar, this message translates to:
  /// **'مؤقتة'**
  String get attr_0cfe7e2c;

  /// No description provided for @attr_9e37b135.
  ///
  /// In ar, this message translates to:
  /// **'ماجستير'**
  String get attr_9e37b135;

  /// No description provided for @attr_14184253.
  ///
  /// In ar, this message translates to:
  /// **'متوسط'**
  String get attr_14184253;

  /// No description provided for @attr_5443be84.
  ///
  /// In ar, this message translates to:
  /// **'مثبت سرعة تكيفي'**
  String get attr_5443be84;

  /// No description provided for @deliveryFree.
  ///
  /// In ar, this message translates to:
  /// **'مجاني'**
  String get deliveryFree;

  /// No description provided for @propCommercial.
  ///
  /// In ar, this message translates to:
  /// **'محل تجاري'**
  String get propCommercial;

  /// No description provided for @genderMixed.
  ///
  /// In ar, this message translates to:
  /// **'مختلط'**
  String get genderMixed;

  /// No description provided for @deliveryPaid.
  ///
  /// In ar, this message translates to:
  /// **'مدفوع'**
  String get deliveryPaid;

  /// No description provided for @attr_463b559b.
  ///
  /// In ar, this message translates to:
  /// **'مراقب النقطة العمياء'**
  String get attr_463b559b;

  /// No description provided for @attr_3e6b7c47.
  ///
  /// In ar, this message translates to:
  /// **'مرايا جانبية مدفأة'**
  String get attr_3e6b7c47;

  /// No description provided for @attr_5e7c67c4.
  ///
  /// In ar, this message translates to:
  /// **'مرايا كهربائية'**
  String get attr_5e7c67c4;

  /// No description provided for @colorSpotted.
  ///
  /// In ar, this message translates to:
  /// **'مرقط'**
  String get colorSpotted;

  /// No description provided for @propFarm.
  ///
  /// In ar, this message translates to:
  /// **'مزرعة'**
  String get propFarm;

  /// No description provided for @attr_726ee881.
  ///
  /// In ar, this message translates to:
  /// **'مزيج'**
  String get attr_726ee881;

  /// No description provided for @attr_abbb3685.
  ///
  /// In ar, this message translates to:
  /// **'مسائي'**
  String get attr_abbb3685;

  /// No description provided for @attr_b1f57e19.
  ///
  /// In ar, this message translates to:
  /// **'مساعد الازدحام'**
  String get attr_b1f57e19;

  /// No description provided for @attr_1c5815dd.
  ///
  /// In ar, this message translates to:
  /// **'مساعد الفرملة الطارئة'**
  String get attr_1c5815dd;

  /// No description provided for @attr_1d2d9327.
  ///
  /// In ar, this message translates to:
  /// **'مسبح'**
  String get attr_1d2d9327;

  /// No description provided for @attr_908b36c3.
  ///
  /// In ar, this message translates to:
  /// **'مستشعرات ضغط الإطارات'**
  String get attr_908b36c3;

  /// No description provided for @propWarehouse.
  ///
  /// In ar, this message translates to:
  /// **'مستودع'**
  String get propWarehouse;

  /// No description provided for @attr_f4bcb528.
  ///
  /// In ar, this message translates to:
  /// **'مسند ذراع'**
  String get attr_f4bcb528;

  /// No description provided for @attr_50eeda55.
  ///
  /// In ar, this message translates to:
  /// **'مصبوغ جزئي'**
  String get attr_50eeda55;

  /// No description provided for @attr_d7f99058.
  ///
  /// In ar, this message translates to:
  /// **'مصبوغ كلي'**
  String get attr_d7f99058;

  /// No description provided for @attr_c29ac455.
  ///
  /// In ar, this message translates to:
  /// **'مصعد'**
  String get attr_c29ac455;

  /// No description provided for @furnishedYes.
  ///
  /// In ar, this message translates to:
  /// **'مفروش'**
  String get furnishedYes;

  /// No description provided for @attr_bc8dd527.
  ///
  /// In ar, this message translates to:
  /// **'مقاعد مساج'**
  String get attr_bc8dd527;

  /// No description provided for @conditionFair.
  ///
  /// In ar, this message translates to:
  /// **'مقبول'**
  String get conditionFair;

  /// No description provided for @attr_4827979f.
  ///
  /// In ar, this message translates to:
  /// **'مقيم'**
  String get attr_4827979f;

  /// No description provided for @attr_4a9d2ecf.
  ///
  /// In ar, this message translates to:
  /// **'مكافآت'**
  String get attr_4a9d2ecf;

  /// No description provided for @propOffice.
  ///
  /// In ar, this message translates to:
  /// **'مكتب'**
  String get propOffice;

  /// No description provided for @conditionScreenBroken.
  ///
  /// In ar, this message translates to:
  /// **'مكسور الشاشة'**
  String get conditionScreenBroken;

  /// No description provided for @conditionExcellent.
  ///
  /// In ar, this message translates to:
  /// **'ممتاز'**
  String get conditionExcellent;

  /// No description provided for @attr_a274e886.
  ///
  /// In ar, this message translates to:
  /// **'مواد أخرى'**
  String get attr_a274e886;

  /// No description provided for @attr_8c812969.
  ///
  /// In ar, this message translates to:
  /// **'مواصلات'**
  String get attr_8c812969;

  /// No description provided for @attr_5830d091.
  ///
  /// In ar, this message translates to:
  /// **'موقف سيارة'**
  String get attr_5830d091;

  /// No description provided for @furnishedPartial.
  ///
  /// In ar, this message translates to:
  /// **'نصف مفروش'**
  String get furnishedPartial;

  /// No description provided for @attr_d80ed6a2.
  ///
  /// In ar, this message translates to:
  /// **'نظام ستارت ستوب'**
  String get attr_d80ed6a2;

  /// No description provided for @attr_3b085d0f.
  ///
  /// In ar, this message translates to:
  /// **'نظام صوتي Harman Kardon'**
  String get attr_3b085d0f;

  /// No description provided for @attr_f6cf560b.
  ///
  /// In ar, this message translates to:
  /// **'نظيف'**
  String get attr_f6cf560b;

  /// No description provided for @attr_301b8203.
  ///
  /// In ar, this message translates to:
  /// **'نقل أثاث'**
  String get attr_301b8203;

  /// No description provided for @attr_3edd4576.
  ///
  /// In ar, this message translates to:
  /// **'نوافذ كهربائية'**
  String get attr_3edd4576;

  /// No description provided for @fuelHybrid.
  ///
  /// In ar, this message translates to:
  /// **'هايبرد'**
  String get fuelHybrid;

  /// No description provided for @attr_f0f27452.
  ///
  /// In ar, this message translates to:
  /// **'هندسة البرمجيات'**
  String get attr_f0f27452;

  /// No description provided for @attr_d50cbb11.
  ///
  /// In ar, this message translates to:
  /// **'هيل هولدر'**
  String get attr_d50cbb11;

  /// No description provided for @attr_a5d7347c.
  ///
  /// In ar, this message translates to:
  /// **'وجبات'**
  String get attr_a5d7347c;

  /// No description provided for @colorPink.
  ///
  /// In ar, this message translates to:
  /// **'وردي'**
  String get colorPink;

  /// No description provided for @attr_da3d03ec.
  ///
  /// In ar, this message translates to:
  /// **'وضع القيادة'**
  String get attr_da3d03ec;

  /// No description provided for @attr_065a7470.
  ///
  /// In ar, this message translates to:
  /// **'وكالة'**
  String get attr_065a7470;

  /// No description provided for @attr_f5e2c57f.
  ///
  /// In ar, this message translates to:
  /// **'ياباني'**
  String get attr_f5e2c57f;

  /// No description provided for @transManual.
  ///
  /// In ar, this message translates to:
  /// **'يدوي'**
  String get transManual;

  /// No description provided for @attr_1111f817.
  ///
  /// In ar, this message translates to:
  /// **'يومي كامل'**
  String get attr_1111f817;

  /// No description provided for @yesLabel.
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get yesLabel;

  /// No description provided for @noLabel.
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get noLabel;

  /// No description provided for @transCvt.
  ///
  /// In ar, this message translates to:
  /// **'CVT'**
  String get transCvt;

  /// No description provided for @resultsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} نتيجة'**
  String resultsCount(int count);

  /// No description provided for @sortNewest.
  ///
  /// In ar, this message translates to:
  /// **'الأحدث'**
  String get sortNewest;

  /// No description provided for @sortCheapest.
  ///
  /// In ar, this message translates to:
  /// **'الأرخص'**
  String get sortCheapest;

  /// No description provided for @sortExpensive.
  ///
  /// In ar, this message translates to:
  /// **'الأغلى'**
  String get sortExpensive;

  /// No description provided for @sortMostViewed.
  ///
  /// In ar, this message translates to:
  /// **'الأكثر مشاهدة'**
  String get sortMostViewed;

  /// No description provided for @statusSold.
  ///
  /// In ar, this message translates to:
  /// **'مباع'**
  String get statusSold;

  /// No description provided for @statusDeleted.
  ///
  /// In ar, this message translates to:
  /// **'محذوف'**
  String get statusDeleted;

  /// No description provided for @statusRejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوض'**
  String get statusRejected;

  /// No description provided for @listingTypeSale.
  ///
  /// In ar, this message translates to:
  /// **'للبيع'**
  String get listingTypeSale;

  /// No description provided for @listingTypeRent.
  ///
  /// In ar, this message translates to:
  /// **'للإيجار'**
  String get listingTypeRent;

  /// No description provided for @contactPhoneAndMessages.
  ///
  /// In ar, this message translates to:
  /// **'هاتف ورسائل'**
  String get contactPhoneAndMessages;

  /// No description provided for @contactPhoneOnly.
  ///
  /// In ar, this message translates to:
  /// **'هاتف فقط'**
  String get contactPhoneOnly;

  /// No description provided for @contactMessagesOnly.
  ///
  /// In ar, this message translates to:
  /// **'رسائل فقط'**
  String get contactMessagesOnly;

  /// No description provided for @packageStandardFull.
  ///
  /// In ar, this message translates to:
  /// **'إعلان عادي'**
  String get packageStandardFull;

  /// No description provided for @packageProFull.
  ///
  /// In ar, this message translates to:
  /// **'إعلان برو'**
  String get packageProFull;

  /// No description provided for @packagePremiumFull.
  ///
  /// In ar, this message translates to:
  /// **'إعلان مميز'**
  String get packagePremiumFull;

  /// No description provided for @chooseCategoryTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر الفئة'**
  String get chooseCategoryTitle;

  /// No description provided for @categoriesLoadError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل الفئات'**
  String get categoriesLoadError;

  /// No description provided for @tryDifferentSearchOrFilters.
  ///
  /// In ar, this message translates to:
  /// **'حاول تغيير كلمة البحث أو الفلاتر'**
  String get tryDifferentSearchOrFilters;

  /// No description provided for @listingFallbackTitle.
  ///
  /// In ar, this message translates to:
  /// **'إعلان'**
  String get listingFallbackTitle;

  /// No description provided for @validationPhoneRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم الهاتف'**
  String get validationPhoneRequired;

  /// No description provided for @validationPhoneInvalid.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف غير صالح'**
  String get validationPhoneInvalid;

  /// No description provided for @validationPhoneInvalidIq.
  ///
  /// In ar, this message translates to:
  /// **'رقم هاتف عراقي غير صالح'**
  String get validationPhoneInvalidIq;

  /// No description provided for @validationOtpRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز التحقق المكون من 6 أرقام'**
  String get validationOtpRequired;

  /// No description provided for @validationFieldRequired.
  ///
  /// In ar, this message translates to:
  /// **'{field} مطلوب'**
  String validationFieldRequired(String field);

  /// No description provided for @validationPriceRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخل السعر'**
  String get validationPriceRequired;

  /// No description provided for @validationPriceInvalid.
  ///
  /// In ar, this message translates to:
  /// **'سعر غير صالح'**
  String get validationPriceInvalid;

  /// No description provided for @validationEmailRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخل البريد الإلكتروني'**
  String get validationEmailRequired;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In ar, this message translates to:
  /// **'بريد إلكتروني غير صالح'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordRequired.
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة المرور'**
  String get validationPasswordRequired;

  /// No description provided for @validationPasswordMinLength.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور يجب أن تكون {count} أحرف على الأقل'**
  String validationPasswordMinLength(int count);

  /// No description provided for @validationPasswordLetter.
  ///
  /// In ar, this message translates to:
  /// **'أضف حرفاً (a-z) إلى كلمة المرور'**
  String get validationPasswordLetter;

  /// No description provided for @validationPasswordLowercase.
  ///
  /// In ar, this message translates to:
  /// **'أضف حرفاً صغيراً (a-z) إلى كلمة المرور'**
  String get validationPasswordLowercase;

  /// No description provided for @validationPasswordUppercase.
  ///
  /// In ar, this message translates to:
  /// **'أضف حرفاً كبيراً (A-Z) إلى كلمة المرور'**
  String get validationPasswordUppercase;

  /// No description provided for @validationPasswordDigit.
  ///
  /// In ar, this message translates to:
  /// **'أضف رقماً (0-9) إلى كلمة المرور'**
  String get validationPasswordDigit;

  /// No description provided for @validationPasswordSymbol.
  ///
  /// In ar, this message translates to:
  /// **'أضف رمزاً خاصاً (!@#...) إلى كلمة المرور'**
  String get validationPasswordSymbol;

  /// No description provided for @validationConfirmPasswordRequired.
  ///
  /// In ar, this message translates to:
  /// **'أكّد كلمة المرور'**
  String get validationConfirmPasswordRequired;

  /// No description provided for @validationPasswordMismatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين'**
  String get validationPasswordMismatch;

  /// No description provided for @validationWeakPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور يجب أن تحتوي على 8 أحرف على الأقل، مع حرف ورقم'**
  String get validationWeakPassword;

  /// No description provided for @authNetworkError.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من الاتصال بالإنترنت'**
  String get authNetworkError;

  /// No description provided for @authRateLimitGeneric.
  ///
  /// In ar, this message translates to:
  /// **'طلبات كثيرة. انتظر دقيقة ثم حاول مرة أخرى.'**
  String get authRateLimitGeneric;

  /// No description provided for @authRateLimitSeconds.
  ///
  /// In ar, this message translates to:
  /// **'طلبات كثيرة. انتظر {seconds} ثانية ثم حاول مرة أخرى.'**
  String authRateLimitSeconds(String seconds);

  /// No description provided for @authInvalidCredentials.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني أو كلمة المرور غير صحيحة.'**
  String get authInvalidCredentials;

  /// No description provided for @authInvalidEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني غير صالح'**
  String get authInvalidEmail;

  /// No description provided for @authEmailExists.
  ///
  /// In ar, this message translates to:
  /// **'هذا البريد مسجل مسبقاً'**
  String get authEmailExists;

  /// No description provided for @authEmailNotConfirmed.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تأكيد بريدك الإلكتروني قبل تسجيل الدخول.'**
  String get authEmailNotConfirmed;

  /// No description provided for @authSignupDisabled.
  ///
  /// In ar, this message translates to:
  /// **'التسجيل غير متاح حالياً.'**
  String get authSignupDisabled;

  /// No description provided for @authSmsFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إرسال الرسالة. تحقق من إعدادات SMS في Supabase.'**
  String get authSmsFailed;

  /// No description provided for @authPhoneInvalidFormat.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف غير صالح. استخدم الصيغة +9647XXXXXXXX.'**
  String get authPhoneInvalidFormat;

  /// No description provided for @authGenericError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء المصادقة. حاول مرة أخرى.'**
  String get authGenericError;

  /// No description provided for @authOperationFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر إكمال العملية. حاول مرة أخرى.'**
  String get authOperationFailed;

  /// No description provided for @loginRequiredFirst.
  ///
  /// In ar, this message translates to:
  /// **'يجب تسجيل الدخول أولاً'**
  String get loginRequiredFirst;

  /// No description provided for @metaPropertyType.
  ///
  /// In ar, this message translates to:
  /// **'نوع العقار'**
  String get metaPropertyType;

  /// No description provided for @metaOfferType.
  ///
  /// In ar, this message translates to:
  /// **'نوع العرض'**
  String get metaOfferType;

  /// No description provided for @metaArea.
  ///
  /// In ar, this message translates to:
  /// **'المساحة'**
  String get metaArea;

  /// No description provided for @metaFloor.
  ///
  /// In ar, this message translates to:
  /// **'الطابق'**
  String get metaFloor;

  /// No description provided for @metaTotalFloors.
  ///
  /// In ar, this message translates to:
  /// **'عدد الطوابق'**
  String get metaTotalFloors;

  /// No description provided for @metaRooms.
  ///
  /// In ar, this message translates to:
  /// **'عدد الغرف'**
  String get metaRooms;

  /// No description provided for @metaBathrooms.
  ///
  /// In ar, this message translates to:
  /// **'عدد الحمامات'**
  String get metaBathrooms;

  /// No description provided for @metaBuildingAge.
  ///
  /// In ar, this message translates to:
  /// **'عمر البناء'**
  String get metaBuildingAge;

  /// No description provided for @metaFurnishing.
  ///
  /// In ar, this message translates to:
  /// **'التشطيب'**
  String get metaFurnishing;

  /// No description provided for @metaYear.
  ///
  /// In ar, this message translates to:
  /// **'السنة'**
  String get metaYear;

  /// No description provided for @metaTrim.
  ///
  /// In ar, this message translates to:
  /// **'الفئة'**
  String get metaTrim;

  /// No description provided for @metaEngine.
  ///
  /// In ar, this message translates to:
  /// **'محرك'**
  String get metaEngine;

  /// No description provided for @metaCylinders.
  ///
  /// In ar, this message translates to:
  /// **'أسطوانة'**
  String get metaCylinders;

  /// No description provided for @metaLanguages.
  ///
  /// In ar, this message translates to:
  /// **'اللغات'**
  String get metaLanguages;

  /// No description provided for @metaSalary.
  ///
  /// In ar, this message translates to:
  /// **'الراتب'**
  String get metaSalary;

  /// No description provided for @metaExperience.
  ///
  /// In ar, this message translates to:
  /// **'الخبرة'**
  String get metaExperience;

  /// No description provided for @metaGender.
  ///
  /// In ar, this message translates to:
  /// **'الجنس'**
  String get metaGender;

  /// No description provided for @metaAge.
  ///
  /// In ar, this message translates to:
  /// **'العمر'**
  String get metaAge;

  /// No description provided for @metaBreed.
  ///
  /// In ar, this message translates to:
  /// **'السلالة'**
  String get metaBreed;

  /// No description provided for @metaServiceType.
  ///
  /// In ar, this message translates to:
  /// **'نوع الخدمة'**
  String get metaServiceType;

  /// No description provided for @metaAvailability.
  ///
  /// In ar, this message translates to:
  /// **'التوفر'**
  String get metaAvailability;

  /// No description provided for @metaBrand.
  ///
  /// In ar, this message translates to:
  /// **'العلامة'**
  String get metaBrand;

  /// No description provided for @metaModel.
  ///
  /// In ar, this message translates to:
  /// **'الموديل'**
  String get metaModel;

  /// No description provided for @metaStorage.
  ///
  /// In ar, this message translates to:
  /// **'التخزين'**
  String get metaStorage;

  /// No description provided for @metaCondition.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get metaCondition;

  /// No description provided for @metaItemType.
  ///
  /// In ar, this message translates to:
  /// **'نوع السلعة'**
  String get metaItemType;

  /// No description provided for @metaSubject.
  ///
  /// In ar, this message translates to:
  /// **'المادة'**
  String get metaSubject;

  /// No description provided for @metaLevel.
  ///
  /// In ar, this message translates to:
  /// **'المستوى'**
  String get metaLevel;

  /// No description provided for @metaJobType.
  ///
  /// In ar, this message translates to:
  /// **'نوع الوظيفة'**
  String get metaJobType;

  /// No description provided for @metaWorkMode.
  ///
  /// In ar, this message translates to:
  /// **'نمط العمل'**
  String get metaWorkMode;

  /// No description provided for @metaEducation.
  ///
  /// In ar, this message translates to:
  /// **'التعليم'**
  String get metaEducation;

  /// No description provided for @metaDetailsSection.
  ///
  /// In ar, this message translates to:
  /// **'التفاصيل'**
  String get metaDetailsSection;

  /// No description provided for @bodyConditionTitle.
  ///
  /// In ar, this message translates to:
  /// **'حالة الهيكل والطلاء'**
  String get bodyConditionTitle;

  /// No description provided for @bodyPartSelected.
  ///
  /// In ar, this message translates to:
  /// **'تم الاختيار لـ {selected}/{total} قطعة'**
  String bodyPartSelected(int selected, int total);

  /// No description provided for @bodyPartOriginal.
  ///
  /// In ar, this message translates to:
  /// **'أصلي'**
  String get bodyPartOriginal;

  /// No description provided for @bodyPartLocalPaint.
  ///
  /// In ar, this message translates to:
  /// **'صبغ محلي'**
  String get bodyPartLocalPaint;

  /// No description provided for @bodyPartPainted.
  ///
  /// In ar, this message translates to:
  /// **'مصبوغه'**
  String get bodyPartPainted;

  /// No description provided for @bodyPartReplaced.
  ///
  /// In ar, this message translates to:
  /// **'مستبدلة'**
  String get bodyPartReplaced;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @allCarPartsOriginalFull.
  ///
  /// In ar, this message translates to:
  /// **'جميع أجزاء السيارة أصلية. لا توجد قطع مصبوغة أو مستبدلة.'**
  String get allCarPartsOriginalFull;

  /// No description provided for @carPaintPanelFrontBumper.
  ///
  /// In ar, this message translates to:
  /// **'الرقم الأمامي'**
  String get carPaintPanelFrontBumper;

  /// No description provided for @carPaintPanelHood.
  ///
  /// In ar, this message translates to:
  /// **'الغطاء الأمامي'**
  String get carPaintPanelHood;

  /// No description provided for @carPaintPanelFrontLeftFender.
  ///
  /// In ar, this message translates to:
  /// **'الجناح الأمامي أيسر'**
  String get carPaintPanelFrontLeftFender;

  /// No description provided for @carPaintPanelFrontRightFender.
  ///
  /// In ar, this message translates to:
  /// **'الجناح الأمامي أيمن'**
  String get carPaintPanelFrontRightFender;

  /// No description provided for @carPaintPanelFrontLeftDoor.
  ///
  /// In ar, this message translates to:
  /// **'الباب الأمامي أيسر'**
  String get carPaintPanelFrontLeftDoor;

  /// No description provided for @carPaintPanelFrontRightDoor.
  ///
  /// In ar, this message translates to:
  /// **'الباب الأمامي أيمن'**
  String get carPaintPanelFrontRightDoor;

  /// No description provided for @carPaintPanelRoof.
  ///
  /// In ar, this message translates to:
  /// **'السقف'**
  String get carPaintPanelRoof;

  /// No description provided for @carPaintPanelRearLeftDoor.
  ///
  /// In ar, this message translates to:
  /// **'الباب الخلفي أيسر'**
  String get carPaintPanelRearLeftDoor;

  /// No description provided for @carPaintPanelRearRightDoor.
  ///
  /// In ar, this message translates to:
  /// **'الباب الخلفي أيمن'**
  String get carPaintPanelRearRightDoor;

  /// No description provided for @carPaintPanelTrunk.
  ///
  /// In ar, this message translates to:
  /// **'غطاء الصندوق'**
  String get carPaintPanelTrunk;

  /// No description provided for @carPaintPanelRearLeftFender.
  ///
  /// In ar, this message translates to:
  /// **'الجناح الخلفي أيسر'**
  String get carPaintPanelRearLeftFender;

  /// No description provided for @carPaintPanelRearRightFender.
  ///
  /// In ar, this message translates to:
  /// **'الجناح الخلفي أيمن'**
  String get carPaintPanelRearRightFender;

  /// No description provided for @carPaintPanelRearBumper.
  ///
  /// In ar, this message translates to:
  /// **'الرقم الخلفي'**
  String get carPaintPanelRearBumper;

  /// No description provided for @locationPickerTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الموقع'**
  String get locationPickerTitle;

  /// No description provided for @locationCoordinates.
  ///
  /// In ar, this message translates to:
  /// **'الإحداثيات'**
  String get locationCoordinates;

  /// No description provided for @locationUseCurrentLocation.
  ///
  /// In ar, this message translates to:
  /// **'استخدام موقعي الحالي'**
  String get locationUseCurrentLocation;

  /// No description provided for @locationConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الموقع'**
  String get locationConfirm;

  /// No description provided for @locationMapUnavailableStatus.
  ///
  /// In ar, this message translates to:
  /// **'الخريطة غير متاحة حالياً. يمكنك تأكيد موقع بغداد الافتراضي أو إغلاق النافذة.'**
  String get locationMapUnavailableStatus;

  /// No description provided for @locationMapLoadFailedStatus.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل الخريطة. تم استخدام موقع بغداد الافتراضي.'**
  String get locationMapLoadFailedStatus;

  /// No description provided for @locationGpsFailedSnack.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحديد موقعك. تم استخدام موقع بغداد الافتراضي.'**
  String get locationGpsFailedSnack;

  /// No description provided for @locationFetchFailedSnack.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الحصول على الموقع'**
  String get locationFetchFailedSnack;

  /// No description provided for @locationMapUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'الخريطة غير متاحة'**
  String get locationMapUnavailable;

  /// No description provided for @locationLoadingMap.
  ///
  /// In ar, this message translates to:
  /// **'جاري تحميل الخريطة...'**
  String get locationLoadingMap;

  /// No description provided for @statYear.
  ///
  /// In ar, this message translates to:
  /// **'السنة'**
  String get statYear;

  /// No description provided for @statCategory.
  ///
  /// In ar, this message translates to:
  /// **'الفئة'**
  String get statCategory;

  /// No description provided for @statKm.
  ///
  /// In ar, this message translates to:
  /// **'كم'**
  String get statKm;

  /// No description provided for @statMile.
  ///
  /// In ar, this message translates to:
  /// **'ميل'**
  String get statMile;

  /// No description provided for @statEngine.
  ///
  /// In ar, this message translates to:
  /// **'محرك'**
  String get statEngine;

  /// No description provided for @statCylinders.
  ///
  /// In ar, this message translates to:
  /// **'أسطوانة'**
  String get statCylinders;

  /// No description provided for @sectionDetails.
  ///
  /// In ar, this message translates to:
  /// **'التفاصيل'**
  String get sectionDetails;

  /// No description provided for @sectionSpecs.
  ///
  /// In ar, this message translates to:
  /// **'المواصفات'**
  String get sectionSpecs;

  /// No description provided for @sectionBodyCondition.
  ///
  /// In ar, this message translates to:
  /// **'وضع الهيكل والطلاء'**
  String get sectionBodyCondition;

  /// No description provided for @listedOn.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ النشر'**
  String get listedOn;

  /// No description provided for @fieldCondition.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get fieldCondition;

  /// No description provided for @fieldPaintCondition.
  ///
  /// In ar, this message translates to:
  /// **'وضع الطلاء'**
  String get fieldPaintCondition;

  /// No description provided for @fieldFuel.
  ///
  /// In ar, this message translates to:
  /// **'الوقود'**
  String get fieldFuel;

  /// No description provided for @fieldImportCountry.
  ///
  /// In ar, this message translates to:
  /// **'بلد الاستيراد'**
  String get fieldImportCountry;

  /// No description provided for @fieldPlate.
  ///
  /// In ar, this message translates to:
  /// **'اللوحة'**
  String get fieldPlate;

  /// No description provided for @fieldTransmission.
  ///
  /// In ar, this message translates to:
  /// **'ناقل الحركة'**
  String get fieldTransmission;

  /// No description provided for @fieldSeats.
  ///
  /// In ar, this message translates to:
  /// **'عدد المقاعد'**
  String get fieldSeats;

  /// No description provided for @fieldSeatMaterial.
  ///
  /// In ar, this message translates to:
  /// **'مادة المقاعد'**
  String get fieldSeatMaterial;

  /// No description provided for @fieldColor.
  ///
  /// In ar, this message translates to:
  /// **'اللون'**
  String get fieldColor;

  /// No description provided for @metaDeliveryCost.
  ///
  /// In ar, this message translates to:
  /// **'تكلفة التوصيل'**
  String get metaDeliveryCost;

  /// No description provided for @metaPricePerHour.
  ///
  /// In ar, this message translates to:
  /// **'السعر/ساعة'**
  String get metaPricePerHour;

  /// No description provided for @metaSalaryMin.
  ///
  /// In ar, this message translates to:
  /// **'الراتب الأدنى'**
  String get metaSalaryMin;

  /// No description provided for @metaSalaryMax.
  ///
  /// In ar, this message translates to:
  /// **'الراتب الأعلى'**
  String get metaSalaryMax;

  /// No description provided for @metaSector.
  ///
  /// In ar, this message translates to:
  /// **'القطاع'**
  String get metaSector;

  /// No description provided for @metaExperienceRequired.
  ///
  /// In ar, this message translates to:
  /// **'الخبرة المطلوبة'**
  String get metaExperienceRequired;

  /// No description provided for @metaEducationRequired.
  ///
  /// In ar, this message translates to:
  /// **'المؤهل المطلوب'**
  String get metaEducationRequired;

  /// No description provided for @metaGenderPreference.
  ///
  /// In ar, this message translates to:
  /// **'تفضيل الجنس'**
  String get metaGenderPreference;

  /// No description provided for @metaTeachingMethod.
  ///
  /// In ar, this message translates to:
  /// **'طريقة التدريس'**
  String get metaTeachingMethod;

  /// No description provided for @metaQualifications.
  ///
  /// In ar, this message translates to:
  /// **'المؤهل العلمي'**
  String get metaQualifications;

  /// No description provided for @metaStudyStages.
  ///
  /// In ar, this message translates to:
  /// **'المراحل الدراسية'**
  String get metaStudyStages;

  /// No description provided for @metaAnimalType.
  ///
  /// In ar, this message translates to:
  /// **'نوع الحيوان'**
  String get metaAnimalType;

  /// No description provided for @metaHasPapers.
  ///
  /// In ar, this message translates to:
  /// **'يمتلك وثائق'**
  String get metaHasPapers;

  /// No description provided for @metaVaccinated.
  ///
  /// In ar, this message translates to:
  /// **'ملقح'**
  String get metaVaccinated;

  /// No description provided for @metaTrained.
  ///
  /// In ar, this message translates to:
  /// **'مدرب'**
  String get metaTrained;

  /// No description provided for @metaDaysPerWeek.
  ///
  /// In ar, this message translates to:
  /// **'أيام الأسبوع'**
  String get metaDaysPerWeek;

  /// No description provided for @metaExpectedSalary.
  ///
  /// In ar, this message translates to:
  /// **'الراتب المتوقع'**
  String get metaExpectedSalary;

  /// No description provided for @metaWorkHours.
  ///
  /// In ar, this message translates to:
  /// **'أوقات العمل'**
  String get metaWorkHours;

  /// No description provided for @metaAgeMonths.
  ///
  /// In ar, this message translates to:
  /// **'{count} شهر'**
  String metaAgeMonths(int count);

  /// No description provided for @metaRam.
  ///
  /// In ar, this message translates to:
  /// **'الرام'**
  String get metaRam;

  /// No description provided for @metaBatteryHealth.
  ///
  /// In ar, this message translates to:
  /// **'صحة البطارية'**
  String get metaBatteryHealth;

  /// No description provided for @metaWarranty.
  ///
  /// In ar, this message translates to:
  /// **'الضمان'**
  String get metaWarranty;

  /// No description provided for @metaProcessor.
  ///
  /// In ar, this message translates to:
  /// **'المعالج'**
  String get metaProcessor;

  /// No description provided for @metaScreenSize.
  ///
  /// In ar, this message translates to:
  /// **'حجم الشاشة'**
  String get metaScreenSize;

  /// No description provided for @metaResolution.
  ///
  /// In ar, this message translates to:
  /// **'الدقة'**
  String get metaResolution;

  /// No description provided for @metaWithBox.
  ///
  /// In ar, this message translates to:
  /// **'مع العلبة'**
  String get metaWithBox;

  /// No description provided for @metaWithCharger.
  ///
  /// In ar, this message translates to:
  /// **'مع الشاحن'**
  String get metaWithCharger;

  /// No description provided for @metaSmartTv.
  ///
  /// In ar, this message translates to:
  /// **'سمارت TV'**
  String get metaSmartTv;

  /// No description provided for @mainCategory.
  ///
  /// In ar, this message translates to:
  /// **'الفئة الرئيسية'**
  String get mainCategory;

  /// No description provided for @subCategory.
  ///
  /// In ar, this message translates to:
  /// **'الفئة الفرعية'**
  String get subCategory;

  /// No description provided for @categoryDetail.
  ///
  /// In ar, this message translates to:
  /// **'التفصيل'**
  String get categoryDetail;

  /// No description provided for @termsTitle.
  ///
  /// In ar, this message translates to:
  /// **'شروط الاستخدام'**
  String get termsTitle;

  /// No description provided for @termsSection1Title.
  ///
  /// In ar, this message translates to:
  /// **'مقدمة'**
  String get termsSection1Title;

  /// No description provided for @termsSection1Body.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بك في تطبيق سوقك. باستخدامك للتطبيق أو إنشاء حساب، فأنك توافق على الالتزام بهذه الشروط. يرجى قراءتها بعناية قبل المتابعة. إذا لم توافق على أي بند، يرجى عدم استخدام الخدمة.'**
  String get termsSection1Body;

  /// No description provided for @termsSection2Title.
  ///
  /// In ar, this message translates to:
  /// **'استخدام التطبيق'**
  String get termsSection2Title;

  /// No description provided for @termsSection2Body.
  ///
  /// In ar, this message translates to:
  /// **'يسمح لك باستخدام سوقك لعرض وشراء السلع والخدمات ضمن القوانين المعمول بها في جمهورية العراق. يُحظر نشر إعلانات مضللة أو مخالفة للقانون أو تحتوي على محتوى مسيء أو احتيالي. نحتفظ بالحق في إزالة أي محتوى يخالف هذه الشروط دون إشعار مسبق.'**
  String get termsSection2Body;

  /// No description provided for @termsSection3Title.
  ///
  /// In ar, this message translates to:
  /// **'حقوق المستخدم'**
  String get termsSection3Title;

  /// No description provided for @termsSection3Body.
  ///
  /// In ar, this message translates to:
  /// **'تحتفظ بملكية المحتوى الذي تنشره. وتمنح سوقك ترخيصاً غير حصري لعرضه داخل التطبيق لأغراض تشغيل الخدمة. لك الحق في تعديل ملفك الشخصي وإعلاناتك وحذف حسابك وفق الإجراءات المتاحة في التطبيق.'**
  String get termsSection3Body;

  /// No description provided for @termsSection4Title.
  ///
  /// In ar, this message translates to:
  /// **'المسؤوليات'**
  String get termsSection4Title;

  /// No description provided for @termsSection4Body.
  ///
  /// In ar, this message translates to:
  /// **'أنت مسؤول عن دقة معلومات حسابك وإعلاناتك وعن أي تفاعل مع مستخدمين آخرين. سوقك منصة وسيطة ولا تضمن صحة كل إعلان أو اكتمال الصفقات بين الأطراف. ننصح بالتحقق من المنتجات والبائعين قبل إتمام أي عملية شراء.'**
  String get termsSection4Body;

  /// No description provided for @termsSection5Title.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء الخدمة'**
  String get termsSection5Title;

  /// No description provided for @termsSection5Body.
  ///
  /// In ar, this message translates to:
  /// **'يجوز لنا تعليق أو إنهاء حسابك في حال مخالفة هذه الشروط أو الاشتباه في أي نشاط احتيالي. يمكنك أنت أيضاً حذف حسابك في أي وقت من إعدادات التطبيق.'**
  String get termsSection5Body;

  /// No description provided for @privacyTitle.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacyTitle;

  /// No description provided for @privacySection1Title.
  ///
  /// In ar, this message translates to:
  /// **'ما المعلومات التي نجمعها'**
  String get privacySection1Title;

  /// No description provided for @privacySection1Body.
  ///
  /// In ar, this message translates to:
  /// **'نجمع المعلومات التي تقدمها عند التسجيل مثل الاسم والبريد الإلكتروني ورقم الهاتف واسم المستخدم، بالإضافة إلى بيانات الإعلانات التي تنشرها ورسائلك داخل التطبيق. قد نجمع أيضاً بيانات تقنية مثل نوع الجهاز وعنوان IP لأغراض الأمان وتحسين الخدمة.'**
  String get privacySection1Body;

  /// No description provided for @privacySection2Title.
  ///
  /// In ar, this message translates to:
  /// **'كيف نستخدم بياناتك'**
  String get privacySection2Title;

  /// No description provided for @privacySection2Body.
  ///
  /// In ar, this message translates to:
  /// **'نستخدم بياناتك لتشغيل حسابك وعرض إعلاناتك وتمكين التواصل بين المستخدمين وإرسال الإشعارات المتعلقة بالتنبيهات الذكية والرسائل. كما نستخدم البيانات المجمّعة لتحسين تجربة الاستخدام ومنع الاحتيال وضمان أمان المنصة.'**
  String get privacySection2Body;

  /// No description provided for @privacySection3Title.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة البيانات'**
  String get privacySection3Title;

  /// No description provided for @privacySection3Body.
  ///
  /// In ar, this message translates to:
  /// **'لا نبيع بياناتك الشخصية لأطراف ثالثة. قد نشارك معلومات محدودة مع مزودي الخدمات الذين يساعدوننا في استضافة البيانات وإرسال الإشعارات، مع الالتزام بسرية هذه البيانات. قد نفصح عن معلومات عند طلب قانوني أو لحماية حقوق المستخدمين وسلامة المنصة.'**
  String get privacySection3Body;

  /// No description provided for @privacySection4Title.
  ///
  /// In ar, this message translates to:
  /// **'أمان البيانات'**
  String get privacySection4Title;

  /// No description provided for @privacySection4Body.
  ///
  /// In ar, this message translates to:
  /// **'نطبّق إجراءات تقنية وتنظيمية لحماية بياناتك من الوصول غير المصرح به أو الفقدان أو التعديل. رغم ذلك، لا يمكن ضمان أمان مطلق لأي نقل عبر الإنترنت، لذا ننصحك باستخدام كلمة مرور قوية وعدم مشاركة بيانات الدخول مع الآخرين.'**
  String get privacySection4Body;

  /// No description provided for @privacySection5Title.
  ///
  /// In ar, this message translates to:
  /// **'التواصل معنا'**
  String get privacySection5Title;

  /// No description provided for @privacySection5Body.
  ///
  /// In ar, this message translates to:
  /// **'إذا كانت لديك أسئلة حول سياسة الخصوصية أو ترغب في ممارسة حقوقك المتعلقة ببياناتك، يمكنك التواصل معنا عبر البريد الإلكتروني للدعم المذكور في إعدادات التطبيق. سنرد على طلباتك في أقرب وقت ممكن وفقاً للقوانين المعمول بها.'**
  String get privacySection5Body;

  /// No description provided for @packageDurationDays.
  ///
  /// In ar, this message translates to:
  /// **'{count} يوم'**
  String packageDurationDays(int count);

  /// No description provided for @pkgStandardFeature1Title.
  ///
  /// In ar, this message translates to:
  /// **'إعلان أساسي'**
  String get pkgStandardFeature1Title;

  /// No description provided for @pkgStandardFeature1Desc.
  ///
  /// In ar, this message translates to:
  /// **'ينشر ضمن نتائج البحث العادية'**
  String get pkgStandardFeature1Desc;

  /// No description provided for @pkgStandardFeature2Title.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مباشر'**
  String get pkgStandardFeature2Title;

  /// No description provided for @pkgStandardFeature2Desc.
  ///
  /// In ar, this message translates to:
  /// **'يتواصل معك المهتمون حسب تفضيلاتك'**
  String get pkgStandardFeature2Desc;

  /// No description provided for @pkgProFeature1Title.
  ///
  /// In ar, this message translates to:
  /// **'ظهور أعلى في نتائج البحث'**
  String get pkgProFeature1Title;

  /// No description provided for @pkgProFeature1Desc.
  ///
  /// In ar, this message translates to:
  /// **'يتصدّر إعلانك على العاديين في نفس الفئة'**
  String get pkgProFeature1Desc;

  /// No description provided for @pkgProFeature2Title.
  ///
  /// In ar, this message translates to:
  /// **'شارة \"برو\" الموثوقة'**
  String get pkgProFeature2Title;

  /// No description provided for @pkgProFeature2Desc.
  ///
  /// In ar, this message translates to:
  /// **'تمنح المشترين ثقة أكبر وتضاعف فرص البيع'**
  String get pkgProFeature2Desc;

  /// No description provided for @pkgProFeature3Title.
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات'**
  String get pkgProFeature3Title;

  /// No description provided for @pkgProFeature3Desc.
  ///
  /// In ar, this message translates to:
  /// **'مشاهدات وتواصل مع الإعلان'**
  String get pkgProFeature3Desc;

  /// No description provided for @pkgPremiumFeature1Title.
  ///
  /// In ar, this message translates to:
  /// **'الظهور الأول للجميع'**
  String get pkgPremiumFeature1Title;

  /// No description provided for @pkgPremiumFeature1Desc.
  ///
  /// In ar, this message translates to:
  /// **'يُعرض في الكاروسيل المميز بأعلى الصفحة الرئيسية'**
  String get pkgPremiumFeature1Desc;

  /// No description provided for @pkgPremiumFeature2Title.
  ///
  /// In ar, this message translates to:
  /// **'الترتيب الأعلى دائماً'**
  String get pkgPremiumFeature2Title;

  /// No description provided for @pkgPremiumFeature2Desc.
  ///
  /// In ar, this message translates to:
  /// **'يسبق حتى إعلانات برو في نتائج البحث والفئة'**
  String get pkgPremiumFeature2Desc;

  /// No description provided for @pkgPremiumFeature3Title.
  ///
  /// In ar, this message translates to:
  /// **'تعزيز دفع'**
  String get pkgPremiumFeature3Title;

  /// No description provided for @pkgPremiumFeature3Desc.
  ///
  /// In ar, this message translates to:
  /// **'ظهور مميز لزيادة المشاهدات'**
  String get pkgPremiumFeature3Desc;

  /// No description provided for @pkgProFeature4Title.
  ///
  /// In ar, this message translates to:
  /// **'تجديد تلقائي أسبوعي'**
  String get pkgProFeature4Title;

  /// No description provided for @pkgProFeature4Desc.
  ///
  /// In ar, this message translates to:
  /// **'يعود إعلانك لأعلى القائمة كل أسبوع دون أي مجهود'**
  String get pkgProFeature4Desc;

  /// No description provided for @pkgProFeature5Title.
  ///
  /// In ar, this message translates to:
  /// **'صور أكثر وواتساب فوري'**
  String get pkgProFeature5Title;

  /// No description provided for @pkgProFeature5Desc.
  ///
  /// In ar, this message translates to:
  /// **'أضف حتى 15 صورة، وزر تواصل واتساب مباشر على البطاقة'**
  String get pkgProFeature5Desc;

  /// No description provided for @pkgProFeature6Title.
  ///
  /// In ar, this message translates to:
  /// **'زر واتساب مباشر'**
  String get pkgProFeature6Title;

  /// No description provided for @pkgProFeature6Desc.
  ///
  /// In ar, this message translates to:
  /// **'تواصل فوري عبر واتساب من بطاقة الإعلان'**
  String get pkgProFeature6Desc;

  /// No description provided for @pkgProFeature7Title.
  ///
  /// In ar, this message translates to:
  /// **'إطار وشارة برو'**
  String get pkgProFeature7Title;

  /// No description provided for @pkgProFeature7Desc.
  ///
  /// In ar, this message translates to:
  /// **'إطار مميّز وشارة \"برو\" تبرز إعلانك في البحث'**
  String get pkgProFeature7Desc;

  /// No description provided for @pkgPremiumFeature4Title.
  ///
  /// In ar, this message translates to:
  /// **'تجديد تلقائي يومي'**
  String get pkgPremiumFeature4Title;

  /// No description provided for @pkgPremiumFeature4Desc.
  ///
  /// In ar, this message translates to:
  /// **'يبقى إعلانك في القمة كل يوم بدون أي تدخل منك'**
  String get pkgPremiumFeature4Desc;

  /// No description provided for @pkgPremiumFeature5Title.
  ///
  /// In ar, this message translates to:
  /// **'إشعار فوري لكل مهتم'**
  String get pkgPremiumFeature5Title;

  /// No description provided for @pkgPremiumFeature5Desc.
  ///
  /// In ar, this message translates to:
  /// **'يصل إشعار مباشر لكل من يبحث عن هذه الفئة'**
  String get pkgPremiumFeature5Desc;

  /// No description provided for @pkgPremiumFeature6Title.
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات متقدمة'**
  String get pkgPremiumFeature6Title;

  /// No description provided for @pkgPremiumFeature6Desc.
  ///
  /// In ar, this message translates to:
  /// **'تحليل شامل: مصادر المشاهدات وأوقات الذروة'**
  String get pkgPremiumFeature6Desc;

  /// No description provided for @currentPhotos.
  ///
  /// In ar, this message translates to:
  /// **'الصور الحالية'**
  String get currentPhotos;

  /// No description provided for @completePayment.
  ///
  /// In ar, this message translates to:
  /// **'إتمام الدفع'**
  String get completePayment;

  /// No description provided for @paymentSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم الدفع بنجاح ✓'**
  String get paymentSuccess;

  /// No description provided for @paymentFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل الدفع، يرجى المحاولة مرة أخرى'**
  String get paymentFailed;

  /// No description provided for @startPayment.
  ///
  /// In ar, this message translates to:
  /// **'بدء الدفع'**
  String get startPayment;
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
      <String>['ar', 'en', 'ku', 'tr'].contains(locale.languageCode);

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
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
