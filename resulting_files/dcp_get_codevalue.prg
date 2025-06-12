CREATE PROGRAM dcp_get_codevalue
 RECORD reply(
   1 code_value = f8
   1 code_set = i4
   1 display = c40
   1 display_key = c40
   1 description = c60
   1 definition = c100
   1 cdf_meaning = c12
   1 collation_seq = i4
   1 active_ind = i2
   1 updt_cnt = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "F"
 IF ((request->code_value > 0))
  SELECT INTO "nl:"
   c.code_value, c.code_set, c.display,
   c.display_key, c.description, c.definition,
   c.cdf_meaning, c.collation_seq, c.active_ind,
   c.updt_cnt
   FROM code_value c
   WHERE (c.code_value=request->code_value)
   DETAIL
    reply->code_value = c.code_value, reply->code_set = c.code_set, reply->display = c.display,
    reply->display_key = c.display_key, reply->description = c.description, reply->definition = c
    .definition,
    reply->cdf_meaning = c.cdf_meaning, reply->collation_seq = c.collation_seq, reply->active_ind = c
    .active_ind,
    reply->updt_cnt = c.updt_cnt
   WITH nocounter
  ;end select
 ELSE
  IF ((request->code_set > 0))
   SELECT INTO "nl:"
    c.code_value, c.code_set, c.display,
    c.display_key, c.description, c.definition,
    c.cdf_meaning, c.collation_seq, c.active_ind,
    c.updt_cnt
    FROM code_value c
    WHERE (c.code_set=request->code_set)
     AND (c.cdf_meaning=request->meaning)
    DETAIL
     reply->code_value = c.code_value, reply->code_set = c.code_set, reply->display = c.display,
     reply->display_key = c.display_key, reply->description = c.description, reply->definition = c
     .definition,
     reply->cdf_meaning = c.cdf_meaning, reply->collation_seq = c.collation_seq, reply->active_ind =
     c.active_ind,
     reply->updt_cnt = c.updt_cnt
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
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
