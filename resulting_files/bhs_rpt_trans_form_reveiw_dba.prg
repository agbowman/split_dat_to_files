CREATE PROGRAM bhs_rpt_trans_form_reveiw:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Select Facility" = 673936.00,
  "Unit" = value(0.0),
  "Start date" = "CURDATE",
  "End Date" = "CURDATE"
  WITH outdev, fname, f_unit,
  s_start_date, s_end_date
 FREE RECORD frec
 RECORD frec(
   1 file_name = vc
   1 file_buf = vc
   1 file_desc = w8
   1 file_offset = i4
   1 file_dir = i4
 )
 FREE RECORD impella
 RECORD impella(
   1 l_ecnt = i4
   1 elst[*]
     2 f_person_id = f8
     2 f_encntr_id = f8
     2 s_mrn = vc
     2 s_patient_name = vc
     2 s_location = vc
     2 l_chtd = i4
     2 chartd[*]
       3 s_impellaperformancelevel = vc
       3 s_date_charted = vc
 ) WITH protect
 DECLARE mf_cs72_bp_product_rn_reqd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "BLOODPRODUCTSTRANSFUSEDRNWITREQD")), protect
 DECLARE mf_cs72_nursestatementofattestation = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",
   72,"NURSESTATEMENTOFATTESTATION"))
 DECLARE mf_cs18189_primaryeventid = f8 WITH constant(uar_get_code_by("DISPLAYKEY",18189,
   "PRIMARYEVENTID")), protect
 DECLARE mf_cs48_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",48,"ACTIVE")), protect
 DECLARE mf_cs319_fin_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"FIN NBR")), protect
 DECLARE mf_cs319_mrn_cd = f8 WITH constant(uar_get_code_by("MEANING",319,"MRN")), protect
 DECLARE mf_cs8_altered_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE mf_cs8_modified_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE mf_cs8_auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE mf_cs8_active = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"ACTIVE")), protect
 DECLARE mf_cs8_inprogress = f8 WITH constant(uar_get_code_by("DISPLAYKEY",8,"INPROGRESS")), protect
 DECLARE mf_cs72_nursewitnesstransfusion = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "NURSEWITNESSTRANSFUSION")), protect
 DECLARE mf_cs72_bp_rn_witnessrequired = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,
   "BLOODPRODUCTRNWITNESSREQUIRED")), protect
 DECLARE mf_cs72_transfusiontagform = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "TRANSFUSIONTAGFORM"))
 DECLARE ms_start_date = vc WITH noconstant( $S_START_DATE), protect
 DECLARE ms_end_date = vc WITH noconstant( $S_END_DATE), protect
 DECLARE location = vc WITH protect, noconstant("              ")
 DECLARE patient_name = vc WITH protect, noconstant("              ")
 DECLARE mrn = vc WITH protect, noconstant("              ")
 DECLARE ms_error = vc WITH protect, noconstant("              ")
 DECLARE ms_subject = vc WITH protect, noconstant("              ")
 DECLARE ml_cnt2 = i4 WITH noconstant(0), protect
 DECLARE ml_cnt = i4 WITH noconstant(0), protect
 DECLARE opr_var = vc WITH protect
 DECLARE lcheck = vc WITH protect
 DECLARE gcnt = i4 WITH noconstant(0), protect
 SET lcheck = substring(1,1,reflect(parameter(parameter2( $F_UNIT),0)))
 RECORD grec1(
   1 list[*]
     2 cv = f8
     2 disp = c15
 )
 IF (lcheck="L")
  SET opr_var = "IN"
  WHILE (lcheck > " ")
    SET gcnt += 1
    SET lcheck = substring(1,1,reflect(parameter(parameter2( $F_UNIT),gcnt)))
    CALL echo(lcheck)
    IF (lcheck > " ")
     IF (mod(gcnt,5)=1)
      SET stat = alterlist(grec1->list,(gcnt+ 4))
     ENDIF
     SET grec1->list[gcnt].cv = cnvtint(parameter(parameter2( $F_UNIT),gcnt))
     SET grec1->list[gcnt].disp = uar_get_code_display(parameter(parameter2( $F_UNIT),gcnt))
    ENDIF
  ENDWHILE
  SET gcnt -= 1
  SET stat = alterlist(grec1->list,gcnt)
 ELSE
  SET stat = alterlist(grec1->list,1)
  SET gcnt = 1
  SET grec1->list[1].cv =  $F_UNIT
  IF ((grec1->list[1].cv=0.0))
   SET grec1->list[1].disp = "All Units"
   SET opr_var = "!="
  ELSE
   SET grec1->list[1].disp = uar_get_code_display(grec1->list[1].cv)
   SET opr_var = "="
  ENDIF
 ENDIF
 SELECT INTO  $OUTDEV
  form = uar_get_code_display(ce.event_cd), patient_name = substring(1,100,p.name_full_formatted),
  mrn = trim(mrn.alias,3),
  fin = trim(fin.alias,3), nurse_unit = uar_get_code_display(el.loc_nurse_unit_cd),
  nurse_witness_required = bpw.result_val,
  blood_product_witness_required = substring(1,100,trim(bp.result_val,3)), date_first_signature =
  format(ce4.performed_dt_tm,"mm/dd/yyyy hh:mm;;Q"), orignal_nurse = tag.name_full_formatted,
  nurse_witness = ce2.result_val, nurse_attestation = pra.name_full_formatted, compliant =
  IF (trim(pra.name_full_formatted,3)=concat(trim(ce2.result_val,3),"*")
   AND concat(trim(ce2.result_val,3),"*") != trim(tag.name_full_formatted,3)) "Yes"
  ELSE "No"
  ENDIF
  FROM dcp_forms_ref dfr,
   dcp_forms_activity dfa,
   dcp_forms_activity_comp dfac,
   encntr_alias fin,
   encntr_alias mrn,
   person p,
   encounter e,
   encntr_loc_hist el,
   clinical_event ce,
   clinical_event ce4,
   clinical_event ce1,
   clinical_event ce1a,
   clinical_event ce2,
   clinical_event ce2a,
   clinical_event bpw,
   clinical_event bp,
   prsnl pra,
   prsnl tag
  PLAN (dfr
   WHERE dfr.end_effective_dt_tm >= cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0)
    AND dfr.beg_effective_dt_tm <= cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959)
    AND dfr.definition IN ("Transfusion Tag Form - BHS")
    AND dfr.active_ind=1)
   JOIN (dfa
   WHERE dfa.dcp_forms_ref_id=dfr.dcp_forms_ref_id
    AND dfa.updt_dt_tm >= cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0))
   JOIN (dfac
   WHERE dfac.dcp_forms_activity_id=dfa.dcp_forms_activity_id
    AND dfac.component_cd=mf_cs18189_primaryeventid
    AND dfac.parent_entity_name="CLINICAL_EVENT")
   JOIN (fin
   WHERE fin.encntr_id=dfa.encntr_id
    AND fin.active_ind=1
    AND fin.encntr_alias_type_cd=mf_cs319_fin_cd
    AND sysdate BETWEEN fin.beg_effective_dt_tm AND fin.end_effective_dt_tm)
   JOIN (mrn
   WHERE mrn.encntr_id=dfa.encntr_id
    AND mrn.active_ind=1
    AND mrn.encntr_alias_type_cd=mf_cs319_mrn_cd
    AND sysdate BETWEEN mrn.beg_effective_dt_tm AND mrn.end_effective_dt_tm)
   JOIN (e
   WHERE e.encntr_id=dfa.encntr_id
    AND (e.loc_facility_cd= $FNAME))
   JOIN (el
   WHERE el.encntr_id=e.encntr_id
    AND el.active_ind=1
    AND operator(el.loc_nurse_unit_cd,opr_var, $F_UNIT)
    AND el.end_effective_dt_tm >= dfa.version_dt_tm
    AND el.beg_effective_dt_tm <= dfa.version_dt_tm)
   JOIN (p
   WHERE p.person_id=e.person_id
    AND p.active_ind=1)
   JOIN (ce
   WHERE ce.event_id=dfac.parent_entity_id
    AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce.event_end_dt_tm BETWEEN cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0) AND
   cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959)
    AND ce.performed_dt_tm BETWEEN cnvtdatetime(cnvtdate2(ms_start_date,"DD-MMM-YYYY"),0) AND
   cnvtdatetime(cnvtdate2(ms_end_date,"DD-MMM-YYYY"),235959)
    AND ce.result_status_cd IN (mf_cs8_auth_cd, mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_active)
    AND ce.event_cd IN (mf_cs72_transfusiontagform))
   JOIN (ce4
   WHERE ce4.event_id=dfac.parent_entity_id
    AND ce4.result_status_cd IN (mf_cs8_auth_cd, mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_active,
   mf_cs8_inprogress)
    AND ce4.event_cd IN (mf_cs72_transfusiontagform)
    AND (ce4.valid_until_dt_tm=
   (SELECT
    min(ces.valid_until_dt_tm)
    FROM clinical_event ces
    WHERE ces.event_cd=ce4.event_cd
     AND ces.event_id=ce4.event_id
     AND ces.encntr_id=ce4.encntr_id
     AND ces.person_id=ce4.person_id)))
   JOIN (ce1
   WHERE ce1.parent_event_id=ce.event_id
    AND ce1.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce1.result_status_cd IN (mf_cs8_auth_cd, mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_active
   ))
   JOIN (ce1a
   WHERE ce1a.parent_event_id=ce.event_id
    AND ce1a.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce1a.result_status_cd IN (mf_cs8_auth_cd, mf_cs8_altered_cd, mf_cs8_modified_cd,
   mf_cs8_active))
   JOIN (bpw
   WHERE bpw.parent_event_id=ce1.event_id
    AND bpw.event_cd=mf_cs72_bp_rn_witnessrequired
    AND bpw.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND bpw.result_val="Yes"
    AND bpw.view_level=1)
   JOIN (bp
   WHERE bp.parent_event_id=bpw.parent_event_id
    AND bp.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND bp.result_status_cd IN (mf_cs8_auth_cd, mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_active)
    AND bp.event_cd IN (mf_cs72_bp_product_rn_reqd)
    AND bp.view_level=1)
   JOIN (ce2
   WHERE ce2.parent_event_id=ce1.event_id
    AND ce2.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce2.result_status_cd IN (mf_cs8_auth_cd, mf_cs8_altered_cd, mf_cs8_modified_cd, mf_cs8_active
   )
    AND ce2.event_cd IN (mf_cs72_nursewitnesstransfusion)
    AND ce2.view_level=1)
   JOIN (ce2a
   WHERE ce2a.parent_event_id=ce1a.event_id
    AND ce2a.result_status_cd IN (mf_cs8_auth_cd, mf_cs8_altered_cd, mf_cs8_modified_cd,
   mf_cs8_active)
    AND ce2a.view_level=1
    AND ce2a.valid_until_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ce2a.event_cd=mf_cs72_nursestatementofattestation)
   JOIN (pra
   WHERE pra.person_id=ce2a.performed_prsnl_id)
   JOIN (tag
   WHERE tag.person_id=ce4.performed_prsnl_id)
  ORDER BY nurse_unit, p.name_full_formatted, dfac.parent_entity_id
  WITH nocounter, format, separator = " ",
   format(date,";;Q")
 ;end select
END GO
