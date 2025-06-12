CREATE PROGRAM bbd_rpt_recruit_productivity:dba
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
 FREE SET methods
 RECORD methods(
   1 qual[*]
     2 display = c8
     2 code_value = f8
     2 count = i4
     2 sum = i4
     2 total = i4
 )
 FREE SET recruiters
 RECORD recruiters(
   1 qual[*]
     2 name = c20
     2 person_id = f8
     2 contacted = i4
     2 scheduled = i4
     2 callbacks = i4
     2 failed = i4
     2 con_meths[*]
       3 total = i4
 )
 FREE SET list
 RECORD list(
   1 scheduled[*]
     2 value = f8
   1 callback[*]
     2 value = f8
   1 failed[*]
     2 value = f8
 )
 SET modify = predeclare
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE count = i4 WITH protect, noconstant(0)
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE length = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE start_index = i4 WITH protect, noconstant(1)
 DECLARE occurrences = i4 WITH protect, noconstant(100)
 DECLARE remaining = i4 WITH protect, noconstant(0)
 DECLARE temp_list[100] = f8 WITH protect, noconstant(0.0)
 DECLARE script_name = c16 WITH protect, constant("bbd_rpt_recruit_productivity")
 DECLARE recruit_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14220,"RECRUIT"))
 DECLARE line6 = c6 WITH protect, constant(fillstring(6,"-"))
 DECLARE line5 = c5 WITH protect, constant(fillstring(5,"-"))
 DECLARE line8 = c8 WITH protect, constant(fillstring(8,"-"))
 DECLARE line9 = c9 WITH protect, constant(fillstring(9,"-"))
 DECLARE line20 = c20 WITH protect, constant(fillstring(20,"-"))
 DECLARE line10 = c10 WITH protect, constant(fillstring(10,"-"))
 DECLARE line131 = c131 WITH protect, constant(fillstring(131,"-"))
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
   1 rpt_rec_date = vc
   1 rpt_donors = vc
   1 rpt_recruiter = vc
   1 rpt_contacted = vc
   1 rpt_con_meths = vc
   1 rpt_outcome = vc
   1 rpt_sched = vc
   1 rpt_failed = vc
   1 rpt_callback = vc
   1 rpt_total = vc
   1 rpt_r_summary = vc
   1 rpt_title = vc
   1 rpt_page = vc
   1 rpt_time = vc
   1 rpt_other = vc
   1 end_of_report = vc
 )
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","As Of Date:")
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title","RECRUITMENT PRODUCTIVITY")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->beg_date = uar_i18ngetmessage(i18nhandle,"beg_date","Beginning Date:")
 SET captions->end_date = uar_i18ngetmessage(i18nhandle,"end_date","Ending Date:")
 SET captions->rpt_rec_date = uar_i18ngetmessage(i18nhandle,"rpt_rec_date","Recruitment Date")
 SET captions->rpt_donors = uar_i18ngetmessage(i18nhandle,"rpt_donors","Donors")
 SET captions->rpt_recruiter = uar_i18ngetmessage(i18nhandle,"rpt_recruiter","Recruiter")
 SET captions->rpt_contacted = uar_i18ngetmessage(i18nhandle,"rpt_contacted","Contacted")
 SET captions->rpt_con_meths = uar_i18ngetmessage(i18nhandle,"rpt_con_meths","Contact Methods")
 SET captions->rpt_outcome = uar_i18ngetmessage(i18nhandle,"rpt_outcome","Outcome")
 SET captions->rpt_sched = uar_i18ngetmessage(i18nhandle,"rpt_sched","Scheduled")
 SET captions->rpt_failed = uar_i18ngetmessage(i18nhandle,"rpt_failed","Failed")
 SET captions->rpt_callback = uar_i18ngetmessage(i18nhandle,"rpt_callback","Call Back")
 SET captions->rpt_total = uar_i18ngetmessage(i18nhandle,"rpt_total","Total")
 SET captions->rpt_other = uar_i18ngetmessage(i18nhandle,"rpt_other","Other")
 SET captions->rpt_r_summary = uar_i18ngetmessage(i18nhandle,"rpt_r_summary","Recruitment Summary")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report","*** End of Report ***")
 SET reply->status_data.status = "Z"
 IF (recruit_cd=0.0)
  SET reply->status_data.status = "F"
  CALL subevent_add("bbd_rpt_recruit_productivity","F","uar_get_code_by",
   "Unable to retrieve the code_value for the cdf_meaning in code_set 14220.")
  SET reply->status = "F"
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
 CALL uar_get_code_list_by_meaning(14221,"APPOINT",start_index,occurrences,remaining,
  temp_list)
 SET stat = alterlist(list->scheduled,occurrences)
 FOR (index = 1 TO occurrences)
   SET list->scheduled[index].value = temp_list[index]
 ENDFOR
 WHILE (remaining > 0)
   SET occurrences = size(temp_list,5)
   SET start_index = (start_index+ occurrences)
   CALL uar_get_code_list_by_meaning(14221,"APPOINT",start_index,occurrences,remaining,
    temp_list)
   SET stat = alterlist(list->scheduled,(occurrences+ start_index))
   FOR (index = 1 TO occurrences)
     SET list->scheduled[((index+ start_index) - 1)].value = temp_list[index]
   ENDFOR
 ENDWHILE
 SET occurrences = 100
 CALL uar_get_code_list_by_meaning(14221,"CALLBACK",start_index,occurrences,remaining,
  temp_list)
 SET stat = alterlist(list->callback,occurrences)
 FOR (index = 1 TO occurrences)
   SET list->callback[index].value = temp_list[index]
 ENDFOR
 WHILE (remaining > 0)
   SET occurrences = size(temp_list,5)
   SET start_index = (start_index+ occurrences)
   CALL uar_get_code_list_by_meaning(14221,"CALLBACK",start_index,occurrences,remaining,
    temp_list)
   SET stat = alterlist(list->callback,(occurrences+ start_index))
   FOR (index = 1 TO occurrences)
     SET list->callback[((index+ start_index) - 1)].value = temp_list[index]
   ENDFOR
 ENDWHILE
 SET occurrences = 100
 CALL uar_get_code_list_by_meaning(14221,"RECFAIL",start_index,occurrences,remaining,
  temp_list)
 SET stat = alterlist(list->failed,occurrences)
 FOR (index = 1 TO occurrences)
   SET list->failed[index].value = temp_list[index]
 ENDFOR
 WHILE (remaining > 0)
   SET occurrences = size(temp_list,5)
   SET start_index = (start_index+ occurrences)
   CALL uar_get_code_list_by_meaning(14221,"RECFAIL",start_index,occurrences,remaining,
    temp_list)
   SET stat = alterlist(list->failed,(occurrences+ start_index))
   FOR (index = 1 TO occurrences)
     SET list->failed[((index+ start_index) - 1)].value = temp_list[index]
   ENDFOR
 ENDWHILE
 SELECT
  cv1.code_value, disp = substring(1,8,cv1.display)
  FROM code_value cv1
  WHERE cv1.code_set=14222
   AND cv1.active_ind=1
  HEAD REPORT
   count = 0, stat = alterlist(methods->qual,7)
  DETAIL
   count = (count+ 1)
   IF (count <= 7)
    methods->qual[count].code_value = cv1.code_value, methods->qual[count].display = disp
   ENDIF
  FOOT REPORT
   IF (count <= 7)
    stat = alterlist(methods->qual,count)
   ELSE
    stat = alterlist(methods->qual,7)
   ENDIF
  WITH nocounter, separator = " ", format
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "F"
  CALL subevent_add("bbd_rpt_recruit_productivity.prg","F","Select on Code_Value",
   "Unable to retrieve the code_values for the contact methods in code_set 14222.")
  SET reply->status = "F"
  GO TO exit_script
 ENDIF
 EXECUTE cpm_create_file_name_logical "bbd_recruit_prod", "txt", "x"
 SELECT
  IF ((request->null_ind=1))
   WITH nullreport, compress, nolandscape
  ELSE
   WITH nocounter, compress, nolandscape
  ENDIF
  INTO cpm_cfn_info->file_name_logical
  don_date = cnvtdate(bdc.contact_dt_tm), brr_outcome_disp = uar_get_code_display(brr.outcome_cd),
  brr_contact_method_disp = uar_get_code_display(brr.contact_method_cd),
  recruiter =
  IF (substring(1,20,p.name_full_formatted) > " ") substring(1,20,p.name_full_formatted)
  ELSE uar_i18ngetmessage(i18nhandle,"unknown","<Unknown>")
  ENDIF
  FROM bbd_donor_contact bdc,
   bbd_recruitment_rslts brr,
   prsnl p
  PLAN (bdc
   WHERE bdc.contact_type_cd=recruit_cd
    AND bdc.contact_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
    end_dt_tm))
   JOIN (brr
   WHERE brr.contact_id=bdc.contact_id)
   JOIN (p
   WHERE p.person_id=brr.recruit_prsnl_id)
  ORDER BY don_date, p.name_last_key, p.name_first_key
  HEAD REPORT
   new_sum_page = 0, rec_count = 0, tot_other = 0
  HEAD PAGE
   row 0,
   CALL center(captions->rpt_title,1,125), col 110,
   captions->rpt_time, col 122, curtime,
   row + 1, col 110, captions->as_of_date,
   col 122, curdate"@DATECONDENSED;;d", save_row = row,
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
   IF (save_row > row)
    row save_row
   ENDIF
   row + 1, col 30, captions->beg_date,
   col 46, request->beg_dt_tm"@DATETIMECONDENSED;;D", col 72,
   captions->end_date, col 85, request->end_dt_tm"@DATETIMECONDENSED;;D",
   row + 2
   IF (new_sum_page=0)
    col 0, captions->rpt_rec_date, col 21,
    captions->rpt_donors, column = (31+ (floor((size(methods->qual,5)/ 2)) * 11)), col column,
    captions->rpt_con_meths, column = (31+ (size(methods->qual,5) * 11)), col column,
    captions->rpt_outcome, row + 1, col 0,
    captions->rpt_recruiter, col 21, captions->rpt_contacted,
    column = 31
    FOR (i = 1 TO size(methods->qual,5))
      col column, methods->qual[i].display, column = (column+ 9)
    ENDFOR
    col column, captions->rpt_other, column = (column+ 6),
    col column, captions->rpt_sched, column = (column+ 10),
    col column, captions->rpt_callback, column = (column+ 10),
    col column, captions->rpt_failed, row + 1,
    col 0, line20, col 21,
    line9, column = 31
    FOR (i = 1 TO size(methods->qual,5))
      col column, line8, column = (column+ 9)
    ENDFOR
    col column, line5, column = (column+ 6),
    col column, line9, column = (column+ 10),
    col column, line9, column = (column+ 10),
    col column, line6, row + 1
   ENDIF
  HEAD don_date
   IF (row > 52)
    BREAK
   ENDIF
   date_other = 0, date_total = 0
   FOR (i = 1 TO size(methods->qual,5))
     methods->qual[i].sum = 0
   ENDFOR
   col 0, bdc.contact_dt_tm"@SHORTDATE;;D"
  HEAD recruiter
   num_recs = size(recruiters->qual,5)
   IF (locateval(index,1,num_recs,brr.recruit_prsnl_id,recruiters->qual[index].person_id)=0)
    rec_count = (rec_count+ 1), stat = alterlist(recruiters->qual,rec_count), recruiters->qual[
    rec_count].person_id = brr.recruit_prsnl_id,
    recruiters->qual[rec_count].name = recruiter, stat = alterlist(recruiters->qual[rec_count].
     con_meths,(size(methods->qual,5)+ 1))
   ENDIF
   other = 0
   FOR (i = 1 TO size(methods->qual,5))
     methods->qual[i].count = 0
   ENDFOR
  DETAIL
   pos = locateval(index,1,size(methods->qual,5),brr.contact_method_cd,methods->qual[index].
    code_value)
   IF (pos=0)
    other = (other+ 1), date_other = (date_other+ 1), tot_other = (tot_other+ 1)
   ELSE
    methods->qual[pos].count = (methods->qual[pos].count+ 1), methods->qual[pos].sum = (methods->
    qual[pos].sum+ 1), methods->qual[pos].total = (methods->qual[pos].total+ 1)
   ENDIF
  FOOT  recruiter
   IF (row > 56)
    BREAK
   ENDIF
   contacts = count(bdc.contact_id), scheduled = count(brr.outcome_cd
    WHERE expand(num,1,size(list->scheduled,5),brr.outcome_cd,list->scheduled[num].value)), callbacks
    = count(brr.outcome_cd
    WHERE expand(num,1,size(list->callback,5),brr.outcome_cd,list->callback[num].value)),
   failures = count(brr.outcome_cd
    WHERE expand(num,1,size(list->failed,5),brr.outcome_cd,list->failed[num].value)), con_str =
   cnvtstring(contacts), num_recs = size(recruiters->qual,5),
   pos = locateval(index,1,num_recs,brr.recruit_prsnl_id,recruiters->qual[index].person_id),
   recruiters->qual[pos].contacted = (recruiters->qual[pos].contacted+ contacts), row + 1,
   col 0, recruiter";R", col 22,
   con_str, column = 32
   FOR (i = 1 TO size(methods->qual,5))
    IF ((methods->qual[i].count > 0))
     recruiters->qual[pos].con_meths[i].total = (recruiters->qual[pos].con_meths[i].total+ methods->
     qual[i].count), out_str = cnvtstring(methods->qual[i].count), col column,
     out_str
    ENDIF
    ,column = (column+ 9)
   ENDFOR
   IF (other > 0)
    recruiters->qual[pos].con_meths[size(recruiters->qual[pos].con_meths,5)].total = (recruiters->
    qual[pos].con_meths[size(recruiters->qual[pos].con_meths,5)].total+ other), othr_str = cnvtstring
    (other), col column,
    othr_str
   ENDIF
   column = (column+ 6)
   IF (scheduled > 0)
    recruiters->qual[pos].scheduled = (recruiters->qual[pos].scheduled+ scheduled), sch_str =
    cnvtstring(scheduled), col column,
    sch_str
   ENDIF
   column = (column+ 10)
   IF (callbacks > 0)
    recruiters->qual[pos].callbacks = (recruiters->qual[pos].callbacks+ callbacks), cb_str =
    cnvtstring(callbacks), col column,
    cb_str
   ENDIF
   column = (column+ 9)
   IF (failures > 0)
    recruiters->qual[pos].failed = (recruiters->qual[pos].failed+ failures), fail_str = cnvtstring(
     failures), col column,
    fail_str
   ENDIF
  FOOT  don_date
   IF (row > 55)
    BREAK
   ENDIF
   tot_contacts = count(bdc.contact_id), tot_sched = count(brr.outcome_cd
    WHERE expand(num,1,size(list->scheduled,5),brr.outcome_cd,list->scheduled[num].value)), tot_cbs
    = count(brr.outcome_cd
    WHERE expand(num,1,size(list->callback,5),brr.outcome_cd,list->callback[num].value)),
   tot_fails = count(brr.outcome_cd
    WHERE expand(num,1,size(list->failed,5),brr.outcome_cd,list->failed[num].value)), row + 1, col 0,
   line20, col 21, line9,
   column = 31
   FOR (i = 1 TO size(methods->qual,5))
     col column, line8, column = (column+ 9)
   ENDFOR
   col column, line5, column = (column+ 6),
   col column, line9, column = (column+ 10),
   col column, line9, column = (column+ 10),
   col column, line6, row + 1,
   col 0, captions->rpt_total";R", con_str = cnvtstring(tot_contacts),
   col 22, con_str, column = 32
   FOR (i = 1 TO size(methods->qual,5))
     out_str = cnvtstring(methods->qual[i].sum), col column, out_str,
     column = (column+ 9)
   ENDFOR
   othr_str = cnvtstring(date_other), col column, othr_str,
   column = (column+ 6), sch_str = cnvtstring(tot_sched), col column,
   sch_str, column = (column+ 10), cb_str = cnvtstring(tot_cbs),
   col column, cb_str, column = (column+ 9),
   fail_str = cnvtstring(tot_fails), col column, fail_str,
   row + 3
  FOOT PAGE
   rpt_row = row, row 57, col 0,
   line131, row + 1, col 0,
   cpm_cfn_info->file_name, col 113, captions->rpt_page,
   col 120, curpage";L", row + 1
  FOOT REPORT
   new_sum_page = 1, BREAK
   IF (size(recruiters->qual,5) > 0)
    rpt_tot_contacts = count(bdc.contact_id), rpt_tot_sched = count(brr.outcome_cd
     WHERE expand(num,1,size(list->scheduled,5),brr.outcome_cd,list->scheduled[num].value)),
    rpt_tot_cbs = count(brr.outcome_cd
     WHERE expand(num,1,size(list->callback,5),brr.outcome_cd,list->callback[num].value)),
    rpt_tot_fails = count(brr.outcome_cd
     WHERE expand(num,1,size(list->failed,5),brr.outcome_cd,list->failed[num].value)), con_str =
    cnvtstring(rpt_tot_contacts)
    FOR (i = 1 TO size(recruiters->qual,5))
      IF (row > 54)
       new_sum_page = 1, BREAK
      ENDIF
      IF (new_sum_page=1)
       col 21, captions->rpt_donors, column = (31+ (floor((size(methods->qual,5)/ 2)) * 11)),
       col column, captions->rpt_con_meths, column = (31+ (size(methods->qual,5) * 11)),
       col column, captions->rpt_outcome, row + 1,
       col 0, captions->rpt_r_summary, col 21,
       captions->rpt_contacted, column = 31
       FOR (j = 1 TO size(methods->qual,5))
         col column, methods->qual[j].display, column = (column+ 9)
       ENDFOR
       col column, captions->rpt_other, column = (column+ 6),
       col column, captions->rpt_sched, column = (column+ 10),
       col column, captions->rpt_callback, column = (column+ 10),
       col column, captions->rpt_failed, row + 1,
       col 0, line20, col 21,
       line9, column = 31
       FOR (j = 1 TO size(methods->qual,5))
         col column, line8, column = (column+ 9)
       ENDFOR
       col column, line5, column = (column+ 6),
       col column, line9, column = (column+ 10),
       col column, line9, column = (column+ 10),
       col column, line6, row + 1,
       new_sum_page = 0
      ENDIF
      col 0, recruiters->qual[i].name";R", out_str = cnvtstring(recruiters->qual[i].contacted),
      col 22, out_str, column = 32
      FOR (j = 1 TO size(methods->qual,5))
        out_str = cnvtstring(recruiters->qual[i].con_meths[j].total), col column, out_str,
        column = (column+ 9)
      ENDFOR
      othr_str = cnvtstring(recruiters->qual[i].con_meths[size(recruiters->qual[i].con_meths,5)].
       total), col column, othr_str,
      column = (column+ 6), out_str = cnvtstring(recruiters->qual[i].scheduled), col column,
      out_str, column = (column+ 10), out_str = cnvtstring(recruiters->qual[i].callbacks),
      col column, out_str, column = (column+ 9),
      out_str = cnvtstring(recruiters->qual[i].failed), col column, out_str,
      row + 1
    ENDFOR
    col 0, line20, col 21,
    line9, column = 31
    FOR (i = 1 TO size(methods->qual,5))
      col column, line8, column = (column+ 9)
    ENDFOR
    col column, line5, column = (column+ 6),
    col column, line9, column = (column+ 10),
    col column, line9, column = (column+ 10),
    col column, line6, row + 1,
    col 0, captions->rpt_total";R", col 22,
    con_str, column = 32
    FOR (i = 1 TO size(methods->qual,5))
      out_str = cnvtstring(methods->qual[i].total), col column, out_str,
      column = (column+ 9)
    ENDFOR
    othr_str = cnvtstring(tot_other), col column, othr_str,
    column = (column+ 6), sch_str = cnvtstring(rpt_tot_sched), col column,
    sch_str, column = (column+ 10), cb_str = cnvtstring(rpt_tot_cbs),
    col column, cb_str, column = (column+ 9),
    fail_str = cnvtstring(rpt_tot_fails), col column, fail_str
   ENDIF
   row 57, col 0, line131,
   row + 1, col 0, cpm_cfn_info->file_name,
   col 113, captions->rpt_page, col 120,
   curpage";L", row + 1,
   CALL center(captions->end_of_report,1,125)
 ;end select
#set_status
 IF (curqual=0)
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
 FREE SET list
 FREE SET methods
 FREE SET recruiters
 FREE SET captions
 SET modify = nopredeclare
END GO
