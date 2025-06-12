CREATE PROGRAM bhs_eks_calc_weight
 SET retval = 0
 SET event_id = link_clineventid
 SET personid = 0
 SET encntrid = 0
 SET event_tag = fillstring(60,"")
 SET event_id2 = 0.0
 SET result = 0.0
 SET parent_id = 0
 SELECT INTO "nl:"
  FROM clinical_event ce
  WHERE ce.clinical_event_id=event_id
  DETAIL
   result = (cnvtreal(ce.event_tag) * 2.2046), personid = ce.person_id, encntrid = ce.encntr_id
  WITH nocounter
 ;end select
 SET pound_disp = cnvtint(result)
 SET oz_disp = ((result - pound_disp) * 16)
 IF (oz_disp > 15)
  SET oz_disp = 0
  SET pound_disp = (pound_disp+ 1)
 ENDIF
 SET result_disp = concat(trim(cnvtstring(pound_disp))," lb ",trim(cnvtstring(oz_disp))," oz")
 SET weight2_cd = uar_get_code_by("displaykey",72,"WEIGHTLBOZ")
 CALL echo(build("pound_disp",pound_disp))
 CALL echo(build("oz_disp",oz_disp))
 CALL echo(build("result_disp",result_disp))
 IF (trim( $1)="Auth")
  SELECT INTO "nl:"
   FROM clinical_event ce
   WHERE ce.event_cd=weight2_cd
    AND ce.person_id=personid
    AND ce.encntr_id=encntrid
    AND ce.clinical_event_id > event_id
   DETAIL
    event_tag = trim(ce.event_tag), event_id2 = ce.clinical_event_id
   WITH nocounter
  ;end select
  CALL echo(build("event_tag",event_tag))
  CALL echo(build("event_id2",event_id2))
  UPDATE  FROM clinical_event ce
   SET ce.event_tag = trim(result_disp), ce.result_val = trim(result_disp), ce.event_class_cd = 236
   WHERE ce.clinical_event_id=event_id2
   WITH nocounter
  ;end update
  COMMIT
  SET log_message = build("Clin Event ID:",event_id)
  SET retval = 100
 ELSEIF (trim( $1)="In Error")
  SELECT INTO "nl:"
   FROM clinical_event ce
   WHERE ce.clinical_event_id=event_id
   DETAIL
    parent_id = ce.parent_event_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM clinical_event ce
   WHERE ce.event_cd=weight2_cd
    AND ce.person_id=personid
    AND ce.encntr_id=encntrid
    AND ce.parent_event_id > parent_id
    AND ce.event_tag != "In Error"
   ORDER BY ce.parent_event_id DESC
   DETAIL
    event_tag = trim(ce.event_tag), event_id2 = ce.clinical_event_id
   WITH nocounter
  ;end select
  CALL echo(build("event_tag",event_tag))
  CALL echo(build("event_id2",event_id2))
  UPDATE  FROM clinical_event ce
   SET ce.event_tag = "In Error", ce.result_val = "In Error", ce.view_level = 0,
    ce.publish_flag = 0, ce.valid_until_dt_tm = sysdate, ce.result_status_cd = 28
   WHERE ce.clinical_event_id=event_id2
   WITH nocounter
  ;end update
  COMMIT
  SET log_message = build("Clin Event ID:",event_id)
  SET retval = 100
 ELSEIF (trim( $1)="Update")
  SELECT INTO "nl:"
   FROM clinical_event ce
   WHERE ce.clinical_event_id=event_id
   DETAIL
    parent_id = ce.parent_event_id
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM clinical_event ce
   WHERE ce.event_cd=weight2_cd
    AND ce.person_id=personid
    AND ce.encntr_id=encntrid
    AND ce.parent_event_id > parent_id
    AND ce.event_tag != "In Error"
   ORDER BY ce.parent_event_id DESC
   DETAIL
    event_tag = trim(ce.event_tag), event_id2 = ce.clinical_event_id
   WITH nocounter
  ;end select
  CALL echo(build("event_tag",event_tag))
  CALL echo(build("event_id2",event_id2))
  UPDATE  FROM clinical_event ce
   SET ce.event_tag = trim(result_disp), ce.result_val = trim(result_disp), ce.updt_dt_tm = sysdate
   WHERE ce.clinical_event_id=event_id2
   WITH nocounter
  ;end update
  COMMIT
  SET log_message = build("Clin Event ID:",event_id)
  SET retval = 100
 ENDIF
END GO
