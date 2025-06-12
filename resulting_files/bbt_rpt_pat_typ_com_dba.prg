CREATE PROGRAM bbt_rpt_pat_typ_com:dba
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
 RECORD person_antib(
   1 antib_list[*]
     2 antib_display = c10
 )
 RECORD person_antig(
   1 antig_list[*]
     2 antig_display = c10
 )
 RECORD person_trans_req(
   1 trans_req_list[*]
     2 trans_req_display = c12
 )
 RECORD personhold_all(
   1 person_list[*]
     2 person_id = f8
 )
 RECORD personhold_unsorted(
   1 person_list[*]
     2 person_id = f8
 )
 RECORD personhold(
   1 person_list[*]
     2 person_id = f8
     2 person_id_alias_id = vc
     2 person_mrn_list[*]
       3 formatted_mrn = vc
 )
 RECORD bbcomment(
   1 qual[1]
     2 comment = vc
 )
 IF (trim(request->batch_selection) > " ")
  SET begday = request->ops_date
  SET endday = request->ops_date
  SET temp_string = cnvtupper(trim(request->batch_selection))
  CALL check_opt_date_passed("bbt_rpt_pat_typ_com")
  IF ((reply->status_data.status != "F"))
   SET request->beg_dt_tm = begday
   SET request->end_dt_tm = endday
  ENDIF
  SET request->patient_selection = 0.0
  SET sort_selection = fillstring(20," ")
  CALL check_sort_opt("bbt_rpt_pat_typ_com")
  IF (sort_selection="NAME")
   SET request->sort_selection = 0
  ELSEIF (sort_selection="MRN")
   SET request->sort_selection = 1
  ELSE
   SET request->sort_selection = 0
  ENDIF
  CALL check_location_cd("bbt_rpt_pat_typ_com")
  CALL check_facility_cd("bbt_rpt_pat_typ_com")
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
 DECLARE log_program_name = vc WITH protect, noconstant(curprog)
 IF (validate(glbsl_def,999)=999)
  CALL echo("Declaring GLBSL_DEF")
  DECLARE glbsl_def = i2 WITH protect, constant(1)
  DECLARE log_override_ind = i2 WITH protect, noconstant(0)
  SET log_override_ind = 0
  DECLARE log_level_error = i2 WITH protect, noconstant(0)
  DECLARE log_level_warning = i2 WITH protect, noconstant(1)
  DECLARE log_level_audit = i2 WITH protect, noconstant(2)
  DECLARE log_level_info = i2 WITH protect, noconstant(3)
  DECLARE log_level_debug = i2 WITH protect, noconstant(4)
  DECLARE hsys = h WITH protect, noconstant(0)
  DECLARE sysstat = i4 WITH protect, noconstant(0)
  DECLARE serrmsg = c132 WITH protect, noconstant(" ")
  DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
  DECLARE glbsl_msg_default = i4 WITH protect, noconstant(0)
  DECLARE glbsl_msg_level = i4 WITH protect, noconstant(0)
  EXECUTE msgrtl
  SET glbsl_msg_default = uar_msgdefhandle()
  SET glbsl_msg_level = uar_msggetlevel(glbsl_msg_default)
  CALL uar_syscreatehandle(hsys,sysstat)
  DECLARE lglbslsubeventcnt = i4 WITH protect, noconstant(0)
  DECLARE iglbslloggingstat = i2 WITH protect, noconstant(0)
  DECLARE lglbslsubeventsize = i4 WITH protect, noconstant(0)
  DECLARE iglbslloglvloverrideind = i2 WITH protect, noconstant(0)
  DECLARE sglbsllogtext = vc WITH protect, noconstant("")
  DECLARE sglbsllogevent = vc WITH protect, noconstant("")
  DECLARE iglbslholdloglevel = i2 WITH protect, noconstant(0)
  DECLARE iglbslerroroccured = i2 WITH protect, noconstant(0)
  DECLARE lglbsluarmsgwritestat = i4 WITH protect, noconstant(0)
  DECLARE glbsl_info_domain = vc WITH protect, constant("PATHNET SCRIPT LOGGING")
  DECLARE glbsl_logging_on = c1 WITH protect, constant("L")
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=glbsl_info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=glbsl_logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET iglbslloglvloverrideind = 0
   SET sglbsllogtext = ""
   SET sglbsllogevent = ""
   SET sglbsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET iglbslholdloglevel = loglvl
   ELSE
    IF (glbsl_msg_level < loglvl)
     SET iglbslholdloglevel = glbsl_msg_level
     SET iglbslloglvloverrideind = 1
    ELSE
     SET iglbslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (iglbslloglvloverrideind=1)
    SET sglbsllogevent = "ScriptOverride"
   ELSE
    CASE (iglbslholdloglevel)
     OF log_level_error:
      SET sglbsllogevent = "ScriptError"
     OF log_level_warning:
      SET sglbsllogevent = "ScriptWarning"
     OF log_level_audit:
      SET sglbsllogevent = "ScriptAudit"
     OF log_level_info:
      SET sglbsllogevent = "ScriptInfo"
     OF log_level_debug:
      SET sglbsllogevent = "ScriptDebug"
    ENDCASE
   ENDIF
   SET lglbsluarmsgwritestat = uar_msgwrite(glbsl_msg_default,0,nullterm(sglbsllogevent),
    iglbslholdloglevel,nullterm(sglbsllogtext))
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET iglbslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET iglbslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(iglbslerroroccured)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lglbslsubeventcnt = size(reply->status_data.subeventstatus,5)
    IF (lglbslsubeventcnt > 0)
     SET lglbslsubeventsize = size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       operationname))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       operationstatus))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       targetobjectname))
     SET lglbslsubeventsize += size(trim(reply->status_data.subeventstatus[lglbslsubeventcnt].
       targetobjectvalue))
    ELSE
     SET lglbslsubeventsize = 1
    ENDIF
    IF (lglbslsubeventsize > 0)
     SET lglbslsubeventcnt += 1
     SET iglbslloggingstat = alter(reply->status_data.subeventstatus,lglbslsubeventcnt)
    ENDIF
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET reply->status_data.subeventstatus[lglbslsubeventcnt].targetobjectvalue = targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((glbsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 IF (validate(bbt_get_pref_def,999)=999)
  DECLARE bbt_get_pref_def = i2 WITH protect, constant(1)
  RECORD prefvalues(
    1 prefs[*]
      2 value = vc
  )
  RECORD flexspectransparams(
    1 params[*]
      2 index = i4
      2 transfusionstartrange = i4
      2 transfusionendrange = i4
      2 specimenexpiration = i4
  )
  RECORD encounterlocations(
    1 locs[*]
      2 encfacilitycd = f8
  )
  DECLARE pref_level_bb = i2 WITH public, constant(1)
  DECLARE pref_level_flex = i2 WITH public, constant(2)
  DECLARE flex_spec_group = vc WITH protect, constant("flexible specimen")
  DECLARE pref_flex_spec_yes = vc WITH protect, constant("YES")
  DECLARE pref_flex_spec_no = vc WITH protect, constant("NO")
  DECLARE prefentryexists = i2 WITH protect, noconstant(0)
  DECLARE statbbpref = i2 WITH protect, noconstant(0)
 ENDIF
 SUBROUTINE (bbtgetencounterlocations(facility_code=f8(value),level_flag=i2(value)) =i2)
   DECLARE index = i2 WITH protect, noconstant(0)
   DECLARE loccnt = i2 WITH protect, noconstant(0)
   DECLARE prefcount = i2 WITH protect, noconstant(0)
   DECLARE flexprefentry = vc WITH protect, constant("patient encounter locations")
   SET statbbpref = initrec(encounterlocations)
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    flexprefentry)
   IF ((statbbpref=- (1)))
    IF (prefentryexists=1)
     RETURN(1)
    ELSE
     RETURN(- (1))
    ENDIF
   ENDIF
   SET prefcount = size(prefvalues->prefs,5)
   IF (prefcount=0)
    RETURN(1)
   ENDIF
   FOR (index = 1 TO prefcount)
     IF (cnvtreal(prefvalues->prefs[index].value) > 0.0)
      SET loccnt += 1
      IF (size(encounterlocations->locs,5) < loccnt)
       SET stat = alterlist(encounterlocations->locs,(loccnt+ 9))
      ENDIF
      SET encounterlocations->locs[loccnt].encfacilitycd = cnvtreal(prefvalues->prefs[index].value)
     ENDIF
   ENDFOR
   SET stat = alterlist(encounterlocations->locs,loccnt)
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (bbtgethistoricinfopreference(facility_code=f8(value)) =i2)
   DECLARE historical_demog_ind = i2 WITH protect, noconstant(0)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE prefentry = vc WITH protect, constant("print historical demographics")
   DECLARE code_set = i4 WITH protect, constant(20790)
   DECLARE historycd = f8 WITH protect, constant(uar_get_code_by("MEANING",code_set,"HISTORY"))
   IF ((historycd=- (1)))
    RETURN(0)
   ENDIF
   SELECT INTO "nl:"
    FROM code_value_extension cve
    WHERE cve.code_value=historycd
     AND cve.field_name="OPTION"
     AND cve.code_set=code_set
    DETAIL
     IF (trim(cve.field_value,3)="1")
      historical_demog_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   IF (historical_demog_ind=0)
    RETURN(0)
   ENDIF
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="Yes"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetcustompacklistpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("custom packing list program name")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetrequiredcourierdispenseassignpreference(facility_code=f8(value)) =i2)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("require dispense courier")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetrequiredcourierreturnproductspreference(facility_code=f8(value)) =i2)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("require return courier")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetinterfaceddevicespreference(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("uses interfaced devices")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(0)
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="1"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetbbtestingfacility(facility_code=f8(value)) =f8)
   RETURN(bbtgetflexspectestingfacility(facility_code))
 END ;Subroutine
 SUBROUTINE (bbtgetflexspectestingfacility(facility_code=f8(value)) =f8)
   DECLARE prefentry = vc WITH protect, constant("transfusion service facility")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF ((((statbbpref=- (1))) OR (size(prefvalues->prefs,5) > 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(prefvalues->prefs,5)=1)
    IF (size(trim(prefvalues->prefs[1].value)) > 0)
     SET strlogmessage = build("PrefEntry- ",prefentry,":",prefvalues->prefs[1].value,
      ",Facility Code:",
      facility_code)
     CALL log_message(strlogmessage,log_level_debug)
     RETURN(cnvtreal(trim(prefvalues->prefs[1].value,3)))
    ELSE
     RETURN(0.0)
    ENDIF
   ELSE
    RETURN(0.0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecenableflexexpiration(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("enable flex expiration")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF ((((statbbpref=- (1))) OR (size(prefvalues->prefs,5) > 1)) )
    SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
    CALL log_message(strlogmessage,log_level_error)
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(prefvalues->prefs,5)=1)
    IF ((prefvalues->prefs[1].value="1"))
     RETURN(1)
    ELSE
     RETURN(0)
    ENDIF
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecdefclinsigantibodyparams(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("def clin sig antibody params")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="1"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecxmalloexpunits(facility_code=f8(value)) =i4)
   DECLARE prefentry = vc WITH protect, constant("xm allogeneic expire units")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(cnvtint(trim(prefvalues->prefs[1].value,3)))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecxmautoexpunits(facility_code=f8(value)) =i4)
   DECLARE prefentry = vc WITH protect, constant("xm autologous expire units")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(cnvtint(trim(prefvalues->prefs[1].value,3)))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecmaxspecexpunits(facility_code=f8(value)) =i4)
   DECLARE prefentry = vc WITH protect, constant("max specimen expire units")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(cnvtint(trim(prefvalues->prefs[1].value,3)))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecclinsigantibodiesexpunits(facility_code=f8(value)) =i4)
   DECLARE prefentry = vc WITH protect, constant("clin sig antibodies exp units")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(cnvtint(trim(prefvalues->prefs[1].value,3)))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecextendtransfoverride(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("extend transf override")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ELSEIF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_no))
     RETURN(0)
    ELSE
     RETURN(1)
    ENDIF
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspeccalcposttransfspecsfromdawndt(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("calc post transf specs from drawn dt")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ELSEIF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_no))
     RETURN(0)
    ELSE
     RETURN(0)
    ENDIF
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecexpunittypemean(facility_code=f8(value)) =c12)
   DECLARE prefentry = vc WITH protect, constant("flex spec expiration unit type")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(trim(prefvalues->prefs[1].value,3))
   ELSE
    RETURN("")
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecxmtagsprinter(facility_code=f8(value)) =vc)
   DECLARE prefentry = vc WITH protect, constant("xm tags printer")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   RETURN(trim(prefvalues->prefs[1].value))
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecexceptionrptprinter(facility_code=f8(value)) =vc)
   DECLARE prefentry = vc WITH protect, constant("exception rpt printer")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   RETURN(trim(prefvalues->prefs[1].value))
 END ;Subroutine
 SUBROUTINE (bbtgetflexspectransfusionparameters(facility_code=f8(value)) =i2)
   DECLARE index = i2 WITH protect, noconstant(0)
   DECLARE prefcount = i2 WITH protect, noconstant(0)
   DECLARE strposhold = i2 WITH protect, noconstant(0)
   DECLARE strprevposhold = i2 WITH protect, noconstant(0)
   DECLARE strsize = i2 WITH protect, noconstant(0)
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE maxparamitems = i2 WITH protect, constant(4)
   DECLARE prefentry = vc WITH protect, constant("transfusion parameters")
   SET statbbpref = initrec(flexspectransparams)
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   SET prefcount = size(prefvalues->prefs,5)
   IF (((statbbpref != 1) OR (prefcount < 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET statbbpref = alterlist(flexspectransparams->params,prefcount)
   FOR (index = 1 TO prefcount)
     SET strsize = 0
     SET strsize = size(prefvalues->prefs[index].value)
     SET strposhold = findstring(",",prefvalues->prefs[index].value)
     SET flexspectransparams->params[index].index = cnvtint(substring(1,(strposhold - 1),prefvalues->
       prefs[index].value))
     SET strprevposhold = strposhold
     SET strposhold = findstring(",",prefvalues->prefs[index].value,(strprevposhold+ 1))
     SET flexspectransparams->params[index].transfusionstartrange = cnvtint(substring((strprevposhold
       + 1),((strposhold - strprevposhold) - 1),prefvalues->prefs[index].value))
     SET strprevposhold = strposhold
     SET strposhold = findstring(",",prefvalues->prefs[index].value,(strprevposhold+ 1))
     SET flexspectransparams->params[index].transfusionendrange = cnvtint(substring((strprevposhold+
       1),((strposhold - strprevposhold) - 1),prefvalues->prefs[index].value))
     SET flexspectransparams->params[index].specimenexpiration = cnvtint(substring((strposhold+ 1),(
       strsize - strposhold),prefvalues->prefs[index].value))
   ENDFOR
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (getbbpreference(sfacilityctx=vc,spositionctx=vc,suserctx=vc,ssubgroup=vc,sprefentry=vc
  ) =i2)
   DECLARE success_ind = i2 WITH protect, noconstant(0)
   DECLARE hpref = i4 WITH protect, noconstant(0)
   DECLARE hgroup = i4 WITH protect, noconstant(0)
   DECLARE hsection = i4 WITH protect, noconstant(0)
   DECLARE hgroup2 = i4 WITH protect, noconstant(0)
   DECLARE hsubgroup = i4 WITH protect, noconstant(0)
   DECLARE hsubgroup2 = i4 WITH protect, noconstant(0)
   DECLARE hval = i4 WITH protect, noconstant(0)
   DECLARE hattr = i4 WITH protect, noconstant(0)
   DECLARE hentry = i4 WITH protect, noconstant(0)
   DECLARE idxentry = i4 WITH protect, noconstant(0)
   DECLARE idxattr = i4 WITH protect, noconstant(0)
   DECLARE idxval = i4 WITH protect, noconstant(0)
   DECLARE subgroupcount = i4 WITH protect, noconstant(0)
   DECLARE namelen = i4 WITH protect, noconstant(255)
   DECLARE entryname = c255 WITH protect, noconstant(fillstring(255," "))
   DECLARE entrycount = i4 WITH protect, noconstant(0)
   DECLARE attrcount = i4 WITH protect, noconstant(0)
   DECLARE valcount = i4 WITH protect, noconstant(0)
   DECLARE valname = c255 WITH protect, noconstant(fillstring(255," "))
   DECLARE subgroupexists = i2 WITH protect, noconstant(0)
   EXECUTE prefrtl
   SET statbbpref = initrec(prefvalues)
   SET prefentryexists = 0
   SET hpref = uar_prefcreateinstance(0)
   IF (hpref=0)
    CALL log_message("Bad hPref, try logging in",log_level_error)
    RETURN(- (1))
   ENDIF
   SET statbbpref = uar_prefaddcontext(hpref,"default","system")
   IF (statbbpref != 1)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Bad default context",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (size(nullterm(sfacilityctx)) > 0)
    SET statbbpref = uar_prefaddcontext(hpref,"facility",nullterm(sfacilityctx))
    IF (statbbpref != 1)
     CALL uar_prefdestroyinstance(hpref)
     CALL log_message("Bad facility context",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   IF (size(nullterm(spositionctx)) > 0)
    SET statbbpref = uar_prefaddcontext(hpref,"position",nullterm(spositionctx))
    IF (statbbpref != 1)
     CALL uar_prefdestroyinstance(hpref)
     CALL log_message("Bad position context",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   IF (size(nullterm(suserctx)) > 0)
    SET statbbpref = uar_prefaddcontext(hpref,"user",nullterm(suserctx))
    IF (statbbpref != 1)
     CALL uar_prefdestroyinstance(hpref)
     CALL log_message("Bad user context",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET statbbpref = uar_prefsetsection(hpref,"module")
   IF (statbbpref != 1)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Bad section",log_level_error)
    RETURN(- (1))
   ENDIF
   SET hgroup = uar_prefcreategroup()
   SET statbbpref = uar_prefsetgroupname(hgroup,"blood bank")
   IF (statbbpref != 1)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Bad group name",log_level_error)
    RETURN(- (1))
   ENDIF
   SET statbbpref = uar_prefaddgroup(hpref,hgroup)
   IF (statbbpref != 1)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Error adding group",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (size(nullterm(ssubgroup)) > 0)
    SET subgroupexists = 1
    SET hsubgroup = uar_prefaddsubgroup(hgroup,nullterm(ssubgroup))
    IF (hsubgroup <= 0)
     CALL uar_prefdestroygroup(hgroup)
     CALL uar_prefdestroyinstance(hpref)
     CALL log_message("Error adding sub group",log_level_error)
     RETURN(- (1))
    ENDIF
   ENDIF
   SET statbbpref = uar_prefperform(hpref)
   IF (statbbpref != 1)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Error performing preference query",log_level_error)
    RETURN(- (1))
   ENDIF
   SET hsection = uar_prefgetsectionbyname(hpref,"module")
   SET hgroup2 = uar_prefgetgroupbyname(hsection,"blood bank")
   IF (subgroupexists=1)
    SET hsubgroup2 = uar_prefgetsubgroup(hgroup2,0)
    IF (hsubgroup2 <= 0)
     CALL uar_prefdestroysection(hsection)
     CALL uar_prefdestroygroup(hgroup2)
     CALL uar_prefdestroygroup(hgroup)
     CALL uar_prefdestroyinstance(hpref)
     CALL log_message("Error obtaining sub group",log_level_error)
     RETURN(- (1))
    ENDIF
    SET hgroup2 = hsubgroup2
   ENDIF
   SET entrycount = 0
   SET statbbpref = uar_prefgetgroupentrycount(hgroup2,entrycount)
   IF (statbbpref != 1)
    CALL uar_prefdestroysection(hsection)
    CALL uar_prefdestroygroup(hgroup2)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Error getting group entry count",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (entrycount <= 0)
    CALL uar_prefdestroysection(hsection)
    CALL uar_prefdestroygroup(hgroup2)
    CALL uar_prefdestroygroup(hgroup)
    CALL uar_prefdestroyinstance(hpref)
    CALL log_message("Preferences not found",log_level_error)
    RETURN(0)
   ENDIF
   FOR (idxentry = 0 TO (entrycount - 1))
     SET hentry = uar_prefgetgroupentry(hgroup2,idxentry)
     SET namelen = 255
     SET entryname = fillstring(255," ")
     SET statbbpref = uar_prefgetentryname(hentry,entryname,namelen)
     IF (statbbpref != 1)
      CALL uar_prefdestroyentry(hentry)
      CALL uar_prefdestroysection(hsection)
      CALL uar_prefdestroygroup(hgroup2)
      CALL uar_prefdestroygroup(hgroup)
      CALL uar_prefdestroyinstance(hpref)
      CALL log_message("Error getting entry name",log_level_error)
      RETURN(- (1))
     ENDIF
     IF (nullterm(entryname)=nullterm(sprefentry))
      SET prefentryexists = 1
      SET attrcount = 0
      SET statbbpref = uar_prefgetentryattrcount(hentry,attrcount)
      IF (((statbbpref != 1) OR (attrcount=0)) )
       CALL uar_prefdestroyentry(hentry)
       CALL uar_prefdestroysection(hsection)
       CALL uar_prefdestroygroup(hgroup2)
       CALL uar_prefdestroygroup(hgroup)
       CALL uar_prefdestroyinstance(hpref)
       CALL log_message("Bad entryAttrCount",log_level_error)
       RETURN(- (1))
      ENDIF
      FOR (idxattr = 0 TO (attrcount - 1))
        SET hattr = uar_prefgetentryattr(hentry,idxattr)
        DECLARE attrname = c255
        SET namelen = 255
        SET statbbpref = uar_prefgetattrname(hattr,attrname,namelen)
        IF (nullterm(attrname)="prefvalue")
         SET valcount = 0
         SET statbbpref = uar_prefgetattrvalcount(hattr,valcount)
         SET idxval = 0
         SET statbbpref = alterlist(prefvalues->prefs,valcount)
         FOR (idxval = 0 TO (valcount - 1))
           SET valname = fillstring(255," ")
           SET namelen = 255
           SET hval = uar_prefgetattrval(hattr,valname,namelen,idxval)
           SET prefvalues->prefs[(idxval+ 1)].value = nullterm(valname)
         ENDFOR
         IF (hattr > 0)
          CALL uar_prefdestroyattr(hattr)
         ENDIF
         IF (hentry > 0)
          CALL uar_prefdestroyentry(hentry)
         ENDIF
         IF (hsection > 0)
          CALL uar_prefdestroysection(hsection)
         ENDIF
         IF (hgroup2 > 0)
          CALL uar_prefdestroygroup(hgroup2)
         ENDIF
         IF (hgroup > 0)
          CALL uar_prefdestroygroup(hgroup)
         ENDIF
         IF (hpref > 0)
          CALL uar_prefdestroyinstance(hpref)
         ENDIF
         RETURN(1)
        ENDIF
      ENDFOR
     ENDIF
   ENDFOR
   IF (hattr > 0)
    CALL uar_prefdestroyattr(hattr)
   ENDIF
   IF (hentry > 0)
    CALL uar_prefdestroyentry(hentry)
   ENDIF
   IF (hsection > 0)
    CALL uar_prefdestroysection(hsection)
   ENDIF
   IF (hgroup2 > 0)
    CALL uar_prefdestroygroup(hgroup2)
   ENDIF
   IF (hgroup > 0)
    CALL uar_prefdestroygroup(hgroup)
   ENDIF
   IF (hpref > 0)
    CALL uar_prefdestroyinstance(hpref)
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtgetxmtagpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE prefentry = vc WITH protect, constant("crossmatch tag program name")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetcomponenttagpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("component tag program name")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetemergencytagpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE prefentry = vc WITH protect, constant("emergency tag program name")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    RETURN(trim(prefvalues->prefs[1].value))
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexfilterbyfacility(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("filter specimens by facility")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE flex_on_ind = i2 WITH protect, noconstant(0)
   SET flex_on_ind = bbtgetflexspecenableflexexpiration(facility_code)
   IF (flex_on_ind=0)
    RETURN(0)
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtdispgetproductorderassocpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("associate to prod orders on dispense")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN("")
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    IF (trim(prefvalues->prefs[1].value)="1")
     RETURN("Yes")
    ELSE
     RETURN("No")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecahgxmatch(facility_code=f8(value)) =vc)
   DECLARE prefentry = vc WITH protect, constant("ahg crossmatch")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    IF (trim(prefvalues->prefs[1].value)="1")
     RETURN("Yes")
    ELSE
     RETURN("No")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetaborhdiscrepancy(facility_code=f8(value)) =vc)
   DECLARE prefentry = vc WITH protect, constant("abo discrepancy")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    IF (trim(prefvalues->prefs[1].value)="1")
     RETURN("Yes")
    ELSE
     RETURN("No")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexspecneonatedaysdefined(facility_code=f8(value)) =i4)
   DECLARE prefentry = vc WITH protect, constant("neonate day spec override")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    RETURN(cnvtint(trim(prefvalues->prefs[1].value,3)))
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetflexexpiredspecimenexpirationovrd(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("extend expired specimen expiration")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET flex_on_ind = bbtgetflexspecenableflexexpiration(facility_code)
   IF (flex_on_ind=0)
    RETURN(0)
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtgetdisponcurrentaborh(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("dispense based on current aborh")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE flex_on_ind = i2 WITH protect, noconstant(0)
   SET flex_on_ind = bbtgetflexspecenableflexexpiration(facility_code)
   IF (flex_on_ind=0)
    RETURN(0)
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtgetdisponsecondaborh(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("dispense based on two aborh")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE flex_on_ind = i2 WITH protect, noconstant(0)
   SET flex_on_ind = bbtgetflexspecenableflexexpiration(facility_code)
   IF (flex_on_ind=0)
    RETURN(0)
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtgetflexexpiredspecimenneonatedischarge(facility_code=f8(value)) =i2)
   DECLARE prefentry = vc WITH protect, constant("extend neonate specimen discharge")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET flex_on_ind = bbtgetflexspecenableflexexpiration(facility_code)
   IF (flex_on_ind=0)
    RETURN(0)
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","",flex_spec_group,
    prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_debug)
    ENDIF
    RETURN(- (1))
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF (size(trim(prefvalues->prefs[1].value)) > 0)
    IF (cnvtupper(trim(prefvalues->prefs[1].value,3))=cnvtupper(pref_flex_spec_yes))
     RETURN(1)
    ENDIF
   ENDIF
   RETURN(0)
 END ;Subroutine
 SUBROUTINE (bbtcorrectcommentpromptpreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("result comment prompt")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN("")
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value=trim("")))
    RETURN("")
   ELSE
    IF (trim(prefvalues->prefs[1].value)="1")
     RETURN("Yes")
    ELSE
     RETURN("No")
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE bbtprintdispenseencounteridentifier(facility_code)
   DECLARE prefentry = vc WITH protect, constant("print dispense encounter identifier")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_debug)
    ENDIF
    RETURN(0)
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="1"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetsamplevalidityorderspreference(facility_code=f8(value)) =vc)
   DECLARE testing_facility_cd = f8 WITH protect, noconstant(0.0)
   DECLARE prefentry = vc WITH protect, constant("sample validity qualifying orders")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   DECLARE strpref = vc WITH protect, noconstant("")
   SET testing_facility_cd = bbtgetbbtestingfacility(facility_code)
   IF ((testing_facility_cd=- (1)))
    CALL log_message("Error getting BB transfusion service facility preference.",log_level_error)
    RETURN(- (1))
   ENDIF
   IF (testing_facility_cd=0.0)
    SET testing_facility_cd = facility_code
   ENDIF
   SET statbbpref = getbbpreference(trim(cnvtstring(testing_facility_cd,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) < 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",
      testing_facility_cd)
     CALL log_message(strlogmessage,log_level_error)
    ENDIF
    RETURN("")
   ENDIF
   FOR (index = 1 TO size(prefvalues->prefs,5))
     IF (strpref="")
      SET strpref = concat(strpref,prefvalues->prefs[index].value)
     ELSE
      SET strpref = concat(strpref,",",prefvalues->prefs[index].value)
     ENDIF
   ENDFOR
   SET strlogmessage = build("PrefEntry- ",prefentry," : ",strpref,",Facility Code:",
    testing_facility_cd)
   CALL log_message(strlogmessage,log_level_debug)
   RETURN(strpref)
 END ;Subroutine
 SUBROUTINE bbtgetbbidtagpreference(facility_code)
   DECLARE prefentry = vc WITH protect, constant("disp bbid 2d tags")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_debug)
    ENDIF
    RETURN(0)
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="1"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SUBROUTINE (bbtgetprodtagverifypreference(facility_code=f8(value)) =vc)
   DECLARE prefentry = vc WITH protect, constant("product tag verification")
   DECLARE strlogmessage = vc WITH protect, noconstant("")
   SET statbbpref = getbbpreference(trim(cnvtstring(facility_code,32,2)),"","","",prefentry)
   IF (((statbbpref != 1) OR (size(prefvalues->prefs,5) != 1)) )
    IF (statbbpref <= 0)
     SET strlogmessage = build(" Missing Preference :",prefentry,", Facility Code ",facility_code)
     CALL log_message(strlogmessage,log_level_debug)
    ENDIF
    RETURN(0)
   ENDIF
   SET strlogmessage = build("Pref Entry - ",prefentry," : ",prefvalues->prefs[1].value,
    ",Facility Code:",
    facility_code)
   CALL log_message(strlogmessage,log_level_debug)
   IF ((prefvalues->prefs[1].value="1"))
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
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
 RECORD tmptext(
   1 qual[*]
     2 text = vc
 )
 DECLARE uar_get_ceblobsize(p1=f8(ref),p2=vc(ref)) = i4 WITH image_aix =
 "uar_ce_blob.a(uar_ce_blob.o)", uar = "uar_get_ceblobsize", persist
 DECLARE uar_get_ceblob(p1=f8(ref),p2=vc(ref),p3=vc(ref),p4=i4(value)) = i4 WITH image_aix =
 "uar_ce_blob.a(uar_ce_blob.o)", uar = "uar_get_ceblob", persist
 RECORD recdate(
   1 datetime = dq8
 ) WITH protect
 DECLARE format = i2
 DECLARE outbuffer = vc
 DECLARE nortftext = vc
 SET format = 0
 DECLARE txt_pos = i4
 DECLARE start = i4
 DECLARE len = i4
 DECLARE linecnt = i4
 SUBROUTINE (rtf_to_text(rtftext=vc,format=i2,line_len=i2) =null)
   SET all_len = 0
   SET start = 0
   SET len = 0
   SET text_pos = 0
   SET linecnt = 0
   SET inbuffer = fillstring(value(size(rtftext))," ")
   SET outbufferlen = 0
   SET bfl = 0
   SET bfl2 = 1
   SET outbuffer = ""
   SET nortftext = ""
   SET stat = memrealloc(outbuffer,1,build("C",value(size(rtftext))))
   SET stat = memrealloc(nortftext,1,build("C",value(size(rtftext))))
   IF (substring(1,5,rtftext)=asis("{\rtf"))
    SET inbuffer = trim(rtftext)
    CALL uar_rtf2(inbuffer,size(inbuffer),outbuffer,size(outbuffer),outbufferlen,
     bfl)
   ELSE
    SET outbuffer = trim(rtftext)
   ENDIF
   SET nortftext = trim(outbuffer)
   SET stat = alterlist(tmptext->qual,0)
   SET crchar = concat(char(13),char(10))
   SET lfchar = char(10)
   SET ffchar = char(12)
   IF (format > 0)
    SET all_len = cnvtint(size(trim(outbuffer)))
    SET tot_len = 0
    SET start = 1
    SET bigfirst = "Y"
    SET crstart = start
    WHILE (all_len > tot_len)
      SET crpos = crstart
      SET crfirst = "Y"
      SET loaded = "N"
      WHILE ((crpos <= ((crstart+ line_len)+ 1))
       AND loaded="N"
       AND all_len > tot_len)
       IF ((crpos=((crstart+ line_len)+ 1))
        AND crfirst="N")
        SET start = crstart
        SET first = "Y"
        SET text_pos = ((start+ line_len) - 1)
        IF (bigfirst="Y"
         AND text_pos >= all_len)
         SET text_pos = start
        ENDIF
        SET bigfirst = "N"
        WHILE (text_pos >= start
         AND all_len > tot_len)
          IF (text_pos=start)
           SET text_pos = ((start+ line_len) - 1)
           SET linecnt += 1
           SET stat = alterlist(tmptext->qual,linecnt)
           SET len = ((text_pos - start)+ 1)
           SET tmptext->qual[linecnt].text = substring(start,len,outbuffer)
           SET start = (text_pos+ 1)
           SET crstart = (text_pos+ 1)
           SET text_pos = 0
           SET tot_len = ((tot_len+ len) - 1)
           SET loaded = "Y"
          ELSE
           IF (substring(text_pos,1,outbuffer)=" ")
            SET len = (text_pos - start)
            IF (cnvtint(size(trim(substring(start,len,outbuffer)))) > 0)
             SET linecnt += 1
             SET stat = alterlist(tmptext->qual,linecnt)
             SET tmptext->qual[linecnt].text = substring(start,len,outbuffer)
             SET loaded = "Y"
            ENDIF
            SET start = (text_pos+ 1)
            SET crstart = (text_pos+ 1)
            SET text_pos = 0
            SET tot_len += len
           ELSE
            IF (first="Y")
             SET first = "N"
             SET tot_len += 1
            ENDIF
            SET text_pos -= 1
           ENDIF
          ENDIF
        ENDWHILE
       ELSE
        SET crfirst = "N"
        IF (((substring(crpos,1,outbuffer)=crchar) OR (((substring(crpos,1,outbuffer)=lfchar) OR (
        substring(crpos,1,outbuffer)=ffchar)) )) )
         SET crlen = (crpos - crstart)
         SET linecnt += 1
         SET stat = alterlist(tmptext->qual,linecnt)
         SET tmptext->qual[linecnt].text = substring(crstart,crlen,outbuffer)
         SET loaded = "Y"
         IF (substring(crpos,1,outbuffer)=crchar)
          SET crstart = (crpos+ textlen(crchar))
         ELSEIF (substring(crpos,1,outbuffer)=lfchar)
          SET crstart = (crpos+ textlen(lfchar))
         ELSEIF (substring(crpos,1,outbuffer)=ffchar)
          SET crstart = (crpos+ textlen(ffchar))
         ENDIF
         SET tot_len += crlen
        ENDIF
       ENDIF
       SET crpos += 1
      ENDWHILE
    ENDWHILE
   ENDIF
   SET rtftext = fillstring(value(size(rtftext))," ")
   SET inbuffer = fillstring(value(size(rtftext))," ")
 END ;Subroutine
 DECLARE outbufmaxsiz = i2
 DECLARE tblobin = c32000
 DECLARE tblobout = c32000
 DECLARE blobin = c32000
 DECLARE blobout = c32000
 SUBROUTINE (decompress_text(tblobin=vc) =null)
   SET tblobout = fillstring(32000," ")
   SET blobout = fillstring(32000," ")
   SET outbufmaxsiz = 0
   SET blobin = trim(tblobin)
   CALL uar_ocf_uncompress(blobin,size(blobin),blobout,size(blobout),outbufmaxsiz)
   SET tblobout = blobout
   SET tblobin = fillstring(32000," ")
   SET blobin = fillstring(32000," ")
 END ;Subroutine
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
   1 patient_typings = vc
   1 time = vc
   1 as_of_date = vc
   1 by_patient = vc
   1 by_med_no = vc
   1 specific_patient = vc
   1 beg_date = vc
   1 end_date = vc
   1 name = vc
   1 medical = vc
   1 record_number = vc
   1 birth_dt = vc
   1 aborh = vc
   1 phenotype = vc
   1 transfusion = vc
   1 antibodies = vc
   1 antigens = vc
   1 requirements = vc
   1 not_on_file = vc
   1 none = vc
   1 patient_comments = vc
   1 report_id = vc
   1 page_no = vc
   1 printed = vc
   1 rpt_by = vc
   1 end_of_report = vc
   1 facility = vc
 )
 SET captions->patient_typings = uar_i18ngetmessage(i18nhandle,"patient_typings",
  "P A T I E N T   T Y P I N G S   A N D   C O M M E N T S")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","Time:")
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","As of Date:")
 SET captions->by_patient = uar_i18ngetmessage(i18nhandle,"by_patient","(by Patient Name)")
 SET captions->by_med_no = uar_i18ngetmessage(i18nhandle,"by_med_no","(by Medical Record Number)")
 SET captions->specific_patient = uar_i18ngetmessage(i18nhandle,"specific_patient",
  "(Specific Patient)")
 SET captions->beg_date = uar_i18ngetmessage(i18nhandle,"beg_date","Beginning Date:")
 SET captions->end_date = uar_i18ngetmessage(i18nhandle,"end_date","Ending Date:")
 SET captions->name = uar_i18ngetmessage(i18nhandle,"name","Name")
 SET captions->medical = uar_i18ngetmessage(i18nhandle,"medical","Medical")
 SET captions->record_number = uar_i18ngetmessage(i18nhandle,"record_number","Record Number")
 SET captions->birth_dt = uar_i18ngetmessage(i18nhandle,"birth_dt","  Birth Date")
 SET captions->aborh = uar_i18ngetmessage(i18nhandle,"aborh","ABO/Rh")
 SET captions->phenotype = uar_i18ngetmessage(i18nhandle,"phenotype"," Phenotype")
 SET captions->transfusion = uar_i18ngetmessage(i18nhandle,"transfusion","Transfusion")
 SET captions->antibodies = uar_i18ngetmessage(i18nhandle,"antibodies","Antibodies")
 SET captions->antigens = uar_i18ngetmessage(i18nhandle,"antigens","Antigens")
 SET captions->requirements = uar_i18ngetmessage(i18nhandle,"requirements","Requirements")
 SET captions->not_on_file = uar_i18ngetmessage(i18nhandle,"not_on_file","<Not on File>")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"none","<None>")
 SET captions->patient_comments = uar_i18ngetmessage(i18nhandle,"patient_comments",
  "* * * * * * * * * * * * * * * * Patient Comments * * * * * * * * * * * * * * * *")
 SET captions->report_id = uar_i18ngetmessage(i18nhandle,"report_id",
  "Report ID: BBT_RPT_PAT_TYP_COM.PRG")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->rpt_by = uar_i18ngetmessage(i18nhandle,"rpt_by","By:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->facility = uar_i18ngetmessage(i18nhandle,"facility","Facility:")
 SET stat = alterlist(person_antib->antib_list,10)
 SET stat = alterlist(person_antig->antig_list,10)
 SET stat = alterlist(person_trans_req->trans_req_list,10)
 DECLARE done = i2 WITH noconstant(0)
 DECLARE report_person_cnt = i4 WITH noconstant(0)
 DECLARE increment = i4 WITH noconstant(500)
 DECLARE seq_var = i4 WITH noconstant(0)
 DECLARE first_person = i2 WITH noconstant(0)
 DECLARE report_page = i4 WITH noconstant(0)
 DECLARE row_hold = i4 WITH noconstant(60)
 DECLARE bump_lines = i4 WITH noconstant(0)
 DECLARE dm_domain = vc WITH constant("PATHNET_BBT")
 DECLARE dm_loop_increment = vc WITH constant("PTC_REPORT_LOOP_INCREMENT")
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET line = fillstring(125,"_")
 SET comment_size = 0
 SET idx1 = 0
 SET idx2 = 0
 SET idx3 = 0
 SET idx4 = 0
 SET comment_cnt = 0
 SET trans_cnt = 0
 SET trans_cnt1 = 0
 SET index = 0
 SET hld_trans_req = ""
 SET anti_col = 12
 SET person_cnt = 0
 SET report_complete_ind = "N"
 SET cur_username = fillstring(10," ")
 DECLARE pheno_cnt = i4 WITH noconstant(0)
 DECLARE person_mrn_cnt = i4 WITH noconstant(0)
 DECLARE mrn_count1 = i4 WITH noconstant(0)
 DECLARE mrn_count2 = i4 WITH noconstant(0)
 DECLARE facility_disp = vc WITH protect, noconstant("")
 SET cur_username = get_username(reqinfo->updt_id)
 SET mrn_code = 0.0
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(4,"MRN",code_cnt,mrn_code)
 IF (mrn_code=0.0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get MRN alias_type_cd"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_pat_typ_com"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "could not get MRN alias type code_value"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  seq = decode(bb.seq,"bb ",pan.seq,"pan",pab.seq,
   "pab",par.seq,"pa ",prh.seq,"pr",
   "   "), person_id = decode(bb.person_id,bb.person_id,pan.person_id,pan.person_id,pab.person_id,
   pab.person_id,par.person_id,par.person_id,prh.person_id,prh.person_id,
   pah.person_id,pah.person_id,ptr.person_id,ptr.person_id,0.0), pa = decode(par.seq,par.seq,0),
  par.person_id, par.updt_dt_tm";;f", pah.person_id,
  pab = decode(pab.seq,pab.seq,0), pab.person_id, pab.updt_dt_tm";;f",
  pan = decode(pan.seq,pan.seq,0), pan.person_id, pan.updt_dt_tm";;f",
  bb = decode(bb.seq,bb.seq,0), bb.person_id, bb.updt_dt_tm";;f",
  prh.person_id, prh.person_rh_pheno_rs_id
  FROM (dummyt d1  WITH seq = 1),
   person_aborh_result par,
   person_aborh pah,
   person_antibody pab,
   person_antigen pan,
   blood_bank_comment bb,
   person_rh_pheno_result prh,
   person_trans_req ptr
  PLAN (d1)
   JOIN (((par
   WHERE par.active_ind=1
    AND ((par.person_id+ 0) > 0)
    AND par.updt_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND (((request->patient_selection=0.0)) OR ((request->patient_selection > 0.0)
    AND (par.person_id=request->patient_selection))) )
   ) ORJOIN ((((pah
   WHERE pah.active_ind=1
    AND ((pah.person_id+ 0) > 0)
    AND pah.updt_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND (((request->patient_selection=0.0)) OR ((request->patient_selection > 0.0)
    AND (pah.person_id=request->patient_selection))) )
   ) ORJOIN ((((pab
   WHERE pab.active_ind=1
    AND ((pab.person_id+ 0) > 0)
    AND pab.updt_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND (((request->patient_selection=0.0)) OR ((request->patient_selection > 0.0)
    AND (pab.person_id=request->patient_selection))) )
   ) ORJOIN ((((pan
   WHERE pan.active_ind=1
    AND ((pan.person_id+ 0) > 0)
    AND pan.updt_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND (((request->patient_selection=0.0)) OR ((request->patient_selection > 0.0)
    AND (pan.person_id=request->patient_selection))) )
   ) ORJOIN ((((bb
   WHERE bb.active_ind=1
    AND ((bb.person_id+ 0) > 0)
    AND bb.updt_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND (((request->patient_selection=0.0)) OR ((request->patient_selection > 0.0)
    AND (bb.person_id=request->patient_selection))) )
   ) ORJOIN ((((prh
   WHERE prh.active_ind=1
    AND ((prh.person_id+ 0) > 0)
    AND (prh.person_id=request->patient_selection)
    AND prh.updt_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm))
   ) ORJOIN ((ptr
   WHERE ptr.active_ind=1
    AND ((ptr.person_id+ 0) > 0)
    AND ptr.updt_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND (((request->patient_selection=0.0)) OR ((request->patient_selection > 0.0)
    AND (ptr.person_id=request->patient_selection))) )
   )) )) )) )) )) ))
  ORDER BY person_id
  HEAD REPORT
   person_cnt = 0
  HEAD person_id
   IF (person_id > 0)
    person_cnt += 1
    IF (size(personhold_all->person_list,5) < person_cnt)
     stat = alterlist(personhold_all->person_list,(person_cnt+ 500))
    ENDIF
    personhold_all->person_list[person_cnt].person_id = person_id
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET stat = alterlist(personhold_all->person_list,person_cnt)
 ENDIF
 IF (curqual=0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[count1].operationname = "get qualifying person_id's"
  SET reply->status_data.subeventstatus[count1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_pat_typ_com"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "No qualifying data found"
  GO TO exit_script
 ENDIF
 IF ((request->facility_cd > 0))
  SET stat = bbtgetencounterlocations(request->facility_cd,pref_level_bb)
  IF ((stat=- (1)))
   SET count1 += 1
   IF (count1 > 1)
    SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
   ENDIF
   SET reply->status_data.status = "Z"
   SET reply->status_data.subeventstatus[count1].operationname = "BbtGetEncounterLocations"
   SET reply->status_data.subeventstatus[count1].operationstatus = "F"
   SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_pat_typ_com"
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "Retrieve patient encounter locations failed."
   GO TO exit_script
  ENDIF
  DECLARE batch_size = i4 WITH constant(200)
  DECLARE nstart = i4 WITH noconstant(1)
  DECLARE record_list_size = i4 WITH noconstant(size(personhold_all->person_list,5))
  SET idx1 = 0
  SET personidx = 0
  SET facidx = 0
  SET locationidx = 0
  SELECT INTO "nl:"
   e.person_id, e.loc_facility_cd
   FROM (dummyt d  WITH seq = value(ceil((cnvtreal(record_list_size)/ batch_size)))),
    encounter e
   PLAN (d
    WHERE assign(nstart,evaluate(d.seq,1,1,(nstart+ batch_size))))
    JOIN (e
    WHERE expand(personidx,nstart,minval(((nstart+ batch_size) - 1),record_list_size),e.person_id,
     personhold_all->person_list[personidx].person_id))
   GROUP BY e.person_id, e.loc_facility_cd
   DETAIL
    locationidx = 0, locationidx = locateval(facidx,1,size(encounterlocations->locs,5),e
     .loc_facility_cd,encounterlocations->locs[facidx].encfacilitycd)
    IF ((((e.loc_facility_cd=request->facility_cd)) OR (locationidx > 0)) )
     idx1 += 1
     IF (size(personhold_unsorted->person_list,5) < idx1)
      stat = alterlist(personhold_unsorted->person_list,(idx1+ 49))
     ENDIF
     personhold_unsorted->person_list[idx1].person_id = e.person_id
    ENDIF
   WITH nocounter, expand = 1
  ;end select
  SET stat = alterlist(personhold_unsorted->person_list,idx1)
  SET person_cnt = idx1
  SET idx1 = 0
 ELSE
  SET stat = alterlist(personhold_unsorted->person_list,person_cnt)
  FOR (idx1 = 1 TO person_cnt)
    SET personhold_unsorted->person_list[idx1].person_id = personhold_all->person_list[idx1].
    person_id
  ENDFOR
  SET idx1 = 0
 ENDIF
 FREE RECORD personhold_all
 IF (person_cnt=0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[count1].operationname = "filter qualifying person_id's"
  SET reply->status_data.subeventstatus[count1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_pat_typ_com"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue =
  "No patients have an encounter at the filter transfusion facility."
  GO TO exit_script
 ENDIF
 IF ((request->facility_cd > 0))
  SET facility_disp = uar_get_code_display(request->facility_cd)
 ENDIF
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_pat_typ_com", "txt", "x"
 SELECT INTO "nl:"
  dm.info_date
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=dm_domain
    AND dm.info_name=dm_loop_increment)
  DETAIL
   increment = cnvtint(trim(dm.info_char))
  WITH nocounter
 ;end select
 IF (increment < 500)
  SET increment = 500
 ENDIF
 IF ((((request->sort_selection=0)) OR ((request->patient_selection > 0))) )
  SELECT INTO "nl:"
   person_id_alias_id = decode(pra.person_alias_id,build(per.person_id,pra.person_alias_id),build(per
     .person_id,0.0)), sort_mrn = decode(pra.seq,substring(1,15,cnvtalias(pra.alias,pra.alias_pool_cd
      )),""), sort_patient_name = substring(1,30,cnvtupper(per.name_full_formatted))
   FROM (dummyt d_sortper  WITH seq = value(person_cnt)),
    person per,
    person_alias pra
   PLAN (d_sortper)
    JOIN (per
    WHERE (per.person_id=personhold_unsorted->person_list[d_sortper.seq].person_id))
    JOIN (pra
    WHERE (pra.person_id= Outerjoin(per.person_id))
     AND pra.person_alias_type_cd=mrn_code
     AND pra.active_ind=1)
   ORDER BY sort_patient_name, per.person_id
   HEAD REPORT
    stat = alterlist(personhold->person_list,person_cnt), person_cnt_sort = 0
   HEAD per.person_id
    person_cnt_sort += 1, personhold->person_list[person_cnt_sort].person_id = per.person_id
   FOOT REPORT
    IF (person_cnt < increment)
     increment = person_cnt, report_person_cnt = 0
    ELSE
     report_person_cnt = (person_cnt - increment)
    ENDIF
   WITH nocounter, dontcare(pra)
  ;end select
  FREE RECORD personhold_unsorted
  SELECT INTO "nl:"
   formatted_mrn = cnvtalias(pra.alias,pra.alias_pool_cd)
   FROM (dummyt d_person_list  WITH seq = value(person_cnt)),
    person_alias pra
   PLAN (d_person_list)
    JOIN (pra
    WHERE (personhold->person_list[d_person_list.seq].person_id=pra.person_id)
     AND pra.person_alias_type_cd=mrn_code
     AND pra.active_ind=1)
   ORDER BY d_person_list.seq, formatted_mrn
   HEAD d_person_list.seq
    stat = alterlist(personhold->person_list[d_person_list.seq].person_mrn_list,10), person_mrn_cnt
     = 0
   DETAIL
    person_mrn_cnt += 1
    IF (mod(person_mrn_cnt,10)=1
     AND person_mrn_cnt != 1)
     stat = alterlist(personhold->person_list[d_person_list.seq].person_mrn_list,(person_mrn_cnt+ 9))
    ENDIF
    personhold->person_list[d_person_list.seq].person_mrn_list[person_mrn_cnt].formatted_mrn =
    formatted_mrn
   FOOT  d_person_list.seq
    stat = alterlist(personhold->person_list[d_person_list.seq].person_mrn_list,person_mrn_cnt)
   WITH nocounter
  ;end select
  WHILE (done=0)
    SELECT INTO cpm_cfn_info->file_name_logical
     per.person_id, sort_patient_name = substring(1,30,cnvtupper(per.name_full_formatted)), d_flag =
     decode(trq.seq,"F",nom.seq,"E",bb.seq,
      "D",pan.seq,"C",pab.seq,"B",
      pa.seq,"A","G"),
     aborh_display = concat(trim(uar_get_code_display(pa.abo_cd))," ",trim(uar_get_code_display(pa
        .rh_cd))), pa.rh_cd, per.person_id,
     pab.antibody_cd, pan.antigen_cd, pab_display = substring(1,15,uar_get_code_display(pab
       .antibody_cd)),
     pan_display = substring(1,10,uar_get_code_display(pan.antigen_cd)), antibody_display =
     uar_get_code_display(pab.antibody_cd), antigen_display = uar_get_code_display(pan.antigen_cd),
     prh.rh_phenotype_id, prh.person_id, nom.short_string,
     ptr.person_id, ptr.requirement_cd, requirement_disp = uar_get_code_display(trq.requirement_cd)
     FROM (dummyt d10  WITH seq = value(increment)),
      person per,
      (dummyt d9  WITH seq = 1),
      person_aborh pa,
      blood_bank_comment bb,
      long_text lt,
      person_antibody pab,
      person_antigen pan,
      person_rh_phenotype prh,
      bb_rh_phenotype brh,
      nomenclature nom,
      person_trans_req ptr,
      transfusion_requirements trq
     PLAN (d10)
      JOIN (per
      WHERE (per.person_id=personhold->person_list[(d10.seq+ seq_var)].person_id))
      JOIN (d9
      WHERE d9.seq=1)
      JOIN (((pa
      WHERE pa.active_ind=1
       AND pa.person_id=per.person_id)
      ) ORJOIN ((((bb
      WHERE bb.active_ind=1
       AND bb.person_id=per.person_id)
      JOIN (lt
      WHERE lt.long_text_id=bb.long_text_id)
      ) ORJOIN ((((pab
      WHERE pab.person_id=per.person_id
       AND pab.active_ind=1)
      ) ORJOIN ((((pan
      WHERE pan.person_id=per.person_id
       AND pan.active_ind=1)
      ) ORJOIN ((((prh
      WHERE prh.person_id=per.person_id
       AND prh.active_ind=1)
      JOIN (brh
      WHERE prh.rh_phenotype_id=brh.rh_phenotype_id)
      JOIN (nom
      WHERE ((nom.nomenclature_id=brh.w_nomenclature_id) OR (nom.nomenclature_id=brh
      .fr_nomenclature_id)) )
      ) ORJOIN ((ptr
      WHERE ptr.person_id=per.person_id
       AND ptr.person_id > 0
       AND ptr.active_ind=1)
      JOIN (trq
      WHERE ptr.requirement_cd=trq.requirement_cd)
      )) )) )) )) ))
     ORDER BY sort_patient_name, per.person_id, d_flag,
      pab_display, pab.antibody_cd, pan_display,
      pan.antigen_cd
     HEAD REPORT
      beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm),
      select_ok_ind = 0,
      first_person = 0
     HEAD PAGE
      IF (row_hold >= 55)
       IF (first_person=0
        AND report_page > 1)
        row + 1
       ENDIF
       inc_i18nhandle = 0, inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row
        0
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
       row 0,
       CALL center(captions->patient_typings,1,125), col 104,
       captions->time, col 118, curtime"@TIMENOSECONDS;;M",
       row + 1, col 104, captions->as_of_date,
       col 118, curdate"@DATECONDENSED;;d", row 1
       IF ((request->patient_selection=0.0))
        CALL center(captions->by_patient,1,125)
       ELSE
        CALL center(captions->specific_patient,1,125)
       ENDIF
       row + 2, col 30, captions->beg_date,
       col 46, beg_dt_tm"@DATECONDENSED;;d", col 55,
       beg_dt_tm"@TIMENOSECONDS;;M", col 69, captions->end_date,
       col 82, end_dt_tm"@DATECONDENSED;;d", col 91,
       end_dt_tm"@TIMENOSECONDS;;M"
       IF ((request->facility_cd > 0))
        row + 2, col 1, captions->facility,
        col 11, facility_disp
       ENDIF
       row + 3,
       CALL center(captions->medical,31,46),
       CALL center(captions->transfusion,91,103),
       row + 1,
       CALL center(captions->name,1,30),
       CALL center(captions->record_number,31,46),
       col 47, captions->birth_dt, col 66,
       captions->aborh, col 78, captions->phenotype,
       CALL center(captions->requirements,91,105),
       CALL center(captions->antibodies,106,117),
       CALL center(captions->antigens,119,128),
       row + 1, col 1, "----------------------------",
       col 31, "---------------", col 48,
       "-------------", col 63, "-------------",
       col 78, "------------", col 92,
       "------------", col 106, "-----------",
       col 119, "--------", row + 1,
       row_hold = row
      ELSE
       row + 1
      ENDIF
      first_person = 1
     HEAD per.person_id
      IF (row_hold > 55)
       BREAK
      ENDIF
      hld_antibody = "          ", hld_antigen = "          ", hld_trans_req = "            ",
      person_name = substring(1,30,per.name_full_formatted), person_birth_dt_tm = cnvtdatetime(per
       .birth_dt_tm), person_birth_tz = validate(per.birth_tz,0),
      col_name = 1, col_mrn = 31
      IF (size(trim(person_name))=0)
       col col_name, captions->not_on_file
      ELSE
       col col_name, person_name
      ENDIF
      IF (person_birth_dt_tm=0)
       col 48, captions->not_on_file
      ELSE
       IF (curutc=1)
        temp1 = format(datetimezone(person_birth_dt_tm,person_birth_tz),"@DATECONDENSED;4;q"), temp2
         = format(datetimezone(person_birth_dt_tm,person_birth_tz),"@TIMENOSECONDS;4;q")
       ELSE
        temp1 = format(person_birth_dt_tm,"@DATECONDENSED;;d"), temp2 = format(person_birth_dt_tm,
         "@TIMENOSECONDS;;M")
       ENDIF
       col 48, temp1, col 56,
       temp2
      ENDIF
      IF (size(trim(aborh_display)) > 0)
       CALL center(trim(substring(1,13,aborh_display)),63,75)
      ELSE
       CALL center(trim(substring(1,13,captions->none)),63,75)
      ENDIF
      antib_col = 0, antig_col = 0, first_time = "Y",
      comment_cnt = 0, pheno_cnt = 0
     DETAIL
      IF (d_flag="B")
       IF (substring(1,10,trim(antibody_display)) != hld_antibody)
        idx1 += 1
        IF (mod(idx1,10)=1
         AND idx1 != 1)
         stat = alterlist(person_antib->antib_list,(idx1+ 9))
        ENDIF
        person_antib->antib_list[idx1].antib_display = substring(1,10,trim(antibody_display)),
        hld_antibody = substring(1,10,trim(antibody_display))
       ENDIF
      ELSEIF (d_flag="C")
       IF (substring(1,10,trim(antigen_display)) != hld_antigen)
        idx3 += 1
        IF (mod(idx3,10)=1
         AND idx3 != 1)
         stat = alterlist(person_antig->antig_list,(idx3+ 9))
        ENDIF
        person_antig->antig_list[idx3].antig_display = substring(1,10,trim(antigen_display)),
        hld_antigen = substring(1,10,trim(antigen_display))
       ENDIF
      ELSEIF (d_flag="E")
       IF (nom.nomenclature_id=brh.fr_nomenclature_id)
        pheno_cnt += 1, fisher_disp = substring(1,10,trim(nom.short_string))
       ELSEIF (nom.nomenclature_id=brh.w_nomenclature_id)
        pheno_cnt += 1, wiener_disp = substring(1,10,trim(nom.short_string)), phen_display =
        substring(1,20,concat(trim(fisher_disp),"  ",trim(wiener_disp))),
        col 78, phen_display
       ENDIF
      ELSEIF (d_flag="F")
       IF (substring(1,12,trim(requirement_disp)) != trim(hld_trans_req))
        trans_cnt += 1
        IF (mod(trans_cnt,10)=1
         AND trans_cnt != 1)
         stat = alterlist(person_trans_req->trans_req_list,(trans_cnt+ 9))
        ENDIF
        person_trans_req->trans_req_list[trans_cnt].trans_req_display = substring(1,12,trim(
          requirement_disp)), hld_trans_req = substring(1,12,trim(requirement_disp))
       ENDIF
      ELSEIF (d_flag="D")
       comment_cnt += 1, bbcomment->qual[1].comment = trim(lt.long_text,3)
      ENDIF
     FOOT  per.person_id
      idx2 = 1, idx4 = 1, trans_cnt1 = 1,
      mrn_count1 = size(personhold->person_list[(d10.seq+ seq_var)].person_mrn_list,5), mrn_count2 =
      1
      IF (mrn_count1=0)
       col col_mrn, captions->not_on_file
      ENDIF
      IF (pheno_cnt=0)
       CALL center(captions->none,78,90)
      ENDIF
      IF (trans_cnt=0)
       CALL center(captions->none,92,104)
      ENDIF
      IF (idx1=0)
       CALL center(captions->none,106,118)
      ENDIF
      IF (idx3=0)
       CALL center(captions->none,120,127)
      ENDIF
      IF (((idx1 > 0) OR (((idx3 > 0) OR (((trans_cnt > 0) OR (mrn_count1 > 0)) )) )) )
       WHILE (((idx2 <= idx1) OR (((idx4 <= idx3) OR (((trans_cnt1 <= trans_cnt) OR (mrn_count2 <=
       mrn_count1)) )) )) )
         IF (first_time="Y")
          first_time = "N"
         ELSE
          row + 1, row_hold += 1
          IF (row_hold > 56)
           BREAK
          ENDIF
         ENDIF
         cnt = 1
         WHILE (cnt < 2
          AND mrn_count2 <= mrn_count1)
           cnt += 1, person_nbr = substring(1,15,personhold->person_list[(d10.seq+ seq_var)].
            person_mrn_list[mrn_count2].formatted_mrn), col col_mrn,
           person_nbr, mrn_count2 += 1
         ENDWHILE
         trans_req_col = 0, cnt = 1
         WHILE (cnt < 2
          AND trans_cnt1 <= trans_cnt)
           cnt += 1, col 87, trans_req_col += 5,
           col + trans_req_col, person_trans_req->trans_req_list[trans_cnt1].trans_req_display,
           trans_cnt1 += 1
         ENDWHILE
         antib_col = 0, cnt = 1
         WHILE (cnt < 2
          AND idx2 <= idx1)
           cnt += 1, col 107, col + antib_col,
           person_antib->antib_list[idx2].antib_display, idx2 += 1
         ENDWHILE
         antig_col = 0, cnt = 1
         WHILE (cnt < 2
          AND idx4 <= idx3)
           cnt += 1, col 110, antig_col += 11,
           col + antig_col, person_antig->antig_list[idx4].antig_display, idx4 += 1
         ENDWHILE
       ENDWHILE
      ENDIF
      idx2 = 1, idx4 = 1, trans_cnt1 = 1
      WHILE (idx2 <= idx1)
       person_antib->antib_list[idx2].antib_display = "",idx2 += 1
      ENDWHILE
      WHILE (idx4 <= idx3)
       person_antig->antig_list[idx4].antig_display = "",idx4 += 1
      ENDWHILE
      WHILE (trans_cnt1 <= trans_cnt)
       person_trans_req->trans_req_list[trans_cnt1].trans_req_display = "",trans_cnt1 += 1
      ENDWHILE
      idx1 = 0, idx3 = 0, trans_cnt = 0,
      tmptext_index = 0
      IF (comment_cnt > 0)
       CALL rtf_to_text(bbcomment->qual[1].comment,1,80), row + 2, row_hold += 2
       IF (row_hold > 55)
        BREAK
       ENDIF
       col 27, captions->patient_comments, row + 1,
       row_hold += 1
       FOR (tmptext_index = 1 TO size(tmptext->qual,5))
         col 27, tmptext->qual[tmptext_index].text
         IF (row_hold > 55)
          BREAK
         ELSE
          row + 1, row_hold += 1
         ENDIF
       ENDFOR
      ENDIF
      IF (row_hold >= 55)
       BREAK
      ELSE
       row + 2, row_hold += 2
      ENDIF
     FOOT PAGE
      IF (((row_hold >= 55) OR (report_person_cnt=0)) )
       bump_lines = (row_hold - 57), row- (bump_lines), report_page += 1,
       col 1, line, row + 1,
       col 001, captions->report_id, col 060,
       captions->page_no, col 067, report_page";L",
       col 103, captions->printed, col 112,
       curdate"@DATECONDENSED;;d", col 121, curtime"@TIMENOSECONDS;;M",
       row + 1, col 108, captions->rpt_by,
       col 112, cur_username
      ENDIF
     FOOT REPORT
      IF (report_person_cnt=0)
       row + 1,
       CALL center(captions->end_of_report,1,125), report_complete_ind = "Y",
       select_ok_ind = 1
      ENDIF
     WITH counter, nullreport, maxrow = 61,
      outerjoin(d9), dontcare(pra), outerjoin(d_pra),
      dontcare(ap), outerjoin(d_ap), compress,
      nolandscape, memsort, append
    ;end select
    SET seq_var += increment
    IF (report_person_cnt=0)
     SET done = 1
    ELSEIF (report_person_cnt < increment)
     SET increment = report_person_cnt
     SET report_person_cnt = 0
    ELSE
     SET report_person_cnt -= increment
    ENDIF
  ENDWHILE
 ELSE
  SELECT INTO "nl:"
   person_id_alias_id = decode(pra.person_alias_id,build(per.person_id,pra.person_alias_id),build(per
     .person_id,0.0)), sort_mrn = decode(pra.seq,substring(1,15,cnvtalias(pra.alias,pra.alias_pool_cd
      )),""), sort_patient_name = substring(1,30,cnvtupper(per.name_full_formatted))
   FROM (dummyt d_sortper  WITH seq = value(person_cnt)),
    person per,
    (dummyt d_sortpra  WITH seq = 1),
    person_alias pra
   PLAN (d_sortper)
    JOIN (per
    WHERE (per.person_id=personhold_unsorted->person_list[d_sortper.seq].person_id))
    JOIN (d_sortpra
    WHERE d_sortpra.seq=1)
    JOIN (pra
    WHERE per.person_id=pra.person_id
     AND pra.person_alias_type_cd=mrn_code
     AND pra.active_ind=1)
   ORDER BY sort_mrn, sort_patient_name, person_id_alias_id
   HEAD REPORT
    stat = alterlist(personhold->person_list,person_cnt), person_cnt_sort = 0
   HEAD person_id_alias_id
    person_cnt_sort += 1
    IF (size(personhold->person_list,5) < person_cnt_sort)
     stat = alterlist(personhold->person_list,(person_cnt_sort+ 500))
    ENDIF
    stat = alterlist(personhold->person_list[person_cnt_sort].person_mrn_list,1), personhold->
    person_list[person_cnt_sort].person_mrn_list[1].formatted_mrn = sort_mrn, personhold->
    person_list[person_cnt_sort].person_id_alias_id = person_id_alias_id,
    personhold->person_list[person_cnt_sort].person_id = per.person_id
   FOOT REPORT
    person_cnt = person_cnt_sort, stat = alterlist(personhold->person_list,person_cnt)
    IF (person_cnt < increment)
     increment = person_cnt, report_person_cnt = 0
    ELSE
     report_person_cnt = (person_cnt - increment)
    ENDIF
   WITH nocounter, dontcare(pra), outerjoin(d_sortpra)
  ;end select
  FREE RECORD personhold_unsorted
  WHILE (done=0)
    SELECT INTO cpm_cfn_info->file_name_logical
     person_id_alias_id = personhold->person_list[(d10.seq+ seq_var)].person_id_alias_id,
     sort_patient_name = substring(1,30,cnvtupper(per.name_full_formatted)), d_flag = decode(trq.seq,
      "F",nom.seq,"E",bb.seq,
      "D",pan.seq,"C",pab.seq,"B",
      pa.seq,"A","G"),
     aborh_display = concat(trim(uar_get_code_display(pa.abo_cd))," ",trim(uar_get_code_display(pa
        .rh_cd))), pa.rh_cd, sort_mrn = substring(1,15,personhold->person_list[(d10.seq+ seq_var)].
      person_mrn_list[1].formatted_mrn),
     per.person_id, pab.antibody_cd, pan.antigen_cd,
     pab_display = substring(1,15,uar_get_code_display(pab.antibody_cd)), pan_display = substring(1,
      10,uar_get_code_display(pan.antigen_cd)), antibody_display = uar_get_code_display(pab
      .antibody_cd),
     antigen_display = uar_get_code_display(pan.antigen_cd), prh.rh_phenotype_id, prh.person_id,
     nom.short_string, ptr.person_id, ptr.requirement_cd,
     requirement_disp = uar_get_code_display(trq.requirement_cd)
     FROM (dummyt d10  WITH seq = value(increment)),
      person per,
      (dummyt d9  WITH seq = 1),
      person_aborh pa,
      blood_bank_comment bb,
      long_text lt,
      person_antibody pab,
      person_antigen pan,
      person_rh_phenotype prh,
      bb_rh_phenotype brh,
      nomenclature nom,
      person_trans_req ptr,
      transfusion_requirements trq
     PLAN (d10)
      JOIN (per
      WHERE (per.person_id=personhold->person_list[(d10.seq+ seq_var)].person_id))
      JOIN (d9
      WHERE d9.seq=1)
      JOIN (((pa
      WHERE pa.active_ind=1
       AND pa.person_id=per.person_id)
      ) ORJOIN ((((bb
      WHERE bb.active_ind=1
       AND bb.person_id=per.person_id)
      JOIN (lt
      WHERE lt.long_text_id=bb.long_text_id)
      ) ORJOIN ((((pab
      WHERE pab.person_id=per.person_id
       AND pab.active_ind=1)
      ) ORJOIN ((((pan
      WHERE pan.person_id=per.person_id
       AND pan.active_ind=1)
      ) ORJOIN ((((prh
      WHERE prh.person_id=per.person_id
       AND prh.active_ind=1)
      JOIN (brh
      WHERE prh.rh_phenotype_id=brh.rh_phenotype_id)
      JOIN (nom
      WHERE ((nom.nomenclature_id=brh.w_nomenclature_id) OR (nom.nomenclature_id=brh
      .fr_nomenclature_id)) )
      ) ORJOIN ((ptr
      WHERE ptr.person_id=per.person_id
       AND ptr.person_id > 0
       AND ptr.active_ind=1)
      JOIN (trq
      WHERE ptr.requirement_cd=trq.requirement_cd)
      )) )) )) )) ))
     ORDER BY sort_mrn, sort_patient_name, person_id_alias_id,
      d_flag, pab_display, pab.antibody_cd,
      pan_display, pan.antigen_cd
     HEAD REPORT
      beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm),
      select_ok_ind = 0,
      first_person = 0
     HEAD PAGE
      IF (row_hold >= 55)
       IF (first_person=0
        AND report_page > 1)
        row + 1
       ENDIF
       inc_i18nhandle = 0, inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row
        0
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
       row 0,
       CALL center(captions->patient_typings,1,125), col 104,
       captions->time, col 118, curtime"@TIMENOSECONDS;;M",
       row + 1, col 104, captions->as_of_date,
       col 118, curdate"@DATECONDENSED;;d", row 1,
       CALL center(captions->by_med_no,1,125), row + 2, col 30,
       captions->beg_date, col 46, beg_dt_tm"@DATECONDENSED;;d",
       col 55, beg_dt_tm"@TIMENOSECONDS;;M", col 69,
       captions->end_date, col 82, end_dt_tm"@DATECONDENSED;;d",
       col 91, end_dt_tm"@TIMENOSECONDS;;M"
       IF ((request->facility_cd > 0))
        row + 2, col 1, captions->facility,
        col 11, facility_disp
       ENDIF
       row + 3,
       CALL center(captions->medical,1,16),
       CALL center(captions->transfusion,91,103),
       row + 1,
       CALL center(captions->record_number,1,16),
       CALL center(captions->name,18,45),
       col 47, captions->birth_dt, col 66,
       captions->aborh, col 78, captions->phenotype,
       CALL center(captions->requirements,91,105),
       CALL center(captions->antibodies,106,117),
       CALL center(captions->antigens,119,128),
       row + 1, col 1, "---------------",
       col 18, "----------------------------", col 48,
       "-------------", col 63, "-------------",
       col 78, "------------", col 92,
       "------------", col 106, "-----------",
       col 119, "--------", row + 1,
       row_hold = row
      ELSE
       row + 1
      ENDIF
      first_person = 1
     HEAD person_id_alias_id
      IF (row > 55)
       BREAK
      ENDIF
      hld_antibody = "          ", hld_antigen = "          ", hld_trans_req = "            ",
      person_name = substring(1,30,per.name_full_formatted), person_nbr = substring(1,15,sort_mrn),
      person_birth_dt_tm = cnvtdatetime(per.birth_dt_tm),
      person_birth_tz = validate(per.birth_tz,0), col_name = 18, col_mrn = 1
      IF (size(trim(person_name))=0)
       col col_name, captions->not_on_file
      ELSE
       col col_name, person_name
      ENDIF
      IF (size(trim(person_nbr))=0)
       col col_mrn, captions->not_on_file
      ELSE
       col col_mrn, person_nbr
      ENDIF
      IF (person_birth_dt_tm=0)
       col 48, captions->not_on_file
      ELSE
       IF (curutc=1)
        temp1 = format(datetimezone(person_birth_dt_tm,person_birth_tz),"@DATECONDENSED;4;q"), temp2
         = format(datetimezone(person_birth_dt_tm,person_birth_tz),"@TIMENOSECONDS;4;q")
       ELSE
        temp1 = format(person_birth_dt_tm,"@DATECONDENSED;;d"), temp2 = format(person_birth_dt_tm,
         "@TIMENOSECONDS;;M")
       ENDIF
       col 48, temp1, col 56,
       temp2
      ENDIF
      IF (size(trim(aborh_display)) > 0)
       CALL center(trim(substring(1,13,aborh_display)),63,75)
      ELSE
       CALL center(trim(substring(1,13,captions->none)),63,75)
      ENDIF
      antib_col = 0, antig_col = 0, first_time = "Y",
      comment_cnt = 0, pheno_cnt = 0
     DETAIL
      IF (d_flag="B")
       IF (substring(1,10,trim(antibody_display)) != hld_antibody)
        idx1 += 1
        IF (mod(idx1,10)=1
         AND idx1 != 1)
         stat = alterlist(person_antib->antib_list,(idx1+ 9))
        ENDIF
        person_antib->antib_list[idx1].antib_display = substring(1,10,trim(antibody_display)),
        hld_antibody = substring(1,10,trim(antibody_display))
       ENDIF
      ELSEIF (d_flag="C")
       IF (substring(1,10,trim(antigen_display)) != hld_antigen)
        idx3 += 1
        IF (mod(idx3,10)=1
         AND idx3 != 1)
         stat = alterlist(person_antig->antig_list,(idx3+ 9))
        ENDIF
        person_antig->antig_list[idx3].antig_display = substring(1,10,trim(antigen_display)),
        hld_antigen = substring(1,10,trim(antigen_display))
       ENDIF
      ELSEIF (d_flag="E")
       IF (nom.nomenclature_id=brh.fr_nomenclature_id)
        pheno_cnt += 1, fisher_disp = substring(1,10,trim(nom.short_string))
       ELSEIF (nom.nomenclature_id=brh.w_nomenclature_id)
        pheno_cnt += 1, wiener_disp = substring(1,10,trim(nom.short_string)), phen_display =
        substring(1,20,concat(trim(fisher_disp),"  ",trim(wiener_disp))),
        col 78, phen_display
       ENDIF
      ELSEIF (d_flag="F")
       IF (substring(1,12,trim(requirement_disp)) != trim(hld_trans_req))
        trans_cnt += 1
        IF (mod(trans_cnt,10)=1
         AND trans_cnt != 1)
         stat = alterlist(person_trans_req->trans_req_list,(trans_cnt+ 9))
        ENDIF
        person_trans_req->trans_req_list[trans_cnt].trans_req_display = substring(1,12,trim(
          requirement_disp)), hld_trans_req = substring(1,12,trim(requirement_disp))
       ENDIF
      ELSEIF (d_flag="D")
       comment_cnt += 1, bbcomment->qual[1].comment = trim(lt.long_text,3)
      ENDIF
     FOOT  person_id_alias_id
      idx2 = 1, idx4 = 1, trans_cnt1 = 1
      IF (pheno_cnt=0)
       CALL center(captions->none,78,90)
      ENDIF
      IF (trans_cnt=0)
       CALL center(captions->none,92,104)
      ENDIF
      IF (idx1=0)
       CALL center(captions->none,106,118)
      ENDIF
      IF (idx3=0)
       CALL center(captions->none,120,127)
      ENDIF
      IF (((idx1 > 0) OR (((idx3 > 0) OR (trans_cnt > 0)) )) )
       WHILE (((idx2 <= idx1) OR (((idx4 <= idx3) OR (trans_cnt1 <= trans_cnt)) )) )
         IF (first_time="Y")
          first_time = "N"
         ELSE
          row + 1, row_hold += 1
          IF (row_hold > 56)
           BREAK
          ENDIF
         ENDIF
         trans_req_col = 0, cnt = 1
         WHILE (cnt < 2
          AND trans_cnt1 <= trans_cnt)
           cnt += 1, col 87, trans_req_col += 5,
           col + trans_req_col, person_trans_req->trans_req_list[trans_cnt1].trans_req_display,
           trans_cnt1 += 1
         ENDWHILE
         antib_col = 0, cnt = 1
         WHILE (cnt < 2
          AND idx2 <= idx1)
           cnt += 1, col 107, col + antib_col,
           person_antib->antib_list[idx2].antib_display, idx2 += 1
         ENDWHILE
         antig_col = 0, cnt = 1
         WHILE (cnt < 2
          AND idx4 <= idx3)
           cnt += 1, col 110, antig_col += 11,
           col + antig_col, person_antig->antig_list[idx4].antig_display, idx4 += 1
         ENDWHILE
       ENDWHILE
      ENDIF
      idx2 = 1, idx4 = 1, trans_cnt1 = 1
      WHILE (idx2 <= idx1)
       person_antib->antib_list[idx2].antib_display = "",idx2 += 1
      ENDWHILE
      WHILE (idx4 <= idx3)
       person_antig->antig_list[idx4].antig_display = "",idx4 += 1
      ENDWHILE
      WHILE (trans_cnt1 <= trans_cnt)
       person_trans_req->trans_req_list[trans_cnt1].trans_req_display = "",trans_cnt1 += 1
      ENDWHILE
      idx1 = 0, idx3 = 0, trans_cnt = 0,
      tmptext_index = 0
      IF (comment_cnt > 0)
       CALL rtf_to_text(bbcomment->qual[1].comment,1,80), row + 2, row_hold += 2
       IF (row_hold > 55)
        BREAK
       ENDIF
       col 27, captions->patient_comments, row + 1,
       row_hold += 1
       FOR (tmptext_index = 1 TO size(tmptext->qual,5))
         col 27, tmptext->qual[tmptext_index].text
         IF (row_hold > 55)
          BREAK
         ELSE
          row + 1, row_hold += 1
         ENDIF
       ENDFOR
      ENDIF
      IF (row_hold >= 55)
       BREAK
      ELSE
       row + 2, row_hold += 2
      ENDIF
     FOOT PAGE
      IF (((row_hold >= 55) OR (report_person_cnt=0)) )
       bump_lines = (row_hold - 57), row- (bump_lines), report_page += 1,
       col 1, line, row + 1,
       col 001, captions->report_id, col 060,
       captions->page_no, col 067, report_page";L",
       col 103, captions->printed, col 112,
       curdate"@DATECONDENSED;;d", col 121, curtime"@TIMENOSECONDS;;M",
       row + 1, col 108, captions->rpt_by,
       col 112, cur_username
      ENDIF
     FOOT REPORT
      IF (report_person_cnt=0)
       row + 1,
       CALL center(captions->end_of_report,1,125), report_complete_ind = "Y",
       select_ok_ind = 1
      ENDIF
     WITH counter, nullreport, maxrow = 61,
      outerjoin(d9), dontcare(pra), outerjoin(d_pra),
      dontcare(ap), outerjoin(d_ap), compress,
      nolandscape, memsort, append
    ;end select
    SET seq_var += increment
    IF (report_person_cnt=0)
     SET done = 1
    ELSEIF (report_person_cnt < increment)
     SET increment = report_person_cnt
     SET report_person_cnt = 0
    ELSE
     SET report_person_cnt -= increment
    ENDIF
  ENDWHILE
 ENDIF
 SET count1 += 1
 IF (count1 > 1)
  SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
 ENDIF
 IF (report_complete_ind="Y")
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[count1].operationname = "Report Complete"
  SET reply->status_data.subeventstatus[count1].operationstatus = "S"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_pat_typ_com"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "Report completed successfully"
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "Abnormal End"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_pat_typ_com"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = "Report ended abnormally"
 ENDIF
 SET rpt_cnt += 1
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
 IF (trim(request->batch_selection) > " "
  AND trim(request->output_dist) > " ")
  SET spool value(reply->rpt_list[rpt_cnt].rpt_filename) value(request->output_dist)
 ENDIF
 GO TO exit_script
 DECLARE get_username(sub_person_id) = c10
 SUBROUTINE get_username(sub_person_id)
   SET sub_get_username = fillstring(10," ")
   SELECT INTO "nl:"
    pnl.username
    FROM prsnl pnl
    WHERE pnl.person_id=sub_person_id
     AND pnl.person_id != null
     AND pnl.person_id > 0.0
    DETAIL
     sub_get_username = pnl.username
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET inc_i18nhandle = 0
    SET inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev)
    SET sub_get_username = uar_i18ngetmessage(inc_i18nhandle,"inc_unknown","<Unknown>")
   ENDIF
   RETURN(sub_get_username)
 END ;Subroutine
#exit_script
END GO
