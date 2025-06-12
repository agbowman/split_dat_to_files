CREATE PROGRAM aps_prt_db_rpt_sect_synoptic:dba
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
   1 cont = vc
   1 sttask = vc
   1 stcatalog = vc
   1 stworksheet = vc
 )
 SET captions->rptaps = uar_i18ngetmessage(i18nhandle,"rptaps",
  "REPORT: APS_PRT_DB_RPT_SECT_SYNOPTIC.PRG")
 SET captions->pathap = uar_i18ngetmessage(i18nhandle,"pathap","PATHNET ANATOMIC PATHOLOGY")
 SET captions->ddate = uar_i18ngetmessage(i18nhandle,"ddate","DATE")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"dir","DIRECTORY")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"ttime","TIME")
 SET captions->rda = uar_i18ngetmessage(i18nhandle,"rda","REFERENCE DATABASE AUDIT")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"bby","BY")
 SET captions->dbsgt = uar_i18ngetmessage(i18nhandle,"dbsgt",
  "DB MAINTAIN SYNOPTIC WORKSHEETS and REPORT SECTIONS")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"ppage","PAGE")
 SET captions->cont = uar_i18ngetmessage(i18nhandle,"cont","CONTINUED...")
 SET captions->sttask = uar_i18ngetmessage(i18nhandle,"sttask","Report Section")
 SET captions->stcatalog = uar_i18ngetmessage(i18nhandle,"stcatalog","Report")
 SET captions->stworksheet = uar_i18ngetmessage(i18nhandle,"stworksheet","Worksheet")
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
   1 max_nbr_reports = i4
   1 scr_qual[*]
     2 scr_pattern_id = f8
     2 scr_display = c40
     2 rpt_qual[*]
       3 catalog_cd = f8
       3 catalog_display = c40
       3 task_assay_cd = f8
       3 task_assay_display = c40
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  catalog_cd = syn.catalog_cd, catalog_display = uar_get_code_display(syn.catalog_cd), task_assay_cd
   = syn.task_assay_cd,
  task_assay_display = uar_get_code_display(syn.task_assay_cd), scr_pattern_id = scr.scr_pattern_id,
  scr_display = scr.display
  FROM ap_synoptic_rpt_section_r syn,
   scr_pattern scr
  PLAN (syn)
   JOIN (scr
   WHERE scr.cki_source=syn.cki_source
    AND scr.cki_identifier=syn.cki_identifier)
  ORDER BY scr_display, catalog_display
  HEAD REPORT
   rpt_cntr = 0, scr_cntr = 0
  HEAD scr_display
   scr_cntr = (scr_cntr+ 1), stat = alterlist(temp->scr_qual,scr_cntr), temp->scr_qual[scr_cntr].
   scr_pattern_id = scr_pattern_id,
   temp->scr_qual[scr_cntr].scr_display = scr_display, rpt_cntr = 0
  DETAIL
   rpt_cntr = (rpt_cntr+ 1)
   IF ((rpt_cntr > temp->max_nbr_reports))
    temp->max_nbr_reports = rpt_cntr
   ENDIF
   stat = alterlist(temp->scr_qual[scr_cntr].rpt_qual,rpt_cntr)
   IF (scr_pattern_id=0
    AND syn.cki_identifier != "")
    temp->scr_qual[scr_cntr].rpt_qual[rpt_cntr].catalog_display = syn.cki_identifier
   ELSE
    temp->scr_qual[scr_cntr].rpt_qual[rpt_cntr].catalog_display = catalog_display
   ENDIF
   temp->scr_qual[scr_cntr].rpt_qual[rpt_cntr].catalog_cd = catalog_cd, temp->scr_qual[scr_cntr].
   rpt_qual[rpt_cntr].task_assay_display = task_assay_display, temp->scr_qual[scr_cntr].rpt_qual[
   rpt_cntr].task_assay_cd = task_assay_cd
  WITH nocounter
 ;end select
#report_maker
 EXECUTE cpm_create_file_name_logical "apsDbRpSyn", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name
 SELECT INTO value(cpm_cfn_info->file_name_logical)
  scr_display = temp->scr_qual[d1.seq].scr_display, catalog_display = temp->scr_qual[d1.seq].
  rpt_qual[d2.seq].catalog_display, task_assay_display = temp->scr_qual[d1.seq].rpt_qual[d2.seq].
  task_assay_display
  FROM (dummyt d1  WITH seq = value(size(temp->scr_qual,5))),
   (dummyt d2  WITH seq = value(temp->max_nbr_reports))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->scr_qual[d1.seq].rpt_qual,5))
  ORDER BY scr_display, catalog_display, task_assay_display
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
   row + 1, col 5, captions->stworksheet,
   col 30, captions->stcatalog, col 65,
   captions->sttask, row + 1, col 5,
   "---------", col 30, "------",
   col 65, "--------------"
  HEAD scr_display
   IF ((((row+ temp->max_nbr_reports)+ 2) > maxrow))
    BREAK
   ENDIF
   row + 1, col 5, scr_display
  DETAIL
   col 30, catalog_display, col 65,
   task_assay_display, row + 1
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
