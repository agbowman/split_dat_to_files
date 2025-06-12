CREATE PROGRAM bb_rpt_recd_products:dba
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
 SUBROUTINE (subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value
   )) =null WITH protect)
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
 SET modify = predeclare
 DECLARE script_name = c20 WITH protect, constant("bb_rpt_recd_products")
 DECLARE recd_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1610,"13"))
 DECLARE blood_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1606,"BLOOD"))
 DECLARE deriv_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1606,"DERIVATIVE"))
 DECLARE a_pos_cd = f8 WITH constant(uar_get_code_by("MEANING",1640,"APOS"))
 DECLARE o_pos_cd = f8 WITH constant(uar_get_code_by("MEANING",1640,"OPOS"))
 DECLARE b_pos_cd = f8 WITH constant(uar_get_code_by("MEANING",1640,"BPOS"))
 DECLARE ab_pos_cd = f8 WITH constant(uar_get_code_by("MEANING",1640,"ABPOS"))
 DECLARE a_neg_cd = f8 WITH constant(uar_get_code_by("MEANING",1640,"ANEG"))
 DECLARE o_neg_cd = f8 WITH constant(uar_get_code_by("MEANING",1640,"ONEG"))
 DECLARE b_neg_cd = f8 WITH constant(uar_get_code_by("MEANING",1640,"BNEG"))
 DECLARE ab_neg_cd = f8 WITH constant(uar_get_code_by("MEANING",1640,"ABNEG"))
 DECLARE a_pool_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"APOOLRH"))
 DECLARE o_pool_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"OPOOLRH"))
 DECLARE b_pool_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"BPOOLRH"))
 DECLARE ab_pool_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"ABPOOLRH"))
 DECLARE pool_neg_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"POOLABONEG"))
 DECLARE pool_pos_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"POOLABOPOS"))
 DECLARE pool_pool_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"POOLABOPLRH"))
 DECLARE pool_abo_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"POOLABO"))
 DECLARE a_cd = f8 WITH constant(uar_get_code_by("MEANING",1640,"A"))
 DECLARE o_cd = f8 WITH constant(uar_get_code_by("MEANING",1640,"O"))
 DECLARE b_cd = f8 WITH constant(uar_get_code_by("MEANING",1640,"B"))
 DECLARE ab_cd = f8 WITH constant(uar_get_code_by("MEANING",1640,"AB"))
 DECLARE line8 = c8 WITH protect, constant(fillstring(8,"-"))
 DECLARE line17 = c17 WITH protect, constant(fillstring(17,"-"))
 DECLARE line22 = c22 WITH protect, constant(fillstring(22,"-"))
 DECLARE line93 = c93 WITH protect, constant(fillstring(93,"-"))
 DECLARE line131 = c131 WITH protect, constant(fillstring(131,"-"))
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE count = i4 WITH protect, noconstant(0)
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE stat = i4 WITH protect, noconstant(0)
 RECORD totals(
   1 qual[*]
     2 product_type = vc
     2 total_reg_cnt = i4
     2 total_reg_no_rh_cnt = i4
     2 total_pool_cnt = i4
     2 aborhs[*]
       3 count = i4
       3 pooled_ind = i2
 )
 RECORD aborh(
   1 qual[*]
     2 aborh_cd = f8
     2 abo_cd = f8
     2 rh_cd = f8
     2 aborh_disp = c10
     2 abo_disp = c10
     2 rh_disp = c10
     2 pooled_ind = i2
     2 no_rh_ind = i2
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
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 as_of_date = vc
   1 beg_date = vc
   1 end_date = vc
   1 rpt_owner = vc
   1 rpt_all = vc
   1 rpt_inv_area = vc
   1 rpt_recv_date = vc
   1 rpt_prod_nbr = vc
   1 rpt_aborh = vc
   1 rpt_expire = vc
   1 rpt_date_time = vc
   1 rpt_prod_totals = vc
   1 rpt_total = vc
   1 rpt_tot_prods = vc
   1 rpt_title = vc
   1 rpt_page = vc
   1 rpt_time = vc
   1 head_products = vc
   1 rpt_qnty = vc
   1 rpt_intl = vc
   1 rpt_units = vc
   1 end_of_report = vc
   1 interface = vc
   1 receipt = vc
   1 yes = vc
   1 no = vc
   1 serial_number = vc
 )
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","As Of Date:")
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title","SUMMARY OF PRODUCTS RECEIVED")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->beg_date = uar_i18ngetmessage(i18nhandle,"beg_date","Beginning Date:")
 SET captions->end_date = uar_i18ngetmessage(i18nhandle,"end_date","Ending Date:")
 SET captions->rpt_owner = uar_i18ngetmessage(i18nhandle,"rpt_owner","Blood Bank Owner:")
 SET captions->rpt_inv_area = uar_i18ngetmessage(i18nhandle,"rpt_inv_area","Inventory Area:")
 SET captions->rpt_recv_date = uar_i18ngetmessage(i18nhandle,"rpt_recv_date","Receive Date")
 SET captions->rpt_prod_nbr = uar_i18ngetmessage(i18nhandle,"rpt_prod_nbr","Product Number")
 SET captions->rpt_aborh = uar_i18ngetmessage(i18nhandle,"rpt_aborh","ABO/Rh")
 SET captions->rpt_expire = uar_i18ngetmessage(i18nhandle,"rpt_expire","Expiration")
 SET captions->rpt_date_time = uar_i18ngetmessage(i18nhandle,"rpt_date_time","Date and Time")
 SET captions->rpt_prod_totals = uar_i18ngetmessage(i18nhandle,"rpt_prod_totals","Product Totals")
 SET captions->rpt_total = uar_i18ngetmessage(i18nhandle,"rpt_total","TOTAL")
 SET captions->rpt_tot_prods = uar_i18ngetmessage(i18nhandle,"rpt_tot_prods","Total Products")
 SET captions->rpt_all = uar_i18ngetmessage(i18nhandle,"rpt_all","(All)")
 SET captions->rpt_qnty = uar_i18ngetmessage(i18nhandle,"rpt_qnty","Quantity")
 SET captions->rpt_intl = uar_i18ngetmessage(i18nhandle,"rpt_intl","International")
 SET captions->rpt_units = uar_i18ngetmessage(i18nhandle,"rpt_units","Units")
 SET captions->head_products = uar_i18ngetmessage(i18nhandle,"head_products","Product")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report","*** End of Report ***")
 SET captions->interface = uar_i18ngetmessage(i18nhandle,"interface","Interface")
 SET captions->receipt = uar_i18ngetmessage(i18nhandle,"receipt","Receipt")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","NO")
 SET captions->serial_number = uar_i18ngetmessage(i18nhandle,"serial_number","Serial Number")
 SET reply->status_data.status = "Z"
 SET count = size(aborh->qual,5)
 IF (a_pos_cd != 0.0)
  SET count += 1
  SET stat = alterlist(aborh->qual,count)
  SET aborh->qual[count].aborh_cd = a_pos_cd
  SET aborh->qual[count].aborh_disp = substring(1,10,uar_get_code_display(a_pos_cd))
 ENDIF
 SET count = size(aborh->qual,5)
 IF (o_pos_cd != 0.0)
  SET count += 1
  SET stat = alterlist(aborh->qual,count)
  SET aborh->qual[count].aborh_cd = o_pos_cd
  SET aborh->qual[count].aborh_disp = substring(1,10,uar_get_code_display(o_pos_cd))
 ENDIF
 SET count = size(aborh->qual,5)
 IF (b_pos_cd != 0.0)
  SET count += 1
  SET stat = alterlist(aborh->qual,count)
  SET aborh->qual[count].aborh_cd = b_pos_cd
  SET aborh->qual[count].aborh_disp = substring(1,10,uar_get_code_display(b_pos_cd))
 ENDIF
 SET count = size(aborh->qual,5)
 IF (ab_pos_cd != 0.0)
  SET count += 1
  SET stat = alterlist(aborh->qual,count)
  SET aborh->qual[count].aborh_cd = ab_pos_cd
  SET aborh->qual[count].aborh_disp = substring(1,10,uar_get_code_display(ab_pos_cd))
 ENDIF
 SET count = size(aborh->qual,5)
 IF (a_neg_cd != 0.0)
  SET count += 1
  SET stat = alterlist(aborh->qual,count)
  SET aborh->qual[count].aborh_cd = a_neg_cd
  SET aborh->qual[count].aborh_disp = substring(1,10,uar_get_code_display(a_neg_cd))
 ENDIF
 IF (o_neg_cd != 0.0)
  SET count += 1
  SET stat = alterlist(aborh->qual,count)
  SET aborh->qual[count].aborh_cd = o_neg_cd
  SET aborh->qual[count].aborh_disp = substring(1,10,uar_get_code_display(o_neg_cd))
 ENDIF
 IF (b_neg_cd != 0.0)
  SET count += 1
  SET stat = alterlist(aborh->qual,count)
  SET aborh->qual[count].aborh_cd = b_neg_cd
  SET aborh->qual[count].aborh_disp = substring(1,10,uar_get_code_display(b_neg_cd))
 ENDIF
 IF (ab_neg_cd != 0.0)
  SET count += 1
  SET stat = alterlist(aborh->qual,count)
  SET aborh->qual[count].aborh_cd = ab_neg_cd
  SET aborh->qual[count].aborh_disp = substring(1,10,uar_get_code_display(ab_neg_cd))
 ENDIF
 IF (a_pool_cd != 0.0)
  SET count += 1
  SET stat = alterlist(aborh->qual,count)
  SET aborh->qual[count].aborh_cd = a_pool_cd
  SET aborh->qual[count].aborh_disp = substring(1,10,uar_get_code_display(a_pool_cd))
  SET aborh->qual[count].pooled_ind = 1
 ENDIF
 IF (o_pool_cd != 0.0)
  SET count += 1
  SET stat = alterlist(aborh->qual,count)
  SET aborh->qual[count].aborh_cd = o_pool_cd
  SET aborh->qual[count].aborh_disp = substring(1,10,uar_get_code_display(o_pool_cd))
  SET aborh->qual[count].pooled_ind = 1
 ENDIF
 IF (b_pool_cd != 0.0)
  SET count += 1
  SET stat = alterlist(aborh->qual,count)
  SET aborh->qual[count].aborh_cd = b_pool_cd
  SET aborh->qual[count].aborh_disp = substring(1,10,uar_get_code_display(b_pool_cd))
  SET aborh->qual[count].pooled_ind = 1
 ENDIF
 IF (ab_pool_cd != 0.0)
  SET count += 1
  SET stat = alterlist(aborh->qual,count)
  SET aborh->qual[count].aborh_cd = ab_pool_cd
  SET aborh->qual[count].aborh_disp = substring(1,10,uar_get_code_display(ab_pool_cd))
  SET aborh->qual[count].pooled_ind = 1
 ENDIF
 IF (pool_neg_cd != 0.0)
  SET count += 1
  SET stat = alterlist(aborh->qual,count)
  SET aborh->qual[count].aborh_cd = pool_neg_cd
  SET aborh->qual[count].aborh_disp = substring(1,10,uar_get_code_display(pool_neg_cd))
  SET aborh->qual[count].pooled_ind = 1
 ENDIF
 IF (pool_pos_cd != 0.0)
  SET count += 1
  SET stat = alterlist(aborh->qual,count)
  SET aborh->qual[count].aborh_cd = pool_pos_cd
  SET aborh->qual[count].aborh_disp = substring(1,10,uar_get_code_display(pool_pos_cd))
  SET aborh->qual[count].pooled_ind = 1
 ENDIF
 IF (pool_pool_cd != 0.0)
  SET count += 1
  SET stat = alterlist(aborh->qual,count)
  SET aborh->qual[count].aborh_cd = pool_pool_cd
  SET aborh->qual[count].aborh_disp = substring(1,10,uar_get_code_display(pool_pool_cd))
  SET aborh->qual[count].pooled_ind = 1
 ENDIF
 IF (pool_abo_cd != 0.0)
  SET count += 1
  SET stat = alterlist(aborh->qual,count)
  SET aborh->qual[count].aborh_cd = pool_abo_cd
  SET aborh->qual[count].aborh_disp = substring(1,10,uar_get_code_display(pool_abo_cd))
  SET aborh->qual[count].pooled_ind = 1
 ENDIF
 IF (a_cd != 0.0)
  SET count += 1
  SET stat = alterlist(aborh->qual,count)
  SET aborh->qual[count].aborh_cd = a_cd
  SET aborh->qual[count].aborh_disp = substring(1,10,uar_get_code_display(a_cd))
  SET aborh->qual[count].no_rh_ind = 1
 ENDIF
 IF (b_cd != 0.0)
  SET count += 1
  SET stat = alterlist(aborh->qual,count)
  SET aborh->qual[count].aborh_cd = b_cd
  SET aborh->qual[count].aborh_disp = substring(1,10,uar_get_code_display(b_cd))
  SET aborh->qual[count].no_rh_ind = 1
 ENDIF
 IF (ab_cd != 0.0)
  SET count += 1
  SET stat = alterlist(aborh->qual,count)
  SET aborh->qual[count].aborh_cd = ab_cd
  SET aborh->qual[count].aborh_disp = substring(1,10,uar_get_code_display(ab_cd))
  SET aborh->qual[count].no_rh_ind = 1
 ENDIF
 IF (o_cd != 0.0)
  SET count += 1
  SET stat = alterlist(aborh->qual,count)
  SET aborh->qual[count].aborh_cd = o_cd
  SET aborh->qual[count].aborh_disp = substring(1,10,uar_get_code_display(o_cd))
  SET aborh->qual[count].no_rh_ind = 1
 ENDIF
 SELECT
  c.code_value
  FROM code_value_extension c
  WHERE expand(index,1,size(aborh->qual,5),c.code_value,aborh->qual[index].aborh_cd)
   AND c.field_name IN ("ABOOnly_cd", "RhOnly_cd")
  DETAIL
   pos = locateval(index,1,size(aborh->qual,5),c.code_value,aborh->qual[index].aborh_cd)
   IF (c.field_name="ABOOnly_cd")
    aborh->qual[pos].abo_cd = cnvtreal(c.field_value)
   ELSE
    aborh->qual[pos].rh_cd = cnvtreal(c.field_value)
   ENDIF
  WITH nocounter
 ;end select
 FOR (i = 1 TO size(aborh->qual,5))
  SET aborh->qual[i].abo_disp = substring(1,10,uar_get_code_display(aborh->qual[i].abo_cd))
  SET aborh->qual[i].rh_disp = substring(1,10,uar_get_code_display(aborh->qual[i].rh_cd))
 ENDFOR
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  SET reply->status_data.status = "F"
  CALL subevent_add("Select abo and rh code values.","F","bb_rpt_recd_products.prg",errmsg)
  GO TO exit_script
 ENDIF
 IF (((size(aborh->qual,5)=0) OR (curqual=0)) )
  SET reply->status_data.status = "F"
  CALL subevent_add("bb_rpt_recd_products.prg","F","uar_get_code_by",
   "Unable to retrieve the code_values for the abo and rh codes.")
  GO TO exit_script
 ENDIF
 IF (((recd_cd=0.0) OR (((blood_cd=0.0) OR (deriv_cd=0.0)) )) )
  SET reply->status_data.status = "F"
  CALL subevent_add("bb_rpt_recd_products.prg","F","uar_get_code_by",
   "Unable to retrieve the code_values for the cdf_meanings in code_sets 1606 and 1610.")
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
 EXECUTE cpm_create_file_name_logical "bb_reced_prods", "txt", "x"
 SELECT
  IF ((request->null_ind=1))
   WITH nullreport, compress, nolandscape
  ELSE
   WITH nocounter, compress, nolandscape
  ENDIF
  INTO cpm_cfn_info->file_name_logical
  recd_date = cnvtdate(pe.event_dt_tm), p_product_disp = substring(1,22,uar_get_code_display(p
    .product_cd)), p_owner_area = uar_get_code_display(pe.owner_area_cd),
  p_inv_area = uar_get_code_display(pe.inventory_area_cd), prod_number = substring(1,22,concat(trim(b
     .supplier_prefix),trim(p.product_nbr)," ",trim(p.product_sub_nbr))), aborh = substring(1,22,
   concat(trim(uar_get_code_display(b.cur_abo_cd))," ",trim(uar_get_code_display(b.cur_rh_cd))))
  FROM product_event pe,
   receipt r,
   product p,
   blood_product b
  PLAN (pe
   WHERE pe.event_type_cd=recd_cd
    AND pe.event_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND pe.active_ind=0
    AND (((request->cur_owner_area_cd != 0.0)
    AND (pe.owner_area_cd=request->cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
    AND (((request->cur_inv_area_cd != 0.0)
    AND (pe.inventory_area_cd=request->cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
   JOIN (r
   WHERE r.product_event_id=pe.product_event_id)
   JOIN (p
   WHERE p.product_id=r.product_id)
   JOIN (b
   WHERE (b.product_id= Outerjoin(p.product_id)) )
  ORDER BY pe.owner_area_cd, pe.inventory_area_cd, recd_date,
   p_product_disp, aborh
  HEAD REPORT
   first_page = 1, last_page = 0, new_sum_page = 0,
   print_pool_headers = 0, print_no_rh_headers = 0, owner_last = fillstring(25," "),
   inv_last = fillstring(25," ")
  HEAD PAGE
   row 0,
   CALL center(captions->rpt_title,0,125), col 110,
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
   col 46, request->beg_dt_tm"@DATETIMECONDENSED;;d", col 72,
   captions->end_date, col 85, request->end_dt_tm"@DATETIMECONDENSED;;d",
   row + 2
   IF (last_page != 1
    AND new_sum_page != 1
    AND print_pool_headers != 1
    AND print_no_rh_headers != 1)
    col 0, captions->rpt_owner, col 18,
    p_owner_area, row + 1, col 0,
    captions->rpt_inv_area, col 18, p_inv_area,
    row + 2, col 0, captions->rpt_recv_date,
    col 25, captions->rpt_prod_nbr, col 60,
    captions->rpt_intl, col 97, captions->rpt_expire,
    col 117, captions->interface, row + 1,
    col 0, captions->head_products, col 25,
    captions->serial_number, col 50, captions->rpt_qnty,
    col 60, captions->rpt_units, col 75,
    captions->rpt_aborh, col 97, captions->rpt_date_time,
    col 117, captions->receipt, row + 1,
    col 0, line22, col 25,
    line22, col 50, line8,
    col 60, line8, col 75,
    line17, col 97, line17,
    col 117, line8, row + 1
   ELSE
    col 0, captions->rpt_owner, col 18,
    owner_last, row + 1, col 0,
    captions->rpt_inv_area, col 18, inv_last,
    row + 2
   ENDIF
  HEAD pe.owner_area_cd
   IF (first_page != 1)
    first_page = 1, BREAK
   ENDIF
   owner_last = p_owner_area
  HEAD pe.inventory_area_cd
   IF (first_page=1)
    first_page = 0
   ELSE
    BREAK
   ENDIF
   FOR (x = 1 TO size(totals->qual,5))
     FOR (y = 1 TO size(totals->qual[x].aborhs,5))
      totals->qual[x].aborhs[y].count = 0,totals->qual[x].aborhs[y].pooled_ind = 0
     ENDFOR
     totals->qual[x].total_reg_cnt = 0, totals->qual[x].total_pool_cnt = 0, totals->qual[x].
     total_reg_no_rh_cnt = 0
   ENDFOR
   pool_prods_found_ind = 0, reg_prods_no_rh_found_ind = 0, inv_last = p_inv_area
  HEAD recd_date
   IF (row > 55)
    BREAK
   ENDIF
   col 0, recd_date"@SHORTDATE;;d", row + 1
  HEAD p_product_disp
   IF (row > 56)
    BREAK
   ENDIF
   num_recs = size(totals->qual,5), pos = locateval(num,1,num_recs,p_product_disp,totals->qual[num].
    product_type)
   IF (pos=0
    AND p.product_class_cd=blood_cd)
    stat = alterlist(totals->qual,(num_recs+ 1)), pos = (num_recs+ 1), totals->qual[pos].product_type
     = p_product_disp,
    stat = alterlist(totals->qual[pos].aborhs,size(aborh->qual,5))
   ENDIF
  DETAIL
   IF (row > 56)
    BREAK
   ENDIF
   IF (row >= 56
    AND p.serial_number_txt != null)
    BREAK
   ENDIF
   col 3, p_product_disp, col 25,
   prod_number
   IF (p.product_class_cd=blood_cd)
    col 75, aborh, num_recs = size(totals->qual,5),
    p_pos = locateval(index,1,num_recs,p_product_disp,totals->qual[index].product_type), num_recs =
    size(aborh->qual,5), a_pos = locateval(index,1,num_recs,b.cur_abo_cd,aborh->qual[index].abo_cd)
    IF (a_pos > 0)
     WHILE ((aborh->qual[a_pos].rh_cd != b.cur_rh_cd)
      AND (aborh->qual[a_pos].abo_cd=b.cur_abo_cd)
      AND a_pos < num_recs
      AND a_pos > 0)
      start_pos = (a_pos+ 1),a_pos = locateval(index,start_pos,num_recs,b.cur_abo_cd,aborh->qual[
       index].abo_cd)
     ENDWHILE
     IF ((aborh->qual[a_pos].rh_cd=b.cur_rh_cd))
      totals->qual[p_pos].aborhs[a_pos].count += 1
      IF ((aborh->qual[a_pos].pooled_ind=0))
       IF ((aborh->qual[a_pos].no_rh_ind=0))
        totals->qual[p_pos].total_reg_cnt += 1, totals->qual[p_pos].aborhs[a_pos].pooled_ind = 0
       ELSE
        totals->qual[p_pos].total_reg_no_rh_cnt += 1, totals->qual[p_pos].aborhs[a_pos].pooled_ind =
        0, reg_prods_no_rh_found_ind = 1
       ENDIF
      ELSE
       totals->qual[p_pos].total_pool_cnt += 1, totals->qual[p_pos].aborhs[a_pos].pooled_ind = 1,
       pool_prods_found_ind = 1
      ENDIF
     ENDIF
    ENDIF
   ELSEIF (p.product_class_cd=deriv_cd)
    out_str = cnvtstring(r.orig_rcvd_qty), col 53, out_str,
    out_str = cnvtstring(r.orig_intl_units), col 63, out_str
   ENDIF
   col 97, p.cur_expire_dt_tm"@SHORTDATETIME;;d"
   IF (r.electronic_receipt_ind=1)
    col 120, captions->yes
   ELSE
    col 120, captions->no
   ENDIF
   IF (p.serial_number_txt != null)
    row + 1, col 25, p.serial_number_txt
   ENDIF
   row + 1
  FOOT  p_product_disp
   row + 0
  FOOT  recd_date
   row + 1
  FOOT  pe.inventory_area_cd
   tot_prods = 0
   FOR (i = 1 TO size(totals->qual,5))
     IF ((totals->qual[i].total_reg_cnt > 0))
      tot_prods += 1
     ENDIF
     IF ((totals->qual[i].total_pool_cnt > 0))
      tot_prods += 1
     ENDIF
     IF ((totals->qual[i].total_reg_no_rh_cnt > 0))
      tot_prods += 1
     ENDIF
   ENDFOR
   IF (((row+ tot_prods) > 39))
    last_page = 1, owner_last = p_owner_area, inv_last = p_inv_area,
    BREAK
   ENDIF
   IF (last_page != 1)
    row + 1, col 0, line93,
    row + 2
   ELSE
    last_page = 0
   ENDIF
   IF (size(totals->qual,5) > 0)
    new_sum_page = 1, total = 0
    FOR (x = 1 TO size(totals->qual,5))
      IF (row > 54)
       new_sum_page = 1, BREAK
      ENDIF
      IF (new_sum_page=1)
       col 0, captions->rpt_prod_totals, column = 25
       FOR (i = 1 TO size(aborh->qual,5))
         IF ((aborh->qual[i].pooled_ind=0)
          AND (aborh->qual[i].no_rh_ind=0))
          col column, aborh->qual[i].aborh_disp, column += 10
         ENDIF
       ENDFOR
       col column, captions->rpt_total, row + 1,
       col 0, line22, column = 25
       FOR (i = 1 TO size(aborh->qual,5))
         IF ((aborh->qual[i].pooled_ind=0)
          AND (aborh->qual[i].no_rh_ind=0))
          col column, line8, column += 10
         ENDIF
       ENDFOR
       col column, line8, row + 1,
       new_sum_page = 0
      ENDIF
      IF ((totals->qual[x].total_reg_cnt > 0))
       col 0, totals->qual[x].product_type, column = 28
       FOR (y = 1 TO size(aborh->qual,5))
         IF ((aborh->qual[y].pooled_ind=0)
          AND (aborh->qual[y].no_rh_ind=0))
          IF ((totals->qual[x].aborhs[y].count > 0))
           string = cnvtstring(totals->qual[x].aborhs[y].count), col column, string
          ENDIF
          column += 10
         ENDIF
       ENDFOR
       string = cnvtstring(totals->qual[x].total_reg_cnt), col column, string,
       total += totals->qual[x].total_reg_cnt, row + 1
      ENDIF
    ENDFOR
    col 90, line22, row + 1,
    string = cnvtstring(total), col 90, captions->rpt_tot_prods,
    col 108, string, row + 2
    IF (reg_prods_no_rh_found_ind=1)
     print_no_rh_headers = 1, total = 0
     FOR (x = 1 TO size(totals->qual,5))
       IF ((totals->qual[x].total_reg_no_rh_cnt > 0))
        IF (row > 54)
         print_no_rh_headers = 1, BREAK
        ENDIF
        IF (print_no_rh_headers=1)
         col 0, captions->rpt_prod_totals, column = 25
         FOR (j = 1 TO size(aborh->qual,5))
           IF ((aborh->qual[j].pooled_ind=0)
            AND (aborh->qual[j].no_rh_ind=1))
            col column, aborh->qual[j].aborh_disp, column += 10
           ENDIF
         ENDFOR
         col column, captions->rpt_total, row + 1,
         col 0, line22, column = 25
         FOR (i = 1 TO size(aborh->qual,5))
           IF ((aborh->qual[i].pooled_ind=0)
            AND (aborh->qual[i].no_rh_ind=1))
            col column, line8, column += 10
           ENDIF
         ENDFOR
         col column, line8, row + 1,
         print_no_rh_headers = 0
        ENDIF
        col 0, totals->qual[x].product_type, column = 28
        FOR (y = 1 TO size(aborh->qual,5))
          IF ((aborh->qual[y].pooled_ind=0)
           AND (aborh->qual[y].no_rh_ind=1))
           IF ((totals->qual[x].aborhs[y].count > 0))
            string = cnvtstring(totals->qual[x].aborhs[y].count), col column, string
           ENDIF
           column += 10
          ENDIF
        ENDFOR
        string = cnvtstring(totals->qual[x].total_reg_no_rh_cnt), col column, string,
        total += totals->qual[x].total_reg_no_rh_cnt, row + 1
       ENDIF
     ENDFOR
     IF (row > 55)
      print_no_rh_headers = 1, BREAK, print_no_rh_headers = 0
     ENDIF
     col 50, line22, row + 1,
     string = cnvtstring(total), col 50, captions->rpt_tot_prods,
     col 68, string, row + 2
    ENDIF
    IF (pool_prods_found_ind=1)
     print_pool_headers = 1, total = 0
     FOR (x = 1 TO size(totals->qual,5))
       IF (row > 50)
        print_pool_headers = 1, BREAK
       ENDIF
       IF (print_pool_headers=1)
        col 0, captions->rpt_prod_totals, column = 25
        FOR (j = 1 TO size(aborh->qual,5))
          IF ((aborh->qual[j].pooled_ind=1))
           col column, aborh->qual[j].abo_disp, column += 11
          ENDIF
        ENDFOR
        row + 1, column = 25
        FOR (j = 1 TO size(aborh->qual,5))
          IF ((aborh->qual[j].pooled_ind=1))
           col column, aborh->qual[j].rh_disp, column += 11
          ENDIF
        ENDFOR
        col column, captions->rpt_total, row + 1,
        col 0, line22, column = 25
        FOR (i = 1 TO size(aborh->qual,5))
          IF ((aborh->qual[i].pooled_ind=1))
           col column, line8, column += 11
          ENDIF
        ENDFOR
        col column, line8, row + 1,
        print_pool_headers = 0
       ENDIF
       IF ((totals->qual[x].total_pool_cnt > 0))
        col 0, totals->qual[x].product_type, column = 28
        FOR (y = 1 TO size(aborh->qual,5))
          IF ((aborh->qual[y].pooled_ind=1))
           IF ((totals->qual[x].aborhs[y].count > 0))
            string = cnvtstring(totals->qual[x].aborhs[y].count), col column, string
           ENDIF
           column += 11
          ENDIF
        ENDFOR
        string = cnvtstring(totals->qual[x].total_pool_cnt), col column, string,
        total += totals->qual[x].total_pool_cnt, row + 1
       ENDIF
     ENDFOR
     col 98, line22, row + 1,
     string = cnvtstring(total), col 98, captions->rpt_tot_prods,
     col 116, string, row + 2
    ENDIF
   ENDIF
  FOOT  pe.owner_area_cd
   row + 0
  FOOT PAGE
   row 57, col 0, line131,
   row + 1, col 0, cpm_cfn_info->file_name,
   col 113, captions->rpt_page, col 120,
   curpage";l", row + 1
  FOOT REPORT
   row 59,
   CALL center(captions->end_of_report,1,125)
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  SET reply->status_data.status = "F"
  CALL subevent_add("Select received products.","F","bb_rpt_recd_products.prg",errmsg)
  GO TO exit_script
 ENDIF
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
 FREE SET aborh
 FREE SET totals
 FREE SET captions
 SET modify = nopredeclare
END GO
