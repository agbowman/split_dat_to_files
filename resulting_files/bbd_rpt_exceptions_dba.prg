CREATE PROGRAM bbd_rpt_exceptions:dba
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
 DECLARE check_facility_cd(script_name=vc) = null
 DECLARE check_exception_type_cd(script_name=vc) = null
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
      SET ddmmyy_flag = (ddmmyy_flag+ 1)
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
       SET ddmmyy_flag = (ddmmyy_flag+ 1)
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
       SET ddmmyy_flag = (ddmmyy_flag+ 1)
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
 SUBROUTINE check_facility_cd(script_name)
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
 SUBROUTINE check_exception_type_cd(script_name)
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
 RECORD except(
   1 exceptions[*]
     2 exception_id = f8
     2 exception_type_cd = f8
     2 exception_dt_tm = dq8
     2 override_reason_disp = vc
     2 person_id = f8
     2 tech_username = vc
     2 donor_contact_id = f8
     2 donation_ident_old = vc
     2 donation_ident_curr = vc
     2 don_reg_result_dt_tm = dq8
     2 eligibility_type_cd = f8
     2 eligibility_type_disp = vc
     2 defer_until_dt_tm = dq8
     2 deferred_dt_tm = dq8
     2 procedure_disp = vc
     2 perform_result_id = f8
     2 result_id = f8
     2 result = vc
     2 product_nbr = vc
     2 product_disp = vc
     2 product_abo_disp = vc
     2 product_rh_disp = vc
     2 person_abo_disp = vc
     2 person_rh_disp = vc
     2 from_abo_disp = vc
     2 from_rh_disp = vc
     2 to_abo_disp = vc
     2 to_rh_disp = vc
     2 ineligible_until_dt_tm = dq8
     2 facility_cd = f8
     2 owner_cd = f8
     2 inventory_cd = f8
     2 donor
       3 name_full_formatted = vc
       3 birth_dt_tm = dq8
       3 abo_disp = vc
       3 rh_disp = vc
       3 aliases[*]
         4 alias_type_cd = f8
         4 alias = vc
     2 recipient
       3 name_full_formatted = vc
       3 mrn = vc
       3 abo_disp = vc
       3 rh_disp = vc
 )
 RECORD captions(
   1 inc_title = vc
   1 inc_time = vc
   1 inc_as_of_date = vc
   1 inc_blood_bank_owner = vc
   1 inc_inventory_area = vc
   1 inc_beg_dt_tm = vc
   1 inc_end_dt_tm = vc
   1 inc_report_id = vc
   1 inc_page = vc
   1 inc_printed = vc
   1 end_of_report = vc
   1 sdonloc = vc
   1 sdondir = vc
   1 sregdir = vc
   1 sdoninelig = vc
   1 sreginelig = vc
   1 sregperm = vc
   1 sregtemp = vc
   1 soverinterp = vc
   1 sdonelig = vc
   1 sdonperm = vc
   1 sdontemp = vc
   1 sdnrgtchg = vc
   1 sdnrgtnochg = vc
   1 sregelig = vc
   1 sdonnbrupd = vc
   1 saborh = vc
   1 sall = vc
   1 scur = vc
   1 sdefer = vc
   1 sdeferd = vc
   1 sdeferl = vc
   1 sdemog = vc
   1 sdobssn = vc
   1 sdonation = vc
   1 sdonnbr = vc
   1 sdonor = vc
   1 sdonorid = vc
   1 sdt = vc
   1 sdttm = vc
   1 sinelig = vc
   1 smrn = vc
   1 sname = vc
   1 snodata = vc
   1 soverreas = vc
   1 sprev = vc
   1 sprocedure = vc
   1 sprodnum = vc
   1 sprod = vc
   1 srecipient = vc
   1 sreg = vc
   1 sresult = vc
   1 sresultd = vc
   1 stech = vc
   1 stype = vc
   1 suntil = vc
 )
 SET captions->inc_title = uar_i18ngetmessage(i18nhandle,"inc_title",
  "B L O O D   B A N K   E X C E P T I O N   R E P O R T")
 SET captions->inc_time = uar_i18ngetmessage(i18nhandle,"inc_time","Time:")
 SET captions->inc_as_of_date = uar_i18ngetmessage(i18nhandle,"inc_as_of_date","As of Date:")
 SET captions->inc_blood_bank_owner = uar_i18ngetmessage(i18nhandle,"inc_blood_bank_owner",
  "Blood Bank Owner: ")
 SET captions->inc_inventory_area = uar_i18ngetmessage(i18nhandle,"inc_inventory_area",
  "Inventory Area: ")
 SET captions->inc_beg_dt_tm = uar_i18ngetmessage(i18nhandle,"inc_beg_dt_tm","Beginnning Date/Time:")
 SET captions->inc_end_dt_tm = uar_i18ngetmessage(i18nhandle,"inc_end_dt_tm","Ending Date/Time:")
 SET captions->inc_page = uar_i18ngetmessage(i18nhandle,"inc_page","Page:")
 SET captions->inc_printed = uar_i18ngetmessage(i18nhandle,"inc_printed","Printed:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->sdonloc = uar_i18ngetmessage(i18nhandle,"sDonLoc","Donation Location")
 SET captions->sdondir = uar_i18ngetmessage(i18nhandle,"sDonDir",
  "Directed Donation Recorded Where Product/Recipient are Incompatible")
 SET captions->sregdir = uar_i18ngetmessage(i18nhandle,"sRegDir",
  "Registration Recorded for Directed Donation Where Product/Recipient are Incompatible")
 SET captions->sdoninelig = uar_i18ngetmessage(i18nhandle,"sDonInelig",
  "Donation Recorded for Date Ineligible Donor")
 SET captions->sreginelig = uar_i18ngetmessage(i18nhandle,"sRegInelig",
  "Registration Recorded for Date Ineligible Donor")
 SET captions->sregperm = uar_i18ngetmessage(i18nhandle,"sRegPerm",
  "Registration Recorded for Permanently Deferred Donor")
 SET captions->sregtemp = uar_i18ngetmessage(i18nhandle,"sRegTemp",
  "Registration Recorded for Temporarily Deferred Donor")
 SET captions->soverinterp = uar_i18ngetmessage(i18nhandle,"sOverInterp",
  "Donor Exception System Interpretation Override")
 SET captions->sdonelig = uar_i18ngetmessage(i18nhandle,"sDonElig",
  "Donation Recorded for Deferred Donor other than an Autologus Donation or Reinstatement")
 SET captions->sregelig = uar_i18ngetmessage(i18nhandle,"sRegElig",
  "Registration Recorded for Deferred Donor other than an Autologus Donation or Reinstatement")
 SET captions->sdonperm = uar_i18ngetmessage(i18nhandle,"sDonPerm",
  "Donation Recorded for Permanently Deferred Donor")
 SET captions->sdontemp = uar_i18ngetmessage(i18nhandle,"sDonTemp",
  "Donation Recorded for Temporarily Deferred Donor")
 SET captions->sdnrgtchg = uar_i18ngetmessage(i18nhandle,"sDnrGTChg","Donor Group/Type Changed")
 SET captions->sdnrgtnochg = uar_i18ngetmessage(i18nhandle,"sDnrGTNoChg",
  "Donor Group/Type Not Changed")
 SET captions->sdonnbrupd = uar_i18ngetmessage(i18nhandle,"sDonNbrUpd","Donation Number Updated")
 SET captions->snodata = uar_i18ngetmessage(i18nhandle,"sNoData","(none)")
 SET captions->saborh = uar_i18ngetmessage(i18nhandle,"sABORh","ABO/Rh")
 SET captions->sall = uar_i18ngetmessage(i18nhandle,"sABORh","All")
 SET captions->scur = uar_i18ngetmessage(i18nhandle,"sCur","Current")
 SET captions->sdefer = uar_i18ngetmessage(i18nhandle,"sDefer","Defer")
 SET captions->sdeferd = uar_i18ngetmessage(i18nhandle,"sDeferd","Deferred")
 SET captions->sdeferl = uar_i18ngetmessage(i18nhandle,"sDeferl","Deferral")
 SET captions->sdemog = uar_i18ngetmessage(i18nhandle,"sDemog","Demographics")
 SET captions->sdobssn = uar_i18ngetmessage(i18nhandle,"sDOBSSN","DOB/SSN")
 SET captions->sdonation = uar_i18ngetmessage(i18nhandle,"sDonation","Donation")
 SET captions->sdonnbr = uar_i18ngetmessage(i18nhandle,"sDonNbr","Donation Number")
 SET captions->sdonor = uar_i18ngetmessage(i18nhandle,"sDonor","Donor")
 SET captions->sdonorid = uar_i18ngetmessage(i18nhandle,"sDonorId","Donor ID")
 SET captions->sdt = uar_i18ngetmessage(i18nhandle,"sDt","Date")
 SET captions->sdttm = uar_i18ngetmessage(i18nhandle,"sDtTm","Date/Time")
 SET captions->sinelig = uar_i18ngetmessage(i18nhandle,"sInelig","Ineligible")
 SET captions->smrn = uar_i18ngetmessage(i18nhandle,"sMRN","MRN")
 SET captions->sname = uar_i18ngetmessage(i18nhandle,"sName","Name")
 SET captions->soverreas = uar_i18ngetmessage(i18nhandle,"sOverReas","Override Reason")
 SET captions->sprev = uar_i18ngetmessage(i18nhandle,"sPrev","Previous")
 SET captions->sprocedure = uar_i18ngetmessage(i18nhandle,"sProcedure","Procedure")
 SET captions->sprodnum = uar_i18ngetmessage(i18nhandle,"sProdNum","Product Number")
 SET captions->sprod = uar_i18ngetmessage(i18nhandle,"sProd","Product")
 SET captions->srecipient = uar_i18ngetmessage(i18nhandle,"sRecipient","Recipient")
 SET captions->sreg = uar_i18ngetmessage(i18nhandle,"sReg","Registration")
 SET captions->sresult = uar_i18ngetmessage(i18nhandle,"sResult","Result")
 SET captions->sresultd = uar_i18ngetmessage(i18nhandle,"sResultd","Resulted")
 SET captions->stech = uar_i18ngetmessage(i18nhandle,"sTech","Tech")
 SET captions->stype = uar_i18ngetmessage(i18nhandle,"sType","Type")
 SET captions->suntil = uar_i18ngetmessage(i18nhandle,"sUntil","Until")
 DECLARE dondirnomatc = f8 WITH protect, noconstant(0.0)
 DECLARE regdirnomatc = f8 WITH protect, noconstant(0.0)
 DECLARE doninelig = f8 WITH protect, noconstant(0.0)
 DECLARE reginelig = f8 WITH protect, noconstant(0.0)
 DECLARE regperm = f8 WITH protect, noconstant(0.0)
 DECLARE regtemp = f8 WITH protect, noconstant(0.0)
 DECLARE overinterp = f8 WITH protect, noconstant(0.0)
 DECLARE doneligrein = f8 WITH protect, noconstant(0.0)
 DECLARE donperm = f8 WITH protect, noconstant(0.0)
 DECLARE dontemp = f8 WITH protect, noconstant(0.0)
 DECLARE ungtchg = f8 WITH protect, noconstant(0.0)
 DECLARE ungtnochg = f8 WITH protect, noconstant(0.0)
 DECLARE regeligrein = f8 WITH protect, noconstant(0.0)
 DECLARE doninterview = f8 WITH protect, noconstant(0.0)
 DECLARE interview = f8 WITH protect, noconstant(0.0)
 DECLARE nlstcnt = i4 WITH protect, noconstant(0)
 DECLARE nalicnt = i4 WITH protect, noconstant(0)
 DECLARE getopsparam(sparam=vc) = vc WITH persist
 DECLARE assignstring(sstring=vc,nmaxlen=i4) = vc WITH persist
 DECLARE bopscall = i2 WITH protect, noconstant(0)
 DECLARE nrptcnt = i4 WITH protect, noconstant(0)
 DECLARE n = i4 WITH protect, noconstant(0)
 DECLARE x = i4 WITH protect, noconstant(0)
 DECLARE sret = vc WITH protect, noconstant(" ")
 DECLARE sdonloc = vc WITH protect, noconstant(" ")
 DECLARE ddonoridcd = f8 WITH protect, noconstant(0.0)
 DECLARE dssncd = f8 WITH protect, noconstant(0.0)
 DECLARE dmrncd = f8 WITH protect, noconstant(0.0)
 DECLARE cur_owner_area_disp = vc WITH protect, noconstant(" ")
 DECLARE cur_inv_area_disp = vc WITH protect, noconstant(" ")
 DECLARE p_alias_cs = i4 WITH protect, constant(4)
 DECLARE exception_cs = i4 WITH protect, constant(14072)
 DECLARE contact_type_cs = i4 WITH protect, constant(14220)
 SUBROUTINE getopsparam(sparam)
   DECLARE stemp = vc WITH protect, noconstant(" ")
   DECLARE nposbegin = i4 WITH protect, noconstant(0)
   DECLARE nposend = i4 WITH protect, noconstant(0)
   SET stemp = cnvtupper(trim(request->batch_selection))
   SET sparam = cnvtupper(sparam)
   SET nposbegin = findstring(concat(sparam,"["),stemp,1,0)
   IF (nposbegin > 0)
    SET nposbegin = ((nposbegin+ textlen(sparam))+ 1)
    SET nposend = findstring("]",stemp,nposbegin,0)
    IF (nposend > 0)
     RETURN(substring(nposbegin,(nposend - nposbegin),stemp))
    ENDIF
   ENDIF
   RETURN("")
 END ;Subroutine
 SUBROUTINE assignstring(sstring,nmaxlen)
   IF (textlen(trim(sstring))=0)
    SET sstring = captions->snodata
   ENDIF
   IF (textlen(sstring) <= nmaxlen)
    RETURN(sstring)
   ENDIF
   RETURN(substring(1,nmaxlen,sstring))
 END ;Subroutine
 IF (trim(request->batch_selection) > " ")
  SET begday = request->ops_date
  SET endday = request->ops_date
  SET temp_string = cnvtupper(trim(request->batch_selection))
  SET bopscall = 1
  CALL check_opt_date_passed("bbd_rpt_exceptions")
  IF ((reply->status_data.status != "F"))
   SET request->beg_dt_tm = begday
   SET request->end_dt_tm = endday
  ENDIF
  SET request->printer_name = trim(request->output_dist)
  CALL check_location_cd("bbd_rpt_exceptions")
  CALL check_inventory_cd("bbd_rpt_exceptions")
  CALL check_owner_cd("bbd_rpt_exceptions")
  SET sret = getopsparam("EXCEPT")
  IF (textlen(sret)=0)
   SET sret = "0.0"
  ENDIF
  SET request->exception_type_cd = cnvtreal(sret)
  SET sret = getopsparam("DLOC")
  IF (textlen(sret)=0)
   SET sret = "0.0"
  ENDIF
  SET request->donation_location_cd = cnvtreal(sret)
  SET sret = trim(getopsparam("NULLRPT"))
  SET request->null_report_ind = evaluate(sret,"Y",1,0)
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
 SET cur_owner_area_disp = evaluate(request->cur_owner_area_cd,0.0,captions->sall,
  uar_get_code_display(request->cur_owner_area_cd))
 SET cur_inv_area_disp = evaluate(request->cur_inv_area_cd,0.0,captions->sall,uar_get_code_display(
   request->cur_inv_area_cd))
 SET sdonloc = evaluate(request->donation_location_cd,0.0,captions->sall,uar_get_code_display(request
   ->donation_location_cd))
 SET sdonloc = concat(captions->sdonloc,": ",sdonloc)
 SET ddonoridcd = uar_get_code_by("MEANING",p_alias_cs,"DONORID")
 SET dssncd = uar_get_code_by("MEANING",p_alias_cs,"SSN")
 SET dmrncd = uar_get_code_by("MEANING",p_alias_cs,"MRN")
 SET dondirnomatc = uar_get_code_by("MEANING",exception_cs,"DONDIRNOMATC")
 SET regdirnomatc = uar_get_code_by("MEANING",exception_cs,"REGDIRNOMATC")
 SET doninelig = uar_get_code_by("MEANING",exception_cs,"DONINELIG")
 SET reginelig = uar_get_code_by("MEANING",exception_cs,"REGINELIG")
 SET regperm = uar_get_code_by("MEANING",exception_cs,"REGPERM")
 SET regtemp = uar_get_code_by("MEANING",exception_cs,"REGTEMP")
 SET overinterp = uar_get_code_by("MEANING",exception_cs,"OVERINTERP")
 SET doneligrein = uar_get_code_by("MEANING",exception_cs,"DONELIGREIN")
 SET donperm = uar_get_code_by("MEANING",exception_cs,"DONPERM")
 SET dontemp = uar_get_code_by("MEANING",exception_cs,"DONTEMP")
 SET ungtchg = uar_get_code_by("MEANING",exception_cs,"UNGTCHG")
 SET ungtnochg = uar_get_code_by("MEANING",exception_cs,"UNGTNOCHG")
 SET regeligrein = uar_get_code_by("MEANING",exception_cs,"REGELIGREIN")
 SET doninterview = uar_get_code_by("MEANING",exception_cs,"DONINTERVIEW")
 SET interview = uar_get_code_by("MEANING",contact_type_cs,"INTERVIEW")
 IF ((dondirnomatc=- (2.0)))
  SET sret = "DONDIRNOMATC"
 ELSEIF ((regdirnomatc=- (2.0)))
  SET sret = "REGDIRNOMATC"
 ELSEIF ((doninelig=- (2.0)))
  SET sret = "DONINELIG"
 ELSEIF ((reginelig=- (2.0)))
  SET sret = "REGINELIG"
 ELSEIF ((regperm=- (2.0)))
  SET sret = "REGPERM"
 ELSEIF ((regtemp=- (2.0)))
  SET sret = "REGTEMP"
 ELSEIF ((overinterp=- (2.0)))
  SET sret = "OVERINTERP"
 ELSEIF ((doneligrein=- (2.0)))
  SET sret = "DONELIGREIN"
 ELSEIF ((donperm=- (2.0)))
  SET sret = "DONPERM"
 ELSEIF ((dontemp=- (2.0)))
  SET sret = "DONTEMP"
 ELSEIF ((ungtchg=- (2.0)))
  SET sret = "UNGTCHG"
 ELSEIF ((ungtnochg=- (2.0)))
  SET sret = "UNGTNOCHG"
 ELSEIF ((regeligrein=- (2.0)))
  SET sret = "REGELIGREIN"
 ELSEIF ((doninterview=- (2.0)))
  SET sret = "DONINTERVIEW"
 ELSEIF ((interview=- (2.0)))
  SET sret = "INTERVIEW"
 ELSE
  SET sret = " "
 ENDIF
 IF (textlen(trim(sret)) > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "Exception Reporting"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(
   "Code value not found for cdf_meaning: ",sret)
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_rpt_exceptions"
  GO TO exit_script
 ENDIF
 SELECT
  IF ((request->exception_type_cd > 0))
   PLAN (bbe
    WHERE (bbe.exception_type_cd=request->exception_type_cd)
     AND bbe.exception_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
     end_dt_tm)
     AND bbe.person_id > 0)
    JOIN (pd
    WHERE pd.person_id=bbe.person_id)
    JOIN (p
    WHERE p.person_id=pd.person_id)
    JOIN (pr
    WHERE pr.person_id=bbe.updt_id)
    JOIN (d
    WHERE d.seq=1)
    JOIN (pa
    WHERE pa.person_id=p.person_id
     AND pa.person_alias_type_cd IN (ddonoridcd, dssncd))
  ELSE
  ENDIF
  INTO "nl:"
  pa_exists = evaluate(nullind(pa.person_id),0,1,0)
  FROM bb_exception bbe,
   person_donor pd,
   person p,
   prsnl pr,
   (dummyt d  WITH seq = 1),
   person_alias pa
  PLAN (bbe
   WHERE bbe.exception_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
    end_dt_tm)
    AND bbe.person_id > 0)
   JOIN (pd
   WHERE pd.person_id=bbe.person_id)
   JOIN (p
   WHERE p.person_id=pd.person_id)
   JOIN (pr
   WHERE pr.person_id=bbe.updt_id)
   JOIN (d
   WHERE d.seq=1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd IN (ddonoridcd, dssncd))
  ORDER BY bbe.exception_id, pa.person_alias_id
  HEAD bbe.exception_id
   nlstcnt = (nlstcnt+ 1), nalicnt = 0
   IF (nlstcnt > size(except->exceptions,5))
    stat = alterlist(except->exceptions,(nlstcnt+ 9))
   ENDIF
   except->exceptions[nlstcnt].exception_id = bbe.exception_id, except->exceptions[nlstcnt].
   exception_type_cd = bbe.exception_type_cd, except->exceptions[nlstcnt].exception_dt_tm =
   cnvtdatetime(bbe.exception_dt_tm),
   except->exceptions[nlstcnt].override_reason_disp = uar_get_code_display(bbe.override_reason_cd),
   except->exceptions[nlstcnt].person_id = bbe.person_id, except->exceptions[nlstcnt].tech_username
    = pr.username,
   except->exceptions[nlstcnt].donor_contact_id = bbe.donor_contact_id, except->exceptions[nlstcnt].
   eligibility_type_cd = pd.eligibility_type_cd, except->exceptions[nlstcnt].eligibility_type_disp =
   uar_get_code_display(pd.eligibility_type_cd),
   except->exceptions[nlstcnt].defer_until_dt_tm = cnvtdatetime(pd.defer_until_dt_tm), except->
   exceptions[nlstcnt].procedure_disp = uar_get_code_display(bbe.procedure_cd), except->exceptions[
   nlstcnt].perform_result_id = bbe.perform_result_id,
   except->exceptions[nlstcnt].result_id = bbe.result_id, except->exceptions[nlstcnt].donor.
   name_full_formatted = p.name_full_formatted, except->exceptions[nlstcnt].donor.birth_dt_tm =
   cnvtdatetime(p.birth_dt_tm),
   except->exceptions[nlstcnt].product_abo_disp = uar_get_code_display(bbe.product_abo_cd), except->
   exceptions[nlstcnt].product_rh_disp = uar_get_code_display(bbe.product_rh_cd), except->exceptions[
   nlstcnt].person_abo_disp = uar_get_code_display(bbe.person_abo_cd),
   except->exceptions[nlstcnt].person_rh_disp = uar_get_code_display(bbe.person_rh_cd), except->
   exceptions[nlstcnt].from_abo_disp = uar_get_code_display(bbe.from_abo_cd), except->exceptions[
   nlstcnt].from_rh_disp = uar_get_code_display(bbe.from_rh_cd),
   except->exceptions[nlstcnt].to_abo_disp = uar_get_code_display(bbe.to_abo_cd), except->exceptions[
   nlstcnt].to_rh_disp = uar_get_code_display(bbe.to_rh_cd), except->exceptions[nlstcnt].
   ineligible_until_dt_tm = cnvtdatetime(bbe.ineligible_until_dt_tm)
  HEAD pa.person_alias_id
   IF (pa_exists=1)
    nalicnt = (nalicnt+ 1), stat = alterlist(except->exceptions[nlstcnt].donor.aliases,nalicnt),
    except->exceptions[nlstcnt].donor.aliases[nalicnt].alias_type_cd = pa.person_alias_type_cd,
    except->exceptions[nlstcnt].donor.aliases[nalicnt].alias = trim(cnvtalias(pa.alias,pa
      .alias_pool_cd))
   ENDIF
  FOOT  bbe.exception_id
   row + 0
  FOOT  pa.person_alias_id
   row + 0
  WITH outerjoin(d), nocounter
 ;end select
 SET stat = alterlist(except->exceptions,nlstcnt)
 IF ((request->exception_type_cd IN (doninterview, donperm, dontemp, doninelig, dondirnomatc,
 doneligrein, regtemp, regperm, reginelig, regdirnomatc,
 regeligrein, 0.0)))
  SELECT INTO "nl:"
   bdr_exists = evaluate(nullind(bdr.contact_id),0,1,0), bp_exists = evaluate(nullind(bp.product_id),
    0,1,0)
   FROM bb_exception bbe,
    bbd_donor_contact bdc,
    encounter e,
    bbd_donation_results bdr,
    bbd_don_product_r bdpr,
    (dummyt d  WITH seq = 1),
    product pr,
    blood_product bp
   PLAN (bbe
    WHERE expand(n,1,nlstcnt,bbe.exception_id,except->exceptions[n].exception_id)
     AND bbe.exception_type_cd IN (doninterview, donperm, dontemp, doninelig, dondirnomatc,
    doneligrein, regperm, regtemp, reginelig, regdirnomatc,
    regeligrein))
    JOIN (bdc
    WHERE bdc.contact_id=bbe.donor_contact_id)
    JOIN (e
    WHERE e.encntr_id=bdc.encntr_id)
    JOIN (bdr
    WHERE bdr.contact_id=outerjoin(bdc.contact_id))
    JOIN (bdpr
    WHERE bdpr.donation_results_id=outerjoin(bdr.donation_result_id))
    JOIN (d
    WHERE d.seq=1)
    JOIN (pr
    WHERE pr.product_id=bdpr.product_id
     AND (((request->cur_inv_area_cd > 0)
     AND (pr.cur_inv_area_cd=request->cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0)))
     AND (((request->cur_owner_area_cd > 0)
     AND (pr.cur_owner_area_cd=request->cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0))) )
    JOIN (bp
    WHERE bp.product_id=pr.product_id)
   ORDER BY bbe.exception_id
   HEAD bbe.exception_id
    n = locateval(n,1,nlstcnt,bbe.exception_id,except->exceptions[n].exception_id), except->
    exceptions[n].don_reg_result_dt_tm = cnvtdatetime(bdc.contact_dt_tm), except->exceptions[n].
    facility_cd = e.loc_facility_cd
    IF (bdr_exists=1)
     except->exceptions[n].don_reg_result_dt_tm = cnvtdatetime(bdr.drawn_dt_tm)
    ENDIF
    IF (bp_exists=1)
     sret = build(bp.supplier_prefix,pr.product_nbr," ",pr.product_sub_nbr), except->exceptions[n].
     product_nbr = sret, except->exceptions[n].product_disp = uar_get_code_display(bp.product_cd),
     except->exceptions[n].owner_cd = pr.cur_owner_area_cd, except->exceptions[n].inventory_cd = pr
     .cur_inv_area_cd
    ENDIF
   DETAIL
    row + 0
   FOOT  bbe.exception_id
    row + 0
   WITH outerjoin(d), nocounter
  ;end select
 ENDIF
 IF ((request->exception_type_cd IN (dondirnomatc, doneligrein, regdirnomatc, regeligrein, 0.0)))
  SELECT INTO "nl:"
   pa_exists = evaluate(nullind(pa.person_id),0,1,0), da_exists = evaluate(nullind(da.person_id),0,1,
    0), pabo_exists = evaluate(nullind(pabo.person_id),0,1,0),
   p_exists = evaluate(nullind(p.person_id),0,1,0)
   FROM bb_exception bbe,
    bbd_donor_contact bdc,
    donor_aborh da,
    person_aborh pabo,
    encntr_person_reltn epr,
    person p,
    person_alias pa
   PLAN (bbe
    WHERE expand(n,1,nlstcnt,bbe.exception_id,except->exceptions[n].exception_id)
     AND bbe.exception_type_cd IN (dondirnomatc, doneligrein, regdirnomatc, regeligrein))
    JOIN (bdc
    WHERE bdc.contact_id=bbe.donor_contact_id)
    JOIN (da
    WHERE da.person_id=outerjoin(bdc.person_id)
     AND da.active_ind=outerjoin(1))
    JOIN (epr
    WHERE epr.encntr_id=outerjoin(bdc.encntr_id))
    JOIN (p
    WHERE p.person_id=outerjoin(epr.related_person_id))
    JOIN (pabo
    WHERE pabo.person_id=outerjoin(epr.related_person_id)
     AND pabo.active_ind=outerjoin(1))
    JOIN (pa
    WHERE pa.person_id=outerjoin(epr.related_person_id)
     AND pa.person_alias_type_cd=outerjoin(dmrncd))
   ORDER BY bbe.exception_id
   HEAD bbe.exception_id
    n = locateval(n,1,nlstcnt,bbe.exception_id,except->exceptions[n].exception_id)
    IF (da_exists=1)
     except->exceptions[n].donor.abo_disp = uar_get_code_display(da.abo_cd), except->exceptions[n].
     donor.rh_disp = uar_get_code_display(da.rh_cd)
    ENDIF
    IF (p_exists=1)
     except->exceptions[n].recipient.name_full_formatted = p.name_full_formatted
    ENDIF
    IF (pabo_exists=1)
     except->exceptions[n].recipient.abo_disp = uar_get_code_display(pabo.abo_cd), except->
     exceptions[n].recipient.rh_disp = uar_get_code_display(pabo.rh_cd)
    ENDIF
    IF (pa_exists=1)
     except->exceptions[n].recipient.mrn = trim(cnvtalias(pa.alias,pa.alias_pool_cd))
    ENDIF
   DETAIL
    row + 0
   FOOT  bbe.exception_id
    row + 0
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->exception_type_cd IN (ungtchg, ungtnochg, 0.0)))
  SELECT INTO "nl:"
   donor_abo_disp = uar_get_code_display(da.abo_cd), rh_disp = uar_get_code_display(da.rh_cd)
   FROM bb_exception bbe,
    donor_aborh da
   PLAN (bbe
    WHERE expand(n,1,nlstcnt,bbe.exception_id,except->exceptions[n].exception_id)
     AND bbe.exception_type_cd IN (ungtchg, ungtnochg))
    JOIN (da
    WHERE da.person_id=bbe.person_id
     AND da.active_ind=1)
   ORDER BY bbe.exception_id
   HEAD bbe.exception_id
    n = locateval(n,1,nlstcnt,bbe.exception_id,except->exceptions[n].exception_id), except->
    exceptions[n].donor.abo_disp = donor_abo_disp, except->exceptions[n].donor.rh_disp = rh_disp
   DETAIL
    row + 0
   FOOT  bbe.exception_id
    row + 0
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->exception_type_cd IN (overinterp, 0.0)))
  SELECT INTO "nl:"
   result_dt_tm = cnvtdatetime(pr.result_value_dt_tm), pr_result_dt_tm_exists = evaluate(nullind(pr
     .result_value_dt_tm),0,1,0), result_alpha = trim(pr.result_value_alpha)
   FROM bb_exception bbe,
    perform_result pr,
    result r,
    orders o,
    discrete_task_assay dta,
    product p,
    blood_product bp
   PLAN (bbe
    WHERE expand(n,1,nlstcnt,bbe.exception_id,except->exceptions[n].exception_id)
     AND bbe.exception_type_cd=overinterp)
    JOIN (pr
    WHERE pr.perform_result_id=bbe.perform_result_id
     AND pr.result_id=bbe.result_id)
    JOIN (r
    WHERE r.result_id=pr.result_id)
    JOIN (o
    WHERE o.order_id=r.order_id)
    JOIN (dta
    WHERE dta.task_assay_cd=r.task_assay_cd)
    JOIN (p
    WHERE p.product_id=o.product_id)
    JOIN (bp
    WHERE bp.product_id=p.product_id)
   ORDER BY bbe.exception_id
   HEAD bbe.exception_id
    n = locateval(n,1,nlstcnt,bbe.exception_id,except->exceptions[n].exception_id)
    IF (pr_result_dt_tm_exists=1)
     dt = format(result_dt_tm,"@SHORTDATE;;d"), tm = format(result_dt_tm,"@TIMENOSECONDS;;M"), except
     ->exceptions[n].result = concat(dt," ",tm)
    ELSEIF (textlen(result_alpha) > 0)
     except->exceptions[n].result = pr.result_value_alpha
    ELSE
     except->exceptions[n].result = cnvtstring(pr.result_value_numeric)
    ENDIF
    except->exceptions[n].product_nbr = build(bp.supplier_prefix,p.product_nbr," ",p.product_sub_nbr),
    except->exceptions[n].procedure_disp = uar_get_code_display(o.catalog_cd)
   DETAIL
    row + 0
   FOOT  bbe.exception_id
    row + 0
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->exception_type_cd IN (donperm, dontemp, regtemp, regperm, regeligrein,
 doneligrein, 0.0)))
  SELECT INTO "nl:"
   contact_dt_tm = cnvtdatetime(bdc.contact_dt_tm)
   FROM bb_exception bbe,
    bbd_donor_eligibility bde,
    bbd_donor_contact bdc
   PLAN (bbe
    WHERE expand(n,1,nlstcnt,bbe.exception_id,except->exceptions[n].exception_id)
     AND bbe.exception_type_cd IN (donperm, dontemp, regtemp, regperm, regeligrein,
    doneligrein))
    JOIN (bde
    WHERE bde.person_id=bbe.person_id
     AND expand(n,1,nlstcnt,bde.eligibility_type_cd,except->exceptions[n].eligibility_type_cd))
    JOIN (bdc
    WHERE bdc.contact_id=bde.contact_id)
   ORDER BY bbe.exception_id
   HEAD bbe.exception_id
    n = locateval(n,1,nlstcnt,bbe.exception_id,except->exceptions[n].exception_id), except->
    exceptions[n].deferred_dt_tm = contact_dt_tm
   DETAIL
    row + 0
   FOOT  bbe.exception_id
    row + 0
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->exception_type_cd IN (doninterview, 0.0)))
  SELECT INTO "nl:"
   FROM bb_exception bbe,
    bbd_donor_contact_r bcr,
    bbd_donor_contact bdc,
    bbd_other_contact boc
   PLAN (bbe
    WHERE expand(n,1,nlstcnt,bbe.exception_id,except->exceptions[n].exception_id)
     AND bbe.exception_type_cd IN (doninterview))
    JOIN (bcr
    WHERE bcr.related_contact_id=bbe.donor_contact_id)
    JOIN (bdc
    WHERE bdc.contact_id=bcr.contact_id
     AND bdc.contact_type_cd=interview)
    JOIN (boc
    WHERE boc.contact_id=bdc.contact_id)
   ORDER BY bbe.exception_id
   HEAD bbe.exception_id
    n = locateval(n,1,nlstcnt,bbe.exception_id,except->exceptions[n].exception_id), except->
    exceptions[n].donation_ident_old = bbe.donation_ident, except->exceptions[n].donation_ident_curr
     = boc.donation_ident
   DETAIL
    row + 0
   FOOT  bbe.exception_id
    row + 0
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->exception_type_cd IN (dondirnomatc, 0.0)))
  SET nrptcnt = (nrptcnt+ 1)
  EXECUTE cpm_create_file_name_logical "bbd_dondirnomatc_except", "txt", "x"
  SET stat = alterlist(reply->rpt_list,nrptcnt)
  SET reply->rpt_list[nrptcnt].rpt_filename = cpm_cfn_info->file_name_path
  SET captions->inc_report_id = cpm_cfn_info->file_name
  SELECT
   IF ((request->null_report_ind=1))
    WITH nullreport, maxrow = 61, compress,
     nolandscape, maxcol = 142
   ELSE
    WITH nocounter, maxrow = 61, compress,
     nolandscape, maxcol = 142
   ENDIF
   INTO cpm_cfn_info->file_name_path
   don_dt = cnvtdate(except->exceptions[d.seq].don_reg_result_dt_tm), b_dt_tm = except->exceptions[d
   .seq].donor.birth_dt_tm, owner_cd = except->exceptions[d.seq].owner_cd,
   inv_cd = except->exceptions[d.seq].inventory_cd, dloc_cd = except->exceptions[d.seq].facility_cd,
   seq_exists = evaluate(nullind(d.seq),0,1,0),
   name_sort_key = cnvtupper(except->exceptions[d.seq].donor.name_full_formatted)
   FROM (dummyt d  WITH seq = value(nlstcnt))
   WHERE (except->exceptions[d.seq].exception_type_cd=dondirnomatc)
    AND (((request->donation_location_cd=0)) OR ((request->donation_location_cd > 0)
    AND (request->donation_location_cd=except->exceptions[d.seq].facility_cd)))
    AND (((request->cur_owner_area_cd=0)) OR ((request->cur_owner_area_cd > 0)
    AND (request->cur_owner_area_cd=except->exceptions[d.seq].owner_cd)))
    AND (((request->cur_inv_area_cd=0)) OR ((request->cur_inv_area_cd > 0)
    AND (request->cur_inv_area_cd=except->exceptions[d.seq].inventory_cd)))
   ORDER BY owner_cd, inv_cd, dloc_cd,
    don_dt, name_sort_key
   HEAD REPORT
    row + 0, line1 = fillstring(22,"-"), line2 = fillstring(8,"-"),
    line3 = fillstring(26,"-"), line4 = fillstring(10,"-"), first_owner = 1,
    first_inv = 1, first_dloc = 1
   HEAD PAGE
    row 0
    IF (seq_exists=1)
     cur_owner_area_disp = uar_get_code_display(except->exceptions[d.seq].owner_cd),
     cur_inv_area_disp = uar_get_code_display(except->exceptions[d.seq].inventory_cd), sdonloc =
     uar_get_code_display(except->exceptions[d.seq].facility_cd),
     sdonloc = concat(captions->sdonloc,": ",sdonloc)
    ENDIF
    CALL center(captions->inc_title,1,125), col 107, captions->inc_time,
    col 121, curtime"@TIMENOSECONDS;;m", row + 1,
    col 107, captions->inc_as_of_date, col 119,
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
    row + 1, dt_tm = cnvtdatetime(request->beg_dt_tm), col 32,
    captions->inc_beg_dt_tm, col 56, dt_tm"@DATECONDENSED;;d",
    col 64, dt_tm"@TIMENOSECONDS;;m", dt_tm = cnvtdatetime(request->end_dt_tm),
    col 74, captions->inc_end_dt_tm, col 92,
    dt_tm"@DATECONDENSED;;d", col 100, dt_tm"@TIMENOSECONDS;;m",
    row + 2, col 1, captions->inc_blood_bank_owner
    IF ((request->cur_owner_area_cd=0.0))
     cur_owner_area_disp = validate(last_owner_area_disp,cur_owner_area_disp)
    ENDIF
    col 19, cur_owner_area_disp, row + 1,
    col 1, captions->inc_inventory_area
    IF ((request->cur_inv_area_cd=0.0))
     cur_inv_area_disp = validate(last_inv_area_disp,cur_inv_area_disp)
    ENDIF
    col 17, cur_inv_area_disp, row + 2,
    row- (1), col 1, sdonloc,
    row + 2, col 1, captions->sdondir,
    row + 2, col 1, captions->sdonor,
    row + 1, col 1, captions->sdonorid,
    col 25, captions->srecipient, col 49,
    captions->sdonation, col 59, captions->sprodnum,
    col 88, captions->saborh, row + 1,
    col 1, captions->sdobssn, col 25,
    captions->smrn, col 49, captions->sdt,
    col 59, captions->sprod, col 83,
    captions->sprod, col 92, captions->srecipient,
    col 102, captions->soverreas, col 130,
    captions->stech, row + 1, col 1,
    line1, col 25, line1,
    col 49, line2, col 59,
    line1, col 83, line2,
    col 92, line2, col 102,
    line3, col 130, line4,
    row + 1
   HEAD owner_cd
    IF (first_owner=1)
     first_owner = 0
    ELSE
     first_inv = 1, first_dloc = 1, BREAK
    ENDIF
   HEAD inv_cd
    IF (first_inv=1)
     first_inv = 0
    ELSE
     first_dloc = 1, BREAK
    ENDIF
   HEAD dloc_cd
    IF (first_dloc=1)
     first_dloc = 0
    ELSE
     BREAK
    ENDIF
   DETAIL
    IF (row > 56)
     BREAK
    ENDIF
    sret = assignstring(except->exceptions[d.seq].donor.name_full_formatted,22), col 1, sret,
    sret = assignstring(except->exceptions[d.seq].recipient.name_full_formatted,22), col 25, sret,
    col 49, don_dt"@SHORTDATE", sret = assignstring(except->exceptions[d.seq].product_nbr,22),
    col 59, sret, sret = concat(except->exceptions[d.seq].product_abo_disp," ",except->exceptions[d
     .seq].product_rh_disp),
    sret = assignstring(sret,8), col 83, sret,
    sret = concat(except->exceptions[d.seq].recipient.abo_disp," ",except->exceptions[d.seq].
     recipient.rh_disp), sret = assignstring(sret,8), col 92,
    sret, sret = assignstring(except->exceptions[d.seq].override_reason_disp,26), col 102,
    sret, sret = assignstring(except->exceptions[d.seq].tech_username,10), col 130,
    sret, row + 1
    IF (row=57)
     BREAK
    ENDIF
    x = size(except->exceptions[d.seq].donor.aliases,5)
    FOR (n = 1 TO x)
      IF ((except->exceptions[d.seq].donor.aliases[n].alias_type_cd=ddonoridcd))
       sret = assignstring(except->exceptions[d.seq].donor.aliases[n].alias,22), col 1, sret,
       n = x
      ENDIF
    ENDFOR
    sret = assignstring(trim(except->exceptions[d.seq].recipient.mrn),22), col 25, sret,
    sret = assignstring(except->exceptions[d.seq].product_disp,22), col 59, sret,
    row + 1
    IF (row=57)
     BREAK
    ENDIF
    col 1, b_dt_tm"@SHORTDATE;;d"
    FOR (n = 1 TO x)
      IF ((except->exceptions[d.seq].donor.aliases[n].alias_type_cd=dssncd))
       sret = assignstring(except->exceptions[d.seq].donor.aliases[n].alias,12), col 10, sret,
       n = x
      ENDIF
    ENDFOR
    row + 2
   FOOT  owner_cd
    row + 0
   FOOT  inv_cd
    row + 0
   FOOT  dloc_cd
    row + 0
   FOOT PAGE
    row 57, col 1,
"--------------------------------------------------------------------------------------------------------------------------\
----\
", row + 1, col 1, captions->inc_report_id,
    col 58, captions->inc_page, col 64,
    curpage"###", col 109, captions->inc_printed,
    col 119, curdate"@DATECONDENSED;;d", row + 1
   FOOT REPORT
    row 60, col 51, captions->end_of_report
  ;end select
 ENDIF
 IF ((request->exception_type_cd IN (regdirnomatc, 0.0)))
  SET nrptcnt = (nrptcnt+ 1)
  EXECUTE cpm_create_file_name_logical "bbd_regdirnomatc_except", "txt", "x"
  SET stat = alterlist(reply->rpt_list,nrptcnt)
  SET reply->rpt_list[nrptcnt].rpt_filename = cpm_cfn_info->file_name_path
  SET captions->inc_report_id = cpm_cfn_info->file_name
  SELECT
   IF ((request->null_report_ind=1))
    WITH nullreport, maxrow = 61, compress,
     nolandscape
   ELSE
    WITH nocounter, maxrow = 61, compress,
     nolandscape
   ENDIF
   INTO cpm_cfn_info->file_name_path
   reg_dt_tm = except->exceptions[d.seq].don_reg_result_dt_tm, b_dt_tm = except->exceptions[d.seq].
   donor.birth_dt_tm, name_sort_key = cnvtupper(except->exceptions[d.seq].donor.name_full_formatted)
   FROM (dummyt d  WITH seq = value(nlstcnt))
   WHERE (except->exceptions[d.seq].exception_type_cd=regdirnomatc)
   ORDER BY reg_dt_tm, name_sort_key
   HEAD REPORT
    row + 0, line1 = fillstring(24,"-"), line2 = fillstring(14,"-"),
    line3 = fillstring(8,"-"), line4 = fillstring(26,"-"), line5 = fillstring(10,"-")
   HEAD PAGE
    CALL center(captions->inc_title,1,125), col 107, captions->inc_time,
    col 121, curtime"@TIMENOSECONDS;;m", row + 1,
    col 107, captions->inc_as_of_date, col 119,
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
    row + 1, dt_tm = cnvtdatetime(request->beg_dt_tm), col 32,
    captions->inc_beg_dt_tm, col 56, dt_tm"@DATECONDENSED;;d",
    col 64, dt_tm"@TIMENOSECONDS;;m", dt_tm = cnvtdatetime(request->end_dt_tm),
    col 74, captions->inc_end_dt_tm, col 92,
    dt_tm"@DATECONDENSED;;d", col 100, dt_tm"@TIMENOSECONDS;;m",
    row + 2, col 1, captions->sregdir,
    row + 2, col 1, captions->sdonor,
    row + 1, col 1, captions->sdonorid,
    col 27, captions->srecipient, col 53,
    captions->sreg, col 74, captions->saborh,
    row + 1, col 1, captions->sdobssn,
    col 27, captions->smrn, col 53,
    captions->sdttm, col 69, captions->sdonor,
    col 79, captions->srecipient, col 89,
    captions->soverreas, col 117, captions->stech,
    row + 1, col 1, line1,
    col 27, line1, col 53,
    line2, col 69, line3,
    col 79, line3, col 89,
    line4, col 117, line5,
    row + 1
   DETAIL
    IF (row > 56)
     BREAK
    ENDIF
    sret = assignstring(except->exceptions[d.seq].donor.name_full_formatted,24), col 1, sret,
    sret = assignstring(except->exceptions[d.seq].recipient.name_full_formatted,24), col 27, sret,
    col 53, reg_dt_tm"@SHORTDATE;;d", col 62,
    reg_dt_tm"@TIMENOSECONDS;;m", sret = concat(except->exceptions[d.seq].donor.abo_disp," ",except->
     exceptions[d.seq].donor.rh_disp), sret = assignstring(sret,8),
    col 69, sret, sret = concat(except->exceptions[d.seq].recipient.abo_disp," ",except->exceptions[d
     .seq].recipient.rh_disp),
    sret = assignstring(sret,8), col 79, sret,
    sret = assignstring(except->exceptions[d.seq].override_reason_disp,26), col 89, sret,
    sret = assignstring(except->exceptions[d.seq].tech_username,10), col 117, sret,
    row + 1
    IF (row=57)
     BREAK
    ENDIF
    x = size(except->exceptions[d.seq].donor.aliases,5)
    FOR (n = 1 TO x)
      IF ((except->exceptions[d.seq].donor.aliases[n].alias_type_cd=ddonoridcd))
       sret = assignstring(except->exceptions[d.seq].donor.aliases[n].alias,24), col 1, sret,
       n = x
      ENDIF
    ENDFOR
    sret = assignstring(trim(except->exceptions[d.seq].recipient.mrn),24), col 27, sret,
    row + 1
    IF (row=57)
     BREAK
    ENDIF
    col 1, b_dt_tm"@SHORTDATE;;d"
    FOR (n = 1 TO x)
      IF ((except->exceptions[d.seq].donor.aliases[n].alias_type_cd=dssncd))
       sret = assignstring(except->exceptions[d.seq].donor.aliases[n].alias,14), col 10, sret,
       n = x
      ENDIF
    ENDFOR
    row + 2
   FOOT PAGE
    row 57, col 1,
"--------------------------------------------------------------------------------------------------------------------------\
----\
", row + 1, col 1, captions->inc_report_id,
    col 58, captions->inc_page, col 64,
    curpage"###", col 109, captions->inc_printed,
    col 119, curdate"@DATECONDENSED;;d", row + 1
   FOOT REPORT
    row 60, col 51, captions->end_of_report
  ;end select
 ENDIF
 IF ((request->exception_type_cd IN (doninelig, 0.0)))
  SET nrptcnt = (nrptcnt+ 1)
  EXECUTE cpm_create_file_name_logical "bbd_doninelig_except", "txt", "x"
  SET stat = alterlist(reply->rpt_list,nrptcnt)
  SET reply->rpt_list[nrptcnt].rpt_filename = cpm_cfn_info->file_name_path
  SET captions->inc_report_id = cpm_cfn_info->file_name
  SELECT
   IF ((request->null_report_ind=1))
    WITH nullreport, maxrow = 61, compress,
     nolandscape
   ELSE
    WITH nocounter, maxrow = 61, compress,
     nolandscape
   ENDIF
   INTO cpm_cfn_info->file_name_path
   don_dt = cnvtdate(except->exceptions[d.seq].don_reg_result_dt_tm), owner_cd = except->exceptions[d
   .seq].owner_cd, inv_cd = except->exceptions[d.seq].inventory_cd,
   dloc_cd = except->exceptions[d.seq].facility_cd, seq_exists = evaluate(nullind(d.seq),0,1,0),
   name_sort_key = cnvtupper(except->exceptions[d.seq].donor.name_full_formatted)
   FROM (dummyt d  WITH seq = value(nlstcnt))
   WHERE (except->exceptions[d.seq].exception_type_cd=doninelig)
    AND (((request->donation_location_cd=0)) OR ((request->donation_location_cd > 0)
    AND (request->donation_location_cd=except->exceptions[d.seq].facility_cd)))
    AND (((request->cur_owner_area_cd=0)) OR ((request->cur_owner_area_cd > 0)
    AND (request->cur_owner_area_cd=except->exceptions[d.seq].owner_cd)))
    AND (((request->cur_inv_area_cd=0)) OR ((request->cur_inv_area_cd > 0)
    AND (request->cur_inv_area_cd=except->exceptions[d.seq].inventory_cd)))
   ORDER BY owner_cd, inv_cd, dloc_cd,
    don_dt, name_sort_key
   HEAD REPORT
    row + 0, line1 = fillstring(24,"-"), line2 = fillstring(8,"-"),
    line3 = fillstring(10,"-"), first_owner = 1, first_inv = 1,
    first_dloc = 1
   HEAD PAGE
    row 0
    IF (seq_exists=1)
     cur_owner_area_disp = uar_get_code_display(except->exceptions[d.seq].owner_cd),
     cur_inv_area_disp = uar_get_code_display(except->exceptions[d.seq].inventory_cd), sdonloc =
     uar_get_code_display(except->exceptions[d.seq].facility_cd),
     sdonloc = concat(captions->sdonloc,": ",sdonloc)
    ENDIF
    CALL center(captions->inc_title,1,125), col 107, captions->inc_time,
    col 121, curtime"@TIMENOSECONDS;;m", row + 1,
    col 107, captions->inc_as_of_date, col 119,
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
    row + 1, dt_tm = cnvtdatetime(request->beg_dt_tm), col 32,
    captions->inc_beg_dt_tm, col 56, dt_tm"@DATECONDENSED;;d",
    col 64, dt_tm"@TIMENOSECONDS;;m", dt_tm = cnvtdatetime(request->end_dt_tm),
    col 74, captions->inc_end_dt_tm, col 92,
    dt_tm"@DATECONDENSED;;d", col 100, dt_tm"@TIMENOSECONDS;;m",
    row + 2, col 1, captions->inc_blood_bank_owner
    IF ((request->cur_owner_area_cd=0.0))
     cur_owner_area_disp = validate(last_owner_area_disp,cur_owner_area_disp)
    ENDIF
    col 19, cur_owner_area_disp, row + 1,
    col 1, captions->inc_inventory_area
    IF ((request->cur_inv_area_cd=0.0))
     cur_inv_area_disp = validate(last_inv_area_disp,cur_inv_area_disp)
    ENDIF
    col 17, cur_inv_area_disp, row + 2,
    row- (1), col 1, sdonloc,
    row + 2, col 1, captions->sdoninelig,
    row + 2, col 1, captions->sname,
    row + 1, col 1, captions->sdonorid,
    col 27, captions->sdonation, col 37,
    captions->sprodnum, col 64, captions->sinelig,
    row + 1, col 1, captions->sdobssn,
    col 27, captions->sdt, col 37,
    captions->sprod, col 64, captions->suntil,
    col 76, captions->soverreas, col 102,
    captions->stech, row + 1, col 1,
    line1, col 27, line2,
    col 37, line1, col 64,
    line2, col 76, line1,
    col 102, line3, row + 1
   HEAD owner_cd
    IF (first_owner=1)
     first_owner = 0
    ELSE
     first_inv = 1, first_dloc = 1, BREAK
    ENDIF
   HEAD inv_cd
    IF (first_inv=1)
     first_inv = 0
    ELSE
     first_dloc = 1, BREAK
    ENDIF
   HEAD dloc_cd
    IF (first_dloc=1)
     first_dloc = 0
    ELSE
     BREAK
    ENDIF
   DETAIL
    IF (row > 56)
     BREAK
    ENDIF
    sret = assignstring(except->exceptions[d.seq].donor.name_full_formatted,24), col 1, sret,
    col 27, don_dt"@SHORTDATE", sret = assignstring(except->exceptions[d.seq].product_nbr,24),
    col 37, sret, dt = format(except->exceptions[d.seq].ineligible_until_dt_tm,"@SHORTDATE;;d"),
    col 64, dt, sret = assignstring(except->exceptions[d.seq].override_reason_disp,24),
    col 76, sret, sret = assignstring(except->exceptions[d.seq].tech_username,10),
    col 102, sret, row + 1
    IF (row=57)
     BREAK
    ENDIF
    x = size(except->exceptions[d.seq].donor.aliases,5)
    FOR (n = 1 TO x)
      IF ((except->exceptions[d.seq].donor.aliases[n].alias_type_cd=ddonoridcd))
       sret = assignstring(except->exceptions[d.seq].donor.aliases[n].alias,24), col 1, sret,
       n = x
      ENDIF
    ENDFOR
    sret = assignstring(except->exceptions[d.seq].product_disp,24), col 37, sret,
    row + 1
    IF (row=57)
     BREAK
    ENDIF
    dt = format(except->exceptions[d.seq].donor.birth_dt_tm,"@SHORTDATE;;d"), col 1, dt
    FOR (n = 1 TO x)
      IF ((except->exceptions[d.seq].donor.aliases[n].alias_type_cd=dssncd))
       sret = assignstring(except->exceptions[d.seq].donor.aliases[n].alias,14), col 10, sret,
       n = x
      ENDIF
    ENDFOR
    row + 2
   FOOT  owner_cd
    row + 0
   FOOT  inv_cd
    row + 0
   FOOT  dloc_cd
    row + 0
   FOOT PAGE
    row 57, col 1,
"--------------------------------------------------------------------------------------------------------------------------\
----\
", row + 1, col 1, captions->inc_report_id,
    col 58, captions->inc_page, col 64,
    curpage"###", col 109, captions->inc_printed,
    col 119, curdate"@DATECONDENSED;;d", row + 1
   FOOT REPORT
    row 60, col 51, captions->end_of_report
  ;end select
 ENDIF
 IF ((request->exception_type_cd IN (reginelig, 0.0)))
  SET nrptcnt = (nrptcnt+ 1)
  EXECUTE cpm_create_file_name_logical "bbd_reginelig_except", "txt", "x"
  SET stat = alterlist(reply->rpt_list,nrptcnt)
  SET reply->rpt_list[nrptcnt].rpt_filename = cpm_cfn_info->file_name_path
  SET captions->inc_report_id = cpm_cfn_info->file_name
  SELECT
   IF ((request->null_report_ind=1))
    WITH nullreport, maxrow = 61, compress,
     nolandscape
   ELSE
    WITH nocounter, maxrow = 61, compress,
     nolandscape
   ENDIF
   INTO cpm_cfn_info->file_name_path
   reg_dt_tm = except->exceptions[d.seq].don_reg_result_dt_tm, name_sort_key = cnvtupper(except->
    exceptions[d.seq].donor.name_full_formatted)
   FROM (dummyt d  WITH seq = value(nlstcnt))
   WHERE (except->exceptions[d.seq].exception_type_cd=reginelig)
   ORDER BY except->exceptions[d.seq].don_reg_result_dt_tm, name_sort_key
   HEAD REPORT
    row + 0, line1 = fillstring(24,"-"), line2 = fillstring(14,"-"),
    line3 = fillstring(20,"-"), line4 = fillstring(10,"-"), line5 = fillstring(26,"-")
   HEAD PAGE
    CALL center(captions->inc_title,1,125), col 107, captions->inc_time,
    col 121, curtime"@TIMENOSECONDS;;m", row + 1,
    col 107, captions->inc_as_of_date, col 119,
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
    row + 1, dt_tm = cnvtdatetime(request->beg_dt_tm), col 32,
    captions->inc_beg_dt_tm, col 56, dt_tm"@DATECONDENSED;;d",
    col 64, dt_tm"@TIMENOSECONDS;;m", dt_tm = cnvtdatetime(request->end_dt_tm),
    col 74, captions->inc_end_dt_tm, col 92,
    dt_tm"@DATECONDENSED;;d", col 100, dt_tm"@TIMENOSECONDS;;m",
    row + 2, col 1, captions->sreginelig,
    row + 2, col 1, captions->sname,
    row + 1, col 1, captions->sdonorid,
    col 27, captions->sreg, col 65,
    captions->sinelig, row + 1, col 1,
    captions->sdobssn, col 27, captions->sdttm,
    col 43, captions->sprocedure, col 65,
    captions->suntil, col 77, captions->soverreas,
    col 105, captions->stech, row + 1,
    col 1, line1, col 27,
    line2, col 43, line3,
    col 65, line4, col 77,
    line5, col 105, line4,
    row + 1
   DETAIL
    IF (row > 56)
     BREAK
    ENDIF
    dt = format(reg_dt_tm,"@SHORTDATE;;d"), sret = assignstring(except->exceptions[d.seq].donor.
     name_full_formatted,24), col 1,
    sret, col 27, dt,
    col 36, reg_dt_tm"@TIMENOSECONDS;;m", sret = assignstring(except->exceptions[d.seq].
     procedure_disp,20),
    col 43, sret, dt = format(except->exceptions[d.seq].ineligible_until_dt_tm,"@SHORTDATE;;d"),
    col 65, dt, sret = assignstring(except->exceptions[d.seq].override_reason_disp,26),
    col 77, sret, sret = assignstring(except->exceptions[d.seq].tech_username,10),
    col 105, sret, row + 1
    IF (row=57)
     BREAK
    ENDIF
    x = size(except->exceptions[d.seq].donor.aliases,5)
    FOR (n = 1 TO x)
      IF ((except->exceptions[d.seq].donor.aliases[n].alias_type_cd=ddonoridcd))
       sret = assignstring(except->exceptions[d.seq].donor.aliases[n].alias,24), col 1, sret,
       n = x
      ENDIF
    ENDFOR
    row + 1
    IF (row=57)
     BREAK
    ENDIF
    dt = format(except->exceptions[d.seq].donor.birth_dt_tm,"@SHORTDATE;;d"), col 1, dt
    FOR (n = 1 TO x)
      IF ((except->exceptions[d.seq].donor.aliases[n].alias_type_cd=dssncd))
       sret = assignstring(except->exceptions[d.seq].donor.aliases[n].alias,14), col 10, sret,
       n = x
      ENDIF
    ENDFOR
    row + 2
   FOOT PAGE
    row 57, col 1,
"--------------------------------------------------------------------------------------------------------------------------\
----\
", row + 1, col 1, captions->inc_report_id,
    col 58, captions->inc_page, col 64,
    curpage"###", col 109, captions->inc_printed,
    col 119, curdate"@DATECONDENSED;;d", row + 1
   FOOT REPORT
    row 60, col 51, captions->end_of_report
  ;end select
 ENDIF
 IF ((request->exception_type_cd IN (regperm, 0.0)))
  SET nrptcnt = (nrptcnt+ 1)
  EXECUTE cpm_create_file_name_logical "bbd_regperm_except", "txt", "x"
  SET stat = alterlist(reply->rpt_list,nrptcnt)
  SET reply->rpt_list[nrptcnt].rpt_filename = cpm_cfn_info->file_name_path
  SET captions->inc_report_id = cpm_cfn_info->file_name
  SELECT
   IF ((request->null_report_ind=1))
    WITH nullreport, maxrow = 61, compress,
     nolandscape
   ELSE
    WITH nocounter, maxrow = 61, compress,
     nolandscape
   ENDIF
   INTO cpm_cfn_info->file_name_path
   reg_dt_tm = except->exceptions[d.seq].don_reg_result_dt_tm, name_sort_key = cnvtupper(except->
    exceptions[d.seq].donor.name_full_formatted)
   FROM (dummyt d  WITH seq = value(nlstcnt))
   WHERE (except->exceptions[d.seq].exception_type_cd=regperm)
   ORDER BY except->exceptions[d.seq].don_reg_result_dt_tm, name_sort_key
   HEAD REPORT
    row + 0, line1 = fillstring(24,"-"), line2 = fillstring(14,"-"),
    line3 = fillstring(21,"-"), line4 = fillstring(8,"-"), line5 = fillstring(10,"-")
   HEAD PAGE
    CALL center(captions->inc_title,1,125), col 107, captions->inc_time,
    col 121, curtime"@TIMENOSECONDS;;m", row + 1,
    col 107, captions->inc_as_of_date, col 119,
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
    row + 1, dt_tm = cnvtdatetime(request->beg_dt_tm), col 32,
    captions->inc_beg_dt_tm, col 56, dt_tm"@DATECONDENSED;;d",
    col 64, dt_tm"@TIMENOSECONDS;;m", dt_tm = cnvtdatetime(request->end_dt_tm),
    col 74, captions->inc_end_dt_tm, col 92,
    dt_tm"@DATECONDENSED;;d", col 100, dt_tm"@TIMENOSECONDS;;m",
    row + 2, col 1, captions->sregperm,
    row + 2, col 1, captions->sname,
    row + 1, col 1, captions->sdonorid,
    col 27, captions->sreg, col 66,
    captions->sdt, col 77, captions->sdefer,
    row + 1, col 1, captions->sdobssn,
    col 27, captions->sdttm, col 43,
    captions->sprocedure, col 66, captions->sdeferd,
    col 77, captions->suntil, col 88,
    captions->soverreas, col 114, captions->stech,
    row + 1, col 1, line1,
    col 27, line2, col 43,
    line3, col 66, line4,
    col 77, line4, col 88,
    line1, col 114, line5,
    row + 1
   DETAIL
    IF (row > 56)
     BREAK
    ENDIF
    sret = assignstring(except->exceptions[d.seq].donor.name_full_formatted,24), col 1, sret,
    dt = format(reg_dt_tm,"@SHORTDATE;;d"), col 27, dt,
    col 36, reg_dt_tm"@TIMENOSECONDS;;m", sret = assignstring(except->exceptions[d.seq].
     procedure_disp,21),
    col 43, sret, dt = format(except->exceptions[d.seq].deferred_dt_tm,"@SHORTDATE;;d"),
    col 66, dt, sret = assignstring(except->exceptions[d.seq].eligibility_type_disp,8),
    col 77, sret, sret = assignstring(except->exceptions[d.seq].override_reason_disp,24),
    col 88, sret, sret = assignstring(except->exceptions[d.seq].tech_username,10),
    col 114, sret, row + 1
    IF (row=57)
     BREAK
    ENDIF
    x = size(except->exceptions[d.seq].donor.aliases,5)
    FOR (n = 1 TO x)
      IF ((except->exceptions[d.seq].donor.aliases[n].alias_type_cd=ddonoridcd))
       sret = assignstring(except->exceptions[d.seq].donor.aliases[n].alias,24), col 1, sret,
       n = x
      ENDIF
    ENDFOR
    row + 1
    IF (row=57)
     BREAK
    ENDIF
    dt = format(except->exceptions[d.seq].donor.birth_dt_tm,"@SHORTDATE;;d"), col 1, dt
    FOR (n = 1 TO x)
      IF ((except->exceptions[d.seq].donor.aliases[n].alias_type_cd=dssncd))
       sret = assignstring(except->exceptions[d.seq].donor.aliases[n].alias,14), col 10, sret,
       n = x
      ENDIF
    ENDFOR
    row + 2
   FOOT PAGE
    row 57, col 1,
"--------------------------------------------------------------------------------------------------------------------------\
----\
", row + 1, col 1, captions->inc_report_id,
    col 58, captions->inc_page, col 64,
    curpage"###", col 109, captions->inc_printed,
    col 119, curdate"@DATECONDENSED;;d", row + 1
   FOOT REPORT
    row 60, col 51, captions->end_of_report
  ;end select
 ENDIF
 IF ((request->exception_type_cd IN (regtemp, 0.0)))
  SET nrptcnt = (nrptcnt+ 1)
  EXECUTE cpm_create_file_name_logical "bbd_regtemp_except", "txt", "x"
  SET stat = alterlist(reply->rpt_list,nrptcnt)
  SET reply->rpt_list[nrptcnt].rpt_filename = cpm_cfn_info->file_name_path
  SET captions->inc_report_id = cpm_cfn_info->file_name
  SELECT
   IF ((request->null_report_ind=1))
    WITH nullreport, maxrow = 61, compress,
     nolandscape
   ELSE
    WITH nocounter, maxrow = 61, compress,
     nolandscape
   ENDIF
   INTO cpm_cfn_info->file_name_path
   reg_dt_tm = except->exceptions[d.seq].don_reg_result_dt_tm, name_sort_key = cnvtupper(except->
    exceptions[d.seq].donor.name_full_formatted)
   FROM (dummyt d  WITH seq = value(nlstcnt))
   WHERE (except->exceptions[d.seq].exception_type_cd=regtemp)
   ORDER BY except->exceptions[d.seq].don_reg_result_dt_tm, name_sort_key
   HEAD REPORT
    row + 0, line1 = fillstring(24,"-"), line2 = fillstring(14,"-"),
    line3 = fillstring(21,"-"), line4 = fillstring(8,"-"), line5 = fillstring(10,"-")
   HEAD PAGE
    CALL center(captions->inc_title,1,125), col 107, captions->inc_time,
    col 121, curtime"@TIMENOSECONDS;;m", row + 1,
    col 107, captions->inc_as_of_date, col 119,
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
    row + 1, dt_tm = cnvtdatetime(request->beg_dt_tm), col 32,
    captions->inc_beg_dt_tm, col 56, dt_tm"@DATECONDENSED;;d",
    col 64, dt_tm"@TIMENOSECONDS;;m", dt_tm = cnvtdatetime(request->end_dt_tm),
    col 74, captions->inc_end_dt_tm, col 92,
    dt_tm"@DATECONDENSED;;d", col 100, dt_tm"@TIMENOSECONDS;;m",
    row + 2, col 1, captions->sregtemp,
    row + 2, col 1, captions->sname,
    row + 1, col 1, captions->sdonorid,
    col 27, captions->sreg, col 66,
    captions->sdt, col 77, captions->sdefer,
    row + 1, col 1, captions->sdobssn,
    col 27, captions->sdttm, col 43,
    captions->sprocedure, col 66, captions->sdeferd,
    col 77, captions->suntil, col 88,
    captions->soverreas, col 114, captions->stech,
    row + 1, col 1, line1,
    col 27, line2, col 43,
    line3, col 66, line4,
    col 77, line4, col 88,
    line1, col 114, line5,
    row + 1
   DETAIL
    IF (row > 56)
     BREAK
    ENDIF
    sret = assignstring(except->exceptions[d.seq].donor.name_full_formatted,24), col 1, sret,
    dt = format(reg_dt_tm,"@SHORTDATE;;d"), col 27, dt,
    col 36, reg_dt_tm"@TIMENOSECONDS;;m", sret = assignstring(except->exceptions[d.seq].
     procedure_disp,21),
    col 43, sret, dt = format(except->exceptions[d.seq].deferred_dt_tm,"@SHORTDATE;;d"),
    col 66, dt, dt = format(except->exceptions[d.seq].defer_until_dt_tm,"@SHORTDATE;;d"),
    col 77, dt, sret = assignstring(except->exceptions[d.seq].override_reason_disp,24),
    col 88, sret, sret = assignstring(except->exceptions[d.seq].tech_username,10),
    col 114, sret, row + 1
    IF (row=57)
     BREAK
    ENDIF
    x = size(except->exceptions[d.seq].donor.aliases,5)
    FOR (n = 1 TO x)
      IF ((except->exceptions[d.seq].donor.aliases[n].alias_type_cd=ddonoridcd))
       sret = assignstring(except->exceptions[d.seq].donor.aliases[n].alias,24), col 1, sret,
       n = x
      ENDIF
    ENDFOR
    row + 1
    IF (row=57)
     BREAK
    ENDIF
    dt = format(except->exceptions[d.seq].donor.birth_dt_tm,"@SHORTDATE;;d"), col 1, dt
    FOR (n = 1 TO x)
      IF ((except->exceptions[d.seq].donor.aliases[n].alias_type_cd=dssncd))
       sret = assignstring(except->exceptions[d.seq].donor.aliases[n].alias,14), col 10, sret,
       n = x
      ENDIF
    ENDFOR
    row + 2
   FOOT PAGE
    row 57, col 1,
"--------------------------------------------------------------------------------------------------------------------------\
----\
", row + 1, col 1, captions->inc_report_id,
    col 58, captions->inc_page, col 64,
    curpage"###", col 109, captions->inc_printed,
    col 119, curdate"@DATECONDENSED;;d", row + 1
   FOOT REPORT
    row 60, col 51, captions->end_of_report
  ;end select
 ENDIF
 IF ((request->exception_type_cd IN (overinterp, 0.0)))
  SET nrptcnt = (nrptcnt+ 1)
  EXECUTE cpm_create_file_name_logical "bbd_overinterp_except", "txt", "x"
  SET stat = alterlist(reply->rpt_list,nrptcnt)
  SET reply->rpt_list[nrptcnt].rpt_filename = cpm_cfn_info->file_name_path
  SET captions->inc_report_id = cpm_cfn_info->file_name
  SELECT
   IF ((request->null_report_ind=1))
    WITH nullreport, maxrow = 61, compress,
     nolandscape, maxcol = 132
   ELSE
    WITH nocounter, maxrow = 61, compress,
     nolandscape, maxcol = 132
   ENDIF
   INTO cpm_cfn_info->file_name_path
   except_dt_tm = except->exceptions[d.seq].exception_dt_tm, name_sort_key = cnvtupper(except->
    exceptions[d.seq].donor.name_full_formatted)
   FROM (dummyt d  WITH seq = value(nlstcnt))
   WHERE (except->exceptions[d.seq].exception_type_cd=overinterp)
   ORDER BY except->exceptions[d.seq].don_reg_result_dt_tm, name_sort_key
   HEAD REPORT
    row + 0, line1 = fillstring(24,"-"), line3 = fillstring(15,"-"),
    line2 = fillstring(20,"-"), line4 = fillstring(8,"-"), line5 = fillstring(10,"-"),
    first_owner = 1, first_inv = 1, first_dloc = 1
   HEAD PAGE
    CALL center(captions->inc_title,1,125), col 107, captions->inc_time,
    col 121, curtime"@TIMENOSECONDS;;m", row + 1,
    col 107, captions->inc_as_of_date, col 119,
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
    row + 1, dt_tm = cnvtdatetime(request->beg_dt_tm), col 32,
    captions->inc_beg_dt_tm, col 56, dt_tm"@DATECONDENSED;;d",
    col 64, dt_tm"@TIMENOSECONDS;;m", dt_tm = cnvtdatetime(request->end_dt_tm),
    col 74, captions->inc_end_dt_tm, col 92,
    dt_tm"@DATECONDENSED;;d", col 100, dt_tm"@TIMENOSECONDS;;m",
    row + 2, col 1, captions->soverinterp,
    row + 2, col 1, captions->sname,
    row + 1, col 1, captions->sdonorid,
    col 94, captions->soverreas, row + 1,
    col 1, captions->sdobssn, col 27,
    captions->sprodnum, col 54, captions->sprocedure,
    col 76, captions->sresult, col 94,
    captions->sdttm, col 120, captions->stech,
    row + 1, col 1, line1,
    col 27, line1, col 54,
    line2, col 76, line3,
    col 94, line1, col 120,
    line5, row + 1
   DETAIL
    IF (row > 56)
     BREAK
    ENDIF
    sret = assignstring(except->exceptions[d.seq].donor.name_full_formatted,24), col 1, sret,
    sret = assignstring(except->exceptions[d.seq].product_nbr,24), col 27, sret,
    sret = assignstring(except->exceptions[d.seq].procedure_disp,20), col 54, sret,
    sret = assignstring(except->exceptions[d.seq].result,15), col 76, sret,
    sret = assignstring(except->exceptions[d.seq].override_reason_disp,24), col 94, sret,
    sret = assignstring(except->exceptions[d.seq].tech_username,10), col 120, sret,
    row + 1
    IF (row=57)
     BREAK
    ENDIF
    x = size(except->exceptions[d.seq].donor.aliases,5)
    FOR (n = 1 TO x)
      IF ((except->exceptions[d.seq].donor.aliases[n].alias_type_cd=ddonoridcd))
       sret = assignstring(except->exceptions[d.seq].donor.aliases[n].alias,24), col 1, sret,
       n = x
      ENDIF
    ENDFOR
    dt = format(except_dt_tm,"@SHORTDATE;;d"), col 94, dt,
    col 104, except_dt_tm"@TIMENOSECONDS;;m", row + 1
    IF (row=57)
     BREAK
    ENDIF
    dt = format(except->exceptions[d.seq].donor.birth_dt_tm,"@SHORTDATE;;d"), col 1, dt
    FOR (n = 1 TO x)
      IF ((except->exceptions[d.seq].donor.aliases[n].alias_type_cd=dssncd))
       sret = assignstring(except->exceptions[d.seq].donor.aliases[n].alias,14), col 10, sret,
       n = x
      ENDIF
    ENDFOR
    row + 2
   FOOT PAGE
    row 57, col 1,
"--------------------------------------------------------------------------------------------------------------------------\
----\
", row + 1, col 1, captions->inc_report_id,
    col 58, captions->inc_page, col 64,
    curpage"###", col 109, captions->inc_printed,
    col 119, curdate"@DATECONDENSED;;d", row + 1
   FOOT REPORT
    row 60, col 51, captions->end_of_report
  ;end select
 ENDIF
 IF ((request->exception_type_cd IN (doneligrein, 0.0)))
  SET nrptcnt = (nrptcnt+ 1)
  EXECUTE cpm_create_file_name_logical "bbd_doneligrein_except", "txt", "x"
  SET stat = alterlist(reply->rpt_list,nrptcnt)
  SET reply->rpt_list[nrptcnt].rpt_filename = cpm_cfn_info->file_name_path
  SET captions->inc_report_id = cpm_cfn_info->file_name
  SELECT
   IF ((request->null_report_ind=1))
    WITH nullreport, maxrow = 61, compress,
     nolandscape, maxcol = 135
   ELSE
    WITH nocounter, maxrow = 61, compress,
     nolandscape, maxcol = 135
   ENDIF
   INTO cpm_cfn_info->file_name_path
   don_dt = cnvtdate(except->exceptions[d.seq].don_reg_result_dt_tm), defferal_meaning =
   uar_get_code_meaning(except->exceptions[d.seq].eligibility_type_cd), owner_cd = except->
   exceptions[d.seq].owner_cd,
   inv_cd = except->exceptions[d.seq].inventory_cd, dloc_cd = except->exceptions[d.seq].facility_cd,
   seq_exists = evaluate(nullind(d.seq),0,1,0),
   name_sort_key = cnvtupper(except->exceptions[d.seq].donor.name_full_formatted)
   FROM (dummyt d  WITH seq = value(nlstcnt))
   WHERE (except->exceptions[d.seq].exception_type_cd=doneligrein)
    AND (((request->donation_location_cd=0)) OR ((request->donation_location_cd > 0)
    AND (request->donation_location_cd=except->exceptions[d.seq].facility_cd)))
    AND (((request->cur_owner_area_cd=0)) OR ((request->cur_owner_area_cd > 0)
    AND (request->cur_owner_area_cd=except->exceptions[d.seq].owner_cd)))
    AND (((request->cur_inv_area_cd=0)) OR ((request->cur_inv_area_cd > 0)
    AND (request->cur_inv_area_cd=except->exceptions[d.seq].inventory_cd)))
   ORDER BY owner_cd, inv_cd, dloc_cd,
    don_dt, name_sort_key
   HEAD REPORT
    row + 0, line1 = fillstring(24,"-"), line3 = fillstring(10,"-"),
    line2 = fillstring(8,"-"), first_owner = 1, first_inv = 1,
    first_dloc = 1
   HEAD PAGE
    row 0
    IF (seq_exists=1)
     cur_owner_area_disp = uar_get_code_display(except->exceptions[d.seq].owner_cd),
     cur_inv_area_disp = uar_get_code_display(except->exceptions[d.seq].inventory_cd), sdonloc =
     uar_get_code_display(except->exceptions[d.seq].facility_cd),
     sdonloc = concat(captions->sdonloc,": ",sdonloc)
    ENDIF
    CALL center(captions->inc_title,1,125), col 107, captions->inc_time,
    col 121, curtime"@TIMENOSECONDS;;m", row + 1,
    col 107, captions->inc_as_of_date, col 119,
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
    row + 1, dt_tm = cnvtdatetime(request->beg_dt_tm), col 32,
    captions->inc_beg_dt_tm, col 56, dt_tm"@DATECONDENSED;;d",
    col 64, dt_tm"@TIMENOSECONDS;;m", dt_tm = cnvtdatetime(request->end_dt_tm),
    col 74, captions->inc_end_dt_tm, col 92,
    dt_tm"@DATECONDENSED;;d", col 100, dt_tm"@TIMENOSECONDS;;m",
    row + 2, col 1, captions->inc_blood_bank_owner
    IF ((request->cur_owner_area_cd=0.0))
     cur_owner_area_disp = validate(last_owner_area_disp,cur_owner_area_disp)
    ENDIF
    col 19, cur_owner_area_disp, row + 1,
    col 1, captions->inc_inventory_area
    IF ((request->cur_inv_area_cd=0.0))
     cur_inv_area_disp = validate(last_inv_area_disp,cur_inv_area_disp)
    ENDIF
    col 17, cur_inv_area_disp, row + 2,
    row- (1), col 1, sdonloc,
    row + 2, col 1, captions->sdonelig,
    row + 2, col 1, captions->sname,
    row + 1, col 1, captions->sdonorid,
    col 27, captions->sdonation, col 37,
    captions->sprodnum, col 63, captions->sdt,
    col 73, captions->sdefer, col 85,
    captions->sdeferl, row + 1, col 1,
    captions->sdobssn, col 27, captions->sdt,
    col 37, captions->sprod, col 63,
    captions->sdeferd, col 73, captions->suntil,
    col 85, captions->stype, col 97,
    captions->soverreas, col 123, captions->stech,
    row + 1, col 1, line1,
    col 27, line2, col 37,
    line1, col 63, line2,
    col 73, line3, col 85,
    line3, col 97, line1,
    col 123, line3, row + 1
   HEAD owner_cd
    IF (first_owner=1)
     first_owner = 0
    ELSE
     first_inv = 1, first_dloc = 1, BREAK
    ENDIF
   HEAD inv_cd
    IF (first_inv=1)
     first_inv = 0
    ELSE
     first_dloc = 1, BREAK
    ENDIF
   HEAD dloc_cd
    IF (first_dloc=1)
     first_dloc = 0
    ELSE
     BREAK
    ENDIF
   DETAIL
    IF (row > 56)
     BREAK
    ENDIF
    sret = assignstring(except->exceptions[d.seq].donor.name_full_formatted,24), col 1, sret,
    dt = format(don_dt,"@SHORTDATE"), col 27, dt,
    sret = assignstring(except->exceptions[d.seq].product_nbr,24), col 37, sret,
    dt = format(except->exceptions[d.seq].deferred_dt_tm,"@SHORTDATE;;d"), col 63, dt
    IF (defferal_meaning="PERMNENT")
     sret = assignstring(except->exceptions[d.seq].eligibility_type_disp,10), col 73, sret
    ELSE
     dt = format(except->exceptions[d.seq].defer_until_dt_tm,"@SHORTDATE;;d"), col 73, dt
    ENDIF
    sret = assignstring(except->exceptions[d.seq].eligibility_type_disp,10), col 85, sret,
    sret = assignstring(except->exceptions[d.seq].override_reason_disp,24), col 97, sret,
    sret = assignstring(except->exceptions[d.seq].tech_username,10), col 123, sret,
    row + 1
    IF (row=57)
     BREAK
    ENDIF
    x = size(except->exceptions[d.seq].donor.aliases,5)
    FOR (n = 1 TO x)
      IF ((except->exceptions[d.seq].donor.aliases[n].alias_type_cd=ddonoridcd))
       sret = assignstring(except->exceptions[d.seq].donor.aliases[n].alias,24), col 1, sret,
       n = x
      ENDIF
    ENDFOR
    sret = assignstring(except->exceptions[d.seq].product_disp,24), col 37, sret,
    row + 1
    IF (row=57)
     BREAK
    ENDIF
    dt = format(except->exceptions[d.seq].donor.birth_dt_tm,"@SHORTDATE;;d"), col 1, dt
    FOR (n = 1 TO x)
      IF ((except->exceptions[d.seq].donor.aliases[n].alias_type_cd=dssncd))
       sret = assignstring(except->exceptions[d.seq].donor.aliases[n].alias,14), col 10, sret,
       n = x
      ENDIF
    ENDFOR
    row + 2
   FOOT  owner_cd
    row + 0
   FOOT  inv_cd
    row + 0
   FOOT  dloc_cd
    row + 0
   FOOT PAGE
    row 57, col 1,
"--------------------------------------------------------------------------------------------------------------------------\
----\
", row + 1, col 1, captions->inc_report_id,
    col 58, captions->inc_page, col 64,
    curpage"###", col 109, captions->inc_printed,
    col 119, curdate"@DATECONDENSED;;d", row + 1
   FOOT REPORT
    row 60, col 51, captions->end_of_report
  ;end select
 ENDIF
 IF ((request->exception_type_cd IN (donperm, 0.0)))
  SET nrptcnt = (nrptcnt+ 1)
  EXECUTE cpm_create_file_name_logical "bbd_donperm_except", "txt", "x"
  SET stat = alterlist(reply->rpt_list,nrptcnt)
  SET reply->rpt_list[nrptcnt].rpt_filename = cpm_cfn_info->file_name_path
  SET captions->inc_report_id = cpm_cfn_info->file_name
  SELECT
   IF ((request->null_report_ind=1))
    WITH nullreport, maxrow = 61, compress,
     nolandscape
   ELSE
    WITH nocounter, maxrow = 61, compress,
     nolandscape
   ENDIF
   INTO cpm_cfn_info->file_name_path
   don_dt = cnvtdate(except->exceptions[d.seq].don_reg_result_dt_tm), deferral_meaning =
   uar_get_code_meaning(except->exceptions[d.seq].eligibility_type_cd), owner_cd = except->
   exceptions[d.seq].owner_cd,
   inv_cd = except->exceptions[d.seq].inventory_cd, dloc_cd = except->exceptions[d.seq].facility_cd,
   seq_exists = evaluate(nullind(d.seq),0,1,0),
   name_sort_key = cnvtupper(except->exceptions[d.seq].donor.name_full_formatted)
   FROM (dummyt d  WITH seq = value(nlstcnt))
   WHERE (except->exceptions[d.seq].exception_type_cd=donperm)
    AND (((request->donation_location_cd=0)) OR ((request->donation_location_cd > 0)
    AND (request->donation_location_cd=except->exceptions[d.seq].facility_cd)))
    AND (((request->cur_owner_area_cd=0)) OR ((request->cur_owner_area_cd > 0)
    AND (request->cur_owner_area_cd=except->exceptions[d.seq].owner_cd)))
    AND (((request->cur_inv_area_cd=0)) OR ((request->cur_inv_area_cd > 0)
    AND (request->cur_inv_area_cd=except->exceptions[d.seq].inventory_cd)))
   ORDER BY owner_cd, inv_cd, dloc_cd,
    don_dt, name_sort_key
   HEAD REPORT
    row + 0, line1 = fillstring(24,"-"), line3 = fillstring(10,"-"),
    line2 = fillstring(8,"-"), first_owner = 1, first_inv = 1,
    first_dloc = 1
   HEAD PAGE
    row 0
    IF (seq_exists=1)
     cur_owner_area_disp = uar_get_code_display(except->exceptions[d.seq].owner_cd),
     cur_inv_area_disp = uar_get_code_display(except->exceptions[d.seq].inventory_cd), sdonloc =
     uar_get_code_display(except->exceptions[d.seq].facility_cd),
     sdonloc = concat(captions->sdonloc,": ",sdonloc)
    ENDIF
    CALL center(captions->inc_title,1,125), col 107, captions->inc_time,
    col 121, curtime"@TIMENOSECONDS;;m", row + 1,
    col 107, captions->inc_as_of_date, col 119,
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
    row + 1, dt_tm = cnvtdatetime(request->beg_dt_tm), col 32,
    captions->inc_beg_dt_tm, col 56, dt_tm"@DATECONDENSED;;d",
    col 64, dt_tm"@TIMENOSECONDS;;m", dt_tm = cnvtdatetime(request->end_dt_tm),
    col 74, captions->inc_end_dt_tm, col 92,
    dt_tm"@DATECONDENSED;;d", col 100, dt_tm"@TIMENOSECONDS;;m",
    row + 2, col 1, captions->inc_blood_bank_owner
    IF ((request->cur_owner_area_cd=0.0))
     cur_owner_area_disp = validate(last_owner_area_disp,cur_owner_area_disp)
    ENDIF
    col 19, cur_owner_area_disp, row + 1,
    col 1, captions->inc_inventory_area
    IF ((request->cur_inv_area_cd=0.0))
     cur_inv_area_disp = validate(last_inv_area_disp,cur_inv_area_disp)
    ENDIF
    col 17, cur_inv_area_disp, row + 2,
    row- (1), col 1, sdonloc,
    row + 2, col 1, captions->sdonperm,
    row + 2, col 1, captions->sname,
    row + 1, col 1, captions->sdonorid,
    col 27, captions->sdonation, col 37,
    captions->sprodnum, col 64, captions->sdt,
    col 74, captions->sdefer, row + 1,
    col 1, captions->sdobssn, col 27,
    captions->sdt, col 37, captions->sprod,
    col 64, captions->sdeferd, col 74,
    captions->suntil, col 86, captions->soverreas,
    col 112, captions->stech, row + 1,
    col 1, line1, col 27,
    line2, col 37, line1,
    col 64, line2, col 74,
    line3, col 86, line1,
    col 112, line3, row + 1
   HEAD owner_cd
    IF (first_owner=1)
     first_owner = 0
    ELSE
     first_inv = 1, first_dloc = 1, BREAK
    ENDIF
   HEAD inv_cd
    IF (first_inv=1)
     first_inv = 0
    ELSE
     first_dloc = 1, BREAK
    ENDIF
   HEAD dloc_cd
    IF (first_dloc=1)
     first_dloc = 0
    ELSE
     BREAK
    ENDIF
   DETAIL
    IF (row > 56)
     BREAK
    ENDIF
    sret = assignstring(except->exceptions[d.seq].donor.name_full_formatted,24), col 1, sret,
    dt = format(don_dt,"@SHORTDATE"), col 27, dt,
    sret = assignstring(except->exceptions[d.seq].product_nbr,24), col 37, sret,
    dt = format(except->exceptions[d.seq].deferred_dt_tm,"@SHORTDATE;;d"), col 64, dt,
    sret = assignstring(except->exceptions[d.seq].eligibility_type_disp,10), col 74, sret,
    sret = assignstring(except->exceptions[d.seq].override_reason_disp,24), col 86, sret,
    sret = assignstring(except->exceptions[d.seq].tech_username,10), col 112, sret,
    row + 1
    IF (row=57)
     BREAK
    ENDIF
    x = size(except->exceptions[d.seq].donor.aliases,5)
    FOR (n = 1 TO x)
      IF ((except->exceptions[d.seq].donor.aliases[n].alias_type_cd=ddonoridcd))
       sret = assignstring(except->exceptions[d.seq].donor.aliases[n].alias,24), col 1, sret,
       n = x
      ENDIF
    ENDFOR
    sret = assignstring(except->exceptions[d.seq].product_disp,24), col 37, sret,
    row + 1
    IF (row=57)
     BREAK
    ENDIF
    dt = format(except->exceptions[d.seq].donor.birth_dt_tm,"@SHORTDATE;;d"), col 1, dt
    FOR (n = 1 TO x)
      IF ((except->exceptions[d.seq].donor.aliases[n].alias_type_cd=dssncd))
       sret = assignstring(except->exceptions[d.seq].donor.aliases[n].alias,14), col 10, sret,
       n = x
      ENDIF
    ENDFOR
    row + 2
   FOOT  owner_cd
    row + 0
   FOOT  inv_cd
    row + 0
   FOOT  dloc_cd
    row + 0
   FOOT PAGE
    row 57, col 1,
"--------------------------------------------------------------------------------------------------------------------------\
----\
", row + 1, col 1, captions->inc_report_id,
    col 58, captions->inc_page, col 64,
    curpage"###", col 109, captions->inc_printed,
    col 119, curdate"@DATECONDENSED;;d", row + 1
   FOOT REPORT
    row 60, col 51, captions->end_of_report
  ;end select
 ENDIF
 IF ((request->exception_type_cd IN (dontemp, 0.0)))
  SET nrptcnt = (nrptcnt+ 1)
  EXECUTE cpm_create_file_name_logical "bbd_dontemp_except", "txt", "x"
  SET stat = alterlist(reply->rpt_list,nrptcnt)
  SET reply->rpt_list[nrptcnt].rpt_filename = cpm_cfn_info->file_name_path
  SET captions->inc_report_id = cpm_cfn_info->file_name
  SELECT
   IF ((request->null_report_ind=1))
    WITH nullreport, maxrow = 61, compress,
     nolandscape
   ELSE
    WITH nocounter, maxrow = 61, compress,
     nolandscape
   ENDIF
   INTO cpm_cfn_info->file_name_path
   don_dt = cnvtdate(except->exceptions[d.seq].don_reg_result_dt_tm), owner_cd = except->exceptions[d
   .seq].owner_cd, inv_cd = except->exceptions[d.seq].inventory_cd,
   dloc_cd = except->exceptions[d.seq].facility_cd, seq_exists = evaluate(nullind(d.seq),0,1,0),
   name_sort_key = cnvtupper(except->exceptions[d.seq].donor.name_full_formatted)
   FROM (dummyt d  WITH seq = value(nlstcnt))
   WHERE (except->exceptions[d.seq].exception_type_cd=dontemp)
    AND (((request->donation_location_cd=0)) OR ((request->donation_location_cd > 0)
    AND (request->donation_location_cd=except->exceptions[d.seq].facility_cd)))
    AND (((request->cur_owner_area_cd=0)) OR ((request->cur_owner_area_cd > 0)
    AND (request->cur_owner_area_cd=except->exceptions[d.seq].owner_cd)))
    AND (((request->cur_inv_area_cd=0)) OR ((request->cur_inv_area_cd > 0)
    AND (request->cur_inv_area_cd=except->exceptions[d.seq].inventory_cd)))
   ORDER BY owner_cd, inv_cd, dloc_cd,
    don_dt, name_sort_key
   HEAD REPORT
    row + 0, line1 = fillstring(24,"-"), line3 = fillstring(10,"-"),
    line2 = fillstring(8,"-"), first_owner = 1, first_inv = 1,
    first_dloc = 1
   HEAD PAGE
    row 0
    IF (seq_exists=1)
     cur_owner_area_disp = uar_get_code_display(except->exceptions[d.seq].owner_cd),
     cur_inv_area_disp = uar_get_code_display(except->exceptions[d.seq].inventory_cd), sdonloc =
     uar_get_code_display(except->exceptions[d.seq].facility_cd),
     sdonloc = concat(captions->sdonloc,": ",sdonloc)
    ENDIF
    CALL center(captions->inc_title,1,125), col 107, captions->inc_time,
    col 121, curtime"@TIMENOSECONDS;;m", row + 1,
    col 107, captions->inc_as_of_date, col 119,
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
    row + 1, dt_tm = cnvtdatetime(request->beg_dt_tm), col 32,
    captions->inc_beg_dt_tm, col 56, dt_tm"@DATECONDENSED;;d",
    col 64, dt_tm"@TIMENOSECONDS;;m", dt_tm = cnvtdatetime(request->end_dt_tm),
    col 74, captions->inc_end_dt_tm, col 92,
    dt_tm"@DATECONDENSED;;d", col 100, dt_tm"@TIMENOSECONDS;;m",
    row + 2, col 1, captions->inc_blood_bank_owner
    IF ((request->cur_owner_area_cd=0.0))
     cur_owner_area_disp = validate(last_owner_area_disp,cur_owner_area_disp)
    ENDIF
    col 19, cur_owner_area_disp, row + 1,
    col 1, captions->inc_inventory_area
    IF ((request->cur_inv_area_cd=0.0))
     cur_inv_area_disp = validate(last_inv_area_disp,cur_inv_area_disp)
    ENDIF
    col 17, cur_inv_area_disp, row + 2,
    row- (1), col 1, sdonloc,
    row + 2, col 1, captions->sdontemp,
    row + 2, col 1, captions->sname,
    row + 1, col 1, captions->sdonorid,
    col 27, captions->sdonation, col 37,
    captions->sprodnum, col 64, captions->sdt,
    col 74, captions->sdefer, row + 1,
    col 1, captions->sdobssn, col 27,
    captions->sdt, col 37, captions->sprod,
    col 64, captions->sdeferd, col 74,
    captions->suntil, col 86, captions->soverreas,
    col 112, captions->stech, row + 1,
    col 1, line1, col 27,
    line2, col 37, line1,
    col 64, line2, col 74,
    line3, col 86, line1,
    col 112, line3, row + 1
   HEAD owner_cd
    IF (first_owner=1)
     first_owner = 0
    ELSE
     first_inv = 1, first_dloc = 1, BREAK
    ENDIF
   HEAD inv_cd
    IF (first_inv=1)
     first_inv = 0
    ELSE
     first_dloc = 1, BREAK
    ENDIF
   HEAD dloc_cd
    IF (first_dloc=1)
     first_dloc = 0
    ELSE
     BREAK
    ENDIF
   DETAIL
    IF (row > 56)
     BREAK
    ENDIF
    sret = assignstring(except->exceptions[d.seq].donor.name_full_formatted,24), col 1, sret,
    dt = format(don_dt,"@SHORTDATE"), col 27, dt,
    sret = assignstring(except->exceptions[d.seq].product_nbr,24), col 37, sret,
    dt = format(except->exceptions[d.seq].deferred_dt_tm,"@SHORTDATE;;d"), col 64, dt,
    dt = format(except->exceptions[d.seq].defer_until_dt_tm,"@SHORTDATE;;d"), col 74, dt,
    sret = assignstring(except->exceptions[d.seq].override_reason_disp,24), col 86, sret,
    sret = assignstring(except->exceptions[d.seq].tech_username,10), col 112, sret,
    row + 1
    IF (row=57)
     BREAK
    ENDIF
    x = size(except->exceptions[d.seq].donor.aliases,5)
    FOR (n = 1 TO x)
      IF ((except->exceptions[d.seq].donor.aliases[n].alias_type_cd=ddonoridcd))
       sret = assignstring(except->exceptions[d.seq].donor.aliases[n].alias,24), col 1, sret,
       n = x
      ENDIF
    ENDFOR
    sret = assignstring(except->exceptions[d.seq].product_disp,24), col 37, sret,
    row + 1
    IF (row=57)
     BREAK
    ENDIF
    dt = format(except->exceptions[d.seq].donor.birth_dt_tm,"@SHORTDATE;;d"), col 1, dt
    FOR (n = 1 TO x)
      IF ((except->exceptions[d.seq].donor.aliases[n].alias_type_cd=dssncd))
       sret = assignstring(except->exceptions[d.seq].donor.aliases[n].alias,14), col 10, sret,
       n = x
      ENDIF
    ENDFOR
    row + 2
   FOOT  owner_cd
    row + 0
   FOOT  inv_cd
    row + 0
   FOOT  dloc_cd
    row + 0
   FOOT PAGE
    row 57, col 1,
"--------------------------------------------------------------------------------------------------------------------------\
----\
", row + 1, col 1, captions->inc_report_id,
    col 58, captions->inc_page, col 64,
    curpage"###", col 109, captions->inc_printed,
    col 119, curdate"@DATECONDENSED;;d", row + 1
   FOOT REPORT
    row 60, col 51, captions->end_of_report
  ;end select
 ENDIF
 IF ((request->exception_type_cd IN (ungtchg, 0.0)))
  SET nrptcnt = (nrptcnt+ 1)
  EXECUTE cpm_create_file_name_logical "bbd_dnrgtchg_except", "txt", "x"
  SET stat = alterlist(reply->rpt_list,nrptcnt)
  SET reply->rpt_list[nrptcnt].rpt_filename = cpm_cfn_info->file_name_path
  SET captions->inc_report_id = cpm_cfn_info->file_name
  SELECT
   IF ((request->null_report_ind=1))
    WITH nullreport, maxrow = 61, compress,
     nolandscape
   ELSE
    WITH nocounter, maxrow = 61, compress,
     nolandscape
   ENDIF
   INTO cpm_cfn_info->file_name_path
   except_dt_tm = except->exceptions[d.seq].exception_dt_tm, name_sort_key = cnvtupper(except->
    exceptions[d.seq].donor.name_full_formatted)
   FROM (dummyt d  WITH seq = value(nlstcnt))
   WHERE (except->exceptions[d.seq].exception_type_cd=ungtchg)
   ORDER BY name_sort_key
   HEAD REPORT
    row + 0, line1 = fillstring(15,"-"), line2 = fillstring(25,"-"),
    line3 = fillstring(12,"-"), line4 = fillstring(8,"-"), line5 = fillstring(29,"-"),
    line6 = fillstring(10,"-")
   HEAD PAGE
    CALL center(captions->inc_title,1,125), col 107, captions->inc_time,
    col 121, curtime"@TIMENOSECONDS;;m", row + 1,
    col 107, captions->inc_as_of_date, col 119,
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
    row + 1, dt_tm = cnvtdatetime(request->beg_dt_tm), col 32,
    captions->inc_beg_dt_tm, col 56, dt_tm"@DATECONDENSED;;d",
    col 64, dt_tm"@TIMENOSECONDS;;m", dt_tm = cnvtdatetime(request->end_dt_tm),
    col 74, captions->inc_end_dt_tm, col 92,
    dt_tm"@DATECONDENSED;;d", col 100, dt_tm"@TIMENOSECONDS;;m",
    row + 2, col 1, captions->sdnrgtchg,
    row + 2, col 1, captions->sname,
    col 47, captions->sprev, col 72,
    captions->scur, row + 1, col 1,
    captions->sdonorid, col 33, captions->sdt,
    col 45, captions->sdemog, col 59,
    captions->sresultd, col 69, captions->sdemog,
    col 88, captions->soverreas, col 117,
    captions->stech, row + 1, col 1,
    line2, col 28, line1,
    col 45, line3, col 59,
    line4, col 69, line3,
    col 83, line5, col 114,
    line6, row + 1
   DETAIL
    IF (row > 56)
     BREAK
    ENDIF
    sret = assignstring(except->exceptions[d.seq].donor.name_full_formatted,25), col 1, sret,
    col 28, except_dt_tm"@DATECONDENSED;;d", col 37,
    except_dt_tm"@TIMENOSECONDS;;m", sret = concat(except->exceptions[d.seq].from_abo_disp," ",except
     ->exceptions[d.seq].from_rh_disp), sret = assignstring(sret,12),
    col 45, sret, sret = concat(except->exceptions[d.seq].to_abo_disp," ",except->exceptions[d.seq].
     to_rh_disp),
    sret = assignstring(sret,8), col 59, sret,
    sret = concat(except->exceptions[d.seq].donor.abo_disp," ",except->exceptions[d.seq].donor.
     rh_disp), sret = assignstring(sret,12), col 69,
    sret, sret = assignstring(except->exceptions[d.seq].override_reason_disp,29), col 83,
    sret, sret = assignstring(except->exceptions[d.seq].tech_username,10), col 114,
    sret, row + 1
    IF (row=57)
     BREAK
    ENDIF
    x = size(except->exceptions[d.seq].donor.aliases,5)
    FOR (n = 1 TO x)
      IF ((except->exceptions[d.seq].donor.aliases[n].alias_type_cd=ddonoridcd))
       sret = assignstring(except->exceptions[d.seq].donor.aliases[n].alias,25), col 1, sret,
       n = x
      ENDIF
    ENDFOR
    row + 2
   FOOT PAGE
    row 57, col 1,
"--------------------------------------------------------------------------------------------------------------------------\
----\
", row + 1, col 1, captions->inc_report_id,
    col 58, captions->inc_page, col 64,
    curpage"###", col 109, captions->inc_printed,
    col 119, curdate"@DATECONDENSED;;d", row + 1
   FOOT REPORT
    row 60, col 51, captions->end_of_report
  ;end select
 ENDIF
 IF ((request->exception_type_cd IN (ungtnochg, 0.0)))
  SET nrptcnt = (nrptcnt+ 1)
  EXECUTE cpm_create_file_name_logical "bbd_dnrgtnochg_except", "txt", "x"
  SET stat = alterlist(reply->rpt_list,nrptcnt)
  SET reply->rpt_list[nrptcnt].rpt_filename = cpm_cfn_info->file_name_path
  SET captions->inc_report_id = cpm_cfn_info->file_name
  SELECT
   IF ((request->null_report_ind=1))
    WITH nullreport, maxrow = 61, compress,
     nolandscape
   ELSE
    WITH nocounter, maxrow = 61, compress,
     nolandscape
   ENDIF
   INTO cpm_cfn_info->file_name_path
   except_dt_tm = except->exceptions[d.seq].exception_dt_tm, name_sort_key = cnvtupper(except->
    exceptions[d.seq].donor.name_full_formatted)
   FROM (dummyt d  WITH seq = value(nlstcnt))
   WHERE (except->exceptions[d.seq].exception_type_cd=ungtnochg)
   ORDER BY name_sort_key
   HEAD REPORT
    row + 0, line1 = fillstring(15,"-"), line2 = fillstring(25,"-"),
    line3 = fillstring(12,"-"), line4 = fillstring(8,"-"), line5 = fillstring(29,"-"),
    line6 = fillstring(10,"-")
   HEAD PAGE
    CALL center(captions->inc_title,1,125), col 107, captions->inc_time,
    col 121, curtime"@TIMENOSECONDS;;m", row + 1,
    col 107, captions->inc_as_of_date, col 119,
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
    row + 1, dt_tm = cnvtdatetime(request->beg_dt_tm), col 32,
    captions->inc_beg_dt_tm, col 56, dt_tm"@DATECONDENSED;;d",
    col 64, dt_tm"@TIMENOSECONDS;;m", dt_tm = cnvtdatetime(request->end_dt_tm),
    col 74, captions->inc_end_dt_tm, col 92,
    dt_tm"@DATECONDENSED;;d", col 100, dt_tm"@TIMENOSECONDS;;m",
    row + 2, col 1, captions->sdnrgtnochg,
    row + 2, col 1, captions->sname,
    col 47, captions->sprev, col 72,
    captions->scur, row + 1, col 1,
    captions->sdonorid, col 33, captions->sdt,
    col 45, captions->sdemog, col 59,
    captions->sresultd, col 69, captions->sdemog,
    col 88, captions->soverreas, col 117,
    captions->stech, row + 1, col 1,
    line2, col 28, line1,
    col 45, line3, col 59,
    line4, col 69, line3,
    col 83, line5, col 114,
    line6, row + 1
   DETAIL
    IF (row > 56)
     BREAK
    ENDIF
    sret = assignstring(except->exceptions[d.seq].donor.name_full_formatted,25), col 1, sret,
    col 28, except_dt_tm"@DATECONDENSED;;d", col 37,
    except_dt_tm"@TIMENOSECONDS;;m", sret = concat(except->exceptions[d.seq].donor.abo_disp," ",
     except->exceptions[d.seq].donor.rh_disp), sret = assignstring(sret,12),
    col 45, sret, sret = concat(except->exceptions[d.seq].to_abo_disp," ",except->exceptions[d.seq].
     to_rh_disp),
    sret = assignstring(sret,8), col 59, sret,
    sret = concat(except->exceptions[d.seq].donor.abo_disp," ",except->exceptions[d.seq].donor.
     rh_disp), sret = assignstring(sret,12), col 69,
    sret, sret = assignstring(except->exceptions[d.seq].override_reason_disp,29), col 83,
    sret, sret = assignstring(except->exceptions[d.seq].tech_username,10), col 114,
    sret, row + 1
    IF (row=57)
     BREAK
    ENDIF
    x = size(except->exceptions[d.seq].donor.aliases,5)
    FOR (n = 1 TO x)
      IF ((except->exceptions[d.seq].donor.aliases[n].alias_type_cd=ddonoridcd))
       sret = assignstring(except->exceptions[d.seq].donor.aliases[n].alias,25), col 1, sret,
       n = x
      ENDIF
    ENDFOR
    row + 2
   FOOT PAGE
    row 57, col 1,
"--------------------------------------------------------------------------------------------------------------------------\
----\
", row + 1, col 1, captions->inc_report_id,
    col 58, captions->inc_page, col 64,
    curpage"###", col 109, captions->inc_printed,
    col 119, curdate"@DATECONDENSED;;d", row + 1
   FOOT REPORT
    row 60, col 51, captions->end_of_report
  ;end select
 ENDIF
 IF ((request->exception_type_cd IN (regeligrein, 0.0)))
  SET nrptcnt = (nrptcnt+ 1)
  EXECUTE cpm_create_file_name_logical "bbd_regeligrein_except", "txt", "x"
  SET stat = alterlist(reply->rpt_list,nrptcnt)
  SET reply->rpt_list[nrptcnt].rpt_filename = cpm_cfn_info->file_name_path
  SET captions->inc_report_id = cpm_cfn_info->file_name
  SELECT
   IF ((request->null_report_ind=1))
    WITH nullreport, maxrow = 61, compress,
     nolandscape, maxcol = 136
   ELSE
    WITH nocounter, maxrow = 61, compress,
     nolandscape, maxcol = 136
   ENDIF
   INTO cpm_cfn_info->file_name_path
   reg_dt_tm = except->exceptions[d.seq].don_reg_result_dt_tm, deferral_meaning =
   uar_get_code_meaning(except->exceptions[d.seq].eligibility_type_cd), name_sort_key = cnvtupper(
    except->exceptions[d.seq].donor.name_full_formatted)
   FROM (dummyt d  WITH seq = value(nlstcnt))
   WHERE (except->exceptions[d.seq].exception_type_cd=regeligrein)
   ORDER BY except->exceptions[d.seq].don_reg_result_dt_tm, name_sort_key
   HEAD REPORT
    row + 0, line1 = fillstring(24,"-"), line2 = fillstring(12,"-"),
    line3 = fillstring(21,"-"), line4 = fillstring(8,"-"), line5 = fillstring(10,"-")
   HEAD PAGE
    CALL center(captions->inc_title,1,125), col 107, captions->inc_time,
    col 121, curtime"@TIMENOSECONDS;;m", row + 1,
    col 107, captions->inc_as_of_date, col 119,
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
    row + 1, dt_tm = cnvtdatetime(request->beg_dt_tm), col 32,
    captions->inc_beg_dt_tm, col 56, dt_tm"@DATECONDENSED;;d",
    col 64, dt_tm"@TIMENOSECONDS;;m", dt_tm = cnvtdatetime(request->end_dt_tm),
    col 74, captions->inc_end_dt_tm, col 92,
    dt_tm"@DATECONDENSED;;d", col 100, dt_tm"@TIMENOSECONDS;;m",
    row + 2, col 1, captions->sregelig,
    row + 2, col 1, captions->sname,
    row + 1, col 1, captions->sdonorid,
    col 27, captions->sreg, col 64,
    captions->sdt, col 74, captions->sdefer,
    col 86, captions->sdeferl, row + 1,
    col 1, captions->sdobssn, col 27,
    captions->sdttm, col 41, captions->sprocedure,
    col 64, captions->sdeferd, col 74,
    captions->suntil, col 86, captions->stype,
    col 98, captions->soverreas, col 124,
    captions->stech, row + 1, col 1,
    line1, col 27, line2,
    col 41, line3, col 64,
    line4, col 74, line5,
    col 86, line5, col 98,
    line1, col 124, line4,
    row + 1
   DETAIL
    IF (row > 56)
     BREAK
    ENDIF
    sret = assignstring(except->exceptions[d.seq].donor.name_full_formatted,24), col 1, sret,
    dt = format(reg_dt_tm,"@SHORTDATE;;d"), col 27, dt,
    sret = assignstring(except->exceptions[d.seq].procedure_disp,21), col 41, sret,
    dt = format(except->exceptions[d.seq].deferred_dt_tm,"@SHORTDATE;;d"), col 64, dt
    IF (deferral_meaning="PERMNENT")
     sret = assignstring(except->exceptions[d.seq].eligibility_type_disp,10), col 74, sret
    ELSE
     dt = format(except->exceptions[d.seq].defer_until_dt_tm,"@SHORTDATE;;d"), col 74, dt
    ENDIF
    sret = assignstring(except->exceptions[d.seq].eligibility_type_disp,10), col 86, sret,
    sret = assignstring(except->exceptions[d.seq].override_reason_disp,24), col 98, sret,
    sret = assignstring(except->exceptions[d.seq].tech_username,8), col 124, sret,
    row + 1
    IF (row=57)
     BREAK
    ENDIF
    x = size(except->exceptions[d.seq].donor.aliases,5)
    FOR (n = 1 TO x)
      IF ((except->exceptions[d.seq].donor.aliases[n].alias_type_cd=ddonoridcd))
       sret = assignstring(except->exceptions[d.seq].donor.aliases[n].alias,24), col 1, sret,
       n = x
      ENDIF
    ENDFOR
    col 27, reg_dt_tm"@TIMENOSECONDS;;m", row + 1
    IF (row=57)
     BREAK
    ENDIF
    dt = format(except->exceptions[d.seq].donor.birth_dt_tm,"@SHORTDATE;;d"), col 1, dt
    FOR (n = 1 TO x)
      IF ((except->exceptions[d.seq].donor.aliases[n].alias_type_cd=dssncd))
       sret = assignstring(except->exceptions[d.seq].donor.aliases[n].alias,14), col 10, sret,
       n = x
      ENDIF
    ENDFOR
    row + 2
   FOOT PAGE
    row 57, col 1,
"--------------------------------------------------------------------------------------------------------------------------\
----\
", row + 1, col 1, captions->inc_report_id,
    col 58, captions->inc_page, col 64,
    curpage"###", col 109, captions->inc_printed,
    col 119, curdate"@DATECONDENSED;;d", row + 1
   FOOT REPORT
    row 60, col 51, captions->end_of_report
  ;end select
 ENDIF
 IF ((request->exception_type_cd IN (doninterview, 0.0)))
  SET nrptcnt = (nrptcnt+ 1)
  EXECUTE cpm_create_file_name_logical "bbd_doninterview_except", "txt", "x"
  SET stat = alterlist(reply->rpt_list,nrptcnt)
  SET reply->rpt_list[nrptcnt].rpt_filename = cpm_cfn_info->file_name_path
  SET captions->inc_report_id = cpm_cfn_info->file_name
  SELECT
   IF ((request->null_report_ind=1))
    WITH nullreport, maxrow = 61, compress,
     nolandscape, maxcol = 136
   ELSE
    WITH nocounter, maxrow = 61, compress,
     nolandscape, maxcol = 136
   ENDIF
   INTO cpm_cfn_info->file_name_path
   don_dt = cnvtdate(except->exceptions[d.seq].don_reg_result_dt_tm), owner_cd = except->exceptions[d
   .seq].owner_cd, inv_cd = except->exceptions[d.seq].inventory_cd,
   dloc_cd = except->exceptions[d.seq].facility_cd, seq_exists = evaluate(nullind(d.seq),0,1,0),
   name_sort_key = cnvtupper(except->exceptions[d.seq].donor.name_full_formatted)
   FROM (dummyt d  WITH seq = value(nlstcnt))
   WHERE (except->exceptions[d.seq].exception_type_cd=doninterview)
    AND (((request->donation_location_cd=0)) OR ((request->donation_location_cd > 0)
    AND (request->donation_location_cd=except->exceptions[d.seq].facility_cd)))
    AND (((request->cur_owner_area_cd=0)) OR ((request->cur_owner_area_cd > 0)
    AND (request->cur_owner_area_cd=except->exceptions[d.seq].owner_cd)))
    AND (((request->cur_inv_area_cd=0)) OR ((request->cur_inv_area_cd > 0)
    AND (request->cur_inv_area_cd=except->exceptions[d.seq].inventory_cd)))
   ORDER BY owner_cd, inv_cd, dloc_cd,
    don_dt, name_sort_key
   HEAD REPORT
    row + 0, line1 = fillstring(24,"-"), line2 = fillstring(21,"-"),
    line3 = fillstring(12,"-"), line4 = fillstring(15,"-"), first_owner = 1,
    first_inv = 1, first_dloc = 1
   HEAD PAGE
    row 0
    IF (seq_exists=1)
     cur_owner_area_disp = uar_get_code_display(except->exceptions[d.seq].owner_cd),
     cur_inv_area_disp = uar_get_code_display(except->exceptions[d.seq].inventory_cd), sdonloc =
     uar_get_code_display(except->exceptions[d.seq].facility_cd),
     sdonloc = concat(captions->sdonloc,": ",sdonloc)
    ENDIF
    CALL center(captions->inc_title,1,125), col 107, captions->inc_time,
    col 121, curtime"@TIMENOSECONDS;;m", row + 1,
    col 107, captions->inc_as_of_date, col 119,
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
    row + 1, dt_tm = cnvtdatetime(request->beg_dt_tm), col 32,
    captions->inc_beg_dt_tm, col 56, dt_tm"@DATECONDENSED;;d",
    col 64, dt_tm"@TIMENOSECONDS;;m", dt_tm = cnvtdatetime(request->end_dt_tm),
    col 74, captions->inc_end_dt_tm, col 92,
    dt_tm"@DATECONDENSED;;d", col 100, dt_tm"@TIMENOSECONDS;;m",
    row + 2, col 1, captions->inc_blood_bank_owner
    IF ((request->cur_owner_area_cd=0.0))
     cur_owner_area_disp = validate(last_owner_area_disp,cur_owner_area_disp)
    ENDIF
    col 19, cur_owner_area_disp, row + 1,
    col 1, captions->inc_inventory_area
    IF ((request->cur_inv_area_cd=0.0))
     cur_inv_area_disp = validate(last_inv_area_disp,cur_inv_area_disp)
    ENDIF
    col 17, cur_inv_area_disp, row + 2,
    row- (1), col 1, sdonloc,
    row + 2, col 1, captions->sdonnbrupd,
    row + 2, col 1, captions->sname,
    row + 1, col 1, captions->sdonorid,
    col 27, captions->sdonation, col 41,
    captions->sprodnum, col 64, captions->sprev,
    col 87, captions->scur, row + 1,
    col 1, captions->sdobssn, col 27,
    captions->sdt, col 41, captions->sprod,
    col 64, captions->sdonnbr, col 87,
    captions->sdonnbr, col 110, captions->stech,
    row + 1, col 1, line1,
    col 27, line3, col 41,
    line2, col 64, line2,
    col 87, line2, col 110,
    line4, row + 1
   HEAD owner_cd
    IF (first_owner=1)
     first_owner = 0
    ELSE
     first_inv = 1, first_dloc = 1, BREAK
    ENDIF
   HEAD inv_cd
    IF (first_inv=1)
     first_inv = 0
    ELSE
     first_dloc = 1, BREAK
    ENDIF
   HEAD dloc_cd
    IF (first_dloc=1)
     first_dloc = 0
    ELSE
     BREAK
    ENDIF
   DETAIL
    IF (row > 56)
     BREAK
    ENDIF
    sret = assignstring(except->exceptions[d.seq].donor.name_full_formatted,24), col 1, sret,
    dt = assignstring(format(don_dt,"@SHORTDATE"),12), col 27, dt,
    sret = assignstring(except->exceptions[d.seq].product_nbr,21), col 41, sret,
    sret = assignstring(except->exceptions[d.seq].donation_ident_old,21), col 64, sret,
    sret = assignstring(except->exceptions[d.seq].donation_ident_curr,21), col 87, sret,
    sret = assignstring(except->exceptions[d.seq].tech_username,15), col 110, sret,
    row + 1
    IF (row=57)
     BREAK
    ENDIF
    x = size(except->exceptions[d.seq].donor.aliases,5)
    FOR (n = 1 TO x)
      IF ((except->exceptions[d.seq].donor.aliases[n].alias_type_cd=ddonoridcd))
       sret = assignstring(except->exceptions[d.seq].donor.aliases[n].alias,24), col 1, sret,
       n = x
      ENDIF
    ENDFOR
    sret = assignstring(except->exceptions[d.seq].product_disp,21), col 41, sret,
    row + 1
    IF (row=57)
     BREAK
    ENDIF
    dt = assignstring(format(except->exceptions[d.seq].donor.birth_dt_tm,"@SHORTDATE;;d"),8), col 1,
    dt
    FOR (n = 1 TO x)
      IF ((except->exceptions[d.seq].donor.aliases[n].alias_type_cd=dssncd))
       sret = assignstring(except->exceptions[d.seq].donor.aliases[n].alias,14), col 10, sret,
       n = x
      ENDIF
    ENDFOR
    row + 2
   FOOT  owner_cd
    row + 0
   FOOT  inv_cd
    row + 0
   FOOT  dloc_cd
    row + 0
   FOOT PAGE
    row 57, col 1,
"--------------------------------------------------------------------------------------------------------------------------\
----\
", row + 1, col 1, captions->inc_report_id,
    col 58, captions->inc_page, col 64,
    curpage"###", col 109, captions->inc_printed,
    col 119, curdate"@DATECONDENSED;;d", row + 1
   FOOT REPORT
    row 60, col 51, captions->end_of_report
  ;end select
 ENDIF
 IF (bopscall=1)
  IF (checkqueue(request->output_dist)=1)
   FOR (n = 1 TO nrptcnt)
     SET spool value(reply->rpt_list[n].rpt_filename) value(trim(request->output_dist))
   ENDFOR
  ELSE
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Exception Reporting"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Print checkqueue failed"
   SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_rpt_exceptions"
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
END GO
