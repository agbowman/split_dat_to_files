CREATE PROGRAM br_create_process
 DECLARE curdttm = vc
 DECLARE procname = vc
 DECLARE max_log_id = f8
 DECLARE min_log_id = f8
 DECLARE overlap_flag = i2
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE from_env_id = f8
 DECLARE to_env_id = f8
 DECLARE operation = vc
 DECLARE person_id = f8
 SET reply->status_data.status = "F"
 SET overlap_flag = false
 SET from_env_id =  $1
 SET to_env_id =  $2
 SET operation =  $3
 SET person_id =  $4
 IF (from_env_id > 0
  AND to_env_id > 0)
  GO TO exit_script
 ENDIF
 IF (from_env_id > 0)
  IF (check_env_id(from_env_id)=0)
   GO TO exit_script
  ENDIF
 ENDIF
 IF (to_env_id > 0)
  IF (check_env_id(to_env_id)=0)
   GO TO exit_script
  ENDIF
 ENDIF
 IF (to_env_id > 0)
  SELECT INTO "nl:"
   m_log_id = max(d.log_id), mn_log_id = min(d.log_id)
   FROM dm_chg_log d
   PLAN (d
    WHERE d.target_env_id=to_env_id
     AND d.log_type="REFCHG")
   DETAIL
    max_log_id = m_log_id, min_log_id = mn_log_id
   WITH nocounter
  ;end select
  IF (((max_log_id < 1) OR (min_log_id < 1)) )
   GO TO exit_script
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM br_process b
  PLAN (b
   WHERE b.to_client_id=to_env_id
    AND b.to_client_id > 0)
  DETAIL
   IF (min_log_id < b.max_log_id)
    overlap_flag = true
   ENDIF
  WITH nocounter
 ;end select
 IF (overlap_flag=true)
  CALL echo("OVERLAPPING IDs")
  GO TO exit_script
 ENDIF
 SET curdttm = format(sysdate,"YYYYMMDDHHMMSS;;d")
 SET procname = concat("rdds_",trim(cnvtstring(from_env_id)),"_",trim(cnvtstring(to_env_id)),"_",
  trim(curdttm))
 INSERT  FROM br_process b
  SET b.process_identifier = trim(procname), b.from_client_id = from_env_id, b.to_client_id =
   to_env_id,
   b.process_dt_tm = sysdate, b.operation = operation, b.person_id = person_id,
   b.updt_dt_tm = sysdate, b.updt_cnt = 0, b.max_log_id = max_log_id,
   b.min_log_id = min_log_id
  WITH nocounter
 ;end insert
 SUBROUTINE check_env_id(env_id)
  SELECT INTO "nl:"
   b.br_client_id
   FROM br_client b
   PLAN (b
    WHERE b.br_client_id=value(env_id)
     AND b.active_ind=1)
   WITH check
  ;end select
  IF (curqual > 0)
   RETURN(1)
  ELSE
   RETURN(0)
  ENDIF
 END ;Subroutine
 SET reply->status_data.status = "S"
#exit_script
 IF ((reply->status_data.status="S"))
  COMMIT
 ENDIF
END GO
