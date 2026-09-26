# تقرير جاهزية الإنتاج — Bella Box Flutter
**Command #17 — Production Readiness** | التاريخ: 2026-07-09 | Commit: `0afa3c8`

---

## ⚠️ إفصاح إلزامي أولاً: حدود التحقق

**التنفيذ الفعلي لأدوات Flutter غير ممكن في هذه البيئة.**

| الأمر | النتيجة الفعلية |
|-------|----------------|
| `which flutter` / `which dart` | **غير مثبّت** |
| تنزيل Flutter SDK | **محجوب شبكياً** — `storage.googleapis.com` يرد `403 x-deny-reason: host_not_allowed` (تم التحقق فعلياً بـ curl) |
| `flutter pub get` | ❌ **لم يُنفَّذ** |
| `flutter analyze` | ❌ **لم يُنفَّذ** — لا يوجد ناتج فعلي |
| `flutter build apk --debug` | ❌ **لم يُنفَّذ** — لا يمكن الادعاء بنجاح البناء |

**بالتالي: هذا التقرير لا يدّعي أن التطبيق Production Ready بدليل أدوات Flutter.** كل ما يلي هو **مراجعة ساكنة (Static Review)** نُفّذت آلياً بسكربتات Python مخصصة على الـ 81 ملف Dart، مع إصلاح كل ما كشفته.

---

## 1. الأرقام

| المقياس | القيمة | طريقة التحقق |
|---------|--------|---------------|
| ملفات Dart | **81** | `find` فعلي ✓ |
| الشاشات (`*_page.dart`) | **19** | عدّ فعلي ✓ |
| Providers (Riverpod) | **36** | استخراج regex فعلي ✓ |
| Routes (GoRoute) | **22** + 5 shell branches | عدّ فعلي ✓ |
| مفاتيح الترجمة | ar = en (تطابق تام) | مقارنة JSON فعلية ✓ |

---

## 2. ما تم التحقق منه **فعلياً** (بسكربتات آلية على الكود)

| الفحص | النتيجة |
|-------|---------|
| كل استيرادات `package:bellabox/*` تُحل لملفات موجودة | ✓ 0 مكسور |
| استيرادات غير مستخدمة (مع احتساب extension methods) | ✓ 0 |
| استيرادات حزم خارجية غير مستخدمة | ✓ 0 |
| توازن الأقواس `{} () []` بعد إزالة strings/comments (كشف syntax فادح) | ✓ 81/81 |
| كل مفتاح `tr()` مستخدم موجود في ar.json وen.json | ✓ 0 مفقود |
| مفاتيح ترجمة ميتة | ✓ 0 (بعد حذف 41) |
| كل `RouteNames.*` مستخدم مسجّل في الـ router | ✓ 0 غير مسجّل |
| Routes ميتة | ✓ 0 (بعد حذف 5 ثوابت) |
| Providers غير مستخدمة | ✓ 0 من 36 |
| Circular dependencies بين ملفات الـ providers | ✓ 0 دورات |
| APIs مهجورة معروفة (RaisedButton، accentColor، onPopInvoked، CarouselController v4...) | ✓ 0 |
| ملفات يتيمة | ✓ 0 (بعد حذف واحد) |
| pubspec: كل asset معلن موجود على القرص | ✓ |

## 3. ما هو **استنتاج من مراجعة الكود** (غير مثبت بالتشغيل)

- توافق توقيعات الـ APIs مع إصدارات الحزم المثبتة في pubspec (riverpod 2.5 `AutoDisposeFamilyNotifier`، go_router 14 `StatefulShellRoute.indexedStack`، carousel_slider 5، pinput 5، photo_view 0.15) — مراجعة يدوية مقابل توثيق الحزم، **بحاجة تأكيد `flutter analyze`**.
- سلامة الـ generics وnull-safety الدقيقة — regex لا يغني عن الـ analyzer.
- السلوك الفعلي على جهاز (RTL rendering، overflow، الدفع polling).

---

## 4. قائمة الإصلاحات المُنجزة (17 إصلاحاً)

### أخطاء Compile مؤكدة (كانت ستُفشل `flutter build`)
1. **`ThemeData.copyWith(brightness: ...)`** في light وdark — البارامتر غير موجود في `copyWith` بإصدارات Flutter الحديثة → حُذف (يُشتق من colorScheme).
2. **قيد SDK خاطئ**: الكود يستخدم `withValues(alpha:)` ×9 (يتطلب Dart 3.6/Flutter 3.27) بينما pubspec كان `>=3.5.0`/`flutter >=3.24` → رُفع إلى `sdk: >=3.6.0` و`flutter: >=3.27.0`.
3. **مجلدا assets فارغان** (`assets/images/`، `assets/icons/`) معلنان في pubspec — يختفيان عند فك الـ zip (الأرشيف لا يحفظ مجلدات فارغة) → `flutter build` يفشل بـ "unable to find directory entry" → حُذفا من pubspec (لا يشير إليهما أي كود — تحقق فعلي).
4. **`custom_lint` plugin** في analysis_options بدون الحزمة بعد التنظيف → أُزيل.

### Error Handling (ثغرة حرجة — البند 12)
5. **ردود 4xx كانت تفلت من كل المعالجة**: بسبب `validateStatus < 500` لا يصل 401/404/422/429 لـ ErrorInterceptor أبداً، و`_ensureSuccess` كان يرمي `ServerException` خام يفلت من `on DioException catch` في الـ providers (crash محتمل)، و**الجلسة المنتهية (401) لم تكن ستُمسح أبداً** لأن `UnauthorizedException` لا يُنشأ. → أُنشئ `core/network/response_handler.dart` موحّد يصنّف 401/404/422/429 ويرمي `DioException(error: TypedException)`، واستُبدلت الدوال الخمس المكررة في كل الـ datasources.

### Providers
6. **Memory leak**: `categoryProductsProvider` عائلي غير-autoDispose — كل فئة تُزار تبقى بالذاكرة للأبد → حُوّل لـ `AutoDisposeFamilyNotifier` مع حارس `_alive` (via `ref.onDispose`) يمنع الكتابة على state بعد الـ dispose أثناء طلبات معلّقة.

### Router
7. حذف 4 ثوابت routes ميتة (`wishlist`, `editProfile`, `addresses`, `language`) — غير مسجلة وغير مستخدمة.
8. حذف ثابت `about` + الـ GoRoute alias الخاص به (الـ Profile يستخدم `staticPage/about`).

### Imports & ملفات
9. تحويل 3 استيرادات نسبية في `dio_client.dart` إلى package imports (كانت تخالف lint `always_use_package_imports` المفعّل).
10. حذف الملف اليتيم الوحيد `core/utils/extensions/context_extensions.dart`.
11. تنظيف pubspec: حذف 8 dependencies غير مستوردة إطلاقاً (logger، flutter_svg، package_info_plus، device_info_plus، riverpod/freezed/json annotations) + 7 dev_dependencies codegen غير مستخدمة (لا يوجد ملف `.g.dart` واحد بالمشروع).

### Localization
12. حذف 41 مفتاح ترجمة ميت من ar.json وen.json (بعد فحص مزدوج يشمل الاستخدام غير المباشر عبر string literals مثل onboarding). التطابق ar↔en تام.

### Responsive / Accessibility / UX
13. **Overflow**: صف السعر في تفاصيل المنتج (سعر + سعر قديم + شارة خصم) → `Wrap` — كان سينكسر على شاشات ~320px مع أسعار طويلة.
14. **Overflow**: سطر رقم الهاتف في صفحة OTP → `Wrap`.
15. **Touch targets**: أزرار الكمية في السلة 32px → 40px.
16. **Pull-to-refresh على محتوى قصير**: إضافة `AlwaysScrollableScrollPhysics` لـ Home/Cart/Categories/Orders (بدونها السحب لا يعمل على Android عندما لا يملأ المحتوى الشاشة).
17. **Lint**: إزالة statement عديم الأثر (`results;`) في Splash + تقوية typing في نتائج البحث (`List` → `List<Product>` مع إزالة casts).

---

## 5. تغطية Loading / Error / Empty / Retry (مراجعة كود)

كل شاشة بيانات لديها المسارات الأربعة — **لا شاشة بيضاء ممكنة عند الخطأ** بحدود المراجعة الساكنة:

| الشاشة | Loading | Error+Retry | Empty | الآلية |
|--------|---------|-------------|-------|--------|
| Home (5 أقسام) | Shimmer لكل قسم | Retry لكل قسم مستقل | إخفاء القسم | `.when` ×3 + خفي للبانر/الفئات |
| Search | Shimmer grid | ErrorStateView | noResults + startTyping | sealed switch (5 حالات حصري) |
| Categories / Details | Shimmer | ErrorStateView | EmptyState | `.when` / PaginatedListState |
| Product | Shimmer كامل | Retry + زر رجوع | — | `.when` ×2 |
| Cart | Shimmer | Retry | EmptyState + CTA | `.when` |
| Checkout | Shimmer لكل قسم | Retry لكل قسم | AddAddress | `.when` ×2 |
| Payment | Spinner + رسائل حالة | Failed page + tryAgain | — | sealed PaymentFlowState + timeout 5min + "تحقق لاحقاً" |
| Orders / Details | Shimmer | Retry | EmptyState + guest state | `.when` |
| Static pages | Shimmer | Retry | — | `.when` |

**Offline**: OfflineBanner عام (connectivity stream) + settings/user cache fallback + timeout 20s على Dio + تصنيف NetworkException لأخطاء الاتصال والـ timeout.

---

## 6. المشكلات المتبقية (صريحة)

| # | المشكلة | الخطورة | لماذا لم تُحل |
|---|---------|---------|----------------|
| 1 | **لم يُنفَّذ `flutter analyze` ولا `flutter build`** — احتمال أخطاء analyzer دقيقة (generics/inference) لا يكشفها regex | **عالية** | SDK غير متاح وتنزيله محجوب شبكياً (مثبت) |
| 2 | لا اختبار على جهاز/محاكي — الدفع polling وRTL والـ deep behavior غير مجرّبة | عالية | نفس السبب |
| 3 | مجلدا `android/` و`ios/` غير موجودين — يلزم `flutter create .` محلياً لتوليدهما ثم ضبط applicationId/bundle id، الأذونات (INTERNET)، والتوقيع | متوسطة | توليدهما يتطلب Flutter SDK |
| 4 | google_fonts يجلب Tajawal من الشبكة أول تشغيل — للإنتاج يُفضَّل تضمين الخط asset | منخفضة | إضافة asset = خارج نطاق "إصلاحات فقط" |
| 5 | dark theme placeholder (سيعمل compile لكنه غير مصمم) | منخفضة | مقصود بالعقد |
| 6 | pull-to-refresh لا يعمل فوق EmptyState (غير scrollable) في orders/cart الفارغين | منخفضة جداً | زر CTA بديل موجود |

## 7. خطوات التحقق المطلوبة منك محلياً (بالترتيب)

```bash
cd bellabox_app
flutter create . --platforms=android,ios   # يولّد android/ ios/ فقط، لن يمس lib/
flutter pub get
flutter analyze                             # المرجع النهائي
flutter build apk --debug
```

---

## 8. تقييم الجاهزية: **78%**

**التبرير:**
- **الكود المصدري (lib/ + pubspec + assets): ~95%** بحدود ما تكشفه المراجعة الساكنة — صفر واقعات في 13 فحصاً آلياً، وأُصلحت 4 أخطاء compile مؤكدة و13 مشكلة جودة، منها ثغرة error-handling كانت ستسبب crashes وجلسات لا تنتهي.
- **الخصم (−22%):** غياب الدليل التنفيذي (`analyze`/`build` لم يعملا — وهذا شرطك الصريح)، وغياب مجلدات المنصات android/ios، وصفر اختبار على جهاز. لا يمكن بأمانة تسمية تطبيق "Production Ready" قبل هذه الثلاثة.

**الخلاصة:** المشروع في أفضل حالة يمكن الوصول إليها بدون Flutter SDK. المتوقع بعد `flutter create . && pub get && analyze` محلياً: 0 errors أو أخطاء معدودة سطحية (استنتاج، ليس ضماناً).
