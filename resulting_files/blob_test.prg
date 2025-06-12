CREATE PROGRAM blob_test
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 FREE RECORD m_rec
 RECORD m_rec(
   1 list[*]
     2 event_id = f8
     2 fin = vc
 ) WITH protect
 DECLARE event_cnt = i4 WITH protect, noconstant(0)
 DECLARE mf_fin_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",319,"FIN NBR"))
 EXECUTE bhs_hlp_ccl
 SELECT INTO "nl:"
  FROM clinical_event ce,
   encntr_alias ea
  PLAN (ce
   WHERE ce.event_cd=value(uar_get_code_by("DISPLAYKEY",72,"PATIENTINSTRUCTIONS"))
    AND ce.record_status_cd=value(uar_get_code_by("MEANING",48,"ACTIVE"))
    AND ce.valid_until_dt_tm > sysdate)
   JOIN (ea
   WHERE ea.encntr_id=ce.encntr_id
    AND ea.active_ind=1
    AND ea.encntr_alias_type_cd=mf_fin_cd)
  ORDER BY ce.updt_dt_tm DESC
  HEAD REPORT
   CALL alterlist(m_rec->list,100), event_cnt = 0
  HEAD ce.event_id
   event_cnt += 1,
   CALL alterlist(m_rec->list,event_cnt), m_rec->list[event_cnt].event_id = ce.event_id,
   m_rec->list[event_cnt].fin = trim(cnvtalias(ea.alias,ea.alias_pool_cd),3)
  FOOT  ce.event_id
   CALL alterlist(m_rec->list,event_cnt)
  WITH nocounter, time = 60, maxrec = 50
 ;end select
 FOR (num = 1 TO size(m_rec->list,5))
  CALL echo(bhs_sbr_get_blob(m_rec->list[num].event_id,1))
  CALL echo(m_rec->list[num].fin)
 ENDFOR
END GO
