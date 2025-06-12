CREATE PROGRAM ec_profiler_m5:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 DECLARE dfacilitycd = f8 WITH constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE dbuildingcd = f8 WITH constant(uar_get_code_by("MEANING",222,"BUILDING"))
 SELECT INTO "nl"
  FROM code_value cv,
   track_group tg,
   tracking_checkin tc,
   tracking_item ti,
   location_group lg,
   location_group lg2,
   pat_ed_document pedoc,
   pat_ed_doc_activity peda,
   pat_ed_reltn perel,
   prsnl p
  PLAN (cv
   WHERE cv.code_set=16370
    AND cv.cdf_meaning="ER")
   JOIN (tg
   WHERE tg.child_value=0
    AND tg.tracking_group_cd=cv.code_value)
   JOIN (tc
   WHERE tc.tracking_group_cd=tg.tracking_group_cd
    AND tc.checkin_dt_tm <= cnvtdatetime(request->stop_dt_tm)
    AND tc.checkout_dt_tm >= cnvtdatetime(request->start_dt_tm))
   JOIN (ti
   WHERE ti.tracking_id=tc.tracking_id)
   JOIN (pedoc
   WHERE pedoc.encntr_id=ti.encntr_id
    AND pedoc.create_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    stop_dt_tm))
   JOIN (peda
   WHERE peda.pat_ed_doc_id=pedoc.pat_ed_document_id)
   JOIN (perel
   WHERE perel.pat_ed_reltn_id=peda.pat_ed_reltn_id)
   JOIN (lg
   WHERE (lg.child_loc_cd=(tg.parent_value+ 0))
    AND lg.location_group_type_cd=dbuildingcd
    AND ((lg.root_loc_cd+ 0)=0)
    AND lg.active_ind=1)
   JOIN (lg2
   WHERE lg2.child_loc_cd=lg.parent_loc_cd
    AND lg2.location_group_type_cd=dfacilitycd
    AND ((lg2.root_loc_cd+ 0)=0)
    AND lg2.active_ind=1)
   JOIN (p
   WHERE p.person_id=pedoc.create_id)
  ORDER BY lg2.parent_loc_cd, p.position_cd, perel.pat_ed_domain_cd
  HEAD REPORT
   facilitycnt = 0
  HEAD lg2.parent_loc_cd
   facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
    ->facilities,facilitycnt),
   reply->facilities[facilitycnt].facility_cd = lg2.parent_loc_cd, positioncnt = 0
  HEAD p.position_cd
   positioncnt = (reply->facilities[facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].
   position_cnt = positioncnt, stat = alterlist(reply->facilities[facilitycnt].positions,positioncnt),
   reply->facilities[facilitycnt].positions[positioncnt].position_cd = p.position_cd, reply->
   facilities[facilitycnt].positions[positioncnt].capability_in_use_ind = 1
  HEAD perel.pat_ed_domain_cd
   idoccnt = 0
  DETAIL
   idoccnt = (idoccnt+ 1)
  FOOT  perel.pat_ed_domain_cd
   reply->facilities[facilitycnt].positions[positioncnt].detail_cnt = 1, stat = alterlist(reply->
    facilities[facilitycnt].positions[positioncnt].details,1), reply->facilities[facilitycnt].
   positions[positioncnt].details[1].detail_name = uar_get_code_display(perel.pat_ed_domain_cd),
   reply->facilities[facilitycnt].positions[positioncnt].details[1].detail_value_txt = cnvtstring(
    idoccnt)
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
