CREATE PROGRAM bed_get_report_security:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 user_level_security_ind = i2
    1 solutions[*]
      2 solution_mean = vc
      2 reports[*]
        3 script_name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM br_name_value bnv
  PLAN (bnv
   WHERE bnv.br_nv_key1="REPORTPARAM"
    AND bnv.br_name="USERLEVELSECIND")
  DETAIL
   IF (bnv.br_value="1")
    reply->user_level_security_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SET scnt = 0
 SELECT INTO "nl:"
  FROM br_name_value bnv,
   br_report br
  PLAN (bnv
   WHERE bnv.br_nv_key1="REPORTSECURITY"
    AND bnv.br_name=cnvtstring(request->person_id))
   JOIN (br
   WHERE br.program_name=bnv.br_value)
  ORDER BY br.solution_mean, br.program_name
  HEAD br.solution_mean
   scnt = (scnt+ 1), stat = alterlist(reply->solutions,scnt), reply->solutions[scnt].solution_mean =
   br.solution_mean,
   rcnt = 0
  DETAIL
   rcnt = (rcnt+ 1), stat = alterlist(reply->solutions[scnt].reports,rcnt), reply->solutions[scnt].
   reports[rcnt].script_name = br.program_name
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
