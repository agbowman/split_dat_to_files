CREATE PROGRAM bbt_rpt_serv_directory
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
   1 bb_order_catalog = vc
   1 catalog_code = vc
   1 short_name = vc
   1 long_name = vc
   1 process_type = vc
   1 default_phases = vc
   1 end_of_report = vc
 )
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","AS OF DATE:   ")
 SET captions->database_audit = uar_i18ngetmessage(i18nhandle,"database_audit","DATABASE AUDIT")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","PAGE NO:  ")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","TIME:  ")
 SET captions->bb_order_catalog = uar_i18ngetmessage(i18nhandle,"bb_order_catalog",
  "BLOOD BANK ORDER CATALOG AUDIT")
 SET captions->catalog_code = uar_i18ngetmessage(i18nhandle,"catalog_code","CATALOG CODE")
 SET captions->short_name = uar_i18ngetmessage(i18nhandle,"short_name","SHORT NAME")
 SET captions->long_name = uar_i18ngetmessage(i18nhandle,"long_name","LONG NAME")
 SET captions->process_type = uar_i18ngetmessage(i18nhandle,"process_type","PROCESS TYPE")
 SET captions->default_phases = uar_i18ngetmessage(i18nhandle,"default_phases","DEFAULT PHASES")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  " * * * E N D  O F  R E P O R T * * * ")
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_directory", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  orc.catalog_cd, orc.activity_type_cd, sd.synonym_id,
  sd.short_description"####################", sd.description"#########################", sd
  .bb_processing_cd,
  sd.bb_default_phases_cd, c106.cdf_meaning, c1635.display"#########################",
  c1601.display"#########################", res = d_res.seq, phas = d_phas.seq
  FROM code_value c106,
   order_catalog orc,
   service_directory sd,
   code_value c1601,
   (dummyt d_phas  WITH seq = 1),
   code_value c1635,
   (dummyt d_res  WITH seq = 1)
  PLAN (c106
   WHERE c106.cdf_meaning="BB")
   JOIN (orc
   WHERE orc.activity_type_cd=c106.code_value)
   JOIN (sd
   WHERE orc.catalog_cd=sd.catalog_cd)
   JOIN (d_res
   WHERE d_res.seq=1)
   JOIN (c1635
   WHERE sd.bb_processing_cd=c1635.code_value)
   JOIN (d_phas
   WHERE d_phas.seq=1)
   JOIN (c1601
   WHERE sd.bb_default_phases_cd=c1601.code_value)
  ORDER BY sd.short_description
  HEAD REPORT
   select_ok_ind = 0
  HEAD PAGE
   col 1, captions->as_of_date, col 14,
   curdate"@DATECONDENSED;;DATE", col 52, captions->database_audit,
   col 116, captions->page_no, col 126,
   curpage"##", row + 1, col 7,
   captions->time, col 14, curtime"@TIMENOSECONDS;;MTIME",
   col 45, captions->bb_order_catalog, row + 1,
   line1 = fillstring(130,"="), line1, row + 1,
   col 1, captions->catalog_code, col 18,
   captions->short_name, col 45, captions->long_name,
   col 78, captions->process_type, col 103,
   captions->default_phases, row + 1, line1,
   row + 1
  DETAIL
   IF (row=58)
    BREAK
   ENDIF
   col 1, orc.catalog_cd, col 18,
   sd.short_description, col 45, sd.description
   IF (sd.bb_processing_cd > 0)
    col 78, c1635.display
   ENDIF
   IF (sd.bb_default_phases_cd > 0)
    col 103, c1601.display
   ENDIF
   row + 1
  FOOT REPORT
   row + 3, col 49, captions->end_of_report,
   select_ok_ind = 1
  WITH nullreport, nocounter, compress,
   nolandscape, dontcare = sd, dontcare = c1635,
   dontcare = c1601, outerjoin = d_res, outerjoin = d_phas
 ;end select
 SET rpt_cnt = (rpt_cnt+ 1)
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
