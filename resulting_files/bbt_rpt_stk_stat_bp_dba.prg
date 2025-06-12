CREATE PROGRAM bbt_rpt_stk_stat_bp:dba
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
   1 stock_status = vc
   1 time = vc
   1 as_of_date = vc
   1 blood_products = vc
   1 bb_owner = vc
   1 inventory_area = vc
   1 product_class = vc
   1 product_category = vc
   1 products = vc
   1 aborh = vc
   1 avail = vc
   1 assign = vc
   1 auto_dir = vc
   1 quar = vc
   1 xmatch = vc
   1 dispense = vc
   1 total = vc
   1 no_aborh = vc
   1 report_id = vc
   1 page_no = vc
   1 printed = vc
   1 user = vc
   1 all = vc
   1 aborh_space = vc
   1 end_of_report = vc
   1 paren_all = vc
   1 slash = vc
 )
 SET captions->stock_status = uar_i18ngetmessage(i18nhandle,"stock_status",
  "S T O C K   S T A T U S   S U M M A R Y")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","Time:")
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","As of Date:")
 SET captions->blood_products = uar_i18ngetmessage(i18nhandle,"blood_products","(Blood Products)")
 SET captions->bb_owner = uar_i18ngetmessage(i18nhandle,"bb_owner","Blood Bank Owner: ")
 SET captions->inventory_area = uar_i18ngetmessage(i18nhandle,"inventory_area","Inventory Area: ")
 SET captions->product_class = uar_i18ngetmessage(i18nhandle,"product_class","Product Class:")
 SET captions->product_category = uar_i18ngetmessage(i18nhandle,"product_category",
  "Product Category:")
 SET captions->products = uar_i18ngetmessage(i18nhandle,"products","Products:")
 SET captions->aborh = uar_i18ngetmessage(i18nhandle,"aborh","ABO/Rh")
 SET captions->avail = uar_i18ngetmessage(i18nhandle,"avail","Avail")
 SET captions->assign = uar_i18ngetmessage(i18nhandle,"assign","Assign")
 SET captions->auto_dir = uar_i18ngetmessage(i18nhandle,"auto_dir","Auto/Dir")
 SET captions->quar = uar_i18ngetmessage(i18nhandle,"quar","Quar")
 SET captions->xmatch = uar_i18ngetmessage(i18nhandle,"xmatch","X-Match")
 SET captions->dispense = uar_i18ngetmessage(i18nhandle,"dispense","Dispense")
 SET captions->total = uar_i18ngetmessage(i18nhandle,"total","Total")
 SET captions->no_aborh = uar_i18ngetmessage(i18nhandle,"no_aborh","No ABORh")
 SET captions->report_id = uar_i18ngetmessage(i18nhandle,"report_id","Report ID: BBT_RPT_STK_STAT_BP"
  )
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->user = uar_i18ngetmessage(i18nhandle,"user","User:")
 SET captions->all = uar_i18ngetmessage(i18nhandle,"all","All")
 SET captions->aborh_space = uar_i18ngetmessage(i18nhandle,"aborh_space","ABO / RH:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->paren_all = uar_i18ngetmessage(i18nhandle,"paren_all","(All)")
 SET captions->slash = uar_i18ngetmessage(i18nhandle,"slash","/")
 IF (trim(request->batch_selection) > " ")
  SET request->sss_product_cat_cd = 0
  SET request->sss_cur_abo_cd = 0
  SET request->sss_cur_rh_cd = 0
  SET temp_string = cnvtupper(trim(request->batch_selection))
  CALL check_owner_cd("bbt_rpt_stk_stat_bp")
  CALL check_inventory_cd("bbt_rpt_stk_stat_bp")
  CALL check_location_cd("bbt_rpt_stk_stat_bp")
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
 DECLARE firsttime = c1 WITH protected, noconstant("Y")
 DECLARE aborh_total_qty = i4 WITH protected, noconstant(0)
 DECLARE aborh_index = i4 WITH protected, noconstant(0)
 DECLARE aborh_cnt = i2 WITH protected, noconstant(0)
 DECLARE prod_index = i4 WITH protected, noconstant(0)
 DECLARE match_found = c1 WITH protected, noconstant("N")
 DECLARE avail_hold = c1 WITH protected, noconstant("N")
 DECLARE assigned_hold = c1 WITH protected, noconstant("N")
 DECLARE autodir_hold = c1 WITH protected, noconstant("N")
 DECLARE xm_hold = c1 WITH protected, noconstant("N")
 DECLARE quar_hold = c1 WITH protected, noconstant("N")
 DECLARE dispense_hold = c1 WITH protected, noconstant("N")
 DECLARE dont_use_hold = c1 WITH protected, noconstant("N")
 DECLARE avail_cnt_total = i4 WITH protected, noconstant(0)
 DECLARE assigned_cnt_total = i4 WITH protected, noconstant(0)
 DECLARE autodir_cnt_total = i4 WITH protected, noconstant(0)
 DECLARE xm_cnt_total = i4 WITH protected, noconstant(0)
 DECLARE quar_cnt_total = i4 WITH protected, noconstant(0)
 DECLARE dispense_cnt_total = i4 WITH protected, noconstant(0)
 DECLARE code_index = i4 WITH protected, noconstant(0)
 DECLARE line = vc WITH protected, constant(fillstring(125,"_"))
 DECLARE product_disp_ind = i2 WITH protected, noconstant(0)
 DECLARE abo_rh_disp_ind = i2 WITH protected, noconstant(0)
 DECLARE reportbyusername = vc WITH protect, noconstant("")
 DECLARE a_pool_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"APOOLRH"))
 DECLARE o_pool_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"OPOOLRH"))
 DECLARE b_pool_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"BPOOLRH"))
 DECLARE ab_pool_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"ABPOOLRH"))
 DECLARE pool_neg_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"POOLABONEG"))
 DECLARE pool_pos_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"POOLABOPOS"))
 DECLARE pool_pool_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"POOLABOPLRH"))
 DECLARE pool_abo_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",1640,"POOLABO"))
 SET reportbyusername = get_username(reqinfo->updt_id)
 RECORD aborh(
   1 info[*]
     2 abo_cd = f8
     2 rh_cd = f8
     2 aborh_cd = f8
     2 aborh_display = vc
     2 abo_display = vc
     2 rh_display = vc
     2 aborh_qty = i4
     2 avail_cnt = i4
     2 assigned_cnt = i4
     2 autodir_cnt = i4
     2 xm_cnt = i4
     2 quar_cnt = i4
     2 dispense_cnt = i4
     2 pooled_ind = i2
 )
 RECORD codeinfo(
   1 code_info[*]
     2 code = f8
     2 rank = c2
 )
 SET cur_owner_area_disp = fillstring(40," ")
 SET cur_inv_area_disp = fillstring(40," ")
 IF ((request->cur_owner_area_cd=0.0))
  SET cur_owner_area_disp = captions->paren_all
 ELSE
  SET cur_owner_area_disp = uar_get_code_display(request->cur_owner_area_cd)
 ENDIF
 IF ((request->cur_inv_area_cd=0.0))
  SET cur_inv_area_disp = captions->paren_all
 ELSE
  SET cur_inv_area_disp = uar_get_code_display(request->cur_inv_area_cd)
 ENDIF
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=1610
   AND c.cdf_meaning != "19"
  HEAD REPORT
   code_index = 0, stat = alterlist(codeinfo->code_info,5)
  DETAIL
   code_index += 1
   IF (size(codeinfo->code_info,5) <= code_index)
    stat = alterlist(codeinfo->code_info,(code_index+ 4))
   ENDIF
   IF (c.cdf_meaning="1")
    codeinfo->code_info[code_index].code = c.code_value, codeinfo->code_info[code_index].rank = "3"
   ELSEIF (c.cdf_meaning="2")
    codeinfo->code_info[code_index].code = c.code_value, codeinfo->code_info[code_index].rank = "6"
   ELSEIF (c.cdf_meaning="3")
    codeinfo->code_info[code_index].code = c.code_value, codeinfo->code_info[code_index].rank = "5"
   ELSEIF (c.cdf_meaning="4")
    codeinfo->code_info[code_index].code = c.code_value, codeinfo->code_info[code_index].rank = "7"
   ELSEIF (c.cdf_meaning="5")
    codeinfo->code_info[code_index].code = c.code_value, codeinfo->code_info[code_index].rank = "0"
   ELSEIF (c.cdf_meaning="6")
    codeinfo->code_info[code_index].code = c.code_value, codeinfo->code_info[code_index].rank = "0"
   ELSEIF (c.cdf_meaning="7")
    codeinfo->code_info[code_index].code = c.code_value, codeinfo->code_info[code_index].rank = "0"
   ELSEIF (c.cdf_meaning="8")
    codeinfo->code_info[code_index].code = c.code_value, codeinfo->code_info[code_index].rank = "0"
   ELSEIF (c.cdf_meaning="9")
    codeinfo->code_info[code_index].code = c.code_value, codeinfo->code_info[code_index].rank = "1"
   ELSEIF (c.cdf_meaning="10")
    codeinfo->code_info[code_index].code = c.code_value, codeinfo->code_info[code_index].rank = "4"
   ELSEIF (c.cdf_meaning="11")
    codeinfo->code_info[code_index].code = c.code_value, codeinfo->code_info[code_index].rank = "4"
   ELSEIF (c.cdf_meaning="12")
    codeinfo->code_info[code_index].code = c.code_value, codeinfo->code_info[code_index].rank = "2"
   ELSEIF (c.cdf_meaning="13")
    codeinfo->code_info[code_index].code = c.code_value, codeinfo->code_info[code_index].rank = "1"
   ELSEIF (c.cdf_meaning="14")
    codeinfo->code_info[code_index].code = c.code_value, codeinfo->code_info[code_index].rank = "0"
   ELSEIF (c.cdf_meaning="15")
    codeinfo->code_info[code_index].code = c.code_value, codeinfo->code_info[code_index].rank = "0"
   ELSEIF (c.cdf_meaning="16")
    codeinfo->code_info[code_index].code = c.code_value, codeinfo->code_info[code_index].rank = "0"
   ELSEIF (c.cdf_meaning="17")
    codeinfo->code_info[code_index].code = c.code_value, codeinfo->code_info[code_index].rank = "0"
   ELSEIF (c.cdf_meaning="18")
    codeinfo->code_info[code_index].code = c.code_value, codeinfo->code_info[code_index].rank = "0"
   ENDIF
  FOOT REPORT
   stat = alterlist(codeinfo->code_info,code_index)
  WITH nullreport, nocounter, check
 ;end select
 SET blood_product_class_cd = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "BLOOD"
 SET stat = uar_get_meaning_by_codeset(1606,nullterm(cdf_meaning),1,blood_product_class_cd)
 SET prod_col = 20
 SET prod_index = 0
 SELECT
  IF ((request->sss_cur_abo_cd=0)
   AND (request->sss_cur_rh_cd=0))
   PLAN (cv1
    WHERE cv1.code_set=1640
     AND cv1.active_ind=1)
    JOIN (cve1
    WHERE cve1.code_set=1640
     AND cv1.code_value=cve1.code_value
     AND cve1.field_name="ABOOnly_cd")
    JOIN (cve2
    WHERE cve2.code_set=1640
     AND cv1.code_value=cve2.code_value
     AND cve2.field_name="RhOnly_cd")
  ELSEIF ((request->sss_cur_abo_cd=0)
   AND (request->sss_cur_rh_cd > 0))
   PLAN (cv1
    WHERE cv1.code_set=1640
     AND cv1.active_ind=1)
    JOIN (cve1
    WHERE cve1.code_set=1640
     AND cv1.code_value=cve1.code_value
     AND cve1.field_name="ABOOnly_cd")
    JOIN (cve2
    WHERE cve2.code_set=1640
     AND cv1.code_value=cve2.code_value
     AND cve2.field_name="RhOnly_cd"
     AND (cnvtint(cve2.field_value)=request->sss_cur_rh_cd))
  ELSEIF ((request->sss_cur_abo_cd > 0)
   AND (request->sss_cur_rh_cd=0))
   PLAN (cv1
    WHERE cv1.code_set=1640
     AND cv1.active_ind=1)
    JOIN (cve1
    WHERE cve1.code_set=1640
     AND cv1.code_value=cve1.code_value
     AND cve1.field_name="ABOOnly_cd"
     AND (cnvtint(cve1.field_value)=request->sss_cur_abo_cd))
    JOIN (cve2
    WHERE cve2.code_set=1640
     AND cv1.code_value=cve2.code_value
     AND cve2.field_name="RhOnly_cd")
  ELSEIF ((request->sss_cur_abo_cd > 0)
   AND (request->sss_cur_rh_cd > 0))
   PLAN (cv1
    WHERE cv1.code_set=1640
     AND cv1.active_ind=1)
    JOIN (cve1
    WHERE cve1.code_set=1640
     AND cv1.code_value=cve1.code_value
     AND cve1.field_name="ABOOnly_cd"
     AND (cnvtint(cve1.field_value)=request->sss_cur_abo_cd))
    JOIN (cve2
    WHERE cve2.code_set=1640
     AND cv1.code_value=cve2.code_value
     AND cve2.field_name="RhOnly_cd"
     AND (cnvtint(cve2.field_value)=request->sss_cur_rh_cd))
  ELSE
  ENDIF
  INTO "nl:"
  aborh_combined_display = uar_get_code_display(cv1.code_value), aborh_code = cnvtreal(cv1.code_value
   ), abo_only_display = uar_get_code_display(cnvtreal(cve1.field_value)),
  rh_only_display = uar_get_code_display(cnvtreal(cve2.field_value)), abo_code = cnvtreal(cve1
   .field_value), rh_code = cnvtreal(cve2.field_value)
  FROM code_value cv1,
   code_value_extension cve1,
   code_value_extension cve2
  ORDER BY cve1.field_value, cve2.field_value
  HEAD REPORT
   stat = alterlist(aborh->info,10)
  DETAIL
   prod_index += 1
   IF (size(aborh->info,5) <= prod_index)
    stat = alterlist(aborh->info,(prod_index+ 9))
   ENDIF
   aborh->info[prod_index].aborh_display = aborh_combined_display, aborh->info[prod_index].
   abo_display = abo_only_display, aborh->info[prod_index].rh_display = rh_only_display,
   aborh->info[prod_index].abo_cd = abo_code, aborh->info[prod_index].rh_cd = rh_code
   IF (((aborh_code=o_pool_cd) OR (((aborh_code=pool_neg_cd) OR (((aborh_code=a_pool_cd) OR (((
   aborh_code=pool_pos_cd) OR (((aborh_code=b_pool_cd) OR (((aborh_code=pool_pool_cd) OR (((
   aborh_code=ab_pool_cd) OR (aborh_code=pool_abo_cd)) )) )) )) )) )) )) )
    aborh->info[prod_index].pooled_ind = 1
   ELSE
    aborh->info[prod_index].pooled_ind = 0
   ENDIF
   aborh_cnt += 1
  FOOT REPORT
   stat = alterlist(aborh->info,prod_index)
  WITH check, nocounter
 ;end select
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_stck_stat_bp", "txt", "x"
 SELECT
  IF ((request->sss_product_cat_cd=0))
   PLAN (pi
    WHERE pi.product_class_cd=blood_product_class_cd
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
    JOIN (pe
    WHERE pr.product_id=pe.product_id
     AND pe.active_ind=1)
    JOIN (bp
    WHERE (bp.product_id= Outerjoin(pr.product_id)) )
   ORDER BY pi.product_class_cd, pi.product_cat_cd, pi.product_cd,
    pe.product_id, pe.product_event_id
  ELSEIF ((request->sss_product_cat_cd > 0))
   PLAN (pi
    WHERE (pi.product_cat_cd=request->sss_product_cat_cd)
     AND pi.product_cat_cd > 0
     AND pi.product_class_cd=blood_product_class_cd
     AND pi.active_ind=1)
    JOIN (d1
    WHERE d1.seq=1)
    JOIN (pr
    WHERE pi.product_cd=pr.product_cd
     AND (((request->cur_owner_area_cd > 0.0)
     AND (request->cur_owner_area_cd=pr.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (request->cur_inv_area_cd=pr.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
    JOIN (pe
    WHERE pr.product_id=pe.product_id
     AND pe.active_ind=1)
    JOIN (bp
    WHERE (bp.product_id= Outerjoin(pr.product_id)) )
   ORDER BY pi.product_class_cd, pi.product_cat_cd, pi.product_cd,
    pe.product_id, pe.product_event_id
  ELSE
  ENDIF
  INTO cpm_cfn_info->file_name_logical
  pi.product_class_cd, pi.product_cat_cd, pi.product_cd,
  pe.product_id, pe.product_event_id, bp.cur_abo_cd,
  bp.cur_rh_cd, pe.event_type_cd, pr.product_cd,
  pr.product_cat_cd, pr.product_class_cd, product_type_display = uar_get_code_display(pi.product_cd),
  product_cat_display = uar_get_code_display(pi.product_cat_cd), product_class_display =
  uar_get_code_display(pi.product_class_cd), abo_display = uar_get_code_display(bp.cur_abo_cd),
  rh_display = uar_get_code_display(bp.cur_rh_cd), decode_flag = decode(pe.seq,"PE","NO")
  FROM product_index pi,
   (dummyt d1  WITH seq = 1),
   product pr,
   product_event pe,
   blood_product bp
  HEAD REPORT
   select_ok_ind = 0, idx = 0, abo_rh_display = fillstring(25," "),
   product_disp_ind = 1, abo_rh_disp_ind = 0, prod_category_disp = fillstring(40," ")
  HEAD PAGE
   CALL center(captions->stock_status,1,125), col 104, captions->time,
   col 118, curtime"@TIMENOSECONDS;;M", row + 1,
   col 104, captions->as_of_date, col 118,
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
   CALL center(captions->blood_products,1,125),
   row save_row, row + 1, col 1,
   captions->bb_owner, col 19, cur_owner_area_disp,
   row + 1, col 1, captions->inventory_area,
   col 17, cur_inv_area_disp, row + 2,
   col 1, captions->product_class, col 21,
   product_class_display, row + 2, col 1,
   captions->product_category
   IF (size(trim(prod_category_disp))=0)
    prod_category_disp = product_cat_display
   ENDIF
   col 21, prod_category_disp, row + 2
   IF (product_disp_ind=1)
    col 1, captions->products
   ELSEIF (abo_rh_disp_ind=1)
    CALL center(captions->aborh,9,23), col 31, captions->avail,
    col 44, captions->assign, col 56,
    captions->auto_dir, col 71, captions->quar,
    col 82, captions->xmatch, col 95,
    captions->dispense, col 109, captions->total,
    row + 1, col 09, "---------------",
    col 30, "--------", col 43,
    "--------", col 56, "--------",
    col 69, "--------", col 82,
    "--------", col 95, "--------",
    col 108, "--------", row + 1
   ENDIF
  HEAD pi.product_class_cd
   row + 0
  HEAD pi.product_cat_cd
   prod_category_disp = product_cat_display
   IF (firsttime="Y")
    firsttime = "N"
   ELSE
    BREAK
   ENDIF
  HEAD pi.product_cd
   row + 0
  HEAD pe.product_id
   row + 0
  HEAD pe.product_event_id
   row + 0
  DETAIL
   row + 0
  FOOT  pe.product_event_id
   IF (decode_flag="PE")
    code_index = 1, match_found = "N"
    WHILE (match_found="N"
     AND code_index <= size(codeinfo->code_info,5))
      IF ((pe.event_type_cd=codeinfo->code_info[code_index].code))
       match_found = "Y"
       IF ((codeinfo->code_info[code_index].rank="0"))
        dont_use_hold = "Y"
       ELSEIF ((codeinfo->code_info[code_index].rank="2"))
        avail_hold = "Y"
       ELSEIF ((codeinfo->code_info[code_index].rank="3"))
        assigned_hold = "Y"
       ELSEIF ((codeinfo->code_info[code_index].rank="4"))
        autodir_hold = "Y"
       ELSEIF ((codeinfo->code_info[code_index].rank="5"))
        xm_hold = "Y"
       ELSEIF ((codeinfo->code_info[code_index].rank="6"))
        quar_hold = "Y"
       ELSEIF ((codeinfo->code_info[code_index].rank="7"))
        dispense_hold = "Y"
       ENDIF
      ELSE
       code_index += 1
      ENDIF
    ENDWHILE
   ENDIF
  FOOT  pe.product_id
   IF (decode_flag="PE"
    AND dont_use_hold="N")
    aborh_index = 1, match_found = "N"
    WHILE (match_found="N"
     AND aborh_index <= aborh_cnt)
      IF ((bp.cur_abo_cd=aborh->info[aborh_index].abo_cd)
       AND (bp.cur_rh_cd=aborh->info[aborh_index].rh_cd))
       IF (dispense_hold="Y")
        aborh->info[aborh_index].dispense_cnt += 1, aborh->info[aborh_index].aborh_qty += 1
       ELSEIF (quar_hold="Y")
        aborh->info[aborh_index].quar_cnt += 1, aborh->info[aborh_index].aborh_qty += 1
       ELSEIF (xm_hold="Y")
        aborh->info[aborh_index].xm_cnt += 1, aborh->info[aborh_index].aborh_qty += 1
       ELSEIF (autodir_hold="Y")
        aborh->info[aborh_index].autodir_cnt += 1, aborh->info[aborh_index].aborh_qty += 1
       ELSEIF (assigned_hold="Y")
        aborh->info[aborh_index].assigned_cnt += 1, aborh->info[aborh_index].aborh_qty += 1
       ELSEIF (avail_hold="Y")
        aborh->info[aborh_index].avail_cnt += 1, aborh->info[aborh_index].aborh_qty += 1
       ENDIF
       match_found = "Y"
      ELSE
       aborh_index += 1
      ENDIF
    ENDWHILE
   ENDIF
   dont_use_hold = "N", avail_hold = "N", assigned_hold = "N",
   autodir_hold = "N", xm_hold = "N", quar_hold = "N",
   dispense_hold = "N"
  FOOT  pi.product_cd
   col 1, display_product = substring(1,22,product_type_display), col + prod_col,
   display_product
   IF (prod_col > 80)
    row + 1
    IF (row > 57)
     product_disp_ind = 1, abo_rh_disp_ind = 0, BREAK
    ENDIF
    prod_col = 20
   ELSE
    prod_col += 25
   ENDIF
  FOOT  pi.product_cat_cd
   prod_col = 20, row + 3
   IF (row > 48)
    product_disp_ind = 0, abo_rh_disp_ind = 0, BREAK
   ENDIF
   CALL center(captions->aborh,9,23), col 31, captions->avail,
   col 44, captions->assign, col 56,
   captions->auto_dir, col 71, captions->quar,
   col 82, captions->xmatch, col 95,
   captions->dispense, col 109, captions->total,
   row + 1, col 09, "---------------",
   col 30, "--------", col 43,
   "--------", col 56, "--------",
   col 69, "--------", col 82,
   "--------", col 95, "--------",
   col 108, "--------", aborh_index = 1
   WHILE (aborh_index <= aborh_cnt)
    IF ((((aborh->info[aborh_index].aborh_qty > 0)) OR ((aborh->info[aborh_index].pooled_ind=0))) )
     row + 1
     IF (row > 54)
      product_disp_ind = 0, abo_rh_disp_ind = 1, BREAK
     ENDIF
     IF (trim(aborh->info[aborh_index].aborh_display)=" ")
      col 08, captions->no_aborh
     ELSE
      col 09, aborh->info[aborh_index].aborh_display
     ENDIF
     col 32, aborh->info[aborh_index].avail_cnt"####;p ", col 45,
     aborh->info[aborh_index].assigned_cnt"####;p ", col 58, aborh->info[aborh_index].autodir_cnt
     "####;p ",
     col 71, aborh->info[aborh_index].quar_cnt"####;p ", col 84,
     aborh->info[aborh_index].xm_cnt"####;p ", col 97, aborh->info[aborh_index].dispense_cnt"####;p ",
     col 110, aborh->info[aborh_index].aborh_qty"####;p ", avail_cnt_total += aborh->info[aborh_index
     ].avail_cnt,
     assigned_cnt_total += aborh->info[aborh_index].assigned_cnt, autodir_cnt_total += aborh->info[
     aborh_index].autodir_cnt, xm_cnt_total += aborh->info[aborh_index].xm_cnt,
     quar_cnt_total += aborh->info[aborh_index].quar_cnt, dispense_cnt_total += aborh->info[
     aborh_index].dispense_cnt, aborh_total_qty += aborh->info[aborh_index].aborh_qty
    ENDIF
    ,aborh_index += 1
   ENDWHILE
   FOR (idx = 1 TO aborh_cnt)
     aborh->info[idx].aborh_qty = 0, aborh->info[idx].avail_cnt = 0, aborh->info[idx].assigned_cnt =
     0,
     aborh->info[idx].autodir_cnt = 0, aborh->info[idx].xm_cnt = 0, aborh->info[idx].quar_cnt = 0,
     aborh->info[idx].dispense_cnt = 0
   ENDFOR
   row + 1, col 30, "--------",
   col 43, "--------", col 56,
   "--------", col 69, "--------",
   col 82, "--------", col 95,
   "--------", col 108, "--------",
   row + 1, col 32, avail_cnt_total"####;p ",
   col 45, assigned_cnt_total"####;p ", col 58,
   autodir_cnt_total"####;p ", col 71, quar_cnt_total"####;p ",
   col 84, xm_cnt_total"####;p ", col 97,
   dispense_cnt_total"####;p ", col 110, aborh_total_qty"####;p ",
   avail_cnt_total = 0, assigned_cnt_total = 0, autodir_cnt_total = 0,
   xm_cnt_total = 0, quar_cnt_total = 0, dispense_cnt_total = 0,
   aborh_total_qty = 0, prod_index = 0, product_disp_ind = 1
  FOOT  pi.product_class_cd
   row + 0
  FOOT PAGE
   row 61, col 1, line,
   row + 1, col 1, captions->report_id,
   col 58, captions->page_no, col 64,
   curpage"###", col 100, captions->printed,
   col 110, curdate"@DATECONDENSED;;d", col 120,
   curtime"@TIMENOSECONDS;;M"
  FOOT REPORT
   row 58, col 1, captions->user,
   col 20, reportbyusername, row + 1,
   col 1, captions->product_category
   IF ((request->sss_product_cat_cd > 0))
    col 20, prod_category_disp
   ELSE
    col 20, captions->all
   ENDIF
   row + 1
   IF ((request->sss_cur_abo_cd=0)
    AND (request->sss_cur_rh_cd=0))
    abo_rh_display = concat(captions->all," ",captions->slash," ",captions->all)
   ELSEIF ((request->sss_cur_abo_cd > 0)
    AND (request->sss_cur_rh_cd=0))
    abo_rh_display = concat(aborh->info[1].abo_display," ",captions->slash," ",captions->all)
   ELSEIF ((request->sss_cur_abo_cd=0)
    AND (request->sss_cur_rh_cd > 0))
    abo_rh_display = concat(captions->all," ",captions->slash," ",aborh->info[1].rh_display)
   ELSEIF ((request->sss_cur_abo_cd > 0)
    AND (request->sss_cur_rh_cd > 0))
    abo_rh_display = concat(aborh->info[1].abo_display," ",captions->slash," ",aborh->info[1].
     rh_display)
   ENDIF
   col 1, captions->aborh_space, col 20,
   abo_rh_display, row 64, col 51,
   captions->end_of_report, select_ok_ind = 1
  WITH nullreport, nocounter, outerjoin(d1),
   maxrow = 65, nolandscape, compress
 ;end select
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
