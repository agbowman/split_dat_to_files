CREATE PROGRAM ct_stratum_chk_a_ok_func:dba
 SET false = 0
 SET true = 1
 SET stratum_chk_a_ok_func_accrual = 0.0
 SET stratum_chk_a_ok_func_enrollstrattypecd = 0.0
 SET cval = 0.0
 SET cmean = fillstring(12," ")
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 DECLARE i18nhandle = i4 WITH public, noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET cset = 18790
 SET cmean = "ACCRUAL"
 EXECUTE ct_get_cv
 SET stratum_chk_a_ok_func_accrual = cval
 CALL echo(build("STRATUM_CHK_A_OK_FUNC_Accrual =",stratum_chk_a_ok_func_accrual))
 SELECT INTO "nl:"
  pr_am.enroll_stratification_type_cd
  FROM prot_amendment pr_am
  WHERE pr_am.prot_amendment_id=stratum_chk_a_ok_func_amendid
  DETAIL
   stratum_chk_a_ok_func_enrollstrattypecd = pr_am.enroll_stratification_type_cd
  WITH nocounter
 ;end select
 IF (stratum_chk_a_ok_func_enrollstrattypecd != 0.0)
  IF (stratum_chk_a_ok_func_enrollstrattypecd=stratum_chk_a_ok_func_accrual)
   SELECT INTO "nl:"
    strat.prot_stratum_id
    FROM prot_stratum strat
    WHERE strat.prot_amendment_id=stratum_chk_a_ok_func_amendid
     AND strat.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET stratum_chk_a_ok_func_isok = true
   ELSE
    SET stratum_chk_a_ok_func_isok = false
    SET stratum_chk_a_ok_func_reason = uar_i18ngetmessage(i18nhandle,"NO_STRATUMS",
     "The Enroll Stratification Type is ACCRUAL and no stratums are defined")
   ENDIF
  ELSE
   SET stratum_chk_a_ok_func_isok = true
  ENDIF
 ELSE
  SET stratum_chk_a_ok_func_isok = false
  SET stratum_chk_a_ok_func_reason = uar_i18ngetmessage(i18nhandle,"NOT_CHOSEN",
   "The Enrollment Stratification Type has not been chosen")
 ENDIF
END GO
