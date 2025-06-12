CREATE PROGRAM bbt_rpt_pat_typ_com_xml:dba
 DECLARE dtcur = q8 WITH noconstant(cnvtdatetime(sysdate))
 IF (validate(reply->file_name,"ZZZ")="ZZZ")
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
  DECLARE report_type_all = c1 WITH constant("A")
  DECLARE report_type_new = c1 WITH constant("N")
  DECLARE report_type_date = c1 WITH constant("D")
  DECLARE default_start_date = q8 WITH constant(cnvtdatetime("01-JAN-1800 00:00:00.00"))
  DECLARE dm_domain = vc WITH constant("PATHNET_BBT")
  DECLARE dm_name = vc WITH noconstant("LAST_PTC_XML_DT_TM")
  DECLARE dtend = q8
  DECLARE facility_all = c3 WITH constant("ALL")
  DECLARE dtlastendrpt = q8 WITH noconstant(cnvtdatetime(default_start_date))
  DECLARE serrmsg = c132 WITH noconstant(fillstring(132," "))
  DECLARE ierrcode = i4 WITH noconstant(error(serrmsg,1))
  DECLARE istatusblkcnt = i4 WITH noconstant(0)
  DECLARE istat = i2 WITH noconstant(0)
  DECLARE dtutcdate = q8
  DECLARE cdateformatted = vc WITH noconstant(fillstring(20," "))
  DECLARE file_name = vc WITH noconstant(fillstring(200," "))
  DECLARE personid = vc WITH noconstant(fillstring(20," "))
  DECLARE fullnamenonull = vc WITH noconstant(fillstring(200," "))
  DECLARE phenotypenonull = vc WITH noconstant(fillstring(100," "))
  DECLARE aborhnonull = vc WITH noconstant(fillstring(20," "))
  DECLARE i18nhandle = i4 WITH noconstant(0)
  SET dtend = cnvtenddttmops(dtcur)
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
  SET istat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 ELSE
  SET reply->file_name = ""
  SET file_name = ""
  SET dtend = cnvtdatetime(request->end_dt_tm)
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
 DECLARE alias_type_cs = i4 WITH constant(4)
 DECLARE mrn_mean = c12 WITH constant("MRN")
 DECLARE trans_req_row = vc WITH constant("TRQ")
 DECLARE pheno_typ_row = vc WITH constant("PH")
 DECLARE comment_row = vc WITH constant("COM")
 DECLARE antigen_row = vc WITH constant("AG")
 DECLARE antibody_row = vc WITH constant("AB")
 DECLARE aborh_row = vc WITH constant("ABO")
 DECLARE mrn_row = vc WITH constant("MRN")
 DECLARE dtbegin = q8 WITH noconstant(cnvtdatetime(default_start_date))
 DECLARE srpttype = c1 WITH noconstant(report_type_all)
 DECLARE iupdenddtind = i2 WITH noconstant(0)
 DECLARE dmrntypecd = f8 WITH noconstant(0.0)
 DECLARE dm_loop_increment = vc WITH constant("PTC_LOOP_INCREMENT")
 DECLARE i = i4 WITH noconstant(1)
 DECLARE ifound = i2 WITH noconstant(0)
 DECLARE idone = i2 WITH noconstant(0)
 DECLARE ipersoncnt = i4 WITH noconstant(0)
 DECLARE iincrement = i4 WITH noconstant(0)
 DECLARE iseqvar = i4 WITH noconstant(0)
 DECLARE ipersonrowadd = i2 WITH noconstant(0)
 DECLARE facility_disp = vc WITH protect, noconstant("")
 DECLARE ixmlcounter = i4 WITH noconstant(0)
 RECORD rectemppersons(
   1 ipersoncnt = i4
   1 persons[*]
     2 dpersonid = f8
     2 spersonind = vc
 )
 RECORD recpersons(
   1 ipersoncnt = i4
   1 persons[*]
     2 dpersonid = f8
     2 spersonind = vc
 )
 RECORD reccaptions1(
   1 report_type = vc
   1 begin_date = vc
   1 end_date = vc
   1 all_ind = vc
   1 new_ind = vc
   1 date_ind = vc
   1 inactive_type = vc
   1 facility = vc
 )
 RECORD recpersonstobedeleted(
   1 ipersoncnt = i4
   1 persons[*]
     2 dpersonid = f8
 )
 SET reccaptions1->report_type = uar_i18ngetmessage(i18nhandle,"RPT_TYPE","EXPORT TYPE:")
 SET reccaptions1->begin_date = uar_i18ngetmessage(i18nhandle,"BEG_DATE","BEGIN DATE:")
 SET reccaptions1->end_date = uar_i18ngetmessage(i18nhandle,"END_DATE","END DATE:")
 SET reccaptions1->all_ind = uar_i18ngetmessage(i18nhandle,"ALL_INDICATOR","A")
 SET reccaptions1->new_ind = uar_i18ngetmessage(i18nhandle,"NEW_INDICATOR","N")
 SET reccaptions1->date_ind = uar_i18ngetmessage(i18nhandle,"DATE_RANGE_INDICATOR","D")
 SET reccaptions1->inactive_type = uar_i18ngetmessage(i18nhandle,"INACTIVE_TYPE","(INACTIVE)")
 SET reccaptions1->facility = uar_i18ngetmessage(i18nhandle,"facility","FACILITY:")
 DECLARE personstobeupdated() = i2
 DECLARE updateexportstatusinfo() = i2
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
 SUBROUTINE (formatdttm(dtvalue=q8) =vc)
   RETURN(concat(format(dtvalue,cclfmt->mediumdate4yr)," ",format(dtvalue,cclfmt->timenoseconds)))
 END ;Subroutine
 SUBROUTINE (cnvtbegindttmops(begindttmops=q8) =q8)
   RETURN(cnvtdatetime(concat(format(cnvtdatetime(begindttmops),"DD/MMM/YYYY HH:MM;;D"),":00.00")))
 END ;Subroutine
 SUBROUTINE (cnvtenddttmops(enddttmops=q8) =q8)
   RETURN(cnvtdatetime(concat(format(cnvtdatetime(enddttmops),"DD/MMM/YYYY HH:MM;;D"),":59.99")))
 END ;Subroutine
 SUBROUTINE (readlastreportdttm(ilock=i2) =i2)
  IF (ilock)
   SELECT INTO "nl:"
    dm.info_date
    FROM dm_info dm
    PLAN (dm
     WHERE dm.info_domain=dm_domain
      AND dm.info_name=dm_name
      AND (dm.info_number=request->facility_cd))
    DETAIL
     dtlastendrpt = dm.info_date
    WITH nocounter, forupdate(dm)
   ;end select
  ELSE
   SELECT INTO "nl:"
    dm.info_date
    FROM dm_info dm
    PLAN (dm
     WHERE dm.info_domain=dm_domain
      AND dm.info_name=dm_name
      AND (dm.info_number=request->facility_cd))
    DETAIL
     dtlastendrpt = dm.info_date
    WITH nocounter
   ;end select
  ENDIF
  IF (checkforerror("F","SELECT","F","DM_INFO"))
   RETURN(- (1))
  ELSE
   RETURN(curqual)
  ENDIF
 END ;Subroutine
 SUBROUTINE (getdaysfrombatchselection(ssearchstring=vc) =i2)
   DECLARE istartpos = i2 WITH noconstant(0)
   DECLARE iendpos = i2 WITH noconstant(0)
   DECLARE ivalue = i2 WITH noconstant(- (1))
   SET istartpos = cnvtint(value(findstring("DAYS[",ssearchstring)))
   IF (istartpos > 0)
    SET istartpos += 5
    SET iendpos = cnvtint(value(findstring("]",ssearchstring,istartpos)))
    IF (iendpos > istartpos)
     SET ivalue = cnvtint(trim(substring(istartpos,(iendpos - istartpos),ssearchstring)))
    ENDIF
   ENDIF
   RETURN(ivalue)
 END ;Subroutine
 DECLARE determinedaterangeops() = null
 SUBROUTINE determinedaterangeops(null)
   DECLARE idays = i2 WITH noconstant(1)
   IF (textlen(trim(request->batch_selection))=0)
    SET dtbegin = cnvtdatetime(default_start_date)
    SET srpttype = report_type_all
   ELSE
    SET idays = getdaysfrombatchselection(cnvtupper(request->batch_selection))
    IF (idays < 0)
     SET dtbegin = cnvtdatetime(default_start_date)
     SET srpttype = report_type_all
    ELSEIF (idays=0)
     IF (readlastreportdttm(0) >= 0)
      IF (dtlastendrpt=0)
       SET dtbegin = cnvtdatetime(default_start_date)
       SET srpttype = report_type_all
      ELSE
       SET dtbegin = cnvtbegindttmops(dtlastendrpt)
       SET srpttype = report_type_new
      ENDIF
     ELSE
      SET dtbegin = cnvtdatetime(default_start_date)
      SET srpttype = report_type_all
     ENDIF
    ELSE
     SET dtbegin = datetimeadd(dtcur,- (idays))
     SET dtbegin = cnvtdatetime(cnvtdate(dtbegin),0)
     SET srpttype = report_type_date
    ENDIF
   ENDIF
   SET iupdenddtind = 1
 END ;Subroutine
 DECLARE findchangeddata() = i2
 SUBROUTINE findchangeddata(null)
   DECLARE recidx = i4 WITH protect, noconstant(- (1))
   SELECT INTO "nl:"
    person_id = decode(par.seq,par.person_id,pab.seq,pab.person_id,pan.seq,
     pan.person_id,bb.seq,bb.person_id,prh.seq,prh.person_id,
     ptr.seq,ptr.person_id,pa.seq,pa.person_id,0.0), person_ind = decode(par.seq,"par",pab.seq,"pab",
     pan.seq,
     "pan",bb.seq,"bb",prh.seq,"prh",
     ptr.seq,"ptr",pa.seq,"pa","NONE")
    FROM (dummyt d1  WITH seq = 1),
     person_aborh_result par,
     person_antibody pab,
     person_antigen pan,
     blood_bank_comment bb,
     person_rh_pheno_result prh,
     person_trans_req ptr,
     person_aborh pa
    PLAN (d1)
     JOIN (((par
     WHERE ((par.person_id+ 0) != null)
      AND ((par.person_id+ 0) > 0)
      AND par.updt_dt_tm >= cnvtdatetime(dtbegin)
      AND par.updt_dt_tm <= cnvtdatetime(dtend))
     ) ORJOIN ((((pab
     WHERE ((pab.person_id+ 0) != null)
      AND ((pab.person_id+ 0) > 0)
      AND pab.updt_dt_tm >= cnvtdatetime(dtbegin)
      AND pab.updt_dt_tm <= cnvtdatetime(dtend))
     ) ORJOIN ((((pan
     WHERE ((pan.person_id+ 0) != null)
      AND ((pan.person_id+ 0) > 0)
      AND pan.updt_dt_tm >= cnvtdatetime(dtbegin)
      AND pan.updt_dt_tm <= cnvtdatetime(dtend))
     ) ORJOIN ((((bb
     WHERE ((bb.person_id+ 0) != null)
      AND ((bb.person_id+ 0) > 0)
      AND bb.updt_dt_tm >= cnvtdatetime(dtbegin)
      AND bb.updt_dt_tm <= cnvtdatetime(dtend))
     ) ORJOIN ((((prh
     WHERE ((prh.person_id+ 0) != null)
      AND ((prh.person_id+ 0) > 0)
      AND prh.updt_dt_tm >= cnvtdatetime(dtbegin)
      AND prh.updt_dt_tm <= cnvtdatetime(dtend))
     ) ORJOIN ((((ptr
     WHERE ((ptr.person_id+ 0) != null)
      AND ((ptr.person_id+ 0) > 0)
      AND ptr.updt_dt_tm >= cnvtdatetime(dtbegin)
      AND ptr.updt_dt_tm <= cnvtdatetime(dtend))
     ) ORJOIN ((pa
     WHERE ((pa.person_id+ 0) != null)
      AND ((pa.person_id+ 0) > 0)
      AND pa.updt_dt_tm >= cnvtdatetime(dtbegin)
      AND pa.updt_dt_tm <= cnvtdatetime(dtend))
     )) )) )) )) )) ))
    ORDER BY person_id
    HEAD REPORT
     rectemppersons->ipersoncnt = 0
    HEAD person_id
     rectemppersons->ipersoncnt += 1
     IF ((size(rectemppersons->persons,5) < rectemppersons->ipersoncnt))
      istat = alterlist(rectemppersons->persons,(rectemppersons->ipersoncnt+ 4999))
     ENDIF
     rectemppersons->persons[rectemppersons->ipersoncnt].dpersonid = person_id, rectemppersons->
     persons[rectemppersons->ipersoncnt].spersonind = person_ind
    FOOT REPORT
     istat = alterlist(rectemppersons->persons,rectemppersons->ipersoncnt)
    WITH nocounter
   ;end select
   IF (checkforerror("F","SELECT","F","FINDDATA"))
    RETURN(2)
   ENDIF
   SET istat = personstobeupdated(null)
   IF (istat < 1)
    RETURN(2)
   ENDIF
   IF ((rectemppersons->ipersoncnt < 1))
    RETURN(0)
   ENDIF
   IF ((request->facility_cd > 0))
    SET stat = bbtgetencounterlocations(request->facility_cd,pref_level_bb)
    IF ((stat=- (1)))
     CALL addtostatusblock("F","BbtGetEncounterLocations","F","request->facility_cd",
      "Failed to retrieve patient encounter locations.")
     GO TO exit_script
    ENDIF
    SELECT INTO "nl:"
     e.person_id, e.loc_facility_cd
     FROM (dummyt d_p  WITH seq = value(rectemppersons->ipersoncnt)),
      (dummyt d_f  WITH seq = value(size(encounterlocations->locs,5))),
      encounter e
     PLAN (d_p)
      JOIN (d_f)
      JOIN (e
      WHERE (e.person_id=rectemppersons->persons[d_p.seq].dpersonid)
       AND e.loc_facility_cd > 0
       AND (((e.loc_facility_cd=encounterlocations->locs[d_f.seq].encfacilitycd)) OR ((e
      .loc_facility_cd=request->facility_cd))) )
     GROUP BY e.person_id, e.loc_facility_cd
     HEAD REPORT
      recpersons->ipersoncnt = 0
     DETAIL
      recpersons->ipersoncnt += 1
      IF ((size(recpersons->persons,5) < recpersons->ipersoncnt))
       istat = alterlist(recpersons->persons,(recpersons->ipersoncnt+ 500))
      ENDIF
      recpersons->persons[recpersons->ipersoncnt].dpersonid = rectemppersons->persons[d_p.seq].
      dpersonid, recpersons->persons[recpersons->ipersoncnt].spersonind = rectemppersons->persons[d_p
      .seq].spersonind
     FOOT REPORT
      istat = alterlist(recpersons->persons,recpersons->ipersoncnt)
     WITH nocounter
    ;end select
   ELSE
    SET stat = alterlist(recpersons->persons,rectemppersons->ipersoncnt)
    FOR (recidx = 1 TO rectemppersons->ipersoncnt)
     SET recpersons->persons[recidx].dpersonid = rectemppersons->persons[recidx].dpersonid
     SET recpersons->persons[recidx].spersonind = rectemppersons->persons[recidx].spersonind
    ENDFOR
    SET recpersons->ipersoncnt = rectemppersons->ipersoncnt
   ENDIF
   FREE RECORD rectemppersons
   IF ((recpersons->ipersoncnt < 1))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE (addreportlistitem(stype=vc,sitem=vc,ditem=f8) =null)
   SET i = 1
   SET ifound = 0
   WHILE ((i <= recpersondata->ilstitemcnt)
    AND ifound=0)
    IF ((recpersondata->lstitems[i].sitemtype=stype)
     AND (recpersondata->lstitems[i].ditemvalue=ditem))
     SET ifound = 1
    ENDIF
    SET i += 1
   ENDWHILE
   IF (ifound=0)
    SET recpersondata->ilstitemcnt += 1
    IF (mod(recpersondata->ilstitemcnt,10)=1)
     SET istat = alterlist(recpersondata->lstitems,(recpersondata->ilstitemcnt+ 9))
    ENDIF
    SET recpersondata->lstitems[recpersondata->ilstitemcnt].sitemtype = stype
    SET recpersondata->lstitems[recpersondata->ilstitemcnt].sitemdisp = sitem
    SET recpersondata->lstitems[recpersondata->ilstitemcnt].ditemvalue = ditem
   ENDIF
 END ;Subroutine
 DECLARE generatereport() = i2
 SUBROUTINE generatereport(null)
   DECLARE sfilename = vc WITH noconstant("")
   DECLARE sline = vc WITH noconstant("")
   SET istat = uar_get_meaning_by_codeset(alias_type_cs,mrn_mean,1,dmrntypecd)
   SET logical d value(trim(logical("CER_PRINT")))
   SELECT INTO "nl:"
    dm.info_date
    FROM dm_info dm
    PLAN (dm
     WHERE dm.info_domain=dm_domain
      AND dm.info_name=dm_loop_increment)
    DETAIL
     iincrement = cnvtint(trim(dm.info_char))
    WITH nocounter
   ;end select
   IF (iincrement < 500)
    SET iincrement = 500
   ENDIF
   SET ipersoncnt = recpersons->ipersoncnt
   IF (ipersoncnt < iincrement)
    SET iincrement = ipersoncnt
    SET ipersoncnt = 0
   ELSE
    SET ipersoncnt -= iincrement
   ENDIF
   IF ((request->facility_cd > 0))
    SET facility_disp = uar_get_code_display(request->facility_cd)
   ENDIF
   WHILE (idone=0)
     IF ((request->facility_cd > 0))
      SET sfilename = build("d/bbpte_",trim(trim(facility_disp,8)),"_",format(dtcur,
        "YYMMDDHHMMSSCC;;d"),"_",
       ixmlcounter,".xml")
      SET file_name = build("cer_print/bbpte_",trim(trim(facility_disp,8)),"_",format(dtcur,
        "YYMMDDHHMMSSCC;;d"),"_",
       ixmlcounter,".xml")
     ELSE
      SET sfilename = build("d/bbpte_",format(dtcur,"YYMMDDHHMMSSCC;;d"),"_",ixmlcounter,".xml")
      SET file_name = build("cer_print/bbpte_",format(dtcur,"YYMMDDHHMMSSCC;;d"),"_",ixmlcounter,
       ".xml")
     ENDIF
     FREE RECORD recpersondata
     RECORD recpersondata(
       1 sfullname = vc
       1 smrnlist = vc
       1 dtbirth = dq8
       1 birth_tz = i4
       1 sgender = vc
       1 dpersonid = f8
       1 saborh = vc
       1 sphenotype = vc
       1 scomment = vc
       1 ilstitemcnt = i4
       1 lstitems[*]
         2 sitemtype = vc
         2 sitemdisp = vc
         2 ditemvalue = f8
     )
     SELECT INTO value(sfilename)
      d_flag = decode(trq.seq,trans_req_row,nom.seq,pheno_typ_row,bb.seq,
       comment_row,pan.seq,antigen_row,pab.seq,antibody_row,
       pa.seq,aborh_row,pra.seq,mrn_row,"")
      FROM (dummyt d_per  WITH seq = value(iincrement)),
       (dummyt d  WITH seq = 1),
       person per,
       person_alias pra,
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
      PLAN (d_per)
       JOIN (per
       WHERE (per.person_id=recpersons->persons[(d_per.seq+ iseqvar)].dpersonid)
        AND per.person_id > 0)
       JOIN (d)
       JOIN (((pra
       WHERE pra.person_id=per.person_id
        AND pra.person_alias_type_cd=dmrntypecd
        AND pra.end_effective_dt_tm > cnvtdatetime(sysdate)
        AND pra.active_ind=1)
       ) ORJOIN ((((pa
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
        AND ptr.active_ind=1)
       JOIN (trq
       WHERE ptr.requirement_cd=trq.requirement_cd)
       )) )) )) )) )) ))
      ORDER BY per.person_id
      HEAD REPORT
       col 0, "<?xml version='1.0' encoding='UTF-8'?>", row + 1,
       col 0, "<ptc>", row + 1,
       col 1, "<export_criteria>", row + 1,
       ipersonrowadd = 0
       CASE (srpttype)
        OF report_type_all:
         sline = concat(reccaptions1->report_type,reccaptions1->all_ind,", "),col 2,"<report_type>",
         reccaptions1->all_ind,"</report_type>",row + 1
        OF report_type_new:
         sline = concat(reccaptions1->report_type,reccaptions1->new_ind,", "),col 2,"<report_type>",
         reccaptions1->new_ind,"</report_type>",row + 1
        OF report_type_date:
         sline = concat(reccaptions1->report_type,reccaptions1->date_ind,", "),col 2,"<report_type>",
         reccaptions1->date_ind,"</report_type>",row + 1
       ENDCASE
       sline = concat(sline," ",reccaptions1->begin_date,formatdttm(dtbegin),", ",
        reccaptions1->end_date,formatdttm(dtend)), col 2, "<begin_date>",
       dtbegin, "</begin_date>", row + 1,
       col 2, "<end_date>", dtend,
       "</end_date>", row + 1, sline = "",
       ipersonrowadd = 1
       IF ((request->facility_cd > 0))
        col 2, "<facility>", facility_disp,
        "</facility>", row + 1
       ELSEIF ((request->facility_cd=0))
        col 2, "<facility>", facility_all,
        "</facility>", row + 1
       ENDIF
       col 2, "<last_run>", dtlastendrpt,
       "</last_run>", row + 1, col 1,
       "</export_criteria>", row + 1
      HEAD per.person_id
       recpersondata->sfullname = "", recpersondata->smrnlist = "", recpersondata->dtbirth = 0,
       recpersondata->birth_tz = 0, recpersondata->sgender = "", recpersondata->dpersonid = 0.0,
       recpersondata->saborh = "", recpersondata->sphenotype = "", recpersondata->scomment = "",
       recpersondata->ilstitemcnt = 0, istat = alterlist(recpersondata->lstitems,0)
       IF (per.active_ind=0)
        recpersondata->sfullname = concat(trim(per.name_full_formatted),"  ",trim(reccaptions1->
          inactive_type))
       ELSE
        recpersondata->sfullname = trim(per.name_full_formatted)
       ENDIF
       recpersondata->dtbirth = per.birth_dt_tm, recpersondata->birth_tz = validate(per.birth_tz,0),
       recpersondata->sgender = trim(uar_get_code_display(per.sex_cd))
       IF (trim(recpersondata->sgender) > "")
        recpersondata->sgender = concat("<![CDATA[",recpersondata->sgender,"]]>")
       ENDIF
       recpersondata->dpersonid = per.person_id, ipersonrowadd = 1
      DETAIL
       CASE (d_flag)
        OF aborh_row:
         recpersondata->saborh = concat(trim(uar_get_code_display(pa.abo_cd))," ",trim(
           uar_get_code_display(pa.rh_cd)))
        OF trans_req_row:
         CALL addreportlistitem(d_flag,trim(uar_get_code_display(trq.requirement_cd)),trq
         .requirement_cd)
        OF pheno_typ_row:
         IF (nom.nomenclature_id=brh.fr_nomenclature_id)
          recpersondata->sphenotype = concat(trim(nom.short_string)," ",trim(recpersondata->
            sphenotype,3))
         ELSEIF (nom.nomenclature_id=brh.w_nomenclature_id)
          recpersondata->sphenotype = concat(trim(recpersondata->sphenotype,3)," ",trim(nom
            .short_string))
         ENDIF
        OF comment_row:
         recpersondata->scomment = trim(check(replace(lt.long_text,concat(char(13),char(10),char(13),
             char(10)),"\n",0)),3),recpersondata->scomment = replace(recpersondata->scomment,char(10),
          "\n",0)
        OF antigen_row:
         CALL addreportlistitem(d_flag,trim(uar_get_code_display(pan.antigen_cd)),pan.antigen_cd)
        OF antibody_row:
         CALL addreportlistitem(d_flag,trim(uar_get_code_display(pab.antibody_cd)),pab.antibody_cd)
        OF mrn_row:
         CALL addreportlistitem(d_flag,trim(cnvtalias(pra.alias,pra.alias_pool_cd)),pra
         .person_alias_id)
       ENDCASE
      FOOT  per.person_id
       personid = trim(cnvtstring(recpersondata->dpersonid,19,0))
       IF ((recpersondata->sfullname=null))
        fullnamenonull = " "
       ELSE
        fullnamenonull = concat("<![CDATA[",trim(recpersondata->sfullname),"]]>")
       ENDIF
       IF ((recpersondata->sphenotype=null))
        phenotypenonull = " "
       ELSE
        phenotypenonull = concat("<![CDATA[",trim(recpersondata->sphenotype),"]]>")
       ENDIF
       IF ((recpersondata->saborh=null))
        aborhnonull = " "
       ELSE
        aborhnonull = concat("<![CDATA[",trim(recpersondata->saborh),"]]>")
       ENDIF
       IF (curutc=1)
        cdateformatted = concat(format(datetimezone(recpersondata->dtbirth,recpersondata->birth_tz),
          "@MEDIUMDATE4YR;4;q")," ",format(datetimezone(recpersondata->dtbirth,recpersondata->
           birth_tz),"@TIMENOSECONDS;4;q"))
       ELSE
        cdateformatted = formatdttm(recpersondata->dtbirth)
       ENDIF
       FOR (i = 1 TO recpersondata->ilstitemcnt)
         IF ((recpersondata->lstitems[i].sitemtype=mrn_row))
          IF ((recpersondata->smrnlist > ""))
           recpersondata->smrnlist = concat(recpersondata->smrnlist,",",recpersondata->lstitems[i].
            sitemdisp)
          ELSE
           recpersondata->smrnlist = recpersondata->lstitems[i].sitemdisp
          ENDIF
         ENDIF
       ENDFOR
       col 2, "<person>", row + 1,
       col 4, "<ptc_time>", dtcur,
       "</ptc_time>", row + 1, col 4,
       "<person_id>", personid, "</person_id>",
       row + 1, col 4, "<name>",
       fullnamenonull, "</name>", row + 1,
       col 4, "<dob>", cdateformatted,
       "</dob>", row + 1, col 4,
       "<gender>", recpersondata->sgender, "</gender>",
       row + 1, col 4, "<ABORh>",
       aborhnonull, "</ABORh>", row + 1,
       col 4, "<phenotype>", phenotypenonull,
       "</phenotype>", row + 1
       FOR (i = 1 TO recpersondata->ilstitemcnt)
         IF ((recpersondata->lstitems[i].sitemtype=mrn_row))
          col 4, "<mrns>", row + 1,
          col 6, "<ptc_time>", dtcur,
          "</ptc_time>", row + 1, col 6,
          "<person_id>", personid, "</person_id>",
          row + 1, col 6, "<mrn>",
          "<![CDATA[", recpersondata->lstitems[i].sitemdisp, "]]>",
          "</mrn>", row + 1, col 4,
          "</mrns>", row + 1
         ENDIF
       ENDFOR
       FOR (i = 1 TO recpersondata->ilstitemcnt)
         IF ((recpersondata->lstitems[i].sitemtype=trans_req_row))
          col 4, "<transReqs>", row + 1,
          col 6, "<ptc_time>", dtcur,
          "</ptc_time>", row + 1, col 6,
          "<person_id>", personid, "</person_id>",
          row + 1, col 6, "<transReq>",
          "<![CDATA[", recpersondata->lstitems[i].sitemdisp, "]]>",
          "</transReq>", row + 1, col 4,
          "</transReqs>", row + 1
         ENDIF
       ENDFOR
       FOR (i = 1 TO recpersondata->ilstitemcnt)
         IF ((recpersondata->lstitems[i].sitemtype=antibody_row))
          col 4, "<antibodies>", row + 1,
          col 6, "<ptc_time>", dtcur,
          "</ptc_time>", row + 1, col 6,
          "<person_id>", personid, "</person_id>",
          row + 1, col 6, "<antibody>",
          "<![CDATA[", recpersondata->lstitems[i].sitemdisp, "]]>",
          "</antibody>", row + 1, col 4,
          "</antibodies>", row + 1
         ENDIF
       ENDFOR
       FOR (i = 1 TO recpersondata->ilstitemcnt)
         IF ((recpersondata->lstitems[i].sitemtype=antigen_row))
          col 4, "<antigens>", row + 1,
          col 6, "<ptc_time>", dtcur,
          "</ptc_time>", row + 1, col 6,
          "<person_id>", personid, "</person_id>",
          row + 1, col 6, "<antigen>",
          "<![CDATA[", recpersondata->lstitems[i].sitemdisp, "]]>",
          "</antigen>", row + 1, col 4,
          "</antigens>", row + 1
         ENDIF
       ENDFOR
       col 4, "<comments>"
       IF ((recpersondata->scomment > ""))
        col 15, "<![CDATA[", recpersondata->scomment,
        "]]>", row + 1
       ENDIF
       "</comments>", row + 1, col 2,
       "</person>", row + 1
      FOOT REPORT
       IF ((recpersonstobedeleted->ipersoncnt > 0))
        col 2, "<persons_to_be_deleted>", row + 1
        IF (ixmlcounter=0)
         FOR (i = 1 TO recpersonstobedeleted->ipersoncnt)
           personid = trim(cnvtstring(recpersonstobedeleted->persons[i].dpersonid,19,0)), col 4,
           "<person>",
           row + 1, col 6, "<person_id>",
           personid, "</person_id>", row + 1,
           col 4, "</person>", row + 1
         ENDFOR
        ENDIF
        col 2, "</persons_to_be_deleted>", row + 1
       ENDIF
       col 0, "</ptc>", row + 1
      WITH nocounter, memsort, format = stream,
       formfeed = none, maxcol = 100000, maxrow = 1,
       outerjoin(d)
     ;end select
     SET iseqvar += iincrement
     SET ixmlcounter += 1
     SET stat = alterlist(reply->rpt_list,ixmlcounter)
     SET reply->rpt_list[ixmlcounter].rpt_filename = file_name
     IF (ipersoncnt=0)
      SET idone = 1
     ELSEIF (ipersoncnt < iincrement)
      SET iincrement = ipersoncnt
      SET ipersoncnt = 0
     ELSE
      SET ipersoncnt -= iincrement
     ENDIF
   ENDWHILE
   IF (ixmlcounter > 1)
    IF ((request->facility_cd > 0))
     SET reply->file_name = concat("cer_print/bbpte_",trim(trim(facility_disp,8)),"_",format(dtcur,
       "YYMMDDHHMMSSCC;;d"),".zip")
    ELSE
     SET reply->file_name = concat("cer_print/bbpte_",format(dtcur,"YYMMDDHHMMSSCC;;d"),".zip")
    ENDIF
    IF (textlen(trim(request->batch_selection)) > 0)
     FOR (j = 0 TO ixmlcounter)
       DECLARE lstat = i4 WITH protect, noconstant(0)
       DECLARE commtext = vc WITH protect
       SET commtext = concat("$cer_exe/zip $",reply->file_name," $",reply->rpt_list[j].rpt_filename)
       CALL dcl(commtext,size(commtext),lstat)
     ENDFOR
    ENDIF
   ELSE
    SET reply->file_name = file_name
   ENDIF
   IF (checkforerror("F","SELECT","F","REPORT"))
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 DECLARE updatedminfo() = i2
 SUBROUTINE updatedminfo(null)
   SET istat = readlastreportdttm(1)
   IF (istat >= 1)
    UPDATE  FROM dm_info dm
     SET dm.info_date =
      IF (iupdenddtind
       AND datetimediff(dtend,dtlastendrpt) >= 0)
       IF (datetimediff(dtend,cnvtenddttmops(dtcur)) > 0) cnvtdatetime(cnvtenddttmops(dtcur))
       ELSE cnvtdatetime(dtend)
       ENDIF
      ELSE dm.info_date
      ENDIF
      , dm.info_char = srpttype, dm.updt_dt_tm = cnvtdatetime(sysdate),
      dm.updt_id = reqinfo->updt_id, dm.updt_cnt = (dm.updt_cnt+ 1), dm.updt_task = reqinfo->
      updt_task,
      dm.updt_applctx = 0
     PLAN (dm
      WHERE dm.info_domain=dm_domain
       AND dm.info_name=dm_name
       AND (dm.info_number=request->facility_cd))
     WITH nocounter
    ;end update
    IF (checkforerror("F","UPDATE","F","DM_INFO"))
     CALL addtostatusblock("F","UPDATE","F","DM_INFO","Failed to update DM_INFO row")
     RETURN(0)
    ENDIF
   ELSEIF (istat=0)
    INSERT  FROM dm_info dm
     SET dm.info_domain = dm_domain, dm.info_name = dm_name, dm.info_date =
      IF (iupdenddtind)
       IF (datetimediff(dtend,cnvtenddttmops(dtcur)) > 0) cnvtdatetime(cnvtenddttmops(dtcur))
       ELSE cnvtdatetime(dtend)
       ENDIF
      ELSE null
      ENDIF
      ,
      dm.info_char = srpttype, dm.updt_dt_tm = cnvtdatetime(sysdate), dm.updt_id = reqinfo->updt_id,
      dm.updt_cnt = 0, dm.updt_task = reqinfo->updt_task, dm.updt_applctx = 0,
      dm.info_number = request->facility_cd
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
 IF (textlen(trim(request->batch_selection))=0)
  SET dtbegin = cnvtdatetime(request->beg_dt_tm)
  SET dtend = cnvtdatetime(request->end_dt_tm)
  IF (textlen(trim(request->report_flag)) > 0)
   SET srpttype = request->report_flag
  ENDIF
  SET iupdenddtind = request->update_end_date_ind
  IF ((request->facility_cd > 0))
   SET dm_name = concat(dm_name,trim(cnvtstring(request->facility_cd,19,0)))
  ENDIF
 ELSE
  SET temp_string = cnvtupper(trim(request->batch_selection))
  CALL check_facility_cd("bbt_rpt_pat_typ_com_xml")
  IF ((request->facility_cd > 0))
   SET dm_name = concat(dm_name,trim(cnvtstring(request->facility_cd,19,0)))
  ENDIF
  CALL determinedaterangeops(null)
 ENDIF
 IF (dtbegin < dtend
  AND ((srpttype=report_type_all) OR (((srpttype=report_type_new) OR (srpttype=report_type_date)) ))
 )
  SET istat = findchangeddata(null)
  IF (istat=1)
   IF (generatereport(null))
    IF (updateexportstatusinfo(null))
     IF (updatedminfo(null))
      IF (textlen(trim(request->batch_selection))=0)
       FOR (j = 0 TO size(reply->rpt_list,5))
        CALL readexportfile(reply->rpt_list[j].rpt_filename)
        IF ((eksreply->status_data.status="S"))
         SET reply->rpt_list[j].data_blob = eksreply->data_blob
         SET reply->rpt_list[j].data_blob_size = eksreply->data_blob_size
        ELSE
         CALL addtostatusblock("F","SCRIPT","F","BBT_RPT_PAT_TYP_COM_XML",concat(
           "Error reading report",reply->rpt_list[j].rpt_filename))
        ENDIF
       ENDFOR
       IF ((eksreply->status_data.status="S"))
        CALL addtostatusblock("S","SCRIPT","S","SCRIPT","Success")
       ELSE
        CALL addtostatusblock("F","SCRIPT","F","BBT_RPT_PAT_TYP_COM_XML","Error reading report")
       ENDIF
      ELSE
       CALL addtostatusblock("S","SCRIPT","S","SCRIPT","Success")
      ENDIF
     ELSE
      CALL addtostatusblock("F","UPDATE","F","DM_INFO","Failed updating DM_INFO")
     ENDIF
    ELSE
     CALL addtostatusblock("F","UPDATE","F","BB_PTC_TEMP_PERSON","Failed updating BB_PTC_TEMP_PERSON"
      )
    ENDIF
   ELSE
    CALL addtostatusblock("F","SCRIPT","F","BBT_RPT_PAT_TYP_COM_XML","Error generating export")
   ENDIF
  ELSEIF (istat=0)
   IF (updatedminfo(null))
    CALL addtostatusblock("Z","SCRIPT","Z","BBT_RPT_PAT_TYP_COM_XML","No export items found")
   ELSE
    CALL addtostatusblock("F","UPDATE","F","DM_INFO","Failed updating DM_INFO")
   ENDIF
  ELSE
   CALL addtostatusblock("F","SCRIPT","F","BBT_RPT_PAT_TYP_COM_XML","Error loading data")
  ENDIF
 ELSE
  CALL addtostatusblock("F","DATA","F","VALIDATION","Export data not valid")
  CALL addtostatusblock("F","DATA","F","BEGINDTTM",format(dtbegin,";;q"))
  CALL addtostatusblock("F","DATA","F","ENDDTTM",format(dtend,";;q"))
  CALL addtostatusblock("F","DATA","F","RPTTYPE",srpttype)
 ENDIF
 SUBROUTINE personstobeupdated(null)
   SELECT INTO "nl:"
    temp.person_id, temp.process_type_flag
    FROM bb_ptc_temp_person temp
    WHERE temp.process_type_flag > 0
     AND temp.export_ind=0
    HEAD REPORT
     recpersonstobedeleted->ipersoncnt = 0
    DETAIL
     IF (temp.process_type_flag=2)
      rectemppersons->ipersoncnt += 1
      IF ((size(rectemppersons->persons,5) < rectemppersons->ipersoncnt))
       istat = alterlist(rectemppersons->persons,(rectemppersons->ipersoncnt+ 500))
      ENDIF
      rectemppersons->persons[rectemppersons->ipersoncnt].dpersonid = temp.person_id
     ELSE
      recpersonstobedeleted->ipersoncnt += 1
      IF ((size(recpersonstobedeleted->persons,5) < recpersonstobedeleted->ipersoncnt))
       istat = alterlist(recpersonstobedeleted->persons,(recpersonstobedeleted->ipersoncnt+ 500))
      ENDIF
      recpersonstobedeleted->persons[recpersonstobedeleted->ipersoncnt].dpersonid = temp.person_id
     ENDIF
    FOOT REPORT
     istat = alterlist(rectemppersons->persons,rectemppersons->ipersoncnt), istat = alterlist(
      recpersonstobedeleted->persons,recpersonstobedeleted->ipersoncnt)
    WITH nocounter
   ;end select
   IF (checkforerror("F","SELECT","F","bb_ptc_temp_person"))
    CALL addtostatusblock("F","SELECT","F","bb_ptc_temp_person",
     "Failed to retrieve Person_Ids from bb_ptc_temp_table")
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE updateexportstatusinfo(null)
   UPDATE  FROM bb_ptc_temp_person p
    SET p.export_ind = 1, p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_id = reqinfo->updt_id,
     p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx
    WHERE p.export_ind=0
    WITH nocounter
   ;end update
   IF (checkforerror("F","UPDATE","F","BB_PTC_TEMP_PERSON"))
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_script
 IF ((reply->status_data.status="S"))
  SET reqinfo->commit_ind = 1
 ENDIF
 FREE SET recpersons
 FREE SET recpersondata
 FREE SET reccaptions1
 FREE SET recpersonstobeupdated
END GO
