CREATE PROGRAM bbt_rpt_transfus_log:dba
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
   1 rpt_title = vc
   1 rpt_time = vc
   1 rpt_as_of_date = vc
   1 begin_date = vc
   1 ending_date = vc
   1 physician = vc
   1 not_on_file = vc
   1 by_patient_name = vc
   1 by_med_rec_num = vc
   1 blood_bank_owner = vc
   1 inventory_area = vc
   1 by_transfusion_dt_tm = vc
   1 for_all_physicians = vc
   1 for_specific_physicians = vc
   1 patient_info = vc
   1 unit_info = vc
   1 name = vc
   1 alias = vc
   1 abo_rh = vc
   1 product_number = vc
   1 product_type = vc
   1 qty = vc
   1 transfused = vc
   1 rpt_id = vc
   1 rpt_page = vc
   1 printed = vc
   1 end_of_report = vc
   1 all = vc
   1 hist_note = vc
   1 end_of_report = vc
   1 serial_number = vc
 )
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title","T R A N S F U S I O N  L O G")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->rpt_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As of Date:")
 SET captions->begin_date = uar_i18ngetmessage(i18nhandle,"begin_date","Beginning Date:")
 SET captions->ending_date = uar_i18ngetmessage(i18nhandle,"ending_date","Ending Date:")
 SET captions->physician = uar_i18ngetmessage(i18nhandle,"physician","Physician:")
 SET captions->not_on_file = uar_i18ngetmessage(i18nhandle,"not_on_file","<Not on File>")
 SET captions->by_patient_name = uar_i18ngetmessage(i18nhandle,"by_patient_name","(by Patient Name)")
 SET captions->by_med_rec_num = uar_i18ngetmessage(i18nhandle,"by_med_rec_num",
  "(by Medical Record Number)")
 SET captions->blood_bank_owner = uar_i18ngetmessage(i18nhandle,"blood_bank_owner",
  "Blood Bank Owner: ")
 SET captions->inventory_area = uar_i18ngetmessage(i18nhandle,"inventory_area","Inventory Area:")
 SET captions->by_transfusion_dt_tm = uar_i18ngetmessage(i18nhandle,"by_transfusion_dt_tm",
  "(by Transfusion Date/Time)")
 SET captions->for_all_physicians = uar_i18ngetmessage(i18nhandle,"for_all_physicians",
  "(for All Physicians)")
 SET captions->for_specific_physicians = uar_i18ngetmessage(i18nhandle,"for_specific_physicians",
  "(for Specific Physician)")
 SET captions->patient_info = uar_i18ngetmessage(i18nhandle,"patient_info",
  "------------------  PATIENT INFORMATION  -----------------")
 SET captions->unit_info = uar_i18ngetmessage(i18nhandle,"unit_info",
  "----------------------  UNIT INFORMATION  ------------------------")
 SET captions->name = uar_i18ngetmessage(i18nhandle,"name","NAME")
 SET captions->alias = uar_i18ngetmessage(i18nhandle,"alias","ALIAS")
 SET captions->abo_rh = uar_i18ngetmessage(i18nhandle,"abo_rh","ABO/Rh")
 SET captions->product_number = uar_i18ngetmessage(i18nhandle,"product_number","PRODUCT NUMBER/")
 SET captions->product_type = uar_i18ngetmessage(i18nhandle,"product_type","PRODUCT TYPE")
 SET captions->qty = uar_i18ngetmessage(i18nhandle,"qty","QTY")
 SET captions->transfused = uar_i18ngetmessage(i18nhandle,"transfused","TRANSFUSED")
 SET captions->rpt_id = uar_i18ngetmessage(i18nhandle,"rpt_id","Report ID: BBT_RPT_TRANSFUS_LOG")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->all = uar_i18ngetmessage(i18nhandle,"all","(All)")
 SET captions->hist_note = uar_i18ngetmessage(i18nhandle,"hist_note",
  "* - From product history upload.")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->serial_number = uar_i18ngetmessage(i18nhandle,"serial_number","SERIAL NUMBER")
 DECLARE rpt_cnt = i2 WITH noconstant(0)
 DECLARE rpt_filename = c32 WITH noconstant(fillstring(32," "))
 DECLARE mrn_code = f8 WITH noconstant(0.0)
 DECLARE transfuse_code = f8 WITH noconstant(0.0)
 DECLARE code_cnt = i4 WITH noconstant(1)
 DECLARE prod_cnt = i4 WITH noconstant(0)
 DECLARE aborh_index = i4 WITH noconstant(0)
 DECLARE line = vc WITH noconstant(fillstring(125,"_"))
 DECLARE phy_name = vc WITH noconstant(fillstring(40," "))
 DECLARE finish_flag = c1 WITH noconstant(fillstring(1,"N"))
 DECLARE failed = c1 WITH noconstant(fillstring(1,"F"))
 DECLARE cur_owner_area_disp = c40 WITH noconstant(fillstring(40," "))
 DECLARE cur_inv_area_disp = c40 WITH noconstant(fillstring(40," "))
 DECLARE sort_patient = c1 WITH constant("1")
 DECLARE sort_date = c1 WITH constant("2")
 DECLARE sort_all_phys = c1 WITH constant("3")
 DECLARE sort_sel_phys = c1 WITH constant("4")
 DECLARE sort_mrn = c1 WITH constant("5")
 IF (trim(request->batch_selection) > " ")
  SET begday = request->ops_date
  SET endday = request->ops_date
  SET temp_string = cnvtupper(trim(request->batch_selection))
  CALL check_opt_date_passed("bbt_rpt_transfus_log")
  IF ((reply->status_data.status != "F"))
   SET request->beg_transfuse_dt_tm = begday
   SET request->end_transfuse_dt_tm = endday
  ENDIF
  SET sort_selection = fillstring(20," ")
  CALL check_sort_opt("bbt_rpt_transfus_log")
  IF (sort_selection="DATE")
   SET request->report_selection = sort_date
  ELSEIF (sort_selection="PHYSICIAN")
   SET request->report_selection = sort_all_phys
  ELSEIF (sort_selection="NAME")
   SET request->report_selection = sort_patient
  ELSE
   SET request->report_selection = sort_patient
  ENDIF
  CALL check_owner_cd("bbt_rpt_transfus_log")
  CALL check_inventory_cd("bbt_rpt_transfus_log")
  CALL check_location_cd("bbt_rpt_transfus_log")
  SET request->printer_name = trim(request->output_dist)
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
 SET reply->status_data.status = "F"
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(319,nullterm("MRN"),code_cnt,mrn_code)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1610,nullterm("7"),code_cnt,transfuse_code)
 IF (((mrn_code=0.0) OR (transfuse_code=0.0)) )
  SET failed = "T"
  GO TO exit_script
 ENDIF
 DECLARE person_abo_disp = c40 WITH noconstant(fillstring(40," "))
 DECLARE person_rh_disp = c40 WITH noconstant(fillstring(40," "))
 DECLARE product_abo_disp = c40 WITH noconstant(fillstring(40," "))
 DECLARE product_rh_disp = c40 WITH noconstant(fillstring(40," "))
 SET reply->status_data.status = "F"
 SET serrormsg = fillstring(255," ")
 SET nerrorstatus = error(serrormsg,1)
 RECORD trans_data(
   1 products[*]
     2 history_ind = i2
     2 physician_id = f8
     2 physician_name = vc
     2 person_id = f8
     2 person_name = vc
     2 person_alias = vc
     2 person_alias_id = f8
     2 person_aborh = vc
     2 product_id = f8
     2 product_aborh = vc
     2 product_prefix = vc
     2 product_nbr = c25
     2 product_sub_nbr = c5
     2 product_type = vc
     2 qty = c4
     2 transfuse_dt_tm = dq8
     2 serial_number = vc
 )
 SELECT INTO "nl:"
  alias_exists = decode(ea.seq,"Y","N"), pers_name = per.name_full_formatted, phys_name = prs
  .name_full_formatted,
  phys_id = pd.dispense_prov_id, prod_type = uar_get_code_display(pr.product_cd), pr.product_nbr,
  pr.product_sub_nbr, tr.cur_transfused_qty, pe.event_dt_tm,
  flag = decode(bp.seq,"Y","N")
  FROM transfusion tr,
   product pr,
   product_event pe,
   patient_dispense pd,
   person per,
   prsnl prs,
   (dummyt d_bp  WITH seq = 1),
   blood_product bp,
   (dummyt d_pa  WITH seq = 1),
   person_aborh pa,
   (dummyt d_ea  WITH seq = 1),
   encntr_alias ea
  PLAN (pe
   WHERE pe.event_type_cd=transfuse_code
    AND pe.event_dt_tm BETWEEN cnvtdatetime(request->beg_transfuse_dt_tm) AND cnvtdatetime(request->
    end_transfuse_dt_tm)
    AND pe.active_ind=1)
   JOIN (tr
   WHERE tr.product_event_id=pe.product_event_id
    AND tr.active_ind=1)
   JOIN (pr
   WHERE tr.product_id=pr.product_id
    AND (((request->cur_owner_area_cd > 0.0)
    AND (request->cur_owner_area_cd=pr.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
    AND (((request->cur_inv_area_cd > 0.0)
    AND (request->cur_inv_area_cd=pr.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
   JOIN (pd
   WHERE pe.related_product_event_id=pd.product_event_id
    AND (((request->report_selection=sort_sel_phys)
    AND (pd.dispense_prov_id=request->physician_selection)) OR ((request->report_selection IN (
   sort_patient, sort_date, sort_all_phys, sort_mrn)))) )
   JOIN (prs
   WHERE pd.dispense_prov_id=prs.person_id)
   JOIN (per
   WHERE pe.person_id=per.person_id)
   JOIN (d_bp
   WHERE d_bp.seq=1)
   JOIN (bp
   WHERE tr.product_id=bp.product_id)
   JOIN (d_pa
   WHERE d_pa.seq=1)
   JOIN (pa
   WHERE pe.person_id=pa.person_id
    AND pa.active_ind=1)
   JOIN (d_ea
   WHERE d_ea.seq=1)
   JOIN (ea
   WHERE ea.encntr_id=pe.encntr_id
    AND ea.encntr_alias_type_cd=mrn_code
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
  HEAD REPORT
   prod_cnt = 0
  DETAIL
   person_abo_disp = fillstring(40," "), person_rh_disp = fillstring(40," "), product_abo_disp =
   fillstring(40," "),
   product_rh_disp = fillstring(40," "), mrn = fillstring(20," "), prod_cnt += 1
   IF (mod(prod_cnt,10)=1)
    stat = alterlist(trans_data->products,(prod_cnt+ 9))
   ENDIF
   IF (alias_exists="Y")
    mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
   ELSE
    mrn = captions->not_on_file
   ENDIF
   trans_data->products[prod_cnt].history_ind = 0, trans_data->products[prod_cnt].physician_id =
   phys_id, trans_data->products[prod_cnt].physician_name = phys_name,
   trans_data->products[prod_cnt].person_id = per.person_id, trans_data->products[prod_cnt].
   person_name = substring(1,30,pers_name), trans_data->products[prod_cnt].person_alias = substring(1,
    20,mrn),
   trans_data->products[prod_cnt].person_alias_id = ea.encntr_alias_id, person_abo_disp =
   uar_get_code_display(pa.abo_cd), person_rh_disp = uar_get_code_display(pa.rh_cd),
   trans_data->products[prod_cnt].person_aborh = concat(trim(person_abo_disp)," ",trim(person_rh_disp
     )), trans_data->products[prod_cnt].product_id = pr.product_id
   IF (flag="Y")
    product_abo_disp = uar_get_code_display(bp.cur_abo_cd), product_rh_disp = uar_get_code_display(bp
     .cur_rh_cd), trans_data->products[prod_cnt].product_aborh = concat(trim(product_abo_disp)," ",
     trim(product_rh_disp)),
    trans_data->products[prod_cnt].product_prefix = trim(bp.supplier_prefix)
   ENDIF
   trans_data->products[prod_cnt].product_nbr = trim(pr.product_nbr), trans_data->products[prod_cnt].
   product_sub_nbr = trim(pr.product_sub_nbr), trans_data->products[prod_cnt].product_type =
   substring(1,15,uar_get_code_display(pr.product_cd)),
   trans_data->products[prod_cnt].qty = trim(cnvtstring(tr.cur_transfused_qty,4,0,r)), trans_data->
   products[prod_cnt].transfuse_dt_tm = pe.event_dt_tm, trans_data->products[prod_cnt].serial_number
    = pr.serial_number_txt
  FOOT REPORT
   stat = alterlist(trans_data->products,prod_cnt)
  WITH nocounter, outerjoin(d_bp), dontcare(bp),
   outerjoin(d_pa), dontcare(pa), outerjoin(d_ea),
   dontcare(ea)
 ;end select
 SELECT INTO "nl:"
  alias_exists = decode(ea.seq,"Y","N"), pers_name = per.name_full_formatted, phys_name = prs
  .name_full_formatted,
  phys_id = bbhpe.prsnl_id, prod_type = uar_get_code_display(bbhp.product_cd), bbhp.product_nbr,
  bbhp.product_sub_nbr, bbhpe.qty, bbhpe.event_dt_tm
  FROM bbhist_product_event bbhpe,
   bbhist_product bbhp,
   person per,
   prsnl prs,
   (dummyt d_pa  WITH seq = 1),
   person_aborh pa,
   (dummyt d_ea  WITH seq = 1),
   encntr_alias ea
  PLAN (bbhpe
   WHERE bbhpe.event_type_cd=transfuse_code
    AND bbhpe.event_dt_tm BETWEEN cnvtdatetime(request->beg_transfuse_dt_tm) AND cnvtdatetime(request
    ->end_transfuse_dt_tm)
    AND bbhpe.active_ind=1
    AND (((request->report_selection=sort_sel_phys)
    AND (bbhpe.prsnl_id=request->physician_selection)) OR ((request->report_selection IN (
   sort_patient, sort_date, sort_all_phys, sort_mrn)))) )
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
   JOIN (d_pa
   WHERE d_pa.seq=1)
   JOIN (pa
   WHERE bbhpe.person_id=pa.person_id
    AND pa.active_ind=1)
   JOIN (d_ea
   WHERE d_ea.seq=1)
   JOIN (ea
   WHERE bbhpe.encntr_id=ea.encntr_id
    AND ea.encntr_alias_type_cd=mrn_code
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
  HEAD REPORT
   stat = alterlist(trans_data->products,(prod_cnt+ 10))
  DETAIL
   person_abo_disp = fillstring(40," "), person_rh_disp = fillstring(40," "), product_abo_disp =
   fillstring(40," "),
   product_rh_disp = fillstring(40," "), mrn = fillstring(20," "), prod_cnt += 1
   IF (mod(prod_cnt,10)=1)
    stat = alterlist(trans_data->products,(prod_cnt+ 9))
   ENDIF
   IF (alias_exists="Y")
    mrn = cnvtalias(ea.alias,ea.alias_pool_cd)
   ELSE
    mrn = captions->not_on_file
   ENDIF
   trans_data->products[prod_cnt].history_ind = 1, trans_data->products[prod_cnt].physician_id =
   phys_id, trans_data->products[prod_cnt].physician_name = phys_name,
   trans_data->products[prod_cnt].person_id = per.person_id, trans_data->products[prod_cnt].
   person_name = substring(1,30,pers_name), trans_data->products[prod_cnt].person_alias = mrn,
   "####################", trans_data->products[prod_cnt].person_alias_id = ea.encntr_alias_id,
   person_abo_disp = uar_get_code_display(pa.abo_cd),
   person_rh_disp = uar_get_code_display(pa.rh_cd), trans_data->products[prod_cnt].person_aborh =
   concat(trim(person_abo_disp)," ",trim(person_rh_disp)), trans_data->products[prod_cnt].product_id
    = bbhp.product_id,
   product_abo_disp = uar_get_code_display(bbhp.abo_cd), product_rh_disp = uar_get_code_display(bbhp
    .rh_cd), trans_data->products[prod_cnt].product_aborh = concat(trim(product_abo_disp)," ",trim(
     product_rh_disp)),
   trans_data->products[prod_cnt].product_prefix = trim(bbhp.supplier_prefix), trans_data->products[
   prod_cnt].product_nbr = trim(bbhp.product_nbr), trans_data->products[prod_cnt].product_sub_nbr =
   trim(bbhp.product_sub_nbr),
   trans_data->products[prod_cnt].product_type = substring(1,15,uar_get_code_display(bbhp.product_cd)
    ), trans_data->products[prod_cnt].qty = trim(cnvtstring(bbhpe.qty,4,0,r)), trans_data->products[
   prod_cnt].transfuse_dt_tm = bbhpe.event_dt_tm
  FOOT REPORT
   stat = alterlist(trans_data->products,prod_cnt)
  WITH nocounter, outerjoin(d_pa), dontcare(pa),
   outerjoin(d_ea), dontcare(ea)
 ;end select
 SET beg_dt_tm = cnvtdatetime(request->beg_transfuse_dt_tm)
 SET end_dt_tm = cnvtdatetime(request->end_transfuse_dt_tm)
 SET line = fillstring(125,"_")
 SET phy_name = fillstring(40," ")
 EXECUTE cpm_create_file_name_logical "bbt_transfus_log", "txt", "x"
 IF (prod_cnt=0)
  SELECT INTO "nl:"
   prs.name_full_formatted
   FROM prsnl prs
   WHERE (prs.person_id=request->physician_selection)
   DETAIL
    phy_name = prs.name_full_formatted
   WITH nocounter
  ;end select
 ENDIF
 SELECT
  IF ((request->report_selection IN (sort_all_phys, sort_sel_phys)))
   ORDER BY trans_data->products[d.seq].physician_name, trans_data->products[d.seq].physician_id,
    trans_data->products[d.seq].person_name,
    trans_data->products[d.seq].person_id, trans_data->products[d.seq].person_alias, trans_data->
    products[d.seq].person_alias_id,
    cnvtdatetime(trans_data->products[d.seq].transfuse_dt_tm), trans_data->products[d.seq].
    product_nbr, trans_data->products[d.seq].serial_number
  ELSEIF ((request->report_selection=sort_mrn))
   ORDER BY trans_data->products[d.seq].person_alias, trans_data->products[d.seq].person_alias_id,
    trans_data->products[d.seq].person_name,
    trans_data->products[d.seq].person_id, trans_data->products[d.seq].product_nbr, trans_data->
    products[d.seq].serial_number,
    cnvtdatetime(trans_data->products[d.seq].transfuse_dt_tm), trans_data->products[d.seq].
    physician_name, trans_data->products[d.seq].physician_id
  ELSEIF ((request->report_selection=sort_date))
   ORDER BY cnvtdatetime(trans_data->products[d.seq].transfuse_dt_tm), trans_data->products[d.seq].
    person_name, trans_data->products[d.seq].person_id,
    trans_data->products[d.seq].person_alias, trans_data->products[d.seq].person_alias_id, trans_data
    ->products[d.seq].product_nbr,
    trans_data->products[d.seq].serial_number, trans_data->products[d.seq].physician_name, trans_data
    ->products[d.seq].physician_id
  ELSE
   ORDER BY trans_data->products[d.seq].person_name, trans_data->products[d.seq].person_id,
    trans_data->products[d.seq].person_alias,
    trans_data->products[d.seq].person_alias_id, cnvtdatetime(trans_data->products[d.seq].
     transfuse_dt_tm), trans_data->products[d.seq].product_nbr,
    trans_data->products[d.seq].serial_number, trans_data->products[d.seq].physician_name, trans_data
    ->products[d.seq].physician_id
  ENDIF
  INTO cpm_cfn_info->file_name_logical
  d.seq, physician_id = trans_data->products[d.seq].physician_id
  FROM (dummyt d  WITH seq = value(size(trans_data->products,5)))
  PLAN (d)
  HEAD REPORT
   IF ((request->report_selection IN (sort_all_phys, sort_sel_phys)))
    first_time = "Y"
   ENDIF
   product_display = fillstring(26," ")
  HEAD PAGE
   CALL center(captions->rpt_title,1,125), col 104, captions->rpt_time,
   col 118, curtime"@TIMENOSECONDS;;M", row + 1,
   col 104, captions->rpt_as_of_date, col 118,
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
   save_row = row, row 1
   IF ((((request->report_selection=sort_patient)) OR ((request->report_selection=sort_mrn))) )
    IF ((request->report_selection=sort_patient))
     CALL center(captions->by_patient_name,1,125)
    ELSE
     CALL center(captions->by_med_rec_num,1,125)
    ENDIF
    row save_row, row + 1, col 1,
    captions->blood_bank_owner, col 19, cur_owner_area_disp,
    row + 1, col 1, captions->inventory_area,
    col 17, cur_inv_area_disp, row + 2,
    col 24, captions->begin_date, col 41,
    beg_dt_tm"@DATETIMECONDENSED;;d", col 80, captions->ending_date,
    col 94, end_dt_tm"@DATETIMECONDENSED;;d"
   ELSEIF ((request->report_selection=sort_date))
    CALL center(captions->by_transfusion_dt_tm,1,125), row save_row, row + 2,
    col 24, captions->begin_date, col 41,
    beg_dt_tm"@DATETIMECONDENSED;;d", col 80, captions->ending_date,
    col 94, end_dt_tm"@DATETIMECONDENSED;;d"
   ELSEIF ((((request->report_selection=sort_all_phys)) OR ((request->report_selection=sort_sel_phys)
   )) )
    IF ((request->report_selection="3"))
     CALL center(captions->for_all_physicians,1,125)
    ELSE
     CALL center(captions->for_specific_physicians,1,125)
    ENDIF
    row save_row, row + 2, col 24,
    captions->begin_date, col 41, beg_dt_tm"@DATETIMECONDENSED;;d",
    col 80, captions->ending_date, col 94,
    end_dt_tm"@DATETIMECONDENSED;;d", row + 2, col 1,
    captions->physician
    IF ((trans_data->products[d.seq].physician_name > " "))
     col 12, trans_data->products[d.seq].physician_name
    ELSEIF (prod_cnt=0)
     col 12, phy_name
    ELSE
     col 12, captions->not_on_file
    ENDIF
   ENDIF
   row + 3, col 0, captions->patient_info,
   col 60, captions->unit_info, row + 1,
   col 12, captions->name, col 36,
   captions->alias, col 48, captions->abo_rh,
   col 56, captions->abo_rh, col 70,
   captions->product_number, col 93, captions->product_type,
   col 109, captions->qty, col 115,
   captions->transfused, row + 1, col 70,
   captions->serial_number, row + 1, col 0,
   "---------------------------", col 28, "-------------------",
   col 48, "-------", col 56,
   "-------", col 64, "--------------------------",
   col 91, "-----------------", col 109,
   "----", col 114, "------------",
   row + 1, hist_found = false
  HEAD physician_id
   IF ((request->report_selection IN (sort_all_phys, sort_sel_phys)))
    IF (first_time="Y")
     first_time = "N"
    ELSE
     BREAK
    ENDIF
   ENDIF
  DETAIL
   col 0, trans_data->products[d.seq].person_name"###########################", col 28,
   trans_data->products[d.seq].person_alias"####################", col 48, trans_data->products[d.seq
   ].person_aborh"#######",
   col 56, trans_data->products[d.seq].product_aborh"#######"
   IF ((trans_data->products[d.seq].history_ind=0))
    product_display = concat(trim(trans_data->products[d.seq].product_prefix),trim(trans_data->
      products[d.seq].product_nbr)," ",trim(trans_data->products[d.seq].product_sub_nbr))
   ELSE
    product_display = concat("*",trim(trans_data->products[d.seq].product_prefix),trim(trans_data->
      products[d.seq].product_nbr)," ",trim(trans_data->products[d.seq].product_sub_nbr)), hist_found
     = true
   ENDIF
   col 64, product_display"##########################", col 91,
   trans_data->products[d.seq].product_type, col 109, trans_data->products[d.seq].qty,
   col 114, trans_data->products[d.seq].transfuse_dt_tm"@DATETIMECONDENSED;;d"
   IF ((trans_data->products[d.seq].serial_number != null))
    row + 1, col 64, trans_data->products[d.seq].serial_number
   ENDIF
   row + 2
   IF (row > 56)
    BREAK
   ENDIF
  FOOT PAGE
   row 57, col 1, line,
   row + 1, col 1, captions->rpt_id,
   col 58, captions->rpt_page, col 64,
   curpage"###", col 100, captions->printed,
   col 110, curdate"@DATECONDENSED;;d", col 120,
   curtime"@TIMENOSECONDS;;M"
   IF (hist_found)
    row + 1, col 1, captions->hist_note
   ENDIF
  FOOT REPORT
   row 60,
   CALL center(captions->end_of_report,1,125)
  WITH nocounter, nullreport, maxrow = 61,
   maxcol = 132, compress, nolandscape
 ;end select
 SET rpt_cnt += 1
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF ((request->batch_selection > " ")
  AND checkqueue(request->printer_name))
  SET spool value(reply->rpt_list[rpt_cnt].rpt_filename) value(request->printer_name)
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
 FREE RECORD trans_data
END GO
