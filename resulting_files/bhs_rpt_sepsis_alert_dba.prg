CREATE PROGRAM bhs_rpt_sepsis_alert:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter start date:" = "CURDATE",
  "Enter end date:" = "CURDATE",
  "Select Facility:" = 0,
  "Select location:" = 0
  WITH outdev, begdt, enddt,
  fname, lname
 DECLARE brsa_clean_rs(null) = null
 DECLARE ms_beg_dt_tm = vc WITH protect, constant(concat( $BEGDT," 00:00:00"))
 DECLARE ms_end_dt_tm = vc WITH protect, constant(concat( $ENDDT," 23:59:59"))
 DECLARE mf_facility = f8 WITH protect, constant( $FNAME)
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 DECLARE mf_mrn_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"MRN"))
 DECLARE mf_inpatient_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"INPATIENT"))
 DECLARE mf_daystay_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"DAYSTAY"))
 DECLARE mf_observation_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")
  )
 DECLARE mf_attending_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",333,
   "ATTENDINGPHYSICIAN"))
 DECLARE mf_canceled_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",12030,"CANCELED"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE ms_loc_ind = c1 WITH protect, constant(substring(1,1,reflect(parameter(5,0))))
 DECLARE ms_nomen_list = vc WITH protect, constant("SEPSIS_ALERT")
 DECLARE mf_hfnc_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "HIGHFLOWNASALCANNULA"))
 DECLARE mf_ovn_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "OXYGENVIANONREBREATHER"))
 DECLARE mf_bipap_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"BIPAP"))
 DECLARE mf_vent_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"VENTILATORCPAP"))
 DECLARE mf_cpap_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,"CPAP"))
 DECLARE mf_ordered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",6004,"ORDERED"))
 DECLARE mf_oxysat_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"OXYGENSATURATION")
  )
 DECLARE ml_cnt = i4 WITH protect, noconstant(0)
 DECLARE ml_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_loc2 = i4 WITH protect, noconstant(0)
 DECLARE ml_loc3 = i4 WITH protect, noconstant(0)
 DECLARE listdesc = vc WITH protect, noconstant("")
 DECLARE ml_loop = i4 WITH protect, noconstant(0)
 DECLARE ml_tmp_loc = i4 WITH protect, noconstant(0)
 DECLARE ml_group_cnt = i4 WITH protect, noconstant(0)
 DECLARE mn_disp_ind = i2 WITH protect, noconstant(0)
 DECLARE ewscorecnt = i4 WITH protect, noconstant(0)
 DECLARE ml_loc_pd = i4 WITH protect, noconstant(0)
 DECLARE ml_loc_s1 = i4 WITH protect, noconstant(0)
 DECLARE ml_loc_s2 = i4 WITH protect, noconstant(0)
 DECLARE ml_loc_s3 = i4 WITH protect, noconstant(0)
 DECLARE ml_loc_s4 = i4 WITH protect, noconstant(0)
 DECLARE mn_str_fnd_ind = i2 WITH protect, noconstant(0)
 DECLARE mf_uos_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,"URINEOUTPUTSECTION"))
 DECLARE mf_output_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",93,"OUTPUT"))
 DECLARE mf_urinecount_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"URINECOUNT"))
 DECLARE mf_diapercount_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,"DIAPERCOUNT")
  )
 DECLARE mf_diaperweight_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DIAPERWEIGHT"))
 DECLARE mf_tot_volume = f8 WITH protect, noconstant(0.0)
 FREE RECORD nunit
 RECORD nunit(
   1 n_cnt = i4
   1 list[*]
     2 f_unit_cd = f8
     2 s_unit_name = vc
 ) WITH protect
 FREE RECORD urine
 RECORD urine(
   1 l_cnt = i4
   1 list[*]
     2 f_event_cd = f8
     2 s_event_name = vc
 ) WITH protect
 FREE RECORD patients
 RECORD patients(
   1 n_cnt = i4
   1 list[*]
     2 f_person_id = f8
     2 s_pat_name = vc
     2 f_encntr_id = f8
     2 s_mrn = vc
     2 s_fin = vc
     2 s_encntr_type = vc
     2 s_att_name = vc
     2 f_admit_dt_tm = dq8
     2 f_room_cd = f8
     2 s_room_disp = vc
     2 f_bed_cd = f8
     2 s_bed_disp = vc
     2 f_nunit_cd = f8
     2 s_nunit_disp = vc
     2 l_d_cnt = i4
     2 s_pd_txt = vc
     2 s_r1 = vc
     2 s_r2 = vc
     2 s_r3 = vc
     2 s_qual_txt = vc
     2 data[*]
       3 s_data_name = vc
       3 l_dd_cnt = i4
       3 dd_score[*]
         4 s_score_txt = vc
         4 f_score_val = f8
         4 f_event_cd = f8
         4 l_grouper = i4
 ) WITH protect
 FREE RECORD glist
 RECORD glist(
   1 l_cnt = i4
   1 qual[*]
     2 s_list_name = vc
 ) WITH protect
 FREE RECORD ewevent
 RECORD ewevent(
   1 encntr_id = f8
   1 updt_dt_tm = dq8
   1 updt_id = f8
   1 qual[*]
     2 early_warning_id = f8
     2 active_ind = i4
     2 encntr_id = f8
     2 listtype = vc
     2 event_id = f8
     2 eventtype = vc
     2 event_grouper = f8
     2 range_id = f8
     2 clinical_event_id = f8
     2 event_cd = f8
     2 event_score = i4
     2 vitals_score = i4
     2 labs_score = i4
     2 total_score = i4
     2 insert_dt_tm = dq8
     2 event_end_dt_tm = dq8
 ) WITH protect
 FREE RECORD ewreason
 RECORD ewreason(
   1 l_cnt = i4
   1 qual[*]
     2 f_event_cd = f8
     2 s_reason = vc
 ) WITH protect
 IF (ms_loc_ind="C")
  SELECT INTO "nl:"
   FROM nurse_unit n,
    code_value cv
   PLAN (n
    WHERE (n.loc_facility_cd= $FNAME)
     AND n.active_ind=1)
    JOIN (cv
    WHERE cv.code_value=n.location_cd
     AND cv.code_set=220
     AND cv.active_ind=1
     AND cv.cdf_meaning="NURSEUNIT"
     AND  NOT (cv.display_key IN ("APTU", "SICU", "MICU", "PICU", "HVCC",
    "NICU", "NCCN", "INFC")))
   ORDER BY cv.display
   HEAD REPORT
    nunit->n_cnt = 0
   DETAIL
    nunit->n_cnt = (nunit->n_cnt+ 1), stat = alterlist(nunit->list,nunit->n_cnt), nunit->list[nunit->
    n_cnt].f_unit_cd = cv.code_value,
    nunit->list[nunit->n_cnt].s_unit_name = cv.display
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM code_value cv
   WHERE (cv.code_value= $LNAME)
    AND cv.code_set=220
    AND cv.active_ind=1
    AND cv.cdf_meaning="NURSEUNIT"
   ORDER BY cv.display
   HEAD REPORT
    nunit->n_cnt = 0
   DETAIL
    nunit->n_cnt = (nunit->n_cnt+ 1), stat = alterlist(nunit->list,nunit->n_cnt), nunit->list[nunit->
    n_cnt].f_unit_cd = cv.code_value,
    nunit->list[nunit->n_cnt].s_unit_name = cv.display
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  FROM encntr_alias ea1,
   encntr_alias ea2,
   encntr_domain ed,
   encntr_loc_hist elh,
   encounter e,
   person p
  PLAN (ed
   WHERE ((ed.loc_facility_cd+ 0)= $FNAME)
    AND expand(ml_cnt,1,nunit->n_cnt,ed.loc_nurse_unit_cd,nunit->list[ml_cnt].f_unit_cd)
    AND ((ed.active_ind+ 0)=1)
    AND ed.beg_effective_dt_tm < cnvtdatetime(ms_end_dt_tm)
    AND ed.beg_effective_dt_tm > cnvtdatetime(ms_beg_dt_tm))
   JOIN (e
   WHERE e.encntr_id=ed.encntr_id
    AND e.encntr_type_cd IN (mf_inpatient_cd, mf_daystay_cd, mf_observation_cd)
    AND e.disch_dt_tm = null
    AND e.active_ind=1)
   JOIN (elh
   WHERE elh.encntr_id=e.encntr_id
    AND ((elh.active_ind+ 0)=1)
    AND ((elh.loc_nurse_unit_cd+ 0)=ed.loc_nurse_unit_cd)
    AND elh.beg_effective_dt_tm <= cnvtdatetime(ms_end_dt_tm))
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (ea1
   WHERE ea1.encntr_id=outerjoin(e.encntr_id)
    AND ea1.active_ind=outerjoin(1)
    AND ea1.encntr_alias_type_cd=outerjoin(mf_fin_cd))
   JOIN (ea2
   WHERE ea2.encntr_id=outerjoin(e.encntr_id)
    AND ea2.active_ind=outerjoin(1)
    AND ea2.encntr_alias_type_cd=outerjoin(mf_mrn_cd))
  ORDER BY e.encntr_id, p.person_id
  HEAD REPORT
   patients->n_cnt = 0
  HEAD e.encntr_id
   patients->n_cnt = (patients->n_cnt+ 1), stat = alterlist(patients->list,patients->n_cnt), patients
   ->list[patients->n_cnt].f_person_id = p.person_id,
   patients->list[patients->n_cnt].f_encntr_id = e.encntr_id, patients->list[patients->n_cnt].
   s_pat_name = trim(p.name_full_formatted), patients->list[patients->n_cnt].s_fin = trim(ea1.alias),
   patients->list[patients->n_cnt].s_mrn = trim(ea2.alias), patients->list[patients->n_cnt].
   f_admit_dt_tm = e.reg_dt_tm, patients->list[patients->n_cnt].f_room_cd = ed.loc_room_cd,
   patients->list[patients->n_cnt].f_bed_cd = ed.loc_bed_cd, patients->list[patients->n_cnt].
   s_room_disp = uar_get_code_display(ed.loc_room_cd), patients->list[patients->n_cnt].s_bed_disp =
   uar_get_code_display(ed.loc_bed_cd),
   patients->list[patients->n_cnt].f_nunit_cd = ed.loc_nurse_unit_cd, patients->list[patients->n_cnt]
   .s_nunit_disp = uar_get_code_display(ed.loc_nurse_unit_cd)
   CASE (e.encntr_type_cd)
    OF mf_inpatient_cd:
     patients->list[patients->n_cnt].s_encntr_type = "INPATIENT"
    OF mf_daystay_cd:
     patients->list[patients->n_cnt].s_encntr_type = "DAYSTAY"
    OF mf_observation_cd:
     patients->list[patients->n_cnt].s_encntr_type = "OBSERVATION"
   ENDCASE
  DETAIL
   CALL echo(e.encntr_id)
  WITH nocounter, orahintcbo("LEADING(ED,E,P,EA1,EA2,ELH)","INDEX(ED XIE1ENCNTR_DOMAIN)",
    "INDEX(E XPKENCOUNTER)","INDEX(P XPKPERSON)","INDEX(EA1 XIE2ENCNTR_ALIAS)",
    "INDEX(EA2 XIE2ENCNTR_ALIAS)","INDEX(ELH XIE1ENCNTR_LOC_HIST)","USE_NL(E)","USE_NL(P)",
    "USE_NL(EA1)",
    "USE_NL(EA2)","USE_NL(ELH)")
 ;end select
 SELECT INTO "nl:"
  FROM encntr_prsnl_reltn epr,
   prsnl p
  PLAN (epr
   WHERE expand(ml_cnt,1,patients->n_cnt,epr.encntr_id,patients->list[ml_cnt].f_encntr_id)
    AND epr.encntr_prsnl_r_cd=mf_attending_cd
    AND epr.expiration_ind=0
    AND epr.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (p
   WHERE epr.prsnl_person_id=p.person_id
    AND p.physician_ind=1)
  DETAIL
   ml_loc = locateval(ml_cnt,1,patients->n_cnt,epr.encntr_id,patients->list[ml_cnt].f_encntr_id)
   IF (ml_loc > 0)
    patients->list[ml_cnt].s_att_name = trim(p.name_full_formatted)
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM bhs_nomen_list bnl,
   nomenclature n,
   problem p
  PLAN (bnl
   WHERE bnl.nomen_list=ms_nomen_list
    AND bnl.active_ind=1)
   JOIN (n
   WHERE n.nomenclature_id=bnl.nomenclature_id
    AND n.active_ind=1
    AND n.beg_effective_dt_tm < sysdate
    AND n.end_effective_dt_tm > sysdate)
   JOIN (p
   WHERE p.nomenclature_id=n.nomenclature_id
    AND expand(ml_loc,1,patients->n_cnt,p.person_id,patients->list[ml_loc].f_person_id)
    AND p.life_cycle_status_cd != mf_canceled_cd
    AND p.active_ind=1
    AND p.beg_effective_dt_tm < sysdate
    AND p.end_effective_dt_tm > sysdate)
  ORDER BY p.person_id
  HEAD p.person_id
   ml_loc = locateval(ml_loc,1,patients->n_cnt,p.person_id,patients->list[ml_loc].f_person_id)
   IF (ml_loc > 0)
    IF ((patients->list[ml_loc].l_d_cnt > 0))
     ml_loc2 = locateval(ml_loc2,1,patients->list[ml_loc].l_d_cnt,"PD",patients->list[ml_loc].data[
      ml_loc2].s_data_name)
     IF (ml_loc2=0)
      patients->list[ml_loc].l_d_cnt = (patients->list[ml_loc].l_d_cnt+ 1), ml_loc2 = patients->list[
      ml_loc].l_d_cnt, stat = alterlist(patients->list[ml_loc].data,patients->list[ml_loc].l_d_cnt),
      patients->list[ml_loc].data[patients->list[ml_loc].l_d_cnt].s_data_name = "PD"
     ENDIF
    ELSE
     patients->list[ml_loc].l_d_cnt = (patients->list[ml_loc].l_d_cnt+ 1), ml_loc2 = patients->list[
     ml_loc].l_d_cnt, stat = alterlist(patients->list[ml_loc].data,patients->list[ml_loc].l_d_cnt),
     patients->list[ml_loc].data[patients->list[ml_loc].l_d_cnt].s_data_name = "PD"
    ENDIF
   ENDIF
  DETAIL
   IF ((patients->list[ml_loc].data[ml_loc2].l_dd_cnt > 0))
    ml_loc3 = locateval(ml_loc3,1,patients->list[ml_loc].data[ml_loc2].l_dd_cnt,n.nomenclature_id,
     patients->list[ml_loc].data[ml_loc2].dd_score[ml_loc3].f_score_val)
    IF (ml_loc3=0)
     patients->list[ml_loc].data[ml_loc2].l_dd_cnt = (patients->list[ml_loc].data[ml_loc2].l_dd_cnt+
     1), stat = alterlist(patients->list[ml_loc].data[ml_loc2].dd_score,patients->list[ml_loc].data[
      ml_loc2].l_dd_cnt), patients->list[ml_loc].data[ml_loc2].dd_score[patients->list[ml_loc].data[
     ml_loc2].l_dd_cnt].s_score_txt = n.source_string,
     patients->list[ml_loc].data[ml_loc2].dd_score[patients->list[ml_loc].data[ml_loc2].l_dd_cnt].
     f_score_val = n.nomenclature_id
    ENDIF
   ELSE
    patients->list[ml_loc].data[ml_loc2].l_dd_cnt = (patients->list[ml_loc].data[ml_loc2].l_dd_cnt+ 1
    ), stat = alterlist(patients->list[ml_loc].data[ml_loc2].dd_score,patients->list[ml_loc].data[
     ml_loc2].l_dd_cnt), patients->list[ml_loc].data[ml_loc2].dd_score[patients->list[ml_loc].data[
    ml_loc2].l_dd_cnt].s_score_txt = n.source_string,
    patients->list[ml_loc].data[ml_loc2].dd_score[patients->list[ml_loc].data[ml_loc2].l_dd_cnt].
    f_score_val = n.nomenclature_id
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM bhs_nomen_list bnl,
   nomenclature n,
   diagnosis d
  PLAN (bnl
   WHERE bnl.nomen_list=ms_nomen_list
    AND bnl.active_ind=1)
   JOIN (n
   WHERE n.nomenclature_id=bnl.nomenclature_id
    AND n.active_ind=1
    AND n.beg_effective_dt_tm < sysdate
    AND n.end_effective_dt_tm > sysdate)
   JOIN (d
   WHERE d.nomenclature_id=n.nomenclature_id
    AND expand(ml_loc,1,patients->n_cnt,d.person_id,patients->list[ml_loc].f_person_id)
    AND d.active_ind=1
    AND d.beg_effective_dt_tm < sysdate
    AND d.end_effective_dt_tm > sysdate)
  ORDER BY d.person_id
  HEAD d.person_id
   ml_loc = locateval(ml_loc,1,patients->n_cnt,d.person_id,patients->list[ml_loc].f_person_id)
   IF (ml_loc > 0)
    IF ((patients->list[ml_loc].l_d_cnt > 0))
     ml_loc2 = locateval(ml_loc2,1,patients->list[ml_loc].l_d_cnt,"PD",patients->list[ml_loc].data[
      ml_loc2].s_data_name)
     IF (ml_loc2=0)
      patients->list[ml_loc].l_d_cnt = (patients->list[ml_loc].l_d_cnt+ 1), ml_loc2 = patients->list[
      ml_loc].l_d_cnt, stat = alterlist(patients->list[ml_loc].data,patients->list[ml_loc].l_d_cnt),
      patients->list[ml_loc].data[patients->list[ml_loc].l_d_cnt].s_data_name = "PD"
     ENDIF
    ELSE
     patients->list[ml_loc].l_d_cnt = (patients->list[ml_loc].l_d_cnt+ 1), ml_loc2 = patients->list[
     ml_loc].l_d_cnt, stat = alterlist(patients->list[ml_loc].data,patients->list[ml_loc].l_d_cnt),
     patients->list[ml_loc].data[patients->list[ml_loc].l_d_cnt].s_data_name = "PD"
    ENDIF
   ENDIF
  DETAIL
   IF ((patients->list[ml_loc].data[ml_loc2].l_dd_cnt > 0))
    ml_loc3 = locateval(ml_loc3,1,patients->list[ml_loc].data[ml_loc2].l_dd_cnt,n.nomenclature_id,
     patients->list[ml_loc].data[ml_loc2].dd_score[ml_loc3].f_score_val)
    IF (ml_loc3=0)
     patients->list[ml_loc].data[ml_loc2].l_dd_cnt = (patients->list[ml_loc].data[ml_loc2].l_dd_cnt+
     1), stat = alterlist(patients->list[ml_loc].data[ml_loc2].dd_score,patients->list[ml_loc].data[
      ml_loc2].l_dd_cnt), patients->list[ml_loc].data[ml_loc2].dd_score[patients->list[ml_loc].data[
     ml_loc2].l_dd_cnt].s_score_txt = n.source_string,
     patients->list[ml_loc].data[ml_loc2].dd_score[patients->list[ml_loc].data[ml_loc2].l_dd_cnt].
     f_score_val = n.nomenclature_id
    ENDIF
   ELSE
    patients->list[ml_loc].data[ml_loc2].l_dd_cnt = (patients->list[ml_loc].data[ml_loc2].l_dd_cnt+ 1
    ), stat = alterlist(patients->list[ml_loc].data[ml_loc2].dd_score,patients->list[ml_loc].data[
     ml_loc2].l_dd_cnt), patients->list[ml_loc].data[ml_loc2].dd_score[patients->list[ml_loc].data[
    ml_loc2].l_dd_cnt].s_score_txt = n.source_string,
    patients->list[ml_loc].data[ml_loc2].dd_score[patients->list[ml_loc].data[ml_loc2].l_dd_cnt].
    f_score_val = n.nomenclature_id
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM bhs_event_cd_list becl
  WHERE becl.listkey="SWSL*"
  ORDER BY becl.listkey
  HEAD becl.listkey
   glist->l_cnt = (glist->l_cnt+ 1), stat = alterlist(glist->qual,glist->l_cnt), glist->qual[glist->
   l_cnt].s_list_name = becl.listkey
  WITH nocounter
 ;end select
 CALL echorecord(glist)
 SELECT INTO "nl:"
  event_disp = uar_get_code_display(vese.event_cd), vese.event_cd
  FROM v500_event_set_code vesc2,
   v500_event_set_canon vesc,
   v500_event_set_canon vesc1,
   v500_event_set_explode vese
  PLAN (vesc2
   WHERE vesc2.event_set_name="IO")
   JOIN (vesc
   WHERE vesc.parent_event_set_cd=vesc2.event_set_cd
    AND vesc.event_set_cd=mf_output_cd)
   JOIN (vesc1
   WHERE vesc1.parent_event_set_cd=vesc.event_set_cd
    AND vesc1.event_set_cd=mf_uos_cd)
   JOIN (vese
   WHERE vese.event_set_cd=vesc1.event_set_cd
    AND  NOT (vese.event_cd IN (mf_urinecount_cd, mf_diapercount_cd, mf_diaperweight_cd)))
  HEAD REPORT
   urine->l_cnt = 0
  DETAIL
   urine->l_cnt = (urine->l_cnt+ 1), stat = alterlist(urine->list,urine->l_cnt), urine->list[urine->
   l_cnt].f_event_cd = vese.event_cd,
   urine->list[urine->l_cnt].s_event_name = event_disp
  WITH nocounter
 ;end select
 CALL echorecord(urine)
 FOR (ml_loop = 1 TO glist->l_cnt)
   SET listdesc = glist->qual[ml_loop].s_list_name
   CALL echo(concat("List is :",listdesc))
   FOR (ml_ploop = 1 TO patients->n_cnt)
     CALL brsa_clean_rs(null)
     SET ewscorecnt = 0
     SELECT INTO "NL:"
      e.event_cd, ce.event_end_dt_tm
      FROM bhs_event_cd_list e,
       clinical_event ce
      PLAN (e
       WHERE e.listkey IN (listdesc)
        AND e.active_ind=1)
       JOIN (ce
       WHERE (ce.encntr_id=patients->list[ml_ploop].f_encntr_id)
        AND ce.event_cd=e.event_cd
        AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
        AND ce.result_status_cd IN (mf_altered_cd, mf_modified_cd, mf_auth_cd)
        AND ce.view_level=1)
      ORDER BY e.event_cd, ce.event_end_dt_tm DESC
      HEAD REPORT
       ewevent->encntr_id = ce.encntr_id
      HEAD e.event_cd
       IF (isnumeric(ce.result_val))
        ewscorecnt = (ewscorecnt+ 1), stat = alterlist(ewevent->qual,ewscorecnt), ewevent->qual[
        ewscorecnt].active_ind = 1,
        ewevent->qual[ewscorecnt].event_id = ce.event_id, ewevent->qual[ewscorecnt].clinical_event_id
         = ce.clinical_event_id, ewevent->qual[ewscorecnt].event_cd = ce.event_cd,
        ewevent->qual[ewscorecnt].event_grouper = e.grouper_id, ewevent->qual[ewscorecnt].listtype =
        e.grouper
       ENDIF
      WITH nocounter
     ;end select
     CALL echo(patients->list[ml_ploop].s_pat_name)
     CALL echorecord(ewevent)
     IF (ewscorecnt > 0)
      EXECUTE bhs_eks_early_warning_score
      CALL echorecord(ewevent)
      CALL echorecord(ewreason)
      SELECT INTO "NL:"
       event_grouper = ewevent->qual[d.seq].event_grouper
       FROM (dummyt d  WITH seq = size(ewevent->qual,5))
       PLAN (d
        WHERE (ewevent->qual[d.seq].active_ind=1)
         AND (ewevent->qual[d.seq].event_score > 0))
       ORDER BY event_grouper
       HEAD event_grouper
        ml_group_cnt = 0
       DETAIL
        ml_group_cnt = (ml_group_cnt+ 1)
        IF (ml_group_cnt > 1)
         ewevent->qual[d.seq].event_score = 0
        ENDIF
       WITH nocounter
      ;end select
      CALL echo("EVENT SCORE AFTER MOD")
      CALL echorecord(ewevent)
      FOR (ml_loc1 = 1 TO size(ewevent->qual,5))
        IF ((ewevent->qual[ml_loc1].event_score > 0))
         SET mn_store_ind = 1
         IF (listdesc="SWSL4")
          IF ((ewevent->qual[ml_loc1].event_cd=mf_oxysat_cd))
           SELECT INTO "nl:"
            FROM orders o
            WHERE (o.person_id=patients->list[ml_ploop].f_person_id)
             AND o.catalog_cd IN (mf_hfnc_cd, mf_ovn_cd, mf_bipap_cd, mf_vent_cd, mf_cpap_cd)
             AND (o.encntr_id=patients->list[ml_ploop].f_encntr_id)
             AND o.active_ind=1
             AND o.template_order_id=0
             AND o.orig_ord_as_flag=0
             AND o.order_status_cd=mf_ordered_cd
            WITH nocounter
           ;end select
           IF (curqual=0)
            SET mn_store_ind = 0
           ENDIF
          ENDIF
         ENDIF
         SET ml_loc2 = locateval(ml_loc2,1,patients->list[ml_ploop].l_d_cnt,listdesc,patients->list[
          ml_ploop].data[ml_loc2].s_data_name)
         IF (ml_loc2=0)
          SET patients->list[ml_ploop].l_d_cnt = (patients->list[ml_ploop].l_d_cnt+ 1)
          SET ml_loc2 = patients->list[ml_ploop].l_d_cnt
          SET stat = alterlist(patients->list[ml_ploop].data,ml_loc2)
          SET patients->list[ml_ploop].data[ml_loc2].s_data_name = listdesc
         ENDIF
         IF (mn_store_ind != 0)
          SET patients->list[ml_ploop].data[ml_loc2].l_dd_cnt = (patients->list[ml_ploop].data[
          ml_loc2].l_dd_cnt+ 1)
          SET ml_tmp_loc = patients->list[ml_ploop].data[ml_loc2].l_dd_cnt
          SET stat = alterlist(patients->list[ml_ploop].data[ml_loc2].dd_score,ml_tmp_loc)
          SET patients->list[ml_ploop].data[ml_loc2].dd_score[ml_tmp_loc].f_event_cd = ewevent->qual[
          ml_loc1].event_cd
          SET patients->list[ml_ploop].data[ml_loc2].dd_score[ml_tmp_loc].f_score_val = ewevent->
          qual[ml_loc1].event_score
          SET ml_loc3 = locateval(ml_loc3,1,ewreason->l_cnt,ewevent->qual[ml_loc1].event_cd,ewreason
           ->qual[ml_loc3].f_event_cd)
          SET patients->list[ml_ploop].data[ml_loc2].dd_score[ml_tmp_loc].s_score_txt = ewreason->
          qual[ml_loc3].s_reason
          SET patients->list[ml_ploop].data[ml_loc2].dd_score[ml_tmp_loc].l_grouper = ewevent->qual[
          ml_loc1].event_grouper
         ENDIF
        ENDIF
      ENDFOR
     ENDIF
     IF (listdesc="SWSL4")
      SET mf_tot_volume = 0
      SELECT INTO "nl:"
       FROM ce_intake_output_result c,
        clinical_event ce
       PLAN (c
        WHERE (c.encntr_id=patients->list[ml_ploop].f_encntr_id)
         AND expand(ml_loc1,1,urine->l_cnt,c.reference_event_cd,urine->list[ml_loc1].f_event_cd)
         AND c.io_end_dt_tm >= cnvtlookbehind("24, H",sysdate)
         AND c.valid_until_dt_tm >= sysdate)
        JOIN (ce
        WHERE ce.event_id=c.event_id
         AND ce.valid_until_dt_tm >= sysdate
         AND ce.result_status_cd IN (
        (SELECT
         cv.code_value
         FROM code_value cv
         WHERE cv.code_set=8
          AND  NOT (cv.display_key IN ("NOTDONE", "INERROR", "CANCELED", "INLAB", "INPROGRESS",
         "REJECTED", "PRELIMINARY", "UNKNOWN")))))
       HEAD REPORT
        mf_tot_volume = 0
       DETAIL
        mf_tot_volume = (mf_tot_volume+ c.io_volume)
       WITH nocounter
      ;end select
      IF (mf_tot_volume < 960.0)
       SET ml_loc2 = locateval(ml_loc2,1,patients->list[ml_ploop].l_d_cnt,listdesc,patients->list[
        ml_ploop].data[ml_loc2].s_data_name)
       IF (ml_loc2=0)
        SET patients->list[ml_ploop].l_d_cnt = (patients->list[ml_ploop].l_d_cnt+ 1)
        SET ml_loc2 = patients->list[ml_ploop].l_d_cnt
        SET stat = alterlist(patients->list[ml_ploop].data,ml_loc2)
        SET patients->list[ml_ploop].data[ml_loc2].s_data_name = listdesc
       ENDIF
       SET patients->list[ml_ploop].data[ml_loc2].l_dd_cnt = (patients->list[ml_ploop].data[ml_loc2].
       l_dd_cnt+ 1)
       SET ml_tmp_loc = patients->list[ml_ploop].data[ml_loc2].l_dd_cnt
       SET stat = alterlist(patients->list[ml_ploop].data[ml_loc2].dd_score,ml_tmp_loc)
       SET patients->list[ml_ploop].data[ml_loc2].dd_score[ml_tmp_loc].f_event_cd = 0
       SET patients->list[ml_ploop].data[ml_loc2].dd_score[ml_tmp_loc].f_score_val = 1
       SET patients->list[ml_ploop].data[ml_loc2].dd_score[ml_tmp_loc].s_score_txt = concat(
        "Urine Output(Total) less than 960ml (",trim(cnvtstring(mf_tot_volume)),"ml)")
       SET patients->list[ml_ploop].data[ml_loc2].dd_score[ml_tmp_loc].l_grouper = 100
      ENDIF
     ENDIF
   ENDFOR
 ENDFOR
 FOR (ml_loc = 1 TO patients->n_cnt)
   IF ((patients->list[ml_loc].l_d_cnt > 0))
    SET ml_loc_pd = locateval(ml_loop,1,patients->list[ml_loc].l_d_cnt,"PD",patients->list[ml_loc].
     data[ml_loop].s_data_name)
    SET ml_loc_s1 = locateval(ml_loop,1,patients->list[ml_loc].l_d_cnt,"SWSL1",patients->list[ml_loc]
     .data[ml_loop].s_data_name)
    SET ml_loc_s2 = locateval(ml_loop,1,patients->list[ml_loc].l_d_cnt,"SWSL2",patients->list[ml_loc]
     .data[ml_loop].s_data_name)
    SET ml_loc_s3 = locateval(ml_loop,1,patients->list[ml_loc].l_d_cnt,"SWSL3",patients->list[ml_loc]
     .data[ml_loop].s_data_name)
    SET ml_loc_s4 = locateval(ml_loop,1,patients->list[ml_loc].l_d_cnt,"SWSL4",patients->list[ml_loc]
     .data[ml_loop].s_data_name)
    IF (ml_loc_pd > 0
     AND ml_loc_s1 > 0)
     IF (size(patients->list[ml_loc].data[ml_loc_pd].dd_score,5) > 0
      AND size(patients->list[ml_loc].data[ml_loc_s1].dd_score,5) > 0)
      SET mn_disp_ind = 1
      FOR (ml_loop = 1 TO size(patients->list[ml_loc].data[ml_loc_pd].dd_score,5))
        SET mn_str_fnd_ind = findstring(patients->list[ml_loc].data[ml_loc_pd].dd_score[ml_loop].
         s_score_txt,patients->list[ml_loc].s_qual_txt,1,0)
        IF (mn_str_fnd_ind=0)
         SET patients->list[ml_loc].s_qual_txt = concat(patients->list[ml_loc].s_qual_txt,", ",
          patients->list[ml_loc].data[ml_loc_pd].dd_score[ml_loop].s_score_txt)
        ENDIF
        SET patients->list[ml_loc].s_r1 = concat(patients->list[ml_loc].s_r1,evaluate(ml_loop,1," ",
          ", "),patients->list[ml_loc].data[ml_loc_pd].dd_score[ml_loop].s_score_txt)
      ENDFOR
      FOR (ml_loop = 1 TO size(patients->list[ml_loc].data[ml_loc_s1].dd_score,5))
        SET mn_str_fnd_ind = findstring(patients->list[ml_loc].data[ml_loc_s1].dd_score[ml_loop].
         s_score_txt,patients->list[ml_loc].s_qual_txt,1,0)
        IF (mn_str_fnd_ind=0)
         SET patients->list[ml_loc].s_qual_txt = concat(patients->list[ml_loc].s_qual_txt,", ",
          patients->list[ml_loc].data[ml_loc_s1].dd_score[ml_loop].s_score_txt)
        ENDIF
        SET patients->list[ml_loc].s_r1 = concat(patients->list[ml_loc].s_r1,", ",patients->list[
         ml_loc].data[ml_loc_s1].dd_score[ml_loop].s_score_txt)
      ENDFOR
     ENDIF
    ENDIF
    IF (ml_loc_s2 > 0)
     IF (size(patients->list[ml_loc].data[ml_loc_s2].dd_score,5) > 1)
      SET mn_disp_ind = 1
      FOR (ml_loop = 1 TO size(patients->list[ml_loc].data[ml_loc_s2].dd_score,5))
        SET mn_str_fnd_ind = findstring(patients->list[ml_loc].data[ml_loc_s2].dd_score[ml_loop].
         s_score_txt,patients->list[ml_loc].s_qual_txt,1,0)
        IF (mn_str_fnd_ind=0)
         SET patients->list[ml_loc].s_qual_txt = concat(patients->list[ml_loc].s_qual_txt,", ",
          patients->list[ml_loc].data[ml_loc_s2].dd_score[ml_loop].s_score_txt)
        ENDIF
        SET patients->list[ml_loc].s_r2 = concat(patients->list[ml_loc].s_r2,evaluate(ml_loop,1," ",
          ", "),patients->list[ml_loc].data[ml_loc_s2].dd_score[ml_loop].s_score_txt)
      ENDFOR
     ENDIF
    ENDIF
    IF (ml_loc_s3 > 0
     AND ml_loc_s4 > 0)
     IF (size(patients->list[ml_loc].data[ml_loc_s3].dd_score,5) > 0
      AND size(patients->list[ml_loc].data[ml_loc_s4].dd_score,5) > 0)
      SET mn_disp_ind = 1
      FOR (ml_loop = 1 TO size(patients->list[ml_loc].data[ml_loc_s3].dd_score,5))
        SET mn_str_fnd_ind = findstring(patients->list[ml_loc].data[ml_loc_s3].dd_score[ml_loop].
         s_score_txt,patients->list[ml_loc].s_qual_txt,1,0)
        IF (mn_str_fnd_ind=0)
         SET patients->list[ml_loc].s_qual_txt = concat(patients->list[ml_loc].s_qual_txt,", ",
          patients->list[ml_loc].data[ml_loc_s3].dd_score[ml_loop].s_score_txt)
        ENDIF
        SET patients->list[ml_loc].s_r3 = concat(patients->list[ml_loc].s_r3,evaluate(ml_loop,1," ",
          ", "),patients->list[ml_loc].data[ml_loc_s3].dd_score[ml_loop].s_score_txt)
      ENDFOR
      FOR (ml_loop = 1 TO size(patients->list[ml_loc].data[ml_loc_s4].dd_score,5))
        SET mn_str_fnd_ind = findstring(patients->list[ml_loc].data[ml_loc_s4].dd_score[ml_loop].
         s_score_txt,patients->list[ml_loc].s_qual_txt,1,0)
        IF (mn_str_fnd_ind=0)
         SET patients->list[ml_loc].s_qual_txt = concat(patients->list[ml_loc].s_qual_txt,", ",
          patients->list[ml_loc].data[ml_loc_s4].dd_score[ml_loop].s_score_txt)
        ENDIF
        SET patients->list[ml_loc].s_r3 = concat(patients->list[ml_loc].s_r3,", ",patients->list[
         ml_loc].data[ml_loc_s4].dd_score[ml_loop].s_score_txt)
      ENDFOR
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 CALL echorecord(patients)
 IF (mn_disp_ind=1)
  SELECT INTO  $OUTDEV
   patient_name = trim(substring(1,100,patients->list[d.seq].s_pat_name)), nurse_unit = trim(
    substring(1,100,patients->list[d.seq].s_nunit_disp)), room = trim(substring(1,100,patients->list[
     d.seq].s_room_disp)),
   bed = trim(substring(1,100,patients->list[d.seq].s_bed_disp)), fin = trim(substring(1,100,patients
     ->list[d.seq].s_fin)), mrn = trim(substring(1,100,patients->list[d.seq].s_mrn)),
   attending_md = trim(substring(1,100,patients->list[d.seq].s_att_name)), admit_date = format(
    cnvtdatetime(patients->list[d.seq].f_admit_dt_tm),"dd-mmm-yyyy hh:mm:ss;;d"), category_1 = trim(
    substring(1,3000,patients->list[d.seq].s_r1)),
   category_2 = trim(substring(1,3000,patients->list[d.seq].s_r2)), category_3 = trim(substring(1,
     3000,patients->list[d.seq].s_r3))
   FROM (dummyt d  WITH seq = patients->n_cnt)
   PLAN (d
    WHERE d.seq > 0
     AND ((size(trim(patients->list[d.seq].s_r1)) > 0) OR (((size(trim(patients->list[d.seq].s_r2))
     > 0) OR (size(trim(patients->list[d.seq].s_r3)) > 0)) )) )
   ORDER BY nurse_unit, room, bed,
    admit_date
   WITH nocounter, maxcol = 20000, format,
    separator = " ", memsort
  ;end select
 ELSE
  SELECT INTO  $OUTDEV
   FROM dummyt
   HEAD REPORT
    msg1 = "Report finished successfully. No patients qualified.", col 0,
    "{PS/792 0 translate 90 rotate/}",
    y_pos = 18, row + 1, "{F/1}{CPI/7}",
    CALL print(calcpos(36,(y_pos+ 0))), msg1
   WITH dio = 08
  ;end select
 ENDIF
 GO TO exit_script
 SUBROUTINE brsa_clean_rs(null)
   SET ewevent->encntr_id = 0
   SET ewevent->updt_dt_tm = 0
   SET ewevent->updt_id = 0
   SET stat = alterlist(ewevent->qual,0)
   SET ewreason->l_cnt = 0
   SET stat = alterlist(ewreason->qual,0)
 END ;Subroutine
#exit_script
END GO
