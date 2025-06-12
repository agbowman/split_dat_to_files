CREATE PROGRAM cv_get_code_values_from_cdfmng:dba
 RECORD reply(
   1 qual[10]
     2 code_value = f8
     2 code_set = f8
     2 cdf_meaning = c12
     2 display = c50
     2 description = c100
     2 definition = c100
     2 collation_seq = i4
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SET nbr_to_get = cnvtint(size(request->qual,5))
 IF ((request->get_active=0))
  SELECT INTO "nl:"
   cv.code_value, cv.code_set, cv.cdf_meaning,
   cv.display, cv.description, cv.definition,
   cv.collation_seq, cv.active_ind
   FROM (dummyt d  WITH seq = value(nbr_to_get)),
    code_value cv
   PLAN (d)
    JOIN (cv
    WHERE (cv.code_set=request->code_set)
     AND (cv.cdf_meaning=request->qual[d.seq].cdf_meaning))
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1)
    IF (mod(count1,10)=2)
     stat = alter(reply->qual,(count1+ 10))
    ENDIF
    reply->qual[count1].code_value = cv.code_value, reply->qual[count1].code_set = cv.code_set, reply
    ->qual[count1].cdf_meaning = cv.cdf_meaning,
    reply->qual[count1].display = cv.display, reply->qual[count1].description = cv.description, reply
    ->qual[count1].definition = cv.definition,
    reply->qual[count1].collation_seq = cv.collation_seq, reply->qual[count1].active_ind = cv
    .active_ind
   WITH counter
  ;end select
 ELSE
  SELECT INTO "nl:"
   cv.code_value, cv.code_set, cv.cdf_meaning,
   cv.display, cv.description, cv.definition,
   cv.collation_seq, cv.active_ind
   FROM (dummyt d  WITH seq = value(nbr_to_get)),
    code_value cv
   PLAN (d)
    JOIN (cv
    WHERE (cv.code_set=request->code_set)
     AND (cv.cdf_meaning=request->qual[d.seq].cdf_meaning)
     AND cv.active_ind=1)
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1)
    IF (mod(count1,10)=2)
     stat = alter(reply->qual,(count1+ 10))
    ENDIF
    reply->qual[count1].code_value = cv.code_value, reply->qual[count1].code_set = cv.code_set, reply
    ->qual[count1].cdf_meaning = cv.cdf_meaning,
    reply->qual[count1].display = cv.display, reply->qual[count1].description = cv.description, reply
    ->qual[count1].definition = cv.definition,
    reply->qual[count1].collation_seq = cv.collation_seq, reply->qual[count1].active_ind = cv
    .active_ind
   WITH counter
  ;end select
 ENDIF
 IF (curqual != 0)
  SET reply->status_data.status = "S"
  SET stat = alter(reply->qual,count1)
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#stop
END GO
