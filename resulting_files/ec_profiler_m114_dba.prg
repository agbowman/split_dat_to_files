CREATE PROGRAM ec_profiler_m114:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 SELECT INTO "nl:"
  FROM risk_adjustment ra
  WHERE ra.encntr_id > 0.0
   AND ra.icu_admit_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
   stop_dt_tm)
   AND ra.valid_until_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00")
  HEAD REPORT
   reply->facility_cnt = 1, stat = alterlist(reply->facilities,1), reply->facilities[1].facility_cd
    = 0.0,
   reply->facilities[1].position_cnt = 1, stat = alterlist(reply->facilities[1].positions,1), reply->
   facilities[1].positions[1].position_cd = 0.0,
   reply->facilities[1].positions[1].capability_in_use_ind = 1, reply->facilities[1].positions[1].
   detail_cnt = 1, stat = alterlist(reply->facilities[1].positions[1].details,1),
   reply->facilities[1].positions[1].details[1].detail_name = "", reply->facilities[1].positions[1].
   details[1].detail_value_txt = ""
  WITH nocounter
 ;end select
 IF ((reply->facility_cnt=0))
  SET reply->facility_cnt = 1
  SET stat = alterlist(reply->facilities,1)
  SET reply->facilities[1].position_cnt = 1
  SET stat = alterlist(reply->facilities[1].positions,1)
  SET reply->facilities[1].positions[1].capability_in_use_ind = 0
 ENDIF
END GO
