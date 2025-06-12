CREATE PROGRAM bhs_maint_fix_deficiency:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter FIN:" = ""
  WITH outdev, s_fin
 FREE RECORD m_rec
 RECORD m_rec(
   1 def[*]
     2 s_fin = vc
     2 s_pat_name = vc
     2 s_phys_name = vc
     2 f_pv_chart_id = f8
     2 f_pv_doc_id = f8
     2 f_pv_phys_id = f8
 ) WITH protect
 DECLARE ms_fin = vc WITH protect, constant(trim(cnvtupper( $S_FIN),3))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 SELECT INTO "nl:"
  FROM encntr_alias ea,
   him_pv_chart hpc,
   him_pv_document hpd,
   him_pv_physician hpp,
   prsnl pr,
   person p
  PLAN (ea
   WHERE ea.alias=ms_fin
    AND ea.active_ind=1
    AND ea.end_effective_dt_tm > sysdate
    AND ea.encntr_alias_type_cd=1077)
   JOIN (hpc
   WHERE hpc.encntr_id=ea.encntr_id)
   JOIN (hpd
   WHERE hpd.encntr_id=hpc.encntr_id)
   JOIN (hpp
   WHERE hpp.encntr_id=hpc.encntr_id)
   JOIN (p
   WHERE (p.person_id= Outerjoin(hpc.person_id)) )
   JOIN (pr
   WHERE pr.person_id=hpd.action_prsnl_id)
  ORDER BY pr.name_full_formatted
  HEAD REPORT
   pl_cnt = 0
  DETAIL
   pl_cnt += 1,
   CALL alterlist(m_rec->def,pl_cnt), m_rec->def[pl_cnt].s_fin = trim(ea.alias,3),
   m_rec->def[pl_cnt].s_pat_name = trim(p.name_full_formatted,3), m_rec->def[pl_cnt].s_phys_name =
   trim(pr.name_full_formatted,3), m_rec->def[pl_cnt].f_pv_chart_id = hpc.him_pv_chart_id,
   m_rec->def[pl_cnt].f_pv_doc_id = hpd.him_pv_document_id, m_rec->def[pl_cnt].f_pv_phys_id = hpp
   .him_pv_physician_id
  WITH nocounter
 ;end select
 IF (curqual < 1)
  SELECT INTO value( $OUTDEV)
   FROM dummyt d
   HEAD REPORT
    ms_tmp = concat("No records found for FIN: ",ms_fin), col 0, ms_tmp
   WITH nocounter
  ;end select
  GO TO exit_script
 ENDIF
 DELETE  FROM him_pv_chart hpc,
   (dummyt d  WITH seq = value(size(m_rec->def,5)))
  SET hpc.seq = 1
  PLAN (d)
   JOIN (hpc
   WHERE (hpc.him_pv_chart_id=m_rec->def[d.seq].f_pv_chart_id))
  WITH nocounter
 ;end delete
 DELETE  FROM him_pv_document hpd,
   (dummyt d  WITH seq = value(size(m_rec->def,5)))
  SET hpd.seq = 1
  PLAN (d)
   JOIN (hpd
   WHERE (hpd.him_pv_document_id=m_rec->def[d.seq].f_pv_doc_id))
  WITH nocounter
 ;end delete
 DELETE  FROM him_pv_physician hpp,
   (dummyt d  WITH seq = value(size(m_rec->def,5)))
  SET hpp.seq = 1
  PLAN (d)
   JOIN (hpp
   WHERE (hpp.him_pv_physician_id=m_rec->def[d.seq].f_pv_phys_id))
  WITH nocounter
 ;end delete
 COMMIT
 SELECT INTO value( $OUTDEV)
  FROM (dummyt d  WITH seq = value(size(m_rec->def,5)))
  HEAD REPORT
   col 0, "Records found:", row + 2,
   col 0, "FIN:", col 30,
   "Patient Name:", col 85, "Physician Name:",
   row + 1
  DETAIL
   col 0, m_rec->def[d.seq].s_fin, col 30,
   m_rec->def[d.seq].s_pat_name, col 85, m_rec->def[d.seq].s_phys_name,
   row + 1
  WITH nocounter
 ;end select
#exit_script
 CALL echorecord(m_rec)
 FREE RECORD m_rec
END GO
