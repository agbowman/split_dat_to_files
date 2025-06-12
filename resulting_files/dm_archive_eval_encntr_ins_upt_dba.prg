CREATE PROGRAM dm_archive_eval_encntr_ins_upt:dba
 IF (o_encntr_type_cd != n_encntr_type_cd)
  RECORD dm_request(
    1 enc[*]
      2 encntr_id = f8
      2 org_id = f8
      2 encntr_type = f8
      2 encntr_complete_dt_tm = dq8
      2 archive_dt_tm = dq8
      2 enc_complete_ind = i4
  )
  SET stat = alterlist(dm_request->enc,1)
  SET dm_request->enc[1].encntr_id = request->n_encntr_id
  SET dm_request->enc[1].encntr_type = request->n_encntr_type_cd
  EXECUTE dm_set_archive_dt_tm
 ENDIF
END GO
