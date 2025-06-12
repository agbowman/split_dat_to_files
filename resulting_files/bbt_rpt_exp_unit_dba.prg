CREATE PROGRAM bbt_rpt_exp_unit:dba
 FREE RECORD quar_request
 RECORD quar_request(
   1 event_prsnl_id = f8
   1 event_dt_tm = dq8
   1 productlist[*]
     2 product_id = f8
     2 cur_inv_locn_cd = f8
     2 p_updt_cnt = i4
     2 drv_updt_cnt = i4
     2 available_product_event_id = f8
     2 available_pe_updt_cnt = i4
     2 quarlist[1]
       3 quar_reason_cd = f8
       3 quar_qty = i4
 )
 FREE SET quar_reply
 RECORD quar_reply(
   1 product_status[10]
     2 product_id = f8
     2 status = c1
     2 err_process = vc
     2 err_message = vc
     2 quar_status[10]
       3 quar_reason_cd = f8
       3 product_event_id = f8
       3 product_event_status = c2
       3 status = c1
       3 err_process = vc
       3 err_message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET rpt_request
 RECORD rpt_request(
   1 productlist[*]
     2 pr_product_id = f8
     2 pr_product_nbr = c20
     2 pr_product_display = c20
     2 og_org_name = c20
     2 bp_supplier_prefix = c20
     2 pr_product_sub_nbr = c20
     2 pr_cur_expire_dt_tm = dq8
     2 bp_cur_abo_cd = f8
     2 bp_cur_rh_cd = f8
     2 pr_alternate_nbr = c20
     2 d_flag = c20
     2 quarantine_status = c20
     2 lock_ind = i2
     2 serial_number_txt = c20
 )
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
   1 expired_unit_rpt = vc
   1 time = vc
   1 as_of_date = vc
   1 blood_products = vc
   1 bb_owner = vc
   1 inventory_area = vc
   1 beg_date = vc
   1 end_date = vc
   1 product_number = vc
   1 expires = vc
   1 aborh = vc
   1 product_type = vc
   1 supplier = vc
   1 alternate_id = vc
   1 status = vc
   1 report_id = vc
   1 page_no = vc
   1 printed = vc
   1 end_of_report = vc
   1 all = vc
   1 note1 = vc
   1 note2 = vc
   1 serial_number = vc
 )
 SET captions->expired_unit_rpt = uar_i18ngetmessage(i18nhandle,"expired_unit_rpt",
  "E X P I R E D   U N I T   R E P O R T")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","Time:")
 SET captions->serial_number = uar_i18ngetmessage(i18nhandle,"serial_number","Serial Number")
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","As of Date:")
 SET captions->blood_products = uar_i18ngetmessage(i18nhandle,"blood_products",
  "(Blood Products & Derivatives)")
 SET captions->bb_owner = uar_i18ngetmessage(i18nhandle,"bb_owner","Blood Bank Owner: ")
 SET captions->inventory_area = uar_i18ngetmessage(i18nhandle,"inventory_area","Inventory Area: ")
 SET captions->beg_date = uar_i18ngetmessage(i18nhandle,"beg_date","Beginning Date:")
 SET captions->end_date = uar_i18ngetmessage(i18nhandle,"end_date","Ending Date:")
 SET captions->product_number = uar_i18ngetmessage(i18nhandle,"product_number","Product Number")
 SET captions->expires = uar_i18ngetmessage(i18nhandle,"expires","Expires")
 SET captions->aborh = uar_i18ngetmessage(i18nhandle,"aborh","ABO/Rh")
 SET captions->product_type = uar_i18ngetmessage(i18nhandle,"product_type","Product Type")
 SET captions->supplier = uar_i18ngetmessage(i18nhandle,"supplier","Supplier")
 SET captions->alternate_id = uar_i18ngetmessage(i18nhandle,"alternate_id","Alternate ID")
 SET captions->report_id = uar_i18ngetmessage(i18nhandle,"report_id","Report ID: BBT_RPT_EXP_UNIT")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->all = uar_i18ngetmessage(i18nhandle,"all","(All)")
 SET captions->note1 = uar_i18ngetmessage(i18nhandle,"note1",
  "**Q denotes product quarantined. NQ denotes product qualified for quarantine but not quarantined."
  )
 SET captions->note2 = uar_i18ngetmessage(i18nhandle,"note2",
  "Blank denotes product did not qualify for quarantine.")
 DECLARE quarantine_reason_cd = f8 WITH constant(uar_get_code_by("MEANING",1630,"SYSTEM_QUAR"))
 DECLARE quar_loop = i4 WITH noconstant(0)
 DECLARE pos = i4 WITH noconstant(0)
 DECLARE quar_count = i4 WITH noconstant(0)
 DECLARE rpt_prd_cnt = i4 WITH noconstant(0)
 DECLARE mode_selection = vc
 DECLARE quar_mode = vc WITH noconstant(" ")
 DECLARE temp_string = vc
 DECLARE sort_selection = vc
 DECLARE sort_field = vc WITH noconstant(" ")
 IF (trim(request->batch_selection) > " ")
  SET begday = request->ops_date
  SET endday = request->ops_date
  SET temp_string = cnvtupper(trim(request->batch_selection))
  SET mode_selection = fillstring(6," ")
  CALL check_opt_date_passed("bbt_rpt_exp_unit")
  IF ((reply->status_data.status != "F"))
   SET request->beg_expire_dt_tm = begday
   SET request->end_expire_dt_tm = endday
  ENDIF
  CALL check_owner_cd("bbt_rpt_exp_unit")
  CALL check_inventory_cd("bbt_rpt_exp_unit")
  CALL check_location_cd("bbt_rpt_exp_unit")
  CALL check_mode_opt("bbt_rpt_exp_unit")
  IF (((mode_selection="UPDATE") OR (((mode_selection="REPORT") OR (mode_selection=" ")) )) )
   SET quar_mode = mode_selection
  ELSE
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_exp_unit"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "no mode selection"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "no correct mode selection in string"
   GO TO exit_script
  ENDIF
  SET sort_selection = fillstring(20," ")
  CALL check_sort_opt("bbt_rpt_exp_unit")
  IF (((sort_selection="EXPDATE") OR (sort_selection=" ")) )
   SET sort_field = sort_selection
  ELSE
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_exp_unit"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "no mode selection"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "no correct mode selection in string"
   GO TO exit_script
  ENDIF
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
 RECORD aborh(
   1 aborh_list[*]
     2 aborh_display = c15
     2 abo_code = f8
     2 rh_code = f8
 )
 SET stat = alterlist(aborh->aborh_list,10)
 SET aborh_index = 0
 SELECT INTO "nl:"
  FROM code_value cv1,
   code_value_extension cve1,
   code_value_extension cve2
  PLAN (cv1
   WHERE cv1.code_set=1640
    AND cv1.active_ind=1)
   JOIN (cve1
   WHERE cve1.code_set=1640
    AND cv1.code_value=cve1.code_value
    AND cve1.field_name="ABOOnly_cd")
   JOIN (cve2
   WHERE cve2.code_set=1640
    AND cv1.code_value=cve2.code_value
    AND cve2.field_name="RhOnly_cd")
  ORDER BY cve1.field_value, cve2.field_value
  DETAIL
   aborh_index += 1
   IF (mod(aborh_index,10)=1
    AND aborh_index != 1)
    stat = alterlist(aborh->aborh_list,(aborh_index+ 9))
   ENDIF
   aborh->aborh_list[aborh_index].aborh_display = cv1.display, aborh->aborh_list[aborh_index].
   abo_code = cnvtreal(cve1.field_value), aborh->aborh_list[aborh_index].rh_code = cnvtreal(cve2
    .field_value)
  WITH check, nocounter
 ;end select
 IF (curqual > 0)
  SET stat = alterlist(aborh->aborh_list,aborh_index)
 ENDIF
 SET line = fillstring(125,"_")
 SET transfuse_code = 0.0
 SET dispose_code = 0.0
 SET destroy_code = 0.0
 SET shipped_code = 0.0
 SET quarantine_code = 0.0
 SET available_code = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "5"
 SET dispose_code = uar_get_code_by("MEANING",1610,nullterm(cdf_meaning))
 SET cdf_meaning = "7"
 SET transfuse_code = uar_get_code_by("MEANING",1610,nullterm(cdf_meaning))
 SET cdf_meaning = "14"
 SET destroy_code = uar_get_code_by("MEANING",1610,nullterm(cdf_meaning))
 SET cdf_meaning = "15"
 SET shipped_code = uar_get_code_by("MEANING",1610,nullterm(cdf_meaning))
 SET cdf_meaning = "2"
 SET quarantine_code = uar_get_code_by("MEANING",1610,nullterm(cdf_meaning))
 SET cdf_meaning = "12"
 SET available_code = uar_get_code_by("MEANING",1610,nullterm(cdf_meaning))
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 SELECT INTO "nl:"
  d_flg = decode(bp.seq,"BP",de.seq,"DE","XX"), pe.event_type_cd, pr.product_id,
  pr.product_nbr, pr.product_sub_nbr, pr.alternate_nbr,
  product_disp = uar_get_code_display(pr.product_cd), og.org_name, pr.cur_expire_dt_tm,
  pr.serial_number_txt
  FROM product pr,
   product_event pe,
   (dummyt d1  WITH seq = 1),
   organization og,
   (dummyt d2  WITH seq = 1),
   blood_product bp,
   derivative de
  PLAN (pr
   WHERE pr.cur_expire_dt_tm BETWEEN cnvtdatetime(request->beg_expire_dt_tm) AND cnvtdatetime(request
    ->end_expire_dt_tm)
    AND (((request->cur_owner_area_cd > 0.0)
    AND (request->cur_owner_area_cd=pr.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
    AND (((request->cur_inv_area_cd > 0.0)
    AND (request->cur_inv_area_cd=pr.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
   JOIN (pe
   WHERE pr.product_id=pe.product_id)
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (og
   WHERE pr.cur_supplier_id=og.organization_id
    AND pr.cur_supplier_id > 0)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (((bp
   WHERE pr.product_id=bp.product_id)
   ) ORJOIN ((de
   WHERE pr.product_id=de.product_id)
   ))
  ORDER BY pr.product_id
  HEAD pr.product_id
   display_bp = "Y", display_de = "N", quar_ind_bp = "Y",
   quar_ind_de = "Y", avail_product_eventid = 0.0, avail_updt_cnt = 0,
   avail_der_qty = 0
  DETAIL
   IF (d_flg="BP")
    IF (((pe.event_type_cd=transfuse_code) OR (((pe.event_type_cd=dispose_code) OR (((pe
    .event_type_cd=destroy_code) OR (pe.event_type_cd=shipped_code)) )) ))
     AND pe.active_ind=1)
     display_bp = "N"
    ELSEIF (pe.event_type_cd=available_code
     AND pe.active_ind=1)
     avail_product_eventid = pe.product_event_id, avail_updt_cnt = pe.updt_cnt
    ELSEIF (pe.event_type_cd=quarantine_code
     AND pe.active_ind=1)
     quar_ind_bp = "N"
    ENDIF
   ELSE
    IF (pe.event_type_cd != transfuse_code
     AND pe.event_type_cd != dispose_code
     AND pe.event_type_cd != destroy_code
     AND pe.active_ind=1)
     display_de = "Y"
    ENDIF
    IF (pe.event_type_cd=available_code
     AND pe.active_ind=1)
     avail_product_eventid = pe.product_event_id, avail_updt_cnt = pe.updt_cnt, avail_der_qty = de
     .cur_avail_qty
    ELSEIF (pe.event_type_cd=quarantine_code
     AND pe.active_ind=1)
     quar_ind_de = "N"
    ENDIF
   ENDIF
  FOOT  pr.product_id
   IF (d_flg="BP"
    AND display_bp="Y")
    IF (quar_ind_bp="Y"
     AND pr.cur_expire_dt_tm < cnvtdatetime(sysdate)
     AND pr.locked_ind != 1
     AND cnvtupper(quar_mode)="UPDATE")
     quar_count += 1
     IF (mod(quar_count,10)=1)
      stat = alterlist(quar_request->productlist,(quar_count+ 9))
     ENDIF
     quar_request->productlist[quar_count].product_id = pr.product_id, quar_request->productlist[
     quar_count].cur_inv_locn_cd = pr.cur_inv_locn_cd, quar_request->productlist[quar_count].
     p_updt_cnt = pr.updt_cnt,
     quar_request->productlist[quar_count].available_product_event_id = avail_product_eventid,
     quar_request->productlist[quar_count].available_pe_updt_cnt = avail_updt_cnt, quar_request->
     productlist[quar_count].quarlist[1].quar_reason_cd = quarantine_reason_cd
    ENDIF
    rpt_prd_cnt += 1
    IF (mod(rpt_prd_cnt,10)=1)
     stat = alterlist(rpt_request->productlist,(rpt_prd_cnt+ 9))
    ENDIF
    rpt_request->productlist[rpt_prd_cnt].pr_product_id = pr.product_id, rpt_request->productlist[
    rpt_prd_cnt].pr_product_nbr = pr.product_nbr, rpt_request->productlist[rpt_prd_cnt].
    pr_product_display = product_disp,
    rpt_request->productlist[rpt_prd_cnt].og_org_name = og.org_name, rpt_request->productlist[
    rpt_prd_cnt].bp_supplier_prefix = bp.supplier_prefix, rpt_request->productlist[rpt_prd_cnt].
    pr_product_sub_nbr = pr.product_sub_nbr,
    rpt_request->productlist[rpt_prd_cnt].pr_cur_expire_dt_tm = pr.cur_expire_dt_tm, rpt_request->
    productlist[rpt_prd_cnt].bp_cur_abo_cd = bp.cur_abo_cd, rpt_request->productlist[rpt_prd_cnt].
    bp_cur_rh_cd = bp.cur_rh_cd,
    rpt_request->productlist[rpt_prd_cnt].pr_alternate_nbr = pr.alternate_nbr, rpt_request->
    productlist[rpt_prd_cnt].d_flag = d_flg, rpt_request->productlist[rpt_prd_cnt].serial_number_txt
     = pr.serial_number_txt
    IF (quar_ind_bp="Y"
     AND pr.cur_expire_dt_tm < cnvtdatetime(sysdate)
     AND cnvtupper(quar_mode)="UPDATE")
     rpt_request->productlist[rpt_prd_cnt].quarantine_status = "NQ"
     IF (pr.locked_ind=1)
      rpt_request->productlist[rpt_prd_cnt].lock_ind = 1
     ENDIF
    ELSEIF (quar_ind_bp="N"
     AND cnvtupper(quar_mode)="UPDATE")
     rpt_request->productlist[rpt_prd_cnt].quarantine_status = "Q"
    ELSE
     rpt_request->productlist[rpt_prd_cnt].quarantine_status = "  "
    ENDIF
   ELSEIF (d_flg="DE"
    AND display_de="Y")
    IF (avail_der_qty > 0
     AND pr.cur_expire_dt_tm < cnvtdatetime(sysdate)
     AND pr.locked_ind != 1
     AND cnvtupper(quar_mode)="UPDATE")
     quar_count += 1
     IF (mod(quar_count,10)=1)
      stat = alterlist(quar_request->productlist,(quar_count+ 9))
     ENDIF
     quar_request->productlist[quar_count].product_id = pr.product_id, quar_request->productlist[
     quar_count].cur_inv_locn_cd = pr.cur_inv_locn_cd, quar_request->productlist[quar_count].
     p_updt_cnt = pr.updt_cnt,
     quar_request->productlist[quar_count].drv_updt_cnt = de.updt_cnt, quar_request->productlist[
     quar_count].available_product_event_id = avail_product_eventid, quar_request->productlist[
     quar_count].available_pe_updt_cnt = avail_updt_cnt,
     quar_request->productlist[quar_count].quarlist[1].quar_reason_cd = quarantine_reason_cd,
     quar_request->productlist[quar_count].quarlist[1].quar_qty = avail_der_qty
    ENDIF
    rpt_prd_cnt += 1
    IF (mod(rpt_prd_cnt,10)=1)
     stat = alterlist(rpt_request->productlist,(rpt_prd_cnt+ 9))
    ENDIF
    rpt_request->productlist[rpt_prd_cnt].pr_product_id = pr.product_id, rpt_request->productlist[
    rpt_prd_cnt].pr_product_nbr = pr.product_nbr, rpt_request->productlist[rpt_prd_cnt].
    pr_product_display = product_disp,
    rpt_request->productlist[rpt_prd_cnt].og_org_name = og.org_name, rpt_request->productlist[
    rpt_prd_cnt].pr_product_sub_nbr = pr.product_sub_nbr, rpt_request->productlist[rpt_prd_cnt].
    pr_cur_expire_dt_tm = pr.cur_expire_dt_tm,
    rpt_request->productlist[rpt_prd_cnt].pr_alternate_nbr = pr.alternate_nbr, rpt_request->
    productlist[rpt_prd_cnt].d_flag = d_flg, rpt_request->productlist[rpt_prd_cnt].serial_number_txt
     = pr.serial_number_txt
    IF (avail_der_qty > 0
     AND pr.cur_expire_dt_tm < cnvtdatetime(sysdate)
     AND cnvtupper(quar_mode)="UPDATE")
     rpt_request->productlist[rpt_prd_cnt].quarantine_status = "NQ"
     IF (pr.locked_ind=1)
      rpt_request->productlist[rpt_prd_cnt].lock_ind = 1
     ENDIF
    ELSEIF (quar_ind_de="N"
     AND cnvtupper(quar_mode)="UPDATE")
     rpt_request->productlist[rpt_prd_cnt].quarantine_status = "Q"
    ELSE
     rpt_request->productlist[rpt_prd_cnt].quarantine_status = "  "
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(quar_request->productlist,quar_count), stat = alterlist(rpt_request->productlist,
    rpt_prd_cnt)
  WITH counter, outerjoin(d1), dontcare(og)
 ;end select
 IF (quar_count > 0)
  EXECUTE bbt_add_quarantine  WITH replace("REQUEST",quar_request), replace("REPLY",quar_reply)
 ENDIF
 EXECUTE cpm_create_file_name_logical "bbt_exp_unit", "txt", "x"
 SELECT
  IF (sort_field="EXPDATE")
   ORDER BY cnvtdatetime(rpt_request->productlist[d.seq].pr_cur_expire_dt_tm)
  ELSE
   ORDER BY rpt_request->productlist[d.seq].pr_product_nbr, rpt_request->productlist[d.seq].
    pr_product_sub_nbr
  ENDIF
  INTO cpm_cfn_info->file_name_logical
  FROM (dummyt d  WITH seq = value(size(rpt_request->productlist,5)))
  PLAN (d)
  HEAD REPORT
   select_ok_ind = 0
   IF (cnvtupper(quar_mode)="UPDATE")
    foot_start_row = 56
   ELSE
    foot_start_row = 57
   ENDIF
  HEAD PAGE
   beg_expire_dt_tm = cnvtdatetime(request->beg_expire_dt_tm), end_expire_dt_tm = cnvtdatetime(
    request->end_expire_dt_tm),
   CALL center(captions->expired_unit_rpt,1,125),
   col 105, captions->time, col 119,
   curtime"@TIMENOSECONDS;;M", row + 1, col 105,
   captions->as_of_date, col 119, curdate"@DATECONDENSED;;d",
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
   save_row = row, row 1,
   CALL center(captions->blood_products,1,125),
   row save_row, row + 1, col 1,
   captions->bb_owner, col 19, cur_owner_area_disp,
   row + 1, col 1, captions->inventory_area,
   col 17, cur_inv_area_disp, row + 2,
   col 34, captions->beg_date, col 50,
   beg_expire_dt_tm"@DATETIMECONDENSED;;d", col 73, captions->end_date,
   col 86, end_expire_dt_tm"@DATETIMECONDENSED;;d", row + 2,
   col 1, captions->product_number, row + 1,
   col 1, captions->serial_number, col 24,
   "  ",
   CALL center(captions->expires,27,38),
   CALL center(captions->aborh,40,54),
   CALL center(captions->product_type,56,80),
   CALL center(captions->supplier,82,106),
   CALL center(captions->alternate_id,108,125),
   row + 1, col 1, "----------------------",
   col 24, "--", col 27,
   "------------", col 40, "---------------",
   col 56, "-------------------------", col 82,
   "-------------------------", col 108, "------------------",
   row + 1
  DETAIL
   pos = 0
   IF (row > foot_start_row)
    BREAK
   ENDIF
   expire_dt_tm = cnvtdatetime(rpt_request->productlist[d.seq].pr_cur_expire_dt_tm), product_display
    = fillstring(25," "), product_display = substring(1,25,rpt_request->productlist[d.seq].
    pr_product_display),
   supplier = substring(1,25,rpt_request->productlist[d.seq].og_org_name), supplr_prfx = rpt_request
   ->productlist[d.seq].bp_supplier_prefix, prod_nbr = rpt_request->productlist[d.seq].pr_product_nbr,
   prod_sub_nbr = rpt_request->productlist[d.seq].pr_product_sub_nbr, prod_nbr_display = concat(trim(
     supplr_prfx),trim(prod_nbr)," ",trim(prod_sub_nbr)), serial_number = substring(1,25,rpt_request
    ->productlist[d.seq].serial_number_txt)
   IF ((rpt_request->productlist[d.seq].quarantine_status="NQ")
    AND (rpt_request->productlist[d.seq].lock_ind != 1))
    pos = locateval(quar_loop,1,quar_count,rpt_request->productlist[d.seq].pr_product_id,quar_reply->
     product_status[quar_loop].product_id)
    IF (pos > 0)
     IF ((quar_reply->product_status[pos].status="S"))
      rpt_request->productlist[d.seq].quarantine_status = "Q"
     ENDIF
    ENDIF
   ENDIF
   IF (row > 55)
    BREAK
   ENDIF
   col 1, prod_nbr_display, col 24,
   rpt_request->productlist[d.seq].quarantine_status, col 27, expire_dt_tm"@DATETIMECONDENSED;;d"
   IF ((rpt_request->productlist[d.seq].d_flag="BP"))
    idx_a = 1, finish_flag = "N"
    WHILE (idx_a <= aborh_index
     AND finish_flag="N")
      IF ((rpt_request->productlist[d.seq].bp_cur_abo_cd=aborh->aborh_list[idx_a].abo_code)
       AND (rpt_request->productlist[d.seq].bp_cur_rh_cd=aborh->aborh_list[idx_a].rh_code))
       col 40, aborh->aborh_list[idx_a].aborh_display"###############", finish_flag = "Y"
      ELSE
       idx_a += 1
      ENDIF
    ENDWHILE
   ENDIF
   col 56, product_display
   IF (supplier="0")
    col 82, " "
   ELSE
    col 82, supplier
   ENDIF
   col 108, rpt_request->productlist[d.seq].pr_alternate_nbr"##################"
   IF (serial_number != null)
    row + 1, col 1, serial_number
   ENDIF
   row + 2
  FOOT PAGE
   row foot_start_row, col 1, line,
   row + 1, col 1, captions->report_id,
   col 58, captions->page_no, col 64,
   curpage"###", col 100, captions->printed,
   col 109, curdate"@DATECONDENSED;;d", col 120,
   curtime"@TIMENOSECONDS;;M"
   IF (cnvtupper(quar_mode)="UPDATE")
    row + 1, col 1, captions->note1,
    row + 1, col 3, captions->note2
   ENDIF
  FOOT REPORT
   row 60,
   CALL center(captions->end_of_report,1,125), select_ok_ind = 1
  WITH nullreport, counter, maxrow = 61,
   compress, nolandscape
 ;end select
 SET rpt_cnt += 1
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (trim(request->batch_selection) > " ")
  SET spool value(reply->rpt_list[rpt_cnt].rpt_filename) value(request->output_dist)
 ENDIF
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
