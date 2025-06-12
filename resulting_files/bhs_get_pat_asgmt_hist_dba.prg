CREATE PROGRAM bhs_get_pat_asgmt_hist:dba
 RECORD temp(
   1 qual[*]
     2 person_id = f8
     2 name_full_formatted = vc
     2 position = c30
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
 )
 RECORD encntr_loc(
   1 qual[*]
     2 encntr_id = f8
     2 organization_id = f8
     2 confid_level = i4
     2 beg_dt_tm = dq8
     2 end_dt_tm = dq8
     2 loc_facility_cd = f8
     2 loc_building_cd = f8
     2 loc_nurse_unit_cd = f8
     2 loc_room_cd = f8
     2 loc_bed_cd = f8
 )
 SET reply2->status_data.status = "F"
 SET encntr_org_sec_ind = 0
 SET confid_ind = 0
 SET security_ind = 0
 SET cnt = 0
 SET el_cnt = 0
 SET rep_cnt = 0
 SET temp_cnt = 0
 IF (validate(ccldminfo->mode,0))
  SET encntr_org_sec_ind = ccldminfo->sec_org_reltn
  SET confid_ind = ccldminfo->sec_confid
  IF (((encntr_org_sec_ind) OR (confid_ind)) )
   SET security_ind = 1
  ENDIF
 ELSE
  SELECT INTO "nl:"
   FROM dm_info di
   PLAN (di
    WHERE di.info_domain="SECURITY"
     AND di.info_name IN ("SEC_ORG_RELTN", "SEC_CONFID"))
   DETAIL
    IF (di.info_name="SEC_ORG_RELTN"
     AND di.info_number=1)
     encntr_org_sec_ind = 1, security_ind = 1
    ELSEIF (di.info_name="SEC_CONFID"
     AND di.info_number=1)
     confid_ind = 1, security_ind = 1
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  ed.encntr_id, cv1.collation_seq
  FROM encntr_domain ed,
   encounter e,
   encntr_loc_hist elh,
   code_value cv1,
   code_value cv2,
   prsnl_org_reltn por
  PLAN (ed
   WHERE (ed.encntr_id=request2->encntrid)
    AND ed.end_effective_dt_tm > cnvtdatetime(request2->beg_dt_tm)
    AND ed.beg_effective_dt_tm < cnvtdatetime(request2->end_dt_tm))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id)
   JOIN (cv1
   WHERE cv1.code_value=e.confid_level_cd)
   JOIN (por
   WHERE ((security_ind=1
    AND (por.person_id=request2->prsnl_id)
    AND por.organization_id=e.organization_id
    AND por.active_ind=1
    AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND por.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (security_ind=0
    AND por.person_id=0)) )
   JOIN (cv2
   WHERE cv2.code_value=por.confid_level_cd)
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND ((confid_ind=0) OR (confid_ind=1
    AND cv2.collation_seq >= cv1.collation_seq))
    AND elh.end_effective_dt_tm > cnvtdatetime(request2->beg_dt_tm)
    AND elh.beg_effective_dt_tm < cnvtdatetime(request2->end_dt_tm))
  ORDER BY elh.encntr_id, elh.end_effective_dt_tm
  HEAD REPORT
   el_cnt = 0
  HEAD elh.encntr_id
   set_one = 0
  HEAD elh.encntr_loc_hist_id
   IF (((set_one=0) OR ((((encntr_loc->qual[el_cnt].loc_facility_cd != elh.loc_facility_cd)) OR ((((
   encntr_loc->qual[el_cnt].loc_building_cd != elh.loc_building_cd)) OR ((((encntr_loc->qual[el_cnt].
   loc_nurse_unit_cd != elh.loc_nurse_unit_cd)) OR ((((encntr_loc->qual[el_cnt].loc_room_cd != elh
   .loc_room_cd)) OR ((encntr_loc->qual[el_cnt].loc_bed_cd != elh.loc_bed_cd))) )) )) )) )) )
    set_one = 1, el_cnt = (el_cnt+ 1), stat = alterlist(encntr_loc->qual,el_cnt),
    encntr_loc->qual[el_cnt].encntr_id = elh.encntr_id, encntr_loc->qual[el_cnt].confid_level = cv1
    .collation_seq, encntr_loc->qual[el_cnt].organization_id = e.organization_id
    IF ((elh.beg_effective_dt_tm < request2->beg_dt_tm))
     encntr_loc->qual[el_cnt].beg_dt_tm = request2->beg_dt_tm
    ELSE
     encntr_loc->qual[el_cnt].beg_dt_tm = elh.beg_effective_dt_tm
    ENDIF
    IF ((elh.end_effective_dt_tm > request2->end_dt_tm))
     encntr_loc->qual[el_cnt].end_dt_tm = request2->end_dt_tm
    ELSE
     encntr_loc->qual[el_cnt].end_dt_tm = elh.end_effective_dt_tm
    ENDIF
    encntr_loc->qual[el_cnt].loc_facility_cd = elh.loc_facility_cd, encntr_loc->qual[el_cnt].
    loc_building_cd = elh.loc_building_cd, encntr_loc->qual[el_cnt].loc_nurse_unit_cd = elh
    .loc_nurse_unit_cd,
    encntr_loc->qual[el_cnt].loc_room_cd = elh.loc_room_cd, encntr_loc->qual[el_cnt].loc_bed_cd = elh
    .loc_bed_cd
   ELSE
    IF ((elh.end_effective_dt_tm > request2->end_dt_tm))
     encntr_loc->qual[el_cnt].end_dt_tm = request2->end_dt_tm
    ELSE
     encntr_loc->qual[el_cnt].end_dt_tm = elh.end_effective_dt_tm
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF (el_cnt=0)
  GO TO exit_prg
 ENDIF
 SELECT INTO "nl:"
  sa.assignment_id, ctp.careteam_id, p1.person_id,
  por.prsnl_org_reltn_id, cv.code_value
  FROM (dummyt d1  WITH seq = value(el_cnt)),
   dcp_shift_assignment sa,
   dcp_care_team_prsnl ctp,
   prsnl p1,
   prsnl_org_reltn por,
   code_value cv
  PLAN (d1)
   JOIN (sa
   WHERE (((((sa.loc_facility_cd=encntr_loc->qual[d1.seq].loc_facility_cd)) OR (sa.loc_facility_cd=0
   ))
    AND (((sa.loc_building_cd=encntr_loc->qual[d1.seq].loc_building_cd)) OR (sa.loc_building_cd=0))
    AND (((sa.loc_unit_cd=encntr_loc->qual[d1.seq].loc_nurse_unit_cd)) OR (sa.loc_unit_cd=0))
    AND (((sa.loc_room_cd=encntr_loc->qual[d1.seq].loc_room_cd)) OR (sa.loc_room_cd=0))
    AND (((sa.loc_bed_cd=encntr_loc->qual[d1.seq].loc_bed_cd)) OR (sa.loc_bed_cd=0))
    AND sa.person_id=0) OR ((((sa.loc_facility_cd=encntr_loc->qual[d1.seq].loc_facility_cd)) OR (sa
   .loc_facility_cd=0))
    AND (((sa.loc_building_cd=encntr_loc->qual[d1.seq].loc_building_cd)) OR (sa.loc_building_cd=0))
    AND (((sa.loc_unit_cd=encntr_loc->qual[d1.seq].loc_nurse_unit_cd)) OR (sa.loc_unit_cd=0))
    AND (sa.person_id=request2->patient_id)))
    AND sa.end_effective_dt_tm >= cnvtdatetime(encntr_loc->qual[d1.seq].beg_dt_tm)
    AND sa.beg_effective_dt_tm <= cnvtdatetime(encntr_loc->qual[d1.seq].end_dt_tm)
    AND (sa.assignment_group_cd=request2->assignment_group_cd)
    AND (sa.assignment_pos_cd=request2->assignment_pos_cd))
   JOIN (ctp
   WHERE ctp.careteam_id=sa.careteam_id)
   JOIN (p1
   WHERE ((ctp.careteam_id > 0
    AND p1.person_id=ctp.prsnl_id
    AND (p1.position_cd=request2->assignment_pos_cd)) OR (ctp.careteam_id=0
    AND p1.person_id=sa.prsnl_id
    AND (p1.position_cd=request2->assignment_pos_cd))) )
   JOIN (por
   WHERE ((security_ind=1
    AND por.person_id=p1.person_id
    AND (por.organization_id=encntr_loc->qual[d1.seq].organization_id)
    AND por.active_ind=1
    AND por.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND por.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)) OR (security_ind=0
    AND por.person_id=0)) )
   JOIN (cv
   WHERE cv.code_value=por.confid_level_cd
    AND ((confid_ind=0) OR ((cv.collation_seq >= encntr_loc->qual[d1.seq].confid_level))) )
  DETAIL
   temp_cnt = (temp_cnt+ 1), stat = alterlist(temp->qual,temp_cnt), temp->qual[temp_cnt].person_id =
   p1.person_id,
   temp->qual[temp_cnt].name_full_formatted = p1.name_full_formatted, temp->qual[temp_cnt].position
    = uar_get_code_display(p1.position_cd), temp->qual[temp_cnt].beg_dt_tm = sa.beg_effective_dt_tm,
   temp->qual[temp_cnt].end_dt_tm = sa.end_effective_dt_tm
   IF ((ctp.end_effective_dt_tm < temp->qual[temp_cnt].end_dt_tm)
    AND ctp.prsnl_id != 0)
    temp->qual[temp_cnt].end_dt_tm = ctp.end_effective_dt_tm
   ENDIF
   IF ((encntr_loc->qual[d1.seq].end_dt_tm < temp->qual[temp_cnt].end_dt_tm)
    AND (request2->end_dt_tm != encntr_loc->qual[d1.seq].end_dt_tm))
    temp->qual[temp_cnt].end_dt_tm = encntr_loc->qual[d1.seq].end_dt_tm
   ENDIF
   IF ((ctp.beg_effective_dt_tm > temp->qual[temp_cnt].beg_dt_tm)
    AND ctp.prsnl_id != 0)
    temp->qual[temp_cnt].beg_dt_tm = ctp.beg_effective_dt_tm
   ENDIF
   IF ((encntr_loc->qual[d1.seq].beg_dt_tm > temp->qual[temp_cnt].beg_dt_tm)
    AND (encntr_loc->qual[d1.seq].beg_dt_tm != request2->beg_dt_tm))
    temp->qual[temp_cnt].beg_dt_tm = encntr_loc->qual[d1.seq].beg_dt_tm
   ENDIF
  WITH nocounter
 ;end select
 IF (temp_cnt != 0)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(temp_cnt))
   WHERE d1.seq > 0
   ORDER BY temp->qual[d1.seq].beg_dt_tm, temp->qual[d1.seq].end_dt_tm, temp->qual[d1.seq].person_id
   HEAD REPORT
    first_one = 1, rep_cnt = 0
   DETAIL
    IF (((first_one=1) OR ((((temp->qual[d1.seq].person_id != reply2->qual[rep_cnt].person_id)) OR (
    (((temp->qual[d1.seq].beg_dt_tm != reply2->qual[rep_cnt].beg_dt_tm)) OR ((temp->qual[d1.seq].
    end_dt_tm != reply2->qual[rep_cnt].end_dt_tm))) )) )) )
     first_one = 0, rep_cnt = (rep_cnt+ 1), stat = alterlist(reply2->qual,rep_cnt),
     reply2->qual[rep_cnt].person_id = temp->qual[d1.seq].person_id, reply2->qual[rep_cnt].
     name_full_formatted = temp->qual[d1.seq].name_full_formatted, reply2->qual[rep_cnt].beg_dt_tm =
     temp->qual[d1.seq].beg_dt_tm,
     reply2->qual[rep_cnt].end_dt_tm = temp->qual[d1.seq].end_dt_tm, reply2->qual[rep_cnt].position
      = temp->qual[d1.seq].position
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#exit_prg
 IF (rep_cnt=0)
  SET reply2->status_data.status = "Z"
 ELSE
  SET reply2->status_data.status = "S"
 ENDIF
 CALL echorecord(reply2)
 SET script_version = "003 07/28/04 RR4690"
END GO
