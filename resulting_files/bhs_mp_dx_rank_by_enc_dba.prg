CREATE PROGRAM bhs_mp_dx_rank_by_enc:dba
 PROMPT
  "Encounter ID:" = 0,
  "Number of dx:" = 0
  WITH f_encntr_id, l_nbr_dx
 FREE RECORD data
 RECORD data(
   1 dx[*]
     2 id = vc
     2 versionid = vc
     2 rank = vc
 ) WITH protect
 DECLARE mf_encntr_id = f8 WITH protect, constant(cnvtreal( $F_ENCNTR_ID))
 DECLARE ml_nbr_dx = i4 WITH protect, constant(cnvtint( $L_NBR_DX))
 DECLARE ms_tmp = vc WITH protect, noconstant(" ")
 SELECT INTO "nl:"
  FROM diagnosis d,
   nomenclature n
  PLAN (d
   WHERE d.encntr_id=mf_encntr_id
    AND d.active_ind=1
    AND d.end_effective_dt_tm > sysdate
    AND d.clinical_diag_priority > 0)
   JOIN (n
   WHERE n.nomenclature_id=d.nomenclature_id)
  ORDER BY d.clinical_diag_priority, d.updt_dt_tm DESC
  HEAD REPORT
   pl_cnt = 0
  HEAD d.clinical_diag_priority
   pl_cnt += 1
   IF (pl_cnt <= ml_nbr_dx)
    CALL alterlist(data->dx,pl_cnt), data->dx[pl_cnt].id = trim(cnvtstring(d.diagnosis_group),3),
    data->dx[pl_cnt].versionid = trim(cnvtstring(d.diagnosis_id),3),
    data->dx[pl_cnt].rank = trim(cnvtstring(d.clinical_diag_priority),3)
   ENDIF
  WITH nocounter
 ;end select
 SET ms_tmp = cnvtrectojson(data)
 CALL echo(ms_tmp)
 SET _memory_reply_string = ms_tmp
#exit_script
 CALL echorecord(data)
 FREE RECORD data
END GO
