CREATE PROGRAM dcp_get_code_alias:dba
 RECORD reply(
   1 qual_cnt = i4
   1 qual[*]
     2 code_set = i4
     2 contributor_source_cd = f8
     2 alias = vc
     2 alias_type_meaning = vc
     2 primary_ind = i2
     2 code_value = f8
     2 collation_seq = i4
     2 cdf_meaning = vc
     2 display = vc
     2 display_key = vc
     2 description = vc
     2 definition = vc
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->qual_cnt = 0
 SET reply->status_data.status = "F"
 SET count = 0
 SET list_size = cnvtint(size(request->code_list,5))
 IF ((request->mode_flag=1))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(list_size)),
    code_value_alias cva,
    code_value cv
   PLAN (d)
    JOIN (cva
    WHERE (cva.code_set=request->code_list[d.seq].code_set)
     AND (cva.contributor_source_cd=request->code_list[d.seq].contributor_source_cd))
    JOIN (cv
    WHERE cv.code_value=cva.code_value)
   DETAIL
    count = (count+ 1)
    IF (mod(count,10)=1)
     stat = alterlist(reply->qual,(count+ 9))
    ENDIF
    reply->qual[count].code_set = cva.code_set, reply->qual[count].contributor_source_cd = cva
    .contributor_source_cd, reply->qual[count].alias = cva.alias,
    reply->qual[count].alias_type_meaning = cva.alias_type_meaning, reply->qual[count].code_value =
    cva.code_value, reply->qual[count].primary_ind = cva.primary_ind,
    reply->qual[count].cdf_meaning = cv.cdf_meaning, reply->qual[count].collation_seq = cv
    .collation_seq, reply->qual[count].display = cv.display,
    reply->qual[count].display_key = cv.display_key, reply->qual[count].description = cv.description,
    reply->qual[count].definition = cv.definition,
    reply->qual[count].active_ind = cv.active_ind
   WITH counter
  ;end select
 ELSEIF ((request->mode_flag=2))
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(list_size)),
    code_value_alias cva,
    code_value cv
   PLAN (d)
    JOIN (cva
    WHERE (cva.code_set=request->code_list[d.seq].code_set)
     AND (cva.contributor_source_cd=request->code_list[d.seq].contributor_source_cd)
     AND (cva.alias=request->code_list[d.seq].alias))
    JOIN (cv
    WHERE cva.code_value=cv.code_value)
   DETAIL
    count = (count+ 1)
    IF (mod(count,5)=1)
     stat = alterlist(reply->qual,(count+ 4))
    ENDIF
    reply->qual[count].code_set = cva.code_set, reply->qual[count].contributor_source_cd = cva
    .contributor_source_cd, reply->qual[count].alias = cva.alias,
    reply->qual[count].alias_type_meaning = cva.alias_type_meaning, reply->qual[count].code_value =
    cv.code_value, reply->qual[count].primary_ind = cva.primary_ind,
    reply->qual[count].cdf_meaning = cv.cdf_meaning, reply->qual[count].collation_seq = cv
    .collation_seq, reply->qual[count].display = cv.display,
    reply->qual[count].display_key = cv.display_key, reply->qual[count].description = cv.description,
    reply->qual[count].definition = cv.definition,
    reply->qual[count].active_ind = cv.active_ind
   WITH counter
  ;end select
 ELSE
  SELECT INTO "nl:"
   cva.*
   FROM (dummyt d  WITH seq = value(list_size)),
    code_value_alias cva,
    code_value cv
   PLAN (d)
    JOIN (cva
    WHERE (cva.code_set=request->code_list[d.seq].code_set)
     AND (cva.contributor_source_cd=request->code_list[d.seq].contributor_source_cd)
     AND (cva.code_value=request->code_list[d.seq].code_value))
    JOIN (cv
    WHERE cv.code_value=cva.code_value)
   DETAIL
    count = (count+ 1)
    IF (mod(count,5)=1)
     stat = alterlist(reply->qual,(count+ 4))
    ENDIF
    reply->qual[count].code_set = cva.code_set, reply->qual[count].contributor_source_cd = cva
    .contributor_source_cd, reply->qual[count].alias = cva.alias,
    reply->qual[count].alias_type_meaning = cva.alias_type_meaning, reply->qual[count].code_value =
    cva.code_value, reply->qual[count].primary_ind = cva.primary_ind,
    reply->qual[count].cdf_meaning = cv.cdf_meaning, reply->qual[count].collation_seq = cv
    .collation_seq, reply->qual[count].display = cv.display,
    reply->qual[count].display_key = cv.display_key, reply->qual[count].description = cv.description,
    reply->qual[count].definition = cv.definition,
    reply->qual[count].active_ind = cv.active_ind
   WITH counter
  ;end select
 ENDIF
 SET reply->qual_cnt = count
 SET stat = alterlist(reply->qual,count)
 CALL echo(build("cnt:",count))
 IF (curqual < 0)
  GO TO fail_script
 ELSE
  GO TO success_script
 ENDIF
#fail_script
 SET reply->status_data.subeventstatus[1].operationname = "select"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "CODE_VALUE"
 GO TO end_script
#success_script
 IF (curqual=0)
  SET reply->status_data.status = "Z"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
 ELSE
  SET reply->status_data.status = "S"
  SET reply->status_data.subeventstatus[1].operationstatus = "S"
 ENDIF
#end_script
END GO
