CREATE PROGRAM ec_profiler_m102:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 DECLARE dopencclass = f8 WITH constant(uar_get_code_by("MEANING",69,"OUTPATIENT"))
 DECLARE idx = i4 WITH noconstant(0)
 FREE RECORD openctypes
 RECORD openctypes(
   1 qual[*]
     2 encntr_type_cd = f8
 )
 SELECT INTO "nl:"
  FROM code_value_group cvg,
   code_value cv
  PLAN (cvg
   WHERE cvg.parent_code_value=dopencclass)
   JOIN (cv
   WHERE cv.code_value=cvg.child_code_value
    AND cv.code_set=71
    AND cv.active_ind=1)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(openctypes->qual,(cnt+ 9))
   ENDIF
   openctypes->qual[cnt].encntr_type_cd = cvg.child_code_value
  FOOT REPORT
   stat = alterlist(openctypes->qual,cnt)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SELECT INTO "nl"
   FROM encntr_loc_hist elh,
    problem p,
    encounter e,
    prsnl pr
   PLAN (p
    WHERE p.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     stop_dt_tm)
     AND p.active_ind=1)
    JOIN (e
    WHERE (e.person_id=(p.person_id+ 0))
     AND e.active_ind=1)
    JOIN (pr
    WHERE pr.person_id=p.updt_id
     AND ((pr.position_cd+ 0) > 0))
    JOIN (elh
    WHERE (elh.encntr_id=(e.encntr_id+ 0))
     AND elh.beg_effective_dt_tm <= cnvtdatetime(request->stop_dt_tm)
     AND ((elh.end_effective_dt_tm+ 0) >= cnvtdatetime(request->start_dt_tm))
     AND expand(idx,1,size(openctypes->qual,5),(elh.encntr_type_cd+ 0),openctypes->qual[idx].
     encntr_type_cd)
     AND elh.active_ind=1
     AND p.updt_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm)
   ORDER BY pr.position_cd, p.problem_id
   HEAD REPORT
    reply->facility_cnt = 1, stat = alterlist(reply->facilities,1), reply->facilities[1].facility_cd
     = 0.0,
    positioncnt = 0
   HEAD pr.position_cd
    positioncnt = (reply->facilities[1].position_cnt+ 1), reply->facilities[1].position_cnt =
    positioncnt, stat = alterlist(reply->facilities[1].positions,positioncnt),
    reply->facilities[1].positions[positioncnt].position_cd = pr.position_cd, reply->facilities[1].
    positions[positioncnt].capability_in_use_ind = 1, probcnt = 0
   HEAD p.problem_id
    probcnt = (probcnt+ 1)
   FOOT  pr.position_cd
    reply->facilities[1].positions[positioncnt].detail_cnt = 1, stat = alterlist(reply->facilities[1]
     .positions[positioncnt].details,1), reply->facilities[1].positions[positioncnt].details[1].
    detail_name = "",
    reply->facilities[1].positions[positioncnt].details[1].detail_value_txt = trim(cnvtstring(probcnt
      ))
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
