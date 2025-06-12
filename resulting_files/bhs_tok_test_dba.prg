CREATE PROGRAM bhs_tok_test:dba
 IF (validate(reply->text,"-1")="-1")
  FREE RECORD reply
  RECORD reply(
    1 text = vc
    1 format = i4
  ) WITH protect
 ENDIF
 EXECUTE bhs_hlp_ccl
 DECLARE v_ce_stat_inerror_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE active_status_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",48,"ACTIVE"))
 DECLARE dplaceholdercd = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"PLACEHOLDER"))
 DECLARE divparentcd = f8 WITH protect, constant(uar_get_code_by("MEANING",72,"IVPARENT"))
 DECLARE mf_pat_instruct_cd = f8 WITH protect, constant(uar_get_code_by("DISPLAYKEY",72,
   "PATIENTINSTRUCTIONS"))
 DECLARE l_idx = i4 WITH protect, noconstant(0)
 DECLARE s_text = vc WITH protect, noconstant("")
 DECLARE mf_event_id = f8 WITH protect, noconstant(0.0)
 DECLARE ml_ver = i4 WITH protect, noconstant(0)
 DECLARE ms_blob_rtf = vc WITH protect, noconstant("")
 DECLARE ml_start = i4 WITH protect, noconstant(0)
 DECLARE ml_end = i4 WITH protect, noconstant(0)
 SELECT INTO "nl:"
  FROM clinical_event ce,
   ce_blob cb
  PLAN (ce
   WHERE (ce.encntr_id=request->encntr_id)
    AND (ce.person_id=request->person_id)
    AND ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)
    AND ce.record_status_cd != v_ce_stat_inerror_cd
    AND ce.record_status_cd=active_status_cd
    AND ce.event_cd=mf_pat_instruct_cd)
   JOIN (cb
   WHERE cb.event_id=ce.event_id
    AND cb.valid_from_dt_tm < cnvtdatetime(curdate,curtime3)
    AND cb.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY ce.updt_dt_tm DESC
  HEAD REPORT
   mf_event_id = cb.event_id
  WITH nocounter
 ;end select
 IF (mf_event_id > 0.0)
  SET ms_blob_rtf = bhs_sbr_get_blob(mf_event_id,1)
  SET ml_start = findstring("<div",ms_blob_rtf,1,0)
  SET ml_end = findstring("</div>",ms_blob_rtf,1,1)
  SET ms_blob_rtf = substring(ml_start,((ml_end - ml_start)+ 6),ms_blob_rtf)
  SET s_text = "<html><body><table border=1 cellspacing=0 cellpadding=0 width=100%>"
  SET s_text = build2(s_text,"<tr><td><p><b>Patient Instructions</b></p></td></tr><tr><td><p>",
   ms_blob_rtf,"</p></td></tr>")
  SET s_text = build2(s_text,"</table><br><br><br><br><br></body></html>")
 ENDIF
 SET reply->text = s_text
 SET reply->format = 1
 CALL echo(reply->text)
#exit_script
END GO
