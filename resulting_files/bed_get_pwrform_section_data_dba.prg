CREATE PROGRAM bed_get_pwrform_section_data:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 controls[*]
      2 input_ref_id = f8
      2 description = vc
      2 dcp_section_ref_id = f8
      2 section_description = vc
      2 condition = vc
    1 forms[*]
      2 dcp_forms_ref_id = f8
      2 description = vc
    1 status_data
      2 status = c1
      2 subeventstatus[*]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 SET fcnt = 0
 SET ccnt = 0
 DECLARE cond = vc
 DECLARE cond_string = vc
 DECLARE num_string = vc
 SELECT INTO "nl:"
  FROM name_value_prefs n,
   dcp_input_ref i,
   dcp_section_ref s
  PLAN (n
   WHERE n.parent_entity_name="DCP_INPUT_REF"
    AND n.pvc_name="conditional_section"
    AND n.merge_name="DCP_SECTION_REF"
    AND (n.merge_id=request->dcp_section_ref_id)
    AND ((n.active_ind+ 0)=1))
   JOIN (i
   WHERE i.dcp_input_ref_id=n.parent_entity_id
    AND i.active_ind=1)
   JOIN (s
   WHERE s.dcp_section_ref_id=i.dcp_section_ref_id
    AND s.active_ind=1)
  ORDER BY s.definition, i.description
  HEAD s.definition
   ccnt = (ccnt+ 1), stat = alterlist(reply->controls,ccnt), reply->controls[ccnt].input_ref_id = i
   .dcp_input_ref_id,
   reply->controls[ccnt].description = i.description, reply->controls[ccnt].dcp_section_ref_id = s
   .dcp_section_ref_id, reply->controls[ccnt].section_description = s.definition,
   a = textlen(n.pvc_value), b = findstring(";",n.pvc_value), cond = substring(1,(b - 1),n.pvc_value)
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
   num_string = substring((b+ 1),(a - b),n.pvc_value), reply->controls[ccnt].condition = concat(trim(
     cond_string),trim(num_string))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dcp_forms_def d,
   dcp_forms_ref f
  PLAN (d
   WHERE (d.dcp_section_ref_id=request->dcp_section_ref_id)
    AND d.active_ind=1)
   JOIN (f
   WHERE f.dcp_forms_ref_id=d.dcp_forms_ref_id
    AND f.active_ind=1)
  ORDER BY f.definition
  HEAD f.dcp_forms_ref_id
   fcnt = (fcnt+ 1), stat = alterlist(reply->forms,fcnt), reply->forms[fcnt].dcp_forms_ref_id = f
   .dcp_forms_ref_id,
   reply->forms[fcnt].description = f.definition
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
