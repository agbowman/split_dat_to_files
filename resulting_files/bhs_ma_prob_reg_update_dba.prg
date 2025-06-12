CREATE PROGRAM bhs_ma_prob_reg_update:dba
 FREE RECORD t_record
 RECORD t_record(
   1 person_cnt = i4
   1 person_qual[*]
     2 person_id = f8
     2 phys_id = f8
 )
 DECLARE pcp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",331,"PCP"))
 SELECT INTO "nl:"
  FROM bhs_problem_registry b,
   person_prsnl_reltn ppr,
   person p
  PLAN (b)
   JOIN (ppr
   WHERE ppr.person_id=b.person_id
    AND ppr.person_prsnl_r_cd=pcp_cd
    AND ppr.active_ind=1
    AND ppr.end_effective_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00"))
   JOIN (p
   WHERE p.person_id=ppr.prsnl_person_id
    AND p.name_last_key != "NOTONSTAFF"
    AND ((p.person_id+ 0) > 0))
  ORDER BY b.person_id, ppr.updt_dt_tm DESC
  HEAD b.person_id
   IF (ppr.prsnl_person_id != b.pcp_id
    AND b.reason != "Patient Expired")
    t_record->person_cnt = (t_record->person_cnt+ 1), stat = alterlist(t_record->person_qual,t_record
     ->person_cnt), t_record->person_qual[t_record->person_cnt].person_id = b.person_id,
    t_record->person_qual[t_record->person_cnt].phys_id = ppr.prsnl_person_id
   ENDIF
  WITH orahint("index(PPR XIE2PERSON_PRSNL_RELTN)")
 ;end select
 IF ((t_record->person_cnt > 0))
  UPDATE  FROM bhs_problem_registry b,
    (dummyt d  WITH seq = t_record->person_cnt)
   SET b.pcp_id = t_record->person_qual[d.seq].phys_id, b.active_ind = 1
   PLAN (d)
    JOIN (b
    WHERE (b.person_id=t_record->person_qual[d.seq].person_id))
   WITH nocounter
  ;end update
  COMMIT
 ENDIF
END GO
