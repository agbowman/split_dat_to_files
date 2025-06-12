CREATE PROGRAM ec_profiler_m50:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 SELECT INTO "nl:"
  FROM perioperative_document pd
  WHERE pd.rec_ver_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
   stop_dt_tm)
  ORDER BY pd.doc_type_cd
  HEAD REPORT
   reply->facility_cnt = 1, stat = alterlist(reply->facilities,1), reply->facilities[1].facility_cd
    = 0.0,
   reply->facilities[1].position_cnt = 1, stat = alterlist(reply->facilities[1].positions,1), reply->
   facilities[1].positions[1].position_cd = 0.0,
   reply->facilities[1].positions[1].capability_in_use_ind = 1
  HEAD pd.doc_type_cd
   doctypecnt = 0
  DETAIL
   doctypecnt = (doctypecnt+ 1)
  FOOT  pd.doc_type_cd
   detailcnt = (reply->facilities[1].positions[1].detail_cnt+ 1), reply->facilities[1].positions[1].
   detail_cnt = detailcnt, stat = alterlist(reply->facilities[1].positions[1].details,detailcnt),
   reply->facilities[1].positions[1].details[detailcnt].detail_name = uar_get_code_display(pd
    .doc_type_cd), reply->facilities[1].positions[1].details[detailcnt].detail_value_txt = trim(
    cnvtstring(doctypecnt))
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
