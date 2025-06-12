CREATE PROGRAM bbd_get_multiple_codes:dba
 RECORD reply(
   1 qual[*]
     2 code_set = i4
     2 code_value = f8
     2 display = c40
     2 cdf_meaning = c12
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET val_count = 0
 SET cvcount = size(request->codesetlist,5)
 SELECT INTO "nl:"
  cv.code_value, cv.code_set, cv.display,
  cv.cdf_meaning
  FROM code_value cv,
   (dummyt d1  WITH seq = value(cvcount))
  PLAN (d1)
   JOIN (cv
   WHERE (cv.code_set=request->codesetlist[d1.seq].code_set)
    AND cv.active_ind=1
    AND cv.code_value != null
    AND cv.code_value > 0)
  DETAIL
   val_count = (val_count+ 1), stat = alterlist(reply->qual,val_count), reply->qual[val_count].
   code_set = cv.code_set,
   reply->qual[val_count].code_value = cv.code_value, reply->qual[val_count].display = cv.display,
   reply->qual[val_count].cdf_meaning = cv.cdf_meaning
  WITH nocounter
 ;end select
 IF (val_count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
