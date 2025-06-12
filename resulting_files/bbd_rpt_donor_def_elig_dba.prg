CREATE PROGRAM bbd_rpt_donor_def_elig:dba
 RECORD reply(
   1 rpt_list[*]
     2 rpt_filename = vc
     2 node = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET stat = alterlist(reply->rpt_list,1)
 RECORD report_info(
   1 donor_list[*]
     2 person_id = f8
     2 name_last = vc
     2 name_first = vc
     2 name_middle = vc
     2 name_full_formatted = vc
     2 birth_dt_tm = dq8
     2 alias_ssn = vc
     2 alias_donor_id = vc
     2 eligibility_type_cd = f8
     2 deferral_contact_id = f8
     2 deferred_dt_tm = dq8
     2 defer_until_dt_tm = dq8
     2 reason_list[*]
       3 reason_disp = vc
       3 reason_defer_dt_tm = dq8
     2 donation_history_list[*]
       3 product_cd = f8
       3 drawn_dt_tm = dq8
     2 eligibility_list[*]
       3 product_cd = f8
       3 product_disp = vc
       3 eligible_dt_tm = dq8
 )
 RECORD product_eligibility(
   1 previous_product_list[*]
     2 previous_product_cd = f8
     2 product_list[*]
       3 product_cd = f8
       3 days_until_eligible = f8
 )
 RECORD captions(
   1 rpt_name = vc
   1 report_date = vc
   1 for_date = vc
   1 report_time = vc
   1 deferral_type = vc
   1 perm_and_temp = vc
   1 temp_only = vc
   1 perm_only = vc
   1 ineligibility = vc
   1 yes = vc
   1 no = vc
   1 donor = vc
   1 donor_id = vc
   1 ssn = vc
   1 or_inelig = vc
   1 date = vc
   1 ineligible = vc
   1 ineligible_lc = vc
   1 products = vc
   1 deferred = vc
   1 defer = vc
   1 until = vc
   1 reasons = vc
   1 end_of_report = vc
   1 page_num = vc
   1 birth_date = vc
 )
 DECLARE setcaptions(null) = null WITH persist
 SUBROUTINE setcaptions(null)
   SET captions->rpt_name = uar_i18ngetmessage(i18nhandle,"rpt_name",
    "DONOR DEFERRAL-INELIGIBILITY REPORT")
   SET captions->report_date = uar_i18ngetmessage(i18nhandle,"report_date","REPORT DATE:")
   SET captions->for_date = uar_i18ngetmessage(i18nhandle,"for_date","FOR DONATION DATE: ")
   SET captions->report_time = uar_i18ngetmessage(i18nhandle,"report_time","REPORT TIME:")
   SET captions->deferral_type = uar_i18ngetmessage(i18nhandle,"deferral_type","DEFERRAL TYPE")
   SET captions->perm_and_temp = uar_i18ngetmessage(i18nhandle,"perm_and_temp",
    "Permanent and Temporary")
   SET captions->perm_only = uar_i18ngetmessage(i18nhandle,"perm_only","Permanent")
   SET captions->temp_only = uar_i18ngetmessage(i18nhandle,"temp_only","Temporary")
   SET captions->ineligibility = uar_i18ngetmessage(i18nhandle,"ineligibility","INELIGIBILITY:")
   SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","Yes")
   SET captions->no = uar_i18ngetmessage(i18nhandle,"no","No")
   SET captions->donor = uar_i18ngetmessage(i18nhandle,"donor","DONOR")
   SET captions->donor_id = uar_i18ngetmessage(i18nhandle,"donor_id","DONOR ID")
   SET captions->ssn = uar_i18ngetmessage(i18nhandle,"ssn","SSN")
   SET captions->or_inelig = uar_i18ngetmessage(i18nhandle,"or_inelig","OR INELIGIBLE")
   SET captions->date = uar_i18ngetmessage(i18nhandle,"date","DATE")
   SET captions->ineligible = uar_i18ngetmessage(i18nhandle,"ineligible","INELIGIBLE")
   SET captions->ineligible_lc = uar_i18ngetmessage(i18nhandle,"ineligible2","Ineligible")
   SET captions->products = uar_i18ngetmessage(i18nhandle,"products","PRODUCTS")
   SET captions->deferred = uar_i18ngetmessage(i18nhandle,"deferred","DEFERRED")
   SET captions->defer = uar_i18ngetmessage(i18nhandle,"defer","DEFER")
   SET captions->until = uar_i18ngetmessage(i18nhandle,"until","UNTIL")
   SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
    "*** End of Report ***")
   SET captions->page_num = uar_i18ngetmessage(i18nhandle,"page_num","Page:")
   SET captions->birth_date = uar_i18ngetmessage(i18nhandle,"birth_date","BIRTH DATE")
 END ;Subroutine
 DECLARE setopsrequest(null) = i2 WITH persist
 SUBROUTINE setopsrequest(null)
   DECLARE temp_string = vc WITH protected, noconstant(" ")
   DECLARE mode_string = vc WITH protected, noconstant(" ")
   DECLARE mode_selection = vc WITH protected, noconstant(" ")
   DECLARE mode_pos = i4 WITH protected, noconstant(0)
   DECLARE temp_pos = i4 WITH protected, noconstant(0)
   SET temp_string = trim(request->batch_selection)
   IF (size(temp_string,1) > 0)
    SET begday = request->ops_date
    SET endday = request->ops_date
    CALL check_opt_date_passed("bbd_rpt_donor_def_elig")
    IF ((reply->status_data.status != "F"))
     SET request->donation_dt_tm = endday
    ENDIF
    CALL check_location_cd("bbd_rpt_donor_def_elig")
    CALL check_deferral_opt(0)
    CALL check_elig_ind(0)
    CALL check_mode_opt("bbd_rpt_donor_def_elig")
    IF (mode_selection="EXPORT")
     SET request->xml_ind = 1
    ELSEIF (mode_selection="REPORT")
     SET request->xml_ind = 0
    ELSE
     SET request->xml_ind = 0
    ENDIF
   ENDIF
   IF ((reply->status_data.status="F"))
    RETURN(0)
   ELSE
    RETURN(1)
   ENDIF
 END ;Subroutine
 DECLARE check_deferral_opt(null) = null WITH persist
 SUBROUTINE check_deferral_opt(null)
   DECLARE def_string = vc WITH protected, noconstant(" ")
   DECLARE def_pos = i4 WITH protected, noconstant(0)
   DECLARE def_selection = vc WITH protected, noconstant(" ")
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("DEF[",temp_string)))
   IF (temp_pos > 0)
    SET def_string = substring((temp_pos+ 4),size(temp_string),temp_string)
    SET def_pos = cnvtint(value(findstring("]",def_string)))
    IF (def_pos > 0)
     SET def_selection = substring(1,(def_pos - 1),def_string)
    ELSE
     SET def_selection = " "
    ENDIF
   ELSE
    SET set_selection = " "
   ENDIF
   IF (def_selection="BOTH")
    SET request->deferral_flag = 0
   ELSEIF (def_selection="PERM")
    SET request->deferral_flag = 1
   ELSEIF (def_selection="TEMP")
    SET request->deferral_flag = 2
   ELSE
    SET request->deferral_flag = 99
   ENDIF
 END ;Subroutine
 DECLARE check_elig_ind(null) = null WITH persist
 SUBROUTINE check_elig_ind(null)
   DECLARE elig_string = vc WITH protected, noconstant(" ")
   DECLARE elig_pos = i4 WITH protected, noconstant(0)
   DECLARE elig_selection = vc WITH protected, noconstant(" ")
   SET temp_pos = 0
   SET temp_pos = cnvtint(value(findstring("INELIG[",temp_string)))
   IF (temp_pos > 0)
    SET elig_string = substring((temp_pos+ 7),size(temp_string),temp_string)
    SET elig_pos = cnvtint(value(findstring("]",elig_string)))
    IF (elig_pos > 0)
     SET elig_selection = substring(1,(elig_pos - 1),elig_string)
     IF (elig_selection="1")
      SET request->ineligibility_ind = 1
     ELSEIF (elig_selection="0")
      SET request->ineligibility_ind = 0
     ELSE
      SET reply->status_data.status = "F"
      SET reply->status_data.subeventstatus[1].operationname = script_name
      SET reply->status_data.subeventstatus[1].operationstatus = "F"
      SET reply->status_data.subeventstatus[1].targetobjectvalue = "Invalid elig param"
      SET reply->status_data.subeventstatus[1].targetobjectname = "Parse eligibility_ind"
      GO TO exit_script
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationname = script_name
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "no elig value in string"
     SET reply->status_data.subeventstatus[1].targetobjectname = "parse eligibility_ind"
     GO TO exit_script
    ENDIF
   ELSE
    SET request->ineligibility_ind = 0.0
   ENDIF
 END ;Subroutine
 DECLARE parse_string(string_to_parse=vc) = vc WITH persist
 SUBROUTINE parse_string(string_to_parse)
   DECLARE string_to_return = vc WITH noconstant("")
   RECORD replaces(
     1 strings[*]
       2 org_str = vc
       2 new_str = vc
   )
   SET stat = alterlist(replaces->strings,5)
   SET replaces->strings[1].org_str = "&"
   SET replaces->strings[1].new_str = "&amp;"
   SET replaces->strings[2].org_str = "<"
   SET replaces->strings[2].new_str = "&lt;"
   SET replaces->strings[3].org_str = ">"
   SET replaces->strings[3].new_str = "&gt;"
   SET replaces->strings[4].org_str = '"'
   SET replaces->strings[4].new_str = "&quot;"
   SET replaces->strings[5].org_str = "'"
   SET replaces->strings[5].new_str = "&#39;"
   SET string_to_return = string_to_parse
   FOR (i = 1 TO size(replaces->strings,5))
     SET string_to_return = replace(string_to_return,replaces->strings[i].org_str,replaces->strings[i
      ].new_str,0)
   ENDFOR
   RETURN(string_to_return)
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
 DECLARE i18nhandle = i4 WITH protected, noconstant(0)
 DECLARE h = i4 WITH protected, noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 CALL setcaptions(null)
 SET modify = nopredeclare
 DECLARE check_facility_cd(script_name=vc) = null
 DECLARE check_exception_type_cd(script_name=vc) = null
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
      SET ddmmyy_flag = (ddmmyy_flag+ 1)
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
       SET ddmmyy_flag = (ddmmyy_flag+ 1)
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
       SET ddmmyy_flag = (ddmmyy_flag+ 1)
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
 SUBROUTINE check_facility_cd(script_name)
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
 SUBROUTINE check_exception_type_cd(script_name)
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
 RECORD dates(
   1 eligibility_dt = dq8
   1 request_dt = dq8
   1 request_dt_hold = dq8
 )
 DECLARE hold_days_until_eligible = i2 WITH noconstant(0)
 DECLARE hold_days_vc = vc WITH noconstant(" ")
 DECLARE person_cnt = i4 WITH noconstant(0)
 DECLARE product_cnt = i4 WITH noconstant(0)
 DECLARE prod_elig_cnt = i4 WITH noconstant(0)
 DECLARE prod_list_cnt = i4 WITH noconstant(0)
 DECLARE person_elig_cnt = i4 WITH noconstant(0)
 DECLARE product_found = i2 WITH noconstant(0)
 DECLARE prev_prod_cd = f8 WITH noconstant(0.0)
 DECLARE prod_cd = f8 WITH noconstant(0.0)
 DECLARE elig_prod_cnt = i4 WITH noconstant(0)
 DECLARE days_until_elig = i4 WITH noconstant(0)
 DECLARE days_to_add = vc WITH noconstant("     ")
 DECLARE i = i4 WITH noconstant(0)
 DECLARE j = i4 WITH noconstant(0)
 DECLARE k = i4 WITH noconstant(0)
 DECLARE m = i4 WITH noconstant(0)
 DECLARE n = i4 WITH noconstant(0)
 DECLARE perm_cdf = c12 WITH constant("PERMNENT")
 DECLARE perm_cd = f8 WITH noconstant(0.0)
 DECLARE deferral_code_set = i4 WITH constant(14237)
 DECLARE temp_cdf = c12 WITH constant("TEMP")
 DECLARE temp_cd = f8 WITH noconstant(0.0)
 DECLARE ssn_cdf = c12 WITH noconstant("SSN")
 DECLARE ssn_cd = f8 WITH noconstant(0.0)
 DECLARE alias_code_set = i4 WITH constant(4)
 DECLARE donorid_cdf = c12 WITH noconstant("DONORID")
 DECLARE donorid_cd = f8 WITH noconstant(0.0)
 DECLARE reason_disp = vc WITH noconstant(fillstring(15," "))
 DECLARE dash_line = vc WITH constant(fillstring(125,"="))
 DECLARE deferral_type = vc WITH noconstant(fillstring(40," "))
 DECLARE deferral_type_head = vc WITH noconstant(fillstring(40," "))
 DECLARE inelig_type_head = vc WITH noconstant(fillstring(40," "))
 DECLARE donation_date_string = vc WITH noconstant(fillstring(40," "))
 DECLARE error_check = i4 WITH noconstant(0)
 DECLARE ermsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE loc_name = vc WITH noconstant("")
 DECLARE address1 = vc WITH noconstant("")
 DECLARE address2 = vc WITH noconstant("")
 DECLARE address3 = vc WITH noconstant("")
 DECLARE address4 = vc WITH noconstant("")
 DECLARE address5 = vc WITH noconstant("")
 SET stat = setopsrequest(0)
 IF (stat=0)
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "F"
 SET stat = uar_get_meaning_by_codeset(deferral_code_set,nullterm(perm_cdf),1,perm_cd)
 IF (stat > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbd_rpt_donor_def_elig"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error getting perm_cd"
  SET reply->status_data.subeventstatus[1].targetobjectname =
  "Error in UAR_GET_MEANING_BY_CODESET(PERM_CD)"
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(deferral_code_set,nullterm(temp_cdf),1,temp_cd)
 IF (stat > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbd_rpt_donor_def_elig"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error getting temp_cd"
  SET reply->status_data.subeventstatus[1].targetobjectname =
  "Error in UAR_GET_MEANING_BY_CODESET(TEMP_CD)"
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(alias_code_set,nullterm(ssn_cdf),1,ssn_cd)
 IF (stat > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbd_rpt_donor_def_elig"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error getting ssn_cd"
  SET reply->status_data.subeventstatus[1].targetobjectname =
  "Error in UAR_GET_MEANING_BY_CODESET(SSN_CD)"
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(alias_code_set,nullterm(donorid_cdf),1,donorid_cd)
 IF (stat > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbd_rpt_donor_def_elig"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error getting donorid_cd"
  SET reply->status_data.subeventstatus[1].targetobjectname =
  "Error in UAR_GET_MEANING_BY_CODESET(DONORID_CD)"
  GO TO exit_script
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
 IF ((request->ineligibility_ind=1))
  SELECT INTO "nl:"
   bpe.previous_product_cd, bpe.product_cd, bpe.days_until_eligible
   FROM bbd_product_eligibility bpe
   PLAN (bpe
    WHERE bpe.product_eligibility_id > 0
     AND bpe.list_ind=1
     AND bpe.active_ind=1)
   ORDER BY bpe.previous_product_cd, bpe.days_until_eligible DESC
   HEAD REPORT
    hold_days_until_eligible = 0, prev_prod_cnt = 0
   HEAD bpe.previous_product_cd
    product_cd_cnt = 0
    IF (bpe.days_until_eligible > hold_days_until_eligible)
     hold_days_until_eligible = bpe.days_until_eligible
    ENDIF
    prev_prod_cnt = (prev_prod_cnt+ 1)
    IF (size(product_eligibility->previous_product_list,5) < prev_prod_cnt)
     stat = alterlist(product_eligibility->previous_product_list,(prev_prod_cnt+ 9))
    ENDIF
    product_eligibility->previous_product_list[prev_prod_cnt].previous_product_cd = bpe
    .previous_product_cd
   DETAIL
    product_cd_cnt = (product_cd_cnt+ 1)
    IF (size(product_eligibility->previous_product_list[prev_prod_cnt].product_list,5) <
    product_cd_cnt)
     stat = alterlist(product_eligibility->previous_product_list[prev_prod_cnt].product_list,(
      product_cd_cnt+ 9))
    ENDIF
    product_eligibility->previous_product_list[prev_prod_cnt].product_list[product_cd_cnt].product_cd
     = bpe.product_cd, product_eligibility->previous_product_list[prev_prod_cnt].product_list[
    product_cd_cnt].days_until_eligible = bpe.days_until_eligible
   FOOT  bpe.previous_product_cd
    stat = alterlist(product_eligibility->previous_product_list[prev_prod_cnt].product_list,
     product_cd_cnt)
   FOOT REPORT
    stat = alterlist(product_eligibility->previous_product_list,prev_prod_cnt)
   WITH nocounter
  ;end select
  SET error_check = error(ermsg,0)
  IF (error_check != 0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "bbd_rpt_donor_def_elig"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = ermsg
   SET reply->status_data.subeventstatus[1].targetobjectname = "Select eligibility info"
   GO TO exit_script
  ENDIF
  IF (size(product_eligibility->previous_product_list,5) > 0)
   SET dates->request_dt_hold = request->donation_dt_tm
   SET hold_days_vc = build(hold_days_until_eligible,",D")
   SET dates->request_dt_hold = cnvtlookbehind(hold_days_vc,dates->request_dt_hold)
   SELECT INTO "nl:"
    bdr.person_id, pr.product_cd, bdr.drawn_dt_tm
    FROM bbd_donation_results bdr,
     bbd_don_product_r bdp,
     product pr
    PLAN (bdr
     WHERE bdr.drawn_dt_tm > cnvtdatetime(dates->request_dt_hold)
      AND bdr.active_ind=1)
     JOIN (bdp
     WHERE bdp.donation_results_id=bdr.donation_result_id
      AND bdp.active_ind=1)
     JOIN (pr
     WHERE pr.product_id=bdp.product_id)
    ORDER BY bdr.person_id, pr.product_cd, bdr.drawn_dt_tm DESC
    HEAD REPORT
     person_cnt = 0
    HEAD bdr.person_id
     person_cnt = (person_cnt+ 1)
     IF (size(report_info->donor_list,5) < person_cnt)
      stat = alterlist(report_info->donor_list,(person_cnt+ 99))
     ENDIF
     report_info->donor_list[person_cnt].person_id = bdr.person_id, product_cnt = 0
    HEAD pr.product_cd
     product_cnt = (product_cnt+ 1)
     IF (size(report_info->donor_list[person_cnt].donation_history_list,5) < product_cnt)
      stat = alterlist(report_info->donor_list[person_cnt].donation_history_list,(product_cnt+ 4))
     ENDIF
     report_info->donor_list[person_cnt].donation_history_list[product_cnt].product_cd = pr
     .product_cd, report_info->donor_list[person_cnt].donation_history_list[product_cnt].drawn_dt_tm
      = cnvtdatetime(cnvtdate(bdr.drawn_dt_tm),0)
    FOOT  pr.product_cd
     stat = alterlist(report_info->donor_list[person_cnt].donation_history_list,product_cnt)
    FOOT REPORT
     stat = alterlist(report_info->donor_list,person_cnt)
    WITH nocounter
   ;end select
   SET error_check = error(ermsg,0)
   IF (error_check != 0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bbd_rpt_donor_def_elig"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectvalue = ermsg
    SET reply->status_data.subeventstatus[1].targetobjectname = "Select donation history"
    GO TO exit_script
   ENDIF
   FOR (i = 1 TO person_cnt)
    SET product_cnt = size(report_info->donor_list[i].donation_history_list,5)
    FOR (j = 1 TO product_cnt)
      SET elig_prod_cnt = 0
      SET prod_elig_cnt = size(product_eligibility->previous_product_list,5)
      FOR (k = 1 TO prod_elig_cnt)
        SET prod_list_cnt = size(product_eligibility->previous_product_list[k].product_list,5)
        SET prev_prod_cd = product_eligibility->previous_product_list[k].previous_product_cd
        FOR (m = 1 TO prod_list_cnt)
         SET product_found = 0
         IF ((prev_prod_cd=report_info->donor_list[i].donation_history_list[j].product_cd))
          SET prod_cd = product_eligibility->previous_product_list[k].product_list[m].product_cd
          SET dates->eligibility_dt = report_info->donor_list[i].donation_history_list[j].drawn_dt_tm
          SET days_until_elig = (product_eligibility->previous_product_list[k].product_list[m].
          days_until_eligible+ 1)
          SET days_to_add = build(days_until_elig,",D")
          SET dates->eligibility_dt = cnvtlookahead(days_to_add,dates->eligibility_dt)
          SET dates->request_dt = cnvtdatetime(cnvtdate(request->donation_dt_tm),0)
          IF ((dates->eligibility_dt > dates->request_dt))
           SET person_elig_cnt = size(report_info->donor_list[i].eligibility_list,5)
           FOR (n = 1 TO person_elig_cnt)
             IF ((report_info->donor_list[i].eligibility_list[n].product_cd=prod_cd))
              SET product_found = 1
              IF ((report_info->donor_list[i].eligibility_list[n].eligible_dt_tm < dates->
              eligibility_dt))
               SET report_info->donor_list[i].eligibility_list[n].eligible_dt_tm = dates->
               eligibility_dt
              ENDIF
             ENDIF
           ENDFOR
           IF (product_found=0)
            SET elig_prod_cnt = (elig_prod_cnt+ 1)
            IF (person_elig_cnt < elig_prod_cnt)
             SET stat = alterlist(report_info->donor_list[i].eligibility_list,(elig_prod_cnt+ 4))
            ENDIF
            SET report_info->donor_list[i].eligibility_list[elig_prod_cnt].product_cd = prod_cd
            SET report_info->donor_list[i].eligibility_list[elig_prod_cnt].product_disp =
            uar_get_code_display(prod_cd)
            SET report_info->donor_list[i].eligibility_list[elig_prod_cnt].eligible_dt_tm = dates->
            eligibility_dt
           ENDIF
          ENDIF
         ENDIF
        ENDFOR
        SET stat = alterlist(report_info->donor_list[i].eligibility_list[elig_prod_cnt],elig_prod_cnt
         )
      ENDFOR
    ENDFOR
   ENDFOR
  ENDIF
 ENDIF
 SET max_seq = size(report_info->donor_list,5)
 IF (max_seq=0)
  SET max_seq = 1
 ENDIF
 SELECT INTO "nl:"
  FROM person_donor pd,
   (dummyt d  WITH seq = value(max_seq))
  PLAN (pd
   WHERE ((pd.eligibility_type_cd=perm_cd
    AND (request->deferral_flag IN (0, 1))) OR (pd.eligibility_type_cd=temp_cd
    AND (request->deferral_flag IN (0, 2))
    AND ((pd.defer_until_dt_tm > cnvtdatetime(request->donation_dt_tm)) OR (pd.defer_until_dt_tm=null
   )) )) )
   JOIN (d
   WHERE pd.person_id=outerjoin(report_info->donor_list[d.seq].person_id))
  ORDER BY pd.person_id
  HEAD REPORT
   count = 0, orig_size = 0, orig_size = size(report_info->donor_list,5),
   count = orig_size
  HEAD pd.person_id
   found = 0
   FOR (index = 1 TO orig_size)
     IF ((report_info->donor_list[index].person_id=pd.person_id))
      report_info->donor_list[index].eligibility_type_cd = pd.eligibility_type_cd, report_info->
      donor_list[index].defer_until_dt_tm = pd.defer_until_dt_tm, found = 1
     ENDIF
   ENDFOR
   IF (found=0)
    count = (count+ 1)
    IF (size(report_info->donor_list,5) < count)
     stat = alterlist(report_info->donor_list,(count+ 100))
    ENDIF
    report_info->donor_list[count].person_id = pd.person_id, report_info->donor_list[count].
    eligibility_type_cd = pd.eligibility_type_cd, report_info->donor_list[count].defer_until_dt_tm =
    pd.defer_until_dt_tm
   ENDIF
  FOOT REPORT
   stat = alterlist(report_info->donor_list,count)
  WITH nocounter
 ;end select
 SET error_check = error(ermsg,0)
 IF (error_check != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbd_rpt_donor_def_elig"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ermsg
  SET reply->status_data.subeventstatus[1].targetobjectname = "Select deferred donors"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(report_info->donor_list,5))),
   bbd_donor_eligibility bde,
   bbd_donor_contact bdc
  PLAN (d
   WHERE (report_info->donor_list[d.seq].eligibility_type_cd > 0.0))
   JOIN (bde
   WHERE (bde.person_id=report_info->donor_list[d.seq].person_id)
    AND (bde.eligibility_type_cd=report_info->donor_list[d.seq].eligibility_type_cd))
   JOIN (bdc
   WHERE bdc.contact_id=bde.contact_id)
  ORDER BY bde.person_id, bde.eligible_dt_tm
  HEAD bde.person_id
   report_info->donor_list[d.seq].deferral_contact_id = bdc.contact_id, report_info->donor_list[d.seq
   ].deferred_dt_tm = bdc.contact_dt_tm
  WITH nocounter
 ;end select
 SET error_check = error(ermsg,0)
 IF (error_check != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbd_rpt_donor_def_elig"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ermsg
  SET reply->status_data.subeventstatus[1].targetobjectname = "Select contact info"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(report_info->donor_list,5))),
   person p,
   (dummyt d_pa  WITH seq = 1),
   person_alias pa
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=report_info->donor_list[d.seq].person_id)
    AND p.active_ind=1)
   JOIN (d_pa)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND ((pa.person_alias_type_cd=ssn_cd) OR (pa.person_alias_type_cd=donorid_cd))
    AND pa.active_ind=1)
  ORDER BY p.person_id, pa.person_alias_type_cd
  HEAD p.person_id
   report_info->donor_list[d.seq].name_first = p.name_first, report_info->donor_list[d.seq].name_last
    = p.name_last, report_info->donor_list[d.seq].name_middle = p.name_middle,
   report_info->donor_list[d.seq].birth_dt_tm = p.birth_dt_tm, report_info->donor_list[d.seq].
   name_full_formatted = p.name_full_formatted
  DETAIL
   IF (pa.person_alias_type_cd=ssn_cd)
    report_info->donor_list[d.seq].alias_ssn = cnvtalias(pa.alias,pa.alias_pool_cd)
   ELSE
    report_info->donor_list[d.seq].alias_donor_id = cnvtalias(pa.alias,pa.alias_pool_cd)
   ENDIF
  WITH outerjoin(d,d_pa), nocounter
 ;end select
 SET error_check = error(ermsg,0)
 IF (error_check != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "bbd_rpt_donor_def_elig"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = ermsg
  SET reply->status_data.subeventstatus[1].targetobjectname = "Select edonor personal info"
  GO TO exit_script
 ENDIF
 IF ((request->xml_ind=0))
  EXECUTE cpm_create_file_name_logical "bbd_def_inelig", "txt", "x"
  SET reply->rpt_list[1].rpt_filename = cpm_cfn_info->file_name_path
  SET reply->rpt_list[1].node = curnode
  SELECT INTO cpm_cfn_info->file_name_logical
   name_last = cnvtupper(substring(1,100,report_info->donor_list[d.seq].name_last)), name_first =
   cnvtupper(substring(1,100,report_info->donor_list[d.seq].name_first)), name_middle = cnvtupper(
    substring(1,100,report_info->donor_list[d.seq].name_middle)),
   person_id = report_info->donor_list[d.seq].person_id
   FROM (dummyt d  WITH seq = value(size(report_info->donor_list,5)))
   PLAN (d)
   ORDER BY name_last, name_first, name_middle,
    person_id
   HEAD REPORT
    IF ((request->deferral_flag=0))
     deferral_type = captions->perm_and_temp
    ELSEIF ((request->deferral_flag=1))
     deferral_type = captions->perm_only
    ELSE
     deferral_type = captions->temp_only
    ENDIF
   HEAD PAGE
    rpt_row = 1, row rpt_row, col 1,
    sub_get_location_name,
    CALL center(captions->rpt_name,1,126), col 106,
    captions->report_date, col 119, curdate"@DATECONDENSED;;d",
    rpt_row = (rpt_row+ 1), row rpt_row, col 1,
    sub_get_location_address1, donation_date_string = format(request->donation_dt_tm,
     "@DATECONDENSED;;d"), donation_date_string = concat(captions->for_date," ",donation_date_string),
    CALL center(donation_date_string,1,126), col 106, captions->report_time,
    col 121, curtime"@TIMENOSECONDS;;M", rpt_row = (rpt_row+ 1),
    row rpt_row, col 1, sub_get_location_address2,
    deferral_type_head = concat(captions->deferral_type,": ",deferral_type),
    CALL center(deferral_type_head,1,126), rpt_row = (rpt_row+ 1),
    row rpt_row, col 1, sub_get_location_address3
    IF ((request->ineligibility_ind=0))
     inelig_type_head = concat(captions->ineligibility," ",captions->no)
    ELSE
     inelig_type_head = concat(captions->ineligibility," ",captions->yes)
    ENDIF
    CALL center(inelig_type_head,1,126), rpt_row = (rpt_row+ 1), row rpt_row,
    col 1, sub_get_location_citystatezip, rpt_row = (rpt_row+ 1),
    row rpt_row, col 1, sub_get_location_country,
    rpt_row = (rpt_row+ 2), row rpt_row, col 1,
    captions->donor, col 27, captions->donor_id,
    col 48, captions->deferral_type, col 69,
    captions->date, col 80, captions->defer,
    col 91, captions->ineligible, col 115,
    captions->ineligible, rpt_row = (rpt_row+ 1), row rpt_row,
    col 3, captions->birth_date, col 27,
    captions->ssn, col 48, captions->or_inelig,
    col 69, captions->deferred, col 80,
    captions->until, col 91, captions->products,
    col 115, captions->until, rpt_row = (rpt_row+ 1),
    row rpt_row, col 1, dash_line,
    rpt_row = (rpt_row+ 1), rpt_row_product = rpt_row
   HEAD name_last
    rpt_row = rpt_row
   HEAD name_first
    rpt_row = rpt_row
   HEAD name_middle
    rpt_row = rpt_row
   HEAD person_id
    IF (rpt_row > 60)
     BREAK
    ENDIF
    prod_list_cnt = size(report_info->donor_list[d.seq].eligibility_list,5)
    IF ((((report_info->donor_list[d.seq].eligibility_type_cd > 0)) OR (prod_list_cnt > 0)) )
     rpt_row_product = rpt_row, row rpt_row, col 1,
     report_info->donor_list[d.seq].name_full_formatted"#########################"
     IF ((report_info->donor_list[d.seq].alias_donor_id > " "))
      row rpt_row, col 27, report_info->donor_list[d.seq].alias_donor_id
     ENDIF
     IF ((report_info->donor_list[d.seq].eligibility_type_cd=temp_cd))
      col 48, captions->temp_only, col 69,
      report_info->donor_list[d.seq].deferred_dt_tm"@DATECONDENSED;;d", col 80, report_info->
      donor_list[d.seq].defer_until_dt_tm"@DATECONDENSED;;d"
     ELSEIF ((report_info->donor_list[d.seq].eligibility_type_cd=perm_cd))
      col 48, captions->perm_only, col 69,
      report_info->donor_list[d.seq].deferred_dt_tm"@DATECONDENSED;;d", col 80, captions->perm_only
     ELSE
      col 48, captions->ineligible_lc
     ENDIF
     rpt_row = (rpt_row+ 1), row rpt_row, col 3,
     report_info->donor_list[d.seq].birth_dt_tm"MM/DD/YYYY;;D"
     IF ((report_info->donor_list[d.seq].alias_ssn > " "))
      row rpt_row, col 27, report_info->donor_list[d.seq].alias_ssn
     ENDIF
     rpt_row = (rpt_row+ 2), row rpt_row_product
     IF ((report_info->donor_list[d.seq].eligibility_type_cd=0))
      FOR (i = 1 TO size(report_info->donor_list[d.seq].eligibility_list,5))
        IF (rpt_row_product > 61)
         BREAK
        ENDIF
        row rpt_row_product, col 91, report_info->donor_list[d.seq].eligibility_list[i].product_disp,
        col 115, report_info->donor_list[d.seq].eligibility_list[i].eligible_dt_tm"@DATECONDENSED;;d",
        rpt_row_product = (rpt_row_product+ 1)
      ENDFOR
      rpt_row_product = (rpt_row_product+ 1)
     ENDIF
     IF (rpt_row < rpt_row_product)
      rpt_row = rpt_row_product
     ENDIF
    ENDIF
   FOOT  person_id
    rpt_row = rpt_row
   FOOT  name_middle
    rpt_row = rpt_row
   FOOT  name_first
    rpt_row = rpt_row
   FOOT  name_last
    rpt_row = rpt_row
   FOOT PAGE
    row 63, col 1, dash_line,
    rpt_row = (rpt_row+ 1), row 64, col 1,
    cpm_cfn_info->file_name, col 115, captions->page_num,
    col 122, curpage"###"
   FOOT REPORT
    row rpt_row,
    CALL center(captions->end_of_report,1,126)
   WITH maxrow = 65, nocounter
  ;end select
  IF (size(request->batch_selection,1) > 0)
   IF (checkqueue(request->output_dist)=1)
    SET spool value(reply->rpt_list[1].rpt_filename) value(request->output_dist)
   ENDIF
  ENDIF
 ELSE
  EXECUTE cpm_create_file_name_logical "bbd_def_inelig", "xml", "x"
  SET reply->rpt_list[1].rpt_filename = cpm_cfn_info->file_name_path
  SET reply->rpt_list[1].node = curnode
  SELECT INTO cpm_cfn_info->file_name_logical
   name_last = substring(1,100,report_info->donor_list[d.seq].name_last), name_first = substring(1,
    100,report_info->donor_list[d.seq].name_first), name_middle = substring(1,100,report_info->
    donor_list[d.seq].name_middle),
   person_id = report_info->donor_list[d.seq].person_id
   FROM (dummyt d  WITH seq = value(size(report_info->donor_list,5)))
   PLAN (d)
   ORDER BY name_last, name_first, name_middle,
    person_id
   HEAD REPORT
    loc_name = parse_string(sub_get_location_name), address1 = parse_string(sub_get_location_address1
     ), address2 = parse_string(sub_get_location_address2),
    address3 = parse_string(sub_get_location_address3), address4 = parse_string(
     sub_get_location_citystatezip), address5 = parse_string(sub_get_location_country),
    rpt_row = 0
    IF ((request->deferral_flag=0))
     deferral_type = captions->perm_and_temp
    ELSEIF ((request->deferral_flag=1))
     deferral_type = captions->perm_only
    ELSE
     deferral_type = captions->temp_only
    ENDIF
    IF ((request->ineligibility_ind=0))
     inelig_type_head = captions->no
    ELSE
     inelig_type_head = captions->yes
    ENDIF
    row rpt_row, col 0, "<REPORT title=",
    '"', "Donor Deferral-Ineligibility Report", '"',
    " donation_date=", '"', request->donation_dt_tm"@DATECONDENSED;;d",
    '"', " defer_type=", '"',
    deferral_type, '"', " inelig=",
    '"', inelig_type_head, '"',
    " report_date=", '"', curdate"@DATECONDENSED;;d",
    '"', " report_time=", '"',
    curtime"@TIMENOSECONDS;;M", '"', ">",
    rpt_row = (rpt_row+ 1), row rpt_row, col 2,
    "<LOCATION name=", '"', loc_name,
    '"', " address_1=", '"',
    address1, '"', " address_2=",
    '"', address2, '"',
    " address_3=", '"', address3,
    '"', " address_4=", '"',
    address4, '"', " address_5=",
    '"', address5, '"',
    ">", rpt_row = (rpt_row+ 1)
   HEAD name_last
    rpt_row = rpt_row
   HEAD name_first
    rpt_row = rpt_row
   HEAD name_middle
    rpt_row = rpt_row
   HEAD person_id
    prod_list_cnt = size(report_info->donor_list[d.seq].eligibility_list,5)
    IF ((((report_info->donor_list[d.seq].eligibility_type_cd > 0)) OR (prod_list_cnt > 0)) )
     rpt_row = (rpt_row+ 1)
     IF ((report_info->donor_list[d.seq].eligibility_type_cd=temp_cd))
      deferral_type = captions->temp_only
     ELSEIF ((report_info->donor_list[d.seq].eligibility_type_cd=perm_cd))
      deferral_type = captions->perm_only
     ELSE
      deferral_type = captions->ineligible_lc
     ENDIF
     row rpt_row, col 4, "<DONOR name_last=",
     '"', report_info->donor_list[d.seq].name_last, '"',
     " name_first=", '"', report_info->donor_list[d.seq].name_first,
     '"', " name_middle=", '"',
     report_info->donor_list[d.seq].name_middle, '"', " birth=",
     '"', report_info->donor_list[d.seq].birth_dt_tm"@SHORTDATE", '"',
     " ssn=", '"', report_info->donor_list[d.seq].alias_ssn,
     '"', " donor_id=", '"',
     report_info->donor_list[d.seq].alias_donor_id, '"', ">",
     rpt_row = (rpt_row+ 1)
     IF ((((report_info->donor_list[d.seq].eligibility_type_cd=temp_cd)) OR ((report_info->
     donor_list[d.seq].eligibility_type_cd=perm_cd))) )
      row rpt_row, col 6, "<DEFERRAL deferral_type=",
      '"', deferral_type, '"',
      " deferred=", '"', report_info->donor_list[d.seq].deferred_dt_tm"@DATECONDENSED;;d",
      '"', " defer_until=", '"'
      IF ((report_info->donor_list[d.seq].eligibility_type_cd=temp_cd))
       col + 0, report_info->donor_list[d.seq].defer_until_dt_tm"@DATECONDENSED;;d", '"',
       ">", "</DEFERRAL>"
      ELSE
       col + 0, captions->perm_only, '"',
       ">", "</DEFERRAL>"
      ENDIF
      rpt_row = (rpt_row+ 1)
     ELSE
      row rpt_row, col 6, "<DEFERRAL deferral_type=",
      '"', captions->ineligible_lc, '"',
      " deferred=", '"', '"',
      " defer_until=", '"', '"',
      ">", "</DEFERRAL>", rpt_row = (rpt_row+ 1),
      row rpt_row, col 6, "<INELIGIBILITY>",
      rpt_row = (rpt_row+ 1)
      FOR (i = 1 TO size(report_info->donor_list[d.seq].eligibility_list,5))
        row rpt_row, col 8, "<PRODUCT date_eligibile=",
        '"', report_info->donor_list[d.seq].eligibility_list[i].eligible_dt_tm"@DATECONDENSED;;d",
        '"',
        ">", report_info->donor_list[d.seq].eligibility_list[i].product_disp, "</PRODUCT>",
        rpt_row = (rpt_row+ 1)
      ENDFOR
      row rpt_row, col 6, "</INELIGIBILITY>",
      rpt_row = (rpt_row+ 1)
     ENDIF
     row rpt_row, col 4, "</DONOR>",
     rpt_row = (rpt_row+ 1)
    ENDIF
   FOOT  person_id
    rpt_row = rpt_row
   FOOT  name_middle
    rpt_row = rpt_row
   FOOT  name_first
    rpt_row = rpt_row
   FOOT  name_last
    rpt_row = rpt_row
   FOOT REPORT
    row rpt_row, col 2, "</LOCATION>",
    rpt_row = (rpt_row+ 1), row rpt_row, col 0,
    "</REPORT>"
   WITH maxcol = 500, maxrow = 10000, nocounter
  ;end select
 ENDIF
#exit_script
 IF (error_check != 0)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 FREE RECORD report_info
 FREE RECORD dates
 FREE RECORD product_eligibility
 FREE RECORD captions
END GO
