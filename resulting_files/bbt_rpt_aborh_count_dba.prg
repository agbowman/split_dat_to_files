CREATE PROGRAM bbt_rpt_aborh_count:dba
 PAINT
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
   1 rpt_order_summary = vc
   1 page_no = vc
   1 time = vc
   1 beg_date = vc
   1 ending_date = vc
   1 accession_no = vc
   1 short_desc = vc
   1 order_status = vc
   1 completed_date = vc
   1 total_orders = vc
   1 end_of_report = vc
   1 what_printer = vc
   1 start_date = vc
   1 end_date = vc
 )
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","AS OF DATE:  ")
 SET captions->rpt_order_summary = uar_i18ngetmessage(i18nhandle,"rpt_order_summary",
  "Patient ABORh Order Summary")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","PAGE NO: ")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","TIME:  ")
 SET captions->beg_date = uar_i18ngetmessage(i18nhandle,"beg_date","Beginning Date:")
 SET captions->ending_date = uar_i18ngetmessage(i18nhandle,"ending_date","Ending Date:")
 SET captions->accession_no = uar_i18ngetmessage(i18nhandle,"accession_no","Accession #")
 SET captions->short_desc = uar_i18ngetmessage(i18nhandle,"short_desc","Short Desc.")
 SET captions->order_status = uar_i18ngetmessage(i18nhandle,"order_status","Order Status")
 SET captions->completed_date = uar_i18ngetmessage(i18nhandle,"completed_date","Completed Date")
 SET captions->total_orders = uar_i18ngetmessage(i18nhandle,"total_orders","Total Orders: ")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  " * * * E N D  O F  R E P O R T * * * ")
 SET captions->what_printer = uar_i18ngetmessage(i18nhandle,"what_printer",
  "What printer do you want to use?")
 SET captions->start_date = uar_i18ngetmessage(i18nhandle,"start_date",
  "Enter start date, example 01-JAN-1998")
 SET captions->end_date = uar_i18ngetmessage(i18nhandle,"end_date",
  "Enter end date, example 01-JAN-1998")
 DECLARE stat = i2 WITH noconstant(0)
 DECLARE order_processing_cs = i4 WITH constant(1635)
 DECLARE order_status_cs = i4 WITH constant(6004)
 DECLARE patient_abo_cdf = c12 WITH noconstant(fillstring(12," "))
 DECLARE completed_cdf = c12 WITH noconstant(fillstring(12," "))
 DECLARE patient_abo_cd = f8 WITH noconstant(0.0)
 DECLARE completed_cd = f8 WITH noconstant(0.0)
 SET patient_abo_cdf = "PATIENT ABO"
 SET completed_cdf = "COMPLETED"
 SET stat = uar_get_meaning_by_codeset(order_processing_cs,patient_abo_cdf,1,patient_abo_cd)
 IF (stat != 0)
  CALL echo(concat("Error getting code value: ",patient_abo_cdf,cnvtstring(patient_abo_cd,32,2)))
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(order_status_cs,completed_cdf,1,completed_cd)
 IF (stat != 0)
  CALL echo(concat("Error getting code value: ",completed_cdf,cnvtstring(completed_cd,32,2)))
  GO TO exit_script
 ENDIF
 SET v_printer = "MINE"
 DECLARE v_begin_date = c11
 DECLARE v_end_date = c11
 CALL box(1,1,15,80)
 CALL line(4,1,80,xhor)
 CALL text(2,10,captions->rpt_order_summary)
 CALL text(5,5,captions->what_printer)
 CALL text(7,5,captions->start_date)
 CALL text(9,5,captions->end_date)
 CALL accept(5,38,"PPPP;CU","MINE")
 SET v_printer = curaccept
 CALL accept(7,45,"XXXXXXXXXXX;CD","  -   -    "
  WHERE cnvtdatetime(curaccept) >= cnvtdatetime("01-JAN-1995"))
 SET v_begin_date = curaccept
 CALL accept(9,45,"XXXXXXXXXXX;CD","  -   -    "
  WHERE cnvtdatetime(curaccept) >= cnvtdatetime("01-JAN-1995")
   AND cnvtdatetime(curaccept) > cnvtdatetime(v_begin_date))
 SET v_end_date = curaccept
 CALL video(n)
 SELECT
  sd.catalog_cd, sd.short_description"####################", ord.catalog_cd,
  ord.order_id, ord.status_dt_tm, order_display = uar_get_code_display(ord.order_status_cd)
  "###############",
  acc = d_acc.seq, aor.order_id, aor.accession
  FROM service_directory sd,
   orders ord,
   (dummyt d_acc  WITH seq = 1),
   accession_order_r aor
  PLAN (sd
   WHERE sd.bb_processing_cd=patient_abo_cd)
   JOIN (ord
   WHERE sd.catalog_cd=ord.catalog_cd
    AND ord.status_dt_tm >= cnvtdatetime(v_begin_date)
    AND ord.status_dt_tm <= cnvtdatetime(v_end_date)
    AND ord.order_status_cd=completed_cd)
   JOIN (d_acc
   WHERE d_acc.seq=1)
   JOIN (aor
   WHERE ord.order_id=aor.order_id
    AND aor.primary_flag=0)
  ORDER BY aor.accession, sd.catalog_cd
  HEAD REPORT
   order_cnt = 0, beg_dt_tm = cnvtdatetime(v_begin_date), end_dt_tm = cnvtdatetime(v_end_date),
   formatted_acc = fillstring(20," ")
  HEAD PAGE
   col 1, captions->as_of_date, col 14,
   curdate"@DATECONDENSED;;DATE", col 45, captions->rpt_order_summary,
   col 108, captions->page_no, col 120,
   curpage"##", row + 1, col 7,
   captions->time, col 14, curtime"@TIMENOSECONDS;;MTIME",
   row + 2, col 25, captions->beg_date,
   col 41, beg_dt_tm"@SHORTDATE;;d", col 50,
   beg_dt_tm"@TIMENOSECONDS;;m", col 64, captions->ending_date,
   col 77, end_dt_tm"@SHORTDATE;;d", col 86,
   end_dt_tm"@TIMENOSECONDS;;m", row + 2, line = fillstring(122,"-"),
   line, row + 1, col 2,
   captions->accession_no, col 24, captions->short_desc,
   col 48, captions->order_status, col 67,
   captions->completed_date, row + 1, line,
   row + 1
  DETAIL
   formatted_acc = cnvtacc(aor.accession), col 2, formatted_acc,
   col 24, sd.short_description, col 48,
   order_display, col 67, ord.status_dt_tm"@SHORTDATE;;DATE",
   row + 1
   IF (row >= 58)
    BREAK
   ENDIF
   order_cnt += 1
  FOOT REPORT
   row + 3, col 002, captions->total_orders,
   col 016, order_cnt"####;p ", row + 2,
   CALL center(captions->end_of_report,1,125)
  WITH nullreport, nocounter, compress,
   nolandscape, dontcare = aor, outerjoin = d_acc
 ;end select
#exit_script
END GO
