CREATE PROGRAM bbd_rpt_lbl_verified_prods:dba
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
 FREE SET aborh
 RECORD aborh(
   1 qual[*]
     2 aborh_cd = f8
     2 abo_cd = f8
     2 rh_cd = f8
     2 aborh_disp = c10
     2 count = i4
     2 abo_disp = c10
     2 rh_disp = c10
     2 pooled_ind = i2
 )
 FREE SET products
 RECORD products(
   1 qual[*]
     2 name = c25
     2 product_cd = f8
     2 tot_reg_count = i4
     2 tot_pool_count = i4
     2 prods[*]
       3 count = i4
       3 pooled_ind = i2
 )
 SET modify = predeclare
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE count = i4 WITH protect, noconstant(0)
 DECLARE index = i4 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE pooled_prods_day = i2 WITH protect, noconstant(0)
 DECLARE reg_headers_printed = i2 WITH protect, noconstant(0)
 DECLARE script_name = c26 WITH protect, constant("bbd_rpt_lbl_verified_prods")
 DECLARE verified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1610,"23"))
 DECLARE a_pos_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"APOS"))
 DECLARE o_pos_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"OPOS"))
 DECLARE b_pos_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"BPOS"))
 DECLARE ab_pos_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"ABPOS"))
 DECLARE a_neg_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"ANEG"))
 DECLARE o_neg_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"ONEG"))
 DECLARE b_neg_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"BNEG"))
 DECLARE ab_neg_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"ABNEG"))
 DECLARE a_pool_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"APOOLRH"))
 DECLARE o_pool_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"OPOOLRH"))
 DECLARE b_pool_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"BPOOLRH"))
 DECLARE ab_pool_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"ABPOOLRH"))
 DECLARE pool_neg_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"POOLABONEG"))
 DECLARE pool_pos_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"POOLABOPOS"))
 DECLARE pool_pool_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"POOLABOPLRH"))
 DECLARE pool_abo_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"POOLABO"))
 DECLARE line8 = c8 WITH protect, constant(fillstring(8,"-"))
 DECLARE line25 = c25 WITH protect, constant(fillstring(25,"-"))
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
   1 rpt_owner = vc
   1 rpt_all = vc
   1 rpt_inv_area = vc
   1 rpt_prod_sum = vc
   1 rpt_date = vc
   1 rpt_total = vc
   1 rpt_title = vc
   1 rpt_page = vc
   1 rpt_time = vc
   1 head_products = vc
   1 end_of_report = vc
 )
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","As Of Date:")
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title",
  "SUMMARY OF LABEL-VERIFIED PRODUCTS")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->beg_date = uar_i18ngetmessage(i18nhandle,"beg_date","Beginning Date:")
 SET captions->end_date = uar_i18ngetmessage(i18nhandle,"end_date","Ending Date:")
 SET captions->rpt_owner = uar_i18ngetmessage(i18nhandle,"rpt_owner","Blood Bank Owner:")
 SET captions->rpt_inv_area = uar_i18ngetmessage(i18nhandle,"rpt_inv_area","Inventory Area:")
 SET captions->rpt_prod_sum = uar_i18ngetmessage(i18nhandle,"rpt_prod_sum","Products Summary")
 SET captions->rpt_total = uar_i18ngetmessage(i18nhandle,"rpt_total","Total")
 SET captions->rpt_date = uar_i18ngetmessage(i18nhandle,"rpt_date","Label Verified Date")
 SET captions->rpt_all = uar_i18ngetmessage(i18nhandle,"rpt_all","(All)")
 SET captions->head_products = uar_i18ngetmessage(i18nhandle,"head_products","Product")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report","*** End of Report ***")
 IF (verified_cd=0.0)
  SET reply->status_data.status = "F"
  CALL subevent_add("bbd_rpt_lbl_verified_prods.prg","F","uar_get_code_by",
   "Unable to retrieve the code_value for the cdf_meaning in code_set 1610.")
  SET reply->status = "F"
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
 SET count = size(aborh->qual,5)
 IF (a_pos_cd != 0.0)
  SET count += 1
  SET stat = alterlist(aborh->qual,count)
  SET aborh->qual[count].aborh_cd = a_pos_cd
  SET aborh->qual[count].aborh_disp = substring(1,10,uar_get_code_display(a_pos_cd))
  SET aborh->qual[count].pooled_ind = 0
 ENDIF
 SET count = size(aborh->qual,5)
 IF (o_pos_cd != 0.0)
  SET count += 1
  SET stat = alterlist(aborh->qual,count)
  SET aborh->qual[count].aborh_cd = o_pos_cd
  SET aborh->qual[count].aborh_disp = substring(1,10,uar_get_code_display(o_pos_cd))
  SET aborh->qual[count].pooled_ind = 0
 ENDIF
 SET count = size(aborh->qual,5)
 IF (b_pos_cd != 0.0)
  SET count += 1
  SET stat = alterlist(aborh->qual,count)
  SET aborh->qual[count].aborh_cd = b_pos_cd
  SET aborh->qual[count].aborh_disp = substring(1,10,uar_get_code_display(b_pos_cd))
  SET aborh->qual[count].pooled_ind = 0
 ENDIF
 SET count = size(aborh->qual,5)
 IF (ab_pos_cd != 0.0)
  SET count += 1
  SET stat = alterlist(aborh->qual,count)
  SET aborh->qual[count].aborh_cd = ab_pos_cd
  SET aborh->qual[count].aborh_disp = substring(1,10,uar_get_code_display(ab_pos_cd))
  SET aborh->qual[count].pooled_ind = 0
 ENDIF
 SET count = size(aborh->qual,5)
 IF (a_neg_cd != 0.0)
  SET count += 1
  SET stat = alterlist(aborh->qual,count)
  SET aborh->qual[count].aborh_cd = a_neg_cd
  SET aborh->qual[count].aborh_disp = substring(1,10,uar_get_code_display(a_neg_cd))
  SET aborh->qual[count].pooled_ind = 0
 ENDIF
 IF (o_neg_cd != 0.0)
  SET count += 1
  SET stat = alterlist(aborh->qual,count)
  SET aborh->qual[count].aborh_cd = o_neg_cd
  SET aborh->qual[count].aborh_disp = substring(1,10,uar_get_code_display(o_neg_cd))
  SET aborh->qual[count].pooled_ind = 0
 ENDIF
 IF (b_neg_cd != 0.0)
  SET count += 1
  SET stat = alterlist(aborh->qual,count)
  SET aborh->qual[count].aborh_cd = b_neg_cd
  SET aborh->qual[count].aborh_disp = substring(1,10,uar_get_code_display(b_neg_cd))
  SET aborh->qual[count].pooled_ind = 0
 ENDIF
 IF (ab_neg_cd != 0.0)
  SET count += 1
  SET stat = alterlist(aborh->qual,count)
  SET aborh->qual[count].aborh_cd = ab_neg_cd
  SET aborh->qual[count].aborh_disp = substring(1,10,uar_get_code_display(ab_neg_cd))
  SET aborh->qual[count].pooled_ind = 0
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
 IF (curqual=0)
  SET reply->status_data.status = "F"
  CALL subevent_add("bbd_rpt_lbl_verified_prods.prg","F","uar_get_code_by",
   "Unable to retrieve the code_values for the abo and rh codes.")
  SET reply->status = "F"
  GO TO exit_script
 ENDIF
 EXECUTE cpm_create_file_name_logical "bbd_lbl_vrfd_prods", "txt", "x"
 SELECT
  IF ((request->null_ind=1))
   WITH nullreport, compress, nolandscape
  ELSE
   WITH nocounter, compress, nolandscape
  ENDIF
  INTO cpm_cfn_info->file_name_logical
  verfd_date = cnvtdate(pe.event_dt_tm), p_product_disp = cnvtalphanum(uar_get_code_display(p
    .product_cd)), p_product_disp_show = substring(1,25,uar_get_code_display(p.product_cd)),
  p_owner_area = uar_get_code_display(p.cur_owner_area_cd), p_inv_area = uar_get_code_display(p
   .cur_inv_area_cd)
  FROM product_event pe,
   blood_product bp,
   product p
  PLAN (pe
   WHERE pe.event_type_cd=verified_cd
    AND pe.event_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm))
   JOIN (bp
   WHERE bp.product_id=pe.product_id)
   JOIN (p
   WHERE p.product_id=bp.product_id
    AND (((request->cur_inv_area_cd != 0.0)
    AND (p.cur_inv_area_cd=request->cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0)))
    AND (((request->cur_owner_area_cd != 0.0)
    AND (p.cur_owner_area_cd=request->cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0))) )
  ORDER BY p_owner_area, p_inv_area, verfd_date,
   p_product_disp
  HEAD REPORT
   first_page = 1, new_sum_page = 0, pooled_prods_summary = 0
  HEAD PAGE
   row 0, rpt_row = 0,
   CALL center(captions->rpt_title,0,125),
   col 110, captions->rpt_time, col 122,
   curtime, row + 1, col 110,
   captions->as_of_date, col 122, curdate"@DATECONDENSED;;d",
   save_row = row, inc_i18nhandle = 0, inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",
    curcclrev),
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
   IF (save_row > row)
    row save_row
   ENDIF
   row + 1, col 30, captions->beg_date,
   col 46, request->beg_dt_tm"@DATETIMECONDENSED;;d", col 72,
   captions->end_date, col 85, request->end_dt_tm"@DATETIMECONDENSED;;d",
   row + 2
   IF (new_sum_page=0)
    col 0, captions->rpt_owner, col 18,
    p_owner_area, row + 1, col 0,
    captions->rpt_inv_area, col 18, p_inv_area,
    row + 2, col 0, captions->rpt_date,
    row + 1, col 0, captions->head_products
    IF (pooled_prods_day=0)
     column = 27
     FOR (i = 1 TO size(aborh->qual,5))
       IF ((aborh->qual[i].pooled_ind=0))
        col column, aborh->qual[i].aborh_disp, column += 10
       ENDIF
     ENDFOR
     col column, captions->rpt_total, row + 1,
     col 0, line25, column = 27
     FOR (i = 1 TO size(aborh->qual,5))
       IF ((aborh->qual[i].pooled_ind=0))
        col column, line8, column += 10
       ENDIF
     ENDFOR
     col column, line8, row + 1,
     reg_headers_printed = 1
    ENDIF
   ENDIF
  HEAD p_owner_area
   IF (first_page != 1)
    first_page = 1, BREAK
   ENDIF
  HEAD p_inv_area
   IF (first_page=1)
    first_page = 0
   ELSE
    BREAK
   ENDIF
  HEAD verfd_date
   IF (row > 55)
    BREAK
   ENDIF
   col 0, verfd_date"@SHORTDATE;;d"
   IF (pooled_prods_day=1
    AND reg_headers_printed=0)
    column = 27
    FOR (i = 1 TO size(aborh->qual,5))
      IF ((aborh->qual[i].pooled_ind=0))
       col column, aborh->qual[i].aborh_disp, column += 10
      ENDIF
    ENDFOR
    col column, captions->rpt_total, row + 1,
    column = 27
    FOR (i = 1 TO size(aborh->qual,5))
      IF ((aborh->qual[i].pooled_ind=0))
       col column, line8, column += 10
      ENDIF
    ENDFOR
    col column, line8, row + 1
   ELSE
    reg_headers_printed = 0
   ENDIF
   pooled_prods_day = 0, row + 1
  HEAD p_product_disp
   num_recs = size(products->qual,5), pos = locateval(index,1,num_recs,p.product_cd,products->qual[
    index].product_cd)
   IF (pos=0)
    num_recs += 1, stat = alterlist(products->qual,num_recs), products->qual[num_recs].name =
    p_product_disp_show,
    products->qual[num_recs].product_cd = p.product_cd, p_size = size(aborh->qual,5), stat =
    alterlist(products->qual[num_recs].prods,p_size)
   ENDIF
   FOR (i = 1 TO size(aborh->qual,5))
     aborh->qual[i].count = 0
   ENDFOR
  DETAIL
   num_recs = size(aborh->qual,5), a_pos = locateval(index,1,num_recs,bp.cur_abo_cd,aborh->qual[index
    ].abo_cd)
   IF (a_pos > 0)
    WHILE ((aborh->qual[a_pos].rh_cd != bp.cur_rh_cd)
     AND (aborh->qual[a_pos].abo_cd=bp.cur_abo_cd)
     AND a_pos < num_recs
     AND a_pos > 0)
     start_pos = (a_pos+ 1),a_pos = locateval(index,start_pos,num_recs,bp.cur_abo_cd,aborh->qual[
      index].abo_cd)
    ENDWHILE
    IF ((aborh->qual[a_pos].rh_cd=bp.cur_rh_cd))
     aborh->qual[a_pos].count += 1
    ENDIF
   ENDIF
  FOOT  p_product_disp
   IF (row > 56)
    BREAK
   ENDIF
   num_recs = size(products->qual,5), p_pos = locateval(index,1,num_recs,p.product_cd,products->qual[
    index].product_cd), num_recs = size(aborh->qual,5),
   p_tot = count(p.product_id), ptot_str = cnvtstring(p_tot), p_section_cnt = 0,
   col 0, p_product_disp_show";r", column = 30
   FOR (i = 1 TO size(aborh->qual,5))
     IF ((aborh->qual[i].pooled_ind=0))
      IF ((aborh->qual[i].count > 0))
       products->qual[p_pos].prods[i].count += aborh->qual[i].count, products->qual[p_pos].
       tot_reg_count += aborh->qual[i].count, p_section_cnt += aborh->qual[i].count,
       products->qual[p_pos].prods[i].pooled_ind = 0, out_str = cnvtstring(aborh->qual[i].count), col
        column,
       out_str
      ENDIF
      column += 10
     ELSE
      products->qual[p_pos].prods[i].count += aborh->qual[i].count, products->qual[p_pos].
      tot_pool_count += aborh->qual[i].count, products->qual[p_pos].prods[i].pooled_ind = 1
      IF ((aborh->qual[i].count > 0))
       pooled_prods_day = 1, pooled_prods_summary = 1
      ENDIF
     ENDIF
   ENDFOR
   ptot_str = trim(cnvtstring(p_section_cnt)), col column, ptot_str,
   row + 1
  FOOT  verfd_date
   row + 1
   IF (pooled_prods_day=1)
    IF (((row+ size(products->qual,5)) > 56))
     BREAK
    ENDIF
    column = 27
    FOR (j = 1 TO size(aborh->qual,5))
      IF ((aborh->qual[j].pooled_ind=1))
       col column, aborh->qual[j].abo_disp, column += 11
      ENDIF
    ENDFOR
    row + 1, column = 27
    FOR (j = 1 TO size(aborh->qual,5))
      IF ((aborh->qual[j].pooled_ind=1))
       col column, aborh->qual[j].rh_disp, column += 11
      ENDIF
    ENDFOR
    col column, captions->rpt_total, row + 1,
    column = 27
    FOR (j = 1 TO size(aborh->qual,5))
      IF ((aborh->qual[j].pooled_ind=1))
       col column, line8, column += 11
      ENDIF
    ENDFOR
    col column, line8, row + 1
    FOR (i = 1 TO size(products->qual,5))
      IF ((products->qual[i].tot_pool_count > 0))
       col 0, products->qual[i].name";r", column = 30
       FOR (j = 1 TO size(products->qual[i].prods,5))
         IF ((products->qual[i].prods[j].pooled_ind=1))
          IF ((products->qual[i].prods[j].count > 0))
           out_str = cnvtstring(products->qual[i].prods[j].count), col column, out_str
          ENDIF
          column += 11
         ENDIF
       ENDFOR
       out_str = cnvtstring(products->qual[i].tot_pool_count), col column, out_str,
       row + 1
      ENDIF
    ENDFOR
    row + 2
   ENDIF
  FOOT  p_inv_area
   row + 0
  FOOT  p_owner_area
   row + 0
  FOOT PAGE
   rpt_row = row, row 57, col 0,
   line131, row + 1, col 0,
   cpm_cfn_info->file_name_logical, col 113, captions->rpt_page,
   col 120, curpage";l", row + 1
  FOOT REPORT
   IF (size(products->qual,5) > 0)
    new_sum_page = 1, BREAK
    FOR (i = 1 TO size(products->qual,5))
      IF (row > 56)
       new_sum_page = 1, BREAK
      ENDIF
      IF (new_sum_page=1)
       col 0, captions->rpt_prod_sum, column = 27
       FOR (j = 1 TO size(aborh->qual,5))
         IF ((aborh->qual[j].pooled_ind=0))
          col column, aborh->qual[j].aborh_disp, column += 10
         ENDIF
       ENDFOR
       col column, captions->rpt_total, row + 1,
       col 0, line25, column = 27
       FOR (j = 1 TO size(aborh->qual,5))
         IF ((aborh->qual[j].pooled_ind=0))
          col column, line8, column += 10
         ENDIF
       ENDFOR
       col column, line8, row + 1,
       new_sum_page = 0
      ENDIF
      col 0, products->qual[i].name";r", column = 30
      FOR (j = 1 TO size(aborh->qual,5))
        IF ((products->qual[i].prods[j].pooled_ind=0))
         IF ((products->qual[i].prods[j].count > 0))
          out_str = cnvtstring(products->qual[i].prods[j].count), col column, out_str
         ENDIF
         column += 10
        ENDIF
      ENDFOR
      out_str = cnvtstring(products->qual[i].tot_reg_count), col column, out_str,
      row + 1
    ENDFOR
    IF (pooled_prods_summary=1)
     print_pooled_headers = 1
     FOR (i = 1 TO size(products->qual,5))
      IF ((products->qual[i].tot_pool_count > 0))
       IF (row > 56)
        print_pooled_headers = 1, BREAK
       ENDIF
       IF (print_pooled_headers=1)
        column = 27
        FOR (j = 1 TO size(aborh->qual,5))
          IF ((aborh->qual[j].pooled_ind=1))
           col column, aborh->qual[j].abo_disp, column += 11
          ENDIF
        ENDFOR
        row + 1, column = 27
        FOR (j = 1 TO size(aborh->qual,5))
          IF ((aborh->qual[j].pooled_ind=1))
           col column, aborh->qual[j].rh_disp, column += 11
          ENDIF
        ENDFOR
        col column, captions->rpt_total, row + 1,
        column = 27
        FOR (j = 1 TO size(aborh->qual,5))
          IF ((aborh->qual[j].pooled_ind=1))
           col column, line8, column += 11
          ENDIF
        ENDFOR
        col column, line8, print_pooled_headers = 0,
        row + 1
       ENDIF
       col 0, products->qual[i].name";r", column = 30
       FOR (j = 1 TO size(products->qual[i].prods,5))
         IF ((products->qual[i].prods[j].pooled_ind=1))
          IF ((products->qual[i].prods[j].count > 0))
           out_str = cnvtstring(products->qual[i].prods[j].count), col column, out_str
          ENDIF
          column += 11
         ENDIF
       ENDFOR
       out_str = cnvtstring(products->qual[i].tot_pool_count), col column, out_str
      ENDIF
      ,row + 1
     ENDFOR
    ENDIF
   ENDIF
   row 57, col 0, line131,
   row + 1, col 0, cpm_cfn_info->file_name,
   col 113, captions->rpt_page, col 120,
   curpage";l", row + 1,
   CALL center(captions->end_of_report,1,125)
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  SET reply->status_data.status = "F"
  CALL subevent_add("Select Label Verified Products","F","bbd_rpt_lbl_verified_prods.prg",errmsg)
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
 FREE SET products
 FREE SET captions
 SET modify = nopredeclare
END GO
