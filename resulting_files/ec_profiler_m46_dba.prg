CREATE PROGRAM ec_profiler_m46:dba
 SET dipencclass = uar_get_code_by("MEANING",69,"INPATIENT")
 SET dcompletestat = uar_get_code_by("MEANING",79,"COMPLETE")
 SET idx = 0
 SET idx2 = 0
 FREE RECORD ipenctypes
 RECORD ipenctypes(
   1 qual[*]
     2 encntr_type_cd = f8
 )
 FREE RECORD medtasks
 RECORD medtasks(
   1 qual[*]
     2 task_type_cd = f8
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
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=6026
   AND cv.cdf_meaning="MED"
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(medtasks->qual,(cnt+ 9))
   ENDIF
   medtasks->qual[cnt].task_type_cd = cv.code_value
  FOOT REPORT
   stat = alterlist(medtasks->qual,cnt)
  WITH nocounter
 ;end select
 IF (curqual > 0)
  SELECT INTO "nl"
   FROM encntr_loc_hist elh,
    task_activity ta
   PLAN (ta
    WHERE expand(idx,1,size(medtasks->qual,5),ta.task_type_cd,medtasks->qual[idx].task_type_cd)
     AND ta.task_status_cd=dcompletestat
     AND ta.task_dt_tm >= cnvtdatetime(request->start_dt_tm)
     AND ta.task_dt_tm <= cnvtdatetime(request->stop_dt_tm))
    JOIN (elh
    WHERE (elh.encntr_id=(ta.encntr_id+ 0))
     AND elh.beg_effective_dt_tm <= cnvtdatetime(request->stop_dt_tm)
     AND ((elh.end_effective_dt_tm+ 0) >= cnvtdatetime(request->start_dt_tm))
     AND expand(idx2,1,size(ipenctypes->qual,5),(elh.encntr_type_cd+ 0),ipenctypes->qual[idx2].
     encntr_type_cd)
     AND elh.active_ind=1
     AND ta.task_dt_tm BETWEEN elh.beg_effective_dt_tm AND elh.end_effective_dt_tm)
   ORDER BY elh.loc_facility_cd
   HEAD REPORT
    facilitycnt = 0
   HEAD elh.loc_facility_cd
    facilitycnt = (reply->facility_cnt+ 1), reply->facility_cnt = facilitycnt, stat = alterlist(reply
     ->facilities,facilitycnt),
    reply->facilities[facilitycnt].facility_cd = elh.loc_facility_cd
   FOOT  elh.loc_facility_cd
    positioncnt = (reply->facilities[facilitycnt].position_cnt+ 1), reply->facilities[facilitycnt].
    position_cnt = positioncnt, stat = alterlist(reply->facilities[facilitycnt].positions,positioncnt
     ),
    reply->facilities[facilitycnt].positions[positioncnt].position_cd = 0.0, reply->facilities[
    facilitycnt].positions[positioncnt].capability_in_use_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->facility_cnt = 1
  SET stat = alterlist(reply->facilities,1)
  SET reply->facilities[1].position_cnt = 1
  SET stat = alterlist(reply->facilities[1].positions,1)
  SET reply->facilities[1].positions[1].capability_in_use_ind = 0
 ENDIF
END GO
