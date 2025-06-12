CREATE PROGRAM bhs_diabetes_resistry_rpt:dba
 EXECUTE bhs_sys_stand_subroutine
 FREE RECORD t_record
 RECORD t_record(
   1 two_year_date = dq8
   1 pcp_id = f8
   1 diab_cnt = i4
   1 diab_qual[*]
     2 source_identifier = vc
   1 diab_cnt2 = i4
   1 diab_qual2[*]
     2 source_identifier = vc
   1 nomen_cnt = i4
   1 nomen_qual[*]
     2 nomen_id = f8
   1 meds_cnt = i4
   1 meds_qual[*]
     2 catalog_cd = f8
   1 pat_cnt = i4
   1 pat_qual[*]
     2 person_id = f8
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
 DECLARE indx = i2 WITH protect, noconstant(0)
 DECLARE nsize = i4 WITH protect, noconstant(0)
 DECLARE nbucketsize = i4 WITH protect, noconstant(0)
 DECLARE ntotal = i4 WITH protect, noconstant(0)
 DECLARE nstart = i4 WITH protect, noconstant(0)
 DECLARE nbuckets = i4 WITH protect, noconstant(0)
 DECLARE t_line = vc
 DECLARE problem = vc
 DECLARE lab = vc
 DECLARE med = vc
 DECLARE asprin = vc
 DECLARE ace_arb = vc
 SET t_record->two_year_date = cnvtdatetime(datetimeadd(cnvtdatetime(curdate,curtime3),- (730)))
 SET t_record->pcp_id = 749878.00
 FREE DEFINE rtl2
 DEFINE rtl2 "diabetes_codes.dat"
 SELECT INTO "nl:"
  FROM rtl2t m
  HEAD REPORT
   line_count = 0
  DETAIL
   t_len = size(m.line), line_count = (line_count+ 1), t_record->diab_cnt = (t_record->diab_cnt+ 1),
   idx = t_record->diab_cnt, stat = alterlist(t_record->diab_qual,idx), t_record->diab_qual[idx].
   source_identifier = substring(1,t_len,m.line)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  code = t_record->diab_qual[d.seq].source_identifier
  FROM (dummyt d  WITH seq = t_record->diab_cnt)
  PLAN (d)
  ORDER BY code
  HEAD code
   t_record->diab_cnt2 = (t_record->diab_cnt2+ 1), stat = alterlist(t_record->diab_qual2,t_record->
    diab_cnt2), t_record->diab_qual2[t_record->diab_cnt2].source_identifier = t_record->diab_qual[d
   .seq].source_identifier
  WITH nocounter
 ;end select
 SET stat = alterlist(t_record->diab_qual,0)
 SET t_record->diab_cnt = 0
 SELECT INTO "nl:"
  code = t_record->diab_qual2[d.seq].source_identifier
  FROM (dummyt d  WITH seq = t_record->diab_cnt2)
  PLAN (d)
  ORDER BY code
  HEAD code
   t_record->diab_cnt = (t_record->diab_cnt+ 1), stat = alterlist(t_record->diab_qual,t_record->
    diab_cnt), t_record->diab_qual[t_record->diab_cnt].source_identifier = cnvtupper(trim(t_record->
     diab_qual2[d.seq].source_identifier))
  WITH nocounter
 ;end select
 SET stat = alterlist(t_record->diab_qual2,0)
 SELECT INTO TABLE diab_codes
  source_identifier = t_record->diab_qual[d.seq].source_identifier
  FROM (dummyt d  WITH seq = t_record->diab_cnt)
  PLAN (d)
  WITH nocounter
 ;end select
 SET stat = alterlist(t_record->diab_qual,0)
 SELECT INTO "nl:"
  FROM diab_codes d,
   nomenclature n
  PLAN (d)
   JOIN (n
   WHERE n.source_identifier_keycap=d.source_identifier)
  ORDER BY d.source_identifier
  HEAD d.source_identifier
   t_record->nomen_cnt = (t_record->nomen_cnt+ 1), idx = t_record->nomen_cnt, stat = alterlist(
    t_record->nomen_qual,idx),
   t_record->nomen_qual[idx].nomen_id = n.nomenclature_id
  WITH nocounter
 ;end select
 SELECT INTO TABLE nomen_ids
  nomen_id = t_record->nomen_qual[d.seq].nomen_id
  FROM (dummyt d  WITH seq = t_record->nomen_cnt)
  PLAN (d)
  WITH nocounter
 ;end select
 SET stat = alterlist(t_record->nomen_qual,0)
 FREE DEFINE rtl2
 DEFINE rtl2 "diabetes_meds.dat"
 SELECT INTO "nl:"
  FROM rtl2t m,
   order_catalog_synonym ocs
  PLAN (m)
   JOIN (ocs
   WHERE ocs.mnemonic_key_cap=m.line)
  DETAIL
   t_record->meds_cnt = (t_record->meds_cnt+ 1), idx = t_record->meds_cnt, stat = alterlist(t_record
    ->meds_qual,idx),
   t_record->meds_qual[idx].catalog_cd = ocs.catalog_cd
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
  FROM bhs_diabetes_registry_1 b,
   person p,
   person_alias pa,
   address a
  PLAN (b
   WHERE (b.pcp_id=t_record->pcp_id)
    AND b.active_ind=1)
   JOIN (p
   WHERE p.person_id=b.person_id
    AND b.active_ind=1)
   JOIN (pa
   WHERE pa.person_id=p.person_id
    AND pa.person_alias_type_cd=mrn_cd
    AND pa.active_ind=1)
   JOIN (a
   WHERE a.parent_entity_id=outerjoin(p.person_id)
    AND a.parent_entity_name=outerjoin("PERSON"))
  ORDER BY p.name_full_formatted
  HEAD p.name_full_formatted
   t_record->pat_cnt = (t_record->pat_cnt+ 1), stat = alterlist(t_record->pat_qual,t_record->pat_cnt),
   idx = t_record->pat_cnt,
   t_record->pat_qual[idx].person_id = p.person_id, t_record->pat_qual[idx].name = p
   .name_full_formatted, t_record->pat_qual[idx].mrn = pa.alias,
   t_record->pat_qual[idx].dob = p.birth_dt_tm, t_record->pat_qual[idx].street1 = a.street_addr,
   t_record->pat_qual[idx].street2 = a.street_addr2,
   t_record->pat_qual[idx].street3 = a.street_addr3, t_record->pat_qual[idx].street4 = a.street_addr4,
   t_record->pat_qual[idx].state = a.state,
   t_record->pat_qual[idx].city = a.city, t_record->pat_qual[idx].zip = a.zipcode
  WITH maxcol = 1000
 ;end select
 SET nsize = t_record->pat_cnt
 SET nbucketsize = 200
 SET ntotal = (ceil((cnvtreal(nsize)/ nbucketsize)) * nbucketsize)
 SET nstart = 1
 SET nbuckets = value((1+ ((ntotal - 1)/ nbucketsize)))
 SET stat = alterlist(t_record->pat_qual,ntotal)
 FOR (j = (nsize+ 1) TO ntotal)
   SET t_record->pat_qual[j].person_id = t_record->pat_qual[nsize].person_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   problem p,
   nomen_ids n
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (p
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),p.person_id,t_record->pat_qual[indx].
    person_id))
   JOIN (n
   WHERE n.nomen_id=p.nomenclature_id)
  ORDER BY p.person_id
  HEAD p.person_id
   idx1 = locateval(indx,1,t_record->pat_cnt,p.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx1].problem_ind = 1
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   diagnosis dg,
   nomen_ids n
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (dg
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),dg.person_id,t_record->pat_qual[indx].
    person_id))
   JOIN (n
   WHERE n.nomen_id=dg.nomenclature_id)
  ORDER BY dg.person_id
  HEAD dg.person_id
   idx1 = locateval(indx,1,t_record->pat_cnt,dg.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx1].problem_ind = 1
  WITH maxcol = 1000
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
   orders o
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (o
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),o.person_id,t_record->pat_qual[indx].
    person_id)
    AND parser(med_string)
    AND o.order_status_cd IN (ordered_cd, on_hold_cd, pending_cd, pending_rev_cd, in_process_cd,
   future_cd))
  ORDER BY o.person_id
  HEAD o.person_id
   idx1 = locateval(indx,1,t_record->pat_cnt,o.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx1].med_ind = 1
  WITH orahint("index(O XIE3ORDERS)")
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
    AND (sa1.person_id=t_record->pcp_id)
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
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),ce.encntr_id,t_record->pat_qual[indx].
    last_visit_encntr_id)
    AND ce.event_cd=sys_bp_cd)
  ORDER BY ce.person_id, ce.clinsig_updt_dt_tm DESC
  HEAD ce.person_id
   idx1 = locateval(indx,1,t_record->pat_cnt,ce.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx1].bp_dt_tm = cnvtdatetime(ce.clinsig_updt_dt_tm), t_record->pat_qual[idx1].
   sys_bp_val = ce.result_val
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   clinical_event ce
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (ce
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),ce.encntr_id,t_record->pat_qual[indx].
    last_visit_encntr_id)
    AND ce.event_cd=dia_bp_cd)
  ORDER BY ce.person_id, ce.clinsig_updt_dt_tm DESC
  HEAD ce.person_id
   idx1 = locateval(indx,1,t_record->pat_cnt,ce.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx1].dia_bp_val = ce.result_val
  WITH maxcol = 1000
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
   idx1 = locateval(indx,1,t_record->pat_cnt,ce.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx1].ldl_dt_tm = cnvtdatetime(ce.clinsig_updt_dt_tm), t_record->pat_qual[idx1]
   .ldl_val = ce.result_val
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
   idx1 = locateval(indx,1,t_record->pat_cnt,ce.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx1].microalb_dt_tm = cnvtdatetime(ce.clinsig_updt_dt_tm), t_record->pat_qual[
   idx1].microalb_val = ce.result_val
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
   idx1 = locateval(indx,1,t_record->pat_cnt,ce.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx1].pneu_vac_dt_tm = cnvtdatetime(ce.clinsig_updt_dt_tm)
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
   idx1 = locateval(indx,1,t_record->pat_cnt,ce.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx1].flu_vac_dt_tm = cnvtdatetime(ce.clinsig_updt_dt_tm)
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
    AND o.catalog_cd=aspirin_cd
    AND o.order_status_cd IN (ordered_cd, on_hold_cd, pending_cd, pending_rev_cd, in_process_cd,
   future_cd))
  ORDER BY o.person_id
  HEAD o.person_id
   idx1 = locateval(indx,1,t_record->pat_cnt,o.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx1].asprin_ind = 1
  WITH orahint("index(O XIE3ORDERS)")
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
  ORDER BY o.person_id
  HEAD o.person_id
   idx1 = locateval(indx,1,t_record->pat_cnt,o.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx1].ace_arb_ind = 1
  WITH orahint("index(O XIE3ORDERS)")
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
   idx1 = locateval(indx,1,t_record->pat_cnt,hem.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx1].hm_retinal_dt_tm = cnvtdatetime(hem.updt_dt_tm)
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
   idx1 = locateval(indx,1,t_record->pat_cnt,hem.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx1].hm_foot_dt_tm = cnvtdatetime(hem.updt_dt_tm)
  WITH maxcol = 1000
 ;end select
 SET stat = alterlist(t_record->nomen_qual,0)
 SET stat = alterlist(t_record->diab_qual,0)
 SELECT INTO "diabetes_registry.xls"
  FROM (dummyt d  WITH seq = t_record->pat_cnt),
   person p
  PLAN (d)
   JOIN (p
   WHERE (p.person_id=t_record->pcp_id))
  HEAD REPORT
   t_line = concat("Diabetes Registry for ",p.name_full_formatted), col 0, t_line,
   row + 1, t_line = concat(char(9),char(9),char(9),"Diagnosis Criteria",char(9),
    char(9),char(9),char(9),"Hb A1c (Goal <7.0)",char(9),
    char(9),"BP (Goal <130/80)",char(9),char(9),char(9),
    "LDL (Goal <100)",char(9),char(9),"Microalbumin (Goal Malb/cr<30)",char(9)), col 0,
   t_line, row + 1, t_line = concat("Patient Name",char(9),"Medical Record #",char(9),"Date of Birth",
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
  DETAIL
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
   t_line = concat(t_record->pat_qual[d.seq].name,char(9),t_record->pat_qual[d.seq].mrn,char(9),
    format(t_record->pat_qual[d.seq].dob,"mm/dd/yyyy;;q"),
    char(9),problem,char(9),lab,char(9),
    med,char(9),format(t_record->pat_qual[d.seq].last_visit_dt_tm,"mm/dd/yyyy;;q"),char(9),format(
     t_record->pat_qual[d.seq].hgb_a1c_dt_tm,"mm/dd/yyyy;;q"),
    char(9),t_record->pat_qual[d.seq].hgb_a1c_val,char(9),format(t_record->pat_qual[d.seq].bp_dt_tm,
     "mm/dd/yyyy;;q"),char(9),
    t_record->pat_qual[d.seq].sys_bp_val,char(9),t_record->pat_qual[d.seq].dia_bp_val,char(9),format(
     t_record->pat_qual[d.seq].ldl_dt_tm,"mm/dd/yyyy;;q"),
    char(9),t_record->pat_qual[d.seq].ldl_val,char(9),format(t_record->pat_qual[d.seq].microalb_dt_tm,
     "mm/dd/yyyy;;q"),char(9),
    t_record->pat_qual[d.seq].microalb_val,char(9),ace_arb,char(9),format(t_record->pat_qual[d.seq].
     pneu_vac_dt_tm,"mm/dd/yyyy;;q"),
    char(9),asprin,char(9),format(t_record->pat_qual[d.seq].flu_vac_dt_tm,"mm/dd/yyyy;;q"),char(9),
    format(t_record->pat_qual[d.seq].hm_foot_dt_tm,"mm/dd/yyyy;;q"),char(9),format(t_record->
     pat_qual[d.seq].hm_retinal_dt_tm,"mm/dd/yyyy;;q"),char(9),t_record->pat_qual[d.seq].street1,
    char(9),t_record->pat_qual[d.seq].city,char(9),t_record->pat_qual[d.seq].state,char(9),
    t_record->pat_qual[d.seq].zip,char(9)), col 0, t_line,
   row + 1
  WITH nocounter, maxcol = 1000, formfeed = none
 ;end select
 IF (findfile("diabetes_registry.xls")=1)
  SET email_list = "anthony.jacobson@bhs.org"
  SET subject_line = "Diabetes Registry"
  CALL emailfile("diabetes_registry.xls","diabetes_registry.xls",email_list,subject_line,1)
 ENDIF
 SET dclcom = "rm -f nomen_ids*"
 SET len = size(trim(dclcom))
 SET status = 0
 SET stat = dcl(dclcom,len,status)
 SET dclcom = "rm -f diab_codes*"
 SET len = size(trim(dclcom))
 SET status = 0
 SET stat = dcl(dclcom,len,status)
END GO
