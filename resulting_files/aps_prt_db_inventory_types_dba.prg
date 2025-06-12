CREATE PROGRAM aps_prt_db_inventory_types:dba
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
 FREE RECORD captions
 RECORD captions(
   1 head_rpt_title = vc
   1 pathnet_title = vc
   1 date_label = vc
   1 dir_label = vc
   1 time_label = vc
   1 db_audit_title = vc
   1 by_label = vc
   1 tool_name_title = vc
   1 page_label = vc
   1 inv_type_label = vc
   1 def_ret_label = vc
   1 ret_overrides_label = vc
   1 prefix_label = vc
   1 normalcy_code_label = vc
   1 retention_label = vc
   1 hz_line = vc
   1 foot_rpt_title = vc
   1 continued = vc
   1 end_report = vc
   1 short_hz_line = vc
 )
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
 SET modify = predeclare
 DECLARE mli18nhandle = i4 WITH protect, noconstant(0)
 DECLARE mlstat = i4 WITH protect, noconstant(0)
 DECLARE ddefretentionvalue = f8 WITH protect, noconstant(0.0)
 DECLARE sdefretentionunits = vc WITH protect, noconstant("")
 SET reply->status_data.status = "F"
 CALL i18ncaptions(null)
 EXECUTE cpm_create_file_name_logical "apsDBInvSetup", "dat", "x"
 SET reply->print_status_data.print_directory = ""
 SET reply->print_status_data.print_filename = ""
 SET reply->print_status_data.print_dir_and_filename = ""
 SET reply->print_status_data.print_directory = substring(1,10,cpm_cfn_info->file_name_path)
 SET reply->print_status_data.print_filename = cpm_cfn_info->file_name_logical
 SET reply->print_status_data.print_dir_and_filename = cpm_cfn_info->file_name_path
 CALL echo(reply->print_status_data.print_filename)
 SELECT INTO value(reply->print_status_data.print_filename)
  inventory_type_disp = uar_get_code_display(air.inventory_type_cd), normalcy_disp = substring(1,39,
   uar_get_code_display(air.normalcy_cd)), prefix_disp = substring(1,39,ap.prefix_name)
  FROM ap_inv_retention air,
   ap_prefix ap
  PLAN (air
   WHERE air.ap_inv_retention_id != 0.0)
   JOIN (ap
   WHERE ap.prefix_id=air.prefix_id)
  ORDER BY inventory_type_disp, ap.prefix_name, normalcy_disp
  HEAD REPORT
   dcurinvtypecd = 0.0, nwritecolind = 0, sdatestr = format(curdate,"@SHORTDATE;;Q"),
   snewday = format(curdate,"@WEEKDAYABBREV;;D"), snewdate = format(curdate,"@MEDIUMDATE4YR;;D"),
   soverrideretentionunits = fillstring(35," ")
  HEAD PAGE
   row + 1, col 1, captions->head_rpt_title,
   col 56,
   CALL center(captions->pathnet_title,1,132), col 110,
   captions->date_label, col 117, sdatestr,
   row + 1, col 1, captions->dir_label,
   col 110, captions->time_label, col 117,
   curtime, row + 1, col 54,
   CALL center(captions->db_audit_title,1,132), col 112, captions->by_label,
   col 117, request->user_name, row + 1,
   col 50,
   CALL center(captions->tool_name_title,1,132), col 110,
   captions->page_label, col 117, curpage"###"
   IF (air.inventory_type_cd=dcurinvtypecd)
    row + 1, row + 1, col 1,
    captions->inv_type_label, " ", inventory_type_disp,
    row + 1, col 1, captions->def_ret_label,
    " ", ddefretentionvalue"### ;L;F", sdefretentionunits,
    nwritecolind = 1
   ENDIF
  HEAD air.inventory_type_cd
   dcurinvtypecd = air.inventory_type_cd, ddefretentionvalue = air.retention_tm_value,
   sdefretentionunits = substring(1,35,trim(uar_get_code_display(air.retention_units_cd)))
   IF (((row+ 7) >= (maxrow - 4)))
    BREAK
   ENDIF
   nwritecolind = 1, row + 1, row + 1,
   col 1, captions->inv_type_label, " ",
   inventory_type_disp, row + 1, col 1,
   captions->def_ret_label, " ", ddefretentionvalue"### ;L;F",
   sdefretentionunits
  DETAIL
   IF (((row+ 1) >= (maxrow - 4)))
    BREAK
   ENDIF
   IF (((air.prefix_id != 0.0) OR (air.normalcy_cd != 0.0)) )
    IF (nwritecolind=1)
     row + 1, col 1, captions->ret_overrides_label,
     row + 1, col 10, captions->prefix_label,
     col 50, captions->normalcy_code_label, col 90,
     captions->retention_label, row + 1, col 10,
     captions->short_hz_line, col 50, captions->short_hz_line,
     col 90, captions->short_hz_line, nwritecolind = 0
    ENDIF
    soverrideretentionunits = substring(1,35,trim(uar_get_code_display(air.retention_units_cd))), row
     + 1, col 10,
    prefix_disp, col 50, normalcy_disp,
    col 90, air.retention_tm_value"###;L;F", col 94,
    soverrideretentionunits
   ENDIF
  FOOT PAGE
   row 60, col 1, captions->hz_line,
   row + 1, col 1, captions->foot_rpt_title,
   col 58, snewday, " ",
   snewdate, col 110, captions->page_label,
   col 117, curpage"###", row + 1,
   col 55,
   CALL center(captions->continued,1,132)
  FOOT REPORT
   col 55,
   CALL center(fillstring(130," "),1,132), col 55,
   CALL center(captions->end_report,1,132)
  WITH nocounter, maxcol = 132, nullreport,
   maxrow = 63, compress
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 DECLARE i18ncaptions() = null
 SUBROUTINE i18ncaptions(null)
   SET mlstat = uar_i18nlocalizationinit(mli18nhandle,curprog,"",curcclrev)
   SET captions->by_label = uar_i18ngetmessage(mli18nhandle,"by_label","BY:")
   SET captions->continued = uar_i18ngetmessage(mli18nhandle,"continued","CONTINUED...")
   SET captions->date_label = uar_i18ngetmessage(mli18nhandle,"date_label","DATE:")
   SET captions->def_ret_label = uar_i18ngetmessage(mli18nhandle,"def_ret_label","DEFAULT RETENTION:"
    )
   SET captions->dir_label = uar_i18ngetmessage(mli18nhandle,"dir_label","DIRECTORY:")
   SET captions->foot_rpt_title = uar_i18ngetmessage(mli18nhandle,"foot_rpt_title",
    "REPORT: DB INVENTORY SETUP DATABASE AUDIT")
   SET captions->head_rpt_title = uar_i18ngetmessage(mli18nhandle,"head_rpt_title",
    "REPORT: APS_PRT_DB_INVENTORY_TYPE.PRG")
   SET captions->hz_line = fillstring(130,"-")
   SET captions->inv_type_label = uar_i18ngetmessage(mli18nhandle,"inv_type_label","INVENTORY TYPE:")
   SET captions->normalcy_code_label = uar_i18ngetmessage(mli18nhandle,"normalcy_code_label",
    "NORMALCY CODE:")
   SET captions->page_label = uar_i18ngetmessage(mli18nhandle,"page_label","PAGE:")
   SET captions->pathnet_title = uar_i18ngetmessage(mli18nhandle,"pathnet_title",
    "PathNet Anatomic Pathology")
   SET captions->prefix_label = uar_i18ngetmessage(mli18nhandle,"prefix_label","PREFIX:")
   SET captions->db_audit_title = uar_i18ngetmessage(mli18nhandle,"db_audit_title",
    "REFERENCE DATABASE AUDIT")
   SET captions->ret_overrides_label = uar_i18ngetmessage(mli18nhandle,"ret_overrides_label",
    "RETENTION OVERRIDES:")
   SET captions->retention_label = uar_i18ngetmessage(mli18nhandle,"retention_label","RETENTION:")
   SET captions->time_label = uar_i18ngetmessage(mli18nhandle,"time_label","TIME:")
   SET captions->tool_name_title = uar_i18ngetmessage(mli18nhandle,"tool_name_title",
    "DB INVENTORY SETUP")
   SET captions->end_report = uar_i18ngetmessage(mli18nhandle,"end_report","### END OF REPORT ###")
   SET captions->short_hz_line = fillstring(39,"-")
 END ;Subroutine
END GO
