CREATE PROGRAM dcp_get_template_ids
 RECORD reply(
   1 qual[*]
     2 task_assay_cd = f8
     2 label_template_id = f8
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
 DECLARE dta_cnt = i2 WITH noconstant(size(request->qual,5))
 DECLARE statreq = i4 WITH noconstant(0)
 DECLARE idx = i4 WITH noconstant(0)
 DECLARE ntotal = i4 WITH noconstant(0)
 DECLARE nreqsize = i4 WITH noconstant(0)
 DECLARE nexpandsize = i4 WITH constant(20)
 DECLARE nstart = i4 WITH noconstant(1)
 DECLARE count = i2 WITH noconstant(0)
 DECLARE nrepcnt = i2 WITH noconstant(0)
 DECLARE stat = i4 WITH noconstant(0)
 IF (((dta_cnt=0) OR (dta_cnt=null)) )
  GO TO exit_script
 ENDIF
 SET nreqsize = size(request->qual,5)
 SET ntotal = (nreqsize+ (nexpandsize - mod(nreqsize,nexpandsize)))
 SET statreq = alterlist(request->qual,ntotal)
 FOR (idx = (nreqsize+ 1) TO ntotal)
   SET request->qual[idx].task_assay_cd = request->qual[nreqsize].task_assay_cd
 ENDFOR
 SELECT INTO "nl:"
  dta.task_assay_cd, dta.label_template_id
  FROM discrete_task_assay dta,
   (dummyt d  WITH seq = value((1+ ((ntotal - 1)/ nexpandsize))))
  PLAN (d
   WHERE initarray(nstart,evaluate(d.seq,1,1,(nstart+ nexpandsize))))
   JOIN (dta
   WHERE expand(count,nstart,(nstart+ (nexpandsize - 1)),dta.task_assay_cd,request->qual[count].
    task_assay_cd)
    AND dta.active_ind=1)
  DETAIL
   nrepcnt = (nrepcnt+ 1)
   IF (mod(nrepcnt,10)=1)
    stat = alterlist(reply->qual,(nrepcnt+ 9))
   ENDIF
   reply->qual[nrepcnt].task_assay_cd = dta.task_assay_cd, reply->qual[nrepcnt].label_template_id =
   dta.label_template_id
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,nrepcnt)
#exit_script
 IF (nrepcnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
