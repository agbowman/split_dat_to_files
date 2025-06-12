CREATE PROGRAM bbt_rpt_stk_stat_de:dba
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
   1 rpt_title = vc
   1 rpt_time = vc
   1 rpt_as_of_date = vc
   1 product_category = vc
   1 all = vc
   1 derivatives = vc
   1 blood_bank_owner = vc
   1 inventory_area = vc
   1 product_class = vc
   1 products = vc
   1 avail = vc
   1 assign = vc
   1 quar = vc
   1 dispense = vc
   1 total = vc
   1 rpt_id = vc
   1 rpt_page = vc
   1 printed = vc
   1 user = vc
   1 end_of_report = vc
   1 rpt_all = vc
 )
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title",
  "S T O C K   S T A T U S   S U M M A R Y")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->rpt_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As of Date:")
 SET captions->derivatives = uar_i18ngetmessage(i18nhandle,"derivatives","(Derivatives)")
 SET captions->blood_bank_owner = uar_i18ngetmessage(i18nhandle,"blood_bank_owner",
  "Blood Bank Owner: ")
 SET captions->inventory_area = uar_i18ngetmessage(i18nhandle,"inventory_area","Inventory Area: ")
 SET captions->product_class = uar_i18ngetmessage(i18nhandle,"product_class","Product Class:")
 SET captions->product_category = uar_i18ngetmessage(i18nhandle,"product_category",
  "Product Category:")
 SET captions->products = uar_i18ngetmessage(i18nhandle,"products","Products:")
 SET captions->avail = uar_i18ngetmessage(i18nhandle,"avail","Avail")
 SET captions->assign = uar_i18ngetmessage(i18nhandle,"assign","Assign")
 SET captions->quar = uar_i18ngetmessage(i18nhandle,"quar","Quar")
 SET captions->dispense = uar_i18ngetmessage(i18nhandle,"dispense","Dispense")
 SET captions->total = uar_i18ngetmessage(i18nhandle,"total","Total")
 SET captions->all = uar_i18ngetmessage(i18nhandle,"all","All")
 SET captions->rpt_id = uar_i18ngetmessage(i18nhandle,"rpt_id","Report ID: BBT_RPT_STK_STAT_DE")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->user = uar_i18ngetmessage(i18nhandle,"user","User:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->rpt_all = uar_i18ngetmessage(i18nhandle,"rpt_all","(All)")
 DECLARE reportbyusername = vc WITH protect, noconstant("")
 SET reportbyusername = get_username(reqinfo->updt_id)
 IF (trim(request->batch_selection) > " ")
  SET request->dsss_product_cat_cd = 0
  SET temp_string = cnvtupper(trim(request->batch_selection))
  CALL check_owner_cd("bbt_rpt_stk_stat_de")
  CALL check_inventory_cd("bbt_rpt_stk_stat_de")
  CALL check_location_cd("bbt_rpt_stk_stat_de")
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
 SET firsttime = "Y"
 SET prod_list[30] = fillstring(20," ")
 SET cnt = 1
 SET match_found = "N"
 SET avail_cnt = 0
 SET assigned_cnt = 0
 SET quar_cnt = 0
 SET dispense_cnt = 0
 SET deriv_cnt = 0
 SET code_val[4] = 0.0
 SET code_rank[4] = " "
 SET code_index = 1
 SET line = fillstring(125,"_")
 SET xx = initarray(code_val,0)
 SET xx = initarray(code_rank," ")
 SET code_index = 1
 SET cur_owner_area_disp = fillstring(40," ")
 SET cur_inv_area_disp = fillstring(40," ")
 IF ((request->cur_owner_area_cd=0.0))
  SET cur_owner_area_disp = captions->all
 ELSE
  SET cur_owner_area_disp = uar_get_code_display(request->cur_owner_area_cd)
 ENDIF
 IF ((request->cur_inv_area_cd=0.0))
  SET cur_inv_area_disp = captions->all
 ELSE
  SET cur_inv_area_disp = uar_get_code_display(request->cur_inv_area_cd)
 ENDIF
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=1610
  DETAIL
   IF (c.cdf_meaning="1")
    code_val[code_index] = c.code_value, code_rank[code_index] = "1", code_index += 1
   ELSEIF (c.cdf_meaning="2")
    code_val[code_index] = c.code_value, code_rank[code_index] = "2", code_index += 1
   ELSEIF (c.cdf_meaning="4")
    code_val[code_index] = c.code_value, code_rank[code_index] = "3", code_index += 1
   ELSEIF (c.cdf_meaning="12")
    code_val[code_index] = c.code_value, code_rank[code_index] = "4", code_index += 1
   ENDIF
  WITH nocounter, check
 ;end select
 SET derivative_class_cd = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "DERIVATIVE"
 SET stat = uar_get_meaning_by_codeset(1606,cdf_meaning,1,derivative_class_cd)
 SET prod_col = 20
 SET xx = initarray(prod_list," ")
 IF ((request->dsss_product_cat_cd=0))
  SET reply->status_data.status = "F"
  SET select_ok_ind = 0
  SET rpt_cnt = 0
  EXECUTE cpm_create_file_name_logical "bbt_stck_stat_de", "txt", "x"
  SELECT INTO cpm_cfn_info->file_name_logical
   pi.product_class_cd, pi.product_cat_cd, pi.product_cd,
   pe.product_id, de.cur_avail_qty, an.cur_assign_qty,
   pd.cur_dispense_qty, qu.cur_quar_qty, pe.product_event_id,
   pe.event_type_cd, pr.product_cd, pr.product_cat_cd,
   pr.product_class_cd, product_type_display = uar_get_code_display(pi.product_cd),
   product_cat_display = uar_get_code_display(pi.product_cat_cd),
   product_class_display = uar_get_code_display(pi.product_class_cd), decode_flag = decode(de.seq,
    "DE","NO")
   FROM product_index pi,
    (dummyt d1  WITH seq = 1),
    product pr,
    (dummyt d6  WITH seq = 1),
    product_event pe,
    (dummyt d7  WITH seq = 1),
    derivative de,
    (dummyt d3  WITH seq = 1),
    assign an,
    (dummyt d4  WITH seq = 1),
    patient_dispense pd,
    (dummyt d5  WITH seq = 1),
    quarantine qu
   PLAN (pi
    WHERE pi.product_class_cd=derivative_class_cd
     AND pi.product_cat_cd > 0
     AND pi.product_cd > 0
     AND pi.active_ind=1)
    JOIN (d1
    WHERE d1.seq=1)
    JOIN (pr
    WHERE pi.product_cd=pr.product_cd
     AND (((request->cur_owner_area_cd > 0.0)
     AND (request->cur_owner_area_cd=pr.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (request->cur_inv_area_cd=pr.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
    JOIN (d6
    WHERE d6.seq=1)
    JOIN (pe
    WHERE pr.product_id=pe.product_id
     AND pe.active_ind=1
     AND (((pe.event_type_cd=code_val[1])) OR ((((pe.event_type_cd=code_val[2])) OR ((((pe
    .event_type_cd=code_val[3])) OR ((pe.event_type_cd=code_val[4]))) )) )) )
    JOIN (d7
    WHERE d7.seq=1)
    JOIN (de
    WHERE pe.product_id=de.product_id
     AND de.active_ind=1)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (an
    WHERE pe.product_event_id=an.product_event_id
     AND an.active_ind=1)
    JOIN (d4
    WHERE d4.seq=1)
    JOIN (pd
    WHERE pe.product_event_id=pd.product_event_id
     AND pd.active_ind=1)
    JOIN (d5
    WHERE d5.seq=1)
    JOIN (qu
    WHERE pe.product_event_id=qu.product_event_id
     AND qu.active_ind=1)
   ORDER BY pi.product_class_cd, pi.product_cat_cd, pi.product_cd,
    pe.product_id, pe.product_event_id
   HEAD REPORT
    select_ok_ind = 0
   HEAD PAGE
    CALL center(captions->rpt_title,1,125), col 104, captions->rpt_time,
    col 118, curtime"@TIMENOSECONDS;;M", row + 1,
    col 104, captions->rpt_as_of_date, col 118,
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
    save_row = row, row 1,
    CALL center(captions->derivatives,1,125),
    row save_row, row + 1, col 1,
    captions->blood_bank_owner, col 19, cur_owner_area_disp,
    row + 1, col 1, captions->inventory_area,
    col 17, cur_inv_area_disp, row + 2,
    col 1, captions->product_class, col 21,
    product_class_display, row + 2, col 1,
    captions->product_category, col 21, product_cat_display,
    row + 2, col 1, captions->products
   HEAD pi.product_class_cd
    row + 0
   HEAD pi.product_cat_cd
    IF (firsttime="Y")
     firsttime = "N"
    ELSE
     BREAK
    ENDIF
   HEAD pi.product_cd
    row + 0
   HEAD pe.product_event_id
    row + 0
   DETAIL
    row + 0
   FOOT  pi.product_class_cd
    row + 0
   FOOT  pi.product_cat_cd
    prod_col = 20, row + 3, col 38,
    captions->avail, col 51, captions->assign,
    col 65, captions->quar, col 76,
    captions->dispense, col 90, captions->total,
    row + 1, col 37, "--------",
    col 50, "--------", col 63,
    "--------", col 76, "--------",
    col 89, "--------", row + 1,
    col 39, avail_cnt"#####;p ", col 52,
    assigned_cnt"#####;p ", col 65, quar_cnt"#####;p ",
    col 78, dispense_cnt"#####;p ", col 91,
    deriv_cnt"#####;p ", xx = initarray(prod_list," "), avail_cnt = 0,
    assigned_cnt = 0, quar_cnt = 0, dispense_cnt = 0,
    deriv_cnt = 0
   FOOT  pi.product_cd
    cnt = 1, col 1, display_product = substring(1,22,product_type_display),
    col + prod_col, display_product
    IF (prod_col > 80)
     row + 1, prod_col = 20
    ELSE
     prod_col += 25
    ENDIF
    cnt += 1
   FOOT  pe.product_event_id
    IF (decode_flag="DE")
     code_index = 1, match_found = "N"
     WHILE (match_found="N"
      AND code_index < 5)
       IF ((pe.event_type_cd=code_val[code_index]))
        match_found = "Y"
        IF ((code_rank[code_index]="1"))
         assigned_cnt += an.cur_assign_qty, deriv_cnt += an.cur_assign_qty
        ENDIF
        IF ((code_rank[code_index]="2"))
         quar_cnt += qu.cur_quar_qty, deriv_cnt += qu.cur_quar_qty
        ENDIF
        IF ((code_rank[code_index]="3"))
         dispense_cnt += pd.cur_dispense_qty, deriv_cnt += pd.cur_dispense_qty
        ENDIF
        IF ((code_rank[code_index]="4"))
         avail_cnt += de.cur_avail_qty, deriv_cnt += de.cur_avail_qty
        ENDIF
       ELSE
        code_index += 1
       ENDIF
     ENDWHILE
    ENDIF
   FOOT PAGE
    row 57, col 1, line,
    row + 1, col 1, captions->rpt_id,
    col 58, captions->rpt_page, col 64,
    curpage"###", col 100, captions->printed,
    col 110, curdate"@DATECONDENSED;;d", col 120,
    curtime"@TIMENOSECONDS;;M"
   FOOT REPORT
    row 54, col 1, captions->user,
    col 20, reportbyusername, row + 1,
    col 1, captions->product_category, col 20,
    captions->all, row 60, col 51,
    captions->end_of_report, select_ok_ind = 1
   WITH nullreport, nocounter, check,
    outerjoin(d1), outerjoin(d6), outerjoin(d3),
    outerjoin(d4), outerjoin(d7), dontcare(an),
    dontcare(pd), maxrow = 61, nolandscape,
    compress
  ;end select
 ENDIF
 IF ((request->dsss_product_cat_cd > 0))
  SET reply->status_data.status = "F"
  SET select_ok_ind = 0
  SET rpt_cnt = 0
  EXECUTE cpm_create_file_name_logical "bbt_stck_stat_de", "txt", "x"
  SELECT INTO cpm_cfn_info->file_name_logical
   pi.product_class_cd, pi.product_cat_cd, pi.product_cd,
   pe.product_id, de.cur_avail_qty, an.cur_assign_qty,
   pd.cur_dispense_qty, qu.cur_quar_qty, pe.product_event_id,
   pe.event_type_cd, pr.product_cd, pr.product_cat_cd,
   pr.product_class_cd, product_type_display = uar_get_code_display(pi.product_cd),
   product_cat_display = uar_get_code_display(pi.product_cat_cd),
   product_class_display = uar_get_code_display(pi.product_class_cd), decode_flag = decode(de.seq,
    "DE","NO")
   FROM product_index pi,
    (dummyt d1  WITH seq = 1),
    product pr,
    (dummyt d6  WITH seq = 1),
    product_event pe,
    (dummyt d7  WITH seq = 1),
    derivative de,
    (dummyt d3  WITH seq = 1),
    assign an,
    (dummyt d4  WITH seq = 1),
    patient_dispense pd,
    (dummyt d5  WITH seq = 1),
    quarantine qu
   PLAN (pi
    WHERE (pi.product_cat_cd=request->dsss_product_cat_cd)
     AND pi.product_cat_cd > 0
     AND pi.product_class_cd=derivative_class_cd
     AND pi.active_ind=1)
    JOIN (d1
    WHERE d1.seq=1)
    JOIN (pr
    WHERE pi.product_cd=pr.product_cd
     AND (((request->cur_owner_area_cd > 0.0)
     AND (request->cur_owner_area_cd=pr.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (request->cur_inv_area_cd=pr.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
    JOIN (d6
    WHERE d6.seq=1)
    JOIN (pe
    WHERE pr.product_id=pe.product_id
     AND pe.active_ind=1
     AND (((pe.event_type_cd=code_val[1])) OR ((((pe.event_type_cd=code_val[2])) OR ((((pe
    .event_type_cd=code_val[3])) OR ((pe.event_type_cd=code_val[4]))) )) )) )
    JOIN (d7
    WHERE d7.seq=1)
    JOIN (de
    WHERE pe.product_id=de.product_id
     AND de.active_ind=1)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (an
    WHERE pe.product_event_id=an.product_event_id
     AND an.active_ind=1)
    JOIN (d4
    WHERE d4.seq=1)
    JOIN (pd
    WHERE pe.product_event_id=pd.product_event_id
     AND pd.active_ind=1)
    JOIN (d5
    WHERE d5.seq=1)
    JOIN (qu
    WHERE pe.product_event_id=qu.product_event_id
     AND qu.active_ind=1)
   ORDER BY pi.product_class_cd, pi.product_cat_cd, pi.product_cd,
    pe.product_id, pe.product_event_id
   HEAD REPORT
    select_ok_ind = 0
   HEAD PAGE
    CALL center(captions->rpt_title,1,125), col 107, captions->rpt_time,
    col 121, curtime"@TIMENOSECONDS;;M", row + 1,
    col 107, captions->rpt_as_of_date, col 119,
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
    save_row = row, row 1,
    CALL center(captions->derivatives,1,125),
    row save_row, row + 1, col 1,
    captions->blood_bank_owner, col 19, cur_owner_area_disp,
    row + 1, col 1, captions->inventory_area,
    col 17, cur_inv_area_disp, row + 2,
    col 1, captions->product_class, col 21,
    product_class_display, row + 2, col 1,
    captions->product_category, col 21, product_cat_display,
    row + 2, col 1, captions->products
   HEAD pi.product_class_cd
    row + 0
   HEAD pi.product_cat_cd
    IF (firsttime="Y")
     firsttime = "N"
    ELSE
     BREAK
    ENDIF
   HEAD pi.product_cd
    row + 0
   HEAD pe.product_event_id
    row + 0
   DETAIL
    row + 0
   FOOT  pi.product_class_cd
    row + 0
   FOOT  pi.product_cat_cd
    prod_col = 20, row + 3, col 38,
    captions->avail, col 51, captions->assign,
    col 65, captions->quar, col 76,
    captions->dispense, col 90, captions->total,
    row + 1, col 37, "--------",
    col 50, "--------", col 63,
    "--------", col 76, "--------",
    col 89, "--------", row + 1,
    col 39, avail_cnt"####;p ", col 52,
    assigned_cnt"####;p ", col 65, quar_cnt"####;p ",
    col 78, dispense_cnt"####;p ", col 91,
    deriv_cnt"####;p ", xx = initarray(prod_list," "), avail_cnt = 0,
    assigned_cnt = 0, quar_cnt = 0, dispense_cnt = 0,
    deriv_cnt = 0
   FOOT  pi.product_cd
    cnt = 1, col 1, display_product = substring(1,22,product_type_display),
    col + prod_col, display_product
    IF (prod_col > 80)
     row + 1, prod_col = 20
    ELSE
     prod_col += 25
    ENDIF
    cnt += 1
   FOOT  pe.product_event_id
    IF (decode_flag="DE")
     code_index = 1, match_found = "N"
     WHILE (match_found="N"
      AND code_index < 5)
       IF ((pe.event_type_cd=code_val[code_index]))
        match_found = "Y"
        IF ((code_rank[code_index]="1"))
         assigned_cnt += an.cur_assign_qty, deriv_cnt += an.cur_assign_qty
        ENDIF
        IF ((code_rank[code_index]="2"))
         quar_cnt += qu.cur_quar_qty, deriv_cnt += qu.cur_quar_qty
        ENDIF
        IF ((code_rank[code_index]="3"))
         dispense_cnt += pd.cur_dispense_qty, deriv_cnt += pd.cur_dispense_qty
        ENDIF
        IF ((code_rank[code_index]="4"))
         avail_cnt += de.cur_avail_qty, deriv_cnt += de.cur_avail_qty
        ENDIF
       ELSE
        code_index += 1
       ENDIF
     ENDWHILE
    ENDIF
   FOOT PAGE
    row 57, col 1, line,
    row + 1, col 1, captions->rpt_id,
    col 58, captions->rpt_page, col 64,
    curpage"###", col 100, captions->printed,
    col 110, curdate"@DATECONDENSED;;d", col 120,
    curtime"@TIMENOSECONDS;;M"
   FOOT REPORT
    row 54, col 1, captions->user,
    col 20, reportbyusername"##########;L", row + 1,
    col 1, captions->product_category, col 20,
    product_cat_display, row 60, col 51,
    captions->end_of_report, select_ok_ind = 1
   WITH nullreport, nocounter, check,
    outerjoin(d1), outerjoin(d6), outerjoin(d3),
    outerjoin(d4), outerjoin(d7), dontcare(an),
    dontcare(pd), maxrow = 61, compress,
    nolandscape
  ;end select
 ENDIF
#exit_script
 SET rpt_cnt += 1
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
  IF (trim(request->batch_selection) > " ")
   SET spool value(reply->rpt_list[rpt_cnt].rpt_filename) value(request->output_dist)
  ENDIF
 ENDIF
END GO
