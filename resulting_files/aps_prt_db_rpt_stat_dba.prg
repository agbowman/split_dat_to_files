CREATE PROGRAM aps_prt_db_rpt_stat:dba
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
   1 dbrst = vc
   1 ppage = vc
   1 status = vc
   1 code = vc
   1 desc = vc
   1 active = vc
   1 inactive = vc
   1 rsa = vc
   1 rpt = vc
   1 tskassay = vc
   1 rptstat = vc
   1 cancel = vc
   1 cont = vc
   1 yep = vc
   1 nope = vc
 )
 SET captions->rptaps = uar_i18ngetmessage(i18nhandle,"rptaps","REPORT: APS_PRT_DB_RPT_STAT.PRG")
 SET captions->pathap = uar_i18ngetmessage(i18nhandle,"pathap","PATHNET ANATOMIC PATHOLOGY")
 SET captions->ddate = uar_i18ngetmessage(i18nhandle,"ddate","DATE")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"dir","DIRECTORY")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"ttime","TIME")
 SET captions->rda = uar_i18ngetmessage(i18nhandle,"rda","REFERENCE DATABASE AUDIT")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"bby","BY")
 SET captions->dbrst = uar_i18ngetmessage(i18nhandle,"dbrst","DB REPORT STATUS TOOL")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"ppage","PAGE")
 SET captions->status = uar_i18ngetmessage(i18nhandle,"status","STATUS")
 SET captions->code = uar_i18ngetmessage(i18nhandle,"code","CODE")
 SET captions->desc = uar_i18ngetmessage(i18nhandle,"desc","DESCRIPTION")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","ACTIVE")
 SET captions->inactive = uar_i18ngetmessage(i18nhandle,"inactive","INACTIVE")
 SET captions->rsa = uar_i18ngetmessage(i18nhandle,"rsa","REPORT STATUS ASSOCIATIONS")
 SET captions->rpt = uar_i18ngetmessage(i18nhandle,"rpt","REPORT")
 SET captions->tskassay = uar_i18ngetmessage(i18nhandle,"tskassay","TASK ASSAY")
 SET captions->rptstat = uar_i18ngetmessage(i18nhandle,"rptstat","REPORT STATUS")
 SET captions->cancel = uar_i18ngetmessage(i18nhandle,"cancel","CANCELABLE?")
 SET captions->cont = uar_i18ngetmessage(i18nhandle,"cont","CONTINUED...")
 SET captions->yep = uar_i18ngetmessage(i18nhandle,"yep","YES")
 SET captions->nope = uar_i18ngetmessage(i18nhandle,"nope","NO")
 RECORD temp(
   1 max_details = i4
   1 report_proc_qual[*]
     2 mnemonic = vc
     2 ris_catalog_cd = f8
     2 long_desc = vc
     2 rpt_detail_qual[*]
       3 detail_task_assay_cd = f8
       3 detail_task_assay_disp = c25
       3 ris_description = c40
       3 ris_proc_seq = i4
       3 ris_cancelable_ind = c1
       3 sort_key_1 = c3
       3 sort_key_2 = c50
   1 stat_qual[*]
     2 display = c15
     2 display_key = c40
     2 description = c60
     2 active_ind = i2
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
 SET proc_cnt = 0
 SET detail_cnt = 0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=1305
  ORDER BY cv.active_ind, cv.display_key
  HEAD REPORT
   spec_cnt = 0
  DETAIL
   spec_cnt = (spec_cnt+ 1), stat = alterlist(temp->stat_qual,spec_cnt), temp->stat_qual[spec_cnt].
   display = cv.display,
   temp->stat_qual[spec_cnt].display_key = cv.display_key, temp->stat_qual[spec_cnt].description = cv
   .description, temp->stat_qual[spec_cnt].active_ind = cv.active_ind
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  ris.task_assay_cd, p.task_assay_cd, group_mnemonic = oc.primary_mnemonic,
  c1.display, c1.description, ris.processing_sequence
  FROM order_catalog oc,
   profile_task_r p,
   report_inproc_status ris,
   (dummyt d1  WITH seq = 1),
   code_value c1
  PLAN (ris)
   JOIN (p
   WHERE ris.catalog_cd=p.catalog_cd
    AND p.active_ind=1
    AND cnvtdatetime(curdate,curtime3) BETWEEN p.beg_effective_dt_tm AND p.end_effective_dt_tm)
   JOIN (d1)
   JOIN (c1
   WHERE ris.transcribed_status_cd=c1.code_value
    AND c1.code_set=1305)
   JOIN (oc
   WHERE ris.catalog_cd=oc.catalog_cd)
  ORDER BY group_mnemonic, p.task_assay_cd
  HEAD REPORT
   rpt_cnt = 0
  HEAD group_mnemonic
   IF (oc.catalog_cd > 0)
    detail_cnt = 0, rpt_cnt = (rpt_cnt+ 1), stat = alterlist(temp->report_proc_qual,rpt_cnt),
    temp->report_proc_qual[rpt_cnt].mnemonic = oc.primary_mnemonic, temp->report_proc_qual[rpt_cnt].
    long_desc = oc.description, temp->report_proc_qual[rpt_cnt].ris_catalog_cd = oc.catalog_cd
   ENDIF
  HEAD p.task_assay_cd
   IF (oc.catalog_cd > 0)
    detail_cnt = (detail_cnt+ 1)
    IF ((detail_cnt > temp->max_details))
     temp->max_details = detail_cnt
    ENDIF
    stat = alterlist(temp->report_proc_qual[rpt_cnt].rpt_detail_qual,detail_cnt), temp->
    report_proc_qual[rpt_cnt].rpt_detail_qual[detail_cnt].detail_task_assay_cd = p.task_assay_cd
   ENDIF
  DETAIL
   IF (oc.catalog_cd > 0)
    IF (p.task_assay_cd=ris.task_assay_cd)
     temp->report_proc_qual[rpt_cnt].rpt_detail_qual[detail_cnt].ris_description = c1.display, temp->
     report_proc_qual[rpt_cnt].rpt_detail_qual[detail_cnt].ris_proc_seq = ris.processing_sequence
     IF (ris.cancelable_ind=1)
      temp->report_proc_qual[rpt_cnt].rpt_detail_qual[detail_cnt].ris_cancelable_ind = "Y"
     ELSE
      temp->report_proc_qual[rpt_cnt].rpt_detail_qual[detail_cnt].ris_cancelable_ind = "N"
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter, outerjoin = d1
 ;end select
 SELECT INTO "nl:"
  proc_seq = temp->report_proc_qual[d1.seq].rpt_detail_qual[d2.seq].ris_proc_seq
  FROM (dummyt d1  WITH seq = value(size(temp->report_proc_qual,5))),
   (dummyt d2  WITH seq = value(temp->max_details))
  PLAN (d1
   WHERE (temp->report_proc_qual[d1.seq].ris_catalog_cd > 0))
   JOIN (d2
   WHERE d2.seq <= size(temp->report_proc_qual[d1.seq].rpt_detail_qual,5))
  DETAIL
   IF (proc_seq=0)
    temp->report_proc_qual[d1.seq].rpt_detail_qual[d2.seq].sort_key_1 = "B"
   ELSEIF (proc_seq < 10)
    temp->report_proc_qual[d1.seq].rpt_detail_qual[d2.seq].sort_key_1 = cnvtstring(proc_seq)
   ELSE
    temp->report_proc_qual[d1.seq].rpt_detail_qual[d2.seq].sort_key_1 = concat("A",cnvtstring(
      proc_seq))
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.description
  FROM (dummyt d1  WITH seq = value(size(temp->report_proc_qual,5))),
   (dummyt d2  WITH seq = value(temp->max_details)),
   code_value cv
  PLAN (d1
   WHERE (temp->report_proc_qual[d1.seq].ris_catalog_cd > 0))
   JOIN (d2
   WHERE d2.seq <= size(temp->report_proc_qual[d1.seq].rpt_detail_qual,5))
   JOIN (cv
   WHERE (temp->report_proc_qual[d1.seq].rpt_detail_qual[d2.seq].detail_task_assay_cd=cv.code_value))
  DETAIL
   temp->report_proc_qual[d1.seq].rpt_detail_qual[d2.seq].detail_task_assay_disp = cv.description
   IF ((temp->report_proc_qual[d1.seq].rpt_detail_qual[d2.seq].sort_key_1="A"))
    temp->report_proc_qual[d1.seq].rpt_detail_qual[d2.seq].sort_key_2 = cv.description
   ENDIF
   IF ((temp->report_proc_qual[d1.seq].rpt_detail_qual[d2.seq].sort_key_1="B"))
    temp->report_proc_qual[d1.seq].rpt_detail_qual[d2.seq].sort_key_2 = cv.description
   ENDIF
  WITH nocounter
 ;end select
#report_maker
 EXECUTE cpm_create_file_name_logical "apsDbRptStatus", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  short_desc = temp->report_proc_qual[d1.seq].mnemonic, long_desc = temp->report_proc_qual[d1.seq].
  long_desc, task_assay_cd = temp->report_proc_qual[d1.seq].rpt_detail_qual[d2.seq].
  detail_task_assay_cd,
  task_assay_disp = temp->report_proc_qual[d1.seq].rpt_detail_qual[d2.seq].detail_task_assay_disp,
  ris_description = temp->report_proc_qual[d1.seq].rpt_detail_qual[d2.seq].ris_description,
  ris_proc_seq = temp->report_proc_qual[d1.seq].rpt_detail_qual[d2.seq].ris_proc_seq,
  sort_order = concat(temp->report_proc_qual[d1.seq].rpt_detail_qual[d2.seq].sort_key_1,temp->
   report_proc_qual[d1.seq].rpt_detail_qual[d2.seq].sort_key_2)
  FROM (dummyt d1  WITH seq = value(size(temp->report_proc_qual,5))),
   (dummyt d2  WITH seq = value(temp->max_details))
  PLAN (d1
   WHERE (temp->report_proc_qual[d1.seq].ris_catalog_cd > 0))
   JOIN (d2
   WHERE d2.seq <= size(temp->report_proc_qual[d1.seq].rpt_detail_qual,5))
  ORDER BY short_desc, sort_order
  HEAD REPORT
   status_printed = "N", line1 = fillstring(125,"-"), beg_val = 1
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
   CALL center(captions->dbrst,0,132), col 110, captions->ppage,
   ":", col 117, curpage"###",
   row + 2
  HEAD short_desc
   IF (status_printed="N")
    row + 1, col 0, captions->status,
    col 10, captions->code, col 27,
    captions->desc, row + 1, col 0,
    "--------", col 10, "---------------",
    col 27, "------------------------------------------------------"
    FOR (loop = beg_val TO size(temp->stat_qual,5))
      IF ((temp->stat_qual[loop].active_ind=1))
       row + 1, col 0, captions->active
      ELSE
       row + 1, col 0, captions->inactive
      ENDIF
      col 10, temp->stat_qual[loop].display, col 27,
      temp->stat_qual[loop].description
      IF (((row+ 10) > maxrow))
       beg_val = loop, BREAK
      ENDIF
    ENDFOR
    row + 2, col 56, "* * * * * * * * * *",
    row + 1,
    CALL center(captions->rsa,0,132), status_printed = "Y"
   ENDIF
   row + 1, col 0, captions->rpt,
   ":", col 9, short_desc,
   row + 1, col 9, long_desc,
   row + 1, row + 1, col 9,
   captions->tskassay, col 36, captions->rptstat,
   col 53, captions->cancel, row + 1,
   col 9, "-------------------------", col 36,
   "---------------", col 53, "-----------"
  HEAD sort_order
   row + 1, col 9, task_assay_disp,
   col 36, ris_description
   IF ((temp->report_proc_qual[d1.seq].rpt_detail_qual[d2.seq].ris_cancelable_ind="Y"))
    col 53, captions->yep
   ELSEIF ((temp->report_proc_qual[d1.seq].rpt_detail_qual[d2.seq].ris_cancelable_ind="N"))
    col 53, captions->nope
   ENDIF
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
  FOOT  short_desc
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
END GO
