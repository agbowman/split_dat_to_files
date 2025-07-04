CREATE PROGRAM ags_pvd_org_clean:dba
 CALL echo("***")
 CALL echo("***   BEG LOGGING")
 CALL echo("***")
 CALL echo("***")
 CALL echo("***   Get Job Data")
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM ags_job j
  PLAN (j
   WHERE j.ags_job_id=the_job_id
    AND j.status IN ("COMPLETE", "WAITING", "ERROR-CLEAN"))
  HEAD REPORT
   working_run_nbr = j.run_nbr
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "GET JOB DATA"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("GET JOB DATA :: Select Error :: ",trim(serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 IF (the_job_id < 1)
  SET failed = input_error
  SET table_name = "GET JOB DATA"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("GET JOB DATA :: Input Error :: Invalid AGS_JOB_ID ",
   trim(cnvtstring(the_job_id)))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echo("***")
 CALL echo(build("***   the_job_id  :",the_job_id))
 CALL echo(build("***   working_run_nbr :",working_run_nbr))
 CALL echo("***")
 CALL echo("***")
 CALL echo("***   Update Job to Cleaning")
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 UPDATE  FROM ags_job j
  SET j.status = "CLEANING", j.status_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (j
   WHERE j.ags_job_id=the_job_id)
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = update_error
  SET table_name = "AGS_JOB CLEANING"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("AGS_JOB CLEANING :: Select Error :: ",trim(serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 COMMIT
 CALL echo("***")
 CALL echo("***   Clean Data")
 CALL echo("***")
 CALL echo("***")
 CALL echo(build("***   the_job_id  :",the_job_id))
 CALL echo(build("***   working_run_nbr :",working_run_nbr))
 CALL echo("***")
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("BEG CLEAN :: AGS_JOB_ID :: ",trim(cnvtstring(the_job_id)
   ))
 FREE RECORD hold
 RECORD hold(
   1 qual_knt = i4
   1 qual[*]
     2 ags_org_data_id = f8
 )
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SELECT INTO "nl:"
  FROM ags_org_data o1,
   ags_org_data o2
  PLAN (o1
   WHERE o1.ags_job_id=the_job_id
    AND o1.provdir_alias > " "
    AND o1.status="COMPLETE"
    AND o1.run_nbr=working_run_nbr)
   JOIN (o2
   WHERE o2.provdir_alias=o1.provdir_alias
    AND ((o2.run_nbr+ 0) < o1.run_nbr))
  HEAD REPORT
   stat = alterlist(hold->qual,data_size), idx = 0
  HEAD o2.ags_org_data_id
   idx = (idx+ 1)
   IF (idx > size(hold->qual,5))
    stat = alterlist(hold->qual,(idx+ data_size))
   ENDIF
   hold->qual[idx].ags_org_data_id = o2.ags_org_data_id
  FOOT REPORT
   hold->qual_knt = idx, stat = alterlist(hold->qual,idx)
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = select_error
  SET table_name = "AGS_ORG_DATA LOADING"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("AGS_ORG_DATA LOADING :: Select Error :: ",trim(serrmsg)
   )
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 CALL echorecord(hold)
 IF ((hold->qual_knt > 0))
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat(trim(cnvtstring(hold->qual_knt)),
   " Rows Found For Processing")
  SET ierrcode = error(serrmsg,1)
  SET ierrcode = 0
  DELETE  FROM ags_org_data p,
    (dummyt d  WITH seq = value(hold->qual_knt))
   SET p.seq = 1
   PLAN (d
    WHERE (hold->qual[d.seq].ags_org_data_id > 0))
    JOIN (p
    WHERE (p.ags_org_data_id=hold->qual[d.seq].ags_org_data_id))
   WITH nocounter, maxcommit = value(5000)
  ;end delete
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   ROLLBACK
   SET failed = select_error
   SET table_name = "AGS_ORG_DATA CLEANING"
   SET ilog_status = 1
   SET log->qual_knt = (log->qual_knt+ 1)
   SET stat = alterlist(log->qual,log->qual_knt)
   SET log->qual[log->qual_knt].smsgtype = "ERROR"
   SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
   SET log->qual[log->qual_knt].smsg = concat("AGS_ORG_DATA CLEAN LOAD :: Delete Error :: ",trim(
     serrmsg))
   SET serrmsg = log->qual[log->qual_knt].smsg
   GO TO exit_script
  ENDIF
  COMMIT
 ELSE
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "INFO"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = "No Rows Found For Processing"
 ENDIF
 SET log->qual_knt = (log->qual_knt+ 1)
 SET stat = alterlist(log->qual,log->qual_knt)
 SET log->qual[log->qual_knt].smsgtype = "INFO"
 SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
 SET log->qual[log->qual_knt].smsg = concat("END CLEAN :: AGS_JOB_ID :: ",trim(cnvtstring(the_job_id)
   ))
 CALL echo("***")
 CALL echo("***   Update Job to Cleaned")
 CALL echo("***")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 UPDATE  FROM ags_job j
  SET j.status = "CLEANED", j.status_dt_tm = cnvtdatetime(curdate,curtime3)
  PLAN (j
   WHERE j.ags_job_id=the_job_id)
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET failed = update_error
  SET table_name = "AGS_JOB CLEANED"
  SET ilog_status = 1
  SET log->qual_knt = (log->qual_knt+ 1)
  SET stat = alterlist(log->qual,log->qual_knt)
  SET log->qual[log->qual_knt].smsgtype = "ERROR"
  SET log->qual[log->qual_knt].dmsg_dt_tm = cnvtdatetime(curdate,curtime3)
  SET log->qual[log->qual_knt].smsg = concat("AGS_JOB CLEANED :: Select Error :: ",trim(serrmsg))
  SET serrmsg = log->qual[log->qual_knt].smsg
  GO TO exit_script
 ENDIF
 COMMIT
#exit_script
 CALL echo("***")
 CALL echo("***   Exit AGS_PVD_ORG_CLEAN Script")
 CALL echo("***")
 IF (failed != false)
  ROLLBACK
 ELSE
  CALL echo("***")
  CALL echo("***   else (failed != FALSE)")
  CALL echo("***")
  COMMIT
 ENDIF
 CALL echo("***")
 CALL echo("***   END AGS_PVD_ORG_CLEAN")
 CALL echo("***")
 SET script_ver = "002 10/11/06"
END GO
