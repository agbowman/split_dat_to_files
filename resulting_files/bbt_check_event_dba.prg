CREATE PROGRAM bbt_check_event:dba
 RECORD reply(
   1 qual[*]
     2 accession = c20
     2 order_id = f8
     2 catalog_cd = f8
     2 catalog_disp = c40
     2 task_assay_cd = f8
     2 task_assay_disp = c40
     2 result_id = f8
     2 result_dt_tm = dq8
     2 result_type_cd = f8
     2 result_type_disp = c40
     2 ref_nbr = c60
     2 alias_nf_ind = i2
     2 final_event_ind = i2
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
   1 rpt_bbt_activity = vc
   1 date_range = vc
   1 accession = vc
   1 order_mnemonic = vc
   1 assay_mnemonic = vc
   1 event_type = vc
   1 event_dt_tm = vc
   1 curr_ce = vc
   1 result_id = vc
   1 rpt_assays_not = vc
   1 assay = vc
   1 alias = vc
   1 rpt_note = vc
   1 rpt_n_action = vc
   1 rpt_transfused = vc
   1 product_number = vc
   1 product_event_id = vc
   1 product_id = vc
   1 crossmatched_products = vc
   1 product_nbr = vc
   1 rpt_clinical_audit = vc
   1 results_from = vc
   1 rpt_to = vc
   1 show_only = vc
   1 not_in = vc
   1 correct = vc
   1 start_dt = vc
   1 processing = vc
   1 no_report_error = vc
 )
 SET captions->rpt_bbt_activity = uar_i18ngetmessage(i18nhandle,"rpt_bbt_activity",
  "BBT Activity and Clinical Event Audit Report")
 SET captions->date_range = uar_i18ngetmessage(i18nhandle,"date_range","Date Range:")
 SET captions->accession = uar_i18ngetmessage(i18nhandle,"accession","Accession")
 SET captions->order_mnemonic = uar_i18ngetmessage(i18nhandle,"order_mnemonic","Order Mnemonic")
 SET captions->assay_mnemonic = uar_i18ngetmessage(i18nhandle,"assay_mnemonic","Assay Mnemonic")
 SET captions->event_type = uar_i18ngetmessage(i18nhandle,"event_type","Event Type")
 SET captions->event_dt_tm = uar_i18ngetmessage(i18nhandle,"event_dt_tm","Event Date/Time")
 SET captions->curr_ce = uar_i18ngetmessage(i18nhandle,"curr_ce","Curr CE")
 SET captions->result_id = uar_i18ngetmessage(i18nhandle,"result_id","Result ID")
 SET captions->rpt_assays_not = uar_i18ngetmessage(i18nhandle,"rpt_assays_not",
  "Assays not configured to post to Clinical Event tables:")
 SET captions->assay = uar_i18ngetmessage(i18nhandle,"assay","Assay")
 SET captions->alias = uar_i18ngetmessage(i18nhandle,"alias","Alias")
 SET captions->rpt_note = uar_i18ngetmessage(i18nhandle,"rpt_note",
  "NOTE:  Curr CE column indicates whether the most recent result for this discrete assay is in clinical events."
  )
 SET captions->rpt_n_action = uar_i18ngetmessage(i18nhandle,"rpt_n_action",
  "       An 'N' in this column means action must be taken to ensure the correct results are in clinical events."
  )
 SET captions->rpt_transfused = uar_i18ngetmessage(i18nhandle,"rpt_transfused",
  "Transfused and Returned Inventory Products")
 SET captions->product_number = uar_i18ngetmessage(i18nhandle,"product_number","Product Number")
 SET captions->product_event_id = uar_i18ngetmessage(i18nhandle,"product_event_id","Product Event ID"
  )
 SET captions->product_id = uar_i18ngetmessage(i18nhandle,"product_id","Product ID")
 SET captions->crossmatched_products = uar_i18ngetmessage(i18nhandle,"crossmatched_products",
  "Crossmatched Products")
 SET captions->product_nbr = uar_i18ngetmessage(i18nhandle,"product_nbr","Product Nbr")
 SET captions->rpt_clinical_audit = uar_i18ngetmessage(i18nhandle,"rpt_clinical_audit",
  "BBT Clinical Event Audit")
 SET captions->results_from = uar_i18ngetmessage(i18nhandle,"results_from","Results From:")
 SET captions->rpt_to = uar_i18ngetmessage(i18nhandle,"rpt_to","To:")
 SET captions->show_only = uar_i18ngetmessage(i18nhandle,"show_only",
  "Show only assays in which the most current result is")
 SET captions->not_in = uar_i18ngetmessage(i18nhandle,"not_in","not in clinical events (Yes/All)?")
 SET captions->correct = uar_i18ngetmessage(i18nhandle,"correct","Correct (Y/N)?")
 SET captions->start_dt = uar_i18ngetmessage(i18nhandle,"start_dt",
  "Start date must be earlier than end date!")
 SET captions->processing = uar_i18ngetmessage(i18nhandle,"processing","Processing...")
 SET captions->no_report_error = uar_i18ngetmessage(i18nhandle,"no_report_error",
  "No data was returned for any of the reports.")
 RECORD dates(
   1 start_dt_tm = dq8
   1 end_dt_tm = dq8
   1 future_dt_tm = dq8
 )
 RECORD activity_cross(
   1 qual[*]
     2 accession = c20
     2 order_id = f8
     2 catalog_cd = f8
     2 task_assay_cd = f8
     2 result_id = f8
     2 result_dt_tm = dq8
     2 result_type_cd = f8
     2 ref_nbr = c60
     2 product_id = f8
     2 bb_result_id = f8
     2 product_nbr = c20
     2 activity_type_cd = f8
 )
 RECORD activity_trans(
   1 qual[*]
     2 product_event_id = f8
     2 active_ind = i2
     2 product_id = f8
     2 product_nbr = c20
     2 order_id = f8
     2 bb_result_id = f8
     2 result_dt_tm = dq8
     2 result_type_cd = f8
     2 ref_nbr = c60
 )
 RECORD activity(
   1 qual[*]
     2 accession = c20
     2 order_id = f8
     2 catalog_cd = f8
     2 task_assay_cd = f8
     2 result_id = f8
     2 result_dt_tm = dq8
     2 result_type_cd = f8
     2 ref_nbr = c60
     2 alias_nf_ind = i2
     2 activity_type_cd = f8
 )
 RECORD assay_nf(
   1 assay[*]
     2 task_assay_cd = f8
     2 task_assay_disp = c20
 )
 SET serrormsg = fillstring(255," ")
 SET serror_check = error(serrormsg,1)
 DECLARE verified_cdf = c12 WITH noconstant(fillstring(12," "))
 DECLARE corrected_cdf = c12 WITH noconstant(fillstring(12," "))
 DECLARE autoverified_cdf = c12 WITH noconstant(fillstring(12," "))
 DECLARE transfused_cdf = c12 WITH noconstant(fillstring(12," "))
 DECLARE inprogress_cdf = c12 WITH noconstant(fillstring(12," "))
 DECLARE bbt_cdf = c12 WITH noconstant(fillstring(12," "))
 DECLARE cl_crossmatched_cdf = c12 WITH noconstant(fillstring(12," "))
 DECLARE cl_transfused_cdf = c12 WITH noconstant(fillstring(12," "))
 DECLARE cl_returned_cdf = c12 WITH noconstant(fillstring(12," "))
 DECLARE event_type_codeset = i4 WITH constant(1901)
 DECLARE product_states_codeset = i4 WITH constant(1610)
 DECLARE activity_type_codeset = i4 WITH constant(106)
 DECLARE clinical_product_states_codeset = i4 WITH constant(14131)
 SET verified_cdf = "VERIFIED"
 SET corrected_cdf = "CORRECTED"
 SET autoverified_cdf = "AUTOVERIFIED"
 SET transfused_cdf = "7"
 SET inprogress_cdf = "16"
 SET bbt_cdf = "BB"
 SET cl_crossmatched_cdf = "CROSSMATCHED"
 SET cl_transfused_cdf = "TRANSFUSED"
 SET cl_returned_cdf = "RETURNED"
 DECLARE ver_cd = f8 WITH noconstant(0.0)
 DECLARE cor_cd = f8 WITH noconstant(0.0)
 DECLARE auto_ver_cd = f8 WITH noconstant(0.0)
 DECLARE transfused_cd = f8 WITH noconstant(0.0)
 DECLARE inprogress_cd = f8 WITH noconstant(0.0)
 DECLARE crossmatched_prod_status_cd = f8 WITH noconstant(0.0)
 DECLARE transfused_prod_status_cd = f8 WITH noconstant(0.0)
 DECLARE returned_prod_status_cd = f8 WITH noconstant(0.0)
 DECLARE bbt_cd = f8 WITH noconstant(0.0)
 DECLARE print_output_dest = c30 WITH noconstant(fillstring(30," "))
 DECLARE reply_cnt = i2 WITH noconstant(0)
 DECLARE interface_flag = i2 WITH noconstant(0)
 DECLARE ce_activity_cnt = i2 WITH noconstant(0)
 DECLARE nf_activity_cnt = i2 WITH noconstant(0)
 DECLARE curr_result_ind = i2 WITH noconstant(0)
 DECLARE stat = i2 WITH noconstant(0)
 SET reply->status_data.status = "F"
 DECLARE log_program_name = vc WITH constant("BBT_CHECK_EVENT")
 SET dt_day_beg = fillstring(2," ")
 SET dt_month_beg = fillstring(3," ")
 SET dt_year_beg = fillstring(4," ")
 SET dt_day_end = fillstring(2," ")
 SET dt_month_end = fillstring(3," ")
 SET dt_year_end = fillstring(4," ")
 SET tm_hour_beg = fillstring(2," ")
 SET tm_min_beg = fillstring(2," ")
 SET tm_hour_end = fillstring(2," ")
 SET tm_min_end = fillstring(2," ")
 SET dt_tm_beg = fillstring(23," ")
 SET dt_tm_end = fillstring(23," ")
 DECLARE bbt_ce_orders = vc WITH noconstant(fillstring(30," "))
 DECLARE bbt_ce_trans = vc WITH noconstant(fillstring(30," "))
 DECLARE bbt_ce_xm = vc WITH noconstant(fillstring(30," "))
 DECLARE display_ind = i2 WITH noconstant(0)
 DECLARE found_transfused_ind = i2 WITH noconstant(0)
 DECLARE found_returned_ind = i2 WITH noconstant(0)
 DECLARE found_ce_row_ind = i2 WITH noconstant(0)
 DECLARE found_latest_ind = i2 WITH noconstant(0)
 DECLARE curqual_orders = i2 WITH noconstant(0)
 DECLARE curqual_trans_return = i2 WITH noconstant(0)
 DECLARE curqual_crossmatch = i2 WITH noconstant(0)
 IF (validate(request->batch_selection,"N")="N")
  EXECUTE cclseclogin
 ENDIF
 SET stat = uar_get_meaning_by_codeset(event_type_codeset,verified_cdf,1,ver_cd)
 IF (stat != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Error retrieving code_value for code_set ",cnvtstring(event_type_codeset)," and cdf_meaning ",
   verified_cdf)
  CALL echo(concat("Error getting code value: ",verified_cdf,cnvtstring(ver_cd,32,2)))
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(event_type_codeset,corrected_cdf,1,cor_cd)
 IF (stat != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Error retrieving code_value for code_set ",cnvtstring(event_type_codeset)," and cdf_meaning ",
   corrected_cdf)
  CALL echo(concat("Error getting code value: ",corrected_cdf))
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(event_type_codeset,autoverified_cdf,1,auto_ver_cd)
 IF (stat != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Error retrieving code_value for code_set ",cnvtstring(event_type_codeset)," and cdf_meaning ",
   autoverified_cdf)
  CALL echo(concat("Error getting code value: ",autoverified_cdf))
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(product_states_codeset,transfused_cdf,1,transfused_cd)
 IF (stat != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Error retrieving code_value for code_set ",cnvtstring(product_states_codeset)," and cdf_meaning ",
   transfused_cdf)
  CALL echo(concat("Error getting code value: ",transfused_cdf))
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(product_states_codeset,inprogress_cdf,1,inprogress_cd)
 IF (stat != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Error retrieving code_value for code_set ",cnvtstring(product_states_codeset)," and cdf_meaning ",
   inprogress_cdf)
  CALL echo(concat("Error getting code value: ",inprogress_cdf))
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(clinical_product_states_codeset,cl_crossmatched_cdf,1,
  crossmatched_prod_status_cd)
 IF (stat != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Error retrieving code_value for code_set ",cnvtstring(clinical_product_states_codeset),
   " and cdf_meaning ",cl_crossmatched_cdf)
  CALL echo(concat("Error getting code value: ",cl_crossmatched_cdf))
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(clinical_product_states_codeset,cl_transfused_cdf,1,
  transfused_prod_status_cd)
 IF (stat != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Error retrieving code_value for code_set ",cnvtstring(clinical_product_states_codeset),
   " and cdf_meaning ",cl_transfused_cdf)
  CALL echo(concat("Error getting code value: ",cl_transfused_cdf))
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(clinical_product_states_codeset,cl_returned_cdf,1,
  returned_prod_status_cd)
 IF (stat != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Error retrieving code_value for code_set ",cnvtstring(clinical_product_states_codeset),
   " and cdf_meaning ",cl_returned_cdf)
  CALL echo(concat("Error getting code value: ",cl_returned_cdf))
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(activity_type_codeset,bbt_cdf,1,bbt_cd)
 IF (stat != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Error retrieving code_value for code_set ",cnvtstring(activity_type_codeset)," and cdf_meaning ",
   bbt_cdf)
  CALL echo(concat("Error getting code value: ",bbt_cdf))
  GO TO exit_script
 ENDIF
 DECLARE returned_event_cd = f8 WITH noconstant(0.0)
 DECLARE returned_event_disp = vc WITH noconstant(fillstring(40," "))
 DECLARE transfused_event_cd = f8 WITH noconstant(0.0)
 DECLARE transfused_event_disp = vc WITH noconstant(fillstring(40," "))
 DECLARE bbproduct_event_cd = f8 WITH noconstant(0.0)
 DECLARE bbproduct_event_disp = vc WITH noconstant(fillstring(40," "))
 SELECT INTO "nl:"
  v.event_cd, v.event_cd_disp_key
  FROM v500_event_code v
  WHERE ((v.event_cd_disp_key="RETURNINV") OR (((v.event_cd_disp_key="TRANSFUSED") OR (v
  .event_cd_disp_key="BBPRODUCT")) ))
  DETAIL
   IF (v.event_cd_disp_key="RETURNINV")
    returned_event_cd = v.event_cd, returned_event_disp = v.event_cd_disp
   ELSEIF (v.event_cd_disp_key="TRANSFUSED")
    transfused_event_cd = v.event_cd, transfused_event_disp = v.event_cd_disp
   ELSEIF (v.event_cd_disp_key="BBPRODUCT")
    bbproduct_event_cd = v.event_cd, bbproduct_event_disp = v.event_cd_disp
   ENDIF
  WITH nocounter
 ;end select
 SET curr_result_ind = 1
 IF (validate(request->batch_selection,"N")="N")
  SET interface_flag = 0
  SET output_dest = "FORMS"
 ELSE
  IF (trim(request->output_dist) > "")
   SET interface_flag = - (1)
   SET logical d value(trim(logical("CER_PRINT")))
   SET bbt_ce_orders = build("d:ceor",format(curdate,"yymmdd;;d"),format(curtime3,"hhmmsscc;;m"),
    ".txt")
   SET bbt_ce_trans = build("d:cetr",format(curdate,"yymmdd;;d"),format(curtime3,"hhmmsscc;;m"),
    ".txt")
   SET bbt_ce_xm = build("d:cexm",format(curdate,"yymmdd;;d"),format(curtime3,"hhmmsscc;;m"),".txt")
   IF ((request->batch_selection=""))
    SET nbr_days = 0
   ELSE
    SET nbr_days = (0 - cnvtint(request->batch_selection))
   ENDIF
   SET holddate = datetimeadd(cnvtdatetime(request->ops_date),nbr_days)
   SET dates->start_dt_tm = cnvtdatetime(holddate)
   SET dates->end_dt_tm = cnvtdatetime(curdate,2359)
  ELSE
   GO TO exit_script
  ENDIF
  GO TO begin_script
 ENDIF
 CALL clear(1,1)
 CALL video(n)
 CALL box(1,1,3,80)
 CALL text(2,3,captions->rpt_clinical_audit)
 CALL video(n)
 CALL text(5,3,captions->results_from)
 CALL text(6,13,captions->rpt_to)
 CALL text(9,3,captions->show_only)
 CALL text(10,3,captions->not_in)
 SET dt_day_beg = format(day(curdate),"##;P0;I")
 SET dt_month_beg = format(cnvtdatetime(curdate,curtime3),"MMM;;D")
 SET dt_year_beg = format(year(curdate),"####;P0;I")
 SET tm_hour_beg = "00"
 SET tm_min_beg = "00"
 SET dt_day_end = format(day(curdate),"##;P0;I")
 SET dt_month_end = format(cnvtdatetime(curdate,curtime3),"MMM;;D")
 SET dt_year_end = format(year(curdate),"####;P0;I")
 SET tm_hour_end = format(hour(curtime),"##;P0;I")
 SET tm_min_end = format(minute(curtime),"##;P0;I")
 CALL video(l)
 CALL text(5,17,dt_day_beg)
 CALL text(5,19,"-")
 CALL text(5,20,dt_month_beg)
 CALL text(5,23,"-")
 CALL text(5,24,dt_year_beg)
 CALL text(5,30,tm_hour_beg)
 CALL text(5,32,":")
 CALL text(5,33,tm_min_beg)
 CALL text(6,17,dt_day_end)
 CALL text(6,19,"-")
 CALL text(6,20,dt_month_end)
 CALL text(6,23,"-")
 CALL text(6,24,dt_year_end)
 CALL text(6,30,tm_hour_end)
 CALL text(6,32,":")
 CALL text(6,33,tm_min_end)
 CALL text(10,40,"Y")
 GO TO correct_yn
#acc_date_range
 CALL accept(5,17,"NN",value(dt_day_beg)
  WHERE cnvtint(curaccept) BETWEEN 1 AND 31)
 SET dt_day_beg = format(curaccept,"##;P0;I")
 CALL accept(5,20,"XXX;;CU",value(dt_month_beg)
  WHERE curaccept IN ("JAN", "FEB", "MAR", "APR", "MAY",
  "JUN", "JUL", "AUG", "SEP", "OCT",
  "NOV", "DEC"))
 SET dt_month_beg = curaccept
 CALL accept(5,24,"NNNN",value(dt_year_beg))
 SET dt_year_beg = format(curaccept,"####;P0;I")
 CALL accept(5,30,"NN",value(tm_hour_beg)
  WHERE cnvtint(curaccept) BETWEEN 0 AND 24)
 SET tm_hour_beg = format(curaccept,"##;P0;I")
 CALL accept(5,33,"NN",value(tm_min_beg)
  WHERE cnvtint(curaccept) BETWEEN 0 AND 59)
 SET tm_min_beg = format(curaccept,"##;P0;I")
 CALL accept(6,17,"NN",value(dt_day_end)
  WHERE cnvtint(curaccept) BETWEEN 1 AND 31)
 SET dt_day_end = format(curaccept,"##;P0;I")
 CALL accept(6,20,"XXX;;CU",value(dt_month_end)
  WHERE curaccept IN ("JAN", "FEB", "MAR", "APR", "MAY",
  "JUN", "JUL", "AUG", "SEP", "OCT",
  "NOV", "DEC"))
 SET dt_month_end = curaccept
 CALL accept(6,24,"NNNN",value(dt_year_end))
 SET dt_year_end = format(curaccept,"####;P0;I")
 CALL accept(6,30,"NN",value(tm_hour_end)
  WHERE cnvtint(curaccept) BETWEEN 0 AND 24)
 SET tm_hour_end = format(curaccept,"##;P0;I")
 CALL accept(6,33,"NN",value(tm_min_end)
  WHERE cnvtint(curaccept) BETWEEN 0 AND 59)
 SET tm_min_end = format(curaccept,"##;P0;I")
 CALL accept(10,40,"X;;CU","Y"
  WHERE curaccept IN ("Y", "A"))
 IF (curaccept="Y")
  SET curr_result_ind = 1
 ELSEIF (curaccept="A")
  SET curr_result_ind = 0
 ENDIF
#correct_yn
 CALL text(24,2,captions->correct)
 CALL accept(24,17,"X;;CU","Y"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="N")
  GO TO acc_date_range
 ENDIF
 SET dt_tm_beg = concat(dt_day_beg,"-",dt_month_beg,"-",dt_year_beg,
  " ",tm_hour_beg,":",tm_min_beg,":00.00")
 SET dt_tm_end = concat(dt_day_end,"-",dt_month_end,"-",dt_year_end,
  " ",tm_hour_end,":",tm_min_end,":59.99")
 SET dates->start_dt_tm = cnvtdatetime(dt_tm_beg)
 SET dates->end_dt_tm = cnvtdatetime(dt_tm_end)
 IF (cnvtdatetime(dates->start_dt_tm) >= cnvtdatetime(dates->end_dt_tm))
  CALL text(15,3,captions->start_dt)
  GO TO acc_date_range
 ENDIF
 CALL clear(11,1)
 CALL text(15,3,captions->processing)
#begin_script
 SELECT INTO "nl:"
  task_assay_disp = substring(0,20,trim(uar_get_code_display(r.task_assay_cd),3)), cver_ind = decode(
   cver.seq,"Y","N")
  FROM result_event re,
   perform_result pr,
   result r,
   accession_order_r aor,
   dummyt d1,
   code_value_event_r cver
  PLAN (re
   WHERE re.event_type_cd IN (ver_cd, cor_cd, auto_ver_cd)
    AND re.event_dt_tm >= cnvtdatetime(dates->start_dt_tm)
    AND re.event_dt_tm <= cnvtdatetime(dates->end_dt_tm))
   JOIN (pr
   WHERE pr.result_id=re.result_id
    AND pr.perform_result_id=re.perform_result_id)
   JOIN (r
   WHERE r.result_id=pr.result_id)
   JOIN (aor
   WHERE aor.order_id=r.order_id
    AND aor.activity_type_cd=bbt_cd
    AND aor.primary_flag=0)
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (cver
   WHERE cver.parent_cd=r.task_assay_cd)
  ORDER BY task_assay_disp
  HEAD REPORT
   ce_activity_cnt = 0, nf_activity_cnt = 0
  HEAD task_assay_disp
   IF (interface_flag != 1
    AND cver_ind="N")
    nf_activity_cnt = (nf_activity_cnt+ 1)
    IF (mod(nf_activity_cnt,10)=1)
     stat = alterlist(assay_nf->assay,(nf_activity_cnt+ 10))
    ENDIF
    assay_nf->assay[nf_activity_cnt].task_assay_cd = r.task_assay_cd, assay_nf->assay[nf_activity_cnt
    ].task_assay_disp = task_assay_disp
   ENDIF
  DETAIL
   ce_activity_cnt = (ce_activity_cnt+ 1)
   IF (mod(ce_activity_cnt,100)=1)
    stat = alterlist(activity->qual,(ce_activity_cnt+ 100))
   ENDIF
   activity->qual[ce_activity_cnt].accession = aor.accession, activity->qual[ce_activity_cnt].
   order_id = r.order_id, activity->qual[ce_activity_cnt].catalog_cd = r.catalog_cd,
   activity->qual[ce_activity_cnt].task_assay_cd = r.task_assay_cd, activity->qual[ce_activity_cnt].
   result_id = r.result_id, activity->qual[ce_activity_cnt].result_dt_tm = re.event_dt_tm,
   activity->qual[ce_activity_cnt].result_type_cd = re.event_type_cd, activity->qual[ce_activity_cnt]
   .activity_type_cd = aor.activity_type_cd, activity->qual[ce_activity_cnt].ref_nbr = trim(build(r
     .order_id,r.result_id,r.task_assay_cd))
   IF (cver_ind="N")
    activity->qual[ce_activity_cnt].alias_nf_ind = 1
   ELSE
    activity->qual[ce_activity_cnt].alias_nf_ind = 0
   ENDIF
  FOOT REPORT
   stat = alterlist(activity->qual,ce_activity_cnt), stat = alterlist(assay_nf->assay,nf_activity_cnt
    )
  WITH outerjoin = d1, nocounter
 ;end select
 SET serror_check = error(serrormsg,0)
 IF (serror_check=0)
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
  GO TO exit_script
 ENDIF
 IF (ce_activity_cnt=0)
  CALL echo("No activity data was found for this date range: Orders")
 ENDIF
 IF (validate(request->batch_selection,"N")="N")
  SET print_output_dest = output_dest
 ELSE
  SET print_output_dest = bbt_ce_orders
 ENDIF
 SELECT INTO value(print_output_dest)
  ce1_ind = decode(ce1.seq,"Y","N"), ce2_ind = decode(ce2.seq,"Y","N"), accn2 = activity->qual[d1.seq
  ].accession,
  order_id = activity->qual[d1.seq].order_id, task_assay_cd = activity->qual[d1.seq].task_assay_cd,
  result_dt_tm = cnvtdatetime(activity->qual[d1.seq].result_dt_tm)
  FROM (dummyt d1  WITH seq = value(ce_activity_cnt)),
   dummyt d2,
   clinical_event ce1,
   dummyt d3,
   perform_result pr2,
   result_event re2,
   clinical_event ce2
  PLAN (d1
   WHERE ce_activity_cnt > 0)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (ce1
   WHERE (ce1.reference_nbr=activity->qual[d1.seq].ref_nbr)
    AND ce1.verified_dt_tm=cnvtdatetime(activity->qual[d1.seq].result_dt_tm))
   JOIN (d3
   WHERE d3.seq=1)
   JOIN (pr2
   WHERE (pr2.result_id=activity->qual[d1.seq].result_id)
    AND pr2.result_status_cd IN (ver_cd, auto_ver_cd, cor_cd))
   JOIN (re2
   WHERE re2.result_id=pr2.result_id
    AND re2.perform_result_id=pr2.perform_result_id)
   JOIN (ce2
   WHERE (ce2.reference_nbr=activity->qual[d1.seq].ref_nbr)
    AND ce2.verified_dt_tm=re2.event_dt_tm)
  ORDER BY accn2, order_id, task_assay_cd,
   result_dt_tm
  HEAD REPORT
   reply_cnt = 0
   IF (interface_flag != 1)
    CALL center(captions->rpt_bbt_activity,0,125), row + 1, col 34,
    captions->date_range, col + 1, dates->start_dt_tm"@MEDIUMDATE4YR",
    col + 1, dates->start_dt_tm"@TIMEWITHSECONDS", col + 1,
    "-", col + 1, dates->end_dt_tm"@MEDIUMDATE4YR",
    col + 1, dates->end_dt_tm"@TIMEWITHSECONDS", row + 2,
    prt_page_head = 1
   ENDIF
  HEAD PAGE
   IF (interface_flag != 1)
    IF (prt_page_head=1)
     col 0, captions->accession, col 23,
     captions->order_mnemonic, col 45, captions->assay_mnemonic,
     col 67, captions->event_type, col 83,
     captions->event_dt_tm, col 99, captions->curr_ce,
     col 107, captions->result_id, row + 1
    ELSE
     col 2, captions->rpt_assays_not, row + 1,
     col 0, captions->assay, col 21,
     captions->alias, row + 1
    ENDIF
   ENDIF
  DETAIL
   IF (ce1_ind="N"
    AND curr_result_ind=0)
    IF (interface_flag != 1)
     accn = substring(0,20,trim(uar_fmt_accession(activity->qual[d1.seq].accession,size(activity->
         qual[d1.seq].accession,1)))), catalog_disp = substring(0,20,trim(uar_get_code_display(
        activity->qual[d1.seq].catalog_cd),3)), task_assay_disp = substring(0,20,trim(
       uar_get_code_display(activity->qual[d1.seq].task_assay_cd),3)),
     result_type_disp = substring(0,15,trim(uar_get_code_display(activity->qual[d1.seq].
        result_type_cd),3)), result_id = trim(cnvtstring(activity->qual[d1.seq].result_id,19,0),3),
     col 0,
     accn
     IF ((activity->qual[d1.seq].alias_nf_ind=0))
      col + 1, "*"
     ELSE
      col + 1, " "
     ENDIF
     col + 1, catalog_disp, col + 2,
     task_assay_disp, col + 2, result_type_disp,
     col + 1, activity->qual[d1.seq].result_dt_tm"@DATETIMECONDENSED", col 102,
     ce2_ind, col 107, result_id,
     row + 1
    ENDIF
   ENDIF
  FOOT  accn2
   row + 0
  FOOT  order_id
   row + 0
  FOOT  task_assay_cd
   IF (ce1_ind="N"
    AND ce2_ind="N"
    AND curr_result_ind=1)
    IF (interface_flag != 1)
     accn = substring(0,20,trim(uar_fmt_accession(activity->qual[d1.seq].accession,size(activity->
         qual[d1.seq].accession,1)))), catalog_disp = substring(0,20,trim(uar_get_code_display(
        activity->qual[d1.seq].catalog_cd),3)), task_assay_disp = substring(0,20,trim(
       uar_get_code_display(activity->qual[d1.seq].task_assay_cd),3)),
     result_type_disp = substring(0,15,trim(uar_get_code_display(activity->qual[d1.seq].
        result_type_cd),3)), result_id = trim(cnvtstring(activity->qual[d1.seq].result_id,19,0),3),
     curqual_orders = (curqual_orders+ 1),
     col 0, accn
     IF ((activity->qual[d1.seq].alias_nf_ind=0))
      col + 1, "*"
     ELSE
      col + 1, " "
     ENDIF
     col + 1, catalog_disp, col + 2,
     task_assay_disp, col + 2, result_type_disp,
     col + 1, activity->qual[d1.seq].result_dt_tm"@DATETIMECONDENSED", col 102,
     ce2_ind, col 107, result_id,
     row + 1
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->qual,reply_cnt)
   IF (interface_flag != 1)
    row + 1, col 0, captions->rpt_note,
    row + 1, col 0, captions->rpt_n_action
    IF (nf_activity_cnt > 0)
     prt_page_head = 0, BREAK
     FOR (i = 1 TO nf_activity_cnt)
       task_assay = cnvtstring(assay_nf->assay[i].task_assay_cd,19,0,r), col 0, assay_nf->assay[i].
       task_assay_disp,
       col + 1, task_assay, row + 1
     ENDFOR
    ENDIF
   ENDIF
  WITH outerjoin = d2, outerjoin = d3, dontcare = ce1,
   nullreport, nocounter
 ;end select
 SET serror_check = error(serrormsg,0)
 IF (serror_check=0)
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
  GO TO exit_script
 ENDIF
 SET ce_activity_cnt = 0
 SELECT INTO "nl:"
  ref_nbr = trim(build(pe.product_event_id,pe.product_id))
  FROM product_event pe,
   product p
  PLAN (pe
   WHERE pe.event_type_cd=transfused_cd
    AND pe.event_dt_tm >= cnvtdatetime(dates->start_dt_tm)
    AND pe.event_dt_tm <= cnvtdatetime(dates->end_dt_tm))
   JOIN (p
   WHERE p.product_id=pe.product_id)
  ORDER BY pe.product_id, ref_nbr
  HEAD REPORT
   ce_activity_cnt = 0
  DETAIL
   ce_activity_cnt = (ce_activity_cnt+ 1)
   IF (mod(ce_activity_cnt,100)=1)
    stat = alterlist(activity_trans->qual,(ce_activity_cnt+ 100))
   ENDIF
   activity_trans->qual[ce_activity_cnt].product_event_id = pe.product_event_id, activity_trans->
   qual[ce_activity_cnt].active_ind = pe.active_ind, activity_trans->qual[ce_activity_cnt].product_id
    = pe.product_id,
   activity_trans->qual[ce_activity_cnt].product_nbr = p.product_nbr, activity_trans->qual[
   ce_activity_cnt].order_id = pe.order_id, activity_trans->qual[ce_activity_cnt].bb_result_id = pe
   .bb_result_id,
   activity_trans->qual[ce_activity_cnt].result_dt_tm = pe.event_dt_tm, activity_trans->qual[
   ce_activity_cnt].result_type_cd = pe.event_type_cd, activity_trans->qual[ce_activity_cnt].ref_nbr
    = ref_nbr
  FOOT REPORT
   stat = alterlist(activity_trans->qual,ce_activity_cnt)
  WITH nocounter, nullreport
 ;end select
 SET serror_check = error(serrormsg,0)
 IF (serror_check=0)
  IF (ce_activity_cnt > 0)
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
  GO TO exit_script
 ENDIF
 IF (ce_activity_cnt=0)
  CALL echo("No activity data was found for this date range: Tranfused and Returned")
 ENDIF
 IF (validate(request->batch_selection,"N")="N")
  SET print_output_dest = output_dest
 ELSE
  SET print_output_dest = bbt_ce_trans
 ENDIF
 SELECT INTO value(print_output_dest)
  prod_nbr = trim(activity_trans->qual[d.seq].product_nbr), prod_id = activity_trans->qual[d.seq].
  product_id, ref_nbr = trim(activity_trans->qual[d.seq].ref_nbr),
  res_dt_tm = cnvtdatetime(activity_trans->qual[d.seq].result_dt_tm), ce_ind = decode(ce.seq,"Y","N")
  FROM (dummyt d  WITH seq = value(ce_activity_cnt)),
   clinical_event ce,
   (dummyt d1  WITH seq = 1),
   ce_product cep
  PLAN (d
   WHERE ce_activity_cnt > 0)
   JOIN (ce
   WHERE (ce.reference_nbr=activity_trans->qual[d.seq].ref_nbr))
   JOIN (d1)
   JOIN (cep
   WHERE (cep.product_id=activity_trans->qual[d.seq].product_id)
    AND cep.product_status_cd=transfused_prod_status_cd
    AND cep.event_id=ce.event_id)
  ORDER BY prod_id, ref_nbr, res_dt_tm
  HEAD REPORT
   CALL center(captions->rpt_bbt_activity,0,125), row + 1,
   CALL center(captions->rpt_transfused,0,125),
   row + 1, col 34, captions->date_range,
   col + 1, dates->start_dt_tm"@MEDIUMDATE4YR", col + 1,
   dates->start_dt_tm"@TIMEWITHSECONDS", col + 1, "-",
   col + 1, dates->end_dt_tm"@MEDIUMDATE4YR", col + 1,
   dates->end_dt_tm"@TIMEWITHSECONDS", row + 2
  HEAD PAGE
   col 0, captions->product_number, col 25,
   captions->event_type, col 50, captions->event_dt_tm,
   col 70, captions->product_event_id, col 88,
   captions->product_id, col 99, captions->curr_ce,
   row + 1
  HEAD prod_id
   display_ind = 0
  HEAD ref_nbr
   found_transfused_ind = 0, found_returned_ind = 0, found_ce_row_ind = 0
  DETAIL
   IF (ce_ind="Y")
    IF (ce.event_cd=transfused_event_cd
     AND cep.product_status_cd=transfused_prod_status_cd)
     found_transfused_ind = 1
    ELSEIF (ce.event_cd=returned_event_cd)
     found_returned_ind = 1
    ENDIF
    found_ce_row_ind = 1
   ELSE
    display_ind = 1
   ENDIF
  FOOT  ref_nbr
   found_latest_ind = 0
   IF (found_ce_row_ind=1)
    IF (found_transfused_ind=0)
     display_ind = 1
    ENDIF
    IF (found_returned_ind=0
     AND (activity_trans->qual[d.seq].active_ind=0))
     display_ind = 1
    ELSE
     found_latest_ind = found_transfused_ind
     IF (found_returned_ind=1)
      found_latest_ind = 1
     ELSE
      IF ((activity_trans->qual[d.seq].active_ind=0))
       found_latest_ind = found_transfused_ind
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT  prod_id
   IF (found_latest_ind=1
    AND curr_result_ind=1)
    display_ind = 0
   ENDIF
   IF (display_ind=1)
    IF (found_transfused_ind=0)
     temp_transfused_event_disp = substring(0,20,trim(transfused_event_disp)), temp_result_dt_tm =
     activity_trans->qual[d.seq].result_dt_tm, temp_prod_event_id = trim(cnvtstring(activity_trans->
       qual[d.seq].product_event_id,16,0),3),
     temp_prod_id = trim(cnvtstring(activity_trans->qual[d.seq].product_id,14,0),3),
     curqual_trans_return = (curqual_trans_return+ 1), col 0,
     prod_nbr, col 25, temp_transfused_event_disp,
     col 50, temp_result_dt_tm"@DATETIMECONDENSED", col 70,
     temp_prod_event_id, col 88, temp_prod_id
     IF (found_latest_ind=1)
      col 103, "Y"
     ELSE
      col 103, "N"
     ENDIF
     row + 1
    ENDIF
    IF ((activity_trans->qual[d.seq].active_ind=0)
     AND found_returned_ind=0)
     temp_returned_event_disp = substring(0,20,trim(returned_event_disp)), temp_result_dt_tm =
     activity_trans->qual[d.seq].result_dt_tm, temp_prod_event_id = trim(cnvtstring(activity_trans->
       qual[d.seq].product_event_id,16,0),3),
     temp_prod_id = trim(cnvtstring(activity_trans->qual[d.seq].product_id,14,0),3), col 0, prod_nbr,
     col 25, temp_returned_event_disp, col 50,
     temp_result_dt_tm"@DATETIMECONDENSED", col 70, temp_prod_event_id,
     col 88, temp_prod_id
     IF (found_latest_ind=1)
      col 103, "Y"
     ELSE
      col 103, "N"
     ENDIF
     row + 1
    ENDIF
   ENDIF
  FOOT REPORT
   row + 1, col 0, captions->rpt_note,
   row + 1, col 0, captions->rpt_n_action
  WITH outerjoin = d, outerjoin = d1, nullreport,
   nocounter
 ;end select
 SET serror_check = error(serrormsg,0)
 IF (serror_check=0)
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
  GO TO exit_script
 ENDIF
 SET ce_activity_cnt = 0
 SELECT INTO "nl:"
  ref_nbr = trim(build(r.order_id,r.catalog_cd,p.product_id))
  FROM result_event re,
   perform_result pr,
   result r,
   accession_order_r aor,
   product_event pe,
   product p
  PLAN (re
   WHERE re.event_type_cd IN (ver_cd, cor_cd, auto_ver_cd)
    AND re.event_dt_tm >= cnvtdatetime(dates->start_dt_tm)
    AND re.event_dt_tm <= cnvtdatetime(dates->end_dt_tm))
   JOIN (pr
   WHERE pr.result_id=re.result_id
    AND pr.perform_result_id=re.perform_result_id)
   JOIN (r
   WHERE r.result_id=pr.result_id)
   JOIN (aor
   WHERE aor.order_id=r.order_id
    AND aor.activity_type_cd=bbt_cd
    AND aor.primary_flag=0)
   JOIN (pe
   WHERE pe.order_id=r.order_id
    AND pe.bb_result_id=r.bb_result_id
    AND pe.event_type_cd=inprogress_cd)
   JOIN (p
   WHERE p.product_id=pe.product_id)
  ORDER BY p.product_id, ref_nbr
  HEAD REPORT
   ce_activity_cnt = 0
  DETAIL
   ce_activity_cnt = (ce_activity_cnt+ 1)
   IF (mod(ce_activity_cnt,100)=1)
    stat = alterlist(activity_cross->qual,(ce_activity_cnt+ 100))
   ENDIF
   activity_cross->qual[ce_activity_cnt].accession = aor.accession, activity_cross->qual[
   ce_activity_cnt].order_id = r.order_id, activity_cross->qual[ce_activity_cnt].catalog_cd = r
   .catalog_cd,
   activity_cross->qual[ce_activity_cnt].task_assay_cd = r.task_assay_cd, activity_cross->qual[
   ce_activity_cnt].result_id = r.result_id, activity_cross->qual[ce_activity_cnt].result_dt_tm = re
   .event_dt_tm,
   activity_cross->qual[ce_activity_cnt].result_type_cd = re.event_type_cd, activity_cross->qual[
   ce_activity_cnt].activity_type_cd = aor.activity_type_cd, activity_cross->qual[ce_activity_cnt].
   ref_nbr = trim(build(r.order_id,r.catalog_cd,p.product_id)),
   activity_cross->qual[ce_activity_cnt].product_id = p.product_id, activity_cross->qual[
   ce_activity_cnt].bb_result_id = r.bb_result_id, activity_cross->qual[ce_activity_cnt].product_nbr
    = p.product_nbr
  FOOT REPORT
   stat = alterlist(activity_cross->qual,ce_activity_cnt)
  WITH nocounter
 ;end select
 SET serror_check = error(serrormsg,0)
 IF (serror_check=0)
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
  GO TO exit_script
 ENDIF
 IF (ce_activity_cnt=0)
  CALL echo("No activity data was found for this date range: Crossmatched")
 ENDIF
 IF (validate(request->batch_selection,"N")="N")
  SET print_output_dest = output_dest
 ELSE
  SET print_output_dest = bbt_ce_xm
 ENDIF
 SELECT INTO value(print_output_dest)
  ce1_ind = decode(ce1.seq,"Y","N"), cep_ind = decode(cep.seq,"Y","N"), order_id = activity_cross->
  qual[d1.seq].order_id,
  accn2 = activity_cross->qual[d1.seq].accession, result_dt_tm = cnvtdatetime(activity_cross->qual[d1
   .seq].result_dt_tm)"@DATETIMECONDENSED", prod_id = activity_cross->qual[d1.seq].product_id,
  assay = activity_cross->qual[d1.seq].task_assay_cd
  FROM (dummyt d1  WITH seq = value(ce_activity_cnt)),
   dummyt d2,
   clinical_event ce1,
   dummyt d3,
   ce_product cep
  PLAN (d1
   WHERE ce_activity_cnt > 0)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (ce1
   WHERE (ce1.reference_nbr=activity_cross->qual[d1.seq].ref_nbr)
    AND ce1.verified_dt_tm=cnvtdatetime(activity_cross->qual[d1.seq].result_dt_tm)
    AND ce1.event_cd=bbproduct_event_cd)
   JOIN (d3
   WHERE d3.seq=1)
   JOIN (cep
   WHERE (cep.product_id=activity_cross->qual[d1.seq].product_id)
    AND cep.product_status_cd=crossmatched_prod_status_cd
    AND cep.event_id=ce1.event_id)
  ORDER BY prod_id, assay, result_dt_tm DESC,
   order_id, accn2
  HEAD REPORT
   IF (interface_flag != 1)
    CALL center(captions->rpt_bbt_activity,0,125), row + 1,
    CALL center(captions->crossmatched_products,0,125),
    row + 1, col 34, captions->date_range,
    col + 1, dates->start_dt_tm"@MEDIUMDATE4YR", col + 1,
    dates->start_dt_tm"@TIMEWITHSECONDS", col + 1, "-",
    col + 1, dates->end_dt_tm"@MEDIUMDATE4YR", col + 1,
    dates->end_dt_tm"@TIMEWITHSECONDS", row + 2
   ENDIF
  HEAD PAGE
   IF (interface_flag != 1)
    col 0, captions->accession, col 22,
    captions->order_mnemonic, col 42, captions->assay_mnemonic,
    col 67, captions->event_type, col 82,
    captions->event_dt_tm, col 98, captions->curr_ce,
    col 106, captions->result_id, col 116,
    captions->product_nbr, row + 1
   ENDIF
  HEAD prod_id
   row + 0
  HEAD assay
   found_latest_ind = 1, found_ce_row_ind = 0
  HEAD result_dt_tm
   row + 0
  HEAD order_id
   row + 0
  HEAD accn2
   row + 0
  DETAIL
   IF (((ce1_ind="N") OR (cep_ind="N")) )
    IF (((curr_result_ind=0) OR (((found_latest_ind=1) OR (found_ce_row_ind=0)) )) )
     IF (interface_flag != 1)
      temp_accn = substring(0,21,trim(uar_fmt_accession(activity_cross->qual[d1.seq].accession,size(
          activity_cross->qual[d1.seq].accession,1)))), temp_catalog_disp = substring(0,20,trim(
        uar_get_code_display(activity_cross->qual[d1.seq].catalog_cd),3)), temp_task_assay_disp =
      substring(0,20,trim(uar_get_code_display(activity_cross->qual[d1.seq].task_assay_cd),3)),
      temp_result_type_disp = substring(0,15,trim(uar_get_code_display(activity_cross->qual[d1.seq].
         result_type_cd),3)), temp_result_dt_tm = activity_cross->qual[d1.seq].result_dt_tm,
      temp_result_id = trim(cnvtstring(activity_cross->qual[d1.seq].result_id),3),
      temp_prod_nbr = substring(0,15,trim(activity_cross->qual[d1.seq].product_nbr)),
      curqual_crossmatch = (curqual_crossmatch+ 1), col 0,
      temp_accn, col 22, temp_catalog_disp,
      col 42, temp_task_assay_disp, col 67,
      temp_result_type_disp, col 82, temp_result_dt_tm"@DATETIMECONDENSED"
      IF (found_ce_row_ind=1)
       col 101, "Y"
      ELSE
       col 101, "N"
      ENDIF
      col 106, temp_result_id, col 116,
      temp_prod_nbr, row + 1
     ENDIF
    ENDIF
   ELSE
    IF (found_latest_ind=1)
     found_ce_row_ind = 1
    ENDIF
   ENDIF
   found_latest_ind = 0
  FOOT  accn2
   row + 0
  FOOT  order_id
   row + 0
  FOOT  result_dt_tm
   row + 0
  FOOT  assay
   row + 0
  FOOT  prod_id
   row + 0
  FOOT REPORT
   IF (interface_flag != 1)
    row + 1, col 0, captions->rpt_note,
    row + 1, col 0, captions->rpt_n_action
   ENDIF
  WITH outerjoin = d2, outerjoin = d3, dontcare = ce1,
   dontcare = cep, nullreport, nocounter
 ;end select
 SET serror_check = error(serrormsg,0)
 IF (serror_check=0)
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
  GO TO exit_script
 ENDIF
#exit_script
 IF (curqual_crossmatch=0
  AND curqual_trans_return=0
  AND curqual_orders=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = captions->no_report_error
 ENDIF
 IF (validate(request->output_dist,"N") != "N")
  IF (trim(request->output_dist) > "")
   SET spool value(bbt_ce_orders) value(request->output_dist)
   SET spool value(bbt_ce_trans) value(request->output_dist)
   SET spool value(bbt_ce_xm) value(request->output_dist)
  ENDIF
 ENDIF
END GO
