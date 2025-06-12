CREATE PROGRAM bbt_rpt_component:dba
 RECORD prod_list(
   1 loc_list[*]
     2 location_cd = f8
     2 totals[*]
       3 product_cd = f8
       3 count = f8
       3 active_ind = i2
 )
 RECORD num_list(
   1 parent_list[*]
     2 product_number = c20
     2 product_sub_nbr = c5
     2 product_id = f8
     2 product_disp = c16
     2 abo_disp = c2
     2 rh_disp = c3
     2 supplier = c16
     2 orig_vol = i4
     2 orig_meas_disp = c4
     2 orig_exp_dt = dq8
     2 nbr_of_states = i4
     2 states[*]
       3 event_type_disp = c10
     2 nbr_of_mod = i4
     2 mod_list[*]
       3 product_id = f8
       3 product_number = c20
       3 product_sub_nbr = c5
       3 product_disp = c16
       3 abo_disp = c2
       3 rh_disp = c3
       3 nbr_of_states = i4
       3 states[*]
         4 event_type_disp = c10
       3 supplier = c16
       3 drawn_date = dq8
       3 modify_date = dq8
       3 mod_tech_id = c9
       3 mod_vol = i4
       3 mod_meas_disp = c4
       3 mod_exp_dt = dq8
       3 donor_nbr = f8
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
   1 component_report = vc
   1 as_of_date = vc
   1 as_of_time = vc
   1 bb_owner = vc
   1 inventory_area = vc
   1 beg_date = vc
   1 end_date = vc
   1 summary = vc
   1 product = vc
   1 total = vc
   1 report_id = vc
   1 page_no = vc
   1 printed = vc
   1 end_of_report = vc
   1 rpt_detail = vc
   1 product_type = vc
   1 draw_modify = vc
   1 expire = vc
   1 donor = vc
   1 number = vc
   1 sub = vc
   1 orig_modified = vc
   1 aborh = vc
   1 states = vc
   1 supplier = vc
   1 date = vc
   1 time = vc
   1 tech = vc
   1 volume = vc
   1 no_modified = vc
   1 report_id_det = vc
   1 all = vc
   1 unknown = vc
   1 inactive = vc
 )
 SET captions->component_report = uar_i18ngetmessage(i18nhandle,"component_report",
  "C O M P O N E N T   R E P O R T")
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","As of Date:")
 SET captions->as_of_time = uar_i18ngetmessage(i18nhandle,"as_of_time","As of Time:")
 SET captions->bb_owner = uar_i18ngetmessage(i18nhandle,"bb_owner","Blood Bank Owner: ")
 SET captions->inventory_area = uar_i18ngetmessage(i18nhandle,"inventory_area","Inventory Area: ")
 SET captions->beg_date = uar_i18ngetmessage(i18nhandle,"beg_date","Beginning Date:")
 SET captions->end_date = uar_i18ngetmessage(i18nhandle,"end_date","Ending Date:")
 SET captions->summary = uar_i18ngetmessage(i18nhandle,"summary","SUMMARY")
 SET captions->product = uar_i18ngetmessage(i18nhandle,"product","Product")
 SET captions->total = uar_i18ngetmessage(i18nhandle,"total","Total")
 SET captions->report_id = uar_i18ngetmessage(i18nhandle,"report_id","Report ID: BBT_COMPONENT_SUM")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->rpt_detail = uar_i18ngetmessage(i18nhandle,"rpt_detail","DETAIL")
 SET captions->product_type = uar_i18ngetmessage(i18nhandle,"product_type","Product Type")
 SET captions->draw_modify = uar_i18ngetmessage(i18nhandle,"draw_modify","Draw/Modify")
 SET captions->expire = uar_i18ngetmessage(i18nhandle,"expire","Expire")
 SET captions->donor = uar_i18ngetmessage(i18nhandle,"donor","Donor ")
 SET captions->number = uar_i18ngetmessage(i18nhandle,"number","Number")
 SET captions->sub = uar_i18ngetmessage(i18nhandle,"sub","Sub")
 SET captions->orig_modified = uar_i18ngetmessage(i18nhandle,"orig_modified","Orig/Modified")
 SET captions->aborh = uar_i18ngetmessage(i18nhandle,"aborh","ABORh")
 SET captions->states = uar_i18ngetmessage(i18nhandle,"states","States")
 SET captions->supplier = uar_i18ngetmessage(i18nhandle,"supplier","Supplier")
 SET captions->date = uar_i18ngetmessage(i18nhandle,"date","Date")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","Time")
 SET captions->tech = uar_i18ngetmessage(i18nhandle,"tech","Tech")
 SET captions->volume = uar_i18ngetmessage(i18nhandle,"volume","Volume")
 SET captions->no_modified = uar_i18ngetmessage(i18nhandle,"no_modified",
  " * * * No modified products for time frame * * *")
 SET captions->report_id_det = uar_i18ngetmessage(i18nhandle,"report_id_det",
  "Report ID: BBT_COMPONENT_DET")
 SET captions->all = uar_i18ngetmessage(i18nhandle,"all","(All)")
 SET captions->unknown = uar_i18ngetmessage(i18nhandle,"unknown","unknwn")
 SET captions->inactive = uar_i18ngetmessage(i18nhandle,"inactive","(inactive)")
 IF (trim(request->batch_selection) > " ")
  SET begday = request->ops_date
  SET endday = request->ops_date
  SET temp_string = cnvtupper(trim(request->batch_selection))
  CALL check_opt_date_passed("bbt_rpt_component")
  IF ((reply->status_data.status != "F"))
   SET request->start_dt_tm = begday
   SET request->end_dt_tm = endday
  ENDIF
  CALL check_owner_cd("bbt_rpt_component")
  CALL check_inventory_cd("bbt_rpt_component")
  CALL check_location_cd("bbt_rpt_component")
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
 DECLARE count1 = i4 WITH protected, noconstant(0)
 DECLARE count2 = i4 WITH protected, noconstant(0)
 DECLARE count3 = i4 WITH protected, noconstant(0)
 DECLARE qualstep = i4 WITH protected, noconstant(0)
 DECLARE counted = c1 WITH protected, noconstant(" ")
 DECLARE this_cd = f8 WITH protected, noconstant(0.0)
 DECLARE failure_occured = c1 WITH protected, noconstant(" ")
 DECLARE error_process = vc WITH protected, noconstant(" ")
 DECLARE error_message = vc WITH protected, noconstant(" ")
 DECLARE modified_event_type_cd = f8 WITH protected, noconstant(0.0)
 DECLARE mod_prod_event_type_cd = f8 WITH protected, noconstant(0.0)
 DECLARE modified = vc WITH protected, noconstant("8")
 DECLARE modified_product = vc WITH protected, noconstant("24")
 SET count1 = 0
 SET count2 = 0
 SET count3 = 0
 SET qualstep = 0
 SET counted = "F"
 SET this_cd = 0.0
 SET reply->status_data.status = "S"
 SET failure_occured = "F"
 SET error_process = "                                "
 SET error_message = "                                "
 SET modified_event_type_cd = 0.0
 SET mod_prod_event_type_cd = 0.0
 DECLARE get_cvtext(p1) = c23
 SET stat = alterlist(prod_list->loc_list,1)
 SET prod_list->loc_list[1].location_cd = 1234
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
 SET modified_event_type_cd = 0.0
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1610,nullterm(modified),code_cnt,modified_event_type_cd)
 IF (modified_event_type_cd=0.0)
  SET failure_occured = "T"
  SET reply->status_data.status = "F"
  SET error_process = "get codevalues: 1610"
  SET error_message = "could not get Modified event_type_cd"
 ENDIF
 SET mod_prod_event_type_cd = 0.0
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1610,nullterm(modified_product),code_cnt,
  mod_prod_event_type_cd)
 IF (mod_prod_event_type_cd=0.0)
  SET failure_occured = "T"
  SET reply->status_data.status = "F"
  SET error_process = "get codevalues: 1610"
  SET error_message = "could not get Modified_Product event_type_cd"
 ENDIF
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=1604
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 += 1, stat = alterlist(prod_list->loc_list[1].totals,count1), prod_list->loc_list[1].
   totals[count1].product_cd = cv.code_value,
   prod_list->loc_list[1].totals[count1].count = 0, prod_list->loc_list[1].totals[count1].active_ind
    = cv.active_ind
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failure_occured = "T"
  SET reply->status_data.status = "F"
  SET error_process = "get codevalues: 1604"
  SET error_message = "could not get product codes"
 ENDIF
 IF (failure_occured="T")
  GO TO exit_script
 ENDIF
 SET count2 = size(prod_list->loc_list[1].totals,5)
 SELECT INTO "nl:"
  pr1.product_id, pr1.product_cd, pr2.product_id,
  pr2.product_cd, pr2.cur_unit_meas_cd, b1.product_id,
  b1.cur_abo_cd, b1.cur_rh_cd, b2.product_id,
  b2.cur_abo_cd, b2.cur_rh_cd, pe.product_event_id,
  pnl.username, org1.org_name, org2.org_name,
  cv_abo1_display = uar_get_code_display(b1.cur_abo_cd), cv_rh1_display = uar_get_code_display(b1
   .cur_rh_cd), cv_meas1_display = uar_get_code_display(pr1.cur_unit_meas_cd),
  cv_abo2_display = uar_get_code_display(b2.cur_abo_cd), cv_rh2_display = uar_get_code_display(b2
   .cur_rh_cd), cv_meas2_display = uar_get_code_display(pr2.cur_unit_meas_cd),
  cv_p1_display = uar_get_code_display(pr1.product_cd), cv_p2_display = uar_get_code_display(pr2
   .product_cd)
  FROM product pr1,
   product pr2,
   blood_product b1,
   blood_product b2,
   product_event pe,
   product_event pe2,
   organization org1,
   (dummyt d_org1  WITH seq = 1),
   organization org2,
   (dummyt d_org2  WITH seq = 1),
   prsnl pnl,
   (dummyt d_pnl  WITH seq = 1)
  PLAN (pe
   WHERE pe.event_type_cd=modified_event_type_cd
    AND cnvtdatetime(request->start_dt_tm) <= pe.event_dt_tm
    AND cnvtdatetime(request->end_dt_tm) >= pe.event_dt_tm)
   JOIN (pr1
   WHERE pr1.modified_product_ind=1
    AND pe.product_id=pr1.product_id
    AND (((request->cur_owner_area_cd > 0.0)
    AND (request->cur_owner_area_cd=pr1.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
    AND (((request->cur_inv_area_cd > 0.0)
    AND (request->cur_inv_area_cd=pr1.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
   JOIN (b1
   WHERE b1.product_id=pr1.product_id
    AND b1.active_ind=1)
   JOIN (pr2
   WHERE pr2.modified_product_id=pr1.product_id
    AND pr2.active_ind=1)
   JOIN (b2
   WHERE b2.product_id=pr2.product_id
    AND b2.active_ind=1)
   JOIN (pe2
   WHERE pe2.product_id=pr2.product_id
    AND pe2.event_type_cd=mod_prod_event_type_cd)
   JOIN (d_pnl
   WHERE d_pnl.seq=1)
   JOIN (pnl
   WHERE pnl.person_id=pe2.event_prsnl_id
    AND pnl.active_ind=1)
   JOIN (d_org1
   WHERE d_org1.seq=1)
   JOIN (org1
   WHERE org1.organization_id=pr1.cur_supplier_id
    AND org1.organization_id != 0)
   JOIN (d_org2
   WHERE d_org2.seq=1)
   JOIN (org2
   WHERE org2.organization_id=pr2.cur_supplier_id
    AND org2.organization_id != 0)
  ORDER BY pr1.product_id, pr2.product_id
  HEAD REPORT
   count1 = 0
  HEAD pr1.product_id
   count1 += 1, stat = alterlist(num_list->parent_list,count1), count2 = 0,
   num_list->parent_list[count1].product_number = concat(trim(b1.supplier_prefix),trim(pr1
     .product_nbr)), num_list->parent_list[count1].product_sub_nbr = trim(pr1.product_sub_nbr),
   num_list->parent_list[count1].product_id = pr1.product_id,
   num_list->parent_list[count1].product_disp = cv_p1_display, num_list->parent_list[count1].abo_disp
    = cv_abo1_display, num_list->parent_list[count1].rh_disp = cv_rh1_display,
   num_list->parent_list[count1].supplier =
   IF (org1.seq=1) org1.org_name
   ELSE captions->unknown
   ENDIF
   , num_list->parent_list[count1].orig_vol = b1.cur_volume, num_list->parent_list[count1].
   orig_meas_disp = cv_meas1_display,
   num_list->parent_list[count1].orig_exp_dt = cnvtdatetime(pr1.cur_expire_dt_tm)
  HEAD pr2.product_id
   counted = "F", this_cd = pr2.product_cd, count3 = 0,
   count2 += 1, stat = alterlist(num_list->parent_list[count1].mod_list,count2), num_list->
   parent_list[count1].nbr_of_mod = count2,
   num_list->parent_list[count1].mod_list[count2].product_id = pr2.product_id, num_list->parent_list[
   count1].mod_list[count2].product_number = concat(trim(b2.supplier_prefix),trim(pr2.product_nbr)),
   num_list->parent_list[count1].mod_list[count2].product_sub_nbr = trim(pr2.product_sub_nbr),
   num_list->parent_list[count1].mod_list[count2].product_disp = cv_p2_display, num_list->
   parent_list[count1].mod_list[count2].abo_disp = cv_abo2_display, num_list->parent_list[count1].
   mod_list[count2].rh_disp = cv_rh2_display,
   num_list->parent_list[count1].mod_list[count2].supplier =
   IF (org2.seq=1) org2.org_name
   ELSE captions->unknown
   ENDIF
   , num_list->parent_list[count1].mod_list[count2].drawn_date = cnvtdatetime(sysdate), num_list->
   parent_list[count1].mod_list[count2].modify_date = cnvtdatetime(pr2.create_dt_tm),
   num_list->parent_list[count1].mod_list[count2].mod_tech_id =
   IF (pnl.seq=1) pnl.username
   ELSE captions->unknown
   ENDIF
   , num_list->parent_list[count1].mod_list[count2].mod_vol = b2.cur_volume, num_list->parent_list[
   count1].mod_list[count2].mod_meas_disp = cv_meas2_display,
   num_list->parent_list[count1].mod_list[count2].mod_exp_dt = cnvtdatetime(pr2.cur_expire_dt_tm),
   num_list->parent_list[count1].mod_list[count2].donor_nbr = 0
   WHILE (counted="F")
     count3 += 1
     IF ((this_cd=prod_list->loc_list[1].totals[count3].product_cd))
      prod_list->loc_list[1].totals[count3].count += 1, counted = "T"
     ENDIF
     IF (count3 > size(prod_list->loc_list[1].totals,5))
      counted = "T", failure_occured = "T", error_process = "error counting totals",
      error_message = "product code not counted"
     ENDIF
   ENDWHILE
  WITH counter, outerjoin = d_pnl, dontcare = pnl,
   outerjoin = d_org1, dontcare = org1, outerjoin = d_org2,
   dontcare = org2
 ;end select
 SET count1 = size(num_list->parent_list,5)
 FOR (qualstep = 1 TO count1)
   SET count3 = 0
   SELECT DISTINCT INTO "nl:"
    pe.product_event_id, pe.product_id, pe.event_type_cd,
    cv_state_display = uar_get_code_display(pe.event_type_cd)
    FROM product_event pe
    PLAN (pe
     WHERE (num_list->parent_list[qualstep].product_id=pe.product_id)
      AND pe.active_ind=1)
    ORDER BY pe.product_event_id
    DETAIL
     IF (pe.event_type_cd > 0)
      count3 += 1, stat = alterlist(num_list->parent_list[qualstep].states,count3), num_list->
      parent_list[qualstep].nbr_of_states = count3,
      num_list->parent_list[qualstep].states[count3].event_type_disp = cv_state_display
     ENDIF
    WITH counter
   ;end select
   FOR (count2 = 1 TO num_list->parent_list[qualstep].nbr_of_mod)
    SET count3 = 0
    SELECT DISTINCT INTO "nl:"
     pe.product_event_id, pe.product_id, pe.event_type_cd,
     cv_state_display = uar_get_code_display(pe.event_type_cd)
     FROM product_event pe
     PLAN (pe
      WHERE (num_list->parent_list[qualstep].mod_list[count2].product_id=pe.product_id)
       AND pe.active_ind=1)
     ORDER BY pe.product_event_id
     DETAIL
      IF (pe.event_type_cd > 0)
       count3 += 1, stat = alterlist(num_list->parent_list[qualstep].mod_list[count2].states,count3),
       num_list->parent_list[qualstep].mod_list[count2].nbr_of_states = count3,
       num_list->parent_list[qualstep].mod_list[count2].states[count3].event_type_disp =
       cv_state_display
      ENDIF
     WITH nocounter
    ;end select
   ENDFOR
 ENDFOR
 SET product = "                                        "
 SET loc = "               "
 SET count1 = size(prod_list->loc_list[1].totals,5)
 SET line = fillstring(130,"_")
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_cmpnt_sum", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  c_prod.code_value
  FROM code_value c_prod,
   (dummyt d_ar  WITH seq = value(count1))
  PLAN (d_ar)
   JOIN (c_prod
   WHERE (c_prod.code_value=prod_list->loc_list[1].totals[d_ar.seq].product_cd))
  ORDER BY d_ar.seq, c_prod.code_value
  HEAD REPORT
   prod_display = fillstring(35," ")
  HEAD PAGE
   col 111, captions->as_of_date, col 123,
   curdate"@DATECONDENSED;;d", row + 1, col 111,
   captions->as_of_time, col 123, curtime"@TIMENOSECONDS;;M",
   row + 1, inc_i18nhandle = 0, inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev),
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
   CALL center(captions->component_report,1,132),
   row save_row, row + 1, col 1,
   captions->bb_owner, col 19, cur_owner_area_disp,
   row + 1, col 1, captions->inventory_area,
   col 17, cur_inv_area_disp, row + 2,
   col 32, captions->beg_date, col 48,
   request->start_dt_tm"@DATECONDENSED;;d", col 56, request->start_dt_tm"@TIMENOSECONDS;;M",
   col 69, captions->end_date, col 82,
   request->end_dt_tm"@DATECONDENSED;;d", col 90, request->end_dt_tm"@TIMENOSECONDS;;M",
   row + 2,
   CALL center(captions->summary,1,132), row + 3,
   row + 1,
   CALL center(captions->product,40,65),
   CALL center(captions->total,85,91),
   row + 1, col 40, "--------------------------",
   col 85, "-------", row + 1
  HEAD c_prod.code_value
   IF (row > 58)
    BREAK
   ENDIF
   IF ((prod_list->loc_list[1].totals[d_ar.seq].count > 0))
    product = c_prod.display, count1 = prod_list->loc_list[1].totals[d_ar.seq].count
    IF ((prod_list->loc_list[1].totals[d_ar.seq].active_ind=0))
     prod_display = concat(trim(product),"  ",captions->inactive), col 40, prod_display
    ELSE
     col 40, product
    ENDIF
    col 80, count1, row + 1
   ENDIF
  DETAIL
   row + 0
  FOOT PAGE
   row 59, col 1, line,
   row + 1, col 1, captions->report_id,
   col 60, captions->page_no, col 67,
   curpage"###", col 108, captions->printed,
   col 117, curdate"@DATECONDENSED;;d", col 126,
   curtime"@TIMENOSECONDS;;M"
  FOOT REPORT
   row 62, col 53, captions->end_of_report
  WITH nocounter, maxrow = 63, nullreport,
   compress, nolandscape
 ;end select
 SET rpt_cnt += 1
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 SET parent_id = 0.0
 SET count1 = size(num_list->parent_list,5)
 EXECUTE cpm_create_file_name_logical "bbt_cmpnt_det", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  d_ar.seq, parent_id = num_list->parent_list[d_ar.seq].product_id
  FROM (dummyt d_ar  WITH seq = value(count1))
  PLAN (d_ar)
  ORDER BY parent_id
  HEAD PAGE
   col 111, captions->as_of_date, col 123,
   curdate"@DATECONDENSED;;d", row + 1, col 111,
   captions->as_of_time, col 123, curtime"@TIMENOSECONDS;;M",
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
   CALL center(captions->component_report,1,132),
   row save_row, row + 1, col 1,
   captions->bb_owner, col 19, cur_owner_area_disp,
   row + 1, col 1, captions->inventory_area,
   col 17, cur_inv_area_disp, row + 2,
   col 32, captions->beg_date, col 48,
   request->start_dt_tm"@DATECONDENSED;;d", col 56, request->start_dt_tm"@TIMENOSECONDS;;M",
   col 69, captions->end_date, col 82,
   request->end_dt_tm"@DATECONDENSED;;d", col 90, request->end_dt_tm"@TIMENOSECONDS;;M",
   row + 2,
   CALL center(captions->rpt_detail,1,132), row + 3,
   CALL center(captions->product,0,27),
   CALL center(captions->product_type,28,44),
   CALL center(captions->draw_modify,80,92),
   CALL center(captions->expire,111,119),
   CALL center(captions->donor,120,130), row + 1,
   col 1, captions->number, col 21,
   captions->sub,
   CALL center(captions->orig_modified,28,44), col 45,
   captions->aborh, col 52, captions->states,
   col 63, captions->supplier, col 80,
   captions->date, col 88, captions->time,
   col 94, captions->tech, col 104,
   captions->volume,
   CALL center(captions->date,112,118),
   CALL center(captions->number,120,130),
   row + 1, col 0, "---------------------------",
   col 28, "----------------", col 45,
   "------", col 52, "----------",
   col 63, "----------------", col 80,
   "-------------", col 94, "---------",
   col 104, "-------", col 112,
   "-------", col 120, "-----------"
  HEAD parent_id
   IF ((num_list->parent_list[d_ar.seq].product_id > 0.0))
    IF (row > 58)
     BREAK
    ENDIF
    IF (((row+ num_list->parent_list[d_ar.seq].nbr_of_states) > 58))
     BREAK
    ENDIF
    row + 1, aborh = concat(num_list->parent_list[d_ar.seq].abo_disp," ",num_list->parent_list[d_ar
     .seq].rh_disp), meas_val = cnvtstring(num_list->parent_list[d_ar.seq].orig_vol),
    meas = build(meas_val,num_list->parent_list[d_ar.seq].orig_meas_disp), col 0, num_list->
    parent_list[d_ar.seq].product_number,
    col 20, num_list->parent_list[d_ar.seq].product_sub_nbr, col 28,
    num_list->parent_list[d_ar.seq].product_disp, col 45, aborh,
    col 63, num_list->parent_list[d_ar.seq].supplier, col 104,
    meas, col 112, num_list->parent_list[d_ar.seq].orig_exp_dt"@DATECONDENSED;;d"
    IF ((num_list->parent_list[d_ar.seq].nbr_of_states > 1))
     FOR (qualcnt = 1 TO num_list->parent_list[d_ar.seq].nbr_of_states)
       col 52, num_list->parent_list[d_ar.seq].states[qualcnt].event_type_disp, row + 1
     ENDFOR
     row- (1)
    ELSE
     col 52, num_list->parent_list[d_ar.seq].states[1].event_type_disp
    ENDIF
    FOR (count2 = 1 TO num_list->parent_list[d_ar.seq].nbr_of_mod)
      IF (((row+ num_list->parent_list[d_ar.seq].mod_list[count2].nbr_of_states) > 58))
       BREAK
      ENDIF
      row + 1, aborh = concat(num_list->parent_list[d_ar.seq].mod_list[count2].abo_disp," ",num_list
       ->parent_list[d_ar.seq].mod_list[count2].rh_disp), meas_val = cnvtstring(num_list->
       parent_list[d_ar.seq].mod_list[count2].mod_vol),
      meas = build(meas_val,num_list->parent_list[d_ar.seq].mod_list[count2].mod_meas_disp), col 2,
      num_list->parent_list[d_ar.seq].mod_list[count2].product_number,
      col 22, num_list->parent_list[d_ar.seq].mod_list[count2].product_sub_nbr, col 28,
      num_list->parent_list[d_ar.seq].mod_list[count2].product_disp, col 45, aborh,
      col 63, num_list->parent_list[d_ar.seq].mod_list[count2].supplier, col 80,
      num_list->parent_list[d_ar.seq].mod_list[count2].modify_date"@DATECONDENSED;;d", col 87, " ",
      col 88, num_list->parent_list[d_ar.seq].mod_list[count2].modify_date"@TIMENOSECONDS;;M", col 94,
      num_list->parent_list[d_ar.seq].mod_list[count2].mod_tech_id, col 104, meas,
      col 112, num_list->parent_list[d_ar.seq].mod_list[count2].mod_exp_dt"@DATECONDENSED;;d"
      IF ((num_list->parent_list[d_ar.seq].mod_list[count2].nbr_of_states > 1))
       FOR (qualcnt = 1 TO num_list->parent_list[d_ar.seq].mod_list[count2].nbr_of_states)
         col 52, num_list->parent_list[d_ar.seq].mod_list[count2].states[qualcnt].event_type_disp,
         row + 1
       ENDFOR
       row- (1)
      ELSE
       col 52, num_list->parent_list[d_ar.seq].mod_list[count2].states[1].event_type_disp
      ENDIF
    ENDFOR
   ELSEIF (count1 <= 1)
    row + 1,
    CALL center(captions->no_modified,1,131)
   ENDIF
  DETAIL
   row + 1
  FOOT PAGE
   row 59, col 1, line,
   row + 1, col 1, captions->report_id_det,
   col 60, captions->page_no, col 67,
   curpage"###", col 108, captions->printed,
   col 117, curdate"@DATECONDENSED;;d", col 126,
   curtime"@TIMENOSECONDS;;M"
  FOOT REPORT
   row 62, col 53, captions->end_of_report
  WITH nocounter, maxrow = 63, compress,
   nolandscape, nullreport
 ;end select
 SET rpt_cnt += 1
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (trim(request->batch_selection) > " ")
  SET i = 0
  FOR (i = 1 TO rpt_cnt)
    SET spool value(reply->rpt_list[i].rpt_filename) value(request->output_dist)
  ENDFOR
 ENDIF
#exit_script
END GO
