CREATE PROGRAM bhs_diab_qrtrly_practice_rpt:dba
 EXECUTE bhs_sys_stand_subroutine
 FREE RECORD t_record
 RECORD t_record(
   1 t_action_dt_tm = dq8
   1 two_year_date = dq8
   1 name = vc
   1 practice_cnt = i4
   1 practice_qual[*]
     2 practice_id = f8
     2 email = vc
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
 FREE RECORD reply
 RECORD reply(
   1 status_data[1]
     2 status = c1
 )
 DECLARE month = i2
 IF (validate(request->batch_selection))
  SET t_record->t_action_dt_tm = cnvtdatetime(request->ops_date)
  SET month = month(cnvtdatetime(request->ops_date))
  IF ((t_record->t_action_dt_tm <= 0))
   SET month = month(cnvtdatetime(curdate,curtime3))
  ENDIF
  IF (((month=1) OR (((month=4) OR (((month=7) OR (month=10)) )) )) )
   SET count = 1
  ELSE
   GO TO exit_script
  ENDIF
  SET email_list = "neil.kudler@bhs.org"
 ELSE
  SET email_list = "bob.kauffman@bhs.org"
 ENDIF
 CALL echo(concat("email to: ",email_list))
 DECLARE mf_not_done_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"NOT DONE"))
 DECLARE mf_inerror_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE mrn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",4,
   "CORPORATEMEDICALRECORDNUMBER"))
 DECLARE glucose_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"GLUCOSELEVEL"))
 DECLARE hemo_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "HEMOGLOBINA1CMONITORING"))
 DECLARE sys_bp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "SYSTOLICBLOODPRESSURE"))
 DECLARE dia_bp_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DIASTOLICBLOODPRESSURE"))
 DECLARE ldl1_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"LDLCHOLESTEROL"))
 DECLARE ldl2_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"LDLCARDIAC"))
 DECLARE ldl3_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DIRECTLOWDENSITYLIPOPROTEIN"))
 DECLARE microalb_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"MICROALBUMIN"))
 DECLARE aspirin_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ASPIRIN"))
 DECLARE ordered_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED"))
 DECLARE on_hold_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"ONHOLDMEDSTUDENT")
  )
 DECLARE pending_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"PENDINGCOMPLETE"))
 DECLARE pending_rev_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"PENDINGREVIEW"
   ))
 DECLARE in_process_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"INPROCESS"))
 DECLARE future_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",6004,"FUTURE"))
 DECLARE ace_med01_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"QUINAPRIL"))
 DECLARE ace_med02_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"PERINDOPRIL"))
 DECLARE ace_med03_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"RAMIPRIL"))
 DECLARE ace_med04_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "AMLODIPINEBENAZEPRIL"))
 DECLARE ace_med05_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"BENAZEPRIL"))
 DECLARE ace_med06_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"CAPTOPRIL"))
 DECLARE ace_med07_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ENALAPRIL"))
 DECLARE ace_med08_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"FOSINOPRIL"))
 DECLARE ace_med09_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ENALAPRILFELODIPINE"))
 DECLARE ace_med10_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"LISINOPRIL"))
 DECLARE ace_med11_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"TRANDOLAPRIL"))
 DECLARE ace_med12_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"MOEXIPRIL"))
 DECLARE ace_med13_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "TRANDOLAPRILVERAPAMIL"))
 DECLARE ace_med14_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"ENALAPRIL"))
 DECLARE ace_med15_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"LISINOPRIL"))
 DECLARE ace_com01_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROCHLOROTHIAZIDEQUINAPRIL"))
 DECLARE ace_com02_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "BENAZEPRILHYDROCHLOROTHIAZIDE"))
 DECLARE ace_com03_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CAPTOPRILHYDROCHLOROTHIAZIDE"))
 DECLARE ace_com04_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ENALAPRILHYDROCHLOROTHIAZIDE"))
 DECLARE ace_com05_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "FOSINOPRILHYDROCHLOROTHIAZIDE"))
 DECLARE ace_com06_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROCHLOROTHIAZIDELISINOPRIL"))
 DECLARE ace_com07_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROCHLOROTHIAZIDEMOEXIPRIL"))
 DECLARE arb_med01_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"CANDESARTAN"))
 DECLARE arb_med02_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"IRBESARTAN"))
 DECLARE arb_med03_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "AMLODIPINEOLMESARTAN"))
 DECLARE arb_med04_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"OLMESARTAN"))
 DECLARE arb_med05_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"LOSARTAN"))
 DECLARE arb_med06_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"VALSARTAN"))
 DECLARE arb_med07_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "AMLODIPINEVALSARTAN"))
 DECLARE arb_med08_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"TELMISARTAN"))
 DECLARE arb_med09_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"EPROSARTAN"))
 DECLARE arb_med10_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "AMLODIPINETELMISARTAN"))
 DECLARE arb_med11_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ALISKIRENVALSARTAN"))
 DECLARE arb_com01_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "CANDESARTANHYDROCHLOROTHIAZIDE"))
 DECLARE arb_com02_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROCHLOROTHIAZIDEIRBESARTAN"))
 DECLARE arb_com03_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROCHLOROTHIAZIDEOLMESARTAN"))
 DECLARE arb_com04_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROCHLOROTHIAZIDEVALSARTAN"))
 DECLARE arb_com05_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "AMLODIPINEHYDROCHLOROTHIAZIDEVALSARTAN"))
 DECLARE arb_com06_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROCHLOROTHIAZIDELOSARTAN"))
 DECLARE arb_com07_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HYDROCHLOROTHIAZIDETELMISARTAN"))
 DECLARE arb_com08_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "EPROSARTANHYDROCHLOROTHIAZIDE"))
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
 DECLARE indx = i4 WITH protect, noconstant(0)
 DECLARE nsize = i4 WITH protect, noconstant(0)
 DECLARE nbucketsize = i4 WITH protect, noconstant(0)
 DECLARE ntotal = i4 WITH protect, noconstant(0)
 DECLARE nstart = i4 WITH protect, noconstant(0)
 DECLARE nbuckets = i4 WITH protect, noconstant(0)
 SET t_record->two_year_date = cnvtdatetime(datetimeadd(cnvtdatetime(curdate,curtime3),- (365)))
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
  FROM bhs_practice_location b
  PLAN (b
   WHERE b.email != null)
  DETAIL
   t_record->practice_cnt = (t_record->practice_cnt+ 1), stat = alterlist(t_record->practice_qual,
    t_record->practice_cnt), t_record->practice_qual[t_record->practice_cnt].practice_id = b
   .location_id,
   t_record->practice_qual[t_record->practice_cnt].email = b.email
  WITH nocounter
 ;end select
 FOR (i = 1 TO t_record->practice_cnt)
   SELECT INTO "nl:"
    FROM bhs_physician_location b,
     bhs_practice_location b1
    PLAN (b
     WHERE (b.location_id=t_record->practice_qual[i].practice_id))
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
     idx = t_record->pat_cnt, t_record->pat_qual[idx].person_id = b.person_id, t_record->pat_qual[idx
     ].phys_id = b.pcp_id,
     t_record->pat_qual[idx].practice_id = b.practice_id
    FOOT REPORT
     stat = alterlist(t_record->pat_qual,t_record->pat_cnt)
    WITH nocounter
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
      AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
     JOIN (a
     WHERE a.parent_entity_id=outerjoin(p.person_id)
      AND a.parent_entity_name=outerjoin("PERSON"))
     JOIN (b
     WHERE b.person_id=p.person_id
      AND b.problem="DIABETES")
     JOIN (bp
     WHERE bp.person_id=b.pcp_id)
     JOIN (bpl
     WHERE bpl.location_id=bp.location_id)
    ORDER BY p.person_id, pa.active_status_dt_tm DESC
    HEAD p.person_id
     done = 0, idx = locateval(indx,1,t_record->pat_cnt,p.person_id,t_record->pat_qual[indx].
      person_id), t_record->pat_qual[idx].org_key = bpl.location_description,
     t_record->pat_qual[idx].org = bpl.location_description, t_record->pat_qual[idx].name = p
     .name_full_formatted, t_record->pat_qual[idx].dob = p.birth_dt_tm,
     t_record->pat_qual[idx].street1 = a.street_addr, t_record->pat_qual[idx].street2 = a
     .street_addr2, t_record->pat_qual[idx].street3 = a.street_addr3,
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
     WHERE n.nomenclature_id=p.nomenclature_id
      AND n.nomen_list_key="HM_DIABETESSCREENING")
    ORDER BY p.person_id
    HEAD p.person_id
     idx1 = locateval(indx,1,t_record->pat_cnt,p.person_id,t_record->pat_qual[indx].person_id),
     t_record->pat_qual[idx1].problem_ind = 1
    WITH nocounter
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
      AND n.nomen_list_key="HM_DIABETESSCREENING")
    ORDER BY dg.person_id
    HEAD dg.person_id
     idx1 = locateval(indx,1,t_record->pat_cnt,dg.person_id,t_record->pat_qual[indx].person_id),
     t_record->pat_qual[idx1].problem_ind = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(size(t_record->pat_qual,5))),
     bhs_problem_registry bpr,
     bhs_physician_location bpl1,
     bhs_physician_location bpl2,
     sch_appt sa,
     sch_appt sa1
    PLAN (d)
     JOIN (bpr
     WHERE (bpr.person_id=t_record->pat_qual[d.seq].person_id))
     JOIN (bpl1
     WHERE bpl1.person_id=bpr.pcp_id)
     JOIN (bpl2
     WHERE bpl2.location_id=bpl1.location_id)
     JOIN (sa
     WHERE sa.person_id=bpr.person_id
      AND sa.state_meaning="CHECKED IN"
      AND sa.role_meaning="PATIENT")
     JOIN (sa1
     WHERE sa1.schedule_id=sa.schedule_id
      AND sa1.person_id=bpl2.person_id
      AND sa1.state_meaning="CHECKED IN"
      AND sa1.role_meaning="RESOURCE")
    ORDER BY sa.person_id, sa.beg_dt_tm DESC
    HEAD sa.person_id
     t_record->pat_qual[d.seq].last_visit_dt_tm = cnvtdatetime(sa.beg_dt_tm), t_record->pat_qual[d
     .seq].last_visit_encntr_id = sa.encntr_id
    WITH nocounter
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
      AND ce.event_cd IN (ldl1_cd, ldl2_cd, ldl3_cd))
    ORDER BY ce.person_id, ce.clinsig_updt_dt_tm DESC
    HEAD ce.person_id
     idx = locateval(indx,1,t_record->pat_cnt,ce.person_id,t_record->pat_qual[indx].person_id),
     t_record->pat_qual[idx].ldl_dt_tm = cnvtdatetime(ce.clinsig_updt_dt_tm), t_record->pat_qual[idx]
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
     idx = locateval(indx,1,t_record->pat_cnt,ce.person_id,t_record->pat_qual[indx].person_id),
     t_record->pat_qual[idx].microalb_dt_tm = cnvtdatetime(ce.clinsig_updt_dt_tm), t_record->
     pat_qual[idx].microalb_val = ce.result_val
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
     idx = locateval(indx,1,t_record->pat_cnt,o.person_id,t_record->pat_qual[indx].person_id),
     t_record->pat_qual[idx].med_ind = 1
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
     idx = locateval(indx,1,t_record->pat_cnt,o.person_id,t_record->pat_qual[indx].person_id),
     t_record->pat_qual[idx].asprin_ind = 1
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
      AND o.catalog_cd IN (ace_med01_cd, ace_med02_cd, ace_med03_cd, ace_med04_cd, ace_med05_cd,
     ace_med06_cd, ace_med07_cd, ace_med08_cd, ace_med09_cd, ace_med10_cd,
     ace_med11_cd, ace_med12_cd, ace_med13_cd, ace_med14_cd, ace_med15_cd,
     ace_com01_cd, ace_com02_cd, ace_com03_cd, ace_com04_cd, ace_com05_cd,
     ace_com06_cd, ace_com07_cd, arb_med01_cd, arb_med02_cd, arb_med03_cd,
     arb_med04_cd, arb_med05_cd, arb_med06_cd, arb_med07_cd, arb_med08_cd,
     arb_med09_cd, arb_med10_cd, arb_med11_cd, arb_com01_cd, arb_com02_cd,
     arb_com03_cd, arb_com04_cd, arb_com05_cd, arb_com06_cd, arb_com07_cd,
     arb_com08_cd)
      AND o.order_status_cd IN (ordered_cd, on_hold_cd, pending_cd, pending_rev_cd, in_process_cd,
     future_cd))
    DETAIL
     idx = locateval(indx,1,t_record->pat_cnt,o.person_id,t_record->pat_qual[indx].person_id),
     t_record->pat_qual[idx].ace_arb_ind = 1
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
      AND hes.expect_step_name="Diabetes Dilated Retinal Eye Exam")
    ORDER BY hem.person_id, hem.updt_dt_tm DESC
    HEAD hem.person_id
     idx = locateval(indx,1,t_record->pat_cnt,hem.person_id,t_record->pat_qual[indx].person_id),
     t_record->pat_qual[idx].hm_retinal_dt_tm = cnvtdatetime(hem.updt_dt_tm)
    WITH nocounter
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
      AND hes.expect_step_name="Diabetes Comprehensive Foot Exam")
    ORDER BY hem.person_id, hem.updt_dt_tm DESC
    HEAD hem.person_id
     idx = locateval(indx,1,t_record->pat_cnt,hem.person_id,t_record->pat_qual[indx].person_id),
     t_record->pat_qual[idx].hm_foot_dt_tm = cnvtdatetime(hem.updt_dt_tm)
    WITH nocounter
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
      AND hes.expect_step_name="Pneumococcal")
    ORDER BY hem.person_id, hem.updt_dt_tm DESC
    HEAD hem.person_id
     idx = locateval(indx,1,t_record->pat_cnt,hem.person_id,t_record->pat_qual[indx].person_id)
     IF (cnvtdatetime(hem.updt_dt_tm) > cnvtdatetime(t_record->pat_qual[idx].pneu_vac_dt_tm))
      t_record->pat_qual[idx].pneu_vac_dt_tm = cnvtdatetime(hem.updt_dt_tm)
     ENDIF
    WITH maxcol = 1000
   ;end select
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
     t_line = concat("Quarterly Diabetes Registry for ",t_record->name), col 0, t_line,
     row + 1, t_line = concat(char(9),char(9),char(9),char(9),"Diagnosis Ctiteria",
      char(9),char(9),char(9),char(9),"Hb A1c (Goal <7.0)",
      char(9),char(9),"BP (Goal <130/80)",char(9),char(9),
      char(9),"LDL (Goal <100)",char(9),char(9),"Microalbumin (Goal Malb/cr<30)",
      char(9)), col 0,
     t_line, row + 1, t_line = concat("Patient Name",char(9),"Medical Record #",char(9),
      "Date of Birth",
      char(9),"PCP",char(9),"Diabetes on Problem List",char(9),
      "Lab",char(9),"Med",char(9),"Last office visit",
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
    WITH nocounter, maxcol = 1000, formfeed = none
   ;end select
   IF (findfile("diabetes_registry.xls")=1)
    SET subject_line = concat("Quarterly Diabetes Registry Report for ",t_record->name)
    CALL emailfile("diabetes_registry.xls","diabetes_registry.xls",email_list,subject_line,1)
   ENDIF
   SET t_record->pat_cnt = 0
   SET stat = alterlist(t_record->pat_qual,t_record->pat_cnt)
 ENDFOR
#exit_script
 SET reply->status_data[1].status = "S"
END GO
