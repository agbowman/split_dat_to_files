CREATE PROGRAM ec_profiler_m110:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 DECLARE idx = i4 WITH noconstant(0)
 SET last_mod = "001"
 SELECT INTO "nl:"
  FROM eks_dlg_event ede,
   eks_dlg ekd,
   prsnl p
  PLAN (ede
   WHERE ede.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    stop_dt_tm)
    AND ede.dlg_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->stop_dt_tm
    )
    AND trim(ede.dlg_name)="MUL_MED!*")
   JOIN (ekd
   WHERE ekd.dlg_name=ede.dlg_name)
   JOIN (p
   WHERE p.person_id=ede.dlg_prsnl_id)
  ORDER BY p.position_cd, ede.dlg_name, ede.dlg_event_id
  HEAD REPORT
   reply->facility_cnt = 1, stat = alterlist(reply->facilities,1), reply->facilities[1].facility_cd
    = 0.0
  HEAD p.position_cd
   positioncnt = (reply->facilities[1].position_cnt+ 1), reply->facilities[1].position_cnt =
   positioncnt, stat = alterlist(reply->facilities[1].positions,positioncnt),
   reply->facilities[1].positions[positioncnt].position_cd = p.position_cd, reply->facilities[1].
   positions[positioncnt].capability_in_use_ind = 1
  HEAD ede.dlg_name
   dlgcnt = 0
  HEAD ede.dlg_event_id
   dlgcnt = (dlgcnt+ 1)
  FOOT  ede.dlg_name
   detailcnt = (reply->facilities[1].positions[positioncnt].detail_cnt+ 1), reply->facilities[1].
   positions[positioncnt].detail_cnt = detailcnt, stat = alterlist(reply->facilities[1].positions[
    positioncnt].details,detailcnt),
   reply->facilities[1].positions[positioncnt].details[detailcnt].detail_name = ekd.title, reply->
   facilities[1].positions[positioncnt].details[detailcnt].detail_value_txt = trim(cnvtstring(dlgcnt)
    )
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
