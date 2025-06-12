CREATE PROGRAM bbt_rpt_transf_not_charged:dba
 RECORD reply(
   1 rpt_list[*]
     2 rpt_filename = vc
   1 ltransfused_product_cnt = i4
   1 results[*]
     2 batch_transfuse_ind = c1
     2 product_event_id = f8
     2 pd_product_event_id = f8
     2 product_type = c1
     2 product_cd = f8
     2 product_id = f8
     2 serial_number = vc
     2 product_nbr = vc
     2 person_id = f8
     2 encounter_id = f8
     2 event_prsnl_id = f8
     2 transfused_iu = i4
     2 transfused_qty = i4
     2 transfused_dt_tm = dq8
     2 transfused_tz = i4
     2 order_id = f8
     2 accession = c20
     2 dispense_loc_cd = f8
     2 status = c1
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
 DECLARE i18nhandle = i4 WITH protected, noconstant(0)
 DECLARE h = i4 WITH protected, noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 rpt_name = vc
   1 time = vc
   1 as_of_date = vc
   1 beg_date = vc
   1 end_date = vc
   1 not_on_file = vc
   1 report_update = vc
   1 report_only = vc
   1 bb_owner = vc
   1 inventory_area = vc
   1 all = vc
   1 report_id = vc
   1 page_no = vc
   1 printed = vc
   1 end_of_report = vc
   1 name = vc
   1 mrn = vc
   1 transfused = vc
   1 dttm = vc
   1 product_number = vc
   1 product_type = vc
   1 accession_number = vc
   1 dispense_loc = vc
   1 serial_number = vc
 )
 CALL setcaptions(null)
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
 DECLARE dispense_event_type_cd = f8 WITH protected, noconstant(0.0)
 DECLARE transfuse_event_type_cd = f8 WITH protected, noconstant(0.0)
 DECLARE crossmatch_event_type_cd = f8 WITH protected, noconstant(0.0)
 DECLARE charge_product_cd = f8 WITH protected, noconstant(0.0)
 DECLARE poolfee_cd = f8 WITH protected, noconstant(0.0)
 DECLARE mrn_cd = f8 WITH protected, noconstant(0.0)
 DECLARE stat = i4 WITH protected, noconstant(0)
 DECLARE event_cnt = i4 WITH protected, noconstant(0)
 DECLARE update_mode_ind = i2 WITH protected, noconstant(0)
 DECLARE owner_disp = vc WITH protected, noconstant(" ")
 DECLARE inventory_disp = vc WITH protected, noconstant(" ")
 DECLARE select_ok_ind = i2 WITH protected, noconstant(0)
 DECLARE dummy_seq = i4 WITH protected, noconstant(1)
 DECLARE rpt_cnt = i4 WITH protected, noconstant(0)
 SET stat = setopsrequest(0)
 IF (stat=0)
  GO TO exit_script
 ENDIF
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
  SET owner_disp = captions->all
 ELSE
  SET owner_disp = uar_get_code_display(request->cur_owner_area_cd)
 ENDIF
 IF ((request->cur_inv_area_cd=0.0))
  SET inventory_disp = captions->all
 ELSE
  SET inventory_disp = uar_get_code_display(request->cur_inv_area_cd)
 ENDIF
 SET stat = getcodevalues(null)
 IF (stat=0)
  GO TO exit_script
 ENDIF
 SET reply->ltransfused_product_cnt = 0
 SELECT INTO "nl:"
  t_pe.product_id, c_pe.order_id, accession = cnvtacc(aor.accession),
  bp.product_id, pd.dispense_to_locn_cd, d.item_volume
  FROM product_event t_pe,
   product_event d_pe,
   patient_dispense pd,
   product p,
   blood_product bp,
   derivative d,
   product_event c_pe,
   accession_order_r aor
  PLAN (t_pe
   WHERE t_pe.event_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
    end_dt_tm)
    AND t_pe.event_type_cd=transfuse_event_type_cd
    AND t_pe.active_ind=1)
   JOIN (d_pe
   WHERE t_pe.related_product_event_id=d_pe.product_event_id
    AND d_pe.event_type_cd=dispense_event_type_cd
    AND  NOT ( EXISTS (
   (SELECT
    ce.ext_m_event_id
    FROM charge_event ce
    WHERE d_pe.product_event_id=ce.ext_m_event_id
     AND ((ce.ext_m_event_cont_cd=charge_product_cd) OR (ce.ext_m_event_cont_cd=poolfee_cd)) ))))
   JOIN (p
   WHERE p.product_id=t_pe.product_id
    AND p.active_ind=1
    AND (((request->cur_owner_area_cd > 0.0)
    AND (request->cur_owner_area_cd=p.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
    AND (((request->cur_inv_area_cd > 0.0)
    AND (request->cur_inv_area_cd=p.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
   JOIN (pd
   WHERE pd.product_event_id=d_pe.product_event_id)
   JOIN (bp
   WHERE (bp.product_id= Outerjoin(t_pe.product_id)) )
   JOIN (d
   WHERE (d.product_id= Outerjoin(t_pe.product_id)) )
   JOIN (c_pe
   WHERE (c_pe.product_event_id= Outerjoin(d_pe.related_product_event_id))
    AND (c_pe.event_type_cd= Outerjoin(crossmatch_event_type_cd)) )
   JOIN (aor
   WHERE (aor.order_id= Outerjoin(c_pe.order_id))
    AND (aor.primary_flag= Outerjoin(0)) )
  ORDER BY d_pe.product_event_id
  HEAD d_pe.product_event_id
   event_cnt += 1
   IF (size(reply->results,5) <= event_cnt)
    stat = alterlist(reply->results,(event_cnt+ 10))
   ENDIF
   reply->results[event_cnt].batch_transfuse_ind = "Y", reply->results[event_cnt].product_event_id =
   t_pe.product_event_id, reply->results[event_cnt].pd_product_event_id = d_pe.product_event_id,
   reply->results[event_cnt].product_type =
   IF (bp.product_id > 0) "B"
   ELSE "D"
   ENDIF
   , reply->results[event_cnt].product_cd = p.product_cd, reply->results[event_cnt].product_id = p
   .product_id,
   reply->ltransfused_product_cnt += 1
   IF (bp.product_id > 0)
    reply->results[event_cnt].product_nbr = concat(trim(bp.supplier_prefix),trim(p.product_nbr)," ",
     trim(p.product_sub_nbr))
   ELSE
    reply->results[event_cnt].product_nbr = concat(trim(p.product_nbr)," ",trim(p.product_sub_nbr))
   ENDIF
   reply->results[event_cnt].serial_number = p.serial_number_txt, reply->results[event_cnt].person_id
    = d_pe.person_id, reply->results[event_cnt].encounter_id = d_pe.encntr_id,
   reply->results[event_cnt].event_prsnl_id = t_pe.event_prsnl_id, reply->results[event_cnt].
   transfused_iu =
   IF (d.product_id > 0) pd.cur_dispense_intl_units
   ELSE 0
   ENDIF
   , reply->results[event_cnt].transfused_qty =
   IF (d.product_id > 0) pd.cur_dispense_qty
   ELSE 0
   ENDIF
   ,
   reply->results[event_cnt].transfused_dt_tm = t_pe.event_dt_tm, reply->results[event_cnt].
   transfused_tz = validate(t_pe.event_tz,0), reply->results[event_cnt].order_id = c_pe.order_id,
   reply->results[event_cnt].accession = accession, reply->results[event_cnt].dispense_loc_cd = pd
   .dispense_to_locn_cd, reply->results[event_cnt].status = "S"
  FOOT REPORT
   stat = alterlist(reply->results,event_cnt)
  WITH nocounter
 ;end select
 IF (event_cnt > 1)
  SET dummy_seq = event_cnt
 ENDIF
 EXECUTE cpm_create_file_name_logical "bbt_trsf_no_chrg", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  name = p.name_full_formatted
  FROM (dummyt d1  WITH seq = dummy_seq),
   (dummyt d2  WITH seq = 1),
   person p,
   encntr_alias ea
  PLAN (d1)
   JOIN (p
   WHERE (p.person_id=reply->results[d1.seq].person_id))
   JOIN (d2)
   JOIN (ea
   WHERE (ea.encntr_id=reply->results[d1.seq].encounter_id)
    AND ea.active_ind=1
    AND ea.encntr_alias_type_cd=mrn_cd
    AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
  ORDER BY name, p.person_id
  HEAD REPORT
   beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm), mrn =
   fillstring(25," "),
   dispense_loc = fillstring(20," "), product_type_disp = fillstring(20," "), line = fillstring(125,
    "-")
  HEAD PAGE
   row 0,
   CALL center(trim(captions->rpt_name,3),1,125), col 104,
   captions->time, col 118, curtime"@TIMENOSECONDS;;M",
   row + 1, col 104, captions->as_of_date,
   col 118, curdate"@DATECONDENSED;;d", inc_i18nhandle = 0,
   inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
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
   row + 1, col 1, captions->bb_owner,
   col 19, owner_disp
   IF (update_mode_ind=1)
    CALL center(captions->report_update,1,125)
   ELSE
    CALL center(captions->report_only,1,125)
   ENDIF
   row + 1, col 1, captions->inventory_area,
   col 19, inventory_disp, row + 2,
   col 32, captions->beg_date, col 56,
   beg_dt_tm"@DATECONDENSED;;d", col 64, beg_dt_tm"@TIMENOSECONDS;;M",
   col 74, captions->end_date, col 92,
   end_dt_tm"@DATECONDENSED;;d", col 100, end_dt_tm"@TIMENOSECONDS;;M",
   row + 2, col 1, captions->name,
   col 33, captions->product_number, col 75,
   captions->accession_number, col 60, captions->transfused,
   row + 1, col 1, captions->mrn,
   col 33, captions->product_type, col 60,
   captions->dttm, col 75, captions->serial_number,
   col 97, captions->dispense_loc, row + 1,
   col 1, "------------------------------", col 33,
   "-------------------------", col 60, "-------------",
   col 75, "--------------------", col 97,
   "--------------------", row + 1
  DETAIL
   IF ((reply->results[d1.seq].product_id > 0))
    IF (row > 58)
     BREAK
    ENDIF
    IF (row >= 58
     AND (reply->results[d1.seq].serial_number != null))
     BREAK
    ENDIF
    col 1, name, col 33,
    reply->results[d1.seq].product_nbr, col 60, reply->results[d1.seq].transfused_dt_tm
    "@DATECONDENSED;;d"
    IF ((reply->results[d1.seq].order_id > 0.0))
     col 75, reply->results[d1.seq].accession
    ENDIF
    IF ((reply->results[d1.seq].dispense_loc_cd > 0.0))
     dispense_loc = uar_get_code_display(reply->results[d1.seq].dispense_loc_cd), col 97,
     dispense_loc
    ENDIF
    row + 1
    IF (ea.encntr_alias_id > 0)
     mrn = cnvtalias(ea.alias,ea.alias_pool_cd), col 1, mrn
    ENDIF
    IF ((reply->results[d1.seq].product_cd > 0.0))
     product_type_disp = substring(1,20,uar_get_code_display(reply->results[d1.seq].product_cd))
    ENDIF
    col 33, product_type_disp
    IF ((reply->results[d1.seq].serial_number != null))
     col 75, reply->results[d1.seq].serial_number
    ENDIF
    col 60, reply->results[d1.seq].transfused_dt_tm"@TIMENOSECONDS;;M", row + 2
   ENDIF
  FOOT PAGE
   row 59, col 1, line,
   row + 1, col 1, captions->report_id,
   col 60, captions->page_no, col 67,
   curpage"###", col 104, captions->printed,
   col 113, curdate"@DATECONDENSED;;d", col 121,
   curtime"@TIMENOSECONDS;;M", row + 1
  FOOT REPORT
   row 62,
   CALL center(captions->end_of_report,1,125), select_ok_ind = 1
  WITH nocounter, maxrow = 63, nullreport,
   outerjoin = d2
 ;end select
 IF ((reply->status_data.status="F"))
  SET select_ok_ind = 0
 ENDIF
 SET rpt_cnt += 1
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (trim(request->batch_selection) > " "
  AND trim(request->output_dist) > "")
  SET spool value(reply->rpt_list[rpt_cnt].rpt_filename) value(trim(request->output_dist))
 ENDIF
 IF (update_mode_ind=0)
  SET event_cnt = 0
  SET reply->ltransfused_product_cnt = 0
  SET stat = alterlist(reply->results,event_cnt)
 ENDIF
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
#exit_script
 FREE SET captions
 DECLARE getcodevalues(null) = i2
 SUBROUTINE getcodevalues(null)
   DECLARE code_cnt = i4 WITH protected, noconstant(1)
   SET stat = uar_get_meaning_by_codeset(1610,nullterm("7"),code_cnt,transfuse_event_type_cd)
   IF (transfuse_event_type_cd=0.0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_transf_not_charged.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Unable to retrieve the code_value for the cdf_meaning 7 in code_set 1610."
    SET reply->status = "F"
    RETURN(0)
   ENDIF
   SET stat = uar_get_meaning_by_codeset(1610,nullterm("4"),code_cnt,dispense_event_type_cd)
   IF (dispense_event_type_cd=0.0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_transf_not_charged.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Unable to retrieve the code_value for the cdf_meaning 4 in code_set 1610."
    SET reply->status = "F"
    RETURN(0)
   ENDIF
   SET stat = uar_get_meaning_by_codeset(1610,nullterm("3"),code_cnt,crossmatch_event_type_cd)
   IF (crossmatch_event_type_cd=0.0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_transf_not_charged.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Unable to retrieve the code_value for the cdf_meaning 3 in code_set 1610."
    SET reply->status = "F"
    RETURN(0)
   ENDIF
   SET stat = uar_get_meaning_by_codeset(319,nullterm("MRN"),code_cnt,mrn_cd)
   IF (mrn_cd=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_transf_not_charged.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Unable to retrieve the code_value for the cdf_meaning mrn in code_set 319."
    SET reply->status = "F"
    RETURN(0)
   ENDIF
   SET stat = uar_get_meaning_by_codeset(13016,nullterm("BBPRODUCT"),code_cnt,charge_product_cd)
   IF (charge_product_cd=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_transf_not_charged.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Unable to retrieve the code_value for the cdf_meaning BBPRODUCT in code_set 13016."
    SET reply->status = "F"
    RETURN(0)
   ENDIF
   SET stat = uar_get_meaning_by_codeset(13016,nullterm("BBPOOLFEE"),code_cnt,poolfee_cd)
   IF (poolfee_cd=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bbt_rpt_transf_not_charged.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Unable to retrieve the code_value for the cdf_meaning BBPOOLFEE in code_set 13016."
    SET reply->status = "F"
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE setcaptions(null) = i2
 SUBROUTINE setcaptions(null)
   SET captions->rpt_name = uar_i18ngetmessage(i18nhandle,"rpt_name",
    "T R A N S F U S E D   U N I T S   N O T   C H A R G E D   R E P O R T")
   SET captions->time = uar_i18ngetmessage(i18nhandle,"time","Time:")
   SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","As of Date:")
   SET captions->beg_date = uar_i18ngetmessage(i18nhandle,"beg_date","Beginning Date:")
   SET captions->end_date = uar_i18ngetmessage(i18nhandle,"end_date","Ending Date:")
   SET captions->not_on_file = uar_i18ngetmessage(i18nhandle,"not_on_file","<Not on File>")
   SET captions->report_update = uar_i18ngetmessage(i18nhandle,"report_update","(Report/Update)")
   SET captions->report_only = uar_i18ngetmessage(i18nhandle,"report_only","Report Only")
   SET captions->bb_owner = uar_i18ngetmessage(i18nhandle,"bb_owner","Blood Bank Owner: ")
   SET captions->inventory_area = uar_i18ngetmessage(i18nhandle,"inventory_area","Inventory Area: ")
   SET captions->all = uar_i18ngetmessage(i18nhandle,"all","(All)")
   SET captions->report_id = uar_i18ngetmessage(i18nhandle,"report_id","Report ID: BBT_TRSF_NO_CHRG")
   SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","Page:")
   SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
   SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
    "* * * End of Report * * *")
   SET captions->name = uar_i18ngetmessage(i18nhandle,"name","Patient Name/")
   SET captions->mrn = uar_i18ngetmessage(i18nhandle,"med_rec_num","Medical Record Number")
   SET captions->transfused = uar_i18ngetmessage(i18nhandle,"transfused","Transfused")
   SET captions->dttm = uar_i18ngetmessage(i18nhandle,"dt_tm","Date/Time")
   SET captions->product_number = uar_i18ngetmessage(i18nhandle,"prod_nbr","Product Number/")
   SET captions->product_type = uar_i18ngetmessage(i18nhandle,"prod_type","Product Type")
   SET captions->accession_number = uar_i18ngetmessage(i18nhandle,"accession_nbr","Accession Number/"
    )
   SET captions->dispense_loc = uar_i18ngetmessage(i18nhandle,"dispense_loc","Dispense Location")
   SET captions->serial_number = uar_i18ngetmessage(i18nhandle,"serial_number","Serial Number")
   RETURN(1)
 END ;Subroutine
 DECLARE setopsrequest(null) = i2
 SUBROUTINE setopsrequest(null)
   DECLARE temp_string = vc WITH protected, noconstant(" ")
   DECLARE mode_selection = vc WITH protected, noconstant(" ")
   SET temp_string = trim(request->batch_selection)
   IF (trim(request->batch_selection) > " ")
    SET begday = request->ops_date
    SET endday = request->ops_date
    CALL check_opt_date_passed("bbt_rpt_transf_not_charged")
    IF ((reply->status_data.status != "F"))
     SET request->beg_dt_tm = begday
     SET request->end_dt_tm = endday
    ENDIF
    CALL check_owner_cd("bbt_rpt_transf_not_charged")
    CALL check_inventory_cd("bbt_rpt_transf_not_charged")
    CALL check_location_cd("bbt_rpt_transf_not_charged")
    CALL check_mode_opt("bbt_rpt_transf_not_charged")
    IF (trim(mode_selection)="UPDATE")
     SET update_mode_ind = 1
    ENDIF
   ENDIF
   IF ((reply->status_data.status="F"))
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
END GO
