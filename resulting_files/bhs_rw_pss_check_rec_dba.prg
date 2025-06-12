CREATE PROGRAM bhs_rw_pss_check_rec:dba
 PROMPT
  "Enter EVENT_ID to check: " = 0.00
 DECLARE mf_true_cd = f8 WITH constant(uar_get_code_by("DISPLAYKEY",15751,"TRUE"))
 DECLARE mn_wait_ind = i2 WITH noconstant(0)
 IF (cnvtreal( $1) <= 0.00)
  SET retval = - (1)
  SET log_message = "No clinical_event_id entered. Exiting script."
  GO TO exit_script
 ENDIF
 SET retval = 0
 SET log_message = build2("SCHOOL_HEALTH_RECORD term not found for CLINICAL_EVENT_ID ",trim(
   cnvtstring( $1),3))
 SELECT INTO "nl:"
  FROM clinical_event ce,
   scd_story ss,
   scd_story_pattern ssp,
   scr_pattern sp
  PLAN (ce
   WHERE ce.clinical_event_id=cnvtreal( $1))
   JOIN (ss
   WHERE ce.event_id=ss.event_id)
   JOIN (ssp
   WHERE ss.scd_story_id=ssp.scd_story_id)
   JOIN (sp
   WHERE ssp.scr_pattern_id=sp.scr_pattern_id
    AND sp.display_key="PEDI*")
  DETAIL
   log_misc1 = trim(cnvtstring(ss.event_id)), mn_wait_ind = 2
  WITH nocounter
 ;end select
 WHILE (mn_wait_ind >= 1)
  SELECT INTO "nl:"
   FROM scd_story ss,
    scd_term st,
    scr_term_text stt
   PLAN (ss
    WHERE ss.event_id=cnvtreal(log_misc1))
    JOIN (st
    WHERE ss.scd_story_id=st.scd_story_id
     AND st.truth_state_cd=mf_true_cd)
    JOIN (stt
    WHERE st.scr_term_id=stt.scr_term_id
     AND stt.definition="SCHOOL_HEALTH_RECORD")
   DETAIL
    retval = 100, log_message = build2("SCHOOL_HEALTH_RECORD term found. Saving EVENT_ID ",trim(
      cnvtstring(ss.event_id),3))
   WITH nocounter
  ;end select
  IF (retval != 100)
   SET mn_wait_ind = (mn_wait_ind - 1)
   CALL pause(1)
  ELSE
   SET mn_wait_ind = 0
  ENDIF
 ENDWHILE
#exit_script
END GO
