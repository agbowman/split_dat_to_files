CREATE PROGRAM bhs_eks_event_powernote:dba
 PROMPT
  "clinicalEventId" = ""
  WITH eventid
 IF (cnvtreal( $EVENTID) <= 0.00)
  SET retval = - (1)
  SET log_message = "no clinical_event_id entered. exiting script"
  GO TO exit_script
 ENDIF
 SET retval = 0
 SET log_message = build2("term not found for clinical_event_id ",trim(cnvtstring( $EVENTID),3))
 DECLARE log_misc1 = vc
 SET powernotetype = 0
 DECLARE highriskconsult = vc WITH constant("HIGH_RISK_CONSULT_FORM")
 DECLARE floormgrnotrify = vc WITH constant("FLOOR_MANAGER_NOTIFICATION_FORM")
 DECLARE highriskfollowup = vc WITH constant("HIGH_RISK_FOLLOW_UP")
 DECLARE schoolhealthrec = vc WITH constant("SCHOOL_HEALTH_RECORD")
 DECLARE cs15751_true_cda = f8 WITH constant(uar_get_code_by("displaykey",15751,"TRUE")), protect
 DECLARE wait_ind2 = i2 WITH noconstant(4)
 DECLARE wait_ind1 = i2 WITH noconstant(0)
 WHILE (wait_ind2 >= 1)
  SELECT INTO "nl:"
   FROM clinical_event ce,
    scd_story ss,
    scd_story_pattern ssp,
    scr_pattern sp
   PLAN (ce
    WHERE ce.clinical_event_id=cnvtreal( $EVENTID))
    JOIN (ss
    WHERE ce.event_id=ss.event_id)
    JOIN (ssp
    WHERE ss.scd_story_id=ssp.scd_story_id)
    JOIN (sp
    WHERE ssp.scr_pattern_id=sp.scr_pattern_id
     AND ((cnvtupper(sp.display_key)=value("PEDI*")) OR (cnvtupper(sp.display_key)=
    "PREOPANESTHESIAASSESSMENTADULT*")) )
   DETAIL
    log_misc1 = trim(cnvtstring(ss.event_id)), wait_ind1 = 4, wait_ind2 = 0
   WITH nocounter
  ;end select
  IF (curqual <= 0)
   SET log_message = build2("term not found for event_id ",trim(log_misc1))
   SET wait_ind2 = (wait_ind2 - 1)
   CALL pause(1)
  ELSE
   SET log_message = build2("term  found for event_id ",trim(log_misc1))
  ENDIF
 ENDWHILE
 IF (wait_ind1 <= 0)
  SET log_message = build2("Note not found (clinical_event_id):",trim(cnvtstring(cnvtreal( $EVENTID)),
    3))
  CALL echo(log_message)
  GO TO exit_script
 ENDIF
 CALL echo(log_message)
 WHILE (wait_ind1 >= 1)
  SELECT INTO "nl:"
   FROM scd_story ss,
    scd_term st,
    scr_term_text stt
   PLAN (ss
    WHERE ss.event_id=cnvtreal(log_misc1))
    JOIN (st
    WHERE ss.scd_story_id=st.scd_story_id
     AND st.truth_state_cd=cs15751_true_cda)
    JOIN (stt
    WHERE stt.scr_term_id=st.scr_term_id
     AND ((stt.definition IN (schoolhealthrec)) OR (stt.definition IN (highriskconsult,
    floormgrnotrify, highriskfollowup))) )
   ORDER BY stt.definition
   DETAIL
    IF (stt.definition IN (highriskconsult, floormgrnotrify)
     AND powernotetype <= 0)
     powernotetype = 1
    ELSEIF (stt.definition IN (schoolhealthrec))
     powernotetype = 2
    ELSEIF (stt.definition IN (highriskfollowup))
     powernotetype = 3
    ENDIF
    retval = 100,
    CALL echo(log_message)
   WITH nocounter
  ;end select
  IF (retval != 100)
   SET wait_ind1 = (wait_ind1 - 1)
   CALL pause(1)
  ELSE
   SET log_message = build2("Note Found_","Event_id",trim(cnvtstring(cnvtreal(log_misc1)),3),
    "PowerNoteType:",powernotetype)
   SET wait_ind1 = 0
  ENDIF
 ENDWHILE
 IF (retval=100)
  IF (powernotetype=2)
   CALL echo("entering bhs_rw_pss_health_record")
   EXECUTE bhs_rw_pss_health_record "discern", cnvtreal(log_misc1)
  ENDIF
  CALL echo("exiting child script")
 ELSE
  SET log_message = build2("Note search failed (clinical_event_id):",trim(cnvtstring(cnvtreal(
       $EVENTID)),3))
  CALL echo(log_message)
 ENDIF
#exit_script
END GO
