CREATE PROGRAM ec_profiler_m119:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 DECLARE dconfidlevelphy = f8 WITH constant(uar_get_code_by("MEANING",87,"WEBPROVIDER"))
 DECLARE dconfidlevelcon = f8 WITH constant(uar_get_code_by("MEANING",87,"WEBSPONSOR"))
 DECLARE dmessaging = f8 WITH constant(uar_get_code_by("MEANING",320,"MESSAGING"))
 DECLARE dmessagingpa = f8 WITH constant(uar_get_code_by("MEANING",4,"MESSAGING"))
 SELECT INTO "nl:"
  FROM code_value cv,
   org_alias_pool_reltn oapr,
   prsnl_org_reltn por,
   prsnl pr,
   person_alias pa
  PLAN (cv
   WHERE cv.display_key IN ("MESSAGINGCERNPHR", "LOCALMESSAGING*")
    AND cv.code_set=263
    AND cv.active_ind=1)
   JOIN (oapr
   WHERE oapr.alias_pool_cd=cv.code_value
    AND oapr.active_ind=1
    AND oapr.alias_entity_alias_type_cd=dmessaging)
   JOIN (por
   WHERE por.organization_id=oapr.organization_id
    AND por.confid_level_cd IN (dconfidlevelphy, dconfidlevelcon)
    AND por.active_ind=1)
   JOIN (pr
   WHERE pr.person_id=por.person_id
    AND pr.active_ind=1)
   JOIN (pa
   WHERE pa.person_id=outerjoin(pr.person_id)
    AND pa.person_alias_type_cd=outerjoin(dmessagingpa)
    AND pa.active_ind=outerjoin(1)
    AND pa.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
    AND pa.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
  HEAD REPORT
   reply->facility_cnt = 1, stat = alterlist(reply->facilities,1), reply->facilities[1].facility_cd
    = 0.0,
   reply->facilities[1].position_cnt = 1, stat = alterlist(reply->facilities[1].positions,1), reply->
   facilities[1].positions[1].position_cd = 0.0,
   reply->facilities[1].positions[1].capability_in_use_ind = 1, physcnt = 0, consumercnt = 0,
   identconsumercnt = 0
  DETAIL
   IF (pr.physician_ind=1)
    physcnt = (physcnt+ 1)
   ELSEIF (pa.person_alias_id > 0.0)
    identconsumercnt = (identconsumercnt+ 1)
   ELSE
    consumercnt = (consumercnt+ 1)
   ENDIF
  FOOT REPORT
   reply->facilities[1].positions[1].detail_cnt = 3, stat = alterlist(reply->facilities[1].positions[
    1].details,3), reply->facilities[1].positions[1].details[1].detail_name = "Physicians",
   reply->facilities[1].positions[1].details[1].detail_value_txt = cnvtstring(physcnt), reply->
   facilities[1].positions[1].details[2].detail_name = "Identified Consumers", reply->facilities[1].
   positions[1].details[2].detail_value_txt = cnvtstring(identconsumercnt),
   reply->facilities[1].positions[1].details[3].detail_name = "Unidentified Consumers", reply->
   facilities[1].positions[1].details[3].detail_value_txt = cnvtstring(consumercnt)
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
