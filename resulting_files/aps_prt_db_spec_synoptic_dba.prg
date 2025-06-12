CREATE PROGRAM aps_prt_db_spec_synoptic:dba
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
   1 dbsgt = vc
   1 ppage = vc
   1 stpref = vc
   1 cont = vc
   1 stspec = vc
   1 stallowed = vc
   1 stsuggested = vc
   1 strequired = vc
   1 stunknown = vc
   1 stpref = vc
   1 stworksheet = vc
   1 stsuggest = vc
   1 stallothers = vc
   1 stnowrksheets = vc
   1 stmissingrptmsg = vc
 )
 SET captions->rptaps = uar_i18ngetmessage(i18nhandle,"rptaps","REPORT: APS_PRT_DB_SPEC_SYNOPTIC.PRG"
  )
 SET captions->pathap = uar_i18ngetmessage(i18nhandle,"pathap","PATHNET ANATOMIC PATHOLOGY")
 SET captions->ddate = uar_i18ngetmessage(i18nhandle,"ddate","DATE")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"dir","DIRECTORY")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"ttime","TIME")
 SET captions->rda = uar_i18ngetmessage(i18nhandle,"rda","REFERENCE DATABASE AUDIT")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"bby","BY")
 SET captions->dbsgt = uar_i18ngetmessage(i18nhandle,"dbsgt",
  "DB MAINTAIN SYNOPTIC SPECIMEN WORKSHEETS")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"ppage","PAGE")
 SET captions->stpref = uar_i18ngetmessage(i18nhandle,"stpref","Prefix")
 SET captions->cont = uar_i18ngetmessage(i18nhandle,"cont","CONTINUED...")
 SET captions->stallowed = uar_i18ngetmessage(i18nhandle,"stAllowed","No")
 SET captions->stsuggested = uar_i18ngetmessage(i18nhandle,"stSuggested","Yes")
 SET captions->stunknown = uar_i18ngetmessage(i18nhandle,"stUnknown","")
 SET captions->stspec = uar_i18ngetmessage(i18nhandle,"stspec","Specimen")
 SET captions->stworksheet = uar_i18ngetmessage(i18nhandle,"stworksheet","Worksheet")
 SET captions->stsuggest = uar_i18ngetmessage(i18nhandle,"stsuggest","Suggested")
 SET captions->stallothers = uar_i18ngetmessage(i18nhandle,"stallothers","<All Others>")
 SET captions->stnowrksheets = uar_i18ngetmessage(i18nhandle,"stnowrksheets","<No Worksheets>")
 SET captions->stmissingrptmsg = uar_i18ngetmessage(i18nhandle,"stMissingRptMsg",
  "No report sections hooked to this worksheet!")
 DECLARE site_format = c5 WITH protect, constant("00000")
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
 IF ((validate(accession_common_version,- (1))=- (1)))
  DECLARE accession_common_version = i2 WITH constant(0)
  DECLARE acc_success = i2 WITH constant(0)
  DECLARE acc_error = i2 WITH constant(1)
  DECLARE acc_future = i2 WITH constant(2)
  DECLARE acc_null_dt_tm = i2 WITH constant(3)
  DECLARE acc_template = i2 WITH constant(300)
  DECLARE acc_pool = i2 WITH constant(310)
  DECLARE acc_pool_sequence = i2 WITH constant(320)
  DECLARE acc_duplicate = i2 WITH constant(410)
  DECLARE acc_modify = i2 WITH constant(420)
  DECLARE acc_sequence_id = i2 WITH constant(430)
  DECLARE acc_insert = i2 WITH constant(440)
  DECLARE acc_pool_id = i2 WITH constant(450)
  DECLARE acc_aor_false = i2 WITH constant(500)
  DECLARE acc_aor_true = i2 WITH constant(501)
  DECLARE acc_person_false = i2 WITH constant(502)
  DECLARE acc_person_true = i2 WITH constant(503)
  DECLARE site_length = i2 WITH constant(5)
  DECLARE julian_sequence_length = i2 WITH constant(6)
  DECLARE prefix_sequence_length = i2 WITH constant(7)
  DECLARE accession_status = i4 WITH noconstant(acc_success)
  DECLARE accession_meaning = c200 WITH noconstant(fillstring(200," "))
  RECORD acc_settings(
    1 acc_settings_loaded = i2
    1 site_code_length = i4
    1 julian_sequence_length = i4
    1 alpha_sequence_length = i4
    1 year_display_length = i4
    1 default_site_cd = f8
    1 default_site_prefix = c5
    1 assignment_days = i4
    1 assignment_dt_tm = dq8
    1 check_disp_ind = i2
  )
  RECORD accession_fmt(
    1 time_ind = i2
    1 insert_aor_ind = i2
    1 cpri_lookup = i2
    1 act_lookup = i2
    1 qual[*]
      2 order_id = f8
      2 catalog_cd = f8
      2 facility_cd = f8
      2 site_prefix_cd = f8
      2 site_prefix_disp = c5
      2 accession_format_cd = f8
      2 accession_format_mean = c12
      2 accession_class_cd = f8
      2 specimen_type_cd = f8
      2 accession_dt_tm = dq8
      2 accession_day = i4
      2 accession_year = i4
      2 alpha_prefix = c2
      2 accession_seq_nbr = i4
      2 accession_pool_id = f8
      2 assignment_meaning = vc
      2 assignment_status = i2
      2 accession_id = f8
      2 accession = c20
      2 accession_formatted = c25
      2 activity_type_cd = f8
      2 activity_type_mean = c12
      2 order_tag = i2
      2 accession_info_pos = i2
      2 accession_flag = i2
      2 collection_priority_cd = f8
      2 group_with_other_flag = i2
      2 accession_parent = i2
      2 body_site_cd = f8
      2 body_site_ind = i2
      2 specimen_type_ind = i2
      2 service_area_cd = f8
      2 linked_qual[*]
        3 linked_pos = i2
  )
  RECORD accession_grp(
    1 cpri_lookup = i2
    1 act_lookup = i2
    1 qual[*]
      2 catalog_cd = f8
      2 specimen_type_cd = f8
      2 site_prefix_cd = f8
      2 accession_format_cd = f8
      2 accession_class_cd = f8
      2 accession_dt_tm = dq8
      2 accession_pool_id = f8
      2 accession_id = f8
      2 accession = c20
      2 activity_type_cd = f8
      2 accession_flag = i2
      2 collection_priority_cd = f8
      2 group_with_other_flag = i2
      2 body_site_cd = f8
      2 service_area_cd = f8
  )
  DECLARE accession_nbr = c20 WITH noconstant(fillstring(20," "))
  DECLARE accession_nbr_chk = c50 WITH noconstant(fillstring(50," "))
  RECORD accession_str(
    1 site_prefix_disp = c5
    1 accession_year = i4
    1 accession_day = i4
    1 alpha_prefix = c2
    1 accession_seq_nbr = i4
    1 accession_pool_id = f8
  )
  DECLARE acc_site_prefix_cd = f8 WITH noconstant(0.0)
  DECLARE acc_site_prefix = c5 WITH noconstant(fillstring(value(site_length)," "))
  DECLARE accession_id = f8 WITH noconstant(0.0)
  DECLARE accession_dup_id = f8 WITH noconstant(0.0)
  DECLARE accession_updt_cnt = i4 WITH noconstant(0)
  DECLARE accession_assignment_ind = i2 WITH noconstant(0)
  RECORD accession_chk(
    1 check_disp_ind = i2
    1 site_prefix_cd = f8
    1 accession_year = i4
    1 accession_day = i4
    1 accession_pool_id = f8
    1 accession_seq_nbr = i4
    1 accession_class_cd = f8
    1 accession_format_cd = f8
    1 alpha_prefix = c2
    1 accession_id = f8
    1 accession = c20
    1 accession_nbr_check = c50
    1 accession_updt_cnt = i4
    1 action_ind = i2
    1 preactive_ind = i2
    1 assignment_ind = i2
  )
 ENDIF
 RECORD temp(
   1 max_nbr_pref = i4
   1 max_nbr_scr = i4
   1 spec_qual[*]
     2 specimen_cd = f8
     2 specimen_display = c40
     2 pref_qual[*]
       3 prefix_id = f8
       3 prefix_name = c2
       3 site_cd = f8
       3 site_display = c40
       3 scr_qual[*]
         4 scr_pattern_id = f8
         4 scr_display = c60
         4 sequence = i4
         4 suggest_flag = i4
         4 missing_rpt_msg = vc
 )
 SET reply->status_data.status = "F"
 EXECUTE accession_settings
 IF (accession_status != acc_success)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  specimen_display = uar_get_code_display(syn.specimen_cd), prefix_name = ap.prefix_name,
  site_unformatted = uar_get_code_display(ap.site_cd),
  scr_display = scr.display, specimen_cd = syn.specimen_cd, prefix_id = ap.prefix_id
  FROM ap_synoptic_spec_prefix_r syn,
   ap_prefix ap,
   dummyt d,
   scr_pattern scr
  PLAN (syn)
   JOIN (ap
   WHERE ap.prefix_id=syn.prefix_id)
   JOIN (d)
   JOIN (scr
   WHERE scr.cki_source=syn.cki_source
    AND scr.cki_identifier=syn.cki_identifier)
  ORDER BY specimen_cd, prefix_id
  HEAD REPORT
   spec_cntr = 0, pref_cntr = 0, scr_cntr = 0
  HEAD specimen_cd
   spec_cntr = (spec_cntr+ 1)
   IF (mod(spec_cntr,10)=1)
    stat = alterlist(temp->spec_qual,(spec_cntr+ 9))
   ENDIF
   temp->spec_qual[spec_cntr].specimen_cd = syn.specimen_cd, temp->spec_qual[spec_cntr].
   specimen_display = specimen_display, pref_cntr = 0
  HEAD prefix_id
   pref_cntr = (pref_cntr+ 1)
   IF ((pref_cntr > temp->max_nbr_pref))
    temp->max_nbr_pref = pref_cntr
   ENDIF
   stat = alterlist(temp->spec_qual[spec_cntr].pref_qual,pref_cntr), temp->spec_qual[spec_cntr].
   pref_qual[pref_cntr].prefix_id = syn.prefix_id, temp->spec_qual[spec_cntr].pref_qual[pref_cntr].
   prefix_name = prefix_name,
   temp->spec_qual[spec_cntr].pref_qual[pref_cntr].site_cd = ap.site_cd
   IF (cnvtint(site_unformatted) != 0)
    temp->spec_qual[spec_cntr].pref_qual[pref_cntr].site_display = build(substring(1,(acc_settings->
      site_code_length - textlen(trim(cnvtstring(cnvtint(site_unformatted))))),site_format),cnvtint(
      site_unformatted))
   ELSE
    temp->spec_qual[spec_cntr].pref_qual[pref_cntr].site_display = " "
   ENDIF
   scr_cntr = 0
  DETAIL
   scr_cntr = (scr_cntr+ 1), stat = alterlist(temp->spec_qual[spec_cntr].pref_qual[pref_cntr].
    scr_qual,scr_cntr)
   IF ((scr_cntr > temp->max_nbr_scr))
    temp->max_nbr_scr = scr_cntr
   ENDIF
   IF (trim(syn.cki_identifier) != ""
    AND scr.scr_pattern_id=0)
    temp->spec_qual[spec_cntr].pref_qual[pref_cntr].scr_qual[scr_cntr].scr_pattern_id = - (1), temp->
    spec_qual[spec_cntr].pref_qual[pref_cntr].scr_qual[scr_cntr].scr_display = build("<",syn
     .cki_identifier,">"), temp->spec_qual[spec_cntr].pref_qual[pref_cntr].scr_qual[scr_cntr].
    missing_rpt_msg = "",
    temp->spec_qual[spec_cntr].pref_qual[pref_cntr].scr_qual[scr_cntr].suggest_flag = 3
   ELSEIF (trim(syn.cki_identifier) != "")
    temp->spec_qual[spec_cntr].pref_qual[pref_cntr].scr_qual[scr_cntr].scr_pattern_id = scr
    .scr_pattern_id, temp->spec_qual[spec_cntr].pref_qual[pref_cntr].scr_qual[scr_cntr].scr_display
     = scr_display, temp->spec_qual[spec_cntr].pref_qual[pref_cntr].scr_qual[scr_cntr].
    missing_rpt_msg = captions->stmissingrptmsg,
    temp->spec_qual[spec_cntr].pref_qual[pref_cntr].scr_qual[scr_cntr].suggest_flag = syn
    .suggested_flag
   ELSE
    temp->spec_qual[spec_cntr].pref_qual[pref_cntr].scr_qual[scr_cntr].scr_pattern_id = 0, temp->
    spec_qual[spec_cntr].pref_qual[pref_cntr].scr_qual[scr_cntr].scr_display = captions->
    stnowrksheets, temp->spec_qual[spec_cntr].pref_qual[pref_cntr].scr_qual[scr_cntr].missing_rpt_msg
     = "",
    temp->spec_qual[spec_cntr].pref_qual[pref_cntr].scr_qual[scr_cntr].suggest_flag = 3
   ENDIF
   temp->spec_qual[spec_cntr].pref_qual[pref_cntr].scr_qual[scr_cntr].sequence = syn.sequence
  FOOT REPORT
   stat = alterlist(temp->spec_qual,spec_cntr)
  WITH nocounter, outerjoin = d
 ;end select
 SELECT INTO "nl:"
  rpt.*
  FROM ap_synoptic_rpt_section_r rpt,
   scr_pattern scr,
   (dummyt d1  WITH seq = value(size(temp->spec_qual,5))),
   (dummyt d2  WITH seq = value(temp->max_nbr_pref)),
   (dummyt d3  WITH seq = value(temp->max_nbr_scr))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->spec_qual[d1.seq].pref_qual,5))
   JOIN (d3
   WHERE d3.seq <= size(temp->spec_qual[d1.seq].pref_qual[d2.seq].scr_qual,5))
   JOIN (scr
   WHERE (scr.scr_pattern_id=temp->spec_qual[d1.seq].pref_qual[d2.seq].scr_qual[d3.seq].
   scr_pattern_id))
   JOIN (rpt
   WHERE rpt.cki_source=scr.cki_source
    AND rpt.cki_identifier=scr.cki_identifier)
  DETAIL
   temp->spec_qual[d1.seq].pref_qual[d2.seq].scr_qual[d3.seq].missing_rpt_msg = ""
  WITH nocounter
 ;end select
#report_maker
 EXECUTE cpm_create_file_name_logical "apsDbSpSyn", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name
 SELECT INTO value(cpm_cfn_info->file_name_logical)
  specimen_display = temp->spec_qual[d1.seq].specimen_display, specimen_sort = cnvtupper(temp->
   spec_qual[d1.seq].specimen_display), site_pref_display = evaluate(temp->spec_qual[d1.seq].
   pref_qual[d2.seq].prefix_id,0.00,captions->stallothers,build(temp->spec_qual[d1.seq].pref_qual[d2
    .seq].site_display,temp->spec_qual[d1.seq].pref_qual[d2.seq].prefix_name)),
  sequence = temp->spec_qual[d1.seq].pref_qual[d2.seq].scr_qual[d3.seq].sequence, scr_display = temp
  ->spec_qual[d1.seq].pref_qual[d2.seq].scr_qual[d3.seq].scr_display, suggest_flag = temp->spec_qual[
  d1.seq].pref_qual[d2.seq].scr_qual[d3.seq].suggest_flag,
  missing_rpt_msg = temp->spec_qual[d1.seq].pref_qual[d2.seq].scr_qual[d3.seq].missing_rpt_msg
  FROM (dummyt d1  WITH seq = value(size(temp->spec_qual,5))),
   (dummyt d2  WITH seq = value(temp->max_nbr_pref)),
   (dummyt d3  WITH seq = value(temp->max_nbr_scr))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->spec_qual[d1.seq].pref_qual,5))
   JOIN (d3
   WHERE d3.seq <= size(temp->spec_qual[d1.seq].pref_qual[d2.seq].scr_qual,5))
  ORDER BY specimen_sort, site_pref_display, sequence
  HEAD REPORT
   line1 = fillstring(125,"-")
  HEAD PAGE
   row + 1, col 0, captions->rptaps,
   CALL center(captions->pathap,0,132), col 110, captions->ddate,
   ":", cdate = format(curdate,"@SHORTDATE;;d"), col 117,
   cdate, row + 1, col 0,
   captions->dir, ":", col 110,
   captions->ttime, ":", col 117,
   curtime, row + 1,
   CALL center(captions->rda,0,132),
   col 112, captions->bby, ":",
   col 117, request->scuruser"##############", row + 1,
   CALL center(captions->dbsgt,0,132), col 110, captions->ppage,
   ":", col 117, curpage"###",
   row + 1, col 5, captions->stspec,
   col 30, captions->stpref, col 52,
   captions->stworksheet, col 82, captions->stsuggest,
   row + 1, col 5, "--------",
   col 30, "------", col 52,
   "---------", col 82, "---------"
  HEAD specimen_sort
   IF ((((row+ temp->max_nbr_pref)+ 2) > maxrow))
    BREAK
   ENDIF
   row + 1, col 5, specimen_display
  DETAIL
   col 30, site_pref_display, col 47,
   sequence, col 52, scr_display,
   col 82
   CASE (suggest_flag)
    OF 0:
     captions->stallowed
    OF 1:
     captions->stsuggested
    ELSE
     captions->stunknown
   ENDCASE
   IF (trim(missing_rpt_msg) != "")
    row + 1, col 52, missing_rpt_msg
   ENDIF
   row + 1
  FOOT PAGE
   row 60, col 0, line1,
   row + 1, col 0, captions->rptaps,
   today = concat(format(curdate,"@WEEKDAYABBREV;;d")," ",format(curdate,"@MEDIUMDATE4YR;;d")), col
   53, today,
   col 110, captions->ppage, ":",
   col 117, curpage"###", row + 1,
   col 55, captions->cont
  FOOT REPORT
   col 55, "##########                              "
  WITH nocounter, maxcol = 132, nullreport,
   maxrow = 63, compress
 ;end select
 SET reply->status_data.status = "S"
#exit_script
END GO
