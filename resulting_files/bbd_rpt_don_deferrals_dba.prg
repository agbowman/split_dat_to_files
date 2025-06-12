CREATE PROGRAM bbd_rpt_don_deferrals:dba
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
 RECORD temp(
   1 qual[*]
     2 donation_dt = dq8
     2 donor_name = c100
     2 birth_dt_tm = dq8
     2 gender = c10
     2 donor_id = vc
     2 donor_ssn = vc
     2 person_id = f8
     2 product_nbr = c25
     2 product_type = c25
     2 aborh = c10
     2 deferred_dt_tm = dq8
     2 reason = c20
     2 deferral_until = dq8
     2 deferral_type_cd = f8
     2 donation_id = f8
     2 cur_inv_area_cd = f8
     2 donation_location_cd = f8
     2 cur_owner_area_cd = f8
 )
 SET modify = predeclare
 DECLARE script_name = c21 WITH constant("bbd_rpt_don_deferrals")
 DECLARE ssn_cd = f8 WITH constant(uar_get_code_by("MEANING",4,"SSN"))
 DECLARE id_cd = f8 WITH constant(uar_get_code_by("MEANING",4,"DONORID"))
 DECLARE mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",4,"MRN"))
 DECLARE deferred_cd = f8 WITH constant(uar_get_code_by("MEANING",14237,"PERMNENT"))
 DECLARE suspended_cd = f8 WITH constant(uar_get_code_by("MEANING",14237,"TEMP"))
 DECLARE line9 = c9 WITH constant(fillstring(9,"-"))
 DECLARE line20 = c20 WITH constant(fillstring(20,"-"))
 DECLARE line14 = c14 WITH constant(fillstring(14,"-"))
 DECLARE line25 = c25 WITH constant(fillstring(25,"-"))
 DECLARE line131 = c131 WITH constant(fillstring(131,"-"))
 DECLARE i18nhandle = i4 WITH noconstant(0)
 DECLARE num = i4 WITH noconstant(0)
 DECLARE forcount = i4 WITH noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE stat = i4 WITH protect, noconstant(0)
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
   1 rpt_donor = vc
   1 rpt_donor_id = vc
   1 rpt_don_ssn = vc
   1 rpt_prod_nbr = vc
   1 rpt_aborh = vc
   1 rpt_dob_gndr = vc
   1 rpt_dt_deferred = vc
   1 rpt_reason = vc
   1 rpt_defer = vc
   1 rpt_until = vc
   1 rpt_deferral = vc
   1 rpt_type = vc
   1 rpt_title = vc
   1 rpt_page = vc
   1 rpt_time = vc
   1 rpt_product = vc
   1 rpt_permanent = vc
   1 end_of_report = vc
 )
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","As Of Date:")
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title",
  "SUMMARY OF TEMPORARY AND PERMANENT DEFERRALS")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->beg_date = uar_i18ngetmessage(i18nhandle,"beg_date","Beginning Date:")
 SET captions->end_date = uar_i18ngetmessage(i18nhandle,"end_date","Ending Date:")
 SET captions->rpt_owner = uar_i18ngetmessage(i18nhandle,"rpt_owner","Blood Bank Owner:")
 SET captions->rpt_inv_area = uar_i18ngetmessage(i18nhandle,"rpt_inv_area","Inventory Area:")
 SET captions->rpt_don_loc = uar_i18ngetmessage(i18nhandle,"rpt_don_loc","Donation Location:")
 SET captions->rpt_don_date = uar_i18ngetmessage(i18nhandle,"rpt_don_date","Donation Date")
 SET captions->rpt_donor = uar_i18ngetmessage(i18nhandle,"rpt_donor","Donor")
 SET captions->rpt_donor_id = uar_i18ngetmessage(i18nhandle,"rpt_donor_id","Donor ID")
 SET captions->rpt_don_ssn = uar_i18ngetmessage(i18nhandle,"rpt_don_ssn","SSN")
 SET captions->rpt_prod_nbr = uar_i18ngetmessage(i18nhandle,"rpt_prod_nbr","Product Number")
 SET captions->rpt_aborh = uar_i18ngetmessage(i18nhandle,"rpt_aborh","ABO/Rh")
 SET captions->rpt_defer = uar_i18ngetmessage(i18nhandle,"rpt_defer","Defer")
 SET captions->rpt_until = uar_i18ngetmessage(i18nhandle,"rpt_until","Until")
 SET captions->rpt_deferral = uar_i18ngetmessage(i18nhandle,"rpt_deferral","Deferral")
 SET captions->rpt_type = uar_i18ngetmessage(i18nhandle,"rpt_type","Type")
 SET captions->rpt_reason = uar_i18ngetmessage(i18nhandle,"rpt_reason","Reason")
 SET captions->rpt_dt_deferred = uar_i18ngetmessage(i18nhandle,"rpt_dt_deferred","Date Deferred")
 SET captions->rpt_dob_gndr = uar_i18ngetmessage(i18nhandle,"rpt_dob_gndr","DOB/Gender")
 SET captions->rpt_all = uar_i18ngetmessage(i18nhandle,"rpt_all","(All)")
 SET captions->rpt_product = uar_i18ngetmessage(i18nhandle,"rpt_product","Product")
 SET captions->rpt_permanent = uar_i18ngetmessage(i18nhandle,"rpt_permanent","Permanent")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report","*** End of Report ***")
 IF (((ssn_cd=0.0) OR (((id_cd=0.0) OR (((mrn_cd=0.0) OR (((deferred_cd=0.0) OR (suspended_cd=0.0))
 )) )) )) )
  SET reply->status_data.status = "F"
  CALL subevent_add("bbd_rpt_don_defferals.prg","F","uar_get_code_by",
   "Unable to retrieve the code_value for the cdf_meanings in code_sets 4 and 14237.")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "Z"
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
 SELECT
  sex = substring(1,10,uar_get_code_display(p.sex_cd)), aborh = substring(1,10,concat(trim(
     uar_get_code_display(da.abo_cd))," ",trim(uar_get_code_display(da.rh_cd)))), drawn_date =
  cnvtdate(bdr.drawn_dt_tm),
  reason = substring(1,20,uar_get_code_display(bdf.reason_cd)), product_number = substring(1,25,
   concat(trim(prod.product_nbr)," ",trim(prod.product_sub_nbr))), product_type = substring(1,25,
   uar_get_code_display(prod.product_cd))
  FROM bbd_donation_results bdr,
   encounter e,
   bbd_donor_eligibility bde,
   bbd_deferral_reason bdf,
   person p,
   donor_aborh da,
   bbd_don_product_r bdp,
   product prod
  PLAN (bdr
   WHERE bdr.drawn_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm
    ))
   JOIN (e
   WHERE bdr.encntr_id=e.encntr_id
    AND (((request->donation_location_cd=e.loc_facility_cd)) OR ((request->donation_location_cd=0.0)
   )) )
   JOIN (bde
   WHERE bde.encntr_id=e.encntr_id
    AND bde.eligibility_type_cd IN (suspended_cd, deferred_cd))
   JOIN (bdf
   WHERE bdf.eligibility_id=bde.eligibility_id)
   JOIN (p
   WHERE p.person_id=bdf.person_id)
   JOIN (da
   WHERE da.person_id=outerjoin(p.person_id))
   JOIN (bdp
   WHERE bdp.donation_results_id=outerjoin(bdr.donation_result_id))
   JOIN (prod
   WHERE prod.product_id=outerjoin(bdp.product_id)
    AND (((request->cur_inv_area_cd != 0.0)
    AND (prod.cur_inv_area_cd=request->cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0)))
    AND (((request->cur_owner_area_cd != 0.0)
    AND (prod.cur_owner_area_cd=request->cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0))) )
  ORDER BY prod.cur_owner_area_cd, prod.cur_inv_area_cd, e.loc_facility_cd,
   drawn_date, p.name_last, p.name_first
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(temp->qual,(count+ 9))
   ENDIF
   temp->qual[count].birth_dt_tm = p.birth_dt_tm, temp->qual[count].donor_name = p
   .name_full_formatted, temp->qual[count].person_id = p.person_id,
   temp->qual[count].donation_dt = drawn_date, temp->qual[count].gender = sex, temp->qual[count].
   deferred_dt_tm = bde.active_status_dt_tm,
   temp->qual[count].reason = reason, temp->qual[count].deferral_until = bde.eligible_dt_tm, temp->
   qual[count].deferral_type_cd = bde.eligibility_type_cd,
   temp->qual[count].aborh = aborh, temp->qual[count].donation_id = bdr.donation_result_id, temp->
   qual[count].product_nbr = product_number,
   temp->qual[count].product_type = product_type, temp->qual[count].cur_inv_area_cd = prod
   .cur_inv_area_cd, temp->qual[count].cur_owner_area_cd = prod.cur_owner_area_cd,
   temp->qual[count].donation_location_cd = e.loc_facility_cd
  FOOT REPORT
   stat = alterlist(temp->qual,count)
  WITH nocounter, separator = " ", format
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  SET reply->status_data.status = "F"
  CALL subevent_add("Select deferred donors.","F","bbd_rpt_don_deferrals.prg",errmsg)
  GO TO exit_script
 ENDIF
 EXECUTE cpm_create_file_name_logical "bbd_donor_deferrals", "txt", "x"
 IF (size(temp->qual,5) > 0)
  SELECT
   alias = cnvtalias(pa.alias,pa.alias_pool_cd)
   FROM person_alias pa
   WHERE expand(num,1,size(temp->qual,5),pa.person_id,temp->qual[num].person_id)
    AND pa.person_alias_type_cd IN (ssn_cd, id_cd)
   DETAIL
    pos = 0, pos = locateval(num,1,size(temp->qual,5),pa.person_id,temp->qual[num].person_id)
    WHILE (pos != 0)
     IF (pa.person_alias_type_cd=ssn_cd)
      temp->qual[pos].donor_ssn = alias
     ELSE
      temp->qual[pos].donor_id = alias
     ENDIF
     ,pos = locateval(num,(pos+ 1),size(temp->qual,5),pa.person_id,temp->qual[num].person_id)
    ENDWHILE
   WITH nocounter
  ;end select
  SET error_check = error(errmsg,0)
  IF (error_check != 0)
   SET reply->status_data.status = "F"
   CALL subevent_add("Select donor aliases.","F","bbd_rpt_don_deferrals.prg",errmsg)
   GO TO exit_script
  ENDIF
  SELECT INTO cpm_cfn_info->file_name_logical
   p_inv_area = uar_get_code_display(temp->qual[d.seq].cur_inv_area_cd), p_owner_area =
   uar_get_code_display(temp->qual[d.seq].cur_owner_area_cd), p_don_loc = uar_get_code_display(temp->
    qual[d.seq].donation_location_cd),
   deferral_type = substring(1,20,uar_get_code_display(temp->qual[d.seq].deferral_type_cd))
   FROM (dummyt d  WITH seq = size(temp->qual,5))
   PLAN (d
    WHERE d.seq > 0.0)
   HEAD REPORT
    row + 0
   HEAD PAGE
    date = cnvtdatetime("01-jan-1900 00:00"), donation_type = "not specified", row 0,
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
    row + 2, date = cnvtdatetime("01-jan-1900 00:00"), col 0,
    captions->rpt_owner, col 18, p_owner_area,
    owner = temp->qual[d.seq].cur_owner_area_cd, row + 1, col 0,
    captions->rpt_inv_area, col 18, p_inv_area,
    inv_area = temp->qual[d.seq].cur_inv_area_cd, row + 1, col 0,
    captions->rpt_don_loc, col 20, p_don_loc,
    don_loc = temp->qual[d.seq].donation_location_cd, row + 2, col 0,
    captions->rpt_don_date, row + 1, col 0,
    captions->rpt_donor, col 22, captions->rpt_donor_id,
    col 38, captions->rpt_prod_nbr, col 76,
    captions->rpt_dt_deferred, col 98, captions->rpt_defer,
    col 109, captions->rpt_deferral, row + 1,
    col 0, captions->rpt_dob_gndr, col 22,
    captions->rpt_don_ssn, col 38, captions->rpt_product,
    col 65, captions->rpt_aborh, col 76,
    captions->rpt_reason, col 98, captions->rpt_until,
    col 109, captions->rpt_type, row + 1,
    col 0, line20, col 22,
    line14, col 38, line25,
    col 65, line9, col 76,
    line20, col 98, line9,
    col 109, line9, row + 1
   DETAIL
    IF (row > 55)
     BREAK
    ENDIF
    IF ((((owner != temp->qual[d.seq].cur_owner_area_cd)) OR ((((inv_area != temp->qual[d.seq].
    cur_inv_area_cd)) OR ((don_loc != temp->qual[d.seq].donation_location_cd))) )) )
     BREAK
    ENDIF
    IF ((temp->qual[d.seq].donation_dt != date))
     date = temp->qual[d.seq].donation_dt, col 0, date"@SHORTDATE;;d",
     row + 1
    ENDIF
    string = substring(1,20,temp->qual[d.seq].donor_name), col 0, string";r",
    col 22, temp->qual[d.seq].donor_id, col 38,
    temp->qual[d.seq].product_nbr, col 65, temp->qual[d.seq].aborh,
    col 76, temp->qual[d.seq].deferred_dt_tm"@SHORTDATE;;d"
    IF ((temp->qual[d.seq].deferral_type_cd=deferred_cd))
     col 98, deferral_type
    ELSE
     col 98, temp->qual[d.seq].deferral_until"@SHORTDATE;;d"
    ENDIF
    col 109, deferral_type, row + 1,
    string2 = substring(1,20,concat(format(temp->qual[d.seq].birth_dt_tm,"@SHORTDATE;;d")," ",temp->
      qual[d.seq].gender)), col 0, string2";r",
    col 22, temp->qual[d.seq].donor_ssn, col 38,
    temp->qual[d.seq].product_type, col 76, temp->qual[d.seq].reason,
    row + 2
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
   CALL subevent_add("Print Report.","F","bbd_rpt_don_deferrals.prg",errmsg)
   GO TO exit_script
  ENDIF
 ELSEIF ((request->null_ind=1))
  SELECT INTO cpm_cfn_info->file_name_logical
   FROM (dummyt d  WITH seq = 1)
   PLAN (d
    WHERE d.seq > 0.0)
   HEAD REPORT
    first_page = "y"
   HEAD PAGE
    date = cnvtdatetime("01-jan-1900 00:00"), donation_type = "not specified", row 0,
    col 0, sub_get_location_name,
    CALL center(captions->rpt_title,1,125),
    col 110, captions->rpt_time, col 122,
    curtime, row + 1, col 0,
    sub_get_location_address1, col 110, captions->as_of_date,
    col 122, curdate"@DATECONDENSED;;d", row + 1,
    col 0, sub_get_location_citystatezip, col 30,
    captions->beg_date, col 46, request->beg_dt_tm"@DATETIMECONDENSED;;d",
    col 72, captions->end_date, col 85,
    request->end_dt_tm"@DATETIMECONDENSED;;d", row + 2, date = cnvtdatetime("01-jan-1900 00:00"),
    col 0, captions->rpt_owner, row + 1,
    col 0, captions->rpt_inv_area, row + 1,
    col 0, captions->rpt_don_loc, row + 2,
    col 0, captions->rpt_don_date, row + 1,
    col 0, captions->rpt_donor, col 22,
    captions->rpt_donor_id, col 38, captions->rpt_prod_nbr,
    col 76, captions->rpt_dt_deferred, col 98,
    captions->rpt_defer, col 109, captions->rpt_deferral,
    row + 1, col 0, captions->rpt_dob_gndr,
    col 22, captions->rpt_don_ssn, col 38,
    captions->rpt_product, col 65, captions->rpt_aborh,
    col 76, captions->rpt_reason, col 98,
    captions->rpt_until, col 109, captions->rpt_type,
    row + 1, col 0, line20,
    col 22, line14, col 38,
    line25, col 65, line9,
    col 76, line20, col 98,
    line9, col 109, line9,
    row + 1
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
   CALL subevent_add("Print Null Report.","F","bbd_rpt_don_deferrals.prg",errmsg)
   GO TO exit_script
  ENDIF
 ENDIF
#set_status
 IF (size(temp->qual,5)=0)
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
 FREE SET captions
 SET modify = nopredeclare
END GO
