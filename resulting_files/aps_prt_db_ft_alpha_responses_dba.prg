CREATE PROGRAM aps_prt_db_ft_alpha_responses:dba
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
   1 rptaps = vc
   1 pathap = vc
   1 ddate = vc
   1 dir = vc
   1 ttime = vc
   1 rda = vc
   1 bby = vc
   1 dbftar = vc
   1 ppage = vc
   1 nofound = vc
   1 procedure = vc
   1 numdays = vc
   1 init = vc
   1 frstovrdu = vc
   1 finlovrdu = vc
   1 aresp = vc
   1 ftype = vc
   1 notif = vc
   1 term = vc
   1 cont = vc
   1 svcresource = vc
   1 default = vc
 )
 SET captions->rptaps = uar_i18ngetmessage(i18nhandle,"rptaps",
  "REPORT: APS_PRT_DB_FT_ALPHA_RESPONSES.PRG")
 SET captions->pathap = uar_i18ngetmessage(i18nhandle,"pathap","PATHNET ANATOMIC PATHOLOGY")
 SET captions->ddate = uar_i18ngetmessage(i18nhandle,"ddate","DATE")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"dir","DIRECTORY")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"ttime","TIME")
 SET captions->rda = uar_i18ngetmessage(i18nhandle,"rda","REFERENCE DATABASE AUDIT")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"bby","BY")
 SET captions->dbftar = uar_i18ngetmessage(i18nhandle,"dbftar",
  "DB FOLLOW-UP TRACKING ALPHA RESPONSES")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"ppage","PAGE")
 SET captions->nofound = uar_i18ngetmessage(i18nhandle,"nofound","No audit data found.")
 SET captions->procedure = uar_i18ngetmessage(i18nhandle,"procedure","PROCEDURE")
 SET captions->numdays = uar_i18ngetmessage(i18nhandle,"numdays","# DAYS")
 SET captions->init = uar_i18ngetmessage(i18nhandle,"init","INITIAL")
 SET captions->frstovrdu = uar_i18ngetmessage(i18nhandle,"frstovrdu","1ST OVERDUE")
 SET captions->finlovrdu = uar_i18ngetmessage(i18nhandle,"finlovrdu","FINAL OVERDUE")
 SET captions->aresp = uar_i18ngetmessage(i18nhandle,"aresp","ALPHA RESPONSES")
 SET captions->ftype = uar_i18ngetmessage(i18nhandle,"ftype","FOLLOW-UP TYPE")
 SET captions->notif = uar_i18ngetmessage(i18nhandle,"notif","NOTIFICATION")
 SET captions->term = uar_i18ngetmessage(i18nhandle,"term","TERMINATION")
 SET captions->cont = uar_i18ngetmessage(i18nhandle,"cont","CONTINUED...")
 SET captions->svcresource = uar_i18ngetmessage(i18nhandle,"h1","SERVICE RESOURCE:")
 SET captions->default = uar_i18ngetmessage(i18nhandle,"h2","(default)")
 RECORD temp(
   1 catalog_qual[*]
     2 catalog_cd = f8
     2 diagnosis_disp = c40
     2 cap_diagnosis_disp = c40
     2 diagnosis_desc = c60
     2 alpha_qual[*]
       3 sequence = i4
       3 nomenclature_id = f8
       3 nomenclature_disp = c25
       3 diagnostic_category_cd = f8
       3 diagnostic_category_disp = c40
       3 tracking_type_cd = f8
       3 tracking_type_disp = c40
       3 initial_interval = i4
       3 init_null_ind = i2
       3 first_interval = i4
       3 first_null_ind = i2
       3 final_interval = i4
       3 final_null_ind = i2
       3 termination_interval = i4
       3 term_null_ind = i2
       3 service_resource_cd = f8
       3 service_resource_disp = c40
 )
 RECORD reply(
   1 print_status_data
     2 print_directory = c19
     2 print_filename = c40
     2 print_dir_and_filename = c60
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET max_alpha_cntr = 0
 SET no_cases_found = "F"
 SELECT INTO "nl:"
  display_caps = cnvtupper(uar_get_code_display(crc.diagnosis_task_assay_cd)), crc.catalog_cd
  FROM cyto_report_control crc
  PLAN (crc
   WHERE crc.catalog_cd != 0.0)
  ORDER BY display_caps
  HEAD REPORT
   ctlg_cntr = 0
  HEAD display_caps
   ctlg_cntr += 1, stat = alterlist(temp->catalog_qual,ctlg_cntr), temp->catalog_qual[ctlg_cntr].
   catalog_cd = crc.catalog_cd,
   temp->catalog_qual[ctlg_cntr].diagnosis_disp = uar_get_code_display(crc.diagnosis_task_assay_cd),
   temp->catalog_qual[ctlg_cntr].cap_diagnosis_disp = display_caps, temp->catalog_qual[ctlg_cntr].
   diagnosis_desc = uar_get_code_description(crc.diagnosis_task_assay_cd)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET no_cases_found = "T"
  GO TO report_maker
 ENDIF
 SELECT INTO "nl:"
  dta.mnemonic_key_cap, n.mnemonic, init_null_ind = nullind(cas.followup_initial_interval),
  first_null_ind = nullind(cas.followup_first_interval), final_null_ind = nullind(cas
   .followup_final_interval), term_null_ind = nullind(cas.followup_termination_interval)
  FROM discrete_task_assay dta,
   reference_range_factor rrf,
   alpha_responses ar,
   dummyt d1,
   (dummyt d2  WITH seq = value(size(temp->catalog_qual,5))),
   cyto_alpha_security cas,
   nomenclature n
  PLAN (d2)
   JOIN (dta
   WHERE (dta.mnemonic_key_cap=temp->catalog_qual[d2.seq].cap_diagnosis_disp))
   JOIN (rrf
   WHERE dta.task_assay_cd=rrf.task_assay_cd
    AND rrf.active_ind=1)
   JOIN (ar
   WHERE rrf.reference_range_factor_id=ar.reference_range_factor_id
    AND ar.active_ind=1)
   JOIN (n
   WHERE ar.nomenclature_id=n.nomenclature_id)
   JOIN (d1)
   JOIN (cas
   WHERE ar.reference_range_factor_id=cas.reference_range_factor_id
    AND ar.nomenclature_id=cas.nomenclature_id
    AND cas.definition_ind IN (0, 2)
    AND cas.service_resource_cd=0.0)
  ORDER BY dta.mnemonic_key_cap, ar.sequence
  HEAD REPORT
   max_alpha_cntr = 0
  HEAD dta.mnemonic_key_cap
   alpha_cntr = 0
  DETAIL
   alpha_cntr += 1
   IF (alpha_cntr > max_alpha_cntr)
    max_alpha_cntr = alpha_cntr
   ENDIF
   stat = alterlist(temp->catalog_qual[d2.seq].alpha_qual,alpha_cntr), temp->catalog_qual[d2.seq].
   alpha_qual[alpha_cntr].sequence = ar.sequence, temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].
   nomenclature_disp = n.mnemonic,
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].diagnostic_category_cd = cas
   .diagnostic_category_cd, temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].
   diagnostic_category_disp = uar_get_code_display(cas.diagnostic_category_cd), temp->catalog_qual[d2
   .seq].alpha_qual[alpha_cntr].nomenclature_id = ar.nomenclature_id,
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].tracking_type_cd = cas.followup_tracking_type_cd,
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].tracking_type_disp = uar_get_code_display(cas
    .followup_tracking_type_cd), temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].
   service_resource_cd = cas.service_resource_cd,
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].service_resource_disp = captions->default, temp
   ->catalog_qual[d2.seq].alpha_qual[alpha_cntr].initial_interval = cas.followup_initial_interval,
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].first_interval = cas.followup_first_interval,
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].final_interval = cas.followup_final_interval,
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].termination_interval = cas
   .followup_termination_interval, temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].init_null_ind =
   init_null_ind,
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].first_null_ind = first_null_ind, temp->
   catalog_qual[d2.seq].alpha_qual[alpha_cntr].final_null_ind = final_null_ind, temp->catalog_qual[d2
   .seq].alpha_qual[alpha_cntr].term_null_ind = term_null_ind
   IF (ar.reference_range_factor_id != cas.reference_range_factor_id
    AND ar.nomenclature_id != cas.nomenclature_id)
    temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].init_null_ind = 1, temp->catalog_qual[d2.seq].
    alpha_qual[alpha_cntr].first_null_ind = 1, temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].
    final_null_ind = 1,
    temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].term_null_ind = 1
   ENDIF
  WITH nocounter, outerjoin = d1
 ;end select
 SELECT INTO "nl:"
  dta.mnemonic_key_cap, n.mnemonic, init_null_ind = nullind(cas.followup_initial_interval),
  first_null_ind = nullind(cas.followup_first_interval), final_null_ind = nullind(cas
   .followup_final_interval), term_null_ind = nullind(cas.followup_termination_interval),
  srv_rsrce_disp_caps = cnvtupper(uar_get_code_display(cas.service_resource_cd))
  FROM discrete_task_assay dta,
   reference_range_factor rrf,
   alpha_responses ar,
   (dummyt d2  WITH seq = value(size(temp->catalog_qual,5))),
   cyto_alpha_security cas,
   nomenclature n
  PLAN (d2)
   JOIN (dta
   WHERE (dta.mnemonic_key_cap=temp->catalog_qual[d2.seq].cap_diagnosis_disp))
   JOIN (rrf
   WHERE dta.task_assay_cd=rrf.task_assay_cd
    AND rrf.active_ind=1)
   JOIN (ar
   WHERE rrf.reference_range_factor_id=ar.reference_range_factor_id
    AND ar.active_ind=1)
   JOIN (n
   WHERE ar.nomenclature_id=n.nomenclature_id)
   JOIN (cas
   WHERE ar.reference_range_factor_id=cas.reference_range_factor_id
    AND ar.nomenclature_id=cas.nomenclature_id
    AND cas.definition_ind IN (0, 2)
    AND cas.service_resource_cd > 0.0)
  ORDER BY dta.mnemonic_key_cap, srv_rsrce_disp_caps, ar.sequence
  HEAD dta.mnemonic_key_cap
   alpha_cntr = size(temp->catalog_qual[d2.seq].alpha_qual,5)
  DETAIL
   alpha_cntr += 1
   IF (alpha_cntr > size(temp->catalog_qual[d2.seq].alpha_qual,5))
    stat = alterlist(temp->catalog_qual[d2.seq].alpha_qual,(alpha_cntr+ 9))
   ENDIF
   IF (alpha_cntr > max_alpha_cntr)
    max_alpha_cntr = alpha_cntr
   ENDIF
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].sequence = ar.sequence, temp->catalog_qual[d2
   .seq].alpha_qual[alpha_cntr].nomenclature_disp = n.mnemonic, temp->catalog_qual[d2.seq].
   alpha_qual[alpha_cntr].diagnostic_category_cd = cas.diagnostic_category_cd,
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].diagnostic_category_disp = uar_get_code_display(
    cas.diagnostic_category_cd), temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].nomenclature_id =
   ar.nomenclature_id, temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].tracking_type_cd = cas
   .followup_tracking_type_cd,
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].tracking_type_disp = uar_get_code_display(cas
    .followup_tracking_type_cd), temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].
   service_resource_cd = cas.service_resource_cd, temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].
   service_resource_disp = uar_get_code_display(cas.service_resource_cd),
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].initial_interval = cas.followup_initial_interval,
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].first_interval = cas.followup_first_interval,
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].final_interval = cas.followup_final_interval,
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].termination_interval = cas
   .followup_termination_interval, temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].init_null_ind =
   init_null_ind, temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].first_null_ind = first_null_ind,
   temp->catalog_qual[d2.seq].alpha_qual[alpha_cntr].final_null_ind = final_null_ind, temp->
   catalog_qual[d2.seq].alpha_qual[alpha_cntr].term_null_ind = term_null_ind
  FOOT  dta.mnemonic_key_cap
   stat = alterlist(temp->catalog_qual[d2.seq].alpha_qual,alpha_cntr)
  WITH nocounter
 ;end select
#report_maker
 EXECUTE cpm_create_file_name_logical "apsDbFtResponses", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  *, alpha_sequence = temp->catalog_qual[d1.seq].alpha_qual[d2.seq].sequence, diagnsrvrsrcedispcaps
   = build(temp->catalog_qual[d1.seq].cap_diagnosis_disp,cnvtupper(temp->catalog_qual[d1.seq].
    alpha_qual[d2.seq].service_resource_disp))
  FROM (dummyt d1  WITH seq = value(size(temp->catalog_qual,5))),
   (dummyt d2  WITH seq = value(max_alpha_cntr))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->catalog_qual[d1.seq].alpha_qual,5))
  ORDER BY diagnsrvrsrcedispcaps, alpha_sequence
  HEAD REPORT
   line1 = fillstring(125,"-")
  HEAD PAGE
   row + 1, col 0, captions->rptaps,
   col 0,
   CALL center(captions->pathap,0,132), col 110,
   captions->ddate, ":", cdate = format(curdate,"@SHORTDATE;;d"),
   col 117, cdate, row + 1,
   col 0, captions->dir, ":",
   col 110, captions->ttime, ":",
   col 117, curtime, row + 1,
   col 0,
   CALL center(captions->rda,0,132), col 112,
   captions->bby, ":", col 117,
   request->scuruser"##############", row + 1, col 0,
   CALL center(captions->dbftar,0,132), col 110, captions->ppage,
   ":", col 117, curpage"###",
   row + 1
   IF (no_cases_found="T")
    row + 10, col 0,
    CALL center(captions->nofound,0,132)
   ENDIF
  HEAD diagnsrvrsrcedispcaps
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   row + 1, col 0, captions->procedure,
   ": ", col 19, temp->catalog_qual[d1.seq].diagnosis_disp,
   row + 1, col 19, temp->catalog_qual[d1.seq].diagnosis_desc,
   row + 1, col 0, captions->svcresource,
   "  ", col 19, temp->catalog_qual[d1.seq].alpha_qual[d2.seq].service_resource_disp,
   row + 1, col 51, captions->numdays,
   col 65, captions->numdays, col 79,
   captions->numdays, row + 1, col 51,
   captions->init, col 65, captions->frstovrdu,
   col 79, captions->finlovrdu, col 94,
   captions->numdays, row + 1, col 0,
   captions->aresp, col 25, captions->ftype,
   col 51, captions->notif, col 65,
   captions->notif, col 79, captions->notif,
   col 94, captions->term, row + 1,
   col 0, "-----------------------", col 25,
   "------------------------", col 51, "------------",
   col 65, "------------", col 79,
   "-------------", col 94, "-----------"
  DETAIL
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   row + 1, col 0, temp->catalog_qual[d1.seq].alpha_qual[d2.seq].nomenclature_disp
   "#########################",
   col 25, temp->catalog_qual[d1.seq].alpha_qual[d2.seq].tracking_type_disp
   "########################################"
   IF ((temp->catalog_qual[d1.seq].alpha_qual[d2.seq].init_null_ind=0))
    col 51, temp->catalog_qual[d1.seq].alpha_qual[d2.seq].initial_interval"###"
   ENDIF
   IF ((temp->catalog_qual[d1.seq].alpha_qual[d2.seq].first_null_ind=0))
    col 65, temp->catalog_qual[d1.seq].alpha_qual[d2.seq].first_interval"###"
   ENDIF
   IF ((temp->catalog_qual[d1.seq].alpha_qual[d2.seq].final_null_ind=0))
    col 79, temp->catalog_qual[d1.seq].alpha_qual[d2.seq].final_interval"###"
   ENDIF
   IF ((temp->catalog_qual[d1.seq].alpha_qual[d2.seq].term_null_ind=0))
    col 94, temp->catalog_qual[d1.seq].alpha_qual[d2.seq].termination_interval"###"
   ENDIF
  FOOT  diagnsrvrsrcedispcaps
   row + 1, row + 1, col 50,
   "* * * * * * * * *", row + 1
  FOOT PAGE
   row 60, col 0, line1,
   row + 1, col 0, captions->rptaps,
   today = concat(format(curdate,"@WEEKDAYABBREV;;d")," ",format(curdate,"@MEDIUMDATE4YR;;d")), col
   53, today,
   col 110, captions->ppage, ":",
   col 117, curpage"###", row + 1,
   col 55, captions->cont
  FOOT REPORT
   col 55, "##########  "
  WITH nocounter, maxcol = 132, nullreport,
   maxrow = 63, compress
 ;end select
 SET reply->status_data.status = "S"
END GO
