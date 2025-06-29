CREATE PROGRAM bbt_rpt_ct_ratio:dba
 RECORD reply(
   1 file_name = vc
   1 rpt_list[*]
     2 rpt_filename = vc
     2 data_blob = gvc
     2 data_blob_size = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET sline = fillstring(125,"-")
 DECLARE crossmatch_event_cd = f8
 DECLARE dispense_event_cd = f8
 DECLARE transfuse_event_cd = f8
 DECLARE prod_xm_cnt = f8
 DECLARE prod_disp_cnt = f8
 DECLARE prod_xm_trans_cnt = f8
 DECLARE prod_perc = f8
 DECLARE default_start_date = dq8 WITH constant(cnvtdatetime("01-JAN-1900 00:00:00.00"))
 DECLARE owner_disp = vc WITH protected, noconstant(" ")
 DECLARE inventory_disp = vc WITH protected, noconstant(" ")
 DECLARE dtbegin = dq8 WITH noconstant(cnvtdatetime(default_start_date))
 DECLARE dtend = dq8 WITH noconstant(cnvtdatetime(default_start_date))
 DECLARE dtcur = dq8 WITH noconstant(cnvtdatetime(sysdate))
 DECLARE serrmsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE ierrcode = i4 WITH noconstant(error(serrmsg,1))
 DECLARE istatusblkcnt = i4 WITH noconstant(0)
 DECLARE istat = i2 WITH noconstant(0)
 DECLARE all = vc WITH constant("All")
 DECLARE cur_owner_area_disp = c40 WITH protected, noconstant(" ")
 DECLARE provider_disp = c40 WITH protected, noconstant(" ")
 DECLARE cur_inv_area_disp = c40 WITH protected, noconstant(" ")
 DECLARE dm_domain = vc WITH constant("PATHNET_BBT")
 DECLARE dm_name = vc WITH noconstant("LAST_CT_REPORT_DT_TM")
 DECLARE prod_cnt = i4 WITH noconstant(0)
 SET stat = uar_get_meaning_by_codeset(1610,"3",1,crossmatch_event_cd)
 SET stat = uar_get_meaning_by_codeset(1610,"4",1,dispense_event_cd)
 SET stat = uar_get_meaning_by_codeset(1610,"7",1,transfuse_event_cd)
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
 FREE RECORD ekssourcerequest
 RECORD ekssourcerequest(
   1 module_dir = vc
   1 module_name = vc
   1 basblob = i2
 )
 FREE RECORD eksreply
 RECORD eksreply(
   1 info_line[*]
     2 new_line = vc
   1 data_blob = gvc
   1 data_blob_size = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SUBROUTINE (readexportfile(fullfilepath=vc) =null)
   SET stat = initrec(ekssourcerequest)
   SET stat = initrec(eksreply)
   DECLARE filename = vc WITH protect, noconstant
   DECLARE file_dir = vc WITH protect, noconstant
   DECLARE separator_pos = i2 WITH protect, noconstant(0)
   SET separator_pos = 0
   SET separator_pos = cnvtint(value(findstring(":",fullfilepath,1,1)))
   IF (separator_pos <= 0)
    SET separator_pos = cnvtint(value(findstring("/",fullfilepath,1,1)))
   ENDIF
   SET file_dir = concat(substring(1,(separator_pos - 1),fullfilepath),":")
   SET filename = substring((separator_pos+ 1),(size(fullfilepath) - separator_pos),fullfilepath)
   SET ekssourcerequest->module_dir = file_dir
   SET ekssourcerequest->module_name = filename
   SET ekssourcerequest->basblob = 1
   EXECUTE eks_get_source  WITH replace("REQUEST",ekssourcerequest), replace("REPLY",eksreply)
   RETURN
 END ;Subroutine
 SET prod_cnt = 0
 RECORD xm(
   1 prod_qual[*]
     2 product_id = f8
     2 product_cd = f8
     2 product_disp = vc
     2 product_cat_cd = f8
     2 product_cat_disp = vc
     2 order_provider_id = f8
     2 order_provider_name = vc
     2 bb_result_id = f8
     2 xm_cnt = i4
     2 transfuse_cnt = i4
     2 owner_area_disp = vc
     2 inv_area_disp = vc
     2 med_service_cd = f8
 )
 IF (textlen(trim(request->batch_selection))=0)
  CALL echo("ReportSelection")
 ELSE
  CALL echo("OPS")
  SET temp_string = cnvtupper(trim(request->batch_selection))
  CALL check_owner_cd("bbt_rpt_ct_ratio")
  CALL check_inventory_cd("bbt_rpt_ct_ratio")
  SET begday = request->ops_date
  SET endday = request->ops_date
  SET temp_string = cnvtupper(trim(request->batch_selection))
  CALL check_opt_date_passed("bbt_rpt_ct_ratio")
  IF ((reply->status_data.status != "F"))
   SET request->beg_dt_tm = begday
   SET request->end_dt_tm = endday
  ENDIF
 ENDIF
 SET dtbegin = cnvtdatetime(request->beg_dt_tm)
 SET dtend = cnvtdatetime(request->end_dt_tm)
 IF ((request->cur_owner_area_cd=0.0))
  SET cur_owner_area_disp = all
 ELSE
  SET cur_owner_area_disp = uar_get_code_display(request->cur_owner_area_cd)
 ENDIF
 IF ((request->cur_inv_area_cd=0.0))
  SET cur_inv_area_disp = all
 ELSE
  SET cur_inv_area_disp = uar_get_code_display(request->cur_inv_area_cd)
 ENDIF
 IF (dtbegin < dtend)
  SET istat = readcrossmatch(null)
  IF (istat=1)
   IF (readtransfusion(null))
    IF (generatereport(null))
     IF (updatedminfo(null))
      IF (textlen(trim(request->batch_selection))=0)
       CALL readexportfile(reply->file_name)
       IF ((eksreply->status_data[1].status="S"))
        CALL addtostatusblock("S","SCRIPT","S","SCRIPT","Success")
       ELSE
        CALL addtostatusblock("F","SCRIPT","F","BBT_RPT_CT_RATIO","Error reading report")
       ENDIF
      ELSE
       CALL addtostatusblock("S","SCRIPT","S","SCRIPT","Success")
      ENDIF
     ELSE
      CALL addtostatusblock("F","SCRIPT","F","SUpdateDMInfo","Failed in DM_INFO")
     ENDIF
    ELSE
     CALL addtostatusblock("F","SCRIPT","F","BBT_RPT_CT_RATIO","Error generating export")
    ENDIF
   ELSE
    CALL addtostatusblock("F","SCRIPT","F","SELECT","Failed in ReadTranfusion")
   ENDIF
  ELSEIF (istat=0)
   CALL addtostatusblock("F","SCRIPT","F","SELECT","Failed in ReadCrossmatch")
  ENDIF
 ELSE
  CALL addtostatusblock("F","DATA","F","VALIDATION","Export data not valid")
  CALL addtostatusblock("F","DATA","F","BEGINDTTM",format(dtbegin,";;q"))
  CALL addtostatusblock("F","DATA","F","ENDDTTM",format(dtend,";;q"))
 ENDIF
 SUBROUTINE (addtostatusblock(sstatus=vc,sopname=vc,sopstatus=vc,stargetobjname=vc,stargetobjvalue=vc
  ) =null)
   IF (sstatus > "")
    SET reply->status_data.status = sstatus
   ENDIF
   SET istatusblkcnt += 1
   IF (istatusblkcnt > 1)
    SET istat = alter(reply->status_data.subeventstatus,istatusblkcnt)
   ENDIF
   SET reply->status_data.subeventstatus[istatusblkcnt].operationname = sopname
   SET reply->status_data.subeventstatus[istatusblkcnt].operationstatus = sopstatus
   SET reply->status_data.subeventstatus[istatusblkcnt].targetobjectname = stargetobjname
   SET reply->status_data.subeventstatus[istatusblkcnt].targetobjectvalue = stargetobjvalue
 END ;Subroutine
 SUBROUTINE (checkforerror(sstatus=vc,sopname=vc,sopstatus=vc,stargetobjname=vc) =i2)
   SET ierrcode = error(serrmsg,0)
   IF (ierrcode > 0)
    WHILE (ierrcode)
     CALL addtostatusblock(sstatus,sopname,sopstatus,stargetobjname,serrmsg)
     SET ierrcode = error(serrmsg,0)
    ENDWHILE
    RETURN(1)
   ENDIF
   RETURN(0)
 END ;Subroutine
 DECLARE updatedminfo() = i2
 SUBROUTINE updatedminfo(null)
   SELECT INTO "nl:"
    dm.info_date
    FROM dm_info dm
    PLAN (dm
     WHERE dm.info_domain=dm_domain
      AND dm.info_name=dm_name)
    WITH nocounter
   ;end select
   IF (curqual >= 1)
    UPDATE  FROM dm_info dm
     SET dm.info_date = cnvtdatetime(sysdate), dm.updt_dt_tm = cnvtdatetime(sysdate), dm.updt_id =
      reqinfo->updt_id,
      dm.updt_cnt = (dm.updt_cnt+ 1), dm.updt_task = reqinfo->updt_task, dm.updt_applctx = 0
     PLAN (dm
      WHERE dm.info_domain=dm_domain
       AND dm.info_name=dm_name)
     WITH nocounter
    ;end update
    IF (checkforerror("F","UPDATE","F","DM_INFO"))
     CALL addtostatusblock("F","UPDATE","F","DM_INFO","Failed to update DM_INFO row")
     RETURN(0)
    ENDIF
   ELSEIF (curqual=0)
    INSERT  FROM dm_info dm
     SET dm.info_domain = dm_domain, dm.info_name = dm_name, dm.info_date = cnvtdatetime(sysdate),
      dm.updt_dt_tm = cnvtdatetime(sysdate), dm.updt_id = reqinfo->updt_id, dm.updt_cnt = 0,
      dm.updt_task = reqinfo->updt_task, dm.updt_applctx = 0
     PLAN (dm)
     WITH nocounter
    ;end insert
    IF (checkforerror("F","INSERT","F","DM_INFO"))
     CALL addtostatusblock("F","INSERT","F","DM_INFO","Failed to insert DM_INFO row")
     RETURN(0)
    ENDIF
   ELSE
    CALL addtostatusblock("F","SELECT","F","DM_INFO","Failed to lock DM_INFO row")
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE readcrossmatch() = i2
 SUBROUTINE readcrossmatch(null)
   SELECT INTO "nl"
    FROM crossmatch xm,
     product_event pe,
     product p,
     orders o,
     prsnl pl,
     product_event pe_alt,
     encounter en
    PLAN (xm
     WHERE xm.crossmatch_exp_dt_tm >= cnvtdatetime(request->beg_dt_tm)
      AND xm.crossmatch_exp_dt_tm <= cnvtdatetime(request->end_dt_tm))
     JOIN (pe
     WHERE pe.product_event_id=xm.product_event_id)
     JOIN (p
     WHERE p.product_id=pe.product_id
      AND (((request->cur_owner_area_cd > 0.0)
      AND (request->cur_owner_area_cd=p.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
      AND (((request->cur_inv_area_cd > 0.0)
      AND (request->cur_inv_area_cd=p.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
     JOIN (o
     WHERE o.order_id=pe.order_id
      AND (((request->provider_id > 0.0)
      AND (o.last_update_provider_id=request->provider_id)) OR ((request->provider_id=0.0))) )
     JOIN (pl
     WHERE pl.person_id=o.last_update_provider_id)
     JOIN (pe_alt
     WHERE pe_alt.bb_result_id=pe.bb_result_id
      AND pe_alt.event_type_cd=crossmatch_event_cd)
     JOIN (en
     WHERE en.encntr_id=o.encntr_id)
    ORDER BY pe.bb_result_id, pe_alt.product_id, pe_alt.product_event_id DESC
    HEAD REPORT
     xm_found = 0, first_product_cd = 0.0
    HEAD pe.bb_result_id
     xm_found = 0, first_product_id = pe_alt.product_id
    DETAIL
     IF (xm_found=0
      AND pe_alt.product_id=first_product_id)
      IF (p.product_id=pe_alt.product_id)
       IF (xm.product_event_id=pe_alt.product_event_id)
        xm_found = 1, prod_cnt += 1
        IF (size(xm->prod_qual,5) < prod_cnt)
         stat = alterlist(xm->prod_qual,(prod_cnt+ 10))
        ENDIF
        xm->prod_qual[prod_cnt].product_id = p.product_id, xm->prod_qual[prod_cnt].product_cd = p
        .product_cd
        IF ((request->debug_ind=1))
         xm->prod_qual[prod_cnt].product_disp = build(p.product_nbr,"_",pe.product_event_id)
        ELSE
         xm->prod_qual[prod_cnt].product_disp = uar_get_code_display(p.product_cd)
        ENDIF
        xm->prod_qual[prod_cnt].bb_result_id = pe.bb_result_id, xm->prod_qual[prod_cnt].
        order_provider_id = o.last_update_provider_id, xm->prod_qual[prod_cnt].order_provider_name =
        trim(pl.name_full_formatted),
        xm->prod_qual[prod_cnt].product_cat_cd = p.product_cat_cd, xm->prod_qual[prod_cnt].
        product_cat_disp = uar_get_code_display(p.product_cat_cd), xm->prod_qual[prod_cnt].xm_cnt = 1,
        xm->prod_qual[prod_cnt].owner_area_disp = uar_get_code_display(p.cur_owner_area_cd), xm->
        prod_qual[prod_cnt].inv_area_disp = uar_get_code_display(p.cur_inv_area_cd), xm->prod_qual[
        prod_cnt].med_service_cd = en.med_service_cd
       ENDIF
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(xm->prod_qual,prod_cnt), row + 1
    WITH nocounter
   ;end select
   CALL echo(prod_cnt)
   IF (prod_cnt=0)
    CALL addtostatusblock("Z","SCRIPT","Z","BBT_RPT_CT_RATIO","No Crossmatches Found")
    GO TO exit_script
   ENDIF
   IF (checkforerror("F","SELECT","F","Crossmatch"))
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 DECLARE readtransfusion() = i2
 SUBROUTINE readtransfusion(null)
   SET idx1 = 0
   SELECT INTO "nl:"
    FROM (dummyt d1  WITH seq = value(prod_cnt)),
     product_event pe_xm,
     product_event pe_disp,
     product_event pe_tx
    PLAN (d1)
     JOIN (pe_xm
     WHERE (pe_xm.bb_result_id=xm->prod_qual[d1.seq].bb_result_id)
      AND pe_xm.event_type_cd=crossmatch_event_cd)
     JOIN (pe_disp
     WHERE pe_disp.related_product_event_id=pe_xm.product_event_id
      AND pe_disp.event_type_cd=dispense_event_cd)
     JOIN (pe_tx
     WHERE pe_tx.related_product_event_id=pe_disp.product_event_id
      AND pe_tx.event_type_cd=transfuse_event_cd
      AND pe_tx.active_ind=1)
    ORDER BY pe_xm.bb_result_id
    HEAD pe_xm.bb_result_id
     IF (pe_tx.product_event_id != 0)
      xm->prod_qual[d1.seq].transfuse_cnt = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (checkforerror("F","SELECT","F","Transfusion"))
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 DECLARE generatereport() = i2
 SUBROUTINE generatereport(null)
   DECLARE res_count = i4 WITH noconstant(0)
   DECLARE sfilename = vc WITH noconstant("")
   SET formatdtcur = format(dtcur,"DD-MMM-YYYY HH:MM:SS;;D")
   SET formatdtbegin = format(dtbegin,"DD-MMM-YYYY HH:MM:SS;;D")
   SET formatdtend = format(dtend,"DD-MMM-YYYY HH:MM:SS;;D")
   SET logical d value(trim(logical("CER_PRINT")))
   SET sfilename = concat("d:bbt_rpt_ct_ratio",format(dtcur,"YYMMDDHHMMSSCC;;d"),".xml")
   SET reply->file_name = concat("cer_print:bbt_rpt_ct_ratio",format(dtcur,"YYMMDDHHMMSSCC;;d"),
    ".xml")
   SET res_count = prod_cnt
   SELECT INTO value(sfilename)
    provider_name = xm->prod_qual[d1.seq].order_provider_name"#####################################",
    provider_id = xm->prod_qual[d1.seq].order_provider_id, prod_disp = xm->prod_qual[d1.seq].
    product_disp"########################################",
    product_cat_disp = trim(xm->prod_qual[d1.seq].product_cat_disp)
    "#################################", owner_area_disp = trim(xm->prod_qual[d1.seq].owner_area_disp
     )"####################################", inv_area_disp = trim(xm->prod_qual[d1.seq].
     inv_area_disp)"########################################",
    med_service = trim(uar_get_code_display(xm->prod_qual[d1.seq].med_service_cd))
    "########################################"
    FROM (dummyt d1  WITH seq = value(prod_cnt))
    PLAN (d1)
    ORDER BY provider_name, provider_id, prod_disp,
     med_service
    HEAD REPORT
     col 0, "<?xml version='1.0'?>", row + 1,
     col 0, "<CT_report>", row + 1,
     col 2, "<Filter_criteria>", row + 1,
     col 4, "<Export_dt_tm_filter>", formatdtcur,
     "</Export_dt_tm_filter>", row + 1, col 4,
     "<Begin_date_filter>", formatdtbegin, "</Begin_date_filter>",
     row + 1, col 4, "<End_date_filter>",
     formatdtend, "</End_date_filter>", row + 1,
     col 4, "<cur_owner_area_disp_filter>", cur_owner_area_disp,
     "</cur_owner_area_disp_filter>", row + 1, col 4,
     "<cur_inv_area_disp_filter>", cur_inv_area_disp, "</cur_inv_area_disp_filter>",
     row + 1
     IF ((request->provider_id > 0))
      col 4, "<Provider_disp_filter>", provider_name,
      "</Provider_disp_filter>", row + 1
     ELSEIF ((request->provider_id=0))
      col 4, "<Provider_disp_filter>", all,
      "</Provider_disp_filter>", row + 1
     ENDIF
     col 2, "</Filter_criteria>", row + 1,
     prev_med_serv_cd = xm->prod_qual[d1.seq].med_service_cd, prev_inv_area_disp = inv_area_disp,
     prev_provider_disp = provider_name,
     prev_prod_disp = prod_disp, prev_med_service_disp = med_service, prev_owner_area_disp =
     owner_area_disp,
     prev_product_cat_disp = product_cat_disp, prod_xm_cnt = 0, prod_xm_trans_cnt = 0,
     prod_perc = 0.0
    DETAIL
     IF (prod_xm_cnt >= 1
      AND (((xm->prod_qual[d1.seq].med_service_cd != prev_med_serv_cd)) OR ((((xm->prod_qual[d1.seq].
     inv_area_disp != prev_inv_area_disp)) OR ((((xm->prod_qual[d1.seq].order_provider_name !=
     prev_provider_disp)) OR ((xm->prod_qual[d1.seq].product_disp != prev_prod_disp))) )) )) )
      col 2, "<CT_row>", row + 1,
      col 4, "<Owner_area>", prev_owner_area_disp,
      "</Owner_area>", row + 1, col 4,
      "<Inventory_area>", prev_inv_area_disp, "</Inventory_area>",
      row + 1, col 4, "<Product_category>",
      prev_product_cat_disp, "</Product_category>", row + 1,
      col 4, "<Product_type>", prev_prod_disp,
      "</Product_type>", row + 1, col 4,
      "<Number_of_units_crossmatched>", prod_xm_cnt, "</Number_of_units_crossmatched>",
      row + 1, col 4, "<Number_of_units_transfused>",
      prod_xm_trans_cnt, "</Number_of_units_transfused>", row + 1
      IF (prod_xm_trans_cnt=0)
       prod_perc = prod_xm_cnt
      ELSE
       prod_perc = (prod_xm_cnt/ prod_xm_trans_cnt)
      ENDIF
      col 4, "<CT_ratio>", prod_perc,
      "</CT_ratio>", row + 1, col 4,
      "<Physician>", prev_provider_disp, "</Physician>",
      row + 1, col 4, "<Medical_service>",
      prev_med_service_disp, "</Medical_service>", row + 1,
      col 2, "</CT_row>", row + 1,
      prod_xm_cnt = 0, prod_xm_trans_cnt = 0, prod_perc = 0.00
     ENDIF
     prod_xm_cnt += xm->prod_qual[d1.seq].xm_cnt
     IF ((xm->prod_qual[d1.seq].bb_result_id > 0))
      prod_xm_trans_cnt += xm->prod_qual[d1.seq].transfuse_cnt
     ENDIF
     prev_owner_area_disp = owner_area_disp, prev_med_serv_cd = xm->prod_qual[d1.seq].med_service_cd,
     prev_inv_area_disp = inv_area_disp,
     prev_provider_disp = provider_name, prev_prod_disp = prod_disp, prev_product_cat_disp =
     product_cat_disp,
     prev_med_service_disp = med_service
    FOOT REPORT
     col 2, "<CT_row>", row + 1,
     col 4, "<Owner_area>", owner_area_disp,
     "</Owner_area>", row + 1, col 4,
     "<Inventory_area>", inv_area_disp, "</Inventory_area>",
     row + 1, col 4, "<Product_category>",
     product_cat_disp, "</Product_category>", row + 1,
     col 4, "<Product_type>", prod_disp,
     "</Product_type>", row + 1, col 4,
     "<Number_of_units_crossmatched>", prod_xm_cnt, "</Number_of_units_crossmatched>",
     row + 1, col 4, "<Number_of_units_transfused>",
     prod_xm_trans_cnt, "</Number_of_units_transfused>", row + 1
     IF (prod_xm_trans_cnt=0)
      prod_perc = prod_xm_cnt
     ELSE
      prod_perc = (prod_xm_cnt/ prod_xm_trans_cnt)
     ENDIF
     col 4, "<CT_ratio>", prod_perc,
     "</CT_ratio>", row + 1, col 4,
     "<Physician>", provider_name, "</Physician>",
     row + 1, col 4, "<Medical_service>",
     med_service, "</Medical_service>", row + 1,
     col 2, "</CT_row>", row + 1,
     col 0, "</CT_report>", row + 1
    WITH nocounter, format = stream, formfeed = none,
     maxcol = 35000, maxrow = 1
   ;end select
   IF (checkforerror("F","SELECT","F","REPORT"))
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
#exit_script
 SET stat = alterlist(reply->rpt_list,1)
 SET reply->rpt_list[1].rpt_filename = reply->file_name
 IF (textlen(trim(request->batch_selection))=0)
  IF ((eksreply->status_data[1].status="S"))
   SET reply->rpt_list[1].data_blob = eksreply->data_blob
   SET reply->rpt_list[1].data_blob_size = eksreply->data_blob_size
  ENDIF
 ENDIF
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ENDIF
 FREE SET xm
END GO
