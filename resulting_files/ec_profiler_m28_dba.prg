CREATE PROGRAM ec_profiler_m28:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 SET last_mod = "002"
 DECLARE dfacility = f8 WITH constant(uar_get_code_by("MEANING",222,"FACILITY"))
 DECLARE dbuilding = f8 WITH constant(uar_get_code_by("MEANING",222,"BUILDING"))
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE idlgcnt = i4 WITH noconstant(0)
 DECLARE idlgpos = i4 WITH noconstant(0)
 SELECT INTO "nl"
  FROM code_value cv,
   track_group tg,
   tracking_checkin tc,
   tracking_item ti,
   location_group lg,
   location_group lg2,
   eks_dlg_event ede,
   eks_dlg ed
  PLAN (cv
   WHERE cv.code_set=16370
    AND cv.cdf_meaning="ER")
   JOIN (tg
   WHERE tg.child_value=0
    AND (tg.tracking_group_cd=(cv.code_value+ 0)))
   JOIN (tc
   WHERE tc.tracking_group_cd=tg.tracking_group_cd
    AND tc.checkin_dt_tm <= cnvtdatetime(request->stop_dt_tm)
    AND tc.checkout_dt_tm >= cnvtdatetime(request->start_dt_tm))
   JOIN (ti
   WHERE ti.tracking_id=tc.tracking_id
    AND ti.encntr_id > 0.0)
   JOIN (lg
   WHERE (lg.child_loc_cd=(tg.parent_value+ 0))
    AND lg.location_group_type_cd=dbuilding
    AND ((lg.root_loc_cd+ 0)=0)
    AND lg.active_ind=1)
   JOIN (lg2
   WHERE lg2.child_loc_cd=lg.parent_loc_cd
    AND lg2.location_group_type_cd=dfacility
    AND ((lg2.root_loc_cd+ 0)=0)
    AND lg2.active_ind=1)
   JOIN (ede
   WHERE ede.encntr_id=ti.encntr_id
    AND ede.dlg_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->stop_dt_tm
    ))
   JOIN (ed
   WHERE ed.dlg_name=ede.dlg_name
    AND ed.active_ind=1
    AND ed.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ed.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
  ORDER BY lg2.parent_loc_cd, ede.dlg_dt_tm, ede.trigger_entity_id,
   ede.trigger_order_id
  HEAD REPORT
   facilitycnt = 0
  HEAD lg2.parent_loc_cd
   facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
    ->facilities,facilitycnt),
   reply->facilities[facilitycnt].facility_cd = lg2.parent_loc_cd, reply->facilities[facilitycnt].
   position_cnt = 1, stat = alterlist(reply->facilities[facilitycnt].positions,1),
   reply->facilities[facilitycnt].positions[1].position_cd = 0.0, reply->facilities[facilitycnt].
   positions[1].capability_in_use_ind = 1, idlgcnt = 0
  HEAD ede.dlg_dt_tm
   idlgpos = locateval(idx,1,idlgcnt,ed.title,reply->facilities[facilitycnt].positions[1].details[idx
    ].detail_name)
   IF (((idlgpos=0) OR (idlgcnt=0)) )
    idlgcnt = (idlgcnt+ 1), reply->facilities[facilitycnt].positions[1].detail_cnt = idlgcnt, stat =
    alterlist(reply->facilities[facilitycnt].positions[1].details,idlgcnt),
    reply->facilities[facilitycnt].positions[1].details[idlgcnt].detail_name = ed.title, reply->
    facilities[facilitycnt].positions[1].details[idlgcnt].detail_value_txt = "0", idlgpos = idlgcnt
   ENDIF
  DETAIL
   reply->facilities[facilitycnt].positions[1].details[idlgpos].detail_value_txt = cnvtstring((
    cnvtint(reply->facilities[facilitycnt].positions[1].details[idlgpos].detail_value_txt)+ 1))
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
