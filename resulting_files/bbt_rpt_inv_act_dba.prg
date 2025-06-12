CREATE PROGRAM bbt_rpt_inv_act:dba
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
   1 inventory_activity = vc
   1 time = vc
   1 as_of_date = vc
   1 bb_owner = vc
   1 inventory_area = vc
   1 beg_date = vc
   1 end_date = vc
   1 ct = vc
   1 per_of = vc
   1 patients = vc
   1 per_patients = vc
   1 product = vc
   1 receivd = vc
   1 assignd = vc
   1 xmatchd = vc
   1 dispensd = vc
   1 transfsd = vc
   1 disposd = vc
   1 destryd = vc
   1 rc_ratio = vc
   1 transfsns = vc
   1 rpt_total = vc
   1 report_id = vc
   1 page_no = vc
   1 printed = vc
   1 rpt_by = vc
   1 end_of_report = vc
   1 all = vc
 )
 SET captions->inventory_activity = uar_i18ngetmessage(i18nhandle,"inventory_activity",
  "I N V E N T O R Y   A C T I V I T Y   R E P O R T")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","Time:")
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","As of Date:")
 SET captions->bb_owner = uar_i18ngetmessage(i18nhandle,"bb_owner","Blood Bank Owner: ")
 SET captions->inventory_area = uar_i18ngetmessage(i18nhandle,"inventory_area","Inventory Area: ")
 SET captions->beg_date = uar_i18ngetmessage(i18nhandle,"beg_date","Beginning Date:")
 SET captions->end_date = uar_i18ngetmessage(i18nhandle,"end_date","Ending Date:")
 SET captions->ct = uar_i18ngetmessage(i18nhandle,"ct","     C/T  ")
 SET captions->per_of = uar_i18ngetmessage(i18nhandle,"per_of","  % OF   ")
 SET captions->patients = uar_i18ngetmessage(i18nhandle,"patients","PATIENTS")
 SET captions->per_patients = uar_i18ngetmessage(i18nhandle,"per_patients","% PATIENTS")
 SET captions->product = uar_i18ngetmessage(i18nhandle,"product","PRODUCT             ")
 SET captions->receivd = uar_i18ngetmessage(i18nhandle,"receivd","RECEIVD")
 SET captions->assignd = uar_i18ngetmessage(i18nhandle,"assignd","ASSIGND")
 SET captions->xmatchd = uar_i18ngetmessage(i18nhandle,"xmatchd","XMATCHD")
 SET captions->dispensd = uar_i18ngetmessage(i18nhandle,"dispensd","DISPENSD")
 SET captions->transfsd = uar_i18ngetmessage(i18nhandle,"transfsd","TRANSFSD")
 SET captions->disposd = uar_i18ngetmessage(i18nhandle,"disposd","DISPOSD")
 SET captions->destryd = uar_i18ngetmessage(i18nhandle,"destryd","DESTRYD")
 SET captions->rc_ratio = uar_i18ngetmessage(i18nhandle,"rc_ratio","RC  RATIO ")
 SET captions->transfsns = uar_i18ngetmessage(i18nhandle,"transfsns","TRANSFSNS")
 SET captions->rpt_total = uar_i18ngetmessage(i18nhandle,"rpt_total","TOTAL")
 SET captions->report_id = uar_i18ngetmessage(i18nhandle,"report_id","Report ID: BBT_RPT_INV_ACT.PRG"
  )
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->rpt_by = uar_i18ngetmessage(i18nhandle,"rpt_by","By:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->all = uar_i18ngetmessage(i18nhandle,"all","(All)")
 DECLARE derivative_class_cd = f8
 DECLARE stat = i4
 DECLARE new_order_product_ind = i2 WITH protected, noconstant(0)
 DECLARE reportbyusername = vc WITH protect, noconstant("")
 SET stat = uar_get_meaning_by_codeset(1606,"DERIVATIVE",1,derivative_class_cd)
 IF (trim(request->batch_selection) > " ")
  SET begday = request->ops_date
  SET endday = request->ops_date
  SET temp_string = cnvtupper(trim(request->batch_selection))
  CALL check_opt_date_passed("bbt_rpt_inv_act")
  IF ((reply->status_data.status != "F"))
   SET request->beg_dt_tm = begday
   SET request->end_dt_tm = endday
  ENDIF
  CALL check_owner_cd("bbt_rpt_inv_act")
  CALL check_inventory_cd("bbt_rpt_inv_act")
  CALL check_location_cd("bbt_rpt_inv_act")
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
 RECORD inv_act(
   1 product[*]
     2 product_cd = f8
     2 product_disp = c20
     2 red_cell_product_ind = i2
     2 active_ind = i2
     2 patient_cnt = f8
     2 received_cnt = f8
     2 assigned_cnt = f8
     2 xmatched_cnt = f8
     2 issued_cnt = f8
     2 transfused_cnt = f8
     2 disposed_cnt = f8
     2 destroyed_cnt = f8
     2 derivative_ind = i2
   1 person[*]
     2 person_id = f8
 )
 DECLARE get_event_type_cds(" ") = c1
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET get_event_type_cds_status = ""
 SET report_complete_ind = "N"
 SET prod_cnt = 0
 SET prod = 0
 SET person_cnt = 0
 SET tot_patient_cnt = 0.0
 SET tot_received_cnt = 0.0
 SET tot_assigned_cnt = 0.0
 SET tot_xmatched_cnt = 0.0
 SET tot_issued_cnt = 0.0
 SET tot_transfused_cnt = 0.0
 SET tot_disposed_cnt = 0.0
 SET tot_destroyed_cnt = 0.0
 SET totals_d_seq = 0
 SET active_cnt = 0
 DECLARE assigned_cdf_meaning = c12
 DECLARE quarantined_cdf_meaning = c12
 DECLARE crossmatched_cdf_meaning = c12
 DECLARE issued_cdf_meaning = c12
 DECLARE disposed_cdf_meaning = c12
 DECLARE transferred_cdf_meaning = c12
 DECLARE transfused_cdf_meaning = c12
 DECLARE modified_cdf_meaning = c12
 DECLARE unconfirmed_cdf_meaning = c12
 DECLARE autologous_cdf_meaning = c12
 DECLARE directed_cdf_meaning = c12
 DECLARE available_cdf_meaning = c12
 DECLARE received_cdf_meaning = c12
 DECLARE destroyed_cdf_meaning = c12
 DECLARE shipped_cdf_meaning = c12
 DECLARE in_progress_cdf_meaning = c12
 DECLARE pooled_cdf_meaning = c12
 DECLARE pooled_product_cdf_meaning = c12
 DECLARE confirmed_cdf_meaning = c12
 DECLARE drawn_cdf_meaning = c12
 DECLARE tested_cdf_meaning = c12
 DECLARE intransit_cdf_meaning = c12
 DECLARE transferred_from_cdf_meaning = c12
 SET product_state_code_set = 1610
 SET product_state_expected_cnt = 19
 SET assigned_cdf_meaning = "1"
 SET quarantined_cdf_meaning = "2"
 SET crossmatched_cdf_meaning = "3"
 SET issued_cdf_meaning = "4"
 SET disposed_cdf_meaning = "5"
 SET transferred_cdf_meaning = "6"
 SET transfused_cdf_meaning = "7"
 SET modified_cdf_meaning = "8"
 SET unconfirmed_cdf_meaning = "9"
 SET autologous_cdf_meaning = "10"
 SET directed_cdf_meaning = "11"
 SET available_cdf_meaning = "12"
 SET received_cdf_meaning = "13"
 SET destroyed_cdf_meaning = "14"
 SET shipped_cdf_meaning = "15"
 SET in_progress_cdf_meaning = "16"
 SET pooled_cdf_meaning = "17"
 SET pooled_product_cdf_meaning = "18"
 SET confirmed_cdf_meaning = "19"
 SET drawn_cdf_meaning = "20"
 SET tested_cdf_meaning = "21"
 SET intransit_cdf_meaning = "25"
 SET modified_product_cdf_meaning = "24"
 SET transferred_from_cdf_meaning = "26"
 SET assigned_event_type_cd = 0.0
 SET quarantined_event_type_cd = 0.0
 SET crossmatched_event_type_cd = 0.0
 SET issued_event_type_cd = 0.0
 SET disposed_event_type_cd = 0.0
 SET transferred_event_type_cd = 0.0
 SET transfused_event_type_cd = 0.0
 SET modified_event_type_cd = 0.0
 SET unconfirmed_event_type_cd = 0.0
 SET autologous_event_type_cd = 0.0
 SET directed_event_type_cd = 0.0
 SET available_event_type_cd = 0.0
 SET received_event_type_cd = 0.0
 SET destroyed_event_type_cd = 0.0
 SET shipped_event_type_cd = 0.0
 SET in_progress_event_type_cd = 0.0
 SET pooled_event_type_cd = 0.0
 SET pooled_product_event_type_cd = 0.0
 SET confirmed_event_type_cd = 0.0
 SET drawn_event_type_cd = 0.0
 SET tested_event_type_cd = 0.0
 SET in_transit_event_type_cd = 0.0
 SET modified_product_event_type_cd = 0.0
 SET transferred_from_event_type_cd = 0.0
 SET get_event_type_cds_status = " "
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
 SET get_event_type_cds_status = get_event_type_cds(" ")
 IF (((get_event_type_cds_status=" ") OR (0.0 IN (received_event_type_cd, assigned_event_type_cd,
 crossmatched_event_type_cd, issued_event_type_cd, transfused_event_type_cd,
 disposed_event_type_cd, destroyed_event_type_cd))) )
  SET reply->status_data.status = "F"
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alter(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.subeventstatus[count1].operationname = "get event_type code_values"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "code_value"
  IF (get_event_type_cds_status="F")
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not et event_type code_values, select failed"
  ELSEIF (received_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get received event_type_cd"
  ELSEIF (assigned_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get assigned event_type_cd"
  ELSEIF (crossmatched_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get crossmatched event_type_cd"
  ELSEIF (issued_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get issued event_type_cd"
  ELSEIF (transfused_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get transfused event_type_cd"
  ELSEIF (disposed_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get disposed event_type_cd"
  ELSEIF (destroyed_event_type_cd=0.0)
   SET reply->status_data.subeventstatus[count1].targetobjectvalue =
   "could not get destroyed event_type_cd"
  ENDIF
  GO TO exit_script
 ENDIF
 SET reportbyusername = get_username(reqinfo->updt_id)
 SELECT INTO "nl:"
  pi.product_cd, pi.active_ind, product_disp = uar_get_code_display(pi.product_cd),
  pc.product_cat_cd, pc.red_cell_product_ind
  FROM product_index pi,
   product_category pc
  PLAN (pi
   WHERE pi.product_cd > 0.0)
   JOIN (pc
   WHERE pc.product_cat_cd=pi.product_cat_cd
    AND pc.product_class_cd=pi.product_class_cd)
  ORDER BY product_disp, pi.product_cd
  HEAD REPORT
   prod_cnt = 0
  HEAD pi.product_cd
   prod_cnt += 1
   IF (mod(prod_cnt,20)=1)
    stat = alterlist(inv_act->product,(prod_cnt+ 19))
   ENDIF
   inv_act->product[prod_cnt].product_cd = pi.product_cd, inv_act->product[prod_cnt].active_ind = pi
   .active_ind
   IF (pi.active_ind=1)
    active_cnt += 1
   ENDIF
   inv_act->product[prod_cnt].product_disp = product_disp, inv_act->product[prod_cnt].
   red_cell_product_ind = pc.red_cell_product_ind
   IF (pi.product_class_cd=derivative_class_cd)
    inv_act->product[prod_cnt].derivative_ind = 1
   ELSE
    inv_act->product[prod_cnt].derivative_ind = 0
   ENDIF
   inv_act->product[prod_cnt].patient_cnt = 0, inv_act->product[prod_cnt].received_cnt = 0, inv_act->
   product[prod_cnt].assigned_cnt = 0,
   inv_act->product[prod_cnt].xmatched_cnt = 0, inv_act->product[prod_cnt].issued_cnt = 0, inv_act->
   product[prod_cnt].transfused_cnt = 0,
   inv_act->product[prod_cnt].disposed_cnt = 0, inv_act->product[prod_cnt].destroyed_cnt = 0
  FOOT REPORT
   stat = alterlist(inv_act->product,prod_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.product_id, derivative_ind = inv_act->product[d1.seq].derivative_ind, pe.event_dt_tm,
  pe.event_type_cd, pe.event_status_flag, pe.person_id,
  re.product_event_id, disp.product_event_id, dest.product_event_id,
  ass.product_event_id, pd.product_event_id, tran.product_event_id,
  pe.order_id
  FROM (dummyt d1  WITH seq = value(prod_cnt)),
   product p,
   product_event pe,
   (dummyt d_re  WITH seq = 1),
   (dummyt d_derivatives  WITH seq = 1),
   receipt re,
   disposition disp,
   destruction dest,
   assign ass,
   patient_dispense pd,
   transfusion tran
  PLAN (pe
   WHERE pe.event_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND ((pe.event_type_cd IN (received_event_type_cd, assigned_event_type_cd,
   crossmatched_event_type_cd, issued_event_type_cd)) OR (pe.event_type_cd IN (
   transfused_event_type_cd, disposed_event_type_cd, destroyed_event_type_cd)
    AND pe.active_ind=1)) )
   JOIN (p
   WHERE p.product_id=pe.product_id
    AND (((request->cur_owner_area_cd > 0.0)
    AND (p.cur_owner_area_cd=request->cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
    AND (((request->cur_inv_area_cd > 0.0)
    AND (p.cur_inv_area_cd=request->cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
   JOIN (d1
   WHERE (inv_act->product[d1.seq].product_cd=p.product_cd))
   JOIN (d_re)
   JOIN (d_derivatives
   WHERE (inv_act->product[d1.seq].derivative_ind=1))
   JOIN (((re
   WHERE re.product_event_id=pe.product_event_id)
   ) ORJOIN ((((disp
   WHERE disp.product_event_id=pe.product_event_id)
   ) ORJOIN ((((dest
   WHERE dest.product_event_id=pe.product_event_id)
   ) ORJOIN ((((ass
   WHERE ass.product_event_id=pe.product_event_id)
   ) ORJOIN ((((pd
   WHERE pd.product_event_id=pe.product_event_id)
   ) ORJOIN ((tran
   WHERE tran.product_event_id=pe.product_event_id)
   )) )) )) )) ))
  ORDER BY p.product_cd, pe.event_type_cd, pe.person_id,
   pe.order_id, pe.product_id, pe.product_event_id
  HEAD p.product_cd
   event_cnt = 0
  HEAD pe.event_type_cd
   person_id_hd = 0.0
  HEAD pe.person_id
   row + 0
  HEAD pe.order_id
   row + 0
  HEAD pe.product_id
   new_order_product_ind = 1
  HEAD pe.product_event_id
   row + 0
  DETAIL
   event_cnt += 1
   IF (pe.event_type_cd=received_event_type_cd)
    IF (derivative_ind=1)
     tot_received_cnt += re.orig_rcvd_qty, inv_act->product[d1.seq].received_cnt += re.orig_rcvd_qty
    ELSE
     tot_received_cnt += 1, inv_act->product[d1.seq].received_cnt += 1
    ENDIF
   ELSEIF (pe.event_type_cd=assigned_event_type_cd)
    IF (derivative_ind=1)
     tot_assigned_cnt += ass.orig_assign_qty, inv_act->product[d1.seq].assigned_cnt += ass
     .orig_assign_qty
    ELSE
     tot_assigned_cnt += 1, inv_act->product[d1.seq].assigned_cnt += 1
    ENDIF
   ELSEIF (pe.event_type_cd=crossmatched_event_type_cd)
    IF (new_order_product_ind=1)
     tot_xmatched_cnt += 1, inv_act->product[d1.seq].xmatched_cnt += 1, new_order_product_ind = 0
    ENDIF
   ELSEIF (pe.event_type_cd=issued_event_type_cd)
    IF (derivative_ind=1)
     tot_issued_cnt += pd.orig_dispense_qty, inv_act->product[d1.seq].issued_cnt += pd
     .orig_dispense_qty
    ELSE
     tot_issued_cnt += 1, inv_act->product[d1.seq].issued_cnt += 1
    ENDIF
   ELSEIF (pe.event_type_cd=transfused_event_type_cd)
    IF (derivative_ind=1)
     tot_transfused_cnt += tran.orig_transfused_qty, inv_act->product[d1.seq].transfused_cnt += tran
     .orig_transfused_qty
    ELSE
     tot_transfused_cnt += 1, inv_act->product[d1.seq].transfused_cnt += 1
    ENDIF
    IF (pe.person_id != null
     AND pe.person_id > 0)
     IF (pe.person_id != person_id_hd)
      person_id_hd = pe.person_id, inv_act->product[d1.seq].patient_cnt += 1, person_cnt += 1
      IF (mod(person_cnt,20)=1)
       stat = alterlist(inv_act->person,(person_cnt+ 19))
      ENDIF
      inv_act->person[person_cnt].person_id = pe.person_id
     ENDIF
    ENDIF
   ELSEIF (pe.event_type_cd=disposed_event_type_cd)
    IF (derivative_ind=1)
     tot_disposed_cnt += disp.disposed_qty, inv_act->product[d1.seq].disposed_cnt += disp
     .disposed_qty
    ELSE
     tot_disposed_cnt += 1, inv_act->product[d1.seq].disposed_cnt += 1
    ENDIF
   ELSEIF (pe.event_type_cd=destroyed_event_type_cd
    AND pe.event_status_flag=0)
    IF (derivative_ind=1)
     tot_destroyed_cnt += dest.destroyed_qty, inv_act->product[d1.seq].destroyed_cnt += dest
     .destroyed_qty
    ELSE
     tot_destroyed_cnt += 1, inv_act->product[d1.seq].destroyed_cnt += 1
    ENDIF
   ENDIF
  FOOT  p.product_cd
   IF (event_cnt > 0
    AND (inv_act->product[d1.seq].active_ind=0))
    active_cnt += 1, inv_act->product[d1.seq].active_ind = 1
   ENDIF
  WITH nocounter, outerjoin(d_re)
 ;end select
 SELECT INTO "nl:"
  product_cd = inv_act->product[d1.seq].product_cd, derivative_ind = inv_act->product[d1.seq].
  derivative_ind, p.product_id,
  pe.event_dt_tm, pe.event_type_cd, pe.event_status_flag,
  pe.person_id
  FROM (dummyt d1  WITH seq = prod_cnt),
   bbhist_product p,
   bbhist_product_event pe
  PLAN (pe
   WHERE pe.event_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND pe.event_type_cd IN (transfused_event_type_cd, destroyed_event_type_cd))
   JOIN (p
   WHERE p.product_id=pe.product_id
    AND (((p.owner_area_cd=request->cur_owner_area_cd)
    AND (request->cur_owner_area_cd > 0.0)) OR ((request->cur_owner_area_cd=0.0)))
    AND (((request->cur_inv_area_cd=p.inv_area_cd)
    AND (request->cur_inv_area_cd > 0.0)) OR ((request->cur_inv_area_cd=0.0))) )
   JOIN (d1
   WHERE (inv_act->product[d1.seq].product_cd=p.product_cd))
  ORDER BY product_cd, pe.event_type_cd, pe.person_id,
   pe.product_event_id
  HEAD product_cd
   event_cnt = 0
  HEAD pe.event_type_cd
   person_id_hd = 0.0, i = 0
  DETAIL
   event_cnt += 1
   IF (pe.event_type_cd=transfused_event_type_cd)
    IF (derivative_ind=1)
     tot_transfused_cnt += pe.qty, inv_act->product[d1.seq].transfused_cnt += pe.qty
    ELSE
     tot_transfused_cnt += 1, inv_act->product[d1.seq].transfused_cnt += 1
    ENDIF
    IF (pe.person_id > 0.0)
     IF (pe.person_id != person_id_hd)
      person_id_hd = pe.person_id, inv_act->product[d1.seq].patient_cnt += 1, person_cnt += 1
      IF (mod(person_cnt,20)=1)
       stat = alterlist(inv_act->person,(person_cnt+ 19))
      ENDIF
      inv_act->person[person_cnt].person_id = pe.person_id
     ENDIF
    ENDIF
   ELSEIF (pe.event_type_cd=destroyed_event_type_cd)
    IF (derivative_ind=1)
     tot_destroyed_cnt += pe.qty, inv_act->product[d1.seq].destroyed_cnt += pe.qty
    ELSE
     tot_destroyed_cnt += 1, inv_act->product[d1.seq].destroyed_cnt += 1
    ENDIF
   ENDIF
  FOOT  product_cd
   IF ((inv_act->product[d1.seq].active_ind=0)
    AND event_cnt > 0)
    active_cnt += 1, inv_act->product[d1.seq].active_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(inv_act->person,person_cnt)
 SET totals_d_seq = (prod_cnt+ 1)
 SET tot_patient_cnt = 0
 SELECT INTO "nl:"
  d.seq, person_id = inv_act->person[d.seq].person_id
  FROM (dummyt d  WITH seq = value(person_cnt))
  ORDER BY person_id
  HEAD person_id
   IF (person_id > 0
    AND d.seq > 0)
    tot_patient_cnt += 1
   ENDIF
  WITH nocounter
 ;end select
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_inv_act", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  d.seq
  FROM (dummyt d  WITH seq = value(totals_d_seq))
  HEAD REPORT
   line = fillstring(130,"-"), beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime
   (request->end_dt_tm),
   tot_trans_pcnt = 0.0, first_page = "Y", select_ok_ind = 0
  HEAD PAGE
   new_page = "Y", row + 1, row 0,
   CALL center(captions->inventory_activity,1,132), col 107, captions->time,
   col 121, curtime"@TIMENOSECONDS;;M", row + 1,
   col 107, captions->as_of_date, col 121,
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
   row + 1, col 1, captions->bb_owner,
   col 19, cur_owner_area_disp, row + 1,
   col 1, captions->inventory_area, col 17,
   cur_inv_area_disp, row + 2, col 034,
   captions->beg_date, col 050, beg_dt_tm"@DATETIMECONDENSED;;d",
   col 073, captions->end_date, col 086,
   end_dt_tm"@DATETIMECONDENSED;;d", row + 2, col 088,
   captions->ct, col 100, captions->per_of,
   col 111, captions->patients, col 121,
   captions->per_patients, row + 1, col 001,
   captions->product, col 023, captions->receivd,
   col 032, captions->assignd, col 041,
   captions->xmatchd, col 050, captions->dispensd,
   col 060, captions->transfsd, col 070,
   captions->disposd, col 079, captions->destryd,
   col 088, captions->rc_ratio, col 100,
   captions->transfsns, col 111, captions->transfsd,
   col 121, captions->transfsd, row + 1,
   col 001, "--------------------", col 023,
   "-------", col 032, "-------",
   col 041, "-------", col 050,
   "--------", col 060, "--------",
   col 070, "-------", col 079,
   "-------", col 088, "----------",
   col 100, "---------", col 111,
   "--------", col 121, "----------"
  DETAIL
   IF (d.seq != totals_d_seq)
    IF ((inv_act->product[d.seq].active_ind=1))
     IF (first_page="Y")
      first_page = "N"
     ELSE
      row + 1
      IF (row > 56)
       BREAK
      ENDIF
     ENDIF
     row + 1, col 001, inv_act->product[d.seq].product_disp,
     col 024, inv_act->product[d.seq].received_cnt"######", col 033,
     inv_act->product[d.seq].assigned_cnt"######", col 042, inv_act->product[d.seq].xmatched_cnt
     "######",
     col 052, inv_act->product[d.seq].issued_cnt"######", col 062,
     inv_act->product[d.seq].transfused_cnt"######", col 071, inv_act->product[d.seq].disposed_cnt
     "######",
     col 080, inv_act->product[d.seq].destroyed_cnt"######"
     IF ((inv_act->product[d.seq].red_cell_product_ind=1))
      col 088, "*", ct_ratio = 0.0
      IF ((inv_act->product[d.seq].transfused_cnt > 0))
       ct_ratio = (inv_act->product[d.seq].xmatched_cnt/ inv_act->product[d.seq].transfused_cnt)
      ELSE
       ct_ratio = inv_act->product[d.seq].xmatched_cnt
      ENDIF
      ct_ratio_display = format(ct_ratio,"###.####;I;F"), col 090, ct_ratio_display
     ENDIF
     trans_pcnt = 0.0, trans_pcnt = ((inv_act->product[d.seq].transfused_cnt/ tot_transfused_cnt) *
     100), tot_trans_pcnt += trans_pcnt,
     trans_pcnt_display = format(trans_pcnt,"###.##;I;F"), col 101, trans_pcnt_display,
     col 108, "%", col 113,
     inv_act->product[d.seq].patient_cnt"######", pat_trans_pcnt = 0.0, pat_trans_pcnt = ((inv_act->
     product[d.seq].patient_cnt/ tot_patient_cnt) * 100),
     pat_trans_pcnt_display = format(pat_trans_pcnt,"###.##;I;F"), col 123, pat_trans_pcnt_display,
     col 130, "%"
    ENDIF
   ELSE
    row + 1
    IF (row > 55)
     BREAK
    ELSE
     col 001, "--------------------", col 023,
     "-------", col 032, "-------",
     col 041, "-------", col 050,
     "--------", col 060, "--------",
     col 070, "-------", col 079,
     "-------", col 088, "----------",
     col 100, "---------", col 111,
     "--------", col 121, "----------"
    ENDIF
    row + 1, col 001, captions->rpt_total,
    col 007, "(", col 008,
    active_cnt"####", col 012, ")",
    col 024, tot_received_cnt"######", col 033,
    tot_assigned_cnt"######", col 042, tot_xmatched_cnt"######",
    col 052, tot_issued_cnt"######", col 062,
    tot_transfused_cnt"######", col 071, tot_disposed_cnt"######",
    col 080, tot_destroyed_cnt"######", col 111,
    tot_patient_cnt"######", ct_ratio = 0.0
    IF (tot_transfused_cnt > 0)
     ct_ratio = (tot_xmatched_cnt/ tot_transfused_cnt)
    ELSE
     ct_ratio = tot_xmatched_cnt
    ENDIF
    col 088, "*", ct_ratio_display = format(ct_ratio,"###.####;I;F"),
    col 090, ct_ratio_display, tot_trans_pcnt_display = format(tot_trans_pcnt,"###.##;I;F"),
    col 101, tot_trans_pcnt_display, col 108,
    "%", col 113, tot_patient_cnt"######",
    pat_trans_pcnt = 0.0, pat_trans_pcnt = ((tot_patient_cnt/ tot_patient_cnt) * 100),
    pat_trans_pcnt_display = format(pat_trans_pcnt,"###.##;I;F"),
    col 123, pat_trans_pcnt_display, col 130,
    "%"
   ENDIF
  FOOT PAGE
   row 058, col 001, line,
   row + 1, col 001, captions->report_id,
   col 060, captions->page_no, col 067,
   curpage"###", col 103, captions->printed,
   col 113, curdate"@DATECONDENSED;;d", col 123,
   curtime"@TIMENOSECONDS;;M", row + 1, col 113,
   captions->rpt_by, col 117, reportbyusername"##############"
  FOOT REPORT
   row 061,
   CALL center(captions->end_of_report,1,125), report_complete_ind = "Y",
   select_ok_ind = 1
  WITH nocounter, outerjoin(d_pe), maxrow = 63,
   nullreport, compress, nolandscape
 ;end select
 SET rpt_cnt += 1
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
 IF (trim(request->batch_selection) > " "
  AND (reply->status_data.status="S"))
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
 DECLARE get_event_type_cds(event_type_status) = c1
 SUBROUTINE get_event_type_cds(event_type_cd_dummy)
   SET event_type_status = "F"
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,assigned_cdf_meaning,1,
    assigned_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,quarantined_cdf_meaning,1,
    quarantined_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,crossmatched_cdf_meaning,1,
    crossmatched_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,issued_cdf_meaning,1,
    issued_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,disposed_cdf_meaning,1,
    disposed_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,transferred_cdf_meaning,1,
    transferred_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,transfused_cdf_meaning,1,
    transfused_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,modified_cdf_meaning,1,
    modified_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,unconfirmed_cdf_meaning,1,
    unconfirmed_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,autologous_cdf_meaning,1,
    autologous_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,directed_cdf_meaning,1,
    directed_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,available_cdf_meaning,1,
    available_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,received_cdf_meaning,1,
    received_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,destroyed_cdf_meaning,1,
    destroyed_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,shipped_cdf_meaning,1,
    shipped_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,in_progress_cdf_meaning,1,
    in_progress_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,pooled_cdf_meaning,1,
    pooled_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,pooled_product_cdf_meaning,1,
    pooled_product_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,confirmed_cdf_meaning,1,
    confirmed_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,drawn_cdf_meaning,1,
    drawn_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,tested_cdf_meaning,1,
    tested_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,intransit_cdf_meaning,1,
    in_transit_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,modified_product_cdf_meaning,1,
    modified_product_event_type_cd)
   SET stat = uar_get_meaning_by_codeset(product_state_code_set,transferred_from_cdf_meaning,1,
    transferred_from_event_type_cd)
   SET event_type_status = "S"
   RETURN(event_type_status)
 END ;Subroutine
#exit_script
END GO
