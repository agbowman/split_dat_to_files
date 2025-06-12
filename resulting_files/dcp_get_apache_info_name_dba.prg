CREATE PROGRAM dcp_get_apache_info_name:dba
 RECORD reply(
   1 icu_admit_dt_tm = dq8
   1 name_full_formatted = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = vc
       3 operationstatus = c1
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 )
 EXECUTE FROM 1000_initialize TO 1099_initialize_exit
 EXECUTE FROM 2000_read TO 2099_read_exit
 GO TO 9999_exit_program
#1000_initialize
 SET reply->status_data.status = "F"
#1099_initialize_exit
#2000_read
 SELECT INTO "nl:"
  FROM person p
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND p.active_ind=1)
  DETAIL
   reply->name_full_formatted = p.name_full_formatted
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 IF ((reply->status_data.status="S"))
  SELECT INTO "nl:"
   FROM risk_adjustment ra
   PLAN (ra
    WHERE (ra.encntr_id=request->encntr_id)
     AND ra.active_ind=1)
   ORDER BY ra.icu_admit_dt_tm
   DETAIL
    reply->icu_admit_dt_tm = ra.icu_admit_dt_tm
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
  IF ((reply->status_data.status="Z"))
   SELECT INTO "nl:"
    FROM encounter e
    PLAN (e
     WHERE (e.encntr_id=request->encntr_id)
      AND e.active_ind=1)
    DETAIL
     reply->icu_admit_dt_tm = e.reg_dt_tm
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET reply->status_data.status = "S"
   ELSE
    SET reply->status_data.status = "Z"
   ENDIF
  ENDIF
 ENDIF
#2099_read_exit
#9999_exit_program
 CALL echorecord(reply)
END GO
