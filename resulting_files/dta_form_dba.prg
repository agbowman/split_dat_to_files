CREATE PROGRAM dta_form:dba
 PROMPT
  "Task_assay_cd?  [0]  " = 0
 SELECT DISTINCT INTO mine
  section_display = substring(1,50,dsr.description), section_name = substring(1,50,dsr.definition),
  section_instance = dsr.dcp_section_instance_id,
  section_active_ind = dsr.active_ind, form_display = substring(1,50,dfr.description), form_name =
  substring(1,50,dfr.definition),
  form_instance = dfr.dcp_form_instance_id, form_active_ind = dfr.active_ind
  FROM dcp_forms_ref dfr,
   dcp_forms_def dfd,
   dcp_section_ref dsr,
   dcp_input_ref dir,
   name_value_prefs nvp
  PLAN (nvp
   WHERE nvp.merge_name="DISCRETE_TASK_ASSAY"
    AND nvp.parent_entity_name="DCP_INPUT_REF"
    AND (nvp.merge_id= $1)
    AND nvp.active_ind=1)
   JOIN (dir
   WHERE nvp.parent_entity_id=dir.dcp_input_ref_id
    AND dir.active_ind=1)
   JOIN (dsr
   WHERE dir.dcp_section_instance_id=dsr.dcp_section_instance_id
    AND dsr.active_ind=1)
   JOIN (dfd
   WHERE dsr.dcp_section_ref_id=dfd.dcp_section_ref_id
    AND dfd.active_ind=1)
   JOIN (dfr
   WHERE dfd.dcp_forms_ref_id=dfr.dcp_forms_ref_id
    AND dfr.active_ind=1)
  ORDER BY section_display, form_display
 ;end select
END GO
