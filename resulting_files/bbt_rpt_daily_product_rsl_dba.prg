CREATE PROGRAM bbt_rpt_daily_product_rsl:dba
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
 RECORD perf_results(
   1 qual[*]
     2 result_id = f8
     2 order_id = f8
     2 catalog_cd = f8
     2 task_assay_cd = f8
     2 perform_result_id = f8
     2 service_resource_cd = f8
     2 detail_mnemonic = c12
     2 drawn_time = c12
     2 bb_result_id = f8
     2 product_nbr = c20
     2 bb_processing_cd = f8
     2 event_sequence = i4
     2 long_text_id = f8
     2 result_status_cd = f8
     2 arg_min_digits = i4
     2 arg_max_digits = i4
     2 arg_min_dec_places = i4
     2 arg_less_great_flag = i2
 )
 RECORD r_long_text(
   1 qual[*]
     2 result_id = f8
     2 perform_result_id = f8
     2 order_id = f8
     2 task_assay_cd = f8
     2 result_status_cd = f8
     2 comment_text = vc
     2 note_text = vc
     2 text_result = vc
     2 event_sequence = i4
 )
 RECORD ops_params(
   1 qual[*]
     2 param = c100
 )
 DECLARE get_username(sub_person_id) = c10
 SUBROUTINE get_username(sub_person_id)
   SET sub_get_username = fillstring(10," ")
   SELECT INTO "nl:"
    pnl.username
    FROM prsnl pnl
    WHERE pnl.person_id=sub_person_id
     AND pnl.person_id != null
     AND pnl.person_id > 0.0
    DETAIL
     sub_get_username = pnl.username
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET inc_i18nhandle = 0
    SET inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev)
    SET sub_get_username = uar_i18ngetmessage(inc_i18nhandle,"inc_unknown","<Unknown>")
   ENDIF
   RETURN(sub_get_username)
 END ;Subroutine
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
   1 rpt_date = vc
   1 rpt_time = vc
   1 rpt_by = vc
   1 page_no = vc
   1 test_site = vc
   1 bb_owner = vc
   1 inventory_area = vc
   1 beg_date = vc
   1 end_date = vc
   1 product_number = vc
   1 order_proc = vc
   1 performed = vc
   1 verified = vc
   1 product_type = vc
   1 order_dt_tm = vc
   1 cell_product = vc
   1 procedure = vc
   1 result = vc
   1 tech_id = vc
   1 date = vc
   1 time = vc
   1 rpt_title = vc
   1 all = vc
   1 report_id = vc
   1 end_of_report = vc
   1 comment = vc
   1 note = vc
   1 text_result = vc
   1 text_result_correct = vc
 )
 SET captions->rpt_date = uar_i18ngetmessage(i18nhandle,"rpt_date","DATE:")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","TIME:")
 SET captions->rpt_by = uar_i18ngetmessage(i18nhandle,"rpt_by","  BY:")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","PAGE:")
 SET captions->test_site = uar_i18ngetmessage(i18nhandle,"test_site","TEST SITE:")
 SET captions->bb_owner = uar_i18ngetmessage(i18nhandle,"bb_owner","Blood Bank Owner: ")
 SET captions->inventory_area = uar_i18ngetmessage(i18nhandle,"inventory_area","Inventory Area: ")
 SET captions->beg_date = uar_i18ngetmessage(i18nhandle,"beg_date","Beginning Date:")
 SET captions->end_date = uar_i18ngetmessage(i18nhandle,"end_date","Ending Date:")
 SET captions->product_number = uar_i18ngetmessage(i18nhandle,"product_number","PRODUCT NUMBER/")
 SET captions->order_proc = uar_i18ngetmessage(i18nhandle,"order_proc","ORDERED PROC/")
 SET captions->performed = uar_i18ngetmessage(i18nhandle,"performed","PERFORMED")
 SET captions->verified = uar_i18ngetmessage(i18nhandle,"verified","VERIFIED")
 SET captions->product_type = uar_i18ngetmessage(i18nhandle,"product_type","PRODUCT TYPE")
 SET captions->order_dt_tm = uar_i18ngetmessage(i18nhandle,"order_dt_tm","ORDER DATE/TIME")
 SET captions->cell_product = uar_i18ngetmessage(i18nhandle,"cell_product","CELL/PRODUCT")
 SET captions->procedure = uar_i18ngetmessage(i18nhandle,"procedure","PROCEDURE")
 SET captions->result = uar_i18ngetmessage(i18nhandle,"result","RESULT")
 SET captions->tech_id = uar_i18ngetmessage(i18nhandle,"tech_id","TECHID")
 SET captions->date = uar_i18ngetmessage(i18nhandle,"date","DATE")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","TIME")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title",
  "BLOOD BANK PRODUCT RESULTS ACTIVITY REPORT")
 SET captions->all = uar_i18ngetmessage(i18nhandle,"all","(All)")
 SET captions->report_id = uar_i18ngetmessage(i18nhandle,"report_id",
  "Report ID: BBT_RPT_DAILY_PRODUCT_RSL")
 SET captions->comment = uar_i18ngetmessage(i18nhandle,"comment","Comment:  ")
 SET captions->note = uar_i18ngetmessage(i18nhandle,"note","Note:  ")
 SET captions->text_result = uar_i18ngetmessage(i18nhandle,"text_result","Text Result:  ")
 SET captions->text_result_correct = uar_i18ngetmessage(i18nhandle,"text_result_correct",
  "Text Result (Corrected): ")
#script
 SET nbr_prs = 0
 SET nbr_comments = 0
 SET no_op = 0
 SET resultflagstr = fillstring(10," ")
 SET result_event_codeset = 1901
 SET testsite_codeset = 221
 SET result_flag_codeset = 1902
 SET priority_codeset = 1905
 SET commenttype_codeset = 14
 SET resulttype_codeset = 289
 SET resourcegroup_codeset = 223
 SET bb_processing_codeset = 1635
 SET i = 0
 SET offset = 0
 SET hyphen_line = fillstring(126,"-")
 SET order_row = 0
 SET detail_row = 0
 SET institution_group_cd = 0.0
 SET department_group_cd = 0.0
 SET section_group_cd = 0.0
 SET subsection_group_cd = 0.0
 SET crossmatch_cd = 0.0
 SET patient_abo_cd = 0.0
 SET product_abo_cd = 0.0
 SET antigen_cd = 0.0
 SET antibody_id_cd = 0.0
 SET antibdy_scrn_cd = 0.0
 SET institution_name = fillstring(40," ")
 SET department_name = fillstring(40," ")
 SET section_name = fillstring(40," ")
 SET subsection_name = fillstring(40," ")
 SET store_perform_result_id = 0.0
 SET store_perfresultids = fillstring(50," ")
 SET procedure_row_hold = 0
 SET dont_print_proc = 0
 DECLARE reportbyusername = vc WITH protect, noconstant("")
 SET reportbyusername = get_username(reqinfo->updt_id)
 IF (trim(request->batch_selection) > " ")
  SET begday = request->ops_date
  SET endday = request->ops_date
  SET temp_string = cnvtupper(trim(request->batch_selection))
  CALL check_opt_date_passed("bbt_rpt_daily_product_rsl")
  IF ((reply->status_data.status != "F"))
   SET request->dt_tm_begin = begday
   SET request->dt_tm_end = endday
  ENDIF
  SET stat = alterlist(request->qual,10)
  CALL check_svc_opt("bbt_rpt_daily_product_rsl")
  CALL check_owner_cd("bbt_rpt_daily_product_rsl")
  CALL check_inventory_cd("bbt_rpt_daily_product_rsl")
  CALL check_location_cd("bbt_rpt_daily_product_rsl")
  SET request->printer_name = request->output_dist
 ENDIF
 SUBROUTINE check_opt_date_passed(script_name)
   SET ddmmyy_flag = 0
   SET dd_flag = 0
   SET mm_flag = 0
   SET yy_flag = 0
   SET dayentered = 0
   SET monthentered = 0
   SET yearentered = 0
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("DAY[",temp_string)))
   IF (temp_pos > 0)
    SET day_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET day_pos = cnvtint(value(findstring("]",day_string)))
    IF (day_pos > 0)
     SET day_nbr = substring(1,(day_pos - 1),day_string)
     IF (trim(day_nbr) > " ")
      SET ddmmyy_flag += 1
      SET dd_flag = 1
      SET dayentered = cnvtreal(day_nbr)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse DAY value"
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse DAY value"
    ENDIF
   ENDIF
   IF ((reply->status_data.status != "F"))
    SET temp_pos = 0
    SET temp_pos = cnvtint(value(findstring("MONTH[",temp_string)))
    IF (temp_pos > 0)
     SET month_string = substring((temp_pos+ 6),size(temp_string),temp_string)
     SET month_pos = cnvtint(value(findstring("]",month_string)))
     IF (month_pos > 0)
      SET month_nbr = substring(1,(month_pos - 1),month_string)
      IF (trim(month_nbr) > " ")
       SET ddmmyy_flag += 1
       SET mm_flag = 1
       SET monthentered = cnvtreal(month_nbr)
      ELSE
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].targetobjectname = "parse MONTH value"
      ENDIF
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse MONTH value"
     ENDIF
    ENDIF
   ENDIF
   IF ((reply->status_data.status != "F"))
    SET temp_pos = 0
    SET temp_pos = cnvtint(value(findstring("YEAR[",temp_string)))
    IF (temp_pos > 0)
     SET year_string = substring((temp_pos+ 5),size(temp_string),temp_string)
     SET year_pos = cnvtint(value(findstring("]",year_string)))
     IF (year_pos > 0)
      SET year_nbr = substring(1,(year_pos - 1),year_string)
      IF (trim(year_nbr) > " ")
       SET ddmmyy_flag += 1
       SET yy_flag = 1
       SET yearentered = cnvtreal(year_nbr)
      ELSE
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].targetobjectname = "parse YEAR value"
      ENDIF
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse YEAR value"
     ENDIF
    ENDIF
   ENDIF
   IF (ddmmyy_flag > 1)
    SET reply->status_data.subeventstatus[1].operationname = script_name
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "parse DAY or MONTH or YEAR value"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "multi date selection"
    GO TO exit_script
   ENDIF
   IF ((reply->status_data.status="F"))
    SET reply->status_data.subeventstatus[1].operationname = script_name
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
    GO TO exit_script
   ENDIF
   IF (dd_flag=1)
    IF (dayentered > 0)
     SET interval = build(abs(dayentered),"d")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET begday = cnvtlookahead(interval,request->ops_date)
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),235959)
     SET endday = cnvtlookahead(interval,request->ops_date)
    ELSE
     SET interval = build(abs(dayentered),"d")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET begday = cnvtlookbehind(interval,request->ops_date)
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),235959)
     SET endday = cnvtlookbehind(interval,request->ops_date)
    ENDIF
   ELSEIF (mm_flag=1)
    IF (monthentered > 0)
     SET interval = build(abs(monthentered),"m")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET smonth = cnvtstring(month(request->ops_date))
     SET sday = "01"
     SET syear = cnvtstring(year(request->ops_date))
     SET sdateall = concat(smonth,sday,syear)
     SET begday = cnvtlookahead(interval,cnvtdatetime(cnvtdate(sdateall),0))
     SET endday = cnvtlookahead("1m",cnvtdatetime(cnvtdate(begday),235959))
     SET endday = cnvtlookbehind("1d",endday)
    ELSE
     SET interval = build(abs(monthentered),"m")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET smonth = cnvtstring(month(request->ops_date))
     SET sday = "01"
     SET syear = cnvtstring(year(request->ops_date))
     SET sdateall = concat(smonth,sday,syear)
     SET begday = cnvtlookbehind(interval,cnvtdatetime(cnvtdate(sdateall),0))
     SET endday = cnvtlookahead("1m",cnvtdatetime(cnvtdate(begday),235959))
     SET endday = cnvtlookbehind("1d",endday)
    ENDIF
   ELSEIF (yy_flag=1)
    IF (yearentered > 0)
     SET interval = build(abs(yearentered),"y")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET smonth = "01"
     SET sday = "01"
     SET syear = cnvtstring(year(request->ops_date))
     SET sdateall = concat(smonth,sday,syear)
     SET begday = cnvtlookahead(interval,cnvtdatetime(cnvtdate(sdateall),0))
     SET endday = cnvtlookahead("1y",cnvtdatetime(cnvtdate(begday),235959))
     SET endday = cnvtlookbehind("1d",endday)
    ELSE
     SET interval = build(abs(yearentered),"y")
     SET request->ops_date = cnvtdatetime(cnvtdate2(format(request->ops_date,"mm/dd/yyyy;;d"),
       "mm/dd/yyyy"),0000)
     SET smonth = "01"
     SET sday = "01"
     SET syear = cnvtstring(year(request->ops_date))
     SET sdateall = concat(smonth,sday,syear)
     SET begday = cnvtlookbehind(interval,cnvtdatetime(cnvtdate(sdateall),0))
     SET endday = cnvtlookahead("1y",cnvtdatetime(cnvtdate(begday),235959))
     SET endday = cnvtlookbehind("1d",endday)
    ENDIF
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = script_name
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "parse DAY or MONTH or YEAR value"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "NO date selection"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE check_bb_organization(script_name)
   DECLARE norgpos = i2 WITH protect, noconstant(0)
   DECLARE ntemppos = i2 WITH protect, noconstant(0)
   DECLARE ncodeset = i4 WITH protect, constant(278)
   DECLARE sorgname = vc WITH protect, noconstant(fillstring(132,""))
   DECLARE sorgstring = vc WITH protect, noconstant(fillstring(132,""))
   DECLARE dbbmanufcd = f8 WITH protect, noconstant(0.0)
   DECLARE dbbsupplcd = f8 WITH protect, noconstant(0.0)
   DECLARE dbbclientcd = f8 WITH protect, noconstant(0.0)
   SET stat = uar_get_meaning_by_codeset(ncodeset,"BBMANUF",1,dbbmanufcd)
   SET stat = uar_get_meaning_by_codeset(ncodeset,"BBSUPPL",1,dbbsupplcd)
   SET stat = uar_get_meaning_by_codeset(ncodeset,"BBCLIENT",1,dbbclientcd)
   SET ntemppos = cnvtint(value(findstring("ORG[",temp_string)))
   IF (ntemppos > 0)
    SET sorgstring = substring((ntemppos+ 4),size(temp_string),temp_string)
    SET norgpos = cnvtint(value(findstring("]",sorgstring)))
    IF (norgpos > 0)
     SET sorgname = substring(1,(norgpos - 1),sorgstring)
     IF (trim(sorgname) > " ")
      SELECT INTO "nl:"
       FROM org_type_reltn ot,
        organization o
       PLAN (ot
        WHERE ot.org_type_cd IN (dbbmanufcd, dbbsupplcd, dbbclientcd)
         AND ot.active_ind=1)
        JOIN (o
        WHERE o.org_name_key=trim(cnvtupper(sorgname))
         AND o.active_ind=1)
       DETAIL
        request->organization_id = o.organization_id
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
   ELSE
    SET request->organization_id = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_owner_cd(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("OWN[",temp_string)))
   IF (temp_pos > 0)
    SET own_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET own_pos = cnvtint(value(findstring("]",own_string)))
    IF (own_pos > 0)
     SET own_area = substring(1,(own_pos - 1),own_string)
     IF (trim(own_area) > " ")
      SET request->cur_owner_area_cd = cnvtreal(own_area)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse owner area code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse owner area code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->cur_owner_area_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_inventory_cd(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("INV[",temp_string)))
   IF (temp_pos > 0)
    SET inv_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET inv_pos = cnvtint(value(findstring("]",inv_string)))
    IF (inv_pos > 0)
     SET inv_area = substring(1,(inv_pos - 1),inv_string)
     IF (trim(inv_area) > " ")
      SET request->cur_inv_area_cd = cnvtreal(inv_area)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse inventory area code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse inventory area code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->cur_inv_area_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_location_cd(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("LOC[",temp_string)))
   IF (temp_pos > 0)
    SET loc_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET loc_pos = cnvtint(value(findstring("]",loc_string)))
    IF (loc_pos > 0)
     SET location_cd = substring(1,(loc_pos - 1),loc_string)
     IF (trim(location_cd) > " ")
      SET request->address_location_cd = cnvtreal(location_cd)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse location code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse location code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->address_location_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_sort_opt(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("SORT[",temp_string)))
   IF (temp_pos > 0)
    SET sort_string = substring((temp_pos+ 5),size(temp_string),temp_string)
    SET sort_pos = cnvtint(value(findstring("]",sort_string)))
    IF (sort_pos > 0)
     SET sort_selection = substring(1,(sort_pos - 1),sort_string)
    ELSE
     SET sort_selection = " "
    ENDIF
   ELSE
    SET sort_selection = " "
   ENDIF
 END ;Subroutine
 SUBROUTINE check_mode_opt(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("MODE[",temp_string)))
   IF (temp_pos > 0)
    SET mode_string = substring((temp_pos+ 5),size(temp_string),temp_string)
    SET mode_pos = cnvtint(value(findstring("]",mode_string)))
    IF (mode_pos > 0)
     SET mode_selection = substring(1,(mode_pos - 1),mode_string)
    ELSE
     SET mode_selection = " "
    ENDIF
   ELSE
    SET mode_selection = " "
   ENDIF
 END ;Subroutine
 SUBROUTINE check_rangeofdays_opt(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("RANGEOFDAYS[",temp_string)))
   IF (temp_pos > 0)
    SET next_string = substring((temp_pos+ 12),size(temp_string),temp_string)
    SET next_pos = cnvtint(value(findstring("]",next_string)))
    SET days_look_ahead = cnvtint(trim(substring(1,(next_pos - 1),next_string)))
    IF (days_look_ahead > 0)
     SET days_look_ahead = days_look_ahead
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse look ahead days"
     GO TO exit_script
    ENDIF
   ELSE
    SET days_look_ahead = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_hrs_opt(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("HRS[",temp_string)))
   IF (temp_pos > 0)
    SET hrs_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET hrs_pos = cnvtint(value(findstring("]",hrs_string)))
    IF (hrs_pos > 0)
     SET num_hrs = substring(1,(hrs_pos - 1),hrs_string)
     IF (trim(num_hrs) > " ")
      IF (cnvtint(trim(num_hrs)) > 0)
       SET hoursentered = cnvtreal(num_hrs)
      ELSE
       SET reply->status_data.status = "F"
       SET reply->status_data.subeventstatus[1].operationname = script_name
       SET reply->status_data.subeventstatus[1].operationstatus = "F"
       SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
       SET reply->status_data.subeventstatus[1].targetobjectname = "parse number of hours"
       GO TO exit_script
      ENDIF
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse number of hours"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse number of hours"
     GO TO exit_script
    ENDIF
   ELSE
    SET hoursentered = 0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_svc_opt(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("SVC[",temp_string)))
   IF (temp_pos > 0)
    SET svc_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET svc_pos = cnvtint(value(findstring("]",svc_string)))
    SET parm_string = fillstring(100," ")
    SET parm_string = substring(1,(svc_pos - 1),svc_string)
    SET ptr = 1
    SET back_ptr = 1
    SET param_idx = 1
    SET nbr_of_services = size(trim(parm_string))
    SET flag_exit_loop = 0
    FOR (param_idx = 1 TO nbr_of_services)
      SET ptr = findstring(",",parm_string,back_ptr)
      IF (ptr=0)
       SET ptr = (nbr_of_services+ 1)
       SET flag_exit_loop = 1
      ENDIF
      SET parm_len = (ptr - back_ptr)
      SET stat = alterlist(ops_params->qual,param_idx)
      SET ops_params->qual[param_idx].param = trim(substring(back_ptr,value(parm_len),parm_string),3)
      SET back_ptr = (ptr+ 1)
      SET stat = alterlist(request->qual,param_idx)
      SET request->qual[param_idx].service_resource_cd = cnvtreal(ops_params->qual[param_idx].param)
      IF (flag_exit_loop=1)
       SET param_idx = nbr_of_services
      ENDIF
    ENDFOR
   ELSE
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = script_name
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
    SET reply->status_data.subeventstatus[1].targetobjectname = "parse service resource"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE check_donation_location(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("DLOC[",temp_string)))
   IF (temp_pos > 0)
    SET loc_string = substring((temp_pos+ 5),size(temp_string),temp_string)
    SET loc_pos = cnvtint(value(findstring("]",loc_string)))
    IF (loc_pos > 0)
     SET location_cd = substring(1,(loc_pos - 1),loc_string)
     IF (trim(location_cd) > " ")
      SET request->donation_location_cd = cnvtreal(trim(location_cd))
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse donation location"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse donation location"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->donation_location_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_null_report(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("NULLRPT[",temp_string)))
   IF (temp_pos > 0)
    SET null_string = substring((temp_pos+ 8),size(temp_string),temp_string)
    SET null_pos = cnvtint(value(findstring("]",null_string)))
    IF (null_pos > 0)
     SET null_selection = substring(1,(null_pos - 1),null_string)
     IF (trim(null_selection)="Y")
      SET request->null_ind = 1
     ELSE
      SET request->null_ind = 0
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse null report indicator"
     GO TO exit_script
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE check_outcome_cd(script_name)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("OUTCOME[",temp_string)))
   IF (temp_pos > 0)
    SET outcome_string = substring((temp_pos+ 8),size(temp_string),temp_string)
    SET loc_pos = cnvtint(value(findstring("]",outcome_string)))
    IF (loc_pos > 0)
     SET outcome_cd = substring(1,(loc_pos - 1),outcome_string)
     IF (trim(outcome_cd) > " ")
      SET request->outcome_cd = cnvtreal(outcome_cd)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse outcome code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse outcome code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->outcome_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE (check_facility_cd(script_name=vc) =null)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("FACILITY[",temp_string)))
   IF (temp_pos > 0)
    SET loc_string = substring((temp_pos+ 9),size(temp_string),temp_string)
    SET loc_pos = cnvtint(value(findstring("]",loc_string)))
    IF (loc_pos > 0)
     SET facility_cd = substring(1,(loc_pos - 1),loc_string)
     IF (trim(facility_cd) > " ")
      SET request->facility_cd = cnvtreal(facility_cd)
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "no facility code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse facility code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no facility code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse facility code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->facility_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE (check_exception_type_cd(script_name=vc) =null)
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("EXCEPT[",temp_string)))
   IF (temp_pos > 0)
    SET loc_string = substring((temp_pos+ 7),size(temp_string),temp_string)
    SET loc_pos = cnvtint(value(findstring("]",loc_string)))
    IF (loc_pos > 0)
     SET exception_type_cd = substring(1,(loc_pos - 1),loc_string)
     IF (trim(exception_type_cd) > " ")
      IF (trim(exception_type_cd)="ALL")
       SET request->exception_type_cd = 0.0
      ELSE
       SET request->exception_type_cd = cnvtreal(exception_type_cd)
      ENDIF
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue =
      "no exception type code value in string"
      SET reply->status_data.subeventstatus[1].targetobjectname = "parse exception type code value"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue =
     "no exception type code value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse exception type code value"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->exception_type_cd = 0.0
   ENDIF
 END ;Subroutine
 SUBROUTINE check_misc_functionality(param_name)
   SET temp_pos = 0
   SET status_param = ""
   SET temp_str = concat(param_name,"[")
   SET temp_pos = cnvtint(value(findstring(temp_str,temp_string)))
   IF (temp_pos > 0)
    SET status_string = substring((temp_pos+ textlen(temp_str)),size(temp_string),temp_string)
    SET status_pos = cnvtint(value(findstring("]",status_string)))
    IF (status_pos > 0)
     SET status_param = substring(1,(status_pos - 1),status_string)
     IF (trim(status_param) > " ")
      SET ops_param_status = cnvtint(status_param)
     ENDIF
    ENDIF
   ENDIF
   RETURN
 END ;Subroutine
 RECORD reportstuff(
   1 qual[*]
     2 printline = c131
     2 detailcount = i4
 )
 SET nitems = 0
 SET limit = 0
 SET blank_line = fillstring(131," ")
 SET z = fillstring(131," ")
 SET vcstring = fillstring(32000," ")
 DECLARE store_item(c,r,reportitem) = i4
 SUBROUTINE store_item(c,r,reportitem)
   SET item_length = 0
   SET junk = 0
   WHILE (nitems < r)
     SET nitems += 1
     SET stat = alterlist(reportstuff->qual,nitems)
     SET junk = movestring(blank_line,1,reportstuff->qual[nitems].printline,1,132)
   ENDWHILE
   SET itemlength = size(trim(reportitem),3)
   IF (itemlength > 0)
    SET junk = movestring(notrim(reportitem),1,reportstuff->qual[r].printline,(c+ 1),itemlength)
   ENDIF
   IF (r > limit)
    SET limit = r
   ENDIF
 END ;Subroutine
 DECLARE clear_item(c,r,reportitem) = i4
 SUBROUTINE clear_item(c,r,reportitem)
   SET item_length = size(reportitem,3)
   SET move_len = movestring(reportitem,1,reportstuff->qual[r].printline,(c+ 1),item_length)
   IF (r > limit)
    SET limit = r
   ENDIF
 END ;Subroutine
 SUBROUTINE clear_reportstuff(fillchar)
   SET fill_line = fillstring(132,fillchar)
   FOR (i = 1 TO nitems)
    CALL store_item(0,i,fill_line)
    SET reportstuff->qual[i].detailcount = 0
   ENDFOR
   SET limit = 0
 END ;Subroutine
 DECLARE store_varchar_item(startrow,para_indent,maxperrow) = i4
 SUBROUTINE store_varchar_item(startrow,para_indent,maxperrow)
   SET j = startrow
   SET p = para_indent
   SET nchars = 0
   SET headptr = 1
   SET strsize = size(trim(vcstring),3)
   WHILE (headptr <= strsize)
     SET tailptr = ((headptr+ maxperrow) - 1)
     SET ch = substring(tailptr,1,vcstring)
     WHILE (tailptr > headptr
      AND ch != " ")
      SET tailptr -= 1
      SET ch = substring(tailptr,1,vcstring)
     ENDWHILE
     IF (tailptr=headptr)
      SET tailptr = ((headptr+ maxperrow) - 1)
     ENDIF
     SET nchars = ((tailptr - headptr)+ 1)
     SET z = substring(headptr,value(nchars),vcstring)
     SET item_length = 0
     SET junk = 0
     WHILE (nitems < j)
       SET nitems += 1
       SET stat = alterlist(reportstuff->qual,nitems)
       SET junk = movestring(blank_line,1,reportstuff->qual[nitems].printline,1,132)
     ENDWHILE
     SET itemlength = size(trim(z),3)
     SET junk = movestring(z,1,reportstuff->qual[j].printline,(p+ 1),itemlength)
     IF (j > limit)
      SET limit = j
     ENDIF
     SET headptr = (tailptr+ 1)
     SET j += 1
   ENDWHILE
   RETURN(j)
 END ;Subroutine
 DECLARE abbrevage(agething) = c20
 SUBROUTINE abbrevage(agething)
   SET agestr1 = substring(1,2,agething)
   SET agestr2 = substring(1,3,agething)
   SET agestr3 = substring(1,4,agething)
   SET inc_i18nhandle = 0
   SET inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev)
   SET pos = findstring("Year",agething)
   IF (pos > 0)
    SET i18n_yrs = uar_i18ngetmessage(inc_i18nhandle,"i18n_yrs","YRS ")
    IF (pos=3)
     SET ageabbrev = concat(agestr1,i18n_yrs)
    ELSEIF (pos=4)
     SET ageabbrev = concat(agestr2,i18n_yrs)
    ELSE
     SET ageabbrev = concat(agestr3,i18n_yrs)
    ENDIF
   ELSE
    SET pos = findstring("Month",agething)
    IF (pos > 0)
     SET i18n_mos = uar_i18ngetmessage(inc_i18nhandle,"i18n_mos","MOS ")
     IF (pos=3)
      SET ageabbrev = concat(agestr1,i18n_mos)
     ELSE
      SET ageabbrev = concat(agestr2,i18n_mos)
     ENDIF
    ELSE
     SET pos = findstring("Week",agething)
     IF (pos > 0)
      SET i18n_wks = uar_i18ngetmessage(inc_i18nhandle,"i18n_wks","WKS ")
      IF (pos=3)
       SET ageabbrev = concat(agestr1,i18n_wks)
      ELSE
       SET ageabbrev = concat(agestr2,i18n_wks)
      ENDIF
     ELSE
      SET pos = findstring("Day",agething)
      IF (pos > 0)
       SET i18n_dys = uar_i18ngetmessage(inc_i18nhandle,"i18n_dys","DYS ")
       IF (pos=3)
        SET ageabbrev = concat(agestr1,i18n_dys)
       ELSE
        SET ageabbrev = concat(agestr2,i18n_dys)
       ENDIF
      ELSE
       SET ageabbrev = substring(1,5,agething)
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   RETURN(ageabbrev)
 END ;Subroutine
 DECLARE bldresultflagstr(fnorm,fcrit,frevw,fdelta,fcomment,
  fnote,fcorr,fnotify) = vc
 SUBROUTINE bldresultflagstr(fnorm,fcrit,frevw,fdelta,fcomment,fnote,fcorr,fnotify)
   DECLARE flagstr = vc WITH protect, noconstant(" ")
   IF (fnorm != " ")
    SET flagstr = fnorm
   ENDIF
   IF (fcrit != " ")
    SET flagstr = concat(flagstr,fcrit)
   ENDIF
   IF (frevw != " ")
    SET flagstr = concat(flagstr,frevw)
   ENDIF
   IF (fdelta != " ")
    SET flagstr = concat(flagstr,fdelta)
   ENDIF
   IF (fcorr="Y")
    SET flagstr = concat(flagstr,"c")
   ENDIF
   IF (((fcomment="Y") OR (fnote="Y")) )
    SET flagstr = concat(flagstr,"f")
   ENDIF
   IF (fnotify != " ")
    SET flagstr = concat(flagstr,fnotify)
   ENDIF
   RETURN(flagstr)
 END ;Subroutine
 DECLARE store_varchar_item2(startrow,startcol,maxperrow,linespace) = i4
 SUBROUTINE store_varchar_item2(startrow,startcol,maxperrow,linespace)
   SET ht = 9
   SET lf = 10
   SET ff = 12
   SET cr = 13
   SET spaces = 32
   SET curr_row = startrow
   SET start_col = startcol
   SET end_col = ((startcol+ maxperrow) - 1)
   SET start_pos = 0
   SET last_space_pos = 0
   SET text_len = 0
   SET text_parse = fillstring(132," ")
   SET ptr = 1
   SET max_text_len = size(trim(vcstring),3)
   WHILE (ptr <= max_text_len)
     SET text_char = substring(ptr,1,vcstring)
     IF (ichar(text_char) < spaces)
      IF (((ichar(text_char)=cr) OR (((ichar(text_char)=ff) OR (ichar(text_char)=lf)) )) )
       IF (start_pos > 0)
        SET text_parse = substring(start_pos,text_len,vcstring)
        WHILE (nitems < curr_row)
          SET nitems += 1
          SET stat = alterlist(reportstuff->qual,nitems)
          SET move_len = movestring(blank_line,1,reportstuff->qual[nitems].printline,1,132)
        ENDWHILE
        SET move_len = movestring(text_parse,1,reportstuff->qual[curr_row].printline,(start_col+ 1),
         text_len)
        IF (curr_row > limit)
         SET limit = curr_row
        ENDIF
       ELSE
        WHILE (nitems < curr_row)
          SET nitems += 1
          SET stat = alterlist(reportstuff->qual,nitems)
          SET move_len = movestring(blank_line,1,reportstuff->qual[nitems].printline,1,132)
        ENDWHILE
        SET move_len = movestring(" ",1,reportstuff->qual[curr_row].printline,(start_col+ 1),1)
        IF (curr_row > limit)
         SET limit = curr_row
        ENDIF
       ENDIF
       IF (ichar(text_char)=cr)
        SET text_char = substring((ptr+ 1),1,vcstring)
        IF (ichar(text_char)=lf)
         SET ptr += 1
        ENDIF
       ENDIF
       SET curr_row += linespace
       SET start_col = startcol
       SET start_pos = 0
       SET last_space_pos = 0
       SET text_len = 0
       SET text_parse = fillstring(132," ")
      ENDIF
      IF (ichar(text_char) != cr
       AND ichar(text_char) != ff
       AND ichar(text_char) != lf)
       IF (text_len > 0)
        SET text_parse = substring(start_pos,text_len,vcstring)
        WHILE (nitems < curr_row)
          SET nitems += 1
          SET stat = alterlist(reportstuff->qual,nitems)
          SET move_len = movestring(blank_line,1,reportstuff->qual[nitems].printline,1,132)
        ENDWHILE
        SET move_len = movestring(text_parse,1,reportstuff->qual[curr_row].printline,(start_col+ 1),
         text_len)
        IF (curr_row > limit)
         SET limit = curr_row
        ENDIF
        SET start_col = (startcol+ text_len)
       ENDIF
       IF (ichar(text_char)=ht)
        SET start_col += 8
       ELSE
        SET start_col += 1
       ENDIF
       IF (start_col >= end_col)
        SET curr_row += linespace
        SET start_col = startcol
       ENDIF
       SET start_pos = (ptr+ 1)
       SET last_space_pos = 0
       SET text_len = 0
       SET text_parse = fillstring(132," ")
      ENDIF
     ENDIF
     IF (ichar(text_char) >= spaces)
      IF (start_pos=0)
       SET start_pos = ptr
      ENDIF
      IF (ichar(text_char)=spaces)
       SET last_space_pos = ptr
      ENDIF
      SET text_len += 1
      IF (((start_col+ text_len) >= end_col))
       IF (last_space_pos > 0)
        SET text_len = ((last_space_pos - start_pos)+ 1)
        SET ptr = last_space_pos
       ENDIF
       SET text_parse = substring(start_pos,text_len,vcstring)
       WHILE (nitems < curr_row)
         SET nitems += 1
         SET stat = alterlist(reportstuff->qual,nitems)
         SET move_len = movestring(blank_line,1,reportstuff->qual[nitems].printline,1,132)
       ENDWHILE
       SET move_len = movestring(text_parse,1,reportstuff->qual[curr_row].printline,(start_col+ 1),
        text_len)
       IF (curr_row > limit)
        SET limit = curr_row
       ENDIF
       SET curr_row += linespace
       SET start_col = startcol
       SET start_pos = 0
       SET last_space_pos = 0
       SET text_len = 0
       SET text_parse = fillstring(132," ")
      ENDIF
     ENDIF
     SET ptr += 1
   ENDWHILE
   IF (text_len > 0)
    SET text_parse = substring(start_pos,text_len,vcstring)
    WHILE (nitems < curr_row)
      SET nitems += 1
      SET stat = alterlist(reportstuff->qual,nitems)
      SET move_len = movestring(blank_line,1,reportstuff->qual[nitems].printline,1,132)
    ENDWHILE
    SET move_len = movestring(text_parse,1,reportstuff->qual[curr_row].printline,(start_col+ 1),
     text_len)
    IF (curr_row > limit)
     SET limit = curr_row
    ENDIF
    SET curr_row += linespace
    SET start_col = startcol
    SET start_pos = 0
    SET last_space_pos = 0
    SET text_len = 0
    SET text_parse = fillstring(132," ")
   ENDIF
   SET vcstring = " "
   RETURN(curr_row)
 END ;Subroutine
 SET sub_get_location_name = fillstring(25," ")
 SET sub_get_location_address1 = fillstring(100," ")
 SET sub_get_location_address2 = fillstring(100," ")
 SET sub_get_location_address3 = fillstring(100," ")
 SET sub_get_location_address4 = fillstring(100," ")
 SET sub_get_location_citystatezip = fillstring(100," ")
 SET sub_get_location_country = fillstring(100," ")
 IF ((request->address_location_cd != 0))
  SET addr_type_cd = 0.0
  SET code_cnt = 1
  SET stat = uar_get_meaning_by_codeset(212,"BUSINESS",code_cnt,addr_type_cd)
  IF (addr_type_cd=0.0)
   SET sub_get_location_name = "<<INFORMATION NOT FOUND>>"
  ELSE
   SELECT INTO "nl:"
    a.street_addr, a.street_addr2, a.street_addr3,
    a.street_addr4, a.city, a.state,
    a.zipcode, a.country, l.location_cd
    FROM address a
    WHERE a.active_ind=1
     AND a.address_type_cd=addr_type_cd
     AND a.parent_entity_name="LOCATION"
     AND (a.parent_entity_id=request->address_location_cd)
    DETAIL
     sub_get_location_name = uar_get_code_display(request->address_location_cd),
     sub_get_location_address1 = a.street_addr, sub_get_location_address2 = a.street_addr2,
     sub_get_location_address3 = a.street_addr3, sub_get_location_address4 = a.street_addr4,
     sub_get_location_citystatezip = concat(trim(a.city),", ",trim(a.state),"  ",trim(a.zipcode)),
     sub_get_location_country = a.country
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET sub_get_location_name = "<<INFORMATION NOT FOUND>>"
   ENDIF
  ENDIF
 ELSE
  SET sub_get_location_name = "<<INFORMATION NOT FOUND>>"
 ENDIF
 SET cur_owner_area_disp = fillstring(40," ")
 SET cur_inv_area_disp = fillstring(40," ")
 IF ((request->cur_owner_area_cd=0.0))
  SET cur_owner_area_disp = captions->all
 ELSE
  SET cur_owner_area_disp = uar_get_code_display(request->cur_owner_area_cd)
 ENDIF
 IF ((request->cur_inv_area_cd=0.0))
  SET cur_inv_area_disp = captions->all
 ELSE
  SET cur_inv_area_disp = uar_get_code_display(request->cur_inv_area_cd)
 ENDIF
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(resourcegroup_codeset,"INSTITUTION",code_cnt,
  institution_group_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(resourcegroup_codeset,"DEPARTMENT",code_cnt,
  department_group_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(resourcegroup_codeset,"SECTION",code_cnt,section_group_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(resourcegroup_codeset,"SUBSECTION",code_cnt,
  subsection_group_cd)
 IF (((institution_group_cd=0.0) OR (((department_group_cd=0.0) OR (((section_group_cd=0.0) OR (
 subsection_group_cd=0.0)) )) )) )
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(bb_processing_codeset,"XM",code_cnt,crossmatch_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(bb_processing_codeset,"PATIENT ABO",code_cnt,patient_abo_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(bb_processing_codeset,"PRODUCT ABO",code_cnt,product_abo_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(bb_processing_codeset,"ANTIGEN",code_cnt,antigen_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(bb_processing_codeset,"ANTIBODY ID",code_cnt,antibody_id_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(bb_processing_codeset,"ANTIBDY SCRN",code_cnt,antibdy_scrn_cd)
 IF (((crossmatch_cd=0.0) OR (((patient_abo_cd=0.0) OR (((product_abo_cd=0.0) OR (((antigen_cd=0.0)
  OR (((antibody_id_cd=0.0) OR (antibdy_scrn_cd=0.0)) )) )) )) )) )
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET title_text = captions->rpt_title
 SET performed_cd = 0.0
 SET verified_cd = 0.0
 SET corrected_cd = 0.0
 SET oldperformed_cd = 0.0
 SET oldverified_cd = 0.0
 SET oldcorrected_cd = 0.0
 SET rejected_cd = 0.0
 SET changed_cd = 0.0
 SET inreview_cd = 0.0
 SET oldinreview_cd = 0.0
 SET corrinreview_cd = 0.0
 SET oldcorrinreview_cd = 0.0
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(result_event_codeset,"CORRECTED",code_cnt,corrected_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(result_event_codeset,"VERIFIED",code_cnt,verified_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(result_event_codeset,"PERFORMED",code_cnt,performed_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(result_event_codeset,"OLDCORRECTED",code_cnt,oldcorrected_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(result_event_codeset,"OLDVERIFIED",code_cnt,oldverified_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(result_event_codeset,"OLDPERFORMED",code_cnt,oldperformed_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(result_event_codeset,"REJECT",code_cnt,rejected_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(result_event_codeset,"CHANGE",code_cnt,changed_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(result_event_codeset,"INREVIEW",code_cnt,inreview_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(result_event_codeset,"OLDINREVIEW",code_cnt,oldinreview_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(result_event_codeset,"CORRINREV",code_cnt,corrinreview_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(result_event_codeset,"OLDCORRINREVIEW",code_cnt,
  oldcorrinreview_cd)
 IF (((corrected_cd=0.0) OR (((verified_cd=0.0) OR (((performed_cd=0.0) OR (((oldcorrected_cd=0.0)
  OR (((oldverified_cd=0.0) OR (((oldperformed_cd=0.0) OR (((rejected_cd=0.0) OR (((changed_cd=0.0)
  OR (((inreview_cd=0.0) OR (((oldinreview_cd=0.0) OR (((corrinreview_cd=0.0) OR (oldcorrinreview_cd=
 0.0)) )) )) )) )) )) )) )) )) )) )) )
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET chartabletype_cd = 0.0
 SET notetype_cd = 0.0
 SET qcfntype_cd = 0.0
 SET qcrevwtype_cd = 0
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(commenttype_codeset,"RES COMMENT",code_cnt,chartabletype_cd)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(commenttype_codeset,"RES NOTE",code_cnt,notetype_cd)
 IF (((chartabletype_cd=0.0) OR (notetype_cd=0.0)) )
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  r.result_id, o.product_id, pr.perform_result_id,
  detail_mnem = trim(substring(1,12,uar_get_code_display(r.task_assay_cd))), drawntime = format(c
   .drawn_dt_tm,"@DATETIMECONDENSED;;d"), perfresultids = build(pr.result_id,pr.perform_result_id,re
   .event_sequence),
  sd.bb_processing_cd, sd.seq
  FROM result_event re,
   perform_result pr,
   result r,
   orders o,
   container c,
   service_directory sd,
   product p
  PLAN (re
   WHERE re.event_dt_tm >= cnvtdatetime(request->dt_tm_begin)
    AND re.event_dt_tm <= cnvtdatetime(request->dt_tm_end))
   JOIN (pr
   WHERE pr.perform_result_id=re.perform_result_id
    AND pr.result_status_cd != oldinreview_cd
    AND pr.result_status_cd != oldcorrinreview_cd)
   JOIN (r
   WHERE r.result_id=pr.result_id)
   JOIN (o
   WHERE o.order_id=r.order_id
    AND o.product_id != null
    AND o.product_id > 0)
   JOIN (p
   WHERE p.product_id=o.product_id
    AND (((request->cur_owner_area_cd > 0.0)
    AND (request->cur_owner_area_cd=p.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
    AND (((request->cur_inv_area_cd > 0.0)
    AND (request->cur_inv_area_cd=p.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
   JOIN (c
   WHERE (c.container_id= Outerjoin(pr.container_id)) )
   JOIN (sd
   WHERE (sd.catalog_cd= Outerjoin(r.catalog_cd)) )
  ORDER BY perfresultids
  HEAD perfresultids
   nbr_prs += 1, stat = alterlist(perf_results->qual,nbr_prs), perf_results->qual[nbr_prs].result_id
    = pr.result_id,
   perf_results->qual[nbr_prs].perform_result_id = pr.perform_result_id, perf_results->qual[nbr_prs].
   service_resource_cd = pr.service_resource_cd, perf_results->qual[nbr_prs].long_text_id = pr
   .long_text_id,
   perf_results->qual[nbr_prs].result_status_cd = pr.result_status_cd, perf_results->qual[nbr_prs].
   order_id = r.order_id, perf_results->qual[nbr_prs].catalog_cd = r.catalog_cd,
   perf_results->qual[nbr_prs].task_assay_cd = r.task_assay_cd, perf_results->qual[nbr_prs].
   detail_mnemonic = detail_mnem, perf_results->qual[nbr_prs].drawn_time = drawntime,
   perf_results->qual[nbr_prs].bb_result_id = r.bb_result_id, perf_results->qual[nbr_prs].
   bb_processing_cd = sd.bb_processing_cd, perf_results->qual[nbr_prs].event_sequence = re
   .event_sequence,
   perf_results->qual[nbr_prs].arg_less_great_flag = pr.less_great_flag
  DETAIL
   no_op = 0
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  dm.task_assay_cd, dm.service_resource_cd, data_map_exists = decode(dm.seq,"Y","N"),
  rg_exists = decode(rg.seq,"Y","N")
  FROM (dummyt d  WITH seq = value(nbr_prs)),
   (dummyt d_dm  WITH seq = 1),
   data_map dm,
   (dummyt d_rg  WITH seq = 1),
   resource_group rg
  PLAN (d
   WHERE d.seq <= nbr_prs
    AND (perf_results->qual[d.seq].result_id > 0.0))
   JOIN (d_dm
   WHERE d_dm.seq=1)
   JOIN (dm
   WHERE (dm.task_assay_cd=perf_results->qual[d.seq].task_assay_cd)
    AND dm.data_map_type_flag=0
    AND dm.active_ind=1)
   JOIN (d_rg
   WHERE d_rg.seq=1)
   JOIN (rg
   WHERE rg.parent_service_resource_cd=dm.service_resource_cd
    AND (rg.child_service_resource_cd=perf_results->qual[d.seq].service_resource_cd)
    AND rg.resource_group_type_cd=subsection_group_cd
    AND ((rg.root_service_resource_cd+ 0)=0.0))
  ORDER BY d.seq, d_dm.seq
  HEAD d.seq
   perf_results->qual[d.seq].arg_min_digits = 1, perf_results->qual[d.seq].arg_max_digits = 8,
   perf_results->qual[d.seq].arg_min_dec_places = 0,
   data_map_level = 0
  HEAD d_dm.seq
   IF (data_map_exists="Y")
    IF (data_map_level <= 2
     AND dm.service_resource_cd > 0
     AND (dm.service_resource_cd=perf_results->qual[d.seq].service_resource_cd))
     data_map_level = 3, perf_results->qual[d.seq].arg_min_digits = dm.min_digits, perf_results->
     qual[d.seq].arg_max_digits = dm.max_digits,
     perf_results->qual[d.seq].arg_min_dec_places = dm.min_decimal_places
    ENDIF
    IF (data_map_level <= 1
     AND dm.service_resource_cd > 0.0
     AND rg_exists="Y"
     AND rg.parent_service_resource_cd=dm.service_resource_cd
     AND (rg.child_service_resource_cd=perf_results->qual[d.seq].service_resource_cd))
     data_map_level = 2, perf_results->qual[d.seq].arg_min_digits = dm.min_digits, perf_results->
     qual[d.seq].arg_max_digits = dm.max_digits,
     perf_results->qual[d.seq].arg_min_dec_places = dm.min_decimal_places
    ENDIF
    IF (data_map_level=0
     AND dm.service_resource_cd=0)
     data_map_level = 1, perf_results->qual[d.seq].arg_min_digits = dm.min_digits, perf_results->
     qual[d.seq].arg_max_digits = dm.max_digits,
     perf_results->qual[d.seq].arg_min_dec_places = dm.min_decimal_places
    ENDIF
   ENDIF
  WITH nocounter, outerjoin(d_dm), outerjoin(d_rg)
 ;end select
 SET num = 0
 SET seqval = 0
 SET pos = 0
 SELECT INTO "nl:"
  rc.result_id, rc.action_sequence, lt.long_text_id,
  lt_long_text = substring(1,32000,lt.long_text)
  FROM result_comment rc,
   long_text lt
  PLAN (rc
   WHERE expand(seqval,1,nbr_prs,rc.result_id,perf_results->qual[seqval].result_id)
    AND ((rc.comment_type_cd=chartabletype_cd) OR (rc.comment_type_cd=notetype_cd)) )
   JOIN (lt
   WHERE rc.long_text_id=lt.long_text_id
    AND lt.long_text_id > 0)
  ORDER BY rc.result_id, rc.comment_type_cd, rc.action_sequence DESC
  HEAD rc.result_id
   row + 0
  HEAD rc.comment_type_cd
   nbr_comments += 1, stat = alterlist(r_long_text->qual,nbr_comments), pos = locateval(num,1,nbr_prs,
    rc.result_id,perf_results->qual[num].result_id),
   r_long_text->qual[nbr_comments].result_id = rc.result_id, r_long_text->qual[nbr_comments].
   perform_result_id = perf_results->qual[pos].perform_result_id, r_long_text->qual[nbr_comments].
   order_id = perf_results->qual[pos].order_id,
   r_long_text->qual[nbr_comments].task_assay_cd = perf_results->qual[pos].task_assay_cd, r_long_text
   ->qual[nbr_comments].result_status_cd = perf_results->qual[pos].result_status_cd
   IF (rc.comment_type_cd=chartabletype_cd)
    r_long_text->qual[nbr_comments].comment_text = trim(lt_long_text)
   ELSEIF (rc.comment_type_cd=notetype_cd)
    r_long_text->qual[nbr_comments].note_text = trim(lt_long_text)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  result_id = perf_results->qual[d1.seq].result_id, perf_result = perf_results->qual[d1.seq].
  perform_result_id, lt.seq,
  lt.long_text_id, lt_long_text = substring(1,32000,lt.long_text)
  FROM (dummyt d1  WITH seq = value(nbr_prs)),
   long_text lt
  PLAN (d1
   WHERE (perf_results->qual[d1.seq].long_text_id > 0))
   JOIN (lt
   WHERE (perf_results->qual[d1.seq].long_text_id=lt.long_text_id))
  ORDER BY result_id, perf_result DESC
  HEAD REPORT
   rtf_out_text = fillstring(32000," "),
   SUBROUTINE remove_rtf(sub_rtf_text)
     rtf_out_text = fillstring(32000," "), len_rtf_out_text = 0,
     CALL uar_rtf(sub_rtf_text,size(sub_rtf_text),rtf_out_text,size(rtf_out_text),len_rtf_out_text,0)
   END ;Subroutine report
   ,
   SUBROUTINE remove_rtf2(sub_rtf_text)
     rtf_out_text = fillstring(32000," "), len_rtf_out_text = 0,
     CALL uar_rtf2(sub_rtf_text,size(sub_rtf_text),rtf_out_text,size(rtf_out_text),len_rtf_out_text,0
     )
   END ;Subroutine report
  DETAIL
   nbr_comments += 1, stat = alterlist(r_long_text->qual,nbr_comments), r_long_text->qual[
   nbr_comments].result_id = perf_results->qual[d1.seq].result_id,
   r_long_text->qual[nbr_comments].perform_result_id = perf_results->qual[d1.seq].perform_result_id,
   r_long_text->qual[nbr_comments].order_id = perf_results->qual[d1.seq].order_id, r_long_text->qual[
   nbr_comments].task_assay_cd = perf_results->qual[d1.seq].task_assay_cd,
   r_long_text->qual[nbr_comments].event_sequence = perf_results->qual[d1.seq].event_sequence,
   r_long_text->qual[nbr_comments].result_status_cd = perf_results->qual[d1.seq].result_status_cd
   IF (lt.seq != null
    AND lt.seq > 0)
    CALL remove_rtf2(lt_long_text), r_long_text->qual[nbr_comments].text_result = trim(rtf_out_text)
   ENDIF
  WITH nocounter
 ;end select
 SET begin_date = format(request->dt_tm_begin,"@DATETIMECONDENSED;;d")
 SET end_date = format(request->dt_tm_end,"@DATETIMECONDENSED;;d")
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbtdailyprodrsl", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  pr.result_id, prod_order.product_id, prod_order.product_nbr,
  re.event_type_cd, pr.result_status_cd, re.perform_result_id,
  o.product_id, cv_oc.display, detail_mnem = perf_results->qual[d_pr.seq].detail_mnemonic,
  alpha_result = trim(substring(1,8,pr.result_value_alpha)), result_code_set_disp = trim(substring(1,
    9,uar_get_code_display(pr.result_code_set_cd))), profile_task_yn = decode(ptr.seq,"Y",pr.seq,"N",
   "Z"),
  order_cell_yn = decode(oc.seq,"Y",pr.seq,"N","Z"), cell_yn = decode(cv_oc.seq,"Y",pr.seq,"N","Z"),
  product_yn = decode(prod.seq,"Y",pr.seq,"N","Z"),
  type_meaning = uar_get_code_meaning(pr.result_type_cd), ptr.sequence, phs_grp.sequence,
  re.event_sequence, re.event_dt_tm, nowtime = format(curtime,"@TIMENOSECONDS;;M"),
  nowdate = format(curdate,"@DATECONDENSED;;d"), drawntime = format(o.orig_order_dt_tm,
   "@DATETIMECONDENSED;;d"), event_date = format(re.event_dt_tm,"@DATETIMECONDENSED;;d"),
  ascii_text = trim(substring(1,13,pr.ascii_text)), text_results = pr.ascii_text, date_result =
  format(pr.result_value_dt_tm,"ddmmmyy;;d"),
  date_time_result = format(pr.result_value_dt_tm,"@DATETIMECONDENSED;;d"), norm_display =
  uar_get_code_display(pr.normal_cd), crit_display = uar_get_code_display(pr.critical_cd),
  notify_disp = decode(pr.seq,uar_get_code_display(pr.notify_cd)," "), revw_display =
  uar_get_code_display(pr.review_cd), delta_display = uar_get_code_display(pr.delta_cd),
  prod_display = uar_get_code_display(prod_order.product_cd), tech_name = substring(1,7,pl.username),
  ord_mnem = trim(substring(1,18,o.order_mnemonic)),
  bb_processing_cd = perf_results->qual[d_pr.seq].bb_processing_cd, product_nbr = prod_order
  .product_nbr, orderunique = build(o.catalog_cd,o.order_id),
  productunique = build(trim(prod_order.product_nbr),prod_order.product_id), pr.perform_result_id,
  p_doc_exists = decode(p_doc.seq,"Y","N"),
  test_site = uar_get_code_display(pr.service_resource_cd), prod_order.product_nbr, oc.bb_result_id,
  oc.order_cell_id, prod.product_nbr, oc.cell_cd,
  pr.long_text_id, perfresultids = build(pr.result_id,pr.perform_result_id,re.event_sequence),
  performdttm = format(pr.perform_dt_tm,"@DATETIMECONDENSED;;d"),
  perftechname = substring(1,7,pl2.username)
  FROM (dummyt d_pr  WITH seq = value(nbr_prs)),
   result_event re,
   perform_result pr,
   (dummyt d_result  WITH seq = 1),
   orders o,
   product prod_order,
   person p_doc,
   prsnl pl,
   (dummyt d_ptr  WITH seq = 1),
   profile_task_r ptr,
   bb_order_cell oc,
   (dummyt d_cv_oc  WITH seq = 1),
   code_value cv_oc,
   product prod,
   (dummyt d_bp2  WITH seq = 1),
   blood_product bp2,
   (dummyt d_phs_grp  WITH seq = 1),
   bb_order_phase op,
   phase_group phs_grp,
   (dummyt d_phase  WITH seq = 1),
   prsnl pl2
  PLAN (d_pr)
   JOIN (pr
   WHERE (pr.perform_result_id=perf_results->qual[d_pr.seq].perform_result_id))
   JOIN (pl2
   WHERE pl2.person_id=pr.perform_personnel_id)
   JOIN (d_result
   WHERE d_result.seq=1)
   JOIN (re
   WHERE (re.result_id=perf_results->qual[d_pr.seq].result_id)
    AND (re.perform_result_id=perf_results->qual[d_pr.seq].perform_result_id)
    AND (re.event_sequence=perf_results->qual[d_pr.seq].event_sequence))
   JOIN (o
   WHERE (o.order_id=perf_results->qual[d_pr.seq].order_id))
   JOIN (prod_order
   WHERE o.product_id > 0
    AND o.product_id != null
    AND o.product_id=prod_order.product_id)
   JOIN (p_doc
   WHERE p_doc.person_id=o.last_update_provider_id)
   JOIN (pl
   WHERE pl.person_id=re.event_personnel_id)
   JOIN (d_ptr
   WHERE d_ptr.seq=1)
   JOIN (((ptr
   WHERE (ptr.catalog_cd=perf_results->qual[d_pr.seq].catalog_cd)
    AND (ptr.task_assay_cd=perf_results->qual[d_pr.seq].task_assay_cd)
    AND (((perf_results->qual[d_pr.seq].bb_processing_cd != antigen_cd)) OR ((((perf_results->qual[
   d_pr.seq].bb_processing_cd=crossmatch_cd)) OR ((((perf_results->qual[d_pr.seq].bb_processing_cd=
   patient_abo_cd)) OR ((((perf_results->qual[d_pr.seq].bb_processing_cd=product_abo_cd)) OR ((
   perf_results->qual[d_pr.seq].bb_result_id=0))) )) )) )) )
   ) ORJOIN ((oc
   WHERE (oc.order_id=perf_results->qual[d_pr.seq].order_id)
    AND (oc.bb_result_id=perf_results->qual[d_pr.seq].bb_result_id))
   JOIN (d_phs_grp
   WHERE d_phs_grp.seq=1)
   JOIN (op
   WHERE (op.order_id=perf_results->qual[d_pr.seq].order_id))
   JOIN (d_phase
   WHERE d_phase.seq=1)
   JOIN (phs_grp
   WHERE op.phase_grp_cd=phs_grp.phase_group_cd
    AND op.phase_grp_cd > 0
    AND (phs_grp.task_assay_cd=perf_results->qual[d_pr.seq].task_assay_cd))
   JOIN (d_cv_oc
   WHERE d_cv_oc.seq=1)
   JOIN (((cv_oc
   WHERE cv_oc.code_value=oc.cell_cd
    AND oc.cell_cd > 0)
   ) ORJOIN ((prod
   WHERE prod.product_id=oc.product_id
    AND oc.product_id > 0)
   )) )) JOIN (d_bp2
   WHERE d_bp2.seq=1)
   JOIN (bp2
   WHERE bp2.product_id=prod_order.product_id)
  ORDER BY test_site, productunique, orderunique,
   test_site, oc.bb_result_id, product_nbr,
   ptr.sequence, phs_grp.sequence, perfresultids,
   re.event_sequence
  HEAD REPORT
   MACRO (print_stuff)
    FOR (i = 1 TO limit)
      saverow = row, nbr_rows_left = reportstuff->qual[i].detailcount
      IF (nbr_rows_left > 0
       AND ((nbr_rows_left+ saverow) > 57)
       AND nbr_rows_left < 42)
       BREAK
      ENDIF
      IF (row > 57)
       BREAK
      ENDIF
      col 0, reportstuff->qual[i].printline, row + 1,
      CALL clear_item(0,i,blank_line), reportstuff->qual[i].detailcount = 0
    ENDFOR
    limit = 0
   ENDMACRO
   ,
   CALL clear_reportstuff(" "), first_page = "Y",
   select_ok_ind = 0, status_disp = fillstring(21," ")
  HEAD PAGE
   inc_i18nhandle = 0, inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
   IF (sub_get_location_name="<<INFORMATION NOT FOUND>>")
    inc_info_not_found = uar_i18ngetmessage(inc_i18nhandle,"inc_information_not_found",
     "<<INFORMATION NOT FOUND>>"), col 1, inc_info_not_found
   ELSE
    col 1, sub_get_location_name
   ENDIF
   row + 1
   IF (sub_get_location_name != "<<INFORMATION NOT FOUND>>")
    IF (sub_get_location_address1 != " ")
     col 1, sub_get_location_address1, row + 1
    ENDIF
    IF (sub_get_location_address2 != " ")
     col 1, sub_get_location_address2, row + 1
    ENDIF
    IF (sub_get_location_address3 != " ")
     col 1, sub_get_location_address3, row + 1
    ENDIF
    IF (sub_get_location_address4 != " ")
     col 1, sub_get_location_address4, row + 1
    ENDIF
    IF (sub_get_location_citystatezip != ",   ")
     col 1, sub_get_location_citystatezip, row + 1
    ENDIF
    IF (sub_get_location_country != " ")
     col 1, sub_get_location_country, row + 1
    ENDIF
   ENDIF
   row 0, col 114, captions->rpt_date,
   col + 1, nowdate, row + 1,
   col 114, captions->rpt_time, col + 1,
   nowtime, row + 1, col 114,
   captions->rpt_by, col 120, reportbyusername"##########;L",
   row + 1, col 114, captions->page_no,
   col + 1, curpage"###", save_row = row,
   row 0,
   CALL center(title_text,1,132), row + 1,
   row save_row, row + 2, col 1,
   captions->test_site, col + 1, test_site,
   row + 2, col 1, captions->bb_owner,
   col 19, cur_owner_area_disp, row + 1,
   col 1, captions->inventory_area, col 17,
   cur_inv_area_disp, row + 2, col 32,
   captions->beg_date, col 48, begin_date,
   col 69, captions->end_date, col 82,
   end_date, row + 2, row + 1,
   col 4, captions->product_number, col 28,
   captions->order_proc, col 92, captions->performed,
   col 113, captions->verified, row + 1,
   col 6, captions->product_type, col 26,
   captions->order_dt_tm, col 49, captions->cell_product,
   col 66, captions->procedure, col 78,
   captions->result, col 86, captions->tech_id,
   col 94, captions->date, col 101,
   captions->time, col 106, captions->tech_id,
   col 115, captions->date, col 122,
   captions->time, row + 1, col 0,
   hyphen_line, col 24, " ",
   col 42, " ", col 65,
   " ", col 76, " ",
   col 85, " ", col 92,
   " ", col 100, " ",
   col 105, " ", col 113,
   " ", col 121, " ",
   row + 1
  HEAD test_site
   IF (first_page="N")
    BREAK
   ELSE
    first_page = "N"
   ENDIF
  HEAD productunique
   prod_nbr_display = concat(trim(bp2.supplier_prefix),trim(prod_order.product_nbr)," ",trim(
     prod_order.product_sub_nbr)),
   CALL store_item(0,1,prod_nbr_display),
   CALL store_item(0,2,prod_display),
   order_row = 0, detail_row = 0
  HEAD orderunique
   IF (detail_row > order_row)
    order_row = detail_row
   ELSE
    detail_row = order_row
   ENDIF
   order_row += 1, detail_row += 1, save1stline = order_row,
   CALL store_item(25,order_row,ord_mnem), order_row += 1
   IF (size(trim(drawntime),3) > 0)
    CALL store_item(25,order_row,drawntime), order_row += 1
   ENDIF
  HEAD oc.bb_result_id
   IF (cell_yn="Y"
    AND product_yn="N")
    CALL store_item(43,detail_row,cv_oc.display)
   ELSEIF (cell_yn="N"
    AND product_yn="Y")
    prod_nbr_display = concat(trim(bp2.supplier_prefix),trim(prod_order.product_nbr)," ",trim(
      prod_order.product_sub_nbr)),
    CALL store_item(43,detail_row,prod_nbr_display)
   ENDIF
  HEAD ptr.sequence
   no_op = 0
  HEAD phs_grp.sequence
   no_op = 0
  HEAD perfresultids
   IF (store_perform_result_id=pr.perform_result_id)
    dont_print_proc = 1
   ELSE
    dont_print_proc = 0
   ENDIF
   IF (pr.result_id > 0
    AND dont_print_proc=0)
    store_perform_result_id = pr.perform_result_id, procedure_row_hold = detail_row,
    CALL store_item(66,detail_row,substring(1,10,detail_mnem))
    IF (type_meaning IN ("1", "7"))
     IF (pr.long_text_id=0)
      CALL store_item(77,detail_row,text_results), offset = (size(trim(text_results),3)+ 77)
     ELSE
      no_op = 0, offset = 79
     ENDIF
    ELSEIF (((type_meaning="2") OR (type_meaning="4"
     AND bb_processing_cd != patient_abo_cd
     AND bb_processing_cd != product_abo_cd)) )
     CALL store_item(77,detail_row,alpha_result), offset = (size(trim(alpha_result),3)+ 77)
    ELSEIF (type_meaning IN ("3", "8"))
     arg_min_digits = perf_results->qual[d_pr.seq].arg_min_digits, arg_max_digits = perf_results->
     qual[d_pr.seq].arg_max_digits, arg_min_dec_places = perf_results->qual[d_pr.seq].
     arg_min_dec_places,
     arg_less_great_flag = perf_results->qual[d_pr.seq].arg_less_great_flag, arg_raw_value = pr
     .result_value_numeric, numeric_result = fillstring(8," "),
     numeric_result = substring(1,8,uar_fmt_result(arg_min_digits,arg_max_digits,arg_min_dec_places,
       arg_less_great_flag,arg_raw_value)),
     CALL store_item(77,detail_row,numeric_result), offset = (size(trim(numeric_result),3)+ 77)
    ELSEIF (type_meaning="6")
     CALL store_item(77,detail_row,date_result), offset = (size(trim(date_result),3)+ 77)
    ELSEIF (type_meaning="11")
     CALL store_item(77,detail_row,date_time_result), offset = (size(trim(date_time_result),3)+ 77)
    ELSE
     CALL store_item(77,detail_row,result_code_set_disp), offset = (size(trim(result_code_set_disp),3
      )+ 77)
    ENDIF
    resultflagstr = fillstring(10," ")
    IF (pr.result_status_cd IN (corrected_cd, oldcorrected_cd))
     correction_flag = "Y"
    ELSE
     correction_flag = "N"
    ENDIF
    cv_normflag = concat(" ",norm_display), cv_critflag = concat(" ",crit_display), cv_revwflag =
    concat(" ",revw_display),
    cv_deltaflag = concat(" ",delta_display), comment_exists = "N", note_exists = "N",
    resultflagstr = bldresultflagstr(cv_normflag,cv_critflag,cv_revwflag,cv_deltaflag,comment_exists,
     note_exists,correction_flag,notify_disp)
    IF (size(trim(resultflagstr),3) > 0)
     CALL store_item(offset,detail_row,resultflagstr), no_op = 0
    ENDIF
   ENDIF
  DETAIL
   IF (store_perfresultids != perfresultids)
    store_perfresultids = perfresultids
    IF (pr.result_id > 0)
     IF (re.event_type_cd IN (verified_cd, corrected_cd))
      offset = 106,
      CALL clear_item(105,procedure_row_hold,fillstring(21," ")),
      CALL store_item(offset,procedure_row_hold,tech_name),
      offset += 8,
      CALL store_item(offset,procedure_row_hold,event_date)
      IF (dont_print_proc=0)
       detail_row += 1
      ENDIF
     ELSEIF (re.event_type_cd IN (performed_cd))
      offset = 86,
      CALL clear_item(105,procedure_row_hold,fillstring(21," ")),
      CALL store_item(offset,procedure_row_hold,tech_name),
      offset += 7,
      CALL store_item(offset,procedure_row_hold,event_date)
      IF (dont_print_proc=0)
       detail_row += 1
      ENDIF
     ELSEIF (re.event_type_cd=inreview_cd)
      offset = 86,
      CALL clear_item(offset,procedure_row_hold,fillstring(20," ")),
      CALL store_item(offset,procedure_row_hold,perftechname),
      offset += 7,
      CALL store_item(offset,procedure_row_hold,performdttm), status_disp = concat("<<< ",trim(
        uar_get_code_display(re.event_type_cd))," >>>"),
      offset = 107,
      CALL store_item(offset,procedure_row_hold,status_disp)
      IF (dont_print_proc=0)
       detail_row += 1
      ENDIF
     ELSEIF (re.event_type_cd=corrinreview_cd)
      status_disp = concat("<<< ",trim(uar_get_code_display(re.event_type_cd))," >>>"), offset = 105,
      CALL store_item(offset,procedure_row_hold,status_disp)
      IF (dont_print_proc=0)
       detail_row += 1
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  FOOT  pr.perform_result_id
   IF (dont_print_proc=0)
    FOR (i = 1 TO nbr_comments)
      IF ((r_long_text->qual[i].perform_result_id=pr.perform_result_id)
       AND (r_long_text->qual[i].event_sequence=re.event_sequence)
       AND (r_long_text->qual[i].text_result > " "))
       IF ((r_long_text->qual[i].result_status_cd IN (corrected_cd, oldcorrected_cd)))
        CALL store_item(57,detail_row,captions->text_result_correct), vcstring = r_long_text->qual[i]
        .text_result, detail_row = store_varchar_item2(detail_row,69,47,1)
       ELSE
        CALL store_item(57,detail_row,captions->text_result), vcstring = r_long_text->qual[i].
        text_result, detail_row = store_varchar_item2(detail_row,66,59,1)
       ENDIF
      ENDIF
    ENDFOR
    FOR (i = 1 TO nbr_comments)
      IF ((r_long_text->qual[i].perform_result_id=pr.perform_result_id))
       IF ((r_long_text->qual[i].comment_text > " "))
        detail_row += 1,
        CALL store_item(57,detail_row,captions->comment), vcstring = r_long_text->qual[i].
        comment_text,
        detail_row = store_varchar_item2(detail_row,64,63,1)
       ENDIF
       IF ((r_long_text->qual[i].note_text > " "))
        detail_row += 1,
        CALL store_item(57,detail_row,captions->note), vcstring = r_long_text->qual[i].note_text,
        detail_row = store_varchar_item2(detail_row,64,63,1)
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
  FOOT  orderunique
   reportstuff->qual[save1stline].detailcount = ((detail_row - save1stline)+ 1)
  FOOT  productunique
   print_stuff
  FOOT PAGE
   row 59, col 1, hyphen_line,
   row + 1, col 1, captions->report_id,
   col 58, captions->page_no, col 64,
   curpage"###", col 110, curdate"@DATECONDENSED;;d",
   col 120, curtime"@TIMENOSECONDS;;M"
  FOOT REPORT
   print_stuff, row + 2,
   CALL center(captions->end_of_report,1,126),
   select_ok_ind = 1
  WITH nocounter, dontcare = cv_result, dontcare = p_doc,
   outerjoin = d_ptr, outerjoin = ptr, outerjoin = oc,
   outerjoin = d_phs_grp, dontcare = op, dontcare = phs_grp,
   outerjoin = d_cv_oc, dontcare = cv_oc, dontcare = prod,
   nullreport, compress, nolandscape,
   maxrow = 63
 ;end select
 IF (nbr_prs=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET rpt_cnt += 1
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (trim(request->batch_selection) > "")
  SET spool value(reply->rpt_list[rpt_cnt].rpt_filename) value(request->printer_name)
 ENDIF
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
