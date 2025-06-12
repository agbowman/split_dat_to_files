CREATE PROGRAM aps_prt_db_ft_term_reasons:dba
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
   1 date = vc
   1 directory = vc
   1 ttime = vc
   1 refdbaudit = vc
   1 bby = vc
   1 dbfollowuptracking = vc
   1 ppage = vc
   1 status = vc
   1 pathnetap = vc
   1 code = vc
   1 description = vc
   1 inactive = vc
   1 active = vc
   1 continued = vc
 )
 SET captions->rptaps = uar_i18ngetmessage(i18nhandle,"h1","REPORT:  APS_PRT_DB_TERM_REASONS.PRG")
 SET captions->date = uar_i18ngetmessage(i18nhandle,"h2","DATE:")
 SET captions->directory = uar_i18ngetmessage(i18nhandle,"h3","DIRECTORY:")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"h4","TIME:")
 SET captions->refdbaudit = uar_i18ngetmessage(i18nhandle,"h5","REFERENCE DATABASE AUDIT")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"h6","BY:")
 SET captions->dbfollowuptracking = uar_i18ngetmessage(i18nhandle,"h7",
  "DB FOLLOW-UP TRACKING TERMINATION REASONS TOOL")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"h8","PAGE:")
 SET captions->status = uar_i18ngetmessage(i18nhandle,"h9","STATUS")
 SET captions->pathnetap = uar_i18ngetmessage(i18nhandle,"h10","PATHNET ANATOMIC PATHOLOGY")
 SET captions->code = uar_i18ngetmessage(i18nhandle,"h11","CODE")
 SET captions->description = uar_i18ngetmessage(i18nhandle,"h12","DESCRIPTION")
 SET captions->inactive = uar_i18ngetmessage(i18nhandle,"d1","INACTIVE")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"d2","ACTIVE")
 SET captions->continued = uar_i18ngetmessage(i18nhandle,"f1","CONTINUED...")
 SET week = format(curdate,"@WEEKDAYABBREV;;Q")
 SET day = format(curdate,"@MEDIUMDATE;;Q")
 RECORD temp(
   1 qual[*]
     2 spec_display = c40
     2 spec_display_key = c40
     2 spec_description = c60
     2 spec_active_ind = i2
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
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=1313
  HEAD REPORT
   spec_cnt = 0
  DETAIL
   spec_cnt = (spec_cnt+ 1), stat = alterlist(temp->qual,spec_cnt), temp->qual[spec_cnt].spec_display
    = cv.display,
   temp->qual[spec_cnt].spec_display_key = cv.display_key, temp->qual[spec_cnt].spec_description = cv
   .description, temp->qual[spec_cnt].spec_active_ind = cv.active_ind
  WITH nocounter
 ;end select
#report_maker
 EXECUTE cpm_create_file_name_logical "apsDbFtTermReas", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  temp->qual[d.seq].spec_display, temp->qual[d.seq].spec_display_key, temp->qual[d.seq].
  spec_description,
  temp->qual[d.seq].spec_active_ind
  FROM (dummyt d  WITH seq = value(size(temp->qual,5)))
  PLAN (d)
  ORDER BY temp->qual[d.seq].spec_active_ind DESC, temp->qual[d.seq].spec_display_key
  HEAD REPORT
   line1 = fillstring(125,"-")
  HEAD PAGE
   row + 1, col 0, captions->rptaps,
   CALL center(captions->pathnetap,0,132), col 110, captions->date,
   col 117, curdate"@SHORTDATE;;Q", row + 1,
   col 0, captions->directory, col 110,
   captions->ttime, col 117, curtime,
   row + 1,
   CALL center(captions->refdbaudit,0,132), col 112,
   captions->bby, col 117, request->scuruser"##############",
   row + 1,
   CALL center(captions->dbfollowuptracking,0,132), col 110,
   captions->ppage, col 117, curpage"###",
   row + 2, row + 1, col 0,
   captions->status, col 10, captions->code,
   col 27, captions->description, row + 1,
   col 0, "--------", col 10,
   "---------------", col 27, "---------------------------------------"
  DETAIL
   row + 1, col 0
   IF ((temp->qual[d.seq].spec_active_ind=0))
    captions->inactive
   ELSE
    captions->active
   ENDIF
   col 10, temp->qual[d.seq].spec_display, col 27,
   temp->qual[d.seq].spec_description
   IF (((row+ 7) > maxrow))
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
   col 55, "##########                              "
  WITH nocounter, maxcol = 132, nullreport,
   maxrow = 63, compress
 ;end select
 SET reply->status_data.status = "S"
END GO
