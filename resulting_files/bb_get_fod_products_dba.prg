CREATE PROGRAM bb_get_fod_products:dba
 SET modify = predeclare
 DECLARE script_name = c19 WITH constant("bb_get_fod_products")
 DECLARE current_dt_tm_hold = dq8 WITH protect, constant(cnvtdatetime(sysdate))
 DECLARE default_begin_dt_tm = dq8 WITH protect, constant(cnvtdatetime("01-JAN-1800 00:00:00.00"))
 DECLARE dm_domain = vc WITH protect, constant("PATHNET_BBT")
 DECLARE lastupdtdttm = vc WITH protect, noconstant("LAST_FOD_DT_TM")
 DECLARE lastrptenddttm = dq8 WITH protect, noconstant(cnvtdatetime(default_begin_dt_tm))
 DECLARE lookbackdays = i2 WITH protect, noconstant(0)
 DECLARE temp_string = vc WITH protect, noconstant(fillstring(50," "))
 DECLARE days = i2 WITH protect, noconstant(1)
 DECLARE startpos = i2 WITH protect, noconstant(0)
 DECLARE commapos = i2 WITH protect, noconstant(0)
 DECLARE endpos = i2 WITH protect, noconstant(0)
 DECLARE locatevalidx = i4 WITH protect, noconstant(0)
 DECLARE productidxhold = i4 WITH protect, noconstant(0)
 DECLARE addupdatereplyind = i2 WITH protect, noconstant(0)
 DECLARE runningfromopsind = i2 WITH protect, noconstant(0)
 DECLARE validdispsereasonind = i2 WITH protect, noconstant(0)
 DECLARE pooledproductexistsind = i2 WITH protect, noconstant(0)
 DECLARE disposereasontocompare = c12 WITH protect, noconstant(fillstring(12," "))
 DECLARE mode_selection = vc WITH protect, noconstant("")
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE event_type_cs = i4 WITH protect, constant(1610)
 DECLARE method_type_cs = i4 WITH protect, constant(1609)
 DECLARE unconfirmed_event_type_mean = c12 WITH protect, constant("9")
 DECLARE unconfirmed_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE available_event_type_mean = c12 WITH protect, constant("12")
 DECLARE available_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE assigned_event_type_mean = c12 WITH protect, constant("1")
 DECLARE assigned_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE crossmatched_event_type_mean = c12 WITH protect, constant("3")
 DECLARE crossmatched_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE dispensed_event_type_mean = c12 WITH protect, constant("4")
 DECLARE dispensed_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE autologous_event_type_mean = c12 WITH protect, constant("10")
 DECLARE autologous_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE directed_event_type_mean = c12 WITH protect, constant("11")
 DECLARE directed_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE inprogress_event_type_mean = c12 WITH protect, constant("16")
 DECLARE inprogress_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE transfused_event_type_mean = c12 WITH protect, constant("7")
 DECLARE transfused_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE disposed_event_type_mean = c12 WITH protect, constant("5")
 DECLARE disposed_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE destroyed_event_type_mean = c12 WITH protect, constant("14")
 DECLARE destroyed_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE transfered_event_type_mean = c12 WITH protect, constant("6")
 DECLARE transferred_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE transfered_from_type_mean = c12 WITH protect, constant("26")
 DECLARE transferred_from_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE ship_inprog_type_mean = c12 WITH protect, constant("22")
 DECLARE ship_inprog_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE shipped_event_type_mean = c12 WITH protect, constant("15")
 DECLARE shipped_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE in_transit_type_mean = c12 WITH protect, constant("25")
 DECLARE in_transit_event_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE destroy_modify_mean = c12 WITH protect, constant("MODIFIED")
 DECLARE destroy_modify_cd = f8 WITH protect, noconstant(0.0)
 DECLARE timex_disp_rsn_mean = c12 WITH protect, constant("TIMEX")
 DECLARE otcol_disp_rsn_mean = c12 WITH protect, constant("OTCOL")
 DECLARE otcil_disp_rsn_mean = c12 WITH protect, constant("OTCIL")
 DECLARE ffail_disp_rsn_mean = c12 WITH protect, constant("FFAIL")
 DECLARE mornu_disp_rsn_mean = c12 WITH protect, constant("MORNU")
 DECLARE sornu_disp_rsn_mean = c12 WITH protect, constant("SORNU")
 DECLARE stmex_disp_rsn_mean = c12 WITH protect, constant("STMEX")
 DECLARE wosol_disp_rsn_mean = c12 WITH protect, constant("WOSOL")
 DECLARE wimpt_disp_rsn_mean = c12 WITH protect, constant("WIMPT")
 DECLARE miscn_disp_rsn_mean = c12 WITH protect, constant("MISCN")
 RECORD rts_events(
   1 rts_event_list[*]
     2 rts_event_id = f8
     2 ret_qty = i4
     2 ret_dt_tm = dq8
 )
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
 DECLARE chartable[37] = c1 WITH protect, noconstant
 SET chartable[1] = "0"
 SET chartable[2] = "1"
 SET chartable[3] = "2"
 SET chartable[4] = "3"
 SET chartable[5] = "4"
 SET chartable[6] = "5"
 SET chartable[7] = "6"
 SET chartable[8] = "7"
 SET chartable[9] = "8"
 SET chartable[10] = "9"
 SET chartable[11] = "A"
 SET chartable[12] = "B"
 SET chartable[13] = "C"
 SET chartable[14] = "D"
 SET chartable[15] = "E"
 SET chartable[16] = "F"
 SET chartable[17] = "G"
 SET chartable[18] = "H"
 SET chartable[19] = "I"
 SET chartable[20] = "J"
 SET chartable[21] = "K"
 SET chartable[22] = "L"
 SET chartable[23] = "M"
 SET chartable[24] = "N"
 SET chartable[25] = "O"
 SET chartable[26] = "P"
 SET chartable[27] = "Q"
 SET chartable[28] = "R"
 SET chartable[29] = "S"
 SET chartable[30] = "T"
 SET chartable[31] = "U"
 SET chartable[32] = "V"
 SET chartable[33] = "W"
 SET chartable[34] = "X"
 SET chartable[35] = "Y"
 SET chartable[36] = "Z"
 SET chartable[37] = "*"
 SUBROUTINE (calculatecheckdigit(productnumber=vc(value)) =c1)
   DECLARE productnbrlen = i2 WITH protect, noconstant(0)
   DECLARE avgoffset = i2 WITH protect, noconstant(0)
   DECLARE idx = i2 WITH protect, noconstant(0)
   DECLARE offset = i2 WITH protect, noconstant(0)
   DECLARE digit = c1 WITH protect, noconstant(" ")
   SET productnbrlen = size(productnumber,1)
   FOR (idx = 1 TO productnbrlen)
     SET digit = substring(idx,1,productnumber)
     IF (isnumeric(digit)=1)
      SET offset = (ichar(digit) - ichar("0"))
     ELSE
      SET offset = ((ichar(digit) - ichar("A"))+ 10)
     ENDIF
     SET avgoffset = mod(((avgoffset+ offset) * 2),37)
   ENDFOR
   SET offset = (mod((38 - avgoffset),37)+ 1)
   RETURN(chartable[offset])
 END ;Subroutine
 RECORD reply(
   1 destination_org_id = f8
   1 source_loc_cd = f8
   1 execution_dt_tm = dq8
   1 product_list[*]
     2 product_id = f8
     2 product_nbr = vc
     2 product_type = vc
     2 pooled_product_ind = i2
     2 abo_cd = f8
     2 rh_cd = f8
     2 product_event_cd = f8
     2 dispose_reason_cd = f8
     2 wasted_dt_tm = dq8
     2 person_id = f8
     2 patient_age = i2
     2 sex_cd = f8
     2 product_event_id = f8
     2 product_cd = f8
     2 blood_component_ind = i2
     2 expire_dt_tm = dq8
     2 event_dt_tm = dq8
     2 quantity = i4
     2 reason_cd = f8
     2 location_txt = vc
     2 cur_inv_area_cd = f8
     2 contributor_system_cd = f8
     2 ship_org_id = f8
     2 person_abo_cd = f8
     2 person_rh_cd = f8
     2 person_name_full_formatted = vc
     2 product_type_ident = vc
     2 encounter_id = f8
     2 modified_product_id = f8
     2 interface_product_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 modeind = i2
 )
 SET reply->status_data.status = "F"
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE uar_error = vc WITH protect, noconstant("")
 DECLARE hreq = i4 WITH protect, noconstant(0)
 DECLARE hcqmstruct = i4 WITH protect, noconstant(0)
 DECLARE holist = i4 WITH protect, noconstant(0)
 DECLARE horec = i4 WITH protect, noconstant(0)
 DECLARE hmsg = i4 WITH protect, noconstant(0)
 DECLARE hmsgstruct = i4 WITH protect, noconstant(0)
 DECLARE hprod = i4 WITH protect, noconstant(0)
 DECLARE hpers = i4 WITH protect, noconstant(0)
 DECLARE htrig = i4 WITH protect, noconstant(0)
 DECLARE dqueueid = f8 WITH protect, noconstant(0.0)
 DECLARE nidx = i4 WITH protect, noconstant(0)
 DECLARE hmsg1202007 = i4 WITH protect, noconstant(0)
 DECLARE hreq1202007 = i4 WITH protect, noconstant(0)
 DECLARE hrep1202007 = i4 WITH protect, noconstant(0)
 DECLARE hstatus_data = i4 WITH protect, noconstant(0)
 DECLARE replystatus = vc WITH protect, noconstant("")
 DECLARE debugind = i2 WITH protect, noconstant(0)
 DECLARE debuglogfile = vc WITH protect, noconstant("bb_fate_log")
 DECLARE transferred_from_only = i2 WITH protect, noconstant(1)
 DECLARE prod_cnt = i4 WITH protect, noconstant(0)
 DECLARE product_count = i4 WITH protect, noconstant(0)
 SUBROUTINE (errorhandler(operationstatus=c1(value),targetobjectname=vc(value),targetobjectvalue=vc(
   value)) =null)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt += 1
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = script_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = substring(1,25,
    targetobjectname)
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE (fsi1202007(no_param=i2) =i2)
   SET hmsg1202007 = uar_srvselectmessage(1202007)
   IF (hmsg1202007=0)
    CALL errorhandler("F","set hMsg1202007","hMsg1202007 returns 0")
   ENDIF
   SET hreq1202007 = uar_srvcreaterequest(hmsg1202007)
   IF (hreq1202007=0)
    CALL uar_srvdestroyinstance(hmsg1202007)
    CALL errorhandler("F","set hReq1202007","hReq1202007 returns 0")
   ENDIF
   SET hrep1202007 = uar_srvcreatereply(hmsg1202007)
   IF (hrep1202007=0)
    CALL uar_srvdestroyinstance(hmsg1202007)
    CALL uar_srvdestroyinstance(hreq1202007)
    CALL errorhandler("F","set hRep1202007","hRep1202007 returns 0")
   ENDIF
   FOR (nidx = 1 TO product_count)
     IF ((reply->product_list[nidx].pooled_product_ind != 1)
      AND size(trim(reply->product_list[nidx].product_type_ident)) > 0)
      SET hprod = uar_srvadditem(hreq1202007,"products")
      SET stat = uar_srvsetstring(hprod,"product_nbr",nullterm(reply->product_list[nidx].product_nbr)
       )
      SET stat = uar_srvsetstring(hprod,"product_type_identifier",nullterm(reply->product_list[nidx].
        product_type_ident))
      SET stat = uar_srvsetshort(hprod,"blood_component_ind",reply->product_list[nidx].
       blood_component_ind)
      SET stat = uar_srvsetdate(hprod,"expire_dt_tm",cnvtdatetime(reply->product_list[nidx].
        expire_dt_tm))
      IF (isreturntostockevent(reply->product_list[nidx].product_event_cd)=1)
       SET stat = uar_srvsetdouble(hprod,"product_event_cd",available_event_type_cd)
      ELSE
       SET stat = uar_srvsetdouble(hprod,"product_event_cd",reply->product_list[nidx].
        product_event_cd)
      ENDIF
      SET stat = uar_srvsetdate(hprod,"event_dt_tm",cnvtdatetime(reply->product_list[nidx].
        event_dt_tm))
      SET stat = uar_srvsetlong(hprod,"quantity",reply->product_list[nidx].quantity)
      SET stat = uar_srvsetdouble(hprod,"reason_cd",reply->product_list[nidx].reason_cd)
      SET stat = uar_srvsetstring(hprod,"location_txt",nullterm(reply->product_list[nidx].
        location_txt))
      SET stat = uar_srvsetdouble(hprod,"cur_inv_area_cd",reply->product_list[nidx].cur_inv_area_cd)
      SET stat = uar_srvsetdouble(hprod,"contributor_system_cd",reply->product_list[nidx].
       contributor_system_cd)
      SET stat = uar_srvsetdouble(hprod,"ship_org_id",reply->product_list[nidx].ship_org_id)
      IF ((reply->product_list[nidx].person_id > 0))
       SET hpers = uar_srvadditem(hprod,"persons")
       SET stat = uar_srvsetdouble(hpers,"person_id",reply->product_list[nidx].person_id)
       SET stat = uar_srvsetdouble(hpers,"encounter_id",reply->product_list[nidx].encounter_id)
       SET stat = uar_srvsetdouble(hpers,"abo_cd",reply->product_list[nidx].person_abo_cd)
       SET stat = uar_srvsetdouble(hpers,"rh_cd",reply->product_list[nidx].person_rh_cd)
      ENDIF
     ENDIF
   ENDFOR
   SET stat = uar_srvexecute(hmsg1202007,hreq1202007,hrep1202007)
   SET hstatus_data = uar_srvgetstruct(hrep1202007,"status_data")
   CALL uar_srvgetstring(hstatus_data,"status",replystatus,uar_srvgetstringlen(hstatus_data,"status")
    )
   IF (debugind=1)
    CALL uar_crmlogmessage(hreq1202007,"BBT_REQ_1202007.dat")
    CALL uar_crmlogmessage(hrep1202007,"BBT_REPLY_1202007.dat")
    CALL echorecord(request,debuglogfile,1)
    CALL echorecord(reply,debuglogfile,1)
    CALL echorecord(request)
    CALL echorecord(reply)
   ENDIF
   CALL uar_srvdestroyinstance(hreq1202007)
   CALL uar_srvdestroyinstance(hmsg1202007)
   CALL uar_srvdestroyinstance(hrep1202007)
   IF (replystatus="F")
    CALL errorhandler("F","FSI-Bloodet","Failure executing server step 1202007")
   ENDIF
 END ;Subroutine
 SUBROUTINE (isreturntostockevent(eventtypecd=f8) =i2)
   DECLARE ret = i2 WITH protect, noconstant(0)
   IF (eventtypecd < 0)
    SET ret = 1
   ENDIF
   RETURN(ret)
 END ;Subroutine
 SUBROUTINE (getpooledcomponents(no_param=i2) =i2)
   SELECT INTO "nl:"
    prd.product_id, prd.product_nbr, prd.product_sub_nbr,
    prd.pooled_product_ind, bp.supplier_prefix, bp.cur_abo_cd,
    bp.cur_rh_cd, bep.product_type_txt
    FROM (dummyt d1  WITH seq = value(size(reply->product_list,5))),
     product prd,
     blood_product bp,
     bb_edn_product bep,
     bb_edn_admin bea
    PLAN (d1
     WHERE (reply->product_list[d1.seq].pooled_product_ind=1))
     JOIN (prd
     WHERE (prd.pooled_product_id=reply->product_list[d1.seq].product_id))
     JOIN (bp
     WHERE bp.product_id=prd.product_id)
     JOIN (bep
     WHERE bep.product_id=bp.product_id)
     JOIN (bea
     WHERE (bea.bb_edn_admin_id= Outerjoin(bep.bb_edn_admin_id)) )
    HEAD REPORT
     row + 0
    DETAIL
     product_count += 1
     IF (product_count > size(reply->product_list,5))
      stat = alterlist(reply->product_list,(product_count+ 9))
     ENDIF
     reply->product_list[product_count].product_id = prd.product_id, reply->product_list[
     product_count].product_nbr = concat(trim(bp.supplier_prefix),trim(prd.product_nbr),trim(prd
       .product_sub_nbr))
     IF (size(trim(prd.product_nbr,3),1)=13
      AND substring(1,1,prd.product_nbr) != "!")
      reply->product_list[product_count].product_nbr = concat(reply->product_list[product_count].
       product_nbr,calculatecheckdigit(reply->product_list[product_count].product_nbr))
     ENDIF
     reply->product_list[product_count].pooled_product_ind = 0, reply->product_list[product_count].
     abo_cd = bp.cur_abo_cd, reply->product_list[product_count].rh_cd = bp.cur_rh_cd,
     reply->product_list[product_count].product_event_cd = reply->product_list[d1.seq].
     product_event_cd, reply->product_list[product_count].person_id = reply->product_list[d1.seq].
     person_id, reply->product_list[product_count].encounter_id = reply->product_list[d1.seq].
     encounter_id,
     reply->product_list[product_count].product_type = bep.product_type_txt
     IF ((reply->modeind=1))
      reply->product_list[product_count].product_type_ident = bep.product_type_ident, reply->
      product_list[product_count].contributor_system_cd = bea.contributor_system_cd, reply->
      product_list[product_count].product_cd = prd.product_cd
      IF (bep.expiration_dt_tm > 0.0)
       reply->product_list[product_count].expire_dt_tm = bep.expiration_dt_tm
      ELSE
       reply->product_list[product_count].expire_dt_tm = prd.cur_expire_dt_tm
      ENDIF
      reply->product_list[product_count].event_dt_tm = reply->product_list[d1.seq].event_dt_tm, reply
      ->product_list[product_count].person_name_full_formatted = reply->product_list[d1.seq].
      person_name_full_formatted, reply->product_list[product_count].person_abo_cd = reply->
      product_list[d1.seq].person_abo_cd,
      reply->product_list[product_count].person_rh_cd = reply->product_list[d1.seq].person_rh_cd,
      reply->product_list[product_count].quantity = reply->product_list[d1.seq].quantity, reply->
      product_list[product_count].reason_cd = reply->product_list[d1.seq].reason_cd,
      reply->product_list[product_count].cur_inv_area_cd = reply->product_list[d1.seq].
      cur_inv_area_cd, reply->product_list[product_count].location_txt = reply->product_list[d1.seq].
      location_txt, reply->product_list[product_count].ship_org_id = reply->product_list[d1.seq].
      ship_org_id,
      reply->product_list[product_count].blood_component_ind = reply->product_list[d1.seq].
      blood_component_ind
     ELSE
      reply->product_list[product_count].patient_age = reply->product_list[d1.seq].patient_age, reply
      ->product_list[product_count].sex_cd = reply->product_list[d1.seq].sex_cd, reply->product_list[
      product_count].dispose_reason_cd = reply->product_list[d1.seq].dispose_reason_cd,
      reply->product_list[product_count].wasted_dt_tm = reply->product_list[d1.seq].wasted_dt_tm
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->product_list,product_count)
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select pooled components",errmsg)
   ENDIF
 END ;Subroutine
 SUBROUTINE (writeoutputtofile(no_param=i2) =i2)
   EXECUTE cpm_create_file_name_logical "bb_get_fod_prods", "txt", "x"
   IF ((reply->modeind=1))
    SELECT INTO cpm_cfn_info->file_name_logical
     prod_number = substring(1,25,reply->product_list[d1.seq].product_nbr), prod_id = reply->
     product_list[d1.seq].product_id, product_type_ident = reply->product_list[d1.seq].
     product_type_ident,
     prod_event_cd = reply->product_list[d1.seq].product_event_cd, prod_event_disp = substring(1,15,
      uar_get_code_display(abs(reply->product_list[d1.seq].product_event_cd))), blood_component_ind
      = reply->product_list[d1.seq].blood_component_ind,
     expire_dt_tm = format(reply->product_list[d1.seq].expire_dt_tm,";;Q"), event_dt_tm = format(
      reply->product_list[d1.seq].event_dt_tm,";;Q"), reason_cd = reply->product_list[d1.seq].
     reason_cd,
     reason_disp = substring(1,25,uar_get_code_display(reply->product_list[d1.seq].reason_cd)),
     quantity = reply->product_list[d1.seq].quantity, location_txt = substring(1,25,reply->
      product_list[d1.seq].location_txt),
     cur_inv_area_cd = reply->product_list[d1.seq].cur_inv_area_cd, cur_inv_area_disp = substring(1,
      25,uar_get_code_display(reply->product_list[d1.seq].cur_inv_area_cd)), ship_org_id = reply->
     product_list[d1.seq].ship_org_id,
     ship_org_name = o.org_name, contributor_system_cd = reply->product_list[d1.seq].
     contributor_system_cd, contributor_system_disp = substring(1,15,uar_get_code_display(reply->
       product_list[d1.seq].contributor_system_cd)),
     person_id = reply->product_list[d1.seq].person_id, encounter_id = reply->product_list[d1.seq].
     encounter_id, person_name_full_formatted = substring(1,25,reply->product_list[d1.seq].
      person_name_full_formatted),
     person_abo_cd = reply->product_list[d1.seq].person_abo_cd, person_abo_disp = substring(1,10,
      uar_get_code_display(reply->product_list[d1.seq].person_abo_cd)), person_rh_cd = reply->
     product_list[d1.seq].person_rh_cd,
     person_rh_disp = substring(1,10,uar_get_code_display(reply->product_list[d1.seq].person_rh_cd)),
     prod_pooled_ind = reply->product_list[d1.seq].pooled_product_ind, edn_prod_type = substring(1,15,
      reply->product_list[d1.seq].product_type)
     FROM (dummyt d1  WITH seq = value(size(reply->product_list,5))),
      organization o
     PLAN (d1)
      JOIN (o
      WHERE (o.organization_id= Outerjoin(reply->product_list[d1.seq].ship_org_id)) )
     WITH format, format = pcformat
    ;end select
   ELSE
    SELECT INTO cpm_cfn_info->file_name_logical
     prod_number = substring(1,25,reply->product_list[d1.seq].product_nbr), prod_id = reply->
     product_list[d1.seq].product_id, prod_type = substring(1,15,reply->product_list[d1.seq].
      product_type),
     prod_event_cd = reply->product_list[d1.seq].product_event_cd, prod_event_disp = substring(1,15,
      uar_get_code_display(reply->product_list[d1.seq].product_event_cd)), prod_pooled_ind = reply->
     product_list[d1.seq].pooled_product_ind,
     prod_abo_cd = reply->product_list[d1.seq].abo_cd, prod_abo_disp = substring(1,10,
      uar_get_code_display(reply->product_list[d1.seq].abo_cd)), prod_rh_cd = reply->product_list[d1
     .seq].rh_cd,
     prod_rh_disp = substring(1,10,uar_get_code_display(reply->product_list[d1.seq].rh_cd)),
     prod_dispose_cd = reply->product_list[d1.seq].dispose_reason_cd, prod_dispose_disp = substring(1,
      20,uar_get_code_display(reply->product_list[d1.seq].dispose_reason_cd)),
     prod_wasted_dt_tm = format(reply->product_list[d1.seq].wasted_dt_tm,";;q"), person_id = reply->
     product_list[d1.seq].person_id, encounter_id = reply->product_list[d1.seq].encounter_id,
     person_age = reply->product_list[d1.seq].patient_age, person_sex_cd = reply->product_list[d1.seq
     ].sex_cd, person_sex_disp = substring(1,10,uar_get_code_display(reply->product_list[d1.seq].
       sex_cd))
     FROM (dummyt d1  WITH seq = value(size(reply->product_list,5)))
     ORDER BY prod_number, prod_id
     WITH format, format = pcformat
    ;end select
   ENDIF
   RETURN(0)
 END ;Subroutine
 SET unconfirmed_event_type_cd = uar_get_code_by("MEANING",event_type_cs,nullterm(
   unconfirmed_event_type_mean))
 IF (unconfirmed_event_type_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve event type code with meaning of ",trim(
    unconfirmed_event_type_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET available_event_type_cd = uar_get_code_by("MEANING",event_type_cs,nullterm(
   available_event_type_mean))
 IF (available_event_type_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve event type code with meaning of ",trim(
    available_event_type_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET assigned_event_type_cd = uar_get_code_by("MEANING",event_type_cs,nullterm(
   assigned_event_type_mean))
 IF (assigned_event_type_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve event type code with meaning of ",trim(
    assigned_event_type_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET crossmatched_event_type_cd = uar_get_code_by("MEANING",event_type_cs,nullterm(
   crossmatched_event_type_mean))
 IF (crossmatched_event_type_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve event type code with meaning of ",trim(
    crossmatched_event_type_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET dispensed_event_type_cd = uar_get_code_by("MEANING",event_type_cs,nullterm(
   dispensed_event_type_mean))
 IF (dispensed_event_type_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve event type code with meaning of ",trim(
    dispensed_event_type_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET autologous_event_type_cd = uar_get_code_by("MEANING",event_type_cs,nullterm(
   autologous_event_type_mean))
 IF (autologous_event_type_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve event type code with meaning of ",trim(
    autologous_event_type_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET directed_event_type_cd = uar_get_code_by("MEANING",event_type_cs,nullterm(
   directed_event_type_mean))
 IF (directed_event_type_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve event type code with meaning of ",trim(
    directed_event_type_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET inprogress_event_type_cd = uar_get_code_by("MEANING",event_type_cs,nullterm(
   inprogress_event_type_mean))
 IF (inprogress_event_type_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve event type code with meaning of ",trim(
    inprogress_event_type_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET transfused_event_type_cd = uar_get_code_by("MEANING",event_type_cs,nullterm(
   transfused_event_type_mean))
 IF (transfused_event_type_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve event type code with meaning of ",trim(
    transfused_event_type_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET transferred_from_event_type_cd = uar_get_code_by("MEANING",event_type_cs,nullterm(
   transfered_from_type_mean))
 IF (transferred_from_event_type_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve event type code with meaning of ",trim(
    transfered_from_type_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET disposed_event_type_cd = uar_get_code_by("MEANING",event_type_cs,nullterm(
   disposed_event_type_mean))
 IF (disposed_event_type_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve event type code with meaning of ",trim(
    disposed_event_type_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET destroyed_event_type_cd = uar_get_code_by("MEANING",event_type_cs,nullterm(
   destroyed_event_type_mean))
 IF (destroyed_event_type_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve event type code with meaning of ",trim(
    destroyed_event_type_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET transferred_event_type_cd = uar_get_code_by("MEANING",event_type_cs,nullterm(
   transfered_event_type_mean))
 IF (transferred_event_type_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve event type code with meaning of ",trim(
    transfered_event_type_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET shipped_event_type_cd = uar_get_code_by("MEANING",event_type_cs,nullterm(shipped_event_type_mean
   ))
 IF (shipped_event_type_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve event type code with meaning of ",trim(
    shipped_event_type_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET ship_inprog_event_type_cd = uar_get_code_by("MEANING",event_type_cs,nullterm(
   ship_inprog_type_mean))
 IF (ship_inprog_event_type_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve event type code with meaning of ",trim(
    ship_inprog_type_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET in_transit_event_type_cd = uar_get_code_by("MEANING",event_type_cs,nullterm(in_transit_type_mean
   ))
 IF (in_transit_event_type_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve event type code with meaning of ",trim(
    in_transit_type_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 SET destroy_modify_cd = uar_get_code_by("MEANING",method_type_cs,nullterm(destroy_modify_mean))
 IF (destroy_modify_cd <= 0.0)
  SET uar_error = concat("Failed to retrieve destruction method code with meaning of ",trim(
    destroy_modify_mean),".")
  CALL errorhandler("F","uar_get_code_by",uar_error)
 ENDIF
 IF (size(trim(request->batch_selection)) > 0)
  SET runningfromopsind = 1
  SET temp_string = cnvtupper(trim(request->batch_selection))
  SET reply->status_data.status = "Z"
  SET modify = nopredeclare
  CALL check_owner_cd(script_name)
  SET mode_selection = fillstring(8," ")
  CALL check_mode_opt(script_name)
  IF (trim(cnvtupper(mode_selection))="BLOODNET")
   SET reply->modeind = 1
   SET lastupdtdttm = "LAST_BN_FU_DT_TM"
  ENDIF
  SET modify = predeclare
  SET reply->status_data.status = "F"
  SET temp_string = cnvtupper(trim(request->batch_selection))
  SET startpos = cnvtint(value(findstring("DAYS[",temp_string)))
  IF (startpos > 0)
   SET startpos += 5
   SET endpos = cnvtint(value(findstring("]",temp_string,startpos)))
   IF (endpos > startpos)
    SET temp_string = trim(substring(startpos,(endpos - startpos),temp_string))
    SET startpos = 1
    SET endpos = size(temp_string,1)
    SET commapos = cnvtint(value(findstring(",",temp_string)))
    IF (commapos > 0)
     SET commapos += 1
     SET lookbackdays = cnvtint(trim(substring(commapos,endpos,temp_string)))
     SET endpos = (commapos - 1)
    ENDIF
    SET days = cnvtint(trim(substring(startpos,endpos,temp_string)))
   ENDIF
  ENDIF
  IF (days < 0)
   SET request->beg_dt_tm = default_begin_dt_tm
  ELSEIF (days=0)
   IF (readlastreportdttm(0) >= 0)
    IF (lastrptenddttm=0)
     SET request->beg_dt_tm = default_begin_dt_tm
    ELSE
     SET request->beg_dt_tm = cnvtdatetime(concat(format(cnvtdatetime(lastrptenddttm),
        "DD/MMM/YYYY HH:MM:SS;;D"),".00"))
     IF (lookbackdays > 0)
      IF (datetimeadd(request->beg_dt_tm,- (lookbackdays)) > 0)
       SET request->beg_dt_tm = datetimeadd(request->beg_dt_tm,- (lookbackdays))
      ELSE
       SET request->beg_dt_tm = default_begin_dt_tm
      ENDIF
     ENDIF
    ENDIF
   ELSE
    SET request->beg_dt_tm = default_begin_dt_tm
   ENDIF
  ELSE
   SET request->beg_dt_tm = datetimeadd(current_dt_tm_hold,- (days))
   SET request->beg_dt_tm = cnvtdatetime(cnvtdate(request->beg_dt_tm),0)
  ENDIF
  SET request->end_dt_tm = cnvtdatetime(concat(format(cnvtdatetime(current_dt_tm_hold),
     "DD/MMM/YYYY HH:MM:SS;;D"),".99"))
 ENDIF
 SET debugind = 0
 SELECT INTO "nl:"
  dm.info_char
  FROM dm_info dm
  WHERE dm.info_domain="PATHNET BLOOD BANK"
   AND dm.info_name="DEBUG BB_GET_FOD_PRODUCTS"
  DETAIL
   IF (dm.info_char="Y")
    debugind = 1
   ELSE
    debugind = 0
   ENDIF
  WITH nocounter
 ;end select
 SET reply->destination_org_id = 0.0
 SET reply->source_loc_cd = request->cur_owner_area_cd
 SET reply->execution_dt_tm = current_dt_tm_hold
 IF ((reply->modeind=1))
  CALL retrieveproductsforbloodnetfou(0)
 ELSE
  CALL retrieveproductsforfod(0)
 ENDIF
 IF (product_count <= 0)
  GO TO update_dm_info
 ENDIF
 IF (pooledproductexistsind=1)
  CALL getpooledcomponents(0)
 ENDIF
 CALL writeoutputtofile(0)
 IF ((reply->modeind=1))
  CALL fsi1202007(0)
 ELSE
  EXECUTE si_esocallsrtl
  SET hmsg = uar_srvselectmessage(1215071)
  SET hreq = uar_srvcreaterequest(hmsg)
  SET hmsgstruct = uar_srvgetstruct(hreq,"message")
  SET hcqmstruct = uar_srvgetstruct(hmsgstruct,"CQMInfo")
  SET stat = uar_srvsetstring(hcqmstruct,"AppName",nullterm("FSIESO"))
  SET stat = uar_srvsetstring(hcqmstruct,"ContribAlias",nullterm("BB_TRANS_DISP"))
  SET stat = uar_srvsetstring(hcqmstruct,"ContribRefnum",nullterm(concat(format(current_dt_tm_hold,
      ";;q")," ",cnvtstring(request->cur_owner_area_cd,19,0))))
  SET stat = uar_srvsetdate(hcqmstruct,"ContribDtTm",cnvtdatetime(sysdate))
  SET stat = uar_srvsetlong(hcqmstruct,"Priority",99)
  SET stat = uar_srvsetstring(hcqmstruct,"Class",nullterm("BB"))
  SET stat = uar_srvsetstring(hcqmstruct,"Type",nullterm("BTS"))
  SET stat = uar_srvsetstring(hcqmstruct,"Subtype",nullterm(""))
  SET stat = uar_srvsetstring(hcqmstruct,"Subtype_Detail",nullterm(""))
  SET stat = uar_srvsetlong(hcqmstruct,"Debug_Ind",0)
  SET stat = uar_srvsetlong(hcqmstruct,"Verbosity_Flag",0)
  SET htrig = uar_srvgetstruct(hmsgstruct,"TRIGInfo")
  SET stat = uar_srvsetdate(htrig,"execution_dt_tm",current_dt_tm_hold)
  SET stat = uar_srvsetdouble(htrig,"destination_org_id",0.0)
  SET stat = uar_srvsetdouble(htrig,"source_loc_cd",request->cur_owner_area_cd)
  FOR (nidx = 1 TO product_count)
    IF ((reply->product_list[nidx].pooled_product_ind != 1)
     AND size(trim(reply->product_list[nidx].product_type,3),1) > 0)
     SET hprod = uar_srvadditem(htrig,"product_list")
     SET stat = uar_srvsetstring(hprod,"product_nbr",nullterm(reply->product_list[nidx].product_nbr))
     SET stat = uar_srvsetstring(hprod,"product_type",nullterm(reply->product_list[nidx].product_type
       ))
     SET stat = uar_srvsetdouble(hprod,"abo_cd",reply->product_list[nidx].abo_cd)
     SET stat = uar_srvsetdouble(hprod,"rh_cd",reply->product_list[nidx].rh_cd)
     SET stat = uar_srvsetdouble(hprod,"product_event_cd",reply->product_list[nidx].product_event_cd)
     SET stat = uar_srvsetdouble(hprod,"dispose_reason_cd",reply->product_list[nidx].
      dispose_reason_cd)
     SET stat = uar_srvsetdate(hprod,"wasted_dt_tm",cnvtdatetime(reply->product_list[nidx].
       wasted_dt_tm))
     SET stat = uar_srvsetdouble(hprod,"person_id",reply->product_list[nidx].person_id)
     SET stat = uar_srvsetshort(hprod,"patient_age",reply->product_list[nidx].patient_age)
     SET stat = uar_srvsetdouble(hprod,"sex_cd",reply->product_list[nidx].sex_cd)
    ENDIF
  ENDFOR
  SET stat = uar_siscriptesoinsertcqm(hreq,dqueueid)
  CALL uar_srvdestroyinstance(hreq)
  IF (dqueueid <= 0.0)
   CALL errorhandler("F","FSI uar Call","FSI api call failed.")
  ENDIF
 ENDIF
#update_dm_info
 IF (runningfromopsind=1)
  SET stat = readlastreportdttm(1)
  IF (stat >= 1)
   UPDATE  FROM dm_info dm
    SET dm.info_date = cnvtdatetime(request->end_dt_tm), dm.updt_dt_tm = cnvtdatetime(sysdate), dm
     .updt_id = reqinfo->updt_id,
     dm.updt_cnt = (dm.updt_cnt+ 1), dm.updt_task = reqinfo->updt_task, dm.updt_applctx = 0
    PLAN (dm
     WHERE dm.info_domain=dm_domain
      AND dm.info_name=concat(lastupdtdttm,trim(cnvtstring(request->cur_owner_area_cd,19,0)))
      AND (dm.info_number=request->cur_owner_area_cd))
    WITH nocounter
   ;end update
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Update dm_info",errmsg)
   ENDIF
  ELSEIF (stat=0)
   INSERT  FROM dm_info dm
    SET dm.info_domain = dm_domain, dm.info_name = concat(lastupdtdttm,trim(cnvtstring(request->
        cur_owner_area_cd,19,0))), dm.info_date = cnvtdatetime(request->end_dt_tm),
     dm.info_number = request->cur_owner_area_cd, dm.updt_dt_tm = cnvtdatetime(sysdate), dm.updt_id
      = reqinfo->updt_id,
     dm.updt_cnt = 0, dm.updt_task = reqinfo->updt_task, dm.updt_applctx = 0
    PLAN (dm)
    WITH nocounter
   ;end insert
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Insert dm_info",errmsg)
   ENDIF
  ELSE
   CALL errorhandler("F","Lock dm_info","Failed to lock DM_INFO row.")
  ENDIF
 ENDIF
 GO TO set_status
 SUBROUTINE (readlastreportdttm(lock=i2(value)) =i2)
   SELECT
    IF (lock=1)
     WITH nocounter, forupdate(dm)
    ELSE
     WITH nocounter
    ENDIF
    INTO "nl:"
    dm.info_date
    FROM dm_info dm
    PLAN (dm
     WHERE dm.info_domain=dm_domain
      AND dm.info_name=concat(lastupdtdttm,trim(cnvtstring(request->cur_owner_area_cd,19,0)))
      AND (dm.info_number=request->cur_owner_area_cd))
    DETAIL
     IF (lock=0)
      lastrptenddttm = dm.info_date
     ENDIF
    WITH noounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select dm_info",errmsg)
   ENDIF
   RETURN(curqual)
 END ;Subroutine
 SUBROUTINE (retrieveproductsforfod(no_param=i2) =i2)
   SELECT INTO "nl:"
    pe.event_type_cd, p.person_id, p.birth_dt_tm,
    p.sex_cd, prd.product_id, prd.product_nbr,
    prd.product_sub_nbr, prd.pooled_product_ind, bp.supplier_prefix,
    bp.cur_abo_cd, bp.cur_rh_cd, bep.product_type_txt,
    d.reason_cd, disposereasonmean = uar_get_code_meaning(d.reason_cd), disposereasonmean2 =
    uar_get_code_meaning(d2.reason_cd)
    FROM product_event pe,
     person p,
     product prd,
     blood_product bp,
     bb_edn_product bep,
     disposition d,
     product_event pe2,
     disposition d2
    PLAN (pe
     WHERE pe.event_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
      end_dt_tm)
      AND pe.event_type_cd IN (unconfirmed_event_type_cd, available_event_type_cd,
     assigned_event_type_cd, crossmatched_event_type_cd, dispensed_event_type_cd,
     autologous_event_type_cd, directed_event_type_cd, inprogress_event_type_cd,
     transfused_event_type_cd, disposed_event_type_cd,
     destroyed_event_type_cd)
      AND ((pe.active_ind+ 0)=1))
     JOIN (p
     WHERE p.person_id=pe.person_id)
     JOIN (prd
     WHERE prd.product_id=pe.product_id
      AND (((request->cur_owner_area_cd > 0.0)
      AND ((prd.cur_owner_area_cd+ 0.0)=request->cur_owner_area_cd)) OR ((request->cur_owner_area_cd=
     0.0)))
      AND ((prd.pooled_product_id+ 0.0)=0.0))
     JOIN (bp
     WHERE bp.product_id=prd.product_id)
     JOIN (bep
     WHERE (bep.product_id= Outerjoin(bp.product_id)) )
     JOIN (d
     WHERE (d.product_event_id= Outerjoin(pe.product_event_id))
      AND ((d.active_ind+ 0.0)= Outerjoin(1)) )
     JOIN (pe2
     WHERE (pe2.product_event_id= Outerjoin(pe.related_product_event_id))
      AND (pe2.event_type_cd= Outerjoin(disposed_event_type_cd)) )
     JOIN (d2
     WHERE (d2.product_event_id= Outerjoin(pe2.product_event_id)) )
    HEAD REPORT
     product_count = 0
    DETAIL
     validdispsereasonind = 0
     IF (d.product_event_id > 0.0)
      disposereasontocompare = disposereasonmean
     ELSEIF (d2.product_event_id > 0.0)
      disposereasontocompare = disposereasonmean2
     ELSE
      disposereasontocompare = ""
     ENDIF
     IF (size(trim(disposereasontocompare,3),1) > 0)
      CASE (disposereasontocompare)
       OF timex_disp_rsn_mean:
       OF otcol_disp_rsn_mean:
       OF otcil_disp_rsn_mean:
       OF ffail_disp_rsn_mean:
       OF mornu_disp_rsn_mean:
       OF sornu_disp_rsn_mean:
       OF stmex_disp_rsn_mean:
       OF wosol_disp_rsn_mean:
       OF wimpt_disp_rsn_mean:
       OF miscn_disp_rsn_mean:
        validdispsereasonind = 1
       ELSE
        validdispsereasonind = 0
      ENDCASE
     ELSE
      validdispsereasonind = 1
     ENDIF
     IF (validdispsereasonind=1
      AND ((bep.product_id > 0.0) OR (prd.pooled_product_ind)) )
      addupdatereplyind = 0, productidxhold = locateval(locatevalidx,1,product_count,prd.product_id,
       reply->product_list[locatevalidx].product_id)
      IF (productidxhold <= 0)
       product_count += 1
       IF (product_count > size(reply->product_list,5))
        stat = alterlist(reply->product_list,(product_count+ 9))
       ENDIF
       productidxhold = product_count, addupdatereplyind = 1
      ELSE
       CASE (pe.event_type_cd)
        OF transfused_event_type_cd:
        OF disposed_event_type_cd:
        OF destroyed_event_type_cd:
         addupdatereplyind = 1
        OF assigned_event_type_cd:
        OF crossmatched_event_type_cd:
        OF dispensed_event_type_cd:
        OF autologous_event_type_cd:
        OF directed_event_type_cd:
        OF inprogress_event_type_cd:
         CASE (reply->product_list[productidxhold].product_event_cd)
          OF unconfirmed_event_type_cd:
          OF available_event_type_cd:
           addupdatereplyind = 1
          ELSE
           addupdatereplyind = 0
         ENDCASE
        ELSE
         addupdatereplyind = 0
       ENDCASE
      ENDIF
      IF (addupdatereplyind=1)
       reply->product_list[productidxhold].product_id = prd.product_id, reply->product_list[
       productidxhold].product_nbr = concat(trim(bp.supplier_prefix),trim(prd.product_nbr),trim(prd
         .product_sub_nbr))
       IF (size(trim(prd.product_nbr,3),1)=13
        AND substring(1,1,prd.product_nbr) != "!")
        reply->product_list[productidxhold].product_nbr = concat(reply->product_list[productidxhold].
         product_nbr,calculatecheckdigit(reply->product_list[productidxhold].product_nbr))
       ENDIF
       IF (prd.pooled_product_ind=1)
        pooledproductexistsind = 1
       ENDIF
       reply->product_list[productidxhold].pooled_product_ind = prd.pooled_product_ind, reply->
       product_list[productidxhold].product_type = bep.product_type_txt, reply->product_list[
       productidxhold].abo_cd = bp.cur_abo_cd,
       reply->product_list[productidxhold].rh_cd = bp.cur_rh_cd, reply->product_list[productidxhold].
       product_event_cd = pe.event_type_cd, reply->product_list[productidxhold].patient_age = - (1)
       CASE (pe.event_type_cd)
        OF transfused_event_type_cd:
         reply->product_list[productidxhold].person_id = p.person_id,
         IF (p.birth_dt_tm > 0.0)
          reply->product_list[productidxhold].patient_age = floor((datetimediff(current_dt_tm_hold,p
            .birth_dt_tm)/ 365))
         ENDIF
         ,reply->product_list[productidxhold].sex_cd = p.sex_cd,reply->product_list[productidxhold].
         wasted_dt_tm = pe.event_dt_tm
        OF disposed_event_type_cd:
        OF destroyed_event_type_cd:
         IF (disposereasontocompare=disposereasonmean)
          reply->product_list[productidxhold].dispose_reason_cd = d.reason_cd
         ELSEIF (disposereasontocompare=disposereasonmean2)
          reply->product_list[productidxhold].dispose_reason_cd = d2.reason_cd
         ELSE
          reply->product_list[productidxhold].dispose_reason_cd = 0.0
         ENDIF
         ,reply->product_list[productidxhold].wasted_dt_tm = pe.event_dt_tm
       ENDCASE
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->product_list,product_count)
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select product_event(FOD)",errmsg)
   ENDIF
 END ;Subroutine
 SUBROUTINE (retrieveproductsforbloodnetfou(no_param=i2) =i2)
   DECLARE prd_typ = vc WITH protect, noconstant("XX")
   CALL retrievertsforfou(0)
   SELECT DISTINCT INTO "nl:"
    pe.event_type_cd, p.person_id, prd.product_id,
    prd.interface_product_id, pe.product_id, bep.product_id,
    prd.product_nbr, prd.product_sub_nbr, prd.pooled_product_ind,
    bp.supplier_prefix, bp.cur_abo_cd, bp.cur_rh_cd,
    bep.product_type_txt, cur_qty = decode(ts.seq,ts.cur_transfused_qty,pd.seq,pd.cur_dispense_qty,d
     .seq,
     d.disposed_qty,ds.seq,ds.destroyed_qty,ag.seq,ag.cur_assign_qty,
     tr.seq,tr.transferred_qty,0), evt_reason_cd = decode(ag.seq,ag.assign_reason_cd,tr.seq,tr
     .transfer_reason_cd,sh.seq,
     sh.order_priority_cd,dp.seq,dp.reason_cd,d.seq,d.reason_cd,
     pd.seq,pd.dispense_reason_cd,0.0),
    loc_txt = decode(pd.seq,uar_get_code_display(pd.dispense_to_locn_cd),ds.seq,uar_get_code_display(
      prd.cur_inv_area_cd),d.seq,
     uar_get_code_display(prd.cur_inv_area_cd),ts.seq,uar_get_code_display(pd2.dispense_to_locn_cd),
     tr.seq,uar_get_code_display(tr.to_inv_area_cd),
     sh.seq,evaluate2(
      IF (sh.inventory_area_cd > 0) uar_get_code_display(sh.inventory_area_cd)
      ELSEIF (so.organization_id > 0) so.org_name
      ELSE ""
      ENDIF
      ),""), ship_org_id = decode(tr.seq,ti.organization_id,sh.seq,evaluate2(
      IF (si.location_cd > 0) si.organization_id
      ELSEIF (sh.organization_id > 0) sh.organization_id
      ELSE 0.0
      ENDIF
      ),0.0), dev_transfer_ind = decode(dt.seq,1,0)
    FROM product_event pe,
     person p,
     product prd,
     blood_product bp,
     bb_edn_product bep,
     bb_edn_admin eda,
     derivative de,
     assign ag,
     disposition d,
     person_aborh pa,
     patient_dispense pd,
     patient_dispense pd2,
     destruction ds,
     transfusion ts,
     bb_ship_event se,
     bb_shipment sh,
     bb_inventory_transfer tr,
     bb_device_transfer dt,
     location ti,
     location si,
     organization so,
     disposition dp,
     (dummyt d_pe  WITH seq = 1)
    PLAN (pe
     WHERE ((pe.event_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
      end_dt_tm)) OR (pe.updt_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request
      ->end_dt_tm)
      AND pe.event_type_cd IN (dispensed_event_type_cd, transfused_event_type_cd)
      AND ((pe.person_id+ 0.0) > 0.0)
      AND ((pe.active_ind+ 0)=1)))
      AND pe.event_type_cd IN (assigned_event_type_cd, crossmatched_event_type_cd,
     dispensed_event_type_cd, autologous_event_type_cd, directed_event_type_cd,
     transfused_event_type_cd, disposed_event_type_cd, destroyed_event_type_cd,
     transferred_event_type_cd, shipped_event_type_cd,
     ship_inprog_event_type_cd, in_transit_event_type_cd)
      AND ((pe.event_type_cd=transferred_event_type_cd) OR (((pe.active_ind+ 0)=1)))
      AND ((pe.event_status_flag < 1) OR (pe.event_status_flag=null))
      AND ((pe.event_type_cd != dispensed_event_type_cd) OR (((pe.person_id+ 0.0) > 0.0))) )
     JOIN (p
     WHERE p.person_id=pe.person_id)
     JOIN (prd
     WHERE prd.product_id=pe.product_id
      AND (((request->cur_owner_area_cd > 0.0)
      AND ((prd.cur_owner_area_cd+ 0.0)=request->cur_owner_area_cd)) OR ((request->cur_owner_area_cd=
     0.0)))
      AND ((prd.pooled_product_id+ 0.0)=0.0))
     JOIN (bep
     WHERE (bep.product_id= Outerjoin(evaluate2(
      IF (((prd.interface_product_id+ 0.0) > 0.0)) prd.interface_product_id
      ELSEIF (((prd.modified_product_id+ 0.0) > 0)) prd.modified_product_id
      ELSE prd.product_id
      ENDIF
      ))) )
     JOIN (eda
     WHERE (eda.bb_edn_admin_id= Outerjoin(bep.bb_edn_admin_id)) )
     JOIN (bp
     WHERE (bp.product_id= Outerjoin(prd.product_id)) )
     JOIN (de
     WHERE (de.product_id= Outerjoin(prd.product_id)) )
     JOIN (pa
     WHERE (pa.person_id= Outerjoin(p.person_id))
      AND (pa.active_ind= Outerjoin(1)) )
     JOIN (d_pe
     WHERE d_pe.seq=1)
     JOIN (((ag
     WHERE ag.product_event_id=pe.product_event_id)
     ) ORJOIN ((((ds
     WHERE ds.product_event_id=pe.product_event_id)
     JOIN (dp
     WHERE (dp.product_event_id= Outerjoin(pe.related_product_event_id)) )
     ) ORJOIN ((((pd
     WHERE pd.product_event_id=pe.product_event_id)
     ) ORJOIN ((((d
     WHERE d.product_event_id=pe.product_event_id)
     ) ORJOIN ((((ts
     WHERE ts.product_event_id=pe.product_event_id)
     JOIN (pd2
     WHERE (pd2.product_event_id= Outerjoin(pe.related_product_event_id)) )
     ) ORJOIN ((((tr
     WHERE tr.product_event_id=pe.product_event_id)
     JOIN (ti
     WHERE ti.location_cd=tr.to_inv_area_cd)
     ) ORJOIN ((((dt
     WHERE dt.product_event_id=pe.product_event_id)
     ) ORJOIN ((se
     WHERE se.product_event_id=pe.product_event_id)
     JOIN (sh
     WHERE sh.shipment_id=se.shipment_id)
     JOIN (si
     WHERE (si.location_cd= Outerjoin(sh.inventory_area_cd))
      AND (si.location_cd> Outerjoin(0.0)) )
     JOIN (so
     WHERE (so.organization_id= Outerjoin(sh.organization_id)) )
     )) )) )) )) )) )) ))
    ORDER BY pe.event_dt_tm DESC, pe.product_id, pe.product_event_id
    HEAD REPORT
     row + 0
    DETAIL
     IF (de.product_id > 0.0)
      prd_typ = "DE"
     ELSEIF (bp.product_id > 0.0)
      prd_typ = "BP"
     ELSE
      prd_typ = "XX"
     ENDIF
     IF (((bep.product_id > 0.0) OR (prd.pooled_product_ind=1))
      AND dev_transfer_ind != 1)
      addupdatereplyind = 0
      IF (prd_typ="DE")
       productidxhold = 0
      ELSE
       IF (istransferorshipevent(pe.event_type_cd)=1)
        productidxhold = 0
       ELSE
        productidxhold = 0, locatevalidx = 1
        WHILE (locatevalidx <= product_count)
         IF ((reply->product_list[locatevalidx].product_id=prd.product_id)
          AND istransferorshipevent(reply->product_list[locatevalidx].product_event_cd) != 1
          AND isreturntostockevent(reply->product_list[locatevalidx].product_event_cd) != 1)
          productidxhold = locatevalidx, locatevalidx = (product_count+ 1)
         ENDIF
         ,locatevalidx += 1
        ENDWHILE
       ENDIF
      ENDIF
      IF (pe.event_type_cd=destroyed_event_type_cd
       AND ds.method_cd=destroy_modify_cd)
       addupdatereplyind = 0
      ELSEIF (productidxhold <= 0)
       product_count += 1
       IF (product_count > size(reply->product_list,5))
        stat = alterlist(reply->product_list,(product_count+ 9))
       ENDIF
       productidxhold = product_count, addupdatereplyind = 1
      ELSE
       CASE (pe.event_type_cd)
        OF transfused_event_type_cd:
        OF disposed_event_type_cd:
        OF destroyed_event_type_cd:
         addupdatereplyind = 1
        OF assigned_event_type_cd:
        OF crossmatched_event_type_cd:
        OF dispensed_event_type_cd:
        OF autologous_event_type_cd:
        OF directed_event_type_cd:
        OF inprogress_event_type_cd:
         CASE (reply->product_list[productidxhold].product_event_cd)
          OF unconfirmed_event_type_cd:
          OF available_event_type_cd:
           addupdatereplyind = 1
          ELSE
           addupdatereplyind = 0
         ENDCASE
         ,
         IF (addupdatereplyind=0
          AND pe.event_type_cd=dispensed_event_type_cd)
          CASE (reply->product_list[productidxhold].product_event_cd)
           OF assigned_event_type_cd:
           OF crossmatched_event_type_cd:
           OF autologous_event_type_cd:
           OF directed_event_type_cd:
            addupdatereplyind = 1
          ENDCASE
         ENDIF
        ELSE
         addupdatereplyind = 0
       ENDCASE
      ENDIF
      IF (addupdatereplyind=1)
       reply->product_list[productidxhold].product_event_id = pe.product_event_id, reply->
       product_list[productidxhold].product_id = prd.product_id, reply->product_list[productidxhold].
       product_nbr = concat(trim(bp.supplier_prefix),trim(prd.product_nbr),trim(prd.product_sub_nbr))
       IF (size(trim(prd.product_nbr,3),1)=13
        AND substring(1,1,prd.product_nbr) != "!"
        AND prd_typ="BP")
        reply->product_list[productidxhold].product_nbr = concat(reply->product_list[productidxhold].
         product_nbr,calculatecheckdigit(reply->product_list[productidxhold].product_nbr))
       ENDIF
       IF (prd.pooled_product_ind=1)
        pooledproductexistsind = 1
       ENDIF
       reply->product_list[productidxhold].pooled_product_ind = prd.pooled_product_ind, reply->
       product_list[productidxhold].product_type = bep.product_type_txt, reply->product_list[
       productidxhold].abo_cd = bp.cur_abo_cd,
       reply->product_list[productidxhold].rh_cd = bp.cur_rh_cd, reply->product_list[productidxhold].
       product_cd = prd.product_cd, reply->product_list[productidxhold].product_type_ident = bep
       .product_type_ident,
       reply->product_list[productidxhold].product_event_cd = pe.event_type_cd, reply->product_list[
       productidxhold].event_dt_tm = pe.event_dt_tm, reply->product_list[productidxhold].
       contributor_system_cd = eda.contributor_system_cd,
       reply->product_list[productidxhold].interface_product_id = prd.interface_product_id
       IF (bep.expiration_dt_tm > 0.0)
        reply->product_list[productidxhold].expire_dt_tm = bep.expiration_dt_tm
       ELSE
        reply->product_list[productidxhold].expire_dt_tm = prd.cur_expire_dt_tm
       ENDIF
       IF (p.person_id > 0)
        reply->product_list[productidxhold].person_id = p.person_id, reply->product_list[
        productidxhold].person_name_full_formatted = p.name_full_formatted, reply->product_list[
        productidxhold].encounter_id = pe.encntr_id
        IF (pa.person_aborh_id > 0)
         reply->product_list[productidxhold].person_abo_cd = pa.abo_cd, reply->product_list[
         productidxhold].person_rh_cd = pa.rh_cd
        ENDIF
       ENDIF
       IF (prd_typ="DE")
        IF (((pe.event_type_cd=unconfirmed_event_type_cd) OR (((pe.event_type_cd=
        available_event_type_cd) OR (((pe.event_type_cd=autologous_event_type_cd) OR (pe
        .event_type_cd=directed_event_type_cd)) )) )) )
         reply->product_list[productidxhold].quantity = de.cur_avail_qty
        ELSE
         reply->product_list[productidxhold].quantity = cur_qty
        ENDIF
        reply->product_list[productidxhold].blood_component_ind = 0
       ELSEIF (prd_typ="BP")
        reply->product_list[productidxhold].quantity = 1, reply->product_list[productidxhold].
        blood_component_ind = 1
       ENDIF
       reply->product_list[productidxhold].reason_cd = evt_reason_cd
       IF (prd_typ="BP"
        AND pe.event_type_cd=transferred_event_type_cd)
        reply->product_list[productidxhold].cur_inv_area_cd = tr.from_inv_area_cd
       ELSE
        reply->product_list[productidxhold].cur_inv_area_cd = prd.cur_inv_area_cd
       ENDIF
       reply->product_list[productidxhold].location_txt = loc_txt, reply->product_list[productidxhold
       ].ship_org_id = ship_org_id
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(reply->product_list,product_count)
    WITH nocounter, outerjoin(d_pe)
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select product_event(BN)",errmsg)
   ENDIF
 END ;Subroutine
 SUBROUTINE (retrievertsforfou(no_param=i2) =i2)
   SELECT
    prod_event_id = c.product_event_id, ret_dt_tm = c.release_dt_tm, ret_qty = c.release_qty
    FROM crossmatch c
    WHERE ((c.release_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
     end_dt_tm)) UNION (
    (SELECT
     prod_event_id = ar.product_event_id, ret_dt_tm = ar.release_dt_tm, ret_qty = ar.release_qty
     FROM assign_release ar
     WHERE ((ar.release_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
      end_dt_tm)) UNION (
     (SELECT
      prod_event_id = dr.product_event_id, ret_dt_tm = dr.return_dt_tm, ret_qty = dr.return_qty
      FROM dispense_return dr
      WHERE dr.return_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
       end_dt_tm)))) )))
    HEAD REPORT
     nrecidx = 0
    DETAIL
     nrecidx += 1
     IF (mod(nrecidx,10)=1)
      stat = alterlist(rts_events->rts_event_list,(nrecidx+ 9))
     ENDIF
     rts_events->rts_event_list[nrecidx].rts_event_id = prod_event_id, rts_events->rts_event_list[
     nrecidx].ret_qty = ret_qty, rts_events->rts_event_list[nrecidx].ret_dt_tm = ret_dt_tm
    FOOT REPORT
     stat = alterlist(rts_events->rts_event_list,nrecidx)
    WITH nocounter, rdbunion
   ;end select
   SET rts_events_size = size(rts_events->rts_event_list,5)
   IF (rts_events_size > 0)
    SELECT INTO "nl:"
     pe.event_type_cd, p.person_id, prd.product_id,
     prd.interface_product_id, pe.product_id, bep.product_id,
     prd.product_nbr, prd.product_sub_nbr, prd.pooled_product_ind,
     bp.supplier_prefix, bp.cur_abo_cd, bp.cur_rh_cd,
     bep.product_type_txt
     FROM product_event pe,
      person p,
      product prd,
      blood_product bp,
      bb_edn_product bep,
      bb_edn_admin eda,
      derivative de,
      person_aborh pa
     PLAN (pe
      WHERE expand(num,1,rts_events_size,pe.product_event_id,rts_events->rts_event_list[num].
       rts_event_id))
      JOIN (p
      WHERE p.person_id=pe.person_id)
      JOIN (prd
      WHERE prd.product_id=pe.product_id
       AND (((request->cur_owner_area_cd > 0.0)
       AND (prd.cur_owner_area_cd=request->cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)
      ))
       AND prd.pooled_product_id=0.0)
      JOIN (bep
      WHERE (bep.product_id= Outerjoin(evaluate2(
       IF (prd.interface_product_id > 0.0) prd.interface_product_id
       ELSEIF (prd.modified_product_id > 0) prd.modified_product_id
       ELSE prd.product_id
       ENDIF
       ))) )
      JOIN (eda
      WHERE (eda.bb_edn_admin_id= Outerjoin(bep.bb_edn_admin_id)) )
      JOIN (bp
      WHERE (bp.product_id= Outerjoin(prd.product_id)) )
      JOIN (de
      WHERE (de.product_id= Outerjoin(prd.product_id)) )
      JOIN (pa
      WHERE (pa.person_id= Outerjoin(p.person_id))
       AND (pa.active_ind= Outerjoin(1)) )
     ORDER BY pe.updt_dt_tm, pe.product_id, pe.product_event_id
     HEAD REPORT
      stat = alterlist(reply->product_list,10), product_count = 0, pos = 0
     DETAIL
      IF (de.product_id > 0.0)
       prd_typ = "DE"
      ELSEIF (bp.product_id > 0.0)
       prd_typ = "BP"
      ELSE
       prd_typ = "XX"
      ENDIF
      IF (((bep.product_id > 0.0) OR (prd.pooled_product_ind=1)) )
       product_count += 1
       IF (mod(product_count,10)=1
        AND product_count > 10)
        stat = alterlist(reply->product_list,(product_count+ 9))
       ENDIF
       reply->product_list[product_count].product_event_id = pe.product_event_id, reply->
       product_list[product_count].product_id = prd.product_id, reply->product_list[product_count].
       product_nbr = concat(trim(bp.supplier_prefix),trim(prd.product_nbr),trim(prd.product_sub_nbr))
       IF (size(trim(prd.product_nbr,3),1)=13
        AND substring(1,1,prd.product_nbr) != "!"
        AND prd_typ="BP")
        reply->product_list[product_count].product_nbr = concat(reply->product_list[product_count].
         product_nbr,calculatecheckdigit(reply->product_list[product_count].product_nbr))
       ENDIF
       IF (prd.pooled_product_ind=1)
        pooledproductexistsind = 1
       ENDIF
       reply->product_list[product_count].pooled_product_ind = prd.pooled_product_ind, reply->
       product_list[product_count].product_type = bep.product_type_txt, reply->product_list[
       product_count].abo_cd = bp.cur_abo_cd,
       reply->product_list[product_count].rh_cd = bp.cur_rh_cd, reply->product_list[product_count].
       product_cd = prd.product_cd, reply->product_list[product_count].product_type_ident = bep
       .product_type_ident,
       reply->product_list[product_count].product_event_cd = - (pe.event_type_cd), pos = locateval(
        num,1,rts_events_size,pe.product_event_id,rts_events->rts_event_list[num].rts_event_id),
       reply->product_list[product_count].event_dt_tm = rts_events->rts_event_list[pos].ret_dt_tm,
       reply->product_list[product_count].contributor_system_cd = eda.contributor_system_cd, reply->
       product_list[product_count].interface_product_id = prd.interface_product_id
       IF (bep.expiration_dt_tm > 0.0)
        reply->product_list[product_count].expire_dt_tm = bep.expiration_dt_tm
       ELSE
        reply->product_list[product_count].expire_dt_tm = prd.cur_expire_dt_tm
       ENDIF
       IF (p.person_id > 0)
        reply->product_list[product_count].person_id = p.person_id, reply->product_list[product_count
        ].person_name_full_formatted = p.name_full_formatted, reply->product_list[product_count].
        encounter_id = pe.encntr_id
        IF (pa.person_aborh_id > 0)
         reply->product_list[product_count].person_abo_cd = pa.abo_cd, reply->product_list[
         product_count].person_rh_cd = pa.rh_cd
        ENDIF
       ENDIF
       IF (prd_typ="DE")
        reply->product_list[product_count].quantity = rts_events->rts_event_list[pos].ret_qty, reply
        ->product_list[product_count].blood_component_ind = 0
       ELSEIF (prd_typ="BP")
        reply->product_list[product_count].quantity = 1, reply->product_list[product_count].
        blood_component_ind = 1
       ENDIF
       reply->product_list[product_count].cur_inv_area_cd = prd.cur_inv_area_cd
      ENDIF
     FOOT REPORT
      stat = alterlist(reply->product_list,product_count)
     WITH nocounter, separator = " ", format,
      expand = 1
    ;end select
   ENDIF
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select RTS events(BN)",errmsg)
   ENDIF
 END ;Subroutine
 SUBROUTINE (istransferorshipevent(eventtypecd=f8) =i2)
   DECLARE ret = i2 WITH protect, noconstant(0)
   CASE (eventtypecd)
    OF transferred_event_type_cd:
    OF shipped_event_type_cd:
    OF in_transit_event_type_cd:
    OF ship_inprog_event_type_cd:
     SET ret = 1
    ELSE
     SET ret = 0
   ENDCASE
   RETURN(ret)
 END ;Subroutine
#set_status
 IF (product_count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET reqinfo->commit_ind = 1
#exit_script
END GO
