CREATE PROGRAM dcp_elh_cleanup:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 DECLARE rdm_errcode = i4 WITH noconstant(0)
 DECLARE rdm_errmsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE readme_status = c1 WITH noconstant("S")
 SET rdm_errcode = error(rdm_errmsg,1)
 SET continue = 1
 SET qualcnt = 0
 SET dischargecd = 0
 SET cancelcd = 0
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 RECORD temp(
   1 qual[*]
     2 encntr_loc_hist_id = f8
     2 end_effective_dt_tm = dq8
 )
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=261
  DETAIL
   IF (cv.cdf_meaning="DISCHARGED")
    dischargecd = cv.code_value
   ELSEIF (cv.cdf_meaning="CANCELLED")
    cancelcd = cv.code_value
   ENDIF
  WITH constant
 ;end select
 CALL echo("Identifying erroneous rows...")
 CALL echo("Please wait...")
 SELECT INTO "nl:"
  FROM encntr_loc_hist elh,
   encounter e
  PLAN (elh
   WHERE elh.end_effective_dt_tm > cnvtdatetime("01-JAN-2100 00:00:00"))
   JOIN (e
   WHERE e.encntr_id=elh.encntr_id
    AND ((e.encntr_status_cd=dischargecd) OR (e.encntr_status_cd=cancelcd)) )
  HEAD REPORT
   qualcnt = 0
  DETAIL
   IF (((nullind(e.disch_dt_tm)=0) OR (nullind(e.depart_dt_tm)=0)) )
    qualcnt = (qualcnt+ 1)
    IF (mod(qualcnt,50)=1)
     stat = alterlist(temp->qual,(qualcnt+ 49))
    ENDIF
    temp->qual[qualcnt].encntr_loc_hist_id = elh.encntr_loc_hist_id
    IF (nullind(e.disch_dt_tm)=0)
     temp->qual[qualcnt].end_effective_dt_tm = e.disch_dt_tm
    ELSEIF (nullind(e.depart_dt_tm)=0)
     temp->qual[qualcnt].end_effective_dt_tm = e.depart_dt_tm
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(temp->qual,qualcnt)
  WITH nocounter
 ;end select
 CALL echo("Updating rows...")
 FOR (x = 1 TO qualcnt)
   CALL echo(temp->qual[x].encntr_loc_hist_id)
   UPDATE  FROM encntr_loc_hist elh
    SET elh.end_effective_dt_tm = cnvtdatetime(temp->qual[x].end_effective_dt_tm), elh.updt_task =
     reqinfo->updt_task
    WHERE (elh.encntr_loc_hist_id=temp->qual[x].encntr_loc_hist_id)
    WITH nocounter
   ;end update
   IF (mod(x,1000)=0)
    SET readme_status = "S"
    SET readme_data->message = "Commit part of the custom column copy loop."
    COMMIT
    EXECUTE dm_readme_status
   ELSEIF (x=qualcnt)
    SET readme_status = "S"
    SET readme_data->message = "Commit the final custom column copy."
    COMMIT
    EXECUTE dm_readme_status
   ENDIF
 ENDFOR
 IF (qualcnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Q"
 ENDIF
 CALL echo(build(qualcnt," rows corrected."))
 IF ((reply->status_data.status="F"))
  SET readme_status = "F"
  SET rdm_errmsg = "dcp_elh_cleanup script failed"
 ELSEIF ((reply->status_data.status="Z"))
  SET readme_status = "S"
 ELSE
  SET readme_status = "S"
 ENDIF
 IF (validate(readme_data->readme_id,0) > 0)
  IF (readme_status="F")
   SET readme_data->status = "F"
   SET readme_data->message = rdm_errmsg
   ROLLBACK
  ELSEIF (readme_status="S")
   IF ((reply->status_data.status="Z"))
    SET readme_data->status = "S"
    SET readme_data->message = "No rows to clean up on the encntr_loc_history table."
    ROLLBACK
   ELSE
    SET readme_data->status = "S"
    SET readme_data->message = "Successfully cleaned up the encntr_loc_history table."
    COMMIT
   ENDIF
  ENDIF
  EXECUTE dm_readme_status
 ELSE
  IF (((readme_status="F") OR (readme_status="Q")) )
   ROLLBACK
  ELSEIF (readme_status="S")
   COMMIT
  ENDIF
 ENDIF
 EXECUTE dm_readme_status
END GO
