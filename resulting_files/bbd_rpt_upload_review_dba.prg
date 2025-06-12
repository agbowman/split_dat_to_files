CREATE PROGRAM bbd_rpt_upload_review:dba
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
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 SET modify = predeclare
 DECLARE script_name = c21 WITH protect, constant("BBD_RPT_UPLOAD_REVIEW")
 DECLARE line131 = c131 WITH protect, constant(fillstring(131,"-"))
 DECLARE bottom_line = c131 WITH protect, constant(fillstring(131,"_"))
 DECLARE donor_aborh_disc = i2 WITH protect, constant(1)
 DECLARE donor_sngl_trx_disc = i2 WITH protect, constant(2)
 DECLARE donor_dup_disc = i2 WITH protect, constant(3)
 DECLARE eligibility_temp_defer_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14237,
   nullterm("TEMP")))
 DECLARE contact_temp_defer_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",14221,nullterm(
    "TEMPDEF")))
 DECLARE person_alias_ssn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",4,nullterm("SSN"))
  )
 DECLARE i18nhandle = i4 WITH protect, noconstant(0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE stat = i4 WITH protect, noconstant(0)
 SET modify = nopredeclare
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
 SET reply->status_data.status = "F"
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
 SET stat = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 RECORD captions(
   1 rpt_title = vc
   1 rpt_time = vc
   1 rpt_as_of_date = vc
   1 rpt_beg_date = vc
   1 rpt_end_date = vc
   1 rpt_page = vc
   1 rpt_end_of_report = vc
   1 hdr_date = vc
   1 hdr_type_of_disc = vc
   1 hdr_donor_name = vc
   1 hdr_contributor = vc
   1 hdr_dob = vc
   1 hdr_gender = vc
   1 hdr_ssn = vc
   1 hdr_aborh = vc
   1 hdr_eligibility = vc
   1 hdr_system = vc
   1 hdr_deferral_status = vc
   1 hdr_resolution = vc
   1 hdr_defer_until = vc
   1 hdr_status_outcome = vc
   1 hdr_elig_status = vc
   1 donor = vc
   1 final_outcome = vc
   1 contact_outcome = vc
   1 no_aborh = vc
   1 temp_deferral = vc
   1 perm_deferral = vc
 )
 SET captions->rpt_title = uar_i18ngetmessage(i18nhandle,"rpt_title","BB Donor Upload Queue Review")
 SET captions->rpt_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->rpt_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As Of Date:")
 SET captions->rpt_beg_date = uar_i18ngetmessage(i18nhandle,"rpt_beg_date","Beginning Date:")
 SET captions->rpt_end_date = uar_i18ngetmessage(i18nhandle,"rpt_end_date","Ending Date:")
 SET captions->rpt_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->rpt_end_of_report = uar_i18ngetmessage(i18nhandle,"rpt_end_of_report",
  "*** End of Report ***")
 SET captions->hdr_date = uar_i18ngetmessage(i18nhandle,"hdr_date","Date")
 SET captions->hdr_type_of_disc = uar_i18ngetmessage(i18nhandle,"hdr_type_of_disc",
  "Type of Discrepancy")
 SET captions->hdr_donor_name = uar_i18ngetmessage(i18nhandle,"hdr_donor_name","Donor Name")
 SET captions->hdr_contributor = uar_i18ngetmessage(i18nhandle,"hdr_contributor","Contributor")
 SET captions->hdr_dob = uar_i18ngetmessage(i18nhandle,"hdr_dob","DOB")
 SET captions->hdr_gender = uar_i18ngetmessage(i18nhandle,"hdr_gender","Gender")
 SET captions->hdr_ssn = uar_i18ngetmessage(i18nhandle,"hdr_ssn","SSN")
 SET captions->hdr_aborh = uar_i18ngetmessage(i18nhandle,"hdr_aborh","ABO/Rh")
 SET captions->hdr_eligibility = uar_i18ngetmessage(i18nhandle,"hdr_eligibility","Eligibility/")
 SET captions->hdr_system = uar_i18ngetmessage(i18nhandle,"hdr_system","System")
 SET captions->hdr_deferral_status = uar_i18ngetmessage(i18nhandle,"hdr_deferral_status",
  "Deferral Status/")
 SET captions->hdr_resolution = uar_i18ngetmessage(i18nhandle,"hdr_resolution","Resolution/")
 SET captions->hdr_defer_until = uar_i18ngetmessage(i18nhandle,"hdr_defer_until","Defer Until")
 SET captions->hdr_status_outcome = uar_i18ngetmessage(i18nhandle,"hdr_status_outcome",
  "Eligibility status and contact outcome")
 SET captions->hdr_elig_status = uar_i18ngetmessage(i18nhandle,"hdr_elig_status","Eligibility status"
  )
 SET captions->donor = uar_i18ngetmessage(i18nhandle,"donor","Donor (Person)")
 SET captions->final_outcome = uar_i18ngetmessage(i18nhandle,"final_outcome","Final contact outcome")
 SET captions->contact_outcome = uar_i18ngetmessage(i18nhandle,"contact_outcome","Contact outcome")
 SET captions->temp_deferral = uar_i18ngetmessage(i18nhandle,"temp_deferral","temporary deferral")
 SET captions->perm_deferral = uar_i18ngetmessage(i18nhandle,"perm_deferral","permanent deferral")
 EXECUTE cpm_create_file_name_logical "bbd_rpt_upload_review", "txt", "x"
 SELECT INTO cpm_cfn_info->file_name_logical
  person_name_disp = substring(1,23,p.name_full_formatted), sex_disp = substring(1,10,
   uar_get_code_display(p.sex_cd)), upload_outcome_disp = substring(1,21,uar_get_code_display(bur
    .upload_outcome_cd)),
  upload_contributor_system_disp = substring(1,11,uar_get_code_display(bur
    .upload_contributor_system_cd)), upload_donor_elig_type_disp = substring(1,21,
   uar_get_code_display(bur.upload_donor_elig_type_cd)), upload_contact_outcome_disp = substring(1,21,
   uar_get_code_display(bur.upload_contact_outcome_cd)),
  upload_donor_abo_disp = uar_get_code_display(bur.upload_donor_abo_cd), upload_donor_rh_disp =
  uar_get_code_display(bur.upload_donor_rh_cd), demog_contributor_system_disp = substring(1,11,
   uar_get_code_display(bur.demog_contributor_system_cd)),
  demog_donor_elig_type_disp = substring(1,21,uar_get_code_display(bur.demog_donor_elig_type_cd)),
  demog_donor_abo_disp = uar_get_code_display(bur.demog_donor_abo_cd), demog_donor_rh_disp =
  uar_get_code_display(bur.demog_donor_rh_cd),
  posted_donor_elig_type_disp = substring(1,26,uar_get_code_display(bur.posted_donor_elig_type_cd)),
  posted_donor_abo_disp = uar_get_code_display(bur.posted_donor_abo_cd), posted_donor_rh_disp =
  uar_get_code_display(bur.posted_donor_rh_cd),
  alias_formatted = substring(1,11,cnvtalias(pa.alias,pa.alias_pool_cd))
  FROM bbd_upload_review bur,
   person p,
   person_alias pa
  PLAN (bur
   WHERE bur.bbd_upload_review_id > 0.0
    AND bur.upload_dt_tm >= cnvtdatetime(request->beg_dt_tm)
    AND bur.upload_dt_tm <= cnvtdatetime(request->end_dt_tm))
   JOIN (p
   WHERE p.person_id=bur.person_id
    AND p.active_ind=1)
   JOIN (pa
   WHERE pa.person_id=outerjoin(bur.person_id)
    AND pa.active_ind=outerjoin(1)
    AND pa.person_alias_type_cd=outerjoin(person_alias_ssn_cd))
  ORDER BY bur.upload_dt_tm
  HEAD REPORT
   first_page = 1, save_row = 0, browminus = "F",
   page_disp = substring(1,3,fillstring(3," ")), upload_donor_aborh_disp = fillstring(12," "),
   demog_donor_aborh_disp = fillstring(12," "),
   posted_donor_aborh_disp = fillstring(26," ")
  HEAD PAGE
   row 0, inc_i18nhandle = 0, inc_h = uar_i18nlocalizationinit(inc_i18nhandle,curprog,"",curcclrev),
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
   save_row = row, row 0,
   CALL center(captions->rpt_title,1,132),
   col 108, captions->rpt_time, col 121,
   curtime, row + 1, col 108,
   captions->rpt_as_of_date, col 121, curdate"@DATECONDENSED",
   row + 1, col 35, captions->rpt_beg_date,
   col 51, request->beg_dt_tm"@DATECONDENSED;;d", col 59,
   request->beg_dt_tm"@TIMENOSECONDS;;M", col 73, captions->rpt_end_date,
   col 86, request->end_dt_tm"@DATECONDENSED;;d", col 95,
   request->end_dt_tm"@TIMENOSECONDS;;M"
   IF (save_row > 1)
    call reportmove('ROW',(save_row+ 2),0)
   ELSE
    row + 2
   ENDIF
   col 0, captions->hdr_date, row + 1,
   col 0, captions->hdr_type_of_disc, row + 1,
   col 0, captions->hdr_donor_name, col 25,
   captions->hdr_contributor, col 37, captions->hdr_dob,
   col 46, captions->hdr_gender, col 57,
   captions->hdr_ssn, col 69, captions->hdr_aborh,
   col 82, captions->hdr_eligibility, col 104,
   captions->hdr_system, row + 1, col 25,
   captions->hdr_system, col 82, captions->hdr_deferral_status,
   col 104, captions->hdr_resolution, row + 1,
   col 82, captions->hdr_defer_until, col 104,
   captions->hdr_defer_until, row + 1, col 0,
   line131
  HEAD bur.upload_dt_tm
   IF (row > 49)
    BREAK
   ENDIF
   row + 1, col 0, bur.upload_dt_tm"@SHORTDATE"
  DETAIL
   browminus = "F"
   IF (bur.upload_discrep_type_flag=donor_aborh_disc)
    upload_donor_aborh_disp = substring(1,12,concat(trim(upload_donor_abo_disp)," ",trim(
       upload_donor_rh_disp))), demog_donor_aborh_disp = substring(1,12,concat(trim(
       demog_donor_abo_disp)," ",trim(demog_donor_rh_disp))), posted_donor_aborh_disp = substring(1,
     26,concat(trim(posted_donor_abo_disp)," ",trim(posted_donor_rh_disp))),
    row + 2
    IF (row > 54)
     BREAK, row + 1
    ENDIF
    col 0, captions->hdr_aborh, row + 1,
    col 1, person_name_disp, col 25,
    upload_contributor_system_disp, col 37, p.birth_dt_tm"@SHORTDATE",
    col 46, sex_disp, col 57,
    alias_formatted, col 69, upload_donor_aborh_disp
    IF (((bur.posted_donor_abo_cd > 0.0) OR (bur.posted_donor_rh_cd > 0.0)) )
     col 104, posted_donor_aborh_disp
    ELSE
     col 104, captions->no_aborh
    ENDIF
    row + 1, col 1, person_name_disp,
    col 25, demog_contributor_system_disp, col 37,
    p.birth_dt_tm"@SHORTDATE", col 46, sex_disp,
    col 57, alias_formatted, col 69,
    demog_donor_aborh_disp
   ELSEIF (bur.upload_discrep_type_flag=donor_sngl_trx_disc)
    row + 2
    IF (row > 51)
     BREAK, row + 1
    ENDIF
    col 0, captions->hdr_status_outcome, row + 1,
    col 1, person_name_disp, col 25,
    upload_contributor_system_disp, col 37, p.birth_dt_tm"@SHORTDATE",
    col 46, sex_disp, col 57,
    alias_formatted, col 104, posted_donor_elig_type_disp,
    row + 1, col 57, captions->donor,
    col 82, upload_donor_elig_type_disp, col 104,
    bur.posted_donor_defer_until_dt_tm"@SHORTDATE"
    IF (bur.upload_donor_elig_type_cd=eligibility_temp_defer_cd)
     row + 1, col 82, bur.upload_donor_defer_until_dt_tm"@SHORTDATE"
    ENDIF
    row + 1, col 57, captions->final_outcome,
    col 82, upload_contact_outcome_disp, row + 1,
    col 57, captions->contact_outcome, col 82,
    upload_outcome_disp
    IF (((bur.upload_contact_outcome_cd=contact_temp_defer_cd) OR (bur.upload_outcome_cd=
    contact_temp_defer_cd)) )
     row + 1, col 82, bur.upload_contact_eligible_dt_tm"@SHORTDATE"
    ENDIF
   ELSEIF (bur.upload_discrep_type_flag=donor_dup_disc)
    row + 2
    IF (row > 52)
     BREAK, row + 1
    ENDIF
    col 0, captions->hdr_elig_status, row + 1,
    col 1, person_name_disp, col 25,
    upload_contributor_system_disp, col 37, p.birth_dt_tm"@SHORTDATE",
    col 46, sex_disp, col 57,
    alias_formatted, col 82, upload_donor_elig_type_disp,
    col 104, posted_donor_elig_type_disp
    IF (bur.upload_donor_elig_type_cd=eligibility_temp_defer_cd)
     row + 1, col 82, bur.upload_donor_defer_until_dt_tm"@SHORTDATE",
     browminus = "T"
    ENDIF
    row + 1, col 1, person_name_disp,
    col 25, demog_contributor_system_disp, col 37,
    p.birth_dt_tm"@SHORTDATE", col 46, sex_disp,
    col 57, alias_formatted, col 82,
    demog_donor_elig_type_disp
    IF (bur.posted_donor_elig_type_cd=eligibility_temp_defer_cd)
     IF (browminus="T")
      save_row = row, row- (1), col 104,
      bur.posted_donor_defer_until_dt_tm"@SHORTDATE", row save_row
     ELSE
      col 104, bur.posted_donor_defer_until_dt_tm"@SHORTDATE"
     ENDIF
    ENDIF
    IF (bur.demog_donor_elig_type_cd=eligibility_temp_defer_cd)
     row + 1, col 82, bur.demog_donor_defer_until_dt_tm"@SHORTDATE"
    ENDIF
   ENDIF
  FOOT  bur.upload_dt_tm
   row + 1
  FOOT PAGE
   row 57, col 0, bottom_line,
   row + 1, col 0, script_name,
   col 119, captions->rpt_page, page_disp = format(curpage,";l"),
   col 125, page_disp, row + 1
  FOOT REPORT
   CALL center(captions->rpt_end_of_report,1,132)
  WITH nullreport
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  SET reply->status_data.status = "F"
  CALL subevent_add("Select BBD Upload Review","F","bbd_rpt_upload_review.prg",errmsg)
  GO TO exit_script
 ENDIF
#set_status
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((reply->status_data.status="S"))
  SET stat = alterlist(reply->rpt_list,1)
  SET reply->rpt_list[1].rpt_filename = cpm_cfn_info->file_name_path
 ENDIF
#exit_script
 FREE SET captions
 SET modify = nopredeclare
END GO
