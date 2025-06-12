CREATE PROGRAM bhs_surgical_notify_frm_print:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 DECLARE preadmitfrm = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PREADMITHEALTHQUESTIONNAIREFORM"))
 DECLARE preopchecklistform = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PREOPCHECKLISTFORM"))
 DECLARE authverified = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE modified = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"MODIFIED"))
 DECLARE clinicalid = f8 WITH protect, noconstant(0.0)
 DECLARE hlog = i4 WITH protect, noconstant(0)
 DECLARE hstat = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant(" ")
 SELECT INTO "NL:"
  ce.clinical_event_id
  FROM clinical_event ce
  WHERE (ce.encntr_id=request->visit[1].encntr_id)
   AND ce.event_cd IN (preadmitfrm, preopchecklistform)
   AND ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
   AND ce.result_status_cd IN (authverified, modified)
  ORDER BY ce.updt_dt_tm
  HEAD ce.clinical_event_id
   clinicalid = ce.clinical_event_id
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET errmsg = build("failed to find CE row for encounter_id:",request->visit[1].encntr_id)
  GO TO exit_script
 ENDIF
 EXECUTE bhs_surgical_notify_frm request->output_device, clinicalid
#exit_script
 IF (errmsg > " ")
  CALL uar_syscreatehandle(hlog,hstat)
  IF (hlog != 0)
   CALL echo("LOG")
   CALL uar_sysevent(hlog,0,nullterm(curprog),nullterm(errmsg))
   CALL uar_sysdestroyhandle(hlog)
  ENDIF
 ENDIF
END GO
