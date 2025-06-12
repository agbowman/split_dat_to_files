CREATE PROGRAM bhs_blob_pdf_update:dba
 PROMPT
  "Event ID" = 0
  WITH f_event_id
 CALL echo("record section")
 FREE RECORD m_rec
 RECORD m_rec(
   1 upd[*]
     2 f_event_id = f8
 )
 CALL echo("declare section")
 DECLARE mf_event_id = f8 WITH protect, noconstant(cnvtreal( $F_EVENT_ID))
 DECLARE mf_rtf_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",23,"RTF"))
 DECLARE mf_unknown_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",23,"UNKNOWN"))
 DECLARE mf_ah_cd = f8 WITH protect, noconstant(uar_get_code_by("MEANING",23,"AH"))
 DECLARE mn_update = i4 WITH protect, noconstant(0)
 DECLARE ml_r_cnt = i4 WITH protect, noconstant(0)
 DECLARE ms_process_rec = vc WITH protect, noconstant(" "), public
 CALL echo("select section")
 SELECT INTO "nl:"
  FROM ce_blob_result cbr,
   clinical_event ce
  PLAN (ce
   WHERE ce.parent_event_id=mf_event_id)
   JOIN (cbr
   WHERE cbr.event_id=ce.event_id
    AND cbr.format_cd IN (mf_rtf_cd, mf_unknown_cd))
  ORDER BY ce.event_id
  DETAIL
   ml_r_cnt = (ml_r_cnt+ 1), stat = alterlist(m_rec->upd,ml_r_cnt), m_rec->upd[ml_r_cnt].f_event_id
    = cbr.event_id,
   CALL echo(build("tracy=",m_rec->upd[ml_r_cnt].f_event_id)),
   CALL echo(ce.clinical_event_id),
   CALL echo(concat("event_id: ",trim(cnvtstring(ce.event_id))," ",uar_get_code_display(ce.event_cd))
   )
   IF (findstring(".pdf",cnvtlower(ce.event_title_text)) > 0)
    mn_update = 1,
    CALL echo(mn_update), ms_process_rec = "Y",
    CALL echo(ms_process_rec),
    CALL echo(concat("pdf: ",ce.event_title_text)),
    CALL echo(uar_get_code_display(cbr.format_cd))
   ENDIF
  WITH nocounter
 ;end select
 CALL echorecord(m_rec)
 CALL echo("update section")
 IF (mn_update=1)
  UPDATE  FROM (dummyt d  WITH seq = value(size(m_rec->upd,5))),
    ce_blob_result cbr
   SET cbr.format_cd = mf_ah_cd, cbr.updt_dt_tm = sysdate, cbr.updt_id = 99999,
    cbr.updt_task = 99999, cbr.updt_cnt = (cbr.updt_cnt+ 1)
   PLAN (d)
    JOIN (cbr
    WHERE (cbr.event_id=m_rec->upd[d.seq].f_event_id)
     AND cbr.format_cd IN (mf_rtf_cd, mf_unknown_cd))
   WITH nocounter
  ;end update
  COMMIT
 ENDIF
 CALL echo("exit section")
#exit_script
END GO
