CREATE PROGRAM bbd_upd_reinstatement_elig:dba
 RECORD reply(
   1 report_name_list[*]
     2 report_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 RECORD temp(
   1 people[*]
     2 person_id = f8
     2 updt_cnt = f8
   1 deferral_reason = vc
   1 list[*]
     2 line = vc
 )
 RECORD current(
   1 system_dt_tm = dq8
 )
 SET reply->status_data.status = "T"
 SET reply->status = "T"
 SET idx = 0
 SET counter = 0
 SET reason_count = size(request->deferral_reason_list,5)
 SET assay_count = size(request->assay_list,5)
 SET current->system_dt_tm = cnvtdatetime(curdate,curtime)
 SET donor_number = 0
 SET line = fillstring(130,"-")
 SET report_complete_ind = "N"
 SET code_cnt = 1
 SET home_phone_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(43,"HOME",code_cnt,home_phone_cd)
 IF (home_phone_cd=0.0)
  SET reply->status = "F"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_reinstatement_elig.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Update"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unable to retrieve code value for code set 43 and cdf meaning HOME."
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 SET code_cnt = 1
 SET business_phone_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(43,"BUSINESS",code_cnt,business_phone_cd)
 IF (business_phone_cd=0)
  SET reply->status = "F"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_reinstatement_elig.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Update"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Unable to retrieve code value for code set 43 and cdf meaning BUSINESS."
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 SET code_cnt = 1
 SET preference_cd = 0.0
 IF ((request->preference_ind="Y"))
  SET cdf_meaning = "SSN"
 ELSE
  SET cdf_meaning = "DONORID"
 ENDIF
 SET stat = uar_get_meaning_by_codeset(4,cdf_meaning,code_cnt,preference_cd)
 IF (preference_cd=0)
  SET reply->status = "F"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_reinstatement_elig.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Update"
  SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = build(
   "Unable to retrieve code value for code set 4 and cdf meaning ",cdf_meaning," .")
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->report_name_list,1)
 SET sfiledate = format(curdate,"mmdd;;d")
 SET sfiletime = substring(1,6,format(curtime3,"hhmmss;;s"))
 IF (reason_count > 0)
  SET sfilename = build("BBDdef",sfiledate,sfiletime)
  SET reply->report_name_list[1].report_name = concat("CER_TEMP:",trim(sfilename),".txt")
  SET index = 1
  SELECT INTO concat("CER_TEMP:",trim(sfilename),".txt")
   pd.person_id, pd.last_donation_dt_tm, state_display = substring(1,30,uar_get_code_display(a
     .state_cd)),
   country_display = substring(1,100,uar_get_code_display(a.country_cd)), reason_display = substring(
    1,12,uar_get_code_display(bdr.reason_cd)), city_display = substring(1,40,a.city),
   zip_display = substring(1,20,a.zipcode), name_display = substring(1,60,p.name_full_formatted), p
   .name_last_key,
   donor_nbr = substring(1,20,pa.alias), preference = substring(1,20,cnvtalias(pa.alias,ap
     .format_mask)), a.street_addr,
   a.street_addr2, a.street_addr3, a.street_addr4,
   ph.phone_num, ph2.phone_num
   FROM person_donor pd,
    bbd_deferral_reason bdr,
    (dummyt d1  WITH seq = value(reason_count)),
    person p,
    dummyt d2,
    address a,
    dummyt d3,
    person_alias pa,
    dummyt d4,
    alias_pool ap,
    dummyt d5,
    phone ph,
    phone ph2,
    dummyt d6
   PLAN (pd
    WHERE pd.last_donation_dt_tm < cnvtdatetime(request->end_dt_tm)
     AND pd.last_donation_dt_tm > cnvtdatetime(request->begin_dt_tm)
     AND pd.active_ind=1)
    JOIN (d1)
    JOIN (bdr
    WHERE bdr.person_id=pd.person_id
     AND (bdr.reason_cd=request->deferral_reason_list[d1.seq].deferral_reason_cd)
     AND bdr.active_ind=1)
    JOIN (p
    WHERE p.person_id=pd.person_id
     AND p.active_ind=1)
    JOIN (d2)
    JOIN (a
    WHERE a.parent_entity_id=pd.person_id
     AND a.parent_entity_name="PERSON"
     AND a.active_ind=1)
    JOIN (d3)
    JOIN (pa
    WHERE pa.person_id=pd.person_id
     AND pa.person_alias_type_cd=preference_cd
     AND pa.active_ind=1)
    JOIN (d4)
    JOIN (ap
    WHERE ap.alias_pool_cd=pa.alias_pool_cd
     AND ap.active_ind=1)
    JOIN (d5)
    JOIN (ph
    WHERE ph.parent_entity_id=pd.person_id
     AND ph.phone_type_cd=home_phone_cd
     AND ph.parent_entity_name="PERSON"
     AND ph.active_ind=1)
    JOIN (d6)
    JOIN (ph2
    WHERE ph2.parent_entity_id=pd.person_id
     AND ph2.phone_type_cd=business_phone_cd
     AND ph2.parent_entity_name="PERSON"
     AND ph2.active_ind=1)
   ORDER BY p.name_last_key, pd.person_id
   HEAD PAGE
    beg_dt_tm = cnvtdatetime(request->begin_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm), col
     0,
    "Cerner Health Systems",
    CALL center("B L O O D   B A N K   D E F E R R A L   R E A S O N S   R E P O R T",0,130), col 107,
    "Time:", col + 2, curtime"hh:mm;;m",
    row + 1, col 107, "Date:",
    col + 2, curdate"mm/dd/yy;;d", row + 1,
    col 0, "Beginning Date:", col + 2,
    beg_dt_tm"mm/dd/yy;;d", col + 2, beg_dt_tm"hh:mm;;m",
    col + 2, "Ending Date:", col + 2,
    end_dt_tm"mm/dd/yy;;d", col + 2, end_dt_tm"hh:mm;;m"
    IF ((request->preference_ind="N"))
     row + 1, col 61, "Donor ID"
    ELSE
     row + 1, col 61, "Social Security",
     row + 1, col 61, "     Number"
    ENDIF
    col 0, "Full Name", col 81,
    "Home Phone", col 97, "Business Phone",
    col 115, "Last Donation", row + 1,
    col 0, "-----------------------------------------------------------", col 61,
    "------------------", col 81, "--------------",
    col 97, "----------------", col 115,
    "---------------", row + 1
   HEAD pd.person_id
    IF (row > 56)
     BREAK
    ENDIF
    donor_number = (donor_number+ 1), idx = (idx+ 1), stat = alterlist(temp->people,idx),
    temp->people[idx].person_id = pd.person_id, temp->people[idx].updt_cnt = pd.updt_cnt, col 0,
    name_display
    IF ((request->preference_ind="N"))
     col 61, donor_nbr
    ELSE
     col 61, preference
    ENDIF
    IF (ph.phone_num != null)
     col 81, ph.phone_num"###############"
    ENDIF
    IF (ph2.phone_num != null)
     col 97, ph2.phone_num"###############"
    ENDIF
    col 115, pd.last_donation_dt_tm"MM/DD/YY"
    IF (((a.street_addr != null) OR (((a.street_addr2 != null) OR (((a.street_addr3 != null) OR (a
    .street_addr4 != null)) )) )) )
     row + 1
     IF (row > 56)
      BREAK
     ENDIF
     col 5, "Address:  "
    ENDIF
    IF (a.street_addr != null)
     col 15, a.street_addr
    ENDIF
    IF (a.street_addr2 != null)
     row + 1
     IF (row > 56)
      BREAK
     ENDIF
     col 15, a.street_addr2
    ENDIF
    IF (a.street_addr3 != null)
     row + 1
     IF (row > 56)
      BREAK
     ENDIF
     col 15, a.street_addr3
    ENDIF
    IF (a.street_addr4 != null)
     row + 1
     IF (row > 56)
      BREAK
     ENDIF
     col 15, a.street_addr4
    ENDIF
    city_state_zip_display = concat(trim(city_display),", ",trim(state_display)," ",zip_display)
    IF (city_state_zip_display != ",  ")
     row + 1
     IF (row > 56)
      BREAK
     ENDIF
     col 15, city_state_zip_display
    ENDIF
    IF (country_display != null)
     row + 1
     IF (row > 56)
      BREAK
     ENDIF
     col 15, country_display
    ENDIF
    counter = 0
   DETAIL
    IF (row > 56)
     BREAK
    ENDIF
    IF (counter=0)
     row + 1
     IF (row > 56)
      BREAK
     ENDIF
     index = 1, stat = alterlist(temp->list,index), temp->list[index].line = concat(
      "Active Deferrals: ",trim(reason_display)),
     col 5, temp->list[index].line, counter = 1
    ELSE
     IF (col > 118)
      temp->list[index].line = concat(temp->list[index].line,","), col 5, temp->list[index].line,
      row + 1
      IF (row > 56)
       BREAK
      ENDIF
      index = (index+ 1), stat = alterlist(temp->list,index), temp->list[index].line = concat(
       "                  ",trim(reason_display)),
      col 5, temp->list[index].line
     ELSE
      temp->list[index].line = concat(temp->list[index].line,", ",trim(reason_display)), col 5, temp
      ->list[index].line
     ENDIF
    ENDIF
   FOOT  pd.person_id
    row + 1, report_complete_ind = "Y"
   FOOT PAGE
    row 57, col 0, line,
    row + 1, col 0, "Report ID:  BBD_UPD_REINSTATEMENT_ELIG",
    col 58, "Page:", col 64,
    curpage"###"
   FOOT REPORT
    row 59, col 0, "Total Number of Donors:  ",
    donor_number"#######"
   WITH nocounter, outerjoin = d2, outerjoin = d3,
    outerjoin = d4, outerjoin = d5, outerjoin = d6,
    dontcare = ph2, dontcare = ph, dontcare = ap,
    dontcare = pa, dontcare = a, compress,
    nolandscape, nullreport
  ;end select
 ELSE
  SET sfilename = build("BBDass",sfiledate,sfiletime)
  SET reply->report_name_list[1].report_name = concat("CER_TEMP:",trim(sfilename),".txt")
  SET index = 1
  SELECT INTO concat("CER_TEMP:",trim(sfilename),".txt")
   pd.last_donation_dt_tm, task = substring(1,20,uar_get_code_display(ce.task_assay_cd)), result =
   substring(1,25,n.mnemonic),
   pd.person_id, donor_nbr = substring(1,20,pa.alias), p.person_id,
   state_display = substring(1,30,uar_get_code_display(a.state_cd)), country_display = substring(1,
    100,uar_get_code_display(a.country_cd)), city_display = substring(1,40,a.city),
   zip_display = substring(1,20,a.zipcode), name_display = substring(1,60,p.name_full_formatted), pr
   .name_last_key,
   preference = substring(1,20,cnvtalias(pa.alias,ap.format_mask)), a.street_addr, a.street_addr2,
   a.street_addr3, a.street_addr4, ph.phone_num,
   ph2.phone_num
   FROM person_donor pd,
    clinical_event ce,
    reference_range_factor rr,
    alpha_responses ar,
    nomenclature n,
    person p,
    address a,
    person_alias pa,
    alias_pool ap,
    phone ph,
    phone ph2,
    (dummyt d1  WITH seq = value(assay_count)),
    (dummyt d2  WITH seq = value(assay_count)),
    dummyt d3,
    dummyt d4,
    dummyt d5,
    dummyt d6,
    dummyt d7,
    dummyt d8
   PLAN (pd
    WHERE pd.last_donation_dt_tm < cnvtdatetime(request->end_dt_tm)
     AND pd.last_donation_dt_tm > cnvtdatetime(request->begin_dt_tm)
     AND pd.active_ind=1)
    JOIN (d1)
    JOIN (ce
    WHERE ce.person_id=pd.person_id
     AND (ce.task_assay_cd=request->assay_list[d1.seq].assay_cd))
    JOIN (rr
    WHERE rr.task_assay_cd=ce.task_assay_cd
     AND rr.active_ind=1)
    JOIN (d2)
    JOIN (ar
    WHERE ar.reference_range_factor_id=rr.reference_range_factor_id
     AND (ar.nomenclature_id=request->assay_list[d2.seq].assay_result_cd)
     AND ar.active_ind=1)
    JOIN (n
    WHERE n.nomenclature_id=ar.nomenclature_id
     AND n.active_ind=1)
    JOIN (d3)
    JOIN (p
    WHERE p.person_id=pd.person_id
     AND p.active_ind=1)
    JOIN (d4)
    JOIN (a
    WHERE a.parent_entity_id=p.person_id
     AND a.parent_entity_name="PERSON"
     AND a.active_ind=1)
    JOIN (d5)
    JOIN (pa
    WHERE pa.person_id=p.person_id
     AND pa.person_alias_type_cd=preference_cd
     AND pa.active_ind=1)
    JOIN (d6)
    JOIN (ap
    WHERE ap.alias_pool_cd=pa.alias_pool_cd
     AND ap.active_ind=1)
    JOIN (d7)
    JOIN (ph
    WHERE ph.parent_entity_id=p.person_id
     AND ph.phone_type_cd=home_phone_cd
     AND ph.parent_entity_name="PERSON"
     AND ph.active_ind=1)
    JOIN (d8)
    JOIN (ph2
    WHERE ph2.parent_entity_id=p.person_id
     AND ph2.phone_type_cd=business_phone_cd
     AND ph2.parent_entity_name="PERSON"
     AND ph2.active_ind=1)
   ORDER BY pd.person_id
   HEAD PAGE
    beg_dt_tm = cnvtdatetime(request->begin_dt_tm), end_dt_tm = cnvtdatetime(request->end_dt_tm), col
     0,
    "Cerner Health Systems",
    CALL center("B L O O D   B A N K   A S S A Y    R E P O R T",0,130), col 107,
    "Time:", col 121, curtime"hh:mm;;m",
    row + 1, col 107, "As of Date:",
    col 121, curdate"mm/dd/yy;;d", row + 1,
    col 0, "Beginning Date:", col + 2,
    beg_dt_tm"mm/dd/yy;;d", col + 2, beg_dt_tm"hh:mm;;m",
    col + 2, "Ending Date:", col + 2,
    end_dt_tm"mm/dd/yy;;d", col + 2, end_dt_tm"hh:mm;;m"
    IF ((request->preference_ind="N"))
     row + 1, col 61, "Donor ID"
    ELSE
     row + 1, col 61, "Social Security",
     row + 1, col 61, "     Number"
    ENDIF
    col 0, "Full Name", col 81,
    "Home Phone", col 97, "Business Phone",
    col 115, "Last Donation", row + 1,
    col 0, "-----------------------------------------------------------", col 61,
    "------------------", col 81, "--------------",
    col 97, "----------------", col 115,
    "---------------", row + 1
   HEAD pd.person_id
    IF (row > 56)
     BREAK
    ENDIF
    donor_number = (donor_number+ 1), idx = (idx+ 1), stat = alterlist(temp->people,idx),
    temp->people[idx].person_id = pd.person_id, temp->people[idx].updt_cnt = pd.updt_cnt, col 0,
    name_display
    IF ((request->preference_ind="N"))
     col 61, donor_nbr
    ELSE
     col 61, preference
    ENDIF
    IF (ph.phone_num != null)
     col 81, ph.phone_num"###############"
    ENDIF
    IF (ph2.phone_num != null)
     col 97, ph2.phone_num"###############"
    ENDIF
    col 115, pd.last_donation_dt_tm"MM/DD/YY"
    IF (((a.street_addr != null) OR (((a.street_addr2 != null) OR (((a.street_addr3 != null) OR (a
    .street_addr4 != null)) )) )) )
     row + 1
     IF (row > 56)
      BREAK
     ENDIF
     col 5, "Address:  "
    ENDIF
    IF (a.street_addr != null)
     col 15, a.street_addr
    ENDIF
    IF (a.street_addr2 != null)
     row + 1
     IF (row > 56)
      BREAK
     ENDIF
     col 15, a.street_addr2
    ENDIF
    IF (a.street_addr3 != null)
     row + 1
     IF (row > 56)
      BREAK
     ENDIF
     col 15, a.street_addr3
    ENDIF
    IF (a.street_addr4 != null)
     row + 1
     IF (row > 56)
      BREAK
     ENDIF
     col 15, a.street_addr4
    ENDIF
    city_state_zip_display = concat(trim(city_display),", ",trim(state_display)," ",zip_display)
    IF (city_state_zip_display != ",  ")
     row + 1
     IF (row > 56)
      BREAK
     ENDIF
     col 15, city_state_zip_display
    ENDIF
    IF (country_display != null)
     row + 1
     IF (row > 56)
      BREAK
     ENDIF
     col 15, country_display
    ENDIF
    counter = 0
   DETAIL
    IF (row > 56)
     BREAK
    ENDIF
    IF (counter=0)
     row + 1
     IF (row > 56)
      BREAK
     ENDIF
     index = 1, stat = alterlist(temp->list,index), temp->list[index].line = concat(
      "Positive Results: ",trim(task),"     ",trim(result)),
     col 5, temp->list[index].line, counter = 1
    ELSE
     IF (col > 82)
      temp->list[index].line = concat(temp->list[index].line,","), col 5, temp->list[index].line,
      row + 1
      IF (row > 56)
       BREAK
      ENDIF
      index = (index+ 1), stat = alterlist(temp->list,index), temp->list[index].line = concat(
       "                  ",trim(task),"     ",trim(result)),
      col 5, temp->list[index].line
     ELSE
      temp->list[index].line = concat(temp->list[index].line,", ",trim(task),"     ",trim(result)),
      col 5, temp->list[index].line
     ENDIF
    ENDIF
   FOOT  pd.person_id
    row + 1, report_complete_ind = "Y"
   FOOT PAGE
    row 57, col 0, line,
    row + 1, col 0, "Report ID:  BBD_UPD_REINSTATEMENT_ELIG",
    col 58, "Page:", col 64,
    curpage"###"
   FOOT REPORT
    row 59, col 0, "Total Number of Donors:  ",
    donor_number"#######"
   WITH nocounter, outerjoin = d3, outerjoin = d4,
    outerjoin = d5, outerjoin = d6, outerjoin = d7,
    outerjoin = d8, dontcare = p, dontcare = a,
    dontcare = ap, dontcare = pa, dontcare = ph,
    dontcare = ph2, compress, nolandscape,
    nullreport
  ;end select
 ENDIF
 IF (report_complete_ind != "Y")
  SET reply->status = "F"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_reinstatement_elig.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Update"
  SET reply->status_data.subeventstatus[1].targetobjectname = "person_donor"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Error on printing deferral reasons report."
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
 IF ((request->elig_for_reinstate_ind=1))
  FOR (counter = 1 TO idx)
    SELECT INTO "nl:"
     p.*
     FROM person_donor p
     WHERE (p.person_id=temp->people[counter].person_id)
      AND (p.updt_cnt=temp->people[counter].updt_cnt)
      AND ((p.lock_ind=0) OR (p.lock_ind=null))
     WITH nocounter, forupdate(p)
    ;end select
    IF (curqual=0)
     SET reply->status = "F"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_reinstatement_elig.prg"
     SET reply->status_data.subeventstatus[1].operationname = "Updating"
     SET reply->status_data.subeventstatus[1].targetobjectname = "person_donor"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error on locking donor."
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     GO TO exit_script
    ENDIF
    UPDATE  FROM person_donor p
     SET p.elig_for_reinstate_ind = 1, p.updt_dt_tm = cnvtdatetime(current->system_dt_tm), p.updt_id
       = reqinfo->updt_id,
      p.updt_cnt = (p.updt_cnt+ 1), p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->
      updt_applctx,
      p.lock_ind = 0
     WHERE (p.person_id=temp->people[counter].person_id)
      AND (p.updt_cnt=temp->people[counter].updt_cnt)
    ;end update
    IF (curqual=0)
     SET reply->status = "F"
     SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_upd_reinstatement_elig.prg"
     SET reply->status_data.subeventstatus[1].operationname = "Update"
     SET reply->status_data.subeventstatus[1].targetobjectname = "person_donor"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = "Error on updating donor."
     SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
     GO TO exit_script
    ENDIF
  ENDFOR
 ENDIF
#exit_script
 IF ((reply->status="F"))
  SET reply->status_data.status = "Z"
  ROLLBACK
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
END GO
