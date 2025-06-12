CREATE PROGRAM cs_get_code_alias:dba
 RECORD reply(
   1 qual[*]
     2 code_value = f8
     2 display = c40
     2 cdf_meaning = c12
     2 cvprim_ind = i2
     2 cvactive_ind = i2
     2 alias_type_meaning = c12
     2 contributor_source_cd = f8
     2 contributor_source_disp = c40
     2 alias = c100
     2 code_set = f8
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
   cv.code_value, cv.display, cv.cdf_meaning,
   cv.active_ind, cva.alias_type_meaning, cva.contributor_source_cd,
   cva.alias, cva.code_set
   FROM (dummyt d  WITH seq = value(nbr_to_get)),
    code_value cv,
    code_value_alias cva
   PLAN (d)
    JOIN (cv
    WHERE (cv.code_set=request->qual[d.seq].code_set))
    JOIN (cva
    WHERE cva.code_value=cv.code_value
     AND cva.code_set=cv.code_set)
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1), stat = alterlist(reply->qual,count1), reply->qual[count1].code_value = cv
    .code_value,
    reply->qual[count1].display = cv.display, reply->qual[count1].cdf_meaning = cv.cdf_meaning, reply
    ->qual[count1].cvactive_ind = cv.active_ind,
    reply->qual[count1].alias_type_meaning = cva.alias_type_meaning, reply->qual[count1].
    contributor_source_cd = cva.contributor_source_cd, reply->qual[count1].alias = cva.alias,
    reply->qual[count1].code_set = cva.code_set
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   cv.code_value, cv.display, cv.cdf_meaning,
   cv.active_ind, cva.alias_type_meaning, cva.contributor_source_cd,
   cva.alias, cva.code_set
   FROM (dummyt d  WITH seq = value(nbr_to_get)),
    code_value cv,
    code_value_alias cva
   PLAN (d)
    JOIN (cv
    WHERE (cv.code_set=request->qual[d.seq].code_set)
     AND cv.active_ind=1)
    JOIN (cva
    WHERE cva.code_value=cv.code_value
     AND cva.code_set=cv.code_set)
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 = (count1+ 1), stat = alterlist(reply->qual,count1), reply->qual[count1].code_value = cv
    .code_value,
    reply->qual[count1].display = cv.display, reply->qual[count1].cdf_meaning = cv.cdf_meaning, reply
    ->qual[count1].cvactive_ind = cv.active_ind,
    reply->qual[count1].alias_type_meaning = cva.alias_type_meaning, reply->qual[count1].
    contributor_source_cd = cva.contributor_source_cd, reply->qual[count1].alias = cva.alias,
    reply->qual[count1].code_set = cva.code_set
   WITH nocounter
  ;end select
 ENDIF
 IF (count1 != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#stop
END GO
