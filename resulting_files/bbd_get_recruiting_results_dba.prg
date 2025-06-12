CREATE PROGRAM bbd_get_recruiting_results:dba
 RECORD reply(
   1 donorlist[*]
     2 person_id = f8
     2 donor_retln_id = f8
     2 recruiting_lists[*]
       3 list_id = f8
       3 list_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp_reply(
   1 donorlist[*]
     2 person_id = f8
     2 ncopyind = i2
 )
 RECORD recruiting_list(
   1 list_id = f8
   1 rare_type_cd = f8
   1 special_interest_cd = f8
   1 abo_cd = f8
   1 rh_cd = f8
   1 race_cd = f8
   1 organization_id = f8
   1 donation_dt_tm = dq8
   1 product_type_cd = f8
   1 last_outcome_cd = f8
   1 contact_method_cd = f8
   1 max_donor_cnt = i2
   1 preferred_donation_location_cd = f8
   1 multiple_list_ind = i2
   1 antigens[*]
     2 antigen_cd = f8
     2 found_ind = i2
   1 zipcodes[*]
     2 zip_code = c25
     2 address_type_cd = f8
 )
 RECORD product_eligibility(
   1 product_list[*]
     2 previous_product_cd = f8
     2 days_until_eligible = i4
 )
 SET modify = predeclare
 DECLARE resettempreply(ltempreplysize=i4) = i2
 DECLARE isvalidtempreply(ltempreplysize=i4) = i2
 DECLARE getcodevalues(null) = i2
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE lmaxdaysuntileligible = i4 WITH protect, noconstant(0)
 DECLARE lindex = i4 WITH protect, noconstant(0)
 DECLARE ncopycnt = i4 WITH protect, noconstant(0)
 DECLARE dnewdonorreltnid = f8 WITH protect, noconstant(0.0)
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(0)
 DECLARE script_name = c25 WITH protect, constant("BBD_GET_RECRUITING_RESULT")
 DECLARE lelig_status_cs = i4 WITH protect, constant(14237)
 DECLARE lcontact_type_cs = i4 WITH protect, constant(14220)
 DECLARE sactive_cdf = c12 WITH protect, constant("GOOD")
 DECLARE sperm_cdf = c12 WITH protect, constant("PERMNENT")
 DECLARE stemp_cdf = c12 WITH protect, constant("TEMP")
 DECLARE srecruit_cdf = c12 WITH protect, constant("RECRUIT")
 DECLARE dactive = f8 WITH protect, noconstant(0.0)
 DECLARE dperm = f8 WITH protect, noconstant(0.0)
 DECLARE dtemp = f8 WITH protect, noconstant(0.0)
 DECLARE drecruitment = f8 WITH protect, noconstant(0.0)
 DECLARE ninvalid = i2 WITH protect, constant(0)
 DECLARE nvalid = i2 WITH protect, constant(1)
 DECLARE indexvar = i4 WITH protect, noconstant(0)
 DECLARE obasedate = dq8 WITH protect
 DECLARE oqualifyingdttm = dq8 WITH protect
 DECLARE otempdate = dq8 WITH protect
 SUBROUTINE resettempreply(ltempreplysize)
   IF (ltempreplysize=0)
    SET lstat = alterlist(temp_reply->donorlist,1)
   ELSE
    FOR (lindex = 1 TO ltempreplysize)
      SET temp_reply->donorlist[lindex].ncopyind = 0
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE isvalidtempreply(ltempreplysize)
   DECLARE nisvalidflag = i2 WITH protect, noconstant(0)
   IF (ltempreplysize > 0)
    SET lindex = 1
    WHILE (lindex <= ltempreplysize
     AND nisvalidflag=ninvalid)
     IF ((temp_reply->donorlist[lindex].ncopyind=1))
      SET nisvalidflag = nvalid
     ENDIF
     SET lindex = (lindex+ 1)
    ENDWHILE
   ENDIF
   RETURN(nisvalidflag)
 END ;Subroutine
 SUBROUTINE getcodevalues(null)
   DECLARE code_cnt = i4 WITH protect, noconstant(1)
   SET lstat = uar_get_meaning_by_codeset(lelig_status_cs,nullterm(sactive_cdf),code_cnt,dactive)
   IF (dactive=0.0)
    SET reply->status_data.status = "F"
    CALL errorhandler("F","uar_get_meaning_by_codeset",
     "Unable to retrieve the code_value for the cdf_meaning GOOD in code_set 14237.")
    RETURN(0)
   ENDIF
   SET lstat = uar_get_meaning_by_codeset(lelig_status_cs,nullterm(sperm_cdf),code_cnt,dperm)
   IF (dperm=0.0)
    SET reply->status_data.status = "F"
    CALL errorhandler("F","uar_get_meaning_by_codeset",
     "Unable to retrieve the code_value for the cdf_meaning PERMNENT in code_set 14237.")
    RETURN(0)
   ENDIF
   SET lstat = uar_get_meaning_by_codeset(lelig_status_cs,nullterm(stemp_cdf),code_cnt,dtemp)
   IF (dtemp=0.0)
    SET reply->status_data.status = "F"
    CALL errorhandler("F","uar_get_meaning_by_codeset",
     "Unable to retrieve the code_value for the cdf_meaning TEMP in code_set 14237.")
    RETURN(0)
   ENDIF
   SET lstat = uar_get_meaning_by_codeset(lcontact_type_cs,nullterm(srecruit_cdf),code_cnt,
    drecruitment)
   IF (drecruitment=0.0)
    SET reply->status_data.status = "F"
    CALL errorhandler("F","uar_get_meaning_by_codeset",
     "Unable to retrieve the code_value for the cdf_meaning RECRUIT in code_set 14220.")
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SET reply->status_data.status = "F"
 SET lstat = getcodevalues(null)
 IF (lstat=0)
  GO TO exit_script
 ENDIF
 IF ((request->person_id=0.0)
  AND (request->list_id=0.0))
  GO TO exit_script
 ELSEIF ((request->person_id > 0.0)
  AND (request->list_id > 0.0))
  GO TO exit_script
 ELSEIF ((request->person_id > 0.0)
  AND (request->list_id=0.0))
  GO TO get_single_donor_lists
 ELSE
  GO TO get_list
 ENDIF
#get_list
 IF ((request->create_ind=0))
  SELECT INTO "nl:"
   rd.person_id
   FROM bbd_recruiting_donor_reltn rd,
    person p
   PLAN (rd
    WHERE (rd.list_id=request->list_id)
     AND rd.active_ind=1)
    JOIN (p
    WHERE p.person_id=rd.person_id)
   HEAD REPORT
    p_cnt = 0
   DETAIL
    p_cnt = (p_cnt+ 1)
    IF (size(reply->donorlist,5) < p_cnt)
     lstat = alterlist(reply->donorlist,(p_cnt+ 9))
    ENDIF
    reply->donorlist[p_cnt].person_id = rd.person_id
   FOOT REPORT
    lstat = alterlist(reply->donorlist,p_cnt)
   WITH nocounter
  ;end select
  SET error_check = error(errmsg,0)
  IF (error_check != 0)
   CALL errorhandler("F","Select donors.",errmsg)
  ENDIF
  IF (curqual=0)
   GO TO set_status
  ENDIF
  SELECT INTO "nl:"
   rl.multiple_list_ind
   FROM bbd_recruiting_list rl
   WHERE (rl.list_id=request->list_id)
   DETAIL
    recruiting_list->multiple_list_ind = rl.multiple_list_ind
   WITH nocounter
  ;end select
  SET error_check = error(errmsg,0)
  IF (error_check != 0)
   CALL errorhandler("F","Select multiple_list_ind.",errmsg)
  ENDIF
 ELSE
  SELECT INTO "nl:"
   rl.list_id, ra.recruit_antigen_id, rz.zip_code_id
   FROM bbd_recruiting_list rl,
    bbd_recruiting_antigen ra,
    bbd_recruiting_zipcode rz
   PLAN (rl
    WHERE (rl.list_id=request->list_id)
     AND rl.active_ind=1
     AND rl.completed_ind=0)
    JOIN (ra
    WHERE ra.list_id=outerjoin(rl.list_id))
    JOIN (rz
    WHERE rz.list_id=outerjoin(rl.list_id))
   ORDER BY rl.list_id, ra.recruit_antigen_id, rz.zip_code_id
   HEAD rl.list_id
    ra_cnt = 0, rz_cnt = 0, recruiting_list->list_id = rl.list_id,
    recruiting_list->donation_dt_tm = cnvtdatetime(rl.donation_dt_tm), recruiting_list->
    product_type_cd = rl.product_type_cd, recruiting_list->rare_type_cd = rl.rare_type_cd,
    recruiting_list->special_interest_cd = rl.special_interest_cd, recruiting_list->abo_cd = rl
    .abo_cd, recruiting_list->rh_cd = rl.rh_cd,
    recruiting_list->race_cd = rl.race_cd, recruiting_list->organization_id = rl.organization_id,
    recruiting_list->last_outcome_cd = rl.last_outcome_cd,
    recruiting_list->contact_method_cd = rl.contact_method_cd, recruiting_list->max_donor_cnt = rl
    .max_donor_cnt, recruiting_list->preferred_donation_location_cd = rl
    .preferred_donation_location_cd,
    recruiting_list->multiple_list_ind = rl.multiple_list_ind
   HEAD ra.recruit_antigen_id
    IF (ra.recruit_antigen_id > 0.0)
     ra_cnt = (ra_cnt+ 1)
     IF (size(recruiting_list->antigens,5) < ra_cnt)
      lstat = alterlist(recruiting_list->antigens,(ra_cnt+ 9))
     ENDIF
     recruiting_list->antigens[ra_cnt].antigen_cd = ra.antigen_cd
    ENDIF
   HEAD rz.zip_code_id
    IF (rz.zip_code_id > 0.0)
     rz_cnt = (rz_cnt+ 1)
     IF (size(recruiting_list->zipcodes,5) < rz_cnt)
      lstat = alterlist(recruiting_list->zipcodes,(rz_cnt+ 9))
     ENDIF
     recruiting_list->zipcodes[rz_cnt].zip_code = rz.zip_code, recruiting_list->zipcodes[rz_cnt].
     address_type_cd = rz.address_type_cd
    ENDIF
   DETAIL
    row + 0
   FOOT  rz.zip_code_id
    row + 0
   FOOT  ra.recruit_antigen_id
    row + 0
   FOOT  rl.list_id
    lstat = alterlist(recruiting_list->antigens,ra_cnt), lstat = alterlist(recruiting_list->zipcodes,
     rz_cnt)
   WITH nocounter
  ;end select
  SET error_check = error(errmsg,0)
  IF (error_check != 0)
   CALL errorhandler("F","Select list criteria.",errmsg)
  ENDIF
  IF (curqual=0)
   CALL errorhandler("F","Select list criteria.","List does not exist")
  ENDIF
  SELECT INTO "nl:"
   bpe.previous_product_cd, bpe.product_cd, bpe.days_until_eligible
   FROM bbd_product_eligibility bpe
   PLAN (bpe
    WHERE (bpe.product_cd=recruiting_list->product_type_cd)
     AND bpe.active_ind=1)
   HEAD REPORT
    product_cnt = 0
   DETAIL
    product_cnt = (product_cnt+ 1)
    IF (size(product_eligibility->product_list,5) < product_cnt)
     lstat = alterlist(product_eligibility->product_list,(product_cnt+ 9))
    ENDIF
    IF (bpe.days_until_eligible > lmaxdaysuntileligible)
     lmaxdaysuntileligible = bpe.days_until_eligible
    ENDIF
    product_eligibility->product_list[product_cnt].previous_product_cd = bpe.previous_product_cd,
    product_eligibility->product_list[product_cnt].days_until_eligible = bpe.days_until_eligible
   FOOT REPORT
    lstat = alterlist(product_eligibility->product_list,product_cnt)
   WITH nocounter
  ;end select
  SET error_check = error(errmsg,0)
  IF (error_check != 0)
   CALL errorhandler("F","Select product elig.",errmsg)
  ENDIF
  SET obasedate = recruiting_list->donation_dt_tm
  SET obasedate = datetimeadd(obasedate,- (lmaxdaysuntileligible))
  IF ((recruiting_list->special_interest_cd > 0.0))
   SELECT INTO "nl:"
    si.special_interest_id
    FROM bbd_special_interest si
    PLAN (si
     WHERE (si.special_interest_cd=recruiting_list->special_interest_cd)
      AND si.active_ind=1)
    HEAD REPORT
     p_cnt = 0
    DETAIL
     p_cnt = (p_cnt+ 1)
     IF (size(temp_reply->donorlist,5) < p_cnt)
      lstat = alterlist(temp_reply->donorlist,(p_cnt+ 10))
     ENDIF
     temp_reply->donorlist[p_cnt].person_id = si.person_id, temp_reply->donorlist[p_cnt].ncopyind = 1
    FOOT REPORT
     lstat = alterlist(temp_reply->donorlist,p_cnt)
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select special interest.",errmsg)
   ENDIF
   IF (curqual=0)
    GO TO set_status
   ENDIF
  ENDIF
  IF ((recruiting_list->rare_type_cd > 0.0))
   IF (size(temp_reply->donorlist,5) > 0)
    SELECT INTO "nl:"
     rt.rare_id
     FROM (dummyt d  WITH seq = value(size(temp_reply->donorlist,5))),
      bbd_rare_types rt
     PLAN (d
      WHERE d.seq <= size(temp_reply->donorlist,5)
       AND (temp_reply->donorlist[d.seq].ncopyind=1))
      JOIN (rt
      WHERE (rt.person_id=temp_reply->donorlist[d.seq].person_id)
       AND (rt.rare_type_cd=recruiting_list->rare_type_cd)
       AND rt.active_ind=1)
     ORDER BY d.seq
     HEAD REPORT
      CALL resettempreply(value(size(temp_reply->donorlist,5)))
     HEAD d.seq
      row + 1
     DETAIL
      temp_reply->donorlist[d.seq].ncopyind = 1
     FOOT  d.seq
      row + 0
     FOOT REPORT
      row + 0
     WITH nocounter
    ;end select
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("F","Select rare types(D).",errmsg)
    ENDIF
    IF (isvalidtempreply(size(temp_reply->donorlist,5))=ninvalid)
     GO TO set_status
    ENDIF
   ELSE
    SELECT INTO "nl:"
     rt.rare_id
     FROM bbd_rare_types rt
     PLAN (rt
      WHERE (rt.rare_type_cd=recruiting_list->rare_type_cd)
       AND rt.active_ind=1)
     HEAD REPORT
      p_cnt = 0
     DETAIL
      p_cnt = (p_cnt+ 1)
      IF (size(temp_reply->donorlist,5) < p_cnt)
       lstat = alterlist(temp_reply->donorlist,(p_cnt+ 10))
      ENDIF
      temp_reply->donorlist[p_cnt].person_id = rt.person_id, temp_reply->donorlist[p_cnt].ncopyind =
      1
     FOOT REPORT
      lstat = alterlist(temp_reply->donorlist,p_cnt)
     WITH nocounter
    ;end select
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("F","Select rare types.",errmsg)
    ENDIF
    IF (curqual=0)
     GO TO set_status
    ENDIF
   ENDIF
  ENDIF
  IF (size(recruiting_list->antigens,5) > 0)
   IF (size(temp_reply->donorlist,5) > 0)
    SELECT INTO "nl:"
     dag.donor_antigen_id
     FROM (dummyt d  WITH seq = value(size(temp_reply->donorlist,5))),
      (dummyt d1  WITH seq = value(size(recruiting_list->antigens,5))),
      donor_antigen dag
     PLAN (d
      WHERE d.seq <= size(temp_reply->donorlist,5)
       AND (temp_reply->donorlist[d.seq].ncopyind=1))
      JOIN (d1
      WHERE d1.seq <= size(recruiting_list->antigens,5))
      JOIN (dag
      WHERE (dag.person_id=temp_reply->donorlist[d.seq].person_id)
       AND (dag.antigen_cd=recruiting_list->antigens[d1.seq].antigen_cd)
       AND dag.active_ind=1)
     ORDER BY dag.person_id
     HEAD REPORT
      CALL resettempreply(value(size(temp_reply->donorlist,5))), p_cnt = 0, a_cnt = 0,
      nadd = 0
     HEAD dag.person_id
      FOR (a_cnt = 1 TO size(recruiting_list->antigens,5))
        recruiting_list->antigens[d1.seq].found_ind = 0
      ENDFOR
     DETAIL
      FOR (a_cnt = 1 TO size(recruiting_list->antigens,5))
        IF ((dag.antigen_cd=recruiting_list->antigens[d1.seq].antigen_cd))
         recruiting_list->antigens[d1.seq].found_ind = 1
        ENDIF
      ENDFOR
     FOOT  dag.person_id
      nadd = 1
      FOR (a_cnt = 1 TO size(recruiting_list->antigens,5))
        IF ((recruiting_list->antigens[a_cnt].found_ind=0))
         nadd = 0
        ENDIF
      ENDFOR
      IF (nadd=1)
       temp_reply->donorlist[d.seq].ncopyind = 1
      ENDIF
     FOOT REPORT
      row + 0
     WITH nocounter
    ;end select
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("F","Select antigens(D).",errmsg)
    ENDIF
    IF (isvalidtempreply(size(temp_reply->donorlist,5))=ninvalid)
     GO TO set_status
    ENDIF
   ELSE
    SELECT INTO "nl:"
     dag.donor_antigen_id
     FROM donor_antigen dag,
      (dummyt d1  WITH seq = value(size(recruiting_list->antigens,5)))
     PLAN (d1
      WHERE d1.seq <= size(recruiting_list->antigens,5))
      JOIN (dag
      WHERE (dag.antigen_cd=recruiting_list->antigens[d1.seq].antigen_cd)
       AND dag.active_ind=1)
     ORDER BY dag.person_id
     HEAD REPORT
      p_cnt = 0, a_cnt = 0, nadd = 0
     HEAD dag.person_id
      FOR (a_cnt = 1 TO size(recruiting_list->antigens,5))
        recruiting_list->antigens[d1.seq].found_ind = 0
      ENDFOR
     DETAIL
      FOR (a_cnt = 1 TO size(recruiting_list->antigens,5))
        IF ((dag.antigen_cd=recruiting_list->antigens[d1.seq].antigen_cd))
         recruiting_list->antigens[d1.seq].found_ind = 1
        ENDIF
      ENDFOR
     FOOT  dag.person_id
      nadd = 1
      FOR (a_cnt = 1 TO size(recruiting_list->antigens,5))
        IF ((recruiting_list->antigens[a_cnt].found_ind=0))
         nadd = 0
        ENDIF
      ENDFOR
      IF (nadd=1)
       p_cnt = (p_cnt+ 1)
       IF (size(temp_reply->donorlist,5) < p_cnt)
        lstat = alterlist(temp_reply->donorlist,(p_cnt+ 10))
       ENDIF
       temp_reply->donorlist[p_cnt].person_id = dag.person_id, temp_reply->donorlist[p_cnt].ncopyind
        = 1
      ENDIF
     FOOT REPORT
      lstat = alterlist(temp_reply->donorlist,p_cnt)
     WITH nocounter
    ;end select
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("F","Select antigens.",errmsg)
    ENDIF
    IF (curqual=0)
     GO TO set_status
    ENDIF
   ENDIF
  ENDIF
  IF ((recruiting_list->contact_method_cd > 0.0))
   IF (size(temp_reply->donorlist,5) > 0)
    SELECT INTO "nl:"
     cm.contact_method_id
     FROM (dummyt d  WITH seq = value(size(temp_reply->donorlist,5))),
      bbd_contact_method cm
     PLAN (d
      WHERE d.seq <= size(temp_reply->donorlist,5)
       AND (temp_reply->donorlist[d.seq].ncopyind=1))
      JOIN (cm
      WHERE (cm.person_id=temp_reply->donorlist[d.seq].person_id)
       AND (cm.contact_method_cd=recruiting_list->contact_method_cd)
       AND cm.active_ind=1)
     ORDER BY d.seq
     HEAD REPORT
      CALL resettempreply(value(size(temp_reply->donorlist,5)))
     HEAD d.seq
      row + 0
     DETAIL
      temp_reply->donorlist[d.seq].ncopyind = 1
     FOOT  d.seq
      row + 0
     FOOT REPORT
      row + 0
     WITH nocounter
    ;end select
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("F","Select contact meths(D).",errmsg)
    ENDIF
    IF (isvalidtempreply(size(temp_reply->donorlist,5))=ninvalid)
     GO TO set_status
    ENDIF
   ELSE
    SELECT INTO "nl:"
     cm.contact_method_id
     FROM bbd_contact_method cm
     PLAN (cm
      WHERE (cm.contact_method_cd=recruiting_list->contact_method_cd)
       AND cm.active_ind=1)
     HEAD REPORT
      p_cnt = 0
     DETAIL
      p_cnt = (p_cnt+ 1)
      IF (size(temp_reply->donorlist,5) < p_cnt)
       lstat = alterlist(temp_reply->donorlist,(p_cnt+ 10))
      ENDIF
      temp_reply->donorlist[p_cnt].person_id = cm.person_id, temp_reply->donorlist[p_cnt].ncopyind =
      1
     FOOT REPORT
      lstat = alterlist(temp_reply->donorlist,p_cnt)
     WITH nocounter
    ;end select
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("F","Select contact meths.",errmsg)
    ENDIF
    IF (curqual=0)
     GO TO set_status
    ENDIF
   ENDIF
  ENDIF
  IF ((recruiting_list->preferred_donation_location_cd > 0.0))
   IF (size(temp_reply->donorlist,5) > 0)
    SELECT INTO "nl:"
     pd.person_id
     FROM (dummyt d  WITH seq = value(size(temp_reply->donorlist,5))),
      person_donor pd
     PLAN (d
      WHERE d.seq <= size(temp_reply->donorlist,5)
       AND (temp_reply->donorlist[d.seq].ncopyind=1))
      JOIN (pd
      WHERE (pd.person_id=temp_reply->donorlist[d.seq].person_id)
       AND (pd.preferred_donation_location_cd=recruiting_list->preferred_donation_location_cd)
       AND ((pd.last_donation_dt_tm < cnvtdatetime(obasedate)) OR (nullind(pd.last_donation_dt_tm)=1
      ))
       AND pd.eligibility_type_cd != dperm
       AND pd.active_ind=1)
     ORDER BY d.seq
     HEAD REPORT
      CALL resettempreply(value(size(temp_reply->donorlist,5)))
     HEAD d.seq
      row + 0
     DETAIL
      temp_reply->donorlist[d.seq].ncopyind = 1
     FOOT  d.seq
      row + 0
     FOOT REPORT
      row + 0
     WITH nocounter
    ;end select
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("F","Select location(D).",errmsg)
    ENDIF
    IF (isvalidtempreply(size(temp_reply->donorlist,5))=ninvalid)
     GO TO set_status
    ENDIF
   ELSE
    SELECT INTO "nl:"
     pd.person_id
     FROM person_donor pd
     PLAN (pd
      WHERE (pd.preferred_donation_location_cd=recruiting_list->preferred_donation_location_cd)
       AND ((pd.last_donation_dt_tm < cnvtdatetime(obasedate)) OR (nullind(pd.last_donation_dt_tm)=1
      ))
       AND pd.eligibility_type_cd != dperm
       AND pd.active_ind=1)
     HEAD REPORT
      p_cnt = 0
     DETAIL
      p_cnt = (p_cnt+ 1)
      IF (size(temp_reply->donorlist,5) < p_cnt)
       lstat = alterlist(temp_reply->donorlist,(p_cnt+ 10))
      ENDIF
      temp_reply->donorlist[p_cnt].person_id = pd.person_id, temp_reply->donorlist[p_cnt].ncopyind =
      1
     FOOT REPORT
      lstat = alterlist(temp_reply->donorlist,p_cnt)
     WITH nocounter
    ;end select
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("F","Select location.",errmsg)
    ENDIF
    IF (curqual=0)
     GO TO set_status
    ENDIF
   ENDIF
  ENDIF
  IF (size(temp_reply->donorlist,5) > 0)
   SELECT INTO "nl:"
    pd.person_id
    FROM (dummyt d  WITH seq = value(size(temp_reply->donorlist,5))),
     person_donor pd
    PLAN (d
     WHERE d.seq <= size(temp_reply->donorlist,5)
      AND (temp_reply->donorlist[d.seq].ncopyind=1))
     JOIN (pd
     WHERE (pd.person_id=temp_reply->donorlist[d.seq].person_id)
      AND ((pd.last_donation_dt_tm < cnvtdatetime(obasedate)) OR (nullind(pd.last_donation_dt_tm)=1
     ))
      AND pd.eligibility_type_cd != dperm
      AND pd.active_ind=1)
    ORDER BY d.seq
    HEAD REPORT
     CALL resettempreply(value(size(temp_reply->donorlist,5)))
    HEAD d.seq
     row + 0
    DETAIL
     IF (pd.eligibility_type_cd=dtemp)
      IF ((pd.defer_until_dt_tm <= recruiting_list->donation_dt_tm))
       temp_reply->donorlist[d.seq].ncopyind = 1
      ENDIF
     ELSE
      temp_reply->donorlist[d.seq].ncopyind = 1
     ENDIF
    FOOT  d.seq
     row + 0
    FOOT REPORT
     row + 0
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select elig donors(D).",errmsg)
   ENDIF
   IF (curqual=0)
    GO TO set_status
   ENDIF
  ELSE
   SELECT INTO "nl:"
    pd.person_id
    FROM person_donor pd
    WHERE ((pd.last_donation_dt_tm < cnvtdatetime(obasedate)) OR (nullind(pd.last_donation_dt_tm)=1
    ))
     AND pd.eligibility_type_cd != dperm
     AND pd.active_ind=1
    HEAD REPORT
     p_cnt = 0
    DETAIL
     p_cnt = (p_cnt+ 1)
     IF (size(temp_reply->donorlist,5) < p_cnt)
      lstat = alterlist(temp_reply->donorlist,(p_cnt+ 9))
     ENDIF
     IF (pd.eligibility_type_cd=dtemp)
      IF ((pd.defer_until_dt_tm <= recruiting_list->donation_dt_tm))
       temp_reply->donorlist[p_cnt].person_id = pd.person_id, temp_reply->donorlist[p_cnt].ncopyind
        = 1
      ENDIF
     ELSE
      temp_reply->donorlist[p_cnt].person_id = pd.person_id, temp_reply->donorlist[p_cnt].ncopyind =
      1
     ENDIF
    FOOT REPORT
     lstat = alterlist(temp_reply->donorlist,p_cnt)
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select elig donors.",errmsg)
   ENDIF
   IF (curqual=0)
    GO TO set_status
   ENDIF
  ENDIF
  IF ((((recruiting_list->abo_cd > 0.0)) OR ((recruiting_list->rh_cd > 0.0))) )
   IF (size(temp_reply->donorlist,5) > 0)
    SELECT
     IF ((recruiting_list->abo_cd > 0.0)
      AND (recruiting_list->rh_cd > 0.0))
      PLAN (d
       WHERE d.seq <= size(temp_reply->donorlist,5)
        AND (temp_reply->donorlist[d.seq].ncopyind=1))
       JOIN (da
       WHERE (da.person_id=temp_reply->donorlist[d.seq].person_id)
        AND ((da.abo_cd+ 0)=recruiting_list->abo_cd)
        AND ((da.rh_cd+ 0)=recruiting_list->rh_cd)
        AND da.active_ind=1)
      ORDER BY d.seq
     ELSEIF ((recruiting_list->abo_cd > 0.0)
      AND (recruiting_list->rh_cd=0.0))
      PLAN (d
       WHERE d.seq <= size(temp_reply->donorlist,5)
        AND (temp_reply->donorlist[d.seq].ncopyind=1))
       JOIN (da
       WHERE (da.person_id=temp_reply->donorlist[d.seq].person_id)
        AND ((da.abo_cd+ 0)=recruiting_list->abo_cd)
        AND da.active_ind=1)
      ORDER BY d.seq
     ELSE
      PLAN (d
       WHERE d.seq <= size(temp_reply->donorlist,5)
        AND (temp_reply->donorlist[d.seq].ncopyind=1))
       JOIN (da
       WHERE (da.person_id=temp_reply->donorlist[d.seq].person_id)
        AND ((da.rh_cd+ 0)=recruiting_list->rh_cd)
        AND da.active_ind=1)
      ORDER BY d.seq
     ENDIF
     INTO "nl:"
     da.person_id
     FROM (dummyt d  WITH seq = value(size(temp_reply->donorlist,5))),
      donor_aborh da
     HEAD REPORT
      CALL resettempreply(value(size(temp_reply->donorlist,5)))
     HEAD d.seq
      row + 0
     DETAIL
      temp_reply->donorlist[d.seq].ncopyind = 1
     FOOT  d.seq
      row + 0
     FOOT REPORT
      row + 0
     WITH nocounter
    ;end select
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("F","Select ABORh(D).",errmsg)
    ENDIF
    IF (curqual=0)
     GO TO set_status
    ENDIF
   ENDIF
  ENDIF
  IF ((recruiting_list->organization_id > 0.0))
   SELECT INTO "nl:"
    por.person_id
    FROM (dummyt d  WITH seq = value(size(temp_reply->donorlist,5))),
     person_org_reltn por
    PLAN (d
     WHERE d.seq <= size(temp_reply->donorlist,5)
      AND (temp_reply->donorlist[d.seq].ncopyind=1))
     JOIN (por
     WHERE (por.person_id=temp_reply->donorlist[d.seq].person_id)
      AND (por.organization_id=recruiting_list->organization_id)
      AND por.active_ind=1)
    ORDER BY d.seq
    HEAD REPORT
     CALL resettempreply(value(size(temp_reply->donorlist,5)))
    HEAD d.seq
     row + 0
    DETAIL
     temp_reply->donorlist[d.seq].ncopyind = 1
    FOOT  d.seq
     row + 0
    FOOT REPORT
     row + 0
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select organization(D).",errmsg)
   ENDIF
   IF (curqual=0)
    GO TO set_status
   ENDIF
  ENDIF
  IF ((recruiting_list->race_cd > 0.0))
   SELECT INTO "nl:"
    p.person_id
    FROM (dummyt d  WITH seq = value(size(temp_reply->donorlist,5))),
     person p
    PLAN (d
     WHERE d.seq <= size(temp_reply->donorlist,5)
      AND (temp_reply->donorlist[d.seq].ncopyind=1))
     JOIN (p
     WHERE (p.person_id=temp_reply->donorlist[d.seq].person_id)
      AND (p.race_cd=recruiting_list->race_cd)
      AND p.active_ind=1)
    ORDER BY d.seq
    HEAD REPORT
     CALL resettempreply(value(size(temp_reply->donorlist,5)))
    HEAD d.seq
     row + 0
    DETAIL
     temp_reply->donorlist[d.seq].ncopyind = 1
    FOOT  d.seq
     row + 0
    FOOT REPORT
     row + 0
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select race(D).",errmsg)
   ENDIF
   IF (curqual=0)
    GO TO set_status
   ENDIF
  ENDIF
  IF ((recruiting_list->last_outcome_cd > 0.0))
   SELECT INTO "nl:"
    bdc.person_id
    FROM (dummyt d  WITH seq = value(size(temp_reply->donorlist,5))),
     bbd_recruitment_rslts brr,
     bbd_donor_contact bdc
    PLAN (d
     WHERE d.seq <= size(temp_reply->donorlist,5)
      AND (temp_reply->donorlist[d.seq].ncopyind=1))
     JOIN (brr
     WHERE (brr.person_id=temp_reply->donorlist[d.seq].person_id)
      AND brr.active_ind=1)
     JOIN (bdc
     WHERE bdc.contact_id=brr.contact_id
      AND bdc.active_ind=1)
    ORDER BY bdc.person_id, bdc.contact_dt_tm DESC
    HEAD REPORT
     CALL resettempreply(value(size(temp_reply->donorlist,5)))
    HEAD d.seq
     row + 0
    HEAD bdc.person_id
     IF ((bdc.contact_outcome_cd=recruiting_list->last_outcome_cd))
      temp_reply->donorlist[d.seq].ncopyind = 1
     ENDIF
    DETAIL
     row + 0
    FOOT  bdc.person_id
     row + 0
    FOOT  d.seq
     row + 0
    FOOT REPORT
     row + 0
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select last outcome(D).",errmsg)
   ENDIF
   IF (isvalidtempreply(size(temp_reply->donorlist,5))=ninvalid)
    GO TO set_status
   ENDIF
  ENDIF
  IF (size(recruiting_list->zipcodes,5) > 0)
   FOR (lindex = 1 TO size(recruiting_list->zipcodes,5))
     SELECT INTO "nl:"
      a.parent_entity_id
      FROM (dummyt d  WITH seq = value(size(temp_reply->donorlist,5))),
       address a
      PLAN (d
       WHERE d.seq <= size(temp_reply->donorlist,5)
        AND (temp_reply->donorlist[d.seq].ncopyind=1))
       JOIN (a
       WHERE (a.parent_entity_id=temp_reply->donorlist[d.seq].person_id)
        AND (a.zipcode=recruiting_list->zipcodes[lindex].zip_code)
        AND (a.address_type_cd=recruiting_list->zipcodes[lindex].address_type_cd)
        AND a.active_ind=1)
      ORDER BY d.seq
      HEAD REPORT
       CALL resettempreply(value(size(temp_reply->donorlist,5)))
      HEAD d.seq
       row + 0
      DETAIL
       temp_reply->donorlist[d.seq].ncopyind = 1
      FOOT  d.seq
       row + 0
      FOOT REPORT
       row + 0
      WITH nocounter
     ;end select
     SET error_check = error(errmsg,0)
     IF (error_check != 0)
      CALL errorhandler("F","Select zipcode(D).",errmsg)
     ENDIF
     IF (curqual=0)
      GO TO set_status
     ENDIF
   ENDFOR
  ENDIF
  IF ((request->days_from_recruitment > 0))
   SET oqualifyingdttm = cnvtdatetime(curdate,0)
   SET oqualifyingdttm = datetimeadd(oqualifyingdttm,- (request->days_from_recruitment))
   SELECT INTO "nl:"
    brr.person_id
    FROM (dummyt d  WITH seq = value(size(temp_reply->donorlist,5))),
     (dummyt d2  WITH seq = 0),
     bbd_recruitment_rslts brr,
     bbd_donor_contact bdc
    PLAN (d
     WHERE d.seq <= size(temp_reply->donorlist,5)
      AND (temp_reply->donorlist[d.seq].ncopyind=1))
     JOIN (d2)
     JOIN (brr
     WHERE (brr.person_id=temp_reply->donorlist[d.seq].person_id)
      AND brr.active_ind=1)
     JOIN (bdc
     WHERE bdc.contact_id=brr.contact_id)
    ORDER BY bdc.person_id, bdc.contact_dt_tm DESC
    HEAD REPORT
     CALL resettempreply(value(size(temp_reply->donorlist,5)))
    HEAD d.seq
     row + 0
    HEAD bdc.person_id
     IF (bdc.contact_id > 0.0)
      IF (bdc.contact_dt_tm > oqualifyingdttm)
       temp_reply->donorlist[d.seq].ncopyind = 0
      ELSE
       temp_reply->donorlist[d.seq].ncopyind = 1
      ENDIF
     ENDIF
    DETAIL
     IF (bdc.contact_id=0.0)
      temp_reply->donorlist[d.seq].ncopyind = 1
     ENDIF
    FOOT  bdc.person_id
     row + 0
    FOOT  d.seq
     row + 0
    FOOT REPORT
     row + 0
    WITH nocounter, outerjoin = d2
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select QualifyDtTm.",errmsg)
   ENDIF
   IF (isvalidtempreply(size(temp_reply->donorlist,5))=ninvalid)
    GO TO set_status
   ENDIF
  ENDIF
  IF (lmaxdaysuntileligible > 0)
   SET oqualifyingdttm = datetimeadd(recruiting_list->donation_dt_tm,- (lmaxdaysuntileligible))
   SELECT INTO "nl:"
    bdr.person_id
    FROM (dummyt d  WITH seq = value(size(temp_reply->donorlist,5))),
     (dummyt d2  WITH seq = 0),
     bbd_donation_results bdr,
     bbd_don_product_r bdp,
     product p
    PLAN (d
     WHERE d.seq <= size(temp_reply->donorlist,5)
      AND (temp_reply->donorlist[d.seq].ncopyind=1))
     JOIN (d2)
     JOIN (bdr
     WHERE (bdr.person_id=temp_reply->donorlist[d.seq].person_id)
      AND bdr.drawn_dt_tm > cnvtdatetime(oqualifyingdttm)
      AND bdr.active_ind=1)
     JOIN (bdp
     WHERE bdp.donation_results_id=bdr.donation_result_id)
     JOIN (p
     WHERE p.product_id=bdp.product_id)
    ORDER BY bdr.person_id, p.product_cd
    HEAD REPORT
     CALL resettempreply(value(size(temp_reply->donorlist,5)))
    HEAD d.seq
     row + 0
    HEAD bdr.person_id
     alreadykickedout = 0
    DETAIL
     IF (alreadykickedout != 1)
      IF (bdr.donation_result_id > 0.0)
       index = locateval(indexvar,1,size(product_eligibility->product_list,5),p.product_cd,
        product_eligibility->product_list[indexvar].previous_product_cd), otempdate = datetimeadd(bdr
        .drawn_dt_tm,product_eligibility->product_list[index].days_until_eligible)
       IF (otempdate > oqualifyingdttm)
        temp_reply->donorlist[d.seq].ncopyind = 0, alreadykickedout = 1
       ELSE
        temp_reply->donorlist[d.seq].ncopyind = 1
       ENDIF
      ELSE
       temp_reply->donorlist[d.seq].ncopyind = 1
      ENDIF
     ENDIF
    FOOT  bdr.person_id
     row + 0
    FOOT  d.seq
     row + 0
    FOOT REPORT
     row + 0
    WITH nocounter, outerjoin = d2
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select Eligibility.",errmsg)
   ENDIF
   IF (isvalidtempreply(size(temp_reply->donorlist,5))=ninvalid)
    GO TO set_status
   ENDIF
  ENDIF
  IF ((recruiting_list->multiple_list_ind=0))
   SELECT INTO "nl:"
    rdr.list_id
    FROM (dummyt d  WITH seq = value(size(temp_reply->donorlist,5))),
     bbd_recruiting_donor_reltn rdr
    PLAN (d
     WHERE d.seq <= size(temp_reply->donorlist,5)
      AND (temp_reply->donorlist[d.seq].ncopyind=1))
     JOIN (rdr
     WHERE (rdr.person_id=temp_reply->donorlist[d.seq].person_id)
      AND rdr.active_ind=1)
    DETAIL
     temp_reply->donorlist[d.seq].ncopyind = 0
    WITH nocounter
   ;end select
   SET error_check = error(errmsg,0)
   IF (error_check != 0)
    CALL errorhandler("F","Select mult_list_ind.",errmsg)
   ENDIF
  ENDIF
  IF (size(temp_reply->donorlist,5) > 0)
   SET ncopycnt = 0
   FOR (lindex = 1 TO size(temp_reply->donorlist,5))
     IF ((temp_reply->donorlist[lindex].ncopyind=1)
      AND (temp_reply->donorlist[lindex].person_id > 0.0))
      SET ncopycnt = (ncopycnt+ 1)
      IF (size(reply->donorlist,5) < ncopycnt)
       IF ((((ncopycnt <= recruiting_list->max_donor_cnt)) OR ((recruiting_list->max_donor_cnt=0))) )
        SET lstat = alterlist(reply->donorlist,ncopycnt)
        SET reply->donorlist[ncopycnt].person_id = temp_reply->donorlist[lindex].person_id
       ENDIF
      ENDIF
     ENDIF
   ENDFOR
  ENDIF
  IF (size(reply->donorlist,5)=0)
   GO TO set_status
  ENDIF
  FOR (lindex = 1 TO size(reply->donorlist,5))
    SET dnewdonorreltnid = 0
    SELECT INTO "nl:"
     seqn = seq(pathnet_seq,nextval)
     FROM dual
     DETAIL
      dnewdonorreltnid = seqn
     WITH format, counter
    ;end select
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("F","Get new dNewDonorReltnID.",errmsg)
    ENDIF
    INSERT  FROM bbd_recruiting_donor_reltn rd
     SET rd.active_ind = 1, rd.active_status_cd = reqdata->active_status_cd, rd.active_status_dt_tm
       = cnvtdatetime(curdate,curtime3),
      rd.active_status_prsnl_id = reqinfo->updt_id, rd.contact_id = 0, rd.list_id = recruiting_list->
      list_id,
      rd.person_id = reply->donorlist[lindex].person_id, rd.recruiting_donor_reltn_id =
      dnewdonorreltnid, rd.updt_applctx = reqinfo->updt_applctx,
      rd.updt_cnt = 0, rd.updt_dt_tm = cnvtdatetime(curdate,curtime3), rd.updt_id = reqinfo->updt_id,
      rd.updt_task = reqinfo->updt_task
     WITH nocounter
    ;end insert
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("F","Insert dNewDonorReltnID.",errmsg)
    ENDIF
    SET reply->donorlist[lindex].donor_retln_id = dnewdonorreltnid
  ENDFOR
 ENDIF
 IF ((recruiting_list->multiple_list_ind=1))
  SELECT INTO "nl:"
   rdr.list_id, rl.display_name
   FROM (dummyt d  WITH seq = value(size(reply->donorlist,5))),
    bbd_recruiting_donor_reltn rdr,
    bbd_recruiting_list rl
   PLAN (d
    WHERE d.seq <= size(reply->donorlist,5))
    JOIN (rdr
    WHERE (rdr.person_id=reply->donorlist[d.seq].person_id)
     AND rdr.active_ind=1)
    JOIN (rl
    WHERE rl.list_id=rdr.list_id
     AND (rl.list_id != request->list_id)
     AND rl.active_ind=1)
   ORDER BY d.seq
   HEAD REPORT
    rl_cnt = 0
   HEAD d.seq
    rl_cnt = 0
   DETAIL
    rl_cnt = (rl_cnt+ 1)
    IF (size(reply->donorlist[d.seq].recruiting_lists,5) < rl_cnt)
     lstat = alterlist(reply->donorlist[d.seq].recruiting_lists,(rl_cnt+ 5))
    ENDIF
    reply->donorlist[d.seq].recruiting_lists[rl_cnt].list_id = rdr.list_id, reply->donorlist[d.seq].
    recruiting_lists[rl_cnt].list_name = rl.display_name
   FOOT  d.seq
    lstat = alterlist(reply->donorlist[d.seq].recruiting_lists,rl_cnt)
   FOOT REPORT
    row + 0
   WITH nocounter
  ;end select
  SET error_check = error(errmsg,0)
  IF (error_check != 0)
   CALL errorhandler("F","Get other lists.",errmsg)
  ENDIF
 ENDIF
 GO TO set_status
#get_single_donor_lists
 SET lstat = alterlist(reply->donorlist,1)
 SET reply->donorlist[1].person_id = request->person_id
 SELECT INTO "nl:"
  rdr.list_id, rl.display_name
  FROM bbd_recruiting_donor_reltn rdr,
   bbd_recruiting_list rl
  PLAN (rdr
   WHERE (rdr.person_id=request->person_id)
    AND rdr.active_ind=1)
   JOIN (rl
   WHERE rl.list_id=rdr.list_id
    AND rl.active_ind=1)
  HEAD REPORT
   rl_cnt = 0
  DETAIL
   rl_cnt = (rl_cnt+ 1)
   IF (size(reply->donorlist[1].recruiting_lists,5) < rl_cnt)
    lstat = alterlist(reply->donorlist[1].recruiting_lists,(rl_cnt+ 5))
   ENDIF
   reply->donorlist[1].recruiting_lists[rl_cnt].list_id = rdr.list_id, reply->donorlist[1].
   recruiting_lists[rl_cnt].list_name = rl.display_name
  FOOT REPORT
   lstat = alterlist(reply->donorlist[1].recruiting_lists,rl_cnt)
  WITH nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","Get single donor lists.",errmsg)
 ENDIF
 IF (curqual=0)
  SET lstat = alterlist(reply->donorlist,0)
 ENDIF
 GO TO set_status
 SUBROUTINE errorhandler(operationstatus,targetobjectname,targetobjectvalue)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt = (error_cnt+ 1)
    SET lstat = alterlist(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = script_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   SET reqinfo->commit_ind = 0
   GO TO exit_script
 END ;Subroutine
#set_status
 IF (size(reply->donorlist,5) > 0)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "Z"
  SET reqinfo->commit_ind = 0
 ENDIF
#exit_script
 FREE RECORD temp_reply
 FREE RECORD recruiting_list
 FREE RECORD product_eligibility
END GO
