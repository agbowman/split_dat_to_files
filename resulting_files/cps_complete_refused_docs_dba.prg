CREATE PROGRAM cps_complete_refused_docs:dba
 FREE SET hold
 RECORD hold(
   1 qual_knt = i4
   1 qual[*]
     2 prsnl_id = f8
     2 event_id = f8
 )
 FREE SET comp
 RECORD comp(
   1 qual_knt = i4
   1 qual[*]
     2 task_id = f8
 )
 SET code_value = 0.0
 SET code_set = 103
 SET cdf_meaning = fillstring(12," ")
 SET refused_cd = 0.0
 SET completed_cd = 0.0
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SET cdf_meaning = "REFUSED"
 EXECUTE cpm_get_cd_for_cdf
 SET refused_cd = code_value
 IF (code_value < 1)
  CALL echo(" ")
  CALL echo(" ")
  CALL echo(" ")
  CALL echo("Failed to find the code_value for cdf_meaning REFUSED on code_set 103")
  CALL echo(" ")
  CALL echo(" ")
  CALL echo(" ")
  GO TO exit_script
 ENDIF
 CALL echo(build("refused : ",refused_cd))
 SET cdf_meaning = "COMPLETE"
 SET code_value = 0.0
 SET code_set = 79
 EXECUTE cpm_get_cd_for_cdf
 SET completed_cd = code_value
 IF (code_value < 1)
  CALL echo(" ")
  CALL echo(" ")
  CALL echo(" ")
  CALL echo("Failed to find the code_value for cdf_meaning COMPLETE on code_set 79")
  CALL echo(" ")
  CALL echo(" ")
  CALL echo(" ")
  GO TO exit_script
 ENDIF
 CALL echo(build("completed cd : ",completed_cd))
 SELECT DISTINCT INTO "nl:"
  ce.action_prsnl_id, ce.event_id
  FROM ce_event_prsnl ce,
   clinical_event cl
  PLAN (ce
   WHERE ce.action_status_cd=refused_cd)
   JOIN (cl
   WHERE cl.event_id=ce.event_id
    AND cl.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
  HEAD REPORT
   knt = 0, stat = alterlist(hold->qual,10)
  DETAIL
   knt = (knt+ 1)
   IF (mod(knt,10)=1
    AND knt != 1)
    stat = alterlist(hold->qual,(knt+ 9))
   ENDIF
   hold->qual[knt].prsnl_id = ce.action_prsnl_id, hold->qual[knt].event_id = ce.event_id
  FOOT REPORT
   hold->qual_knt = knt, stat = alterlist(hold->qual,knt)
  WITH nocounter
 ;end select
 IF ((hold->qual_knt < 1))
  CALL echo(" ")
  CALL echo(" ")
  CALL echo(" ")
  CALL echo("No refused items found to be completed on the TASK_ACTIVITY table")
  CALL echo(" ")
  CALL echo(" ")
  CALL echo(" ")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(hold->qual_knt)),
   task_activity ta,
   task_activity_assignment taa
  PLAN (d
   WHERE d.seq > 0)
   JOIN (ta
   WHERE (ta.event_id=hold->qual[d.seq].event_id)
    AND ta.task_status_cd != completed_cd)
   JOIN (taa
   WHERE taa.task_id=ta.task_id
    AND (taa.assign_prsnl_id=hold->qual[d.seq].prsnl_id))
  HEAD REPORT
   knt1 = 0, stat = alterlist(comp->qual,10)
  DETAIL
   knt1 = (knt1+ 1)
   IF (mod(knt1,10)=1
    AND knt1 != 1)
    stat = alterlist(comp->qual,(knt1+ 9))
   ENDIF
   comp->qual[knt1].task_id = ta.task_id,
   CALL echo(build(" cnt1 : ",knt1," : ",comp->qual[knt1].task_id))
  FOOT REPORT
   comp->qual_knt = knt1, stat = alterlist(comp->qual,knt1)
  WITH nocounter
 ;end select
 IF ((comp->qual_knt < 1))
  CALL echo(" ")
  CALL echo(" ")
  CALL echo(" ")
  CALL echo("No refused items found to be completed on the TASK_ACTIVITY table")
  CALL echo(" ")
  CALL echo(" ")
  CALL echo(" ")
  GO TO exit_script
 ENDIF
 SET ierrcode = 0
 UPDATE  FROM task_activity ta,
   (dummyt d  WITH seq = value(comp->qual_knt))
  SET d.seq = d.seq, ta.task_status_cd = completed_cd, ta.updt_task = 10101
  PLAN (d
   WHERE d.seq > 0)
   JOIN (ta
   WHERE (ta.task_id=comp->qual[d.seq].task_id))
  WITH nocounter
 ;end update
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  CALL echo(" ")
  CALL echo("ERROR : While updating the TASK_ACTIVITY table.  No changes made.")
  CALL echo(" ")
  ROLLBACK
 ELSE
  CALL echo(" ")
  CALL echo(" ")
  CALL echo(" ")
  CALL echo("SUCCESS : Refused items updated to complete on the TASK_ACTIVITY table")
  CALL echo(" ")
  CALL echo(" ")
  CALL echo(" ")
 ENDIF
#exit_script
END GO
