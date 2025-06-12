CREATE PROGRAM bed_get_pwrform_cern_sect_data:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 controls[*]
      2 cnt_input_key_id = f8
      2 description = vc
      2 section_uid = vc
      2 section_description = vc
      2 condition = vc
    1 forms[*]
      2 form_uid = vc
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
  FROM cnt_input i,
   cnt_input_key ik,
   cnt_section_key2 s
  PLAN (i
   WHERE i.pvc_name="conditional_section"
    AND i.merge_name="DCP_SECTION_REF"
    AND (i.cond_sect_uid=request->section_uid))
   JOIN (ik
   WHERE ik.section_uid=i.section_uid
    AND ik.input_description=i.input_description
    AND ik.input_ref_seq=i.input_ref_seq)
   JOIN (s
   WHERE s.section_uid=i.section_uid)
  ORDER BY s.section_description, i.input_description
  DETAIL
   ccnt = (ccnt+ 1), stat = alterlist(reply->controls,ccnt), reply->controls[ccnt].cnt_input_key_id
    = ik.cnt_input_key_id,
   reply->controls[ccnt].description = ik.input_description, reply->controls[ccnt].section_uid = s
   .section_uid, reply->controls[ccnt].section_description = s.section_definition,
   a = textlen(i.pvc_value), b = findstring(";",i.pvc_value), cond = substring(1,(b - 1),i.pvc_value)
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
   num_string = substring((b+ 1),(a - b),i.pvc_value), reply->controls[ccnt].condition = concat(trim(
     cond_string),trim(num_string))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM cnt_pf_section_r r,
   cnt_pf_key2 f
  PLAN (r
   WHERE (r.section_uid=request->section_uid))
   JOIN (f
   WHERE f.form_uid=r.form_uid)
  ORDER BY f.form_description
  HEAD f.form_uid
   fcnt = (fcnt+ 1), stat = alterlist(reply->forms,fcnt), reply->forms[fcnt].form_uid = f.form_uid,
   reply->forms[fcnt].description = f.form_definition
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
