CREATE PROGRAM dcp_get_code_value_group:dba
 RECORD reply(
   1 qual_cnt = i4
   1 qual[*]
     2 parent_code_value = f8
     2 child_qual[*]
       3 child_code_value = f8
       3 cdf_meaning = vc
       3 display = vc
       3 display_key = vc
       3 description = vc
       3 definition = vc
       3 child_code_set = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->qual_cnt = 0
 SET failed = "F"
 SET parent_count = 0
 SET child_count = 0
 SET list_count = cnvtint(size(request->parent_list,5))
 SELECT INTO "nl:"
  cvg.parent_code_value, cvg.child_code_value, cv.cdf_meaning,
  cv.display
  FROM (dummyt d1  WITH seq = value(list_count)),
   code_value_group cvg,
   code_value cv
  PLAN (d1)
   JOIN (cvg
   WHERE (cvg.parent_code_value=request->parent_list[d1.seq].parent_code_value)
    AND (cvg.code_set=request->parent_list[d1.seq].code_set))
   JOIN (cv
   WHERE cv.code_value=cvg.child_code_value
    AND cv.code_set=cvg.code_set
    AND cv.active_ind=1)
  ORDER BY cv.collation_seq
  HEAD cvg.parent_code_value
   parent_count = (parent_count+ 1), child_count = 0
   IF (parent_count > size(reply->qual,5))
    stat = alterlist(reply->qual,(parent_count+ 5))
   ENDIF
   reply->qual[parent_count].parent_code_value = cvg.parent_code_value
  DETAIL
   child_count = (child_count+ 1)
   IF (child_count > size(reply->qual[parent_count].child_qual,5))
    stat = alterlist(reply->qual[parent_count].child_qual,(child_count+ 5))
   ENDIF
   reply->qual[parent_count].child_qual[child_count].child_code_value = cv.code_value, reply->qual[
   parent_count].child_qual[child_count].cdf_meaning = cv.cdf_meaning, reply->qual[parent_count].
   child_qual[child_count].display = cv.display,
   reply->qual[parent_count].child_qual[child_count].display_key = cv.display_key, reply->qual[
   parent_count].child_qual[child_count].description = cv.description, reply->qual[parent_count].
   child_qual[child_count].definition = cv.definition,
   reply->qual[parent_count].child_qual[child_count].child_code_set = cv.code_set
  FOOT  cvg.parent_code_value
   stat = alterlist(reply->qual[parent_count].child_qual,child_count)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SET reply->qual_cnt = parent_count
 SET stat = alterlist(reply->qual,parent_count)
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationname = "READ"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "CODE_VALUE_GROUP TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "UNABLE TO READ"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
