CREATE PROGRAM bhs_anesthesia_risk_form_print:dba
 DECLARE powernote = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",29520,"POWERNOTE"))
 DECLARE highriskconsult = vc WITH constant("HIGH_RISK_CONSULT_FORM")
 DECLARE floormgrnotrify = vc WITH constant("FLOOR_MANAGER_NOTIFICATION_FORM")
 DECLARE cs15751_true_cda = f8 WITH constant(uar_get_code_by("displaykey",15751,"TRUE")), protect
 DECLARE authverified = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE modified = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE event_id = f8 WITH protect, noconstant(0.0)
 DECLARE powernotetype = i2 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant(" ")
 FREE RECORD events
 RECORD events(
   1 qual[*]
     2 event_id = f8
 )
 SELECT INTO "NL:"
  FROM clinical_event ce,
   scd_story ss,
   scd_term st,
   scr_term_text stt
  PLAN (ce
   WHERE (ce.encntr_id=request->visit[1].encntr_id)
    AND ce.entry_mode_cd=powernote
    AND ce.result_status_cd IN (authverified, modified))
   JOIN (ss
   WHERE ss.event_id=ce.event_id)
   JOIN (st
   WHERE ss.scd_story_id=st.scd_story_id
    AND st.truth_state_cd=cs15751_true_cda)
   JOIN (stt
   WHERE stt.scr_term_id=st.scr_term_id
    AND stt.definition IN (highriskconsult, floormgrnotrify))
  ORDER BY ce.clinical_event_id DESC, stt.definition
  HEAD ce.clinical_event_id
   stat = alterlist(events->qual,(size(events->qual,5)+ 1)), events->qual[size(events->qual,5)].
   event_id = ce.event_id
  WITH nocounter
 ;end select
 IF (size(events->qual,5) > 0)
  FOR (x = 1 TO size(events->qual,5))
   CALL echo("entering bhs_anesthesia_risk_form_drvr")
   EXECUTE bhs_anesthesia_risk_form_drvr request->output_device, events->qual[x].event_id, "form"
  ENDFOR
 ELSE
  SET errmsg = build("event_id was not found for encntr_id:",request->visit[1].encntr_id)
 ENDIF
 CALL echo("exiting child script")
#exit_script
 IF (errmsg > " ")
  DECLARE hlog = i4 WITH protect, noconstant(0)
  DECLARE hstat = i4 WITH protect, noconstant(0)
  CALL echo(errmsg)
  CALL uar_syscreatehandle(hlog,hstat)
  IF (hlog != 0)
   CALL echo("LOG")
   CALL uar_sysevent(hlog,0,nullterm(curprog),nullterm(errmsg))
   CALL uar_sysdestroyhandle(hlog)
  ENDIF
 ENDIF
END GO
