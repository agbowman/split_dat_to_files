CREATE PROGRAM aps_prt_db_sys_corr:dba
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
   1 n = vc
   1 rptaps = vc
   1 ap = vc
   1 ddate = vc
   1 directory = vc
   1 ttime = vc
   1 refdbaudit = vc
   1 bby = vc
   1 syscorr = vc
   1 ppage = vc
   1 auditparam = vc
   1 study = vc
   1 triggerparams = vc
   1 active = vc
   1 inactive = vc
   1 executerescreen = vc
   1 trigger = vc
   1 specimen = vc
   1 none = vc
   1 casepercentage = vc
   1 basedon = vc
   1 lookback = vc
   1 acrosscase = vc
   1 withincase = vc
   1 acrosscaseparams = vc
   1 casetype = vc
   1 prefix = vc
   1 qualify = vc
   1 allcases = vc
   1 mostrecentcases = vc
   1 action = vc
   1 correlationby = vc
   1 individual = vc
   1 group = vc
   1 verifyingid = vc
   1 notifyonline = vc
   1 donotnotifyonline = vc
   1 normalcy = vc
   1 y = vc
   1 yes = vc
   1 no = vc
   1 continued = vc
   1 continued2 = vc
   1 reportdisp = vc
   1 endofreport = vc
   1 months = vc
   1 unassigned = vc
 )
 SET captions->n = uar_i18ngetmessage(i18nhandle,"h1","N")
 SET captions->rptaps = uar_i18ngetmessage(i18nhandle,"h2","REPORT:  APS_PRT_DB_SYS_CORR")
 SET captions->ap = uar_i18ngetmessage(i18nhandle,"h3","Anatomic Pathology")
 SET captions->ddate = uar_i18ngetmessage(i18nhandle,"h4","DATE:")
 SET captions->directory = uar_i18ngetmessage(i18nhandle,"h5","DIRECTORY:")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"h6","TIME:")
 SET captions->refdbaudit = uar_i18ngetmessage(i18nhandle,"h7","REFERENCE DATABASE AUDIT")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"h8","BY:")
 SET captions->syscorr = uar_i18ngetmessage(i18nhandle,"h9","SYSTEM SELECTED CORRELATION TOOL")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"h10","PAGE:")
 SET captions->auditparam = uar_i18ngetmessage(i18nhandle,"h11","AUDIT PARAMETERS:")
 SET captions->study = uar_i18ngetmessage(i18nhandle,"h12","STUDY:")
 SET captions->triggerparams = uar_i18ngetmessage(i18nhandle,"h13","***** TRIGGER PARAMETERS *****")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"h14","ACTIVE")
 SET captions->inactive = uar_i18ngetmessage(i18nhandle,"h15","INACTIVE")
 SET captions->executerescreen = uar_i18ngetmessage(i18nhandle,"h16",
  "EXECUTE TRIGGER FOR REPORTS REQUIRING RESCREENING?")
 SET captions->trigger = uar_i18ngetmessage(i18nhandle,"h17","TRIGGER:")
 SET captions->specimen = uar_i18ngetmessage(i18nhandle,"h18","SPECIMEN")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"h19","(NONE)")
 SET captions->casepercentage = uar_i18ngetmessage(i18nhandle,"h20","% OF CASES:")
 SET captions->basedon = uar_i18ngetmessage(i18nhandle,"h21","BASED ON:")
 SET captions->lookback = uar_i18ngetmessage(i18nhandle,"h22","LOOKBACK:")
 SET captions->acrosscase = uar_i18ngetmessage(i18nhandle,"h23","ACROSS CASE")
 SET captions->withincase = uar_i18ngetmessage(i18nhandle,"h24","WITHIN CASE")
 SET captions->acrosscaseparams = uar_i18ngetmessage(i18nhandle,"h25","ACROSS CASE PARAMETERS")
 SET captions->casetype = uar_i18ngetmessage(i18nhandle,"h26","CASE TYPE:")
 SET captions->prefix = uar_i18ngetmessage(i18nhandle,"h27","PREFIX:")
 SET captions->qualify = uar_i18ngetmessage(i18nhandle,"h28","QUALIFY:")
 SET captions->allcases = uar_i18ngetmessage(i18nhandle,"h29","ALL CASES")
 SET captions->mostrecentcases = uar_i18ngetmessage(i18nhandle,"h30","MOST RECENT CASES")
 SET captions->action = uar_i18ngetmessage(i18nhandle,"h31","ACTION:")
 SET captions->correlationby = uar_i18ngetmessage(i18nhandle,"h32","CORRELATION PERFORMED BY:")
 SET captions->individual = uar_i18ngetmessage(i18nhandle,"h33","INDIVIDUAL")
 SET captions->group = uar_i18ngetmessage(i18nhandle,"h34","GROUP")
 SET captions->verifyingid = uar_i18ngetmessage(i18nhandle,"h35","VERIFYING ID")
 SET captions->notifyonline = uar_i18ngetmessage(i18nhandle,"h36","NOTIFY USER ONLINE")
 SET captions->donotnotifyonline = uar_i18ngetmessage(i18nhandle,"h37","DO NOT NOTIFY USER ONLINE")
 SET captions->normalcy = uar_i18ngetmessage(i18nhandle,"h38","NORMALCY")
 SET captions->y = uar_i18ngetmessage(i18nhandle,"h39","Y")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"h40","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"h41","NO")
 SET captions->continued = uar_i18ngetmessage(i18nhandle,"h42","Continued:")
 SET captions->continued2 = uar_i18ngetmessage(i18nhandle,"h43","CONTINUED...")
 SET captions->reportdisp = uar_i18ngetmessage(i18nhandle,"h44","REPORT")
 SET captions->endofreport = uar_i18ngetmessage(i18nhandle,"h45","*** END OF REPORT ***")
 SET captions->months = uar_i18ngetmessage(i18nhandle,"h46","MONTHS")
 SET captions->unassigned = uar_i18ngetmessage(i18nhandle,"h47","(UNASSIGNED)")
 SET week = format(curdate,"@WEEKDAYABBREV;;Q")
 SET day = format(curdate,"@MEDIUMDATE;;Q")
 RECORD temp(
   1 sys_corr_qual[*]
     2 study = vc
     2 across_case_ind = i2
     2 case_percentage = vc
     2 active_ind = i2
     2 execute_on_rescreen_ind = i2
     2 lookback_case_type = vc
     2 lookback_months = vc
     2 lookback_all_cases_ind = i2
     2 notify_user_online_ind = i2
     2 unassigned_ind = i2
     2 assign_to_group_ind = i2
     2 assign_to_group = vc
     2 assign_to_person = vc
     2 assign_to_verifying_ind = i2
     2 trigger_prefix_cnt = i2
     2 trigger_prefix_qual[*]
       3 display = vc
     2 trigger_specimen_cnt = i2
     2 trigger_specimen_qual[*]
       3 display = vc
     2 trigger_normalcy_cnt = i2
     2 trigger_normalcy_qual[*]
       3 display = vc
     2 trigger_report_cnt = i2
     2 trigger_report_qual[*]
       3 display = vc
     2 trigger_section_cnt = i2
     2 trigger_section_qual[*]
       3 display = vc
     2 trigger_alpha_cnt = i2
     2 trigger_alpha_qual[*]
       3 display = vc
     2 lookback_prefix_cnt = i2
     2 lookback_prefix_qual[*]
       3 display = vc
     2 lookback_specimen_cnt = i2
     2 lookback_specimen_qual[*]
       3 display = vc
     2 lookback_normalcy_cnt = i2
     2 lookback_normalcy_qual[*]
       3 display = vc
     2 lookback_report_cnt = i2
     2 lookback_report_qual[*]
       3 display = vc
     2 lookback_section_cnt = i2
     2 lookback_section_qual[*]
       3 display = vc
     2 lookback_alpha_cnt = i2
     2 lookback_alpha_qual[*]
       3 display = vc
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
 SET failed = "F"
 SET sys_corr_cnt = 0
 SET wrote_audit_param = 0
 SET study_cnt = cnvtint(size(request->study_qual,5))
 SET execute_rescreen_disp = fillstring(100," ")
 SET case_percentage_disp = fillstring(100," ")
 SET based_on = fillstring(100," ")
 SET case_type = fillstring(100," ")
 SET lookback = fillstring(100," ")
 SET qualify = fillstring(100," ")
 SET correlation_by = fillstring(100," ")
 SET curalias sys_corr temp->sys_corr_qual[sys_corr_cnt]
 SELECT INTO "nl:"
  apsc.sys_corr_id
  FROM ap_sys_corr apsc,
   ap_sys_corr_detail ascd,
   ap_dc_study ads,
   ap_prefix ap,
   code_value cv1,
   code_value cv2,
   nomenclature n,
   prsnl p,
   prsnl_group pg,
   (dummyt d1  WITH seq = value(study_cnt)),
   (dummyt d2  WITH seq = 1),
   (dummyt d3  WITH seq = 1),
   (dummyt d4  WITH seq = 1)
  PLAN (d1)
   JOIN (apsc
   WHERE (apsc.study_id=request->study_qual[d1.seq].study_id))
   JOIN (ads
   WHERE ads.study_id=apsc.study_id)
   JOIN (cv1
   WHERE apsc.lookback_case_type_cd=cv1.code_value)
   JOIN (p
   WHERE apsc.assign_to_prsnl_id=p.person_id)
   JOIN (pg
   WHERE apsc.assign_to_group_id=pg.prsnl_group_id)
   JOIN (ascd
   WHERE ascd.sys_corr_id=apsc.sys_corr_id)
   JOIN (((d2
   WHERE 1=d2.seq)
   JOIN (cv2
   WHERE ascd.parent_entity_name IN ("ORDER_CATALOG", "DISCRETE_TASK_ASSAY", "CODE_VALUE")
    AND ascd.parent_entity_id=cv2.code_value)
   ) ORJOIN ((((d3
   WHERE 1=d3.seq)
   JOIN (ap
   WHERE ascd.parent_entity_name="AP_PREFIX"
    AND ascd.parent_entity_id=ap.prefix_id)
   ) ORJOIN ((d4
   WHERE 1=d4.seq)
   JOIN (n
   WHERE ascd.parent_entity_name="NOMENCLATURE"
    AND ascd.parent_entity_id=n.nomenclature_id)
   )) ))
  ORDER BY apsc.active_ind DESC, ads.description, apsc.sys_corr_id,
   ascd.lookback_ind, ascd.param_name, ascd.param_sequence,
   ascd.sys_corr_detail_id
  HEAD REPORT
   sys_corr_cnt = 0
  HEAD apsc.sys_corr_id
   sys_corr_cnt = (sys_corr_cnt+ 1)
   IF (mod(sys_corr_cnt,10)=1)
    stat = alterlist(temp->sys_corr_qual,(sys_corr_cnt+ 9))
   ENDIF
   sys_corr->study = trim(ads.description), sys_corr->across_case_ind = ads.across_case_ind, sys_corr
   ->case_percentage = trim(cnvtstring(apsc.case_percentage)),
   sys_corr->active_ind = apsc.active_ind, sys_corr->execute_on_rescreen_ind = apsc
   .execute_on_rescreen_ind, sys_corr->lookback_case_type = trim(cv1.display),
   sys_corr->lookback_months = trim(cnvtstring(apsc.lookback_months)), sys_corr->
   lookback_all_cases_ind = apsc.lookback_all_cases_ind, sys_corr->notify_user_online_ind = apsc
   .notify_user_online_ind,
   sys_corr->assign_to_group_ind = apsc.assign_to_group_ind, sys_corr->assign_to_group = trim(pg
    .prsnl_group_name), sys_corr->assign_to_person = trim(p.name_full_formatted),
   sys_corr->assign_to_verifying_ind = apsc.assign_to_verifying_ind
   IF (apsc.assign_to_prsnl_id=0.0
    AND apsc.assign_to_group_id=0.0
    AND apsc.assign_to_verifying_ind=0)
    sys_corr->unassigned_ind = 1
   ENDIF
  HEAD ascd.lookback_ind
   row + 0
  HEAD ascd.param_name
   row + 0
  HEAD ascd.param_sequence
   row + 0
  DETAIL
   IF (ascd.param_name="PREFIX")
    IF (ascd.lookback_ind=0)
     sys_corr->trigger_prefix_cnt = (sys_corr->trigger_prefix_cnt+ 1), stat = alterlist(sys_corr->
      trigger_prefix_qual,sys_corr->trigger_prefix_cnt), sys_corr->trigger_prefix_qual[sys_corr->
     trigger_prefix_cnt].display = trim(concat(ap.prefix_name,", ",ap.prefix_desc))
    ELSE
     sys_corr->lookback_prefix_cnt = (sys_corr->lookback_prefix_cnt+ 1), stat = alterlist(sys_corr->
      lookback_prefix_qual,sys_corr->lookback_prefix_cnt), sys_corr->lookback_prefix_qual[sys_corr->
     lookback_prefix_cnt].display = trim(concat(ap.prefix_name,", ",ap.prefix_desc))
    ENDIF
   ELSEIF (ascd.param_name="SPECIMEN")
    IF (ascd.lookback_ind=0)
     sys_corr->trigger_specimen_cnt = (sys_corr->trigger_specimen_cnt+ 1), stat = alterlist(sys_corr
      ->trigger_specimen_qual,sys_corr->trigger_specimen_cnt), sys_corr->trigger_specimen_qual[
     sys_corr->trigger_specimen_cnt].display = trim(cv2.display)
    ELSE
     sys_corr->lookback_specimen_cnt = (sys_corr->lookback_specimen_cnt+ 1), stat = alterlist(
      sys_corr->lookback_specimen_qual,sys_corr->lookback_specimen_cnt), sys_corr->
     lookback_specimen_qual[sys_corr->lookback_specimen_cnt].display = trim(cv2.display)
    ENDIF
   ELSEIF (ascd.param_name="NORMALCY")
    IF (ascd.lookback_ind=0)
     sys_corr->trigger_normalcy_cnt = (sys_corr->trigger_normalcy_cnt+ 1), stat = alterlist(sys_corr
      ->trigger_normalcy_qual,sys_corr->trigger_normalcy_cnt), sys_corr->trigger_normalcy_qual[
     sys_corr->trigger_normalcy_cnt].display = trim(cv2.display)
    ELSE
     sys_corr->lookback_normalcy_cnt = (sys_corr->lookback_normalcy_cnt+ 1), stat = alterlist(
      sys_corr->lookback_normalcy_qual,sys_corr->lookback_normalcy_cnt), sys_corr->
     lookback_normalcy_qual[sys_corr->lookback_normalcy_cnt].display = trim(cv2.display)
    ENDIF
   ELSEIF (ascd.param_name="REPORT")
    IF (ascd.lookback_ind=0)
     sys_corr->trigger_report_cnt = (sys_corr->trigger_report_cnt+ 1), stat = alterlist(sys_corr->
      trigger_report_qual,sys_corr->trigger_report_cnt), sys_corr->trigger_report_qual[sys_corr->
     trigger_report_cnt].display = trim(cv2.display)
    ELSE
     sys_corr->lookback_report_cnt = (sys_corr->lookback_report_cnt+ 1), stat = alterlist(sys_corr->
      lookback_report_qual,sys_corr->lookback_report_cnt), sys_corr->lookback_report_qual[sys_corr->
     lookback_report_cnt].display = trim(cv2.display)
    ENDIF
   ELSEIF (ascd.param_name="SECTION"
    AND ascd.parent_entity_name="DISCRETE_TASK_ASSAY")
    IF (ascd.lookback_ind=0)
     sys_corr->trigger_section_cnt = (sys_corr->trigger_section_cnt+ 1), stat = alterlist(sys_corr->
      trigger_section_qual,sys_corr->trigger_section_cnt), sys_corr->trigger_section_qual[sys_corr->
     trigger_section_cnt].display = trim(cv2.display)
    ELSE
     sys_corr->lookback_section_cnt = (sys_corr->lookback_section_cnt+ 1), stat = alterlist(sys_corr
      ->lookback_section_qual,sys_corr->lookback_section_cnt), sys_corr->lookback_section_qual[
     sys_corr->lookback_section_cnt].display = trim(cv2.display)
    ENDIF
   ELSEIF (ascd.param_name="ALPHA"
    AND ascd.parent_entity_name="NOMENCLATURE")
    IF (ascd.lookback_ind=0)
     sys_corr->trigger_alpha_cnt = (sys_corr->trigger_alpha_cnt+ 1), stat = alterlist(sys_corr->
      trigger_alpha_qual,sys_corr->trigger_alpha_cnt), sys_corr->trigger_alpha_qual[sys_corr->
     trigger_alpha_cnt].display = trim(n.source_string)
    ELSE
     sys_corr->lookback_alpha_cnt = (sys_corr->lookback_alpha_cnt+ 1), stat = alterlist(sys_corr->
      lookback_alpha_qual,sys_corr->lookback_alpha_cnt), sys_corr->lookback_alpha_qual[sys_corr->
     lookback_alpha_cnt].display = trim(n.source_string)
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(temp->sys_corr_qual,sys_corr_cnt)
  WITH nocounter
 ;end select
#report_maker
 EXECUTE cpm_create_file_name_logical "apsDbSysCorr", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  study = temp->sys_corr_qual[d1.seq].study, across_case_ind = temp->sys_corr_qual[d1.seq].
  across_case_ind, case_percentage = temp->sys_corr_qual[d1.seq].case_percentage,
  active_ind = temp->sys_corr_qual[d1.seq].active_ind, execute_on_rescreen_ind = temp->sys_corr_qual[
  d1.seq].execute_on_rescreen_ind, lookback_months = temp->sys_corr_qual[d1.seq].lookback_months,
  lookback_all_cases_ind = temp->sys_corr_qual[d1.seq].lookback_all_cases_ind, notify_user_online_ind
   = temp->sys_corr_qual[d1.seq].notify_user_online_ind, assign_to_group_ind = temp->sys_corr_qual[d1
  .seq].assign_to_group_ind,
  assign_to_group = temp->sys_corr_qual[d1.seq].assign_to_group, assign_to_person = temp->
  sys_corr_qual[d1.seq].assign_to_person, assign_to_verifying_ind = temp->sys_corr_qual[d1.seq].
  assign_to_verifying_ind,
  unassigned_ind = temp->sys_corr_qual[d1.seq].unassigned_ind
  FROM (dummyt d1  WITH seq = value(size(temp->sys_corr_qual,5)))
  PLAN (d1)
  HEAD REPORT
   line1 = fillstring(125,"-")
  HEAD PAGE
   row + 1, col 0, captions->rptaps,
   CALL center(captions->ap,0,132), col 110, captions->ddate,
   col 117, curdate"@SHORTDATE;;Q", row + 1,
   col 0, captions->directory, col 110,
   captions->ttime, col 117, curtime,
   row + 1,
   CALL center(captions->refdbaudit,0,132), col 112,
   captions->bby, col 117, request->scuruser"##############",
   row + 1,
   CALL center(captions->syscorr,0,132), col 110,
   captions->ppage, col 117, curpage"###"
  DETAIL
   IF (wrote_audit_param=0)
    row + 2, col 0, captions->auditparam,
    line_offset = 6, curr_col = line_offset
    FOR (loop1 = 1 TO study_cnt)
     text_size = textlen(request->study_qual[loop1].study_desc),
     IF (((curr_col=line_offset) OR (((text_size+ curr_col) > 115))) )
      row + 1, col line_offset, request->study_qual[loop1].study_desc,
      curr_col = (text_size+ line_offset)
     ELSEIF (text_size > 0)
      row + 0, col curr_col, ", ",
      row + 0, call reportmove('COL',(curr_col+ 2),0), request->study_qual[loop1].study_desc,
      curr_col = ((curr_col+ text_size)+ 2)
     ENDIF
    ENDFOR
    wrote_audit_param = 1
   ELSE
    row + 2, col 0, ""
   ENDIF
   row + 2, col 0, "****************************************",
   row + 1, col 0, captions->study,
   row + 1, col 0, study,
   row + 1, col 0, "****************************************",
   row + 2, col 0, captions->triggerparams,
   row + 1, col 0, temp->sys_corr_qual[d1.seq].trigger_prefix_qual[1].display,
   row + 1, col 0
   IF (active_ind=0)
    captions->inactive
   ELSE
    captions->active
   ENDIF
   IF (execute_on_rescreen_ind=0)
    execute_rescreen_disp = concat(captions->executerescreen," ",captions->n)
   ELSE
    execute_rescreen_disp = concat(captions->executerescreen," ",captions->y)
   ENDIF
   row + 1, col 0, execute_rescreen_disp
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   row + 2, col 0, captions->trigger,
   row + 1, col 0, captions->specimen
   IF ((temp->sys_corr_qual[d1.seq].trigger_specimen_cnt=0))
    row + 1, col 5, captions->none
   ELSE
    line_offset = 6, curr_col = line_offset
    FOR (loop1 = 1 TO temp->sys_corr_qual[d1.seq].trigger_specimen_cnt)
      text_size = textlen(temp->sys_corr_qual[d1.seq].trigger_specimen_qual[loop1].display)
      IF (((curr_col=line_offset) OR (((text_size+ curr_col) > 115))) )
       row + 1, col line_offset, temp->sys_corr_qual[d1.seq].trigger_specimen_qual[loop1].display,
       curr_col = (text_size+ line_offset)
      ELSEIF (text_size > 0)
       row + 0, col curr_col, ", ",
       row + 0, call reportmove('COL',(curr_col+ 2),0), temp->sys_corr_qual[d1.seq].
       trigger_specimen_qual[loop1].display,
       curr_col = ((curr_col+ text_size)+ 2)
      ENDIF
      IF (((row+ 10) > maxrow))
       BREAK
      ENDIF
    ENDFOR
   ENDIF
   case_percentage_disp = concat(captions->casepercentage," ",case_percentage,"%"), row + 1, col 0,
   case_percentage_disp
   IF ((temp->sys_corr_qual[d1.seq].trigger_normalcy_cnt=0))
    based_on = concat(captions->basedon," ",captions->reportdisp)
   ELSE
    based_on = concat(captions->basedon," ",captions->normalcy)
   ENDIF
   row + 1, col 0, based_on
   IF ((temp->sys_corr_qual[d1.seq].trigger_normalcy_cnt > 0))
    line_offset = 6, curr_col = line_offset
    FOR (loop1 = 1 TO temp->sys_corr_qual[d1.seq].trigger_normalcy_cnt)
      text_size = textlen(temp->sys_corr_qual[d1.seq].trigger_normalcy_qual[loop1].display)
      IF (((curr_col=line_offset) OR (((text_size+ curr_col) > 115))) )
       row + 1, col line_offset, temp->sys_corr_qual[d1.seq].trigger_normalcy_qual[loop1].display,
       curr_col = (text_size+ line_offset)
      ELSEIF (text_size > 0)
       row + 0, col curr_col, ", ",
       row + 0, call reportmove('COL',(curr_col+ 2),0), temp->sys_corr_qual[d1.seq].
       trigger_normalcy_qual[loop1].display,
       curr_col = ((curr_col+ text_size)+ 2)
      ENDIF
      IF (((row+ 10) > maxrow))
       BREAK
      ENDIF
    ENDFOR
   ELSEIF ((temp->sys_corr_qual[d1.seq].trigger_report_cnt > 0))
    line_offset = 6, curr_col = line_offset
    FOR (loop1 = 1 TO temp->sys_corr_qual[d1.seq].trigger_report_cnt)
      text_size = textlen(temp->sys_corr_qual[d1.seq].trigger_report_qual[loop1].display)
      IF (((curr_col=line_offset) OR (((text_size+ curr_col) > 115))) )
       row + 1, col line_offset, temp->sys_corr_qual[d1.seq].trigger_report_qual[loop1].display,
       curr_col = (text_size+ line_offset)
      ELSEIF (text_size > 0)
       row + 0, col curr_col, ", ",
       row + 0, call reportmove('COL',(curr_col+ 2),0), temp->sys_corr_qual[d1.seq].
       trigger_report_qual[loop1].display,
       curr_col = ((curr_col+ text_size)+ 2)
      ENDIF
      IF (((row+ 10) > maxrow))
       BREAK
      ENDIF
    ENDFOR
   ELSEIF ((temp->sys_corr_qual[d1.seq].trigger_section_cnt > 0))
    line_offset = 6, curr_col = line_offset
    FOR (loop1 = 1 TO temp->sys_corr_qual[d1.seq].trigger_section_cnt)
      text_size = textlen(temp->sys_corr_qual[d1.seq].trigger_section_qual[loop1].display)
      IF (((curr_col=line_offset) OR (((text_size+ curr_col) > 115))) )
       row + 1, col line_offset, temp->sys_corr_qual[d1.seq].trigger_section_qual[loop1].display,
       curr_col = (text_size+ line_offset)
      ELSEIF (text_size > 0)
       row + 0, col curr_col, ", ",
       row + 0, call reportmove('COL',(curr_col+ 2),0), temp->sys_corr_qual[d1.seq].
       trigger_section_qual[loop1].display,
       curr_col = ((curr_col+ text_size)+ 2)
      ENDIF
      IF (((row+ 10) > maxrow))
       BREAK
      ENDIF
    ENDFOR
   ELSEIF ((temp->sys_corr_qual[d1.seq].trigger_alpha_cnt > 0))
    line_offset = 6, curr_col = line_offset
    FOR (loop1 = 1 TO temp->sys_corr_qual[d1.seq].trigger_alpha_cnt)
      text_size = textlen(temp->sys_corr_qual[d1.seq].trigger_alpha_qual[loop1].display)
      IF (((curr_col=line_offset) OR (((text_size+ curr_col) > 115))) )
       row + 1, col line_offset, temp->sys_corr_qual[d1.seq].trigger_alpha_qual[loop1].display,
       curr_col = (text_size+ line_offset)
      ELSEIF (text_size > 0)
       row + 0, col curr_col, ", ",
       row + 0, call reportmove('COL',(curr_col+ 2),0), temp->sys_corr_qual[d1.seq].
       trigger_alpha_qual[loop1].display,
       curr_col = ((curr_col+ text_size)+ 2)
      ENDIF
      IF (((row+ 10) > maxrow))
       BREAK
      ENDIF
    ENDFOR
   ELSE
    row + 1, col 10, captions->none
   ENDIF
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   row + 2, col 0, captions->lookback
   IF (across_case_ind=0)
    row + 1, col 0, captions->withincase
   ELSE
    row + 1, col 0, captions->acrosscase,
    row + 1, col 0, captions->acrosscaseparams,
    case_type = concat(captions->casetype," ",temp->sys_corr_qual[d1.seq].lookback_case_type), row +
    1, col 5,
    case_type, row + 1, col 5,
    captions->prefix
    IF ((temp->sys_corr_qual[d1.seq].lookback_prefix_cnt=0))
     row + 1, col 10, captions->none
    ELSE
     line_offset = 11, curr_col = line_offset
     FOR (loop1 = 1 TO temp->sys_corr_qual[d1.seq].lookback_prefix_cnt)
       text_size = textlen(temp->sys_corr_qual[d1.seq].lookback_prefix_qual[loop1].display)
       IF (((curr_col=line_offset) OR (((text_size+ curr_col) > 115))) )
        row + 1, col curr_col, temp->sys_corr_qual[d1.seq].lookback_prefix_qual[loop1].display,
        curr_col = (text_size+ line_offset)
       ELSEIF (text_size > 0)
        row + 0, col curr_col, ", ",
        row + 0, call reportmove('COL',(curr_col+ 2),0), temp->sys_corr_qual[d1.seq].
        lookback_prefix_qual[loop1].display,
        curr_col = ((curr_col+ text_size)+ 2)
       ENDIF
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
     ENDFOR
    ENDIF
    row + 1, col 5, captions->specimen
    IF ((temp->sys_corr_qual[d1.seq].lookback_specimen_cnt=0))
     row + 1, col 10, captions->none
    ELSE
     line_offset = 11, curr_col = line_offset
     FOR (loop1 = 1 TO temp->sys_corr_qual[d1.seq].lookback_specimen_cnt)
       text_size = textlen(temp->sys_corr_qual[d1.seq].lookback_specimen_qual[loop1].display)
       IF (((curr_col=line_offset) OR (((text_size+ curr_col) > 115))) )
        row + 1, col curr_col, temp->sys_corr_qual[d1.seq].lookback_specimen_qual[loop1].display,
        curr_col = (text_size+ line_offset)
       ELSEIF (text_size > 0)
        row + 0, col curr_col, ", ",
        row + 0, call reportmove('COL',(curr_col+ 2),0), temp->sys_corr_qual[d1.seq].
        lookback_specimen_qual[loop1].display,
        curr_col = ((curr_col+ text_size)+ 2)
       ENDIF
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
     ENDFOR
    ENDIF
    lookback = concat(captions->lookback," ",lookback_months," ",captions->months), row + 1, col 5,
    lookback
    IF (lookback_all_cases_ind=0)
     qualify = concat(captions->qualify," ",captions->mostrecentcases)
    ELSE
     qualify = concat(captions->qualify," ",captions->allcases)
    ENDIF
    row + 1, col 5, qualify
    IF ((temp->sys_corr_qual[d1.seq].lookback_normalcy_cnt=0))
     based_on = concat(captions->basedon," ",captions->reportdisp)
    ELSE
     based_on = concat(captions->basedon," ",captions->normalcy)
    ENDIF
    row + 1, col 0, based_on
    IF ((temp->sys_corr_qual[d1.seq].lookback_normalcy_cnt > 0))
     line_offset = 6, curr_col = line_offset
     FOR (loop1 = 1 TO temp->sys_corr_qual[d1.seq].lookback_normalcy_cnt)
       text_size = textlen(temp->sys_corr_qual[d1.seq].lookback_normalcy_qual[loop1].display)
       IF (((curr_col=line_offset) OR (((text_size+ curr_col) > 115))) )
        row + 1, col curr_col, temp->sys_corr_qual[d1.seq].lookback_normalcy_qual[loop1].display,
        curr_col = (text_size+ line_offset)
       ELSEIF (text_size > 0)
        row + 0, col curr_col, ", ",
        row + 0, call reportmove('COL',(curr_col+ 2),0), temp->sys_corr_qual[d1.seq].
        lookback_normalcy_qual[loop1].display,
        curr_col = ((curr_col+ text_size)+ 2)
       ENDIF
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
     ENDFOR
    ELSEIF ((temp->sys_corr_qual[d1.seq].lookback_report_cnt > 0))
     line_offset = 6, curr_col = line_offset
     FOR (loop1 = 1 TO temp->sys_corr_qual[d1.seq].lookback_report_cnt)
       text_size = textlen(temp->sys_corr_qual[d1.seq].lookback_report_qual[loop1].display)
       IF (((curr_col=line_offset) OR (((text_size+ curr_col) > 115))) )
        row + 1, col curr_col, temp->sys_corr_qual[d1.seq].lookback_report_qual[loop1].display,
        curr_col = (text_size+ line_offset)
       ELSEIF (text_size > 0)
        row + 0, col curr_col, ", ",
        row + 0, call reportmove('COL',(curr_col+ 2),0), temp->sys_corr_qual[d1.seq].
        lookback_report_qual[loop1].display,
        curr_col = ((curr_col+ text_size)+ 2)
       ENDIF
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
     ENDFOR
    ELSEIF ((temp->sys_corr_qual[d1.seq].lookback_section_cnt > 0))
     line_offset = 6, curr_col = line_offset
     FOR (loop1 = 1 TO temp->sys_corr_qual[d1.seq].lookback_section_cnt)
       text_size = textlen(temp->sys_corr_qual[d1.seq].lookback_section_qual[loop1].display)
       IF (((curr_col=line_offset) OR (((text_size+ curr_col) > 115))) )
        row + 1, col curr_col, temp->sys_corr_qual[d1.seq].lookback_section_qual[loop1].display,
        curr_col = (text_size+ line_offset)
       ELSEIF (text_size > 0)
        row + 0, col curr_col, ", ",
        row + 0, call reportmove('COL',(curr_col+ 2),0), temp->sys_corr_qual[d1.seq].
        lookback_section_qual[loop1].display,
        curr_col = ((curr_col+ text_size)+ 2)
       ENDIF
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
     ENDFOR
    ELSEIF ((temp->sys_corr_qual[d1.seq].lookback_alpha_cnt > 0))
     line_offset = 6, curr_col = line_offset
     FOR (loop1 = 1 TO temp->sys_corr_qual[d1.seq].lookback_alpha_cnt)
       text_size = textlen(temp->sys_corr_qual[d1.seq].lookback_alpha_qual[loop1].display)
       IF (((curr_col=line_offset) OR (((text_size+ curr_col) > 115))) )
        row + 1, col curr_col, temp->sys_corr_qual[d1.seq].lookback_alpha_qual[loop1].display,
        curr_col = (text_size+ line_offset)
       ELSEIF (text_size > 0)
        row + 0, col curr_col, ", ",
        row + 0, call reportmove('COL',(curr_col+ 2),0), temp->sys_corr_qual[d1.seq].
        lookback_alpha_qual[loop1].display,
        curr_col = ((curr_col+ text_size)+ 2)
       ENDIF
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
     ENDFOR
    ELSE
     row + 1, col 10, captions->none
    ENDIF
   ENDIF
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   row + 2, col 0, captions->action
   IF (assign_to_group_ind=0)
    correlation_by = concat(captions->correlationby," ",captions->individual)
   ELSE
    correlation_by = concat(captions->correlationby," ",captions->group)
   ENDIF
   row + 1, col 0, correlation_by,
   row + 1, col 5
   IF (assign_to_verifying_ind != 0)
    captions->verifyingid
   ELSEIF (unassigned_ind=1)
    captions->unassigned
   ELSEIF (assign_to_group_ind=0)
    assign_to_person
   ELSE
    assign_to_group
   ENDIF
   row + 1, col 0
   IF (notify_user_online_ind=0)
    captions->donotnotifyonline
   ELSE
    captions->notifyonline
   ENDIF
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
  FOOT PAGE
   row 60, col 0, line1,
   row + 1, col 0, captions->rptaps,
   today = concat(week," ",day), col 53, today,
   col 110, captions->ppage, col 117,
   curpage"###", row + 1, col 55,
   captions->continued
  FOOT REPORT
   col 55, captions->endofreport
  WITH nocounter, maxcol = 132, nullreport,
   maxrow = 63, compress
 ;end select
#exit_script
 SET reply->status_data.status = "S"
END GO
