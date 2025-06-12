CREATE PROGRAM bbt_rpt_final_disp:dba
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
 DECLARE rpt_cnt = i2 WITH noconstant(0)
 DECLARE prod_cnt = i4 WITH noconstant(0)
 DECLARE rpt_filename = c32 WITH noconstant(fillstring(32," "))
 DECLARE mrn_code = f8 WITH noconstant(0.0)
 DECLARE cur_owner_area_disp = c40 WITH noconstant(fillstring(40," "))
 DECLARE cur_inv_area_disp = c40 WITH noconstant(fillstring(40," "))
 DECLARE line = vc WITH noconstant(fillstring(125,"_"))
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE transfuse_code = f8 WITH noconstant(0.0)
 DECLARE transfuse_disp = c40 WITH noconstant(fillstring(40," "))
 DECLARE destroyed_code = f8 WITH noconstant(0.0)
 DECLARE destroyed_disp = c40 WITH noconstant(fillstring(40," "))
 DECLARE qual_cnt = i4 WITH noconstant(0)
 DECLARE dispose_reasons_code_set = i4 WITH constant(1608)
 DECLARE failed = c1 WITH noconstant(fillstring(1,"F"))
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE serrormsg = vc WITH noconstant(fillstring(255," "))
 DECLARE nerrorstatus = i4 WITH noconstant(0)
 DECLARE derivative_class_cd = f8
 SET i18nhandle = 0
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 final_disposition = vc
   1 time = vc
   1 as_of_date = vc
   1 by_prod_type = vc
   1 bb_owner = vc
   1 inventory_area = vc
   1 beg_date = vc
   1 end_date = vc
   1 product_type = vc
   1 disposition = vc
   1 aborh = vc
   1 product_number = vc
   1 qty = vc
   1 reason = vc
   1 name = vc
   1 mrn = vc
   1 dt_tm = vc
   1 tech_id = vc
   1 total = vc
   1 rpt_total = vc
   1 report_id = vc
   1 page_no = vc
   1 printed = vc
   1 end_of_report = vc
   1 all = vc
   1 hist_note = vc
   1 unknown_reason = vc
   1 not_on_file = vc
   1 serial_number = vc
 )
 SET captions->final_disposition = uar_i18ngetmessage(i18nhandle,"final_disposition",
  "F I N A L   D I S P O S I T I O N   L O G")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","Time:")
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","As of Date:")
 SET captions->by_prod_type = uar_i18ngetmessage(i18nhandle,"by_prod_type","(by Product Type)")
 SET captions->bb_owner = uar_i18ngetmessage(i18nhandle,"bb_owner","Blood Bank Owner: ")
 SET captions->inventory_area = uar_i18ngetmessage(i18nhandle,"inventory_area","Inventory Area: ")
 SET captions->beg_date = uar_i18ngetmessage(i18nhandle,"beg_date","Beginning Date:")
 SET captions->end_date = uar_i18ngetmessage(i18nhandle,"end_date","Ending Date:")
 SET captions->product_type = uar_i18ngetmessage(i18nhandle,"product_type","Product Type:")
 SET captions->disposition = uar_i18ngetmessage(i18nhandle,"disposition","Disposition")
 SET captions->aborh = uar_i18ngetmessage(i18nhandle,"aborh","ABO/Rh")
 SET captions->product_number = uar_i18ngetmessage(i18nhandle,"product_number","Product Number/")
 SET captions->qty = uar_i18ngetmessage(i18nhandle,"qty","Qty")
 SET captions->reason = uar_i18ngetmessage(i18nhandle,"reason","(Reason)")
 SET captions->name = uar_i18ngetmessage(i18nhandle,"name","Name")
 SET captions->mrn = uar_i18ngetmessage(i18nhandle,"mrn","MRN")
 SET captions->dt_tm = uar_i18ngetmessage(i18nhandle,"dt_tm","Date/Time")
 SET captions->tech_id = uar_i18ngetmessage(i18nhandle,"tech_id","Tech ID")
 SET captions->total = uar_i18ngetmessage(i18nhandle,"total","Totals for Product Type:")
 SET captions->rpt_total = uar_i18ngetmessage(i18nhandle,"rpt_total","Total")
 SET captions->report_id = uar_i18ngetmessage(i18nhandle,"report_id","Report ID: BBT_RPT_FINAL_DISP")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->all = uar_i18ngetmessage(i18nhandle,"all","(All)")
 SET captions->hist_note = uar_i18ngetmessage(i18nhandle,"hist_note",
  "* - From product history upload.")
 SET captions->unknown_reason = uar_i18ngetmessage(i18nhandle,"unknown_reason","Unknown Reason")
 SET captions->not_on_file = uar_i18ngetmessage(i18nhandle,"not_on_file","<Not on File>")
 SET captions->serial_number = uar_i18ngetmessage(i18nhandle,"serial_number","Serial Number")
 IF (trim(request->batch_selection) > " ")
  SET begday = request->ops_date
  SET endday = request->ops_date
  SET temp_string = cnvtupper(trim(request->batch_selection))
  CALL check_opt_date_passed("bbt_rpt_final_disp")
  IF ((reply->status_data.status != "F"))
   SET request->beg_dt_tm = begday
   SET request->end_dt_tm = endday
  ENDIF
  CALL check_owner_cd("bbt_rpt_final_disp")
  CALL check_inventory_cd("bbt_rpt_final_disp")
  CALL check_location_cd("bbt_rpt_final_disp")
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
 RECORD counters(
   1 qual[*]
     2 found_ind = i2
     2 reason_cd = f8
     2 reason_disp = vc
     2 count = i4
 )
 SET stat = alterlist(counters->qual,10)
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=dispose_reasons_code_set)
  HEAD REPORT
   qual_cnt = 0
  DETAIL
   qual_cnt += 1
   IF (mod(qual_cnt,10)=1
    AND qual_cnt != 1)
    stat = alterlist(counters->qual,(qual_cnt+ 9))
   ENDIF
   counters->qual[qual_cnt].reason_cd = cv.code_value, counters->qual[qual_cnt].reason_disp = cv
   .description, counters->qual[qual_cnt].count = 0,
   counters->qual[qual_cnt].found_ind = 0
  FOOT REPORT
   qual_cnt += 1
   IF (mod(qual_cnt,10)=1
    AND qual_cnt != 1)
    stat = alterlist(counters->qual,(qual_cnt+ 9))
   ENDIF
   counters->qual[qual_cnt].reason_cd = 0, counters->qual[qual_cnt].reason_disp = captions->
   unknown_reason, counters->qual[qual_cnt].count = 0,
   counters->qual[qual_cnt].found_ind = 0, stat = alterlist(counters->qual,qual_cnt)
  WITH nocounter
 ;end select
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
 SET stat = uar_get_meaning_by_codeset(319,nullterm("MRN"),1,mrn_code)
 SET stat = uar_get_meaning_by_codeset(1610,nullterm("7"),1,transfuse_code)
 SET transfuse_disp = uar_get_code_display(transfuse_code)
 SET stat = uar_get_meaning_by_codeset(1610,nullterm("14"),1,destroyed_code)
 SET destroyed_disp = uar_get_code_display(destroyed_code)
 SET stat = uar_get_meaning_by_codeset(1606,nullterm("DERIVATIVE"),1,derivative_class_cd)
 IF (((mrn_code=0.0) OR (((transfuse_code=0.0) OR (destroyed_code=0.0)) )) )
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 SET nerrorstatus = error(serrormsg,1)
 RECORD final_disp_data(
   1 products[*]
     2 history_ind = i2
     2 product_id = f8
     2 product_aborh = vc
     2 product_prefix = vc
     2 product_nbr = vc
     2 product_sub_nbr = c5
     2 product_type = c40
     2 qty = i4
     2 disposition = vc
     2 disposition_cd = f8
     2 disposition_reason = vc
     2 disposition_dt_tm = dq8
     2 disposition_tech_id = vc
     2 person_id = f8
     2 person_name = vc
     2 person_alias = vc
     2 person_alias_id = f8
     2 derivative_ind = i2
     2 serial_number = vc
 )
 SELECT INTO "nl:"
  alias_exists = decode(d_ea.seq,"Y","N"), ea.alias, pers_name = per.name_full_formatted,
  pr.product_cd, pr.product_nbr, pr.product_sub_nbr,
  pe.event_dt_tm
  FROM product_event pe,
   product pr,
   prsnl prs,
   transfusion tr,
   person per,
   (dummyt d_ea  WITH seq = 1),
   encntr_alias ea,
   (dummyt d_bp_de  WITH seq = 1),
   blood_product bp,
   derivative de
  PLAN (pe
   WHERE pe.event_type_cd=transfuse_code
    AND pe.active_ind=1
    AND pe.event_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND pe.event_status_flag=0)
   JOIN (pr
   WHERE pe.product_id=pr.product_id
    AND (((request->cur_owner_area_cd > 0.0)
    AND (request->cur_owner_area_cd=pr.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
    AND (((request->cur_inv_area_cd > 0.0)
    AND (request->cur_inv_area_cd=pr.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
   JOIN (prs
   WHERE pe.event_prsnl_id=prs.person_id)
   JOIN (tr
   WHERE pe.product_event_id=tr.product_event_id
    AND tr.active_ind=1)
   JOIN (per
   WHERE pe.person_id=per.person_id)
   JOIN (d_ea
   WHERE d_ea.seq=1)
   JOIN (ea
   WHERE ea.encntr_id=pe.encntr_id
    AND ea.encntr_alias_type_cd=mrn_code
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (d_bp_de
   WHERE d_bp_de.seq=1)
   JOIN (((bp
   WHERE pe.product_id=bp.product_id)
   ) ORJOIN ((de
   WHERE pe.product_id=de.product_id)
   ))
  HEAD REPORT
   prod_cnt = 0, alias = fillstring(17," "), abo_display = fillstring(15," "),
   rh_display = fillstring(15," ")
  DETAIL
   prod_cnt += 1
   IF (mod(prod_cnt,10)=1)
    stat = alterlist(final_disp_data->products,(prod_cnt+ 9))
   ENDIF
   final_disp_data->products[prod_cnt].history_ind = 0, final_disp_data->products[prod_cnt].
   product_id = pr.product_id, abo_display = uar_get_code_display(bp.cur_abo_cd),
   rh_display = uar_get_code_display(bp.cur_rh_cd), final_disp_data->products[prod_cnt].product_aborh
    = concat(trim(abo_display)," ",trim(rh_display)), final_disp_data->products[prod_cnt].
   product_prefix = trim(bp.supplier_prefix),
   final_disp_data->products[prod_cnt].product_nbr = trim(pr.product_nbr), final_disp_data->products[
   prod_cnt].product_sub_nbr = trim(pr.product_sub_nbr), final_disp_data->products[prod_cnt].
   product_type = uar_get_code_display(pr.product_cd),
   final_disp_data->products[prod_cnt].qty = tr.cur_transfused_qty, final_disp_data->products[
   prod_cnt].disposition = uar_get_code_display(pe.event_type_cd), final_disp_data->products[prod_cnt
   ].disposition_cd = 0,
   final_disp_data->products[prod_cnt].disposition_reason = "", final_disp_data->products[prod_cnt].
   disposition_dt_tm = pe.event_dt_tm, final_disp_data->products[prod_cnt].disposition_tech_id = prs
   .username,
   final_disp_data->products[prod_cnt].person_id = per.person_id, final_disp_data->products[prod_cnt]
   .person_name = substring(1,30,pers_name)
   IF (pr.serial_number_txt != null)
    final_disp_data->products[prod_cnt].serial_number = pr.serial_number_txt
   ENDIF
   IF (alias_exists="Y"
    AND ea.encntr_alias_id > 0.0)
    alias = cnvtalias(ea.alias,ea.alias_pool_cd), final_disp_data->products[prod_cnt].person_alias =
    alias, final_disp_data->products[prod_cnt].person_alias_id = ea.encntr_alias_id
   ELSE
    final_disp_data->products[prod_cnt].person_alias = captions->not_on_file
   ENDIF
   IF (pr.product_class_cd=derivative_class_cd)
    final_disp_data->products[prod_cnt].derivative_ind = 1
   ENDIF
  FOOT REPORT
   stat = alterlist(final_disp_data->products,prod_cnt)
  WITH nocounter, dontcare = ea, outerjoin(d_ea)
 ;end select
 SELECT INTO "nl:"
  pr.product_cd, pr.product_nbr, pr.product_sub_nbr,
  pe.event_dt_tm
  FROM product_event pe,
   product pr,
   prsnl prs,
   destruction ds,
   disposition dis,
   (dummyt d_bp_de  WITH seq = 1),
   blood_product bp2,
   derivative de2
  PLAN (pe
   WHERE pe.event_type_cd=destroyed_code
    AND pe.active_ind=1
    AND pe.event_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND pe.event_status_flag=0)
   JOIN (pr
   WHERE pe.product_id=pr.product_id
    AND (((request->cur_owner_area_cd > 0.0)
    AND (request->cur_owner_area_cd=pr.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
    AND (((request->cur_inv_area_cd > 0.0)
    AND (request->cur_inv_area_cd=pr.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
   JOIN (prs
   WHERE pe.event_prsnl_id=prs.person_id)
   JOIN (ds
   WHERE pe.product_id=ds.product_id
    AND pe.product_event_id=ds.product_event_id
    AND ds.active_ind=1
    AND pe.event_status_flag=0)
   JOIN (dis
   WHERE dis.product_event_id=pe.related_product_event_id)
   JOIN (d_bp_de
   WHERE d_bp_de.seq=1)
   JOIN (((bp2
   WHERE pe.product_id=bp2.product_id)
   ) ORJOIN ((de2
   WHERE pe.product_id=de2.product_id)
   ))
  HEAD REPORT
   stat = alterlist(final_disp_data->products,(prod_cnt+ 10)), abo_display = fillstring(15," "),
   rh_display = fillstring(15," ")
  DETAIL
   prod_cnt += 1
   IF (mod(prod_cnt,10)=1)
    stat = alterlist(final_disp_data->products,(prod_cnt+ 9))
   ENDIF
   final_disp_data->products[prod_cnt].history_ind = 0, final_disp_data->products[prod_cnt].
   product_id = pr.product_id, abo_display = uar_get_code_display(bp2.cur_abo_cd),
   rh_display = uar_get_code_display(bp2.cur_rh_cd), final_disp_data->products[prod_cnt].
   product_aborh = concat(trim(abo_display)," ",trim(rh_display)), final_disp_data->products[prod_cnt
   ].product_prefix = trim(bp2.supplier_prefix),
   final_disp_data->products[prod_cnt].product_nbr = trim(pr.product_nbr), final_disp_data->products[
   prod_cnt].product_sub_nbr = trim(pr.product_sub_nbr), final_disp_data->products[prod_cnt].
   product_type = uar_get_code_display(pr.product_cd),
   final_disp_data->products[prod_cnt].qty = ds.destroyed_qty, final_disp_data->products[prod_cnt].
   disposition = uar_get_code_display(pe.event_type_cd), final_disp_data->products[prod_cnt].
   disposition_cd = dis.reason_cd,
   final_disp_data->products[prod_cnt].disposition_reason = uar_get_code_display(dis.reason_cd),
   final_disp_data->products[prod_cnt].disposition_dt_tm = pe.event_dt_tm, final_disp_data->products[
   prod_cnt].disposition_tech_id = prs.username,
   final_disp_data->products[prod_cnt].person_id = 0, final_disp_data->products[prod_cnt].person_name
    = "", final_disp_data->products[prod_cnt].person_alias = "",
   final_disp_data->products[prod_cnt].person_alias_id = 0
   IF (pr.serial_number_txt != null)
    final_disp_data->products[prod_cnt].serial_number = pr.serial_number_txt
   ENDIF
   IF (pr.product_class_cd=derivative_class_cd)
    final_disp_data->products[prod_cnt].derivative_ind = 1
   ENDIF
  FOOT REPORT
   stat = alterlist(final_disp_data->products,prod_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  pers_name = per.name_full_formatted, bbhp.product_cd, bbhp.product_nbr,
  bbhp.product_sub_nbr, bbhpe.event_dt_tm
  FROM bbhist_product_event bbhpe,
   bbhist_product bbhp,
   person per,
   prsnl prs,
   encntr_alias ea
  PLAN (bbhpe
   WHERE bbhpe.event_type_cd IN (transfuse_code, destroyed_code)
    AND bbhpe.event_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
    end_dt_tm)
    AND bbhpe.active_ind=1)
   JOIN (bbhp
   WHERE bbhp.product_id=bbhpe.product_id
    AND (((request->cur_owner_area_cd > 0.0)
    AND (request->cur_owner_area_cd=bbhp.owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
    AND (((request->cur_inv_area_cd > 0.0)
    AND (request->cur_inv_area_cd=bbhp.inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
   JOIN (prs
   WHERE bbhpe.prsnl_id=prs.person_id)
   JOIN (per
   WHERE bbhpe.person_id=per.person_id)
   JOIN (ea
   WHERE (ea.encntr_id= Outerjoin(bbhpe.encntr_id))
    AND (ea.encntr_alias_type_cd= Outerjoin(mrn_code))
    AND (ea.active_ind= Outerjoin(1))
    AND (ea.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
    AND (ea.end_effective_dt_tm>= Outerjoin(cnvtdatetime(sysdate))) )
  HEAD REPORT
   stat = alterlist(final_disp_data->products,(prod_cnt+ 10)), alias = fillstring(17," "),
   abo_display = fillstring(15," "),
   rh_display = fillstring(15," ")
  DETAIL
   prod_cnt += 1
   IF (mod(prod_cnt,10)=1)
    stat = alterlist(final_disp_data->products,(prod_cnt+ 9))
   ENDIF
   final_disp_data->products[prod_cnt].history_ind = 1, final_disp_data->products[prod_cnt].
   product_id = bbhp.product_id, abo_display = uar_get_code_display(bbhp.abo_cd),
   rh_display = uar_get_code_display(bbhp.rh_cd), final_disp_data->products[prod_cnt].product_aborh
    = concat(trim(abo_display)," ",trim(rh_display)), final_disp_data->products[prod_cnt].
   product_prefix = trim(bbhp.supplier_prefix),
   final_disp_data->products[prod_cnt].product_nbr = trim(bbhp.product_nbr), final_disp_data->
   products[prod_cnt].product_sub_nbr = trim(bbhp.product_sub_nbr), final_disp_data->products[
   prod_cnt].product_type = uar_get_code_display(bbhp.product_cd),
   final_disp_data->products[prod_cnt].qty = bbhpe.qty, final_disp_data->products[prod_cnt].
   disposition = uar_get_code_display(bbhpe.event_type_cd), final_disp_data->products[prod_cnt].
   disposition_cd = bbhpe.reason_cd,
   final_disp_data->products[prod_cnt].disposition_reason = uar_get_code_display(bbhpe.reason_cd),
   final_disp_data->products[prod_cnt].disposition_dt_tm = bbhpe.event_dt_tm, final_disp_data->
   products[prod_cnt].disposition_tech_id = prs.username,
   final_disp_data->products[prod_cnt].person_id = per.person_id, final_disp_data->products[prod_cnt]
   .person_name = substring(1,30,pers_name), final_disp_data->products[prod_cnt].person_alias_id = ea
   .encntr_alias_id
   IF ((final_disp_data->products[prod_cnt].person_alias_id=0.0))
    final_disp_data->products[prod_cnt].person_alias = captions->not_on_file
   ELSE
    alias = cnvtalias(ea.alias,ea.alias_pool_cd), final_disp_data->products[prod_cnt].person_alias =
    alias
   ENDIF
   IF (bbhp.product_class_cd=derivative_class_cd)
    final_disp_data->products[prod_cnt].derivative_ind = 1
   ENDIF
  FOOT REPORT
   stat = alterlist(final_disp_data->products,prod_cnt)
  WITH nocounter
 ;end select
 SET line = fillstring(125,"_")
 EXECUTE cpm_create_file_name_logical "bbt_final_disp", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  d.seq, product_type = final_disp_data->products[d.seq].product_type
  "########################################", sort_prod_aborh = cnvtupper(substring(1,15,
    final_disp_data->products[d.seq].product_aborh)),
  sort_prod_nbr = substring(1,20,final_disp_data->products[d.seq].product_nbr), sort_prod_sub_nbr =
  substring(1,5,final_disp_data->products[d.seq].product_sub_nbr)
  FROM (dummyt d  WITH seq = value(size(final_disp_data->products,5)))
  PLAN (d)
  ORDER BY product_type, sort_prod_aborh, sort_prod_nbr,
   sort_prod_sub_nbr
  HEAD REPORT
   line = fillstring(125,"_"), first_time = "Y", transfuse_cnt = 0,
   destroy_cnt = 0, reason_cnt = 0, cur_prod_type = product_type
  HEAD PAGE
   CALL center(captions->final_disposition,1,125), col 104, captions->time,
   col 118, curtime"@TIMENOSECONDS;;M", row + 1,
   col 104, captions->as_of_date, col 118,
   curdate"@DATECONDENSED;;d", inc_i18nhandle = 0, inc_h = uar_i18nlocalizationinit(inc_i18nhandle,
    curprog,"",curcclrev),
   row 0
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
   save_row = row, row 1,
   CALL center(captions->by_prod_type,1,125),
   row save_row, row + 1, col 1,
   captions->bb_owner, col 19, cur_owner_area_disp,
   row + 1, col 1, captions->inventory_area,
   col 17, cur_inv_area_disp, row + 2,
   col 34, captions->beg_date, col 50,
   request->beg_dt_tm"@DATETIMECONDENSED;;d", col 73, captions->end_date,
   col 86, request->end_dt_tm"@DATETIMECONDENSED;;d", row + 3,
   col 1, captions->product_type, col 15,
   cur_prod_type, row + 1,
   CALL center(captions->disposition,48,62),
   CALL center(captions->product_number,16,41), row + 1,
   CALL center(captions->aborh,1,14),
   CALL center(captions->serial_number,16,41), col 43, captions->qty,
   CALL center(captions->reason,48,62),
   CALL center(captions->name,64,86),
   CALL center(captions->mrn,88,102),
   CALL center(captions->dt_tm,104,115),
   CALL center(captions->tech_id,117,125), row + 1,
   col 1, "--------------", col 16,
   "--------------------------", col 43, "----",
   col 48, "---------------", col 64,
   "-----------------------", col 88, "---------------",
   col 104, "------------", col 117,
   "---------", row + 1, hist_found = false
  HEAD product_type
   cur_prod_type = product_type
   IF (first_time="Y")
    first_time = "N"
   ELSE
    BREAK
   ENDIF
  DETAIL
   IF (row >= 55)
    BREAK
   ENDIF
   col 1, final_disp_data->products[d.seq].product_aborh"##############"
   IF ((final_disp_data->products[d.seq].history_ind=0))
    col 16,
    CALL print(concat(final_disp_data->products[d.seq].product_prefix,final_disp_data->products[d.seq
     ].product_nbr," ",final_disp_data->products[d.seq].product_sub_nbr))
   ELSE
    col 16,
    CALL print(concat("*",final_disp_data->products[d.seq].product_prefix,final_disp_data->products[d
     .seq].product_nbr," ",final_disp_data->products[d.seq].product_sub_nbr)), hist_found = true
   ENDIF
   IF ((final_disp_data->products[d.seq].qty > 0))
    col 43, final_disp_data->products[d.seq].qty"####;p "
   ELSE
    col 43, "    "
   ENDIF
   col 48, final_disp_data->products[d.seq].disposition, col 64,
   final_disp_data->products[d.seq].person_name"#######################", col 88, final_disp_data->
   products[d.seq].person_alias"###############",
   col 104, final_disp_data->products[d.seq].disposition_dt_tm"@DATETIMECONDENSED;;d", col 117,
   final_disp_data->products[d.seq].disposition_tech_id"#########"
   IF ((final_disp_data->products[d.seq].serial_number != null)
    AND (final_disp_data->products[d.seq].disposition=transfuse_disp))
    row + 1, col 16, final_disp_data->products[d.seq].serial_number
   ENDIF
   IF ((final_disp_data->products[d.seq].disposition=destroyed_disp))
    row + 1, col 16, final_disp_data->products[d.seq].serial_number,
    col 48,
    CALL print(concat("(",trim(final_disp_data->products[d.seq].disposition_reason),")"))
   ENDIF
   row + 2
   IF (row > 56)
    BREAK
   ENDIF
   IF ((final_disp_data->products[d.seq].derivative_ind=1))
    IF ((final_disp_data->products[d.seq].disposition=transfuse_disp))
     transfuse_cnt += final_disp_data->products[d.seq].qty
    ELSEIF ((final_disp_data->products[d.seq].disposition=destroyed_disp))
     destroy_cnt += final_disp_data->products[d.seq].qty
     FOR (idx = 1 TO qual_cnt)
       IF ((counters->qual[idx].reason_cd=final_disp_data->products[d.seq].disposition_cd))
        counters->qual[idx].count += 1
        IF ((counters->qual[idx].found_ind != 1))
         reason_cnt += 1, counters->qual[idx].found_ind = 1
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
   ELSE
    IF ((final_disp_data->products[d.seq].disposition=transfuse_disp))
     transfuse_cnt += 1
    ELSEIF ((final_disp_data->products[d.seq].disposition=destroyed_disp))
     destroy_cnt += 1
     FOR (idx = 1 TO qual_cnt)
       IF ((counters->qual[idx].reason_cd=final_disp_data->products[d.seq].disposition_cd))
        counters->qual[idx].count += 1
        IF ((counters->qual[idx].found_ind != 1))
         reason_cnt += 1, counters->qual[idx].found_ind = 1
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
  FOOT  product_type
   IF ((row > (50 - reason_cnt)))
    BREAK
   ENDIF
   col 1, captions->total, col 26,
   cur_prod_type, row + 2, col 4,
   CALL print(concat(trim(transfuse_disp),":")), col 21, transfuse_cnt"####;p ",
   row + 2, col 4,
   CALL print(concat(trim(destroyed_disp),":"))
   IF (destroy_cnt=0)
    col 21, destroy_cnt"####;p ", row + 1
   ELSE
    row + 1
    FOR (idx = 1 TO qual_cnt)
      IF ((counters->qual[idx].count > 0))
       col 10, counters->qual[idx].reason_disp, col 40,
       counters->qual[idx].count"####", row + 1
      ENDIF
    ENDFOR
    col 40, "____", row + 1,
    col 10, captions->rpt_total, col 40,
    destroy_cnt"####;p "
   ENDIF
   transfuse_cnt = 0, destroy_cnt = 0, reason_cnt = 0
   FOR (idx = 1 TO qual_cnt)
    counters->qual[idx].found_ind = 0,counters->qual[idx].count = 0
   ENDFOR
  FOOT PAGE
   row 57, col 1, line,
   row + 1, col 1, captions->report_id,
   col 58, captions->page_no, col 64,
   curpage"###", col 100, captions->printed,
   col 110, curdate"@DATECONDENSED;;d", col 120,
   curtime"@TIMENOSECONDS;;M"
   IF (hist_found)
    row + 1, col 1, captions->hist_note
   ENDIF
  FOOT REPORT
   row 60, col 51, captions->end_of_report
  WITH nocounter, nullreport, maxrow = 61,
   maxcol = 132, compress
 ;end select
 SET rpt_cnt += 1
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (trim(request->batch_selection) > " ")
  SET spool value(reply->rpt_list[rpt_cnt].rpt_filename) value(request->output_dist)
 ENDIF
#exit_script
 SET nerrorstatus = error(serrormsg,0)
 IF (nerrorstatus != 0)
  SET reply->status_data.status = "F"
 ELSE
  IF (failed="T")
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
 ENDIF
 FREE RECORD captions
 FREE RECORD counters
 FREE RECORD final_disp_data
END GO
