CREATE PROGRAM bhs_rpt_ticket_to_ride:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Account #" = ""
  WITH outdev, pat_acct
 DECLARE mf_bloodpressurevenipuncture = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "BLOODPRESSUREVENIPUNCTURE")), protect
 DECLARE mf_wearing_bpv_band = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "WEARINGBPVENIPUNCTURERESTRICTIONBAND")), protect
 DECLARE found_graf_pif = i1 WITH noconstant(0), protect
 DECLARE found_fall_risk = i1 WITH noconstant(0), protect
 DECLARE tracheostomysize = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TRACHEOSTOMYSIZE")),
 protect
 DECLARE othertracheostomycomments = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "OTHERTRACHEOSTOMYCOMMENTS")), protect
 DECLARE trachairwaytype = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TRACHAIRWAYTYPE")),
 protect
 DECLARE result_fall_risk = vc WITH protect
 DECLARE label_fall_risk = vc WITH protect
 DECLARE neurologicalsymptoms = f8 WITH constant(uar_get_code_by("DESCRIPTION",72,
   "Neurological Symptoms")), protect
 DECLARE fallrisklevel = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"FALLRISKLEVEL")), protect
 DECLARE totalfallsriskscore = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"TOTALFALLSRISKSCORE"
   )), protect
 DECLARE test_size = f8 WITH protect
 DECLARE authverified = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"AUTHVERIFIED")), protect
 DECLARE altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE modified_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE cild_reltn = f8 WITH constant(uar_get_code_by("DESCRIPTION",24,"Child")), protect
 DECLARE attendingphysician = f8 WITH constant(uar_get_code_by("DISPLAYKEY",333,"ATTENDINGPHYSICIAN")
  ), protect
 DECLARE active_allergy = f8 WITH constant(uar_get_code_by("DISPLAYKEY",12025,"ACTIVE")), protect
 DECLARE ambulation_devices = vc WITH noconstant("XXXX"), protect
 DECLARE last_void_result = vc WITH protect
 DECLARE is_fall_risk = vc WITH protect
 DECLARE graf_pif = i4 WITH protect
 DECLARE falls_score_int = i4 WITH protect
 DECLARE orientation_psych = vc WITH protect
 DECLARE alertness = vc WITH protect
 DECLARE rxmnemonic = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6011,"RXMNEMONIC")), protect
 DECLARE examordered_dept = f8 WITH constant(uar_get_code_by("DISPLAYKEY",14281,"EXAMORDERED")),
 protect
 DECLARE ordered_dept = f8 WITH constant(uar_get_code_by("MEANING",14281,"ORDERED")), protect
 DECLARE diagnosticcardiaccathscheduledfor = f8 WITH constant(uar_get_code_by("DISPLAYKEY",200,
   "DIAGNOSTICCARDIACCATHSCHEDULEDFOR")), protect
 DECLARE cardiopulmonary_clincat = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16389,
   "CARDIOPULMONARY")), protect
 DECLARE diagnosticimaging_clincat = f8 WITH constant(uar_get_code_by("DISPLAYKEY",16389,
   "DIAGNOSTICIMAGING")), protect
 DECLARE psychosocialed = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PSYCHOSOCIALED")),
 protect
 DECLARE nursing = f8 WITH constant(uar_get_code_by("DISPLAYKEY",259571,"NURSING")), protect
 DECLARE communicationbarriers = f8 WITH constant(uar_get_code_by("DESCRIPTION",72,
   "Communication Barriers Grid")), protect
 DECLARE fallsriskscore = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"FALLSRISKSCORE")),
 protect
 DECLARE grafpifscore = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"GRAFPIFSCORE")), protect
 DECLARE visitorrestrictions = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"VISITORRESTRICTIONS"
   )), protect
 DECLARE mobilityassistance = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"MOBILITYASSISTANCE")),
 protect
 DECLARE mobility = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"MOBILITY")), protect
 DECLARE sensorydeficits = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"SENSORYDEFICITS")),
 protect
 DECLARE assistivedevices = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"ASSISTIVEDEVICES")),
 protect
 DECLARE devicesforambulation = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "DEVICESFORAMBULATION")), protect
 DECLARE painscalescore = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PAINSCALESCORE")),
 protect
 DECLARE painintensity = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PAININTENSITY")), protect
 DECLARE neurologicaled = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"NEUROLOGICALED")),
 protect
 DECLARE bladderdistention = f8 WITH constant(uar_get_code_by("DESCRIPTION",72,"Bladder distention")),
 protect
 DECLARE lastvoid = f8 WITH constant(uar_get_code_by("DESCRIPTION",72,"Last Void")), protect
 DECLARE interpreterneeded = f8 WITH constant(uar_get_code_by("DESCRIPTION",72,"Interpreter Needed")),
 protect
 DECLARE languagespokenv001 = f8 WITH constant(uar_get_code_by("DESCRIPTION",72,
   "Language Spoken v001")), protect
 DECLARE psychosocialnew = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"PSYCHOSOCIALNEW")),
 protect
 DECLARE psychosocial = f8 WITH constant(uar_get_code_by("DESCRIPTION",72,"Psychosocial")), protect
 DECLARE levelofconsciousness = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "LEVELOFCONSCIOUSNESS")), protect
 DECLARE orientatedtopersonplacetime = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "ORIENTATEDTOPERSONPLACETIME")), protect
 DECLARE mf_pt_has_med_inf_pump = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "DOESPTHAVEAMEDICATIONINFUSIONPUMP"))
 CALL echo(build("orientatedtopersonplacetime =",orientatedtopersonplacetime))
 CALL echo(build("levelofconsciousness =",levelofconsciousness))
 DECLARE mf_cs200_isolation_covid = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",200,
   "ISOLATIONCOVID"))
 CALL echo(build2("mf_CS200_ISOLATION_COVID: ",mf_cs200_isolation_covid))
 DECLARE noninvascardiology_act = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,
   "NONINVASIVECARDIOLOGYTXPROCEDURES")), protect
 DECLARE pulmlabtxprocedures_act = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,
   "PULMLABTXPROCEDURES")), protect
 DECLARE isolation = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"ISOLATION")), protect
 DECLARE codestatus_act = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"CODESTATUS")), protect
 DECLARE continued = vc WITH protect
 DECLARE a_prt = i4 WITH protect
 DECLARE b_prt = i4 WITH protect
 DECLARE c_prt = i4 WITH protect
 DECLARE d_prt = i4 WITH protect
 DECLARE e_prt = i4 WITH protect
 DECLARE f_prt = i4 WITH protect
 DECLARE g_prt = i4 WITH protect
 DECLARE h_prt = i4 WITH protect
 DECLARE i_prt = i4 WITH protect
 DECLARE ultrasound_subact = f8 WITH constant(uar_get_code_by("DISPLAYKEY",5801,"ULTRASOUND")),
 protect
 DECLARE vascularlab_subact = f8 WITH constant(uar_get_code_by("DISPLAYKEY",5801,"VASCULARLAB")),
 protect
 DECLARE nuclearmedicine_subact = f8 WITH constant(uar_get_code_by("DISPLAYKEY",5801,
   "NUCLEARMEDICINE")), protect
 DECLARE ordered = f8 WITH constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED")), protect
 DECLARE mrnmnbr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"MRN")), protect
 DECLARE finnbr = f8 WITH constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")), protect
 CALL echo(build("mrnmnbr= ",mrnmnbr))
 DECLARE ct_subact = f8 WITH constant(uar_get_code_by("DISPLAYKEY",5801,"COMPUTERIZEDTOMOGRAPHY")),
 protect
 DECLARE ecg_subact = f8 WITH constant(uar_get_code_by("DISPLAYKEY",5801,"ECG")), protect
 DECLARE echo_subact = f8 WITH constant(uar_get_code_by("DISPLAYKEY",5801,"ECHO")), protect
 DECLARE vascularus_subact = f8 WITH constant(uar_get_code_by("DISPLAYKEY",5801,"VASCULARUS")),
 protect
 DECLARE mri_subact = f8 WITH constant(uar_get_code_by("DISPLAYKEY",5801,"MAGNETICRESONANCEIMAGING")),
 protect
 DECLARE vaslab_subact = f8 WITH constant(uar_get_code_by("DISPLAYKEY",5801,"VASCULARLAB")), protect
 DECLARE int_radiology_subact = f8 WITH constant(uar_get_code_by("DISPLAYKEY",5801,
   "INTERVENTIONALRADIOLOGY")), protect
 DECLARE generaldiagnostic = f8 WITH constant(uar_get_code_by("DISPLAYKEY",5801,"GENERALDIAGNOSTIC")),
 protect
 DECLARE radiology_act = f8 WITH constant(uar_get_code_by("DISPLAYKEY",106,"RADIOLOGY")), protect
 DECLARE misc_analgesics = f8 WITH constant(59)
 DECLARE narc_analgesic_combinations = f8 WITH constant(191)
 DECLARE narc_analgesics = f8 WITH constant(60)
 DECLARE analgesics = f8 WITH constant(58)
 DECLARE nonsteroidal_anti_inflam = f8 WITH constant(61)
 DECLARE mf_cs72_hump_dump = f8 WITH protect, noconstant(uar_get_code_by("DISPLAYKEY",72,
   "HUMPTYDUMPTYFALLRISKSCORE"))
 CALL echo(build2("mf_CS72_HUMP_DUMP: ",mf_cs72_hump_dump))
 DECLARE mf_cs72_c19_overall_res = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "COVID19OVERALLRESULT"))
 DECLARE mf_cs72_c19_pcroverall_res = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "COVID19PCROVERALLRESULT"))
 DECLARE mf_cs72_c19_pcr_res = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "COVID19PCRRESULT"))
 CALL echo(build2("mf_CS72_C19_OVERALL_RES: ",mf_cs72_c19_overall_res))
 CALL echo(build2("mf_CS72_C19_PCROVERALL_RES: ",mf_cs72_c19_pcroverall_res))
 CALL echo(build2("mf_CS72_C19_PCR_RES: ",mf_cs72_c19_pcr_res))
 DECLARE ml_loop = i2 WITH protect, noconstant(0)
 FREE RECORD ticket
 RECORD ticket(
   1 person_id = f8
   1 patient_name = vc
   1 rn = vc
   1 encntr_id = f8
   1 dob = vc
   1 age = vc
   1 accout_no = vc
   1 mrn = vc
   1 admit_date = vc
   1 patient_type = vc
   1 attending = vc
   1 loc_cnt = i2
   1 weight = vc
   1 location = vc
   1 allergy = vc
   1 diag_orders[*]
     2 order_id = f8
     2 order_name = vc
     2 order_display = vc
     2 cat_type = vc
     2 order_act = vc
     2 act_sub_type = vc
     2 clinical_category = vc
   1 special_proc[*]
     2 order_id = f8
     2 order_name = vc
     2 order_display = vc
     2 order_act = vc
     2 clinical_category = vc
   1 mri[*]
     2 order_id = f8
     2 order_name = vc
     2 order_display = vc
     2 order_act = vc
     2 clinical_category = vc
   1 ultra_sound[*]
     2 order_id = f8
     2 order_name = vc
     2 order_display = vc
     2 order_act = vc
     2 clinical_category = vc
   1 ct[*]
     2 order_id = f8
     2 order_name = vc
     2 order_display = vc
     2 order_act = vc
     2 clinical_category = vc
   1 nuclear_med[*]
     2 order_id = f8
     2 order_name = vc
     2 order_display = vc
     2 order_act = vc
     2 clinical_category = vc
   1 stress_lab[*]
     2 order_id = f8
     2 order_name = vc
     2 order_display = vc
     2 order_act = vc
     2 clinical_category = vc
   1 echo[*]
     2 order_id = f8
     2 order_name = vc
     2 order_display = vc
     2 order_act = vc
     2 clinical_category = vc
   1 vascular_lab[*]
     2 order_id = f8
     2 order_name = vc
     2 order_display = vc
     2 order_act = vc
     2 clinical_category = vc
   1 pulmonary_lab[*]
     2 order_id = f8
     2 order_name = vc
     2 order_display = vc
     2 order_act = vc
     2 clinical_category = vc
   1 cath_lab[*]
     2 order_id = f8
     2 order_name = vc
     2 order_display = vc
     2 order_act = vc
     2 clinical_category = vc
   1 code_status_orders[*]
     2 order_id = f8
     2 order_name = vc
     2 order_display = vc
     2 order_act = vc
   1 isolation[*]
     2 order_id = f8
     2 order_name = vc
     2 order_display = vc
     2 order_act = vc
   1 pain_meds[*]
     2 order_id = f8
     2 order_name = vc
     2 order_display = vc
     2 time_given = dq8
     2 order_act = vc
   1 cov19_results[*]
     2 s_disp = vc
     2 s_res = vc
     2 s_res_dt_tm = vc
   1 orientation_res = vc
   1 levelofconsciousness = vc
   1 levelofconsciousness_dttm = dq8
   1 neurologicaled = vc
   1 neurologicaled_dttm = dq8
   1 orientatedtopersonplacetime = vc
   1 orientatedpersonplacetime_dttm = dq8
   1 psychosocialed = vc
   1 psychosocialed_dttm = dq8
   1 pain_score_res = vc
   1 pain_score_res_dttm = dq8
   1 fallrisklabel = vc
   1 fall_risk_score = vc
   1 fallrisklevel = vc
   1 fall_risk_score_dttm = dq8
   1 s_hump_dump_label = vc
   1 s_hump_dump_score = vc
   1 s_hump_dump_dt_tm = vc
   1 graf_pif_label = vc
   1 graf_pif_score = vc
   1 graf_pif_dt_tm = dq8
   1 language_spoken = vc
   1 interpreter_needed = vc
   1 communication_barrier = vc
   1 visitor_restrictions = vc
   1 mobility = vc
   1 ambulation = vc
   1 assistive_devices = vc
   1 sensory_deficits = vc
   1 mobility_assist = vc
   1 lastvoid = vc
   1 bladderdistention = vc
   1 othertrachcomments_label = vc
   1 othertrachcomments_result = vc
   1 othertrachcomments_parent_id = f8
   1 trachairwaytype_label = vc
   1 trachairwaytype_result = vc
   1 trachairwaytype_parent_id = f8
   1 tracheostomysize = vc
   1 tracheostomysize_parent_id = f8
   1 ms_wearing_bpv_band = vc
   1 ms_bloodpressurevenipuncture = vc
   1 s_pt_owns_med_inf_pump = vc
 )
 SET ticket->trachairwaytype_label = "No Result for Artifical Airway"
 SELECT INTO "nl:"
  nurse_unit = uar_get_code_display(ed.loc_nurse_unit_cd)
  FROM encounter e,
   encntr_alias ea,
   encntr_alias ea2,
   person p,
   encntr_prsnl_reltn epr,
   prsnl prn,
   encntr_domain ed
  PLAN (ea
   WHERE (ea.alias= $PAT_ACCT)
    AND ea.encntr_alias_type_cd=finnbr
    AND ea.active_ind=1)
   JOIN (e
   WHERE e.encntr_id=ea.encntr_id)
   JOIN (ea2
   WHERE ea2.encntr_id=e.encntr_id
    AND ea2.encntr_alias_type_cd=mrnmnbr)
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (epr
   WHERE e.encntr_id=epr.encntr_id
    AND epr.active_ind=1
    AND epr.encntr_prsnl_r_cd=attendingphysician
    AND cnvtdatetime(sysdate) BETWEEN epr.beg_effective_dt_tm AND epr.end_effective_dt_tm)
   JOIN (prn
   WHERE prn.person_id=epr.prsnl_person_id)
   JOIN (ed
   WHERE e.encntr_id=ed.encntr_id)
  HEAD e.encntr_id
   CALL echo("head encntr id"), ticket->person_id = e.person_id, ticket->admit_date = format(e
    .reg_dt_tm,"mm/dd/yy hh:mm;;d"),
   ticket->dob = format(p.birth_dt_tm,"mm/dd/yy;;d"), ticket->accout_no = ea.alias, ticket->mrn = ea2
   .alias,
   ticket->encntr_id = e.encntr_id, ticket->patient_name = p.name_full_formatted, ticket->age = trim(
    cnvtage(p.birth_dt_tm),3),
   ticket->location = nurse_unit, ticket->attending = concat(trim(prn.name_first,3)," ",trim(prn
     .name_last,3))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM allergy a,
   nomenclature n
  PLAN (a
   WHERE a.reaction_status_cd=active_allergy
    AND (a.person_id=ticket->person_id)
    AND a.active_ind=1)
   JOIN (n
   WHERE (n.nomenclature_id= Outerjoin(a.substance_nom_id)) )
  HEAD REPORT
   cnt_allergy = 0
  DETAIL
   cnt_allergy += 1
   IF (cnt_allergy=1)
    ticket->allergy = trim(n.source_string,3)
   ELSE
    ticket->allergy = concat(trim(ticket->allergy,3),", ",n.source_string)
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("Get Diagnostic Orders")
 SELECT INTO "nl:"
  o_catalog_type = uar_get_code_display(o.catalog_type_cd), act_type = uar_get_code_display(o
   .activity_type_cd), oc_activity_subtype = uar_get_code_display(oc.activity_subtype_cd)
  FROM orders o,
   order_catalog oc
  PLAN (o
   WHERE (o.encntr_id=ticket->encntr_id)
    AND o.order_status_cd=ordered
    AND o.dept_status_cd IN (examordered_dept, ordered_dept)
    AND o.activity_type_cd IN (radiology_act, pulmlabtxprocedures_act, noninvascardiology_act))
   JOIN (oc
   WHERE o.catalog_cd=oc.catalog_cd)
  ORDER BY oc.catalog_type_cd, oc.activity_type_cd, oc.activity_subtype_cd
  HEAD REPORT
   cnt_diag = 0, cnt_special = 0, cnt_cath_lab = 0,
   cnt_ct = 0, cnt_mri = 0, cnt_echo = 0,
   cnt_ultra_sound = 0, cnt_nuclear = 0, cnt_pulmonary = 0,
   cnt_cath_lab = 0, cnt_stress_lab = 0, cnt_vascular_lab = 0,
   stat = alterlist(ticket->diag_orders,10)
  DETAIL
   cnt_diag += 1
   IF (mod(cnt_diag,10)=1)
    stat = alterlist(ticket->diag_orders,(cnt_diag+ 9))
   ENDIF
   IF (o.ordered_as_mnemonic=o.hna_order_mnemonic)
    ticket->diag_orders[cnt_diag].order_name = trim(o.hna_order_mnemonic)
   ELSE
    ticket->diag_orders[cnt_diag].order_name = concat(trim(o.ordered_as_mnemonic,3)," (",trim(o
      .hna_order_mnemonic,3),")")
   ENDIF
   ticket->diag_orders[cnt_diag].order_id = o.order_id, ticket->diag_orders[cnt_diag].order_display
    = o.clinical_display_line, ticket->diag_orders[cnt_diag].cat_type = o_catalog_type,
   ticket->diag_orders[cnt_diag].order_act = act_type, ticket->diag_orders[cnt_diag].act_sub_type =
   oc_activity_subtype
  FOOT REPORT
   stat = alterlist(ticket->diag_orders,cnt_diag)
  WITH nocounter
 ;end select
 IF (size(ticket->diag_orders,5)=0)
  SET stat = alterlist(ticket->diag_orders,1)
  SET ticket->diag_orders[1].order_name = "No Active Order"
 ENDIF
 SELECT INTO "nl:"
  act_type = uar_get_code_display(o.activity_type_cd)
  FROM orders o
  PLAN (o
   WHERE (o.encntr_id=ticket->encntr_id)
    AND o.order_status_cd=ordered
    AND o.activity_type_cd IN (isolation, mf_cs200_isolation_covid))
  ORDER BY act_type
  HEAD REPORT
   cnt_iso = 0, stat = alterlist(ticket->isolation,10)
  DETAIL
   cnt_iso += 1
   IF (mod(cnt_iso,10)=1)
    stat = alterlist(ticket->isolation,(cnt_iso+ 9))
   ENDIF
   IF (o.ordered_as_mnemonic=o.hna_order_mnemonic)
    ticket->isolation[cnt_iso].order_name = trim(o.hna_order_mnemonic)
   ELSE
    ticket->isolation[cnt_iso].order_name = concat(trim(o.ordered_as_mnemonic,3)," (",trim(o
      .hna_order_mnemonic,3),")")
   ENDIF
   ticket->isolation[cnt_iso].order_id = o.order_id, ticket->isolation[cnt_iso].order_display = o
   .clinical_display_line, ticket->isolation[cnt_iso].order_act = act_type
  FOOT REPORT
   stat = alterlist(ticket->isolation,cnt_iso)
  WITH nocounter
 ;end select
 IF (size(ticket->isolation,5)=0)
  SET stat = alterlist(ticket->isolation,1)
  SET ticket->isolation[1].order_name = "No Active Order"
 ENDIF
 CALL echo("START Get  codestatus Order")
 SELECT INTO "nl:"
  act_type = uar_get_code_display(o.activity_type_cd)
  FROM orders o
  PLAN (o
   WHERE (o.encntr_id=ticket->encntr_id)
    AND o.order_status_cd=ordered
    AND o.activity_type_cd IN (codestatus_act))
  ORDER BY act_type
  HEAD REPORT
   cnt_code = 0, stat = alterlist(ticket->code_status_orders,10)
  DETAIL
   cnt_code += 1
   IF (mod(cnt_code,10)=1)
    stat = alterlist(ticket->code_status_orders,(cnt_code+ 9))
   ENDIF
   IF (o.ordered_as_mnemonic=o.hna_order_mnemonic)
    ticket->code_status_orders[cnt_code].order_name = trim(o.hna_order_mnemonic)
   ELSE
    ticket->code_status_orders[cnt_code].order_name = concat(trim(o.ordered_as_mnemonic,3)," (",trim(
      o.hna_order_mnemonic,3),")")
   ENDIF
   ticket->code_status_orders[cnt_code].order_id = o.order_id, ticket->code_status_orders[cnt_code].
   order_display = o.clinical_display_line, ticket->code_status_orders[cnt_code].order_act = act_type
  FOOT REPORT
   stat = alterlist(ticket->code_status_orders,cnt_code)
  WITH nocounter
 ;end select
 IF (size(ticket->code_status_orders,5)=0)
  SET stat = alterlist(ticket->code_status_orders,1)
  SET ticket->code_status_orders[1].order_name = "No Active Order"
 ENDIF
 SELECT INTO "nl:"
  FROM mltm_drug_categories mdc,
   alt_sel_cat ac,
   mltm_category_drug_xref mc,
   mltm_drug_id md,
   code_value cv,
   order_catalog_synonym ocs,
   orders o,
   clinical_event ce,
   ce_med_result cmr
  PLAN (o
   WHERE (o.encntr_id=ticket->encntr_id)
    AND o.order_status_cd=ordered
    AND o.template_order_flag <= 1
    AND o.orig_ord_as_flag=0)
   JOIN (ocs
   WHERE o.synonym_id=ocs.synonym_id)
   JOIN (cv
   WHERE ocs.catalog_cd=cv.code_value
    AND cv.active_ind=1
    AND cv.end_effective_dt_tm > sysdate)
   JOIN (md
   WHERE cv.cki=concat("MUL.ORD!",trim(md.drug_identifier)))
   JOIN (mc
   WHERE md.drug_identifier=mc.drug_identifier)
   JOIN (mdc
   WHERE mc.multum_category_id=mdc.multum_category_id
    AND mdc.multum_category_id IN (analgesics, misc_analgesics, narc_analgesic_combinations,
   narc_analgesics, nonsteroidal_anti_inflam))
   JOIN (ac
   WHERE ac.long_description_key_cap=cnvtupper(trim(mdc.category_name))
    AND ac.ahfs_ind=1)
   JOIN (ce
   WHERE ce.encntr_id=o.encntr_id
    AND ce.person_id=o.person_id
    AND ce.result_status_cd IN (authverified, altered_cd, modified_cd)
    AND ((ce.order_id+ 0)=o.order_id)
    AND ((ce.view_level+ 0)=1)
    AND ((ce.valid_until_dt_tm+ 0) > sysdate)
    AND ce.event_end_dt_tm <= sysdate)
   JOIN (cmr
   WHERE cmr.event_id=ce.event_id)
  ORDER BY o.order_id, ce.event_end_dt_tm DESC
  HEAD REPORT
   cnt_pain = 0, stat = alterlist(ticket->pain_meds,10)
  HEAD o.order_id
   cnt_pain += 1
   IF (mod(cnt_pain,10)=1)
    stat = alterlist(ticket->pain_meds,(cnt_pain+ 9))
   ENDIF
   IF (o.ordered_as_mnemonic=o.hna_order_mnemonic)
    ticket->pain_meds[cnt_pain].order_name = trim(o.hna_order_mnemonic)
   ELSE
    ticket->pain_meds[cnt_pain].order_name = concat(trim(o.ordered_as_mnemonic,3)," (",trim(o
      .hna_order_mnemonic,3),")")
   ENDIF
   ticket->pain_meds[cnt_pain].order_id = o.order_id, ticket->pain_meds[cnt_pain].order_display = o
   .clinical_display_line, ticket->pain_meds[cnt_pain].time_given = ce.event_end_dt_tm
  FOOT REPORT
   stat = alterlist(ticket->pain_meds,cnt_pain)
  WITH nocounter
 ;end select
 CALL echo(ticket->encntr_id)
 CALL echo("%%%%% GET RESULTS %%%%%")
 SELECT INTO "nl:"
  res_date = format(ce.event_end_dt_tm,"@SHORTDATETIME")
  FROM clinical_event ce
  PLAN (ce
   WHERE (ce.encntr_id=ticket->encntr_id)
    AND (ce.person_id=ticket->person_id)
    AND ce.event_cd IN (assistivedevices, bladderdistention, communicationbarriers,
   devicesforambulation, interpreterneeded,
   languagespokenv001, lastvoid, mobility, mobilityassistance, orientatedtopersonplacetime,
   neurologicaled, sensorydeficits, visitorrestrictions, levelofconsciousness, painintensity,
   grafpifscore, totalfallsriskscore, psychosocialed, fallrisklevel, othertracheostomycomments,
   trachairwaytype, tracheostomysize, mf_bloodpressurevenipuncture, mf_wearing_bpv_band,
   mf_pt_has_med_inf_pump,
   mf_cs72_hump_dump, mf_cs72_c19_overall_res, mf_cs72_c19_pcroverall_res, mf_cs72_c19_pcr_res)
    AND ce.result_status_cd IN (authverified, altered_cd, modified_cd)
    AND ce.valid_until_dt_tm > cnvtdatetime(sysdate))
  ORDER BY ce.event_cd, ce.event_end_dt_tm DESC
  HEAD REPORT
   pl_cov19 = 0
  HEAD ce.event_cd
   IF (ce.event_cd=orientatedtopersonplacetime
    AND datetimeadd(ce.event_end_dt_tm,(720/ 1440.0)) >= cnvtdatetime(sysdate))
    ticket->orientation_res = ce.result_val, ticket->orientatedpersonplacetime_dttm = ce
    .event_end_dt_tm
   ELSEIF (ce.event_cd=levelofconsciousness
    AND datetimeadd(ce.event_end_dt_tm,(720/ 1440.0)) >= cnvtdatetime(sysdate))
    ticket->levelofconsciousness = ce.result_val, ticket->levelofconsciousness_dttm = ce
    .event_end_dt_tm
   ELSEIF (ce.event_cd=painintensity)
    ticket->pain_score_res = ce.result_val
   ELSEIF (ce.event_cd=totalfallsriskscore)
    ticket->fallrisklabel = trim(ce.event_title_text,3), ticket->fall_risk_score = ce.result_val,
    ticket->fall_risk_score_dttm = ce.valid_from_dt_tm
   ELSEIF (ce.event_cd=fallrisklevel)
    ticket->fallrisklevel = ce.result_val
   ELSEIF (ce.event_cd=grafpifscore)
    ticket->graf_pif_dt_tm = ce.valid_from_dt_tm, ticket->graf_pif_label = ce.event_title_text,
    ticket->graf_pif_score = ce.result_val
   ELSEIF (ce.event_cd=mf_bloodpressurevenipuncture)
    ticket->ms_bloodpressurevenipuncture = ce.result_val
   ELSEIF (ce.event_cd=mf_wearing_bpv_band)
    ticket->ms_wearing_bpv_band = ce.result_val
   ELSEIF (ce.event_cd=mf_pt_has_med_inf_pump)
    ticket->s_pt_owns_med_inf_pump = cnvtupper(ce.result_val)
   ELSEIF (ce.event_cd=languagespokenv001)
    ticket->language_spoken = ce.result_val
   ELSEIF (ce.event_cd=interpreterneeded)
    ticket->interpreter_needed = ce.result_val
   ELSEIF (ce.event_cd=communicationbarriers)
    ticket->communication_barrier = ce.result_val
   ELSEIF (ce.event_cd=visitorrestrictions)
    ticket->visitor_restrictions = ce.result_val
   ELSEIF (ce.event_cd=mobility)
    ticket->mobility = ce.result_val
   ELSEIF (ce.event_cd=devicesforambulation)
    ticket->ambulation = ce.result_val
   ELSEIF (ce.event_cd=assistivedevices)
    ticket->assistive_devices = ce.result_val
   ELSEIF (ce.event_cd=sensorydeficits)
    ticket->sensory_deficits = ce.result_val
   ELSEIF (ce.event_cd=mobilityassistance)
    ticket->mobility_assist = ce.result_val
   ELSEIF (ce.event_cd=neurologicaled
    AND datetimeadd(ce.event_end_dt_tm,(720/ 1440.0)) >= cnvtdatetime(sysdate))
    ticket->neurologicaled = ce.result_val, ticket->neurologicaled_dttm = ce.event_end_dt_tm
   ELSEIF (ce.event_cd=psychosocialed
    AND datetimeadd(ce.event_end_dt_tm,(720/ 1440.0)) >= cnvtdatetime(sysdate))
    ticket->psychosocialed = ce.result_val, ticket->psychosocialed_dttm = ce.event_end_dt_tm
   ELSEIF (ce.event_cd=bladderdistention)
    ticket->bladderdistention = ce.result_val
   ELSEIF (ce.event_cd=lastvoid
    AND datetimeadd(ce.event_end_dt_tm,(720/ 1440.0)) >= cnvtdatetime(sysdate))
    ticket->lastvoid = format(cnvtdatetime(cnvtdate2(substring(3,8,ce.result_val),"yyyymmdd"),
      cnvttime2(substring(11,6,ce.result_val),"hhmmss")),"dd-mmm-yyyy hh:mm:ss;;d")
   ELSEIF (ce.event_cd=trachairwaytype)
    ticket->trachairwaytype_label = concat(ce.event_title_text," :"), ticket->trachairwaytype_result
     = ce.result_val, ticket->trachairwaytype_parent_id = ce.parent_event_id
   ELSEIF (ce.event_cd=tracheostomysize)
    ticket->tracheostomysize = ce.result_val, ticket->tracheostomysize_parent_id = ce.parent_event_id
   ELSEIF (ce.event_cd=othertracheostomycomments)
    ticket->othertrachcomments_result = ce.result_val, ticket->othertrachcomments_parent_id = ce
    .parent_event_id
   ELSEIF (ce.event_cd=mf_cs72_hump_dump)
    CALL echo("humpty dumpty"), ticket->s_hump_dump_dt_tm = trim(format(ce.valid_from_dt_tm,
      "mm/dd/yyyy hh:mm;;d"),3), ticket->s_hump_dump_label = "Pedi Fall Risk: ",
    ticket->s_hump_dump_score = trim(ce.result_val,3)
   ELSEIF (ce.event_cd=mf_cs72_c19_overall_res)
    pl_cov19 += 1,
    CALL alterlist(ticket->cov19_results,pl_cov19), ticket->cov19_results[pl_cov19].s_disp = trim(
     uar_get_code_display(ce.event_cd),3),
    ticket->cov19_results[pl_cov19].s_res = trim(ce.result_val,3), ticket->cov19_results[pl_cov19].
    s_res_dt_tm = trim(format(ce.event_end_dt_tm,"mm/dd/yyyy hh:mm;;d"),3)
   ELSEIF (ce.event_cd=mf_cs72_c19_pcroverall_res)
    pl_cov19 += 1,
    CALL alterlist(ticket->cov19_results,pl_cov19), ticket->cov19_results[pl_cov19].s_disp = trim(
     uar_get_code_display(ce.event_cd),3),
    ticket->cov19_results[pl_cov19].s_res = trim(ce.result_val,3), ticket->cov19_results[pl_cov19].
    s_res_dt_tm = trim(format(ce.event_end_dt_tm,"mm/dd/yyyy hh:mm;;d"),3)
   ELSEIF (ce.event_cd=mf_cs72_c19_pcr_res)
    pl_cov19 += 1,
    CALL alterlist(ticket->cov19_results,pl_cov19), ticket->cov19_results[pl_cov19].s_disp = trim(
     uar_get_code_display(ce.event_cd),3),
    ticket->cov19_results[pl_cov19].s_res = trim(ce.result_val,3), ticket->cov19_results[pl_cov19].
    s_res_dt_tm = trim(format(ce.event_end_dt_tm,"mm/dd/yyyy hh:mm;;d"),3)
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("%%%%% END GET RESULTS %%%%%")
 SELECT INTO "nl:"
  FROM encntr_domain e,
   dcp_shift_assignment sa,
   dcp_care_team ct,
   dcp_care_team_prsnl ctp,
   prsnl p
  PLAN (e
   WHERE (e.encntr_id=ticket->encntr_id))
   JOIN (sa
   WHERE ((sa.loc_bed_cd=e.loc_bed_cd
    AND sa.loc_bed_cd > 0) OR (((sa.loc_bed_cd=0
    AND sa.loc_room_cd=e.loc_room_cd
    AND sa.active_ind=1
    AND sa.loc_room_cd > 0) OR (sa.loc_room_cd=0
    AND sa.loc_unit_cd=e.loc_nurse_unit_cd
    AND sa.active_ind=1
    AND sa.loc_unit_cd=0)) ))
    AND sa.active_ind=1
    AND sa.purge_ind=0
    AND cnvtdatetime(sysdate) BETWEEN sa.beg_effective_dt_tm AND sa.end_effective_dt_tm
    AND sa.assign_type_cd=nursing)
   JOIN (ct
   WHERE (ct.careteam_id> Outerjoin(0))
    AND (ct.careteam_id= Outerjoin(sa.careteam_id))
    AND (ct.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(curdate,curtime)))
    AND (ct.end_effective_dt_tm>= Outerjoin(cnvtdatetime(curdate,curtime))) )
   JOIN (ctp
   WHERE (ctp.careteam_id> Outerjoin(0))
    AND (ctp.careteam_id= Outerjoin(ct.careteam_id))
    AND (ctp.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(curdate,curtime)))
    AND (ctp.end_effective_dt_tm>= Outerjoin(cnvtdatetime(curdate,curtime))) )
   JOIN (p
   WHERE ((p.person_id=sa.prsnl_id
    AND sa.prsnl_id > 0) OR (p.person_id=ctp.prsnl_id
    AND ctp.prsnl_id > 0))
    AND p.person_id > 0)
  ORDER BY e.encntr_id, p.name_full_formatted
  HEAD REPORT
   cnt = 0
  DETAIL
   name = concat(trim(p.name_first,3)," ",trim(p.name_last,3)), cnt += 1
   IF (cnt=1)
    ticket->rn = concat(name)
   ELSE
    ticket->rn = concat(ticket->rn,", "), ticket->rn = concat(ticket->rn,name)
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(ticket)
 EXECUTE reportrtl
 DECLARE _createfonts(dummy) = null WITH protect
 DECLARE _createpens(dummy) = null WITH protect
 DECLARE pagebreak(dummy) = null WITH protect
 DECLARE initializereport(dummy) = null WITH protect
 DECLARE _hreport = h WITH noconstant(0), protect
 DECLARE _yoffset = f8 WITH noconstant(0.0), protect
 DECLARE _xoffset = f8 WITH noconstant(0.0), protect
 DECLARE rpt_render = i2 WITH constant(0), protect
 DECLARE _crlf = vc WITH constant(concat(char(13),char(10))), protect
 DECLARE rpt_calcheight = i2 WITH constant(1), protect
 DECLARE _yshift = f8 WITH noconstant(0.0), protect
 DECLARE _xshift = f8 WITH noconstant(0.0), protect
 DECLARE _sendto = vc WITH noconstant(""), protect
 DECLARE _rpterr = i2 WITH noconstant(0), protect
 DECLARE _rptstat = i2 WITH noconstant(0), protect
 DECLARE _oldfont = i4 WITH noconstant(0), protect
 DECLARE _oldpen = i4 WITH noconstant(0), protect
 DECLARE _dummyfont = i4 WITH noconstant(0), protect
 DECLARE _dummypen = i4 WITH noconstant(0), protect
 DECLARE _fdrawheight = f8 WITH noconstant(0.0), protect
 DECLARE _rptpage = h WITH noconstant(0), protect
 DECLARE _diotype = i2 WITH noconstant(8), protect
 DECLARE _outputtype = i2 WITH noconstant(rpt_postscript), protect
 DECLARE _remall_allergies = i4 WITH noconstant(1), protect
 DECLARE _bholdcontinue = i2 WITH noconstant(0), protect
 DECLARE _bcontallergy_details = i2 WITH noconstant(0), protect
 DECLARE _remdiag_orders = i4 WITH noconstant(1), protect
 DECLARE _remdiag_display = i4 WITH noconstant(1), protect
 DECLARE _bcontdiag_orders_detail = i2 WITH noconstant(0), protect
 DECLARE _remcode_orders = i4 WITH noconstant(1), protect
 DECLARE _remcode_stat_display = i4 WITH noconstant(1), protect
 DECLARE _bcontcode_stat_detail = i2 WITH noconstant(0), protect
 DECLARE _rempain_med_name = i4 WITH noconstant(1), protect
 DECLARE _remlast_done = i4 WITH noconstant(1), protect
 DECLARE _bcontpain_ord_detail = i2 WITH noconstant(0), protect
 DECLARE _remmc_blood_pres_veni = i4 WITH noconstant(1), protect
 DECLARE _bcontblood_press_veni = i2 WITH noconstant(0), protect
 DECLARE _remisolation_name = i4 WITH noconstant(1), protect
 DECLARE _remisolation_display = i4 WITH noconstant(1), protect
 DECLARE _bcontisolation_details = i2 WITH noconstant(0), protect
 DECLARE _helvetica10b0 = i4 WITH noconstant(0), protect
 DECLARE _helvetica12b0 = i4 WITH noconstant(0), protect
 DECLARE _times100 = i4 WITH noconstant(0), protect
 DECLARE _helvetica100 = i4 WITH noconstant(0), protect
 DECLARE _helvetica180 = i4 WITH noconstant(0), protect
 DECLARE _times12b0 = i4 WITH noconstant(0), protect
 DECLARE _times14b0 = i4 WITH noconstant(0), protect
 DECLARE _times10u0 = i4 WITH noconstant(0), protect
 DECLARE _times10b0 = i4 WITH noconstant(0), protect
 DECLARE _times120 = i4 WITH noconstant(0), protect
 DECLARE _times10i0 = i4 WITH noconstant(0), protect
 DECLARE _pen50s1c0 = i4 WITH noconstant(0), protect
 DECLARE _pen28s0c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s1c0 = i4 WITH noconstant(0), protect
 DECLARE _pen14s0c0 = i4 WITH noconstant(0), protect
 SUBROUTINE pagebreak(dummy)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE (finalizereport(ssendreport=vc) =null WITH protect)
   SET _rptpage = uar_rptendpage(_hreport)
   SET _rptstat = uar_rptendreport(_hreport)
   DECLARE sfilename = vc WITH noconstant(trim(ssendreport)), private
   DECLARE bprint = i2 WITH noconstant(0), private
   IF (textlen(sfilename) > 0)
    SET bprint = checkqueue(sfilename)
    IF (bprint)
     EXECUTE cpm_create_file_name "RPT", "PS"
     SET sfilename = cpm_cfn_info->file_name_path
    ENDIF
   ENDIF
   SET _rptstat = uar_rptprinttofile(_hreport,nullterm(sfilename))
   IF (bprint)
    SET spool value(sfilename) value(ssendreport) WITH deleted, dio = value(_diotype)
   ENDIF
   DECLARE _errorfound = i2 WITH noconstant(0), protect
   DECLARE _errcnt = i2 WITH noconstant(0), protect
   SET _errorfound = uar_rptfirsterror(_hreport,rpterror)
   WHILE (_errorfound=rpt_errorfound
    AND _errcnt < 512)
     SET _errcnt += 1
     SET stat = alterlist(rpterrors->errors,_errcnt)
     SET rpterrors->errors[_errcnt].m_severity = rpterror->m_severity
     SET rpterrors->errors[_errcnt].m_text = rpterror->m_text
     SET rpterrors->errors[_errcnt].m_source = rpterror->m_source
     SET _errorfound = uar_rptnexterror(_hreport,rpterror)
   ENDWHILE
   SET _rptstat = uar_rptdestroyreport(_hreport)
 END ;Subroutine
 SUBROUTINE (ticket_header(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = ticket_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (ticket_headerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(1.220000), private
   DECLARE __attend_dr = vc WITH noconstant(build2(trim(ticket->attending,3),char(0))), protect
   DECLARE __name = vc WITH noconstant(build2(ticket->patient_name,char(0))), protect
   DECLARE __accnt = vc WITH noconstant(build2(ticket->accout_no,char(0))), protect
   DECLARE __age = vc WITH noconstant(build2(ticket->age,char(0))), protect
   DECLARE __dob = vc WITH noconstant(build2(ticket->dob,char(0))), protect
   DECLARE __mrn = vc WITH noconstant(build2(ticket->mrn,char(0))), protect
   DECLARE __date_print = vc WITH noconstant(build2(format(cnvtdatetime(curdate,curtime),
      "@SHORTDATETIME"),char(0))), protect
   DECLARE __location = vc WITH noconstant(build2(ticket->location,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 1.042)
    SET rptsd->m_x = (offsetx+ 1.375)
    SET rptsd->m_width = 1.980
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__attend_dr)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.011)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.750
    SET rptsd->m_height = 0.323
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica180)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Report Ticket to Ride",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.376)
    SET rptsd->m_x = (offsetx+ 0.938)
    SET rptsd->m_width = 2.688
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__name)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.542)
    SET rptsd->m_x = (offsetx+ 0.938)
    SET rptsd->m_width = 1.178
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__accnt)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.542)
    SET rptsd->m_x = (offsetx+ 5.750)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__age)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.376)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Patient Name:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.542)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 0.438
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Age:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.376)
    SET rptsd->m_x = (offsetx+ 5.750)
    SET rptsd->m_width = 2.251
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__dob)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.376)
    SET rptsd->m_x = (offsetx+ 5.230)
    SET rptsd->m_width = 0.459
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("DOB:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.542)
    SET rptsd->m_x = (offsetx+ - (0.010))
    SET rptsd->m_width = 0.886
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Account/FIN #: ",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.709)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("MRN:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.709)
    SET rptsd->m_x = (offsetx+ 0.938)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__mrn)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.042)
    SET rptsd->m_x = (offsetx+ 6.063)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__date_print)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.042)
    SET rptsd->m_x = (offsetx+ 5.250)
    SET rptsd->m_width = 0.813
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Date Printed:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Location:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.042)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Attending Physican:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 0.938)
    SET rptsd->m_width = 1.344
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__location)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (allergy_details(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = allergy_detailsabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (allergy_detailsabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_all_allergies = f8 WITH noconstant(0.0), private
   DECLARE __all_allergies = vc WITH noconstant(build2(ticket->allergy,char(0))), protect
   IF (bcontinue=0)
    SET _remall_allergies = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.011)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.709)
   SET rptsd->m_width = 1.730
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremall_allergies = _remall_allergies
   IF (_remall_allergies > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remall_allergies,((size(
        __all_allergies) - _remall_allergies)+ 1),__all_allergies)))
    SET drawheight_all_allergies = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remall_allergies = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remall_allergies,((size(__all_allergies)
        - _remall_allergies)+ 1),__all_allergies)))))
     SET _remall_allergies += rptsd->m_drawlength
    ELSE
     SET _remall_allergies = 0
    ENDIF
    SET growsum += _remall_allergies
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.011)
   SET rptsd->m_x = (offsetx+ 0.032)
   SET rptsd->m_width = 0.594
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Allergies:",char(0)))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.011)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.709)
   SET rptsd->m_width = 1.730
   SET rptsd->m_height = drawheight_all_allergies
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND _holdremall_allergies > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremall_allergies,((
       size(__all_allergies) - _holdremall_allergies)+ 1),__all_allergies)))
   ELSE
    SET _remall_allergies = _holdremall_allergies
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (diag_orders_header(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = diag_orders_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (diag_orders_headerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.380000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.876
    SET rptsd->m_height = 0.219
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Diagnostic Orders/Procedures",char(0)
      ))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 5.688)
    SET rptsd->m_width = 2.084
    SET rptsd->m_height = 0.219
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(continued,char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.317),(offsetx+ 7.751),(offsety+
     0.317))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.058),(offsetx+ 7.751),(offsety+
     0.058))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (diag_orders_detail(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = diag_orders_detailabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (diag_orders_detailabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
   WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_diag_orders = f8 WITH noconstant(0.0), private
   DECLARE drawheight_diag_display = f8 WITH noconstant(0.0), private
   DECLARE __diag_orders = vc WITH noconstant(build2(ticket->diag_orders[a_prt].order_name,char(0))),
   protect
   DECLARE __diag_display = vc WITH noconstant(build2(ticket->diag_orders[a_prt].order_display,char(0
      ))), protect
   IF (bcontinue=0)
    SET _remdiag_orders = 1
    SET _remdiag_display = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.501
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremdiag_orders = _remdiag_orders
   IF (_remdiag_orders > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdiag_orders,((size(
        __diag_orders) - _remdiag_orders)+ 1),__diag_orders)))
    SET drawheight_diag_orders = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdiag_orders = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdiag_orders,((size(__diag_orders) -
       _remdiag_orders)+ 1),__diag_orders)))))
     SET _remdiag_orders += rptsd->m_drawlength
    ELSE
     SET _remdiag_orders = 0
    ENDIF
    SET growsum += _remdiag_orders
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.626)
   SET rptsd->m_width = 5.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremdiag_display = _remdiag_display
   IF (_remdiag_display > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remdiag_display,((size(
        __diag_display) - _remdiag_display)+ 1),__diag_display)))
    SET drawheight_diag_display = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remdiag_display = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remdiag_display,((size(__diag_display) -
       _remdiag_display)+ 1),__diag_display)))))
     SET _remdiag_display += rptsd->m_drawlength
    ELSE
     SET _remdiag_display = 0
    ENDIF
    SET growsum += _remdiag_display
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.501
   SET rptsd->m_height = drawheight_diag_orders
   IF (ncalc=rpt_render
    AND _holdremdiag_orders > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdiag_orders,((size
       (__diag_orders) - _holdremdiag_orders)+ 1),__diag_orders)))
   ELSE
    SET _remdiag_orders = _holdremdiag_orders
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.626)
   SET rptsd->m_width = 5.125
   SET rptsd->m_height = drawheight_diag_display
   IF (ncalc=rpt_render
    AND _holdremdiag_display > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremdiag_display,((
       size(__diag_display) - _holdremdiag_display)+ 1),__diag_display)))
   ELSE
    SET _remdiag_display = _holdremdiag_display
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (code_stat_header(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = code_stat_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (code_stat_headerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.320000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.026),(offsetx+ 7.751),(offsety+
     0.026))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.276),(offsetx+ 7.751),(offsety+
     0.276))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 5.688)
    SET rptsd->m_width = 2.084
    SET rptsd->m_height = 0.198
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(continued,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.126
    SET rptsd->m_height = 0.219
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Code Status Orders",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (code_stat_detail(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = code_stat_detailabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (code_stat_detailabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_code_orders = f8 WITH noconstant(0.0), private
   DECLARE drawheight_code_stat_display = f8 WITH noconstant(0.0), private
   DECLARE __code_orders = vc WITH noconstant(build2(ticket->code_status_orders[b_prt].order_name,
     char(0))), protect
   DECLARE __code_stat_display = vc WITH noconstant(build2(ticket->code_status_orders[b_prt].
     order_display,char(0))), protect
   IF (bcontinue=0)
    SET _remcode_orders = 1
    SET _remcode_stat_display = 1
   ENDIF
   SET rptsd->m_flags = 13
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.021)
   SET rptsd->m_width = 2.501
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremcode_orders = _remcode_orders
   IF (_remcode_orders > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcode_orders,((size(
        __code_orders) - _remcode_orders)+ 1),__code_orders)))
    SET drawheight_code_orders = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcode_orders = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcode_orders,((size(__code_orders) -
       _remcode_orders)+ 1),__code_orders)))))
     SET _remcode_orders += rptsd->m_drawlength
    ELSE
     SET _remcode_orders = 0
    ENDIF
    SET growsum += _remcode_orders
   ENDIF
   SET rptsd->m_flags = 13
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.626)
   SET rptsd->m_width = 5.125
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremcode_stat_display = _remcode_stat_display
   IF (_remcode_stat_display > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remcode_stat_display,((
       size(__code_stat_display) - _remcode_stat_display)+ 1),__code_stat_display)))
    SET drawheight_code_stat_display = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remcode_stat_display = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remcode_stat_display,((size(
        __code_stat_display) - _remcode_stat_display)+ 1),__code_stat_display)))))
     SET _remcode_stat_display += rptsd->m_drawlength
    ELSE
     SET _remcode_stat_display = 0
    ENDIF
    SET growsum += _remcode_stat_display
   ENDIF
   SET rptsd->m_flags = 12
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.021)
   SET rptsd->m_width = 2.501
   SET rptsd->m_height = drawheight_code_orders
   IF (ncalc=rpt_render
    AND _holdremcode_orders > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcode_orders,((size
       (__code_orders) - _holdremcode_orders)+ 1),__code_orders)))
   ELSE
    SET _remcode_orders = _holdremcode_orders
   ENDIF
   SET rptsd->m_flags = 12
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.626)
   SET rptsd->m_width = 5.125
   SET rptsd->m_height = drawheight_code_stat_display
   IF (ncalc=rpt_render
    AND _holdremcode_stat_display > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremcode_stat_display,
       ((size(__code_stat_display) - _holdremcode_stat_display)+ 1),__code_stat_display)))
   ELSE
    SET _remcode_stat_display = _holdremcode_stat_display
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (cov19_res_head(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = cov19_res_headabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (cov19_res_headabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.290000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.026),(offsetx+ 7.751),(offsety+
     0.026))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.276),(offsetx+ 7.751),(offsety+
     0.276))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 5.688)
    SET rptsd->m_width = 2.084
    SET rptsd->m_height = 0.198
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(continued,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.126
    SET rptsd->m_height = 0.219
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("COVID Test Results",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (cov19_res_det(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = cov19_res_detabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (cov19_res_detabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.220000), private
   DECLARE __covid_order = vc WITH noconstant(build2(ticket->cov19_results[ml_loop].s_disp,char(0))),
   protect
   DECLARE __covid_result = vc WITH noconstant(build2(concat(ticket->cov19_results[ml_loop].
      s_res_dt_tm," ",ticket->cov19_results[ml_loop].s_res),char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 8
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.501
    SET rptsd->m_height = 0.219
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__covid_order)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 2.605)
    SET rptsd->m_width = 5.125
    SET rptsd->m_height = 0.219
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__covid_result)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (psychosocialed_header(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = psychosocialed_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (psychosocialed_headerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.690000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 1.563
    SET rptsd->m_height = 0.251
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Psychosocial",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 0.188)
    SET rptsd->m_width = 0.750
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10i0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Orientation: ",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 1.000)
    SET rptsd->m_width = 6.792
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(alertness,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.188)
    SET rptsd->m_width = 0.646
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10i0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Alertness:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.313)
    SET rptsd->m_x = (offsetx+ 1.000)
    SET rptsd->m_width = 6.667
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(orientation_psych,char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.058),(offsetx+ 7.751),(offsety+
     0.058))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (pain_ord_header(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = pain_ord_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (pain_ord_headerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.290000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.276),(offsetx+ 7.751),(offsety+
     0.276))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.813
    SET rptsd->m_height = 0.219
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Medications for Pain",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 5.688)
    SET rptsd->m_width = 2.084
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(continued,char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.026),(offsetx+ 7.751),(offsety+
     0.026))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.032)
    SET rptsd->m_x = (offsetx+ 3.209)
    SET rptsd->m_width = 1.480
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Last Charted",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (pain_ord_detail(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = pain_ord_detailabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (pain_ord_detailabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.290000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_pain_med_name = f8 WITH noconstant(0.0), private
   DECLARE drawheight_last_done = f8 WITH noconstant(0.0), private
   DECLARE __pain_med_name = vc WITH noconstant(build2(ticket->pain_meds[c_prt].order_name,char(0))),
   protect
   DECLARE __last_done = vc WITH noconstant(build2(format(ticket->pain_meds[c_prt].time_given,
      "@SHORTDATETIME"),char(0))), protect
   IF (bcontinue=0)
    SET _rempain_med_name = 1
    SET _remlast_done = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.501
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdrempain_med_name = _rempain_med_name
   IF (_rempain_med_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_rempain_med_name,((size(
        __pain_med_name) - _rempain_med_name)+ 1),__pain_med_name)))
    SET drawheight_pain_med_name = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _rempain_med_name = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_rempain_med_name,((size(__pain_med_name)
        - _rempain_med_name)+ 1),__pain_med_name)))))
     SET _rempain_med_name += rptsd->m_drawlength
    ELSE
     SET _rempain_med_name = 0
    ENDIF
    SET growsum += _rempain_med_name
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.032)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.251)
   SET rptsd->m_width = 3.094
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremlast_done = _remlast_done
   IF (_remlast_done > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remlast_done,((size(
        __last_done) - _remlast_done)+ 1),__last_done)))
    SET drawheight_last_done = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remlast_done = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remlast_done,((size(__last_done) -
       _remlast_done)+ 1),__last_done)))))
     SET _remlast_done += rptsd->m_drawlength
    ELSE
     SET _remlast_done = 0
    ENDIF
    SET growsum += _remlast_done
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.000)
   SET rptsd->m_width = 2.501
   SET rptsd->m_height = drawheight_pain_med_name
   IF (ncalc=rpt_render
    AND _holdrempain_med_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdrempain_med_name,((
       size(__pain_med_name) - _holdrempain_med_name)+ 1),__pain_med_name)))
   ELSE
    SET _rempain_med_name = _holdrempain_med_name
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.032)
   ENDIF
   SET rptsd->m_x = (offsetx+ 3.251)
   SET rptsd->m_width = 3.094
   SET rptsd->m_height = drawheight_last_done
   IF (ncalc=rpt_render
    AND _holdremlast_done > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremlast_done,((size(
        __last_done) - _holdremlast_done)+ 1),__last_done)))
   ELSE
    SET _remlast_done = _holdremlast_done
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (pain_score_header(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = pain_score_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (pain_score_headerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.340000), private
   DECLARE __painscore = vc WITH noconstant(build2(ticket->pain_score_res,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.126)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 0.803
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Pain Score:",char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.058),(offsetx+ 7.751),(offsety+
     0.058))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.126)
    SET rptsd->m_x = (offsetx+ 0.990)
    SET rptsd->m_width = 2.094
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__painscore)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (artifical_airway(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = artifical_airwayabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (artifical_airwayabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(1.310000), private
   DECLARE __trachairwaytype_result = vc WITH noconstant(build2(ticket->trachairwaytype_result,char(0
      ))), protect
   DECLARE __trachairwaytype_label = vc WITH noconstant(build2(ticket->trachairwaytype_label,char(0))
    ), protect
   IF ((ticket->trachairwaytype_result > " ")
    AND (ticket->trachairwaytype_parent_id=ticket->tracheostomysize_parent_id))
    DECLARE __tracheostomysize = vc WITH noconstant(build2(ticket->tracheostomysize,char(0))),
    protect
   ENDIF
   IF ((ticket->trachairwaytype_result > " ")
    AND (ticket->trachairwaytype_parent_id=ticket->othertrachcomments_parent_id))
    DECLARE __othertrachcomments_result = vc WITH noconstant(build2(ticket->othertrachcomments_result,
      char(0))), protect
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.126)
    SET rptsd->m_x = (offsetx+ 2.501)
    SET rptsd->m_width = 5.000
    SET rptsd->m_height = 0.396
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__trachairwaytype_result)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.126)
    SET rptsd->m_x = (offsetx+ - (0.010))
    SET rptsd->m_width = 2.261
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__trachairwaytype_label)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.188
    IF ((ticket->trachairwaytype_result > " ")
     AND (ticket->trachairwaytype_parent_id=ticket->tracheostomysize_parent_id))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Tracheostomy :",char(0)))
    ENDIF
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.563)
    SET rptsd->m_x = (offsetx+ 2.501)
    SET rptsd->m_width = 2.021
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
    IF ((ticket->trachairwaytype_result > " ")
     AND (ticket->trachairwaytype_parent_id=ticket->tracheostomysize_parent_id))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__tracheostomysize)
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.021
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
    IF ((ticket->trachairwaytype_result > " ")
     AND (ticket->trachairwaytype_parent_id=ticket->othertrachcomments_parent_id))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Other Trachostomy Comment :",char(0)
       ))
    ENDIF
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.813)
    SET rptsd->m_x = (offsetx+ 2.501)
    SET rptsd->m_width = 5.000
    SET rptsd->m_height = 0.396
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica100)
    IF ((ticket->trachairwaytype_result > " ")
     AND (ticket->trachairwaytype_parent_id=ticket->othertrachcomments_parent_id))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__othertrachcomments_result)
    ENDIF
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.058),(offsetx+ 7.751),(offsety+
     0.058))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (fail_risk_header(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = fail_risk_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (fail_risk_headerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.380000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.126)
    SET rptsd->m_x = (offsetx+ 1.250)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(result_fall_risk,char(0)))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.058),(offsetx+ 7.751),(offsety+
     0.058))
    SET rptsd->m_flags = 32
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.126)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_helvetica10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(label_fall_risk,char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (special_needs_header(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = special_needs_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (special_needs_headerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.380000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.058),(offsetx+ 7.751),(offsety+
     0.058))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.126)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 2.438
    SET rptsd->m_height = 0.209
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Special  Needs",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (language_header(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = language_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (language_headerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   DECLARE __language_spoke = vc WITH noconstant(build2(ticket->language_spoken,char(0))), protect
   IF ( NOT ((ticket->language_spoken != null)))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.198
    SET _oldfont = uar_rptsetfont(_hreport,_times10i0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Language:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 2.001)
    SET rptsd->m_width = 2.407
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__language_spoke)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (interpreter_header(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = interpreter_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (interpreter_headerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   DECLARE __interpreter = vc WITH noconstant(build2(ticket->interpreter_needed,char(0))), protect
   IF ( NOT ((ticket->interpreter_needed != null)))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.198
    SET _oldfont = uar_rptsetfont(_hreport,_times10i0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Interpreter Needed :",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 2.001)
    SET rptsd->m_width = 2.094
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__interpreter)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (wearing_bpv_band(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = wearing_bpv_bandabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (wearing_bpv_bandabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   DECLARE __wearing_bpv_band = vc WITH noconstant(build2(ticket->ms_wearing_bpv_band,char(0))),
   protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 2.626
    SET rptsd->m_height = 0.198
    SET _oldfont = uar_rptsetfont(_hreport,_times10i0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Wearing BP/Venipuncture Restriction Band:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 3.126)
    SET rptsd->m_width = 2.094
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__wearing_bpv_band)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (blood_press_veni(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = blood_press_veniabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (blood_press_veniabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_mc_blood_pres_veni = f8 WITH noconstant(0.0), private
   DECLARE __mc_blood_pres_veni = vc WITH noconstant(build2(ticket->ms_bloodpressurevenipuncture,char
     (0))), protect
   IF (bcontinue=0)
    SET _remmc_blood_pres_veni = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.313)
   SET rptsd->m_width = 5.250
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremmc_blood_pres_veni = _remmc_blood_pres_veni
   IF (_remmc_blood_pres_veni > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remmc_blood_pres_veni,((
       size(__mc_blood_pres_veni) - _remmc_blood_pres_veni)+ 1),__mc_blood_pres_veni)))
    SET drawheight_mc_blood_pres_veni = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remmc_blood_pres_veni = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remmc_blood_pres_veni,((size(
        __mc_blood_pres_veni) - _remmc_blood_pres_veni)+ 1),__mc_blood_pres_veni)))))
     SET _remmc_blood_pres_veni += rptsd->m_drawlength
    ELSE
     SET _remmc_blood_pres_veni = 0
    ENDIF
    SET growsum += _remmc_blood_pres_veni
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_y = (offsety+ 0.001)
   SET rptsd->m_x = (offsetx+ 0.500)
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont(_hreport,_times10i0)
   IF (ncalc=rpt_render
    AND bcontinue=0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Blood Pressure/Venipuncture:",char(0)
      ))
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.313)
   SET rptsd->m_width = 5.250
   SET rptsd->m_height = drawheight_mc_blood_pres_veni
   SET _dummyfont = uar_rptsetfont(_hreport,_times100)
   IF (ncalc=rpt_render
    AND _holdremmc_blood_pres_veni > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremmc_blood_pres_veni,
       ((size(__mc_blood_pres_veni) - _holdremmc_blood_pres_veni)+ 1),__mc_blood_pres_veni)))
   ELSE
    SET _remmc_blood_pres_veni = _holdremmc_blood_pres_veni
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (comunicate_bar_header(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = comunicate_bar_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (comunicate_bar_headerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   DECLARE __communcation_barriers = vc WITH noconstant(build2(ticket->communication_barrier,char(0))
    ), protect
   IF ( NOT ((ticket->communication_barrier != null)))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 1.438
    SET rptsd->m_height = 0.198
    SET _oldfont = uar_rptsetfont(_hreport,_times10i0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Comminication Barriers:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 2.001)
    SET rptsd->m_width = 5.625
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__communcation_barriers)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (visitor_header(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = visitor_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (visitor_headerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   DECLARE __visitor_restrict = vc WITH noconstant(build2(ticket->visitor_restrictions,char(0))),
   protect
   IF ( NOT ((ticket->visitor_restrictions != null)))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.198
    SET _oldfont = uar_rptsetfont(_hreport,_times10i0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Visitor Restrictions: ",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 2.001)
    SET rptsd->m_width = 2.251
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__visitor_restrict)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (mobility_header(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = mobility_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (mobility_headerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.200000), private
   DECLARE __moblility = vc WITH noconstant(build2(ticket->mobility,char(0))), protect
   IF ( NOT ((ticket->mobility != null)))
    RETURN(0.0)
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 0.625
    SET rptsd->m_height = 0.198
    SET _oldfont = uar_rptsetfont(_hreport,_times10i0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Mobility :",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 2.001)
    SET rptsd->m_width = 2.521
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__moblility)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (ambulation_header(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = ambulation_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (ambulation_headerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.450000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 1.250
    SET rptsd->m_height = 0.198
    SET _oldfont = uar_rptsetfont(_hreport,_times10i0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Ambulation Devices:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 2.001)
    SET rptsd->m_width = 5.688
    SET rptsd->m_height = 0.396
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    IF (ambulation_devices != "XXXX")
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(ambulation_devices,char(0)))
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (moblil_sensor_header(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = moblil_sensor_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (moblil_sensor_headerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.790000), private
   IF ((ticket->mobility_assist != null))
    DECLARE __mobil_assist = vc WITH noconstant(build2(ticket->mobility_assist,char(0))), protect
   ENDIF
   IF ((ticket->sensory_deficits != null))
    DECLARE __sensory = vc WITH noconstant(build2(ticket->sensory_deficits,char(0))), protect
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.001)
    SET rptsd->m_x = (offsetx+ 0.500)
    SET rptsd->m_width = 1.563
    SET rptsd->m_height = 0.251
    SET _oldfont = uar_rptsetfont(_hreport,_times10i0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Moblity/Sensory Deficits:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.188)
    SET rptsd->m_x = (offsetx+ 2.063)
    SET rptsd->m_width = 5.500
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    IF ((ticket->mobility_assist != null))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__mobil_assist)
    ENDIF
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 2.001)
    SET rptsd->m_width = 5.563
    SET rptsd->m_height = 0.198
    IF ((ticket->sensory_deficits != null))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__sensory)
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.198)
    SET rptsd->m_x = (offsetx+ 0.625)
    SET rptsd->m_width = 1.209
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times10u0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Mobile Assistance:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 0.625)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.198
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Sensory Deficits:",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (last_void_header(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = last_void_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (last_void_headerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.500000), private
   IF ((ticket->bladderdistention != null))
    DECLARE __bladder_dist = vc WITH noconstant(build2(ticket->bladderdistention,char(0))), protect
   ENDIF
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.032)
    SET rptsd->m_x = (offsetx+ 0.021)
    SET rptsd->m_width = 0.730
    SET rptsd->m_height = 0.261
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Last Void:",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.032)
    SET rptsd->m_x = (offsetx+ 0.750)
    SET rptsd->m_width = 2.782
    SET rptsd->m_height = 0.198
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(last_void_result,char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 1.501)
    SET rptsd->m_width = 2.157
    SET rptsd->m_height = 0.261
    IF ((ticket->bladderdistention != null))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__bladder_dist)
    ENDIF
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 0.375)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times10i0)
    IF ((ticket->bladderdistention != null))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Bladder Distention:",char(0)))
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (text1_header(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = text1_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (text1_headerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(1.120000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdtopborder
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.303)
    SET rptsd->m_x = (offsetx+ - (0.010))
    SET rptsd->m_width = 7.823
    SET rptsd->m_height = 0.282
    SET _oldfont = uar_rptsetfont(_hreport,_times14b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s1c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(concat(
       "Patients Going For CT, US, X-Ray, MRI"),char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.646)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 7.678
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times120)
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "All jewelry, clothing, body piercing, and personal belongings must be removed as appropriate",
      char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.875)
    SET rptsd->m_x = (offsetx+ 0.063)
    SET rptsd->m_width = 7.678
    SET rptsd->m_height = 0.251
    SET _dummyfont = uar_rptsetfont(_hreport,_times12b0)
    IF ((ticket->s_pt_owns_med_inf_pump="YES"))
     SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
       "Patient Has Own Medication Infusion Pump",char(0)))
    ENDIF
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (isolation_header(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = isolation_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (isolation_headerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.340000), private
   IF (ncalc=rpt_render)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.058),(offsetx+ 7.751),(offsety+
     0.058))
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.287),(offsetx+ 7.751),(offsety+
     0.287))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 3.813)
    SET rptsd->m_width = 2.084
    SET rptsd->m_height = 0.219
    SET _oldfont = uar_rptsetfont(_hreport,_helvetica12b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(continued,char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.063)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 3.334
    SET rptsd->m_height = 0.219
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Isolation Orders",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (isolation_details(ncalc=i2,maxheight=f8,bcontinue=i2(ref)) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = isolation_detailsabs(ncalc,_xoffset,_yoffset,maxheight,bcontinue)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (isolation_detailsabs(ncalc=i2,offsetx=f8,offsety=f8,maxheight=f8,bcontinue=i2(ref)) =f8
  WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.250000), private
   DECLARE growsum = i4 WITH noconstant(0), private
   DECLARE drawheight_isolation_name = f8 WITH noconstant(0.0), private
   DECLARE drawheight_isolation_display = f8 WITH noconstant(0.0), private
   DECLARE __isolation_name = vc WITH noconstant(build2(ticket->isolation[d_prt].order_name,char(0))),
   protect
   DECLARE __isolation_display = vc WITH noconstant(build2(ticket->isolation[d_prt].order_display,
     char(0))), protect
   IF (bcontinue=0)
    SET _remisolation_name = 1
    SET _remisolation_display = 1
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.042)
   SET rptsd->m_width = 2.501
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _oldfont = uar_rptsetfont(_hreport,_times100)
   SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
   SET _holdremisolation_name = _remisolation_name
   IF (_remisolation_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remisolation_name,((size(
        __isolation_name) - _remisolation_name)+ 1),__isolation_name)))
    SET drawheight_isolation_name = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remisolation_name = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remisolation_name,((size(__isolation_name
        ) - _remisolation_name)+ 1),__isolation_name)))))
     SET _remisolation_name += rptsd->m_drawlength
    ELSE
     SET _remisolation_name = 0
    ENDIF
    SET growsum += _remisolation_name
   ENDIF
   SET rptsd->m_flags = 5
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.626)
   SET rptsd->m_width = 5.063
   SET rptsd->m_height = ((offsety+ maxheight) - rptsd->m_y)
   SET _holdremisolation_display = _remisolation_display
   IF (_remisolation_display > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_remisolation_display,((
       size(__isolation_display) - _remisolation_display)+ 1),__isolation_display)))
    SET drawheight_isolation_display = rptsd->m_height
    IF ((rptsd->m_height > ((offsety+ sectionheight) - rptsd->m_y)))
     SET sectionheight = ((rptsd->m_y+ _fdrawheight) - offsety)
    ENDIF
    IF ((rptsd->m_drawlength=0))
     SET _remisolation_display = 0
    ELSEIF ((rptsd->m_drawlength < size(nullterm(substring(_remisolation_display,((size(
        __isolation_display) - _remisolation_display)+ 1),__isolation_display)))))
     SET _remisolation_display += rptsd->m_drawlength
    ELSE
     SET _remisolation_display = 0
    ENDIF
    SET growsum += _remisolation_display
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 0.042)
   SET rptsd->m_width = 2.501
   SET rptsd->m_height = drawheight_isolation_name
   IF (ncalc=rpt_render
    AND _holdremisolation_name > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremisolation_name,((
       size(__isolation_name) - _holdremisolation_name)+ 1),__isolation_name)))
   ELSE
    SET _remisolation_name = _holdremisolation_name
   ENDIF
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   IF (bcontinue)
    SET rptsd->m_y = offsety
   ELSE
    SET rptsd->m_y = (offsety+ 0.001)
   ENDIF
   SET rptsd->m_x = (offsetx+ 2.626)
   SET rptsd->m_width = 5.063
   SET rptsd->m_height = drawheight_isolation_display
   IF (ncalc=rpt_render
    AND _holdremisolation_display > 0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,nullterm(substring(_holdremisolation_display,
       ((size(__isolation_display) - _holdremisolation_display)+ 1),__isolation_display)))
   ELSE
    SET _remisolation_display = _holdremisolation_display
   ENDIF
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   IF (growsum > 0)
    SET bcontinue = 1
   ELSE
    SET bcontinue = 0
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (rn_header(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = rn_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (rn_headerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(1.250000), private
   DECLARE __assign = vc WITH noconstant(build2(ticket->rn,char(0))), protect
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 2.813)
    SET rptsd->m_width = 4.875
    SET rptsd->m_height = 0.261
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "(Please Print):_______________________________________________________",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.073)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 0.875
    SET rptsd->m_height = 0.178
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Assigned RN : ",char(0)))
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.073)
    SET rptsd->m_x = (offsetx+ 1.000)
    SET rptsd->m_width = 2.813
    SET rptsd->m_height = 0.188
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,__assign)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.058),(offsetx+ 7.751),(offsety+
     0.058))
    SET _dummypen = uar_rptsetpen(_hreport,_pen50s1c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.000),(offsety+ 0.317),(offsetx+ 7.751),(offsety+
     0.317))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.438)
    SET rptsd->m_x = (offsetx+ 0.021)
    SET rptsd->m_width = 2.667
    SET rptsd->m_height = 0.261
    SET _dummypen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Procedure/Diagnostic Imaging Tech Name:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.719)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 4.375
    SET rptsd->m_height = 0.219
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Patient arrived in Diagnostic Imaging completely prepped and ready for exam:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.000)
    SET rptsd->m_x = (offsetx+ 0.053)
    SET rptsd->m_width = 7.636
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Comments:___________________________________________________________________________________________________________",
      char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.719)
    SET rptsd->m_x = (offsetx+ 4.938)
    SET rptsd->m_width = 0.251
    SET rptsd->m_height = 0.219
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Yes",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.719)
    SET rptsd->m_x = (offsetx+ 6.063)
    SET rptsd->m_width = 0.521
    SET rptsd->m_height = 0.219
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("No",char(0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 4.813),(offsety+ 0.750),0.105,0.104,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 5.938),(offsety+ 0.750),0.105,0.104,
     rpt_nofill,rpt_white)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (text2_header(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = text2_headerabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (text2_headerabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(2.690000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 2.376)
    SET rptsd->m_x = (offsetx+ 1.313)
    SET rptsd->m_width = 6.230
    SET rptsd->m_height = 0.230
    SET _oldfont = uar_rptsetfont(_hreport,_times100)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "_____________________________________________________________________________________",char(0)
      ))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.126)
    SET rptsd->m_x = (offsetx+ 2.126)
    SET rptsd->m_width = 5.667
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "_____________________________________________________________________________________",char(0)
      ))
    SET rptsd->m_flags = 20
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.011)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 7.750
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times14b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Return Trip Infomation",char(0)))
    SET rptsd->m_flags = 4
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.251)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.948
    SET rptsd->m_height = 0.188
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Patient Response during and after exam/Procedure:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 0.250)
    SET rptsd->m_width = 1.063
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Tolerated well",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.750)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.125
    SET rptsd->m_height = 0.261
    SET _dummyfont = uar_rptsetfont(_hreport,_times10b0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Pain Management:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.376)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 1.313
    SET rptsd->m_height = 0.251
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Staff Member Name:",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 2.126)
    SET rptsd->m_x = (offsetx+ 0.000)
    SET rptsd->m_width = 2.188
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Additional Comments/Information:",
      char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.938)
    SET rptsd->m_x = (offsetx+ 0.157)
    SET rptsd->m_width = 2.126
    SET rptsd->m_height = 0.178
    SET _dummyfont = uar_rptsetfont(_hreport,_times100)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Patient experienced pain during exam: ",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.334)
    SET rptsd->m_x = (offsetx+ 0.157)
    SET rptsd->m_width = 5.938
    SET rptsd->m_height = 0.178
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Pain Score:____/10 Intervention:__________________________________________________________________________________",
      char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.532)
    SET rptsd->m_x = (offsetx+ 0.157)
    SET rptsd->m_width = 4.375
    SET rptsd->m_height = 0.178
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Post-intervention Score:___/10",char(
       0)))
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 3.875),(offsety+ 0.521),0.105,0.104,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 1.313),(offsety+ 0.510),0.105,0.104,
     rpt_nofill,rpt_white)
    SET _rptstat = uar_rptrect(_hreport,(offsetx+ 0.105),(offsety+ 0.510),0.105,0.104,
     rpt_nofill,rpt_white)
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 1.501)
    SET rptsd->m_width = 2.313
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Unable to tolerate - test not Completed    ",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.500)
    SET rptsd->m_x = (offsetx+ 4.000)
    SET rptsd->m_width = 3.751
    SET rptsd->m_height = 0.261
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Other:__________________________________________________",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.938)
    SET rptsd->m_x = (offsetx+ 2.876)
    SET rptsd->m_width = 0.251
    SET rptsd->m_height = 0.178
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Yes",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 0.938)
    SET rptsd->m_x = (offsetx+ 3.376)
    SET rptsd->m_width = 0.251
    SET rptsd->m_height = 0.178
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("No",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.136)
    SET rptsd->m_x = (offsetx+ 0.157)
    SET rptsd->m_width = 2.438
    SET rptsd->m_height = 0.178
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Patient experienced pain after exam: ",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 2.876)
    SET rptsd->m_width = 0.251
    SET rptsd->m_height = 0.178
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("Yes",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.125)
    SET rptsd->m_x = (offsetx+ 3.376)
    SET rptsd->m_width = 0.251
    SET rptsd->m_height = 0.178
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2("No",char(0)))
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_y = (offsety+ 1.750)
    SET rptsd->m_x = (offsetx+ 0.157)
    SET rptsd->m_width = 5.188
    SET rptsd->m_height = 0.178
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(
      "Interventions for Pain (i.e. meds given):________________________________",char(0)))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (page_ticket(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = page_ticketabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (page_ticketabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.540000), private
   IF (ncalc=rpt_render)
    SET rptsd->m_flags = 0
    SET rptsd->m_borders = rpt_sdnoborders
    SET rptsd->m_padding = rpt_sdnoborders
    SET rptsd->m_paddingwidth = 0.000
    SET rptsd->m_linespacing = rpt_single
    SET rptsd->m_rotationangle = 0
    SET rptsd->m_y = (offsety+ 0.126)
    SET rptsd->m_x = (offsetx+ 5.813)
    SET rptsd->m_width = 1.625
    SET rptsd->m_height = 0.261
    SET _oldfont = uar_rptsetfont(_hreport,_times10b0)
    SET _oldpen = uar_rptsetpen(_hreport,_pen14s0c0)
    SET _fdrawheight = uar_rptstringdraw(_hreport,rptsd,build2(rpt_pageofpage,char(0)))
    SET _dummypen = uar_rptsetpen(_hreport,_pen28s0c0)
    SET _rptstat = uar_rptline(_hreport,(offsetx+ 0.011),(offsety+ 0.058),(offsetx+ 7.751),(offsety+
     0.058))
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE (foot_report(ncalc=i2) =f8 WITH protect)
   DECLARE a1 = f8 WITH noconstant(0.0), private
   SET a1 = foot_reportabs(ncalc,_xoffset,_yoffset)
   RETURN(a1)
 END ;Subroutine
 SUBROUTINE (foot_reportabs(ncalc=i2,offsetx=f8,offsety=f8) =f8 WITH protect)
   DECLARE sectionheight = f8 WITH noconstant(0.520000), private
   IF (ncalc=rpt_render)
    SET _yoffset = (offsety+ sectionheight)
   ENDIF
   RETURN(sectionheight)
 END ;Subroutine
 SUBROUTINE initializereport(dummy)
   SET rptreport->m_recsize = 104
   SET rptreport->m_reportname = "BHS_RPT_TICKET_TO_RIDE"
   SET rptreport->m_pagewidth = 8.50
   SET rptreport->m_pageheight = 11.00
   SET rptreport->m_orientation = rpt_portrait
   SET rptreport->m_marginleft = 0.50
   SET rptreport->m_marginright = 0.25
   SET rptreport->m_margintop = 0.50
   SET rptreport->m_marginbottom = 0.25
   SET rptreport->m_horzprintoffset = _xshift
   SET rptreport->m_vertprintoffset = _yshift
   SET rptreport->m_dioflag = 0
   SET rptreport->m_needsnotonaskharabic = 0
   SET _yoffset = rptreport->m_margintop
   SET _xoffset = rptreport->m_marginleft
   SET _hreport = uar_rptcreatereport(rptreport,_outputtype,rpt_inches)
   SET _rpterr = uar_rptseterrorlevel(_hreport,rpt_error)
   SET _rptstat = uar_rptstartreport(_hreport)
   SET _rptpage = uar_rptstartpage(_hreport)
   CALL _createfonts(0)
   CALL _createpens(0)
 END ;Subroutine
 SUBROUTINE _createfonts(dummy)
   SET rptfont->m_recsize = 62
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_off
   SET rptfont->m_underline = rpt_off
   SET rptfont->m_strikethrough = rpt_off
   SET rptfont->m_rgbcolor = rpt_black
   SET _times100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_helvetica
   SET rptfont->m_pointsize = 18
   SET _helvetica180 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_on
   SET _times10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_helvetica
   SET rptfont->m_pointsize = 12
   SET _helvetica12b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_pointsize = 10
   SET rptfont->m_bold = rpt_off
   SET rptfont->m_italic = rpt_on
   SET _times10i0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_helvetica
   SET rptfont->m_bold = rpt_on
   SET rptfont->m_italic = rpt_off
   SET _helvetica10b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_off
   SET _helvetica100 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_fontname = rpt_times
   SET rptfont->m_underline = rpt_on
   SET _times10u0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 14
   SET rptfont->m_bold = rpt_on
   SET rptfont->m_underline = rpt_off
   SET _times14b0 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_pointsize = 12
   SET rptfont->m_bold = rpt_off
   SET _times120 = uar_rptcreatefont(_hreport,rptfont)
   SET rptfont->m_bold = rpt_on
   SET _times12b0 = uar_rptcreatefont(_hreport,rptfont)
 END ;Subroutine
 SUBROUTINE _createpens(dummy)
   SET rptpen->m_recsize = 16
   SET rptpen->m_penwidth = 0.014
   SET rptpen->m_penstyle = 0
   SET rptpen->m_rgbcolor = rpt_black
   SET _pen14s0c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penstyle = 1
   SET _pen14s1c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.050
   SET _pen50s1c0 = uar_rptcreatepen(_hreport,rptpen)
   SET rptpen->m_penwidth = 0.028
   SET rptpen->m_penstyle = 0
   SET _pen28s0c0 = uar_rptcreatepen(_hreport,rptpen)
 END ;Subroutine
 SET page_size = 10.18
 SET d0 = initializereport(0)
 SET d0 = ticket_header(rpt_render)
 SET remain_space = (page_size - _yoffset)
 SET becont = 0
 SET d0 = allergy_details(rpt_render,remain_space,becont)
 FOR (b_prt = 1 TO size(ticket->code_status_orders,5))
   SET remain_space = (page_size - _yoffset)
   IF (b_prt=1)
    SET d0 = code_stat_header(rpt_render)
   ENDIF
   IF ((((_yoffset+ code_stat_detail(rpt_calcheight,remain_space,becont))+ page_ticket(rpt_calcheight
    )) > page_size)
    AND curendreport=0)
    SET _yoffset = 10.18
    SET d0 = page_ticket(rpt_render)
    SET d0 = pagebreak(0)
    SET continued = "(continued)"
    SET d0 = code_stat_header(rpt_render)
    SET continued = ""
    SET remain_space = (page_size - _yoffset)
   ENDIF
   WHILE (becont=1)
     SET d0 = page_ticket(rpt_render)
     SET _yoffset = 10.18
     SET d0 = pagebreak(0)
     SET continued = "(continued)"
     SET d0 = code_stat_header(rpt_render)
     SET continued = ""
     SET remain_space = (page_size - _yoffset)
     SET becont = 0
   ENDWHILE
   SET d0 = code_stat_detail(rpt_render,remain_space,becont)
 ENDFOR
 SET remain_space = (page_size - _yoffset)
 IF (((artifical_airway(rpt_calcheight)+ page_ticket(rpt_calcheight)) > remain_space)
  AND curendreport=0)
  SET _yoffset = 10.18
  SET d0 = page_ticket(rpt_render)
  SET d0 = pagebreak(0)
  SET remain_space = (page_size - _yoffset)
 ENDIF
 SET d0 = artifical_airway(rpt_render)
 IF (size(ticket->cov19_results,5) > 0)
  SET remain_space = (page_size - _yoffset)
  IF (((cov_res_head(calcheight)+ (cov_res_det(calcheight) * 3)) > remain_space)
   AND curendreport=0)
   SET _yoffset = 10.18
   SET d0 = page_ticket(rpt_render)
   SET d0 = pagebreak(0)
   SET remain_space = (page_size - _yoffset)
  ENDIF
  CALL cov_res_head(rpt_render)
  FOR (ml_loop = 1 TO size(ticket->cov19_results,5))
    CALL cov_res_det(rpt_render)
  ENDFOR
 ENDIF
 SET remain_space = (page_size - _yoffset)
 IF (cnvtint(ticket->s_hump_dump_score) IN (7, 8, 9, 10, 11))
  SET label_fall_risk = ticket->s_hump_dump_label
  SET result_fall_risk = "Low Risk"
 ELSEIF (cnvtint(ticket->s_hump_dump_score) >= 12)
  SET label_fall_risk = ticket->s_hump_dump_label
  SET result_fall_risk = "High Risk"
 ENDIF
 SET remain_space = (page_size - _yoffset)
 IF (((fail_risk_header(rpt_calcheight)+ page_ticket(rpt_calcheight)) > remain_space)
  AND curendreport=0)
  SET _yoffset = 10.18
  SET d0 = page_ticket(rpt_render)
  SET d0 = pagebreak(0)
  SET remain_space = (page_size - _yoffset)
 ENDIF
 SET d0 = fail_risk_header(rpt_render)
 FOR (d_prt = 1 TO size(ticket->isolation,5))
   SET remain_space = (page_size - _yoffset)
   IF (d_prt=1)
    SET d0 = isolation_header(rpt_render)
   ENDIF
   IF (((_yoffset+ isolation_details(rpt_calcheight,remain_space,becont)) > page_size)
    AND curendreport=0)
    SET _yoffset = 10.18
    SET d0 = page_ticket(rpt_render)
    SET d0 = pagebreak(0)
    SET continued = "(continued)"
    SET d0 = isolation_header(rpt_render)
    SET continued = ""
    SET remain_space = (page_size - _yoffset)
   ENDIF
   SET d0 = isolation_details(rpt_render,remain_space,becont)
   WHILE (becont=1)
     SET _yoffset = 10.18
     SET d0 = page_ticket(rpt_render)
     SET d0 = pagebreak(0)
     SET continued = "(continued)"
     SET d0 = isolation_header(rpt_render)
     SET continued = ""
     SET remain_space = (page_size - _yoffset)
     SET becont = 0
     SET d0 = isolation_details(rpt_render,remain_space,becont)
   ENDWHILE
 ENDFOR
 SET orientation_psych = fillstring(100,"#")
 SET alertness = fillstring(100,"#")
 IF ((ticket->orientation_res=null)
  AND (ticket->neurologicaled=null))
  SET orientation_psych = trim("No Results in last 12 hrs",3)
 ELSEIF ((ticket->neurologicaled=null))
  SET orientation_psych = trim(ticket->orientation_res,3)
 ELSEIF ((ticket->orientation_res=null))
  SET orientation_psych = trim(ticket->neurologicaled,3)
 ELSEIF ((ticket->orientatedpersonplacetime_dttm > ticket->neurologicaled_dttm))
  SET orientation_psych = trim(ticket->orientation_res,3)
 ELSE
  SET orientation_psych = trim(ticket->neurologicaled,3)
 ENDIF
 IF ((ticket->levelofconsciousness=null)
  AND (ticket->psychosocialed=null))
  SET alertness = trim("No Results in last 12 hrs",3)
 ELSEIF ((ticket->psychosocialed=null))
  SET alertness = trim(ticket->levelofconsciousness,3)
 ELSEIF ((ticket->levelofconsciousness=null))
  SET alertness = trim(ticket->psychosocialed,3)
 ELSEIF ((ticket->orientatedpersonplacetime_dttm > ticket->psychosocialed_dttm))
  SET alertness = trim(ticket->levelofconsciousness,3)
 ELSE
  SET alertness = trim(ticket->psychosocialed,3)
 ENDIF
 SET remain_space = (page_size - _yoffset)
 IF (psychosocialed_header(rpt_calcheight) > remain_space)
  SET _yoffset = 10.18
  SET d0 = page_ticket(rpt_render)
  SET d0 = pagebreak(0)
  SET remain_space = (page_size - _yoffset)
 ENDIF
 CALL echo(build("psychosocialed_header(Rpt_CalcHeight) =",psychosocialed_header(rpt_calcheight)))
 SET d0 = psychosocialed_header(rpt_render)
 CALL echo(build("_Yoffset = ",_yoffset))
 CALL echo(build("ambulation_devices = ",ambulation_devices))
 IF ( NOT ((ticket->ambulation IN (null, "", " "))))
  SET ambulation_devices = ticket->ambulation
 ENDIF
 IF ( NOT ((ticket->ambulation IN (null, "", " ")))
  AND  NOT ((ticket->assistive_devices IN (null, "", " "))))
  SET ambulation_devices = concat(trim(ambulation_devices,3),";",trim(ticket->assistive_devices,3))
 ELSEIF ( NOT ((ticket->assistive_devices IN (null, "", " "))))
  SET ambulation_devices = trim(ticket->assistive_devices,3)
 ENDIF
 CALL echo(build("ambulation_devices = ",ambulation_devices))
 SET remain_space = (page_size - _yoffset)
 IF (((special_needs_header(rpt_calcheight)+ language_header(rpt_calcheight)) > remain_space))
  SET _yoffset = 10.18
  SET d0 = page_ticket(rpt_render)
  SET d0 = pagebreak(0)
  SET remain_space = (page_size - _yoffset)
 ENDIF
 SET d0 = special_needs_header(rpt_render)
 SET d0 = language_header(rpt_render)
 SET remain_space = (page_size - _yoffset)
 IF (interpreter_header(rpt_calcheight) > remain_space)
  SET _yoffset = 10.18
  SET d0 = page_ticket(rpt_render)
  SET d0 = pagebreak(0)
  SET d0 = special_needs_header(rpt_render)
  SET remain_space = (page_size - _yoffset)
  CALL echo(build("_Yoffset interpreter_header 1.5 = ",_yoffset))
 ENDIF
 SET d0 = interpreter_header(rpt_render)
 SET remain_space = (page_size - _yoffset)
 IF (comunicate_bar_header(rpt_calcheight) > remain_space)
  SET _yoffset = 10.18
  SET d0 = page_ticket(rpt_render)
  SET d0 = pagebreak(0)
  SET d0 = special_needs_header(rpt_render)
  SET remain_space = (page_size - _yoffset)
 ENDIF
 SET d0 = comunicate_bar_header(rpt_render)
 SET remain_space = (page_size - _yoffset)
 IF (visitor_header(rpt_calcheight) > remain_space)
  SET _yoffset = 10.18
  SET d0 = page_ticket(rpt_render)
  SET d0 = pagebreak(0)
  SET d0 = special_needs_header(rpt_render)
  SET remain_space = (page_size - _yoffset)
 ENDIF
 SET d0 = visitor_header(rpt_render)
 SET remain_space = (page_size - _yoffset)
 IF (blood_press_veni(rpt_calcheight,remain_space,becont) > remain_space)
  SET _yoffset = 10.18
  SET d0 = page_ticket(rpt_render)
  SET d0 = pagebreak(0)
  SET d0 = special_needs_header(rpt_render)
  SET remain_space = (page_size - _yoffset)
 ENDIF
 SET d0 = blood_press_veni(rpt_render,remain_space,becont)
 SET remain_space = (page_size - _yoffset)
 IF (wearing_bpv_band(rpt_calcheight) > remain_space)
  SET _yoffset = 10.18
  SET d0 = page_ticket(rpt_render)
  SET d0 = pagebreak(0)
  SET d0 = special_needs_header(rpt_render)
  SET remain_space = (page_size - _yoffset)
 ENDIF
 SET d0 = wearing_bpv_band(rpt_render)
 SET remain_space = (page_size - _yoffset)
 IF (mobility_header(rpt_calcheight) > remain_space)
  SET _yoffset = 10.18
  SET d0 = page_ticket(rpt_render)
  SET d0 = pagebreak(0)
  SET d0 = special_needs_header(rpt_render)
  SET remain_space = (page_size - _yoffset)
 ENDIF
 SET d0 = mobility_header(rpt_render)
 SET remain_space = (page_size - _yoffset)
 IF (ambulation_header(rpt_calcheight) > remain_space)
  SET _yoffset = 10.18
  SET d0 = page_ticket(rpt_render)
  SET d0 = pagebreak(0)
  SET d0 = special_needs_header(rpt_render)
  SET remain_space = (page_size - _yoffset)
 ENDIF
 SET d0 = ambulation_header(rpt_render)
 SET remain_space = (page_size - _yoffset)
 IF (moblil_sensor_header(rpt_calcheight) > remain_space)
  SET _yoffset = 10.18
  SET d0 = page_ticket(rpt_render)
  SET d0 = pagebreak(0)
  SET d0 = special_needs_header(rpt_render)
  SET remain_space = (page_size - _yoffset)
 ENDIF
 SET d0 = moblil_sensor_header(rpt_render)
 SET remain_space = (page_size - _yoffset)
 IF (mobility_header(rpt_calcheight) > remain_space)
  SET _yoffset = 10.18
  SET d0 = page_ticket(rpt_render)
  SET d0 = pagebreak(0)
  SET d0 = special_needs_header(rpt_render)
  SET remain_space = (page_size - _yoffset)
 ENDIF
 SET d0 = mobility_header(rpt_render)
 SET remain_space = (page_size - _yoffset)
 IF ((ticket->lastvoid=null))
  SET last_void_result = trim("No Results in Last 12 hours",3)
  SET ticket->bladderdistention = trim("No Results in Last 12 hours",3)
 ELSE
  SET last_void_result = trim(ticket->lastvoid,3)
 ENDIF
 IF ((((_yoffset+ last_void_header(rpt_calcheight))+ page_ticket(rpt_calcheight)) > remain_space)
  AND curendreport=0)
  SET d0 = page_ticket(rpt_render)
  SET d0 = pagebreak(0)
  SET continued = "(continued)"
  SET remain_space = (page_size - _yoffset)
 ENDIF
 SET d0 = last_void_header(rpt_render)
 FOR (c_prt = 1 TO size(ticket->pain_meds,5))
   SET remain_space = (page_size - _yoffset)
   IF (c_prt=1)
    SET d0 = pain_ord_header(rpt_render)
   ENDIF
   IF ((((_yoffset+ pain_ord_detail(rpt_calcheight,remain_space,becont))+ page_ticket(rpt_calcheight)
   ) > page_size)
    AND curendreport=0)
    SET _yoffset = 10.18
    SET d0 = page_ticket(rpt_render)
    SET d0 = pagebreak(0)
    SET continued = "(continued)"
    SET d0 = pain_ord_header(rpt_render)
    SET continued = ""
    SET remain_space = (page_size - _yoffset)
   ENDIF
   SET d0 = pain_ord_detail(rpt_render,remain_space,becont)
   WHILE (becont=1)
     SET _yoffset = 10.18
     SET d0 = page_ticket(rpt_render)
     SET d0 = pagebreak(0)
     SET continued = "test continued"
     SET d0 = pain_ord_header(rpt_render)
     SET continued = ""
     SET remain_space = (page_size - _yoffset)
     SET becont = 0
     SET d0 = pain_ord_detail(rpt_render,remain_space,becont)
   ENDWHILE
 ENDFOR
 FOR (a_prt = 1 TO size(ticket->diag_orders,5))
   SET remain_space = (page_size - _yoffset)
   IF (a_prt=1)
    SET d0 = diag_orders_header(rpt_render)
   ENDIF
   SET remain_space = (page_size - _yoffset)
   IF (diag_orders_detail(rpt_calcheight,remain_space,becont) > page_size
    AND curendreport=0)
    SET _yoffset = 10.18
    SET d0 = page_ticket(rpt_render)
    SET d0 = pagebreak(0)
    SET continued = "(continued)"
    SET d0 = diag_orders_header(rpt_render)
    SET continued = ""
    SET remain_space = (page_size - _yoffset)
   ENDIF
   WHILE (becont=1)
     SET _yoffset = 10.18
     SET d0 = page_ticket(rpt_render)
     SET d0 = pagebreak(0)
     SET continued = "test continued"
     SET d0 = diag_orders_header(rpt_render)
     SET continued = ""
     SET remain_space = (page_size - _yoffset)
     SET becont = 0
   ENDWHILE
   SET d0 = diag_orders_detail(rpt_render,remain_space,becont)
 ENDFOR
 SET remain_space = (page_size - _yoffset)
 IF (text1_header(rpt_calcheight) > remain_space)
  SET _yoffset = 10.18
  SET d0 = page_ticket(rpt_render)
  SET d0 = pagebreak(0)
  SET continued = "(continued)"
  SET remain_space = (page_size - _yoffset)
 ENDIF
 SET d0 = text1_header(rpt_render)
 SET remain_space = (page_size - _yoffset)
 IF (((rn_header(rpt_calcheight)+ page_ticket(rpt_calcheight)) > remain_space))
  SET _yoffset = 10.18
  SET d0 = page_ticket(rpt_render)
  SET d0 = pagebreak(0)
  SET continued = "(continued)"
  SET remain_space = (page_size - _yoffset)
 ENDIF
 SET d0 = rn_header(rpt_render)
 SET remain_space = (page_size - _yoffset)
 IF (((text2_header(rpt_calcheight)+ page_ticket(rpt_calcheight)) > remain_space))
  SET _yoffset = 10.18
  SET d0 = page_ticket(rpt_render)
  SET d0 = pagebreak(0)
  SET continued = "(continued)"
  SET remain_space = (page_size - _yoffset)
 ENDIF
 SET d0 = text2_header(rpt_render)
 SET _yoffset = 10.18
 SET d0 = page_ticket(rpt_render)
 SET d0 = finalizereport( $OUTDEV)
END GO
