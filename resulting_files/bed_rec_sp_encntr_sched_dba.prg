CREATE PROGRAM bed_rec_sp_encntr_sched:dba
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
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->run_status_flag = 1
 SET surg_code = 0.0
 SET encnt_code = 0.0
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=16127
    AND cv.cdf_meaning IN ("SURGCASE", "ENCNTRBOOK")
    AND cv.active_ind=1)
  DETAIL
   CASE (cv.cdf_meaning)
    OF "SURGCASE":
     surg_code = cv.code_value
    OF "ENCNTRBOOK":
     encnt_code = cv.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv,
   sch_appt_type sat,
   sch_appt_option sao,
   sch_appt_option sao2
  PLAN (cv
   WHERE cv.code_set=14230
    AND cv.active_ind=1)
   JOIN (sat
   WHERE sat.appt_type_cd=cv.code_value
    AND sat.active_ind=1)
   JOIN (sao
   WHERE sao.appt_type_cd=sat.appt_type_cd
    AND sao.sch_option_cd=surg_code
    AND sao.active_ind=1)
   JOIN (sao2
   WHERE sao2.appt_type_cd=outerjoin(sao.appt_type_cd)
    AND sao2.sch_option_cd=outerjoin(encnt_code)
    AND sao2.active_ind=outerjoin(1))
  DETAIL
   IF (sao2.appt_type_cd=0)
    reply->run_status_flag = 3
   ENDIF
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
END GO
