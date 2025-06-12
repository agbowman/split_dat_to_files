CREATE PROGRAM bhs_rw_print_pss_record:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Encounter ID" = 0
  WITH outdev, f_encntr_id
 DECLARE mf_signed_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",15750,"SIGNED"))
 DECLARE mf_auth_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE mf_altered_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"ALTERED"))
 DECLARE mf_mod_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE mf_true_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",15751,"TRUE"))
 DECLARE mf_event_id = f8 WITH protect, noconstant(0.00)
 DECLARE mf_encntr_id = f8 WITH protect, noconstant(0.0)
 DECLARE ms_output = vc WITH protect, noconstant(" ")
 IF (validate(request->visit[1].encntr_id))
  SET ms_output = trim(request->output_device)
  SET mf_encntr_id = request->visit[1].encntr_id
 ELSE
  SET ms_output =  $OUTDEV
  SET mf_encntr_id = cnvtreal( $F_ENCNTR_ID)
 ENDIF
 SELECT INTO "nl:"
  FROM scd_story ss,
   scd_term st,
   scr_term_text stt,
   clinical_event ce
  PLAN (ss
   WHERE ss.encounter_id=mf_encntr_id
    AND ss.story_completion_status_cd=mf_signed_cd)
   JOIN (st
   WHERE st.scd_story_id=ss.scd_story_id
    AND st.truth_state_cd=mf_true_cd)
   JOIN (stt
   WHERE stt.scr_term_id=st.scr_term_id
    AND stt.definition="SCHOOL_HEALTH_RECORD")
   JOIN (ce
   WHERE ce.event_id=ss.event_id
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ce.result_status_cd IN (mf_auth_cd, mf_altered_cd, mf_mod_cd))
  ORDER BY ce.event_end_dt_tm DESC, ss.event_id DESC
  HEAD ss.encounter_id
   mf_event_id = ss.event_id
  WITH maxrec = 1, nocounter
 ;end select
 EXECUTE bhs_rw_pss_health_record value(ms_output), value(mf_event_id), value(mf_encntr_id)
END GO
