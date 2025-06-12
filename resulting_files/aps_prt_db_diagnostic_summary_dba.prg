CREATE PROGRAM aps_prt_db_diagnostic_summary:dba
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
 RECORD temp(
   1 qual_report[*]
     2 site_disp = vc
     2 prefix_name = vc
     2 discrete_task_assay = vc
     2 required_ind = vc
     2 comment_ind = vc
     2 comment_length_qty = i4
 )
 RECORD captions(
   1 rpt = vc
   1 rpt_nm = vc
   1 ana = vc
   1 dt = vc
   1 dir = vc
   1 tm = vc
   1 ref_data = vc
   1 bye = vc
   1 username = vc
   1 pg = vc
   1 title = vc
   1 rpt_cont = vc
   1 rpt_end = vc
   1 prefix = vc
   1 required_ind = vc
   1 comment_ind = vc
   1 comment_length_qty = vc
   1 dta = vc
 )
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 SET captions->rpt = "Report: "
 SET captions->rpt_nm = uar_i18ngetmessage(i18nhandle,"t1","Aps_prt_db_diagnostic_summary.prg")
 SET captions->ana = uar_i18ngetmessage(i18nhandle,"t2","Anatomic Pathology")
 SET captions->dt = uar_i18ngetmessage(i18nhandle,"t3","Date: ")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"t4","DIRECTORY: ")
 SET captions->tm = uar_i18ngetmessage(i18nhandle,"t5","TIME:")
 SET captions->ref_data = uar_i18ngetmessage(i18nhandle,"t6",
  "REFERENCE DATABASE AUDIT - DB DIAGNOSIS SUMMARY")
 SET captions->bye = uar_i18ngetmessage(i18nhandle,"t7","BY: ")
 SET captions->pg = uar_i18ngetmessage(i18nhandle,"t8","PAGE: ")
 SET captions->title = uar_i18ngetmessage(i18nhandle,"t9","DB DIAGNOSIS SUMMARY DATABASE AUDIT")
 SET captions->rpt_cont = uar_i18ngetmessage(i18nhandle,"t10","Continue")
 SET captions->rpt_end = uar_i18ngetmessage(i18nhandle,"t11","End of Report")
 SET captions->prefix = uar_i18ngetmessage(i18nhandle,"t13","Prefix")
 SET captions->required_ind = uar_i18ngetmessage(i18nhandle,"t14","Use Diagnosis Summary")
 SET captions->comment_ind = uar_i18ngetmessage(i18nhandle,"t15","Use Comment")
 SET captions->comment_length_qty = uar_i18ngetmessage(i18nhandle,"t16","Comment Length")
 SET captions->dta = uar_i18ngetmessage(i18nhandle,"t21","DTA")
#script
 SET reply->status_data.status = "F"
 DECLARE nprefixcnt = i2 WITH protect, noconstant(0)
 DECLARE csitecode = c7
 DECLARE csiteformat = c5 WITH protect, constant("00000")
 DECLARE dgyn = f8 WITH protect, constant(uar_get_code_by("MEANING",1301,"GYN"))
 DECLARE dngyn = f8 WITH protect, constant(uar_get_code_by("MEANING",1301,"NGYN"))
 DECLARE nreportcnt = i2 WITH protect, noconstant(0)
 SELECT
  p.username
  FROM prsnl p
  WHERE (p.person_id=reqinfo->updt_id)
  DETAIL
   captions->username = p.username
  WITH nocounter
 ;end select
 SELECT
  apds.prefix_id, apds.comment_length_qty, apds.required_ind,
  apds.comment_ind, app.prefix_name, app.site_cd
  FROM ap_prefix_diag_smry apds,
   ap_prefix app
  PLAN (apds)
   JOIN (app
   WHERE apds.prefix_id=app.prefix_id
    AND app.active_ind=1
    AND  NOT (app.case_type_cd IN (dgyn, dngyn)))
  DETAIL
   nprefixcnt = (nprefixcnt+ 1)
   IF (nprefixcnt > size(temp->qual_report,5))
    stat = alterlist(temp->qual_report,(nprefixcnt+ 9))
   ENDIF
   csitecode = uar_get_code_display(app.site_cd)
   IF (cnvtint(csitecode) != 0)
    temp->qual_report[nprefixcnt].site_disp = build(substring(1,(acc_settings->site_code_length -
      textlen(trim(cnvtstring(cnvtint(csitecode))))),csiteformat),cnvtint(csitecode))
   ENDIF
   temp->qual_report[nprefixcnt].prefix_name = build2(temp->qual_report[nprefixcnt].site_disp," ",app
    .prefix_name), temp->qual_report[nprefixcnt].discrete_task_assay = uar_get_code_display(apds
    .task_assay_cd)
   IF (apds.required_ind=1)
    temp->qual_report[nprefixcnt].required_ind = uar_i18ngetmessage(i18nhandle,"t17","YES")
   ELSE
    temp->qual_report[nprefixcnt].required_ind = uar_i18ngetmessage(i18nhandle,"t18","NO")
   ENDIF
   IF (apds.comment_ind=1)
    temp->qual_report[nprefixcnt].comment_ind = uar_i18ngetmessage(i18nhandle,"t19","YES")
   ELSE
    temp->qual_report[nprefixcnt].comment_ind = uar_i18ngetmessage(i18nhandle,"t20","NO")
   ENDIF
   temp->qual_report[nprefixcnt].comment_length_qty = apds.comment_length_qty
  FOOT REPORT
   stat = alterlist(temp->qual_report,nprefixcnt)
  WITH nocounter
 ;end select
 EXECUTE cpm_create_file_name_logical "apsDbDiagSumm", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO cpm_cfn_info->file_name_logical
  FROM (dummyt d  WITH seq = evaluate(nprefixcnt,0,1,nprefixcnt))
  WHERE d.seq <= nprefixcnt
  ORDER BY temp->qual_report[d.seq].prefix_name
  HEAD REPORT
   dotted_line1 = fillstring(129,"-")
  HEAD PAGE
   date1 = format(curdate,"@SHORTDATE;;D"), time1 = format(curtime,"@TIMENOSECONDS;;M"), nreportcnt
    = 0,
   row + 1, col 0, captions->rpt,
   col 8, captions->rpt_nm,
   CALL center(captions->ana,0,132),
   col 110, captions->dt, col 117,
   date1, row + 1, col 0,
   captions->dir, col 110, captions->tm,
   col 117, time1, row + 1,
   col 52,
   CALL center(captions->ref_data,0,132), col 112,
   captions->bye, col 117, captions->username"##############",
   row + 1, col 110, captions->pg,
   col 117, curpage"###", row + 1,
   col 0, dotted_line1, row + 1,
   col 3, captions->prefix, col 24,
   captions->dta, col 53, captions->required_ind,
   col 80, captions->comment_ind, col 96,
   captions->comment_length_qty, row + 1, col 0,
   dotted_line1, row + 1
  DETAIL
   nreportcnt = (nreportcnt+ 1), row + 1, col 3,
   temp->qual_report[d.seq].prefix_name, col 18, temp->qual_report[d.seq].discrete_task_assay,
   col 58, temp->qual_report[d.seq].required_ind, col 81,
   temp->qual_report[d.seq].comment_ind, col 95, temp->qual_report[d.seq].comment_length_qty
  FOOT PAGE
   wk = format(curdate,"@WEEKDAYABBREV;;D"), day = format(curdate,"@MEDIUMDATE4YR;;D"), today =
   concat(wk," ",day),
   row 60, col 0, dotted_line1,
   row + 1, col 0, captions->title,
   col 53, today, col 110,
   captions->pg, col 117, curpage"###"
   IF (nprefixcnt > nreportcnt)
    row + 1, col 55, captions->rpt_cont
   ENDIF
  FOOT REPORT
   row + 1, col 55, captions->rpt_end
  WITH nocounter, nullreport, maxcol = 132,
   maxrow = 63, compress
 ;end select
 IF (nprefixcnt > 0)
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
