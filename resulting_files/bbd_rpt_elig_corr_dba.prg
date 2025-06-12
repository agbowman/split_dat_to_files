CREATE PROGRAM bbd_rpt_elig_corr:dba
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
 FREE SET captions
 RECORD captions(
   1 inc_title = vc
   1 inc_time = vc
   1 inc_as_of_date = vc
   1 inc_blood_bank_owner = vc
   1 inc_inventory_area = vc
   1 inc_beg_dt_tm = vc
   1 inc_end_dt_tm = vc
   1 inc_report_id = vc
   1 inc_page = vc
   1 inc_printed = vc
   1 scortyp = vc
   1 rpt_cerner_health_sys = vc
   1 rpt_corrections = vc
   1 donor_number = vc
   1 eligibility_type = vc
   1 defer_until = vc
   1 format_reinstated = vc
   1 eligible_for_reinstate = vc
   1 yes = vc
   1 no = vc
   1 reinstated_date = vc
   1 eligible = vc
   1 defer = vc
   1 rpt_for = vc
   1 reinstated = vc
   1 eligibility = vc
   1 until = vc
   1 reinstate = vc
   1 date_time = vc
   1 corrected = vc
   1 tech_id = vc
   1 correction_reason = vc
   1 note = vc
   1 end_of_report = vc
   1 demographic = vc
   1 previous = vc
   1 formatted_dt_tm = vc
   1 formatted_reason = vc
   1 formatted_tech_disp = vc
   1 donor_name = vc
   1 donor_ssn = vc
   1 deferral_type = vc
   1 none = vc
   1 inc_donation_location = vc
 )
 SET captions->rpt_cerner_health_sys = uar_i18ngetmessage(i18nhandle,"rpt_cerner_health_systems",
  "Cerner HNA Millenium")
 SET captions->inc_title = uar_i18ngetmessage(i18nhandle,"rpt_title",
  "D O N A T I O N   C O R R E C T I O N S")
 SET captions->inc_time = uar_i18ngetmessage(i18nhandle,"rpt_time","Time:")
 SET captions->rpt_corrections = uar_i18ngetmessage(i18nhandle,"rpt_corrections",
  "C O R R E C T I O N S")
 SET captions->inc_as_of_date = uar_i18ngetmessage(i18nhandle,"rpt_as_of_date","As of Date:")
 SET captions->inc_beg_dt_tm = uar_i18ngetmessage(i18nhandle,"begin_dt_tm","Beginning Date/Time:")
 SET captions->inc_end_dt_tm = uar_i18ngetmessage(i18nhandle,"end_dt_tm","Ending Date/Time:")
 SET captions->donor_number = uar_i18ngetmessage(i18nhandle,"donor_number","Donor Number")
 SET captions->eligibility_type = uar_i18ngetmessage(i18nhandle,"eligibility_type",
  "Eligibility Type:")
 SET captions->defer_until = uar_i18ngetmessage(i18nhandle,"defer_until","Defer Until")
 SET captions->format_reinstated = uar_i18ngetmessage(i18nhandle,"format_reinstated","Reinstated:")
 SET captions->eligible_for_reinstate = uar_i18ngetmessage(i18nhandle,"eligible_for_reinstate",
  "Eligible (Reinstatement)")
 SET captions->reinstated_date = uar_i18ngetmessage(i18nhandle,"reinstated_date",
  "Reinstatement Date:")
 SET captions->eligible = uar_i18ngetmessage(i18nhandle,"eligible","Eligible")
 SET captions->defer = uar_i18ngetmessage(i18nhandle,"defer","Defer")
 SET captions->rpt_for = uar_i18ngetmessage(i18nhandle,"rpt_for","for")
 SET captions->eligibility = uar_i18ngetmessage(i18nhandle,"eligibility","Eligibility")
 SET captions->until = uar_i18ngetmessage(i18nhandle,"until","Until")
 SET captions->reinstate = uar_i18ngetmessage(i18nhandle,"reinstate","Reinstate")
 SET captions->reinstated = uar_i18ngetmessage(i18nhandle,"reinstated","Reinstated")
 SET captions->date_time = uar_i18ngetmessage(i18nhandle,"date_time","Date/Time")
 SET captions->corrected = uar_i18ngetmessage(i18nhandle,"corrected","Corrected")
 SET captions->tech_id = uar_i18ngetmessage(i18nhandle,"tech_id","Tech ID")
 SET captions->correction_reason = uar_i18ngetmessage(i18nhandle,"correction_reason",
  "Correction Reason")
 SET captions->yes = uar_i18ngetmessage(i18nhandle,"yes","YES")
 SET captions->no = uar_i18ngetmessage(i18nhandle,"no","NO")
 SET captions->note = uar_i18ngetmessage(i18nhandle,"note","Note:")
 SET captions->inc_report_id = uar_i18ngetmessage(i18nhandle,"rpt_id","BBD_RPT_ELIG_CORR")
 SET captions->inc_page = uar_i18ngetmessage(i18nhandle,"rpt_page","Page:")
 SET captions->inc_printed = uar_i18ngetmessage(i18nhandle,"printed","Printed:")
 SET captions->end_of_report = uar_i18ngetmessage(i18nhandle,"end_of_report",
  "* * * End of Report * * *")
 SET captions->scortyp = uar_i18ngetmessage(i18nhandle,"correction_type","Correction Type: ")
 SET captions->demographic = uar_i18ngetmessage(i18nhandle,"demographic","Demographic")
 SET captions->previous = uar_i18ngetmessage(i18nhandle,"previous","Previous")
 SET captions->formatted_dt_tm = uar_i18ngetmessage(i18nhandle,"formatted_dt_tm","Date/Time")
 SET captions->formatted_reason = uar_i18ngetmessage(i18nhandle,"formatted_reason","Reason")
 SET captions->formatted_tech_disp = uar_i18ngetmessage(i18nhandle,"formatted_tech_disp","Tech")
 SET captions->donor_name = uar_i18ngetmessage(i18nhandle,"donor_name","Donor Name")
 SET captions->donor_ssn = uar_i18ngetmessage(i18nhandle,"donor_ssn","Donor SSN")
 SET captions->deferral_type = uar_i18ngetmessage(i18nhandle,"deferral_type","Deferral Type")
 SET captions->none = uar_i18ngetmessage(i18nhandle,"none","NONE")
 SET captions->inc_donation_location = uar_i18ngetmessage(i18nhandle,"inc_donation_location",
  "Donation Location: ")
 SET captions->inc_blood_bank_owner = uar_i18ngetmessage(i18nhandle,"inc_blood_bank_owner",
  "Blood Bank Owner: ")
 SET captions->inc_inventory_area = uar_i18ngetmessage(i18nhandle,"inc_inventory_area",
  "Inventory Area")
 FREE SET corr
 RECORD corr(
   1 donor[*]
     2 name = vc
     2 donor_id = vc
     2 donor_ssn = vc
     2 deferral_type_disp = vc
     2 defer_until_dt_tm = dq8
     2 elig_for_reinstate_ind = i2
     2 reinstated_dt_tm = dq8
     2 person_id = f8
     2 corrections[*]
       3 deferral_type_disp = vc
       3 defer_until_dt_tm = dq8
       3 elig_for_reinstate_ind = i2
       3 reinstated_dt_tm = dq8
       3 corrected_dt_tm = dq8
       3 correction_reason = vc
       3 corrected_tech_id = vc
       3 person_id = f8
 )
 SET line = fillstring(125,"_")
 SET equal_line = fillstring(126,"=")
 SET donor_id_alias_cd = uar_get_code_by("MEANING",4,"DONORID")
 SET first_donor = "Y"
 SET ssn_id_alias_cd = uar_get_code_by("MEANING",4,"SSN")
 SET new_line = 0
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE nstartrow = i4 WITH protect, noconstant(0)
 DECLARE blank_space = c24 WITH protect, constant(fillstring(24," "))
 SET reply->status_data.status = "F"
 IF (donor_id_alias_cd=0)
  SET reply->status_data.subeventstatus[1].sourceobjectname = "script"
  SET reply->status_data.subeventstatus[1].sourceobjectvalue = "bbd_rpt_elig_corr"
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
  donor_name = substring(1,24,trim(p.name_full_formatted)), def_type_disp = uar_get_code_display(pd
   .eligibility_type_cd), ssn_alias_disp = cnvtalias(pa1.alias,pa1.alias_pool_cd),
  person_alias_disp = cnvtalias(pa.alias,pa.alias_pool_cd)
  FROM bbd_correct_donor bcd,
   person_donor pd,
   person_alias pa,
   person_alias pa1,
   person p
  PLAN (bcd
   WHERE bcd.correction_type_cd=deligcd
    AND bcd.active_ind=1
    AND bcd.updt_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm))
   JOIN (pd
   WHERE pd.person_id=bcd.person_id
    AND pd.active_ind=1)
   JOIN (p
   WHERE p.person_id=pd.person_id)
   JOIN (pa
   WHERE pa.person_id=outerjoin(bcd.person_id)
    AND pa.person_alias_type_cd=outerjoin(donor_id_alias_cd)
    AND pa.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND pa.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
    AND pa.active_ind=outerjoin(1))
   JOIN (pa1
   WHERE pa1.person_id=outerjoin(bcd.person_id)
    AND pa1.person_alias_type_cd=outerjoin(ssn_id_alias_cd)
    AND pa1.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND pa1.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
    AND pa1.active_ind=outerjoin(1))
  ORDER BY p.name_last_key, p.name_first_key, bcd.person_id,
   bcd.active_status_dt_tm, pd.person_id
  HEAD REPORT
   count = 0
  HEAD bcd.person_id
   count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(corr->donor,(count+ 9))
   ENDIF
   corr->donor[count].name = donor_name, corr->donor[count].donor_id =
   IF (pa.person_alias_id > 0) person_alias_disp
   ELSE null
   ENDIF
   , corr->donor[count].donor_ssn =
   IF (pa1.person_alias_id > 0) ssn_alias_disp
   ELSE null
   ENDIF
   ,
   corr->donor[count].deferral_type_disp = def_type_disp, corr->donor[count].defer_until_dt_tm = pd
   .defer_until_dt_tm, corr->donor[count].elig_for_reinstate_ind = pd.elig_for_reinstate_ind,
   corr->donor[count].reinstated_dt_tm = pd.reinstated_dt_tm, corr->donor[count].person_id = pd
   .person_id
  FOOT  bcd.person_id
   row + 0
  FOOT REPORT
   stat = alterlist(corr->donor,count)
  WITH nocounter
 ;end select
 IF (size(corr->donor,5) > 0)
  SELECT
   reason = uar_get_code_display(bcd.correction_reason_cd), def_type_disp = uar_get_code_display(bcd
    .eligibility_type_cd)
   FROM (dummyt d  WITH seq = size(corr->donor,5)),
    bbd_correct_donor bcd,
    prsnl p
   PLAN (d)
    JOIN (bcd
    WHERE (bcd.person_id=corr->donor[d.seq].person_id)
     AND bcd.correction_type_cd=deligcd
     AND bcd.active_ind=1
     AND bcd.updt_dt_tm BETWEEN cnvtdatetime(request->beg_dt_tm) AND cnvtdatetime(request->end_dt_tm)
    )
    JOIN (p
    WHERE p.person_id=bcd.updt_id
     AND cnvtdatetime(curdate,curtime3) >= p.beg_effective_dt_tm
     AND cnvtdatetime(curdate,curtime3) <= p.end_effective_dt_tm
     AND p.active_ind=1)
   ORDER BY bcd.person_id, bcd.updt_dt_tm
   HEAD d.seq
    count = 0
   HEAD bcd.correct_donor_id
    count = (count+ 1)
    IF (mod(count,10)=1)
     stat = alterlist(corr->donor[d.seq].corrections,(count+ 9))
    ENDIF
    corr->donor[d.seq].corrections[count].deferral_type_disp = def_type_disp, corr->donor[d.seq].
    corrections[count].defer_until_dt_tm = bcd.defer_until_dt_tm, corr->donor[d.seq].corrections[
    count].elig_for_reinstate_ind = bcd.elig_for_reinstate_ind,
    corr->donor[d.seq].corrections[count].reinstated_dt_tm = bcd.reinstated_dt_tm, corr->donor[d.seq]
    .corrections[count].corrected_dt_tm = bcd.active_status_dt_tm, corr->donor[d.seq].corrections[
    count].correction_reason = reason,
    corr->donor[d.seq].corrections[count].corrected_tech_id = p.username, corr->donor[d.seq].
    corrections[count].person_id = bcd.person_id
   FOOT  bcd.correct_donor_id
    row + 0
   FOOT  d.seq
    stat = alterlist(corr->donor[d.seq].corrections,count)
   WITH nocounter
  ;end select
  SELECT INTO cpm_cfn_info->file_name_path
   FROM (dummyt d  WITH seq = size(corr->donor,5))
   PLAN (d
    WHERE d.seq > 0.0)
   HEAD REPORT
    row + 0
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
    col 18, elig_disp, row + 2,
    col 1, captions->demographic, col 27,
    captions->previous, col 54, captions->corrected,
    col 81, captions->formatted_dt_tm, col 97,
    captions->formatted_reason, col 123, captions->formatted_tech_disp,
    row + 1, col 1, "------------------------",
    col 27, "-------------------------", col 54,
    "-------------------------", col 81, "--------------",
    col 97, "------------------------", col 123,
    "--------", row + 1, nstartrow = row
   DETAIL
    alt_idx = 0, corr_idx = 0, corr_total = size(corr->donor[d.seq].corrections,5),
    col 1, captions->donor_name, col 27,
    corr->donor[d.seq].name, row + 1, col 1,
    captions->donor_number
    IF ((corr->donor[d.seq].donor_id=null))
     col 27, captions->none
    ELSE
     col 27, corr->donor[d.seq].donor_id
    ENDIF
    row + 1, col 1, captions->donor_ssn
    IF ((corr->donor[d.seq].donor_ssn=null))
     col 27, captions->none
    ELSE
     col 27, corr->donor[d.seq].donor_ssn
    ENDIF
    row + 1, bprinted = 0, col 1,
    captions->deferral_type
    FOR (corr_idx = 1 TO corr_total)
      baltprinted = 0
      IF (new_line=1)
       col 1, captions->deferral_type, new_line = 0
      ENDIF
      IF (size(corr->donor[d.seq].corrections[corr_idx].deferral_type_disp) > 0
       AND (corr->donor[d.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       bprinted = 1, col 27, corr->donor[d.seq].corrections[corr_idx].deferral_type_disp
       FOR (alt_idx = (corr_idx+ 1) TO corr_total)
         IF (size(corr->donor[d.seq].corrections[alt_idx].deferral_type_disp) > 0
          AND baltprinted=0)
          baltprinted = 1, col 54, corr->donor[d.seq].corrections[alt_idx].deferral_type_disp
         ENDIF
       ENDFOR
       IF (baltprinted=0)
        col 54, corr->donor[d.seq].deferral_type_disp
       ENDIF
       col 81, corr->donor[d.seq].corrections[corr_idx].corrected_dt_tm"@SHORTDATE;;d", col 90,
       corr->donor[d.seq].corrections[corr_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col 97, corr->
       donor[d.seq].corrections[corr_idx].correction_reason"####################",
       col 123, corr->donor[d.seq].corrections[corr_idx].corrected_tech_id"########"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ELSEIF (corr_idx >= corr_total
       AND bprinted=0
       AND (corr->donor[d.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       col 27, corr->donor[d.seq].deferral_type_disp
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ENDIF
    ENDFOR
    IF (row > 56)
     BREAK
    ELSE
     col 1, blank_space
    ENDIF
    bprinted = 0, col 1, captions->defer_until
    FOR (corr_idx = 1 TO corr_total)
      baltprinted = 0
      IF (new_line=1)
       col 1, captions->defer_until, new_line = 0
      ENDIF
      IF ((corr->donor[d.seq].corrections[corr_idx].defer_until_dt_tm != null)
       AND (corr->donor[d.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       bprinted = 1, col 27, corr->donor[d.seq].corrections[corr_idx].defer_until_dt_tm
       "@SHORTDATE;;d",
       col 36, corr->donor[d.seq].corrections[corr_idx].defer_until_dt_tm"@TIMENOSECONDS;;d"
       FOR (alt_idx = (corr_idx+ 1) TO corr_total)
         IF ((corr->donor[d.seq].corrections[alt_idx].defer_until_dt_tm != null)
          AND baltprinted=0)
          baltprinted = 1, col 54, corr->donor[d.seq].corrections[alt_idx].defer_until_dt_tm
          "@SHORTDATE;;d",
          col 63, corr->donor[d.seq].corrections[alt_idx].defer_until_dt_tm"@TIMENOSECONDS;;d"
         ENDIF
       ENDFOR
       IF (baltprinted=0)
        col 54, corr->donor[d.seq].defer_until_dt_tm"@SHORTDATE;;d", col 63,
        corr->donor[d.seq].defer_until_dt_tm"@TIMENOSECONDS;;d"
       ENDIF
       col 81, corr->donor[d.seq].corrections[corr_idx].corrected_dt_tm"@SHORTDATE;;d", col 90,
       corr->donor[d.seq].corrections[corr_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col 97, corr->
       donor[d.seq].corrections[corr_idx].correction_reason"####################",
       col 123, corr->donor[d.seq].corrections[corr_idx].corrected_tech_id"########"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ELSEIF (corr_idx >= corr_total
       AND bprinted=0
       AND (corr->donor[d.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       col 27, corr->donor[d.seq].defer_until_dt_tm"@SHORTDATE;;d", col 36,
       corr->donor[d.seq].defer_until_dt_tm"@TIMENOSECONDS;;d"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ENDIF
    ENDFOR
    IF (row > 56)
     BREAK
    ELSE
     col 1, blank_space
    ENDIF
    bprinted = 0, col 1, captions->eligible_for_reinstate
    FOR (corr_idx = 1 TO corr_total)
      baltprinted = 0
      IF (new_line=1)
       col 1, captions->eligible_for_reinstate, new_line = 0
      ENDIF
      IF ((corr->donor[d.seq].corrections[corr_idx].elig_for_reinstate_ind != - (1))
       AND (corr->donor[d.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       bprinted = 1
       IF ((corr->donor[d.seq].corrections[corr_idx].elig_for_reinstate_ind=1))
        col 27, captions->yes
       ELSE
        col 27, captions->no
       ENDIF
       FOR (alt_idx = (corr_idx+ 1) TO corr_total)
         IF ((corr->donor[d.seq].corrections[alt_idx].elig_for_reinstate_ind != - (1))
          AND baltprinted=0)
          baltprinted = 1
          IF ((corr->donor[d.seq].corrections[alt_idx].elig_for_reinstate_ind=1))
           col 54, captions->yes
          ELSE
           col 54, captions->no
          ENDIF
         ENDIF
       ENDFOR
       IF (baltprinted=0)
        IF ((corr->donor[d.seq].elig_for_reinstate_ind=1))
         col 54, captions->yes
        ELSE
         col 54, captions->no
        ENDIF
       ENDIF
       col 81, corr->donor[d.seq].corrections[corr_idx].corrected_dt_tm"@SHORTDATE;;d", col 90,
       corr->donor[d.seq].corrections[corr_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col 97, corr->
       donor[d.seq].corrections[corr_idx].correction_reason"####################",
       col 123, corr->donor[d.seq].corrections[corr_idx].corrected_tech_id"########"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ELSEIF (corr_idx >= corr_total
       AND bprinted=0
       AND (corr->donor[d.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       IF ((corr->donor[d.seq].elig_for_reinstate_ind=1))
        col 27, captions->yes
       ELSE
        col 27, captions->no
       ENDIF
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ENDIF
    ENDFOR
    IF (row > 56)
     BREAK
    ELSE
     col 1, blank_space
    ENDIF
    bprinted = 0, col 1, captions->reinstated_date
    FOR (corr_idx = 1 TO corr_total)
      baltprinted = 0
      IF (new_line=1)
       col 1, captions->reinstated_date, new_line = 0
      ENDIF
      IF ((corr->donor[d.seq].corrections[corr_idx].reinstated_dt_tm != null)
       AND (corr->donor[d.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       bprinted = 1, col 27, corr->donor[d.seq].corrections[corr_idx].reinstated_dt_tm"@SHORTDATE;;d",
       col 36, corr->donor[d.seq].corrections[corr_idx].reinstated_dt_tm"@TIMENOSECONDS;;d"
       FOR (alt_idx = (corr_idx+ 1) TO corr_total)
         IF ((corr->donor[d.seq].corrections[alt_idx].reinstated_dt_tm != null)
          AND baltprinted=0)
          baltprinted = 1, col 54, corr->donor[d.seq].corrections[alt_idx].reinstated_dt_tm
          "@SHORTDATE;;d",
          col 63, corr->donor[d.seq].corrections[alt_idx].reinstated_dt_tm"@TIMENOSECONDS;;d"
         ENDIF
       ENDFOR
       IF (baltprinted=0)
        col 54, corr->donor[d.seq].reinstated_dt_tm"@SHORTDATE;;d", col 63,
        corr->donor[d.seq].reinstated_dt_tm"@TIMENOSECONDS;;d"
       ENDIF
       col 81, corr->donor[d.seq].corrections[corr_idx].corrected_dt_tm"@SHORTDATE;;d", col 90,
       corr->donor[d.seq].corrections[corr_idx].corrected_dt_tm"@TIMENOSECONDS;;d", col 97, corr->
       donor[d.seq].corrections[corr_idx].correction_reason"####################",
       col 123, corr->donor[d.seq].corrections[corr_idx].corrected_tech_id"########"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ELSEIF (corr_idx >= corr_total
       AND bprinted=0
       AND (corr->donor[d.seq].corrections[corr_idx].corrected_dt_tm <= request->end_dt_tm))
       col 27, corr->donor[d.seq].reinstated_dt_tm"@SHORTDATE;;d", col 36,
       corr->donor[d.seq].reinstated_dt_tm"@TIMENOSECONDS;;d"
       IF (row > 55)
        BREAK, new_line = 1
       ELSE
        row + 1
       ENDIF
      ENDIF
    ENDFOR
    col 1, blank_space
    IF (row > 51)
     BREAK
    ELSEIF (row != nstartrow)
     row + 2
    ENDIF
   FOOT PAGE
    row 57, col 1,
"__________________________________________________________________________________________________________________________\
____\
", row + 1, col 1, captions->inc_report_id,
    col 118, captions->inc_page, col 124,
    curpage"###", row + 1
   FOOT REPORT
    row 60, col 51, captions->end_of_report
   WITH nocounter, maxrow = 61, compress,
    nolandscape
  ;end select
 ELSEIF (bnullrpt=1)
  SELECT INTO cpm_cfn_info->file_name_path
   FROM (dummyt d  WITH seq = 1)
   PLAN (d
    WHERE d.seq > 0.0)
   HEAD REPORT
    row + 0
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
    col 18, elig_disp, row + 2,
    col 1, captions->demographic, col 27,
    captions->previous, col 54, captions->corrected,
    col 81, captions->formatted_dt_tm, col 97,
    captions->formatted_reason, col 123, captions->formatted_tech_disp,
    row + 1, col 1, "------------------------",
    col 27, "-------------------------", col 54,
    "-------------------------", col 81, "--------------",
    col 97, "------------------------", col 123,
    "--------", row + 1
   FOOT PAGE
    row 57, col 1,
"__________________________________________________________________________________________________________________________\
____\
", row + 1, col 1, captions->inc_report_id,
    col 118, captions->inc_page, col 124,
    curpage"###", row + 1
   FOOT REPORT
    row 60, col 51, captions->end_of_report
   WITH nocounter, maxrow = 61, compress,
    nolandscape, nullreport
  ;end select
 ELSE
  SELECT INTO cpm_cfn_info->file_name_path
   FROM (dummyt d  WITH seq = 1)
   PLAN (d
    WHERE d.seq > 0.0)
   HEAD REPORT
    row + 0
   FOOT REPORT
    row + 0
   WITH nocounter, nullreport
  ;end select
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 FREE RECORD captions
END GO
