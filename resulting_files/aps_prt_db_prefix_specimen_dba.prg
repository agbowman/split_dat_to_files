CREATE PROGRAM aps_prt_db_prefix_specimen:dba
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
   1 grping = vc
   1 status = vc
   1 code = vc
   1 desc = vc
   1 active = vc
   1 inactive = vc
   1 cont = vc
 )
 SET captions->rptaps = uar_i18ngetmessage(i18nhandle,"rptaps",
  "REPORT: APS_PRT_DB_PREFIX_SPECIMEN.PRG")
 SET captions->pathap = uar_i18ngetmessage(i18nhandle,"pathap","PATHNET ANATOMIC PATHOLOGY")
 SET captions->ddate = uar_i18ngetmessage(i18nhandle,"ddate","DATE")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"dir","DIRECTORY")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"ttime","TIME")
 SET captions->rda = uar_i18ngetmessage(i18nhandle,"rda","REFERENCE DATABASE AUDIT")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"bby","BY")
 SET captions->dbsgt = uar_i18ngetmessage(i18nhandle,"dbsgt","DB PREFIX SPECIMEN TOOL")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"ppage","PAGE")
 SET captions->stpref = uar_i18ngetmessage(i18nhandle,"stpref","Site/Prefix")
 SET captions->grping = uar_i18ngetmessage(i18nhandle,"grping","GROUPING")
 SET captions->status = uar_i18ngetmessage(i18nhandle,"status","STATUS")
 SET captions->code = uar_i18ngetmessage(i18nhandle,"code","CODE")
 SET captions->desc = uar_i18ngetmessage(i18nhandle,"desc","DESCRIPTION")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","ACTIVE")
 SET captions->inactive = uar_i18ngetmessage(i18nhandle,"inactive","INACTIVE")
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
   1 max_specs = i4
   1 qual[*]
     2 prefix_cd = f8
     2 prefix_name = c2
     2 prefix_desc = c40
     2 site_cd = f8
     2 site_display = c40
     2 group_cd = f8
     2 group_name = c40
     2 group_name_cap = c40
     2 spec_qual[*]
       3 source_cd = f8
       3 display = c40
       3 display_key = c40
       3 description = c60
       3 active_ind = i2
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  prefix_name = ap.prefix_name, prefix_desc = ap.prefix_desc, site_cd = ap.site_cd,
  site_pref_cd = build(ap.prefix_id,ap.site_cd), group_name = cv.display, group_name_cap = cv
  .display_key,
  spgr_r.*, active_ind = cv2.active_ind, display = cv2.display,
  cv2.display, cv2.description
  FROM ap_prefix ap,
   code_value cv,
   specimen_grouping_r spgr_r,
   code_value cv2
  PLAN (cv
   WHERE cv.code_set=1312)
   JOIN (spgr_r
   WHERE cv.code_value=spgr_r.category_cd)
   JOIN (ap
   WHERE ap.prefix_id != 0.0
    AND ap.specimen_grouping_cd=spgr_r.category_cd)
   JOIN (cv2
   WHERE spgr_r.source_cd=cv2.code_value)
  ORDER BY site_pref_cd, group_name, active_ind DESC,
   display
  HEAD REPORT
   pref_cntr = 0, spec_cntr = 0
  HEAD site_pref_cd
   pref_cntr = (pref_cntr+ 1), stat = alterlist(temp->qual,pref_cntr), temp->qual[pref_cntr].site_cd
    = ap.site_cd,
   temp->qual[pref_cntr].prefix_cd = ap.prefix_id, temp->qual[pref_cntr].prefix_name = prefix_name,
   temp->qual[pref_cntr].prefix_desc = prefix_desc
  HEAD group_name
   temp->qual[pref_cntr].group_cd = spgr_r.category_cd, temp->qual[pref_cntr].group_name = group_name,
   temp->qual[pref_cntr].group_name_cap = group_name_cap,
   spec_cntr = 0
  HEAD display
   spec_cntr = (spec_cntr+ 1), stat = alterlist(temp->qual[pref_cntr].spec_qual,spec_cntr)
   IF ((spec_cntr > temp->max_specs))
    temp->max_specs = spec_cntr
   ENDIF
   temp->qual[pref_cntr].spec_qual[spec_cntr].source_cd = spgr_r.source_cd, temp->qual[pref_cntr].
   spec_qual[spec_cntr].display = cv2.display, temp->qual[pref_cntr].spec_qual[spec_cntr].display_key
    = cv2.display_key,
   temp->qual[pref_cntr].spec_qual[spec_cntr].description = cv2.description, temp->qual[pref_cntr].
   spec_qual[spec_cntr].active_ind = cv2.active_ind
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.display
  FROM code_value cv,
   (dummyt d1  WITH seq = value(size(temp->qual,5)))
  PLAN (d1
   WHERE (temp->qual[d1.seq].site_cd != 0.0))
   JOIN (cv
   WHERE (cv.code_value=temp->qual[d1.seq].site_cd))
  DETAIL
   temp->qual[d1.seq].site_display = cv.display
  WITH nocounter
 ;end select
#report_maker
 EXECUTE cpm_create_file_name_logical "apsDbPrefixSpec", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  prefix_name = temp->qual[d1.seq].prefix_name, prefix_desc = temp->qual[d1.seq].prefix_desc,
  site_display = temp->qual[d1.seq].site_display,
  site_pref_display = build(trim(temp->qual[d1.seq].site_display),trim(temp->qual[d1.seq].prefix_name
    )), group_name = temp->qual[d1.seq].group_name, group_name_cap = temp->qual[d1.seq].
  group_name_cap,
  active_ind = temp->qual[d1.seq].spec_qual[d2.seq].active_ind, specimen = temp->qual[d1.seq].
  spec_qual[d2.seq].display, specimen_desc = temp->qual[d1.seq].spec_qual[d2.seq].description,
  specimen_cap = temp->qual[d1.seq].spec_qual[d2.seq].display
  FROM (dummyt d1  WITH seq = value(size(temp->qual,5))),
   (dummyt d2  WITH seq = value(temp->max_specs))
  PLAN (d1)
   JOIN (d2
   WHERE d2.seq <= size(temp->qual[d1.seq].spec_qual,5))
  ORDER BY prefix_name, group_name_cap, active_ind DESC,
   specimen_cap
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
   row + 1
  HEAD prefix_name
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
   row + 1, col 0, captions->stpref,
   ": ", col 13, site_pref_display,
   col 22, prefix_desc
  HEAD group_name_cap
   row + 2, col 9, captions->grping,
   ": ", group_name, row + 2,
   col 9, captions->status, col 19,
   captions->code, col 36, captions->desc,
   row + 1, col 9, "--------",
   col 19, "--------------", col 36,
   "-----------------------------------------"
  HEAD specimen_cap
   row + 1, col 9
   IF (active_ind=1)
    captions->active
   ELSE
    captions->inactive
   ENDIF
   col 19, specimen, col 36,
   specimen_desc
   IF (((row+ 10) > maxrow))
    BREAK
   ENDIF
  FOOT  group_name_cap
   row + 1,
   CALL center("* * * * * * * * * * * *",0,132), row + 1
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
