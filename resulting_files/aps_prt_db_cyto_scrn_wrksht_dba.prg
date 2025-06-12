CREATE PROGRAM aps_prt_db_cyto_scrn_wrksht:dba
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
   1 dbcswt = vc
   1 prefix = vc
   1 prefdesc = vc
   1 temp = vc
   1 tempdesc = vc
   1 apparam = vc
   1 histgrp = vc
   1 inclhist = vc
   1 override = vc
   1 yep = vc
   1 nope = vc
   1 prefparam = vc
   1 ppage = vc
   1 cont = vc
 )
 SET captions->rptaps = uar_i18ngetmessage(i18nhandle,"rptaps",
  "REPORT: APS_PRT_DB_CYTO_SCRN_WRKSHT.PRG")
 SET captions->pathap = uar_i18ngetmessage(i18nhandle,"pathap","PATHNET ANATOMIC PATHOLOGY")
 SET captions->ddate = uar_i18ngetmessage(i18nhandle,"ddate","DATE")
 SET captions->dir = uar_i18ngetmessage(i18nhandle,"dir","DIRECTORY")
 SET captions->ttime = uar_i18ngetmessage(i18nhandle,"ttime","TIME")
 SET captions->rda = uar_i18ngetmessage(i18nhandle,"rda","REFERENCE DATABASE AUDIT")
 SET captions->bby = uar_i18ngetmessage(i18nhandle,"bby","BY")
 SET captions->dbcswt = uar_i18ngetmessage(i18nhandle,"dbcswt","DB CYTOLOGY SCREENING WORKSHEET TOOL"
  )
 SET captions->prefix = uar_i18ngetmessage(i18nhandle,"prefix","PREFIX")
 SET captions->prefdesc = uar_i18ngetmessage(i18nhandle,"prefdesc","PREFIX DESCRIPTION")
 SET captions->temp = uar_i18ngetmessage(i18nhandle,"temp","TEMPLATE")
 SET captions->tempdesc = uar_i18ngetmessage(i18nhandle,"tempdesc","TEMPLATE DESCRIPTION")
 SET captions->apparam = uar_i18ngetmessage(i18nhandle,"apparam","APPLICATION PARAMETERS")
 SET captions->histgrp = uar_i18ngetmessage(i18nhandle,"histgrp","HISTORY GROUP")
 SET captions->inclhist = uar_i18ngetmessage(i18nhandle,"inclhist",
  "INCLUDE HISTORY BASED ON PERSON MATCH LOGIC?")
 SET captions->override = uar_i18ngetmessage(i18nhandle,"override",
  "ALLOW USER TO OVERRIDE PERSON MATCH LOGIC PREFIX PREFERENCE?")
 SET captions->yep = uar_i18ngetmessage(i18nhandle,"yep","YES")
 SET captions->nope = uar_i18ngetmessage(i18nhandle,"nope","NO")
 SET captions->prefparam = uar_i18ngetmessage(i18nhandle,"prefparam","PREFIX PARAMETERS")
 SET captions->ppage = uar_i18ngetmessage(i18nhandle,"ppage","PAGE")
 SET captions->cont = uar_i18ngetmessage(i18nhandle,"cont","CONTINUED...")
 RECORD temp(
   1 history_group_cd = f8
   1 history_group_disp = c40
   1 include_hist_based_on_person_match = c1
   1 allow_user_to_override_person_match = c1
   1 qual[*]
     2 site_cd = f8
     2 site_disp = c40
     2 prefix_cd = f8
     2 prefix_desc = c40
     2 prefix_name = c2
     2 template_id = f8
     2 template_short_desc = c25
     2 template_description = c40
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
 SET gyn_case_type_cd = 0.0
 SET ngyn_case_type_cd = 0.0
 SET temp->include_hist_based_on_person_match = "0"
 SET temp->allow_user_to_override_person_match = "0"
 SET temp->history_group_cd = 0.0
 SET temp->history_group_disp = "(No history group specified)"
 SELECT INTO "nl:"
  cv.code_value, cve.field_value
  FROM code_value cv,
   code_value_extension cve
  PLAN (cv
   WHERE cv.code_set=1308
    AND cv.cdf_meaning="CYTO WSHEET")
   JOIN (cve
   WHERE cv.code_value=cve.code_value)
  DETAIL
   IF (cve.field_name="Allow Person Match Override")
    temp->allow_user_to_override_person_match = cve.field_value
   ENDIF
   IF (cve.field_name="Person Match")
    temp->include_hist_based_on_person_match = cve.field_value
   ENDIF
   IF (cve.field_name="History Group")
    temp->history_group_cd = cnvtint(cve.field_value)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE (temp->history_group_cd=cv.code_value)
   AND cv.code_value > 0.0
  DETAIL
   temp->history_group_disp = cv.display
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=1301
   AND cv.cdf_meaning IN ("GYN", "NGYN")
  DETAIL
   IF (cv.cdf_meaning="GYN")
    gyn_case_type_cd = cv.code_value
   ENDIF
   IF (cv.cdf_meaning="NGYN")
    ngyn_case_type_cd = cv.code_value
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.prefix_id, wp.template_id, wp.short_desc
  FROM ap_prefix p,
   dummyt d1,
   wp_template wp
  PLAN (p
   WHERE p.case_type_cd IN (gyn_case_type_cd, ngyn_case_type_cd)
    AND p.active_ind=1)
   JOIN (d1)
   JOIN (wp
   WHERE p.worksheet_template_id=wp.template_id
    AND p.worksheet_template_id > 0)
  HEAD REPORT
   prefix_cnt = 0
  DETAIL
   prefix_cnt = (prefix_cnt+ 1), stat = alterlist(temp->qual,prefix_cnt), temp->qual[prefix_cnt].
   site_cd = p.site_cd,
   temp->qual[prefix_cnt].site_disp = "00", temp->qual[prefix_cnt].prefix_cd = p.prefix_id, temp->
   qual[prefix_cnt].prefix_name = p.prefix_name,
   temp->qual[prefix_cnt].prefix_desc = p.prefix_desc, temp->qual[prefix_cnt].template_id = wp
   .template_id
   IF (wp.short_desc > " ")
    temp->qual[prefix_cnt].template_short_desc = wp.short_desc, temp->qual[prefix_cnt].
    template_description = wp.description
   ELSE
    temp->qual[prefix_cnt].template_short_desc = "(none identified)", temp->qual[prefix_cnt].
    template_description = "(none identified)"
   ENDIF
  WITH nocounter, outerjoin = d1
 ;end select
 SELECT INTO "nl:"
  cv.display
  FROM code_value cv,
   (dummyt d  WITH seq = value(size(temp->qual,5)))
  PLAN (d
   WHERE (temp->qual[d.seq].site_cd > 0))
   JOIN (cv
   WHERE cv.code_set=2062
    AND (temp->qual[d.seq].site_cd=cv.code_value))
  DETAIL
   temp->qual[d.seq].site_disp = cv.display
  WITH nocounter
 ;end select
 EXECUTE cpm_create_file_name_logical "apsDbCytoWrksht", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 SELECT INTO value(reply->print_status_data.print_filename)
  temp->history_group_cd, temp->history_group_disp, temp->include_hist_based_on_person_match,
  temp->allow_user_to_override_person_match, site_pref_disp = build(trim(temp->qual[d.seq].site_disp),
   trim(temp->qual[d.seq].prefix_name))
  FROM (dummyt d  WITH seq = value(size(temp->qual,5)))
  PLAN (d)
  ORDER BY site_pref_disp
  HEAD REPORT
   line1 = fillstring(125,"-"), already_printed = "N"
  HEAD PAGE
   row + 1, col 0, captions->rptaps,
   col 0,
   CALL center(captions->pathap,0,132), col 110,
   captions->ddate, ":", cdate = format(curdate,"@SHORTDATE;;d"),
   col 117, cdate, row + 1,
   col 0, captions->dir, ":",
   col 110, captions->ttime, ":",
   col 117, curtime, row + 1,
   col 0,
   CALL center(captions->rda,0,132), col 112,
   captions->bby, ":", col 117,
   request->scuruser"##############", row + 1, col 0,
   CALL center(captions->dbcswt,0,132), col 110, captions->ppage,
   ":", col 117, curpage"###",
   row + 1
   IF (curpage > 1)
    row + 2, col 3, captions->prefix,
    col 11, captions->prefdesc, col 53,
    captions->temp, col 81, captions->tempdesc,
    row + 1, col 3, "------",
    col 11, "----------------------------------------", col 53,
    "--------------------------", col 81, "----------------------------------------"
   ENDIF
  DETAIL
   IF (already_printed="N")
    row + 1, col 0, captions->apparam,
    ":", row + 2, col 5,
    captions->histgrp, ":", col 21,
    temp->history_group_disp, row + 2, col 5,
    captions->inclhist
    IF ((temp->include_hist_based_on_person_match="1"))
     col 51, captions->yep
    ELSE
     col 51, captions->nope
    ENDIF
    row + 2, col 5, captions->override
    IF ((temp->allow_user_to_override_person_match="1"))
     col 68, captions->yep
    ELSE
     col 68, captions->nope
    ENDIF
    row + 1, col 55, "* * * * * * * * * *",
    row + 2, col 0, captions->prefparam,
    ":", row + 2, col 3,
    captions->prefix, col 11, captions->prefdesc,
    col 53, captions->temp, col 81,
    captions->tempdesc, row + 1, col 3,
    "------", col 11, "----------------------------------------",
    col 53, "--------------------------", col 81,
    "----------------------------------------", already_printed = "Y"
   ENDIF
   row + 1
   IF ((temp->qual[d.seq].site_disp > "00"))
    col 3, site_pref_disp
   ELSE
    col 5, temp->qual[d.seq].prefix_name
   ENDIF
   col 11, temp->qual[d.seq].prefix_desc, col 53,
   temp->qual[d.seq].template_short_desc, col 81, temp->qual[d.seq].template_description
   IF (((row+ 10) > maxrow))
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
   col 55, "##########     "
  WITH nocounter, maxcol = 132, nullreport,
   maxrow = 63, compress
 ;end select
 SET reply->status_data.status = "S"
END GO
