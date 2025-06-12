CREATE PROGRAM bbt_rpt_auto_dir:dba
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
   1 rpt_autologous = vc
   1 time = vc
   1 as_of_date = vc
   1 by_patient_name = vc
   1 by_medical_rec_no = vc
   1 by_expected_use_dt = vc
   1 individual_patient = vc
   1 beg_date = vc
   1 end_date = vc
   1 bb_owner = vc
   1 inventory_area = vc
   1 name = vc
   1 mrn = vc
   1 date = vc
   1 ssn = vc
   1 physician = vc
   1 not_on_file = vc
   1 product = vc
   1 aborh = vc
   1 product_type = vc
   1 type = vc
   1 expires = vc
   1 use_on = vc
   1 states = vc
   1 donor_name = vc
   1 report_id = vc
   1 page_no = vc
   1 printed = vc
   1 end_of_report = vc
   1 all = vc
 )
 SET captions->rpt_autologous = uar_i18ngetmessage(i18nhandle,"rpt_autologous",
  "A U T O L O G O U S / D I R E C T E D   U N I T S")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","Time:")
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","As of Date:")
 SET captions->by_patient_name = uar_i18ngetmessage(i18nhandle,"by_patient_name","(by Patient Name)")
 SET captions->by_medical_rec_no = uar_i18ngetmessage(i18nhandle,"by_medical_rec_no",
  "(by Medical Record Number)")
 SET captions->by_expected_use_dt = uar_i18ngetmessage(i18nhandle,"by_expected_use_dt",
  "(by Expected Usage Date)")
 SET captions->individual_patient = uar_i18ngetmessage(i18nhandle,"individual_patient",
  "(Individual Patient)")
 SET captions->beg_date = uar_i18ngetmessage(i18nhandle,"beg_date","Beginning Date:")
 SET captions->end_date = uar_i18ngetmessage(i18nhandle,"end_date","Ending Date:")
 SET captions->bb_owner = uar_i18ngetmessage(i18nhandle,"bb_owner","Blood Bank Owner: ")
 SET captions->inventory_area = uar_i18ngetmessage(i18nhandle,"inventory_area","Inventory Area: ")
 SET captions->name = uar_i18ngetmessage(i18nhandle,"name","Name:")
 SET captions->mrn = uar_i18ngetmessage(i18nhandle,"mrn","MRN:")
 SET captions->date = uar_i18ngetmessage(i18nhandle,"date","Date")
 SET captions->ssn = uar_i18ngetmessage(i18nhandle,"ssn","SSN:")
 SET captions->physician = uar_i18ngetmessage(i18nhandle,"physician","Physician:")
 SET captions->not_on_file = uar_i18ngetmessage(i18nhandle,"not_on_file","<Not on File>")
 SET captions->product = uar_i18ngetmessage(i18nhandle,"product","Product")
 SET captions->aborh = uar_i18ngetmessage(i18nhandle,"aborh","ABO/Rh")
 SET captions->product_type = uar_i18ngetmessage(i18nhandle,"product_type","Product Type")
 SET captions->type = uar_i18ngetmessage(i18nhandle,"type","Type")
 SET captions->expires = uar_i18ngetmessage(i18nhandle,"expires","Expires")
 SET captions->use_on = uar_i18ngetmessage(i18nhandle,"use_on","Use on")
 SET captions->states = uar_i18ngetmessage(i18nhandle,"states","States")
 SET captions->donor_name = uar_i18ngetmessage(i18nhandle,"donor_name","Donor Name:")
 SET captions->report_id = uar_i18ngetmessage(i18nhandle,"report_id","Report ID: BBT_RPT_AUTO_DIR")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->all = uar_i18ngetmessage(i18nhandle,"all","(All)")
 IF (trim(request->batch_selection) > " ")
  SET request->patient_selection = 0
  SET request->sort_selection = 0
  SET begday = request->ops_date
  SET endday = request->ops_date
  SET temp_string = cnvtupper(trim(request->batch_selection))
  CALL check_opt_date_passed("bbt_rpt_auto_dir")
  IF ((reply->status_data.status != "F"))
   SET request->beg_dt_tm = begday
   SET request->end_dt_tm = endday
  ENDIF
  CALL check_owner_cd("bbt_rpt_auto_dir")
  CALL check_inventory_cd("bbt_rpt_auto_dir")
  CALL check_location_cd("bbt_rpt_auto_dir")
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
 DECLARE get_code_value(sub_code_set,sub_cdf_meaning) = f8
 SUBROUTINE get_code_value(sub_code_set,sub_cdf_meaning)
   SET gsub_code_value = 0.0
   SET cdf_meaning = fillstring(12," ")
   SET cdf_meaning = sub_cdf_meaning
   SET stat = uar_get_meaning_by_codeset(sub_code_set,cdf_meaning,1,gsub_code_value)
   RETURN(gsub_code_value)
 END ;Subroutine
 SET select_ok_ind = 0
 SET rpt_cnt = 0
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
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET line = fillstring(125,"_")
 SET idx = 0
 SET mrn_code = 0.0
 SET ssn_code = 0.0
 SET match_found = "N"
 SET first_time = "Y"
 SET auto_flag = "N"
 SET dir_flag = "N"
 SET display_record = "Y"
 SET donor_name = "                "
 SET first_patient = "Y"
 RECORD event_states(
   1 state_list[*]
     2 state_val = f8
     2 state_display = c12
     2 state_flag = c1
 )
 SET stat = alterlist(event_states->state_list,10)
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=1610
  DETAIL
   idx += 1
   IF (mod(idx,10)=1
    AND idx != 1)
    stat = alterlist(event_states->state_list,(idx+ 9))
   ENDIF
   event_states->state_list[idx].state_val = c.code_value, event_states->state_list[idx].
   state_display = c.display
  FOOT REPORT
   stat = alterlist(event_states->state_list,idx)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname =
  "get product_event codes and dispalys"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_auto_dir"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = build(
   "could not get product_event codes and displays")
  GO TO exit_script
 ENDIF
 SET rec_cnt = 0
 SET mrn_code = 0.0
 SET mrn_code = get_code_value(4,"MRN")
 SET ssn_code = 0.0
 SET ssn_code = get_code_value(4,"SSN")
 IF (((mrn_code=0.0) OR (ssn_code=0.0)) )
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get MRN and SSN type codes"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_auto_dir"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = build(
   "could not retrieve MRN or SSN type codes")
  GO TO exit_script
 ENDIF
 DECLARE dispose_code = f8
 DECLARE transfuse_code = f8
 DECLARE auto_code = f8
 DECLARE dir_code = f8
 DECLARE destroy_code = f8
 DECLARE auto_display = vc
 DECLARE dir_display = vc
 SET dispose_code = 0.0
 SET dispose_code = get_code_value(1610,"5")
 SET transfuse_code = 0.0
 SET transfuse_code = get_code_value(1610,"7")
 SET auto_code = 0.0
 SET auto_code = get_code_value(1610,"10")
 SET auto_display = fillstring(10," ")
 SET auto_display = uar_get_code_display(auto_code)
 SET dir_code = 0.0
 SET dir_code = get_code_value(1610,"11")
 SET dir_display = fillstring(10," ")
 SET dir_display = uar_get_code_display(dir_code)
 SET destroy_code = 0.0
 SET destroy_code = get_code_value(1610,"14")
 IF (((dispose_code=0.0) OR (((transfuse_code=0.0) OR (((auto_code=0.0) OR (((dir_code=0.0) OR (
 destroy_code=0.0)) )) )) )) )
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get product_event code_values"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_auto_dir"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = build(
   "could not retrieve Autologous, Directed, Transfused, Disposed or Destroyed code_vaules")
  GO TO exit_script
 ENDIF
 RECORD aborh(
   1 aborh_list[*]
     2 aborh_display = c15
     2 abo_code = f8
     2 rh_code = f8
 )
 SET stat = alterlist(aborh->aborh_list,10)
 SET aborh_index = 0
 SELECT INTO "nl:"
  abo_field_value = substring(1,20,cve1.field_value), rh_field_value = substring(1,20,cve2
   .field_value)
  FROM code_value cv1,
   code_value_extension cve1,
   code_value_extension cve2
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
  DETAIL
   aborh_index += 1
   IF (mod(aborh_index,10)=1
    AND aborh_index != 1)
    stat = alterlist(aborh->aborh_list,(aborh_index+ 9))
   ENDIF
   aborh->aborh_list[aborh_index].aborh_display = cv1.display, aborh->aborh_list[aborh_index].
   abo_code = cnvtreal(cve1.field_value), aborh->aborh_list[aborh_index].rh_code = cnvtreal(cve2
    .field_value)
  FOOT REPORT
   stat = alterlist(aborh->aborh_list,aborh_index)
  WITH outerjoin(d1), outerjoin(d2), check,
   nocounter
 ;end select
 IF (curqual=0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get ABORh displays and code_values"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_auto_dir"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = build(
   "could not get ABORh code vaules")
  GO TO exit_script
 ENDIF
 RECORD alias(
   1 person_alias[*]
     2 mrn = vc
 )
 RECORD product(
   1 person_products[*]
     2 display_record_flag = c1
     2 product_id = f8
     2 prod_nbr_display = vc
     2 aborh_display = vc
     2 prod_display = vc
     2 auto_flag = c1
     2 dir_flag = c1
     2 auto_dir_display = vc
     2 expire_dt_tm = dq8
     2 expected_dt_tm = dq8
     2 donor_name = vc
     2 states[*]
       3 state_display = vc
 )
 SET admitdoc_code = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "ADMITDOC"
 SET admitdoc_code = get_code_value(333,cdf_meaning)
 EXECUTE cpm_create_file_name_logical "bbt_auto_dir", "txt", "x"
 SELECT
  IF ((((request->patient_selection=0)
   AND (request->sort_selection=0)) OR ((request->patient_selection > 0))) )
   ORDER BY name_full_formatted, per.person_id, mrn_alias,
    pra.person_alias_id, pe.product_id, pe.product_event_id
  ELSEIF ((request->patient_selection=0)
   AND (request->sort_selection=1))
   ORDER BY mrn_alias, pra.person_alias_id, name_full_formatted,
    per.person_id, pe.product_id, pe.product_event_id
  ELSEIF ((request->patient_selection=0)
   AND (request->sort_selection=2))
   ORDER BY cnvtdatetime(ad.expected_usage_dt_tm), name_full_formatted, per.person_id,
    mrn_alias, pra.person_alias_id, pe.product_id,
    pe.product_event_id
  ELSE
  ENDIF
  INTO cpm_cfn_info->file_name_logical
  name_full_formatted = substring(1,27,per.name_full_formatted), ad.person_id, per.person_id,
  pra.person_id, per_pra_id = decode(pra.person_alias_id,build(per.person_id,pra.person_alias_id),
   build(per.person_id)), mrn_alias = cnvtalias(pra.alias,pra.alias_pool_cd),
  ssn_alias = cnvtalias(pra2.alias,pra2.alias_pool_cd), person_alias_exists = decode(pra.seq,build(
    pra.person_alias_id),"0.0"), pra2.person_alias_id,
  per2.person_id, pe.product_id, pe.event_type_cd,
  pr.product_nbr, pe.product_event_id, c3.display,
  pr.cur_expire_dt_tm, bp.supplier_prefix, prod_display = uar_get_code_display(bp.product_cd)
  FROM product_event pe,
   product pr,
   blood_product bp,
   code_value c3,
   auto_directed ad,
   person per,
   (dummyt d2  WITH seq = 1),
   person_alias pra,
   (dummyt d4  WITH seq = 1),
   person_alias pra2,
   (dummyt d3  WITH seq = 1),
   encntr_prsnl_reltn epr,
   person per2
  PLAN (ad
   WHERE ad.active_ind=1
    AND ad.product_id != null
    AND ad.product_id > 0
    AND ad.person_id != null
    AND ad.person_id > 0
    AND cnvtdatetime(request->beg_dt_tm) <= ad.expected_usage_dt_tm
    AND cnvtdatetime(request->end_dt_tm) >= ad.expected_usage_dt_tm
    AND (((request->patient_selection=0)) OR ((request->patient_selection > 0)
    AND (ad.person_id=request->patient_selection))) )
   JOIN (pe
   WHERE pe.product_id=ad.product_id
    AND pe.active_ind=1)
   JOIN (pr
   WHERE pr.product_id=ad.product_id
    AND (((request->cur_owner_area_cd > 0.0)
    AND (request->cur_owner_area_cd=pr.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
    AND (((request->cur_inv_area_cd > 0.0)
    AND (request->cur_inv_area_cd=pr.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
   JOIN (bp
   WHERE bp.product_id=ad.product_id)
   JOIN (c3
   WHERE c3.code_set=1604
    AND c3.code_value=bp.product_cd)
   JOIN (per
   WHERE per.person_id=ad.person_id)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (pra
   WHERE pra.person_id=ad.person_id
    AND pra.person_alias_type_cd=mrn_code
    AND pra.active_ind=1
    AND pra.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pra.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (d4
   WHERE d4.seq=1)
   JOIN (pra2
   WHERE pra2.person_id=ad.person_id
    AND pra2.person_alias_type_cd=ssn_code
    AND pra2.active_ind=1
    AND pra2.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND pra2.end_effective_dt_tm >= cnvtdatetime(sysdate))
   JOIN (d3
   WHERE d3.seq=1)
   JOIN (epr
   WHERE epr.encntr_prsnl_r_cd=admitdoc_code
    AND epr.encntr_id=ad.encntr_id
    AND ad.encntr_id != null
    AND ad.encntr_id > 0)
   JOIN (per2
   WHERE epr.prsnl_person_id=per2.person_id
    AND epr.prsnl_person_id != null
    AND epr.prsnl_person_id > 0)
  HEAD REPORT
   beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm),
   select_ok_ind = 0,
   mrn_cnt = 0, bmrnfound = "F", prod_cnt = 0,
   bprodfound = "F", count = 0
  HEAD PAGE
   CALL center(captions->rpt_autologous,1,125), col 104, captions->time,
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
   save_row = row, row 1
   IF ((request->patient_selection=0)
    AND (request->sort_selection=0))
    CALL center(captions->by_patient_name,1,125)
   ELSEIF ((request->patient_selection=0)
    AND (request->sort_selection=1))
    CALL center(captions->by_medical_rec_no,1,125)
   ELSEIF ((request->patient_selection=0)
    AND (request->sort_selection=2))
    CALL center(captions->by_expected_use_dt,1,125)
   ELSEIF ((request->patient_selection > 0))
    CALL center(captions->individual_patient,1,125)
   ENDIF
   row save_row, row + 1, col 30,
   captions->beg_date, col 46, beg_dt_tm"@DATETIMECONDENSED;;d",
   col 69, captions->end_date, col 82,
   end_dt_tm"@DATETIMECONDENSED;;d", row + 1, col 1,
   captions->bb_owner, col 19, cur_owner_area_disp,
   row + 1, col 1, captions->inventory_area,
   col 17, cur_inv_area_disp, row + 2,
   col 3, captions->product, col 29,
   captions->aborh, col 46, captions->product_type,
   col 77, captions->type, col 89,
   captions->expires, col 104, captions->use_on,
   col 114, captions->states, row + 1,
   line1 = fillstring(24,"-"), col 3, line1,
   line2 = fillstring(15,"-"), col 29, line2,
   line3 = fillstring(29,"-"), col 46, line3,
   line4 = fillstring(10,"-"), col 77, line4,
   line5 = fillstring(13,"-"), col 89, line5,
   line6 = fillstring(8,"-"), col 104, line6,
   line7 = fillstring(12,"-"), col 114, line7,
   row + 1
  HEAD per.person_id
   IF (per.person_id > 0)
    patient_printed_ind = "N", person_name = substring(1,27,per.name_full_formatted), person_ssn =
    substring(1,15,ssn_alias),
    admit_physician = substring(1,30,per2.name_full_formatted)
   ENDIF
   FOR (i = 1 TO size(alias->person_alias,5))
     alias->person_alias[i].mrn = " "
   ENDFOR
   mrn_cnt = 0
   IF (size(product->person_products,5) > 0)
    FOR (j = 1 TO size(product->person_products,5))
      product->person_products[j].display_record_flag = " ", product->person_products[j].
      prod_nbr_display = " ", product->person_products[j].product_id = 0.0,
      product->person_products[j].donor_name = " ", product->person_products[j].aborh_display = " ",
      product->person_products[j].auto_dir_display = " ",
      product->person_products[j].auto_flag = " ", product->person_products[j].dir_flag = " ",
      product->person_products[j].expected_dt_tm = cnvtdatetime(0.0),
      product->person_products[j].expire_dt_tm = cnvtdatetime(0.0), product->person_products[j].
      prod_display = " "
      IF (size(product->person_products[j].states,5) > 0)
       FOR (i = 1 TO size(product->person_products[j].states,5))
         product->person_products[j].states[i].state_display = " "
       ENDFOR
      ENDIF
      stat = alterlist(product->person_products[j].states,0)
    ENDFOR
    stat = alterlist(product->person_products,0), prod_cnt = 0
   ENDIF
  HEAD pe.product_id
   first_time = "Y"
   FOR (x = 1 TO idx)
     event_states->state_list[x].state_flag = " "
   ENDFOR
   IF (pe.product_id > 0.0)
    prod_nbr_display = concat(trim(bp.supplier_prefix),trim(pr.product_nbr)," ",trim(pr
      .product_sub_nbr)), bprodfound = "F"
    IF (prod_cnt=0)
     row + 0
    ELSE
     FOR (j = 1 TO prod_cnt)
       IF ((product->person_products[j].product_id=pe.product_id))
        bprodfound = "T", j = (prod_cnt+ 1)
       ENDIF
     ENDFOR
    ENDIF
    IF (bprodfound="F")
     prod_cnt += 1, product_display = substring(1,29,prod_display), expire_dt_tm = cnvtdatetime(pr
      .cur_expire_dt_tm),
     stat = alterlist(product->person_products,prod_cnt), product->person_products[prod_cnt].
     prod_nbr_display = prod_nbr_display, product->person_products[prod_cnt].product_id = pe
     .product_id,
     product->person_products[prod_cnt].prod_display = product_display, product->person_products[
     prod_cnt].display_record_flag = "Y", product->person_products[prod_cnt].expire_dt_tm =
     expire_dt_tm,
     product->person_products[prod_cnt].expected_dt_tm = ad.expected_usage_dt_tm
    ENDIF
   ENDIF
  HEAD pe.product_event_id
   row + 0
  DETAIL
   IF (person_alias_exists != "0.0")
    bmrnfound = "F"
    IF (mrn_cnt=0)
     row + 0
    ELSE
     FOR (i = 1 TO mrn_cnt)
       IF ((alias->person_alias[i].mrn=mrn_alias))
        bmrnfound = "T", i = (mrn_cnt+ 1)
       ENDIF
     ENDFOR
    ENDIF
    IF (bmrnfound="F")
     mrn_cnt += 1, stat = alterlist(alias->person_alias,mrn_cnt), alias->person_alias[mrn_cnt].mrn =
     mrn_alias
    ENDIF
   ENDIF
  FOOT  pe.product_event_id
   match_found = "N", x = 1
   IF ((pe.product_id=product->person_products[prod_cnt].product_id))
    WHILE (x <= idx
     AND match_found="N")
      IF ((pe.event_type_cd=event_states->state_list[x].state_val))
       event_states->state_list[x].state_flag = "Y", match_found = "Y"
       IF (pe.event_type_cd=auto_code)
        auto_flag = "Y", dir_flag = "N", product->person_products[prod_cnt].auto_flag = "Y",
        product->person_products[prod_cnt].dir_flag = "N"
       ELSEIF (pe.event_type_cd=dir_code)
        dir_flag = "Y", auto_flag = "N", product->person_products[prod_cnt].dir_flag = "Y",
        product->person_products[prod_cnt].auto_flag = "N"
       ENDIF
       IF (((pe.event_type_cd=destroy_code) OR (((pe.event_type_cd=dispose_code) OR (pe.event_type_cd
       =transfuse_code)) )) )
        product->person_products[prod_cnt].display_record_flag = "N"
       ENDIF
      ELSE
       x += 1
      ENDIF
    ENDWHILE
   ENDIF
  FOOT  pe.product_id
   IF ((product->person_products[prod_cnt].display_record_flag="Y"))
    IF ((((product->person_products[prod_cnt].auto_flag="Y")) OR ((product->person_products[prod_cnt]
    .dir_flag="Y"))) )
     idx_a = 1, finish_flag = "N"
     WHILE (idx_a <= aborh_index
      AND finish_flag="N")
       IF ((bp.cur_abo_cd=aborh->aborh_list[idx_a].abo_code)
        AND (bp.cur_rh_cd=aborh->aborh_list[idx_a].rh_code))
        product->person_products[prod_cnt].aborh_display = aborh->aborh_list[idx_a].aborh_display,
        finish_flag = "Y"
       ELSE
        idx_a += 1
       ENDIF
     ENDWHILE
     IF ((product->person_products[prod_cnt].auto_flag="Y"))
      product->person_products[prod_cnt].auto_dir_display = auto_display
     ELSEIF ((product->person_products[prod_cnt].dir_flag="Y"))
      product->person_products[prod_cnt].auto_dir_display = dir_display
     ENDIF
     count = 0
     FOR (x = 1 TO idx)
       IF ((event_states->state_list[x].state_flag="Y")
        AND (event_states->state_list[x].state_val != auto_code)
        AND (event_states->state_list[x].state_val != dir_code))
        count += 1, stat = alterlist(product->person_products[prod_cnt].states,count), product->
        person_products[prod_cnt].states[count].state_display = event_states->state_list[x].
        state_display
       ENDIF
     ENDFOR
    ENDIF
   ENDIF
  FOOT  per.person_id
   FOR (jdx = 1 TO prod_cnt)
     IF ((product->person_products[jdx].display_record_flag="Y"))
      IF (patient_printed_ind="N")
       IF (first_patient="Y")
        row + 0, first_patient = "N"
       ELSE
        row + 2
       ENDIF
       IF (row > 55)
        BREAK
       ENDIF
       IF ((((request->patient_selection=0)
        AND (request->sort_selection=0)) OR ((request->patient_selection > 0))) )
        col 0, captions->name, col 35,
        captions->mrn, col 61, captions->ssn,
        col 84, captions->physician
        IF (trim(person_name) > "")
         col 6, person_name
        ELSE
         col 6, captions->not_on_file
        ENDIF
        IF (trim(person_ssn) > "")
         col 66, person_ssn
        ELSE
         col 66, captions->not_on_file
        ENDIF
        IF (trim(admit_physician) > "")
         col 95, admit_physician
        ELSE
         col 95, captions->not_on_file
        ENDIF
        IF (mrn_cnt < 2)
         IF (trim(alias->person_alias[1].mrn) > "")
          col 40, alias->person_alias[1].mrn
         ELSE
          col 40, captions->not_on_file
         ENDIF
        ELSE
         FOR (i = 1 TO mrn_cnt)
          IF (i > 1)
           row + 1
           IF (row > 56)
            BREAK
           ENDIF
          ENDIF
          ,
          IF (trim(alias->person_alias[i].mrn) > "")
           col 40, alias->person_alias[i].mrn
          ENDIF
         ENDFOR
        ENDIF
       ELSEIF ((request->patient_selection=0)
        AND (request->sort_selection=1))
        col 0, captions->mrn, col 27,
        captions->name, col 61, captions->ssn,
        col 84, captions->physician
        IF (trim(person_name) > "")
         col 33, person_name
        ELSE
         col 33, captions->not_on_file
        ENDIF
        IF (trim(person_ssn) > "")
         col 66, person_ssn
        ELSE
         col 66, captions->not_on_file
        ENDIF
        IF (trim(admit_physician) > "")
         col 95, admit_physician
        ELSE
         col 95, captions->not_on_file
        ENDIF
        IF (mrn_cnt < 2)
         IF (trim(alias->person_alias[1].mrn) > "")
          col 5, alias->person_alias[1].mrn
         ELSE
          col 5, captions->not_on_file
         ENDIF
        ELSE
         FOR (i = 1 TO mrn_cnt)
          IF (i > 1)
           row + 1
           IF (row > 56)
            BREAK
           ENDIF
          ENDIF
          ,
          IF (trim(alias->person_alias[i].mrn) > "")
           col 5, alias->person_alias[i].mrn
          ENDIF
         ENDFOR
        ENDIF
       ELSEIF ((request->patient_selection=0)
        AND (request->sort_selection=2))
        col 0, captions->date, col 27,
        captions->name, col 61, captions->ssn,
        col 84, captions->physician
        IF (ad.expected_usage_dt_tm != null)
         col 6, ad.expected_usage_dt_tm"@DATECONDENSED;;d"
        ELSE
         col 6, captions->not_on_file
        ENDIF
        IF (trim(person_name) > "")
         col 33, person_name
        ELSE
         col 33, captions->not_on_file
        ENDIF
        IF (trim(person_ssn) > "")
         col 66, person_ssn
        ELSE
         col 66, captions->not_on_file
        ENDIF
        IF (trim(admit_physician) > "")
         col 95, admit_physician
        ELSE
         col 95, captions->not_on_file
        ENDIF
       ENDIF
       IF (row > 56)
        BREAK
       ENDIF
       patient_printed_ind = "Y"
      ENDIF
      IF (patient_printed_ind="Y")
       row + 1
      ENDIF
      IF ((((product->person_products[jdx].auto_flag="Y")) OR ((product->person_products[jdx].
      dir_flag="Y"))) )
       IF (row > 56)
        BREAK
       ENDIF
       col 3, product->person_products[jdx].prod_nbr_display, col 29,
       product->person_products[jdx].aborh_display"###############", col 46, product->
       person_products[jdx].prod_display,
       col 77, product->person_products[jdx].auto_dir_display, col 89,
       product->person_products[jdx].expire_dt_tm"@DATETIMECONDENSED;;d", col 104, product->
       person_products[jdx].expected_dt_tm"@DATECONDENSED;;d"
       IF (size(product->person_products[jdx].states,5) > 0)
        FOR (i = 1 TO size(product->person_products[jdx].states,5))
          IF (i=1)
           col 114, product->person_products[jdx].states[i].state_display
          ELSEIF (i > 1)
           row + 1
           IF (row > 56)
            BREAK
           ENDIF
           col 114, product->person_products[jdx].states[i].state_display
          ENDIF
        ENDFOR
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
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
  WITH nocounter, nullreport, dontcare(pra),
   dontcare(pra2), outerjoin(d3), maxrow = 61,
   nolandscape, compress
 ;end select
 IF (curqual=0)
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[count1].operationname = "get ABORh displays and code_values"
  SET reply->status_data.subeventstatus[count1].operationstatus = "F"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_auto_dir"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = build(
   "could not get ABORh code vaules")
 ELSE
  SET count1 += 1
  IF (count1 > 1)
   SET stat = alterlist(reply->status_data.subeventstatus,(count1+ 1))
  ENDIF
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[count1].operationname = "Generate Auto/Dir Report"
  SET reply->status_data.subeventstatus[count1].operationstatus = "S"
  SET reply->status_data.subeventstatus[count1].targetobjectname = "bbt_rpt_auto_dir"
  SET reply->status_data.subeventstatus[count1].targetobjectvalue = build(
   "Report generated successfully")
 ENDIF
 GO TO exit_script
#exit_script
 SET rpt_cnt += 1
 SET stat = alterlist(reply->rpt_list,rpt_cnt)
 SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (trim(request->batch_selection) > "")
  SET spool value(reply->rpt_list[rpt_cnt].rpt_filename) value(request->output_dist)
 ENDIF
 IF (select_ok_ind=1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
