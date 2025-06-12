CREATE PROGRAM ce_upd_event_prsnl_zero_row:dba
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 SELECT INTO "nl:"
  FROM ce_event_prsnl c
  WHERE ce_event_prsnl_id=0.0
  WITH counter
 ;end select
 IF (curqual=0)
  SET reply->error_msg = "Missing zero row on ce_event_prsnl table"
 ELSEIF (curqual > 0)
  SELECT INTO "nl:"
   FROM ce_event_prsnl
   WHERE ce_event_prsnl_id=0.0
    AND updt_dt_tm=cnvtdatetimeutc("01-Jan-1800 00:00:00")
   WITH counter
  ;end select
  IF (curqual=0)
   UPDATE  FROM ce_event_prsnl t
    SET t.updt_dt_tm = cnvtdatetimeutc("01-Jan-1800 00:00:00")
    WHERE t.ce_event_prsnl_id=0.0
    WITH nocounter
   ;end update
   COMMIT
  ENDIF
  SET error_code = error(error_msg,0)
  SET reply->error_code = error_code
  SET reply->error_msg = error_msg
 ENDIF
END GO
