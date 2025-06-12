CREATE PROGRAM dcp_get_event_cd:dba
 RECORD reply(
   1 qual[*]
     2 event_cd = f8
     2 parent_cd = f8
     2 flex1_cd = f8
     2 flex2_cd = f8
     2 flex3_cd = f8
     2 flex4_cd = f8
     2 flex5_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET count1 = 0
 SET reply->status_data.status = "F"
 SET nbr_to_get = cnvtint(size(request->qual,5))
 SELECT INTO "nl:"
  r.parent_cd, r.flex1_cd, r.flex2_cd,
  r.flex3_cd, r.flex4_cd, r.flex5_cd
  FROM (dummyt d  WITH seq = value(nbr_to_get)),
   code_value_event_r r
  PLAN (d)
   JOIN (r
   WHERE (r.parent_cd=request->qual[d.seq].parent_cd)
    AND (r.flex1_cd=request->qual[d.seq].flex1_cd)
    AND (r.flex2_cd=request->qual[d.seq].flex2_cd)
    AND (r.flex3_cd=request->qual[d.seq].flex3_cd)
    AND (r.flex4_cd=request->qual[d.seq].flex4_cd)
    AND (r.flex5_cd=request->qual[d.seq].flex5_cd))
  HEAD REPORT
   count1 = 0
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->qual,5))
    stat = alterlist(reply->qual,(count1+ 10))
   ENDIF
   reply->qual[count1].event_cd = r.event_cd, reply->qual[count1].parent_cd = r.parent_cd, reply->
   qual[count1].flex1_cd = r.flex1_cd,
   reply->qual[count1].flex2_cd = r.flex2_cd, reply->qual[count1].flex3_cd = r.flex3_cd, reply->qual[
   count1].flex4_cd = r.flex4_cd,
   reply->qual[count1].flex5_cd = r.flex5_cd
  FOOT REPORT
   stat = alterlist(reply->qual,count1)
  WITH check
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
