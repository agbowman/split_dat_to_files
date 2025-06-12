CREATE PROGRAM aps_prt_db_diag_categories:dba
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
   1 dbdct = vc
   1 status = vc
   1 desc = vc
   1 type = vc
   1 active = vc
   1 inactive = vc
   1 ppage = vc
   1 cont = vc
 )
 SET captions->rptaps = uar_i18ngetmessage(i18nhandle,"rptaps",
  "REPORT: APS_PRT_DB_DIAG_CATEGORIES.PRG")
 SET captions->pathap = uar_i18ngetmessage(i18nhandle,"pathap","PATHNET ANATOMIC PATHOLOGY")
 SET captions->ddate = uar_i18ngetmessage(i18nhandle,"ddate","DATE")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"dir","DIRECTORY")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"ttime","TIME")
 SET captions->rda = uar_i18ngetmessage(i18nhandle,"rda","REFERENCE DATABASE AUDIT")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"bby","BY")
 SET captions->dbdct = uar_i18ngetmessage(i18nhandle,"dbdct","DB DIAGNOSTIC CATEGORIES TOOL")
 SET captions->status = uar_i18ngetmessage(i18nhandle,"status","STATUS")
 SET captions->desc = uar_i18ngetmessage(i18nhandle,"desc","DESCRIPTION")
 SET captions->type = uar_i18ngetmessage(i18nhandle,"type","TYPE")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","ACTIVE")
 SET captions->inactive = uar_i18ngetmessage(i18nhandle,"inactive","INACTIVE")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"page","PAGE")
 SET captions->cont = uar_i18ngetmessage(i18nhandle,"cont","CONTINUED...")
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
   1 qual[*]
     2 display = c40
     2 cdf_meaning = c12
     2 active_ind = i2
     2 collation_seq = i4
     2 sorting_field = c40
 )
 SET reply->status_data.status = "S"
 SELECT INTO "nl:"
  cv.cdf_meaning, cv.display, cv.active_ind,
  cv.collation_seq
  FROM code_value cv
  WHERE cv.code_set=1314
  ORDER BY cv.cdf_meaning, cv.active_ind DESC, cv.collation_seq
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].cdf_meaning = cv.cdf_meaning,
   temp->qual[cnt].display = cv.display, temp->qual[cnt].active_ind = cv.active_ind, temp->qual[cnt].
   collation_seq = cv.collation_seq
   IF ((temp->qual[cnt].active_ind=1))
    temp->qual[cnt].sorting_field = "A"
   ELSE
    temp->qual[cnt].sorting_field = cv.display_key, temp->qual[cnt].collation_seq = 0
   ENDIF
  WITH nocounter
 ;end select
#report_maker
 EXECUTE cpm_create_file_name_logical "apsDbDiagCat", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  temp->qual[d.seq].display, temp->qual[d.seq].cdf_meaning, temp->qual[d.seq].active_ind,
  temp->qual[d.seq].collation_seq, temp->qual[d.seq].sorting_field
  FROM (dummyt d  WITH seq = value(size(temp->qual,5)))
  PLAN (d)
  ORDER BY temp->qual[d.seq].cdf_meaning, temp->qual[d.seq].active_ind DESC, temp->qual[d.seq].
   collation_seq,
   temp->qual[d.seq].sorting_field
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
   CALL center(captions->dbdct,0,132), col 110, captions->ppage,
   ":", col 117, curpage"###",
   row + 2, row + 1, col 0,
   captions->status, col 10, captions->desc,
   col 51, captions->type, row + 1,
   col 0, "--------", col 10,
   "---------------------------------------", col 51, "-------"
  DETAIL
   row + 1, col 0
   IF ((temp->qual[d.seq].active_ind=1))
    captions->active
   ELSE
    captions->inactive
   ENDIF
   col 10, temp->qual[d.seq].display, col 51,
   temp->qual[d.seq].cdf_meaning
   IF (((row+ 7) > maxrow))
    BREAK
   ENDIF
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
