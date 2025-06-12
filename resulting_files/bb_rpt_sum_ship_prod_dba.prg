CREATE PROGRAM bb_rpt_sum_ship_prod:dba
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
 FREE SET total_products
 RECORD total_products(
   1 qual[*]
     2 username = vc
     2 shipped_cnt = i2
     2 event_dt_tm = dq8
     2 event_type_cd = f8
     2 intransit_cnt = i2
     2 inv_area_disp = c21
     2 product_sub_nbr = c5
     2 owner_area_disp = c21
     2 product_display = c20
     2 transferred_cnt = i2
     2 courier_display = c20
     2 prod_nbr_display = c21
     2 event_date_display = c11
     2 organization_display = c21
     2 product_state_display = c11
     2 product_aborh_display = c15
     2 inventory_area_display = c21
     2 transfer_owner_area_display = c21
     2 transfer_inventory_area_display = c21
     2 transferred_qty = i4
     2 serial_number = vc
 )
 FREE SET total_summary
 RECORD total_summary(
   1 qual[*]
     2 shipped_cnt = i2
     2 intransit_cnt = i2
     2 transferred_cnt = i2
     2 product_display = c20
 )
 FREE SET detail_products
 RECORD detail_products(
   1 qual[*]
     2 event_dt_tm = dq8
     2 event_date_display = c11
     2 date_qual[*]
       3 shipped_cnt = i2
       3 intransit_cnt = i2
       3 transferred_cnt = i2
       3 product_display = c20
       3 product_state_display = c11
 )
 FREE SET detail_summary
 RECORD detail_summary(
   1 qual[*]
     2 event_dt_tm = dq8
     2 event_date_display = c11
     2 date_qual[*]
       3 shipped_cnt = i2
       3 intransit_cnt = i2
       3 transferred_cnt = i2
       3 product_display = c20
 )
 FREE SET location
 RECORD location(
   1 qual[*]
     2 owner_area_cd = f8
     2 inventory_area_cd = f8
 )
 RECORD captions(
   1 time = vc
   1 aborh = vc
   1 total = vc
   1 shipped = vc
   1 courier = vc
   1 tech_id = vc
   1 summary = vc
   1 page_no = vc
   1 beg_date = vc
   1 end_date = vc
   1 bb_owner = vc
   1 report_id = vc
   1 intransit = vc
   1 as_of_date = vc
   1 bb_inv_area = vc
   1 transferred = vc
   1 report_title = vc
   1 product_type = vc
   1 end_of_report = vc
   1 product_state = vc
   1 product_number = vc
   1 bb_transfer_org = vc
   1 bb_receiving_org = vc
   1 bb_inventory_area = vc
   1 quantity = vc
   1 serial_number = vc
 )
 DECLARE nstat = i2 WITH protect, noconstant(0)
 DECLARE npassed = i2 WITH protect, noconstant(0)
 DECLARE nprodcnt = i2 WITH protect, noconstant(0)
 DECLARE nlistcnt = i2 WITH protect, noconstant(0)
 DECLARE ndatecnt = i2 WITH protect, noconstant(0)
 DECLARE senddate = c8 WITH protect, noconstant(fillstring(8,""))
 DECLARE sendtime = c5 WITH protect, noconstant(fillstring(5,""))
 DECLARE nqualcnt = i2 WITH protect, noconstant(0)
 DECLARE sfillchar = c1 WITH protect, noconstant(fillstring(1,""))
 DECLARE sfillline = vc WITH protect, constant(fillstring(130,"_"))
 DECLARE nmaxsumrow = i2 WITH protect, constant(57)
 DECLARE npagebreak = i2 WITH protect, noconstant(0)
 DECLARE ndetailcnt = i2 WITH protect, noconstant(0)
 DECLARE nfirsttime = i2 WITH protect, noconstant(0)
 DECLARE nreportcnt = i2 WITH protect, noconstant(0)
 DECLARE nshippedcnt = i2 WITH protect, noconstant(0)
 DECLARE li18nhandle = i4 WITH persistscript
 DECLARE nproddispcnt = i2 WITH protect, noconstant(0)
 DECLARE nprodqualcnt = i2 WITH protect, noconstant(0)
 DECLARE dbbinvareacd = f8 WITH protect, noconstant(0.0)
 DECLARE nintransitcnt = i2 WITH protect, noconstant(0)
 DECLARE ntotalqualcnt = i2 WITH protect, noconstant(0)
 DECLARE dbbownerrootcd = f8 WITH protect, noconstant(0.0)
 DECLARE ntransferredcnt = i2 WITH protect, noconstant(0)
 DECLARE sshippedcdfmean = c2 WITH protect, constant("15")
 DECLARE sprevinvareadisp = c21 WITH protect, noconstant(fillstring(21,""))
 DECLARE sintransitcdfmean = c2 WITH protect, constant("25")
 DECLARE sprevownerareadisp = c21 WITH protect, noconstant(fillstring(21,""))
 DECLARE dshippedeventtypecd = f8 WITH protect, noconstant(0.0)
 DECLARE stransferredcdfmean = c1 WITH protect, constant("6")
 DECLARE dintransiteventtypecd = f8 WITH protect, noconstant(0.0)
 DECLARE dtransferredeventtypecd = f8 WITH protect, noconstant(0.0)
 DECLARE save_row = i4 WITH protect, noconstant(0)
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
 CALL uar_i18nlocalizationinit(li18nhandle,curprog,"",curcclrev)
 SET captions->time = uar_i18ngetmessage(li18nhandle,"time","Time:")
 SET captions->aborh = uar_i18ngetmessage(li18nhandle,"aborh","ABO/RH or")
 SET captions->total = uar_i18ngetmessage(li18nhandle,"total","Total")
 SET captions->shipped = uar_i18ngetmessage(li18nhandle,"shipped","Shipped")
 SET captions->courier = uar_i18ngetmessage(li18nhandle,"courier","Courier")
 SET captions->tech_id = uar_i18ngetmessage(li18nhandle,"tech_id","Tech Id")
 SET captions->summary = uar_i18ngetmessage(li18nhandle,"summary","Summary")
 SET captions->page_no = uar_i18ngetmessage(li18nhandle,"page_no","Page:")
 SET captions->beg_date = uar_i18ngetmessage(li18nhandle,"beg_date","Beginning Date:")
 SET captions->end_date = uar_i18ngetmessage(li18nhandle,"end_date","Ending Date:")
 SET captions->bb_owner = uar_i18ngetmessage(li18nhandle,"bb_owner","Blood Bank Owner:")
 SET captions->report_id = uar_i18ngetmessage(li18nhandle,"report_id","BB_RPT_SUM_SHIP")
 SET captions->intransit = uar_i18ngetmessage(li18nhandle,"intransit","In-transit")
 SET captions->as_of_date = uar_i18ngetmessage(li18nhandle,"as_of_date","As of Date:")
 SET captions->transferred = uar_i18ngetmessage(li18nhandle,"transferred","Transferred")
 SET captions->report_title = uar_i18ngetmessage(li18nhandle,"report_title",
  "SUMMARY OF SHIPPED AND TRANSFERRED PRODUCTS")
 SET captions->product_type = uar_i18ngetmessage(li18nhandle,"product_type","Product")
 SET captions->end_of_report = uar_i18ngetmessage(li18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->product_state = uar_i18ngetmessage(li18nhandle,"product_state","State")
 SET captions->product_number = uar_i18ngetmessage(li18nhandle,"product_number","Product Number\")
 SET captions->bb_transfer_org = uar_i18ngetmessage(li18nhandle,"bb_transfer_org",
  "Transferred to Organization")
 SET captions->bb_receiving_org = uar_i18ngetmessage(li18nhandle,"bb_receiving_org",
  "Receiving Organization")
 SET captions->bb_inventory_area = uar_i18ngetmessage(li18nhandle,"bb_inventory_area",
  "Inventory Area:")
 SET captions->bb_inv_area = uar_i18ngetmessage(li18nhandle,"bb_inventory_area","Inventory Area")
 SET captions->quantity = uar_i18ngetmessage(li18nhandle,"quantity","Quantity")
 SET captions->serial_number = uar_i18ngetmessage(li18nhandle,"serial_number","Serial Number")
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
 SET stat = uar_get_meaning_by_codeset(222,"BBOWNERROOT",1,dbbownerrootcd)
 SET stat = uar_get_meaning_by_codeset(222,"BBINVAREA",1,dbbinvareacd)
 IF (size(trim(request->batch_selection),1) > 0)
  SET begday = request->ops_date
  SET endday = request->ops_date
  SET temp_string = cnvtupper(trim(request->batch_selection))
  CALL check_opt_date_passed("bb_rpt_sum_ship_prod")
  IF ((reply->status_data.status != "F"))
   SET request->beg_dt_tm = begday
   SET request->end_dt_tm = endday
  ENDIF
  CALL check_bb_organization("bb_rpt_sum_ship_prod")
  CALL check_owner_cd("bb_rpt_sum_ship_prod")
  CALL check_inventory_cd("bb_rpt_sum_ship_prod")
  CALL check_location_cd("bb_rpt_sum_ship_prod")
  CALL check_null_report("bb_rpt_sum_ship_prod")
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
 DECLARE get_code_value(sub_code_set,sub_cdf_meaning) = f8
 SUBROUTINE get_code_value(sub_code_set,sub_cdf_meaning)
   SET gsub_code_value = 0.0
   SET cdf_meaning = fillstring(12," ")
   SET cdf_meaning = sub_cdf_meaning
   SET stat = uar_get_meaning_by_codeset(sub_code_set,cdf_meaning,1,gsub_code_value)
   RETURN(gsub_code_value)
 END ;Subroutine
 SET dshippedeventtypecd = get_code_value(1610,sshippedcdfmean)
 SET dintransiteventtypecd = get_code_value(1610,sintransitcdfmean)
 SET dtransferredeventtypecd = get_code_value(1610,stransferredcdfmean)
 SET reply->status_data.status = "F"
 EXECUTE cpm_create_file_name_logical "bb_rpt_sum_ship", "txt", "x"
 SELECT
  IF ((request->cur_owner_area_cd > 0.0)
   AND (request->cur_inv_area_cd > 0.0))
   PLAN (l
    WHERE l.location_cd IN (request->cur_owner_area_cd, request->cur_inv_area_cd)
     AND l.active_ind=1)
    JOIN (lg
    WHERE lg.child_loc_cd=l.location_cd
     AND lg.active_ind=1)
  ELSEIF ((request->cur_owner_area_cd > 0.0))
   PLAN (l
    WHERE (l.location_cd=request->cur_owner_area_cd)
     AND l.active_ind=1)
    JOIN (lg
    WHERE lg.parent_loc_cd=l.location_cd
     AND l.active_ind=1)
  ELSEIF ((request->cur_inv_area_cd > 0.0))
   PLAN (l
    WHERE (l.location_cd=request->cur_inv_area_cd)
     AND l.active_ind=1)
    JOIN (lg
    WHERE lg.child_loc_cd=l.location_cd
     AND lg.active_ind=1)
  ELSEIF ((request->organization_id > 0.0))
   PLAN (l
    WHERE (l.organization_id=request->organization_id)
     AND l.active_ind=1)
    JOIN (lg
    WHERE lg.child_loc_cd=l.location_cd
     AND lg.active_ind=1)
  ELSE
   PLAN (l
    WHERE l.location_type_cd IN (dbbownerrootcd, dbbinvareacd)
     AND l.active_ind=1)
    JOIN (lg
    WHERE lg.child_loc_cd=l.location_cd
     AND lg.active_ind=1)
  ENDIF
  INTO "nl:"
  FROM location l,
   location_group lg
  HEAD REPORT
   nstat = alterlist(location->qual,10)
  DETAIL
   ndetailcnt += 1
   IF (mod(ndetailcnt,10)=1
    AND ndetailcnt != 1)
    nstat = alterlist(location->qual,(ndetailcnt+ 9))
   ENDIF
   location->qual[ndetailcnt].owner_area_cd = lg.parent_loc_cd, location->qual[ndetailcnt].
   inventory_area_cd = lg.child_loc_cd
  FOOT REPORT
   nstat = alterlist(location->qual,ndetailcnt)
  WITH nocounter
 ;end select
 IF (ndetailcnt=0)
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  d1.seq, pe.product_id, bp.supplier_prefix,
  pr.product_nbr"###############", pr.product_sub_nbr"#####", bse_exists = evaluate(nullind(bse
    .product_event_id),0,1,0),
  bit_exists = evaluate(nullind(bit.product_event_id),0,1,0), product_display = decode(pr.seq,
   substring(1,20,uar_get_code_display(pr.product_cd))," "), product_display_key = cnvtupper(
   substring(1,20,uar_get_code_display(pr.product_cd))),
  product_state_display = decode(pe.seq,substring(1,11,uar_get_code_display(pe.event_type_cd))," "),
  product_state_key = cnvtupper(substring(1,11,uar_get_code_display(pe.event_type_cd))),
  event_date_display = substring(1,11,format(pe.event_dt_tm,"YYYY/MM/DD;;D")),
  abo = decode(bp.seq,uar_get_code_display(bp.cur_abo_cd)," "), rh = decode(bp.seq,
   uar_get_code_display(bp.cur_rh_cd)," "), inventory_area_display = uar_get_code_display(bs
   .inventory_area_cd),
  organization_display = decode(bs.seq,substring(1,21,o.org_name)," "), courier_display = decode(bs
   .seq,substring(1,20,uar_get_code_display(bs.courier_cd))," "), transfer_owner_area_display =
  decode(bit.seq,substring(1,21,uar_get_code_display(bit.to_owner_area_cd))," "),
  transfer_inventory_area_display = decode(bit.seq,substring(1,21,uar_get_code_display(bit
     .to_inv_area_cd))," "), transferred_qty = decode(bit.seq,bit.transferred_qty,- (1))
  FROM (dummyt d1  WITH seq = value(ndetailcnt)),
   product_event pe,
   prsnl prs,
   product pr,
   blood_product bp,
   derivative de,
   bb_ship_event bse,
   bb_shipment bs,
   bb_inventory_transfer bit,
   organization o
  PLAN (d1)
   JOIN (pe
   WHERE pe.event_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    AND pe.event_type_cd IN (dshippedeventtypecd, dintransiteventtypecd, dtransferredeventtypecd)
    AND ((pe.product_event_id+ 0) > 0.0))
   JOIN (prs
   WHERE prs.person_id=pe.event_prsnl_id)
   JOIN (pr
   WHERE pr.product_id=pe.product_id
    AND pr.product_id > 0.0
    AND pr.active_ind=1)
   JOIN (bp
   WHERE (bp.product_id= Outerjoin(pr.product_id))
    AND (bp.active_ind= Outerjoin(1)) )
   JOIN (de
   WHERE (de.product_id= Outerjoin(pr.product_id)) )
   JOIN (bse
   WHERE (bse.product_event_id= Outerjoin(pe.product_event_id))
    AND (bse.from_owner_area_cd= Outerjoin(location->qual[d1.seq].owner_area_cd))
    AND (bse.from_inventory_area_cd= Outerjoin(location->qual[d1.seq].inventory_area_cd)) )
   JOIN (bs
   WHERE (bs.shipment_id= Outerjoin(bse.shipment_id))
    AND (bs.active_ind= Outerjoin(1)) )
   JOIN (bit
   WHERE (bit.product_event_id= Outerjoin(pe.product_event_id))
    AND (bit.from_owner_area_cd= Outerjoin(location->qual[d1.seq].owner_area_cd))
    AND (bit.from_inv_area_cd= Outerjoin(location->qual[d1.seq].inventory_area_cd)) )
   JOIN (o
   WHERE (o.organization_id= Outerjoin(bs.organization_id)) )
  ORDER BY event_date_display, product_state_key, product_display_key
  HEAD REPORT
   ndatecnt = 0, nprodqualcnt = 0
  HEAD PAGE
   row + 0
  HEAD event_date_display
   nprodcnt = 0, ndatecnt += 1, nstat = alterlist(detail_products->qual,ndatecnt)
  HEAD product_state_key
   row + 0
  HEAD product_display_key
   nshippedcnt = 0, nintransitcnt = 0, ntransferredcnt = 0
  DETAIL
   IF (((bse_exists=1) OR (bit_exists=1)) )
    nprodqualcnt += 1, nprodcnt += 1
    IF (nprodcnt > size(detail_products->qual[ndatecnt].date_qual,5))
     stat = alterlist(detail_products->qual[ndatecnt].date_qual,(nprodcnt+ 10))
    ENDIF
    IF (nprodqualcnt > size(total_products->qual,5))
     stat = alterlist(total_products->qual,(nprodqualcnt+ 10))
    ENDIF
    total_products->qual[nprodqualcnt].owner_area_disp = substring(1,20,uar_get_code_display(location
      ->qual[d1.seq].owner_area_cd)), total_products->qual[nprodqualcnt].inv_area_disp = substring(1,
     20,uar_get_code_display(location->qual[d1.seq].inventory_area_cd)), total_products->qual[
    nprodqualcnt].event_dt_tm = pe.event_dt_tm,
    total_products->qual[nprodqualcnt].event_date_display = event_date_display, total_products->qual[
    nprodqualcnt].event_type_cd = pe.event_type_cd, total_products->qual[nprodqualcnt].
    product_display = product_display
    IF (pe.event_type_cd=dintransiteventtypecd)
     total_products->qual[nprodqualcnt].intransit_cnt = (nintransitcnt+ 1), detail_products->qual[
     ndatecnt].date_qual[nprodcnt].intransit_cnt = total_products->qual[nprodqualcnt].intransit_cnt,
     nintransitcnt += 1
    ELSEIF (pe.event_type_cd=dshippedeventtypecd)
     total_products->qual[nprodqualcnt].shipped_cnt = (nshippedcnt+ 1), detail_products->qual[
     ndatecnt].date_qual[nprodcnt].shipped_cnt = total_products->qual[nprodqualcnt].shipped_cnt,
     nshippedcnt += 1
    ELSEIF (pe.event_type_cd=dtransferredeventtypecd)
     total_products->qual[nprodqualcnt].transferred_cnt = (ntransferredcnt+ 1), detail_products->
     qual[ndatecnt].date_qual[nprodcnt].transferred_cnt = total_products->qual[nprodqualcnt].
     transferred_cnt, ntransferredcnt += 1
    ENDIF
    detail_products->qual[ndatecnt].event_dt_tm = pe.event_dt_tm, detail_products->qual[ndatecnt].
    event_date_display = event_date_display, detail_products->qual[ndatecnt].date_qual[nprodcnt].
    product_display = product_display,
    detail_products->qual[ndatecnt].date_qual[nprodcnt].product_state_display = product_state_display,
    total_products->qual[nprodqualcnt].product_state_display = product_state_display, total_products
    ->qual[nprodqualcnt].product_display = product_display,
    total_products->qual[nprodqualcnt].prod_nbr_display = concat(trim(bp.supplier_prefix),trim(pr
      .product_nbr)), total_products->qual[nprodqualcnt].product_sub_nbr = pr.product_sub_nbr,
    total_products->qual[nprodqualcnt].serial_number = pr.serial_number_txt,
    total_products->qual[nprodqualcnt].product_aborh_display = concat(trim(abo)," ",trim(rh)),
    total_products->qual[nprodqualcnt].transferred_qty = transferred_qty
    IF (((pe.event_type_cd=dshippedeventtypecd) OR (pe.event_type_cd=dintransiteventtypecd)) )
     IF (size(trim(organization_display),1) != 0)
      total_products->qual[nprodqualcnt].organization_display = organization_display
     ELSEIF (size(trim(inventory_area_display),1) != 0)
      total_products->qual[nprodqualcnt].inventory_area_display = inventory_area_display
     ENDIF
    ELSE
     total_products->qual[nprodqualcnt].transfer_inventory_area_display =
     transfer_inventory_area_display
    ENDIF
    total_products->qual[nprodqualcnt].courier_display = courier_display, total_products->qual[
    nprodqualcnt].username = prs.username
   ENDIF
  FOOT  product_display_key
   row + 0
  FOOT  product_state_key
   row + 0
  FOOT  event_date_display
   IF (size(detail_products->qual[ndatecnt].date_qual,5)=0)
    stat = alterlist(detail_products->qual,(ndatecnt - 1),(ndatecnt - 1)), ndatecnt -= 1
   ELSE
    stat = alterlist(detail_products->qual[ndatecnt].date_qual,nprodcnt)
   ENDIF
  FOOT PAGE
   row + 0
  FOOT REPORT
   nstat = alterlist(total_products->qual,nprodqualcnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d1.seq, prod_disp_key = cnvtupper(total_products->qual[d1.seq].product_display), state_disp_key =
  cnvtupper(total_products->qual[d1.seq].product_state_display),
  date_display = total_products->qual[d1.seq].event_date_display
  FROM (dummyt d1  WITH seq = value(nprodqualcnt))
  PLAN (d1
   WHERE d1.seq <= size(total_products->qual,5))
  ORDER BY prod_disp_key, state_disp_key, date_display
  HEAD REPORT
   nproddispcnt = 0, nstat = alterlist(total_summary->qual,10)
  HEAD prod_disp_key
   nshippedcnt = 0, nintransitcnt = 0, ntransferredcnt = 0,
   nproddispcnt += 1
   IF (mod(nproddispcnt,10)=1
    AND nproddispcnt != 1)
    nstat = alterlist(total_summary->qual,(nproddispcnt+ 9))
   ENDIF
   total_summary->qual[nproddispcnt].product_display = total_products->qual[d1.seq].product_display
  HEAD state_disp_key
   row + 0
  HEAD date_display
   row + 0
  DETAIL
   nintransitcnt = total_products->qual[d1.seq].intransit_cnt, nshippedcnt = total_products->qual[d1
   .seq].shipped_cnt, ntransferredcnt = total_products->qual[d1.seq].transferred_cnt
  FOOT  date_display
   total_summary->qual[nproddispcnt].intransit_cnt += nintransitcnt, total_summary->qual[nproddispcnt
   ].shipped_cnt += nshippedcnt, total_summary->qual[nproddispcnt].transferred_cnt += ntransferredcnt
  FOOT  state_disp_key
   row + 0
  FOOT  prod_disp_key
   row + 0
  FOOT REPORT
   nstat = alterlist(total_summary->qual,nproddispcnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  d1.seq, d2.seq, prod_disp_key = cnvtupper(detail_products->qual[d1.seq].date_qual[d2.seq].
   product_display),
  state_disp_key = cnvtupper(detail_products->qual[d1.seq].date_qual[d2.seq].product_state_display),
  date_display = detail_products->qual[d1.seq].event_date_display
  FROM (dummyt d1  WITH seq = value(ndatecnt)),
   (dummyt d2  WITH seq = value(nprodqualcnt))
  PLAN (d1
   WHERE d1.seq <= size(detail_products->qual,5))
   JOIN (d2
   WHERE d2.seq <= size(detail_products->qual[d1.seq].date_qual,5))
  ORDER BY date_display, prod_disp_key, state_disp_key
  HEAD REPORT
   nqualcnt = 0, nstat = alterlist(detail_summary->qual,10)
  HEAD date_display
   nprodcnt = 0, nqualcnt += 1
   IF (nqualcnt < 11)
    nstat = alterlist(detail_summary->qual[nqualcnt].date_qual,10)
   ENDIF
   IF (mod(nqualcnt,10)=1
    AND nqualcnt != 1)
    nstat = alterlist(detail_summary->qual,(nqualcnt+ 9))
   ENDIF
   detail_summary->qual[nqualcnt].event_dt_tm = detail_products->qual[d1.seq].event_dt_tm,
   detail_summary->qual[nqualcnt].event_date_display = date_display
  HEAD prod_disp_key
   nshippedcnt = 0, nintransitcnt = 0, ntransferredcnt = 0,
   nprodcnt += 1
   IF (nprodcnt < 11)
    nstat = alterlist(detail_summary->qual[nqualcnt].date_qual,10)
   ENDIF
   IF (mod(nprodcnt,10)=1
    AND nprodcnt != 1)
    nstat = alterlist(detail_summary->qual[nqualcnt].date_qual,(nprodcnt+ 9))
   ENDIF
   detail_summary->qual[nqualcnt].date_qual[nprodcnt].product_display = detail_products->qual[d1.seq]
   .date_qual[d2.seq].product_display
  HEAD state_disp_key
   row + 0
  DETAIL
   nintransitcnt = detail_products->qual[d1.seq].date_qual[d2.seq].intransit_cnt, nshippedcnt =
   detail_products->qual[d1.seq].date_qual[d2.seq].shipped_cnt, ntransferredcnt = detail_products->
   qual[d1.seq].date_qual[d2.seq].transferred_cnt
  FOOT  state_disp_key
   detail_summary->qual[nqualcnt].date_qual[nprodcnt].intransit_cnt += nintransitcnt, detail_summary
   ->qual[nqualcnt].date_qual[nprodcnt].shipped_cnt += nshippedcnt, detail_summary->qual[nqualcnt].
   date_qual[nprodcnt].transferred_cnt += ntransferredcnt
  FOOT  prod_disp_key
   nstat = alterlist(detail_summary->qual[nqualcnt].date_qual,nprodcnt)
  FOOT  date_display
   row + 0
  FOOT REPORT
   nstat = alterlist(detail_summary->qual,nqualcnt)
  WITH nocounter
 ;end select
 SELECT INTO cpm_cfn_info->file_name_logical
  d1.seq, date_display = cnvtupper(total_products->qual[d1.seq].event_date_display), owner_area_disp
   = cnvtupper(total_products->qual[d1.seq].owner_area_disp),
  inventory_area_disp = total_products->qual[d1.seq].inv_area_disp
  FROM (dummyt d1  WITH seq = value(nprodqualcnt))
  PLAN (d1
   WHERE d1.seq <= size(total_products->qual,5))
  ORDER BY owner_area_disp, inventory_area_disp, date_display
  HEAD REPORT
   row + 0
  HEAD PAGE
   inc_i18nhandle = 0, inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
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
   save_row = row, row 0,
   CALL center(captions->report_title,1,130),
   col 108, captions->as_of_date, col 120,
   curdate"@DATECONDENSED;;d", row + 1, col 108,
   captions->time, col 120, curtime"@TIMENOSECONDS;;m",
   row + 1, beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm
    ),
   col 35, captions->beg_date, col 51,
   beg_dt_tm"@DATECONDENSED;;d", col 59, beg_dt_tm"@TIMENOSECONDS;;m",
   col 72, captions->end_date, col 85,
   end_dt_tm"@DATECONDENSED;;d", col 93, end_dt_tm"@TIMENOSECONDS;;m",
   row + 2
   IF (npagebreak=0)
    IF (save_row > row)
     row save_row
    ENDIF
    IF (size(total_products->qual,5) > 0)
     col 1, captions->bb_owner
     IF (nprodqualcnt > 0)
      col 19, total_products->qual[d1.seq].owner_area_disp
     ELSE
      col 19, sfillchar
     ENDIF
     row + 1, col 1, captions->bb_inventory_area
     IF (nprodqualcnt > 0)
      col 19, total_products->qual[d1.seq].inv_area_disp
     ELSE
      col 19, sfillchar
     ENDIF
     row + 1, col 63, captions->aborh,
     col 36, captions->product_number
     IF ((((total_products->qual[d1.seq].event_type_cd=dshippedeventtypecd)) OR ((total_products->
     qual[d1.seq].event_type_cd=dintransiteventtypecd))) )
      col 75, captions->bb_receiving_org
     ELSE
      col 75, captions->bb_transfer_org
     ENDIF
    ELSE
     col 19, sfillchar, col 75,
     sfillchar
    ENDIF
    row + 1, col 1, captions->product_state,
    col 14, captions->product_type, col 36,
    captions->serial_number, col 63, captions->quantity,
    col 75, captions->bb_inv_area, col 98,
    captions->courier, col 120, captions->tech_id,
    row + 1, col 1, "-----------",
    col 14, "--------------------", col 36,
    "-------------------------", col 63, "----------",
    col 75, "---------------------", col 98,
    "--------------------", col 120, "-------"
   ENDIF
   row + 1
  HEAD owner_area_disp
   row + 0
  HEAD inventory_area_disp
   row + 0
  HEAD date_display
   IF (((size(trim(sprevownerareadisp),1) != 0) OR (size(trim(sprevinvareadisp),1) != 0)) )
    IF ((((total_products->qual[d1.seq].owner_area_disp != sprevownerareadisp)) OR ((total_products->
    qual[d1.seq].inv_area_disp != sprevinvareadisp))) )
     sprevownerareadisp = total_products->qual[d1.seq].owner_area_disp, sprevinvareadisp =
     total_products->qual[d1.seq].inv_area_disp, BREAK
    ENDIF
   ENDIF
   col 1, total_products->qual[d1.seq].event_dt_tm"@SHORTDATE", row + 1
  DETAIL
   ntotalqualcnt += 1, col 1, total_products->qual[d1.seq].product_state_display"###########",
   col 14, total_products->qual[d1.seq].product_display"####################", col 36,
   total_products->qual[d1.seq].prod_nbr_display"####################"
   IF (size(trim(total_products->qual[d1.seq].product_sub_nbr),1) > 0)
    col 56, total_products->qual[d1.seq].product_sub_nbr"#####"
   ELSE
    col 56, "     "
   ENDIF
   IF ((total_products->qual[d1.seq].transferred_qty <= 0))
    col 63, total_products->qual[d1.seq].product_aborh_display"##########"
   ELSE
    col 63, total_products->qual[d1.seq].transferred_qty"####;p "
   ENDIF
   IF ((((total_products->qual[d1.seq].event_type_cd=dshippedeventtypecd)) OR ((total_products->qual[
   d1.seq].event_type_cd=dintransiteventtypecd))) )
    IF (size(trim(total_products->qual[d1.seq].organization_display),1) != 0)
     col 75, total_products->qual[d1.seq].organization_display"#####################"
    ELSE
     col 75, total_products->qual[d1.seq].inventory_area_display"#####################"
    ENDIF
   ELSE
    col 75, total_products->qual[d1.seq].transfer_inventory_area_display"#####################"
   ENDIF
   col 98, total_products->qual[d1.seq].courier_display"####################", col 120,
   total_products->qual[d1.seq].username"#######"
   IF ((total_products->qual[d1.seq].serial_number != null))
    row + 1, col 36, total_products->qual[d1.seq].serial_number
   ENDIF
   row + 1
   IF (row > nmaxsumrow)
    BREAK
   ENDIF
  FOOT  date_display
   row + 1
  FOOT  inventory_area_disp
   sprevinvareadisp = trim(total_products->qual[d1.seq].inv_area_disp)
  FOOT  owner_area_disp
   sprevownerareadisp = trim(total_products->qual[d1.seq].owner_area_disp)
   IF (ntotalqualcnt=size(total_products->qual,5))
    npagebreak = 1, BREAK
   ENDIF
   IF (npagebreak=1)
    npagebreak = 2
   ENDIF
  FOOT PAGE
   IF (npagebreak < 2)
    row 58, col 1, sfillline,
    row + 1, col 1, captions->report_id,
    col 120, captions->page_no, col 128,
    curpage"###"
   ENDIF
  FOOT REPORT
   IF (npagebreak=2)
    nshippedcnt = 0, nintransitcnt = 0, ntransferredcnt = 0
    FOR (nlistcnt = 1 TO size(detail_summary->qual,5))
      row + 1, col 1, detail_summary->qual[nlistcnt].event_dt_tm"@SHORTDATE",
      col 10, captions->summary, row + 1,
      col 1, captions->product_type, col 28,
      captions->intransit, col 41, captions->shipped,
      col 54, captions->transferred, row + 1,
      col 1, "-------------------------", col 28,
      "-----------", col 41, "-----------",
      col 54, "-----------", row + 1
      FOR (nqualcnt = 1 TO size(detail_summary->qual[nlistcnt].date_qual,5))
        col 1, detail_summary->qual[nlistcnt].date_qual[nqualcnt].product_display
        "#########################"
        IF ((detail_summary->qual[nlistcnt].date_qual[nqualcnt].intransit_cnt > 0))
         col 35, detail_summary->qual[nlistcnt].date_qual[nqualcnt].intransit_cnt"####;p "
        ENDIF
        IF ((detail_summary->qual[nlistcnt].date_qual[nqualcnt].shipped_cnt > 0))
         col 48, detail_summary->qual[nlistcnt].date_qual[nqualcnt].shipped_cnt"####;p "
        ENDIF
        IF ((detail_summary->qual[nlistcnt].date_qual[nqualcnt].transferred_cnt > 0))
         col 61, detail_summary->qual[nlistcnt].date_qual[nqualcnt].transferred_cnt"####;p "
        ENDIF
        row + 1
        IF (((row+ 1) >= nmaxsumrow))
         BREAK
        ENDIF
      ENDFOR
    ENDFOR
    IF (nprodqualcnt > 0)
     row 58, col 1, sfillline,
     row + 1, col 1, captions->report_id,
     col 120, captions->page_no, col 128,
     curpage"###", BREAK, col 1,
     beg_dt_tm"@SHORTDATE", col 10, beg_dt_tm"@TIMENOSECONDS;;m",
     col 16, "-", col 18,
     end_dt_tm"@SHORTDATE", col 27, end_dt_tm"@TIMENOSECONDS;;m",
     col 33, captions->summary, row + 1,
     col 1, captions->product_type, col 28,
     captions->intransit, col 41, captions->shipped,
     col 54, captions->transferred, row + 1,
     col 1, "-------------------------", col 28,
     "-----------", col 41, "-----------",
     col 54, "-----------", row + 1
     FOR (nqualcnt = 1 TO size(total_summary->qual,5))
       col 1, total_summary->qual[nqualcnt].product_display"#########################"
       IF ((total_summary->qual[nqualcnt].intransit_cnt > 0))
        col 35, total_summary->qual[nqualcnt].intransit_cnt"####;p ", nintransitcnt += total_summary
        ->qual[nqualcnt].intransit_cnt
       ENDIF
       IF ((total_summary->qual[nqualcnt].shipped_cnt > 0))
        col 48, total_summary->qual[nqualcnt].shipped_cnt"####;p ", nshippedcnt += total_summary->
        qual[nqualcnt].shipped_cnt
       ENDIF
       IF ((total_summary->qual[nqualcnt].transferred_cnt > 0))
        col 61, total_summary->qual[nqualcnt].transferred_cnt"####;p ", ntransferredcnt +=
        total_summary->qual[nqualcnt].transferred_cnt
       ENDIF
       row + 1
       IF (row >= nmaxsumrow)
        BREAK
       ENDIF
     ENDFOR
     col 1, "-------------------------", col 28,
     "-----------", col 41, "-----------",
     col 54, "-----------", row + 1,
     col 1, captions->total
     IF (nintransitcnt > 0)
      col 35, nintransitcnt"####;p "
     ENDIF
     IF (nshippedcnt > 0)
      col 48, nshippedcnt"####;p "
     ENDIF
     IF (ntransferredcnt > 0)
      col 61, ntransferredcnt"####;p "
     ENDIF
    ENDIF
   ENDIF
   row 58, col 1, sfillline,
   row + 1, col 1, captions->report_id,
   col 120, captions->page_no, col 128,
   curpage"###", row 60,
   CALL center(captions->end_of_report,1,130),
   npassed = 1
  WITH nocounter, nullreport, maxrow = 61,
   compress, nolandscape
 ;end select
 SET nreportcnt += 1
 SET nstat = alterlist(reply->rpt_list,nreportcnt)
 SET reply->rpt_list[nreportcnt].rpt_filename = cpm_cfn_info->file_name_path
 IF (size(trim(request->batch_selection),1) > 0
  AND (request->null_ind=1))
  SET spool value(reply->rpt_list[nreportcnt].rpt_filename) value(request->output_dist)
 ENDIF
 IF (npassed=1)
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 FREE RECORD total_products
 FREE RECORD total_summary
 FREE RECORD detail_products
 FREE RECORD detail_summary
 FREE RECORD location
 FREE RECORD captions
END GO
