CREATE PROGRAM dcp_get_catalog_event_sets:dba
 RECORD reply(
   1 cnt = i4
   1 qual[*]
     2 catalog_cd = f8
     2 sequence = i4
     2 event_set_name = vc
     2 event_set_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE last_mod = c3 WITH private, noconstant("000")
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE num = i4 WITH protect, noconstant(0)
 DECLARE start = i4 WITH protect, noconstant(1)
 DECLARE errmsg = vc WITH protect, noconstant(" ")
 DECLARE nsize = i4 WITH protect, constant(200)
 DECLARE ntotal2 = i4 WITH protect, constant(size(request->qual,5))
 DECLARE ntotal = i4 WITH protect, constant((ntotal2+ (nsize - mod(ntotal2,nsize))))
 SET stat = alterlist(request->qual,ntotal)
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
   catalog_event_sets ces,
   v500_event_set_code vs
  PLAN (d1
   WHERE initarray(start,evaluate(d1.seq,1,1,(start+ nsize))))
   JOIN (ces
   WHERE expand(num,start,(start+ (nsize - 1)),ces.catalog_cd,request->qual[num].catalog_cd)
    AND ces.catalog_cd > 0.0)
   JOIN (vs
   WHERE vs.event_set_name=ces.event_set_name)
  ORDER BY ces.sequence
  HEAD ces.event_set_name
   cnt += 1
   IF (cnt > size(reply->qual,5))
    stat = alterlist(reply->qual,(cnt+ 10))
   ENDIF
   reply->qual[cnt].catalog_cd = ces.catalog_cd, reply->qual[cnt].sequence = ces.sequence, reply->
   qual[cnt].event_set_cd = vs.event_set_cd,
   reply->qual[cnt].event_set_name = vs.event_set_name
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  SET reply->status_data.subeventstatus[1].operationname = "select"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "catalog_event_sets"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = errmsg
 ELSEIF (cnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET stat = alterlist(reply->qual,cnt)
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "006"
END GO
