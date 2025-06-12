CREATE PROGRAM ec_profiler_m58:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 SET last_mod = "002"
 DECLARE dipencclass = f8 WITH constant(uar_get_code_by("MEANING",69,"INPATIENT"))
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE idlgcnt = i4 WITH noconstant(0)
 DECLARE idlgpos = i4 WITH noconstant(0)
 FREE RECORD ipenctypes
 RECORD ipenctypes(
   1 qual[*]
     2 encntr_type_cd = f8
 )
 SELECT INTO "nl:"
  FROM code_value_group cvg,
   code_value cv
  PLAN (cvg
   WHERE cvg.parent_code_value=dipencclass)
   JOIN (cv
   WHERE cv.code_value=cvg.child_code_value
    AND cv.code_set=71
    AND cv.active_ind=1)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(ipenctypes->qual,(cnt+ 9))
   ENDIF
   ipenctypes->qual[cnt].encntr_type_cd = cvg.child_code_value
  FOOT REPORT
   stat = alterlist(ipenctypes->qual,cnt)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SELECT INTO "nl:"
   FROM eks_dlg ed,
    eks_dlg_event ede,
    encntr_loc_hist elh
   PLAN (ede
    WHERE ede.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     stop_dt_tm)
     AND ede.dlg_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     stop_dt_tm)
     AND ede.active_ind=1)
    JOIN (elh
    WHERE elh.encntr_id=ede.encntr_id
     AND elh.beg_effective_dt_tm <= cnvtdatetime(request->stop_dt_tm)
     AND ((elh.end_effective_dt_tm+ 0) >= cnvtdatetime(request->start_dt_tm))
     AND expand(idx,1,size(ipenctypes->qual,5),(elh.encntr_type_cd+ 0),ipenctypes->qual[idx].
     encntr_type_cd)
     AND elh.active_ind=1
     AND ede.dlg_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm)
    JOIN (ed
    WHERE ed.dlg_name=ede.dlg_name
     AND ed.active_ind=1
     AND ed.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND ed.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   ORDER BY elh.loc_facility_cd, ede.dlg_dt_tm, ede.trigger_entity_id,
    ede.trigger_order_id
   HEAD REPORT
    facilitycnt = 0, positioncnt = 0
   HEAD elh.loc_facility_cd
    facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
     ->facilities,facilitycnt),
    reply->facilities[facilitycnt].facility_cd = elh.loc_facility_cd, reply->facilities[facilitycnt].
    position_cnt = 1, stat = alterlist(reply->facilities[facilitycnt].positions,1),
    reply->facilities[facilitycnt].positions[1].position_cd = 0.0, reply->facilities[facilitycnt].
    positions[1].capability_in_use_ind = 1, idlgcnt = 0
   HEAD ede.dlg_dt_tm
    idlgpos = locateval(idx,1,idlgcnt,ed.title,reply->facilities[facilitycnt].positions[1].details[
     idx].detail_name)
    IF (((idlgpos=0) OR (idlgcnt=0)) )
     idlgcnt = (idlgcnt+ 1), reply->facilities[facilitycnt].positions[1].detail_cnt = idlgcnt, stat
      = alterlist(reply->facilities[facilitycnt].positions[1].details,idlgcnt),
     reply->facilities[facilitycnt].positions[1].details[idlgcnt].detail_name = ed.title, reply->
     facilities[facilitycnt].positions[1].details[idlgcnt].detail_value_txt = "0", idlgpos = idlgcnt
    ENDIF
   DETAIL
    reply->facilities[facilitycnt].positions[1].details[idlgpos].detail_value_txt = cnvtstring((
     cnvtint(reply->facilities[facilitycnt].positions[1].details[idlgpos].detail_value_txt)+ 1))
   WITH nocounter
  ;end select
 ENDIF
 IF ((reply->facility_cnt=0))
  SET reply->facility_cnt = 1
  SET stat = alterlist(reply->facilities,1)
  SET reply->facilities[1].position_cnt = 1
  SET stat = alterlist(reply->facilities[1].positions,1)
  SET reply->facilities[1].positions[1].capability_in_use_ind = 0
 ENDIF
END GO
