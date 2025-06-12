CREATE PROGRAM cv_utl_form_no_ec:dba
 SET cnt = 0
 SELECT
  r.*, d.*, s.*,
  i.*, nv.*
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
    AND nv.pvc_name="discrete_task_assay")
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
   IF (i.input_type=1)
    CALL print("Label - ")
   ELSEIF (i.input_type=2)
    CALL print("Numeric Control - ")
   ELSEIF (i.input_type=22)
    CALL print("Numeric Control - ")
   ELSEIF (i.input_type=3)
    CALL print("Flexible Unit Control - ")
   ELSEIF (i.input_type=4)
    CALL print("AlphaList Control - ")
   ELSEIF (i.input_type=5)
    CALL print("MultiAlpha Grid - ")
   ELSEIF (i.input_type=6)
    CALL print("FreeText Control - ")
   ELSEIF (i.input_type=7)
    CALL print("Calculation Control - ")
   ELSEIF (i.input_type=8)
    CALL print("Static Unit Control - ")
   ELSEIF (i.input_type=9)
    CALL print("AlphaCombo Control - ")
   ELSEIF (i.input_type=10)
    CALL print("Date/Time Control - ")
   ELSEIF (i.input_type=11)
    CALL print("Allergy Control - ")
   ELSEIF (i.input_type=12)
    CALL print("Image Control - ")
   ELSEIF (i.input_type=13)
    CALL print("RTF Control - ")
   ELSEIF (i.input_type=14)
    CALL print("Discrete Grid - ")
   ELSEIF (i.input_type=15)
    CALL print("RepeatingAlpha Control - ")
   ELSEIF (i.input_type=16)
    CALL print("Comment Control - ")
   ELSEIF (i.input_type=17)
    CALL print("PowerGrid - ")
   ELSEIF (i.input_type=18)
    CALL print("Provider Control - ")
   ELSEIF (i.input_type=19)
    CALL print("Ultra Grid - ")
   ELSEIF (i.input_type=21)
    CALL print("Conversion Control - ")
   ELSE
    CALL print("Custom Control - ")
   ENDIF
   CALL print(concat("(",trim(cnvtstring(i.dcp_input_ref_id)),") - ",trim(i.description))), row + 1
  DETAIL
   col 15,
   CALL print(trim(nv.pvc_name)), col 40,
   CALL print(trim(substring(1,75,nv.pvc_value))), col 80,
   CALL print(trim(cnvtstring(nv.merge_id))),
   col 115,
   CALL print(trim(cnvtstring(dta.event_cd))), row + 1
  FOOT  i.dcp_input_ref_id
   row + 1
  FOOT  s.dcp_section_ref_id
   row + 2
  WITH nocounter
 ;end select
#exit_script
END GO
