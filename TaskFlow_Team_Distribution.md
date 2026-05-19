# التوزيع النهائي المعتمد لمشروع TaskFlow 👥
## (TaskFlow Team Approved Task Distribution)

تم تحديث التوزيع رسمياً بعد مراجعة وتأكيد عمل صفحة الإعدادات والمصادقة وتوزيعها بشكل دقيق بين الأعضاء ليكون 100% مطابقاً للملفات الفعلية الموجودة في المشروع.

---

### 1️⃣ محمد محمود (Muhammad Mahmoud) — Backend, Auth & Network Core
* **المسؤول عن الربط بالباكيند والشبكة (Backend & Network Core):**
  - `lib/core/network/` (مجلد الشبكة بالكامل: `dio_client.dart`, `auth_interceptor.dart`, `error_interceptor.dart`, `api_response.dart`, `dio_extensions.dart`)
  - `lib/core/config/app_config.dart` (إعدادات الـ API وعناوين السيرفر وبيئة العمل)
  - `lib/core/error/` (مجلد معالجة الأخطاء والـ Failures: `error_mapper.dart`, `failure.dart`)
  - `lib/core/storage/secure_storage.dart` (التخزين المحلي الآمن للتوكينات وبيانات الجلسة)
* **المصادقة والترحيب (UI & BLoC):**
  - `lib/features/onboarding/presentation/pages/onboarding_page.dart` (شاشات التهيئة الترحيبية)
  - `lib/features/onboarding/presentation/pages/welcome_page.dart` (شاشة البدء)
  - `lib/features/auth/presentation/pages/login_page.dart` (تسجيل الدخول)
  - `lib/features/auth/presentation/pages/signup_page.dart` (التسجيل الجديد)
  - `lib/features/auth/presentation/bloc/auth_bloc.dart` (إدارة حالة المصادقة والتحقق من الجلسة)

---

#### 2️⃣ مازن محمود (Mazen Mahmoud) — Home, Routing & App Styling
* **التوجيه والواجهات الرئيسية (UI, Routing & BLoC):**
  - `lib/core/routes/app_router.dart` (مسارات وتوجيه التطبيق المركزي `GoRouter`)
  - `lib/features/home/presentation/pages/home_page.dart` (الواجهة الرئيسية للتطبيق)
  - `lib/core/widgets/app_shell.dart` (شريط التنقل السفلي والتبويبات الأساسية)
  - `lib/features/home/presentation/bloc/home_bloc.dart` (إدارة حالة الصفحة الرئيسية)
* **الهوية البصرية والألوان (Theme):**
  - `lib/core/theme/app_theme.dart` (ألوان وتنسيقات التطبيق المضيء والمظلم)
  - `lib/core/constants/app_colors.dart` (ألوان وتنسيقات التطبيق الثابتة)
  - `lib/core/widgets/` (مجلد الكروت والأزرار والـ Widgets الموحدة المشتركة)

---

#### 3️⃣ حازم محمد (Hazem Muhammad) — Projects Management
* **إدارة المشاريع وإنشائها (UI & BLoC):**
  - `lib/features/projects/presentation/pages/projects_page.dart` (شاشة استعراض المشاريع)
  - `lib/features/projects/presentation/pages/create_project_page.dart` (شاشة إنشاء مشروع جديد)
  - `lib/features/projects/presentation/bloc/projects_bloc.dart` (إدارة حالة المشاريع وجلبها)
* **النماذج وعمليات المشاريع (Logic & Models):**
  - `lib/features/projects/domain/` (نماذج المشاريع)
  - `lib/features/projects/data/repositories/projects_repository_impl.dart` (دوال الـ CRUD للمشاريع)

---

#### 4️⃣ محمد سيد (Muhammad Sayed) — Collaboration & Project Details
* **تفاصيل المشروع والتعاون (UI & API):**
  - `lib/features/projects/presentation/pages/project_details_page.dart` (شاشة تفاصيل المشروع والمهام التابعة له)
  - `lib/features/projects/presentation/pages/invite_member_page.dart` (شاشة دعوة وإضافة عضو للمشروع)
* **الربط البرمجي للتعاون والأعضاء:**
  - `lib/features/projects/data/datasources/project_remote_datasource.dart` (دوال دعوة الأعضاء والأعضاء المشتركين)
  - `lib/features/projects/data/repositories/projects_repository_impl.dart` (الربط البرمجي لعمليات دعوة الأعضاء وتفاصيل المشاريع)

---

#### 5️⃣ علاء (Alaa) — Tasks Management (Core Feature)
* **استعراض وإنشاء المهام (UI & BLoC):**
  - `lib/features/tasks/presentation/pages/tasks_page.dart` (شاشة عرض وجدولة المهام الشخصية والمشاريع)
  - `lib/features/tasks/presentation/pages/create_task_page.dart` (شاشة إنشاء وتعديل المهام)
  - `lib/features/tasks/presentation/bloc/tasks_bloc.dart` (إدارة حالة المهام وجلبها)
* **الربط ونماذج المهام (Logic & Models):**
  - `lib/features/tasks/data/` (دوال الـ API للمهام: `tasks_repository_impl.dart`, `tasks_remote_datasource.dart`)
  - `lib/features/tasks/domain/` (نماذج المهام وحالاتها: `task_models.dart`)

---

#### 6️⃣ آية (Ayha) — Infrastructure & Settings UI
* **الملف الشخصي وتفاصيل المهمة الدقيقة (UI & Settings):**
  - `lib/features/profile/presentation/pages/settings_page.dart` (شاشة الإعدادات العامة للملف الشخصي والتطبيق)
  - `lib/features/tasks/presentation/pages/task_details_page.dart` (شاشة تفاصيل المهمة والمهام الفرعية)
* **البنية التحتية والمساعدات (Core Infrastructure):**
  - `lib/core/di/injection.dart` (إدارة وحقن الاعتماديات وكائنات التطبيق باستخدام `get_it`)
  - `lib/core/utils/auth_event_bus.dart` (ناقل الأحداث للتواصل البرمجي الداخلي)
  - `lib/core/push/` (إعداد وتجهيز الإشعارات الفورية `Push Notifications`)
