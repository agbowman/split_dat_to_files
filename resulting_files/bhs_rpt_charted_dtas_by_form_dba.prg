CREATE PROGRAM bhs_rpt_charted_dtas_by_form:dba
 SELECT INTO  $OUTDEV
  sort = build2(dfr.dcp_forms_ref_id,cv.code_value)
  FROM dcp_forms_ref dfr,
   dcp_forms_def dfd,
   dcp_section_ref dsr,
   dcp_input_ref dir,
   name_value_prefs nvp,
   discrete_task_assay dta,
   code_value cv
  PLAN (dfr
   WHERE dfr.dcp_forms_ref_id > 0
    AND dfr.beg_effective_dt_tm <= cnvtdatetime(end_effective_dt_tm)
    AND dfr.end_effective_dt_tm >= cnvtdatetime(beg_effective_dt_tm)
    AND cnvtupper(dfr.description)="*")
   JOIN (dfd
   WHERE dfr.dcp_form_instance_id=dfd.dcp_form_instance_id
    AND dfr.dcp_forms_ref_id=dfr.dcp_forms_ref_id)
   JOIN (dsr
   WHERE dfd.dcp_section_ref_id=dsr.dcp_section_ref_id
    AND dsr.beg_effective_dt_tm <= cnvtdatetime(end_effective_dt_tm)
    AND dsr.end_effective_dt_tm >= cnvtdatetime(beg_effective_dt_tm))
   JOIN (dir
   WHERE dir.dcp_section_instance_id=dsr.dcp_section_instance_id
    AND dir.dcp_section_ref_id=dsr.dcp_section_ref_id)
   JOIN (nvp
   WHERE nvp.parent_entity_id=dir.dcp_input_ref_id
    AND nvp.parent_entity_name="DCP_INPUT_REF"
    AND cnvtupper(nvp.pvc_name)="*TASK*")
   JOIN (dta
   WHERE dta.task_assay_cd=nvp.merge_id
    AND dta.beg_effective_dt_tm <= cnvtdatetime(end_effective_dt_tm)
    AND dta.end_effective_dt_tm >= cnvtdatetime(beg_effective_dt_tm))
   JOIN (cv
   WHERE cv.code_set=72
    AND cv.code_value=dta.event_cd
    AND cv.display_key IN (patstring(dtadisplay)))
  ORDER BY sort
  HEAD sort
   stat = alterlist(dtalist->formqual,100), formcnt = (formcnt+ 1), dtalist->formqual[formcnt].
   dta_display = cv.display,
   dtalist->formqual[formcnt].dcp_form_ref_id = dfr.dcp_forms_ref_id, dtalist->formqual[formcnt].
   definition = dfr.definition, dtalist->formqual[formcnt].dta_displaykey = cv.display_key
  WITH nocounter
 ;end select
END GO
