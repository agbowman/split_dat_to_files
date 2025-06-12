CREATE PROGRAM cv_utl_get_form_dta:dba
 SET cnt = 0
 SELECT
  r.*, d.*, s.*,
  i.*, nv.*, event_disp = uar_get_code_display(dta.event_cd)
  FROM dcp_forms_ref r,
   dcp_forms_def d,
   dcp_section_ref s,
   dcp_input_ref i,
   name_value_prefs nv,
   discrete_task_assay dta
  PLAN (r
   WHERE (r.dcp_forms_ref_id= $1)
    AND r.active_ind=1)
   JOIN (d
   WHERE d.dcp_form_instance_id=r.dcp_form_instance_id)
   JOIN (s
   WHERE d.dcp_section_ref_id=s.dcp_section_ref_id
    AND s.active_ind=1)
   JOIN (i
   WHERE s.dcp_section_instance_id=i.dcp_section_instance_id)
   JOIN (nv
   WHERE nv.parent_entity_id=i.dcp_input_ref_id
    AND nv.parent_entity_name="DCP_INPUT_REF"
    AND nv.merge_id > 0)
   JOIN (dta
   WHERE dta.task_assay_cd=nv.merge_id)
  ORDER BY d.section_seq, i.input_ref_seq, nv.pvc_name,
   nv.sequence
  HEAD r.dcp_form_instance_id
   col 0,
   CALL print(concat(trim(r.description)," (",trim(cnvtstring(r.dcp_form_instance_id)),")")), row + 1
  HEAD s.dcp_section_instance_id
   col 5,
   CALL print(concat(trim(s.description)," (",trim(cnvtstring(s.dcp_section_instance_id)),")")), row
    + 1
  HEAD i.dcp_input_ref_id
   col 10
  DETAIL
   col 15
   IF (nv.pvc_name="discrete_task_assay")
    CALL print(trim(nv.pvc_name)), col 40,
    CALL print(trim(substring(1,75,nv.pvc_value))),
    col 80,
    CALL print(trim(cnvtstring(nv.merge_id))), col 95,
    dta.event_cd, col 110, event_disp,
    row + 1
   ENDIF
  FOOT  s.dcp_section_ref_id
   row + 2
  WITH nocounter, maxcol = 2000
 ;end select
#exit_script
END GO
