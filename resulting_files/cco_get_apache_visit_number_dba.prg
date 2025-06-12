CREATE PROGRAM cco_get_apache_visit_number:dba
 DECLARE visit_num = i4 WITH protect
 SET get_visit_reply->visit_number = - (1)
 SET get_visit_reply->status = "F"
 SET get_visit_reply->status_data.subeventstatus[1].targetobjectvalue =
 "(Generic) Not enough information to determine visit number."
 SET ra_found = "N"
 SET encntr_id = 0.0
 SET visit_num = 0
 IF ((get_visit_parameters->risk_adjustment_id=0))
  SET get_visit_reply->status_data.subeventstatus[1].targetobjectvalue =
  "Risk_adjustment_id not populated in CCO_GET_APACHE_VISIT_NUMBER."
  GO TO 9999_exit_program
 ENDIF
 SELECT INTO "nl:"
  FROM risk_adjustment ra
  PLAN (ra
   WHERE ra.active_ind=1
    AND (ra.encntr_id=
   (SELECT
    ra2.encntr_id
    FROM risk_adjustment ra2
    WHERE (ra2.risk_adjustment_id=get_visit_parameters->risk_adjustment_id)))
    AND (ra.icu_admit_dt_tm <=
   (SELECT
    ra3.icu_admit_dt_tm
    FROM risk_adjustment ra3
    WHERE (ra3.risk_adjustment_id=get_visit_parameters->risk_adjustment_id))))
  HEAD REPORT
   visit_num = 0
  DETAIL
   visit_num = (visit_num+ 1)
  WITH nocounter
 ;end select
 IF (visit_num > 0)
  SET ra_found = "Y"
 ENDIF
 IF (ra_found="N")
  SET get_visit_reply->status_data.subeventstatus[1].targetobjectvalue =
  "No active risk_adjustment row found for get apache visit number."
  GO TO 9999_exit_program
 ENDIF
 SET get_visit_reply->visit_number = visit_num
 SET get_visit_reply->status_data.subeventstatus[1].targetobjectvalue = "Success"
 SET get_visit_reply->status_data.status = "S"
#9999_exit_program
END GO
