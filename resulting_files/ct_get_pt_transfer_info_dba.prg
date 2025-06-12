CREATE PROGRAM ct_get_pt_transfer_info:dba
 RECORD reply(
   1 protocol_name = c30
   1 current_amendment_nbr = i4
   1 current_amendment_id = f8
   1 current_revision_nbr_txt = c30
   1 current_revision_ind = i2
   1 pt_reg_info[*]
     2 patient_type = i2
     2 patient_name = vc
     2 patient_id = f8
     2 mrns[*]
       3 mrn = vc
       3 alias_pool_cd = f8
     2 reg_id = f8
     2 consent_released_dt_tm = dq8
     2 consent_signed_dt_tm = dq8
     2 on_study_dt_tm = dq8
     2 off_study_dt_tm = dq8
     2 deceased_dt_tm = dq8
     2 tx_completion_dt_tm = dq8
     2 prot_amendment_nbr = i4
     2 prot_amendment_id = f8
     2 revision_nbr_txt = c30
     2 revision_ind = i2
     2 assign_start_dt_tm = dq8
     2 updt_cnt = i4
     2 enrolling_org_id = f8
     2 enrolled_on_cur_amd = i2
     2 has_pending_consent = i2
   1 amendment_info[*]
     2 prot_amendment_id = f8
     2 amendment_nbr = i4
     2 revision_nbr_txt = c30
     2 revision_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 reason_for_failure = vc
 )
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE i = i2 WITH public, noconstant(0)
 DECLARE count = i2 WITH public, noconstant(0)
 DECLARE cgpt_amendment_nbr = i2 WITH public, noconstant(0)
 DECLARE cgpt_revision_seq = i2 WITH public, noconstant(0)
 DECLARE cur_amd_status = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE cgpt_amendment_id = f8 WITH public, noconstant(0.0)
 DECLARE cgpt_status = c1 WITH public, noconstant("F")
 DECLARE cgpt_revision_ind = i2 WITH public, noconstant(0)
 DECLARE cgpt_revision_nbr_txt = c30 WITH public, noconstant(fillstring(30," "))
 DECLARE cgat_status = c1 WITH public, noconstant("F")
 SET last_mod = "008"
 SET mod_date = "Oct 19, 2010"
 SET reply->status_data.status = "F"
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
 IF ((request->prot_amendment_id=0))
  EXECUTE ct_get_amds_trans_func
  IF (cgat_status="F")
   SET reply->reason_for_failure = uar_i18ngetmessage(i18nhandle,"CANNOT_TRANSFER",
    "Cannot transfer patients.")
   GO TO exit_script
  ELSEIF (cgat_status="Z")
   SET reply->status_data.status = "N"
   SET reply->reason_for_failure = uar_i18ngetmessage(i18nhandle,"TRANSFER_AMD",
    "Transfer requires an additional amendment or revision.")
   GO TO exit_script
  ENDIF
  SET reply->current_amendment_id = cgpt_amendment_id
  SET reply->current_amendment_nbr = cgpt_amendment_nbr
  SET reply->current_revision_nbr_txt = cgpt_revision_nbr_txt
  SET reply->current_revision_ind = cgpt_revision_ind
 ELSE
  SET cgpt_amendment_id = request->prot_amendment_id
  SET cgpt_amendment_nbr = request->amendment_nbr
  SELECT INTO "nl"
   pa.revision_seq
   FROM prot_amendment pa
   WHERE (pa.prot_amendment_id=request->prot_amendment_id)
   DETAIL
    cgpt_revision_seq = pa.revision_seq, cgpt_revision_nbr_txt = pa.revision_nbr_txt,
    cgpt_revision_ind = pa.revision_ind
   WITH nocounter
  ;end select
  SET reply->current_amendment_nbr = request->amendment_nbr
  SET reply->current_amendment_id = request->prot_amendment_id
  SET reply->current_revision_nbr_txt = cgpt_revision_nbr_txt
  SET reply->current_revision_ind = cgpt_revision_ind
 ENDIF
 EXECUTE ct_get_pnt_trans_func
 IF (cgpt_status="F")
  SET reply->reason_for_failure = uar_i18ngetmessage(i18nhandle,"NO_PTS",
   "No patients enrolled on protocol")
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo("here")
#exit_script
 CALL echo(build("Status:",reply->status_data.status))
 SET last_mod = "010"
 SET mod_date = "May 27, 2024"
END GO
