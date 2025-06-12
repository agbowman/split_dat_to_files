CREATE PROGRAM bbt_rpt_pool_prod:dba
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
 DECLARE rowvar = i4
 RECORD captions(
   1 pooled_recon_products = vc
   1 time = vc
   1 as_of_date = vc
   1 bb_owner = vc
   1 inventory_area = vc
   1 beg_dt_tm = vc
   1 end_dt_tm = vc
   1 new_product = vc
   1 components = vc
   1 product_type = vc
   1 aborh = vc
   1 state = vc
   1 received = vc
   1 volume = vc
   1 expires = vc
   1 assigned_to = vc
   1 none = vc
   1 mrn = vc
   1 pooled = vc
   1 tech_id = vc
   1 transfused_to = vc
   1 not_transfused = vc
   1 transfused = vc
   1 report_id = vc
   1 page_no = vc
   1 printed = vc
   1 end_of_report = vc
   1 all = vc
   1 not_on_file = vc
   1 not_applicable = vc
   1 modified = vc
 )
 SET captions->pooled_recon_products = uar_i18ngetmessage(i18nhandle,"pooled_recon_products",
  "P O O L E D / R E C O N S T I T U T E D  P R O D U C T S   R E P O R T")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","Time:")
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","As of Date:")
 SET captions->bb_owner = uar_i18ngetmessage(i18nhandle,"bb_owner","Blood Bank Owner: ")
 SET captions->inventory_area = uar_i18ngetmessage(i18nhandle,"inventory_area","Inventory Area: ")
 SET captions->beg_dt_tm = uar_i18ngetmessage(i18nhandle,"beg_dt_tm","Beginnning Date/Time:")
 SET captions->end_dt_tm = uar_i18ngetmessage(i18nhandle,"end_dt_tm","Ending Date/Time:")
 SET captions->new_product = uar_i18ngetmessage(i18nhandle,"new_product","New Product")
 SET captions->components = uar_i18ngetmessage(i18nhandle,"components","Components")
 SET captions->product_type = uar_i18ngetmessage(i18nhandle,"product_type","Product Type")
 SET captions->aborh = uar_i18ngetmessage(i18nhandle,"aborh","ABO/Rh")
 SET captions->state = uar_i18ngetmessage(i18nhandle,"state","State")
 SET captions->received = uar_i18ngetmessage(i18nhandle,"received","Received")
 SET captions->volume = uar_i18ngetmessage(i18nhandle,"volume","Volume")
 SET captions->expires = uar_i18ngetmessage(i18nhandle,"expires","Expires")
 SET captions->assigned_to = uar_i18ngetmessage(i18nhandle,"assigned_to","Assigned to:")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"none","NONE")
 SET captions->mrn = uar_i18ngetmessage(i18nhandle,"mrn","MRN:")
 SET captions->pooled = uar_i18ngetmessage(i18nhandle,"pooled","Pooled:")
 SET captions->tech_id = uar_i18ngetmessage(i18nhandle,"tech_id","Tech ID:")
 SET captions->transfused_to = uar_i18ngetmessage(i18nhandle,"transfused_to","Transfused to:")
 SET captions->not_transfused = uar_i18ngetmessage(i18nhandle,"not_transfused","NOT TRANSFUSED")
 SET captions->transfused = uar_i18ngetmessage(i18nhandle,"transfused","Transfused:")
 SET captions->report_id = uar_i18ngetmessage(i18nhandle,"report_id","Report ID: BBT_RPT_POOL_PROD")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->all = uar_i18ngetmessage(i18nhandle,"all","(All)")
 SET captions->not_on_file = uar_i18ngetmessage(i18nhandle,"not_on_file","<Not on File>")
 SET captions->not_applicable = uar_i18ngetmessage(i18nhandle,"not_applicable","N/A")
 SET captions->modified = uar_i18ngetmessage(i18nhandle,"Modified","Modified:")
 IF (trim(request->batch_selection) > " ")
  SET begday = request->ops_date
  SET endday = request->ops_date
  SET temp_string = cnvtupper(trim(request->batch_selection))
  CALL check_opt_date_passed("bbt_rpt_pool_prod")
  IF ((reply->status_data.status != "F"))
   SET request->beg_dt_tm = begday
   SET request->end_dt_tm = endday
  ENDIF
  CALL check_owner_cd("bbt_rpt_pool_prod")
  CALL check_inventory_cd("bbt_rpt_pool_prod")
  CALL check_location_cd("bbt_rpt_pool_prod")
  SET request->printer_name = trim(request->output_dist)
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
 SET line = fillstring(125,"_")
 RECORD pool(
   1 pool_list[*]
     2 product_id1 = f8
     2 product_id2 = f8
     2 event_type_cd1 = f8
     2 product_nbr1 = c20
     2 product_sub_nbr1 = c5
     2 product_nbr2 = c20
     2 product_sub_nbr2 = c5
     2 product_type1 = c17
     2 product_type2 = c17
     2 abo1 = f8
     2 abo2 = f8
     2 rh1 = f8
     2 rh2 = f8
     2 status1 = c12
     2 status2 = c12
     2 recv_dt_tm1 = dq8
     2 recv_dt_tm2 = dq8
     2 pool_dt_tm = dq8
     2 volume1 = f8
     2 volume2 = f8
     2 exp_dt_tm1 = dq8
     2 exp_dt_tm2 = dq8
     2 username = c6
     2 alias[*]
       3 mrn = c22
     2 name = c30
     2 tran_alias[*]
       3 mrn = c22
     2 tran_name = vc
     2 tran_date = dq8
     2 tran_username = c6
     2 tran_active_ind = c1
 )
 SET stat = alterlist(pool->pool_list,10)
 RECORD aborh(
   1 aborh_list[*]
     2 aborh_display = c20
     2 abo_code = f8
     2 rh_code = f8
 )
 SET stat = alterlist(aborh->aborh_list,10)
 SET aborh_index = 0
 SELECT INTO "nl:"
  FROM code_value cv1,
   code_value_extension cve1,
   code_value_extension cve2,
   (dummyt d1  WITH seq = 1),
   code_value cv2,
   (dummyt d2  WITH seq = 1),
   code_value cv3
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
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (cv2
   WHERE cv2.code_set=1641
    AND cnvtint(cve1.field_value)=cv2.code_value)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (cv3
   WHERE cv3.code_set=1642
    AND cnvtint(cve2.field_value)=cv3.code_value)
  ORDER BY cve1.field_value, cve2.field_value
  DETAIL
   aborh_index += 1
   IF (mod(aborh_index,10)=1
    AND aborh_index != 1)
    stat = alterlist(aborh->aborh_list,(aborh_index+ 9))
   ENDIF
   aborh->aborh_list[aborh_index].aborh_display = cv1.display, aborh->aborh_list[aborh_index].
   abo_code = cv2.code_value, aborh->aborh_list[aborh_index].rh_code = cv3.code_value
  FOOT REPORT
   stat = alterlist(aborh->aborh_list,aborh_index)
  WITH outerjoin(d1), outerjoin(d2), check,
   nocounter
 ;end select
 SET assign_code = 0.0
 SET pool_code = 0.0
 SET tran_code = 0.0
 SET mrn_code = 0.0
 SET assign_code = uar_get_code_by("MEANING",1610,nullterm("1"))
 SET pool_code = uar_get_code_by("MEANING",1610,nullterm("18"))
 SET tran_code = uar_get_code_by("MEANING",1610,nullterm("7"))
 SET mrn_code = uar_get_code_by("MEANING",319,nullterm("MRN"))
 SET reply->status_data.status = "F"
 SET select_ok_ind = 0
 SET rpt_cnt = 0
 EXECUTE cpm_create_file_name_logical "bbt_pool_prod", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  pr1.product_nbr"###############", pr1.product_sub_nbr"#####", pr2.product_nbr"###############",
  pr2.product_sub_nbr"#####", c3.display"##########", c4.display"##########",
  pr1.product_id, pr2.product_id, pe1.event_type_cd,
  c1.display, c2.display, pr2.recv_dt_tm,
  pe1.event_dt_tm, bp1.cur_abo_cd, bp1.cur_rh_cd,
  prs.username, encntr_alias_exists = decode(ea.seq,"Y","N"), per.name_full_formatted
  "##############################",
  pe1.active_ind
  FROM product pr1,
   blood_product bp1,
   code_value c1,
   product_event pet,
   product_event pe1,
   code_value c3,
   prsnl prs,
   (dummyt d2  WITH seq = 1),
   encntr_alias ea,
   person per,
   (dummyt d1  WITH seq = 1),
   product pr2,
   blood_product bp2,
   code_value c2,
   product_event pe2,
   code_value c4
  PLAN (pr1
   WHERE pr1.pooled_product_ind > 0
    AND (((request->cur_owner_area_cd > 0.0)
    AND (request->cur_owner_area_cd=pr1.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
    AND (((request->cur_inv_area_cd > 0.0)
    AND (request->cur_inv_area_cd=pr1.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
   JOIN (pet
   WHERE pr1.product_id=pet.product_id
    AND pet.event_type_cd=pool_code
    AND pet.event_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm)
   )
   JOIN (pe1
   WHERE pet.product_id=pe1.product_id
    AND ((pe1.active_ind=1) OR (((pe1.event_type_cd=tran_code) OR (pe1.event_type_cd=assign_code))
   )) )
   JOIN (bp1
   WHERE pr1.product_id=bp1.product_id)
   JOIN (c1
   WHERE c1.code_set=1604
    AND bp1.product_cd=c1.code_value)
   JOIN (c3
   WHERE c3.code_set=1610
    AND c3.active_ind=1
    AND pe1.event_type_cd=c3.code_value)
   JOIN (prs
   WHERE pe1.updt_id=prs.person_id)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (ea
   WHERE pe1.person_id > 0
    AND pe1.encntr_id=ea.encntr_id
    AND ea.encntr_alias_type_cd=mrn_code
    AND ea.active_ind=1)
   JOIN (per
   WHERE pe1.person_id=per.person_id)
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (pr2
   WHERE pr1.product_id=pr2.pooled_product_id)
   JOIN (bp2
   WHERE pr2.product_id=bp2.product_id)
   JOIN (c2
   WHERE c2.code_set=1604
    AND bp2.product_cd=c2.code_value)
   JOIN (pe2
   WHERE pr2.product_id=pe2.product_id
    AND pe2.active_ind=1)
   JOIN (c4
   WHERE c4.code_set=1610
    AND c4.active_ind=1
    AND pe2.event_type_cd=c4.code_value)
  ORDER BY pr1.product_nbr, pr1.product_sub_nbr, pr1.product_id,
   pr2.product_id, pe1.event_type_cd, ea.encntr_alias_id
  HEAD REPORT
   pool_idx = 0, x = 0, y = 0,
   prt_rec = "N", component_hld = 0, event_type_cd_hld[10] = 0.0,
   event_type_display[10] = "            "
   FOR (x = 1 TO 10)
    event_type_cd_hld[x] = 0.0,event_type_display[x] = "            "
   ENDFOR
   first_time = "Y", select_ok_ind = 0, mrn_cnt1 = 0,
   mrn_cnt2 = 0, bmrnfound = "F", bpooled = "F",
   btrans = "F", bdisplay = "T", stat = alterlist(pool->pool_list[1].tran_alias,0),
   stat = alterlist(pool->pool_list[1].alias,0), mrn_alias = fillstring(27," "), product1_display =
   fillstring(43," "),
   product2_display = fillstring(25," ")
  HEAD PAGE
   CALL center(captions->pooled_recon_products,1,125), col 104, captions->time,
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
   row + 1, col 1, captions->bb_owner,
   col 19, cur_owner_area_disp, row + 1,
   col 1, captions->inventory_area, col 17,
   cur_inv_area_disp, row + 2, dt_tm = cnvtdatetime(request->beg_dt_tm),
   col 32, captions->beg_dt_tm, col 56,
   dt_tm"@DATECONDENSED;;d", col 64, dt_tm"@TIMENOSECONDS;;M",
   dt_tm = cnvtdatetime(request->end_dt_tm), col 74, captions->end_dt_tm,
   col 92, dt_tm"@DATECONDENSED;;d", col 100,
   dt_tm"@TIMENOSECONDS;;M", row + 2,
   CALL center(captions->new_product,1,22),
   CALL center(captions->components,24,45),
   CALL center(captions->product_type,47,63),
   CALL center(captions->aborh,65,84),
   CALL center(captions->state,86,95),
   CALL center(captions->received,97,106), col 108,
   captions->volume,
   CALL center(captions->expires,115,124), row + 1,
   col 1, "----------------------", col 24,
   "----------------------", col 47, "-----------------",
   col 65, "--------------------", col 86,
   "----------", col 97, "----------",
   col 108, "------", col 115,
   "----------", row + 1
  HEAD pr1.product_nbr
   pool->pool_list[1].tran_active_ind = " "
   FOR (i = 1 TO size(pool->pool_list[1].tran_alias,5))
     pool->pool_list[1].tran_alias[i].mrn = " "
   ENDFOR
   FOR (j = 1 TO size(pool->pool_list[1].alias,5))
     pool->pool_list[1].alias[i].mrn = " "
   ENDFOR
   stat = alterlist(pool->pool_list[1].tran_alias,0), stat = alterlist(pool->pool_list[1].alias,0),
   mrn_cnt1 = 0,
   mrn_cnt2 = 0, bpooled = "F", btrans = "F"
  HEAD pr1.product_sub_nbr
   row + 0
  HEAD pr1.product_id
   row + 0
  HEAD pr2.product_id
   row + 0
  HEAD pe1.event_type_cd
   IF (pe1.event_type_cd=assign_code)
    IF (pe1.active_ind=1)
     bdisplay = "T"
    ELSE
     bdisplay = "F"
    ENDIF
   ELSE
    bdisplay = "T"
   ENDIF
  HEAD ea.encntr_alias_id
   mrn_alias = cnvtalias(ea.alias,ea.alias_pool_cd)
   IF (pe1.event_type_cd=tran_code)
    IF (encntr_alias_exists="Y")
     bmrnfound = "F"
     IF (mrn_cnt1=0)
      row + 0
     ELSE
      FOR (i = 1 TO mrn_cnt1)
        IF ((pool->pool_list[1].tran_alias[i].mrn=mrn_alias))
         bmrnfound = "T", i = (mrn_cnt1+ 1)
        ENDIF
      ENDFOR
     ENDIF
     IF (bmrnfound="F")
      mrn_cnt1 += 1, stat = alterlist(pool->pool_list[1].tran_alias,mrn_cnt1), pool->pool_list[1].
      tran_alias[mrn_cnt1].mrn = mrn_alias
     ENDIF
    ENDIF
   ELSEIF (pe1.event_type_cd=assign_code)
    IF (encntr_alias_exists="Y")
     bmrnfound = "F"
     IF (mrn_cnt2=0)
      row + 0
     ELSE
      FOR (i = 1 TO mrn_cnt2)
        IF ((pool->pool_list[1].alias[i].mrn=mrn_alias))
         bmrnfound = "T", i = (mrn_cnt2+ 1)
        ENDIF
      ENDFOR
     ENDIF
     IF (bmrnfound="F")
      mrn_cnt2 += 1, stat = alterlist(pool->pool_list[1].alias,mrn_cnt2), pool->pool_list[1].alias[
      mrn_cnt2].mrn = mrn_alias
     ENDIF
    ENDIF
   ENDIF
  DETAIL
   pool_idx += 1
   IF (mod(pool_idx,10)=1
    AND pool_idx != 1)
    stat = alterlist(pool->pool_list,(pool_idx+ 9))
   ENDIF
   pool->pool_list[pool_idx].product_id1 = pr1.product_id, pool->pool_list[pool_idx].product_id2 =
   pr2.product_id, pool->pool_list[pool_idx].event_type_cd1 = pe1.event_type_cd
   IF (pe1.event_type_cd=tran_code)
    pool->pool_list[1].tran_name = per.name_full_formatted, pool->pool_list[1].tran_date = pe1
    .event_dt_tm, pool->pool_list[1].tran_username = prs.username
    IF ((pool->pool_list[1].tran_active_ind != "Y"))
     IF (pe1.active_ind=0)
      pool->pool_list[1].tran_active_ind = "N"
     ELSE
      pool->pool_list[1].tran_active_ind = "Y"
     ENDIF
    ENDIF
   ENDIF
   new_rec = "Y"
   IF ((((pool->pool_list[1].tran_active_ind="Y")) OR ((pool->pool_list[1].tran_active_ind=" "))) )
    IF (first_time="Y"
     AND bdisplay="T")
     event_type_cd_hld[1] = pe1.event_type_cd, event_type_display[1] = c3.display, event_idx = 1,
     new_rec = "Y"
    ELSE
     FOR (y = 1 TO event_idx)
       IF ((pe1.event_type_cd=event_type_cd_hld[y]))
        new_rec = "N"
       ENDIF
     ENDFOR
    ENDIF
    IF (new_rec="Y"
     AND bdisplay="T")
     IF (first_time="Y")
      first_time = "N"
     ELSE
      event_idx += 1
     ENDIF
     event_type_cd_hld[event_idx] = pe1.event_type_cd, event_type_display[event_idx] = c3.display
    ENDIF
   ENDIF
   pool->pool_list[pool_idx].product_nbr1 = concat(trim(bp1.supplier_prefix),trim(pr1.product_nbr)),
   pool->pool_list[pool_idx].product_sub_nbr1 = pr1.product_sub_nbr, pool->pool_list[pool_idx].
   product_nbr2 = concat(trim(bp2.supplier_prefix),trim(pr2.product_nbr)),
   pool->pool_list[pool_idx].product_sub_nbr2 = pr2.product_sub_nbr, pool->pool_list[pool_idx].
   product_type1 = c1.display, pool->pool_list[pool_idx].product_type2 = c2.display,
   pool->pool_list[pool_idx].abo1 = bp1.cur_abo_cd, pool->pool_list[pool_idx].rh1 = bp1.cur_rh_cd,
   pool->pool_list[pool_idx].abo2 = bp2.cur_abo_cd,
   pool->pool_list[pool_idx].rh2 = bp2.cur_rh_cd, pool->pool_list[pool_idx].status1 = c3.display,
   pool->pool_list[pool_idx].status2 = c4.display,
   pool->pool_list[pool_idx].recv_dt_tm1 = pr1.recv_dt_tm, pool->pool_list[pool_idx].recv_dt_tm2 =
   pr2.recv_dt_tm
   IF (pet.event_type_cd=pool_code)
    pool->pool_list[1].pool_dt_tm = pet.event_dt_tm
   ENDIF
   pool->pool_list[pool_idx].volume1 = bp1.cur_volume, pool->pool_list[pool_idx].volume2 = bp2
   .orig_volume, pool->pool_list[pool_idx].exp_dt_tm1 = pr1.cur_expire_dt_tm,
   pool->pool_list[pool_idx].exp_dt_tm2 = pr2.cur_expire_dt_tm, pool->pool_list[pool_idx].username =
   prs.username
   IF (ea.alias > " "
    AND pe1.event_type_cd=assign_code)
    pool->pool_list[1].name = per.name_full_formatted
   ENDIF
  FOOT  pr1.product_id
   stat = alterlist(pool->pool_list,pool_idx)
   IF (row > 56)
    BREAK
   ENDIF
   product1_display = concat(trim(pool->pool_list[1].product_nbr1)," ",trim(pool->pool_list[1].
     product_sub_nbr1)), col 1, product1_display,
   col 47, pool->pool_list[1].product_type1, col 65,
   "                  ", idx_a = 1, finish_flag = "N"
   WHILE (idx_a <= aborh_index
    AND finish_flag="N")
     IF ((pool->pool_list[1].abo1=aborh->aborh_list[idx_a].abo_code)
      AND (pool->pool_list[1].rh1=aborh->aborh_list[idx_a].rh_code))
      col 65, aborh->aborh_list[idx_a].aborh_display"####################", finish_flag = "Y"
     ELSE
      idx_a += 1
     ENDIF
   ENDWHILE
   vol = trim(cnvtstring(pool->pool_list[1].volume1,6,1,r)), col 108, vol,
   rowvar = row, dt_tm = cnvtdatetime(pool->pool_list[1].exp_dt_tm1), col 115,
   dt_tm"@DATECONDENSED;;d", row + 1, col 115,
   dt_tm"@TIMENOSECONDS;;M", row rowvar
   FOR (x = 1 TO event_idx)
     IF ((event_type_cd_hld[x] != pool_code))
      col 86, event_type_display[x], row + 1
      IF (row > 56)
       BREAK
      ENDIF
     ENDIF
   ENDFOR
   row + 1, first_time = "Y"
   FOR (x = 1 TO pool_idx)
     IF (first_time="Y")
      first_time = "N", new_rec = "Y", component_hold = pool->pool_list[x].product_id2
     ELSE
      IF ((component_hold=pool->pool_list[x].product_id2))
       new_rec = "N"
      ELSE
       new_rec = "Y", component_hold = pool->pool_list[x].product_id2
      ENDIF
     ENDIF
     IF (row > 56)
      BREAK
     ENDIF
     IF (new_rec="Y"
      AND (pool->pool_list[x].product_id2 > 0.0))
      product2_display = concat(trim(pool->pool_list[x].product_nbr2)," ",trim(pool->pool_list[x].
        product_sub_nbr2)), col 24, product2_display,
      col 47, pool->pool_list[x].product_type2, col 65,
      "                  ", idx_a = 1, finish_flag = "N"
      WHILE (idx_a <= aborh_index
       AND finish_flag="N")
        IF ((pool->pool_list[x].abo2=aborh->aborh_list[idx_a].abo_code)
         AND (pool->pool_list[x].rh2=aborh->aborh_list[idx_a].rh_code))
         col 65, aborh->aborh_list[idx_a].aborh_display"####################", finish_flag = "Y"
        ELSE
         idx_a += 1
        ENDIF
      ENDWHILE
      vol = trim(cnvtstring(pool->pool_list[x].volume2,6,1,r)), col 108, vol,
      col 86, pool->pool_list[x].status2, dt_tm = cnvtdatetime(pool->pool_list[x].recv_dt_tm2),
      col 97, dt_tm"@DATECONDENSED;;d", dt_tm = cnvtdatetime(pool->pool_list[x].exp_dt_tm2),
      col 115, dt_tm"@DATECONDENSED;;d", row + 1,
      dt_tm = cnvtdatetime(pool->pool_list[x].recv_dt_tm2), col 97, dt_tm"@TIMENOSECONDS;;M",
      dt_tm = cnvtdatetime(pool->pool_list[x].exp_dt_tm2), col 115, dt_tm"@TIMENOSECONDS;;M",
      row + 1
      IF (row > 56)
       BREAK
      ENDIF
     ENDIF
   ENDFOR
   col 1, captions->assigned_to
   IF ((pool->pool_list[1].name > " "))
    col 18, pool->pool_list[1].name, bpooled = "T"
   ELSE
    col 18, captions->none
   ENDIF
   col 46, captions->mrn
   IF (size(pool->pool_list[1].alias,5) > 0)
    FOR (i = 1 TO mrn_cnt2)
      IF (i > 1)
       row + 1
      ENDIF
      col 52, pool->pool_list[1].alias[i].mrn
    ENDFOR
   ELSE
    IF (bpooled="T")
     col 52, captions->not_on_file
    ELSE
     col 52, captions->not_applicable
    ENDIF
   ENDIF
   col 86, captions->modified, dt_tm = cnvtdatetime(pool->pool_list[1].pool_dt_tm),
   col 95, dt_tm"@DATECONDENSED;;d", col 103,
   dt_tm"@TIMENOSECONDS;;M", col 109, captions->tech_id,
   col 118, pool->pool_list[1].username, row + 1
   IF (row > 56)
    BREAK
   ENDIF
   col 1, captions->transfused_to
   IF ((pool->pool_list[1].tran_active_ind="Y"))
    col 18, pool->pool_list[1].tran_name"###########################", btrans = "T"
   ELSE
    col 18, captions->not_transfused
   ENDIF
   col 46, captions->mrn
   IF ((pool->pool_list[1].tran_active_ind="Y"))
    IF (size(pool->pool_list[1].tran_alias,5) > 0)
     FOR (i = 1 TO mrn_cnt1)
       IF (i > 1)
        row + 1
       ENDIF
       col 52, pool->pool_list[1].tran_alias[i].mrn
     ENDFOR
    ENDIF
   ELSE
    IF (btrans="T")
     col 52, captions->not_on_file
    ELSE
     col 52, captions->not_applicable
    ENDIF
   ENDIF
   col 84, captions->transfused
   IF ((pool->pool_list[1].tran_active_ind="Y"))
    dt_tm = cnvtdatetime(pool->pool_list[1].tran_date), col 95, dt_tm"@DATECONDENSED;;d",
    col 103, dt_tm"@TIMENOSECONDS;;M"
   ELSE
    col 95, captions->not_applicable
   ENDIF
   col 109, captions->tech_id
   IF ((pool->pool_list[1].tran_active_ind="Y"))
    col 118, pool->pool_list[1].username
   ELSE
    col 118, captions->not_applicable
   ENDIF
   row + 3
   IF (row > 56)
    BREAK
   ENDIF
   stat = alterlist(pool->pool_list,0), stat = alterlist(pool->pool_list,10), pool_idx = 0
   FOR (x = 1 TO 10)
     event_type_cd_hld[x] = 0.0
   ENDFOR
   first_time = "Y"
  FOOT PAGE
   row 57, col 1, line,
   row + 1, col 1, captions->report_id,
   col 58, captions->page_no, col 64,
   curpage"###", col 100, captions->printed,
   col 110, curdate"@DATECONDENSED;;d", col 120,
   curtime"@TIMENOSECONDS;;M"
  FOOT REPORT
   row 60, col 51, captions->end_of_report,
   select_ok_ind = 1
  WITH counter, nullreport, maxrow = 61,
   outerjoin(d1), outerjoin(d2), dontcare(ea),
   compress, nolandscape
 ;end select
 SET rpt_cnt += 1
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF ((request->batch_selection > " "))
  SET spool value(reply->rpt_list[rpt_cnt].rpt_filename) value(request->printer_name)
 ENDIF
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
