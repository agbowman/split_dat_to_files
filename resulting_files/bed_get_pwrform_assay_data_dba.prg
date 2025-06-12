CREATE PROGRAM bed_get_pwrform_assay_data:dba
 FREE SET reply
 RECORD reply(
   1 enabled_by[*]
     2 dcp_forms_ref_id = f8
     2 form_description = vc
     2 dcp_section_ref_id = f8
     2 section_description = vc
     2 task_assay_code_value = f8
     2 assay_description = vc
     2 condition = vc
   1 enables[*]
     2 dcp_forms_ref_id = f8
     2 form_description = vc
     2 dcp_section_ref_id = f8
     2 section_description = vc
     2 task_assay_code_value = f8
     2 assay_description = vc
     2 condition = vc
   1 sections[*]
     2 dcp_section_ref_id = f8
     2 section_description = vc
     2 input_ref_id = f8
     2 input_description = vc
     2 required_ind = i2
     2 condition = vc
     2 default = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET bcnt = 0
 SET ecnt = 0
 SET scnt = 0
 DECLARE cond = vc
 DECLARE cond_string = vc
 DECLARE num_string = vc
 DECLARE formsect = vc
 DECLARE sectinpt = vc
 SELECT INTO "nl:"
  formsect = concat(f.definition,s.definition)
  FROM name_value_prefs n,
   name_value_prefs n2,
   dcp_input_ref i,
   dcp_section_ref s,
   dcp_forms_def d,
   dcp_forms_ref f
  PLAN (n
   WHERE n.parent_entity_name="DCP_INPUT_REF"
    AND (n.parent_entity_id=request->input_ref_id)
    AND n.pvc_name="dta_condition"
    AND ((n.active_ind+ 0)=1))
   JOIN (n2
   WHERE n2.parent_entity_name="DCP_INPUT_REF"
    AND n2.pvc_name="discrete_task_assay"
    AND n2.merge_id=n.merge_id
    AND n2.active_ind=1)
   JOIN (i
   WHERE i.dcp_input_ref_id=n2.parent_entity_id
    AND i.active_ind=1)
   JOIN (s
   WHERE s.dcp_section_instance_id=i.dcp_section_instance_id
    AND s.active_ind=1)
   JOIN (d
   WHERE d.dcp_section_ref_id=s.dcp_section_ref_id
    AND d.active_ind=1)
   JOIN (f
   WHERE f.dcp_form_instance_id=d.dcp_form_instance_id
    AND f.active_ind=1)
  ORDER BY formsect
  HEAD formsect
   bcnt = (bcnt+ 1), stat = alterlist(reply->enabled_by,bcnt), reply->enabled_by[bcnt].
   dcp_forms_ref_id = f.dcp_forms_ref_id,
   reply->enabled_by[bcnt].form_description = f.description, reply->enabled_by[bcnt].
   dcp_section_ref_id = s.dcp_section_ref_id, reply->enabled_by[bcnt].section_description = s
   .description,
   reply->enabled_by[bcnt].task_assay_code_value = n.merge_id, reply->enabled_by[bcnt].
   assay_description = uar_get_code_display(n.merge_id), a = textlen(n.pvc_value),
   b = findstring(";",n.pvc_value), cond = substring(1,(b - 1),n.pvc_value)
   IF (cond="0")
    cond_string = "Equal to: "
   ELSEIF (cond="1")
    cond_string = "Less than: "
   ELSEIF (cond="2")
    cond_string = "Greater than: "
   ELSEIF (cond="3")
    cond_string = "Less than or equal to: "
   ELSEIF (cond="4")
    cond_string = "Greater than or equal to: "
   ELSEIF (cond="5")
    cond_string = "The control/section will be activated if the control value is same as: "
   ELSEIF (cond="6")
    cond_string = "Not equal to: "
   ELSEIF (cond="7")
    cond_string = "The control/section will be inactivated if the control value is same as: "
   ENDIF
   num_string = substring((b+ 1),(a - b),n.pvc_value), reply->enabled_by[bcnt].condition = concat(
    trim(cond_string),trim(num_string))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  formsect = concat(f.definition,s.definition)
  FROM name_value_prefs n,
   name_value_prefs n2,
   dcp_input_ref i,
   dcp_section_ref s,
   dcp_forms_def d,
   dcp_forms_ref f
  PLAN (n
   WHERE n.parent_entity_name="DCP_INPUT_REF"
    AND (n.merge_id=request->task_assay_code_value)
    AND n.pvc_name="dta_condition"
    AND ((n.active_ind+ 0)=1))
   JOIN (n2
   WHERE n2.parent_entity_name="DCP_INPUT_REF"
    AND n2.parent_entity_id=n.parent_entity_id
    AND n2.pvc_name="discrete_task_assay"
    AND n2.active_ind=1)
   JOIN (i
   WHERE i.dcp_input_ref_id=n.parent_entity_id
    AND i.active_ind=1)
   JOIN (s
   WHERE s.dcp_section_ref_id=i.dcp_section_ref_id
    AND s.active_ind=1)
   JOIN (d
   WHERE d.dcp_section_ref_id=s.dcp_section_ref_id
    AND d.active_ind=1)
   JOIN (f
   WHERE f.dcp_form_instance_id=d.dcp_form_instance_id
    AND f.active_ind=1)
  ORDER BY formsect
  HEAD formsect
   ecnt = (ecnt+ 1), stat = alterlist(reply->enables,ecnt), reply->enables[ecnt].dcp_forms_ref_id = f
   .dcp_forms_ref_id,
   reply->enables[ecnt].form_description = f.definition, reply->enables[ecnt].dcp_section_ref_id = s
   .dcp_section_ref_id, reply->enables[ecnt].section_description = s.definition,
   reply->enables[ecnt].task_assay_code_value = n2.merge_id, reply->enables[ecnt].assay_description
    = uar_get_code_display(n2.merge_id), a = textlen(n.pvc_value),
   b = findstring(";",n.pvc_value), cond = substring(1,(b - 1),n.pvc_value)
   IF (cond="0")
    cond_string = "Equal to: "
   ELSEIF (cond="1")
    cond_string = "Less than: "
   ELSEIF (cond="2")
    cond_string = "Greater than: "
   ELSEIF (cond="3")
    cond_string = "Less than or equal to: "
   ELSEIF (cond="4")
    cond_string = "Greater than or equal to: "
   ELSEIF (cond="5")
    cond_string = "The control/section will be activated if the control value is same as: "
   ELSEIF (cond="6")
    cond_string = "Not equal to: "
   ELSEIF (cond="7")
    cond_string = "The control/section will be inactivated if the control value is same as: "
   ENDIF
   num_string = substring((b+ 1),(a - b),n.pvc_value), reply->enables[ecnt].condition = concat(trim(
     cond_string),trim(num_string))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  sectinpt = concat(s.definition,i.description)
  FROM name_value_prefs n,
   name_value_prefs n2,
   dcp_section_ref sr,
   dcp_input_ref i,
   dcp_section_ref s
  PLAN (n
   WHERE n.parent_entity_name="DCP_INPUT_REF"
    AND (n.merge_id=request->task_assay_code_value)
    AND n.pvc_name="discrete_task_assay"
    AND ((n.active_ind+ 0)=1))
   JOIN (i
   WHERE i.dcp_input_ref_id=n.parent_entity_id
    AND i.active_ind=1)
   JOIN (s
   WHERE s.dcp_section_instance_id=i.dcp_section_instance_id
    AND s.active_ind=1)
   JOIN (n2
   WHERE n2.parent_entity_name=outerjoin("DCP_INPUT_REF")
    AND n2.parent_entity_id=outerjoin(n.parent_entity_id)
    AND n2.pvc_name=outerjoin("conditional_section")
    AND n2.active_ind=outerjoin(1))
   JOIN (sr
   WHERE sr.dcp_section_ref_id=outerjoin(n2.merge_id)
    AND sr.active_ind=outerjoin(1))
  ORDER BY sectinpt
  HEAD sectinpt
   scnt = (scnt+ 1), stat = alterlist(reply->sections,scnt), reply->sections[scnt].dcp_section_ref_id
    = s.dcp_section_ref_id,
   reply->sections[scnt].section_description = s.definition, reply->sections[scnt].input_ref_id = i
   .dcp_input_ref_id, reply->sections[scnt].input_description = i.description
   IF (n2.pvc_value > " ")
    a = textlen(n2.pvc_value), b = findstring(";",n2.pvc_value), cond = substring(1,(b - 1),n2
     .pvc_value)
    IF (cond="0")
     cond_string = "Equal to: "
    ELSEIF (cond="1")
     cond_string = "Less than: "
    ELSEIF (cond="2")
     cond_string = "Greater than: "
    ELSEIF (cond="3")
     cond_string = "Less than or equal to: "
    ELSEIF (cond="4")
     cond_string = "Greater than or equal to: "
    ELSEIF (cond="5")
     cond_string = "The control/section will be activated if the control value is same as: "
    ELSEIF (cond="6")
     cond_string = "Not equal to: "
    ELSEIF (cond="7")
     cond_string = "The control/section will be inactivated if the control value is same as: "
    ENDIF
    num_string = substring((b+ 1),(a - b),n2.pvc_value), reply->sections[scnt].condition = concat(
     trim(cond_string),trim(num_string)," then ",trim(sr.definition))
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
