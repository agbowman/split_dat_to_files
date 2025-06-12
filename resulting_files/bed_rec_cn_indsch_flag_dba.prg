CREATE PROGRAM bed_rec_cn_indsch_flag:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 run_status_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET reply->run_status_flag = 1
 SET cnotstarted = 0.0
 SET cnotstarted = uar_get_code_by("MEANING",460,"NOTSTARTED")
 SET check1 = 0
 SELECT INTO "nl:"
  FROM ops_job_step ojs
  PLAN (ojs
   WHERE cnvtupper(ojs.batch_selection)="DCP_OPS_INP_DC_DORDS")
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET check1 = 1
 ENDIF
 SELECT INTO "nl:"
  FROM ops_job_step ojs,
   ops_task ot,
   ops_schedule_task ost
  PLAN (ojs
   WHERE cnvtupper(ojs.batch_selection)="DCP_OPS_INP_DC_DORDS")
   JOIN (ot
   WHERE (ot.ops_job_id=(ojs.ops_job_id+ 0)))
   JOIN (ost
   WHERE (ost.ops_task_id=(ot.ops_task_id+ 0))
    AND ((ost.status_cd+ 0)=cnotstarted))
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET check1 = 1
 ENDIF
 IF (check1=0)
  SELECT INTO "nl:"
   FROM config_prefs c
   PLAN (c
    WHERE c.config_name="DSCH_CANCEL")
   DETAIL
    IF (c.config_value != "NONE")
     reply->run_status_flag = 3
    ENDIF
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET reply->run_status_flag = 3
  ENDIF
  IF ((reply->run_status_flag=1))
   SELECT INTO "nl:"
    FROM config_prefs c
    PLAN (c
     WHERE c.config_name="INDSCH_FLAG")
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET reply->run_status_flag = 3
   ENDIF
  ENDIF
 ELSE
  SET reply->run_status_flag = 3
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
