CREATE PROGRAM bbd_rpt_donor_unlock
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
   1 inc_title = vc
   1 inc_time = vc
   1 inc_as_of_date = vc
   1 inc_beg_dt_tm = vc
   1 inc_end_dt_tm = vc
   1 inc_report_id = vc
   1 inc_page = vc
   1 inc_printed = vc
   1 scortyp = vc
   1 rpt_cerner_health_sys = vc
   1 donor_number = vc
   1 date_time = vc
   1 tech_id = vc
   1 correction_reason = vc
   1 comments = vc
   1 end_of_report = vc
 )
 SET captions->rpt_cerner_health_sys = uar_i18ngetmessage(i18nhandle,"rpt_cerner_health_systems",
  "Cerner HNA Millenium")
 SET captions->inc_title = uar_i18ngetmessage(i18nhandle,"rpt_title",
  "D O N A T I O N   C O R R E C T I O N S")
 SET captions->inc_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->inc_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As of Date:")
 SET captions->inc_beg_dt_tm = uar_i18ngetmessage(i18nhandle,"begin_dt_tm","Beginning Date Time:")
 SET captions->inc_end_dt_tm = uar_i18ngetmessage(i18nhandle,"end_dt_tm","Ending Date Time:")
 SET captions->inc_report_id = uar_i18ngetmessage(i18nhandle,"rpt_id",
  "Report ID: BBD_RPT_DONOR_UNLOCK")
 SET captions->inc_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->inc_printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->scortyp = uar_i18ngetmessage(i18nhandle,"correction_type","Correction Type: ")
 SET captions->donor_number = uar_i18ngetmessage(i18nhandle,"donor_number","Donor Number")
 SET captions->date_time = uar_i18ngetmessage(i18nhandle,"date_time","Date/Time")
 SET captions->tech_id = uar_i18ngetmessage(i18nhandle,"tech_id","Tech Id")
 SET captions->correction_reason = uar_i18ngetmessage(i18nhandle,"correction_reason",
  "Correction Reason")
 SET captions->comments = uar_i18ngetmessage(i18nhandle,"comments","Comments")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET line = fillstring(125,"_")
 SET equal_line = fillstring(126,"=")
 SET donor_id_alias_cd = uar_get_code_by("MEANING",4,"DONORID")
 SET reply->status_data.status = "F"
 IF (donor_id_alias_cd=0.0)
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_rpt_donor_unlock"
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "code_value"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unable to read all required code values for script execution"
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  SET reply->status_data.subeventstatus[1].sub_event_dt_tm = cnvtdatetime(curdate,curtime)
  GO TO exit_script
 ENDIF
#script
 SELECT
  IF (bnullrpt=1)
   WITH nocounter, maxrow = 61, compress,
    nolandscape, outerjoin = d1, outerjoin = d2,
    nullreport
  ELSE
  ENDIF
  INTO cpm_cfn_info->file_name_logical
  bcd.correct_donor_id, bcd.person_id, pa.person_id,
  p.person_id, reason_disp = uar_get_code_display(bcd.correction_reason_cd)
  FROM bbd_correct_donor bcd,
   person_alias pa,
   (dummyt d1  WITH seq = 1),
   prsnl p,
   (dummyt d2  WITH seq = 1),
   long_text lt
  PLAN (bcd
   WHERE bcd.correction_type_cd=dunlockcd
    AND bcd.active_ind=1
    AND bcd.updt_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm))
   JOIN (pa
   WHERE pa.person_id=bcd.person_id
    AND pa.person_alias_type_cd=donor_id_alias_cd
    AND cnvtdatetime(curdate,curtime3) >= pa.beg_effective_dt_tm
    AND cnvtdatetime(curdate,curtime3) <= pa.end_effective_dt_tm
    AND pa.active_ind=1)
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (p
   WHERE p.person_id=bcd.updt_id
    AND cnvtdatetime(curdate,curtime3) >= p.beg_effective_dt_tm
    AND cnvtdatetime(curdate,curtime3) <= p.end_effective_dt_tm
    AND p.active_ind=1)
   JOIN (d2
   WHERE d2.seq=1)
   JOIN (lt
   WHERE lt.long_text_id=bcd.correction_text_id
    AND lt.parent_entity_id=bcd.correct_donor_id
    AND lt.parent_entity_name="BBD_CORRECT_DONOR"
    AND lt.active_ind=1)
  HEAD PAGE
   CALL center(captions->inc_title,1,125), col 107, captions->inc_time,
   col 121, curtime"@TIMENOSECONDS;;m", row + 1,
   col 107, captions->inc_as_of_date, col 119,
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
   row + 1, dt_tm = cnvtdatetime(request->beg_dt_tm), col 32,
   captions->inc_beg_dt_tm, col 56, dt_tm"@DATECONDENSED;;d",
   col 64, dt_tm"@TIMENOSECONDS;;m", dt_tm = cnvtdatetime(request->end_dt_tm),
   col 74, captions->inc_end_dt_tm, col 92,
   dt_tm"@DATECONDENSED;;d", col 100, dt_tm"@TIMENOSECONDS;;m",
   row + 2, col 1, captions->scortyp,
   col 18, unlock_disp, row + 2,
   col 5, captions->donor_number, col 27,
   captions->date_time, col 38, captions->tech_id,
   col 48, captions->correction_reason, col 90,
   captions->comments, row + 1, col 2,
   "--------------------", col 25, "-------------",
   col 39, "-------", col 47,
   "--------------------", col 68, "----------------------------------------------------",
   row + 1
  DETAIL
   bcd.person_id, col 2, pa.alias"####################",
   col 25, bcd.active_status_dt_tm"@DATETIMECONDENSED;;d", col 39,
   p.username"#######", col 47, reason_disp"####################",
   col 68, lt.long_text"####################################################", row + 1
   IF (row > 56)
    BREAK
   ENDIF
  FOOT PAGE
   row 57, col 1,
   "------------------------------------------------------------------------------------------------------------------------------"
,
   row + 1, col 1, captions->inc_report_id,
   col 58, captions->inc_page, col 64,
   curpage"###", col 109, captions->inc_printed,
   col 119, curdate"@DATECONDENSED;;d", row + 1
  FOOT REPORT
   row 60, col 51, captions->end_of_report
  WITH nocounter, maxrow = 61, compress,
   nolandscape, outerjoin = d1, outerjoin = d2
 ;end select
 SET reply->status_data.status = "S"
#exit_script
 FREE RECORD captions
END GO
