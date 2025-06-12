CREATE PROGRAM afc_check_dup_charge_events:dba
 DECLARE standalone = i2
 SET standalone = 0
 IF (validate(request->setup_proc[1].env_id,999)=999)
  SET standalone = 1
  RECORD request(
    1 setup_proc[1]
      2 env_id = f8
      2 process_id = f8
      2 success_ind = i4
      2 error_msg = vc
  )
 ENDIF
 SET request->setup_proc[1].success_ind = 0
 DECLARE cnt = i2
 SET cnt = 0
 SELECT INTO "nl:"
  c.ext_m_event_id, c.ext_m_event_cont_cd, c.ext_p_event_id,
  c.ext_p_event_cont_cd, c.ext_i_event_id, c.ext_i_event_cont_cd
  FROM charge_event c
  DETAIL
   CALL echo(build("charge_event_id->",c.charge_event_id)), cnt += 1
  WITH nocounter
 ;end select
 DECLARE distinctcnt = i2
 SET distinctcnt = 0
 SELECT DISTINCT INTO "nl:"
  c.ext_m_event_id, c.ext_m_event_cont_cd, c.ext_p_event_id,
  c.ext_p_event_cont_cd, c.ext_i_event_id, c.ext_i_event_cont_cd
  FROM charge_event c
  DETAIL
   CALL echo(build("charge_event_id->",c.charge_event_id)), distinctcnt += 1
  WITH nocounter
 ;end select
 CALL echo(build("Full count->",cnt))
 CALL echo(build("Distinct  ->",distinctcnt))
 IF (cnt=distinctcnt)
  SET request->setup_proc[1].success_ind = 1
 ELSE
  SET request->setup_proc[1].error_msg = "Error - afc_cleanup_dup_charge_events failed"
 ENDIF
 IF (standalone=0)
  EXECUTE dm_add_upt_setup_proc_log
 ENDIF
END GO
