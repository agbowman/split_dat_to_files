CREATE PROGRAM bhs_rpt_asthma_prompts:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Choose the type of report" = 0,
  "Enter the practice's password" = "",
  "Choose a physician" = 0,
  "Choose a practice" = 0,
  "Enter an email address(es) separated by a space" = ""
  WITH outdev, type, pass,
  pcp, group, email
 EXECUTE bhs_sys_stand_subroutine
 FREE RECORD t_record
 RECORD t_record(
   1 two_year_date = dq8
   1 name = vc
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
     2 last_visit_dt_tm = dq8
     2 last_visit_encntr_id = f8
     2 flu_vac_dt_tm = dq8
     2 pneu_vac_dt_tm = dq8
     2 education_date = dq8
     2 diagnois = vc
     2 classification = vc
     2 controller_med = vc
     2 saba_ind = i2
     2 laba_ind = i2
     2 leuk_ind = i2
     2 is_ind = i2
     2 os_ind = i2
     2 mcs_ind = i2
     2 antichol_ind = i2
     2 ca_ind = i2
     2 under21_ind = i2
     2 smoker_flag = i4
 )
 DECLARE mf_not_done_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE mf_inerror_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
 DECLARE mf_smokingcessation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SMOKINGCESSATION"))
 DECLARE mf_pneu_vac_cd01 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOCOCCAL7VALENTVACCINE"))
 DECLARE mf_pneu_vac_cd02 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOCOCCAL13VALENTVACCINE"))
 DECLARE mf_pneu_vac_cd05 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOCOCCAL23VALENTVACCINE"))
 DECLARE mf_pneu_vac_cd06 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOCOCCALVACCOLDTERM"))
 DECLARE mf_pneu_vac_cd11 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOCOCCALCONJUGATEPCV7OLDTERM"))
 DECLARE mf_pneu_vac_cd12 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOCOCCALPOLYPPV23OLDTERM"))
 DECLARE mf_pneu_vac_cd13 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOCOCCALVACCINEOLDTERM"))
 DECLARE mf_pneu_vac_cd14 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PNEUMOVAX23OLDTERM"))
 DECLARE mf_pneu_vac_cd15 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PREVNARINJOLDTERM"))
 DECLARE mf_pneu_vac_cd16 = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PREVNAROLDTERM"))
 DECLARE mf_influ_h1n1_inact = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "INFLUENZAVIRUSVACCINEH1N1INACTIVE"))
 DECLARE mf_influ_h1n1_live = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "INFLUENZAVIRUSVACCINEH1N1LIVE"))
 DECLARE mf_influ_vacc_inact = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "INFLUENZAVIRUSVACCINEINACTIVATED"))
 DECLARE mf_influ_vacc_triv = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "INFLUENZAVIRUSVACCINELIVETRIVALENT"))
 DECLARE mf_influ_vacc_old = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "INFLUENZAVIRUSVACCINEOLDTERM"))
 DECLARE mf_influ_vac_cd01 = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "AFLURIAOLDTERM"))
 DECLARE mf_influ_vac_cd02 = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "FLUARIXOLDTERM"))
 DECLARE mf_influ_vac_cd03 = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "FLULAVALOLDTERM"))
 DECLARE mf_influ_vac_cd04 = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "FLUMISTOLDTERM"))
 DECLARE mf_influ_vac_cd05 = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "FLUVIRINOLDTERM"))
 DECLARE mf_influ_vac_cd06 = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "FLUVIRINPRESERVATIVEFREEOLDTERM"))
 DECLARE mf_influ_vac_cd07 = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "FLUZONEOLDTERM"))
 DECLARE mf_influ_vac_cd08 = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "FLUZONEPRESERVATIVEFREEOLDTERM"))
 DECLARE mf_influ_vac_cd09 = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "FLUZONEPRESERVATIVEFREEPEDIOLDTERM"))
 DECLARE mf_influ_vac_cd10 = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "INFLUENZAINACTIVEIMOLDTERM"))
 DECLARE mf_influ_vac_cd11 = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "INFLUENZALIVEINTRANASALOLDTERM"))
 DECLARE ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE on_hold_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ONHOLDMEDSTUDENT")
  )
 DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"PENDINGCOMPLETE"))
 DECLARE pending_rev_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"PENDINGREVIEW"
   ))
 DECLARE in_process_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"INPROCESS"))
 DECLARE future_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"FUTURE"))
 DECLARE saba1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ALBUTEROL"))
 DECLARE saba2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"LEVALBUTEROL"))
 DECLARE saba3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"PIRBUTEROL"))
 DECLARE laba1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"SALMETEROL"))
 DECLARE laba2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"FORMOTEROL"))
 DECLARE leuk1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"MONTELUKAST"))
 DECLARE leuk2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ZAFIRLUKAST"))
 DECLARE leuk3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ZILEUTON"))
 DECLARE is1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"FLUTICASONE"))
 DECLARE is2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"BUDESONIDE"))
 DECLARE is3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"FLUNISOLIDE"))
 DECLARE is4_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"MOMETASONE"))
 DECLARE is5_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"TRIAMCINOLONE"))
 DECLARE is6_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"BECLOMETHASONE"))
 DECLARE is7_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"CICLESONIDE"))
 DECLARE os1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"PREDNISONE"))
 DECLARE os2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"PREDNISOLONE"))
 DECLARE mcs1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"CROMOLYN"))
 DECLARE mcs2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"NEDOCROMIL"))
 DECLARE antichol1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"IPRATROPIUM"))
 DECLARE ca1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ALBUTEROLIPRATROPIUM"))
 DECLARE ca2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"FLUTICASONESALMETEROL")
  )
 DECLARE ca3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"BUDESONIDEFORMOTEROL"))
 DECLARE md_twenty_one_dt = dq8 WITH protect, constant(datetimeadd(cnvtdatetime(sysdate),- (7665)))
 DECLARE t_line = vc
 DECLARE l_line = vc
 DECLARE p_line = vc
 DECLARE problem = vc
 DECLARE address = vc
 DECLARE severity_flag = i2
 DECLARE dclcom = vc
 DECLARE under21_ind_str = vc
 DECLARE smoker_flag_str = vc
 DECLARE indx = i4 WITH protect, noconstant(0)
 DECLARE nsize = i4 WITH protect, noconstant(0)
 DECLARE nbucketsize = i4 WITH protect, noconstant(0)
 DECLARE ntotal = i4 WITH protect, noconstant(0)
 DECLARE nstart = i4 WITH protect, noconstant(0)
 DECLARE nbuckets = i4 WITH protect, noconstant(0)
 SET t_record->two_year_date = cnvtdatetime(datetimeadd(cnvtdatetime(sysdate),- (730)))
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
   FROM bhs_physician_location b,
    bhs_practice_location b1
   PLAN (b
    WHERE (b.location_id= $GROUP))
    JOIN (b1
    WHERE b1.location_id=b.location_id)
   ORDER BY b.person_id
   HEAD REPORT
    t_record->name = b1.location_description, l_line = "b.pcp_id in ( ", p_line =
    "sa1.person_id in ( ",
    first_ind = 0
   HEAD b.person_id
    IF (first_ind=0)
     l_line = concat(l_line,trim(cnvtstring(b.person_id))), p_line = concat(p_line,trim(cnvtstring(b
        .person_id))), first_ind = 1
    ELSE
     l_line = concat(l_line,",",trim(cnvtstring(b.person_id))), p_line = concat(p_line,",",trim(
       cnvtstring(b.person_id)))
    ENDIF
   FOOT REPORT
    l_line = concat(l_line,")"), p_line = concat(p_line,")")
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
 SELECT INTO "nl:"
  FROM bhs_problem_registry b
  PLAN (b
   WHERE parser(l_line)
    AND b.active_ind=1
    AND b.problem="ASTHMA")
  DETAIL
   t_record->pat_cnt += 1
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
   bhs_physician_location bp,
   bhs_practice_location bpl
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
    AND pa.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (a
   WHERE (a.parent_entity_id= Outerjoin(p.person_id))
    AND (a.parent_entity_name= Outerjoin("PERSON")) )
   JOIN (b
   WHERE b.person_id=p.person_id
    AND b.problem="ASTHMA")
   JOIN (bp
   WHERE bp.person_id=b.pcp_id)
   JOIN (bpl
   WHERE bpl.location_id=bp.location_id)
  ORDER BY p.person_id, pa.active_status_dt_tm DESC
  HEAD p.person_id
   done = 0, idx = locateval(indx,1,t_record->pat_cnt,p.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx].org_key = bpl.location_description,
   t_record->pat_qual[idx].org = bpl.location_description, t_record->pat_qual[idx].name = p
   .name_full_formatted, t_record->pat_qual[idx].dob = cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p
     .birth_tz),1),
   t_record->pat_qual[idx].street1 = a.street_addr, t_record->pat_qual[idx].street2 = a.street_addr2,
   t_record->pat_qual[idx].street3 = a.street_addr3,
   t_record->pat_qual[idx].street4 = a.street_addr4, t_record->pat_qual[idx].state = a.state,
   t_record->pat_qual[idx].city = a.city,
   t_record->pat_qual[idx].zip = a.zipcode
   IF ((t_record->pat_qual[idx].dob >= md_twenty_one_dt))
    t_record->pat_qual[idx].under21_ind = 1
   ENDIF
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
   WHERE n.nomenclature_id=p.nomenclature_id
    AND n.nomen_list_key="REGISTRY-ASTHMA")
  ORDER BY p.person_id
  HEAD p.person_id
   idx1 = locateval(indx,1,t_record->pat_cnt,p.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx1].problem_ind = 1, t_record->pat_qual[idx1].classification =
   uar_get_code_display(p.severity_cd)
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
   WHERE n.nomenclature_id=dg.nomenclature_id
    AND n.nomen_list_key="REGISTRY-ASTHMA")
  ORDER BY dg.person_id
  HEAD dg.person_id
   idx1 = locateval(indx,1,t_record->pat_cnt,dg.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx1].problem_ind = 1
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = nbuckets),
   orders o
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nbucketsize))))
   JOIN (o
   WHERE expand(indx,nstart,(nstart+ (nbucketsize - 1)),o.person_id,t_record->pat_qual[indx].
    person_id)
    AND o.catalog_cd IN (saba1_cd, saba2_cd, saba3_cd, laba1_cd, laba2_cd,
   leuk1_cd, leuk2_cd, leuk3_cd, is1_cd, is2_cd,
   is3_cd, is4_cd, is5_cd, is6_cd, is7_cd,
   os1_cd, os2_cd, mcs1_cd, mcs2_cd, antichol1_cd,
   ca1_cd, ca2_cd, ca3_cd)
    AND o.order_status_cd IN (ordered_cd, on_hold_cd, pending_cd, pending_rev_cd, in_process_cd,
   future_cd))
  ORDER BY o.person_id, o.catalog_cd
  HEAD o.person_id
   idx = locateval(indx,1,t_record->pat_cnt,o.person_id,t_record->pat_qual[indx].person_id)
  HEAD o.catalog_cd
   IF (o.catalog_cd IN (saba1_cd, saba2_cd, saba3_cd))
    t_record->pat_qual[idx].saba_ind = 1
   ELSEIF (o.catalog_cd IN (laba1_cd, laba2_cd))
    t_record->pat_qual[idx].laba_ind = 1
   ELSEIF (o.catalog_cd IN (leuk1_cd, leuk2_cd, leuk3_cd))
    t_record->pat_qual[idx].leuk_ind = 1
   ELSEIF (o.catalog_cd IN (is1_cd, is2_cd, is3_cd, is4_cd, is5_cd,
   is6_cd, is7_cd))
    t_record->pat_qual[idx].is_ind = 1
   ELSEIF (o.catalog_cd IN (os1_cd, os2_cd))
    t_record->pat_qual[idx].os_ind = 1
   ELSEIF (o.catalog_cd IN (mcs1_cd, mcs2_cd))
    t_record->pat_qual[idx].mcs_ind = 1
   ELSEIF (o.catalog_cd IN (antichol1_cd))
    t_record->pat_qual[idx].antichol_ind = 1
   ELSEIF (o.catalog_cd IN (ca1_cd, ca2_cd, ca3_cd))
    t_record->pat_qual[idx].ca_ind = 1
   ENDIF
  WITH orahint("index(O XIE99ORDERS)")
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
    AND ce.event_cd IN (mf_influ_h1n1_inact, mf_influ_h1n1_live, mf_influ_vacc_inact,
   mf_influ_vacc_triv, mf_influ_vacc_old,
   mf_influ_vac_cd01, mf_influ_vac_cd02, mf_influ_vac_cd03, mf_influ_vac_cd04, mf_influ_vac_cd05,
   mf_influ_vac_cd06, mf_influ_vac_cd07, mf_influ_vac_cd08, mf_influ_vac_cd09, mf_influ_vac_cd10,
   mf_influ_vac_cd11)
    AND  NOT (ce.result_status_cd IN (mf_not_done_cd, mf_inerror_cd)))
  ORDER BY ce.person_id, ce.clinsig_updt_dt_tm DESC
  HEAD ce.person_id
   idx = locateval(indx,1,t_record->pat_cnt,ce.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx].flu_vac_dt_tm = cnvtdatetime(ce.clinsig_updt_dt_tm)
  WITH orahint("index(CE XIE9CLINICAL_EVENT)")
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
    AND hes.expect_step_name="Influenza")
  ORDER BY hem.person_id, hem.updt_dt_tm DESC
  HEAD hem.person_id
   idx = locateval(indx,1,t_record->pat_cnt,hem.person_id,t_record->pat_qual[indx].person_id)
   IF (cnvtdatetime(hem.updt_dt_tm) > cnvtdatetime(t_record->pat_qual[idx].flu_vac_dt_tm))
    t_record->pat_qual[idx].flu_vac_dt_tm = cnvtdatetime(hem.updt_dt_tm)
   ENDIF
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
    AND ce.event_cd IN (mf_pneu_vac_cd01, mf_pneu_vac_cd02, mf_pneu_vac_cd05, mf_pneu_vac_cd06,
   mf_pneu_vac_cd11,
   mf_pneu_vac_cd12, mf_pneu_vac_cd13, mf_pneu_vac_cd14, mf_pneu_vac_cd15, mf_pneu_vac_cd16)
    AND  NOT (ce.result_status_cd IN (mf_not_done_cd, mf_inerror_cd)))
  ORDER BY ce.person_id, ce.clinsig_updt_dt_tm DESC
  HEAD ce.person_id
   idx = locateval(indx,1,t_record->pat_cnt,ce.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx].pneu_vac_dt_tm = cnvtdatetime(ce.clinsig_updt_dt_tm)
  WITH orahint("index(CE XIE9CLINICAL_EVENT)")
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
    AND hes.expect_step_name="Asthma Education")
  ORDER BY hem.person_id, hem.updt_dt_tm DESC
  HEAD hem.person_id
   idx = locateval(indx,1,t_record->pat_cnt,hem.person_id,t_record->pat_qual[indx].person_id),
   t_record->pat_qual[idx].education_date = hes.active_status_dt_tm
  WITH maxcol = 1000
 ;end select
 SELECT INTO "nl:"
  FROM hm_expect he,
   hm_expect_sat hes,
   hm_expect_mod hem,
   (dummyt d  WITH seq = t_record->pat_cnt)
  PLAN (he
   WHERE he.expect_name="Tobacco Screening"
    AND he.active_ind=1)
   JOIN (hes
   WHERE hes.expect_id=he.expect_id
    AND hes.active_ind=1
    AND hes.expect_sat_name IN ("Never Smoked", "Discontinued Smoking", "Canceled Permanently",
   "Second Hand Smoke Exposure", "Counseled today"))
   JOIN (hem
   WHERE hem.expect_sat_id=hes.expect_sat_id
    AND hem.active_ind=1)
   JOIN (d
   WHERE (t_record->pat_qual[d.seq].person_id=hem.person_id))
  ORDER BY hem.person_id, hem.updt_dt_tm DESC
  HEAD hem.person_id
   IF (hes.expect_sat_name="Counseled today")
    t_record->pat_qual[d.seq].smoker_flag = 2
   ELSE
    t_record->pat_qual[d.seq].smoker_flag = 1
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = t_record->pat_cnt),
   clinical_event ce
  PLAN (d
   WHERE (t_record->pat_qual[d.seq].smoker_flag=0))
   JOIN (ce
   WHERE (ce.person_id=t_record->pat_qual[d.seq].person_id)
    AND ce.event_cd=mf_smokingcessation_cd
    AND ce.valid_until_dt_tm >= sysdate
    AND ce.result_val IN ("Patient has never smoked", "Patient has not smoked in the last 12 months",
   "Patient has smoked in the last 12 months"))
  ORDER BY ce.person_id, ce.valid_from_dt_tm DESC
  HEAD ce.person_id
   IF (ce.result_val="Patient has smoked in the last 12 months")
    t_record->pat_qual[d.seq].smoker_flag = 2
   ELSE
    t_record->pat_qual[d.seq].smoker_flag = 1
   ENDIF
  WITH nocounter
 ;end select
 FOR (z = 1 TO t_record->pat_cnt)
  IF ((t_record->pat_qual[z].problem_ind=0))
   SET severity_flag = 0
   IF ((((t_record->pat_qual[z].saba_ind=1)) OR ((t_record->pat_qual[z].laba_ind=1))) )
    SET severity_flag = 1
   ENDIF
   IF ((t_record->pat_qual[z].saba_ind=1)
    AND (((t_record->pat_qual[z].leuk_ind=1)) OR ((((t_record->pat_qual[z].is_ind=1)) OR ((((t_record
   ->pat_qual[z].os_ind=1)) OR ((t_record->pat_qual[z].antichol_ind=1))) )) )) )
    SET severity_flag = 2
   ENDIF
   IF ((t_record->pat_qual[z].laba_ind=1)
    AND (((t_record->pat_qual[z].leuk_ind=1)) OR ((((t_record->pat_qual[z].is_ind=1)) OR ((((t_record
   ->pat_qual[z].os_ind=1)) OR ((t_record->pat_qual[z].antichol_ind=1))) )) )) )
    SET severity = 2
   ENDIF
   IF ((t_record->pat_qual[z].saba_ind=1)
    AND (t_record->pat_qual[z].is_ind=1)
    AND (t_record->pat_qual[z].os_ind=1))
    SET severity_flag = 2
   ENDIF
   IF ((t_record->pat_qual[z].leuk_ind=1)
    AND (t_record->pat_qual[z].is_ind=1)
    AND (t_record->pat_qual[z].os_ind=1)
    AND (((t_record->pat_qual[z].saba_ind=1)) OR ((((t_record->pat_qual[z].laba_ind=1)) OR ((t_record
   ->pat_qual[z].ca_ind=1))) )) )
    SET severity_flag = 3
   ENDIF
   IF ((t_record->pat_qual[z].leuk_ind=1)
    AND (t_record->pat_qual[z].mcs_ind=1)
    AND (t_record->pat_qual[z].antichol_ind=1)
    AND (((t_record->pat_qual[z].saba_ind=1)) OR ((((t_record->pat_qual[z].laba_ind=1)) OR ((t_record
   ->pat_qual[z].ca_ind=1))) )) )
    SET severity_flag = 3
   ENDIF
   IF ((t_record->pat_qual[z].saba_ind=1)
    AND (t_record->pat_qual[z].laba_ind=1)
    AND (t_record->pat_qual[z].leuk_ind=1)
    AND (t_record->pat_qual[z].is_ind=1)
    AND (t_record->pat_qual[z].os_ind=1)
    AND (t_record->pat_qual[z].mcs_ind=1)
    AND (t_record->pat_qual[z].antichol_ind=1)
    AND (t_record->pat_qual[z].ca_ind=1))
    SET severity_flag = 3
   ENDIF
   IF (severity_flag=1)
    SET t_record->pat_qual[z].diagnois = "Possible Asthma"
   ENDIF
   IF (severity_flag=2)
    SET t_record->pat_qual[z].diagnois = "Likely Asthma"
   ENDIF
   IF (severity_flag=3)
    SET t_record->pat_qual[z].diagnois = "Very Likely Asthma"
   ENDIF
  ENDIF
  IF ((((t_record->pat_qual[z].leuk_ind=1)) OR ((((t_record->pat_qual[z].is_ind=1)) OR ((t_record->
  pat_qual[z].ca_ind=1))) )) )
   SET t_record->pat_qual[z].controller_med = "Yes"
  ELSE
   SET t_record->pat_qual[z].controller_med = "No"
  ENDIF
 ENDFOR
 IF (( $TYPE=1))
  SELECT INTO "asthma_registry.xls"
   under21_ind = t_record->pat_qual[d.seq].under21_ind, name = t_record->pat_qual[d.seq].name, id =
   t_record->pat_qual[d.seq].person_id
   FROM (dummyt d  WITH seq = t_record->pat_cnt)
   PLAN (d)
   ORDER BY under21_ind DESC, name, id
   HEAD REPORT
    t_line = concat("Asthma Registry for ",t_record->name), col 0, t_line,
    row + 1, t_line = concat("Patient Name",char(9),"Medical Record #",char(9),"Date of Birth",
     char(9),"Under 21 Years Old",char(9),"Last office visit with PCP",char(9),
     "Asthma on Problem List",char(9),"Severity",char(9),"Predicted Severity (if no dx)",
     char(9),"Controller Med",char(9),"Asthma Education Date",char(9),
     "Influenza Vaccine",char(9),"Pneumococcal Vaccine",char(9),"Smoker",
     char(9),"Street Address",char(9),"City",char(9),
     "State",char(9),"Zip Code",char(9)), col 0,
    t_line, row + 1
   HEAD name
    null
   HEAD id
    IF ((t_record->pat_qual[d.seq].problem_ind=1))
     problem = "yes"
    ELSE
     problem = "no"
    ENDIF
    IF ((t_record->pat_qual[d.seq].under21_ind=1))
     under21_ind_str = "yes"
    ELSE
     under21_ind_str = "no"
    ENDIF
    IF ((t_record->pat_qual[d.seq].smoker_flag=1))
     smoker_flag_str = "no"
    ELSEIF ((t_record->pat_qual[d.seq].smoker_flag=2))
     smoker_flag_str = "yes"
    ELSE
     smoker_flag_str = "unknown"
    ENDIF
    address = trim(concat(t_record->pat_qual[d.seq].street1," ",t_record->pat_qual[d.seq].street2," ",
      t_record->pat_qual[d.seq].street3,
      " ",t_record->pat_qual[d.seq].street4)), t_line = concat(t_record->pat_qual[d.seq].name,char(9),
     t_record->pat_qual[d.seq].mrn,char(9),format(t_record->pat_qual[d.seq].dob,"mm/dd/yyyy;;q"),
     char(9),under21_ind_str,char(9),format(t_record->pat_qual[d.seq].last_visit_dt_tm,
      "mm/dd/yyyy;;q"),char(9),
     problem,char(9),t_record->pat_qual[d.seq].classification,char(9),t_record->pat_qual[d.seq].
     diagnois,
     char(9),t_record->pat_qual[d.seq].controller_med,char(9),format(t_record->pat_qual[d.seq].
      education_date,"mm/dd/yyyy;;q"),char(9),
     format(t_record->pat_qual[d.seq].flu_vac_dt_tm,"mm/dd/yyyy;;q"),char(9),format(t_record->
      pat_qual[d.seq].pneu_vac_dt_tm,"mm/dd/yyyy;;q"),char(9),smoker_flag_str,
     char(9),address,char(9),t_record->pat_qual[d.seq].city,char(9),
     t_record->pat_qual[d.seq].state,char(9),t_record->pat_qual[d.seq].zip,char(9)), col 0,
    t_line, row + 1
   WITH nocounter, maxcol = 1000, formfeed = none
  ;end select
 ELSEIF (( $TYPE=2))
  SELECT INTO "asthma_registry.xls"
   under21_ind = t_record->pat_qual[d.seq].under21_ind, name = t_record->pat_qual[d.seq].name, id =
   t_record->pat_qual[d.seq].person_id
   FROM (dummyt d  WITH seq = t_record->pat_cnt),
    bhs_problem_registry b,
    person p
   PLAN (d)
    JOIN (b
    WHERE (b.person_id=t_record->pat_qual[d.seq].person_id))
    JOIN (p
    WHERE p.person_id=b.pcp_id)
   ORDER BY under21_ind DESC, name, id
   HEAD REPORT
    t_line = concat("Asthma Registry for ",t_record->name), col 0, t_line,
    row + 1, t_line = concat("Patient Name",char(9),"Medical Record #",char(9),"Date of Birth",
     char(9),"Under 21 Years Old",char(9),"PCP",char(9),
     "Last office visit with PCP",char(9),"Asthma on Problem List",char(9),"Severity",
     char(9),"Predicted Severity (if no dx)",char(9),"Controller Med",char(9),
     "Asthma Education",char(9),"Influenza Vaccine",char(9),"Pneumococcal Vaccine",
     char(9),"Smoker",char(9),"Street Address",char(9),
     "City",char(9),"State",char(9),"Zip Code",
     char(9)), col 0,
    t_line, row + 1
   HEAD name
    null
   HEAD id
    IF ((t_record->pat_qual[d.seq].problem_ind=1))
     problem = "yes"
    ELSE
     problem = "no"
    ENDIF
    IF ((t_record->pat_qual[d.seq].under21_ind=1))
     under21_ind_str = "yes"
    ELSE
     under21_ind_str = "no"
    ENDIF
    IF ((t_record->pat_qual[d.seq].smoker_flag=1))
     smoker_flag_str = "no"
    ELSEIF ((t_record->pat_qual[d.seq].smoker_flag=2))
     smoker_flag_str = "yes"
    ELSE
     smoker_flag_str = "unknown"
    ENDIF
    address = trim(concat(t_record->pat_qual[d.seq].street1," ",t_record->pat_qual[d.seq].street2," ",
      t_record->pat_qual[d.seq].street3,
      " ",t_record->pat_qual[d.seq].street4)), t_line = concat(t_record->pat_qual[d.seq].name,char(9),
     t_record->pat_qual[d.seq].mrn,char(9),format(t_record->pat_qual[d.seq].dob,"mm/dd/yyyy;;q"),
     char(9),under21_ind_str,char(9),p.name_full_formatted,char(9),
     format(t_record->pat_qual[d.seq].last_visit_dt_tm,"mm/dd/yyyy;;q"),char(9),problem,char(9),
     t_record->pat_qual[d.seq].classification,
     char(9),t_record->pat_qual[d.seq].diagnois,char(9),t_record->pat_qual[d.seq].controller_med,char
     (9),
     format(t_record->pat_qual[d.seq].education_date,"mm/dd/yyyy;;q"),char(9),format(t_record->
      pat_qual[d.seq].flu_vac_dt_tm,"mm/dd/yyyy;;q"),char(9),format(t_record->pat_qual[d.seq].
      pneu_vac_dt_tm,"mm/dd/yyyy;;q"),
     char(9),smoker_flag_str,char(9),address,char(9),
     t_record->pat_qual[d.seq].city,char(9),t_record->pat_qual[d.seq].state,char(9),t_record->
     pat_qual[d.seq].zip,
     char(9)), col 0,
    t_line, row + 1
   WITH nocounter, maxcol = 1000, formfeed = none
  ;end select
 ENDIF
 IF (findfile("asthma_registry.xls")=1)
  SET email_list =  $EMAIL
  SET subject_line = "Asthma Registry"
  CALL emailfile("asthma_registry.xls","asthma_registry.xls",email_list,subject_line,1)
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
