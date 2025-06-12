CREATE PROGRAM ams_pa_auto_resave:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Encounter id:" = 0
  WITH outdev, eid
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET script_failed = false
 SET table_name = fillstring(50," ")
 DECLARE serrmsg = vc WITH protect, noconstant("")
 DECLARE ierrcode = i2 WITH protect, noconstant(0)
 DECLARE bamsassociate = i2 WITH protect, noconstant(false)
 EXECUTE ams_define_toolkit_common
 SET bamsassociate = isamsuser(reqinfo->updt_id)
 IF ( NOT (bamsassociate))
  SET script_failed = exe_error
  SET serrmsg = "User must be a Cerner AMS associate to run this program from Explorer Menu"
  GO TO exit_script
 ENDIF
 FREE RECORD temp
 FREE RECORD temp1
 FREE RECORD codingrec
 RECORD codingrec(
   1 codingcount = i4
   1 arr[*]
     2 coding_id = f8
 )
 RECORD temp(
   1 coding_id = f8
   1 encntr_id = f8
   1 svc_cat_hist_id = f8
   1 encntr_slice_id = f8
   1 person_id = f8
   1 payment = i4
   1 birth_weight = i4
   1 ascpay = i4
   1 completed_dt_tm = dq8
   1 contributor_system_cd = f8
   1 cancer_code_cnt = i4
   1 updt_cnt = i4
   1 grouper_qual[*]
     2 nomenclature_id = f8
     2 source_identifier = vc
     2 source_string = vc
     2 drg_weight = i4
     2 outlier_days = i4
     2 outlier_cost = i4
     2 outlier_reimbursement_cost = i4
     2 drg_payor_cd = f8
     2 mdc_cd = f8
     2 mdc_apr_cd = f8
     2 risk_of_mortality_cd = f8
     2 severity_of_illness_cd = f8
     2 comorbidity_cd = f8
     2 source_vocabulary_cd = f8
     2 case_resource_weight = f8
     2 complexity_overlay = i2
     2 complexity_overlay_text = vc
     2 day_threshold = i2
     2 elos = f8
     2 alos = f8
     2 mcc = i2
     2 mcc_text = vc
     2 ontario_case_weight = f8
     2 patient_status = vc
     2 perdiem = f8
     2 hospital_base_rate = i4
     2 total_est_reimb = f8
     2 total_reimb = f8
     2 f_wies_weight = f8
     2 f_wies_funding = f8
     2 f_lt = f8
     2 f_ht = f8
     2 f_hrs_mech_vent = f8
   1 procedure_qual[*]
     2 nomenclature_id = f8
     2 source_identifier = vc
     2 source_string = vc
     2 note = vc
     2 surg_dt_tm = dq8
     2 surgeon_id = f8
     2 anesthesia_type_cd = f8
     2 anesthesia_minutes = i4
     2 tissue_type_cd = f8
     2 priority = i4
     2 proc_loc_cd = f8
     2 generic_val_cd = f8
     2 provider_qual[1]
       3 provider_id = f8
       3 proc_prsnl_reltn_cd = f8
     2 mod_qual[*]
       3 source_identifier = vc
       3 nomenclature_id = f8
     2 dgvp_ind = i2
     2 l_units_of_service = i4
   1 diag_qual[*]
     2 nomenclature_id = f8
     2 source_identifier = vc
     2 source_string = vc
     2 note = vc
     2 diag_type_cd = f8
     2 diag_dt_tm = dq8
     2 priority = i4
     2 mod_qual[0]
       3 source_identifier = vc
       3 nomenclature_id = f8
     2 hac_ind = i2
     2 f_present_on_admit_cd = f8
 )
 RECORD temp1(
   1 request
     2 encntr_id = f8
     2 person_id = f8
     2 grouper_qual[*]
       3 nomenclature_id = f8
       3 source_identifier = vc
       3 drg_weight = f8
       3 total_est_reimb = f8
     2 procedure_qual[*]
       3 nomenclature_id = f8
       3 source_identifier = vc
       3 note = vc
       3 surg_dt_tm = dq8
       3 surgeon_id = f8
       3 anesthesia_type_cd = f8
       3 anesthesia_minutes = i4
       3 tissue_type_cd = f8
       3 proc_loc_cd = f8
       3 generic_val_cd = f8
       3 priority = i4
       3 provider_qual[*]
         4 provider_id = f8
         4 proc_prsnl_reltn_cd = f8
       3 mod_qual[*]
         4 source_identifier = vc
         4 nomenclature_id = f8
 )
 RECORD temp3(
   1 f_encntr_id = f8
   1 f_person_id = f8
   1 procedure_list[*]
     2 f_parent_id = f8
     2 f_child_id = f8
     2 f_reltn_type_cd = f8
     2 f_reltn_subtype_cd = f8
     2 n_exists_ind = i2
   1 diagnosis_list[*]
     2 f_parent_id = f8
     2 f_child_id = f8
     2 f_reltn_type_cd = f8
     2 f_reltn_subtype_cd = f8
     2 n_exists_ind = i2
 )
 DECLARE final_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",17,"FINAL")), protect
 DECLARE ahshahamahealthcenter_var = f8 WITH constant(uar_get_code_by("DISPLAYKEY",220,
   "AHSHAHAMAHEALTHCENTER")), protect
 DECLARE mrn_var = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE finnbr_var = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE count = i4
 SELECT DISTINCT INTO "nl:"
  c.coding_id
  FROM coding c,
   person p,
   encntr_alias ea,
   encntr_alias ea1,
   encounter e,
   drg_encntr_extension dee,
   drg dr,
   procedure pr,
   nomenclature n,
   nomenclature n2,
   diagnosis d,
   nomenclature n3
  PLAN (c
   WHERE c.completed_dt_tm IS NOT null
    AND c.active_ind=1
    AND (c.encntr_id= $EID))
   JOIN (ea
   WHERE ea.encntr_id=c.encntr_id
    AND ea.active_ind=1
    AND ea.encntr_alias_type_cd=mrn_var)
   JOIN (ea1
   WHERE ea1.encntr_id=ea.encntr_id
    AND ea1.active_ind=1
    AND ea1.encntr_alias_type_cd=finnbr_var)
   JOIN (e
   WHERE e.encntr_id=ea.encntr_id
    AND e.active_ind=1
    AND e.loc_facility_cd=ahshahamahealthcenter_var)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (dee
   WHERE dee.encntr_id=outerjoin(e.encntr_id)
    AND dee.active_ind=outerjoin(1))
   JOIN (dr
   WHERE dr.person_id=outerjoin(dee.person_id)
    AND dr.active_ind=outerjoin(1))
   JOIN (n2
   WHERE n2.nomenclature_id=outerjoin(dr.nomenclature_id)
    AND n2.active_ind=outerjoin(1))
   JOIN (pr
   WHERE pr.encntr_id=outerjoin(e.encntr_id)
    AND pr.active_ind=outerjoin(1))
   JOIN (n
   WHERE n.nomenclature_id=outerjoin(pr.nomenclature_id)
    AND n.active_ind=outerjoin(1))
   JOIN (d
   WHERE d.encntr_id=outerjoin(pr.encntr_id)
    AND d.diag_type_cd=outerjoin(final_var)
    AND d.active_ind=outerjoin(1))
   JOIN (n3
   WHERE n3.nomenclature_id=outerjoin(d.nomenclature_id)
    AND n3.active_ind=outerjoin(1))
  HEAD REPORT
   codingcount = 0
  HEAD c.coding_id
   IF (mod(codingcount,10)=0)
    status = alterlist(codingrec->arr,(codingcount+ 10))
   ENDIF
   codingcount = (codingcount+ 1), codingrec->arr[codingcount].coding_id = c.coding_id
  FOOT REPORT
   codingrec->codingcount = codingcount, status = alterlist(codingrec->arr,codingcount)
  WITH maxrec = 100000, time = 200, nocounter
 ;end select
 IF ((codingrec->codingcount=0))
  CALL echo("Cannot resave the encounter - As the provided encounter is not finally coded.")
 ENDIF
 FOR (i = 1 TO codingrec->codingcount)
   SELECT INTO "nl:"
    c.coding_id, e.encntr_id, p.person_id,
    complete_dt_tm = cnvtdatetime(curdate,curtime3), c.birth_weight, dr.nomenclature_id,
    source_identifier = dee.source_identifier, source_string = n2.source_string, dee.drg_weight,
    dee.source_vocabulary_cd, dee.elos, dee.alos,
    dee.mcc_text, dr.mdc_cd, dr.risk_of_mortality_cd,
    dr.severity_of_illness_cd, pr.nomenclature_id, pr.diag_nomenclature_id,
    c.completed_dt_tm, n.source_identifier, n.source_string,
    d.nomenclature_id, n3.source_identifier, n3.source_string,
    d.diag_type_cd, d.diag_priority
    FROM coding c,
     person p,
     encntr_alias ea,
     encntr_alias ea1,
     encounter e,
     drg_encntr_extension dee,
     drg dr,
     procedure pr,
     nomenclature n,
     nomenclature n2,
     diagnosis d,
     nomenclature n3
    PLAN (c
     WHERE c.completed_dt_tm IS NOT null
      AND c.active_ind=1
      AND (c.coding_id=codingrec->arr[i].coding_id))
     JOIN (ea
     WHERE ea.encntr_id=c.encntr_id
      AND ea.active_ind=1
      AND ea.encntr_alias_type_cd=mrn_var)
     JOIN (ea1
     WHERE ea1.encntr_id=ea.encntr_id
      AND ea1.active_ind=1
      AND ea1.encntr_alias_type_cd=finnbr_var)
     JOIN (e
     WHERE e.encntr_id=ea.encntr_id
      AND e.active_ind=1
      AND e.loc_facility_cd=ahshahamahealthcenter_var)
     JOIN (p
     WHERE p.person_id=e.person_id
      AND p.active_ind=1)
     JOIN (dee
     WHERE dee.encntr_id=outerjoin(e.encntr_id)
      AND dee.active_ind=outerjoin(1))
     JOIN (dr
     WHERE dr.person_id=outerjoin(dee.person_id)
      AND dr.active_ind=outerjoin(1))
     JOIN (n2
     WHERE n2.nomenclature_id=outerjoin(dr.nomenclature_id)
      AND n2.active_ind=outerjoin(1))
     JOIN (pr
     WHERE pr.encntr_id=outerjoin(e.encntr_id)
      AND pr.active_ind=outerjoin(1))
     JOIN (n
     WHERE n.nomenclature_id=outerjoin(pr.nomenclature_id)
      AND n.active_ind=outerjoin(1))
     JOIN (d
     WHERE d.encntr_id=outerjoin(pr.encntr_id)
      AND d.diag_type_cd=outerjoin(final_var)
      AND d.active_ind=outerjoin(1))
     JOIN (n3
     WHERE n3.nomenclature_id=outerjoin(d.nomenclature_id)
      AND n3.active_ind=outerjoin(1))
    ORDER BY pr.nomenclature_id
    HEAD REPORT
     countgrouper = 0, countprocedures = 0, countdiag = 0,
     countcoding = 0
    HEAD e.encntr_id
     temp->coding_id = c.coding_id, temp->encntr_id = e.encntr_id, temp->person_id = p.person_id,
     temp->completed_dt_tm = complete_dt_tm, temp->contributor_system_cd = c.contributor_system_cd,
     temp3->f_encntr_id = e.encntr_id,
     temp3->f_person_id = p.person_id, temp1->request.encntr_id = e.encntr_id, temp1->request.
     person_id = p.person_id
    HEAD dr.nomenclature_id
     fail_ind = 0
     IF (mod(countgrouper,10)=0)
      status = alterlist(temp1->request.grouper_qual,(countgrouper+ 10)), status = alterlist(temp->
       grouper_qual,(countgrouper+ 10))
     ENDIF
     IF (countgrouper=0)
      countgrouper = (countgrouper+ 1), temp1->request.grouper_qual[countgrouper].nomenclature_id =
      dr.nomenclature_id, temp1->request.grouper_qual[countgrouper].source_identifier = dee
      .source_identifier,
      temp1->request.grouper_qual[countgrouper].drg_weight = dee.drg_weight, temp1->request.
      grouper_qual[countgrouper].total_est_reimb = dee.total_est_reimb, temp->grouper_qual[
      countgrouper].nomenclature_id = dr.nomenclature_id,
      temp->grouper_qual[countgrouper].source_identifier = dee.source_identifier, temp->grouper_qual[
      countgrouper].source_string = source_string, temp->grouper_qual[countgrouper].drg_weight = dee
      .drg_weight,
      temp->grouper_qual[countgrouper].source_vocabulary_cd = dee.source_vocabulary_cd, temp->
      grouper_qual[countgrouper].elos = dee.elos, temp->grouper_qual[countgrouper].alos = dee.alos,
      temp->grouper_qual[countgrouper].mdc_cd = dr.mdc_cd, temp->grouper_qual[countgrouper].
      risk_of_mortality_cd = dr.risk_of_mortality_cd, temp->grouper_qual[countgrouper].
      severity_of_illness_cd = dr.severity_of_illness_cd
     ELSE
      FOR (i = 1 TO countgrouper)
        IF ((temp1->request.grouper_qual[i].nomenclature_id=dr.nomenclature_id))
         fail_ind = 1
        ENDIF
      ENDFOR
      IF (fail_ind=0)
       countgrouper = (countgrouper+ 1), temp1->request.grouper_qual[countgrouper].nomenclature_id =
       dr.nomenclature_id, temp1->request.grouper_qual[countgrouper].source_identifier = dee
       .source_identifier,
       temp1->request.grouper_qual[countgrouper].drg_weight = dee.drg_weight, temp1->request.
       grouper_qual[countgrouper].total_est_reimb = dee.total_est_reimb, temp->grouper_qual[
       countgrouper].nomenclature_id = dr.nomenclature_id,
       temp->grouper_qual[countgrouper].source_identifier = dee.source_identifier, temp->
       grouper_qual[countgrouper].source_string = source_string, temp->grouper_qual[countgrouper].
       drg_weight = dee.drg_weight,
       temp->grouper_qual[countgrouper].source_vocabulary_cd = dee.source_vocabulary_cd, temp->
       grouper_qual[countgrouper].elos = dee.elos, temp->grouper_qual[countgrouper].alos = dee.alos,
       temp->grouper_qual[countgrouper].mdc_cd = dr.mdc_cd, temp->grouper_qual[countgrouper].
       risk_of_mortality_cd = dr.risk_of_mortality_cd, temp->grouper_qual[countgrouper].
       severity_of_illness_cd = dr.severity_of_illness_cd
      ENDIF
     ENDIF
    HEAD d.nomenclature_id
     IF (mod(countdiag,10)=0)
      status = alterlist(temp->diag_qual,(countdiag+ 10))
     ENDIF
     IF (countdiag=0)
      countdiag = (countdiag+ 1), temp->diag_qual[countdiag].nomenclature_id = d.nomenclature_id,
      temp->diag_qual[countdiag].source_identifier = n3.source_identifier,
      temp->diag_qual[countdiag].source_string = n3.source_string, temp->diag_qual[countdiag].
      diag_type_cd = d.diag_type_cd, temp->diag_qual[countdiag].priority = d.diag_priority
     ELSE
      IF ((d.nomenclature_id != temp->diag_qual[countdiag].nomenclature_id))
       countdiag = (countdiag+ 1), temp->diag_qual[countdiag].nomenclature_id = d.nomenclature_id,
       temp->diag_qual[countdiag].source_identifier = n3.source_identifier,
       temp->diag_qual[countdiag].source_string = n3.source_string, temp->diag_qual[countdiag].
       diag_type_cd = d.diag_type_cd, temp->diag_qual[countdiag].priority = d.diag_priority
      ENDIF
     ENDIF
    HEAD pr.nomenclature_id
     IF (mod(countprocedures,10)=0)
      status = alterlist(temp->procedure_qual,(countprocedures+ 10)), status = alterlist(temp1->
       request.procedure_qual,(countprocedures+ 10))
     ENDIF
     IF (countprocedures=0)
      countprocedures = (countprocedures+ 1), temp1->request.procedure_qual[countprocedures].
      nomenclature_id = pr.nomenclature_id, temp1->request.procedure_qual[countprocedures].surg_dt_tm
       = cnvtdatetime(pr.proc_dt_tm),
      temp1->request.procedure_qual[countprocedures].source_identifier = n.source_identifier, temp1->
      request.procedure_qual[countprocedures].anesthesia_minutes = pr.anesthesia_minutes, temp1->
      request.procedure_qual[countprocedures].anesthesia_type_cd = pr.anesthesia_cd,
      temp1->request.procedure_qual[countprocedures].generic_val_cd = pr.generic_val_cd, temp1->
      request.procedure_qual[countprocedures].note = pr.procedure_note, temp1->request.
      procedure_qual[countprocedures].priority = pr.proc_priority,
      temp1->request.procedure_qual[countprocedures].proc_loc_cd = pr.proc_loc_cd, temp1->request.
      procedure_qual[countprocedures].tissue_type_cd = pr.tissue_type_cd, temp->procedure_qual[
      countprocedures].nomenclature_id = pr.nomenclature_id,
      temp->procedure_qual[countprocedures].surg_dt_tm = cnvtdatetime(pr.proc_dt_tm), temp->
      procedure_qual[countprocedures].source_identifier = n.source_identifier, temp->procedure_qual[
      countprocedures].source_string = n.source_string
     ELSE
      IF ((pr.nomenclature_id != temp->procedure_qual[countprocedures].nomenclature_id))
       countprocedures = (countprocedures+ 1), temp1->request.procedure_qual[countprocedures].
       nomenclature_id = pr.nomenclature_id, temp1->request.procedure_qual[countprocedures].
       surg_dt_tm = cnvtdatetime(pr.proc_dt_tm),
       temp1->request.procedure_qual[countprocedures].source_identifier = n.source_identifier, temp1
       ->request.procedure_qual[countprocedures].anesthesia_minutes = pr.anesthesia_minutes, temp1->
       request.procedure_qual[countprocedures].anesthesia_type_cd = pr.anesthesia_cd,
       temp1->request.procedure_qual[countprocedures].generic_val_cd = pr.generic_val_cd, temp1->
       request.procedure_qual[countprocedures].note = pr.procedure_note, temp1->request.
       procedure_qual[countprocedures].priority = pr.proc_priority,
       temp1->request.procedure_qual[countprocedures].proc_loc_cd = pr.proc_loc_cd, temp1->request.
       procedure_qual[countprocedures].tissue_type_cd = pr.tissue_type_cd, temp->procedure_qual[
       countprocedures].nomenclature_id = pr.nomenclature_id,
       temp->procedure_qual[countprocedures].surg_dt_tm = cnvtdatetime(pr.proc_dt_tm), temp->
       procedure_qual[countprocedures].source_identifier = n.source_identifier, temp->procedure_qual[
       countprocedures].source_string = n.source_string
      ENDIF
     ENDIF
    FOOT REPORT
     status = alterlist(temp->diag_qual,countdiag), status = alterlist(temp->procedure_qual,
      countprocedures), status = alterlist(temp->grouper_qual,countgrouper),
     status = alterlist(temp1->request.procedure_qual,countprocedures), status = alterlist(temp1->
      request.grouper_qual,countgrouper)
    WITH maxrec = 100000, nocounter, time = 200
   ;end select
   CALL echo("before pause")
   CALL echo(build("Executing him_chg_coding_results"))
   EXECUTE him_chg_coding_results  WITH replace(request,temp)
   CALL echo("after results pause")
   COMMIT
   CALL echo("before pause of pfmt_hei_post_him_charges")
   CALL echo(build("Executing pfmt_hei_post_him_charges"))
   EXECUTE pfmt_hei_post_him_charges  WITH replace(requestin,temp1)
   CALL echo("after results pause of pfmt_hei_post_him_charges")
   COMMIT
   CALL echo("Encounter has been resaved successfully.....")
 ENDFOR
#exit_script
 IF (script_failed != false)
  SELECT INTO value( $OUTDEV)
   message = trim(substring(1,200,serrmsg),3)
   FROM (dummyt d  WITH seq = 1)
   WITH nocounter, format, separator = " "
  ;end select
 ENDIF
 IF (script_failed != exe_error)
  CALL updtdminfo(trim(cnvtupper(curprog),3))
 ENDIF
END GO
