CREATE PROGRAM create_fake_jobs:dba
 DECLARE updtid = f8 WITH protect, noconstant(0)
 DECLARE username = c50 WITH protect
 SELECT
  IF ((reqinfo->updt_id != 0.0))
   FROM prsnl p
   WHERE (p.person_id=reqinfo->updt_id)
  ELSE
   FROM prsnl p
   WHERE p.username=curuser
  ENDIF
  INTO "nl:"
  DETAIL
   updtid = p.person_id, username = p.username
  WITH nocounter
 ;end select
 FOR (i = 0 TO 499)
   INSERT  FROM he_job
    SET job_id = cnvtreal(seq(health_status_seq,nextval)), status_flag = 8, type_flag = 2,
     last_action_by_id = updtid, last_action_by_name = username, started_by_id = updtid,
     started_by_name = username, updt_id = updtid, updt_dt_tm = cnvtdatetime(curdate,curtime3)
   ;end insert
 ENDFOR
 COMMIT
END GO
