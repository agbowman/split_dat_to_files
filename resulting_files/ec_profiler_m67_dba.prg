CREATE PROGRAM ec_profiler_m67:dba
 DECLARE dipencclass = f8 WITH constant(uar_get_code_by("MEANING",69,"INPATIENT"))
 DECLARE idx = i4 WITH noconstant(0)
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
  SELECT INTO "nl"
   entrytype =
   IF (a.substance_nom_id > 0) 1
   ELSE 0
   ENDIF
   FROM encntr_loc_hist elh,
    allergy a
   PLAN (a
    WHERE a.created_dt_tm >= cnvtdatetime(request->start_dt_tm)
     AND a.created_dt_tm <= cnvtdatetime(request->stop_dt_tm)
     AND a.updt_dt_tm >= cnvtdatetime(request->start_dt_tm))
    JOIN (elh
    WHERE elh.encntr_id=a.encntr_id
     AND elh.beg_effective_dt_tm <= cnvtdatetime(request->stop_dt_tm)
     AND ((elh.end_effective_dt_tm+ 0) >= cnvtdatetime(request->start_dt_tm))
     AND expand(idx,1,size(ipenctypes->qual,5),(elh.encntr_type_cd+ 0),ipenctypes->qual[idx].
     encntr_type_cd)
     AND elh.active_ind=1
     AND a.created_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm)
   ORDER BY entrytype
   HEAD REPORT
    reply->facility_cnt = 1, stat = alterlist(reply->facilities,1), reply->facilities[1].facility_cd
     = 0.0,
    positioncnt = 1, reply->facilities[1].position_cnt = 1, stat = alterlist(reply->facilities[1].
     positions,positioncnt),
    reply->facilities[1].positions[1].position_cd = 0.0, reply->facilities[1].positions[1].
    capability_in_use_ind = 1
   HEAD entrytype
    entrycnt = 0
   DETAIL
    entrycnt = (entrycnt+ 1)
   FOOT  entrytype
    detailcnt = (reply->facilities[1].positions[1].detail_cnt+ 1), reply->facilities[1].positions[1].
    detail_cnt = detailcnt, stat = alterlist(reply->facilities[1].positions[1].details,detailcnt)
    IF (entrytype=0)
     reply->facilities[1].positions[1].details[detailcnt].detail_name = "Free Text"
    ELSE
     reply->facilities[1].positions[1].details[detailcnt].detail_name = "Codified"
    ENDIF
    reply->facilities[1].positions[1].details[detailcnt].detail_value_txt = trim(cnvtstring(entrycnt)
     )
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
