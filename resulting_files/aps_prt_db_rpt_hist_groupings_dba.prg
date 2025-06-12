CREATE PROGRAM aps_prt_db_rpt_hist_groupings:dba
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
   1 pathnetap = vc
   1 ddate = vc
   1 directory = vc
   1 ttime = vc
   1 refdbaudit = vc
   1 bby = vc
   1 dbreporthistgroup = vc
   1 ppage = vc
   1 grouping = vc
   1 includes = vc
   1 continued = vc
 )
 SET captions->rptaps = uar_i18ngetmessage(i18nhandle,"h1",
  "REPORT: APS_PRT_DB_RPT_HIST_GROUPINGS.PRG")
 SET captions->pathnetap = uar_i18ngetmessage(i18nhandle,"h2","PATHNET ANATOMIC PATHOLOGY")
 SET captions->ddate = uar_i18ngetmessage(i18nhandle,"h3","DATE:")
 SET captions->directory = uar_i18ngetmessage(i18nhandle,"h4","DIRECTORY:")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"h5","TIME:")
 SET captions->refdbaudit = uar_i18ngetmessage(i18nhandle,"h6","REFERENCE DATABASE AUDIT")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"h7","BY:")
 SET captions->dbreporthistgroup = uar_i18ngetmessage(i18nhandle,"h8",
  "DB REPORT HISTORY GROUPING TOOL")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"h9","PAGE:")
 SET captions->grouping = uar_i18ngetmessage(i18nhandle,"h10","GROUPING:")
 SET captions->includes = uar_i18ngetmessage(i18nhandle,"h11","INCLUDES:")
 SET captions->continued = uar_i18ngetmessage(i18nhandle,"f1","CONTINUED...")
 SET week = format(curdate,"@WEEKDAYABBREV;;Q")
 SET day = format(curdate,"@MEDIUMDATE;;Q")
 RECORD temp(
   1 qual[5]
     2 grouping_cd = f8
     2 grouping_disp = c40
     2 det_cnt = i4
     2 det_qual[*]
       3 task_assay_cd = f8
       3 task_assay_disp = c40
       3 task_assay_desc = c60
       3 collating_seq = i4
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 print_status_data
     2 print_directory = c19
     2 print_filename = c40
     2 print_dir_and_filename = c60
 )
#script
 SET reply->status_data.status = "F"
 SET failed = "F"
 SET grp_cnt = 00000
 SET det_cnt = 00000
 SET max_det_cnt = 00000
 SELECT INTO "nl:"
  c.display, rhgr.task_assay_cd, rhgr.grouping_cd,
  c.code_value, c.updt_cnt, c2.display
  FROM report_history_grouping_r rhgr,
   code_value c,
   code_value c2
  PLAN (c
   WHERE c.code_set=1311)
   JOIN (rhgr
   WHERE c.code_value=rhgr.grouping_cd)
   JOIN (c2
   WHERE rhgr.task_assay_cd=c2.code_value
    AND rhgr.task_assay_cd > 0)
  ORDER BY c.display, rhgr.collating_seq
  HEAD c.display
   det_cnt = 0, grp_cnt = (grp_cnt+ 1)
   IF (mod(grp_cnt,5)=1
    AND grp_cnt != 1)
    stat = alter(temp->qual,(grp_cnt+ 4))
   ENDIF
   temp->qual[grp_cnt].grouping_cd = c.code_value, temp->qual[grp_cnt].grouping_disp = c.display
  DETAIL
   det_cnt = (det_cnt+ 1)
   IF (det_cnt > max_det_cnt)
    max_det_cnt = det_cnt
   ENDIF
   stat = alterlist(temp->qual[grp_cnt].det_qual,det_cnt), temp->qual[grp_cnt].det_qual[det_cnt].
   task_assay_cd = rhgr.task_assay_cd, temp->qual[grp_cnt].det_qual[det_cnt].collating_seq = rhgr
   .collating_seq,
   temp->qual[grp_cnt].det_qual[det_cnt].task_assay_disp = c2.display, temp->qual[grp_cnt].det_qual[
   det_cnt].task_assay_desc = c2.description, temp->qual[grp_cnt].det_cnt = det_cnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "REPORT_HISTORY_GROUPING_R"
 ENDIF
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
 ENDIF
#report_maker
 EXECUTE cpm_create_file_name_logical "apsDbRptHistGrp", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  description = temp->qual[d1.seq].grouping_disp, task_assay_disp = temp->qual[d1.seq].det_qual[d2
  .seq].task_assay_disp, collating_seq = temp->qual[d1.seq].det_qual[d2.seq].collating_seq
  FROM (dummyt d1  WITH seq = value(size(temp->qual,5))),
   (dummyt d2  WITH seq = value(max_det_cnt))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->qual[d1.seq].det_qual,5))
  ORDER BY description, collating_seq, task_assay_disp
  HEAD REPORT
   line1 = fillstring(125,"-")
  HEAD PAGE
   row + 1, col 0, captions->rptaps,
   CALL center(captions->pathnetap,0,132), col 110, captions->ddate,
   col 117, curdate"@SHORTDATE;;Q", row + 1,
   col 0, captions->directory, col 110,
   captions->ttime, col 117, curtime,
   row + 1,
   CALL center(captions->refdbaudit,0,132), col 112,
   captions->bby, col 117, request->scuruser"##############",
   row + 1,
   CALL center(captions->dbreporthistgroup,0,132), col 110,
   captions->ppage, col 117, curpage"###",
   row + 2
  HEAD description
   row + 1, col 0, captions->grouping,
   col 11, description, row + 2,
   col 11, captions->includes, row + 1,
   col 11, "----------------------------------------", row + 1
  DETAIL
   col 11, task_assay_disp, row + 1
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
  FOOT  description
   CALL center("* * * * * * * * * * * * *",0,132)
  FOOT PAGE
   row 60, col 0, line1,
   row + 1, col 0, captions->rptaps,
   today = concat(week," ",day), col 53, today,
   col 110, captions->ppage, col 117,
   curpage"###", row + 1, col 55,
   captions->continued
  FOOT REPORT
   col 55, "##########                              "
  WITH nocounter, maxcol = 132, nullreport,
   maxrow = 63, compress
 ;end select
END GO
