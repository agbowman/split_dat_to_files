CREATE PROGRAM bbt_rpt_exception:dba
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
 RECORD ops_params(
   1 qual[*]
     2 param = c100
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
   1 bb_exception = vc
   1 time = vc
   1 as_of_date = vc
   1 bb_owner = vc
   1 inventory_area = vc
   1 beg_date = vc
   1 end_date = vc
   1 product_number = vc
   1 aborh = vc
   1 name = vc
   1 physician = vc
   1 expired = vc
   1 xmd = vc
   1 accession_number = vc
   1 product_type = vc
   1 unit = vc
   1 patient = vc
   1 alias = vc
   1 dispd = vc
   1 reason = vc
   1 tech = vc
   1 report_id = vc
   1 page_no = vc
   1 printed = vc
   1 end_of_report = vc
   1 xm = vc
   1 emergency_dispensed = vc
   1 trans_reqs = vc
   1 dispensed_existing = vc
   1 product_nbr = vc
   1 patient_antibodies = vc
   1 product_antigens = vc
   1 date = vc
   1 validation_aborh = vc
   1 new_time = vc
   1 accession = vc
   1 previous = vc
   1 resulted = vc
   1 current = vc
   1 mrn = vc
   1 heading = vc
   1 accession_head = vc
   1 reason_head = vc
   1 patient_name = vc
   1 accession_nbr = vc
   1 dt_tm = vc
   1 exceptions = vc
   1 reason_for_override = vc
   1 products_xmd = vc
   1 type = vc
   1 xmd_dt_tm = vc
   1 xm_expire_dt_tm = vc
   1 dispensed_dt_tm = vc
   1 transfused_dt_tm = vc
   1 prod_attributes = vc
   1 all = vc
   1 mod_d = vc
   1 collected_dt_tm = vc
   1 prep_hours = vc
   1 mod_option = vc
   1 orig_product = vc
   1 new_product = vc
   1 default_exp = vc
   1 new_expire = vc
   1 tech = vc
   1 not_on_file = vc
   1 unit_abo = vc
   1 patient_abo = vc
   1 procedure = vc
   1 orderable = vc
   1 units = vc
   1 guideline = vc
   1 requested = vc
   1 approved = vc
   1 service_resource = vc
   1 nt_required = vc
   1 ts_only = vc
   1 none = vc
   1 results = vc
   1 verified = vc
   1 datetime = vc
   1 specimen = vc
   1 expiration = vc
   1 dob = vc
   1 override_reason = vc
   1 new_specimen = vc
   1 override = vc
   1 required_date = vc
   1 orderables = vc
   1 adjusted = vc
   1 collected = vc
   1 xm_expiration_dt_tm = vc
   1 not_adjusted = vc
   1 facility = vc
   1 updated_to = vc
   1 crossmatched = vc
   1 state = vc
   1 dispensed = vc
   1 patient_mrn = vc
   1 foot_note = vc
   1 product_order = vc
   1 ordering_physician = vc
   1 no_prod_order = vc
   1 patient_location = vc
   1 serial_number = vc
   1 label_product_number = vc
   1 tag_product_number = vc
   1 info_not_found = vc
 )
 SET captions->bb_exception = uar_i18ngetmessage(i18nhandle,"bb_exception",
  "B L O O D   B A N K   E X C E P T I O N   R E P O R T")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","Time:")
 SET captions->as_of_date = uar_i18ngetmessage(i18nhandle,"as_of_date","As of Date:")
 SET captions->bb_owner = uar_i18ngetmessage(i18nhandle,"bb_owner","Blood Bank Owner: ")
 SET captions->inventory_area = uar_i18ngetmessage(i18nhandle,"inventory_area","Inventory Area: ")
 SET captions->beg_date = uar_i18ngetmessage(i18nhandle,"beg_date","Beginning Date:")
 SET captions->end_date = uar_i18ngetmessage(i18nhandle,"end_date","Ending Date:")
 SET captions->product_number = uar_i18ngetmessage(i18nhandle,"product_number","Product Number")
 SET captions->aborh = uar_i18ngetmessage(i18nhandle,"aborh","ABO/Rh")
 SET captions->name = uar_i18ngetmessage(i18nhandle,"name","Name")
 SET captions->physician = uar_i18ngetmessage(i18nhandle,"physician","Physician")
 SET captions->expired = uar_i18ngetmessage(i18nhandle,"expired","Expired")
 SET captions->xmd = uar_i18ngetmessage(i18nhandle,"xmd","XM'd")
 SET captions->accession_number = uar_i18ngetmessage(i18nhandle,"accession_number","Accession Number"
  )
 SET captions->serial_number = uar_i18ngetmessage(i18nhandle,"serial_number","Serial Number")
 SET captions->product_type = uar_i18ngetmessage(i18nhandle,"product_type","Product Type")
 SET captions->unit = uar_i18ngetmessage(i18nhandle,"unit","Unit")
 SET captions->patient = uar_i18ngetmessage(i18nhandle,"patient","Patient")
 SET captions->alias = uar_i18ngetmessage(i18nhandle,"alias","Alias")
 SET captions->dispd = uar_i18ngetmessage(i18nhandle,"dispd","Disp'd")
 SET captions->reason = uar_i18ngetmessage(i18nhandle,"reason","Reason")
 SET captions->tech = uar_i18ngetmessage(i18nhandle,"tech","Tech")
 SET captions->report_id = uar_i18ngetmessage(i18nhandle,"report_id","Report ID: BBT_RPT_EXCEPTION")
 SET captions->page_no = uar_i18ngetmessage(i18nhandle,"page_no","Page:")
 SET captions->printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->xm = uar_i18ngetmessage(i18nhandle,"xm","XM")
 SET captions->emergency_dispensed = uar_i18ngetmessage(i18nhandle,"emergency_dispensed",
  "*  This patient was Emergency Dispensed")
 SET captions->trans_reqs = uar_i18ngetmessage(i18nhandle,"trans_reqs","Transfusion Requirements")
 SET captions->dispensed_existing = uar_i18ngetmessage(i18nhandle,"dispensed_existing",
  "Dispensed with existing Autologous/Directed Products:")
 SET captions->product_nbr = uar_i18ngetmessage(i18nhandle,"product_nbr","Product Nbr.")
 SET captions->patient_antibodies = uar_i18ngetmessage(i18nhandle,"patient_antibodies",
  "Patient Antibodies")
 SET captions->product_antigens = uar_i18ngetmessage(i18nhandle,"product_antigens","Product Antigens"
  )
 SET captions->date = uar_i18ngetmessage(i18nhandle,"date","Date")
 SET captions->validation_aborh = uar_i18ngetmessage(i18nhandle,"validation_aborh",
  "Validation ABO/Rh")
 SET captions->new_time = uar_i18ngetmessage(i18nhandle,"new_time","Time")
 SET captions->accession = uar_i18ngetmessage(i18nhandle,"accession","Accession")
 SET captions->previous = uar_i18ngetmessage(i18nhandle,"previous","Previous")
 SET captions->resulted = uar_i18ngetmessage(i18nhandle,"resulted","Resulted")
 SET captions->current = uar_i18ngetmessage(i18nhandle,"current","Current")
 SET captions->mrn = uar_i18ngetmessage(i18nhandle,"mrn","MRN")
 SET captions->heading = uar_i18ngetmessage(i18nhandle,"heading",
  "   Procedure        Result       Date/Time    Tech")
 SET captions->accession_head = uar_i18ngetmessage(i18nhandle,"accession_head",
  "          Accession                  Unit/Cell")
 SET captions->reason_head = uar_i18ngetmessage(i18nhandle,"reason_head","       Reason")
 SET captions->patient_name = uar_i18ngetmessage(i18nhandle,"patient_name","Patient Name")
 SET captions->accession_nbr = uar_i18ngetmessage(i18nhandle,"accession_nbr","Accession Nbr")
 SET captions->dt_tm = uar_i18ngetmessage(i18nhandle,"dt_tm","Date/Time")
 SET captions->exceptions = uar_i18ngetmessage(i18nhandle,"exceptions","Exceptions")
 SET captions->reason_for_override = uar_i18ngetmessage(i18nhandle,"reason_for_override",
  "Reason for override")
 SET captions->products_xmd = uar_i18ngetmessage(i18nhandle,"products_xmd","Products XM'd:")
 SET captions->type = uar_i18ngetmessage(i18nhandle,"type","Type")
 SET captions->xmd_dt_tm = uar_i18ngetmessage(i18nhandle,"xmd_dt_tm","XM'd Dt/Tm ")
 SET captions->xm_expire_dt_tm = uar_i18ngetmessage(i18nhandle,"xm_expire_dt_tm","XM Expire Dt/Tm ")
 SET captions->dispensed_dt_tm = uar_i18ngetmessage(i18nhandle,"dispensed_dt_tm","Dispensed Dt/Tm ")
 SET captions->transfused_dt_tm = uar_i18ngetmessage(i18nhandle,"transfused_dt_tm","Transfused Dt/tm"
  )
 SET captions->prod_attributes = uar_i18ngetmessage(i18nhandle,"prod_attributes","Product Attributes"
  )
 SET captions->all = uar_i18ngetmessage(i18nhandle,"all","(All)")
 SET captions->mod_d = uar_i18ngetmessage(i18nhandle,"mod_d","Mod'd")
 SET captions->collected_dt_tm = uar_i18ngetmessage(i18nhandle,"collected_dt_tm","Collected Dt/Tm")
 SET captions->prep_hours = uar_i18ngetmessage(i18nhandle,"prep_hours","Prep Hours")
 SET captions->mod_option = uar_i18ngetmessage(i18nhandle,"mod_option","Modification Option")
 SET captions->orig_product = uar_i18ngetmessage(i18nhandle,"orig_product","Original Product")
 SET captions->new_product = uar_i18ngetmessage(i18nhandle,"new_product","New Product")
 SET captions->default_exp = uar_i18ngetmessage(i18nhandle,"default_exp","Default Exp")
 SET captions->new_expire = uar_i18ngetmessage(i18nhandle,"new_expire","New Expire")
 SET captions->tech = uar_i18ngetmessage(i18nhandle,"tech","Tech")
 SET captions->not_on_file = uar_i18ngetmessage(i18nhandle,"not_on_file","<Not on File>")
 SET captions->unit_abo = uar_i18ngetmessage(i18nhandle,"unit_abo","Unit ABO/Rh")
 SET captions->patient_abo = uar_i18ngetmessage(i18nhandle,"patient_abo","Patient ABO/Rh")
 SET captions->procedure = uar_i18ngetmessage(i18nhandle,"procedure","Surgical Procedure")
 SET captions->orderable = uar_i18ngetmessage(i18nhandle,"orderable","Orderable")
 SET captions->units = uar_i18ngetmessage(i18nhandle,"units","Units")
 SET captions->guideline = uar_i18ngetmessage(i18nhandle,"guideline","Guideline")
 SET captions->requested = uar_i18ngetmessage(i18nhandle,"requested","Requested")
 SET captions->approved = uar_i18ngetmessage(i18nhandle,"approved","Approved")
 SET captions->service_resource = uar_i18ngetmessage(i18nhandle,"service_resource",
  "Service Resource:")
 SET captions->nt_required = uar_i18ngetmessage(i18nhandle,"nt_required","NT Required")
 SET captions->ts_only = uar_i18ngetmessage(i18nhandle,"ts_only","T/S Only")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"NONE","None")
 SET captions->results = uar_i18ngetmessage(i18nhandle,"results","Results")
 SET captions->verified = uar_i18ngetmessage(i18nhandle,"verified","Verified")
 SET captions->datetime = uar_i18ngetmessage(i18nhandle,"datetime","Date/Time")
 SET captions->specimen = uar_i18ngetmessage(i18nhandle,"specimen","Specimen")
 SET captions->expiration = uar_i18ngetmessage(i18nhandle,"expiration","Expiration")
 SET captions->dob = uar_i18ngetmessage(i18nhandle,"dateofbirth","Date of Birth")
 SET captions->override_reason = uar_i18ngetmessage(i18nhandle,"override_reason","Override Reason")
 SET captions->new_specimen = uar_i18ngetmessage(i18nhandle,"new_specimen","New Specimen")
 SET captions->override = uar_i18ngetmessage(i18nhandle,"override","Override")
 SET captions->required_date = uar_i18ngetmessage(i18nhandle,"required_date","Required Date")
 SET captions->orderables = uar_i18ngetmessage(i18nhandle,"orderables","Orderable(s)")
 SET captions->adjusted = uar_i18ngetmessage(i18nhandle,"adjusted","Adjusted")
 SET captions->collected = uar_i18ngetmessage(i18nhandle,"collected","Collected")
 SET captions->xm_expiration_dt_tm = uar_i18ngetmessage(i18nhandle,"xm_expiration_dt_tm",
  "Crossmatch Expiration")
 SET captions->not_adjusted = uar_i18ngetmessage(i18nhandle,"not_adjusted","Not Adjusted")
 SET captions->facility = uar_i18ngetmessage(i18nhandle,"facility","Facility:")
 SET captions->updated_to = uar_i18ngetmessage(i18nhandle,"updated to","Updated to")
 SET captions->crossmatched = uar_i18ngetmessage(i18nhandle,"crossmatched","Crossmatched")
 SET captions->state = uar_i18ngetmessage(i18nhandle,"state","State")
 SET captions->dispensed = uar_i18ngetmessage(i18nhandle,"dispensed","Dispensed")
 SET captions->patient_mrn = uar_i18ngetmessage(i18nhandle,"patient_mrn","Patient MRN")
 SET captions->foot_note = uar_i18ngetmessage(i18nhandle,"foot_note",
  "* - Specimen expiration extended on expired Specimen")
 SET captions->product_order = uar_i18ngetmessage(i18nhandle,"product_order","Product Order")
 SET captions->ordering_physician = uar_i18ngetmessage(i18nhandle,"ordering_physician",
  "Ordering Physician")
 SET captions->no_prod_order = uar_i18ngetmessage(i18nhandle,"no_prod_order","<No Product Order>")
 SET captions->patient_location = uar_i18ngetmessage(i18nhandle,"pat_location","Patient Location")
 SET captions->label_product_number = uar_i18ngetmessage(i18nhandle,"label_product_number",
  "Label Product Number")
 SET captions->tag_product_number = uar_i18ngetmessage(i18nhandle,"tag_product_number",
  "Tag Product Number")
 SET captions->info_not_found = uar_i18ngetmessage(i18nhandle,"information_not_found",
  "<<INFORMATION NOT FOUND>>")
 IF (trim(request->batch_selection) > " ")
  SET begday = request->ops_date
  SET endday = request->ops_date
  SET temp_string = cnvtupper(trim(request->batch_selection))
  CALL check_opt_date_passed("")
  IF ((reply->status_data.status != "F"))
   SET request->beg_dt_tm = begday
   SET request->end_dt_tm = endday
  ENDIF
  CALL check_owner_cd("bbt_rpt_exception")
  CALL check_inventory_cd("bbt_rpt_exception")
  CALL check_location_cd("bbt_rpt_exception")
  CALL check_null_report("bbt_rpt_exception")
  SET nsvc_pos = cnvtint(value(findstring("SVC[",temp_string)))
  IF (nsvc_pos > 0)
   CALL check_svc_opt("bbt_rpt_exception")
  ENDIF
  CALL check_facility_cd("bbt_rpt_exception")
  CALL check_exception_type_cd("bbt_rpt_exception")
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
 DECLARE get_code_value(sub_code_set,sub_cdf_meaning) = f8
 SUBROUTINE get_code_value(sub_code_set,sub_cdf_meaning)
   SET gsub_code_value = 0.0
   SET cdf_meaning = fillstring(12," ")
   SET cdf_meaning = sub_cdf_meaning
   SET stat = uar_get_meaning_by_codeset(sub_code_set,cdf_meaning,1,gsub_code_value)
   RETURN(gsub_code_value)
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
 DECLARE lmsbos_cs = i4 WITH protect, constant(4554)
 DECLARE xm_exception_cd = f8
 DECLARE exception_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE modified_product_cd = f8 WITH protect, noconstant(0.0)
 DECLARE modified_cd = f8 WITH protect, noconstant(0.0)
 DECLARE pooled_cd = f8 WITH protect, noconstant(0.0)
 DECLARE pref_allo_blk_except_ind = i2 WITH noconstant(0)
 DECLARE pref_curr_abo_ind = i2 WITH noconstant(0)
 DECLARE pref_2nd_abo_ind = i2 WITH noconstant(0)
 DECLARE pref_cur_absc_ind = i2 WITH noconstant(0)
 DECLARE pref_agab_val_ind = i2 WITH noconstant(0)
 DECLARE pref_treq_val_ind = i2 WITH noconstant(0)
 DECLARE answer_y_cd = f8 WITH protect, noconstant(0.0)
 DECLARE answer_except_cd = f8 WITH protect, noconstant(0.0)
 DECLARE pref_xm_abo_req_cd = f8 WITH protect, noconstant(0.0)
 DECLARE pref_xm_2a_req_cd = f8 WITH protect, noconstant(0.0)
 DECLARE pref_xm_agab_val_cd = f8 WITH protect, noconstant(0.0)
 DECLARE pref_xm_trfrq_val_cd = f8 WITH protect, noconstant(0.0)
 DECLARE pref_xm_absc_req_cd = f8 WITH protect, noconstant(0.0)
 DECLARE pref_xm_allo_blk_cd = f8 WITH protect, noconstant(0.0)
 DECLARE pref_xm_inc_xm_cd = f8 WITH protect, noconstant(0.0)
 DECLARE pref_xm_inc_xm_ind = i2 WITH noconstant(0)
 DECLARE pref_disp_inc_xm_cd = f8 WITH protect, noconstant(0.0)
 DECLARE pref_disp_inc_xm_ind = i2 WITH noconstant(0)
 DECLARE nsvc_pos = i2 WITH protect, noconstant(0)
 DECLARE facidx = i4 WITH protect, noconstant(0)
 DECLARE patient_loc = vc WITH protect, noconstant("")
 DECLARE datafoundflag = i2 WITH protect, noconstant(false)
 SET stat = uar_get_meaning_by_codeset(1659,nullterm("Y"),1,answer_y_cd)
 SET stat = uar_get_meaning_by_codeset(1659,nullterm("EXCEPTION"),1,answer_except_cd)
 SET stat = uar_get_meaning_by_codeset(1661,nullterm("XM ABO REQ"),1,pref_xm_abo_req_cd)
 SET stat = uar_get_meaning_by_codeset(1661,nullterm("XM 2A REQ"),1,pref_xm_2a_req_cd)
 SET stat = uar_get_meaning_by_codeset(1661,nullterm("XM AGAB VAL"),1,pref_xm_agab_val_cd)
 SET stat = uar_get_meaning_by_codeset(1661,nullterm("XM TRFRQ VAL"),1,pref_xm_trfrq_val_cd)
 SET stat = uar_get_meaning_by_codeset(1661,nullterm("XM ABSC REQ"),1,pref_xm_absc_req_cd)
 SET stat = uar_get_meaning_by_codeset(1661,nullterm("XM ALLO BLK"),1,pref_xm_allo_blk_cd)
 SET stat = uar_get_meaning_by_codeset(1661,nullterm("INCOMPATXM"),1,pref_xm_inc_xm_cd)
 SET stat = uar_get_meaning_by_codeset(1661,nullterm("DISPINCPTXM"),1,pref_disp_inc_xm_cd)
 DECLARE code_value = f8
 DECLARE code_set = i4
 DECLARE cdf_meaning = c12
 SET code_value = 0.0
 SET code_set = 0
 SET cdf_meaning = fillstring(12," ")
 SET code_set = 1610
 SET cdf_meaning = "3"
 EXECUTE cpm_get_cd_for_cdf
 SET crossmatch_code = code_value
 SET code_set = 1610
 SET cdf_meaning = "4"
 EXECUTE cpm_get_cd_for_cdf
 SET dispense_code = code_value
 SET code_set = 1610
 SET cdf_meaning = "7"
 EXECUTE cpm_get_cd_for_cdf
 SET transfuse_code = code_value
 SET cur_owner_area_disp = fillstring(40," ")
 SET cur_inv_area_disp = fillstring(40," ")
 DECLARE facility_disp = vc WITH protect, noconstant("")
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
 SET mrn_code = 0.0
 SET encntr_mrn_code = 0.0
 SET admitdoc = 0.0
 SET in_progress_cd = 0.0
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(4,"MRN",code_cnt,mrn_code)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(319,"MRN",code_cnt,encntr_mrn_code)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(333,"ADMITDOC",code_cnt,admitdoc)
 SET code_cnt = 1
 SET stat = uar_get_meaning_by_codeset(1610,"16",code_cnt,in_progress_cd)
 IF (((mrn_code=0.0) OR (((encntr_mrn_code=0.0) OR (((admitdoc=0.0) OR (in_progress_cd=0.0)) )) )) )
  SET reply->status = "F"
  GO TO exit_script
 ENDIF
 RECORD trnreq(
   1 req_list[*]
     2 trn_code = f8
     2 trn_display = c50
 )
 RECORD autodirreq(
   1 autodir_list[*]
     2 product_id = f8
 )
 SET stat = alterlist(trnreq->req_list,10)
 SET req_idx = 0
 SELECT INTO "nl:"
  FROM code_value c1
  WHERE c1.code_set=1611
   AND c1.code_value > 0
  DETAIL
   req_idx += 1
   IF (mod(req_idx,10)=1
    AND req_idx != 1)
    stat = alterlist(trnreq->req_list,(req_idx+ 9))
   ENDIF
   trnreq->req_list[req_idx].trn_code = c1.code_value, trnreq->req_list[req_idx].trn_display = c1
   .display
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET stat = alterlist(trnreq->req_list,req_idx)
 ENDIF
 RECORD streq(
   1 st_list[*]
     2 st_code = f8
     2 st_display = c20
 )
 SET stat = alterlist(streq->st_list,10)
 SET st_idx = 0
 SELECT INTO "nl:"
  FROM code_value c1
  WHERE c1.code_set=1612
   AND c1.code_value > 0
  DETAIL
   st_idx += 1
   IF (mod(st_idx,10)=1
    AND st_idx != 1)
    stat = alterlist(streq->st_list,(st_idx+ 9))
   ENDIF
   streq->st_list[st_idx].st_code = c1.code_value, streq->st_list[st_idx].st_display = substring(1,20,
    c1.display)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET stat = alterlist(streq->st_list,st_idx)
 ENDIF
 RECORD anreq(
   1 an_list[*]
     2 an_code = f8
     2 an_display = c20
 )
 SET stat = alterlist(anreq->an_list,10)
 SET an_idx = 0
 SELECT INTO "nl:"
  FROM code_value c1
  WHERE c1.code_set=1613
   AND c1.code_value > 0
  DETAIL
   an_idx += 1
   IF (mod(an_idx,10)=1
    AND an_idx != 1)
    stat = alterlist(anreq->an_list,(an_idx+ 9))
   ENDIF
   anreq->an_list[an_idx].an_code = c1.code_value, anreq->an_list[an_idx].an_display = substring(1,20,
    c1.display)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET stat = alterlist(anreq->an_list,an_idx)
 ENDIF
 SET rpt_cnt = 0
 DECLARE rpt_filename = c30
 IF (((uar_get_code_meaning(request->exception_type_cd)="EXPUNITXM") OR ((request->exception_type_cd=
 0.0))) )
  EXECUTE cpm_create_file_name_logical "bbt_exp_unit_xm", "txt", "x"
  SET cdf_meaning = "EXPUNITXM"
  SET exception_code = get_code_value(14072,cdf_meaning)
  SET exception_disp = uar_get_code_display(exception_code)
  SELECT INTO cpm_cfn_info->file_name_logical
   pe.product_event_id, pr.product_nbr, pr.product_sub_nbr,
   pr.cur_expire_dt_tm, bp_cur_abo_disp = uar_get_code_display(bp.cur_abo_cd), bp_cur_rh_disp =
   uar_get_code_display(bp.cur_rh_cd),
   pa_abo_disp = uar_get_code_display(pa.abo_cd), pa_rh_disp = uar_get_code_display(pa.rh_cd), bp
   .supplier_prefix,
   bb.exception_id, per.name_full_formatted, ea.alias,
   prs.name_full_formatted, usr.username, ac.accession,
   override_reason_disp = decode(bb.seq,uar_get_code_display(bb.override_reason_cd)," "),
   product_disp = decode(pr.seq,uar_get_code_display(pr.product_cd)," "), encntr_alias = decode(ea
    .seq,"Y","N")
   FROM bb_exception bb,
    product_event pe,
    product pr,
    blood_product bp,
    person_aborh pa,
    person per,
    (dummyt d5  WITH seq = 1),
    encntr_alias ea,
    (dummyt d6  WITH seq = 1),
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1),
    (dummyt d4  WITH seq = 1),
    encntr_prsnl_reltn epr,
    prsnl prs,
    prsnl usr,
    result re,
    accession_order_r ac
   PLAN (bb
    WHERE exception_code=bb.exception_type_cd
     AND bb.active_ind=1
     AND bb.active_status_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
    JOIN (usr
    WHERE bb.updt_id=usr.person_id)
    JOIN (pe
    WHERE bb.product_event_id=pe.product_event_id)
    JOIN (d5)
    JOIN (ea
    WHERE pe.encntr_id=ea.encntr_id
     AND ea.encntr_alias_type_cd=encntr_mrn_code
     AND ea.active_ind=1)
    JOIN (d6)
    JOIN (pr
    WHERE pe.product_id=pr.product_id
     AND (((request->cur_owner_area_cd > 0.0)
     AND (request->cur_owner_area_cd=pr.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (request->cur_inv_area_cd=pr.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
    JOIN (bp
    WHERE pe.product_id=bp.product_id)
    JOIN (per
    WHERE pe.person_id=per.person_id)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (re
    WHERE bb.result_id=re.result_id)
    JOIN (ac
    WHERE re.order_id=ac.order_id
     AND ac.primary_flag=0)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (epr
    WHERE epr.encntr_prsnl_r_cd=admitdoc
     AND pe.encntr_id=epr.encntr_id
     AND pe.encntr_id > 0
     AND epr.active_ind=1)
    JOIN (prs
    WHERE epr.prsnl_person_id=prs.person_id)
    JOIN (d4
    WHERE d4.seq=1)
    JOIN (pa
    WHERE pe.person_id=pa.person_id
     AND pa.active_ind=1)
   ORDER BY cnvtdatetime(pr.cur_expire_dt_tm), pr.product_nbr, pr.product_sub_nbr,
    bb.exception_id
   HEAD REPORT
    new_exception = "Y", formatted_acc = fillstring(20," ")
   HEAD PAGE
    beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm),
    inc_i18nhandle = 0,
    inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
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
    CALL center(captions->bb_exception,1,125),
    col 104, captions->time, col 118,
    curtime"@TIMENOSECONDS;;M", row + 1, col 104,
    captions->as_of_date, col 118, curdate"@DATECONDENSED;;d",
    row save_row, row + 1, col 1,
    captions->bb_owner, col 19, cur_owner_area_disp,
    row + 1, col 1, captions->inventory_area,
    col 17, cur_inv_area_disp, row + 2,
    col 32, captions->beg_date, col 48,
    beg_dt_tm"@DATECONDENSED;;d", col 56, beg_dt_tm"@TIMENOSECONDS;;M",
    col 69, captions->end_date, col 82,
    end_dt_tm"@DATECONDENSED;;d", col 90, end_dt_tm"@TIMENOSECONDS;;M",
    row + 2, col 1, exception_disp,
    row + 2,
    CALL center(captions->product_number,17,41),
    CALL center(captions->aborh,62,78),
    CALL center(captions->name,80,98),
    CALL center(captions->physician,100,118), row + 1,
    col 1, captions->expired, col 9,
    captions->xmd,
    CALL center(captions->accession_number,17,41),
    CALL center(captions->product_type,43,60),
    CALL center(captions->unit,62,69),
    CALL center(captions->patient,71,78),
    CALL center(captions->alias,80,98),
    CALL center(captions->reason,100,118),
    CALL center(captions->tech,120,125), row + 1,
    col 1, "-------", col 9,
    "-------", col 17, "-------------------------",
    col 43, "------------------", col 62,
    "--------", col 71, "--------",
    col 80, "-------------------", col 100,
    "-------------------", col 120, "------",
    row + 1
   HEAD bb.exception_id
    new_exception = "Y", encntr_alias_disp = fillstring(30," ")
   DETAIL
    IF (bb.exception_id > 0)
     datafoundflag = true
     IF (new_exception="Y")
      new_exception = "N", expire_dt_tm = cnvtdatetime(pr.cur_expire_dt_tm), col 1,
      expire_dt_tm"@DATECONDENSED;;d", pe_dt_tm = cnvtdatetime(pe.event_dt_tm), col 9,
      pe_dt_tm"@DATECONDENSED;;d", prod_nbr_display = concat(trim(bp.supplier_prefix),trim(pr
        .product_nbr)," ",trim(pr.product_sub_nbr)), col 17,
      prod_nbr_display, col 43, product_disp"##################",
      product_aborh_disp = fillstring(8," "), product_aborh_disp = substring(1,8,trim(concat(trim(
          bp_cur_abo_disp)," ",trim(bp_cur_rh_disp)))), col 62,
      product_aborh_disp"########", patient_aborh_disp = fillstring(8," "), patient_aborh_disp =
      substring(1,8,trim(concat(trim(pa_abo_disp)," ",trim(pa_rh_disp)))),
      col 71, patient_aborh_disp"########", col 80,
      per.name_full_formatted"###################", col 100, prs.name_full_formatted
      "###################",
      col 120, usr.username"######", row + 1
      IF (row > 56)
       BREAK
      ENDIF
      col 2, expire_dt_tm"@TIMENOSECONDS;;M", col 10,
      pe_dt_tm"@TIMENOSECONDS;;M", formatted_acc = cnvtacc(ac.accession), col 17,
      formatted_acc"####################"
      IF (encntr_alias="Y")
       encntr_alias_disp = cnvtalias(ea.alias,ea.alias_pool_cd)
      ELSE
       encntr_alias_disp = captions->not_on_file
      ENDIF
      col 80, encntr_alias_disp"###################", col 100,
      override_reason_disp"###################", row + 2
      IF (row > 56)
       BREAK
      ENDIF
     ENDIF
    ENDIF
   FOOT PAGE
    row 57, col 1, line,
    row + 1, col 1, captions->report_id,
    col 58, captions->page_no, col 64,
    curpage"###", col 100, captions->printed,
    col 109, curdate"@DATECONDENSED;;d", col 120,
    curtime"@TIMENOSECONDS;;M"
   FOOT REPORT
    row 60, col 51, captions->end_of_report
   WITH nocounter, maxrow = 61, nullreport,
    outerjoin(d2), outerjoin(d3), outerjoin(d4),
    dontcare(re), dontcare(epr), dontcare(pa),
    dontcare(ea), compress, nolandscape
  ;end select
  IF (((datafoundflag=true) OR ((request->null_ind=1))) )
   SET rpt_cnt += 1
   SET stat = alterlist(reply->rpt_list,rpt_cnt)
   SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
   SET datafoundflag = false
  ENDIF
 ENDIF
 IF (((uar_get_code_meaning(request->exception_type_cd)="EXPUNITDIS") OR ((request->exception_type_cd
 =0.0))) )
  EXECUTE cpm_create_file_name_logical "bbt_exp_unit_dis", "txt", "x"
  SET cdf_meaning = "EXPUNITDIS"
  SET exception_code = get_code_value(14072,cdf_meaning)
  SET exception_disp = uar_get_code_display(exception_code)
  SELECT INTO cpm_cfn_info->file_name_logical
   pa.abo_cd, pa.rh_cd, pr.cur_expire_dt_tm,
   pe.event_dt_tm, pe.person_id, pe.product_event_id,
   pr.product_nbr, pr.product_sub_nbr, pr.serial_number_txt,
   bp_cur_abo_disp = decode(bp.seq,uar_get_code_display(bp.cur_abo_cd)," "), bp_cur_rh_disp = decode(
    bp.seq,uar_get_code_display(bp.cur_rh_cd)," "), pa_abo_disp = uar_get_code_display(pa.abo_cd),
   pa_rh_disp = uar_get_code_display(pa.rh_cd), bb.exception_id, per.name_full_formatted,
   ea.alias, prs.name_full_formatted, usr.username,
   ac.accession, override_reason_disp = decode(bb.seq,uar_get_code_display(bb.override_reason_cd)," "
    ), product_disp = decode(pr.seq,uar_get_code_display(pr.product_cd)," "),
   encntr_alias = decode(ea.seq,"Y","N")
   FROM bb_exception bb,
    product_event pe,
    product pr,
    person_aborh pa,
    person per,
    encntr_alias ea,
    (dummyt d1  WITH seq = 1),
    (dummyt d2  WITH seq = 1),
    (dummyt d4  WITH seq = 1),
    (dummyt d5  WITH seq = 1),
    encntr_prsnl_reltn epr,
    prsnl prs,
    prsnl usr,
    blood_product bp
   PLAN (bb
    WHERE exception_code=bb.exception_type_cd
     AND bb.active_ind=1
     AND bb.active_status_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
    JOIN (usr
    WHERE bb.updt_id=usr.person_id)
    JOIN (pe
    WHERE bb.product_event_id=pe.product_event_id)
    JOIN (pr
    WHERE pe.product_id=pr.product_id
     AND (((request->cur_owner_area_cd > 0.0)
     AND (request->cur_owner_area_cd=pr.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (request->cur_inv_area_cd=pr.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
    JOIN (per
    WHERE pe.person_id=per.person_id)
    JOIN (d5)
    JOIN (ea
    WHERE pe.encntr_id=ea.encntr_id
     AND ea.encntr_alias_type_cd=encntr_mrn_code
     AND ea.active_ind=1)
    JOIN (d1)
    JOIN (bp
    WHERE bp.product_id=pe.product_id)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (epr
    WHERE epr.encntr_prsnl_r_cd=admitdoc
     AND pe.encntr_id=epr.encntr_id
     AND pe.encntr_id > 0
     AND epr.active_ind=1)
    JOIN (prs
    WHERE epr.prsnl_person_id=prs.person_id)
    JOIN (d4
    WHERE d4.seq=1)
    JOIN (pa
    WHERE pe.person_id=pa.person_id
     AND pa.active_ind=1)
   ORDER BY cnvtdatetime(pr.cur_expire_dt_tm), pr.product_nbr, pr.product_sub_nbr,
    bb.exception_id
   HEAD REPORT
    new_exception = "Y", encntr_alias_disp = fillstring(30," "), formatted_acc = fillstring(20," ")
   HEAD PAGE
    beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm),
    inc_i18nhandle = 0,
    inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
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
    CALL center(captions->bb_exception,1,125),
    col 104, captions->time, col 118,
    curtime"@TIMENOSECONDS;;M", row + 1, col 104,
    captions->as_of_date, col 118, curdate"@DATECONDENSED;;d",
    row save_row, row + 1, col 1,
    captions->bb_owner, col 19, cur_owner_area_disp,
    row + 1, col 1, captions->inventory_area,
    col 17, cur_inv_area_disp, row + 2,
    col 32, captions->beg_date, col 48,
    beg_dt_tm"@DATECONDENSED;;d", col 56, beg_dt_tm"@TIMENOSECONDS;;M",
    col 69, captions->end_date, col 82,
    end_dt_tm"@DATECONDENSED;;d", col 90, end_dt_tm"@TIMENOSECONDS;;M",
    row + 2, col 1, exception_disp,
    row + 2, col 17, captions->product_number,
    CALL center(captions->aborh,62,78),
    CALL center(captions->name,80,98),
    CALL center(captions->physician,100,118),
    row + 1, col 1, captions->expired,
    col 9, captions->dispd, col 17,
    captions->serial_number,
    CALL center(captions->product_type,43,60),
    CALL center(captions->unit,62,69),
    CALL center(captions->patient,71,78),
    CALL center(captions->alias,80,98),
    CALL center(captions->reason,100,118),
    CALL center(captions->tech,120,125), row + 1, col 1,
    "-------", col 9, "-------",
    col 17, "-------------------------", col 43,
    "------------------", col 62, "--------",
    col 71, "--------", col 80,
    "-------------------", col 100, "-------------------",
    col 120, "------", row + 1
   HEAD bb.exception_id
    new_exception = "Y"
   DETAIL
    IF (bb.exception_id > 0)
     datafoundflag = true
     IF (new_exception="Y")
      new_exception = "N", expire_dt_tm = cnvtdatetime(pr.cur_expire_dt_tm), col 1,
      expire_dt_tm"@DATECONDENSED;;d", pe_dt_tm = cnvtdatetime(pe.event_dt_tm), col 9,
      pe_dt_tm"@DATECONDENSED;;d", prod_nbr_display = concat(trim(bp.supplier_prefix),trim(pr
        .product_nbr)," ",trim(pr.product_sub_nbr)), col 17,
      prod_nbr_display, col 43, product_disp"##################",
      product_aborh_disp = fillstring(8," "), product_aborh_disp = substring(1,8,trim(concat(trim(
          bp_cur_abo_disp)," ",trim(bp_cur_rh_disp)))), col 62,
      product_aborh_disp"########", patient_aborh_disp = fillstring(8," "), patient_aborh_disp =
      substring(1,8,trim(concat(trim(pa_abo_disp)," ",trim(pa_rh_disp)))),
      col 71, patient_aborh_disp"########"
      IF (per.person_id > 0)
       col 80, per.name_full_formatted"###################"
      ENDIF
      IF (prs.person_id > 0)
       col 100, prs.name_full_formatted"###################"
      ENDIF
      col 120, usr.username"######", row + 1
      IF (row > 56)
       BREAK
      ENDIF
      col 2, expire_dt_tm"@TIMENOSECONDS;;M", col 10,
      pe_dt_tm"@TIMENOSECONDS;;M", col 17, pr.serial_number_txt"####################"
      IF (encntr_alias="Y")
       encntr_alias_disp = cnvtalias(ea.alias,ea.alias_pool_cd)
      ELSE
       encntr_alias_disp = captions->not_on_file
      ENDIF
      col 80, encntr_alias_disp"###################", col 100,
      override_reason_disp"###################", row + 2
      IF (row > 56)
       BREAK
      ENDIF
     ENDIF
    ENDIF
   FOOT PAGE
    row 57, col 1, line,
    row + 1, col 1, captions->report_id,
    col 58, captions->page_no, col 64,
    curpage"###", col 100, captions->printed,
    col 109, curdate"@DATECONDENSED;;d", col 120,
    curtime"@TIMENOSECONDS;;M"
   FOOT REPORT
    row 60, col 51, captions->end_of_report
   WITH nocounter, maxrow = 61, nullreport,
    dontcare(ea), outerjoin(d2), outerjoin(d4),
    dontcare(epr), dontcare(pa), dontcare(bp),
    compress, nolandscape
  ;end select
  IF (((datafoundflag=true) OR ((request->null_ind=1))) )
   SET rpt_cnt += 1
   SET stat = alterlist(reply->rpt_list,rpt_cnt)
   SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
   SET datafoundflag = false
  ENDIF
 ENDIF
 IF (((uar_get_code_meaning(request->exception_type_cd)="EXPXMDIS") OR ((request->exception_type_cd=
 0.0))) )
  EXECUTE cpm_create_file_name_logical "bbt_exp_xm_dis", "txt", "x"
  SET cdf_meaning = "EXPXMDIS"
  SET exception_code = get_code_value(14072,cdf_meaning)
  SET exception_disp = uar_get_code_display(exception_code)
  SELECT INTO cpm_cfn_info->file_name_logical
   pa.abo_cd, pa.rh_cd, pr.cur_expire_dt_tm,
   pe.event_dt_tm, pe.person_id, pe.product_event_id,
   xm.crossmatch_exp_dt_tm, pr.product_nbr, pr.product_sub_nbr,
   bp_cur_abo_disp = uar_get_code_display(bp.cur_abo_cd), bp_cur_rh_disp = uar_get_code_display(bp
    .cur_rh_cd), pa_abo_disp = uar_get_code_display(pa.abo_cd),
   pa_rh_disp = uar_get_code_display(pa.rh_cd), c1.code_value, c1.display,
   bb.exception_id, per.name_full_formatted, ea.alias,
   prs.name_full_formatted, usr.username, ac.accession,
   override_reason_disp = decode(bb.seq,uar_get_code_display(bb.override_reason_cd)," "),
   product_disp = decode(pr.seq,uar_get_code_display(pr.product_cd)," "), encntr_alias = decode(ea
    .seq,"Y","N")
   FROM bb_exception bb,
    product_event pe,
    crossmatch xm,
    product_event pe_xm,
    product pr,
    blood_product bp,
    person_aborh pa,
    person per,
    (dummyt d5  WITH seq = 1),
    encntr_alias ea,
    (dummyt d6  WITH seq = 1),
    (dummyt d3  WITH seq = 1),
    (dummyt d2  WITH seq = 1),
    (dummyt d1  WITH seq = 1),
    (dummyt d4  WITH seq = 1),
    encntr_prsnl_reltn epr,
    prsnl prs,
    prsnl usr,
    accession_order_r ac
   PLAN (bb
    WHERE exception_code=bb.exception_type_cd
     AND bb.active_ind=1
     AND bb.active_status_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
     end_dt_tm)
     AND bb.person_id=0.0)
    JOIN (usr
    WHERE bb.updt_id=usr.person_id)
    JOIN (pe
    WHERE bb.product_event_id=pe.product_event_id)
    JOIN (d5)
    JOIN (ea
    WHERE pe.encntr_id=ea.encntr_id
     AND ea.encntr_alias_type_cd=encntr_mrn_code
     AND ea.active_ind=1)
    JOIN (d6)
    JOIN (xm
    WHERE pe.related_product_event_id=xm.product_event_id)
    JOIN (pe_xm
    WHERE pe_xm.product_event_id=xm.product_event_id
     AND pe_xm.product_event_id > 0.0
     AND pe_xm.product_event_id != null)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (ac
    WHERE ac.order_id=pe_xm.order_id
     AND pe_xm.order_id > 0
     AND pe_xm.order_id != null
     AND ac.primary_flag=0)
    JOIN (d1)
    JOIN (pr
    WHERE pe.product_id=pr.product_id
     AND (((request->cur_owner_area_cd > 0.0)
     AND (request->cur_owner_area_cd=pr.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (request->cur_inv_area_cd=pr.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
    JOIN (bp
    WHERE pe.product_id=bp.product_id)
    JOIN (per
    WHERE pe.person_id=per.person_id)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (epr
    WHERE epr.encntr_prsnl_r_cd=admitdoc
     AND pe.encntr_id=epr.encntr_id
     AND pe.encntr_id > 0
     AND epr.active_ind=1)
    JOIN (prs
    WHERE epr.prsnl_person_id=prs.person_id)
    JOIN (d4
    WHERE d4.seq=1)
    JOIN (pa
    WHERE pe.person_id=pa.person_id
     AND pa.active_ind=1)
   ORDER BY cnvtdatetime(pr.cur_expire_dt_tm), pr.product_nbr, pr.product_sub_nbr,
    bb.exception_id
   HEAD REPORT
    new_exception = "Y", encntr_alias_disp = fillstring(30," "), formatted_acc = fillstring(20," ")
   HEAD PAGE
    beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm),
    inc_i18nhandle = 0,
    inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
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
    CALL center(captions->bb_exception,1,125),
    col 104, captions->time, col 118,
    curtime"@TIMENOSECONDS;;M", row + 1, col 104,
    captions->as_of_date, col 118, curdate"@DATECONDENSED;;d",
    row save_row, row + 1, col 1,
    captions->bb_owner, col 19, cur_owner_area_disp,
    row + 1, col 1, captions->inventory_area,
    col 17, cur_inv_area_disp, row + 2,
    col 32, captions->beg_date, col 48,
    beg_dt_tm"@DATECONDENSED;;d", col 56, beg_dt_tm"@TIMENOSECONDS;;M",
    col 69, captions->end_date, col 82,
    end_dt_tm"@DATECONDENSED;;d", col 90, end_dt_tm"@TIMENOSECONDS;;M",
    row + 2, col 1, exception_disp,
    row + 2, col 3, captions->xm,
    CALL center(captions->product_number,17,41),
    CALL center(captions->aborh,62,78),
    CALL center(captions->name,80,98),
    CALL center(captions->physician,100,118), row + 1, col 1,
    captions->expired, col 9, captions->dispd,
    CALL center(captions->accession_number,17,41),
    CALL center(captions->product_type,43,60),
    CALL center(captions->unit,62,69),
    CALL center(captions->patient,71,78),
    CALL center(captions->alias,80,98),
    CALL center(captions->reason,100,118),
    CALL center(captions->tech,120,125), row + 1, col 1,
    "-------", col 9, "-------",
    col 17, "-------------------------", col 43,
    "------------------", col 62, "--------",
    col 71, "--------", col 80,
    "-------------------", col 100, "-------------------",
    col 120, "------", row + 1
   HEAD bb.exception_id
    new_exception = "Y"
   DETAIL
    IF (bb.exception_id > 0)
     datafoundflag = true
     IF (new_exception="Y")
      new_exception = "N", expire_dt_tm = cnvtdatetime(xm.crossmatch_exp_dt_tm), col 1,
      expire_dt_tm"@DATECONDENSED;;d", pe_dt_tm = cnvtdatetime(pe.event_dt_tm), col 9,
      pe_dt_tm"@DATECONDENSED;;d", product_nbr_display = concat(trim(bp.supplier_prefix),trim(pr
        .product_nbr)," ",trim(pr.product_sub_nbr)), col 17,
      product_nbr_display, col 43, product_disp"##################",
      product_aborh_disp = fillstring(8," "), product_aborh_disp = substring(1,8,trim(concat(trim(
          bp_cur_abo_disp)," ",trim(bp_cur_rh_disp)))), col 62,
      product_aborh_disp"########", patient_aborh_disp = fillstring(8," "), patient_aborh_disp =
      substring(1,8,trim(concat(trim(pa_abo_disp)," ",trim(pa_rh_disp)))),
      col 71, patient_aborh_disp"########", col 80,
      per.name_full_formatted"###################", col 100, prs.name_full_formatted
      "###################",
      col 120, usr.username"######", row + 1
      IF (row > 56)
       BREAK
      ENDIF
      col 2, expire_dt_tm"@TIMENOSECONDS;;M", col 10,
      pe_dt_tm"@TIMENOSECONDS;;M", formatted_acc = cnvtacc(ac.accession), col 17,
      formatted_acc"####################"
      IF (encntr_alias="Y")
       encntr_alias_disp = cnvtalias(ea.alias,ea.alias_pool_cd)
      ELSE
       encntr_alias_disp = captions->not_on_file
      ENDIF
      col 80, encntr_alias_disp"###################", col 100,
      override_reason_disp"###################", row + 2
      IF (row > 56)
       BREAK
      ENDIF
     ENDIF
    ENDIF
   FOOT PAGE
    row 57, col 1, line,
    row + 1, col 1, captions->report_id,
    col 58, captions->page_no, col 64,
    curpage"###", col 100, captions->printed,
    col 109, curdate"@DATECONDENSED;;d", col 120,
    curtime"@TIMENOSECONDS;;M"
   FOOT REPORT
    row 60, col 51, captions->end_of_report
   WITH nocounter, maxrow = 61, nullreport,
    outerjoin(d2), outerjoin(d4), dontcare(epr),
    dontcare(pa), dontcare(ac), dontcare(ea),
    compress, nolandscape
  ;end select
  IF (((datafoundflag=true) OR ((request->null_ind=1))) )
   SET rpt_cnt += 1
   SET stat = alterlist(reply->rpt_list,rpt_cnt)
   SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
   SET datafoundflag = false
  ENDIF
 ENDIF
 IF (((uar_get_code_meaning(request->exception_type_cd)="EXPSPECIMEN") OR ((request->
 exception_type_cd=0.0))) )
  EXECUTE cpm_create_file_name_logical "bbt_exp_specimen", "txt", "x"
  SET cdf_meaning = "EXPSPECIMEN"
  SET exception_code = get_code_value(14072,cdf_meaning)
  SET exception_disp = uar_get_code_display(exception_code)
  SELECT INTO cpm_cfn_info->file_name_logical
   xm.crossmatch_exp_dt_tm, pa.abo_cd, pa.rh_cd,
   pr.cur_expire_dt_tm, pe.event_dt_tm, pe.person_id,
   pe.product_event_id, pr.product_nbr, pr.product_sub_nbr,
   bp_cur_abo_disp = uar_get_code_display(bp.cur_abo_cd), bp_cur_rh_disp = uar_get_code_display(bp
    .cur_rh_cd), pa_abo_disp = uar_get_code_display(pa.abo_cd),
   pa_rh_disp = uar_get_code_display(pa.rh_cd), bb.exception_id, per.name_full_formatted,
   ea.alias, prs.name_full_formatted, usr.username,
   ac.accession, override_reason_disp = decode(bb.seq,uar_get_code_display(bb.override_reason_cd)," "
    ), product_disp = decode(pr.seq,uar_get_code_display(pr.product_cd)," "),
   encntr_alias = decode(ea.seq,"Y","N")
   FROM bb_exception bb,
    product_event pe,
    crossmatch xm,
    product pr,
    blood_product bp,
    person_aborh pa,
    person per,
    (dummyt d5  WITH seq = 1),
    encntr_alias ea,
    (dummyt d6  WITH seq = 1),
    (dummyt d3  WITH seq = 1),
    (dummyt d2  WITH seq = 1),
    (dummyt d4  WITH seq = 1),
    encntr_prsnl_reltn epr,
    prsnl prs,
    prsnl usr,
    result re,
    accession_order_r ac
   PLAN (bb
    WHERE exception_code=bb.exception_type_cd
     AND bb.active_ind=1
     AND bb.active_status_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
    JOIN (usr
    WHERE bb.updt_id=usr.person_id)
    JOIN (pe
    WHERE bb.product_event_id=pe.product_event_id)
    JOIN (d5)
    JOIN (ea
    WHERE pe.encntr_id=ea.encntr_id
     AND ea.encntr_alias_type_cd=encntr_mrn_code
     AND ea.active_ind=1)
    JOIN (d6)
    JOIN (xm
    WHERE pe.product_event_id=xm.product_event_id)
    JOIN (pr
    WHERE pe.product_id=pr.product_id
     AND (((request->cur_owner_area_cd > 0.0)
     AND (request->cur_owner_area_cd=pr.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (request->cur_inv_area_cd=pr.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
    JOIN (bp
    WHERE pe.product_id=bp.product_id)
    JOIN (per
    WHERE pe.person_id=per.person_id)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (re
    WHERE bb.result_id=re.result_id)
    JOIN (ac
    WHERE re.order_id=ac.order_id
     AND ac.primary_flag=0)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (epr
    WHERE epr.encntr_prsnl_r_cd=admitdoc
     AND pe.encntr_id=epr.encntr_id
     AND pe.encntr_id > 0
     AND epr.active_ind=1)
    JOIN (prs
    WHERE epr.prsnl_person_id=prs.person_id)
    JOIN (d4
    WHERE d4.seq=1)
    JOIN (pa
    WHERE pe.person_id=pa.person_id
     AND pa.active_ind=1)
   ORDER BY cnvtdatetime(xm.crossmatch_exp_dt_tm), pr.product_nbr, pr.product_sub_nbr,
    bb.exception_id
   HEAD REPORT
    new_exception = "Y", encntr_alias_disp = fillstring(30," "), formatted_acc = fillstring(20," ")
   HEAD PAGE
    beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm),
    inc_i18nhandle = 0,
    inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
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
    CALL center(captions->bb_exception,1,125),
    col 104, captions->time, col 118,
    curtime"@TIMENOSECONDS;;M", row + 1, col 104,
    captions->as_of_date, col 118, curdate"@DATECONDENSED;;d",
    row save_row, row + 1, col 1,
    captions->bb_owner, col 19, cur_owner_area_disp,
    row + 1, col 1, captions->inventory_area,
    col 17, cur_inv_area_disp, row + 2,
    col 32, captions->beg_date, col 48,
    beg_dt_tm"@DATECONDENSED;;d", col 56, beg_dt_tm"@TIMENOSECONDS;;M",
    col 69, captions->end_date, col 82,
    end_dt_tm"@DATECONDENSED;;d", col 90, end_dt_tm"@TIMENOSECONDS;;M",
    row + 2, col 1, exception_disp,
    row + 2,
    CALL center(captions->product_number,17,41),
    CALL center(captions->aborh,62,78),
    CALL center(captions->name,80,98),
    CALL center(captions->physician,100,118), row + 1,
    col 1, captions->expired, col 9,
    captions->xmd,
    CALL center(captions->accession_number,17,41),
    CALL center(captions->product_type,43,60),
    CALL center(captions->unit,62,69),
    CALL center(captions->patient,71,78),
    CALL center(captions->alias,80,98),
    CALL center(captions->reason,100,118),
    CALL center(captions->tech,120,125), row + 1,
    col 1, "-------", col 9,
    "-------", col 17, "-------------------------",
    col 43, "------------------", col 62,
    "--------", col 71, "--------",
    col 80, "-------------------", col 100,
    "-------------------", col 120, "------",
    row + 1
   HEAD bb.exception_id
    new_exception = "Y"
   DETAIL
    IF (bb.exception_id > 0)
     datafoundflag = true
     IF (new_exception="Y")
      new_exception = "N", expire_dt_tm = cnvtdatetime(xm.crossmatch_exp_dt_tm), col 1,
      expire_dt_tm"@DATECONDENSED;;d", pe_dt_tm = cnvtdatetime(pe.event_dt_tm), col 9,
      pe_dt_tm"@DATECONDENSED;;d", prod_nbr_display = concat(trim(bp.supplier_prefix),trim(pr
        .product_nbr)," ",trim(pr.product_sub_nbr)), col 17,
      prod_nbr_display, col 43, product_disp"##################",
      product_aborh_disp = fillstring(8," "), product_aborh_disp = substring(1,8,trim(concat(trim(
          bp_cur_abo_disp)," ",trim(bp_cur_rh_disp)))), col 62,
      product_aborh_disp"########", patient_aborh_disp = fillstring(8," "), patient_aborh_disp =
      substring(1,8,trim(concat(trim(pa_abo_disp)," ",trim(pa_rh_disp)))),
      col 71, patient_aborh_disp"########", col 80,
      per.name_full_formatted"###################", col 100, prs.name_full_formatted
      "###################",
      col 120, usr.username"######", row + 1
      IF (row > 56)
       BREAK
      ENDIF
      col 2, expire_dt_tm"@TIMENOSECONDS;;M", col 10,
      pe_dt_tm"@TIMENOSECONDS;;M", formatted_acc = cnvtacc(ac.accession), col 17,
      formatted_acc"####################"
      IF (encntr_alias="Y")
       encntr_alias_disp = cnvtalias(ea.alias,ea.alias_pool_cd)
      ELSE
       encntr_alias_disp = captions->not_on_file
      ENDIF
      col 80, encntr_alias_disp"###################", col 100,
      override_reason_disp"###################", row + 2
      IF (row > 56)
       BREAK
      ENDIF
     ENDIF
    ENDIF
   FOOT PAGE
    row 57, col 1, line,
    row + 1, col 1, captions->report_id,
    col 58, captions->page_no, col 64,
    curpage"###", col 100, captions->printed,
    col 109, curdate"@DATECONDENSED;;d", col 120,
    curtime"@TIMENOSECONDS;;M"
   FOOT REPORT
    row 60, col 51, captions->end_of_report
   WITH nocounter, maxrow = 61, nullreport,
    outerjoin(d2), outerjoin(d3), outerjoin(d4),
    dontcare(re), dontcare(epr), dontcare(pa),
    dontcare(ea), compress, nolandscape
  ;end select
  IF (((datafoundflag=true) OR ((request->null_ind=1))) )
   SET rpt_cnt += 1
   SET stat = alterlist(reply->rpt_list,rpt_cnt)
   SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
   SET datafoundflag = false
  ENDIF
 ENDIF
 IF (((uar_get_code_meaning(request->exception_type_cd)="UNCROSSDIS") OR ((request->exception_type_cd
 =0.0))) )
  EXECUTE cpm_create_file_name_logical "bbt_uncross_dis", "txt", "x"
  SET cdf_meaning = "UNCROSSDIS"
  SET exception_code = get_code_value(14072,cdf_meaning)
  SET exception_disp = uar_get_code_display(exception_code)
  SELECT INTO cpm_cfn_info->file_name_logical
   pa.abo_cd, pa.rh_cd, pr.cur_expire_dt_tm,
   pe.event_dt_tm, pe.person_id, pe.product_event_id,
   pr.product_nbr, pr.product_sub_nbr, bp_cur_abo_disp = uar_get_code_display(bp.cur_abo_cd),
   bp_cur_rh_disp = uar_get_code_display(bp.cur_rh_cd), pa_abo_disp = uar_get_code_display(pa.abo_cd),
   pa_rh_disp = uar_get_code_display(pa.rh_cd),
   bb.exception_id, per.name_full_formatted, ea.alias,
   prs.name_full_formatted, usr.username, ac.accession,
   override_reason_disp = decode(bb.seq,uar_get_code_display(bb.override_reason_cd)," "),
   product_disp = decode(pr.seq,uar_get_code_display(pr.product_cd)," "), encntr_alias = decode(ea
    .seq,"Y","N")
   FROM bb_exception bb,
    product_event pe,
    product pr,
    blood_product bp,
    person_aborh pa,
    person per,
    (dummyt d5  WITH seq = 1),
    encntr_alias ea,
    (dummyt d6  WITH seq = 1),
    (dummyt d3  WITH seq = 1),
    (dummyt d2  WITH seq = 1),
    (dummyt d4  WITH seq = 1),
    encntr_prsnl_reltn epr,
    prsnl prs,
    prsnl usr,
    result re,
    accession_order_r ac
   PLAN (bb
    WHERE exception_code=bb.exception_type_cd
     AND bb.active_ind=1
     AND bb.active_status_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
    JOIN (usr
    WHERE bb.updt_id=usr.person_id)
    JOIN (pe
    WHERE bb.product_event_id=pe.product_event_id)
    JOIN (d5)
    JOIN (ea
    WHERE pe.encntr_id=ea.encntr_id
     AND ea.encntr_alias_type_cd=encntr_mrn_code
     AND ea.active_ind=1)
    JOIN (d6)
    JOIN (pr
    WHERE pe.product_id=pr.product_id
     AND (((request->cur_owner_area_cd > 0.0)
     AND (request->cur_owner_area_cd=pr.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (request->cur_inv_area_cd=pr.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
    JOIN (bp
    WHERE pe.product_id=bp.product_id)
    JOIN (per
    WHERE pe.person_id=per.person_id)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (re
    WHERE bb.result_id=re.result_id)
    JOIN (ac
    WHERE re.order_id=ac.order_id
     AND ac.primary_flag=0)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (epr
    WHERE epr.encntr_prsnl_r_cd=admitdoc
     AND pe.encntr_id=epr.encntr_id
     AND pe.encntr_id > 0
     AND epr.active_ind=1)
    JOIN (prs
    WHERE epr.prsnl_person_id=prs.person_id)
    JOIN (d4
    WHERE d4.seq=1)
    JOIN (pa
    WHERE pe.person_id=pa.person_id
     AND pa.active_ind=1)
   ORDER BY cnvtdatetime(pe.event_dt_tm), pr.product_nbr, pr.product_sub_nbr,
    bb.exception_id
   HEAD REPORT
    new_exception = "Y", formatted_acc = fillstring(20," ")
   HEAD PAGE
    beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm),
    inc_i18nhandle = 0,
    inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
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
    CALL center(captions->bb_exception,1,125),
    col 104, captions->time, col 118,
    curtime"@TIMENOSECONDS;;M", row save_row, row + 1,
    col 1, captions->bb_owner, col 19,
    cur_owner_area_disp, row + 1, col 1,
    captions->inventory_area, col 17, cur_inv_area_disp,
    row + 2, col 104, captions->as_of_date,
    col 118, curdate"@DATECONDENSED;;d", row + 1,
    col 32, captions->beg_date, col 48,
    beg_dt_tm"@DATECONDENSED;;d", col 56, beg_dt_tm"@TIMENOSECONDS;;M",
    col 69, captions->end_date, col 82,
    end_dt_tm"@DATECONDENSED;;d", col 90, end_dt_tm"@TIMENOSECONDS;;M",
    row + 2, col 1, exception_disp,
    row + 2,
    CALL center(captions->product_number,9,33),
    CALL center(captions->aborh,54,76),
    CALL center(captions->name,78,97),
    CALL center(captions->physician,99,118), row + 1,
    col 1, captions->dispd,
    CALL center(captions->accession_number,9,33),
    CALL center(captions->product_type,35,52),
    CALL center(captions->unit,54,64),
    CALL center(captions->patient,66,76),
    CALL center(captions->alias,78,97),
    CALL center(captions->reason,99,118),
    CALL center(captions->tech,120,125),
    row + 1, col 1, "-------",
    col 9, "-------------------------", col 35,
    "------------------", col 54, "-----------",
    col 66, "-----------", col 78,
    "--------------------", col 99, "--------------------",
    col 120, "------", row + 1
   HEAD bb.exception_id
    new_exception = "Y"
   DETAIL
    IF (bb.exception_id > 0)
     datafoundflag = true
     IF (new_exception="Y")
      new_exception = "N", pe_dt_tm = cnvtdatetime(pe.event_dt_tm), col 1,
      pe_dt_tm"@DATECONDENSED;;d", prod_nbr_display = concat(trim(bp.supplier_prefix),trim(pr
        .product_nbr)," ",trim(pr.product_sub_nbr)), col 9,
      prod_nbr_display, col 35, product_disp"##################",
      product_aborh_disp = fillstring(11," "), product_aborh_disp = substring(1,11,trim(concat(trim(
          bp_cur_abo_disp)," ",trim(bp_cur_rh_disp)))), col 54,
      product_aborh_disp"###########", patient_aborh_disp = fillstring(11," "), patient_aborh_disp =
      substring(1,11,trim(concat(trim(pa_abo_disp)," ",trim(pa_rh_disp)))),
      col 66, patient_aborh_disp"###########", col 78,
      per.name_full_formatted"####################", col 99, prs.name_full_formatted
      "####################",
      col 120, usr.username"######", row + 1
      IF (row > 56)
       BREAK
      ENDIF
      col 2, pe_dt_tm"@TIMENOSECONDS;;M", formatted_acc = cnvtacc(ac.accession),
      col 9, formatted_acc"####################"
      IF (encntr_alias="Y")
       encntr_alias_disp = cnvtalias(ea.alias,ea.alias_pool_cd)
      ELSE
       encntr_alias_disp = captions->not_on_file
      ENDIF
      col 78, encntr_alias_disp"####################", col 99,
      override_reason_disp"####################", row + 2
      IF (row > 56)
       BREAK
      ENDIF
     ENDIF
    ENDIF
   FOOT PAGE
    row 57, col 1, line,
    row + 1, col 1, captions->report_id,
    col 58, captions->page_no, col 64,
    curpage"###", col 100, captions->printed,
    col 109, curdate"@DATECONDENSED;;d", col 120,
    curtime"@TIMENOSECONDS;;M"
   FOOT REPORT
    row 60, col 51, captions->end_of_report
   WITH nocounter, maxrow = 61, nullreport,
    outerjoin(d2), outerjoin(d3), outerjoin(d4),
    dontcare(re), dontcare(epr), dontcare(pa),
    dontcare(ea), compress, nolandscape
  ;end select
  IF (((datafoundflag=true) OR ((request->null_ind=1))) )
   SET rpt_cnt += 1
   SET stat = alterlist(reply->rpt_list,rpt_cnt)
   SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
   SET datafoundflag = false
  ENDIF
 ENDIF
 IF (((uar_get_code_meaning(request->exception_type_cd)="UNCONFDIS") OR ((request->exception_type_cd=
 0.0))) )
  EXECUTE cpm_create_file_name_logical "bbt_unconf_dis", "txt", "x"
  SET cdf_meaning = "UNCONFDIS"
  SET exception_code = get_code_value(14072,cdf_meaning)
  SET exception_disp = uar_get_code_display(exception_code)
  SELECT INTO cpm_cfn_info->file_name_logical
   pa.abo_cd, pa.rh_cd, pr.cur_expire_dt_tm,
   pe.event_dt_tm, pe.person_id, pe.product_event_id,
   pr.product_nbr, pr.product_sub_nbr, bp_cur_abo_disp = uar_get_code_display(bp.cur_abo_cd),
   bp_cur_rh_disp = uar_get_code_display(bp.cur_rh_cd), pa_abo_disp = uar_get_code_display(pa.abo_cd),
   pa_rh_disp = uar_get_code_display(pa.rh_cd),
   bb.exception_id, per.name_full_formatted, ea.alias,
   prs.name_full_formatted, usr.username, ac.accession,
   override_reason_disp = decode(bb.seq,uar_get_code_display(bb.override_reason_cd)," "),
   product_disp = decode(pr.seq,uar_get_code_display(pr.product_cd)," "), encntr_alias = decode(ea
    .seq,"Y","N")
   FROM bb_exception bb,
    product_event pe,
    product pr,
    blood_product bp,
    person_aborh pa,
    person per,
    (dummyt d5  WITH seq = 1),
    encntr_alias ea,
    (dummyt d6  WITH seq = 1),
    (dummyt d3  WITH seq = 1),
    (dummyt d2  WITH seq = 1),
    (dummyt d4  WITH seq = 1),
    encntr_prsnl_reltn epr,
    prsnl prs,
    prsnl usr,
    result re,
    accession_order_r ac
   PLAN (bb
    WHERE exception_code=bb.exception_type_cd
     AND bb.active_ind=1
     AND bb.active_status_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
    JOIN (usr
    WHERE bb.updt_id=usr.person_id)
    JOIN (pe
    WHERE bb.product_event_id=pe.product_event_id)
    JOIN (d5)
    JOIN (ea
    WHERE pe.encntr_id=ea.encntr_id
     AND ea.encntr_alias_type_cd=encntr_mrn_code
     AND ea.active_ind=1)
    JOIN (d6)
    JOIN (pr
    WHERE pe.product_id=pr.product_id
     AND (((request->cur_owner_area_cd > 0.0)
     AND (request->cur_owner_area_cd=pr.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (request->cur_inv_area_cd=pr.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
    JOIN (bp
    WHERE pe.product_id=bp.product_id)
    JOIN (per
    WHERE pe.person_id=per.person_id)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (re
    WHERE bb.result_id=re.result_id)
    JOIN (ac
    WHERE re.order_id=ac.order_id
     AND ac.primary_flag=0)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (epr
    WHERE epr.encntr_prsnl_r_cd=admitdoc
     AND pe.encntr_id=epr.encntr_id
     AND pe.encntr_id > 0
     AND epr.active_ind=1)
    JOIN (prs
    WHERE epr.prsnl_person_id=prs.person_id)
    JOIN (d4
    WHERE d4.seq=1)
    JOIN (pa
    WHERE pe.person_id=pa.person_id
     AND pa.active_ind=1)
   ORDER BY cnvtdatetime(pe.event_dt_tm), pr.product_nbr, pr.product_sub_nbr,
    bb.exception_id
   HEAD REPORT
    new_exception = "Y", encntr_alias_disp = fillstring(30," "), formatted_acc = fillstring(20," ")
   HEAD PAGE
    beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm),
    inc_i18nhandle = 0,
    inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
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
    CALL center(captions->bb_exception,1,125),
    col 104, captions->time, col 118,
    curtime"@TIMENOSECONDS;;M", row + 1, col 104,
    captions->as_of_date, col 118, curdate"@DATECONDENSED;;d",
    row save_row, row + 1, col 1,
    captions->bb_owner, col 19, cur_owner_area_disp,
    row + 1, col 1, captions->inventory_area,
    col 17, cur_inv_area_disp, row + 2,
    col 32, captions->beg_date, col 48,
    beg_dt_tm"@DATECONDENSED;;d", col 56, beg_dt_tm"@TIMENOSECONDS;;M",
    col 69, captions->end_date, col 82,
    end_dt_tm"@DATECONDENSED;;d", col 90, end_dt_tm"@TIMENOSECONDS;;M",
    row + 2, col 1, exception_disp,
    row + 2,
    CALL center(captions->product_number,9,33),
    CALL center(captions->aborh,54,76),
    CALL center(captions->name,78,97),
    CALL center(captions->physician,99,118), row + 1,
    col 1, captions->dispd,
    CALL center(captions->accession_number,9,33),
    CALL center(captions->product_type,35,52),
    CALL center(captions->unit,54,64),
    CALL center(captions->patient,66,76),
    CALL center(captions->alias,78,97),
    CALL center(captions->reason,99,118),
    CALL center(captions->tech,120,125),
    row + 1, col 1, "-------",
    col 9, "-------------------------", col 35,
    "------------------", col 54, "-----------",
    col 66, "-----------", col 78,
    "--------------------", col 99, "--------------------",
    col 120, "------", row + 1
   HEAD bb.exception_id
    new_exception = "Y"
   DETAIL
    IF (bb.exception_id > 0)
     datafoundflag = true
     IF (new_exception="Y")
      new_exception = "N", pe_dt_tm = cnvtdatetime(pe.event_dt_tm), col 1,
      pe_dt_tm"@DATECONDENSED;;d", prod_nbr_display = concat(trim(bp.supplier_prefix),trim(pr
        .product_nbr)," ",trim(pr.product_sub_nbr)), col 9,
      prod_nbr_display, col 35, product_disp"##################",
      product_aborh_disp = fillstring(11," "), product_aborh_disp = substring(1,11,trim(concat(trim(
          bp_cur_abo_disp)," ",trim(bp_cur_rh_disp)))), col 54,
      product_aborh_disp"###########", patient_aborh_disp = fillstring(11," "), patient_aborh_disp =
      substring(1,11,trim(concat(trim(pa_abo_disp)," ",trim(pa_rh_disp)))),
      col 66, patient_aborh_disp"###########", col 78,
      per.name_full_formatted"####################", col 99, prs.name_full_formatted
      "####################",
      col 120, usr.username"######", row + 1
      IF (row > 56)
       BREAK
      ENDIF
      col 2, pe_dt_tm"@TIMENOSECONDS;;M", formatted_acc = cnvtacc(ac.accession),
      col 9, formatted_acc"####################"
      IF (encntr_alias="Y")
       encntr_alias_disp = cnvtalias(ea.alias,ea.alias_pool_cd)
      ELSE
       encntr_alias_disp = captions->not_on_file
      ENDIF
      col 78, encntr_alias_disp"####################", col 99,
      override_reason_disp"####################", row + 2
      IF (row > 56)
       BREAK
      ENDIF
     ENDIF
    ENDIF
   FOOT PAGE
    row 57, col 1, line,
    row + 1, col 1, captions->report_id,
    col 58, captions->page_no, col 64,
    curpage"###", col 100, captions->printed,
    col 109, curdate"@DATECONDENSED;;d", col 120,
    curtime"@TIMENOSECONDS;;M"
   FOOT REPORT
    row 60, col 51, captions->end_of_report
   WITH nocounter, maxrow = 61, nullreport,
    outerjoin(d2), outerjoin(d3), outerjoin(d4),
    dontcare(re), dontcare(epr), dontcare(pa),
    dontcare(ea), compress, nolandscape
  ;end select
  IF (((datafoundflag=true) OR ((request->null_ind=1))) )
   SET rpt_cnt += 1
   SET stat = alterlist(reply->rpt_list,rpt_cnt)
   SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
   SET datafoundflag = false
  ENDIF
 ENDIF
 IF (((uar_get_code_meaning(request->exception_type_cd)="NOVLDPRODORD") OR ((request->
 exception_type_cd=0.0))) )
  SET stat = bbtgetencounterlocations(request->facility_cd,pref_level_bb)
  IF ((stat=- (1)))
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
  SET facidx = 0
  EXECUTE cpm_create_file_name_logical "bbt_novldprodord_dis", "txt", "x"
  SET cdf_meaning = "NOVLDPRODORD"
  SET exception_code = get_code_value(14072,cdf_meaning)
  SET exception_disp = uar_get_code_display(exception_code)
  IF ((request->facility_cd > 0))
   SET facility_disp = uar_get_code_display(request->facility_cd)
  ENDIF
  SET page_break = "Y"
  SELECT INTO cpm_cfn_info->file_name_logical
   override_reason_disp = decode(bb.seq,uar_get_code_display(bb.override_reason_cd)," "),
   product_disp = decode(pr.seq,uar_get_code_display(pr.product_cd)," "), encntr_alias = decode(ea
    .seq,"Y","N"),
   supplier_prefix = decode(bp.seq,bp.supplier_prefix," "), order_disp = decode(o.seq,o
    .order_mnemonic," "), has_prod_order = decode(o.seq,1,0),
   ordering_physician = decode(ph.seq,trim(ph.name_full_formatted)," ")
   FROM bb_exception bb,
    bb_invld_prod_ord_exceptn bi,
    product_event pe,
    patient_dispense pd,
    product pr,
    blood_product bp,
    person per,
    encntr_alias ea,
    (dummyt d1  WITH seq = 1),
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1),
    prsnl usr,
    accession_order_r ac,
    orders o,
    encounter e,
    prsnl ph
   PLAN (bb
    WHERE exception_code=bb.exception_type_cd
     AND bb.active_ind=1
     AND bb.active_status_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
    JOIN (bi
    WHERE bb.exception_id=bi.exception_id)
    JOIN (usr
    WHERE bb.updt_id=usr.person_id)
    JOIN (pe
    WHERE bb.product_event_id=pe.product_event_id)
    JOIN (pd
    WHERE pe.product_event_id=pd.product_event_id)
    JOIN (pr
    WHERE pe.product_id=pr.product_id
     AND (((request->cur_owner_area_cd > 0.0)
     AND (request->cur_owner_area_cd=pr.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (request->cur_inv_area_cd=pr.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
    JOIN (per
    WHERE pe.person_id=per.person_id)
    JOIN (e
    WHERE e.encntr_id=pe.encntr_id
     AND ((expand(facidx,1,size(encounterlocations->locs,5),e.loc_facility_cd,encounterlocations->
     locs[facidx].encfacilitycd)) OR ((((((e.loc_facility_cd=request->facility_cd)) OR (e.encntr_id=0
    )) ) OR ((request->facility_cd=0.0))) )) )
    JOIN (d1)
    JOIN (ea
    WHERE ea.encntr_id=pe.encntr_id
     AND ea.encntr_alias_type_cd=encntr_mrn_code
     AND ea.active_ind=1)
    JOIN (d2)
    JOIN (bp
    WHERE bp.product_id=pe.product_id)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (o
    WHERE bi.product_order_id > 0
     AND o.order_id=bi.product_order_id)
    JOIN (ac
    WHERE ac.order_id=o.order_id
     AND ac.primary_flag=0)
    JOIN (ph
    WHERE ph.person_id=o.last_update_provider_id)
   ORDER BY cnvtdatetime(pe.event_dt_tm), pr.product_nbr, pr.product_sub_nbr,
    bb.exception_id, bb.order_id
   HEAD REPORT
    encntr_alias_disp = fillstring(25," "), formatted_acc = fillstring(24," ")
   HEAD PAGE
    beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm),
    inc_i18nhandle = 0,
    inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
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
    CALL center(captions->bb_exception,1,125),
    col 104, captions->time, col 118,
    curtime"@TIMENOSECONDS;;M", row + 1, col 104,
    captions->as_of_date, col 118, curdate"@DATECONDENSED;;d",
    row save_row, row + 1, col 1,
    captions->bb_owner, col 19, cur_owner_area_disp,
    row + 1, col 1, captions->inventory_area,
    col 17, cur_inv_area_disp, row + 2,
    col 32, captions->beg_date, col 48,
    beg_dt_tm"@DATECONDENSED;;d", col 56, beg_dt_tm"@TIMENOSECONDS;;M",
    col 69, captions->end_date, col 82,
    end_dt_tm"@DATECONDENSED;;d", col 90, end_dt_tm"@TIMENOSECONDS;;M"
    IF ((request->facility_cd > 0))
     row + 2, col 1, captions->facility,
     col 11, facility_disp
    ENDIF
    row + 2, col 1, exception_disp,
    row + 2,
    CALL center(captions->name,63,88),
    CALL center(captions->override_reason,90,113),
    row + 1, col 1, captions->dispd,
    col 9, captions->product_number,
    CALL center(captions->product_type,35,61),
    CALL center(captions->alias,63,88),
    CALL center(captions->patient_location,90,113),
    CALL center(captions->tech,115,125),
    row + 1, col 9, captions->serial_number,
    row + 1, col 1, "-------",
    col 9, "------------------------", col 35,
    "--------------------------", col 63, "-------------------------",
    col 90, "-----------------------", col 115,
    "----------", row + 1, page_break = "Y"
   HEAD bb.exception_id
    IF (bb.exception_id > 0)
     datafoundflag = true
     IF (page_break="N")
      row + 1
     ENDIF
     IF (row > 55)
      BREAK
     ENDIF
     new_exception = "N", pe_dt_tm = cnvtdatetime(pe.event_dt_tm), col 1,
     pe_dt_tm"@DATECONDENSED;;d", prod_nbr_display = concat(trim(supplier_prefix),trim(pr.product_nbr
       )," ",trim(pr.product_sub_nbr)), col 9,
     prod_nbr_display"########################", col 35, product_disp"##########################",
     col 63, per.name_full_formatted"#########################", col 90,
     override_reason_disp"#######################", col 115, usr.username"##########",
     row + 1, col 2, pe_dt_tm"@TIMENOSECONDS;;M"
     IF (pr.serial_number_txt != null)
      col 9, pr.serial_number_txt
     ENDIF
     IF (encntr_alias="Y")
      encntr_alias_disp = cnvtalias(ea.alias,ea.alias_pool_cd)
     ELSE
      encntr_alias_disp = captions->not_on_file
     ENDIF
     col 63, encntr_alias_disp"#########################", patient_loc = uar_get_code_display(pd
      .dispense_to_locn_cd),
     col 90, patient_loc"#######################", row + 1
     IF (row > 53)
      BREAK
     ENDIF
     CALL center(captions->product_order,22,52),
     CALL center(captions->accession_number,54,77),
     CALL center(captions->ordering_physician,79,111),
     row + 1, col 22, "------------------------------",
     col 54, "-----------------------", col 79,
     "------------------------------", row + 1
     IF (row > 56)
      BREAK
     ENDIF
     IF (has_prod_order=1)
      col 22, order_disp"##############################", formatted_acc = cnvtacc(ac.accession),
      col 54, formatted_acc"#######################", col 79,
      ordering_physician"##############################"
     ELSE
      col 22, captions->no_prod_order"##############################", col 54,
      captions->no_prod_order"#######################", col 79, captions->no_prod_order
      "##############################"
     ENDIF
     row + 2
     IF (row > 56)
      BREAK
     ENDIF
    ENDIF
   FOOT PAGE
    row 57, col 1, line,
    row + 1, col 1, captions->report_id,
    col 58, captions->page_no, col 64,
    curpage"###", col 100, captions->printed,
    col 109, curdate"@DATECONDENSED;;d", col 120,
    curtime"@TIMENOSECONDS;;M"
   FOOT REPORT
    row 60, col 51, captions->end_of_report
   WITH nocounter, maxrow = 61, nullreport,
    outerjoin(d3), dontcare(ea), dontcare(bp),
    compress, nolandscape
  ;end select
  IF (((datafoundflag=true) OR ((request->null_ind=1))) )
   SET rpt_cnt += 1
   SET stat = alterlist(reply->rpt_list,rpt_cnt)
   SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
   SET datafoundflag = false
  ENDIF
 ENDIF
 IF (((uar_get_code_meaning(request->exception_type_cd)="UNMATDIS") OR ((request->exception_type_cd=
 0.0))) )
  EXECUTE cpm_create_file_name_logical "bbt_unmat_dis", "txt", "x"
  SET cur_row = 0
  SET new_page = "Y"
  SET cdf_meaning = "UNMATDIS"
  SET exception_code = get_code_value(14072,cdf_meaning)
  SET exception_disp = uar_get_code_display(exception_code)
  SELECT INTO cpm_cfn_info->file_name_logical
   pr.cur_expire_dt_tm, product_disp = uar_get_code_display(pr.product_cd), pe.event_dt_tm,
   pe.person_id, pe.product_event_id, pr.product_nbr,
   pr.product_sub_nbr, bp_cur_abo_disp = uar_get_code_display(bb.to_abo_cd), bp_cur_rh_disp =
   uar_get_code_display(bb.to_rh_cd),
   bp.supplier_prefix, pa_abo_disp = uar_get_code_display(bb.from_abo_cd), pa_rh_disp =
   uar_get_code_display(bb.from_rh_cd),
   c1.code_value, c1.display, bb.exception_id,
   override_reason_disp = uar_get_code_display(bb.override_reason_cd), per.name_full_formatted, pd
   .unknown_patient_text,
   ea.alias, prs.name_full_formatted, usr.username,
   table_ind = decode(per.seq,"PER",pd.seq,"PD ","XXX"), enc_ind = decode(epr.seq,"EPR",ea.seq,"EA ",
    "XXX"), encntr_alias = decode(ea.seq,"Y","N")
   FROM code_value c1,
    (dummyt d1  WITH seq = 1),
    bb_exception bb,
    product_event pe,
    product pr,
    blood_product bp,
    (dummyt d_pe  WITH seq = 1),
    person per,
    (dummyt d_ea  WITH seq = 1),
    encntr_alias ea,
    encntr_prsnl_reltn epr,
    prsnl prs,
    patient_dispense pd,
    prsnl usr
   PLAN (c1
    WHERE c1.code_set=14072
     AND c1.cdf_meaning IN ("UNMATDIS")
     AND c1.active_ind=1)
    JOIN (d1
    WHERE d1.seq=1)
    JOIN (bb
    WHERE c1.code_value=bb.exception_type_cd
     AND bb.active_ind=1
     AND bb.active_status_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
    JOIN (usr
    WHERE bb.updt_id=usr.person_id)
    JOIN (pe
    WHERE bb.product_event_id=pe.product_event_id)
    JOIN (pr
    WHERE pe.product_id=pr.product_id
     AND (((request->cur_owner_area_cd > 0.0)
     AND (request->cur_owner_area_cd=pr.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (request->cur_inv_area_cd=pr.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
    JOIN (bp
    WHERE pr.product_id=bp.product_id)
    JOIN (d_pe
    WHERE d_pe.seq=1)
    JOIN (((per
    WHERE pe.person_id=per.person_id
     AND pe.person_id > 0.0)
    JOIN (d_ea
    WHERE d_ea.seq=1)
    JOIN (((ea
    WHERE pe.encntr_id=ea.encntr_id
     AND ea.encntr_alias_type_cd=encntr_mrn_code
     AND ea.encntr_id > 0.0)
    ) ORJOIN ((epr
    WHERE pe.encntr_id=epr.encntr_id
     AND epr.encntr_prsnl_r_cd=admitdoc
     AND pe.encntr_id > 0)
    JOIN (prs
    WHERE epr.prsnl_person_id=prs.person_id
     AND prs.person_id > 0.0)
    )) ) ORJOIN ((pd
    WHERE pd.product_event_id=pe.product_event_id
     AND pe.person_id=0.0)
    ))
   ORDER BY cnvtdatetime(pe.event_dt_tm), pr.product_nbr, pr.product_sub_nbr,
    bb.exception_id, table_ind, enc_ind DESC
   HEAD REPORT
    row 0, encntr_alias_disp = fillstring(30," ")
   HEAD PAGE
    beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm),
    inc_i18nhandle = 0,
    inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
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
    CALL center(captions->bb_exception,1,125),
    col 104, captions->time, col 118,
    curtime"@TIMENOSECONDS;;M", row + 1, col 104,
    captions->as_of_date, col 118, curdate"@DATECONDENSED;;d",
    row save_row, row + 1, col 1,
    captions->bb_owner, col 19, cur_owner_area_disp,
    row + 1, col 1, captions->inventory_area,
    col 17, cur_inv_area_disp, row + 2,
    col 32, captions->beg_date, col 48,
    beg_dt_tm"@DATECONDENSED;;d", col 56, beg_dt_tm"@TIMENOSECONDS;;M",
    col 69, captions->end_date, col 82,
    end_dt_tm"@DATECONDENSED;;d", col 90, end_dt_tm"@TIMENOSECONDS;;M",
    row + 2, col 1, c1.display,
    row + 2,
    CALL center(captions->product_number,9,33),
    CALL center(captions->aborh,54,76),
    CALL center(captions->name,78,97),
    CALL center(captions->physician,99,118), row + 1,
    col 1, captions->dispd,
    CALL center(captions->accession_number,9,33),
    CALL center(captions->product_type,35,52),
    CALL center(captions->unit,54,64),
    CALL center(captions->patient,66,76),
    CALL center(captions->alias,78,97),
    CALL center(captions->reason,99,118),
    CALL center(captions->tech,120,125),
    row + 1, col 1, "-------",
    col 9, "-------------------------", col 35,
    "------------------", col 54, "-----------",
    col 66, "-----------", col 78,
    "--------------------", col 99, "--------------------",
    col 120, "------", row + 1,
    cur_row = row, new_page = "Y"
   HEAD bb.exception_id
    IF (bb.exception_id > 0.0)
     IF (row > 53)
      BREAK
     ENDIF
     IF (new_page="Y")
      new_page = "N"
     ELSE
      row + 2
     ENDIF
     pe_dt_tm = cnvtdatetime(pe.event_dt_tm), col 1, pe_dt_tm"@DATECONDENSED;;d",
     prod_nbr_display = fillstring(25," "), prod_nbr_display = concat(trim(bp.supplier_prefix),trim(
       pr.product_nbr)," ",trim(pr.product_sub_nbr)), col 9,
     prod_nbr_display, col 35, product_disp"##################",
     product_aborh_disp = fillstring(11," "), product_aborh_disp = substring(1,11,trim(concat(trim(
         bp_cur_abo_disp)," ",trim(bp_cur_rh_disp)))), col 54,
     product_aborh_disp"###########", patient_aborh_disp = fillstring(11," "), patient_aborh_disp =
     substring(1,11,trim(concat(trim(pa_abo_disp)," ",trim(pa_rh_disp)))),
     col 66, patient_aborh_disp"###########", col 120,
     usr.username"######"
     IF (table_ind="PER")
      col 78, per.name_full_formatted"####################"
     ELSEIF (table_ind="PD ")
      pat_name = concat(trim(substring(1,23,trim(pd.unknown_patient_text)))," ","*"), col 78,
      pat_name"####################"
     ENDIF
     cur_row = (row+ 1)
    ENDIF
   DETAIL
    IF (bb.exception_id > 0.0)
     datafoundflag = true
     IF (enc_ind="EPR")
      col 99, prs.name_full_formatted"####################"
     ENDIF
     IF (encntr_alias="Y")
      encntr_alias_disp = cnvtalias(ea.alias,ea.alias_pool_cd)
     ELSE
      encntr_alias_disp = captions->not_on_file
     ENDIF
     IF (cur_row > 56)
      BREAK
     ENDIF
     row cur_row, col 78, encntr_alias_disp"#########################",
     call reportmove('ROW',(cur_row - 1),0)
    ENDIF
   FOOT  bb.exception_id
    IF (bb.exception_id > 0.0)
     row + 1
     IF (row > 56)
      BREAK
     ENDIF
     col 2, pe_dt_tm"@TIMENOSECONDS;;M", col 99,
     override_reason_disp"####################"
    ENDIF
   FOOT PAGE
    row 57, col 1, line,
    row + 1, col 1, captions->report_id,
    col 58, captions->page_no, col 64,
    curpage"###", col 100, captions->printed,
    col 109, curdate"@DATECONDENSED;;d", col 120,
    curtime"@TIMENOSECONDS;;M", row + 1, col 1,
    captions->emergency_dispensed
   FOOT REPORT
    row 60, col 51, captions->end_of_report
   WITH nocounter, maxrow = 61, nullreport,
    outerjoin(d1), outerjoin(d_pe), outerjoin(d_ea),
    compress, nolandscape
  ;end select
  IF (((datafoundflag=true) OR ((request->null_ind=1))) )
   SET rpt_cnt += 1
   SET stat = alterlist(reply->rpt_list,rpt_cnt)
   SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
   SET datafoundflag = false
  ENDIF
 ENDIF
 IF (((uar_get_code_meaning(request->exception_type_cd)="UNMATXM") OR ((request->exception_type_cd=
 0.0))) )
  EXECUTE cpm_create_file_name_logical "bbt_unmat_xm", "txt", "x"
  SET cdf_meaning = "UNMATXM"
  SET exception_code = get_code_value(14072,cdf_meaning)
  SET exception_disp = uar_get_code_display(exception_code)
  SELECT INTO cpm_cfn_info->file_name_logical
   bp.supplier_prefix, pr.cur_expire_dt_tm, pe.event_dt_tm,
   pe.person_id, pe.product_event_id, pr.product_nbr,
   pr.product_sub_nbr, bp_cur_abo_disp = uar_get_code_display(bb.to_abo_cd), bp_cur_rh_disp =
   uar_get_code_display(bb.to_rh_cd),
   pa_abo_disp = uar_get_code_display(bb.from_abo_cd), pa_rh_disp = uar_get_code_display(bb
    .from_rh_cd), bb.exception_id,
   per.name_full_formatted, ea.alias, prs.name_full_formatted,
   usr.username, ac.accession, override_reason_disp = decode(bb.seq,uar_get_code_display(bb
     .override_reason_cd)," "),
   product_disp = decode(pr.seq,uar_get_code_display(pr.product_cd)," "), encntr_alias = decode(ea
    .seq,"Y","N")
   FROM bb_exception bb,
    product_event pe,
    product pr,
    blood_product bp,
    person per,
    encntr_alias ea,
    (dummyt d3  WITH seq = 1),
    (dummyt d2  WITH seq = 1),
    encntr_prsnl_reltn epr,
    prsnl prs,
    prsnl usr,
    result re,
    accession_order_r ac,
    dummyt d4,
    dummyt d5
   PLAN (bb
    WHERE exception_code=bb.exception_type_cd
     AND bb.active_ind=1
     AND bb.active_status_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
    JOIN (usr
    WHERE bb.updt_id=usr.person_id)
    JOIN (pe
    WHERE bb.product_event_id=pe.product_event_id)
    JOIN (pr
    WHERE pe.product_id=pr.product_id
     AND (((request->cur_owner_area_cd > 0.0)
     AND (request->cur_owner_area_cd=pr.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (request->cur_inv_area_cd=pr.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
    JOIN (d4)
    JOIN (ea
    WHERE pe.encntr_id=ea.encntr_id
     AND ea.encntr_alias_type_cd=encntr_mrn_code
     AND ea.active_ind=1)
    JOIN (d5)
    JOIN (bp
    WHERE pe.product_id=bp.product_id)
    JOIN (per
    WHERE pe.person_id=per.person_id)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (re
    WHERE bb.result_id=re.result_id)
    JOIN (ac
    WHERE re.order_id=ac.order_id
     AND ac.primary_flag=0)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (epr
    WHERE epr.encntr_prsnl_r_cd=admitdoc
     AND pe.encntr_id=epr.encntr_id
     AND pe.encntr_id > 0
     AND epr.active_ind=1)
    JOIN (prs
    WHERE epr.prsnl_person_id=prs.person_id)
   ORDER BY cnvtdatetime(pe.event_dt_tm), pr.product_nbr, pr.product_sub_nbr,
    bb.exception_id
   HEAD REPORT
    new_exception = "Y", encntr_alias_disp = fillstring(30," "), formatted_acc = fillstring(20," ")
   HEAD PAGE
    beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm),
    inc_i18nhandle = 0,
    inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
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
    CALL center(captions->bb_exception,1,125),
    col 104, captions->time, col 118,
    curtime"@TIMENOSECONDS;;M", row + 1, col 104,
    captions->as_of_date, col 118, curdate"@DATECONDENSED;;d",
    row save_row, row + 1, col 1,
    captions->bb_owner, col 19, cur_owner_area_disp,
    row + 1, col 1, captions->inventory_area,
    col 17, cur_inv_area_disp, row + 2,
    col 32, captions->beg_date, col 48,
    beg_dt_tm"@DATECONDENSED;;d", col 56, beg_dt_tm"@TIMENOSECONDS;;M",
    col 69, captions->end_date, col 82,
    end_dt_tm"@DATECONDENSED;;d", col 90, end_dt_tm"@TIMENOSECONDS;;M",
    row + 2, col 1, exception_disp,
    row + 2,
    CALL center(captions->product_number,9,33),
    CALL center(captions->aborh,54,76),
    CALL center(captions->name,78,97),
    CALL center(captions->physician,99,118), row + 1,
    CALL center(captions->xmd,1,7),
    CALL center(captions->accession_number,9,33),
    CALL center(captions->product_type,35,52),
    CALL center(captions->unit,54,64),
    CALL center(captions->patient,66,76),
    CALL center(captions->alias,78,97),
    CALL center(captions->reason,99,118),
    CALL center(captions->tech,120,125), row + 1,
    col 1, "-------", col 9,
    "-------------------------", col 35, "------------------",
    col 54, "-----------", col 66,
    "-----------", col 78, "--------------------",
    col 99, "--------------------", col 120,
    "------", row + 1
   HEAD bb.exception_id
    new_exception = "Y"
   DETAIL
    IF (bb.exception_id > 0)
     datafoundflag = true
     IF (new_exception="Y")
      new_exception = "N", pe_dt_tm = cnvtdatetime(pe.event_dt_tm), col 1,
      pe_dt_tm"@DATECONDENSED;;d", prod_nbr_display = concat(trim(bp.supplier_prefix),trim(pr
        .product_nbr)," ",trim(pr.product_sub_nbr)), col 9,
      prod_nbr_display, col 35, product_disp"##################",
      product_aborh_disp = fillstring(11," "), product_aborh_disp = substring(1,11,trim(concat(trim(
          bp_cur_abo_disp)," ",trim(bp_cur_rh_disp)))), col 54,
      product_aborh_disp"###########", patient_aborh_disp = fillstring(11," "), patient_aborh_disp =
      substring(1,11,trim(concat(trim(pa_abo_disp)," ",trim(pa_rh_disp)))),
      col 66, patient_aborh_disp"###########", col 78,
      per.name_full_formatted"####################", col 99, prs.name_full_formatted
      "####################",
      col 120, usr.username"######", row + 1
      IF (row > 56)
       BREAK
      ENDIF
      IF (pe_dt_tm > 0)
       col 2, pe_dt_tm"@TIMENOSECONDS;;M"
      ENDIF
      formatted_acc = cnvtacc(ac.accession), col 9, formatted_acc"####################"
      IF (encntr_alias="Y")
       encntr_alias_disp = cnvtalias(ea.alias,ea.alias_pool_cd)
      ELSE
       encntr_alias_disp = captions->not_on_file
      ENDIF
      col 78, encntr_alias_disp"####################", col 99,
      override_reason_disp"####################", row + 2
      IF (row > 56)
       BREAK
      ENDIF
     ENDIF
    ENDIF
   FOOT PAGE
    row 57, col 1, line,
    row + 1, col 1, captions->report_id,
    col 58, captions->page_no, col 64,
    curpage"###", col 100, captions->printed,
    col 109, curdate"@DATECONDENSED;;d", col 120,
    curtime"@TIMENOSECONDS;;M"
   FOOT REPORT
    row 60, col 51, captions->end_of_report
   WITH nocounter, maxrow = 61, nullreport,
    outerjoin(d2), outerjoin(d3), dontcare(re),
    dontcare(epr), outerjoin(d5), dontcare(bp),
    outerjoin(d4), dontcare(ea), compress,
    nolandscape
  ;end select
  IF (((datafoundflag=true) OR ((request->null_ind=1))) )
   SET rpt_cnt += 1
   SET stat = alterlist(reply->rpt_list,rpt_cnt)
   SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
   SET datafoundflag = false
  ENDIF
 ENDIF
 IF (((uar_get_code_meaning(request->exception_type_cd)="NOTREQDIS") OR ((request->exception_type_cd=
 0.0))) )
  EXECUTE cpm_create_file_name_logical "bbt_notreq_dis", "txt", "x"
  SET cdf_meaning = "NOTREQDIS"
  SET exception_code = get_code_value(14072,cdf_meaning)
  SET exception_disp = uar_get_code_display(exception_code)
  SELECT INTO cpm_cfn_info->file_name_logical
   d_flg = decode(bb1.seq,"3",prs.seq,"2",pa.seq,
    "1","0"), bb.exception_id, bb1.exception_id,
   bb1.requirement_cd, requirement_disp = uar_get_code_display(bb1.requirement_cd), bb1
   .special_testing_cd,
   special_testing_disp = uar_get_code_display(bb1.special_testing_cd), pa.abo_cd, pa.rh_cd,
   pr.cur_expire_dt_tm, pe.event_dt_tm, pe.person_id,
   pe.product_event_id, pr.product_nbr, pr.product_sub_nbr,
   bp_cur_abo_disp = uar_get_code_display(bp.cur_abo_cd), bp_cur_rh_disp = uar_get_code_display(bp
    .cur_rh_cd), pa_abo_disp = uar_get_code_display(pa.abo_cd),
   pa_rh_disp = uar_get_code_display(pa.rh_cd), per.name_full_formatted, ea.alias,
   prs.name_full_formatted, usr.username, override_reason_disp = decode(bb.seq,uar_get_code_display(
     bb.override_reason_cd)," "),
   product_disp = decode(pr.seq,uar_get_code_display(pr.product_cd)," "), encntr_alias = decode(ea
    .seq,"Y","N")
   FROM (dummyt d1  WITH seq = 1),
    bb_exception bb,
    prsnl usr,
    product_event pe,
    person per,
    product pr,
    blood_product bp,
    (dummyt d5  WITH seq = 1),
    person_aborh pa,
    encntr_prsnl_reltn epr,
    prsnl prs,
    bb_reqs_exception bb1,
    (dummyt d_ea  WITH seq = 1),
    encntr_alias ea
   PLAN (d1)
    JOIN (bb
    WHERE exception_code=bb.exception_type_cd
     AND bb.active_ind=1
     AND bb.active_status_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
    JOIN (usr
    WHERE bb.updt_id=usr.person_id)
    JOIN (pe
    WHERE bb.product_event_id=pe.product_event_id)
    JOIN (per
    WHERE pe.person_id=per.person_id)
    JOIN (pr
    WHERE pe.product_id=pr.product_id
     AND (((request->cur_owner_area_cd > 0.0)
     AND (request->cur_owner_area_cd=pr.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (request->cur_inv_area_cd=pr.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
    JOIN (bp
    WHERE pe.product_id=bp.product_id)
    JOIN (d5
    WHERE d5.seq=1)
    JOIN (((pa
    WHERE pe.person_id=pa.person_id
     AND pa.active_ind=1)
    ) ORJOIN ((((epr
    WHERE epr.encntr_prsnl_r_cd=admitdoc
     AND pe.encntr_id=epr.encntr_id
     AND pe.encntr_id > 0
     AND epr.active_ind=1)
    JOIN (prs
    WHERE epr.prsnl_person_id=prs.person_id)
    ) ORJOIN ((bb1
    WHERE bb.exception_id=bb1.exception_id)
    )) )) JOIN (d_ea
    WHERE d_ea.seq=1)
    JOIN (ea
    WHERE pe.encntr_id=ea.encntr_id
     AND ea.encntr_alias_type_cd=encntr_mrn_code
     AND ea.active_ind=1
     AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
   ORDER BY cnvtdatetime(pe.event_dt_tm), bb.exception_id, pr.product_nbr,
    pr.product_sub_nbr, pe.product_event_id, d_flg
   HEAD REPORT
    new_exception = "Y", first_ag_ab = "Y", encntr_alias_disp = fillstring(30," ")
   HEAD PAGE
    beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm),
    inc_i18nhandle = 0,
    inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
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
    CALL center(captions->bb_exception,1,125),
    col 104, captions->time, col 118,
    curtime"@TIMENOSECONDS;;M", row + 1, col 104,
    captions->as_of_date, col 118, curdate"@DATECONDENSED;;d",
    row save_row, row + 1, col 1,
    captions->bb_owner, col 19, cur_owner_area_disp,
    row + 1, col 1, captions->inventory_area,
    col 17, cur_inv_area_disp, row + 2,
    col 32, captions->beg_date, col 48,
    beg_dt_tm"@DATECONDENSED;;d", col 56, beg_dt_tm"@TIMENOSECONDS;;M",
    col 69, captions->end_date, col 82,
    end_dt_tm"@DATECONDENSED;;d", col 90, end_dt_tm"@TIMENOSECONDS;;M",
    row + 2, col 1, exception_disp,
    row + 2,
    CALL center(captions->aborh,54,76),
    CALL center(captions->name,78,97),
    CALL center(captions->physician,99,118), row + 1,
    CALL center(captions->dispd,1,7),
    CALL center(captions->product_number,9,33),
    CALL center(captions->product_type,35,52),
    CALL center(captions->unit,54,64),
    CALL center(captions->patient,66,76),
    CALL center(captions->alias,78,97),
    CALL center(captions->reason,99,118),
    CALL center(captions->tech,120,125), row + 1, col 1,
    "-------", col 9, "-------------------------",
    col 35, "------------------", col 54,
    "-----------", col 66, "-----------",
    col 78, "--------------------", col 99,
    "--------------------", col 120, "------"
   HEAD bb.exception_id
    new_exception = "Y", first_ag_ab = "Y"
   HEAD pr.product_nbr
    row + 0
   HEAD pr.product_sub_nbr
    row + 0
   HEAD pe.product_event_id
    IF (bb.exception_id > 0)
     datafoundflag = true, row + 1, pe_dt_tm = cnvtdatetime(pe.event_dt_tm),
     col 1, pe_dt_tm"@DATECONDENSED;;d", prod_nbr_display = concat(trim(bp.supplier_prefix),trim(pr
       .product_nbr)," ",trim(pr.product_sub_nbr)),
     col 9, prod_nbr_display, col 35,
     product_disp"##################", product_aborh_disp = fillstring(11," "), product_aborh_disp =
     substring(1,11,trim(concat(trim(bp_cur_abo_disp)," ",trim(bp_cur_rh_disp)))),
     col 54, product_aborh_disp"###########", col 78,
     per.name_full_formatted"####################", col 120, usr.username"######",
     row + 1, col 2, pe_dt_tm"@TIMENOSECONDS;;M"
     IF (encntr_alias="Y")
      encntr_alias_disp = cnvtalias(ea.alias,ea.alias_pool_cd)
     ELSE
      encntr_alias_disp = captions->not_on_file
     ENDIF
     col 78, encntr_alias_disp"####################", col 99,
     override_reason_disp"####################", row- (1)
    ENDIF
   DETAIL
    IF (bb.exception_id > 0)
     IF (d_flg="1")
      patient_aborh_disp = fillstring(11," "), patient_aborh_disp = substring(1,11,trim(concat(trim(
          pa_abo_disp)," ",trim(pa_rh_disp)))), col 66,
      patient_aborh_disp"###########"
     ELSEIF (d_flg="2")
      col 99, prs.name_full_formatted"####################"
     ELSEIF (d_flg="3")
      IF (first_ag_ab="Y")
       first_ag_ab = "N", row + 2
       IF (row > 52)
        BREAK, row + 1
       ENDIF
       col 44, captions->trans_reqs, row + 1
       IF (row > 56)
        BREAK, row + 1
       ENDIF
       col 44, "------------------------"
      ENDIF
      row + 1
      IF (row > 55)
       BREAK, row + 1
      ENDIF
      col 44, requirement_disp, col 73,
      special_testing_disp
      IF (row > 55)
       BREAK, row + 1
      ENDIF
     ENDIF
    ENDIF
   FOOT  pe.product_event_id
    row + 1
    IF (((row+ 5) > 56))
     BREAK
    ENDIF
   FOOT PAGE
    row 57, col 1, line,
    row + 1, col 1, captions->report_id,
    col 58, captions->page_no, col 64,
    curpage"###", col 100, captions->printed,
    col 109, curdate"@DATECONDENSED;;d", col 120,
    curtime"@TIMENOSECONDS;;M"
   FOOT REPORT
    row 60, col 51, captions->end_of_report
   WITH nocounter, maxrow = 61, nullreport,
    outerjoin(d5), outerjoin(d_ea), dontcare(ea),
    compress, nolandscape
  ;end select
  IF (((datafoundflag=true) OR ((request->null_ind=1))) )
   SET rpt_cnt += 1
   SET stat = alterlist(reply->rpt_list,rpt_cnt)
   SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
   SET datafoundflag = false
  ENDIF
 ENDIF
 IF (((uar_get_code_meaning(request->exception_type_cd)="ALLO BLOCK") OR ((request->exception_type_cd
 =0.0))) )
  EXECUTE cpm_create_file_name_logical "bbt_allo_block", "txt", "x"
  SET cdf_meaning = "ALLO BLOCK"
  SET exception_code = get_code_value(14072,cdf_meaning)
  SET exception_disp = uar_get_code_display(exception_code)
  SELECT INTO cpm_cfn_info->file_name_logical
   d_flg = decode(bb1.seq,"1","0"), bb.exception_id, bb1.bb_exception_id,
   bb1.product_id, pa.abo_cd, pa.rh_cd,
   pr.cur_expire_dt_tm, pe.event_dt_tm, pe.person_id,
   pe.product_event_id, pr.product_nbr, pr.product_sub_nbr,
   bp_cur_abo_disp = uar_get_code_display(bp.cur_abo_cd), bp_cur_rh_disp = uar_get_code_display(bp
    .cur_rh_cd), pa_abo_disp = uar_get_code_display(pa.abo_cd),
   pa_rh_disp = uar_get_code_display(pa.rh_cd), per.name_full_formatted, ea.alias,
   prs.name_full_formatted, usr.username, ac.accession,
   pr1.product_nbr, override_reason_disp = decode(bb.seq,uar_get_code_display(bb.override_reason_cd),
    " "), product_disp = decode(pr.seq,uar_get_code_display(pr.product_cd)," "),
   encntr_alias = decode(ea.seq,"Y","N")
   FROM bb_exception bb,
    bb_autodir_exception bb1,
    product pr1,
    product_event pe,
    product pr,
    blood_product bp,
    person_aborh pa,
    person per,
    (dummyt d6  WITH seq = 1),
    encntr_alias ea,
    (dummyt d7  WITH seq = 1),
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1),
    (dummyt d4  WITH seq = 1),
    (dummyt d5  WITH seq = 1),
    encntr_prsnl_reltn epr,
    prsnl prs,
    prsnl usr,
    result re,
    accession_order_r ac
   PLAN (bb
    WHERE exception_code=bb.exception_type_cd
     AND bb.active_ind=1
     AND bb.active_status_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
     end_dt_tm)
     AND bb.person_id=0.0)
    JOIN (usr
    WHERE bb.updt_id=usr.person_id)
    JOIN (pe
    WHERE bb.product_event_id=pe.product_event_id)
    JOIN (d6)
    JOIN (ea
    WHERE pe.encntr_id=ea.encntr_id
     AND ea.encntr_alias_type_cd=encntr_mrn_code
     AND ea.active_ind=1)
    JOIN (d7)
    JOIN (pr
    WHERE pe.product_id=pr.product_id
     AND (((request->cur_owner_area_cd > 0.0)
     AND (request->cur_owner_area_cd=pr.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (request->cur_inv_area_cd=pr.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
    JOIN (bp
    WHERE pe.product_id=bp.product_id)
    JOIN (per
    WHERE pe.person_id=per.person_id)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (re
    WHERE bb.result_id=re.result_id)
    JOIN (ac
    WHERE re.order_id=ac.order_id
     AND ac.primary_flag=0)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (epr
    WHERE epr.encntr_prsnl_r_cd=admitdoc
     AND pe.encntr_id=epr.encntr_id
     AND pe.encntr_id > 0
     AND epr.active_ind=1)
    JOIN (prs
    WHERE epr.prsnl_person_id=prs.person_id
     AND prs.person_id != null
     AND prs.person_id > 0)
    JOIN (((d4
    WHERE d4.seq=1)
    JOIN (pa
    WHERE pe.person_id=pa.person_id
     AND pa.active_ind=1)
    ) ORJOIN ((d5
    WHERE d5.seq=1)
    JOIN (bb1
    WHERE bb.exception_id=bb1.bb_exception_id)
    JOIN (pr1
    WHERE bb1.product_id=pr1.product_id)
    ))
   ORDER BY cnvtdatetime(pe.event_dt_tm), pr.product_nbr, pr.product_sub_nbr,
    bb.exception_id, pe.product_event_id, d_flg
   HEAD REPORT
    new_exception = "Y", first_ag_ab = "Y", new_page = "Y",
    encntr_alias_disp = fillstring(30," "), formatted_acc = fillstring(20," ")
   HEAD PAGE
    beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm),
    inc_i18nhandle = 0,
    inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
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
    CALL center(captions->bb_exception,1,125),
    col 104, captions->time, col 118,
    curtime"@TIMENOSECONDS;;M", row + 1, col 104,
    captions->as_of_date, col 118, curdate"@DATECONDENSED;;d",
    row save_row, row + 1, col 1,
    captions->bb_owner, col 19, cur_owner_area_disp,
    row + 1, col 1, captions->inventory_area,
    col 17, cur_inv_area_disp, row + 2,
    col 32, captions->beg_date, col 48,
    beg_dt_tm"@DATECONDENSED;;d", col 56, beg_dt_tm"@TIMENOSECONDS;;M",
    col 69, captions->end_date, col 82,
    end_dt_tm"@DATECONDENSED;;d", col 90, end_dt_tm"@TIMENOSECONDS;;M",
    row + 2, col 1, captions->dispensed_existing,
    row + 2,
    CALL center(captions->product_number,9,33),
    CALL center(captions->aborh,54,76),
    CALL center(captions->name,78,97),
    CALL center(captions->physician,99,118), row + 1,
    CALL center(captions->dispd,1,7),
    CALL center(captions->accession_number,9,33),
    CALL center(captions->product_type,35,52),
    CALL center(captions->unit,54,64),
    CALL center(captions->patient,66,76),
    CALL center(captions->alias,78,97),
    CALL center(captions->reason,99,118),
    CALL center(captions->tech,120,125), row + 1,
    col 1, "-------", col 9,
    "-------------------------", col 35, "------------------",
    col 54, "-----------", col 66,
    "-----------", col 78, "--------------------",
    col 99, "--------------------", col 120,
    "------", first_ag_ab = "Y"
   HEAD bb.exception_id
    new_exception = "Y", first_allo_block = "Y"
   HEAD pe.product_event_id
    IF (bb.exception_id > 0)
     datafoundflag = true
     IF (((new_exception="Y") OR (d_flg="1")) )
      new_exception = "N"
      IF (first_ag_ab="Y")
       row + 1
      ELSE
       row + 2
      ENDIF
      IF (d_flg="0")
       IF (row > 55)
        BREAK, row + 1
       ENDIF
       pe_dt_tm = cnvtdatetime(pe.event_dt_tm), col 1, pe_dt_tm"@DATECONDENSED;;d",
       prod_nbr_display = concat(trim(bp.supplier_prefix),trim(pr.product_nbr)," ",trim(pr
         .product_sub_nbr)), col 9, prod_nbr_display,
       col 35, product_disp"##################", product_aborh_disp = fillstring(11," "),
       product_aborh_disp = substring(1,11,trim(concat(trim(bp_cur_abo_disp)," ",trim(bp_cur_rh_disp)
          ))), col 54, product_aborh_disp"###########",
       patient_aborh_disp = fillstring(11," "), patient_aborh_disp = substring(1,11,trim(concat(trim(
           pa_abo_disp)," ",trim(pa_rh_disp)))), col 66,
       patient_aborh_disp"###########", col 78, per.name_full_formatted"####################",
       col 99, prs.name_full_formatted"####################", col 120,
       usr.username"######", row + 1, col 2,
       pe_dt_tm"@TIMENOSECONDS;;M", formatted_acc = cnvtacc(ac.accession), col 9,
       formatted_acc"####################"
       IF (encntr_alias="Y")
        encntr_alias_disp = cnvtalias(ea.alias,ea.alias_pool_cd)
       ELSE
        encntr_alias_disp = captions->not_on_file
       ENDIF
       col 78, encntr_alias_disp"####################", col 99,
       override_reason_disp"####################"
      ENDIF
     ENDIF
    ENDIF
    first_ag_ab = "N"
   DETAIL
    IF (bb.exception_id > 0)
     IF (d_flg="1")
      IF (first_allo_block="Y")
       first_allo_block = "N", row + 1
       IF (row > 54)
        BREAK, row + 1
       ENDIF
       CALL center(captions->product_nbr,35,59),
       CALL center(captions->product_type,61,78), row + 1,
       col 35, "-------------------------", col 61,
       "------------------"
      ENDIF
      row + 1
      IF (row > 56)
       BREAK, row + 1
      ENDIF
      col 35, pr1.product_nbr, temp_product_cd = uar_get_code_display(pr1.product_cd),
      col 61, temp_product_cd
     ENDIF
    ENDIF
   FOOT  pe.product_event_id
    row + 0
   FOOT PAGE
    row 57, col 1, line,
    row + 1, col 1, captions->report_id,
    col 58, captions->page_no, col 64,
    curpage"###", col 100, captions->printed,
    col 109, curdate"@DATECONDENSED;;d", col 120,
    curtime"@TIMENOSECONDS;;M", new_page = "Y"
   FOOT REPORT
    row 60, col 51, captions->end_of_report
   WITH nocounter, maxrow = 61, nullreport,
    outerjoin(d2), outerjoin(d3), outerjoin(d4),
    dontcare(re), dontcare(epr), dontcare(pa),
    dontcare(ea), compress, nolandscape
  ;end select
  IF (((datafoundflag=true) OR ((request->null_ind=1))) )
   SET rpt_cnt += 1
   SET stat = alterlist(reply->rpt_list,rpt_cnt)
   SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
   SET datafoundflag = false
  ENDIF
 ENDIF
 IF (((uar_get_code_meaning(request->exception_type_cd)="NOAGDIS") OR ((request->exception_type_cd=
 0.0))) )
  EXECUTE cpm_create_file_name_logical "bbt_noag_dis", "txt", "x"
  SET cdf_meaning = "NOAGDIS"
  SET exception_code = get_code_value(14072,cdf_meaning)
  SET exception_disp = uar_get_code_display(exception_code)
  SELECT INTO cpm_cfn_info->file_name_logical
   d_flg = decode(bb1.seq,"1","0"), bb.exception_id, bb1.exception_id,
   bb1.requirement_cd, bb1.special_testing_cd, pa.abo_cd,
   pa.rh_cd, pr.cur_expire_dt_tm, pe.event_dt_tm,
   pe.person_id, pe.product_event_id, pr.product_nbr,
   pr.product_sub_nbr, bp_cur_abo_disp = uar_get_code_display(bp.cur_abo_cd), bp_cur_rh_disp =
   uar_get_code_display(bp.cur_rh_cd),
   pa_abo_disp = uar_get_code_display(pa.abo_cd), pa_rh_disp = uar_get_code_display(pa.rh_cd), per
   .name_full_formatted,
   ea.alias, prs.name_full_formatted, usr.username,
   ac.accession, override_reason_disp = decode(bb.seq,uar_get_code_display(bb.override_reason_cd)," "
    ), product_disp = decode(pr.seq,uar_get_code_display(pr.product_cd)," "),
   encntr_alias = decode(ea.seq,"Y","N")
   FROM bb_exception bb,
    bb_reqs_exception bb1,
    product_event pe,
    product pr,
    blood_product bp,
    person_aborh pa,
    person per,
    (dummyt d6  WITH seq = 1),
    encntr_alias ea,
    (dummyt d7  WITH seq = 1),
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1),
    (dummyt d4  WITH seq = 1),
    (dummyt d5  WITH seq = 1),
    encntr_prsnl_reltn epr,
    prsnl prs,
    prsnl usr,
    result re,
    accession_order_r ac
   PLAN (bb
    WHERE exception_code=bb.exception_type_cd
     AND bb.active_ind=1
     AND bb.active_status_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
    JOIN (usr
    WHERE bb.updt_id=usr.person_id)
    JOIN (pe
    WHERE bb.product_event_id=pe.product_event_id)
    JOIN (d6)
    JOIN (ea
    WHERE pe.encntr_id=ea.encntr_id
     AND ea.encntr_alias_type_cd=encntr_mrn_code
     AND ea.active_ind=1)
    JOIN (d7)
    JOIN (pr
    WHERE pe.product_id=pr.product_id
     AND (((request->cur_owner_area_cd > 0.0)
     AND (request->cur_owner_area_cd=pr.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (request->cur_inv_area_cd=pr.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
    JOIN (bp
    WHERE pe.product_id=bp.product_id)
    JOIN (per
    WHERE pe.person_id=per.person_id)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (re
    WHERE bb.result_id=re.result_id)
    JOIN (ac
    WHERE re.order_id=ac.order_id
     AND ac.primary_flag=0)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (epr
    WHERE epr.encntr_prsnl_r_cd=admitdoc
     AND pe.encntr_id=epr.encntr_id
     AND pe.encntr_id > 0
     AND epr.active_ind=1)
    JOIN (prs
    WHERE epr.prsnl_person_id=prs.person_id)
    JOIN (((d4
    WHERE d4.seq=1)
    JOIN (pa
    WHERE pe.person_id=pa.person_id
     AND pa.active_ind=1)
    ) ORJOIN ((d5
    WHERE d5.seq=1)
    JOIN (bb1
    WHERE bb.exception_id=bb1.exception_id)
    ))
   ORDER BY cnvtdatetime(pe.event_dt_tm), pr.product_nbr, pr.product_sub_nbr,
    bb.exception_id, d_flg
   HEAD REPORT
    new_exception = "Y", first_ag_ab = "Y", first_exception = "Y",
    encntr_alias_disp = fillstring(30," "), formatted_acc = fillstring(20," ")
   HEAD PAGE
    beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm),
    inc_i18nhandle = 0,
    inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
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
    CALL center(captions->bb_exception,1,125),
    col 104, captions->time, col 118,
    curtime"@TIMENOSECONDS;;M", row + 1, col 104,
    captions->as_of_date, col 118, curdate"@DATECONDENSED;;d",
    row save_row, row + 1, col 1,
    captions->bb_owner, col 19, cur_owner_area_disp,
    row + 1, col 1, captions->inventory_area,
    col 17, cur_inv_area_disp, row + 2,
    col 32, captions->beg_date, col 48,
    beg_dt_tm"@DATECONDENSED;;d", col 56, beg_dt_tm"@TIMENOSECONDS;;M",
    col 69, captions->end_date, col 82,
    end_dt_tm"@DATECONDENSED;;d", col 90, end_dt_tm"@TIMENOSECONDS;;M",
    row + 2, col 1, exception_disp,
    row + 2,
    CALL center(captions->product_number,9,33),
    CALL center(captions->aborh,54,76),
    CALL center(captions->name,78,97),
    CALL center(captions->physician,99,118), row + 1,
    CALL center(captions->dispd,1,7),
    CALL center(captions->accession_number,9,33),
    CALL center(captions->product_type,35,52),
    CALL center(captions->unit,54,64),
    CALL center(captions->patient,66,76),
    CALL center(captions->alias,78,97),
    CALL center(captions->reason,99,118),
    CALL center(captions->tech,120,125), row + 1,
    col 1, "-------", col 9,
    "-------------------------", col 35, "------------------",
    col 54, "-----------", col 66,
    "-----------", col 78, "--------------------",
    col 99, "--------------------", col 120,
    "------", row + 1, first_exception = "Y"
   HEAD bb.exception_id
    new_exception = "Y", first_ag_ab = "Y"
   DETAIL
    IF (bb.exception_id > 0)
     datafoundflag = true
     IF (((new_exception="Y") OR (d_flg="1")) )
      new_exception = "N"
      IF (d_flg="0")
       IF (first_exception="Y")
        row + 0, first_exception = "N"
       ELSE
        row + 1
       ENDIF
       pe_dt_tm = cnvtdatetime(pe.event_dt_tm), col 1, pe_dt_tm"@DATECONDENSED;;d",
       prod_nbr_display = concat(trim(bp.supplier_prefix),trim(pr.product_nbr)," ",trim(pr
         .product_sub_nbr)), col 9, prod_nbr_display,
       col 35, product_disp"##################", product_aborh_disp = fillstring(11," "),
       product_aborh_disp = substring(1,11,trim(concat(trim(bp_cur_abo_disp)," ",trim(bp_cur_rh_disp)
          ))), col 54, product_aborh_disp"###########",
       patient_aborh_disp = fillstring(11," "), patient_aborh_disp = substring(1,11,trim(concat(trim(
           pa_abo_disp)," ",trim(pa_rh_disp)))), col 66,
       patient_aborh_disp"###########", col 78, per.name_full_formatted"####################",
       col 99, prs.name_full_formatted"####################", col 120,
       usr.username"######", row + 1
       IF (row > 56)
        BREAK
       ENDIF
       col 2, pe_dt_tm"@TIMENOSECONDS;;M", formatted_acc = cnvtacc(ac.accession),
       col 9, formatted_acc"####################"
       IF (encntr_alias="Y")
        encntr_alias_disp = cnvtalias(ea.alias,ea.alias_pool_cd)
       ELSE
        encntr_alias_disp = captions->not_on_file
       ENDIF
       col 78, encntr_alias_disp"####################", col 99,
       override_reason_disp"####################", row + 1
      ENDIF
      IF (row > 54)
       BREAK
      ENDIF
      IF (d_flg="1")
       IF (first_ag_ab="Y")
        first_ag_ab = "N", col 47, captions->patient_antibodies,
        col 71, captions->product_antigens, row + 1
        IF (row > 56)
         BREAK
        ENDIF
        col 47, "------------------", col 71,
        "----------------", row + 1
       ENDIF
       IF (row > 56)
        BREAK
       ENDIF
       idx_a = 1, finish_flag = "N"
       WHILE (idx_a <= an_idx
        AND finish_flag="N")
         IF ((bb1.requirement_cd=anreq->an_list[idx_a].an_code))
          col 47, anreq->an_list[idx_a].an_display, finish_flag = "Y"
         ELSE
          idx_a += 1
         ENDIF
       ENDWHILE
       idx_a = 1, finish_flag = "N"
       WHILE (idx_a <= st_idx
        AND finish_flag="N")
         IF ((bb1.special_testing_cd=streq->st_list[idx_a].st_code))
          col 71, streq->st_list[idx_a].st_display, finish_flag = "Y"
         ELSE
          idx_a += 1
         ENDIF
       ENDWHILE
       IF (first_exception="Y")
        first_exception = "N"
       ENDIF
       row + 1
      ENDIF
     ENDIF
    ENDIF
   FOOT PAGE
    row 57, col 1, line,
    row + 1, col 1, captions->report_id,
    col 58, captions->page_no, col 64,
    curpage"###", col 100, captions->printed,
    col 109, curdate"@DATECONDENSED;;d", col 120,
    curtime"@TIMENOSECONDS;;M"
   FOOT REPORT
    row 60, col 51, captions->end_of_report
   WITH nocounter, maxrow = 61, nullreport,
    outerjoin(d2), outerjoin(d3), outerjoin(d4),
    dontcare(re), dontcare(epr), dontcare(pa),
    dontcare(ea), compress, nolandscape
  ;end select
  IF (((datafoundflag=true) OR ((request->null_ind=1))) )
   SET rpt_cnt += 1
   SET stat = alterlist(reply->rpt_list,rpt_cnt)
   SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
   SET datafoundflag = false
  ENDIF
 ENDIF
 RECORD alias(
   1 person_alias[*]
     2 mrn = vc
 )
 IF (((uar_get_code_meaning(request->exception_type_cd)="PTGTCHG") OR ((request->exception_type_cd=
 0.0))) )
  SET stat = bbtgetencounterlocations(request->facility_cd,pref_level_bb)
  IF ((stat=- (1)))
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
  SET facidx = 0
  EXECUTE cpm_create_file_name_logical "bbt_ptgtchg", "txt", "x"
  SET cdf_meaning = "PTGTCHG"
  SET exception_code = get_code_value(14072,cdf_meaning)
  SET exception_disp = uar_get_code_display(exception_code)
  IF ((request->facility_cd > 0))
   SET facility_disp = uar_get_code_display(request->facility_cd)
  ENDIF
  SELECT INTO cpm_cfn_info->file_name_logical
   bb.exception_id, bb.updt_dt_tm, pa.abo_cd,
   pa.rh_cd, bb_from_abo_disp = uar_get_code_display(bb.from_abo_cd), bb_from_rh_disp =
   uar_get_code_display(bb.from_rh_cd),
   bb_to_abo_disp = uar_get_code_display(bb.to_abo_cd), bb_to_rh_disp = uar_get_code_display(bb
    .to_rh_cd), pa_abo_disp = uar_get_code_display(pa.abo_cd),
   pa_rh_disp = uar_get_code_display(pa.rh_cd), per.name_full_formatted, pra.alias,
   person_alias_exists = decode(pra.seq,build(pra.person_alias_id),"0.0"), mrn_alias = cnvtalias(pra
    .alias,pra.alias_pool_cd), prs.name_full_formatted,
   usr.username, ac.accession, override_reason_disp = decode(bb.seq,uar_get_code_display(bb
     .override_reason_cd)," ")
   FROM bb_exception bb,
    person_aborh pa,
    person per,
    encounter e,
    (dummyt d_pra  WITH seq = 1),
    person_alias pra,
    (dummyt d4  WITH seq = 1),
    (dummyt d_epr  WITH seq = 1),
    encntr_prsnl_reltn epr,
    (dummyt d_prs  WITH seq = 1),
    prsnl prs,
    prsnl usr,
    result re,
    accession_order_r ac,
    orders o
   PLAN (bb
    WHERE exception_code=bb.exception_type_cd
     AND bb.active_ind=1
     AND bb.active_status_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
    JOIN (usr
    WHERE bb.updt_id=usr.person_id)
    JOIN (re
    WHERE bb.result_id=re.result_id)
    JOIN (o
    WHERE re.order_id=o.order_id)
    JOIN (ac
    WHERE re.order_id=ac.order_id
     AND ac.primary_flag=0)
    JOIN (per
    WHERE o.person_id=per.person_id)
    JOIN (e
    WHERE e.person_id=o.person_id
     AND ((expand(facidx,1,size(encounterlocations->locs,5),e.loc_facility_cd,encounterlocations->
     locs[facidx].encfacilitycd)) OR ((((e.loc_facility_cd=request->facility_cd)) OR ((request->
    facility_cd=0.0))) )) )
    JOIN (d_pra
    WHERE d_pra.seq=1)
    JOIN (pra
    WHERE pra.person_alias_type_cd=mrn_code
     AND o.person_id=pra.person_id
     AND pra.active_ind=1)
    JOIN (d_epr
    WHERE d_epr.seq=1)
    JOIN (epr
    WHERE epr.encntr_prsnl_r_cd=admitdoc
     AND o.encntr_id=epr.encntr_id
     AND o.encntr_id > 0)
    JOIN (d_prs
    WHERE d_prs.seq=1)
    JOIN (prs
    WHERE epr.prsnl_person_id=prs.person_id)
    JOIN (d4
    WHERE d4.seq=1)
    JOIN (pa
    WHERE o.person_id=pa.person_id
     AND pa.active_ind=1)
   ORDER BY cnvtdatetime(bb.updt_dt_tm), bb.exception_id
   HEAD REPORT
    new_exception = "Y", mrn_cnt = 0, bmrnfound = "F",
    stat = alterlist(alias->person_alias,mrn_cnt), formatted_acc = fillstring(20," ")
   HEAD PAGE
    beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm),
    inc_i18nhandle = 0,
    inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
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
    CALL center(captions->bb_exception,1,125),
    col 104, captions->time, col 118,
    curtime"@TIMENOSECONDS;;M", row + 1, col 104,
    captions->as_of_date, col 118, curdate"@DATECONDENSED;;d",
    row save_row, row + 1, col 32,
    captions->beg_date, col 48, beg_dt_tm"@DATECONDENSED;;d",
    col 56, beg_dt_tm"@TIMENOSECONDS;;M", col 69,
    captions->end_date, col 82, end_dt_tm"@DATECONDENSED;;d",
    col 90, end_dt_tm"@TIMENOSECONDS;;M"
    IF ((request->facility_cd > 0))
     row + 2, col 1, captions->facility,
     col 11, facility_disp
    ENDIF
    row + 2, col 1, exception_disp,
    row + 2,
    CALL center(captions->date,1,7),
    CALL center(captions->validation_aborh,33,67),
    CALL center(captions->name,70,94),
    CALL center(captions->physician,97,119), row + 1,
    CALL center(captions->new_time,1,7),
    CALL center(captions->accession,10,30),
    CALL center(captions->previous,33,43),
    CALL center(captions->resulted,45,55),
    CALL center(captions->current,57,67),
    CALL center(captions->alias,70,94),
    CALL center(captions->reason,97,119),
    CALL center(captions->tech,122,127), row + 1,
    col 1, "-------", col 10,
    "---------------------", col 33, "-----------",
    col 45, "-----------", col 57,
    "-----------", col 70, "-------------------------",
    col 97, "-----------------------", col 122,
    "------", row + 1
   HEAD bb.exception_id
    datafoundflag = true, new_exception = "Y"
    FOR (i = 1 TO size(alias->person_alias,5))
      alias->person_alias[i].mrn = " "
    ENDFOR
    mrn_cnt = 0
   DETAIL
    IF (person_alias_exists != "0.0")
     bmrnfound = "F"
     IF (mrn_cnt=0)
      row + 0
     ELSE
      FOR (i = 1 TO mrn_cnt)
        IF ((alias->person_alias[i].mrn=mrn_alias))
         bmrnfound = "T", i = mrn_cnt
        ENDIF
      ENDFOR
     ENDIF
     IF (bmrnfound="F")
      mrn_cnt += 1, stat = alterlist(alias->person_alias,mrn_cnt), alias->person_alias[mrn_cnt].mrn
       = mrn_alias
     ENDIF
    ENDIF
   FOOT  bb.exception_id
    IF (bb.exception_id > 0)
     IF (new_exception="Y")
      new_exception = "N"
      IF (row > 55)
       BREAK
      ENDIF
      pe_dt_tm = cnvtdatetime(bb.updt_dt_tm), col 1, pe_dt_tm"@DATECONDENSED;;d",
      formatted_acc = cnvtacc(ac.accession), col 10, formatted_acc"####################",
      product_from_aborh_disp = fillstring(11," "), product_from_aborh_disp = substring(1,11,trim(
        concat(trim(bb_from_abo_disp)," ",trim(bb_from_rh_disp)))), col 33,
      product_from_aborh_disp"###########", product_to_aborh_disp = fillstring(11," "),
      product_to_aborh_disp = substring(1,11,trim(concat(trim(bb_to_abo_disp)," ",trim(bb_to_rh_disp)
         ))),
      col 45, product_to_aborh_disp"###########", patient_aborh_disp = fillstring(11," "),
      patient_aborh_disp = substring(1,11,trim(concat(trim(pa_abo_disp)," ",trim(pa_rh_disp)))), col
      57, patient_aborh_disp"###########",
      col 70, per.name_full_formatted"#########################", col 97,
      prs.name_full_formatted"#######################", col 122, usr.username"######",
      row + 1
      IF (row > 56)
       BREAK
      ENDIF
      col 2, pe_dt_tm"@TIMENOSECONDS;;M", col 97,
      override_reason_disp"#########################"
      IF (mrn_cnt < 2)
       IF (size(alias->person_alias,5) > 0
        AND trim(alias->person_alias[1].mrn) > "")
        col 70, alias->person_alias[1].mrn
       ELSE
        col 70, captions->not_on_file
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
         col 70, alias->person_alias[i].mrn
        ENDIF
       ENDFOR
      ENDIF
      row + 2
      IF (row > 56)
       BREAK
      ENDIF
     ENDIF
    ENDIF
   FOOT PAGE
    row 57, col 1, line,
    row + 1, col 1, captions->report_id,
    col 58, captions->page_no, col 64,
    curpage"###", col 100, captions->printed,
    col 109, curdate"@DATECONDENSED;;d", col 120,
    curtime"@TIMENOSECONDS;;M"
   FOOT REPORT
    row 60, col 51, captions->end_of_report
   WITH nocounter, maxrow = 61, nullreport,
    outerjoin(d_pra), dontcare(pra), outerjoin(d4),
    dontcare(epr), dontcare(prs), compress,
    nolandscape
  ;end select
  IF (((datafoundflag=true) OR ((request->null_ind=1))) )
   SET rpt_cnt += 1
   SET stat = alterlist(reply->rpt_list,rpt_cnt)
   SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
   SET datafoundflag = false
  ENDIF
 ENDIF
 IF (((uar_get_code_meaning(request->exception_type_cd)="PTGTNOCHG") OR ((request->exception_type_cd=
 0.0))) )
  SET stat = bbtgetencounterlocations(request->facility_cd,pref_level_bb)
  IF ((stat=- (1)))
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
  SET facidx = 0
  EXECUTE cpm_create_file_name_logical "bbt_ptgtno_chg", "txt", "x"
  SET cdf_meaning = "PTGTNOCHG"
  SET exception_code = get_code_value(14072,cdf_meaning)
  SET exception_disp = uar_get_code_display(exception_code)
  IF ((request->facility_cd > 0))
   SET facility_disp = uar_get_code_display(request->facility_cd)
  ENDIF
  SELECT INTO cpm_cfn_info->file_name_logical
   bb.exception_id, bb.updt_dt_tm, pa.abo_cd,
   pa.rh_cd, bb_from_abo_disp = uar_get_code_display(bb.from_abo_cd), bb_from_rh_disp =
   uar_get_code_display(bb.from_rh_cd),
   bb_to_abo_disp = uar_get_code_display(bb.to_abo_cd), bb_to_rh_disp = uar_get_code_display(bb
    .to_rh_cd), pa_abo_disp = uar_get_code_display(pa.abo_cd),
   pa_rh_disp = uar_get_code_display(pa.rh_cd), per.name_full_formatted, pra.alias,
   person_alias_exists = decode(pra.seq,build(pra.person_alias_id),"0.0"), mrn_alias = cnvtalias(pra
    .alias,pra.alias_pool_cd), prs.name_full_formatted,
   usr.username, ac.accession, override_reason_disp = decode(bb.seq,uar_get_code_display(bb
     .override_reason_cd)," ")
   FROM bb_exception bb,
    person_aborh pa,
    person per,
    (dummyt d_pra  WITH seq = 1),
    person_alias pra,
    (dummyt d4  WITH seq = 1),
    (dummyt d_epr  WITH seq = 1),
    encntr_prsnl_reltn epr,
    (dummyt d_prs  WITH seq = 1),
    prsnl prs,
    prsnl usr,
    result re,
    accession_order_r ac,
    orders o,
    encounter e
   PLAN (bb
    WHERE exception_code=bb.exception_type_cd
     AND bb.active_ind=1
     AND bb.active_status_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
    JOIN (usr
    WHERE bb.updt_id=usr.person_id)
    JOIN (re
    WHERE bb.result_id=re.result_id)
    JOIN (o
    WHERE re.order_id=o.order_id)
    JOIN (e
    WHERE e.person_id=o.person_id
     AND ((expand(facidx,1,size(encounterlocations->locs,5),e.loc_facility_cd,encounterlocations->
     locs[facidx].encfacilitycd)) OR ((((e.loc_facility_cd=request->facility_cd)) OR ((request->
    facility_cd=0.0))) )) )
    JOIN (ac
    WHERE re.order_id=ac.order_id
     AND ac.primary_flag=0)
    JOIN (per
    WHERE o.person_id=per.person_id)
    JOIN (d_pra
    WHERE d_pra.seq=1)
    JOIN (pra
    WHERE pra.person_alias_type_cd=mrn_code
     AND o.person_id=pra.person_id
     AND pra.active_ind=1)
    JOIN (d_epr
    WHERE d_epr.seq=1)
    JOIN (epr
    WHERE epr.encntr_prsnl_r_cd=admitdoc
     AND o.encntr_id=epr.encntr_id
     AND o.encntr_id > 0)
    JOIN (d_prs
    WHERE d_prs.seq=1)
    JOIN (prs
    WHERE epr.prsnl_person_id=prs.person_id)
    JOIN (d4
    WHERE d4.seq=1)
    JOIN (pa
    WHERE o.person_id=pa.person_id
     AND pa.active_ind=1)
   ORDER BY cnvtdatetime(bb.updt_dt_tm), bb.exception_id
   HEAD REPORT
    new_exception = "Y", mrn_cnt = 0, bmrnfound = "F",
    stat = alterlist(alias->person_alias,mrn_cnt), formatted_acc = fillstring(20," ")
   HEAD PAGE
    beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm),
    inc_i18nhandle = 0,
    inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
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
    CALL center(captions->bb_exception,1,125),
    col 104, captions->time, col 118,
    curtime"@TIMENOSECONDS;;M", row + 1, col 104,
    captions->as_of_date, col 118, curdate"@DATECONDENSED;;d",
    row save_row, row + 1, col 32,
    captions->beg_date, col 48, beg_dt_tm"@DATECONDENSED;;d",
    col 56, beg_dt_tm"@TIMENOSECONDS;;M", col 69,
    captions->end_date, col 82, end_dt_tm"@DATECONDENSED;;d",
    col 90, end_dt_tm"@TIMENOSECONDS;;M"
    IF ((request->facility_cd > 0))
     row + 2, col 1, captions->facility,
     col 11, facility_disp
    ENDIF
    row + 2, col 1, exception_disp,
    row + 2,
    CALL center(captions->date,1,7),
    CALL center(captions->validation_aborh,33,67),
    CALL center(captions->name,70,94),
    CALL center(captions->physician,97,119), row + 1,
    CALL center(captions->new_time,1,7),
    CALL center(captions->accession,10,30),
    CALL center(captions->previous,33,43),
    CALL center(captions->resulted,45,55),
    CALL center(captions->current,57,67),
    CALL center(captions->alias,70,94),
    CALL center(captions->reason,97,119),
    CALL center(captions->tech,122,127), row + 1,
    col 1, "-------", col 10,
    "---------------------", col 33, "-----------",
    col 45, "-----------", col 57,
    "-----------", col 70, "-------------------------",
    col 97, "-----------------------", col 122,
    "------", row + 1
   HEAD bb.exception_id
    new_exception = "Y"
    FOR (i = 1 TO size(alias->person_alias,5))
      alias->person_alias[i].mrn = " "
    ENDFOR
    mrn_cnt = 0
   DETAIL
    IF (person_alias_exists != "0.0")
     bmrnfound = "F"
     IF (mrn_cnt=0)
      row + 0
     ELSE
      FOR (i = 1 TO mrn_cnt)
        IF ((alias->person_alias[i].mrn=mrn_alias))
         bmrnfound = "T", i = mrn_cnt
        ENDIF
      ENDFOR
     ENDIF
     IF (bmrnfound="F")
      mrn_cnt += 1, stat = alterlist(alias->person_alias,mrn_cnt), alias->person_alias[mrn_cnt].mrn
       = mrn_alias
     ENDIF
    ENDIF
   FOOT  bb.exception_id
    IF (bb.exception_id > 0)
     datafoundflag = true
     IF (new_exception="Y")
      new_exception = "N"
      IF (row > 55)
       BREAK
      ENDIF
      pe_dt_tm = cnvtdatetime(bb.updt_dt_tm), col 1, pe_dt_tm"@DATECONDENSED;;d",
      formatted_acc = cnvtacc(ac.accession), col 10, formatted_acc"####################",
      product_from_aborh_disp = fillstring(11," "), product_from_aborh_disp = substring(1,11,trim(
        concat(trim(bb_from_abo_disp)," ",trim(bb_from_rh_disp)))), col 33,
      product_from_aborh_disp"###########", product_to_aborh_disp = fillstring(11," "),
      product_to_aborh_disp = substring(1,11,trim(concat(trim(bb_to_abo_disp)," ",trim(bb_to_rh_disp)
         ))),
      col 45, product_to_aborh_disp"###########", patient_aborh_disp = fillstring(11," "),
      patient_aborh_disp = substring(1,11,trim(concat(trim(pa_abo_disp)," ",trim(pa_rh_disp)))), col
      57, patient_aborh_disp"###########",
      col 70, per.name_full_formatted"#########################", col 97,
      prs.name_full_formatted"#######################", col 122, usr.username"######",
      row + 1
      IF (row > 56)
       BREAK
      ENDIF
      col 2, pe_dt_tm"@TIMENOSECONDS;;M", col 97,
      override_reason_disp"#########################"
      IF (mrn_cnt < 2)
       IF (row > 56)
        BREAK
       ENDIF
       IF (trim(alias->person_alias[1].mrn) > "")
        col 70, alias->person_alias[1].mrn
       ELSE
        col 70, captions->not_on_file
       ENDIF
      ELSE
       FOR (i = 1 TO mrn_cnt)
        IF (i > 1)
         row + 1
        ENDIF
        ,
        IF (trim(alias->person_alias[i].mrn) > "")
         IF (row > 56)
          BREAK
         ENDIF
         col 70, alias->person_alias[i].mrn
        ENDIF
       ENDFOR
      ENDIF
      row + 2
     ENDIF
    ENDIF
   FOOT PAGE
    row 57, col 1, line,
    row + 1, col 1, captions->report_id,
    col 58, captions->page_no, col 64,
    curpage"###", col 100, captions->printed,
    col 109, curdate"@DATECONDENSED;;d", col 120,
    curtime"@TIMENOSECONDS;;M"
   FOOT REPORT
    row 60, col 51, captions->end_of_report
   WITH nocounter, maxrow = 61, nullreport,
    outerjoin(d_pra), dontcare(pra), outerjoin(d4),
    dontcare(epr), dontcare(prs), compress,
    nolandscape
  ;end select
  IF (((datafoundflag=true) OR ((request->null_ind=1))) )
   SET rpt_cnt += 1
   SET stat = alterlist(reply->rpt_list,rpt_cnt)
   SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
   SET datafoundflag = false
  ENDIF
 ENDIF
 IF (uar_get_code_meaning(request->exception_type_cd)="UNGTCHG")
  EXECUTE cpm_create_file_name_logical "bbt_ungtch", "txt", "x"
  SET cdf_meaning = "UNGTCHG"
  SET exception_code = get_code_value(14072,cdf_meaning)
  SET exception_disp = uar_get_code_display(exception_code)
  SELECT INTO cpm_cfn_info->file_name_logical
   bb.exception_id, bb.updt_dt_tm, bb_from_abo_disp = uar_get_code_display(bb.from_abo_cd),
   bb.from_rh_cd, bb_from_rh_disp = uar_get_code_display(bb.from_rh_cd), bb_to_abo_disp =
   uar_get_code_display(bb.to_abo_cd),
   bb.to_rh_cd, bb_to_rh_disp = uar_get_code_display(bb.to_rh_cd), bp_cur_abo_disp =
   uar_get_code_display(bp.cur_abo_cd),
   bp.cur_rh_cd, bp_cur_rh_disp = uar_get_code_display(bp.cur_rh_cd), usr.username,
   pr.product_nbr, pr.product_sub_nbr, override_reason_disp = decode(bb.seq,uar_get_code_display(bb
     .override_reason_cd)," "),
   product_disp = decode(pr.seq,uar_get_code_display(pr.product_cd)," ")
   FROM (dummyt d3  WITH seq = 1),
    bb_exception bb,
    prsnl usr,
    product pr,
    blood_product bp,
    prsnl prs,
    encntr_prsnl_reltn epr,
    result re,
    orders o
   PLAN (bb
    WHERE exception_code=bb.exception_type_cd
     AND bb.active_ind=1
     AND bb.active_status_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
    JOIN (usr
    WHERE bb.updt_id=usr.person_id)
    JOIN (re
    WHERE bb.result_id > 0
     AND bb.result_id=re.result_id)
    JOIN (o
    WHERE re.order_id=o.order_id)
    JOIN (pr
    WHERE o.product_id=pr.product_id
     AND (((request->cur_owner_area_cd > 0.0)
     AND (request->cur_owner_area_cd=pr.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (request->cur_inv_area_cd=pr.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
    JOIN (bp
    WHERE pr.product_id=bp.product_id)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (epr
    WHERE epr.encntr_prsnl_r_cd=admitdoc
     AND o.encntr_id=epr.encntr_id
     AND o.encntr_id > 0
     AND epr.active_ind=1)
    JOIN (prs
    WHERE epr.prsnl_person_id=prs.person_id)
   ORDER BY cnvtdatetime(bb.updt_dt_tm), bb.exception_id
   HEAD REPORT
    new_exception = "Y"
   HEAD PAGE
    beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm),
    inc_i18nhandle = 0,
    inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
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
    CALL center(captions->bb_exception,1,125),
    col 104, captions->time, col 118,
    curtime"@TIMENOSECONDS;;M", row + 1, col 104,
    captions->as_of_date, col 118, curdate"@DATECONDENSED;;d",
    row save_row, row + 1, col 1,
    captions->bb_owner, col 19, cur_owner_area_disp,
    row + 1, col 1, captions->inventory_area,
    col 17, cur_inv_area_disp, row + 2,
    col 32, captions->beg_date, col 48,
    beg_dt_tm"@DATECONDENSED;;d", col 56, beg_dt_tm"@TIMENOSECONDS;;M",
    col 69, captions->end_date, col 82,
    end_dt_tm"@DATECONDENSED;;d", col 90, end_dt_tm"@TIMENOSECONDS;;M",
    row + 2, col 1, exception_disp,
    row + 2,
    CALL center(captions->date,1,7),
    CALL center(captions->product_number,9,33),
    CALL center(captions->validation_aborh,55,92),
    CALL center(captions->physician,94,118), row + 1,
    CALL center(captions->new_time,1,7),
    CALL center(captions->accession,9,33),
    CALL center(captions->product_type,35,53),
    CALL center(captions->previous,55,66),
    CALL center(captions->resulted,68,79),
    CALL center(captions->current,81,92),
    CALL center(captions->reason,94,118),
    CALL center(captions->tech,120,125), row + 1,
    col 1, "-------", col 9,
    "-------------------------", col 35, "-------------------",
    col 55, "------------", col 68,
    "------------", col 81, "------------",
    col 94, "-------------------------", col 120,
    "------", row + 1
   HEAD bb.exception_id
    new_exception = "Y"
   DETAIL
    IF (bb.exception_id > 0)
     datafoundflag = true
     IF (new_exception="Y")
      new_exception = "N", pe_dt_tm = cnvtdatetime(bb.updt_dt_tm)
      IF (row > 55)
       BREAK
      ENDIF
      col 1, pe_dt_tm"@DATECONDENSED;;d", prod_nbr_display = concat(trim(bp.supplier_prefix),trim(pr
        .product_nbr)," ",trim(pr.product_sub_nbr)),
      col 9, prod_nbr_display, col 35,
      product_disp"###################", product_from_aborh_disp = fillstring(12," "),
      product_from_aborh_disp = substring(1,12,trim(concat(trim(bb_from_abo_disp)," ",trim(
          bb_from_rh_disp)))),
      col 55, product_from_aborh_disp"############", product_to_aborh_disp = fillstring(12," "),
      product_to_aborh_disp = substring(1,12,trim(concat(trim(bb_to_abo_disp)," ",trim(bb_to_rh_disp)
         ))), col 68, product_to_aborh_disp"############",
      product_aborh_disp = fillstring(12," "), product_aborh_disp = substring(1,12,trim(concat(trim(
          bp_cur_abo_disp)," ",trim(bp_cur_rh_disp)))), col 81,
      product_aborh_disp"############"
      IF (trim(prs.name_full_formatted) > "")
       col 94, prs.name_full_formatted"#########################"
      ELSE
       col 94, captions->not_on_file
      ENDIF
      col 120, usr.username"######", row + 1
      IF (row > 56)
       BREAK
      ENDIF
      col 2, pe_dt_tm"@TIMENOSECONDS;;M", col 94,
      override_reason_disp"#########################", row + 2
     ENDIF
    ENDIF
   FOOT PAGE
    row 57, col 1, line,
    row + 1, col 1, captions->report_id,
    col 58, captions->page_no, col 64,
    curpage"###", col 100, captions->printed,
    col 109, curdate"@DATECONDENSED;;d", col 120,
    curtime"@TIMENOSECONDS;;M"
   FOOT REPORT
    row 60, col 51, captions->end_of_report
   WITH nocounter, maxrow = 61, nullreport,
    outerjoin(d1), outerjoin(d2), outerjoin(d3),
    compress, nolandscape
  ;end select
  IF (((datafoundflag=true) OR ((request->null_ind=1))) )
   SET rpt_cnt += 1
   SET stat = alterlist(reply->rpt_list,rpt_cnt)
   SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
   SET datafoundflag = false
  ENDIF
 ENDIF
 IF (((uar_get_code_meaning(request->exception_type_cd)="UNGTNOCHG") OR ((request->exception_type_cd=
 0.0))) )
  EXECUTE cpm_create_file_name_logical "bbt_ungtnochg", "txt", "x"
  SET cdf_meaning = "UNGTNOCHG"
  SET exception_code = get_code_value(14072,cdf_meaning)
  SET exception_disp = uar_get_code_display(exception_code)
  SELECT INTO cpm_cfn_info->file_name_logical
   bb.exception_id, bb.updt_dt_tm, bb_from_abo_disp = uar_get_code_display(bb.from_abo_cd),
   bb_from_rh_disp = uar_get_code_display(bb.from_rh_cd), bb_to_abo_disp = uar_get_code_display(bb
    .to_abo_cd), bb_to_rh_disp = uar_get_code_display(bb.to_rh_cd),
   bp_cur_abo_disp = uar_get_code_display(bp.cur_abo_cd), bp_cur_rh_disp = uar_get_code_display(bp
    .cur_rh_cd), usr.username,
   pr.product_nbr, pr.product_sub_nbr, override_reason_disp = decode(bb.seq,uar_get_code_display(bb
     .override_reason_cd)," "),
   product_disp = decode(pr.seq,uar_get_code_display(pr.product_cd)," ")
   FROM (dummyt d3  WITH seq = 1),
    bb_exception bb,
    prsnl usr,
    product pr,
    blood_product bp,
    prsnl prs,
    encntr_prsnl_reltn epr,
    result re,
    orders o
   PLAN (bb
    WHERE exception_code=bb.exception_type_cd
     AND bb.active_ind=1
     AND bb.active_status_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
    JOIN (usr
    WHERE bb.updt_id=usr.person_id)
    JOIN (re
    WHERE bb.result_id > 0
     AND bb.result_id=re.result_id)
    JOIN (o
    WHERE re.order_id=o.order_id)
    JOIN (pr
    WHERE o.product_id=pr.product_id
     AND (((request->cur_owner_area_cd > 0.0)
     AND (request->cur_owner_area_cd=pr.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (request->cur_inv_area_cd=pr.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
    JOIN (bp
    WHERE pr.product_id=bp.product_id)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (epr
    WHERE epr.encntr_prsnl_r_cd=admitdoc
     AND o.encntr_id=epr.encntr_id
     AND o.encntr_id > 0
     AND epr.active_ind=1)
    JOIN (prs
    WHERE epr.prsnl_person_id=prs.person_id)
   ORDER BY cnvtdatetime(bb.updt_dt_tm), bb.exception_id
   HEAD REPORT
    new_exception = "Y"
   HEAD PAGE
    beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm),
    inc_i18nhandle = 0,
    inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
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
    CALL center(captions->bb_exception,1,125),
    col 104, captions->time, col 118,
    curtime"@TIMENOSECONDS;;M", row + 1, col 104,
    captions->as_of_date, col 118, curdate"@DATECONDENSED;;d",
    row save_row, row + 1, col 1,
    captions->bb_owner, col 19, cur_owner_area_disp,
    row + 1, col 1, captions->inventory_area,
    col 17, cur_inv_area_disp, row + 2,
    col 32, captions->beg_date, col 48,
    beg_dt_tm"@DATECONDENSED;;d", col 56, beg_dt_tm"@TIMENOSECONDS;;M",
    col 69, captions->end_date, col 82,
    end_dt_tm"@DATECONDENSED;;d", col 90, end_dt_tm"@TIMENOSECONDS;;M",
    row + 2, col 1, exception_disp,
    row + 2,
    CALL center(captions->date,1,7),
    CALL center(captions->product_number,9,33),
    CALL center(captions->validation_aborh,55,92),
    CALL center(captions->physician,94,118), row + 1,
    CALL center(captions->new_time,1,7),
    CALL center(captions->accession,9,33),
    CALL center(captions->product_type,35,53),
    CALL center(captions->previous,55,66),
    CALL center(captions->resulted,68,79),
    CALL center(captions->current,81,92),
    CALL center(captions->reason,94,118),
    CALL center(captions->tech,120,125), row + 1,
    col 1, "-------", col 9,
    "-------------------------", col 35, "-------------------",
    col 55, "------------", col 68,
    "------------", col 81, "------------",
    col 94, "-------------------------", col 120,
    "------", row + 1
   HEAD bb.exception_id
    new_exception = "Y"
   DETAIL
    IF (bb.exception_id > 0)
     datafoundflag = true
     IF (new_exception="Y")
      new_exception = "N", pe_dt_tm = cnvtdatetime(bb.updt_dt_tm)
      IF (row > 56)
       BREAK
      ENDIF
      col 1, pe_dt_tm"@DATECONDENSED;;d", prod_nbr_display = concat(trim(bp.supplier_prefix),trim(pr
        .product_nbr)," ",trim(pr.product_sub_nbr)),
      col 9, prod_nbr_display, col 35,
      product_disp"###################", product_from_aborh_disp = fillstring(12," "),
      product_from_aborh_disp = substring(1,12,trim(concat(trim(bb_from_abo_disp)," ",trim(
          bb_from_rh_disp)))),
      col 55, product_from_aborh_disp"############", product_to_aborh_disp = fillstring(12," "),
      product_to_aborh_disp = substring(1,12,trim(concat(trim(bb_to_abo_disp)," ",trim(bb_to_rh_disp)
         ))), col 68, product_to_aborh_disp"############",
      product_from_aborh_disp = fillstring(12," "), product_aborh_disp = substring(1,12,trim(concat(
         trim(bp_cur_abo_disp)," ",trim(bp_cur_rh_disp)))), col 81,
      product_aborh_disp"############"
      IF (trim(prs.name_full_formatted) > "")
       col 94, prs.name_full_formatted"#########################"
      ELSE
       col 94, captions->not_on_file
      ENDIF
      col 120, usr.username"######", row + 1
      IF (row > 56)
       BREAK
      ENDIF
      IF (pe_dt_tm > 0)
       col 2, pe_dt_tm"@TIMENOSECONDS;;M"
      ENDIF
      col 94, override_reason_disp"#########################", row + 2
     ENDIF
    ENDIF
   FOOT PAGE
    row 57, col 1, line,
    row + 1, col 1, captions->report_id,
    col 58, captions->page_no, col 64,
    curpage"###", col 100, captions->printed,
    col 109, curdate"@DATECONDENSED;;d", col 120,
    curtime"@TIMENOSECONDS;;M"
   FOOT REPORT
    row 60, col 51, captions->end_of_report
   WITH nocounter, maxrow = 61, nullreport,
    outerjoin(d3), compress, nolandscape
  ;end select
  IF (((datafoundflag=true) OR ((request->null_ind=1))) )
   SET rpt_cnt += 1
   SET stat = alterlist(reply->rpt_list,rpt_cnt)
   SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
   SET datafoundflag = false
  ENDIF
 ENDIF
 IF (((uar_get_code_meaning(request->exception_type_cd)="OVERINTERP") OR ((request->exception_type_cd
 =0.0))) )
  SET stat = bbtgetencounterlocations(request->facility_cd,pref_level_bb)
  IF ((stat=- (1)))
   SET reply->status_data.status = "F"
   GO TO exit_script
  ENDIF
  SET facidx = 0
  EXECUTE cpm_create_file_name_logical "bbt_over_interp", "txt", "x"
  SET cdf_meaning = "OVERINTERP"
  SET exception_code = get_code_value(14072,cdf_meaning)
  SET exception_disp = uar_get_code_display(exception_code)
  IF ((request->facility_cd > 0))
   SET facility_disp = uar_get_code_display(request->facility_cd)
  ENDIF
  SELECT INTO cpm_cfn_info->file_name_logical
   bb.exception_id, bb.updt_dt_tm, usr.username,
   dta.mnemonic, perr.result_value_alpha, perr.result_value_numeric,
   perr.result_value_dt_tm, perr.result_code_set_cd, result_cv_disp = uar_get_code_display(perr
    .result_code_set_cd),
   per.name_full_formatted, pra.alias, person_alias_exists = decode(pra.seq,build(pra.person_alias_id
     ),"0.0"),
   mrn_alias = cnvtalias(pra.alias,pra.alias_pool_cd), ac.accession, pr.product_nbr,
   pr.product_sub_nbr, override_reason_disp = decode(bb.seq,uar_get_code_display(bb
     .override_reason_cd)," "), product_disp = decode(pr.seq,uar_get_code_display(pr.product_cd)," "),
   product_ind = decode(pr.seq,"1",pe.seq,"2","3")
   FROM bb_exception bb,
    prsnl usr,
    discrete_task_assay dta,
    perform_result perr,
    result re,
    orders o,
    encounter e,
    (dummyt d3  WITH seq = 1),
    person per,
    (dummyt d_pra  WITH seq = 1),
    person_alias pra,
    accession_order_r ac,
    (dummyt d6  WITH seq = 1),
    product pr,
    (dummyt d_bp  WITH seq = 1),
    blood_product bp,
    (dummyt d_pe  WITH seq = 1),
    product_event pe,
    product pr2,
    (dummyt d_bp2  WITH seq = 1),
    blood_product bp2,
    (dummyt d_ac  WITH seq = 1)
   PLAN (bb
    WHERE exception_code=bb.exception_type_cd
     AND bb.active_ind=1
     AND bb.active_status_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
    JOIN (usr
    WHERE bb.updt_id=usr.person_id
     AND bb.updt_id != null
     AND bb.updt_id > 0)
    JOIN (perr
    WHERE bb.perform_result_id=perr.perform_result_id
     AND bb.result_id=perr.result_id
     AND bb.result_id != null
     AND bb.result_id > 0)
    JOIN (re
    WHERE bb.result_id=re.result_id)
    JOIN (o
    WHERE re.order_id=o.order_id
     AND o.order_id != null
     AND o.order_id > 0)
    JOIN (dta
    WHERE re.task_assay_cd=dta.task_assay_cd)
    JOIN (e
    WHERE e.encntr_id=o.encntr_id
     AND ((expand(facidx,1,size(encounterlocations->locs,5),e.loc_facility_cd,encounterlocations->
     locs[facidx].encfacilitycd)) OR ((((((e.loc_facility_cd=request->facility_cd)) OR (e.encntr_id=0
    )) ) OR ((request->facility_cd=0.0))) )) )
    JOIN (d6
    WHERE d6.seq=1)
    JOIN (pr
    WHERE o.product_id=pr.product_id
     AND pr.product_id != null
     AND pr.product_id > 0)
    JOIN (d_bp
    WHERE d_bp.seq=1)
    JOIN (bp
    WHERE bp.product_id=pr.product_id)
    JOIN (d_pe
    WHERE d_pe.seq=1)
    JOIN (pe
    WHERE pe.bb_result_id=re.bb_result_id
     AND pe.bb_result_id != null
     AND pe.bb_result_id > 0
     AND pe.event_type_cd=in_progress_cd)
    JOIN (pr2
    WHERE pr2.product_id=pe.product_id
     AND pr2.product_id != null
     AND pr2.product_id > 0)
    JOIN (d_bp2
    WHERE d_bp2.seq=1)
    JOIN (bp2
    WHERE bp2.product_id=pr2.product_id)
    JOIN (d3
    WHERE d3.seq=1)
    JOIN (per
    WHERE o.person_id=per.person_id
     AND o.person_id != null
     AND o.person_id > 0)
    JOIN (d_pra
    WHERE d_pra.seq=1)
    JOIN (pra
    WHERE pra.person_alias_type_cd=mrn_code
     AND o.person_id=pra.person_id
     AND pra.active_ind=1)
    JOIN (d_ac
    WHERE d_ac.seq=1)
    JOIN (ac
    WHERE o.order_id=ac.order_id
     AND ac.primary_flag=0)
   ORDER BY cnvtdatetime(bb.updt_dt_tm), bb.exception_id
   HEAD REPORT
    new_exception = "Y", mrn_cnt = 0, bmrnfound = "F",
    stat = alterlist(alias->person_alias,mrn_cnt), formatted_acc = fillstring(30," ")
   HEAD PAGE
    beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm),
    inc_i18nhandle = 0,
    inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
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
    CALL center(captions->bb_exception,1,125),
    col 104, captions->time, col 118,
    curtime"@TIMENOSECONDS;;M", row + 1, col 104,
    captions->as_of_date, col 118, curdate"@DATECONDENSED;;d",
    row save_row, row + 1, col 1,
    captions->bb_owner, col 19, cur_owner_area_disp,
    row + 1, col 1, captions->inventory_area,
    col 17, cur_inv_area_disp, row + 2,
    col 32, captions->beg_date, col 48,
    beg_dt_tm"@DATECONDENSED;;d", col 56, beg_dt_tm"@TIMENOSECONDS;;M",
    col 69, captions->end_date, col 82,
    end_dt_tm"@DATECONDENSED;;d", col 90, end_dt_tm"@TIMENOSECONDS;;M"
    IF ((request->facility_cd > 0))
     row + 2, col 1, captions->facility,
     col 11, facility_disp
    ENDIF
    row + 2, col 1, exception_disp,
    row + 2, col 65, captions->name,
    row + 1, col 66, captions->mrn,
    row + 1, col 1, captions->heading,
    col 53, captions->accession_head, col 106,
    captions->reason_head, row + 1, col 1,
    "---------------", col 17, "--------------",
    col 32, "-------------", col 46,
    "------", col 53, "--------------------------",
    col 80, "-------------------------", col 106,
    "--------------------", row + 1
   HEAD bb.exception_id
    datafoundflag = true, new_exception = "Y"
    FOR (i = 1 TO size(alias->person_alias,5))
      alias->person_alias[i].mrn = " "
    ENDFOR
    mrn_cnt = 0
   DETAIL
    IF (person_alias_exists != "0.0")
     bmrnfound = "F"
     IF (mrn_cnt=0)
      row + 0
     ELSE
      FOR (i = 1 TO mrn_cnt)
        IF ((alias->person_alias[i].mrn=mrn_alias))
         bmrnfound = "T", i = mrn_cnt
        ENDIF
      ENDFOR
     ENDIF
     IF (bmrnfound="F")
      mrn_cnt += 1, stat = alterlist(alias->person_alias,mrn_cnt), alias->person_alias[mrn_cnt].mrn
       = mrn_alias
     ENDIF
    ENDIF
   FOOT  bb.exception_id
    IF (((bb.exception_id > 0
     AND product_ind="1"
     AND (((request->cur_owner_area_cd > 0.0)
     AND (request->cur_owner_area_cd=pr.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (request->cur_inv_area_cd=pr.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) ) OR (((
    bb.exception_id > 0
     AND product_ind="2"
     AND (((request->cur_owner_area_cd > 0.0)
     AND (request->cur_owner_area_cd=pr2.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (request->cur_inv_area_cd=pr2.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) ) OR (
    bb.exception_id > 0
     AND product_ind="3")) )) )
     IF (new_exception="Y")
      new_exception = "N"
      IF (row > 55)
       BREAK
      ENDIF
      col 1, dta.mnemonic"###############"
      IF (trim(perr.result_value_alpha) != " ")
       col 17, perr.result_value_alpha"##############"
      ELSEIF (perr.result_value_numeric > 0)
       col 17, perr.result_value_numeric"##############"
      ELSEIF (perr.result_value_dt_tm > 0)
       res_val_dt_tm = cnvtdatetime(perr.result_value_dt_tm), col 17, res_val_dt_tm
       "@DATECONDENSED;;d",
       col 25, res_val_dt_tm"@TIMENOSECONDS;;M"
      ELSEIF (perr.result_code_set_cd > 0)
       col 17, result_cv_disp"##############"
      ENDIF
      pe_dt_tm = cnvtdatetime(bb.updt_dt_tm), col 32, pe_dt_tm"@DATECONDENSED;;d",
      col 40, pe_dt_tm"@TIMENOSECONDS;;M", col 46,
      usr.username"######"
      IF (o.seq > 0)
       col 53, per.name_full_formatted"##########################"
      ENDIF
      IF (product_ind="1")
       prod_nbr_display = concat(trim(bp.supplier_prefix),trim(pr.product_nbr)," ",trim(pr
         .product_sub_nbr)), col 80, prod_nbr_display
      ELSEIF (product_ind="2")
       prod_nbr_display = concat(trim(bp2.supplier_prefix),trim(pr2.product_nbr)," ",trim(pr2
         .product_sub_nbr)), col 80, prod_nbr_display
      ELSE
       col 80, "            "
      ENDIF
      col 106, override_reason_disp"####################", row + 1
      IF (row > 56)
       BREAK
      ENDIF
      IF (per.person_id > 0)
       IF (mrn_cnt < 2)
        IF (size(alias->person_alias,5) > 0
         AND trim(alias->person_alias[1].mrn) > "")
         col 53, alias->person_alias[1].mrn
        ELSE
         col 53, captions->not_on_file
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
          col 53, alias->person_alias[i].mrn
         ENDIF
        ENDFOR
       ENDIF
      ENDIF
      IF (ac.accession > " ")
       row + 1
       IF (row > 56)
        BREAK
       ENDIF
       formatted_acc = cnvtacc(ac.accession), col 53, formatted_acc"##########################"
      ENDIF
      row + 2
     ENDIF
    ENDIF
   FOOT PAGE
    row 57, col 1, line,
    row + 1, col 1, captions->report_id,
    col 58, captions->page_no, col 64,
    curpage"###", col 100, captions->printed,
    col 109, curdate"@DATECONDENSED;;d", col 120,
    curtime"@TIMENOSECONDS;;M"
   FOOT REPORT
    row 60, col 51, captions->end_of_report
   WITH nocounter, maxrow = 61, nullreport,
    outerjoin(d3), outerjoin(d6), dontcare(ac),
    dontcare(pr), outerjoin(d_bp), dontcare(bp),
    outerjoin(d_pe), dontcare(pe), dontcare(pr2),
    dontcare(bp2), outerjoin(d_bp2), outerjoin(d_pra),
    dontcare(pra), compress, nolandscape
  ;end select
  IF (((datafoundflag=true) OR ((request->null_ind=1))) )
   SET rpt_cnt += 1
   SET stat = alterlist(reply->rpt_list,rpt_cnt)
   SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
   SET datafoundflag = false
  ENDIF
 ENDIF
 IF (((uar_get_code_meaning(request->exception_type_cd)="MSBOS") OR ((request->exception_type_cd=0.0)
 )) )
  IF (printreportind(lmsbos_cs)=1)
   SET cdf_meaning = "MSBOS"
   IF ((request->exception_type_cd=0.0))
    SET exception_code = get_code_value(14072,cdf_meaning)
   ELSE
    SET exception_code = request->exception_type_cd
   ENDIF
   EXECUTE bbt_rpt_ex_msbos
  ENDIF
 ENDIF
 RECORD bb_exception_record(
   1 bb_exception_list[*]
     2 bb_exception_id = f8
 )
 IF (((uar_get_code_meaning(request->exception_type_cd)="CXM") OR ((request->exception_type_cd=0.0)
 )) )
  EXECUTE cpm_create_file_name_logical "bbt_cxm", "txt", "x"
  SET pat_id = 0.0
  SET dash_line = fillstring(175,"-")
  SET cdf_meaning = "CXM"
  SET exception_code = get_code_value(14072,cdf_meaning)
  SET exception_disp = uar_get_code_display(exception_code)
  SET exception_count = 0
  SELECT INTO "nl:"
   be.exception_id
   FROM bb_exception be,
    bb_exc_cxm_product becp,
    product p
   PLAN (be
    WHERE be.exception_type_cd=exception_code
     AND be.active_ind=1
     AND be.active_status_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
     end_dt_tm))
    JOIN (becp
    WHERE becp.bb_exception_id=be.exception_id)
    JOIN (p
    WHERE p.product_id=becp.product_id
     AND (((request->cur_owner_area_cd > 0.0)
     AND (request->cur_owner_area_cd=p.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (request->cur_inv_area_cd=p.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
   ORDER BY be.exception_id
   HEAD REPORT
    exception_count = 0
   HEAD be.exception_id
    IF (be.exception_id > 0.0)
     datafoundflag = true, exception_count += 1, stat = alterlist(bb_exception_record->
      bb_exception_list,exception_count),
     bb_exception_record->bb_exception_list[exception_count].bb_exception_id = be.exception_id
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO cpm_cfn_info->file_name_logical
   d_exception.seq, patient_abo_disp = uar_get_code_display(be.from_abo_cd), patient_rh_disp =
   uar_get_code_display(be.from_rh_cd),
   be.exception_dt_tm, be.order_id, aor.seq,
   aor.accession_id, aor.accession, pn.name_full_formatted,
   pn2.name_full_formatted, pl.username, reason_disp = uar_get_code_display(bec.override_reason_cd),
   becp.event_dt_tm, becp.crossmatch_expire_dt_tm, table_ind = decode(becp.seq,"BECP",bec.seq,"BEC ",
    "XXXX"),
   product_type_disp = uar_get_code_display(becp.product_cd), product_abo_disp = uar_get_code_display
   (becp.abo_cd), product_rh_disp = uar_get_code_display(becp.rh_cd),
   p.product_nbr, bp.supplier_prefix, pe1.event_dt_tm,
   pe2.event_dt_tm, pe3.event_dt_tm, p.cur_owner_area_cd,
   p.cur_inv_area_cd, encntr_alias = decode(ea.seq,"Y","N")
   FROM (dummyt d_exception  WITH seq = value(exception_count)),
    bb_exception be,
    person pn,
    (dummyt d_pn2  WITH seq = 1),
    person pn2,
    prsnl pl,
    orders o,
    (dummyt d_ea  WITH seq = 1),
    encntr_alias ea,
    (dummyt d_ea2  WITH seq = 1),
    accession_order_r aor,
    (dummyt d_pn3  WITH seq = 1),
    person pn3,
    (dummyt d_bec  WITH seq = 1),
    bb_except_cxm bec,
    bb_exc_cxm_product becp,
    product p,
    blood_product bp,
    (dummyt d_pe1  WITH seq = 1),
    product_event pe1,
    (dummyt d_pe2  WITH seq = 1),
    product_event pe2,
    (dummyt d_pe3  WITH seq = 1),
    product_event pe3,
    code_value cv
   PLAN (d_exception
    WHERE d_exception.seq <= exception_count)
    JOIN (be
    WHERE (be.exception_id=bb_exception_record->bb_exception_list[d_exception.seq].bb_exception_id)
     AND be.active_ind=1)
    JOIN (pn
    WHERE pn.person_id=be.person_id)
    JOIN (d_pn2
    WHERE d_pn2.seq=1)
    JOIN (pn2
    WHERE pn2.person_id=be.exception_prsnl_id
     AND pn2.person_id != null
     AND pn2.person_id > 0)
    JOIN (pl
    WHERE pl.person_id=pn2.person_id)
    JOIN (o
    WHERE o.order_id=be.order_id
     AND o.order_id != null
     AND o.order_id > 0)
    JOIN (d_ea
    WHERE d_ea.seq=1)
    JOIN (ea
    WHERE ea.encntr_id=o.encntr_id
     AND ea.encntr_alias_type_cd=encntr_mrn_code
     AND ea.active_ind=1
     AND ea.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND ea.end_effective_dt_tm >= cnvtdatetime(sysdate))
    JOIN (d_ea2
    WHERE d_ea2.seq=1)
    JOIN (aor
    WHERE aor.order_id=o.order_id
     AND aor.primary_flag=0)
    JOIN (d_pn3
    WHERE d_pn3.seq=1)
    JOIN (pn3
    WHERE pn3.person_id=o.last_update_provider_id
     AND pn3.person_id != null
     AND pn3.person_id > 0)
    JOIN (d_bec
    WHERE d_bec.seq=1)
    JOIN (((bec
    WHERE bec.bb_exception_id=be.exception_id
     AND bec.bb_exception_id != null
     AND bec.bb_exception_id > 0)
    JOIN (cv
    WHERE cv.code_value=bec.message_cd)
    ) ORJOIN ((becp
    WHERE becp.bb_exception_id=be.exception_id
     AND becp.bb_exception_id != null
     AND becp.bb_exception_id > 0)
    JOIN (p
    WHERE p.product_id=becp.product_id
     AND p.product_id != null
     AND p.product_id > 0
     AND (((request->cur_owner_area_cd > 0.0)
     AND (request->cur_owner_area_cd=p.cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (request->cur_inv_area_cd=p.cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
    JOIN (bp
    WHERE bp.product_id=p.product_id)
    JOIN (d_pe1
    WHERE d_pe1.seq=1)
    JOIN (pe1
    WHERE pe1.product_event_id=becp.product_event_id
     AND pe1.event_type_cd=crossmatch_code
     AND pe1.product_event_id != null
     AND pe1.product_event_id > 0)
    JOIN (d_pe2
    WHERE d_pe2.seq=1)
    JOIN (pe2
    WHERE pe2.related_product_event_id=pe1.product_event_id
     AND pe2.event_type_cd=dispense_code
     AND pe2.related_product_event_id != null
     AND pe2.related_product_event_id > 0)
    JOIN (d_pe3
    WHERE d_pe3.seq=1)
    JOIN (pe3
    WHERE pe3.related_product_event_id=pe2.product_event_id
     AND pe2.event_type_cd=transfuse_code
     AND pe3.related_product_event_id != null
     AND pe3.related_product_event_id > 0)
    ))
   ORDER BY aor.accession, be.exception_id, table_ind,
    bec.bb_except_cxm_id, p.product_nbr
   HEAD REPORT
    formatted_acc = fillstring(25," ")
   HEAD PAGE
    row + 2, beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->
     end_dt_tm),
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
    CALL center(captions->bb_exception,1,160),
    col 143, captions->time, col 150,
    curtime"@TIMENOSECONDS;;M", row + 1, col 149,
    captions->as_of_date, col 161, curdate"@DATECONDENSED;;d",
    row save_row, row + 1, col 57,
    captions->beg_date, col 73, beg_dt_tm"@DATECONDENSED;;d",
    col 81, beg_dt_tm"@TIMENOSECONDS;;M", col 94,
    captions->end_date, col 107, end_dt_tm"@DATECONDENSED;;d",
    col 115, end_dt_tm"@TIMENOSECONDS;;M", row + 1,
    col 1, exception_disp"########################################", row + 1,
    col 1, dash_line, print_header_exceptions = "Y",
    print_header_products = "Y", encntr_alias_disp = fillstring(23," ")
   HEAD be.exception_id
    IF (row > 38)
     BREAK
    ENDIF
    row + 2, col 1, captions->patient_name,
    col 30, captions->mrn, col 55,
    captions->aborh, col 70, captions->accession_nbr,
    col 100, captions->physician, col 130,
    captions->tech, col 145, captions->dt_tm,
    row + 1, col 1, "----------------------------",
    col 30, "-----------------------", col 54,
    "---------------", col 70, "-------------------------",
    col 100, "----------------------------", col 130,
    "----------", col 145, "-------------"
    IF (exception_count > 0)
     row + 1, col 1, pn.name_full_formatted"############################"
     IF (encntr_alias="Y")
      encntr_alias_disp = cnvtalias(ea.alias,ea.alias_pool_cd)
     ELSE
      encntr_alias_disp = captions->not_on_file
     ENDIF
     col 30, encntr_alias_disp"#######################", pat_abo_rh_disp = concat(trim(
       patient_abo_disp)," ",trim(patient_rh_disp)),
     col 54, pat_abo_rh_disp"###############", formatted_acc = cnvtacc(aor.accession),
     "#########################", col 70, formatted_acc,
     col 100, pn3.name_full_formatted"############################", col 130,
     pl.username"##########", date_time = cnvtdatetime(be.exception_dt_tm), col 145,
     date_time"@DATECONDENSED;;d", col 153, date_time"@TIMENOSECONDS;;M",
     print_header_exceptions = "Y", print_header_products = "Y"
    ENDIF
   DETAIL
    IF (row > 42)
     page_break = "Y", BREAK
    ENDIF
    IF (table_ind="BEC ")
     IF (row > 38
      AND print_header_exceptions="Y"
      AND page_break="N")
      page_break = "Y", BREAK
     ENDIF
     IF (((page_break="Y") OR (print_header_exceptions="Y")) )
      page_break = "N", row + 2, col 5,
      captions->exceptions, col 110, captions->reason_for_override,
      row + 1, ex_line = fillstring(100,"-"), col 5,
      ex_line, col 110, "----------------------------------------",
      print_header_exceptions = "N"
     ENDIF
     row + 1, col 5, cv.definition,
     col 110, reason_disp"########################################"
    ELSEIF (table_ind="BECP")
     IF (row > 38
      AND print_header_products="Y"
      AND page_break="N")
      page_break = "Y", BREAK
     ENDIF
     IF (((page_break="Y") OR (print_header_products="Y")) )
      page_break = "N", row + 2, col 5,
      captions->products_xmd, col 20, captions->product_number,
      col 53, captions->type, col 78,
      captions->aborh, col 95, captions->xmd_dt_tm,
      col 115, captions->xm_expire_dt_tm, col 135,
      captions->dispensed_dt_tm, col 155, captions->transfused_dt_tm,
      row + 1, col 20, "-------------------------------",
      col 53, "-----------------------", col 78,
      "---------------", col 95, "-------------",
      col 115, "---------------", col 135,
      "---------------", col 155, "----------------",
      print_header_products = "N"
     ENDIF
     row + 1, prod_disp = concat(trim(bp.supplier_prefix),trim(p.product_nbr)," ",trim(p
       .product_sub_nbr)), col 20,
     prod_disp"###############################", col 53, product_type_disp"#######################",
     abo_rh_disp = concat(trim(product_abo_disp)," ",trim(product_rh_disp)), col 78, abo_rh_disp
     "###############",
     xm_dt_tm = cnvtdatetime(pe1.event_dt_tm), col 95, xm_dt_tm"@DATECONDENSED;;d",
     col 103, xm_dt_tm"@TIMENOSECONDS;;M", xm_exp_dt_tm = cnvtdatetime(becp.crossmatch_expire_dt_tm),
     col 115, xm_exp_dt_tm"@DATECONDENSED;;d", col 123,
     xm_exp_dt_tm"@TIMENOSECONDS;;M"
     IF (pe2.seq > 0)
      disp_dt_tm = cnvtdatetime(pe2.event_dt_tm), col 135, disp_dt_tm"@DATECONDENSED;;d",
      col 143, disp_dt_tm"@TIMENOSECONDS;;M"
     ENDIF
     IF (pe3.seq > 0)
      trans_dt_tm = cnvtdatetime(pe3.event_dt_tm), col 155, trans_dt_tm"@DATECONDENSED;;d",
      col 163, trans_dt_tm"@TIMENOSECONDS;;M"
     ENDIF
     print_header_patient = "Y"
    ENDIF
   FOOT  be.exception_id
    row + 2
    IF (exception_count > 0)
     col 1, dash_line
    ENDIF
    row + 1
   FOOT PAGE
    row 44, col 1, dash_line,
    row + 1, col 1, captions->report_id,
    col 85, captions->page_no, col 91,
    curpage"###;L", col 140, captions->printed,
    col 151, curdate"@DATECONDENSED;;d"
   FOOT REPORT
    row 47, col 51, captions->end_of_report
   WITH nocounter, dontcare(pn2), dontcare(ea),
    dontcare(pn3), outerjoin(d_bec), outerjoin(d_pe1),
    dontcare(pe2), outerjoin(d_pe3), nullreport,
    maxrow = 49, maxcol = 180, compress,
    landscape
  ;end select
  IF (((datafoundflag=true) OR ((request->null_ind=1))) )
   SET rpt_cnt += 1
   SET stat = alterlist(reply->rpt_list,rpt_cnt)
   SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
   SET datafoundflag = false
  ENDIF
  FREE RECORD be_exception_record
 ENDIF
 SELECT INTO "nl:"
  FROM answer a
  PLAN (a
   WHERE a.question_cd IN (pref_xm_abo_req_cd, pref_xm_2a_req_cd, pref_xm_agab_val_cd,
   pref_xm_trfrq_val_cd, pref_xm_absc_req_cd,
   pref_xm_allo_blk_cd, pref_xm_inc_xm_cd, pref_disp_inc_xm_cd)
    AND a.active_ind=1)
  HEAD REPORT
   pref_answer_cd = 0.0
  DETAIL
   IF (isnumeric(trim(a.answer)) > 0)
    pref_answer_cd = cnvtreal(trim(a.answer))
   ELSE
    pref_answer_cd = 0
   ENDIF
   IF (pref_answer_cd=answer_y_cd)
    CASE (a.question_cd)
     OF pref_xm_abo_req_cd:
      pref_curr_abo_ind = 1
     OF pref_xm_2a_req_cd:
      pref_2nd_abo_ind = 1
     OF pref_xm_agab_val_cd:
      pref_agab_val_ind = 1
     OF pref_xm_trfrq_val_cd:
      pref_treq_val_ind = 1
     OF pref_xm_absc_req_cd:
      pref_cur_absc_ind = 1
     OF pref_xm_inc_xm_cd:
      pref_xm_inc_xm_ind = 1
     OF pref_disp_inc_xm_cd:
      pref_disp_inc_xm_ind = 1
    ENDCASE
   ELSEIF (pref_answer_cd=answer_except_cd)
    IF (a.question_cd=pref_xm_allo_blk_cd)
     pref_allo_blk_except_ind = 1
    ENDIF
   ENDIF
 ;end select
 SET xm_exception_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(14072,nullterm("XMNOABSC"),1,xm_exception_cd)
 IF ((((request->exception_type_cd=xm_exception_cd)) OR ((request->exception_type_cd=0.0)
  AND pref_cur_absc_ind=1)) )
  EXECUTE bbt_rpt_ex_xmnodetail
 ENDIF
 SET xm_exception_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(14072,nullterm("XMUNMATDEMO"),1,xm_exception_cd)
 IF ((((request->exception_type_cd=xm_exception_cd)) OR ((request->exception_type_cd=0.0)
  AND ((pref_curr_abo_ind=1) OR (pref_2nd_abo_ind=1)) )) )
  EXECUTE bbt_rpt_ex_xmnodetail
 ENDIF
 SET xm_exception_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(14072,nullterm("XMUNMATCUR2D"),1,xm_exception_cd)
 IF ((((request->exception_type_cd=xm_exception_cd)) OR ((request->exception_type_cd=0.0)
  AND pref_curr_abo_ind=1
  AND pref_2nd_abo_ind=1)) )
  EXECUTE bbt_rpt_ex_xmnodetail
 ENDIF
 SET xm_exception_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(14072,nullterm("XMNO2NDABO"),1,xm_exception_cd)
 IF ((((request->exception_type_cd=xm_exception_cd)) OR ((request->exception_type_cd=0.0)
  AND pref_2nd_abo_ind=1)) )
  EXECUTE bbt_rpt_ex_xmnodetail
 ENDIF
 SET xm_exception_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(14072,nullterm("XMNOCURABO"),1,xm_exception_cd)
 IF ((((request->exception_type_cd=xm_exception_cd)) OR ((request->exception_type_cd=0.0)
  AND pref_curr_abo_ind=1)) )
  EXECUTE bbt_rpt_ex_xmnodetail
 ENDIF
 SET xm_exception_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(14072,nullterm("XMNOTREQ"),1,xm_exception_cd)
 IF ((((request->exception_type_cd=xm_exception_cd)) OR ((request->exception_type_cd=0.0)
  AND pref_treq_val_ind=1)) )
  EXECUTE bbt_rpt_ex_xmdetail
 ENDIF
 SET xm_exception_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(14072,nullterm("XMNOAG"),1,xm_exception_cd)
 IF ((((request->exception_type_cd=xm_exception_cd)) OR ((request->exception_type_cd=0.0)
  AND pref_agab_val_ind=1)) )
  EXECUTE bbt_rpt_ex_xmdetail
 ENDIF
 SET xm_exception_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(14072,nullterm("XM ALLO BLK"),1,xm_exception_cd)
 IF ((((request->exception_type_cd=xm_exception_cd)) OR ((request->exception_type_cd=0.0)
  AND pref_allo_blk_except_ind=1)) )
  EXECUTE bbt_rpt_ex_xmdetail
 ENDIF
 SET xm_exception_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(14072,nullterm("INCXM"),1,xm_exception_cd)
 IF ((((request->exception_type_cd=xm_exception_cd)) OR ((request->exception_type_cd=0.0)
  AND pref_xm_inc_xm_ind=1)) )
  EXECUTE bbt_rpt_ex_xmnodetail
 ENDIF
 SET xm_exception_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(14072,nullterm("INCXMDISP"),1,xm_exception_cd)
 IF ((((request->exception_type_cd=xm_exception_cd)) OR ((request->exception_type_cd=0.0)
  AND pref_disp_inc_xm_ind=1)) )
  EXECUTE bbt_rpt_ex_xmnodetail
 ENDIF
 DECLARE pref_disp_no_cur_aborh = i2 WITH protect, noconstant(0)
 DECLARE pref_disp_no_2aborh = i2 WITH protect, noconstant(0)
 DECLARE disp_exception_cd = f8 WITH protect, noconstant(0.0)
 SET pref_disp_no_cur_aborh = bbtgetdisponcurrentaborh(request->facility_cd)
 SET pref_disp_no_2aborh = bbtgetdisponsecondaborh(request->facility_cd)
 SET disp_exception_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(14072,nullterm("DISPNOCURABO"),1,disp_exception_cd)
 IF ((((request->exception_type_cd=disp_exception_cd)) OR ((request->exception_type_cd=0.0)
  AND ((pref_disp_no_cur_aborh=1) OR (pref_disp_no_2aborh=1)) )) )
  EXECUTE bbt_rpt_ex_disp_nodetail
 ENDIF
 SET disp_exception_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(14072,nullterm("DISPNO2NDABO"),1,disp_exception_cd)
 IF ((((request->exception_type_cd=disp_exception_cd)) OR ((request->exception_type_cd=0.0)
  AND pref_disp_no_2aborh=1)) )
  EXECUTE bbt_rpt_ex_disp_nodetail
 ENDIF
 SET disp_exception_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(14072,nullterm("DISPUMDEMO"),1,disp_exception_cd)
 IF ((((request->exception_type_cd=disp_exception_cd)) OR ((request->exception_type_cd=0.0)
  AND ((pref_disp_no_cur_aborh=1) OR (pref_disp_no_2aborh=1)) )) )
  EXECUTE bbt_rpt_ex_disp_nodetail
 ENDIF
 SET disp_exception_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(14072,nullterm("DISPUMCUR2D"),1,disp_exception_cd)
 IF ((((request->exception_type_cd=disp_exception_cd)) OR ((request->exception_type_cd=0.0)
  AND pref_disp_no_2aborh=1)) )
  EXECUTE bbt_rpt_ex_disp_nodetail
 ENDIF
 SET exception_type_cd = 0.0
 SET code_value = 0.0
 SET code_set = 14072
 SET cdf_meaning = "OVERCOMPPREP"
 EXECUTE cpm_get_cd_for_cdf
 SET exception_type_cd = code_value
 IF ((((request->exception_type_cd=exception_type_cd)) OR ((request->exception_type_cd=0.0))) )
  SET modified_cd = 0.0
  SET code_value = 0.0
  SET code_set = 1610
  SET cdf_meaning = "8"
  EXECUTE cpm_get_cd_for_cdf
  SET modified_cd = code_value
  SET exception_disp = uar_get_code_display(exception_type_cd)
  EXECUTE cpm_create_file_name_logical "bbt_ocp", "txt", "x"
  SELECT INTO cpm_cfn_info->file_name_logical
   event_dt_tm = cnvtdatetime(pe.event_dt_tm), orig_prod_nbr_disp = concat(trim(bp.supplier_prefix),
    trim(pr_orig.product_nbr)," ",trim(pr_orig.product_sub_nbr)), aborh_disp = concat(trim(
     uar_get_code_display(bp.cur_abo_cd))," ",trim(uar_get_code_display(bp.cur_rh_cd))),
   orig_prod_type_disp = uar_get_code_display(pr_orig.product_cd), new_prod_type_disp =
   uar_get_code_display(pr.product_cd), override_reason_disp = uar_get_code_display(bb
    .override_reason_cd)
   FROM bb_exception bb,
    prsnl pl,
    product_event pe,
    product pr,
    product pr_orig,
    blood_product bp,
    product_event pe_m,
    modification m,
    bb_mod_option mo,
    bb_mod_new_product mnp
   PLAN (bb
    WHERE bb.exception_type_cd=exception_type_cd
     AND bb.active_ind=1
     AND bb.exception_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
     end_dt_tm)
     AND ((bb.exception_id+ 0) > 0))
    JOIN (pl
    WHERE pl.person_id=bb.updt_id)
    JOIN (pe
    WHERE pe.product_event_id=bb.product_event_id)
    JOIN (pr
    WHERE pr.product_id=pe.product_id
     AND (((request->cur_owner_area_cd > 0.0)
     AND (pr.cur_owner_area_cd=request->cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (pr.cur_inv_area_cd=request->cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
    JOIN (pr_orig
    WHERE pr_orig.product_id=pr.modified_product_id)
    JOIN (bp
    WHERE bp.product_id=pr_orig.product_id)
    JOIN (pe_m
    WHERE pe_m.product_id=pr_orig.product_id
     AND pe_m.event_type_cd=modified_cd
     AND pe_m.event_dt_tm=pe.event_dt_tm)
    JOIN (m
    WHERE m.product_event_id=pe_m.product_event_id)
    JOIN (mo
    WHERE mo.option_id=m.option_id)
    JOIN (mnp
    WHERE mnp.option_id=mo.option_id
     AND mnp.orig_product_cd=pr_orig.product_cd
     AND mnp.new_product_cd=pr.product_cd)
   ORDER BY event_dt_tm, bb.exception_id
   HEAD REPORT
    beg_dt_tm = 0.0, end_dt_tm = 0.0, collected_dt_tm = 0.0,
    save_row = 0
   HEAD PAGE
    beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm),
    inc_i18nhandle = 0,
    inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
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
    CALL center(captions->bb_exception,1,125),
    col 104, captions->time, col 118,
    curtime"@TIMENOSECONDS;;m", row + 1, col 104,
    captions->as_of_date, col 118, curdate"@DATECONDENSED;;d",
    row save_row, row + 1, col 1,
    captions->bb_owner, col 19, cur_owner_area_disp,
    row + 1, col 1, captions->inventory_area,
    col 17, cur_inv_area_disp, row + 2,
    col 32, captions->beg_date, col 48,
    beg_dt_tm"@DATECONDENSED;;d", col 56, beg_dt_tm"@TIMENOSECONDS;;m",
    col 69, captions->end_date, col 82,
    end_dt_tm"@DATECONDENSED;;d", col 90, end_dt_tm"@TIMENOSECONDS;;m",
    row + 2, col 1, exception_disp,
    row + 2, col 9, captions->collected_dt_tm,
    col 30, captions->product_number, col 78,
    captions->mod_option, col 114, captions->tech,
    row + 1, col 2, captions->mod_d,
    col 12, captions->prep_hours, col 31,
    captions->product_type, col 57, captions->aborh,
    col 82, captions->new_product, col 106,
    captions->reason_for_override, row + 1, col 1,
    "-------", col 9, "---------------",
    col 25, "-------------------------", col 51,
    "------------------", col 70, "-----------------------------------",
    col 106, "--------------------"
   HEAD event_dt_tm
    row + 0
   HEAD bb.exception_id
    IF (row > 55)
     BREAK
    ENDIF
    row + 1, col 1, event_dt_tm"@DATECONDENSED;;d"
    IF (bp.drawn_dt_tm > 0.0)
     collected_dt_tm = cnvtdatetime(bp.drawn_dt_tm)
    ELSEIF (pr_orig.recv_dt_tm > 0.0)
     collected_dt_tm = cnvtdatetime(pr_orig.recv_dt_tm)
    ELSE
     collected_dt_tm = cnvtdatetime(pr_orig.create_dt_tm)
    ENDIF
    col 9, collected_dt_tm"@DATECONDENSED;;d", col 17,
    collected_dt_tm"@TIMENOSECONDS;;m", col 25, orig_prod_nbr_disp"#########################;;c",
    col 51, aborh_disp"##################;;c", col 70,
    mo.display"###################################;;c", col 106, pl.username"####################;;c",
    row + 1, col 2, event_dt_tm"@TIMENOSECONDS;;m",
    col 14, mnp.max_prep_hrs"##;r;i", col 25,
    orig_prod_type_disp"#####################;;c", col 70, new_prod_type_disp
    "###################################;;c",
    col 106, override_reason_disp"####################;;c", datafoundflag = true
   DETAIL
    row + 0
   FOOT  bb.exception_id
    row + 1
   FOOT  event_dt_tm
    row + 0
   FOOT PAGE
    row 57, col 1, line,
    row + 1, col 1, cpm_cfn_info->file_name_path,
    col 58, captions->page_no, col 64,
    curpage"###", col 100, captions->printed,
    col 109, curdate"@DATECONDENSED;;d", col 120,
    curtime"@TIMENOSECONDS;;M"
   FOOT REPORT
    row 60, col 51, captions->end_of_report
   WITH maxrow = 61, nullreport, compress,
    nolandscape, nocounter
  ;end select
  IF (((datafoundflag=true) OR ((request->null_ind=1))) )
   SET rpt_cnt += 1
   SET stat = alterlist(reply->rpt_list,rpt_cnt)
   SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
   SET datafoundflag = false
  ENDIF
 ENDIF
 SET exception_type_cd = 0.0
 SET code_value = 0.0
 SET code_set = 14072
 SET cdf_meaning = "OVERORIGEXP"
 EXECUTE cpm_get_cd_for_cdf
 SET exception_type_cd = code_value
 IF ((((request->exception_type_cd=exception_type_cd)) OR ((request->exception_type_cd=0.0))) )
  SET modified_product_cd = 0.0
  SET code_value = 0.0
  SET code_set = 1610
  SET cdf_meaning = "24"
  EXECUTE cpm_get_cd_for_cdf
  SET modified_product_cd = code_value
  SET exception_disp = uar_get_code_display(exception_type_cd)
  EXECUTE cpm_create_file_name_logical "bbt_ooe", "txt", "x"
  SELECT INTO cpm_cfn_info->file_name_logical
   event_dt_tm = cnvtdatetime(pe.event_dt_tm), default_exp_dt_tm = cnvtdatetime(bb
    .default_expire_dt_tm), orig_prod_nbr_disp = concat(trim(bp.supplier_prefix),trim(pr.product_nbr),
    " ",trim(pr.product_sub_nbr)),
   orig_prod_type_disp = uar_get_code_display(pr.product_cd), aborh_disp = concat(trim(
     uar_get_code_display(bp.cur_abo_cd))," ",trim(uar_get_code_display(bp.cur_rh_cd))),
   new_exp_dt_tm = cnvtdatetime(m.cur_expire_dt_tm),
   modify_event_yn = decode(pr_new.product_id,"Y","N"), new_prod_type_disp = uar_get_code_display(
    pr_new.product_cd), override_reason_disp = uar_get_code_display(bb.override_reason_cd)
   FROM bb_exception bb,
    prsnl pl,
    product_event pe,
    product pr,
    blood_product bp,
    modification m,
    bb_mod_option mo,
    (dummyt d_mod  WITH seq = 1),
    product pr_new,
    product_event pe_new
   PLAN (bb
    WHERE bb.exception_type_cd=exception_type_cd
     AND bb.active_ind=1
     AND bb.exception_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
     end_dt_tm)
     AND ((bb.exception_id+ 0) > 0))
    JOIN (pl
    WHERE pl.person_id=bb.updt_id)
    JOIN (pe
    WHERE pe.product_event_id=bb.product_event_id)
    JOIN (pr
    WHERE pr.product_id=pe.product_id
     AND (((request->cur_owner_area_cd > 0.0)
     AND (pr.cur_owner_area_cd=request->cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (pr.cur_inv_area_cd=request->cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
    JOIN (bp
    WHERE bp.product_id=pr.product_id)
    JOIN (m
    WHERE m.product_event_id=pe.product_event_id)
    JOIN (mo
    WHERE mo.option_id=m.option_id)
    JOIN (d_mod
    WHERE d_mod.seq=1)
    JOIN (pr_new
    WHERE pr_new.modified_product_id=pr.product_id)
    JOIN (pe_new
    WHERE pe_new.product_id=pr_new.product_id
     AND pe_new.event_type_cd=modified_product_cd
     AND pe_new.event_dt_tm=pe.event_dt_tm)
   ORDER BY event_dt_tm, bb.exception_id
   HEAD REPORT
    beg_dt_tm = 0.0, end_dt_tm = 0.0, save_row = 0,
    first_new_prod_ind = 0
   HEAD PAGE
    beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm),
    inc_i18nhandle = 0,
    inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
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
    CALL center(captions->bb_exception,1,125),
    col 104, captions->time, col 118,
    curtime"@TIMENOSECONDS;;m", row + 1, col 104,
    captions->as_of_date, col 118, curdate"@DATECONDENSED;;d",
    row save_row, row + 1, col 1,
    captions->bb_owner, col 19, cur_owner_area_disp,
    row + 1, col 1, captions->inventory_area,
    col 17, cur_inv_area_disp, row + 2,
    col 32, captions->beg_date, col 48,
    beg_dt_tm"@DATECONDENSED;;d", col 56, beg_dt_tm"@TIMENOSECONDS;;m",
    col 69, captions->end_date, col 82,
    end_dt_tm"@DATECONDENSED;;d", col 90, end_dt_tm"@TIMENOSECONDS;;m",
    row + 2, col 1, exception_disp,
    row + 2, col 26, captions->product_number,
    col 83, captions->mod_option, col 114,
    captions->tech, row + 1, col 2,
    captions->mod_d, col 9, captions->default_exp,
    col 27, captions->product_type, col 55,
    captions->aborh, col 69, captions->new_expire,
    col 87, captions->new_product, col 106,
    captions->reason_for_override, row + 1, col 1,
    "-------", col 9, "-------------",
    col 23, "-------------------------", col 49,
    "------------------", col 68, "-------------",
    col 82, "----------------------", col 105,
    "---------------------"
   HEAD event_dt_tm
    row + 0
   HEAD bb.exception_id
    datafoundflag = true
    IF (row > 54)
     BREAK
    ENDIF
    row + 1, col 1, event_dt_tm"@DATECONDENSED;;d",
    col 9, default_exp_dt_tm"@DATECONDENSED;;d", col 17,
    default_exp_dt_tm"@TIMENOSECONDS;;m", col 23, orig_prod_nbr_disp"#########################;;c",
    col 49, aborh_disp"##################;;c", col 68,
    new_exp_dt_tm"@DATECONDENSED;;d", col 76, new_exp_dt_tm"@TIMENOSECONDS;;m",
    col 82, mo.display"######################;;c", col 105,
    pl.username"#####################;;c", row + 1, col 2,
    event_dt_tm"@TIMENOSECONDS;;m", col 23, orig_prod_type_disp"#########################;;c",
    col 105, override_reason_disp"#####################;;c", first_new_prod_ind = 1
   DETAIL
    IF (row > 55)
     BREAK
    ENDIF
    IF (first_new_prod_ind=1)
     first_new_prod_ind = 0
    ELSE
     row + 1
    ENDIF
    col 82, new_prod_type_disp"######################;;c"
   FOOT  bb.exception_id
    row + 1
   FOOT  event_dt_tm
    row + 0
   FOOT PAGE
    row 57, col 1, line,
    row + 1, col 1, cpm_cfn_info->file_name_path,
    col 58, captions->page_no, col 64,
    curpage"###", col 100, captions->printed,
    col 109, curdate"@DATECONDENSED;;d", col 120,
    curtime"@TIMENOSECONDS;;M"
   FOOT REPORT
    row 60, col 51, captions->end_of_report
   WITH maxrow = 61, nullreport, compress,
    nolandscape, nocounter, outerjoin = d_mod,
    dontcare = pr_new, dontcare = pe_new
  ;end select
  IF (((datafoundflag=true) OR ((request->null_ind=1))) )
   SET rpt_cnt += 1
   SET stat = alterlist(reply->rpt_list,rpt_cnt)
   SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
   SET datafoundflag = false
  ENDIF
 ENDIF
 SET exception_type_cd = 0.0
 SET code_value = 0.0
 SET code_set = 14072
 SET cdf_meaning = "OVERNEWEXP"
 EXECUTE cpm_get_cd_for_cdf
 SET exception_type_cd = code_value
 IF ((((request->exception_type_cd=exception_type_cd)) OR ((request->exception_type_cd=0.0))) )
  SET modified_cd = 0.0
  SET code_value = 0.0
  SET code_set = 1610
  SET cdf_meaning = "8"
  EXECUTE cpm_get_cd_for_cdf
  SET modified_cd = code_value
  SET modified_prod_cd = 0.0
  SET code_value = 0.0
  SET code_set = 1610
  SET cdf_meaning = "24"
  EXECUTE cpm_get_cd_for_cdf
  SET modified_prod_cd = code_value
  SET pooled_cd = 0.0
  SET code_value = 0.0
  SET code_set = 1610
  SET cdf_meaning = "17"
  EXECUTE cpm_get_cd_for_cdf
  SET pooled_cd = code_value
  SET exception_disp = uar_get_code_display(exception_type_cd)
  EXECUTE cpm_create_file_name_logical "bbt_one", "txt", "x"
  SELECT INTO cpm_cfn_info->file_name_logical
   event_dt_tm = cnvtdatetime(pe.event_dt_tm), default_exp_dt_tm = cnvtdatetime(bb
    .default_expire_dt_tm), new_prod_nbr_disp = concat(trim(bp.supplier_prefix),trim(pr.product_nbr),
    " ",trim(pr.product_sub_nbr)),
   new_prod_type_disp = uar_get_code_display(pr.product_cd), aborh_disp = concat(trim(
     uar_get_code_display(bp.cur_abo_cd))," ",trim(uar_get_code_display(bp.cur_rh_cd))),
   modify_event_yn = decode(mod_pr_orig.product_id,"Y","N"),
   mod_orig_prod_type_disp = uar_get_code_display(mod_pr_orig.product_cd), pool_event_yn = decode(
    pool_pr_orig.product_id,"Y","N"), pool_orig_prod_type_disp = uar_get_code_display(pool_pr_orig
    .product_cd),
   override_reason_disp = uar_get_code_display(bb.override_reason_cd)
   FROM bb_exception bb,
    prsnl pl,
    product_event pe,
    product pr,
    blood_product bp,
    (dummyt d_mod  WITH seq = 1),
    product mod_pr_orig,
    product_event mod_pe_orig,
    modification mod_m,
    bb_mod_option mod_mo,
    (dummyt d_pool  WITH seq = 1),
    product pool_pr_orig,
    product_event pool_pe_orig,
    modification pool_m,
    bb_mod_option pool_mo
   PLAN (bb
    WHERE bb.exception_type_cd=exception_type_cd
     AND bb.active_ind=1
     AND bb.exception_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->
     end_dt_tm)
     AND ((bb.exception_id+ 0) > 0))
    JOIN (pl
    WHERE pl.person_id=bb.updt_id)
    JOIN (pe
    WHERE pe.product_event_id=bb.product_event_id)
    JOIN (pr
    WHERE pr.product_id=pe.product_id
     AND (((request->cur_owner_area_cd > 0.0)
     AND (pr.cur_owner_area_cd=request->cur_owner_area_cd)) OR ((request->cur_owner_area_cd=0.0)))
     AND (((request->cur_inv_area_cd > 0.0)
     AND (pr.cur_inv_area_cd=request->cur_inv_area_cd)) OR ((request->cur_inv_area_cd=0.0))) )
    JOIN (bp
    WHERE bp.product_id=pr.product_id)
    JOIN (d_mod
    WHERE d_mod.seq=1)
    JOIN (mod_pr_orig
    WHERE ((mod_pr_orig.product_id=pr.modified_product_id
     AND pr.modified_product_id > 0.0
     AND pe.event_type_cd=modified_prod_cd) OR (mod_pr_orig.product_id=pr.product_id)) )
    JOIN (mod_pe_orig
    WHERE mod_pe_orig.product_id=mod_pr_orig.product_id
     AND mod_pe_orig.event_type_cd=modified_cd
     AND mod_pe_orig.event_dt_tm=pe.event_dt_tm)
    JOIN (mod_m
    WHERE mod_m.product_event_id=mod_pe_orig.product_event_id)
    JOIN (mod_mo
    WHERE mod_mo.option_id=mod_m.option_id)
    JOIN (d_pool
    WHERE d_pool.seq=1)
    JOIN (pool_pr_orig
    WHERE pool_pr_orig.pooled_product_id=pr.product_id)
    JOIN (pool_pe_orig
    WHERE pool_pe_orig.product_id=pool_pr_orig.product_id
     AND ((pool_pe_orig.event_type_cd=pooled_cd) OR (pool_pe_orig.event_type_cd=modified_cd))
     AND pool_pe_orig.event_dt_tm=pe.event_dt_tm)
    JOIN (pool_m
    WHERE pool_m.product_event_id=pool_pe_orig.product_event_id)
    JOIN (pool_mo
    WHERE pool_mo.option_id=pool_m.option_id)
   ORDER BY event_dt_tm, bb.exception_id
   HEAD REPORT
    beg_dt_tm = 0.0, end_dt_tm = 0.0, save_row = 0,
    first_orig_prod_ind = 0
   HEAD PAGE
    beg_dt_tm = cnvtdatetime(request->beg_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm),
    inc_i18nhandle = 0,
    inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev), row 0
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
    CALL center(captions->bb_exception,1,125),
    col 104, captions->time, col 118,
    curtime"@TIMENOSECONDS;;m", row + 1, col 104,
    captions->as_of_date, col 118, curdate"@DATECONDENSED;;d",
    row save_row, row + 1, col 1,
    captions->bb_owner, col 19, cur_owner_area_disp,
    row + 1, col 1, captions->inventory_area,
    col 17, cur_inv_area_disp, row + 2,
    col 32, captions->beg_date, col 48,
    beg_dt_tm"@DATECONDENSED;;d", col 56, beg_dt_tm"@TIMENOSECONDS;;m",
    col 69, captions->end_date, col 82,
    end_dt_tm"@DATECONDENSED;;d", col 90, end_dt_tm"@TIMENOSECONDS;;m",
    row + 2, col 1, exception_disp,
    row + 2, col 28, captions->product_number,
    col 83, captions->mod_option, col 114,
    captions->tech, row + 1, col 2,
    captions->mod_d, col 9, captions->default_exp,
    col 29, captions->product_type, col 55,
    captions->aborh, col 69, captions->new_expire,
    col 85, captions->orig_product, col 106,
    captions->reason_for_override, row + 1, col 1,
    "-------", col 9, "-------------",
    col 23, "-------------------------", col 49,
    "------------------", col 68, "-------------",
    col 82, "----------------------", col 105,
    "---------------------"
   HEAD event_dt_tm
    row + 0
   HEAD bb.exception_id
    IF (row > 54)
     BREAK
    ENDIF
    new_exp_dt_tm =
    IF (((((mod_mo.new_product_ind=1) OR (((mod_mo.split_ind=1) OR (mod_mo.crossover_ind=1)) ))
     AND modify_event_yn="Y") OR (((pool_mo.pool_product_ind=1) OR (pool_mo.recon_rbc_ind))
     AND pool_event_yn="Y")) ) cnvtdatetime(bp.orig_expire_dt_tm)
    ELSE cnvtdatetime(mod_m.cur_expire_dt_tm)
    ENDIF
    , datafoundflag = true, row + 1,
    col 1, event_dt_tm"@DATECONDENSED;;d", col 9,
    default_exp_dt_tm"@DATECONDENSED;;d", col 17, default_exp_dt_tm"@TIMENOSECONDS;;m",
    col 23, new_prod_nbr_disp"#########################;;c", col 49,
    aborh_disp"##################;;c", col 68, new_exp_dt_tm"@DATECONDENSED;;d",
    col 76, new_exp_dt_tm"@TIMENOSECONDS;;m", col 105,
    pl.username"#####################;;c", row + 1, col 2,
    event_dt_tm"@TIMENOSECONDS;;m", col 23, new_prod_type_disp"#########################;;c",
    col 105, override_reason_disp"#####################;;c", first_orig_prod_ind = 1
   DETAIL
    IF (row > 55)
     BREAK
    ENDIF
    IF (first_orig_prod_ind=1)
     first_orig_prod_ind = 0
     IF (modify_event_yn="Y")
      row- (1), col 82, mod_mo.display"######################;;c",
      row + 1
     ENDIF
     IF (pool_event_yn="Y")
      row- (1), col 82, pool_mo.display"######################;;c",
      row + 1
     ENDIF
    ELSE
     row + 1
    ENDIF
    IF (modify_event_yn="Y")
     col 82, mod_orig_prod_type_disp"######################;;c"
    ENDIF
    IF (pool_event_yn="Y")
     col 82, pool_orig_prod_type_disp"######################;;c"
    ENDIF
   FOOT  bb.exception_id
    row + 1
   FOOT  event_dt_tm
    row + 0
   FOOT PAGE
    row 57, col 1, line,
    row + 1, col 1, cpm_cfn_info->file_name_path,
    col 58, captions->page_no, col 64,
    curpage"###", col 100, captions->printed,
    col 109, curdate"@DATECONDENSED;;d", col 120,
    curtime"@TIMENOSECONDS;;M"
   FOOT REPORT
    row 60, col 51, captions->end_of_report
   WITH maxrow = 61, nullreport, compress,
    nolandscape, nocounter, outerjoin = d_mod,
    dontcare = mod_pr_orig, dontcare = mod_pe_orig, dontcare = mod_m,
    dontcare = mod_mo, outerjoin = d_pool, dontcare = pool_pr_orig,
    dontcare = pool_pe_orig, dontcare = pool_m, dontcare = pool_mo
  ;end select
  IF (((datafoundflag=true) OR ((request->null_ind=1))) )
   SET rpt_cnt += 1
   SET stat = alterlist(reply->rpt_list,rpt_cnt)
   SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
   SET datafoundflag = false
  ENDIF
 ENDIF
 SET exception_type_cd = 0.0
 SET code_value = 0.0
 SET code_set = 14072
 SET cdf_meaning = "EXPSPECRES"
 EXECUTE cpm_get_cd_for_cdf
 SET exception_type_cd = code_value
 IF (validate(exception_request->facility_cd)=1)
  IF ((exception_request->exception_type_cd=exception_type_cd))
   EXECUTE bbt_rpt_ex_expspecres  WITH replace("REQUEST","EXCEPTION_REQUEST"), replace("REPLY",
    "EXCEPTION_REPLY")
  ELSEIF ((exception_request->exception_type_cd=0.0))
   SET test_facility_cd = bbtgetflexspectestingfacility(exception_request->facility_cd)
   IF (bbtgetflexspecenableflexexpiration(test_facility_cd)=1)
    EXECUTE bbt_rpt_ex_expspecres  WITH replace("REQUEST","EXCEPTION_REQUEST"), replace("REPLY",
     "EXCEPTION_REPLY")
   ENDIF
  ENDIF
 ELSEIF ((request->exception_type_cd=exception_type_cd))
  EXECUTE bbt_rpt_ex_expspecres
 ELSEIF ((request->exception_type_cd=0.0))
  IF ((request->facility_cd=0))
   EXECUTE bbt_rpt_ex_expspecres
  ELSE
   SET test_facility_cd = bbtgetflexspectestingfacility(request->facility_cd)
   IF (bbtgetflexspecenableflexexpiration(test_facility_cd)=1)
    EXECUTE bbt_rpt_ex_expspecres
   ENDIF
  ENDIF
 ENDIF
 SET exception_type_cd = 0.0
 SET code_value = 0.0
 SET code_set = 14072
 SET cdf_meaning = "FLEXSPEC"
 EXECUTE cpm_get_cd_for_cdf
 SET exception_type_cd = code_value
 SET test_facility_cd = 0.0
 IF (validate(exception_request->facility_cd)=1)
  IF ((exception_request->exception_type_cd=exception_type_cd))
   EXECUTE bbt_rpt_ex_flexspec  WITH replace("REQUEST","EXCEPTION_REQUEST"), replace("REPLY",
    "EXCEPTION_REPLY")
  ELSEIF ((exception_request->exception_type_cd=0.0))
   SET test_facility_cd = bbtgetflexspectestingfacility(exception_request->facility_cd)
   IF (bbtgetflexspecenableflexexpiration(test_facility_cd)=1)
    EXECUTE bbt_rpt_ex_flexspec  WITH replace("REQUEST","EXCEPTION_REQUEST"), replace("REPLY",
     "EXCEPTION_REPLY")
   ENDIF
  ENDIF
 ELSEIF ((request->exception_type_cd=exception_type_cd))
  EXECUTE bbt_rpt_ex_flexspec
 ELSEIF ((request->exception_type_cd=0.0))
  IF ((request->facility_cd=0))
   EXECUTE bbt_rpt_ex_flexspec
  ELSE
   SET test_facility_cd = bbtgetflexspectestingfacility(request->facility_cd)
   IF (bbtgetflexspecenableflexexpiration(test_facility_cd)=1)
    EXECUTE bbt_rpt_ex_flexspec
   ENDIF
  ENDIF
 ENDIF
 SET exception_type_cd = 0.0
 SET code_value = 0.0
 SET code_set = 14072
 SET cdf_meaning = "TAGMISMATCH"
 EXECUTE cpm_get_cd_for_cdf
 SET exception_type_cd = code_value
 DECLARE pref_prod_tag_verify = i2 WITH protect, noconstant(0)
 SET pref_prod_tag_verify = bbtgetprodtagverifypreference(request->facility_cd)
 IF ((((request->exception_type_cd=exception_type_cd)) OR ((request->exception_type_cd=0.0)
  AND pref_prod_tag_verify=1)) )
  SET exception_disp = uar_get_code_display(exception_type_cd)
  EXECUTE cpm_create_file_name_logical "bbt_productTag_mismatch", "txt", "x"
  EXECUTE bbt_rpt_ex_tag_mismatch cpm_cfn_info->file_name_logical
  IF (((datafoundflag=true) OR ((request->null_ind=1))) )
   SET rpt_cnt += 1
   SET stat = alterlist(reply->rpt_list,rpt_cnt)
   SET reply->rpt_list[rpt_cnt].rpt_filename = cpm_cfn_info->file_name_path
   SET datafoundflag = false
  ENDIF
 ENDIF
 SET exception_type_cd = 0.0
 SET code_value = 0.0
 SET code_set = 14072
 SET cdf_meaning = "EDN_PROBLEM"
 EXECUTE cpm_get_cd_for_cdf
 SET exception_type_cd = code_value
 IF ((((request->exception_type_cd=exception_type_cd)) OR ((request->exception_type_cd=0.0))) )
  FREE SET captions
  EXECUTE bbt_rpt_ex_edn_problem
 ENDIF
 SUBROUTINE (printreportind(value=i4) =i2)
   DECLARE lcnt = i2 WITH public, noconstant(0)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.code_set=value
     AND cv.active_ind=1
    FOOT REPORT
     lcnt = count(cv.code_value)
    WITH nocounter
   ;end select
   IF (lcnt > 0)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 IF ((request->batch_selection > " "))
  SET i = 0
  FOR (i = 1 TO rpt_cnt)
    SET spool value(reply->rpt_list[i].rpt_filename) value(request->printer_name)
  ENDFOR
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 FREE SET captions
#exit_script1
END GO
