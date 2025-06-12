CREATE PROGRAM aps_get_cp_encntr:dba
 RECORD ap_encntr(
   1 encntr_list[*]
     2 encntr_id = f8
 )
 SET cnt = 0
 SET x = 0
 SET insertdirect = 0
 IF (size(cp_encntr->encntr_list,5)=0)
  SET insertdirect = 1
 ENDIF
 SELECT INTO "nl:"
  pc.encntr_id
  FROM code_value cv,
   case_report cr,
   pathology_case pc
  PLAN (cv
   WHERE cv.code_set=1305
    AND cv.cdf_meaning="ORDERED"
    AND cv.active_ind=1)
   JOIN (cr
   WHERE cr.updt_dt_tm >= cnvtdatetime(last_dist_run_dt_tm)
    AND cr.status_cd != cv.code_value
    AND cr.cancel_cd IN (0, null))
   JOIN (pc
   WHERE cr.case_id=pc.case_id
    AND pc.cancel_cd IN (0, null)
    AND pc.origin_flag=0)
  ORDER BY pc.encntr_id
  HEAD REPORT
   cnt = 0
  HEAD pc.encntr_id
   cnt = (cnt+ 1)
   IF (insertdirect=1)
    IF (mod(cnt,10)=1)
     stat = alterlist(cp_encntr->encntr_list,(cnt+ 9))
    ENDIF
    cp_encntr->encntr_list[cnt].encntr_id = pc.encntr_id
   ELSE
    IF (mod(cnt,10)=1)
     stat = alterlist(ap_encntr->encntr_list,(cnt+ 9))
    ENDIF
    ap_encntr->encntr_list[cnt].encntr_id = pc.encntr_id
   ENDIF
  FOOT REPORT
   IF (insertdirect=1)
    stat = alterlist(cp_encntr->encntr_list,cnt)
   ELSE
    stat = alterlist(ap_encntr->encntr_list,cnt)
   ENDIF
  WITH nocounter
 ;end select
 IF (insertdirect=0
  AND size(ap_encntr->encntr_list,5) > 0)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(size(ap_encntr->encntr_list,5))),
    (dummyt d  WITH seq = 1),
    (dummyt d2  WITH seq = value(size(cp_encntr->encntr_list,5)))
   PLAN (d1)
    JOIN (d
    WHERE 1=d.seq)
    JOIN (d2
    WHERE (ap_encntr->encntr_list[d1.seq].encntr_id=cp_encntr->encntr_list[d2.seq].encntr_id))
   HEAD REPORT
    cnt = size(cp_encntr->encntr_list,5), stat = alterlist(cp_encntr->encntr_list,(cnt+ 9))
   DETAIL
    cnt = (cnt+ 1)
    IF (mod(cnt,10)=1)
     stat = alterlist(cp_encntr->encntr_list,(cnt+ 9))
    ENDIF
    cp_encntr->encntr_list[cnt].encntr_id = ap_encntr->encntr_list[d1.seq].encntr_id
   FOOT REPORT
    stat = alterlist(cp_encntr->encntr_list,cnt)
   WITH nocounter, outerjoin = d, dontexist
  ;end select
 ENDIF
END GO
