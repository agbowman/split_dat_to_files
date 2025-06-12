CREATE PROGRAM dts_get_med_list:dba
 CALL echo("***")
 CALL echo("***   BEG: DTS_GET_MED_LIST")
 CALL echo("***")
 RECORD reply(
   1 text = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 DECLARE rtf_rhead = vc WITH protect, constant(concat(
   "{\rtf1\ansi\deff0{\fonttbl{\f0\fswiss Arial;}}",
   " {\colortbl;\red0\green0\blue0;\red255\green255\","blue255;}\deftab1134"))
 DECLARE rtf_rh2r = vc WITH protect, constant("\pard\plain\f0\fs18\cb2")
 DECLARE rtf_rh2b = vc WITH protect, constant("\pard\plain\f0\fs18\cb2\b")
 DECLARE rtf_rh2bu = vc WITH protect, constant("\pard\plain\f0\fs18\cb2\b\ul")
 DECLARE rtf_rh2u = vc WITH protect, constant("\pard\plain\f0\fs18\cb2\u")
 DECLARE rtf_rh2i = vc WITH protect, constant("\pard\plain\f0\fs18\cb2\i")
 DECLARE rtf_eol = vc WITH protect, constant("\par")
 DECLARE rtf_rtab = vc WITH protect, constant("\tab")
 DECLARE rtf_wr = vc WITH protect, constant(" \plain\f0\fs18\cb2")
 DECLARE rtf_wb = vc WITH protect, constant("\plain\f0\fs18\cb2\b")
 DECLARE rtf_wu = vc WITH protect, constant("\plain\f0\fs18\cb2\ul")
 DECLARE rtf_wi = vc WITH protect, constant("\plain\f0\fs18\cb2\i")
 DECLARE rtf_wbi = vc WITH protect, constant("\plain\f0\fs18\cb2\b\i")
 DECLARE rtf_wiu = vc WITH protect, constant("\plain\f0\fs18\cb2\i\ul")
 DECLARE rtf_wbiu = vc WITH protect, constant("\plain\f0\fs18\cb2\b\ul\i")
 DECLARE rtf_eof = vc WITH protect, constant("}")
 DECLARE 1_blank = c1 WITH protect, constant(" ")
 DECLARE 4_blank = c4 WITH protect, constant("    ")
 DECLARE 8_blank = c8 WITH protect, constant("        ")
 DECLARE 10_blank = c10 WITH protect, constant("          ")
 DECLARE 12_blank = c12 WITH protect, constant("            ")
 DECLARE 14_blank = c14 WITH protect, constant("              ")
 FREE RECORD med_list
 RECORD med_list(
   1 ordered_med_cnt = i4
   1 ordered_med[*]
     2 order_id = f8
     2 encntr_id = f8
     2 order_status_disp = vc
     2 activity_type_cd = f8
     2 catalog_type_cd = f8
     2 catalog_cd = f8
     2 viewable_ind = i2
     2 med_line = vc
   1 prescribed_med_cnt = i4
   1 prescribed_med[*]
     2 order_id = f8
     2 encntr_id = f8
     2 order_status_disp = vc
     2 activity_type_cd = f8
     2 catalog_type_cd = f8
     2 catalog_cd = f8
     2 viewable_ind = i2
     2 med_line = vc
   1 documented_med_cnt = i4
   1 documented_med[*]
     2 order_id = f8
     2 encntr_id = f8
     2 order_status_disp = vc
     2 activity_type_cd = f8
     2 catalog_type_cd = f8
     2 catalog_cd = f8
     2 viewable_ind = i2
     2 med_line = vc
   1 inprocess_med_cnt = i4
   1 inprocess_med[*]
     2 order_id = f8
     2 encntr_id = f8
     2 order_status_disp = vc
     2 activity_type_cd = f8
     2 catalog_type_cd = f8
     2 catalog_cd = f8
     2 viewable_ind = i2
     2 med_line = vc
   1 future_med_cnt = i4
   1 future_med[*]
     2 order_id = f8
     2 encntr_id = f8
     2 order_status_disp = vc
     2 activity_type_cd = f8
     2 catalog_type_cd = f8
     2 catalog_cd = f8
     2 viewable_ind = i2
     2 med_line = vc
   1 incomplete_med_cnt = i4
   1 incomplete_med[*]
     2 order_id = f8
     2 encntr_id = f8
     2 order_status_disp = vc
     2 activity_type_cd = f8
     2 catalog_type_cd = f8
     2 catalog_cd = f8
     2 viewable_ind = i2
     2 med_line = vc
   1 suspended_med_cnt = i4
   1 suspended_med[*]
     2 order_id = f8
     2 encntr_id = f8
     2 order_status_disp = vc
     2 activity_type_cd = f8
     2 catalog_type_cd = f8
     2 catalog_cd = f8
     2 viewable_ind = i2
     2 med_line = vc
   1 medstudent_med_cnt = i4
   1 medstudent_med[*]
     2 order_id = f8
     2 encntr_id = f8
     2 order_status_disp = vc
     2 activity_type_cd = f8
     2 catalog_type_cd = f8
     2 catalog_cd = f8
     2 viewable_ind = i2
     2 med_line = vc
   1 inact_med_cnt = i4
   1 inact_med[*]
     2 order_id = f8
     2 encntr_id = f8
     2 activity_type_cd = f8
     2 catalog_type_cd = f8
     2 catalog_cd = f8
     2 viewable_ind = i2
     2 med_line = vc
 )
 DECLARE pharmacy_type_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6000,"PHARMACY"))
 DECLARE act_ordered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE act_in_process_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"INPROCESS"))
 DECLARE act_future_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"FUTURE"))
 DECLARE act_incomplete_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"INCOMPLETE"))
 DECLARE act_suspended_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"SUSPENDED"))
 DECLARE act_med_student_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"MEDSTUDENT"))
 DECLARE inact_discontinued_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,
   "DISCONTINUED"))
 DECLARE inact_canceled_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"CANCELED"))
 DECLARE inact_completed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"COMPLETED"))
 DECLARE inact_pending_complete_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,
   "PENDING"))
 DECLARE inact_voided_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"DELETED"))
 DECLARE inact_voided_wrslt_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,
   "VOIDEDWRSLT"))
 DECLARE inact_trans_cancel_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,
   "TRANS/CANCEL"))
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
 DECLARE i18nhandle = i4 WITH noconstant(0)
 SET istat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE prescribed_order_status_disp = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,
   "PRESCRIBED","Prescribed"))
 DECLARE documented_order_status_disp = vc WITH protect, constant(uar_i18ngetmessage(i18nhandle,
   "DOCUMENTED","Documented"))
 DECLARE patient_person_id = f8 WITH protect, noconstant(0.0)
 DECLARE prsnl_person_id = f8 WITH protect, noconstant(reqinfo->updt_id)
 DECLARE prsnl_pos_cd = f8 WITH protect, noconstant(0.0)
 FREE RECORD inact
 RECORD inact(
   1 date_dt_tm = dq8
 )
 SET inact->date_dt_tm = datetimeadd(cnvtdatetime(curdate,0),- (3))
 CALL echorecord(inact)
 FREE RECORD pt
 RECORD pt(
   1 line_cnt = i2
   1 lns[*]
     2 line = vc
 )
 DECLARE max_length = i4 WITH public, noconstant(70)
 DECLARE encntr_org_sec_on = i2 WITH protect, noconstant(false)
 DECLARE conf_security_on = i2 WITH protect, noconstant(false)
 DECLARE dminfo_ok = i2 WITH protect, noconstant(false)
 DECLARE elist_size = i4 WITH protect, noconstant(0)
 DECLARE lnum = i4 WITH protect, noconstant(0)
 FREE RECORD ordr_exp
 RECORD ordr_exp(
   1 priv_value_cd = f8
   1 priv_value_meaning = vc
   1 exception_cnt = i4
   1 exception_type_flag = i2
   1 exception[*]
     2 exp_id = f8
 )
 DECLARE viewordr_val = f8 WITH protect, constant(uar_get_code_by("MEANING",6016,"VIEWORDER"))
 DECLARE found_ordr = i2 WITH protect, noconstant(false)
 DECLARE add_cnt = i4 WITH protect, noconstant(0)
 DECLARE found_ordered_viewable = i2 WITH protect, noconstant(false)
 DECLARE found_prescribed_viewable = i2 WITH protect, noconstant(false)
 DECLARE found_documented_viewable = i2 WITH protect, noconstant(false)
 DECLARE found_inprocess_viewable = i2 WITH protect, noconstant(false)
 DECLARE found_future_viewable = i2 WITH protect, noconstant(false)
 DECLARE found_incomplete_viewable = i2 WITH protect, noconstant(false)
 DECLARE found_suspended_viewable = i2 WITH protect, noconstant(false)
 DECLARE found_medstudent_viewable = i2 WITH protect, noconstant(false)
 DECLARE found_active_viewable = i2 WITH protect, noconstant(false)
 CALL echo("***")
 CALL echo("***   Validate Patient")
 CALL echo("***")
 IF ((((request->person_cnt > 0)) OR (size(request->person,5) > 0)) )
  SET patient_person_id = request->person[1].person_id
 ELSE
  SET failed = input_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "VALIDATE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "PERSON_ID"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Invalid PERSON_ID value passed in request"
  GO TO exit_script
 ENDIF
 IF (prsnl_person_id < 1)
  SET failed = input_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "VALIDATE"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "REQINFO->UPDT_ID"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Invalid REQINFO->UPDT_ID value"
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Validate Code Values")
 CALL echo("***")
 IF (pharmacy_type_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Invalid code_value for cdf_meaning PHARMACY in code_set 6000"
  GO TO exit_script
 ENDIF
 IF (act_ordered_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Invalid code_value for cdf_meaning ORDERED in code_set 6004"
  GO TO exit_script
 ENDIF
 IF (act_in_process_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Invalid code_value for cdf_meaning INPROCESS in code_set 6004"
  GO TO exit_script
 ENDIF
 IF (act_future_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Invalid code_value for cdf_meaning FUTURE in code_set 6004"
  GO TO exit_script
 ENDIF
 IF (act_incomplete_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Invalid code_value for cdf_meaning INCOMPLETE in code_set 6004"
  GO TO exit_script
 ENDIF
 IF (act_suspended_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Invalid code_value for cdf_meaning SUSPENDED in code_set 6004"
  GO TO exit_script
 ENDIF
 IF (act_med_student_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Invalid code_value for cdf_meaning MEDSTUDENT in code_set 6004"
  GO TO exit_script
 ENDIF
 IF (inact_discontinued_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Invalid code_value for cdf_meaning DISCONTINUED in code_set 6004"
  GO TO exit_script
 ENDIF
 IF (inact_canceled_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Invalid code_value for cdf_meaning CANCELED in code_set 6004"
  GO TO exit_script
 ENDIF
 IF (inact_completed_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Invalid code_value for cdf_meaning COMPLETED in code_set 6004"
  GO TO exit_script
 ENDIF
 IF (inact_pending_complete_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Invalid code_value for cdf_meaning PENDING in code_set 6004"
  GO TO exit_script
 ENDIF
 IF (inact_voided_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Invalid code_value for cdf_meaning DELETED in code_set 6004"
  GO TO exit_script
 ENDIF
 IF (inact_voided_wrslt_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Invalid code_value for cdf_meaning VOIDEDWRSLT in code_set 6004"
  GO TO exit_script
 ENDIF
 IF (inact_trans_cancel_cd < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Invalid code_value for cdf_meaning TRANS/CANCEL in code_set 6004"
  GO TO exit_script
 ENDIF
 IF (viewordr_val < 1)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Invalid code_value for cdf_meaning VIEWORDER in code_set 6016"
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Get View Order Privs By PRSNL")
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM priv_loc_reltn pl,
   privilege p,
   privilege_exception pe
  PLAN (pl
   WHERE pl.person_id=prsnl_person_id
    AND pl.location_cd=0.0)
   JOIN (p
   WHERE p.priv_loc_reltn_id=pl.priv_loc_reltn_id
    AND p.privilege_cd=viewordr_val)
   JOIN (pe
   WHERE pe.privilege_id=outerjoin(p.privilege_id))
  ORDER BY p.privilege_cd
  HEAD REPORT
   found_ordr = false
  HEAD p.privilege_cd
   IF (p.privilege_cd=viewordr_val
    AND found_ordr=false)
    stat = alterlist(ordr_exp->exception,10), ordr_exp->priv_value_cd = p.priv_value_cd, ordr_exp->
    priv_value_meaning = uar_get_code_meaning(p.priv_value_cd),
    ordr_cnt = 0, found_ordr = true, found_ordr_type = false
   ENDIF
  DETAIL
   IF (pe.privilege_exception_id > 0)
    IF (p.privilege_cd=viewordr_val
     AND found_ordr=true)
     ordr_cnt = (ordr_cnt+ 1)
     IF (mod(ordr_cnt,10)=1
      AND ordr_cnt != 1)
      stat = alterlist(ordr_exp->exception,(ordr_cnt+ 9))
     ENDIF
     ordr_exp->exception[ordr_cnt].exp_id = pe.exception_id
     IF (found_ordr_type=false)
      IF (cnvtupper(pe.exception_entity_name)="CATALOG TYPE")
       ordr_exp->exception_type_flag = 2, found_ordr_type = true
      ELSEIF (cnvtupper(pe.exception_entity_name)="ACTIVITY TYPE")
       ordr_exp->exception_type_flag = 1, found_ordr_type = true
      ELSEIF (cnvtupper(pe.exception_entity_name)="ORDER CATALOG")
       ordr_exp->exception_type_flag = 0, found_ordr_type = true
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT  p.privilege_cd
   IF (p.privilege_cd=viewordr_val
    AND found_ordr=true)
    ordr_exp->exception_cnt = ordr_cnt, stat = alterlist(ordr_exp->exception,ordr_cnt)
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "PRSNL_PRIVS"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(serrmsg)
  GO TO exit_script
 ENDIF
 IF (found_ordr=false)
  CALL echo("***")
  CALL echo("***   Get View Order Privs By Position")
  CALL echo("***")
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM prsnl p
   PLAN (p
    WHERE p.person_id=prsnl_person_id)
   DETAIL
    prsnl_pos_cd = p.position_cd
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "FIND_POS_CD"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(serrmsg)
   GO TO exit_script
  ENDIF
  IF (prsnl_pos_cd < 1)
   CALL echo("***")
   CALL echo(build("***   Unable to find position_cd for prsnl_person_id :",prsnl_person_id))
   CALL echo("***")
   GO TO end_get_privs
  ENDIF
  CALL echo("***")
  CALL echo(build("***   Load By PRSNL_POS_CD :",prsnl_pos_cd))
  CALL echo("***")
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM priv_loc_reltn pl,
    privilege p,
    privilege_exception pe
   PLAN (pl
    WHERE pl.position_cd=prsnl_pos_cd
     AND pl.location_cd=0.0)
    JOIN (p
    WHERE p.priv_loc_reltn_id=pl.priv_loc_reltn_id
     AND p.privilege_cd=viewordr_val)
    JOIN (pe
    WHERE pe.privilege_id=outerjoin(p.privilege_id))
   ORDER BY p.privilege_cd
   HEAD REPORT
    skip_ordr_chk = true
   HEAD p.privilege_cd
    IF (p.privilege_cd=viewordr_val
     AND found_ordr=false)
     stat = alterlist(ordr_exp->exception,10), ordr_exp->priv_value_cd = p.priv_value_cd, ordr_exp->
     priv_value_meaning = uar_get_code_meaning(p.priv_value_cd),
     ordr_cnt = 0, found_ordr = true, skip_ordr_chk = false,
     found_ordr_type = false
    ENDIF
   DETAIL
    IF (pe.privilege_exception_id > 0)
     IF (p.privilege_cd=viewordr_val
      AND found_ordr=true
      AND skip_ordr_chk=false)
      ordr_cnt = (ordr_cnt+ 1)
      IF (mod(ordr_cnt,10)=1
       AND ordr_cnt != 1)
       stat = alterlist(ordr_exp->exception,(ordr_cnt+ 9))
      ENDIF
      ordr_exp->exception[ordr_cnt].exp_id = pe.exception_id
      IF (found_ordr_type=false)
       IF (cnvtupper(pe.exception_entity_name)="CATALOG TYPE")
        ordr_exp->exception_type_flag = 2, found_ordr_type = true
       ELSEIF (cnvtupper(pe.exception_entity_name)="ACTIVITY TYPE")
        ordr_exp->exception_type_flag = 1, found_ordr_type = true
       ELSEIF (cnvtupper(pe.exception_entity_name)="ORDER CATALOG")
        ordr_exp->exception_type_flag = 0, found_ordr_type = true
       ENDIF
      ENDIF
     ENDIF
    ENDIF
   FOOT  p.privilege_cd
    IF (p.privilege_cd=viewordr_val
     AND found_ordr=true
     AND skip_ordr_chk=false)
     ordr_exp->exception_cnt = ordr_cnt, stat = alterlist(ordr_exp->exception,ordr_cnt)
    ENDIF
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "POS_PRIVS"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(serrmsg)
   GO TO exit_script
  ENDIF
 ENDIF
#end_get_privs
 CALL echo("***")
 CALL echo("***   Is Encntr/Org Security On")
 CALL echo("***")
 SET dminfo_ok = validate(ccldminfo->mode,false)
 IF (dminfo_ok=1)
  IF ((ccldminfo->sec_org_reltn=true))
   SET encntr_org_sec_on = true
  ENDIF
  IF ((ccldminfo->sec_confid=true))
   SET conf_security_on = true
  ENDIF
 ELSE
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  SELECT INTO "nl:"
   FROM dm_info di
   PLAN (di
    WHERE di.info_domain="SECURITY"
     AND di.info_name IN ("SEC_ORG_RELTN", "SEC_CONFID")
     AND di.info_number=1)
   HEAD REPORT
    encntr_org_sec_on = false, conf_security_on = false
   DETAIL
    IF (di.info_name="SEC_ORG_RELTN"
     AND di.info_number=1)
     encntr_org_sec_on = true
    ELSEIF (di.info_name="PERSON_ORG_SEC")
     conf_security_on = true
    ENDIF
   WITH nocounter
  ;end select
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET failed = select_error
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "DM_INFO"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(serrmsg)
   GO TO exit_script
  ENDIF
 ENDIF
 IF (conf_security_on=true
  AND encntr_org_sec_on=false)
  SET encntr_org_sec_on = true
 ENDIF
 EXECUTE dcp_gen_valid_encounters_recs
 IF (encntr_org_sec_on=false)
  GO TO skip_get_encntr_list
 ENDIF
 SET gve_request->prsnl_id = prsnl_person_id
 SET stat = alterlist(gve_request->persons,1)
 SET gve_request->persons[1].person_id = patient_person_id
 EXECUTE dcp_get_valid_encounters  WITH replace("REQUEST","GVE_REQUEST"), replace("REPLY","GVE_REPLY"
  )
 CALL echo("***")
 CALL echo(build("***    status       :",gve_reply->status_data.status))
 CALL echo(build("***    restrict_ind :",gve_reply->restrict_ind))
 CALL echo(build("***    data_cnt     :",size(gve_reply->persons[1].encntrs,5)))
 CALL echo("***")
 IF ((gve_reply->status_data.status="F"))
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "SECURITY"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = gve_reply->status_data.subeventstatus[
  1].targetobjectvalue
  GO TO exit_script
 ENDIF
 SET elist_size = size(gve_reply->persons[1].encntrs,5)
#skip_get_encntr_list
 CALL echo("***")
 CALL echo("***   Get Active Orders")
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = error(serrmsg,0)
 SELECT INTO "nl:"
  sort_var = cnvtupper(cnvtalphanum(o.hna_order_mnemonic))
  FROM orders o
  PLAN (o
   WHERE o.person_id=patient_person_id
    AND ((o.order_status_cd+ 0) IN (act_ordered_cd, act_future_cd, act_in_process_cd,
   act_incomplete_cd, act_med_student_cd,
   act_suspended_cd))
    AND o.catalog_type_cd=pharmacy_type_cd
    AND ((o.template_order_flag+ 0) IN (0, 1)))
  ORDER BY sort_var
  HEAD REPORT
   ocnt = 0, stat = alterlist(med_list->ordered_med,10), ipcnt = 0,
   stat = alterlist(med_list->inprocess_med,10), fcnt = 0, stat = alterlist(med_list->future_med,10),
   pcnt = 0, stat = alterlist(med_list->prescribed_med,10), dcnt = 0,
   stat = alterlist(med_list->documented_med,10), iccnt = 0, stat = alterlist(med_list->
    incomplete_med,10),
   scnt = 0, stat = alterlist(med_list->suspended_med,10), mscnt = 0,
   stat = alterlist(med_list->medstudent_med,10), found_ordered_viewable = false,
   found_inprocess_viewable = false,
   found_future_viewable = false, found_prescribed_viewable = false, found_documented_viewable =
   false,
   found_incomplete_viewable = false, found_suspended_viewable = false, found_medstudent_viewable =
   false,
   found_active_viewable = false
  DETAIL
   IF (o.order_status_cd=act_ordered_cd)
    IF (o.orig_ord_as_flag=2)
     dcnt = (dcnt+ 1)
     IF (mod(dcnt,10)=1
      AND dcnt != 1)
      stat = alterlist(med_list->documented_med,(dcnt+ 9))
     ENDIF
     med_list->documented_med[dcnt].activity_type_cd = o.activity_type_cd, med_list->documented_med[
     dcnt].catalog_type_cd = o.catalog_type_cd, med_list->documented_med[dcnt].catalog_cd = o
     .catalog_cd,
     med_list->documented_med[dcnt].order_id = o.order_id, med_list->documented_med[dcnt].encntr_id
      = o.encntr_id, med_list->documented_med[dcnt].order_status_disp = documented_order_status_disp
     IF (o.simplified_display_line != null
      AND o.simplified_display_line > " ")
      med_list->documented_med[dcnt].med_line = concat(trim(o.hna_order_mnemonic),": ",trim(o
        .simplified_display_line),".")
     ELSE
      med_list->documented_med[dcnt].med_line = concat(trim(o.hna_order_mnemonic),": ",trim(o
        .clinical_display_line),".")
     ENDIF
     IF (encntr_org_sec_on=false)
      med_list->documented_med[dcnt].viewable_ind = true
     ELSE
      fpos = 0, lnum = 0, fpos = locateval(lnum,1,elist_size,o.encntr_id,gve_reply->persons[1].
       encntrs[lnum].encntr_id)
      IF (fpos > 0)
       med_list->documented_med[dcnt].viewable_ind = true
      ENDIF
     ENDIF
     IF ((med_list->documented_med[dcnt].viewable_ind=true))
      IF ((ordr_exp->priv_value_meaning="NO"))
       med_list->documented_med[dcnt].viewable_ind = false
      ELSEIF ((ordr_exp->priv_value_meaning="INCLUDE"))
       med_list->documented_med[dcnt].viewable_ind = false, fpos = 0, lnum = 0
       IF ((ordr_exp->exception_cnt > 0))
        IF ((ordr_exp->exception_type_flag=0))
         fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_cd,ordr_exp->exception[lnum].
          exp_id)
        ELSEIF ((ordr_exp->exception_type_flag=1))
         fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.activity_type_cd,ordr_exp->exception[lnum]
          .exp_id)
        ELSE
         fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_type_cd,ordr_exp->exception[lnum].
          exp_id)
        ENDIF
       ENDIF
       IF (fpos > 0)
        med_list->documented_med[dcnt].viewable_ind = true
       ENDIF
      ELSEIF ((ordr_exp->priv_value_meaning="EXCLUDE"))
       med_list->documented_med[dcnt].viewable_ind = true, fpos = 0, lnum = 0
       IF ((ordr_exp->exception_cnt > 0))
        IF ((ordr_exp->exception_type_flag=0))
         fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_cd,ordr_exp->exception[lnum].
          exp_id)
        ELSEIF ((ordr_exp->exception_type_flag=1))
         fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.activity_type_cd,ordr_exp->exception[lnum]
          .exp_id)
        ELSE
         fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_type_cd,ordr_exp->exception[lnum].
          exp_id)
        ENDIF
       ENDIF
       IF (fpos > 0)
        med_list->documented_med[dcnt].viewable_ind = false
       ENDIF
      ENDIF
     ENDIF
     IF ((med_list->documented_med[dcnt].viewable_ind=true))
      found_documented_viewable = true
     ENDIF
    ELSEIF (o.orig_ord_as_flag=1)
     pcnt = (pcnt+ 1)
     IF (mod(pcnt,10)=1
      AND pcnt != 1)
      stat = alterlist(med_list->prescribed_med,(pcnt+ 9))
     ENDIF
     med_list->prescribed_med[pcnt].activity_type_cd = o.activity_type_cd, med_list->prescribed_med[
     pcnt].catalog_type_cd = o.catalog_type_cd, med_list->prescribed_med[pcnt].catalog_cd = o
     .catalog_cd,
     med_list->prescribed_med[pcnt].order_id = o.order_id, med_list->prescribed_med[pcnt].encntr_id
      = o.encntr_id, med_list->prescribed_med[pcnt].order_status_disp = prescribed_order_status_disp
     IF (o.simplified_display_line != null
      AND o.simplified_display_line > " ")
      med_list->prescribed_med[pcnt].med_line = concat(trim(o.hna_order_mnemonic),": ",trim(o
        .simplified_display_line),".")
     ELSE
      med_list->prescribed_med[pcnt].med_line = concat(trim(o.hna_order_mnemonic),": ",trim(o
        .clinical_display_line),".")
     ENDIF
     IF (encntr_org_sec_on=false)
      med_list->prescribed_med[pcnt].viewable_ind = true
     ELSE
      fpos = 0, lnum = 0, fpos = locateval(lnum,1,elist_size,o.encntr_id,gve_reply->persons[1].
       encntrs[lnum].encntr_id)
      IF (fpos > 0)
       med_list->prescribed_med[pcnt].viewable_ind = true
      ENDIF
     ENDIF
     IF ((med_list->prescribed_med[pcnt].viewable_ind=true))
      IF ((ordr_exp->priv_value_meaning="NO"))
       med_list->prescribed_med[pcnt].viewable_ind = false
      ELSEIF ((ordr_exp->priv_value_meaning="INCLUDE"))
       med_list->prescribed_med[pcnt].viewable_ind = false, fpos = 0, lnum = 0
       IF ((ordr_exp->exception_cnt > 0))
        IF ((ordr_exp->exception_type_flag=0))
         fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_cd,ordr_exp->exception[lnum].
          exp_id)
        ELSEIF ((ordr_exp->exception_type_flag=1))
         fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.activity_type_cd,ordr_exp->exception[lnum]
          .exp_id)
        ELSE
         fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_type_cd,ordr_exp->exception[lnum].
          exp_id)
        ENDIF
       ENDIF
       IF (fpos > 0)
        med_list->prescribed_med[pcnt].viewable_ind = true
       ENDIF
      ELSEIF ((ordr_exp->priv_value_meaning="EXCLUDE"))
       med_list->prescribed_med[pcnt].viewable_ind = true, fpos = 0, lnum = 0
       IF ((ordr_exp->exception_cnt > 0))
        IF ((ordr_exp->exception_type_flag=0))
         fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_cd,ordr_exp->exception[lnum].
          exp_id)
        ELSEIF ((ordr_exp->exception_type_flag=1))
         fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.activity_type_cd,ordr_exp->exception[lnum]
          .exp_id)
        ELSE
         fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_type_cd,ordr_exp->exception[lnum].
          exp_id)
        ENDIF
       ENDIF
       IF (fpos > 0)
        med_list->prescribed_med[pcnt].viewable_ind = false
       ENDIF
      ENDIF
     ENDIF
     IF ((med_list->prescribed_med[pcnt].viewable_ind=true))
      found_prescribed_viewable = true
     ENDIF
    ELSE
     ocnt = (ocnt+ 1)
     IF (mod(ocnt,10)=1
      AND ocnt != 1)
      stat = alterlist(med_list->ordered_med,(ocnt+ 9))
     ENDIF
     med_list->ordered_med[ocnt].activity_type_cd = o.activity_type_cd, med_list->ordered_med[ocnt].
     catalog_type_cd = o.catalog_type_cd, med_list->ordered_med[ocnt].catalog_cd = o.catalog_cd,
     med_list->ordered_med[ocnt].order_id = o.order_id, med_list->ordered_med[ocnt].encntr_id = o
     .encntr_id, med_list->ordered_med[ocnt].order_status_disp = uar_get_code_display(o
      .order_status_cd)
     IF (o.simplified_display_line != null
      AND o.simplified_display_line > " ")
      med_list->ordered_med[ocnt].med_line = concat(trim(o.hna_order_mnemonic),": ",trim(o
        .simplified_display_line),".")
     ELSE
      med_list->ordered_med[ocnt].med_line = concat(trim(o.hna_order_mnemonic),": ",trim(o
        .clinical_display_line),".")
     ENDIF
     IF (encntr_org_sec_on=false)
      med_list->ordered_med[ocnt].viewable_ind = true
     ELSE
      fpos = 0, lnum = 0, fpos = locateval(lnum,1,elist_size,o.encntr_id,gve_reply->persons[1].
       encntrs[lnum].encntr_id)
      IF (fpos > 0)
       med_list->ordered_med[ocnt].viewable_ind = true
      ENDIF
     ENDIF
     IF ((med_list->ordered_med[ocnt].viewable_ind=true))
      IF ((ordr_exp->priv_value_meaning="NO"))
       med_list->ordered_med[ocnt].viewable_ind = false
      ELSEIF ((ordr_exp->priv_value_meaning="INCLUDE"))
       med_list->ordered_med[ocnt].viewable_ind = false, fpos = 0, lnum = 0
       IF ((ordr_exp->exception_cnt > 0))
        IF ((ordr_exp->exception_type_flag=0))
         fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_cd,ordr_exp->exception[lnum].
          exp_id)
        ELSEIF ((ordr_exp->exception_type_flag=1))
         fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.activity_type_cd,ordr_exp->exception[lnum]
          .exp_id)
        ELSE
         fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_type_cd,ordr_exp->exception[lnum].
          exp_id)
        ENDIF
       ENDIF
       IF (fpos > 0)
        med_list->ordered_med[ocnt].viewable_ind = true
       ENDIF
      ELSEIF ((ordr_exp->priv_value_meaning="EXCLUDE"))
       med_list->ordered_med[ocnt].viewable_ind = true, fpos = 0, lnum = 0
       IF ((ordr_exp->exception_cnt > 0))
        IF ((ordr_exp->exception_type_flag=0))
         fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_cd,ordr_exp->exception[lnum].
          exp_id)
        ELSEIF ((ordr_exp->exception_type_flag=1))
         fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.activity_type_cd,ordr_exp->exception[lnum]
          .exp_id)
        ELSE
         fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_type_cd,ordr_exp->exception[lnum].
          exp_id)
        ENDIF
       ENDIF
       IF (fpos > 0)
        med_list->ordered_med[ocnt].viewable_ind = false
       ENDIF
      ENDIF
     ENDIF
     IF ((med_list->ordered_med[ocnt].viewable_ind=true))
      found_ordered_viewable = true
     ENDIF
    ENDIF
   ELSEIF (o.order_status_cd=act_in_process_cd)
    ipcnt = (ipcnt+ 1)
    IF (mod(ipcnt,10)=1
     AND ipcnt != 1)
     stat = alterlist(med_list->inprocess_med,(ipcnt+ 9))
    ENDIF
    med_list->inprocess_med[ipcnt].activity_type_cd = o.activity_type_cd, med_list->inprocess_med[
    ipcnt].catalog_type_cd = o.catalog_type_cd, med_list->inprocess_med[ipcnt].catalog_cd = o
    .catalog_cd,
    med_list->inprocess_med[ipcnt].order_id = o.order_id, med_list->inprocess_med[ipcnt].encntr_id =
    o.encntr_id, med_list->inprocess_med[ipcnt].order_status_disp = uar_get_code_display(o
     .order_status_cd)
    IF (o.simplified_display_line != null
     AND o.simplified_display_line > " ")
     med_list->inprocess_med[ipcnt].med_line = concat(trim(o.hna_order_mnemonic),": ",trim(o
       .simplified_display_line),".")
    ELSE
     med_list->inprocess_med[ipcnt].med_line = concat(trim(o.hna_order_mnemonic),": ",trim(o
       .clinical_display_line),".")
    ENDIF
    IF (encntr_org_sec_on=false)
     med_list->inprocess_med[ipcnt].viewable_ind = true
    ELSE
     fpos = 0, fpos = locateval(lnum,1,elist_size,o.encntr_id,gve_reply->persons[1].encntrs[lnum].
      encntr_id)
     IF (fpos > 0)
      med_list->inprocess_med[ipcnt].viewable_ind = true
     ENDIF
    ENDIF
    IF ((med_list->inprocess_med[ipcnt].viewable_ind=true))
     IF ((ordr_exp->priv_value_meaning="NO"))
      med_list->inprocess_med[ipcnt].viewable_ind = false
     ELSEIF ((ordr_exp->priv_value_meaning="INCLUDE"))
      med_list->inprocess_med[ipcnt].viewable_ind = false, fpos = 0
      IF ((ordr_exp->exception_cnt > 0))
       IF ((ordr_exp->exception_type_flag=0))
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_cd,ordr_exp->exception[lnum].exp_id
         )
       ELSEIF ((ordr_exp->exception_type_flag=1))
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.activity_type_cd,ordr_exp->exception[lnum].
         exp_id)
       ELSE
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_type_cd,ordr_exp->exception[lnum].
         exp_id)
       ENDIF
      ENDIF
      IF (fpos > 0)
       med_list->inprocess_med[ipcnt].viewable_ind = true
      ENDIF
     ELSEIF ((ordr_exp->priv_value_meaning="EXCLUDE"))
      med_list->inprocess_med[ipcnt].viewable_ind = true, fpos = 0
      IF ((ordr_exp->exception_cnt > 0))
       IF ((ordr_exp->exception_type_flag=0))
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_cd,ordr_exp->exception[lnum].exp_id
         )
       ELSEIF ((ordr_exp->exception_type_flag=1))
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.activity_type_cd,ordr_exp->exception[lnum].
         exp_id)
       ELSE
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_type_cd,ordr_exp->exception[lnum].
         exp_id)
       ENDIF
      ENDIF
      IF (fpos > 0)
       med_list->inprocess_med[ipcnt].viewable_ind = false
      ENDIF
     ENDIF
    ENDIF
    IF ((med_list->inprocess_med[ipcnt].viewable_ind=true))
     found_inprocess_viewable = true
    ENDIF
   ELSEIF (o.order_status_cd=act_future_cd)
    fcnt = (fcnt+ 1)
    IF (mod(fcnt,10)=1
     AND fcnt != 1)
     stat = alterlist(med_list->future_med,(fcnt+ 9))
    ENDIF
    med_list->future_med[fcnt].activity_type_cd = o.activity_type_cd, med_list->future_med[fcnt].
    catalog_type_cd = o.catalog_type_cd, med_list->future_med[fcnt].catalog_cd = o.catalog_cd,
    med_list->future_med[fcnt].order_id = o.order_id, med_list->future_med[fcnt].encntr_id = o
    .encntr_id, med_list->future_med[fcnt].order_status_disp = uar_get_code_display(o.order_status_cd
     )
    IF (o.simplified_display_line != null
     AND o.simplified_display_line > " ")
     med_list->future_med[fcnt].med_line = concat(trim(o.hna_order_mnemonic),": ",trim(o
       .simplified_display_line),".")
    ELSE
     med_list->future_med[fcnt].med_line = concat(trim(o.hna_order_mnemonic),": ",trim(o
       .clinical_display_line),".")
    ENDIF
    IF (encntr_org_sec_on=false)
     med_list->future_med[fcnt].viewable_ind = true
    ELSE
     fpos = 0, fpos = locateval(lnum,1,elist_size,o.encntr_id,gve_reply->persons[1].encntrs[lnum].
      encntr_id)
     IF (fpos > 0)
      med_list->future_med[fcnt].viewable_ind = true
     ENDIF
    ENDIF
    IF ((med_list->future_med[fcnt].viewable_ind=true))
     IF ((ordr_exp->priv_value_meaning="NO"))
      med_list->future_med[fcnt].viewable_ind = false
     ELSEIF ((ordr_exp->priv_value_meaning="INCLUDE"))
      med_list->future_med[fcnt].viewable_ind = false, fpos = 0
      IF ((ordr_exp->exception_cnt > 0))
       IF ((ordr_exp->exception_type_flag=0))
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_cd,ordr_exp->exception[lnum].exp_id
         )
       ELSEIF ((ordr_exp->exception_type_flag=1))
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.activity_type_cd,ordr_exp->exception[lnum].
         exp_id)
       ELSE
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_type_cd,ordr_exp->exception[lnum].
         exp_id)
       ENDIF
      ENDIF
      IF (fpos > 0)
       med_list->future_med[fcnt].viewable_ind = true
      ENDIF
     ELSEIF ((ordr_exp->priv_value_meaning="EXCLUDE"))
      med_list->future_med[fcnt].viewable_ind = true, fpos = 0
      IF ((ordr_exp->exception_cnt > 0))
       IF ((ordr_exp->exception_type_flag=0))
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_cd,ordr_exp->exception[lnum].exp_id
         )
       ELSEIF ((ordr_exp->exception_type_flag=1))
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.activity_type_cd,ordr_exp->exception[lnum].
         exp_id)
       ELSE
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_type_cd,ordr_exp->exception[lnum].
         exp_id)
       ENDIF
      ENDIF
      IF (fpos > 0)
       med_list->future_med[fcnt].viewable_ind = false
      ENDIF
     ENDIF
    ENDIF
    IF ((med_list->future_med[fcnt].viewable_ind=true))
     found_future_viewable = true
    ENDIF
   ELSEIF (o.order_status_cd=act_incomplete_cd)
    iccnt = (iccnt+ 1)
    IF (mod(iccnt,10)=1
     AND iccnt != 1)
     stat = alterlist(med_list->incomplete_med,(iccnt+ 9))
    ENDIF
    med_list->incomplete_med[iccnt].activity_type_cd = o.activity_type_cd, med_list->incomplete_med[
    iccnt].catalog_type_cd = o.catalog_type_cd, med_list->incomplete_med[iccnt].catalog_cd = o
    .catalog_cd,
    med_list->incomplete_med[iccnt].order_id = o.order_id, med_list->incomplete_med[iccnt].encntr_id
     = o.encntr_id, med_list->incomplete_med[iccnt].order_status_disp = uar_get_code_display(o
     .order_status_cd)
    IF (o.simplified_display_line != null
     AND o.simplified_display_line > " ")
     med_list->incomplete_med[iccnt].med_line = concat(trim(o.hna_order_mnemonic),": ",trim(o
       .simplified_display_line),".")
    ELSE
     med_list->incomplete_med[iccnt].med_line = concat(trim(o.hna_order_mnemonic),": ",trim(o
       .clinical_display_line),".")
    ENDIF
    IF (encntr_org_sec_on=false)
     med_list->incomplete_med[iccnt].viewable_ind = true
    ELSE
     fpos = 0, fpos = locateval(lnum,1,elist_size,o.encntr_id,gve_reply->persons[1].encntrs[lnum].
      encntr_id)
     IF (fpos > 0)
      med_list->incomplete_med[iccnt].viewable_ind = true
     ENDIF
    ENDIF
    IF ((med_list->incomplete_med[iccnt].viewable_ind=true))
     IF ((ordr_exp->priv_value_meaning="NO"))
      med_list->incomplete_med[iccnt].viewable_ind = false
     ELSEIF ((ordr_exp->priv_value_meaning="INCLUDE"))
      med_list->incomplete_med[iccnt].viewable_ind = false, fpos = 0
      IF ((ordr_exp->exception_cnt > 0))
       IF ((ordr_exp->exception_type_flag=0))
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_cd,ordr_exp->exception[lnum].exp_id
         )
       ELSEIF ((ordr_exp->exception_type_flag=1))
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.activity_type_cd,ordr_exp->exception[lnum].
         exp_id)
       ELSE
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_type_cd,ordr_exp->exception[lnum].
         exp_id)
       ENDIF
      ENDIF
      IF (fpos > 0)
       med_list->incomplete_med[iccnt].viewable_ind = true
      ENDIF
     ELSEIF ((ordr_exp->priv_value_meaning="EXCLUDE"))
      med_list->incomplete_med[iccnt].viewable_ind = true, fpos = 0
      IF ((ordr_exp->exception_cnt > 0))
       IF ((ordr_exp->exception_type_flag=0))
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_cd,ordr_exp->exception[lnum].exp_id
         )
       ELSEIF ((ordr_exp->exception_type_flag=1))
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.activity_type_cd,ordr_exp->exception[lnum].
         exp_id)
       ELSE
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_type_cd,ordr_exp->exception[lnum].
         exp_id)
       ENDIF
      ENDIF
      IF (fpos > 0)
       med_list->incomplete_med[iccnt].viewable_ind = false
      ENDIF
     ENDIF
    ENDIF
    IF ((med_list->incomplete_med[iccnt].viewable_ind=true))
     found_incomplete_viewable = true
    ENDIF
   ELSEIF (o.order_status_cd=act_suspended_cd)
    scnt = (scnt+ 1)
    IF (mod(scnt,10)=1
     AND scnt != 1)
     stat = alterlist(med_list->suspended_med,(scnt+ 9))
    ENDIF
    med_list->suspended_med[scnt].activity_type_cd = o.activity_type_cd, med_list->suspended_med[scnt
    ].catalog_type_cd = o.catalog_type_cd, med_list->suspended_med[scnt].catalog_cd = o.catalog_cd,
    med_list->suspended_med[scnt].order_id = o.order_id, med_list->suspended_med[scnt].encntr_id = o
    .encntr_id, med_list->suspended_med[scnt].order_status_disp = uar_get_code_display(o
     .order_status_cd)
    IF (o.simplified_display_line != null
     AND o.simplified_display_line > " ")
     med_list->suspended_med[scnt].med_line = concat(trim(o.hna_order_mnemonic),": ",trim(o
       .simplified_display_line),".")
    ELSE
     med_list->suspended_med[scnt].med_line = concat(trim(o.hna_order_mnemonic),": ",trim(o
       .clinical_display_line),".")
    ENDIF
    IF (encntr_org_sec_on=false)
     med_list->suspended_med[scnt].viewable_ind = true
    ELSE
     fpos = 0, fpos = locateval(lnum,1,elist_size,o.encntr_id,gve_reply->persons[1].encntrs[lnum].
      encntr_id)
     IF (fpos > 0)
      med_list->suspended_med[scnt].viewable_ind = true
     ENDIF
    ENDIF
    IF ((med_list->suspended_med[scnt].viewable_ind=true))
     IF ((ordr_exp->priv_value_meaning="NO"))
      med_list->suspended_med[scnt].viewable_ind = false
     ELSEIF ((ordr_exp->priv_value_meaning="INCLUDE"))
      med_list->suspended_med[scnt].viewable_ind = false, fpos = 0
      IF ((ordr_exp->exception_cnt > 0))
       IF ((ordr_exp->exception_type_flag=0))
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_cd,ordr_exp->exception[lnum].exp_id
         )
       ELSEIF ((ordr_exp->exception_type_flag=1))
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.activity_type_cd,ordr_exp->exception[lnum].
         exp_id)
       ELSE
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_type_cd,ordr_exp->exception[lnum].
         exp_id)
       ENDIF
      ENDIF
      IF (fpos > 0)
       med_list->suspended_med[scnt].viewable_ind = true
      ENDIF
     ELSEIF ((ordr_exp->priv_value_meaning="EXCLUDE"))
      med_list->suspended_med[scnt].viewable_ind = true, fpos = 0
      IF ((ordr_exp->exception_cnt > 0))
       IF ((ordr_exp->exception_type_flag=0))
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_cd,ordr_exp->exception[lnum].exp_id
         )
       ELSEIF ((ordr_exp->exception_type_flag=1))
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.activity_type_cd,ordr_exp->exception[lnum].
         exp_id)
       ELSE
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_type_cd,ordr_exp->exception[lnum].
         exp_id)
       ENDIF
      ENDIF
      IF (fpos > 0)
       med_list->suspended_med[scnt].viewable_ind = false
      ENDIF
     ENDIF
    ENDIF
    IF ((med_list->suspended_med[scnt].viewable_ind=true))
     found_suspended_viewable = true
    ENDIF
   ELSEIF (o.order_status_cd=act_med_student_cd)
    mscnt = (mscnt+ 1)
    IF (mod(mscnt,10)=1
     AND mscnt != 1)
     stat = alterlist(med_list->medstudent_med,(mscnt+ 9))
    ENDIF
    med_list->medstudent_med[mscnt].activity_type_cd = o.activity_type_cd, med_list->medstudent_med[
    mscnt].catalog_type_cd = o.catalog_type_cd, med_list->medstudent_med[mscnt].catalog_cd = o
    .catalog_cd,
    med_list->medstudent_med[mscnt].order_id = o.order_id, med_list->medstudent_med[mscnt].encntr_id
     = o.encntr_id, med_list->medstudent_med[mscnt].order_status_disp = uar_get_code_display(o
     .order_status_cd)
    IF (o.simplified_display_line != null
     AND o.simplified_display_line > " ")
     med_list->medstudent_med[mscnt].med_line = concat(trim(o.hna_order_mnemonic),": ",trim(o
       .simplified_display_line),".")
    ELSE
     med_list->medstudent_med[mscnt].med_line = concat(trim(o.hna_order_mnemonic),": ",trim(o
       .clinical_display_line),".")
    ENDIF
    IF (encntr_org_sec_on=false)
     med_list->medstudent_med[mscnt].viewable_ind = true
    ELSE
     fpos = 0, fpos = locateval(lnum,1,elist_size,o.encntr_id,gve_reply->persons[1].encntrs[lnum].
      encntr_id)
     IF (fpos > 0)
      med_list->medstudent_med[mscnt].viewable_ind = true
     ENDIF
    ENDIF
    IF ((med_list->medstudent_med[mscnt].viewable_ind=true))
     IF ((ordr_exp->priv_value_meaning="NO"))
      med_list->medstudent_med[mscnt].viewable_ind = false
     ELSEIF ((ordr_exp->priv_value_meaning="INCLUDE"))
      med_list->medstudent_med[mscnt].viewable_ind = false, fpos = 0
      IF ((ordr_exp->exception_cnt > 0))
       IF ((ordr_exp->exception_type_flag=0))
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_cd,ordr_exp->exception[lnum].exp_id
         )
       ELSEIF ((ordr_exp->exception_type_flag=1))
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.activity_type_cd,ordr_exp->exception[lnum].
         exp_id)
       ELSE
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_type_cd,ordr_exp->exception[lnum].
         exp_id)
       ENDIF
      ENDIF
      IF (fpos > 0)
       med_list->medstudent_med[mscnt].viewable_ind = true
      ENDIF
     ELSEIF ((ordr_exp->priv_value_meaning="EXCLUDE"))
      med_list->medstudent_med[mscnt].viewable_ind = true, fpos = 0
      IF ((ordr_exp->exception_cnt > 0))
       IF ((ordr_exp->exception_type_flag=0))
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_cd,ordr_exp->exception[lnum].exp_id
         )
       ELSEIF ((ordr_exp->exception_type_flag=1))
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.activity_type_cd,ordr_exp->exception[lnum].
         exp_id)
       ELSE
        fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_type_cd,ordr_exp->exception[lnum].
         exp_id)
       ENDIF
      ENDIF
      IF (fpos > 0)
       med_list->medstudent_med[mscnt].viewable_ind = false
      ENDIF
     ENDIF
    ENDIF
    IF ((med_list->medstudent_med[mscnt].viewable_ind=true))
     found_medstudent_viewable = true
    ENDIF
   ENDIF
  FOOT REPORT
   med_list->ordered_med_cnt = ocnt, stat = alterlist(med_list->ordered_med,ocnt), med_list->
   inprocess_med_cnt = ipcnt,
   stat = alterlist(med_list->inprocess_med,ipcnt), med_list->future_med_cnt = fcnt, stat = alterlist
   (med_list->future_med,fcnt),
   med_list->documented_med_cnt = dcnt, stat = alterlist(med_list->documented_med,dcnt), med_list->
   prescribed_med_cnt = pcnt,
   stat = alterlist(med_list->prescribed_med,pcnt), med_list->incomplete_med_cnt = iccnt, stat =
   alterlist(med_list->incomplete_med,iccnt),
   med_list->suspended_med_cnt = scnt, stat = alterlist(med_list->suspended_med,scnt), med_list->
   medstudent_med_cnt = mscnt,
   stat = alterlist(med_list->medstudent_med,mscnt)
   IF (((found_ordered_viewable=true) OR (((found_inprocess_viewable=true) OR (((
   found_future_viewable=true) OR (((found_documented_viewable=true) OR (((found_prescribed_viewable=
   true) OR (((found_incomplete_viewable=true) OR (((found_suspended_viewable=true) OR (
   found_medstudent_viewable=true)) )) )) )) )) )) )) )
    found_active_viewable = true
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ACTIVE ORDERS"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(serrmsg)
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Get Inactive Orders")
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = error(serrmsg,0)
 SELECT INTO "nl:"
  sort_var = cnvtupper(cnvtalphanum(o.hna_order_mnemonic))
  FROM orders o
  PLAN (o
   WHERE o.person_id=patient_person_id
    AND ((o.order_status_cd+ 0) IN (inact_canceled_cd, inact_completed_cd, inact_discontinued_cd,
   inact_pending_complete_cd, inact_trans_cancel_cd,
   inact_voided_cd, inact_voided_wrslt_cd))
    AND o.catalog_type_cd=pharmacy_type_cd
    AND o.status_dt_tm >= cnvtdatetime(inact->date_dt_tm)
    AND ((o.template_order_flag+ 0) IN (0, 1)))
  ORDER BY sort_var
  HEAD REPORT
   cnt = 0, stat = alterlist(med_list->inact_med,10)
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1
    AND cnt != 1)
    stat = alterlist(med_list->inact_med,(cnt+ 9))
   ENDIF
   med_list->inact_med[cnt].activity_type_cd = o.activity_type_cd, med_list->inact_med[cnt].
   catalog_type_cd = o.catalog_type_cd, med_list->inact_med[cnt].catalog_cd = o.catalog_cd,
   med_list->inact_med[cnt].order_id = o.order_id, med_list->inact_med[cnt].encntr_id = o.encntr_id
   IF (o.simplified_display_line != null
    AND o.simplified_display_line > " ")
    med_list->inact_med[cnt].med_line = concat(trim(o.hna_order_mnemonic),": ",trim(o
      .simplified_display_line),".")
   ELSE
    med_list->inact_med[cnt].med_line = concat(trim(o.hna_order_mnemonic),": ",trim(o
      .clinical_display_line),".")
   ENDIF
   IF (encntr_org_sec_on=false)
    med_list->inact_med[cnt].viewable_ind = true
   ELSE
    fpos = 0, fpos = locateval(lnum,1,elist_size,o.encntr_id,gve_reply->persons[1].encntrs[lnum].
     encntr_id)
    IF (fpos > 0)
     med_list->inact_med[cnt].viewable_ind = true
    ENDIF
   ENDIF
   IF ((med_list->inact_med[cnt].viewable_ind=true))
    IF ((ordr_exp->priv_value_meaning="NO"))
     med_list->inact_med[cnt].viewable_ind = false
    ELSEIF ((ordr_exp->priv_value_meaning="INCLUDE"))
     med_list->inact_med[cnt].viewable_ind = false, fpos = 0
     IF ((ordr_exp->exception_cnt > 0))
      IF ((ordr_exp->exception_type_flag=0))
       fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_cd,ordr_exp->exception[lnum].exp_id)
      ELSEIF ((ordr_exp->exception_type_flag=1))
       fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.activity_type_cd,ordr_exp->exception[lnum].
        exp_id)
      ELSE
       fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_type_cd,ordr_exp->exception[lnum].
        exp_id)
      ENDIF
     ENDIF
     IF (fpos > 0)
      med_list->inact_med[cnt].viewable_ind = true
     ENDIF
    ELSEIF ((ordr_exp->priv_value_meaning="EXCLUDE"))
     med_list->inact_med[cnt].viewable_ind = true, fpos = 0
     IF ((ordr_exp->exception_cnt > 0))
      IF ((ordr_exp->exception_type_flag=0))
       fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_cd,ordr_exp->exception[lnum].exp_id)
      ELSEIF ((ordr_exp->exception_type_flag=1))
       fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.activity_type_cd,ordr_exp->exception[lnum].
        exp_id)
      ELSE
       fpos = locateval(lnum,1,ordr_exp->exception_cnt,o.catalog_type_cd,ordr_exp->exception[lnum].
        exp_id)
      ENDIF
     ENDIF
     IF (fpos > 0)
      med_list->inact_med[cnt].viewable_ind = false
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   med_list->inact_med_cnt = cnt, stat = alterlist(med_list->inact_med,cnt)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "INACTIVE ORDERS"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(serrmsg)
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo("***   Build Reply")
 CALL echo("***")
 SET reply->text = concat(rtf_rhead,rtf_wb,1_blank,"Medication List",rtf_eol)
 SET reply->text = concat(reply->text,rtf_wb,4_blank,"Active Medications",rtf_eol)
 IF (found_active_viewable=true)
  IF ((med_list->ordered_med_cnt > 0)
   AND found_ordered_viewable=true)
   SET reply->text = concat(reply->text,8_blank,rtf_wu,1_blank,trim(med_list->ordered_med[1].
     order_status_disp),
    rtf_eol)
   SET add_cnt = 0
   FOR (idx = 1 TO med_list->ordered_med_cnt)
     IF ((med_list->ordered_med[idx].viewable_ind=true))
      SET add_cnt = (add_cnt+ 1)
      SET pt->line_cnt = 0
      SET max_length = 70
      EXECUTE dcp_parse_text value(med_list->ordered_med[idx].med_line), value(max_length)
      FOR (jdx = 1 TO pt->line_cnt)
        IF (jdx=1)
         SET reply->text = concat(reply->text,rtf_wr,12_blank,trim(pt->lns[jdx].line),rtf_eol)
        ELSE
         SET reply->text = concat(reply->text,rtf_wr,14_blank,trim(pt->lns[jdx].line),rtf_eol)
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
  ENDIF
  IF ((med_list->prescribed_med_cnt > 0)
   AND found_prescribed_viewable=true)
   SET reply->text = concat(reply->text,8_blank,rtf_wu,1_blank,trim(med_list->prescribed_med[1].
     order_status_disp),
    rtf_eol)
   SET add_cnt = 0
   FOR (idx = 1 TO med_list->prescribed_med_cnt)
     IF ((med_list->prescribed_med[idx].viewable_ind=true))
      SET add_cnt = (add_cnt+ 1)
      SET pt->line_cnt = 0
      SET max_length = 70
      EXECUTE dcp_parse_text value(med_list->prescribed_med[idx].med_line), value(max_length)
      FOR (jdx = 1 TO pt->line_cnt)
        IF (jdx=1)
         SET reply->text = concat(reply->text,rtf_wr,12_blank,trim(pt->lns[jdx].line),rtf_eol)
        ELSE
         SET reply->text = concat(reply->text,rtf_wr,14_blank,trim(pt->lns[jdx].line),rtf_eol)
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
  ENDIF
  IF ((med_list->documented_med_cnt > 0)
   AND found_documented_viewable=true)
   SET reply->text = concat(reply->text,8_blank,rtf_wu,1_blank,trim(med_list->documented_med[1].
     order_status_disp),
    rtf_eol)
   SET add_cnt = 0
   FOR (idx = 1 TO med_list->documented_med_cnt)
     IF ((med_list->documented_med[idx].viewable_ind=true))
      SET add_cnt = (add_cnt+ 1)
      SET pt->line_cnt = 0
      SET max_length = 70
      EXECUTE dcp_parse_text value(med_list->documented_med[idx].med_line), value(max_length)
      FOR (jdx = 1 TO pt->line_cnt)
        IF (jdx=1)
         SET reply->text = concat(reply->text,rtf_wr,12_blank,trim(pt->lns[jdx].line),rtf_eol)
        ELSE
         SET reply->text = concat(reply->text,rtf_wr,14_blank,trim(pt->lns[jdx].line),rtf_eol)
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
  ENDIF
  IF ((med_list->inprocess_med_cnt > 0)
   AND found_inprocess_viewable=true)
   SET reply->text = concat(reply->text,8_blank,rtf_wu,1_blank,trim(med_list->inprocess_med[1].
     order_status_disp),
    rtf_eol)
   SET add_cnt = 0
   FOR (idx = 1 TO med_list->inprocess_med_cnt)
     IF ((med_list->inprocess_med[idx].viewable_ind=true))
      SET add_cnt = (add_cnt+ 1)
      SET pt->line_cnt = 0
      SET max_length = 70
      EXECUTE dcp_parse_text value(med_list->inprocess_med[idx].med_line), value(max_length)
      FOR (jdx = 1 TO pt->line_cnt)
        IF (jdx=1)
         SET reply->text = concat(reply->text,rtf_wr,12_blank,trim(pt->lns[jdx].line),rtf_eol)
        ELSE
         SET reply->text = concat(reply->text,rtf_wr,14_blank,trim(pt->lns[jdx].line),rtf_eol)
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
  ENDIF
  IF ((med_list->suspended_med_cnt > 0)
   AND found_suspended_viewable=true)
   SET reply->text = concat(reply->text,8_blank,rtf_wu,1_blank,trim(med_list->suspended_med[1].
     order_status_disp),
    rtf_eol)
   SET add_cnt = 0
   FOR (idx = 1 TO med_list->suspended_med_cnt)
     IF ((med_list->suspended_med[idx].viewable_ind=true))
      SET add_cnt = (add_cnt+ 1)
      SET pt->line_cnt = 0
      SET max_length = 70
      EXECUTE dcp_parse_text value(med_list->suspended_med[idx].med_line), value(max_length)
      FOR (jdx = 1 TO pt->line_cnt)
        IF (jdx=1)
         SET reply->text = concat(reply->text,rtf_wr,12_blank,trim(pt->lns[jdx].line),rtf_eol)
        ELSE
         SET reply->text = concat(reply->text,rtf_wr,14_blank,trim(pt->lns[jdx].line),rtf_eol)
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
  ENDIF
  IF ((med_list->incomplete_med_cnt > 0)
   AND found_incomplete_viewable=true)
   SET reply->text = concat(reply->text,8_blank,rtf_wu,1_blank,trim(med_list->incomplete_med[1].
     order_status_disp),
    rtf_eol)
   SET add_cnt = 0
   FOR (idx = 1 TO med_list->incomplete_med_cnt)
     IF ((med_list->incomplete_med[idx].viewable_ind=true))
      SET add_cnt = (add_cnt+ 1)
      SET pt->line_cnt = 0
      SET max_length = 70
      EXECUTE dcp_parse_text value(med_list->incomplete_med[idx].med_line), value(max_length)
      FOR (jdx = 1 TO pt->line_cnt)
        IF (jdx=1)
         SET reply->text = concat(reply->text,rtf_wr,12_blank,trim(pt->lns[jdx].line),rtf_eol)
        ELSE
         SET reply->text = concat(reply->text,rtf_wr,14_blank,trim(pt->lns[jdx].line),rtf_eol)
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
  ENDIF
  IF ((med_list->medstudent_med_cnt > 0)
   AND found_medstudent_viewable=true)
   SET reply->text = concat(reply->text,8_blank,rtf_wu,1_blank,trim(med_list->medstudent_med[1].
     order_status_disp),
    rtf_eol)
   SET add_cnt = 0
   FOR (idx = 1 TO med_list->medstudent_med_cnt)
     IF ((med_list->medstudent_med[idx].viewable_ind=true))
      SET add_cnt = (add_cnt+ 1)
      SET pt->line_cnt = 0
      SET max_length = 70
      EXECUTE dcp_parse_text value(med_list->medstudent_med[idx].med_line), value(max_length)
      FOR (jdx = 1 TO pt->line_cnt)
        IF (jdx=1)
         SET reply->text = concat(reply->text,rtf_wr,12_blank,trim(pt->lns[jdx].line),rtf_eol)
        ELSE
         SET reply->text = concat(reply->text,rtf_wr,14_blank,trim(pt->lns[jdx].line),rtf_eol)
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
  ENDIF
  IF ((med_list->future_med_cnt > 0)
   AND found_future_viewable=true)
   SET reply->text = concat(reply->text,8_blank,rtf_wu,1_blank,trim(med_list->future_med[1].
     order_status_disp),
    rtf_eol)
   SET add_cnt = 0
   FOR (idx = 1 TO med_list->future_med_cnt)
     IF ((med_list->future_med[idx].viewable_ind=true))
      SET add_cnt = (add_cnt+ 1)
      SET pt->line_cnt = 0
      SET max_length = 70
      EXECUTE dcp_parse_text value(med_list->future_med[idx].med_line), value(max_length)
      FOR (jdx = 1 TO pt->line_cnt)
        IF (jdx=1)
         SET reply->text = concat(reply->text,rtf_wr,12_blank,trim(pt->lns[jdx].line),rtf_eol)
        ELSE
         SET reply->text = concat(reply->text,rtf_wr,14_blank,trim(pt->lns[jdx].line),rtf_eol)
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
  ENDIF
 ELSE
  SET reply->text = concat(reply->text,rtf_wr,8_blank,"No Active Medications Found",rtf_eol)
 ENDIF
 SET reply->text = concat(reply->text,rtf_wb,4_blank,"Medications Inactivated in the Last 72 Hours",
  rtf_eol)
 IF ((med_list->inact_med_cnt > 0))
  SET add_cnt = 0
  FOR (idx = 1 TO med_list->inact_med_cnt)
    IF ((med_list->inact_med[idx].viewable_ind=true))
     SET add_cnt = (add_cnt+ 1)
     SET pt->line_cnt = 0
     SET max_length = 70
     EXECUTE dcp_parse_text value(med_list->inact_med[idx].med_line), value(max_length)
     FOR (jdx = 1 TO pt->line_cnt)
       IF (jdx=1)
        SET reply->text = concat(reply->text,rtf_wr,8_blank,trim(pt->lns[jdx].line),rtf_eol)
       ELSE
        SET reply->text = concat(reply->text,rtf_wr,10_blank,trim(pt->lns[jdx].line),rtf_eol)
       ENDIF
     ENDFOR
    ENDIF
  ENDFOR
  IF (add_cnt < 1)
   SET reply->text = concat(reply->text,rtf_wr,8_blank,"No medications found.",rtf_eol)
  ENDIF
 ELSE
  SET reply->text = concat(reply->text,rtf_wr,8_blank,"No medications found.",rtf_eol)
 ENDIF
 SET reply->text = concat(reply->text,rtf_eof)
#exit_script
 CALL echo("***")
 CALL echo("***   Exit Script")
 CALL echo("***")
 CALL echorecord(med_list)
 IF (failed != false)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATION"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
   SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
 CALL echo("***")
 CALL echo("***   END: DTS_GET_MED_LIST")
 CALL echo("***")
 SET script_ver = "002 07/26/06"
END GO
