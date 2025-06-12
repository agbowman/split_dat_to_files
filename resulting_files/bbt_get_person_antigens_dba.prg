CREATE PROGRAM bbt_get_person_antigens:dba
 RECORD reply(
   1 all_antigens[*]
     2 active_ind = i2
     2 person_antigen_id = f8
     2 person_antigen_disp = vc
     2 added_by = vc
     2 date_added = dq8
     2 removed_by = vc
     2 date_removed = dq8
     2 removal_reason = vc
     2 removal_notes = vc
     2 updt_cnt = i4
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
 DECLARE result_status_codeset = i4 WITH public, constant(1901)
 DECLARE active_status_codeset = i4 WITH public, constant(48)
 DECLARE autoverify_cd = f8 WITH protected, noconstant(0.0)
 DECLARE verify_cd = f8 WITH protected, noconstant(0.0)
 DECLARE corrected_cd = f8 WITH protected, noconstant(0.0)
 DECLARE oldverified_cd = f8 WITH protected, noconstant(0.0)
 DECLARE combined_cd = f8 WITH protected, noconstant(0.0)
 DECLARE inactive_cd = f8 WITH protected, noconstant(0.0)
 DECLARE antibody_cnt = i4 WITH protected, noconstant(0.0)
 DECLARE autoverified_meaning = vc WITH public, constant("AUTOVERIFIED")
 DECLARE verified_meaning = vc WITH public, constant("VERIFIED")
 DECLARE corrected_meaning = vc WITH public, constant("CORRECTED")
 DECLARE oldverified_meaning = vc WITH public, constant("OLDVERIFIED")
 DECLARE combined_meaning = vc WITH public, constant("COMBINED")
 DECLARE inactive_meaning = vc WITH public, constant("INACTIVE")
 DECLARE historical = vc WITH public
 DECLARE removed_res_correction = vc WITH public
 DECLARE persantigenindex = i4 WITH public, noconstant(0)
 DECLARE pos = i4 WITH public, noconstant(0)
 SET autoverify_cd = uar_get_code_by("MEANING",result_status_codeset,nullterm(autoverified_meaning))
 SET corrected_cd = uar_get_code_by("MEANING",result_status_codeset,nullterm(corrected_meaning))
 SET verify_cd = uar_get_code_by("MEANING",result_status_codeset,nullterm(verified_meaning))
 SET oldverified_cd = uar_get_code_by("MEANING",result_status_codeset,nullterm(oldverified_meaning))
 SET combined_cd = uar_get_code_by("MEANING",active_status_codeset,nullterm(combined_meaning))
 SET inactive_cd = uar_get_code_by("MEANING",active_status_codeset,nullterm(inactive_meaning))
 SET historical = uar_i18ngetmessage(i18nhandle,"historical","Historical")
 SET removed_res_correction = uar_i18ngetmessage(i18nhandle,"removed by result correction",
  "Removed by result correction")
 SET reply->status_data.status = "S"
 IF (autoverify_cd <= 0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "UAR_GET_CODE_BY"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "AUTOVERIFIED"
  GO TO exit_program
 ENDIF
 IF (corrected_cd <= 0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "UAR_GET_CODE_BY"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "CORRECTED"
  GO TO exit_program
 ENDIF
 IF (verify_cd <= 0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "UAR_GET_CODE_BY"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "VERIFIED"
  GO TO exit_program
 ENDIF
 IF (oldverified_cd <= 0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "UAR_GET_CODE_BY"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "OLDVERIFIED"
  GO TO exit_program
 ENDIF
 IF (combined_cd <= 0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "UAR_GET_CODE_BY"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "COMBINED"
  GO TO exit_program
 ENDIF
 IF (inactive_cd <= 0.0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "UAR_GET_CODE_BY"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "INACTIVE"
  GO TO exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM person_antigen pa,
   prsnl prsnl2,
   (dummyt d1  WITH seq = 1),
   perform_result pr,
   prsnl prsnl1
  PLAN (pa
   WHERE (pa.person_id=request->person_id))
   JOIN (prsnl2
   WHERE prsnl2.person_id=pa.removed_prsnl_id)
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (pr
   WHERE pa.result_id=pr.result_id
    AND pr.result_id > 0
    AND pr.result_status_cd IN (autoverify_cd, verify_cd, corrected_cd, oldverified_cd))
   JOIN (prsnl1
   WHERE prsnl1.person_id=pr.perform_personnel_id)
  ORDER BY pa.person_antigen_id
  HEAD REPORT
   antigen_cnt = 0, stat = alterlist(reply->all_antigens,(antigen_cnt+ 10))
  HEAD pa.person_antigen_id
   row + 0
  DETAIL
   IF (pa.contributor_system_cd > 0)
    pos = locateval(persantigenindex,1,size(reply->all_antigens,5),pa.person_antigen_id,reply->
     all_antigens[persantigenindex].person_antigen_id)
    IF (pos <= 0
     AND pa.active_status_cd != combined_cd
     AND pa.active_status_cd != inactive_cd)
     antigen_cnt = (antigen_cnt+ 1)
     IF (antigen_cnt > size(reply->all_antigens,5))
      stat = alterlist(reply->all_antigens,(antigen_cnt+ 10))
     ENDIF
     reply->all_antigens[antigen_cnt].active_ind = pa.active_ind, reply->all_antigens[antigen_cnt].
     person_antigen_id = pa.person_antigen_id, reply->all_antigens[antigen_cnt].person_antigen_disp
      = uar_get_code_display(pa.antigen_cd),
     reply->all_antigens[antigen_cnt].added_by = historical, reply->all_antigens[antigen_cnt].
     updt_cnt = pa.updt_cnt
     IF (pa.active_ind=0)
      reply->all_antigens[antigen_cnt].removed_by = prsnl2.username, reply->all_antigens[antigen_cnt]
      .date_removed = cnvtdatetime(pa.removed_dt_tm), reply->all_antigens[antigen_cnt].removal_reason
       = uar_get_code_display(pa.removal_reason_cd),
      reply->all_antigens[antigen_cnt].removal_notes = pa.removal_notes
     ENDIF
    ENDIF
   ELSE
    IF (pa.active_ind=1
     AND ((pr.result_status_cd=verify_cd) OR (((pr.result_status_cd=autoverify_cd) OR (pr
    .result_status_cd=corrected_cd)) )) )
     antigen_cnt = (antigen_cnt+ 1)
     IF (antigen_cnt > size(reply->all_antigens,5))
      stat = alterlist(reply->all_antigens,(antigen_cnt+ 10))
     ENDIF
     reply->all_antigens[antigen_cnt].active_ind = pa.active_ind, reply->all_antigens[antigen_cnt].
     person_antigen_id = pa.person_antigen_id, reply->all_antigens[antigen_cnt].person_antigen_disp
      = uar_get_code_display(pa.antigen_cd),
     reply->all_antigens[antigen_cnt].added_by = prsnl1.username, reply->all_antigens[antigen_cnt].
     date_added = cnvtdatetime(pr.perform_dt_tm), reply->all_antigens[antigen_cnt].updt_cnt = pa
     .updt_cnt
    ENDIF
    IF (pa.active_ind=0
     AND pa.active_status_cd != combined_cd
     AND pa.active_status_cd != inactive_cd
     AND ((pr.result_status_cd=corrected_cd) OR (((pr.result_status_cd=verify_cd) OR (pr
    .result_status_cd=autoverify_cd)) ))
     AND pa.removal_reason_cd > 0)
     antigen_cnt = (antigen_cnt+ 1)
     IF (antigen_cnt > size(reply->all_antigens,5))
      stat = alterlist(reply->all_antigens,(antigen_cnt+ 10))
     ENDIF
     reply->all_antigens[antigen_cnt].active_ind = pa.active_ind, reply->all_antigens[antigen_cnt].
     person_antigen_id = pa.person_antigen_id, reply->all_antigens[antigen_cnt].person_antigen_disp
      = uar_get_code_display(pa.antigen_cd),
     reply->all_antigens[antigen_cnt].added_by = prsnl1.username, reply->all_antigens[antigen_cnt].
     date_added = cnvtdatetime(pr.perform_dt_tm), reply->all_antigens[antigen_cnt].updt_cnt = pa
     .updt_cnt,
     reply->all_antigens[antigen_cnt].removed_by = prsnl2.username, reply->all_antigens[antigen_cnt].
     date_removed = cnvtdatetime(pa.removed_dt_tm), reply->all_antigens[antigen_cnt].removal_reason
      = uar_get_code_display(pa.removal_reason_cd),
     reply->all_antigens[antigen_cnt].removal_notes = pa.removal_notes
    ENDIF
    IF (pa.active_ind=0
     AND pa.active_status_cd != combined_cd
     AND pa.active_status_cd != inactive_cd
     AND pr.result_status_cd=oldverified_cd
     AND pa.removal_reason_cd <= 0)
     antigen_cnt = (antigen_cnt+ 1)
     IF (antigen_cnt > size(reply->all_antigens,5))
      stat = alterlist(reply->all_antigens,(antigen_cnt+ 10))
     ENDIF
     reply->all_antigens[antigen_cnt].active_ind = pa.active_ind, reply->all_antigens[antigen_cnt].
     person_antigen_id = pa.person_antigen_id, reply->all_antigens[antigen_cnt].person_antigen_disp
      = uar_get_code_display(pa.antigen_cd),
     reply->all_antigens[antigen_cnt].added_by = prsnl1.username, reply->all_antigens[antigen_cnt].
     date_added = cnvtdatetime(pr.perform_dt_tm), reply->all_antigens[antigen_cnt].updt_cnt = pa
     .updt_cnt,
     reply->all_antigens[antigen_cnt].removed_by = prsnl2.username, reply->all_antigens[antigen_cnt].
     date_removed = cnvtdatetime(pa.removed_dt_tm), reply->all_antigens[antigen_cnt].removal_notes =
     removed_res_correction
    ENDIF
   ENDIF
  FOOT  pa.person_antigen_id
   row + 0
  FOOT REPORT
   stat = alterlist(reply->all_antigens,antigen_cnt)
  WITH nocounter, outerjoin = d1
 ;end select
#exit_program
END GO
