CREATE PROGRAM bbd_rpt_auto_dir_donations:dba
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
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
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
 FREE SET temp
 RECORD temp(
   1 qual[*]
     2 donation_date = dq8
     2 donation_type = c12
     2 donor = c22
     2 donor_id = c12
     2 donor_ssn = c12
     2 person_id = f8
     2 contact_id = f8
     2 encntr_id = f8
     2 recipient = c22
     2 recipient_mrn = c22
     2 product_nbr = c25
     2 product_type = c25
     2 product_aborh = c10
     2 recipient_aborh = c10
     2 expiration_date = dq8
     2 date_needed = dq8
     2 cur_owner_area_cd = f8
     2 cur_inv_area_cd = f8
     2 donation_location_cd = f8
 )
 FREE SET list
 RECORD list(
   1 qual[*]
     2 value = f8
 )
 SET modify = predeclare
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE dstart = i4 WITH protect, noconstant(0)
 DECLARE listsize = i4 WITH protect, noconstant(0)
 DECLARE start_index = i4 WITH protect, noconstant(1)
 DECLARE occurrences = i4 WITH protect, noconstant(100)
 DECLARE remaining = i4 WITH protect, noconstant(0)
 DECLARE temp_list[100] = f8 WITH protect, noconstant(0.0)
 DECLARE begday = dq8 WITH protect, noconstant(cnvtdatetime("01-jan-1900 00:00"))
 DECLARE endday = dq8 WITH protect, noconstant(cnvtdatetime("01-jan-1900 00:00"))
 DECLARE temp_string = vc WITH protect, noconstant(fillstring(50," "))
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE script_name = c27 WITH protect, constant("bbd_rpt_auto_dir_donations")
 DECLARE ssn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"SSN"))
 DECLARE id_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"DONORID"))
 DECLARE mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE bed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"BED"))
 DECLARE building_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"BUILDING"))
 DECLARE facility_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE nurse_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"NURSEUNIT"))
 DECLARE room_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",222,"ROOM"))
 DECLARE line8 = c8 WITH protect, constant(fillstring(8,"-"))
 DECLARE line22 = c22 WITH protect, constant(fillstring(22,"-"))
 DECLARE line21 = c21 WITH protect, constant(fillstring(21,"-"))
 DECLARE line12 = c12 WITH protect, constant(fillstring(12,"-"))
 DECLARE line17 = c17 WITH protect, constant(fillstring(17,"-"))
 DECLARE line14 = c14 WITH protect, constant(fillstring(14,"-"))
 DECLARE line25 = c25 WITH protect, constant(fillstring(25,"-"))
 DECLARE line131 = c131 WITH protect, constant(fillstring(131,"-"))
 DECLARE start_date = dq8 WITH protect, constant(cnvtdatetime("01-jan-1900 00:00"))
 DECLARE def_donation_type = c17 WITH protect, constant("Not Specified")
 SET reply->status_data.status = "Z"
 IF (((ssn_cd=0.0) OR (((id_cd=0.0) OR (((mrn_cd=0.0) OR (((bed_cd=0.0) OR (((building_cd=0.0) OR (((
 facility_cd=0.0) OR (((nurse_cd=0.0) OR (room_cd=0.0)) )) )) )) )) )) )) )
  SET reply->status_data.status = "F"
  CALL subevent_add("bbd_rpt_auto_dir_donations.prg","F","uar_get_code_by",
   "Unable to retrieve the code_value for the cdf_meanings in code_sets 4 and 222.")
  GO TO exit_script
 ENDIF
 SET modify = nopredeclare
 IF (size(trim(request->batch_selection)) > 0)
  SET begday = request->ops_date
  SET endday = request->ops_date
  SET temp_string = cnvtupper(trim(request->batch_selection))
  CALL check_opt_date_passed(script_name)
  IF ((reply->status_data.status != "F"))
   SET request->beg_dt_tm = begday
   SET request->end_dt_tm = endday
  ENDIF
  CALL check_owner_cd(script_name)
  CALL check_inventory_cd(script_name)
  CALL check_donation_location(script_name)
  CALL check_location_cd(script_name)
  CALL check_null_report(script_name)
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
 SET modify = predeclare
 SET reply->status_data.status = "F"
 CALL uar_get_code_list_by_meaning(14219,"AUTO",start_index,occurrences,remaining,
  temp_list)
 SET stat = alterlist(list->qual,occurrences)
 FOR (index = 1 TO occurrences)
   SET list->qual[index].value = temp_list[index]
 ENDFOR
 WHILE (remaining > 0)
   SET occurrences = size(temp_list,5)
   SET start_index = (start_index+ occurrences)
   CALL uar_get_code_list_by_meaning(14219,"AUTO",start_index,occurrences,remaining,
    temp_list)
   SET stat = alterlist(list->qual,(occurrences+ start_index))
   FOR (index = 1 TO occurrences)
     SET list->qual[((index+ start_index) - 1)].value = temp_list[index]
   ENDFOR
 ENDWHILE
 SET occurrences = 100
 CALL uar_get_code_list_by_meaning(14219,"DIRECTED",start_index,occurrences,remaining,
  temp_list)
 SET listsize = size(list->qual,5)
 SET stat = alterlist(list->qual,(occurrences+ listsize))
 FOR (index = 1 TO occurrences)
   SET list->qual[(index+ listsize)].value = temp_list[index]
 ENDFOR
 WHILE (remaining > 0)
   SET occurrences = size(temp_list,5)
   SET start_index = (start_index+ occurrences)
   CALL uar_get_code_list_by_meaning(14219,"DIRECTED",start_index,occurrences,remaining,
    temp_list)
   SET stat = alterlist(list->qual,(occurrences+ start_index))
   FOR (index = 1 TO occurrences)
     SET list->qual[((index+ start_index) - 1)].value = temp_list[index]
   ENDFOR
 ENDWHILE
 IF (size(list->qual,5) <= 0)
  SET reply->status_data.status = "F"
  CALL subevent_add("bbd_rpt_auto_dir_donations.prg","F","uar_get_code_list_by_meaning",
   "Unable to retrieve the code_value for the autologous and directed cdf_meanings in code_set 14219."
   )
  GO TO exit_script
 ENDIF
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
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 as_of_date = vc
   1 beg_date = vc
   1 end_date = vc
   1 rpt_owner = vc
   1 rpt_all = vc
   1 rpt_inv_area = vc
   1 rpt_don_loc = vc
   1 rpt_don_date = vc
   1 rpt_proc_type = vc
   1 rpt_donor = vc
   1 rpt_donor_id = vc
   1 rpt_don_ssn = vc
   1 rpt_recip = vc
   1 rpt_mrn = vc
   1 rpt_auto_dons = vc
   1 rpt_dir_dons = vc
   1 rpt_prod_nbr = vc
   1 rpt_aborh = vc
   1 rpt_expire = vc
   1 rpt_date = vc
   1 rpt_date_time = vc
   1 rpt_needed = vc
   1 rpt_title = vc
   1 rpt_page = vc
   1 rpt_time = vc
   1 head_products = vc
   1 end_of_report = vc
 )
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","As Of Date:")
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title","AUTOLOGOUS/DIRECTED DONATIONS")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->beg_date = uar_i18ngetmessage(i18nhandle,"beg_date","Beginning Date:")
 SET captions->end_date = uar_i18ngetmessage(i18nhandle,"end_date","Ending Date:")
 SET captions->rpt_owner = uar_i18ngetmessage(i18nhandle,"rpt_owner","Blood Bank Owner:")
 SET captions->rpt_inv_area = uar_i18ngetmessage(i18nhandle,"rpt_inv_area","Inventory Area:")
 SET captions->rpt_don_loc = uar_i18ngetmessage(i18nhandle,"rpt_don_loc","Donation Location:")
 SET captions->rpt_don_date = uar_i18ngetmessage(i18nhandle,"rpt_don_date","Donation Date")
 SET captions->rpt_proc_type = uar_i18ngetmessage(i18nhandle,"rpt_proc_type","Procedure Type")
 SET captions->rpt_donor = uar_i18ngetmessage(i18nhandle,"rpt_donor","Donor")
 SET captions->rpt_donor_id = uar_i18ngetmessage(i18nhandle,"rpt_donor_id","Donor ID")
 SET captions->rpt_don_ssn = uar_i18ngetmessage(i18nhandle,"rpt_don_ssn","SSN")
 SET captions->rpt_recip = uar_i18ngetmessage(i18nhandle,"rpt_recip","Recipient")
 SET captions->rpt_mrn = uar_i18ngetmessage(i18nhandle,"rpt_mrn","MRN")
 SET captions->rpt_auto_dons = uar_i18ngetmessage(i18nhandle,"rpt_auto_dons","AUTOLOGOUS DONATIONS")
 SET captions->rpt_dir_dons = uar_i18ngetmessage(i18nhandle,"rpt_dir_dons","DIRECTED DONATIONS")
 SET captions->rpt_prod_nbr = uar_i18ngetmessage(i18nhandle,"rpt_prod_nbr","Product Number")
 SET captions->rpt_aborh = uar_i18ngetmessage(i18nhandle,"rpt_aborh","ABO/Rh")
 SET captions->rpt_expire = uar_i18ngetmessage(i18nhandle,"rpt_expire","Expiration")
 SET captions->rpt_date = uar_i18ngetmessage(i18nhandle,"rpt_date","Date")
 SET captions->rpt_date_time = uar_i18ngetmessage(i18nhandle,"rpt_date_time","Date and Time")
 SET captions->rpt_needed = uar_i18ngetmessage(i18nhandle,"rpt_needed","Needed")
 SET captions->rpt_all = uar_i18ngetmessage(i18nhandle,"rpt_all","(All)")
 SET captions->head_products = uar_i18ngetmessage(i18nhandle,"head_products","Product")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report","*** End of Report ***")
 SELECT
  bdr_procedure_disp = substring(1,12,uar_get_code_display(bdr.procedure_cd)), product_number =
  substring(1,25,concat(trim(prod.product_nbr)," ",trim(prod.product_sub_nbr))), prod_product_disp =
  substring(1,25,uar_get_code_display(prod.product_cd)),
  prod_aborh = substring(1,10,concat(trim(uar_get_code_display(bp.cur_abo_cd))," ",trim(
     uar_get_code_display(bp.cur_rh_cd)))), drawn_date = cnvtdate(bdr.drawn_dt_tm), alias = substring
  (1,21,cnvtalias(pa.alias,pa.alias_pool_cd)),
  recip_aborh = substring(1,10,concat(trim(uar_get_code_display(pab.abo_cd))," ",trim(
     uar_get_code_display(pab.rh_cd)))), recipient = substring(1,21,p1.name_full_formatted), donor =
  substring(1,22,p.name_full_formatted),
  prod.cur_owner_area_cd, prod.cur_inv_area_cd, e.location_cd
  FROM bbd_donation_results bdr,
   bbd_don_product_r bdp,
   product prod,
   blood_product bp,
   bbd_donor_contact bdc,
   person p,
   encounter e,
   encntr_person_reltn ep,
   person p1,
   person_alias pa,
   person_aborh pab
  PLAN (bdr
   WHERE expand(index,1,size(list->qual,5),bdr.procedure_cd,list->qual[index].value)
    AND bdr.drawn_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm)
   )
   JOIN (bdp
   WHERE bdp.donation_results_id=bdr.donation_result_id)
   JOIN (prod
   WHERE prod.product_id=bdp.product_id
    AND (((request->cur_inv_area_cd != 0.0)
    AND (prod.cur_inv_area_cd=request->cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0)))
    AND (((request->cur_owner_area_cd != 0.0)
    AND (prod.cur_owner_area_cd=request->cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0))) )
   JOIN (bp
   WHERE bp.product_id=prod.product_id)
   JOIN (bdc
   WHERE bdc.contact_id=bdr.contact_id)
   JOIN (p
   WHERE p.person_id=outerjoin(bdc.person_id))
   JOIN (e
   WHERE e.encntr_id=bdr.encntr_id
    AND (((request->donation_location_cd=e.loc_facility_cd)) OR ((request->donation_location_cd=0.0)
   )) )
   JOIN (ep
   WHERE ep.encntr_id=outerjoin(e.encntr_id)
    AND ep.end_effective_dt_tm=cnvtdatetime("31-dec-2100 00:00:00"))
   JOIN (p1
   WHERE p1.person_id=outerjoin(ep.related_person_id))
   JOIN (pa
   WHERE pa.person_id=outerjoin(p1.person_id)
    AND pa.person_alias_type_cd=outerjoin(mrn_cd))
   JOIN (pab
   WHERE pab.person_id=outerjoin(p1.person_id))
  ORDER BY prod.cur_owner_area_cd, prod.cur_inv_area_cd, e.loc_facility_cd,
   drawn_date, bdr_procedure_disp, p.name_last,
   p.name_first
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(temp->qual,(count+ 9))
   ENDIF
   temp->qual[count].donation_type = bdr_procedure_disp, temp->qual[count].donation_date = drawn_date,
   temp->qual[count].product_nbr = product_number,
   temp->qual[count].product_type = prod_product_disp, temp->qual[count].product_aborh = prod_aborh,
   temp->qual[count].contact_id = bdr.contact_id,
   temp->qual[count].encntr_id = bdr.encntr_id, temp->qual[count].expiration_date = prod
   .cur_expire_dt_tm, temp->qual[count].contact_id = bdc.contact_id,
   temp->qual[count].donor = donor, temp->qual[count].date_needed = bdc.needed_dt_tm, temp->qual[
   count].person_id = p.person_id,
   temp->qual[count].cur_owner_area_cd = prod.cur_owner_area_cd, temp->qual[count].cur_inv_area_cd =
   prod.cur_inv_area_cd, temp->qual[count].recipient = recipient,
   temp->qual[count].recipient_aborh = recip_aborh, temp->qual[count].recipient_mrn = alias, temp->
   qual[count].donation_location_cd = e.loc_facility_cd,
   temp->qual[count].donor_id = fillstring(14," "), temp->qual[count].donor_ssn = fillstring(14," ")
  FOOT REPORT
   stat = alterlist(temp->qual,count)
  WITH nocounter, separator = " ", format
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  SET reply->status_data.status = "F"
  CALL subevent_add("Select autologous and directed donations.","F","bbd_rpt_auto_dir_donations.prg",
   errmsg)
  GO TO exit_script
 ENDIF
 EXECUTE cpm_create_file_name_logical "bbd_auto_dir_dons", "txt", "x"
 IF (size(temp->qual,5) > 0)
  SELECT
   alias = substring(1,12,cnvtalias(pa.alias,pa.alias_pool_cd))
   FROM person_alias pa
   PLAN (pa
    WHERE expand(index,1,size(temp->qual,5),pa.person_id,temp->qual[index].person_id)
     AND pa.person_alias_type_cd IN (ssn_cd, id_cd))
   DETAIL
    pos = 0, pos = locateval(index,1,size(temp->qual,5),pa.person_id,temp->qual[index].person_id)
    WHILE (pos != 0)
     IF (pa.person_alias_type_cd=ssn_cd)
      temp->qual[pos].donor_ssn = alias
     ELSE
      temp->qual[pos].donor_id = alias
     ENDIF
     ,pos = locateval(index,(pos+ 1),size(temp->qual,5),pa.person_id,temp->qual[index].person_id)
    ENDWHILE
   WITH nocounter, separator = " ", format
  ;end select
  SET error_check = error(errmsg,0)
  IF (error_check != 0)
   SET reply->status_data.status = "F"
   CALL subevent_add("Select donor id and ssn.","F","bbd_rpt_auto_dir_donations.prg",errmsg)
   GO TO exit_script
  ENDIF
  SELECT INTO cpm_cfn_info->file_name_logical
   p_inv_area = uar_get_code_display(temp->qual[d.seq].cur_inv_area_cd), p_owner_area =
   uar_get_code_display(temp->qual[d.seq].cur_owner_area_cd), p_don_loc = uar_get_code_display(temp->
    qual[d.seq].donation_location_cd)
   FROM (dummyt d  WITH seq = size(temp->qual,5))
   PLAN (d
    WHERE d.seq > 0.0)
   HEAD REPORT
    row + 0
   HEAD PAGE
    date = start_date, donation_type = def_donation_type, row 0,
    CALL center(captions->rpt_title,1,125), col 110, captions->rpt_time,
    col 122, curtime, row + 1,
    col 110, captions->as_of_date, col 122,
    curdate"@DATECONDENSED;;d", save_row = row, inc_i18nhandle = 0,
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
    IF (save_row > row)
     row save_row
    ENDIF
    row + 1, col 30, captions->beg_date,
    col 46, request->beg_dt_tm"@DATETIMECONDENSED;;d", col 72,
    captions->end_date, col 85, request->end_dt_tm"@DATETIMECONDENSED;;d",
    row + 2, col 0, captions->rpt_owner,
    col 18, p_owner_area, owner = temp->qual[d.seq].cur_owner_area_cd,
    row + 1, col 0, captions->rpt_inv_area,
    col 18, p_inv_area, inv_area = temp->qual[d.seq].cur_inv_area_cd,
    row + 1, col 0, captions->rpt_don_loc,
    col 20, p_don_loc, don_loc = temp->qual[d.seq].donation_location_cd,
    row + 2, col 0, captions->rpt_don_date,
    row + 1, col 0, captions->rpt_proc_type,
    col 23, captions->rpt_donor_id, col 36,
    captions->rpt_recip, col 58, captions->rpt_prod_nbr,
    col 89, captions->rpt_aborh, col 103,
    captions->rpt_expire, col 121, captions->rpt_date,
    row + 1, col 0, captions->rpt_donor,
    col 23, captions->rpt_don_ssn, col 36,
    captions->rpt_mrn, col 58, captions->head_products,
    col 84, captions->rpt_recip, col 94,
    captions->head_products, col 103, captions->rpt_date_time,
    col 121, captions->rpt_needed, row + 1,
    col 0, line22, col 23,
    line12, col 36, line21,
    col 58, line25, col 84,
    line8, col 94, line8,
    col 103, line17, col 121,
    line8, row + 1
   DETAIL
    IF ((((inv_area != temp->qual[d.seq].cur_inv_area_cd)) OR ((((owner != temp->qual[d.seq].
    cur_owner_area_cd)) OR ((((don_loc != temp->qual[d.seq].donation_location_cd)) OR (row > 53)) ))
    )) )
     BREAK
    ENDIF
    IF ((temp->qual[d.seq].donation_date != date))
     date = temp->qual[d.seq].donation_date, donation_type = "not specified", col 0,
     date"@SHORTDATE;;d", row + 1
    ENDIF
    IF ((temp->qual[d.seq].donation_type != donation_type))
     donation_type = trim(temp->qual[d.seq].donation_type)
     IF (cnvtlower(donation_type)="autologous")
      col 0, captions->rpt_auto_dons
     ELSE
      col 0, captions->rpt_dir_dons
     ENDIF
     row + 1
    ENDIF
    string = substring(1,22,temp->qual[d.seq].donor), col 0, string";r",
    col 23, temp->qual[d.seq].donor_id, string2 = substring(1,22,temp->qual[d.seq].recipient),
    col 36, string2, col 58,
    temp->qual[d.seq].product_nbr, col 84, temp->qual[d.seq].recipient_aborh,
    col 94, temp->qual[d.seq].product_aborh, col 103,
    temp->qual[d.seq].expiration_date"@SHORTDATETIME;;d", col 121, temp->qual[d.seq].date_needed
    "@SHORTDATE;;d",
    row + 1, col 23, temp->qual[d.seq].donor_ssn,
    col 36, temp->qual[d.seq].recipient_mrn, col 58,
    temp->qual[d.seq].product_type, row + 2
   FOOT PAGE
    row 57, col 0, line131,
    row + 1, col 0, cpm_cfn_info->file_name,
    col 113, captions->rpt_page, col 120,
    curpage";l", row + 1
   FOOT REPORT
    CALL center(captions->end_of_report,1,125)
   WITH nocounter, separator = " ", format
  ;end select
  SET error_check = error(errmsg,0)
  IF (error_check != 0)
   SET reply->status_data.status = "F"
   CALL subevent_add("Print Report.","F","bbd_rpt_auto_dir_donations.prg",errmsg)
   GO TO exit_script
  ENDIF
 ELSEIF ((request->null_ind=1))
  SELECT INTO cpm_cfn_info->file_name_logical
   FROM (dummyt d  WITH seq = 1)
   PLAN (d
    WHERE d.seq > 0.0)
   HEAD PAGE
    date = start_date, donation_type = def_donation_type, row 0,
    col 0, sub_get_location_name,
    CALL center(captions->rpt_title,1,125),
    col 110, captions->rpt_time, col 122,
    curtime, row + 1, col 0,
    sub_get_location_address1, col 110, captions->as_of_date,
    col 122, curdate"@DATECONDENSED;;d", row + 1,
    col 0, sub_get_location_citystatezip, col 30,
    captions->beg_date, col 46, request->beg_dt_tm"ddmmmyy hh:mm;;d",
    col 72, captions->end_date, col 85,
    request->end_dt_tm"ddmmmyy hh:mm;;d", row + 2, col 0,
    captions->rpt_owner, row + 1, col 0,
    captions->rpt_inv_area, row + 1, col 0,
    captions->rpt_don_loc, row + 2, col 0,
    captions->rpt_don_date, row + 1, col 0,
    captions->rpt_proc_type, col 23, captions->rpt_donor_id,
    col 36, captions->rpt_recip, col 58,
    captions->rpt_prod_nbr, col 89, captions->rpt_aborh,
    col 103, captions->rpt_expire, col 121,
    captions->rpt_date, row + 1, col 0,
    captions->rpt_donor, col 23, captions->rpt_don_ssn,
    col 36, captions->rpt_mrn, col 58,
    captions->head_products, col 84, captions->rpt_recip,
    col 94, captions->head_products, col 103,
    captions->rpt_date_time, col 121, captions->rpt_needed,
    row + 1, col 0, line22,
    col 23, line12, col 36,
    line21, col 58, line25,
    col 84, line8, col 94,
    line8, col 103, line17,
    col 121, line8, row + 1
   FOOT PAGE
    row 57, col 0, line131,
    row + 1, col 0, cpm_cfn_info->file_name,
    col 113, captions->rpt_page, col 120,
    curpage";l", row + 1
   FOOT REPORT
    CALL center(captions->end_of_report,1,125)
   WITH nocounter, separator = " ", format
  ;end select
  SET error_check = error(errmsg,0)
  IF (error_check != 0)
   SET reply->status_data.status = "F"
   CALL subevent_add("Print Null Report.","F","bbd_rpt_auto_dir_donations.prg",errmsg)
   GO TO exit_script
  ENDIF
 ENDIF
#set_status
 IF (size(temp->qual,5)=0
  AND (request->null_ind != 1))
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((((request->null_ind=1)) OR ((reply->status_data.status="S"))) )
  SET stat = alterlist(reply->rpt_list,1)
  SET reply->rpt_list[1].rpt_filename = cpm_cfn_info->file_name_path
  IF (size(request->batch_selection,1) > 0)
   CALL echo(request->output_dist)
   IF (checkqueue(request->output_dist)=1)
    SET spool value(reply->rpt_list[1].rpt_filename) value(request->output_dist)
   ENDIF
  ENDIF
 ENDIF
#exit_script
 FREE SET temp
 FREE SET list
 FREE SET captions
 SET modify = nopredeclare
END GO
