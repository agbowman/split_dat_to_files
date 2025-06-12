CREATE PROGRAM dcp_get_wv_dtas
 RECORD reply(
   1 qual[*]
     2 event_cd = f8
     2 task_assay_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET modify = predeclare
 DECLARE count1 = i2 WITH noconstant(0)
 DECLARE ec_cnt = i2 WITH noconstant(size(request->qual,5))
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE idx = i4
 DECLARE ntotal2 = i4
 DECLARE nsize = i4 WITH constant(50)
 DECLARE nstart = i4
 IF (((ec_cnt=0) OR (ec_cnt=null)) )
  GO TO exit_script
 ENDIF
 DECLARE prev_event_cd = f8 WITH noconstant(0.0)
 DECLARE prev_dta = f8 WITH noconstant(0.0)
 DECLARE count = i2 WITH noconstant(0)
 DECLARE needresize = i2 WITH noconstant(0)
 DECLARE iterations = i4 WITH noconstant(0)
 DECLARE total_items = i4 WITH noconstant(0)
 SET nstart = 1
 SET ntotal2 = size(request->qual,5)
 SET iterations = ceil(((ntotal2 * 1.0)/ nsize))
 SET total_items = (iterations * nsize)
 IF (total_items > ntotal2)
  SET stat = alterlist(request->qual,total_items)
  FOR (idx = (ntotal2+ 1) TO total_items)
    SET request->qual[idx].event_cd = request->qual[ntotal2].event_cd
  ENDFOR
 ENDIF
 SELECT INTO "nl:"
  dta.task_assay_cd, dta.event_cd
  FROM discrete_task_assay dta,
   (dummyt d  WITH seq = value(iterations))
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nsize))))
   JOIN (dta
   WHERE expand(count,nstart,(nstart+ (nsize - 1)),dta.event_cd,request->qual[count].event_cd)
    AND dta.active_ind=1)
  ORDER BY dta.event_cd
  DETAIL
   IF (dta.event_cd=prev_event_cd)
    IF (count1 > 0)
     IF ((reply->qual[count1].event_cd=prev_event_cd))
      IF ((reply->qual[count1].task_assay_cd != prev_dta))
       stat = alterlist(reply->qual,(count1 - 1)), needresize = 1, count1 = (count1 - 1)
      ENDIF
     ENDIF
    ENDIF
    prev_event_cd = dta.event_cd, prev_dta = dta.task_assay_cd
   ELSE
    count1 = (count1+ 1), prev_event_cd = dta.event_cd, prev_dta = dta.task_assay_cd
    IF (((needresize=1) OR (mod(count1,10)=1)) )
     stat = alterlist(reply->qual,(count1+ 9)), needresize = 0
    ENDIF
    reply->qual[count1].event_cd = dta.event_cd, reply->qual[count1].task_assay_cd = dta
    .task_assay_cd
   ENDIF
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,count1)
#exit_script
 IF (count1 > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
END GO
