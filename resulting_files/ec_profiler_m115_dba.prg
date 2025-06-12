CREATE PROGRAM ec_profiler_m115:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 SELECT INTO "nl:"
  FROM eks_module m,
   eks_modulestorage s
  PLAN (m
   WHERE m.active_flag="A"
    AND m.maint_validation="PRODUCTION"
    AND m.maint_dur_begin_dt_tm <= cnvtdatetime(request->stop_dt_tm)
    AND m.maint_dur_end_dt_tm > cnvtdatetime(request->start_dt_tm))
   JOIN (s
   WHERE s.module_name=m.module_name
    AND s.version=m.version
    AND s.data_type=9)
  ORDER BY m.module_name
  HEAD REPORT
   reply->facility_cnt = 1, stat = alterlist(reply->facilities,1), reply->facilities[1].facility_cd
    = 0.0,
   reply->facilities[1].position_cnt = 1, stat = alterlist(reply->facilities[1].positions,1), reply->
   facilities[1].positions[1].position_cd = 0.0,
   reply->facilities[1].positions[1].capability_in_use_ind = 0, detailcnt = 0
  HEAD m.module_name
   IF (s.ekm_info="*EKS_ALERT_HTML_A*")
    reply->facilities[1].positions[1].capability_in_use_ind = 1, detailcnt = (reply->facilities[1].
    positions[1].detail_cnt+ 1), reply->facilities[1].positions[1].detail_cnt = detailcnt,
    stat = alterlist(reply->facilities[1].positions[1].details,detailcnt), reply->facilities[1].
    positions[1].details[detailcnt].detail_name = "", reply->facilities[1].positions[1].details[
    detailcnt].detail_value_txt = m.module_name
   ENDIF
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
