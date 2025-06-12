CREATE PROGRAM ec_profiler_m68:dba
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 SET last_mod = "001"
 DECLARE dipencclass = f8 WITH constant(uar_get_code_by("MEANING",69,"INPATIENT"))
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE dpregcreate = f8 WITH constant(uar_get_code_by("MEANING",4002114,"CREATE"))
 DECLARE dprobauth = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH"))
 DECLARE icur_list_size = i4 WITH noconstant(0)
 DECLARE iloop_cnt = i4 WITH noconstant(0)
 DECLARE inew_list_size = i4 WITH noconstant(0)
 DECLARE istart = i4 WITH noconstant(0)
 DECLARE iexpandidx = i4 WITH noconstant(0)
 DECLARE ibatch_size = i4 WITH constant(50)
 DECLARE facpos = i4 WITH noconstant(0)
 DECLARE pospos = i4 WITH noconstant(0)
 DECLARE bpreginstind = i2 WITH noconstant(0)
 DECLARE bpregactind = i2 WITH noconstant(0)
 DECLARE bshxactind = i2 WITH noconstant(0)
 DECLARE bfhxactind = i2 WITH noconstant(0)
 FREE RECORD ipenctypes
 RECORD ipenctypes(
   1 qual[*]
     2 encntr_type_cd = f8
 )
 SELECT INTO "nl:"
  FROM dtable d
  WHERE d.table_name IN ("PREGNANCY_INSTANCE", "PREGNANCY_ACTION", "SHX_ACTIVITY", "FHX_ACTIVITY")
  DETAIL
   CASE (d.table_name)
    OF "PREGNANCY_INSTANCE":
     bpreginstind = 1
    OF "PREGNANCY_ACTION":
     bpregactind = 1
    OF "SHX_ACTIVITY":
     bshxactind = 1
    OF "FHX_ACTIVITY":
     bfhxactind = 1
   ENDCASE
  WITH nocounter
 ;end select
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
  IF (bpreginstind=1
   AND bpregactind=1)
   SELECT INTO "nl:"
    FROM encounter e,
     encntr_loc_hist elh,
     pregnancy_instance pi,
     pregnancy_action pa,
     prsnl p
    PLAN (pa
     WHERE pa.action_dt_tm >= cnvtdatetime(request->start_dt_tm)
      AND pa.action_dt_tm <= cnvtdatetime(request->stop_dt_tm)
      AND pa.action_type_cd=dpregcreate)
     JOIN (pi
     WHERE (pi.pregnancy_id=(pa.pregnancy_id+ 0))
      AND pi.active_ind=1)
     JOIN (e
     WHERE (e.person_id=(pi.person_id+ 0)))
     JOIN (p
     WHERE p.person_id=pa.prsnl_id)
     JOIN (elh
     WHERE (elh.encntr_id=(e.encntr_id+ 0))
      AND elh.beg_effective_dt_tm <= cnvtdatetime(request->stop_dt_tm)
      AND ((elh.end_effective_dt_tm+ 0) >= cnvtdatetime(request->start_dt_tm))
      AND expand(idx,1,size(ipenctypes->qual,5),(elh.encntr_type_cd+ 0),ipenctypes->qual[idx].
      encntr_type_cd)
      AND elh.active_ind=1)
    ORDER BY elh.loc_facility_cd, p.position_cd, pa.pregnancy_action_id
    HEAD REPORT
     facilitycnt = 0
    HEAD elh.loc_facility_cd
     facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(
      reply->facilities,facilitycnt),
     reply->facilities[facilitycnt].facility_cd = elh.loc_facility_cd, positioncnt = 0
    HEAD p.position_cd
     positioncnt = (reply->facilities[facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].
     position_cnt = positioncnt, stat = alterlist(reply->facilities[facilitycnt].positions,
      positioncnt),
     reply->facilities[facilitycnt].positions[positioncnt].position_cd = p.position_cd, reply->
     facilities[facilitycnt].positions[positioncnt].capability_in_use_ind = 1, detailcnt = 0,
     actioncnt = 0
    DETAIL
     actioncnt = (actioncnt+ 1)
    FOOT  p.position_cd
     detailcnt = (reply->facilities[facilitycnt].positions[positioncnt].detail_cnt+ 1), reply->
     facilities[facilitycnt].positions[positioncnt].detail_cnt = detailcnt, stat = alterlist(reply->
      facilities[facilitycnt].positions[positioncnt].details,detailcnt),
     reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_name =
     "Pregnancy History", reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].
     detail_value_txt = trim(cnvtstring(actioncnt))
    WITH nocounter
   ;end select
  ENDIF
  SELECT INTO "nl:"
   FROM encntr_loc_hist elh,
    procedure pr,
    procedure_action pa,
    prsnl p
   PLAN (pr
    WHERE pr.active_ind=1
     AND pr.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     stop_dt_tm))
    JOIN (pa
    WHERE pa.procedure_id=pr.procedure_id
     AND pa.action_dt_tm >= cnvtdatetime(request->start_dt_tm)
     AND pa.action_dt_tm <= cnvtdatetime(request->stop_dt_tm)
     AND pa.action_type_mean="CREATE")
    JOIN (elh
    WHERE elh.encntr_id=pr.encntr_id
     AND elh.beg_effective_dt_tm <= cnvtdatetime(request->stop_dt_tm)
     AND ((elh.end_effective_dt_tm+ 0) >= cnvtdatetime(request->start_dt_tm))
     AND expand(idx,1,size(ipenctypes->qual,5),(elh.encntr_type_cd+ 0),ipenctypes->qual[idx].
     encntr_type_cd)
     AND elh.active_ind=1)
    JOIN (p
    WHERE p.person_id=pa.prsnl_id)
   ORDER BY elh.loc_facility_cd, p.position_cd, pa.procedure_action_id
   HEAD REPORT
    IF ((reply->facility_cnt=0))
     facilitycnt = 0
    ENDIF
   HEAD elh.loc_facility_cd
    facpos = locateval(idx,1,reply->facility_cnt,elh.loc_facility_cd,reply->facilities[idx].
     facility_cd)
    IF (facpos=0)
     facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(
      reply->facilities,facilitycnt),
     reply->facilities[facilitycnt].facility_cd = elh.loc_facility_cd
    ELSE
     facilitycnt = facpos
    ENDIF
    positioncnt = 0
   HEAD p.position_cd
    pospos = locateval(idx,1,reply->facilities[facilitycnt].position_cnt,p.position_cd,reply->
     facilities[facilitycnt].positions[idx].position_cd)
    IF (pospos=0)
     positioncnt = (reply->facilities[facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].
     position_cnt = positioncnt, stat = alterlist(reply->facilities[facilitycnt].positions,
      positioncnt),
     reply->facilities[facilitycnt].positions[positioncnt].position_cd = p.position_cd, reply->
     facilities[facilitycnt].positions[positioncnt].capability_in_use_ind = 1
    ELSE
     positioncnt = pospos
    ENDIF
    detailcnt = 0, actioncnt = 0
   DETAIL
    actioncnt = (actioncnt+ 1)
   FOOT  p.position_cd
    detailcnt = (reply->facilities[facilitycnt].positions[positioncnt].detail_cnt+ 1), reply->
    facilities[facilitycnt].positions[positioncnt].detail_cnt = detailcnt, stat = alterlist(reply->
     facilities[facilitycnt].positions[positioncnt].details,detailcnt),
    reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_name =
    "Procedure History", reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].
    detail_value_txt = trim(cnvtstring(actioncnt))
   WITH nocounter
  ;end select
  IF (bshxactind=1)
   SELECT INTO "nl:"
    FROM encounter e,
     encntr_loc_hist elh,
     shx_activity shx,
     prsnl p
    PLAN (shx
     WHERE shx.perform_dt_tm >= cnvtdatetime(request->start_dt_tm)
      AND shx.perform_dt_tm <= cnvtdatetime(request->stop_dt_tm)
      AND shx.person_id > 0.0
      AND shx.beg_effective_dt_tm <= cnvtdatetime(request->stop_dt_tm)
      AND shx.end_effective_dt_tm >= cnvtdatetime(request->start_dt_tm)
      AND shx.active_ind=1)
     JOIN (e
     WHERE e.person_id=shx.person_id)
     JOIN (p
     WHERE p.person_id=shx.updt_id)
     JOIN (elh
     WHERE (elh.encntr_id=(e.encntr_id+ 0))
      AND elh.beg_effective_dt_tm <= cnvtdatetime(request->stop_dt_tm)
      AND ((elh.end_effective_dt_tm+ 0) >= cnvtdatetime(request->start_dt_tm))
      AND expand(idx,1,size(ipenctypes->qual,5),(elh.encntr_type_cd+ 0),ipenctypes->qual[idx].
      encntr_type_cd)
      AND elh.active_ind=1)
    ORDER BY elh.loc_facility_cd, p.position_cd, shx.shx_activity_id
    HEAD REPORT
     IF ((reply->facility_cnt=0))
      facilitycnt = 0
     ENDIF
    HEAD elh.loc_facility_cd
     facpos = locateval(idx,1,reply->facility_cnt,elh.loc_facility_cd,reply->facilities[idx].
      facility_cd)
     IF (facpos=0)
      facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(
       reply->facilities,facilitycnt),
      reply->facilities[facilitycnt].facility_cd = elh.loc_facility_cd
     ELSE
      facilitycnt = facpos
     ENDIF
     positioncnt = 0
    HEAD p.position_cd
     pospos = locateval(idx,1,reply->facilities[facilitycnt].position_cnt,p.position_cd,reply->
      facilities[facilitycnt].positions[idx].position_cd)
     IF (pospos=0)
      positioncnt = (reply->facilities[facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].
      position_cnt = positioncnt, stat = alterlist(reply->facilities[facilitycnt].positions,
       positioncnt),
      reply->facilities[facilitycnt].positions[positioncnt].position_cd = p.position_cd, reply->
      facilities[facilitycnt].positions[positioncnt].capability_in_use_ind = 1
     ELSE
      positioncnt = pospos
     ENDIF
     detailcnt = 0, actioncnt = 0
    DETAIL
     actioncnt = (actioncnt+ 1)
    FOOT  p.position_cd
     detailcnt = (reply->facilities[facilitycnt].positions[positioncnt].detail_cnt+ 1), reply->
     facilities[facilitycnt].positions[positioncnt].detail_cnt = detailcnt, stat = alterlist(reply->
      facilities[facilitycnt].positions[positioncnt].details,detailcnt),
     reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_name =
     "Social History", reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].
     detail_value_txt = trim(cnvtstring(actioncnt))
    WITH nocounter
   ;end select
  ENDIF
  SELECT INTO "nl:"
   FROM encounter e,
    encntr_loc_hist elh,
    problem pr,
    prsnl p
   PLAN (pr
    WHERE pr.active_ind=1
     AND pr.data_status_cd=dprobauth
     AND pr.data_status_dt_tm >= cnvtdatetime(request->start_dt_tm)
     AND pr.data_status_dt_tm <= cnvtdatetime(request->stop_dt_tm)
     AND pr.updt_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
     stop_dt_tm))
    JOIN (e
    WHERE e.person_id=pr.person_id)
    JOIN (p
    WHERE p.person_id=pr.updt_id)
    JOIN (elh
    WHERE (elh.encntr_id=(e.encntr_id+ 0))
     AND elh.beg_effective_dt_tm <= cnvtdatetime(request->stop_dt_tm)
     AND ((elh.end_effective_dt_tm+ 0) >= cnvtdatetime(request->start_dt_tm))
     AND expand(idx,1,size(ipenctypes->qual,5),(elh.encntr_type_cd+ 0),ipenctypes->qual[idx].
     encntr_type_cd)
     AND elh.active_ind=1)
   ORDER BY elh.loc_facility_cd, p.position_cd, pr.problem_id
   HEAD REPORT
    IF ((reply->facility_cnt=0))
     facilitycnt = 0
    ENDIF
   HEAD elh.loc_facility_cd
    facpos = locateval(idx,1,reply->facility_cnt,elh.loc_facility_cd,reply->facilities[idx].
     facility_cd)
    IF (facpos=0)
     facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(
      reply->facilities,facilitycnt),
     reply->facilities[facilitycnt].facility_cd = elh.loc_facility_cd
    ELSE
     facilitycnt = facpos
    ENDIF
    positioncnt = 0
   HEAD p.position_cd
    pospos = locateval(idx,1,reply->facilities[facilitycnt].position_cnt,p.position_cd,reply->
     facilities[facilitycnt].positions[idx].position_cd)
    IF (pospos=0)
     positioncnt = (reply->facilities[facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].
     position_cnt = positioncnt, stat = alterlist(reply->facilities[facilitycnt].positions,
      positioncnt),
     reply->facilities[facilitycnt].positions[positioncnt].position_cd = p.position_cd, reply->
     facilities[facilitycnt].positions[positioncnt].capability_in_use_ind = 1
    ELSE
     positioncnt = pospos
    ENDIF
    detailcnt = 0, actioncnt = 0
   DETAIL
    actioncnt = (actioncnt+ 1)
   FOOT  p.position_cd
    detailcnt = (reply->facilities[facilitycnt].positions[positioncnt].detail_cnt+ 1), reply->
    facilities[facilitycnt].positions[positioncnt].detail_cnt = detailcnt, stat = alterlist(reply->
     facilities[facilitycnt].positions[positioncnt].details,detailcnt),
    reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_name =
    "Past Medical History", reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].
    detail_value_txt = trim(cnvtstring(actioncnt))
   WITH nocounter
  ;end select
  IF (bfhxactind=1)
   SELECT INTO "nl:"
    FROM encounter e,
     encntr_loc_hist elh,
     fhx_activity fhx,
     prsnl p
    PLAN (fhx
     WHERE fhx.active_ind=1
      AND fhx.beg_effective_dt_tm >= cnvtdatetime(request->start_dt_tm))
     JOIN (e
     WHERE e.person_id=fhx.person_id)
     JOIN (p
     WHERE p.person_id=fhx.active_status_prsnl_id)
     JOIN (elh
     WHERE (elh.encntr_id=(e.encntr_id+ 0))
      AND elh.beg_effective_dt_tm <= cnvtdatetime(request->stop_dt_tm)
      AND ((elh.end_effective_dt_tm+ 0) >= cnvtdatetime(request->start_dt_tm))
      AND expand(idx,1,size(ipenctypes->qual,5),(elh.encntr_type_cd+ 0),ipenctypes->qual[idx].
      encntr_type_cd)
      AND elh.active_ind=1)
    ORDER BY elh.loc_facility_cd, p.position_cd, fhx.fhx_activity_id
    HEAD REPORT
     IF ((reply->facility_cnt=0))
      facilitycnt = 0
     ENDIF
    HEAD elh.loc_facility_cd
     facpos = locateval(idx,1,reply->facility_cnt,elh.loc_facility_cd,reply->facilities[idx].
      facility_cd)
     IF (facpos=0)
      facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(
       reply->facilities,facilitycnt),
      reply->facilities[facilitycnt].facility_cd = elh.loc_facility_cd
     ELSE
      facilitycnt = facpos
     ENDIF
     positioncnt = 0
    HEAD p.position_cd
     pospos = locateval(idx,1,reply->facilities[facilitycnt].position_cnt,p.position_cd,reply->
      facilities[facilitycnt].positions[idx].position_cd)
     IF (pospos=0)
      positioncnt = (reply->facilities[facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].
      position_cnt = positioncnt, stat = alterlist(reply->facilities[facilitycnt].positions,
       positioncnt),
      reply->facilities[facilitycnt].positions[positioncnt].position_cd = p.position_cd, reply->
      facilities[facilitycnt].positions[positioncnt].capability_in_use_ind = 1
     ELSE
      positioncnt = pospos
     ENDIF
     detailcnt = 0, actioncnt = 0
    DETAIL
     actioncnt = (actioncnt+ 1)
    FOOT  p.position_cd
     detailcnt = (reply->facilities[facilitycnt].positions[positioncnt].detail_cnt+ 1), reply->
     facilities[facilitycnt].positions[positioncnt].detail_cnt = detailcnt, stat = alterlist(reply->
      facilities[facilitycnt].positions[positioncnt].details,detailcnt),
     reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].detail_name =
     "Family History", reply->facilities[facilitycnt].positions[positioncnt].details[detailcnt].
     detail_value_txt = trim(cnvtstring(actioncnt))
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF ((reply->facility_cnt=0))
  SET reply->facility_cnt = 1
  SET stat = alterlist(reply->facilities,1)
  SET reply->facilities[1].position_cnt = 1
  SET stat = alterlist(reply->facilities[1].positions,1)
  SET reply->facilities[1].positions[1].capability_in_use_ind = 0
 ENDIF
END GO
