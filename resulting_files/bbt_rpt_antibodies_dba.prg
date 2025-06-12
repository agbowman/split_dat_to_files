CREATE PROGRAM bbt_rpt_antibodies:dba
 RECORD reply(
   1 rpt_list[*]
     2 rpt_filename = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
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
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 as_of_date = vc
   1 database_audit = vc
   1 page_no = vc
   1 time = vc
   1 antibody_tool = vc
   1 antibodies = vc
   1 display_name = vc
   1 special_inst = vc
   1 chart_name = vc
   1 anti_d = vc
   1 active = vc
   1 significance = vc
   1 yes = vc
   1 no = vc
   1 end_of_report = vc
 )
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","AS OF DATE:  ")
 SET captions->database_audit = uar_i18ngetmessage(i18nhandle,"database_audit","DATABASE AUDIT")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","PAGE NO:  ")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","TIME:  ")
 SET captions->antibody_tool = uar_i18ngetmessage(i18nhandle,"antibody_tool","ANTIBODY TOOL")
 SET captions->antibodies = uar_i18ngetmessage(i18nhandle,"antibodies","ANTIBODIES")
 SET captions->display_name = uar_i18ngetmessage(i18nhandle,"display_name","DISPLAY NAME")
 SET captions->special_inst = uar_i18ngetmessage(i18nhandle,"special_inst","SPECIAL INSTRUCTIONS")
 SET captions->chart_name = uar_i18ngetmessage(i18nhandle,"chart_name","CHART NAME")
 SET captions->anti_d = uar_i18ngetmessage(i18nhandle,"anti_d","ANTI-D")
 SET captions->active = uar_i18ngetmessage(i18nhandle,"active","ACTIVE")
 SET captions->significance = uar_i18ngetmessage(i18nhandle,"significance","SIGNIFICANCE")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","NO")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * END OF REPORT * * * ")
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_antibodies", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  cv.code_value, cv.display, cv.description,
  cv.collation_seq, cv.active_ind, tr.requirement_cd,
  tr.anti_d_ind, tr.description
  FROM code_value cv,
   transfusion_requirements tr
  PLAN (cv
   WHERE cv.code_set=1613)
   JOIN (tr
   WHERE cv.code_value=tr.requirement_cd)
  ORDER BY cv.collation_seq
  HEAD REPORT
   select_ok_ind = 0
  HEAD PAGE
   col 1, captions->as_of_date, col 14,
   curdate"@DATECONDENSED;;d", col 52, captions->database_audit,
   col 108, captions->page_no, col 120,
   curpage"##", row + 1, col 7,
   captions->time, col 14, curtime"@TIMENOSECONDS;;M",
   col 52, captions->antibody_tool, row + 1,
   col 53, captions->antibodies, row + 2,
   line = fillstring(122,"-"), line, row + 1,
   col 4, captions->display_name, col 30,
   captions->special_inst, col 60, captions->chart_name,
   col 85, captions->anti_d, col 96,
   captions->active, col 106, captions->significance,
   row + 1, line, row + 2
  DETAIL
   col 2, cv.display, col 20,
   cv.description, col 62, tr.description
   IF (tr.anti_d_ind=1)
    col 87, captions->yes
   ELSEIF (tr.anti_d_ind=0)
    col 88, captions->no
   ENDIF
   IF (cv.active_ind=1)
    col 97, captions->yes
   ELSEIF (cv.active_ind=0)
    col 98, captions->no
   ENDIF
   IF (tr.significance_ind=1)
    col 110, captions->yes
   ELSEIF (tr.significance_ind=0)
    col 111, captions->no
   ENDIF
   row + 1
   IF (row >= 58)
    BREAK
   ENDIF
  FOOT REPORT
   row + 3,
   CALL center(captions->end_of_report,0,125), select_ok_ind = 1
  WITH nullreport, nocounter, compress,
   nolandscape
 ;end select
 SET rpt_cnt = (rpt_cnt+ 1)
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
