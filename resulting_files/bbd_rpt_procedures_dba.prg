CREATE PROGRAM bbd_rpt_procedures:dba
 RECORD reply(
   1 rpt_list[*]
     2 rpt_filename = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET modify = predeclare
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE rpt_cnt = i2 WITH noconstant(0)
 DECLARE p_auto = c12 WITH constant("AUTO")
 DECLARE p_directed = c12 WITH constant("DIRECTED")
 DECLARE p_pheresis = c12 WITH constant("COUNRES")
 DECLARE p_phleb = c12 WITH constant("PHLEB")
 DECLARE p_recruit = c12 WITH constant("RECRUIT")
 DECLARE p_reinstate = c12 WITH constant("REINSTATE")
 DECLARE o_appoint = c12 WITH constant("APPOINT")
 DECLARE o_callback = c12 WITH constant("CALLBACK")
 DECLARE o_counres = c12 WITH constant("COUNRES")
 DECLARE o_failed = c12 WITH constant("FAILED")
 DECLARE o_permdef = c12 WITH constant("PERMDEF")
 DECLARE o_recfail = c12 WITH constant("RECFAIL")
 DECLARE o_success = c12 WITH constant("SUCCESS")
 DECLARE o_tempdef = c12 WITH constant("TEMPDEF")
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
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 as_of_date = vc
   1 rpt_title = vc
   1 rpt_page = vc
   1 rpt_time = vc
   1 rpt_proc_tool = vc
   1 rpt_proc_act = vc
   1 rpt_proc_inact = vc
   1 head_procedure = vc
   1 head_description = vc
   1 head_type = vc
   1 head_active = vc
   1 head_effective = vc
   1 head_to = vc
   1 head_defs_allowed = vc
   1 head_schedule = vc
   1 head_start_stop = vc
   1 head_outcome = vc
   1 head_donor_test = vc
   1 head_add_product = vc
   1 head_add_quar = vc
   1 head_reason_1 = vc
   1 head_reason_2 = vc
   1 head_calc_deferral = vc
   1 head_days_def = vc
   1 head_hours_def = vc
   1 head_bag_type = vc
   1 head_default = vc
   1 head_products = vc
   1 active = vc
   1 not_active = vc
   1 not_app = vc
   1 end_of_report = vc
   1 head_default_donation_type = vc
   1 donations_per_level = vc
 )
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","AS OF DATE:")
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title","DATABASE AUDIT")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","PAGE:")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","TIME:")
 SET captions->rpt_proc_tool = uar_i18ngetmessage(i18nhandle,"rpt_proc_tool","PROCEDURES TOOL")
 SET captions->rpt_proc_act = uar_i18ngetmessage(i18nhandle,"rpt_proc_act","PROCEDURES (Active)")
 SET captions->rpt_proc_inact = uar_i18ngetmessage(i18nhandle,"rpt_proc_inact",
  "PROCEDURES (Active and Inactive)")
 SET captions->head_procedure = uar_i18ngetmessage(i18nhandle,"head_procedure","PROCEDURE:")
 SET captions->head_description = uar_i18ngetmessage(i18nhandle,"head_description","DESCRIPTION:")
 SET captions->head_type = uar_i18ngetmessage(i18nhandle,"head_type","TYPE:")
 SET captions->head_active = uar_i18ngetmessage(i18nhandle,"head_active","ACTIVE:")
 SET captions->head_effective = uar_i18ngetmessage(i18nhandle,"head_effective","EFFECTIVE:")
 SET captions->head_to = uar_i18ngetmessage(i18nhandle,"head_to","TO")
 SET captions->head_defs_allowed = uar_i18ngetmessage(i18nhandle,"head_defs_allowed","DEFERRALS:")
 SET captions->head_start_stop = uar_i18ngetmessage(i18nhandle,"head_start_stop","START/STOP:")
 SET captions->head_outcome = uar_i18ngetmessage(i18nhandle,"head_outcome","OUTCOME:")
 SET captions->head_donor_test = uar_i18ngetmessage(i18nhandle,"head_donor_test","DONOR TESTING:")
 SET captions->head_add_product = uar_i18ngetmessage(i18nhandle,"head_add_product","ADD PRODUCT:")
 SET captions->head_add_quar = uar_i18ngetmessage(i18nhandle,"head_add_quar","ADD QUARANTINE:")
 SET captions->head_reason_1 = uar_i18ngetmessage(i18nhandle,"head_reason_1","REASON:")
 SET captions->head_reason_2 = uar_i18ngetmessage(i18nhandle,"head_reason_2","REASON")
 SET captions->head_calc_deferral = uar_i18ngetmessage(i18nhandle,"head_calc_deferral",
  "CALCULATE DEFERRAL")
 SET captions->head_days_def = uar_i18ngetmessage(i18nhandle,"head_days_def","DAYS DEFERRED")
 SET captions->head_hours_def = uar_i18ngetmessage(i18nhandle,"head_hours_def","HOURS DEFERRED")
 SET captions->head_bag_type = uar_i18ngetmessage(i18nhandle,"head_bag_type","BAG TYPE")
 SET captions->head_default = uar_i18ngetmessage(i18nhandle,"head_default","DEFAULT")
 SET captions->head_products = uar_i18ngetmessage(i18nhandle,"head_products","PRODUCT")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","Yes")
 SET captions->not_active = uar_i18ngetmessage(i18nhandle,"not_active","No")
 SET captions->not_app = uar_i18ngetmessage(i18nhandle,"not_app","N/A")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report","*** End of Report ***")
 SET captions->head_default_donation_type = uar_i18ngetmessage(i18nhandle,
  "head_default_donation_type","DEFAULT DONATION TYPE:")
 SET captions->donations_per_level = uar_i18ngetmessage(i18nhandle,"donations_per_level",
  "DONATIONS PER LEVEL:")
 EXECUTE cpm_create_file_name_logical "bbd_proc", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  bdp.*, bpo.*, bor.*,
  bobt.*, bbtp.*, donor_test = substring(1,20,ocs.mnemonic),
  procedure_disp = trim(uar_get_code_display(bdp.procedure_cd)), procedure_desc = trim(
   uar_get_code_description(bdp.procedure_cd)), procedure_mean = uar_get_code_meaning(bdp
   .procedure_cd),
  deferrals_disp = substring(1,26,uar_get_code_display(bdp.deferrals_allowed_cd)), outcome_disp =
  trim(uar_get_code_display(bpo.outcome_cd)), outcome_desc = trim(uar_get_code_description(bpo
    .outcome_cd)),
  outcome_mean = uar_get_code_meaning(bpo.outcome_cd), quar_reason_disp = substring(1,15,
   uar_get_code_display(bpo.quar_reason_cd)), reason_disp = trim(uar_get_code_display(bor.reason_cd)),
  calc_deferral_disp = trim(uar_get_code_display(bor.deferral_expire_cd)), bag_type_disp = trim(
   uar_get_code_display(bobt.bag_type_cd)), product_disp = trim(uar_get_code_display(bbtp.product_cd)
   ),
  outcome_path = evaluate(nullind(bpo.procedure_id),0,1,0), synonym_path = evaluate(nullind(ocs
    .synonym_id),0,1,0), bag_reason_path = decode(bor.seq,1,bobt.seq,2,0),
  product_path = evaluate(nullind(bbtp.bag_type_product_id),0,1,0), default_donation_type_disp = trim
  (uar_get_code_display(bdp.default_donation_type_cd)), donations_per_level_disp = format(bdp
   .nbr_per_volume_level,";L")
  FROM bbd_donation_procedure bdp,
   bbd_procedure_outcome bpo,
   bbd_outcome_reason bor,
   bbd_outcome_bag_type bobt,
   bbd_bag_type_product bbtp,
   order_catalog_synonym ocs,
   dummyt d1,
   dummyt d2
  PLAN (bdp
   WHERE (((request->procedure_cd=0.0)) OR ((request->procedure_cd > 0.0)
    AND (bdp.procedure_cd=request->procedure_cd)))
    AND (((request->active_ind=0)) OR ((request->active_ind=1)
    AND bdp.active_ind=1))
    AND bdp.procedure_id > 0.0)
   JOIN (bpo
   WHERE bpo.procedure_id=outerjoin(bdp.procedure_id))
   JOIN (ocs
   WHERE ocs.synonym_id=outerjoin(bpo.synonym_id))
   JOIN (((d1)
   JOIN (bor
   WHERE bor.procedure_outcome_id=bpo.procedure_outcome_id)
   ) ORJOIN ((d2)
   JOIN (bobt
   WHERE bobt.procedure_outcome_id=bpo.procedure_outcome_id)
   JOIN (bbtp
   WHERE bbtp.outcome_bag_type_id=outerjoin(bobt.outcome_bag_type_id))
   ))
  ORDER BY procedure_disp, bdp.end_effective_dt_tm DESC, bdp.beg_effective_dt_tm DESC,
   bdp.procedure_id, bpo.procedure_outcome_id, bor.outcome_reason_id,
   bobt.outcome_bag_type_id, bbtp.bag_type_product_id
  HEAD REPORT
   line0 = fillstring(126,"="), line1 = fillstring(40,"-"), line2 = fillstring(7,"-"),
   line3 = fillstring(18,"-"), line4 = fillstring(14,"-"), holdrow = 0,
   reason_header = 0, bag_header = 0, active_proc = 0
  HEAD PAGE
   col 0, captions->as_of_date, col 12,
   curdate"@DATECONDENSED;;d",
   CALL center(captions->rpt_title,0,125), col 108,
   captions->rpt_page, col 114, curpage";L",
   row + 1, col 0, captions->rpt_time,
   col 12, curtime"@TIMENOSECONDS;;M",
   CALL center(captions->rpt_proc_tool,0,125),
   row + 1
   IF ((request->active_ind=1))
    CALL center(captions->rpt_proc_act,0,125)
   ELSE
    CALL center(captions->rpt_proc_inact,0,125)
   ENDIF
   row + 1
  HEAD bdp.procedure_id
   IF (row > 52)
    BREAK
   ENDIF
   IF (bdp.active_ind=1)
    active_proc = 1
   ENDIF
   row + 2, col 0, line0,
   row + 1, col 0, captions->head_procedure,
   col 11, procedure_disp, col 64,
   captions->head_active, col 72
   IF (bdp.active_ind=1)
    captions->active
   ELSE
    captions->not_active
   ENDIF
   col 77, captions->head_effective, col 88,
   bdp.beg_effective_dt_tm"@SHORTDATETIME", col 106, captions->head_to,
   col 109, bdp.end_effective_dt_tm"@SHORTDATETIME", row + 1,
   col 0, captions->head_description, col 13,
   procedure_desc, col 64, captions->head_defs_allowed,
   col 75
   IF (((procedure_mean=p_recruit) OR (bdp.deferrals_allowed_cd=0.0)) )
    captions->not_app
   ELSE
    deferrals_disp
   ENDIF
   col 103, captions->head_start_stop, col 115
   IF (procedure_mean=p_recruit)
    captions->not_app
   ELSE
    IF (bdp.start_stop_ind=1)
     captions->active
    ELSE
     captions->not_active
    ENDIF
   ENDIF
   row + 1, col 64, captions->head_default_donation_type,
   col 87
   IF (bdp.default_donation_type_cd=0.0)
    captions->not_app
   ELSE
    default_donation_type_disp
   ENDIF
   row + 1, col 64, captions->donations_per_level,
   col + 1, donations_per_level_disp, row + 1,
   col 0, line0, row- (1)
  HEAD bpo.procedure_outcome_id
   IF (outcome_path=1)
    IF (bpo.active_ind=active_proc)
     IF (row > 56)
      BREAK
     ENDIF
     row + 2, col 0, captions->head_outcome,
     col 9, outcome_disp, col 64,
     captions->head_donor_test, col 79
     IF (ocs.synonym_id > 0.0)
      donor_test
     ELSE
      IF (outcome_mean=o_success)
       captions->not_active
      ELSE
       captions->not_app
      ENDIF
     ENDIF
     col 103, captions->head_add_product, col 116
     IF (bpo.add_product_ind=1)
      captions->active
     ELSE
      captions->not_active
     ENDIF
     row + 1
    ENDIF
   ENDIF
  HEAD bor.outcome_reason_id
   IF (bag_reason_path=1)
    IF (bor.active_ind=active_proc)
     IF (row > 55)
      BREAK
     ENDIF
     IF (reason_header=0)
      row + 2, col 9, captions->head_reason_2,
      col 51, captions->head_calc_deferral, col 71,
      captions->head_days_def, col 87, captions->head_hours_def,
      row + 1, col 9, line1,
      col 51, line3, col 71,
      line4, col 87, line4,
      reason_header = 1
     ENDIF
     row + 1, col 9, reason_disp,
     col 51
     IF (bor.deferral_expire_cd=0.0)
      captions->not_app
     ELSE
      calc_deferral_disp
     ENDIF
     col 71
     IF (outcome_mean=o_permdef)
      captions->not_app
     ELSE
      bor.days_ineligible
     ENDIF
     col 87
     IF (outcome_mean=o_permdef)
      captions->not_app
     ELSE
      bor.hours_ineligible
     ENDIF
    ENDIF
   ENDIF
  HEAD bobt.outcome_bag_type_id
   IF (bag_reason_path=2)
    IF (bobt.active_ind=active_proc)
     IF (row > 55)
      BREAK
     ENDIF
     IF (bag_header=0)
      row + 2, col 9, captions->head_bag_type,
      col 51, captions->head_default, col 60,
      captions->head_products, col 102, captions->head_default,
      row + 1, col 9, line1,
      col 51, line2, col 60,
      line1, col 102, line2,
      bag_header = 1
     ENDIF
     row + 1, col 9, bag_type_disp,
     col 51
     IF (bobt.default_ind=1)
      captions->active
     ELSE
      captions->not_active
     ENDIF
     holdrow = (row - 1)
    ENDIF
   ENDIF
  HEAD bbtp.bag_type_product_id
   IF (bag_reason_path=2)
    IF (bbtp.active_ind=active_proc)
     IF (product_path=1)
      IF (row > 55)
       BREAK, holdrow = row
      ENDIF
      holdrow = (holdrow+ 1), row holdrow, col 60,
      product_disp, col 102
      IF (bbtp.default_ind=1)
       captions->active
      ELSE
       captions->not_active
      ENDIF
     ELSE
      col 60, captions->not_app, col 102,
      captions->not_app
     ENDIF
    ENDIF
   ENDIF
  FOOT  bbtp.bag_type_product_id
   IF (bag_reason_path=2)
    IF (product_path=1)
     IF (row > 57)
      BREAK
     ENDIF
    ENDIF
   ENDIF
  FOOT  bobt.outcome_bag_type_id
   IF (bag_reason_path=2)
    holdrow = 0
    IF (row > 57)
     BREAK
    ENDIF
   ENDIF
  FOOT  bor.outcome_reason_id
   IF (bag_reason_path=1)
    IF (row > 57)
     BREAK
    ENDIF
   ENDIF
  FOOT  bpo.procedure_outcome_id
   IF (outcome_path=1)
    reason_header = 0, bag_header = 0
    IF (row > 57)
     BREAK
    ENDIF
   ENDIF
  FOOT  bdp.procedure_id
   row + 1, active_proc = 0
  FOOT REPORT
   row + 2,
   CALL center(captions->end_of_report,0,125)
  WITH nocounter, outerjoin(d1), outerjoin(d2),
   nullreport, compress, nolandscape
 ;end select
 SET rpt_cnt = (rpt_cnt+ 1)
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = concat("cer_print:",cpm_cfn_info->file_name)
#exit_script
 SET reply->status_data.status = "S"
END GO
