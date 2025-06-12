CREATE PROGRAM diabetes_prompts:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Choose the type of report" = 0,
  "Goals" = 0,
  "Choose a physician" = 0,
  "Choose a practice" = 0,
  "Enter an email address(es) separated by a space" = ""
  WITH outdev, type, goals,
  pcp, group, email
 EXECUTE bhs_sys_stand_subroutine
 FREE RECORD t_record
 RECORD t_record(
   1 two_year_date = dq8
   1 name = vc
   1 meds_cnt = i4
   1 meds_qual[*]
     2 catalog_cd = f8
   1 pat_cnt = i4
   1 pat_qual[*]
     2 org = vc
     2 org_key = vc
     2 phys_id = f8
     2 person_id = f8
     2 practice_id = f8
     2 name = vc
     2 mrn = vc
     2 dob = dq8
     2 street1 = vc
     2 street2 = vc
     2 street3 = vc
     2 street4 = vc
     2 city = vc
     2 state = vc
     2 zip = vc
     2 problem_ind = i2
     2 lab_ind = i2
     2 med_ind = i2
     2 last_visit_dt_tm = dq8
     2 last_visit_encntr_id = f8
     2 hgb_a1c_dt_tm = dq8
     2 hgb_a1c_val = vc
     2 bp_dt_tm = dq8
     2 sys_bp_val = vc
     2 dia_bp_val = vc
     2 ldl_dt_tm = dq8
     2 ldl_val = vc
     2 microalb_dt_tm = dq8
     2 microalb_val = vc
     2 ace_arb_ind = i2
     2 pneu_vac_dt_tm = dq8
     2 flu_vac_dt_tm = dq8
     2 asprin_ind = i2
     2 hm_foot_dt_tm = dq8
     2 hm_retinal_dt_tm = dq8
 )
 DECLARE mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,"MRN"))
 DECLARE glucose_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"GLUCOSELEVEL"))
 DECLARE hemo_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"HEMOGLOBINA1C"))
 DECLARE sys_bp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURE"))
 DECLARE dia_bp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURE"))
 DECLARE ldl_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"LDLCHOLESTEROL"))
 DECLARE microalb_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"MICROALBUMIN"))
 DECLARE pneu_vac_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOCOCCALVACCINE"))
 DECLARE flu_vac_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "INFLUENZAVIRUSVACCINE"))
 DECLARE aspirin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ASPIRIN"))
 DECLARE ace_arb_med1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"VALSARTAN"))
 DECLARE ace_arb_med2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"TRANDOLAPRIL")
  )
 DECLARE ace_arb_med3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"IRBESARTAN"))
 DECLARE ace_arb_med4_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"TELMISARTAN"))
 DECLARE ace_arb_med5_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"OLMESARTAN"))
 DECLARE ace_arb_med6_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"EPROSARTAN"))
 DECLARE ace_arb_med7_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"CANDESARTAN"))
 DECLARE ace_arb_med8_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"LOSARTAN"))
 DECLARE ace_arb_med9_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"PERINDOPRIL"))
 DECLARE ace_arb_med10_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"QUINAPRIL"))
 DECLARE ace_arb_med11_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"RAMIPRIL"))
 DECLARE ace_arb_med12_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"MOEXIPRIL"))
 DECLARE ace_arb_med13_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"LISINOPRIL"))
 DECLARE ace_arb_med14_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"FOSINOPRIL"))
 DECLARE ace_arb_med15_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ENALAPRIL"))
 DECLARE ace_arb_med16_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"CAPTOPRIL"))
 DECLARE ace_arb_med17_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"BENAZEPRIL"))
 DECLARE ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE on_hold_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ONHOLDMEDSTUDENT")
  )
 DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"PENDINGCOMPLETE"))
 DECLARE pending_rev_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"PENDINGREVIEW"
   ))
 DECLARE in_process_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"INPROCESS"))
 DECLARE future_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"FUTURE"))
 DECLARE t_line = vc
 DECLARE l_line = vc
 DECLARE p_line = vc
 DECLARE problem = vc
 DECLARE lab = vc
 DECLARE med = vc
 DECLARE asprin = vc
 DECLARE ace_arb = vc
 DECLARE address = vc
 DECLARE dclcom = vc
 DECLARE goals_ind = i2
 SET goals_ind =  $GOALS
 DECLARE indx = i4 WITH protect, noconstant(0)
 DECLARE nsize = i4 WITH protect, noconstant(0)
 DECLARE nbucketsize = i4 WITH protect, noconstant(0)
 DECLARE ntotal = i4 WITH protect, noconstant(0)
 DECLARE nstart = i4 WITH protect, noconstant(0)
 DECLARE nbuckets = i4 WITH protect, noconstant(0)
 SET t_record->two_year_date = cnvtdatetime(datetimeadd(cnvtdatetime(curdate,curtime3),- (730)))
 IF (( $TYPE=0))
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   DETAIL
    col 0, "You did not select a report type. Choose a report type."
   WITH nocounter
  ;end select
  GO TO exit_script
 ELSEIF (( $TYPE=1))
  IF (( $PCP=0))
   SELECT INTO  $OUTDEV
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    DETAIL
     col 0, "You did not select a physician. Choose a physician."
    WITH nocounter
   ;end select
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM person p
   PLAN (p
    WHERE (p.person_id= $PCP)
     AND p.active_ind=1)
   DETAIL
    t_record->name = trim(p.name_full_formatted)
  ;end select
  SET l_line = concat("b.pcp_id = ",trim(cnvtstring( $PCP)))
  SET p_line = concat("sa1.person_id = ",trim(cnvtstring( $PCP)))
 ELSEIF (( $TYPE=2))
  IF (( $GROUP=0))
   SELECT INTO  $OUTDEV
    FROM (dummyt d  WITH seq = 1)
    PLAN (d)
    DETAIL
     col 0, "You did not select a practice. Choose a practice."
    WITH nocounter
   ;end select
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM organization o,
    location l,
    bhs_problem_registry b
   PLAN (o
    WHERE (o.organization_id= $GROUP))
    JOIN (l
    WHERE l.organization_id=o.organization_id
     AND l.active_ind=1)
    JOIN (b
    WHERE b.practice_id=l.location_cd)
   ORDER BY l.location_cd
   HEAD REPORT
    t_record->name = o.org_name, l_line = "b.practice_id in ( ", first_ind = 0
   HEAD l.location_cd
    IF (first_ind=0)
     l_line = concat(l_line,trim(cnvtstring(l.location_cd))), first_ind = 1
    ELSE
     l_line = concat(l_line,",",trim(cnvtstring(l.location_cd)))
    ENDIF
   FOOT REPORT
    l_line = concat(l_line,")")
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM bhs_problem_registry b
   PLAN (b
    WHERE parser(l_line))
   ORDER BY b.pcp_id
   HEAD REPORT
    p_line = "sa1.person_id in ( ", first_ind = 0
   HEAD b.pcp_id
    IF (first_ind=0)
     p_line = concat(p_line,trim(cnvtstring(b.pcp_id))), first_ind = 1
    ELSE
     p_line = concat(p_line,",",trim(cnvtstring(b.pcp_id)))
    ENDIF
   FOOT REPORT
    p_line = concat(p_line,")")
   WITH nocounter
  ;end select
 ENDIF
 IF (findstring("@", $EMAIL)=0)
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   DETAIL
    col 0, "Enter a valid email address."
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 FREE DEFINE rtl2
 DEFINE rtl2 "diabetes_meds.dat"
 SELECT INTO "nl:"
  FROM rtl2t m,
   order_catalog_synonym ocs
  PLAN (m)
   JOIN (ocs
   WHERE ocs.mnemonic_key_cap=m.line)
  DETAIL
   t_record->meds_cnt = (t_record->meds_cnt+ 1)
   IF (mod(t_record->meds_cnt,100)=1)
    stat = alterlist(t_record->meds_qual,(t_record->meds_cnt+ 99))
   ENDIF
   idx = t_record->meds_cnt, t_record->meds_qual[idx].catalog_cd = ocs.catalog_cd
  FOOT REPORT
   stat = alterlist(t_record->meds_qual,t_record->meds_cnt)
  WITH nocounter
 ;end select
 DECLARE med_string = vc
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->meds_cnt)
  PLAN (d)
  DETAIL
   IF (d.seq=1)
    med_string = trim(cnvtstring(t_record->meds_qual[d.seq].catalog_cd))
   ELSE
    med_string = concat(med_string,",",trim(cnvtstring(t_record->meds_qual[d.seq].catalog_cd)))
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(t_record->meds_qual,0)
 SET med_string = concat("o.catalog_cd in (",med_string,")")
 SELECT INTO "nl:"
  FROM bhs_problem_registry b
  PLAN (b
   WHERE parser(l_line)
    AND b.active_ind=1
    AND b.problem="DIABETES")
  DETAIL
   t_record->pat_cnt = (t_record->pat_cnt+ 1)
   IF (mod(t_record->pat_cnt,1000)=1)
    stat = alterlist(t_record->pat_qual,(t_record->pat_cnt+ 999))
   ENDIF
   idx = t_record->pat_cnt, t_record->pat_qual[idx].person_id = b.person_id, t_record->pat_qual[idx].
   phys_id = b.pcp_id,
   t_record->pat_qual[idx].practice_id = b.practice_id
  FOOT REPORT
   stat = alterlist(t_record->pat_qual,t_record->pat_cnt)
  WITH maxcol = 1000
 ;end select
 SET nsize = t_record->pat_cnt
 SET nbucketsize = 40
 SET ntotal = (ceil((cnvtreal(nsize)/ nbucketsize)) * nbucketsize)
 SET nstart = 1
 SET nbuckets = value((1+ ((ntotal - 1)/ nbucketsize)))
 SET stat = alterlist(t_record->pat_qual,ntotal)
 FOR (j = (nsize+ 1) TO ntotal)
   SET t_record->pat_qual[j].person_id = t_record->pat_qual[nsize].person_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   person p,
   person_alias pa,
   address a,
   bhs_problem_registry b,
   location l,
   organization o
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (p
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),p.person_id,t_record->pat_qual[indx].
    person_id)
    AND p.active_ind=1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=mrn_cd
    AND pa.active_ind=1
    AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (a
   WHERE a.parent_entity_id=outerjoin(p.person_id)
    AND a.parent_entity_name=outerjoin("PERSON"))
   JOIN (b
   WHERE b.person_id=p.person_id
    AND b.problem="DIABETES")
   JOIN (l
   WHERE l.location_cd=b.practice_id)
   JOIN (o
   WHERE o.organization_id=l.organization_id)
  ORDER BY p.person_id, pa.active_status_dt_tm DESC
  HEAD p.person_id
   done = 0, idx = locateval(indx,1,t_record->pat_cnt,p.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx].org_key = o.org_name_key,
   t_record->pat_qual[idx].org = o.org_name, t_record->pat_qual[idx].name = p.name_full_formatted,
   t_record->pat_qual[idx].dob = p.birth_dt_tm,
   t_record->pat_qual[idx].street1 = a.street_addr, t_record->pat_qual[idx].street2 = a.street_addr2,
   t_record->pat_qual[idx].street3 = a.street_addr3,
   t_record->pat_qual[idx].street4 = a.street_addr4, t_record->pat_qual[idx].state = a.state,
   t_record->pat_qual[idx].city = a.city,
   t_record->pat_qual[idx].zip = a.zipcode
  HEAD pa.active_status_dt_tm
   IF (done=0)
    IF (pa.alias != "RAD*")
     t_record->pat_qual[idx].mrn = pa.alias, done = 1
    ENDIF
   ENDIF
  WITH orahint("index(pa XIE2PERSON_ALIAS)")
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   problem p,
   bhs_nomen_list n
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (p
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),p.person_id,t_record->pat_qual[indx].
    person_id))
   JOIN (n
   WHERE n.nomenclature_id=p.nomenclature_id)
  ORDER BY p.person_id
  HEAD p.person_id
   idx1 = locateval(indx,1,t_record->pat_cnt,p.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx1].problem_ind = 1
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   diagnosis dg,
   bhs_nomen_list n
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (dg
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),dg.person_id,t_record->pat_qual[indx].
    person_id))
   JOIN (n
   WHERE n.nomenclature_id=dg.nomenclature_id)
  ORDER BY dg.person_id
  HEAD dg.person_id
   idx1 = locateval(indx,1,t_record->pat_cnt,dg.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx1].problem_ind = 1
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   sch_appt sa,
   sch_appt sa1
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (sa
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),sa.person_id,t_record->pat_qual[indx].
    person_id)
    AND sa.state_meaning="CHECKED IN"
    AND sa.role_meaning="PATIENT")
   JOIN (sa1
   WHERE sa1.schedule_id=sa.schedule_id
    AND parser(p_line)
    AND sa1.state_meaning="CHECKED IN"
    AND sa1.role_meaning="RESOURCE")
  ORDER BY sa.person_id, sa.beg_dt_tm DESC
  HEAD sa.person_id
   idx1 = locateval(indx,1,t_record->pat_cnt,sa.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx1].last_visit_dt_tm = cnvtdatetime(sa.beg_dt_tm), t_record->pat_qual[idx1].
   last_visit_encntr_id = sa.encntr_id
  WITH orahint("index(sa XIE97SCH_APPT)")
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   clinical_event ce
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (ce
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),ce.person_id,t_record->pat_qual[indx].
    person_id)
    AND ce.event_cd=glucose_cd
    AND ce.clinsig_updt_dt_tm >= cnvtdatetime(t_record->two_year_date))
  ORDER BY ce.person_id
  HEAD ce.person_id
   idx1 = locateval(indx,1,t_record->pat_cnt,ce.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx1].lab_ind = 1
  WITH orahint("index(CE XIE9CLINICAL_EVENT)")
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   clinical_event ce
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (ce
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),ce.person_id,t_record->pat_qual[indx].
    person_id)
    AND ce.event_cd=hemo_cd
    AND ce.clinsig_updt_dt_tm >= cnvtdatetime(t_record->two_year_date))
  ORDER BY ce.person_id, ce.clinsig_updt_dt_tm DESC
  HEAD ce.person_id
   idx1 = locateval(indx,1,t_record->pat_cnt,ce.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx1].lab_ind = 1, t_record->pat_qual[idx1].hgb_a1c_dt_tm = cnvtdatetime(ce
    .clinsig_updt_dt_tm),
   t_record->pat_qual[idx1].hgb_a1c_val = ce.result_val
  WITH orahint("index(CE XIE9CLINICAL_EVENT)")
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   clinical_event ce
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (ce
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),ce.encntr_id,t_record->pat_qual[indx].
    last_visit_encntr_id)
    AND ce.event_cd IN (sys_bp_cd, dia_bp_cd))
  ORDER BY ce.person_id, ce.event_cd, ce.clinsig_updt_dt_tm DESC
  HEAD ce.person_id
   idx = locateval(indx,1,t_record->pat_cnt,ce.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx].bp_dt_tm = cnvtdatetime(ce.clinsig_updt_dt_tm)
  HEAD ce.event_cd
   IF (ce.event_cd=sys_bp_cd)
    t_record->pat_qual[idx].sys_bp_val = ce.result_val
   ELSEIF (ce.event_cd=dia_bp_cd)
    t_record->pat_qual[idx].dia_bp_val = ce.result_val
   ENDIF
  WITH orahint("index(CE FK10CLINICAL_EVENT)")
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   clinical_event ce
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (ce
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),ce.person_id,t_record->pat_qual[indx].
    person_id)
    AND ce.event_cd=ldl_cd)
  ORDER BY ce.person_id, ce.clinsig_updt_dt_tm DESC
  HEAD ce.person_id
   idx = locateval(indx,1,t_record->pat_cnt,ce.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx].ldl_dt_tm = cnvtdatetime(ce.clinsig_updt_dt_tm), t_record->pat_qual[idx].
   ldl_val = ce.result_val
  WITH orahint("index(CE XIE9CLINICAL_EVENT)")
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   clinical_event ce
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (ce
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),ce.person_id,t_record->pat_qual[indx].
    person_id)
    AND ce.event_cd=microalb_cd)
  ORDER BY ce.person_id, ce.clinsig_updt_dt_tm DESC
  HEAD ce.person_id
   idx = locateval(indx,1,t_record->pat_cnt,ce.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx].microalb_dt_tm = cnvtdatetime(ce.clinsig_updt_dt_tm), t_record->pat_qual[
   idx].microalb_val = ce.result_val
  WITH orahint("index(CE XIE9CLINICAL_EVENT)")
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   clinical_event ce
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (ce
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),ce.person_id,t_record->pat_qual[indx].
    person_id)
    AND ce.event_cd=pneu_vac_cd)
  ORDER BY ce.person_id, ce.clinsig_updt_dt_tm DESC
  HEAD ce.person_id
   idx = locateval(indx,1,t_record->pat_cnt,ce.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx].pneu_vac_dt_tm = cnvtdatetime(ce.clinsig_updt_dt_tm)
  WITH orahint("index(CE XIE9CLINICAL_EVENT)")
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   clinical_event ce
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (ce
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),ce.person_id,t_record->pat_qual[indx].
    person_id)
    AND ce.event_cd=flu_vac_cd)
  ORDER BY ce.person_id, ce.clinsig_updt_dt_tm DESC
  HEAD ce.person_id
   idx = locateval(indx,1,t_record->pat_cnt,ce.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx].flu_vac_dt_tm = cnvtdatetime(ce.clinsig_updt_dt_tm)
  WITH orahint("index(CE XIE9CLINICAL_EVENT)")
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   orders o
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (o
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),o.person_id,t_record->pat_qual[indx].
    person_id)
    AND parser(med_string)
    AND o.order_status_cd IN (ordered_cd, on_hold_cd, pending_cd, pending_rev_cd, in_process_cd,
   future_cd))
  DETAIL
   idx = locateval(indx,1,t_record->pat_cnt,o.person_id,t_record->pat_qual[indx].person_id), t_record
   ->pat_qual[idx].med_ind = 1
  WITH orahint("index(O XIE99ORDERS)")
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   orders o
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (o
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),o.person_id,t_record->pat_qual[indx].
    person_id)
    AND o.catalog_cd=aspirin_cd
    AND o.order_status_cd IN (ordered_cd, on_hold_cd, pending_cd, pending_rev_cd, in_process_cd,
   future_cd))
  DETAIL
   idx = locateval(indx,1,t_record->pat_cnt,o.person_id,t_record->pat_qual[indx].person_id), t_record
   ->pat_qual[idx].asprin_ind = 1
  WITH orahint("index(O XIE99ORDERS)")
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   orders o
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (o
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),o.person_id,t_record->pat_qual[indx].
    person_id)
    AND o.catalog_cd IN (ace_arb_med1_cd, ace_arb_med2_cd, ace_arb_med3_cd, ace_arb_med4_cd,
   ace_arb_med5_cd,
   ace_arb_med6_cd, ace_arb_med7_cd, ace_arb_med8_cd, ace_arb_med9_cd, ace_arb_med10_cd,
   ace_arb_med11_cd, ace_arb_med12_cd, ace_arb_med13_cd, ace_arb_med14_cd, ace_arb_med15_cd,
   ace_arb_med16_cd, ace_arb_med17_cd)
    AND o.order_status_cd IN (ordered_cd, on_hold_cd, pending_cd, pending_rev_cd, in_process_cd,
   future_cd))
  DETAIL
   idx = locateval(indx,1,t_record->pat_cnt,o.person_id,t_record->pat_qual[indx].person_id), t_record
   ->pat_qual[idx].ace_arb_ind = 1
  WITH orahint("index(O XIE99ORDERS)")
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   hm_expect_mod hem,
   hm_expect_step hes
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (hem
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),hem.person_id,t_record->pat_qual[indx].
    person_id)
    AND hem.parent_entity_name="HM_EXPECT_STEP")
   JOIN (hes
   WHERE hes.expect_step_id=hem.parent_entity_id
    AND hes.step_meaning="Diabetes Vision Screening")
  ORDER BY hem.person_id, hem.updt_dt_tm DESC
  HEAD hem.person_id
   idx = locateval(indx,1,t_record->pat_cnt,hem.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx].hm_retinal_dt_tm = cnvtdatetime(hem.updt_dt_tm)
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   hm_expect_mod hem,
   hm_expect_step hes
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (hem
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),hem.person_id,t_record->pat_qual[indx].
    person_id)
    AND hem.parent_entity_name="HM_EXPECT_STEP")
   JOIN (hes
   WHERE hes.expect_step_id=hem.parent_entity_id
    AND hes.step_meaning="Diabetes Comprehensive Foot Exam")
  ORDER BY hem.person_id, hem.updt_dt_tm DESC
  HEAD hem.person_id
   idx = locateval(indx,1,t_record->pat_cnt,hem.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx].hm_foot_dt_tm = cnvtdatetime(hem.updt_dt_tm)
  WITH maxcol = 1000
 ;end select
 IF (( $TYPE=1))
  SELECT INTO "diabetes_registry.xls"
   name = t_record->pat_qual[d.seq].name, id = t_record->pat_qual[d.seq].person_id
   FROM (dummyt d  WITH seq = t_record->pat_cnt)
   PLAN (d)
   ORDER BY name, id
   HEAD REPORT
    t_line = concat("Diabetes Registry for ",t_record->name), col 0, t_line,
    row + 1, t_line = concat(char(9),char(9),char(9),"Diagnosis Ctiteria",char(9),
     char(9),char(9),char(9),"Hb A1c (Goal <7.0)",char(9),
     char(9),"BP (Goal <130/80)",char(9),char(9),char(9),
     "LDL (Goal <100)",char(9),char(9),"Microalbumin (Goal Malb/cr<30)",char(9)), col 0,
    t_line, row + 1, t_line = concat("Patient Name",char(9),"Medical Record #",char(9),
     "Date of Birth",
     char(9),"Diabetes on Problem List",char(9),"Lab",char(9),
     "Med",char(9),"Last office visit with PCP",char(9),"Date",
     char(9),"Value",char(9),"Date",char(9),
     "SBP Value",char(9),"DBP Value",char(9),"Date",
     char(9),"Value",char(9),"Date",char(9),
     "Value",char(9),"ACE/ ARB",char(9),"Pneumo-coccal Vaccine",
     char(9),"ASA",char(9),"Influenza Vaccine",char(9),
     "Comp. foot exam",char(9),"Dilated retinal exam",char(9),"Street Address",
     char(9),"City",char(9),"State",char(9),
     "Zip Code",char(9)),
    col 0, t_line, row + 1
   HEAD name
    null
   HEAD id
    IF (goals_ind=1)
     IF ((t_record->pat_qual[d.seq].problem_ind=1))
      problem = "yes"
     ELSE
      problem = "no"
     ENDIF
     IF ((t_record->pat_qual[d.seq].lab_ind=1))
      lab = "yes"
     ELSE
      lab = "no"
     ENDIF
     IF ((t_record->pat_qual[d.seq].med_ind=1))
      med = "yes"
     ELSE
      med = "no"
     ENDIF
     IF ((t_record->pat_qual[d.seq].asprin_ind=1))
      asprin = "yes"
     ELSE
      asprin = "no"
     ENDIF
     IF ((t_record->pat_qual[d.seq].ace_arb_ind=1))
      ace_arb = "yes"
     ELSE
      ace_arb = "no"
     ENDIF
     address = trim(concat(t_record->pat_qual[d.seq].street1," ",t_record->pat_qual[d.seq].street2,
       " ",t_record->pat_qual[d.seq].street3,
       " ",t_record->pat_qual[d.seq].street4)), t_line = concat(t_record->pat_qual[d.seq].name,char(9
       ),t_record->pat_qual[d.seq].mrn,char(9),format(t_record->pat_qual[d.seq].dob,"mm/dd/yyyy;;q"),
      char(9),problem,char(9),lab,char(9),
      med,char(9),format(t_record->pat_qual[d.seq].last_visit_dt_tm,"mm/dd/yyyy;;q"),char(9),format(
       t_record->pat_qual[d.seq].hgb_a1c_dt_tm,"mm/dd/yyyy;;q"),
      char(9),t_record->pat_qual[d.seq].hgb_a1c_val,char(9),format(t_record->pat_qual[d.seq].bp_dt_tm,
       "mm/dd/yyyy;;q"),char(9),
      t_record->pat_qual[d.seq].sys_bp_val,char(9),t_record->pat_qual[d.seq].dia_bp_val,char(9),
      format(t_record->pat_qual[d.seq].ldl_dt_tm,"mm/dd/yyyy;;q"),
      char(9),t_record->pat_qual[d.seq].ldl_val,char(9),format(t_record->pat_qual[d.seq].
       microalb_dt_tm,"mm/dd/yyyy;;q"),char(9),
      t_record->pat_qual[d.seq].microalb_val,char(9),ace_arb,char(9),format(t_record->pat_qual[d.seq]
       .pneu_vac_dt_tm,"mm/dd/yyyy;;q"),
      char(9),asprin,char(9),format(t_record->pat_qual[d.seq].flu_vac_dt_tm,"mm/dd/yyyy;;q"),char(9),
      format(t_record->pat_qual[d.seq].hm_foot_dt_tm,"mm/dd/yyyy;;q"),char(9),format(t_record->
       pat_qual[d.seq].hm_retinal_dt_tm,"mm/dd/yyyy;;q"),char(9),address,
      char(9),t_record->pat_qual[d.seq].city,char(9),t_record->pat_qual[d.seq].state,char(9),
      t_record->pat_qual[d.seq].zip,char(9)), col 0,
     t_line, row + 1
    ELSE
     IF (((cnvtint(t_record->pat_qual[d.seq].hgb_a1c_val) > 7) OR (((cnvtint(t_record->pat_qual[d.seq
      ].ldl_val) > 100) OR (((cnvtint(t_record->pat_qual[d.seq].sys_bp_val) > 130) OR (((cnvtint(
      t_record->pat_qual[d.seq].dia_bp_val) > 80) OR (cnvtint(t_record->pat_qual[d.seq].microalb_val)
      > 30)) )) )) )) )
      IF ((t_record->pat_qual[d.seq].problem_ind=1))
       problem = "yes"
      ELSE
       problem = "no"
      ENDIF
      IF ((t_record->pat_qual[d.seq].lab_ind=1))
       lab = "yes"
      ELSE
       lab = "no"
      ENDIF
      IF ((t_record->pat_qual[d.seq].med_ind=1))
       med = "yes"
      ELSE
       med = "no"
      ENDIF
      IF ((t_record->pat_qual[d.seq].asprin_ind=1))
       asprin = "yes"
      ELSE
       asprin = "no"
      ENDIF
      IF ((t_record->pat_qual[d.seq].ace_arb_ind=1))
       ace_arb = "yes"
      ELSE
       ace_arb = "no"
      ENDIF
      address = trim(concat(t_record->pat_qual[d.seq].street1," ",t_record->pat_qual[d.seq].street2,
        " ",t_record->pat_qual[d.seq].street3,
        " ",t_record->pat_qual[d.seq].street4)), t_line = concat(t_record->pat_qual[d.seq].name,char(
        9),t_record->pat_qual[d.seq].mrn,char(9),format(t_record->pat_qual[d.seq].dob,"mm/dd/yyyy;;q"
        ),
       char(9),problem,char(9),lab,char(9),
       med,char(9),format(t_record->pat_qual[d.seq].last_visit_dt_tm,"mm/dd/yyyy;;q"),char(9),format(
        t_record->pat_qual[d.seq].hgb_a1c_dt_tm,"mm/dd/yyyy;;q"),
       char(9),t_record->pat_qual[d.seq].hgb_a1c_val,char(9),format(t_record->pat_qual[d.seq].
        bp_dt_tm,"mm/dd/yyyy;;q"),char(9),
       t_record->pat_qual[d.seq].sys_bp_val,char(9),t_record->pat_qual[d.seq].dia_bp_val,char(9),
       format(t_record->pat_qual[d.seq].ldl_dt_tm,"mm/dd/yyyy;;q"),
       char(9),t_record->pat_qual[d.seq].ldl_val,char(9),format(t_record->pat_qual[d.seq].
        microalb_dt_tm,"mm/dd/yyyy;;q"),char(9),
       t_record->pat_qual[d.seq].microalb_val,char(9),ace_arb,char(9),format(t_record->pat_qual[d.seq
        ].pneu_vac_dt_tm,"mm/dd/yyyy;;q"),
       char(9),asprin,char(9),format(t_record->pat_qual[d.seq].flu_vac_dt_tm,"mm/dd/yyyy;;q"),char(9),
       format(t_record->pat_qual[d.seq].hm_foot_dt_tm,"mm/dd/yyyy;;q"),char(9),format(t_record->
        pat_qual[d.seq].hm_retinal_dt_tm,"mm/dd/yyyy;;q"),char(9),address,
       char(9),t_record->pat_qual[d.seq].city,char(9),t_record->pat_qual[d.seq].state,char(9),
       t_record->pat_qual[d.seq].zip,char(9)), col 0,
      t_line, row + 1
     ENDIF
    ENDIF
   WITH nocounter, maxcol = 1000, formfeed = none
  ;end select
 ELSEIF (( $TYPE=2))
  SELECT INTO "diabetes_registry.xls"
   name = t_record->pat_qual[d.seq].name, id = t_record->pat_qual[d.seq].person_id
   FROM (dummyt d  WITH seq = t_record->pat_cnt),
    bhs_problem_registry b,
    person p
   PLAN (d)
    JOIN (b
    WHERE (b.person_id=t_record->pat_qual[d.seq].person_id))
    JOIN (p
    WHERE p.person_id=b.pcp_id)
   ORDER BY name, id
   HEAD REPORT
    t_line = concat("Diabetes Registry for ",t_record->name), col 0, t_line,
    row + 1, t_line = concat(char(9),char(9),char(9),char(9),"Diagnosis Ctiteria",
     char(9),char(9),char(9),char(9),"Hb A1c (Goal <7.0)",
     char(9),char(9),"BP (Goal <130/80)",char(9),char(9),
     char(9),"LDL (Goal <100)",char(9),char(9),"Microalbumin (Goal Malb/cr<30)",
     char(9)), col 0,
    t_line, row + 1, t_line = concat("Patient Name",char(9),"Medical Record #",char(9),
     "Date of Birth",
     char(9),"PCP",char(9),"Diabetes on Problem List",char(9),
     "Lab",char(9),"Med",char(9),"Last office visit with PCP",
     char(9),"Date",char(9),"Value",char(9),
     "Date",char(9),"SBP Value",char(9),"DBP Value",
     char(9),"Date",char(9),"Value",char(9),
     "Date",char(9),"Value",char(9),"ACE/ ARB",
     char(9),"Pneumo-coccal Vaccine",char(9),"ASA",char(9),
     "Influenza Vaccine",char(9),"Comp. foot exam",char(9),"Dilated retinal exam",
     char(9),"Street Address",char(9),"City",char(9),
     "State",char(9),"Zip Code",char(9)),
    col 0, t_line, row + 1
   HEAD name
    null
   HEAD id
    IF (goals_ind=1)
     IF ((t_record->pat_qual[d.seq].problem_ind=1))
      problem = "yes"
     ELSE
      problem = "no"
     ENDIF
     IF ((t_record->pat_qual[d.seq].lab_ind=1))
      lab = "yes"
     ELSE
      lab = "no"
     ENDIF
     IF ((t_record->pat_qual[d.seq].med_ind=1))
      med = "yes"
     ELSE
      med = "no"
     ENDIF
     IF ((t_record->pat_qual[d.seq].asprin_ind=1))
      asprin = "yes"
     ELSE
      asprin = "no"
     ENDIF
     IF ((t_record->pat_qual[d.seq].ace_arb_ind=1))
      ace_arb = "yes"
     ELSE
      ace_arb = "no"
     ENDIF
     address = trim(concat(t_record->pat_qual[d.seq].street1," ",t_record->pat_qual[d.seq].street2,
       " ",t_record->pat_qual[d.seq].street3,
       " ",t_record->pat_qual[d.seq].street4)), t_line = concat(t_record->pat_qual[d.seq].name,char(9
       ),t_record->pat_qual[d.seq].mrn,char(9),format(t_record->pat_qual[d.seq].dob,"mm/dd/yyyy;;q"),
      char(9),p.name_full_formatted,char(9),problem,char(9),
      lab,char(9),med,char(9),format(t_record->pat_qual[d.seq].last_visit_dt_tm,"mm/dd/yyyy;;q"),
      char(9),format(t_record->pat_qual[d.seq].hgb_a1c_dt_tm,"mm/dd/yyyy;;q"),char(9),t_record->
      pat_qual[d.seq].hgb_a1c_val,char(9),
      format(t_record->pat_qual[d.seq].bp_dt_tm,"mm/dd/yyyy;;q"),char(9),t_record->pat_qual[d.seq].
      sys_bp_val,char(9),t_record->pat_qual[d.seq].dia_bp_val,
      char(9),format(t_record->pat_qual[d.seq].ldl_dt_tm,"mm/dd/yyyy;;q"),char(9),t_record->pat_qual[
      d.seq].ldl_val,char(9),
      format(t_record->pat_qual[d.seq].microalb_dt_tm,"mm/dd/yyyy;;q"),char(9),t_record->pat_qual[d
      .seq].microalb_val,char(9),ace_arb,
      char(9),format(t_record->pat_qual[d.seq].pneu_vac_dt_tm,"mm/dd/yyyy;;q"),char(9),asprin,char(9),
      format(t_record->pat_qual[d.seq].flu_vac_dt_tm,"mm/dd/yyyy;;q"),char(9),format(t_record->
       pat_qual[d.seq].hm_foot_dt_tm,"mm/dd/yyyy;;q"),char(9),format(t_record->pat_qual[d.seq].
       hm_retinal_dt_tm,"mm/dd/yyyy;;q"),
      char(9),address,char(9),t_record->pat_qual[d.seq].city,char(9),
      t_record->pat_qual[d.seq].state,char(9),t_record->pat_qual[d.seq].zip,char(9)), col 0,
     t_line, row + 1
    ELSE
     IF (((cnvtint(t_record->pat_qual[d.seq].hgb_a1c_val) > 7) OR (((cnvtint(t_record->pat_qual[d.seq
      ].ldl_val) > 100) OR (((cnvtint(t_record->pat_qual[d.seq].sys_bp_val) > 130) OR (((cnvtint(
      t_record->pat_qual[d.seq].dia_bp_val) > 80) OR (cnvtint(t_record->pat_qual[d.seq].microalb_val)
      > 30)) )) )) )) )
      IF ((t_record->pat_qual[d.seq].problem_ind=1))
       problem = "yes"
      ELSE
       problem = "no"
      ENDIF
      IF ((t_record->pat_qual[d.seq].lab_ind=1))
       lab = "yes"
      ELSE
       lab = "no"
      ENDIF
      IF ((t_record->pat_qual[d.seq].med_ind=1))
       med = "yes"
      ELSE
       med = "no"
      ENDIF
      IF ((t_record->pat_qual[d.seq].asprin_ind=1))
       asprin = "yes"
      ELSE
       asprin = "no"
      ENDIF
      IF ((t_record->pat_qual[d.seq].ace_arb_ind=1))
       ace_arb = "yes"
      ELSE
       ace_arb = "no"
      ENDIF
      address = trim(concat(t_record->pat_qual[d.seq].street1," ",t_record->pat_qual[d.seq].street2,
        " ",t_record->pat_qual[d.seq].street3,
        " ",t_record->pat_qual[d.seq].street4)), t_line = concat(t_record->pat_qual[d.seq].name,char(
        9),t_record->pat_qual[d.seq].mrn,char(9),format(t_record->pat_qual[d.seq].dob,"mm/dd/yyyy;;q"
        ),
       char(9),p.name_full_formatted,char(9),problem,char(9),
       lab,char(9),med,char(9),format(t_record->pat_qual[d.seq].last_visit_dt_tm,"mm/dd/yyyy;;q"),
       char(9),format(t_record->pat_qual[d.seq].hgb_a1c_dt_tm,"mm/dd/yyyy;;q"),char(9),t_record->
       pat_qual[d.seq].hgb_a1c_val,char(9),
       format(t_record->pat_qual[d.seq].bp_dt_tm,"mm/dd/yyyy;;q"),char(9),t_record->pat_qual[d.seq].
       sys_bp_val,char(9),t_record->pat_qual[d.seq].dia_bp_val,
       char(9),format(t_record->pat_qual[d.seq].ldl_dt_tm,"mm/dd/yyyy;;q"),char(9),t_record->
       pat_qual[d.seq].ldl_val,char(9),
       format(t_record->pat_qual[d.seq].microalb_dt_tm,"mm/dd/yyyy;;q"),char(9),t_record->pat_qual[d
       .seq].microalb_val,char(9),ace_arb,
       char(9),format(t_record->pat_qual[d.seq].pneu_vac_dt_tm,"mm/dd/yyyy;;q"),char(9),asprin,char(9
        ),
       format(t_record->pat_qual[d.seq].flu_vac_dt_tm,"mm/dd/yyyy;;q"),char(9),format(t_record->
        pat_qual[d.seq].hm_foot_dt_tm,"mm/dd/yyyy;;q"),char(9),format(t_record->pat_qual[d.seq].
        hm_retinal_dt_tm,"mm/dd/yyyy;;q"),
       char(9),address,char(9),t_record->pat_qual[d.seq].city,char(9),
       t_record->pat_qual[d.seq].state,char(9),t_record->pat_qual[d.seq].zip,char(9)), col 0,
      t_line, row + 1
     ENDIF
    ENDIF
   WITH nocounter, maxcol = 1000, formfeed = none
  ;end select
 ENDIF
 IF (findfile("diabetes_registry.xls")=1)
  SET email_list =  $EMAIL
  SET subject_line = "Diabetes Registry"
  CALL emailfile("diabetes_registry.xls","diabetes_registry.xls",email_list,subject_line,1)
  SET t_line = concat("The report was emailed to ",email_list)
  SELECT INTO  $OUTDEV
   FROM (dummyt d  WITH seq = 1)
   PLAN (d)
   DETAIL
    col 0, t_line
   WITH nocounter
  ;end select
 ENDIF
#exit_script
END GO
