CREATE PROGRAM cps_upd_agc_ref_curves:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select the growth chart(s) to be modified:" = 0,
  "Select the percentile(s):" = "",
  "Select the display type:" = 0.000000
  WITH outdev, chart_id, percentile,
  display_type
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
 DECLARE i18nhandle = i4 WITH private, noconstant(0)
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE t_str = vc WITH public, noconstant("")
 DECLARE line = c150 WITH public, constant(fillstring(150,"-"))
 DECLARE title_printed = c1 WITH public, noconstant("N")
 DECLARE sl_no = i4 WITH public, noconstant(0)
 DECLARE cur_user = vc WITH public, noconstant("")
 DECLARE l_title = vc WITH public, constant(uar_i18ngetmessage(i18nhandle,"l_title",
   "ADVANCED GROWTH CHART"))
 DECLARE l_date_time = vc WITH public, constant(uar_i18ngetmessage(i18nhandle,"l_date","Date/Time:"))
 DECLARE l_chart_title = vc WITH public, constant(uar_i18ngetmessage(i18nhandle,"l_chart_title",
   "Chart Title"))
 DECLARE l_chart_source = vc WITH public, constant(uar_i18ngetmessage(i18nhandle,"l_chart_source",
   "Chart Source"))
 DECLARE l_percentile = vc WITH public, constant(uar_i18ngetmessage(i18nhandle,"l_percentile",
   "Percentile(s)"))
 DECLARE l_display_type = vc WITH public, constant(uar_i18ngetmessage(i18nhandle,"l_display_type",
   "Display Type"))
 DECLARE l_sl_no = vc WITH public, constant(uar_i18ngetmessage(i18nhandle,"l_sl_no","Sl No."))
 DECLARE l_no_update = vc WITH public, constant(uar_i18ngetmessage(i18nhandle,"l_no_update",
   "*** Could not update any growth chart. Reference curves for the selected growth chart(s) are not be available. ***"
   ))
 DECLARE l_curr_user = vc WITH public, constant(uar_i18ngetmessage(i18nhandle,"l_curr_user",
   "Current User:"))
 DECLARE l_note = vc WITH public, constant(uar_i18ngetmessage(i18nhandle,"l_note",
   "*** NOTE: Please cycle the CPMScriptCache server (entry id - 80) to view the changes. ***"))
 DECLARE l_description = vc WITH public, constant(uar_i18ngetmessage(i18nhandle,"l_description",
   "The list of growth chart(s) given below have been updated."))
 DECLARE l_description1 = vc WITH public, constant(uar_i18ngetmessage(i18nhandle,"l_description1",
   "The display type of the reference curve(s) is now set to"))
 DECLARE l_end_of_report = vc WITH public, constant(uar_i18ngetmessage(i18nhandle,"l_end_of_report",
   "*** end of report ***"))
 SELECT INTO "nl:"
  FROM ref_dataset r
  WHERE (r.chart_definition_id= $CHART_ID)
   AND (r.display_name= $PERCENTILE)
  WITH nocounter, forupdate(r)
 ;end select
 IF (curqual != 0)
  UPDATE  FROM ref_dataset r
   SET r.display_type_cd =  $DISPLAY_TYPE, r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_id
     = reqinfo->updt_id,
    r.updt_cnt = (r.updt_cnt+ 1), r.updt_task = reqinfo->updt_task, r.updt_applctx = reqinfo->
    updt_applctx
   WHERE (r.chart_definition_id= $CHART_ID)
    AND (r.display_name= $PERCENTILE)
   WITH nocounter
  ;end update
  COMMIT
 ENDIF
 IF ((reqinfo->updt_id != 0.0))
  SELECT INTO "nl:"
   FROM prsnl p
   WHERE (p.person_id=reqinfo->updt_id)
   DETAIL
    cur_user = concat(trim(p.name_first)," ",trim(p.name_last))
   WITH nocounter
  ;end select
 ELSE
  SET cur_user = curuser
 ENDIF
 SELECT INTO  $OUTDEV
  cd.chart_title, percentile = r.display_name, r_display_type_disp = uar_get_code_display(r
   .display_type_cd),
  cd_chart_source_disp = uar_get_code_display(cd.chart_source_cd)
  FROM ref_dataset r,
   chart_definition cd
  PLAN (cd
   WHERE (cd.chart_definition_id= $CHART_ID))
   JOIN (r
   WHERE r.chart_definition_id=cd.chart_definition_id
    AND (r.display_name= $PERCENTILE))
  ORDER BY cd_chart_source_disp, cd.chart_title, cd.chart_definition_id
  HEAD REPORT
   page_number = 0, col 0, line,
   row + 1,
   CALL center(l_title,1,150), row + 1,
   col 0, line, row + 1,
   col 110, l_date_time, t_str = format(curdate,"@SHORTDATE"),
   col + 2, t_str, t_str = format(curtime3,"@TIMEWITHSECONDS"),
   col + 2, t_str, row + 1,
   col 110, l_curr_user, col + 2,
   cur_user, row + 1, t_str = concat(l_description1," ",trim(r_display_type_disp),"."),
   col 0, t_str, row + 1,
   col 0, l_description, row + 1,
   title_printed = "Y", col 0, line,
   row + 1, col 0, l_sl_no,
   t_str = concat(l_chart_title,"  ( ",l_chart_source," )"), col 10, t_str,
   col 98, l_percentile, row + 1,
   col 0, line
  HEAD PAGE
   page_number = (page_number+ 1)
  HEAD cd.chart_definition_id
   row + 1, sl_no = (sl_no+ 1), t_str = trim(cnvtstring(sl_no)),
   col 0, t_str, t_str = concat(trim(cd.chart_title),"  ( ",trim(cd_chart_source_disp)," )"),
   col 10, t_str, t_str = ""
  DETAIL
   IF (t_str="")
    t_str = trim(r.display_name)
   ELSE
    t_str = concat(t_str,", ",trim(r.display_name))
   ENDIF
  FOOT  cd.chart_definition_id
   IF (textlen(trim(t_str)) > 50)
    t_str1 = substring(1,49,t_str), col 98, t_str1,
    t_str1 = substring(50,99,t_str), row + 1, col 98,
    t_str1
   ELSE
    col 98, t_str
   ENDIF
  FOOT PAGE
   row + 1
  FOOT REPORT
   col 0, line, row + 2,
   CALL center(l_note,1,150), row + 2,
   CALL center(l_end_of_report,1,150)
  WITH nocounter, separator = " ", format,
   maxcol = 153, maxrow = 60
 ;end select
#exit_script
 IF (title_printed="N")
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   DETAIL
    col 0, line, row + 1,
    CALL center(l_title,1,150), row + 1, col 0,
    line, row + 1, col 110,
    l_date_time, t_str = format(curdate,"@SHORTDATE"), col + 2,
    t_str, t_str = format(curtime3,"@TIMEWITHSECONDS"), col + 2,
    t_str, row + 1, col 110,
    l_curr_user, col + 2, cur_user,
    row + 3,
    CALL center(l_no_update,1,150), row + 2,
    col 0, line
   WITH nocounter, separator = " ", format,
    maxcol = 153
  ;end select
 ENDIF
 SET script_version = "001 06/18/12 AB017375"
END GO
