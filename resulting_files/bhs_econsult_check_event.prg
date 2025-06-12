CREATE PROGRAM bhs_econsult_check_event
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SET resource_display = trim( $1,3)
 DECLARE mf_encntr_id = f8 WITH protect, noconstant(0.0)
 IF (textlen(trim(resource_display)) <= 0)
  SET log_message = "no resource display passed in"
  SET retval = - (1)
  GO TO exit_script
 ENDIF
 IF (validate(trigger_encntrid,0.00) > 0.00)
  SET mf_encntr_id = trigger_encntrid
 ELSE
  SET mf_encntr_id = 0.0
  SET log_message = "no encounter id passed in"
  SET retval = - (1)
  GO TO exit_script
 ENDIF
 SET retval = 100
 SET log_message = build2("display: ",resource_display," Encounter id: ",mf_encntr_id)
 SELECT INTO "nl:"
  sep.encntr_id, appt_type = uar_get_code_display(se.appt_type_cd), appt_resource =
  uar_get_code_display(sa.resource_cd)
  FROM sch_appt sa,
   sch_event se,
   sch_event_patient sep,
   code_value cv
  PLAN (cv
   WHERE cv.code_set=14231
    AND cnvtupper(cv.display)=cnvtupper(resource_display))
   JOIN (sa
   WHERE sa.resource_cd=cv.code_value
    AND sa.active_ind=1)
   JOIN (se
   WHERE se.sch_event_id=sa.sch_event_id
    AND se.schedule_seq=sa.schedule_seq
    AND se.active_ind=1)
   JOIN (sep
   WHERE sep.sch_event_id=se.sch_event_id
    AND sep.encntr_id=mf_encntr_id
    AND sep.active_ind=1)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET log_message = "***** Appointment found by resource type ******* "
  GO TO exit_success
 ELSE
  SET log_message = "***** Appointment NOT found ******* "
  GO TO exit_fail
 ENDIF
#exit_fail
 SET retval = 0
 GO TO exit_script
#exit_success
 SET retval = 100
#exit_script
 COMMIT
END GO
