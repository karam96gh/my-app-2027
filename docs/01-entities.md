# الكيانات — النسخة التجريبية المحلية

> الإصدار 1.1؛ المرجع 06-decisions.md. نماذج محلية دون auth.users أو جداول Supabase.

| النموذج | الحقول والقواعد |
|---|---|
| DemoAccount | id وdisplay_name؛ حساب جاهز مرتبط بملف شخصي دون كلمات مرور. |
| Profile | id وfull_name غير فارغ وrole ضمن customer/staff/admin وcreated_at. المستخدم يعدل الاسم فقط. |
| StaffProfile | id وuser_id فريد لملف دوره staff وis_active. |
| Service | id وname غير فارغ وprice_amount غير سالب بدقة منزلتين وcurrency_code ثابت SYP وis_active. |
| StaffService | staff_id وservice_id؛ زوج فريد. |
| WorkingHours | id وstaff_id وweekday وفق ISO من 1 الاثنين إلى 7 الأحد وstart_time وend_time محليان. النهاية أكبر من البداية ولا عبور لمنتصف الليل أو تداخل لنفس الموظف واليوم. |
| StaffTimeOff | id وstaff_id وstarts_at وends_at وreason اختياري داخلي؛ النهاية أكبر من البداية، ويمكن الامتداد عدة أيام. |
| Booking | id وcustomer_id وstaff_id وservice_id وstarts_at وends_at وstatus وprice_at_booking وcurrency_at_booking وcreated_at وcancelled_by وcancelled_at وcancellation_reason الاختيارية. |
| DemoSession | account_id محفوظ محلياً وقابل للاستعادة والخروج والتبديل. |

## العلاقات والسلامة

الحساب له Profile واحد؛ الملف له صفر أو سجل موظف واحد. الموظف والخدمة متعدد لمتعدد عبر StaffService. الموظف له دوام وإجازات وحجوزات متعددة؛ كل حجز يخص زبوناً وموظفاً وخدمة بمراجع إلزامية.

اللحظات تحفظ UTC؛ ساعات الدوام محلية وفق Asia/Damascus. تحفظ الأموال بدقة عشرية مضبوطة دون أخطاء الكسور العائمة. مدة الحجز 30 دقيقة وسعره وعملته من الخدمة وقت الإنشاء. confirmed/completed يحجبان النطاق [start,end)، وcancelled لا يحجبه.

كل إلغاء يسجل المنفذ والوقت؛ سبب المدير إلزامي وسبب الزبون اختياري. لا حذف حسابات أو حجوزات من الواجهة ولا تغيير أسعارها التاريخية. D-05 يمنع تغييرات الإدارة المتعارضة مع حجوزات المستقبل. إعادة الضبط تستبدل بيانات التجربة وتزيل الجلسة، ولا تمثل حذف مستخدم حقيقي.

لا بيانات دفع أو فروع أو خدمات متعددة للحجز. الموظف يرى اسم الزبون دون بيانات الاتصال، والزبون لا يرى أسباب الغياب أو حجوزات غيره.