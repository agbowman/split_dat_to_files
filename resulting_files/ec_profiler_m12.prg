CREATE PROGRAM ec_profiler_m12
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 DECLARE dsnowmedct = f8 WITH constant(uar_get_code_by("MEANING",400,"SNMCT"))
 DECLARE dicd9cm = f8 WITH constant(uar_get_code_by("MEANING",400,"ICD9"))
 DECLARE dicd10 = f8 WITH constant(uar_get_code_by("MEANING",400,"ICD10"))
 DECLARE dlynx = f8 WITH constant(uar_get_code_by("MEANING",400,"LYNX"))
 DECLARE dloinc = f8 WITH constant(uar_get_code_by("MEANING",400,"LOINC"))
 DECLARE dcpt4 = f8 WITH constant(uar_get_code_by("MEANING",400,"CPT4"))
 SELECT INTO "nl:"
  FROM cmt_content_version c
  WHERE c.source_vocabulary_cd IN (dsnowmedct, dicd9cm, dicd10, dlynx, dloinc,
  dcpt4)
   AND c.ver_beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
   AND c.ver_end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  ORDER BY c.source_vocabulary_cd, c.ver_beg_effective_dt_tm DESC
  HEAD REPORT
   reply->facility_cnt = 1, stat = alterlist(reply->facilities,1), reply->facilities[1].facility_cd
    = 0.0,
   reply->facilities[1].position_cnt = 1, stat = alterlist(reply->facilities[1].positions,1), reply->
   facilities[1].positions[1].position_cd = 0.0,
   reply->facilities[1].positions[1].capability_in_use_ind = 0, detailcnt = 0
  HEAD c.source_vocabulary_cd
   reply->facilities[1].positions[1].capability_in_use_ind = 1, detailcnt = (reply->facilities[1].
   positions[1].detail_cnt+ 1), reply->facilities[1].positions[1].detail_cnt = detailcnt,
   stat = alterlist(reply->facilities[1].positions[1].details,detailcnt), reply->facilities[1].
   positions[1].details[detailcnt].detail_name = uar_get_code_display(c.source_vocabulary_cd), reply
   ->facilities[1].positions[1].details[detailcnt].detail_value_txt = c.version_ft
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
