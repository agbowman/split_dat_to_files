CREATE PROGRAM bbd_rpt_donor_card:dba
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
   1 number = vc
   1 ssn = vc
   1 home_address = vc
   1 business_address = vc
   1 birth_date = vc
   1 gender = vc
   1 abo_rh = vc
   1 last_donation = vc
   1 next_donation = vc
   1 current_year_donation = vc
   1 total_donation = vc
   1 donation_procedure = vc
   1 donation_date = vc
   1 eligibility_type = vc
   1 special_testing = vc
   1 date = vc
   1 time = vc
   1 signature = vc
 )
 SET captions->number = uar_i18ngetmessage(i18nhandle,"number","Donor Number:")
 SET captions->ssn = uar_i18ngetmessage(i18nhandle,"ssn","Social Security Number:")
 SET captions->home_address = uar_i18ngetmessage(i18nhandle,"home_address","Home Address:")
 SET captions->business_address = uar_i18ngetmessage(i18nhandle,"business_address",
  "Business Address:")
 SET captions->birth_date = uar_i18ngetmessage(i18nhandle,"birth_date","Birth Date:")
 SET captions->gender = uar_i18ngetmessage(i18nhandle,"gender","Gender:")
 SET captions->abo_rh = uar_i18ngetmessage(i18nhandle,"abo_rh","ABO/Rh:")
 SET captions->last_donation = uar_i18ngetmessage(i18nhandle,"last_donation","Last Donation:")
 SET captions->next_donation = uar_i18ngetmessage(i18nhandle,"next_donation","Next Donation:")
 SET captions->current_year_donation = uar_i18ngetmessage(i18nhandle,"current_year_donation",
  "Current-Year Donations:")
 SET captions->total_donation = uar_i18ngetmessage(i18nhandle,"total_donation","Total Donations:")
 SET captions->donation_procedure = uar_i18ngetmessage(i18nhandle,"donation_procedure",
  "Donation Procedure:")
 SET captions->donation_date = uar_i18ngetmessage(i18nhandle,"donation_date","Donation Date:")
 SET captions->eligibility_type = uar_i18ngetmessage(i18nhandle,"eligibility_type",
  "Eligibility Type:")
 SET captions->special_testing = uar_i18ngetmessage(i18nhandle,"special_testing","Special Testing:")
 SET captions->date = uar_i18ngetmessage(i18nhandle,"date","Date:")
 SET captions->time = uar_i18ngetmessage(i18nhandle,"time","Time:")
 SET captions->signature = uar_i18ngetmessage(i18nhandle,"signature","Signature:")
 DECLARE business_count = i4 WITH noconstant(0)
 DECLARE home_count = i4 WITH noconstant(0)
 DECLARE datetime = f8
 DECLARE rpt_cnt = i4
 SET datetime = cnvtdatetime(curdate,curtime3)
 SET rpt_cnt = size(card_request,5)
 EXECUTE cpm_create_file_name_logical "bbd_card", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  b.seq, donor_name = card_request->donor_name
  FROM (dummyt b  WITH seq = value(rpt_cnt))
  ORDER BY donor_name
  HEAD REPORT
   antigen_num = size(card_request->antigen_list,5), antigen_cnt = 1, row + 0
  HEAD PAGE
   col 0, card_request->location_name, row + 1,
   col 0, card_request->location_address, row + 1
   IF ((card_request->location_address2 > " "))
    col 0, card_request->location_address2, row + 1
   ENDIF
   IF ((card_request->location_address3 > " "))
    col 0, card_request->location_address3, row + 1
   ENDIF
   IF ((card_request->location_address4 > " "))
    col 0, card_request->location_address4, row + 1
   ENDIF
   col 0, card_request->location_city
   IF ((card_request->location_city > " ")
    AND (card_request->location_state > " "))
    col + 0, ","
   ENDIF
   col + 1, card_request->location_state, col + 1,
   card_request->location_zip, row + 2, col 0,
   card_request->donor_name, row + 1
   IF (size(card_request->donor_number) > 0)
    col 0, captions->number, col 30,
    card_request->donor_number";L", row + 1
   ENDIF
   IF (size(card_request->ssn) > 0)
    col 0, captions->ssn, col 30,
    card_request->ssn";L", row + 1
   ENDIF
   row + 1
  HEAD donor_name
   store_date = fillstring(30," "), col 0, captions->home_address,
   col 60, captions->business_address, row + 1
   IF ((card_request->home_address > " "))
    col 0, card_request->home_address, home_count = (home_count+ 1),
    row + 1
   ENDIF
   IF ((card_request->home_address2 > " "))
    col 0, card_request->home_address2, home_count = (home_count+ 1),
    row + 1
   ENDIF
   IF ((card_request->home_address3 > " "))
    col 0, card_request->home_address3, home_count = (home_count+ 1),
    row + 1
   ENDIF
   IF ((card_request->home_address4 > " "))
    col 0, card_request->home_address4, home_count = (home_count+ 1),
    row + 1
   ENDIF
   IF ((card_request->home_city > " ")
    AND (card_request->home_state > " "))
    col 0, card_request->home_city, col + 0,
    ",", col + 1, card_request->home_state,
    col + 1, card_request->home_zip, row + 1,
    home_count = (home_count+ 1)
   ENDIF
   row + 1, row- (home_count), row- (1)
   IF ((card_request->business_address > " "))
    col 60, card_request->business_address, business_count = (business_count+ 1),
    row + 1
   ENDIF
   IF ((card_request->business_address2 > " "))
    col 60, card_request->business_address2, business_count = (business_count+ 1),
    row + 1
   ENDIF
   IF ((card_request->business_address3 > " "))
    col 60, card_request->business_address3, business_count = (business_count+ 1),
    row + 1
   ENDIF
   IF ((card_request->business_address4 > " "))
    col 60, card_request->business_address4, business_count = (business_count+ 1),
    row + 1
   ENDIF
   IF ((card_request->business_city > " ")
    AND (card_request->business_state > " "))
    col 60, card_request->business_city, col + 0,
    ",", col + 1, card_request->business_state,
    col + 1, card_request->business_zip, row + 1,
    business_count = (business_count+ 1)
   ENDIF
   IF (business_count > home_count)
    row + 2
   ELSE
    row + home_count, row- (business_count), row + 1
   ENDIF
   col 0, captions->birth_date
   IF (curutc=1)
    store_date = format(datetimezone(card_request->birth_dt_tm,card_request->birth_tz),
     "@DATECONDENSED;4;q")
   ELSE
    store_date = format(card_request->birth_dt_tm,"@DATECONDENSED;;d")
   ENDIF
   col + 5, store_date, col 60,
   captions->gender, col + 5, card_request->gender_disp,
   col + 10, captions->abo_rh, col + 5,
   card_request->abo_disp, col + 5, card_request->rh_disp,
   row + 2, col 0, captions->last_donation
   IF ((card_request->last_donation_dt_tm > 0))
    col + 5, card_request->last_donation_dt_tm"@DATECONDENSED"
   ELSE
    col + 5, "(None)"
   ENDIF
   col 60, captions->current_year_donation, col 94,
   card_request->current_year_donations";L", row + 1, col 0,
   captions->next_donation, col + 5, card_request->next_donation_dt_tm"@DATECONDENSED",
   col 60, captions->total_donation, col 94,
   card_request->total_donations";L", row + 2, col 0,
   captions->donation_procedure, col 25, card_request->donation_proc_disp";L",
   col 60, captions->eligibility_type, col + 5,
   card_request->eligibility_type_disp, row + 1, col 0,
   captions->donation_date, col 25, card_request->donation_dt_tm"@DATECONDENSED",
   row + 2, col 0, captions->special_testing
  DETAIL
   WHILE (antigen_cnt <= antigen_num)
    IF (size(trim(card_request->antigen_list[antigen_cnt].antigen_disp,3)) > 0)
     row + 1, col 0, card_request->antigen_list[antigen_cnt].antigen_disp
    ENDIF
    ,antigen_cnt = (antigen_cnt+ 1)
   ENDWHILE
   row + 2
  FOOT REPORT
   signature_line = fillstring(40,"_"), col 0, captions->date,
   col + 5, datetime"@DATECONDENSED", col 30,
   captions->time, col + 5, datetime"@TIMENOSECONDS",
   row + 3, col 0, captions->signature,
   col + 0, signature_line
  WITH compress, nolandscape
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("SELECT","F","bbd_rpt_donor_card",errmsg)
  GO TO set_status
 ENDIF
 DECLARE errorhandler(operationname=c25,operationstatus=c1,targetobjectname=c25,targetobjectvalue=vc)
  = null
 SUBROUTINE errorhandler(operationname,operationstatus,targetobjectname,targetobjectvalue)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt = (error_cnt+ 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = operationname
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
 END ;Subroutine
#set_status
 SET reply->report_name = concat("cer_print:",cpm_cfn_info->file_name)
 IF (error_check != 0)
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
