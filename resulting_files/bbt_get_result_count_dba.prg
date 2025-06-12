CREATE PROGRAM bbt_get_result_count:dba
 RECORD reply(
   1 updt_cnt = i4
   1 result_updt_cnt = i4
   1 nbr_of_results = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 patient_aborh_failure = vc
 )
 SET captions->patient_aborh_failure = uar_i18ngetmessage(i18nhandle,"patient_aborh_failure",
  "Unable to find person demographic ABO/Rh.")
 SET err_cnt = 0
 SET store_special_testing_id = 0.0
 SET reply->status_data.status = "F"
 IF ((request->table_ind=1))
  SELECT INTO "nl:"
   pa.person_id, pa.antibody_cd
   FROM person_antibody pa
   WHERE (pa.person_id=request->person_id)
    AND (pa.antibody_cd=request->orig_result_code_set_cd)
    AND pa.active_ind=1
   HEAD REPORT
    reply->nbr_of_results = 0
   DETAIL
    IF (pa.seq > 0)
     reply->nbr_of_results += 1
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET err_cnt += 1
   SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
   SET reply->status_data.subeventstatus[err_cnt].operationstatus = "F"
   SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "person_antibody"
   SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
   "unable to find person antibody specified"
   SET reply->status_data.status = "F"
   GO TO end_script
  ELSE
   SELECT INTO "nl:"
    par.person_id, par.antibody_cd, par.result_id,
    par.updt_cnt
    FROM person_antibody par
    WHERE (par.person_id=request->person_id)
     AND (par.antibody_cd=request->orig_result_code_set_cd)
     AND (par.result_id=request->result_id)
     AND par.active_ind=1
    DETAIL
     reply->updt_cnt = par.updt_cnt
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET err_cnt += 1
    SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
    SET reply->status_data.subeventstatus[err_cnt].operationstatus = "F"
    SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "person_antibody"
    SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
    "unable to find person antibody result specified"
    SET reply->status_data.status = "F"
    GO TO end_script
   ELSE
    SET reply->status_data.status = "S"
    GO TO end_script
   ENDIF
  ENDIF
 ENDIF
 IF ((request->table_ind=2))
  SELECT INTO "nl:"
   pa.person_id, pa.antigen_cd
   FROM person_antigen pa
   WHERE (pa.person_id=request->person_id)
    AND (pa.antigen_cd=request->orig_result_code_set_cd)
    AND pa.active_ind=1
   HEAD REPORT
    reply->nbr_of_results = 0
   DETAIL
    IF (pa.seq > 0)
     reply->nbr_of_results += 1
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET err_cnt += 1
   SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
   SET reply->status_data.subeventstatus[err_cnt].operationstatus = "F"
   SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "person_antigen"
   SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
   "unable to find person antigen specified"
   SET reply->status_data.status = "F"
   GO TO end_script
  ELSE
   SELECT INTO "nl:"
    par.person_id, par.antigen_cd, par.result_id,
    par.updt_cnt
    FROM person_antigen par
    WHERE (par.person_id=request->person_id)
     AND (par.antigen_cd=request->orig_result_code_set_cd)
     AND (par.result_id=request->result_id)
     AND par.active_ind=1
    DETAIL
     reply->updt_cnt = par.updt_cnt
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET err_cnt += 1
    SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
    SET reply->status_data.subeventstatus[err_cnt].operationstatus = "F"
    SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "person_antigen"
    SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
    "unable to find person antigen result specified"
    SET reply->status_data.status = "F"
    GO TO end_script
   ELSE
    SET reply->status_data.status = "S"
    GO TO end_script
   ENDIF
  ENDIF
 ENDIF
 IF ((request->table_ind=3))
  SELECT INTO "nl:"
   pa.person_aborh_id, pa.person_id, pa.abo_cd,
   pa.rh_cd, pa.updt_cnt
   FROM person_aborh pa
   WHERE (pa.person_id=request->person_id)
    AND pa.active_ind=1
   DETAIL
    reply->nbr_of_results = 0
    IF ((pa.abo_cd=request->orig_abo_cd)
     AND (pa.rh_cd=request->orig_rh_cd))
     reply->updt_cnt = pa.updt_cnt
    ELSE
     reply->updt_cnt = - (1)
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET err_cnt += 1
   SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
   SET reply->status_data.subeventstatus[err_cnt].operationstatus = "F"
   SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "person_aborh"
   SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue = captions->patient_aborh_failure
   SET reply->status_data.status = "F"
   GO TO end_script
  ELSE
   SELECT INTO "nl:"
    par.updt_cnt
    FROM person_aborh_result par
    WHERE (par.result_id=request->result_id)
     AND (par.person_id=request->person_id)
     AND par.active_ind=1
    DETAIL
     IF ((par.result_cd=request->orig_result_code_set_cd))
      reply->result_updt_cnt = par.updt_cnt
     ELSE
      reply->result_updt_cnt = - (1)
     ENDIF
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET err_cnt += 1
    SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
    SET reply->status_data.subeventstatus[err_cnt].operationstatus = "F"
    SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "person_aborh_result"
    SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
    "unable to find person aborh result specified"
    SET reply->status_data.status = "F"
    GO TO end_script
   ELSE
    SET reply->status_data.status = "S"
    GO TO end_script
   ENDIF
  ENDIF
 ENDIF
 IF ((request->table_ind=4))
  SELECT INTO "nl:"
   s.special_testing_id, s.product_id, s.special_testing_cd,
   s.updt_cnt, sr.special_testing_id, sr.product_id
   FROM special_testing s,
    special_testing_result sr
   PLAN (s
    WHERE (s.product_id=request->product_id)
     AND (s.special_testing_cd=request->orig_result_code_set_cd)
     AND s.active_ind=1)
    JOIN (sr
    WHERE (sr.product_id=request->product_id)
     AND sr.special_testing_id=s.special_testing_id
     AND sr.active_ind=1)
   ORDER BY s.special_testing_cd
   HEAD REPORT
    reply->nbr_of_results = 0
   HEAD s.special_testing_cd
    reply->updt_cnt = s.updt_cnt
   DETAIL
    store_special_testing_id = s.special_testing_id
    IF (sr.seq > 0)
     reply->nbr_of_results += 1
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET err_cnt += 1
   SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
   SET reply->status_data.subeventstatus[err_cnt].operationstatus = "F"
   SET reply->status_data.subeventstatus[err_cnt].targetobjectname =
   "special_testing and special_testing_result"
   SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
   "unable to find product special testing (antigen) specified"
   SET reply->status_data.status = "F"
   GO TO end_script
  ELSE
   SELECT INTO "nl:"
    sr.special_testing_id, sr.product_id, sr.updt_cnt
    FROM special_testing_result sr
    WHERE sr.special_testing_id=store_special_testing_id
     AND (sr.product_id=request->product_id)
     AND (sr.result_id=request->result_id)
     AND sr.active_ind=1
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET err_cnt += 1
    SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
    SET reply->status_data.subeventstatus[err_cnt].operationstatus = "F"
    SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "special_testing_result"
    SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
    "unable to find product special testing result specified"
    SET reply->status_data.status = "F"
    GO TO end_script
   ELSE
    SET reply->status_data.status = "S"
    GO TO end_script
   ENDIF
  ENDIF
 ENDIF
 IF ((request->table_ind=5))
  SELECT INTO "nl:"
   bp.product_id, bp.cur_abo_cd, bp.cur_rh_cd,
   bp.updt_cnt
   FROM blood_product bp
   WHERE (bp.product_id=request->product_id)
    AND (bp.cur_abo_cd=request->orig_abo_cd)
    AND (bp.cur_rh_cd=request->orig_rh_cd)
    AND bp.active_ind=1
   DETAIL
    reply->updt_cnt = bp.updt_cnt, reply->nbr_of_results = 0
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET err_cnt += 1
   SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
   SET reply->status_data.subeventstatus[err_cnt].operationstatus = "F"
   SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "blood_product"
   SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
   "unable to find blood product aborh specified"
   SET reply->status_data.status = "F"
   GO TO end_script
  ELSE
   SELECT
    IF ((request->abo_testing_cd=0)
     AND (request->rh_testing_cd > 0))
     WHERE (a.product_id=request->product_id)
      AND (a.rh_type_cd=request->rh_testing_cd)
      AND (a.result_id=request->result_id)
      AND a.active_ind=1
    ELSEIF ((request->abo_testing_cd > 0)
     AND (request->rh_testing_cd=0))
     WHERE (a.product_id=request->product_id)
      AND (a.abo_group_cd=request->abo_testing_cd)
      AND (a.result_id=request->result_id)
      AND a.active_ind=1
    ELSE
     WHERE (a.product_id=request->product_id)
      AND (a.abo_group_cd=request->abo_testing_cd)
      AND (a.rh_type_cd=request->rh_testing_cd)
      AND (a.result_id=request->result_id)
      AND a.active_ind=1
    ENDIF
    INTO "nl:"
    a.updt_cnt
    FROM abo_testing a
    DETAIL
     reply->result_updt_cnt = a.updt_cnt
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET err_cnt += 1
    SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
    SET reply->status_data.subeventstatus[err_cnt].operationstatus = "F"
    SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "abo_testing"
    SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
    "unable to find product abo result specified"
    SET reply->status_data.status = "F"
    GO TO end_script
   ELSE
    SET reply->status_data.status = "S"
    GO TO end_script
   ENDIF
  ENDIF
 ENDIF
#end_script
END GO
