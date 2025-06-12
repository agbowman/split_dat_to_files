CREATE PROGRAM bhs_athn_get_careteam_members
 RECORD out_rec(
   1 members[*]
     2 member = vc
     2 member_type = vc
     2 role = vc
     2 service = vc
     2 team = vc
     2 facility = vc
     2 phone[*]
       3 phone_number = vc
       3 phone_type = vc
 )
 DECLARE person_id = f8
 DECLARE cnt = i4
 DECLARE p_cnt = i4
 SELECT INTO "nl:"
  FROM dcp_shift_assignment dsa,
   prsnl pr,
   phone ph
  PLAN (dsa
   WHERE (dsa.encntr_id= $2)
    AND dsa.prsnl_id > 0
    AND dsa.end_effective_dt_tm > sysdate)
   JOIN (pr
   WHERE pr.person_id=dsa.prsnl_id)
   JOIN (ph
   WHERE ph.parent_entity_id=outerjoin(pr.person_id)
    AND ph.active_ind=outerjoin(1)
    AND ph.end_effective_dt_tm > outerjoin(sysdate))
  ORDER BY dsa.assignment_id, ph.beg_effective_dt_tm
  HEAD REPORT
   person_id = dsa.person_id
  HEAD dsa.assignment_id
   cnt = (cnt+ 1), stat = alterlist(out_rec->members,cnt), out_rec->members[cnt].member = pr
   .name_full_formatted,
   out_rec->members[cnt].member_type = "Personnel", out_rec->members[cnt].role = uar_get_code_display
   (dsa.assigned_reltn_type_cd), p_cnt = 0
  DETAIL
   p_cnt = (p_cnt+ 1), stat = alterlist(out_rec->members[cnt].phone,p_cnt), out_rec->members[cnt].
   phone[p_cnt].phone_number = ph.phone_num,
   out_rec->members[cnt].phone[p_cnt].phone_type = uar_get_code_display(ph.phone_type_cd)
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM dcp_shift_assignment dsa,
   person p,
   phone ph
  PLAN (dsa
   WHERE (dsa.encntr_id= $2)
    AND dsa.related_person_id > 0
    AND dsa.end_effective_dt_tm > sysdate)
   JOIN (p
   WHERE p.person_id=dsa.related_person_id)
   JOIN (ph
   WHERE ph.parent_entity_id=outerjoin(p.person_id)
    AND ph.active_ind=outerjoin(1)
    AND ph.end_effective_dt_tm > outerjoin(sysdate))
  ORDER BY dsa.assignment_id, ph.beg_effective_dt_tm
  HEAD dsa.assignment_id
   cnt = (cnt+ 1), stat = alterlist(out_rec->members,cnt), out_rec->members[cnt].member = p
   .name_full_formatted,
   out_rec->members[cnt].member_type = "Non-Provider", out_rec->members[cnt].role =
   uar_get_code_display(dsa.assigned_reltn_type_cd), p_cnt = 0
  DETAIL
   p_cnt = (p_cnt+ 1), stat = alterlist(out_rec->members[cnt].phone,p_cnt), out_rec->members[cnt].
   phone[p_cnt].phone_number = ph.phone_num,
   out_rec->members[cnt].phone[p_cnt].phone_type = uar_get_code_display(ph.phone_type_cd)
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM dcp_shift_assignment dsa,
   pct_care_team pct
  PLAN (dsa
   WHERE (dsa.encntr_id= $2)
    AND dsa.pct_care_team_id > 0
    AND dsa.end_effective_dt_tm > sysdate)
   JOIN (pct
   WHERE pct.pct_care_team_id=dsa.pct_care_team_id)
  ORDER BY dsa.assignment_id
  HEAD dsa.assignment_id
   cnt = (cnt+ 1), stat = alterlist(out_rec->members,cnt), out_rec->members[cnt].role =
   uar_get_code_display(pct.pct_med_service_cd),
   out_rec->members[cnt].member = uar_get_code_display(pct.pct_med_service_cd), out_rec->members[cnt]
   .member_type = "Care Team", out_rec->members[cnt].service = uar_get_code_display(pct
    .pct_med_service_cd)
   IF (pct.pct_team_cd > 0)
    out_rec->members[cnt].team = uar_get_code_display(pct.pct_team_cd), out_rec->members[cnt].member
     = uar_get_code_display(pct.pct_team_cd), out_rec->members[cnt].role = concat(trim(
      uar_get_code_display(pct.pct_med_service_cd)),"|",trim(uar_get_code_display(pct.pct_team_cd)))
   ENDIF
   out_rec->members[cnt].facility = uar_get_code_display(pct.facility_cd)
   IF (pct.facility_cd=0)
    out_rec->members[cnt].facility = "All Facilities"
   ENDIF
  WITH nocounter, time = 30
 ;end select
 SELECT INTO "nl:"
  FROM person_prsnl_reltn ppr,
   prsnl pr,
   phone ph
  PLAN (ppr
   WHERE ppr.person_id=person_id
    AND ppr.end_effective_dt_tm > sysdate)
   JOIN (pr
   WHERE pr.person_id=ppr.prsnl_person_id)
   JOIN (ph
   WHERE ph.parent_entity_id=outerjoin(pr.person_id)
    AND ph.active_ind=outerjoin(1)
    AND ph.end_effective_dt_tm > outerjoin(sysdate))
  ORDER BY ppr.person_prsnl_reltn_id
  HEAD ppr.person_prsnl_reltn_id
   cnt = (cnt+ 1), stat = alterlist(out_rec->members,cnt), out_rec->members[cnt].member = pr
   .name_full_formatted,
   out_rec->members[cnt].member_type = "Personnel", out_rec->members[cnt].role = uar_get_code_display
   (ppr.person_prsnl_r_cd), p_cnt = 0
  DETAIL
   p_cnt = (p_cnt+ 1), stat = alterlist(out_rec->members[cnt].phone,p_cnt), out_rec->members[cnt].
   phone[p_cnt].phone_number = ph.phone_num,
   out_rec->members[cnt].phone[p_cnt].phone_type = uar_get_code_display(ph.phone_type_cd)
  WITH nocounter, time = 30
 ;end select
 CALL echojson(out_rec, $1)
END GO
