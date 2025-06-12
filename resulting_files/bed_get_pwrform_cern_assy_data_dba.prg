CREATE PROGRAM bed_get_pwrform_cern_assy_data:dba
 FREE SET reply
 RECORD reply(
   1 enabled_by[*]
     2 form_uid = vc
     2 form_description = vc
     2 section_uid = vc
     2 section_description = vc
     2 task_assay_uid = vc
     2 assay_description = vc
     2 condition = vc
   1 enables[*]
     2 form_uid = vc
     2 form_description = vc
     2 section_uid = vc
     2 section_description = vc
     2 task_assay_uid = vc
     2 assay_description = vc
     2 condition = vc
   1 sections[*]
     2 section_uid = vc
     2 section_description = vc
     2 cnt_input_key_id = f8
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
  formsect = concat(f.form_description,s.section_description)
  FROM cnt_input_key ik,
   cnt_input i,
   cnt_input i2,
   cnt_input_key ik2,
   cnt_dta d,
   cnt_section_key2 s,
   cnt_pf_section_r r,
   cnt_pf_key2 f
  PLAN (ik
   WHERE (ik.cnt_input_key_id=request->cnt_input_key_id))
   JOIN (i
   WHERE i.section_uid=ik.section_uid
    AND i.input_description=ik.input_description
    AND i.input_ref_seq=ik.input_ref_seq
    AND i.pvc_name="dta_condition")
   JOIN (i2
   WHERE i2.pvc_name="discrete_task_assay"
    AND i2.task_assay_uid=i.task_assay_uid)
   JOIN (ik2
   WHERE ik2.section_uid=i2.section_uid
    AND ik2.input_description=i2.input_description
    AND ik2.input_ref_seq=i2.input_ref_seq)
   JOIN (d
   WHERE d.task_assay_uid=i.task_assay_uid)
   JOIN (s
   WHERE s.section_uid=i.section_uid)
   JOIN (r
   WHERE r.section_uid=s.section_uid)
   JOIN (f
   WHERE f.form_uid=r.form_uid)
  ORDER BY formsect
  HEAD formsect
   bcnt = (bcnt+ 1), stat = alterlist(reply->enabled_by,bcnt), reply->enabled_by[bcnt].form_uid = f
   .form_uid,
   reply->enabled_by[bcnt].form_description = f.form_description, reply->enabled_by[bcnt].section_uid
    = s.section_uid, reply->enabled_by[bcnt].section_description = s.section_description,
   reply->enabled_by[bcnt].task_assay_uid = i.task_assay_uid, reply->enabled_by[bcnt].
   assay_description = d.description, a = textlen(i.pvc_value),
   b = findstring(";",i.pvc_value), cond = substring(1,(b - 1),i.pvc_value)
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
   num_string = substring((b+ 1),(a - b),i.pvc_value), reply->enabled_by[bcnt].condition = concat(
    trim(cond_string),trim(num_string))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  formsect = concat(f.form_description,s.section_description)
  FROM cnt_input i,
   cnt_input i2,
   cnt_input_key ik,
   cnt_dta d,
   cnt_section_key2 s,
   cnt_pf_section_r r,
   cnt_pf_key2 f
  PLAN (i
   WHERE (i.task_assay_uid=request->task_assay_uid)
    AND i.pvc_name="dta_condition")
   JOIN (i2
   WHERE i2.section_uid=i.section_uid
    AND i2.input_description=i.input_description
    AND i2.input_ref_seq=i.input_ref_seq
    AND i2.pvc_name="discrete_task_assay")
   JOIN (ik
   WHERE ik.section_uid=i2.section_uid
    AND ik.input_description=i2.input_description
    AND ik.input_ref_seq=i2.input_ref_seq)
   JOIN (d
   WHERE d.task_assay_uid=i2.task_assay_uid)
   JOIN (s
   WHERE s.section_uid=i.section_uid)
   JOIN (r
   WHERE r.section_uid=s.section_uid)
   JOIN (f
   WHERE f.form_uid=r.form_uid)
  ORDER BY formsect
  HEAD formsect
   ecnt = (ecnt+ 1), stat = alterlist(reply->enables,ecnt), reply->enables[ecnt].form_uid = f
   .form_uid,
   reply->enables[ecnt].form_description = f.form_description, reply->enables[ecnt].section_uid = s
   .section_uid, reply->enables[ecnt].section_description = s.section_description,
   reply->enables[ecnt].task_assay_uid = i2.task_assay_uid, reply->enables[ecnt].assay_description =
   d.description, a = textlen(i.pvc_value),
   b = findstring(";",i.pvc_value), cond = substring(1,(b - 1),i.pvc_value)
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
   num_string = substring((b+ 1),(a - b),i.pvc_value), reply->enables[ecnt].condition = concat(trim(
     cond_string),trim(num_string))
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  sectinpt = concat(s.section_description,i.input_description)
  FROM cnt_input i,
   cnt_section_key2 s,
   cnt_input i2,
   cnt_input_key ik,
   cnt_section_key2 s2
  PLAN (i
   WHERE (i.task_assay_uid=request->task_assay_uid)
    AND i.pvc_name="discrete_task_assay")
   JOIN (s
   WHERE s.section_uid=i.section_uid)
   JOIN (i2
   WHERE i2.section_uid=outerjoin(i.section_uid)
    AND i2.input_description=outerjoin(i.input_description)
    AND i2.input_ref_seq=outerjoin(i.input_ref_seq)
    AND i2.pvc_name=outerjoin("conditional_section"))
   JOIN (ik
   WHERE ik.section_uid=outerjoin(i2.section_uid)
    AND ik.input_description=outerjoin(i2.input_description)
    AND ik.input_ref_seq=outerjoin(i2.input_ref_seq))
   JOIN (s2
   WHERE s2.section_uid=outerjoin(i2.cond_sect_uid))
  ORDER BY sectinpt
  HEAD sectinpt
   scnt = (scnt+ 1), stat = alterlist(reply->sections,scnt), reply->sections[scnt].section_uid = s
   .section_uid,
   reply->sections[scnt].section_description = s.section_description, reply->sections[scnt].
   cnt_input_key_id = ik.cnt_input_key_id, reply->sections[scnt].input_description = i
   .input_description
   IF (i2.pvc_value > " ")
    a = textlen(i2.pvc_value), b = findstring(";",i2.pvc_value), cond = substring(1,(b - 1),i2
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
    num_string = substring((b+ 1),(a - b),i2.pvc_value), reply->sections[scnt].condition = concat(
     trim(cond_string),trim(num_string)," then ",trim(s2.section_description))
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
