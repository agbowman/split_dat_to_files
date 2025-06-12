CREATE PROGRAM bed_rec_regmgmt_ad:dba
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
 SELECT INTO "nl:"
  FROM code_value c69,
   code_value_group cg,
   code_value c71
  PLAN (c69
   WHERE c69.code_set=69
    AND c69.cdf_meaning != "INPATIENT"
    AND c69.active_ind=1)
   JOIN (cg
   WHERE cg.parent_code_value=c69.code_value
    AND cg.code_set=71)
   JOIN (c71
   WHERE c71.code_value=cg.child_code_value
    AND c71.active_ind=1
    AND  NOT ( EXISTS (
   (SELECT
    ep.encntr_type_cd
    FROM encntr_type_params ep
    WHERE ep.encntr_type_cd=c71.code_value
     AND ep.param_name="AUTO_DISCH*"))))
  DETAIL
   reply->run_status_flag = 3
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
