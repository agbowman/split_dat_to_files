CREATE PROGRAM aps_prt_db_diag_correlation:dba
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
   1 date = vc
   1 directory = vc
   1 ttime = vc
   1 refdbaudit = vc
   1 bby = vc
   1 diagcorparam = vc
   1 ppage = vc
   1 auditparam = vc
   1 includeadterm = vc
   1 excludeadterm = vc
   1 includediscrepancyterm = vc
   1 excludediscrepancyterm = vc
   1 includedisagreementterm = vc
   1 excludedisagreementterm = vc
   1 includeinvestigationterm = vc
   1 excludeinvestigationterm = vc
   1 includeresolutionterm = vc
   1 excluderesolutionterm = vc
   1 includestudies = vc
   1 excludestudies = vc
   1 y = vc
   1 adterm = vc
   1 activeentries = vc
   1 require = vc
   1 code = vc
   1 description = vc
   1 flag = vc
   1 discrepancy = vc
   1 reason = vc
   1 investigation = vc
   1 resolution = vc
   1 yes = vc
   1 no = vc
   1 noactiveentries = vc
   1 inactiveentries = vc
   1 noinactiveentries = vc
   1 discrepancyterm = vc
   1 disagreementterm = vc
   1 investigationterm = vc
   1 resolutionterm = vc
   1 diagcorrstudies = vc
   1 study = vc
   1 acrosscasecorrelation = vc
   1 tallycytoslidecounts = vc
   1 defaultto = vc
   1 includecytotechs = vc
   1 reporttaskforreport = vc
   1 continued = vc
   1 notdefined = vc
   1 reporttaskforreport = vc
   1 continued2 = vc
   1 individual = vc
   1 group = vc
   1 none = vc
 )
 SET captions->n = uar_i18ngetmessage(i18nhandle,"h1","N")
 SET captions->rptaps = uar_i18ngetmessage(i18nhandle,"h2","REPORT:  APS_PRT_DB_DIAG_CORRELATION")
 SET captions->ap = uar_i18ngetmessage(i18nhandle,"h3","Anatomic Pathology")
 SET captions->date = uar_i18ngetmessage(i18nhandle,"h4","DATE:")
 SET captions->directory = uar_i18ngetmessage(i18nhandle,"h5","DIRECTORY:")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"h6","TIME:")
 SET captions->refdbaudit = uar_i18ngetmessage(i18nhandle,"h7","REFERENCE DATABASE AUDIT")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"h8","BY:")
 SET captions->diagcorparam = uar_i18ngetmessage(i18nhandle,"h9",
  "DIAGNOSTIC CORRELATION PARAMETERS TOOL")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"h10","PAGE:")
 SET captions->auditparam = uar_i18ngetmessage(i18nhandle,"h11","AUDIT PARAMETERS:")
 SET captions->includeadterm = uar_i18ngetmessage(i18nhandle,"h12",
  "INCLUDE AGREEMENT/DISAGREEMENT TERMINOLOGY")
 SET captions->excludeadterm = uar_i18ngetmessage(i18nhandle,"h13",
  "EXCLUDE AGREEMENT/DISAGREEMENT TERMINOLOGY")
 SET captions->includediscrepancyterm = uar_i18ngetmessage(i18nhandle,"h14",
  "INCLUDE DISCREPANCY TERMINOLOGY")
 SET captions->excludediscrepancyterm = uar_i18ngetmessage(i18nhandle,"h15",
  "EXCLUDE DISCREPANCY TERMINOLOGY")
 SET captions->includedisagreementterm = uar_i18ngetmessage(i18nhandle,"h16",
  "INCLUDE DISAGREEMENT REASON TERMINOLOGY")
 SET captions->excludedisagreementterm = uar_i18ngetmessage(i18nhandle,"h17",
  "EXCLUDE DISAGREEMENT REASON TERMINOLOGY")
 SET captions->includeinvestigationterm = uar_i18ngetmessage(i18nhandle,"h18",
  "INCLUDE INVESTIGATION TERMINOLOGY")
 SET captions->excludeinvestigationterm = uar_i18ngetmessage(i18nhandle,"h19",
  "EXCLUDE INVESTIGATION TERMINOLOGY")
 SET captions->includeresolutionterm = uar_i18ngetmessage(i18nhandle,"h20",
  "INCLUDE RESOLUTION TERMINOLOGY")
 SET captions->excluderesolutionterm = uar_i18ngetmessage(i18nhandle,"h21",
  "EXCLUDE RESOLUTION TERMINOLOGY")
 SET captions->includestudies = uar_i18ngetmessage(i18nhandle,"h22","INCLUDE STUDIES")
 SET captions->excludestudies = uar_i18ngetmessage(i18nhandle,"h23","EXCLUDE STUDIES")
 SET captions->y = uar_i18ngetmessage(i18nhandle,"h24","Y")
 SET captions->adterm = uar_i18ngetmessage(i18nhandle,"h25","AGREEMENT/DISAGREEMENT TERMINOLOGY")
 SET captions->activeentries = uar_i18ngetmessage(i18nhandle,"h26","*** ACTIVE ENTRIES ***")
 SET captions->require = uar_i18ngetmessage(i18nhandle,"h27","REQUIRE")
 SET captions->code = uar_i18ngetmessage(i18nhandle,"h28","CODE")
 SET captions->description = uar_i18ngetmessage(i18nhandle,"h29","DESCRIPTION")
 SET captions->flag = uar_i18ngetmessage(i18nhandle,"h30","FLAG")
 SET captions->discrepancy = uar_i18ngetmessage(i18nhandle,"h31","DISCREPANCY")
 SET captions->reason = uar_i18ngetmessage(i18nhandle,"h32","REASON")
 SET captions->investigation = uar_i18ngetmessage(i18nhandle,"h33","INVESTIGATION")
 SET captions->resolution = uar_i18ngetmessage(i18nhandle,"h34","RESOLUTION")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"h35","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"h36","NO")
 SET captions->noactiveentries = uar_i18ngetmessage(i18nhandle,"h37","NO ACTIVE ENTRIES")
 SET captions->inactiveentries = uar_i18ngetmessage(i18nhandle,"h38","*** INACTIVE ENTRIES ***")
 SET captions->noinactiveentries = uar_i18ngetmessage(i18nhandle,"h39","NO INACTIVE ENTRIES")
 SET captions->discrepancyterm = uar_i18ngetmessage(i18nhandle,"h40","DISCREPANCY TERMINOLOGY")
 SET captions->disagreementterm = uar_i18ngetmessage(i18nhandle,"h41","DISAGREEMENT TERMINOLOGY")
 SET captions->investigationterm = uar_i18ngetmessage(i18nhandle,"h42","INVESTIGATION TERMINOLOGY")
 SET captions->resolutionterm = uar_i18ngetmessage(i18nhandle,"h43","RESOLUTION TERMINOLOGY")
 SET captions->diagcorrstudies = uar_i18ngetmessage(i18nhandle,"h44","DIAGNOSTIC CORRELATION STUDIES"
  )
 SET captions->study = uar_i18ngetmessage(i18nhandle,"h45","STUDY:")
 SET captions->acrosscasecorrelation = uar_i18ngetmessage(i18nhandle,"h46","ACROSS CASE CORRELATION?"
  )
 SET captions->tallycytoslidecounts = uar_i18ngetmessage(i18nhandle,"h46",
  "PROMPT TO TALLY CYTOLOGY SLIDE COUNTS?")
 SET captions->defaultto = uar_i18ngetmessage(i18nhandle,"h46","DEFAULT TO:")
 SET captions->includecytotechs = uar_i18ngetmessage(i18nhandle,"h46","INCLUDE CYTOTECHNOLOGISTS?")
 SET captions->reporttaskforreport = uar_i18ngetmessage(i18nhandle,"h47",
  "REPORT TASKS FOR REPORT AND/OR WORKSHEET:")
 SET captions->continued = uar_i18ngetmessage(i18nhandle,"h48","Continued:")
 SET captions->notdefined = uar_i18ngetmessage(i18nhandle,"h49","(Not defined)")
 SET captions->continued2 = uar_i18ngetmessage(i18nhandle,"f1","CONTINUED...")
 SET captions->individual = uar_i18ngetmessage(i18nhandle,"f2","INDIVIDUAL")
 SET captions->group = uar_i18ngetmessage(i18nhandle,"f3","GROUP")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"h50","(NONE)")
 SET week = format(curdate,"@WEEKDAYABBREV;;Q")
 SET day = format(curdate,"@MEDIUMDATE;;Q")
 RECORD temp(
   1 adet[*]
     2 display = c15
     2 description = c60
     2 agreement_disp = c40
     2 discrepancy_req_ind = i2
     2 reason_req_ind = i2
     2 investigation_req_ind = i2
     2 resolution_req_ind = i2
     2 active_ind = i2
   1 addt[*]
     2 display = c15
     2 description = c60
     2 discrepancy_disp = c40
     2 active_ind = i2
   1 disagree[*]
     2 display = c40
     2 description = c60
     2 active_ind = i2
   1 investigation[*]
     2 display = c40
     2 description = c60
     2 active_ind = i2
   1 resolution[*]
     2 display = c40
     2 description = c60
     2 active_ind = i2
   1 max_details = i4
   1 study[*]
     2 study_id = f8
     2 description = c100
     2 across_case_ind = i2
     2 slide_counts_prompt_ind = i2
     2 include_cytotechs_ind = i2
     2 default_to_group_ind = i2
     2 active_ind = i2
     2 rpt_proc[*]
       3 task_assay_cd = f8
       3 task_assay_disp = c40
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
 IF ((request->inc_agree_disagree=1))
  SELECT INTO "nl:"
   displayvalue = uar_get_code_display(adet.agreement_cd), adet.active_ind
   FROM ap_dc_evaluation_term adet
   PLAN (adet
    WHERE adet.evaluation_term_id > 0)
   ORDER BY adet.active_ind, adet.display
   HEAD REPORT
    x = 0
   DETAIL
    x += 1, stat = alterlist(temp->adet,x), temp->adet[x].display = adet.display,
    temp->adet[x].description = adet.description, temp->adet[x].agreement_disp = displayvalue, temp->
    adet[x].discrepancy_req_ind = adet.discrepancy_req_ind,
    temp->adet[x].reason_req_ind = adet.reason_req_ind, temp->adet[x].investigation_req_ind = adet
    .investigation_req_ind, temp->adet[x].resolution_req_ind = adet.resolution_req_ind,
    temp->adet[x].active_ind = adet.active_ind
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->inc_discrepancy=1))
  SELECT INTO "nl:"
   displayvalue = uar_get_code_display(addt.discrepancy_cd), addt.active_ind
   FROM ap_dc_discrepancy_term addt
   PLAN (addt
    WHERE addt.discrepancy_term_id > 0)
   ORDER BY addt.active_ind, addt.display
   HEAD REPORT
    x = 0
   DETAIL
    x += 1, stat = alterlist(temp->addt,x), temp->addt[x].display = addt.display,
    temp->addt[x].description = addt.description
    IF (addt.discrepancy_cd > 0)
     temp->addt[x].discrepancy_disp = displayvalue
    ELSE
     temp->addt[x].discrepancy_disp = captions->none
    ENDIF
    temp->addt[x].active_ind = addt.active_ind
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->inc_disagreement=1))
  SELECT INTO "nl:"
   cv.display
   FROM code_value cv
   WHERE cv.code_set=15429
   ORDER BY cv.active_ind, cv.display
   HEAD REPORT
    x = 0
   DETAIL
    x += 1, stat = alterlist(temp->disagree,x), temp->disagree[x].display = cv.display,
    temp->disagree[x].description = cv.description, temp->disagree[x].active_ind = cv.active_ind
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->inc_investigation=1))
  SELECT INTO "nl:"
   cv.display
   FROM code_value cv
   WHERE cv.code_set=15449
   ORDER BY cv.active_ind, cv.display
   HEAD REPORT
    x = 0
   DETAIL
    x += 1, stat = alterlist(temp->investigation,x), temp->investigation[x].display = cv.display,
    temp->investigation[x].description = cv.description, temp->investigation[x].active_ind = cv
    .active_ind
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->inc_resolution=1))
  SELECT INTO "nl:"
   cv.display
   FROM code_value cv
   WHERE cv.code_set=15450
   ORDER BY cv.active_ind, cv.display
   HEAD REPORT
    x = 0
   DETAIL
    x += 1, stat = alterlist(temp->resolution,x), temp->resolution[x].display = cv.display,
    temp->resolution[x].description = cv.description, temp->resolution[x].active_ind = cv.active_ind
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->inc_studies=1))
  SELECT INTO "nl:"
   ads.*, adsrp.*, displayvalue = uar_get_code_display(adsrp.task_assay_cd),
   study_id_exists = evaluate(nullind(adsrp.study_id),1,0,1)
   FROM ap_dc_study ads,
    ap_dc_study_rpt_proc adsrp
   PLAN (ads
    WHERE ads.study_id > 0)
    JOIN (adsrp
    WHERE (adsrp.study_id= Outerjoin(ads.study_id)) )
   ORDER BY ads.description, ads.study_id, displayvalue
   HEAD REPORT
    x = 0
   HEAD ads.study_id
    x += 1, stat = alterlist(temp->study,x), temp->study[x].study_id = ads.study_id,
    temp->study[x].description = ads.description, temp->study[x].across_case_ind = ads
    .across_case_ind, temp->study[x].slide_counts_prompt_ind = ads.slide_counts_prompt_ind,
    temp->study[x].include_cytotechs_ind = ads.include_cytotechs_ind, temp->study[x].
    default_to_group_ind = ads.default_to_group_ind, temp->study[x].active_ind = ads.active_ind,
    y = 0
   DETAIL
    IF (study_id_exists=1)
     IF (adsrp.task_assay_cd > 0)
      y += 1
      IF ((y > temp->max_details))
       temp->max_details = y
      ENDIF
      stat = alterlist(temp->study[x].rpt_proc,y), temp->study[x].rpt_proc[y].task_assay_cd = adsrp
      .task_assay_cd, temp->study[x].rpt_proc[y].task_assay_disp = displayvalue
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#report_maker
 EXECUTE cpm_create_file_name_logical "apsDbDiagCorr", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  d1.seq
  FROM (dummyt d1  WITH seq = 1)
  WHERE d1.seq=1
  HEAD REPORT
   line1 = fillstring(125,"-"), line2 = fillstring(116,"-"), linecenter = fillstring(34,"-"),
   parameters_printed = captions->n, lactiveagreedisagreenum = 0, linactiveagreedisagreenum = 0,
   lactivediscrepancynum = 0, linactivediscrepancynum = 0, lactivedisagreementnum = 0,
   linactivedisagreementnum = 0, lactiveinvestigationnum = 0, linactiveinvestigationnum = 0,
   lactiveresolutionnum = 0, linactiveresolutionnum = 0, lactivestudiesnum = 0,
   linactivestudiesnum = 0
  HEAD PAGE
   row + 1, col 0, captions->rptaps,
   CALL center(captions->ap,0,132), col 110, captions->date,
   col 117, curdate"@SHORTDATE;;Q", row + 1,
   col 0, captions->directory, col 110,
   captions->ttime, col 117, curtime,
   row + 1, col 52,
   CALL center(captions->refdbaudit,0,132),
   col 112, captions->bby, col 117,
   request->scuruser"##############", row + 1,
   CALL center(captions->diagcorparam,0,132),
   col 110, captions->ppage, col 117,
   curpage"###"
  DETAIL
   IF (parameters_printed="N")
    row + 1, col 0, captions->auditparam
    IF ((request->inc_agree_disagree=1))
     row + 1, col 2, captions->includeadterm
    ELSE
     row + 1, col 2, captions->excludeadterm
    ENDIF
    IF ((request->inc_discrepancy=1))
     row + 1, col 2, captions->includediscrepancyterm
    ELSE
     row + 1, col 2, captions->excludediscrepancyterm
    ENDIF
    IF ((request->inc_disagreement=1))
     row + 1, col 2, captions->includedisagreementterm
    ELSE
     row + 1, col 2, captions->excludedisagreementterm
    ENDIF
    IF ((request->inc_investigation=1))
     row + 1, col 2, captions->includeinvestigationterm
    ELSE
     row + 1, col 2, captions->excludeinvestigationterm
    ENDIF
    IF ((request->inc_resolution=1))
     row + 1, col 2, captions->includeresolutionterm
    ELSE
     row + 1, col 2, captions->excluderesolutionterm
    ENDIF
    IF ((request->inc_studies=1))
     row + 1, col 2, captions->includestudies
    ELSE
     row + 1, col 2, captions->excludestudies
    ENDIF
    parameters_printed = captions->y
   ENDIF
   IF ((request->inc_agree_disagree=1))
    row + 2,
    CALL center(linecenter,0,132), row + 1,
    CALL center(captions->adterm,0,132), row + 1,
    CALL center(linecenter,0,132)
    IF (((row+ 10) > maxrow))
     BREAK
    ENDIF
    row + 2,
    CALL center(captions->activeentries,0,132), row + 2,
    col 82, captions->require, col 95,
    captions->require, col 104, captions->require,
    col 119, captions->require, row + 1,
    col 0, captions->code, col 16,
    captions->description, col 69, captions->flag,
    col 82, captions->discrepancy, col 95,
    captions->reason, col 104, captions->investigation,
    col 119, captions->resolution, row + 1,
    col 0, "--------------", col 16,
    "---------------------------------------------------", col 69, "-----------",
    col 82, "-----------", col 95,
    "-------", col 104, "-------------",
    col 119, "----------"
    FOR (loop = 1 TO size(temp->adet,5))
      IF ((temp->adet[loop].active_ind=1))
       lactiveagreedisagreenum += 1, row + 1, col 0,
       temp->adet[loop].display"###############", col 16, temp->adet[loop].description
       "###################################################",
       col 69, temp->adet[loop].agreement_disp"############", col 82,
       captions->no
       IF ((temp->adet[loop].discrepancy_req_ind=1))
        col 82, captions->yes
       ENDIF
       col 95, captions->no, " "
       IF ((temp->adet[loop].reason_req_ind=1))
        col 95, captions->yes
       ENDIF
       col 104, captions->no, " "
       IF ((temp->adet[loop].investigation_req_ind=1))
        col 104, captions->yes
       ENDIF
       col 119, captions->no, " "
       IF ((temp->adet[loop].resolution_req_ind=1))
        col 119, captions->yes
       ENDIF
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
      ENDIF
    ENDFOR
    IF (lactiveagreedisagreenum=0)
     row + 1, col 0, captions->noactiveentries
     IF (((row+ 10) > maxrow))
      BREAK
     ENDIF
    ENDIF
    row + 2,
    CALL center(captions->inactiveentries,0,132)
    FOR (loop = 1 TO size(temp->adet,5))
      IF ((temp->adet[loop].active_ind=0))
       linactiveagreedisagreenum += 1, row + 1, col 0,
       temp->adet[loop].display"###############", col 16, temp->adet[loop].description
       "###################################################",
       col 69, temp->adet[loop].agreement_disp"############", col 82,
       captions->no
       IF ((temp->adet[loop].discrepancy_req_ind=1))
        col 82, captions->yes
       ENDIF
       col 95, captions->no, " "
       IF ((temp->adet[loop].reason_req_ind=1))
        col 95, captions->yes
       ENDIF
       col 104, captions->no, " "
       IF ((temp->adet[loop].investigation_req_ind=1))
        col 104, captions->yes
       ENDIF
       col 119, captions->no, " "
       IF ((temp->adet[loop].resolution_req_ind=1))
        col 119, captions->yes
       ENDIF
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
      ENDIF
    ENDFOR
    IF (linactiveagreedisagreenum=0)
     row + 1, col 0, captions->noinactiveentries
     IF (((row+ 10) > maxrow))
      BREAK
     ENDIF
    ENDIF
   ENDIF
   IF ((request->inc_discrepancy=1))
    row + 2,
    CALL center(linecenter,0,132), row + 1,
    CALL center(captions->discrepancyterm,0,132), row + 1,
    CALL center(linecenter,0,132)
    IF (((row+ 10) > maxrow))
     BREAK
    ENDIF
    row + 2,
    CALL center(captions->activeentries,0,132), row + 1,
    col 0, captions->code, col 16,
    captions->description, col 79, captions->flag,
    row + 1, col 0, "--------------",
    col 16, "-------------------------------------------------------------", col 79,
    "-----------"
    FOR (loop = 1 TO size(temp->addt,5))
      IF ((temp->addt[loop].active_ind=1))
       lactivediscrepancynum += 1, row + 1, col 0,
       temp->addt[loop].display"###############", col 16, temp->addt[loop].description
       "###################################################",
       col 79, temp->addt[loop].discrepancy_disp"############"
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
      ENDIF
    ENDFOR
    IF (lactivediscrepancynum=0)
     row + 1, col 0, captions->noactiveentries
     IF (((row+ 10) > maxrow))
      BREAK
     ENDIF
    ENDIF
    row + 2,
    CALL center(captions->inactiveentries,0,132)
    FOR (loop = 1 TO size(temp->addt,5))
      IF ((temp->addt[loop].active_ind=0))
       linactivediscrepancynum += 1, row + 1, col 0,
       temp->addt[loop].display"###############", col 16, temp->addt[loop].description
       "###################################################",
       col 79, temp->addt[loop].discrepancy_disp"############"
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
      ENDIF
    ENDFOR
    IF (linactivediscrepancynum=0)
     row + 1, col 0, captions->noinactiveentries
     IF (((row+ 10) > maxrow))
      BREAK
     ENDIF
    ENDIF
   ENDIF
   IF ((request->inc_disagreement=1))
    row + 2,
    CALL center(linecenter,0,132), row + 1,
    CALL center(captions->disagreementterm,0,132), row + 1,
    CALL center(linecenter,0,132)
    IF (((row+ 10) > maxrow))
     BREAK
    ENDIF
    row + 2,
    CALL center(captions->activeentries,0,132), row + 1,
    col 0, captions->code, col 16,
    captions->description, row + 1, col 0,
    "--------------", col 16, "-------------------------------------------------------------"
    FOR (loop = 1 TO size(temp->disagree,5))
      IF ((temp->disagree[loop].active_ind=1))
       lactivedisagreementnum += 1, row + 1, col 0,
       temp->disagree[loop].display"###############", col 16, temp->disagree[loop].description
       "###################################################"
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
      ENDIF
    ENDFOR
    IF (lactivedisagreementnum=0)
     row + 1, col 0, captions->noactiveentries
     IF (((row+ 10) > maxrow))
      BREAK
     ENDIF
    ENDIF
    row + 2,
    CALL center(captions->inactiveentries,0,132)
    FOR (loop = 1 TO size(temp->disagree,5))
      IF ((temp->disagree[loop].active_ind=0))
       linactivedisagreementnum += 1, row + 1, col 0,
       temp->disagree[loop].display"###############", col 16, temp->disagree[loop].description
       "###################################################"
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
      ENDIF
    ENDFOR
    IF (linactivedisagreementnum=0)
     row + 1, col 0, captions->noinactiveentries
     IF (((row+ 10) > maxrow))
      BREAK
     ENDIF
    ENDIF
   ENDIF
   IF ((request->inc_investigation=1))
    row + 2,
    CALL center(linecenter,0,132), row + 1,
    CALL center(captions->investigationterm,0,132), row + 1,
    CALL center(linecenter,0,132)
    IF (((row+ 10) > maxrow))
     BREAK
    ENDIF
    row + 2,
    CALL center(captions->activeentries,0,132), row + 1,
    col 0, captions->code, col 16,
    captions->description, row + 1, col 0,
    "--------------", col 16, "-------------------------------------------------------------"
    FOR (loop = 1 TO size(temp->investigation,5))
      IF ((temp->investigation[loop].active_ind=1))
       lactiveinvestigationnum += 1, row + 1, col 0,
       temp->investigation[loop].display"###############", col 16, temp->investigation[loop].
       description"###################################################"
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
      ENDIF
    ENDFOR
    IF (lactiveinvestigationnum=0)
     row + 1, col 0, captions->noactiveentries
     IF (((row+ 10) > maxrow))
      BREAK
     ENDIF
    ENDIF
    row + 2,
    CALL center(captions->inactiveentries,0,132)
    FOR (loop = 1 TO size(temp->investigation,5))
      IF ((temp->investigation[loop].active_ind=0))
       linactiveinvestigationnum += 1, row + 1, col 0,
       temp->investigation[loop].display"###############", col 16, temp->investigation[loop].
       description"###################################################"
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
      ENDIF
    ENDFOR
    IF (linactiveinvestigationnum=0)
     row + 1, col 0, captions->noinactiveentries
     IF (((row+ 10) > maxrow))
      BREAK
     ENDIF
    ENDIF
   ENDIF
   IF ((request->inc_resolution=1))
    row + 2,
    CALL center(linecenter,0,132), row + 1,
    CALL center(captions->resolutionterm,0,132), row + 1,
    CALL center(linecenter,0,132)
    IF (((row+ 10) > maxrow))
     BREAK
    ENDIF
    row + 2,
    CALL center(captions->activeentries,0,132), row + 1,
    col 0, captions->code, col 16,
    captions->description, row + 1, col 0,
    "--------------", col 16, "-------------------------------------------------------------"
    FOR (loop = 1 TO size(temp->resolution,5))
      IF ((temp->resolution[loop].active_ind=1))
       lactiveresolutionnum += 1, row + 1, col 0,
       temp->resolution[loop].display"###############", col 16, temp->resolution[loop].description
       "###################################################"
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
      ENDIF
    ENDFOR
    IF (lactiveresolutionnum=0)
     row + 1, col 0, captions->noactiveentries
     IF (((row+ 10) > maxrow))
      BREAK
     ENDIF
    ENDIF
    row + 2,
    CALL center(captions->inactiveentries,0,132)
    FOR (loop = 1 TO size(temp->resolution,5))
      IF ((temp->resolution[loop].active_ind=0))
       linactiveresolutionnum += 1, row + 1, col 0,
       temp->resolution[loop].display"###############", col 16, temp->resolution[loop].description
       "###################################################"
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
      ENDIF
    ENDFOR
    IF (linactiveresolutionnum=0)
     row + 1, col 0, captions->noinactiveentries
     IF (((row+ 10) > maxrow))
      BREAK
     ENDIF
    ENDIF
   ENDIF
   IF ((request->inc_studies=1))
    row + 2,
    CALL center(linecenter,0,132), row + 1,
    CALL center(captions->diagcorrstudies,0,132), row + 1,
    CALL center(linecenter,0,132)
    IF (((row+ 10) > maxrow))
     BREAK
    ENDIF
    row + 2,
    CALL center(captions->activeentries,0,132), row + 1
    IF (((row+ 10) > maxrow))
     BREAK
    ENDIF
    FOR (loop = 1 TO size(temp->study,5))
      IF ((temp->study[loop].active_ind=1))
       lactivestudiesnum += 1, row + 1, col 0,
       captions->study, col 7, temp->study[loop].description,
       row + 1, col 8, captions->acrosscasecorrelation
       IF ((temp->study[loop].across_case_ind=1))
        col 34, captions->yes
       ELSE
        col 34, captions->no
       ENDIF
       row + 1, col 8, captions->tallycytoslidecounts
       IF ((temp->study[loop].slide_counts_prompt_ind=1))
        col 48, captions->yes
       ELSE
        col 48, captions->no
       ENDIF
       row + 1, col 8, captions->defaultto
       IF ((temp->study[loop].default_to_group_ind=1))
        col 21, captions->group
       ELSE
        col 21, captions->individual
       ENDIF
       row + 1, col 8, captions->includecytotechs
       IF ((temp->study[loop].include_cytotechs_ind=1))
        col 36, captions->yes
       ELSE
        col 36, captions->no
       ENDIF
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
       row + 1, col 8, captions->reporttaskforreport
       IF (size(temp->study[loop].rpt_proc,5) > 0)
        FOR (loop2 = 1 TO size(temp->study[loop].rpt_proc,5))
          col 52, temp->study[loop].rpt_proc[loop2].task_assay_disp, row + 1
          IF (((row+ 10) > maxrow))
           BREAK, row + 1, row + 1,
           col 8, captions->continued, "  ",
           temp->study[loop].description, row + 1
          ENDIF
        ENDFOR
        row + 1
       ELSE
        col 52, captions->notdefined, row + 2
       ENDIF
      ENDIF
    ENDFOR
    IF (lactivestudiesnum=0)
     row + 1, col 0, captions->noactiveentries
     IF (((row+ 10) > maxrow))
      BREAK
     ENDIF
    ENDIF
    row + 2,
    CALL center(captions->inactiveentries,0,132)
    FOR (loop = 1 TO size(temp->study,5))
      IF ((temp->study[loop].active_ind=0))
       linactivestudiesnum += 1, row + 1, col 0,
       captions->study, "  ", col 7,
       temp->study[loop].description, row + 1, col 8,
       captions->acrosscasecorrelation, "  "
       IF ((temp->study[loop].across_case_ind=1))
        col 34, captions->yes
       ELSE
        col 34, captions->no
       ENDIF
       row + 1, col 8, captions->tallycytoslidecounts
       IF ((temp->study[loop].slide_counts_prompt_ind=1))
        col 47, captions->yes
       ELSE
        col 47, captions->no
       ENDIF
       row + 1, col 8, captions->defaultto
       IF ((temp->study[loop].default_to_group_ind=1))
        col 19, captions->group
       ELSE
        col 19, captions->individual
       ENDIF
       row + 1, col 8, captions->includecytotechs
       IF ((temp->study[loop].include_cytotechs_ind=1))
        col 36, captions->yes
       ELSE
        col 36, captions->no
       ENDIF
       IF (((row+ 10) > maxrow))
        BREAK
       ENDIF
       row + 1, col 8, captions->reporttaskforreport,
       "  "
       IF (size(temp->study[loop].rpt_proc,5) > 0)
        FOR (loop2 = 1 TO size(temp->study[loop].rpt_proc,5))
          col 52, temp->study[loop].rpt_proc[loop2].task_assay_disp, row + 1
          IF (((row+ 10) > maxrow))
           BREAK, row + 1, row + 1,
           col 8, captions->continued, "  ",
           temp->study[loop].description, row + 1
          ENDIF
        ENDFOR
        row + 1
       ELSE
        col 52, captions->notdefined, row + 2
       ENDIF
      ENDIF
    ENDFOR
    IF (linactivestudiesnum=0)
     row + 1, col 0, captions->noinactiveentries
     IF (((row+ 10) > maxrow))
      BREAK
     ENDIF
    ENDIF
   ENDIF
  FOOT PAGE
   row 60, col 0, line1,
   row + 1, col 0, captions->rptaps,
   today = concat(week," ",day), col 53, today,
   col 110, captions->ppage, col 117,
   curpage"###", row + 1, col 55,
   captions->continued2
  FOOT REPORT
   col 55, "##########                              "
  WITH nocounter, maxcol = 132, nullreport,
   maxrow = 63, compress
 ;end select
 SET reply->status_data.status = "S"
END GO
