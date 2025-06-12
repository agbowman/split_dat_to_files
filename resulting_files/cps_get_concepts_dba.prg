CREATE PROGRAM cps_get_concepts:dba
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 RECORD reply(
   1 item_cnt = i4
   1 concepts[*]
     2 concept_name = vc
     2 concept_identifier = c18
     2 concept_source_cd = f8
     2 concept_source_disp = c20
     2 concept_source_mean = c20
     2 data_status_cd = f8
     2 review_status_cd = f8
     2 active_status_cd = f8
     2 active_status_prsnl_id = f8
     2 data_status_prsnl_id = f8
     2 active_ind = i2
     2 active_status_dt_tm = dq8
     2 data_status_dt_tm = dq8
     2 beg_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[2]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 RECORD context(
   1 concept_name = vc
   1 concept_identifier = vc
   1 context_ind = i2
 )
 IF (validate(context->context_ind,0) != 0)
  SET continue = true
 ELSE
  SET continue = false
 ENDIF
 SET reply->status_data.status = "F"
 SET failed = false
 SET count1 = 0
 SET wcard = "*"
 SET op = fillstring(20," ")
 SET dhtable_name = fillstring(100," ")
 SET serrmsg_error = fillstring(100," ")
 SET searchstrname = fillstring(255," ")
 SET searchstrcode = fillstring(255," ")
 IF ((request->max_items > 0))
  SET max = request->max_items
 ELSE
  SET max = 100
 ENDIF
 SET stat = alterlist(reply->concepts,(max+ 1))
#again
 IF ((request->name_string > " "))
  SET searchstrname = build(request->name_string,wcard)
  SET count2 = 0
  SET done = false
  SELECT
   IF (continue=false)
    PLAN (c
     WHERE c.concept_name=patstring(searchstrname))
   ELSE
    PLAN (c
     WHERE (c.concept_name > context->concept_name))
   ENDIF
   INTO "NL:"
   c.concept_source_cd, c.concept_name, c.concept_identifier,
   c.data_status_cd, c.review_status_cd, c.active_status_cd,
   c.active_status_prsnl_id, c.data_status_prsnl_id, c.active_ind,
   c.active_status_dt_tm, c.data_status_dt_tm, c.beg_effective_dt_tm,
   c.end_effective_dt_tm
   FROM concept c
   DETAIL
    IF (count1 < max)
     count1 = (count1+ 1), count2 = (count2+ 1), reply->concepts[count1].concept_name = c
     .concept_name,
     reply->concepts[count1].concept_identifier = c.concept_identifier, reply->concepts[count1].
     concept_source_cd = c.concept_source_cd, reply->concepts[count1].data_status_cd = c
     .data_status_cd,
     reply->concepts[count1].review_status_cd = c.review_status_cd, reply->concepts[count1].
     active_ind = c.active_ind, reply->concepts[count1].active_status_prsnl_id = c
     .active_status_prsnl_id,
     reply->concepts[count1].data_status_prsnl_id = c.data_status_prsnl_id, reply->concepts[count1].
     active_status_cd = c.active_status_cd, reply->concepts[count1].active_status_dt_tm = c
     .active_status_dt_tm,
     reply->concepts[count1].data_status_dt_tm = c.data_status_dt_tm, reply->concepts[count1].
     beg_effective_dt_tm = c.beg_effective_dt_tm, reply->concepts[count1].end_effective_dt_tm = c
     .end_effective_dt_tm,
     context->concept_name = c.concept_name
     IF (count1=max)
      context->concept_name = c.concept_name, context->context_ind = (context->context_ind+ 1)
     ENDIF
    ENDIF
   WITH nocounter, maxqual(c,value(max))
  ;end select
 ELSE
  SET searchstrcode = build(cnvtupper(request->code_string),wcard)
  SET count2 = 0
  SET done = false
  SELECT
   IF (continue=false)
    PLAN (c
     WHERE c.concept_identifier=patstring(searchstrcode)
      AND (c.concept_source_cd=request->concept_source_cd))
   ELSE
    PLAN (c
     WHERE c.concept_identifier=patstring(searchstrcode)
      AND (c.concept_identifier > context->concept_identifier)
      AND (c.concept_source_cd=request->concept_source_cd))
   ENDIF
   INTO "NL:"
   c.concept_source_cd, c.concept_name, c.concept_identifier,
   c.data_status_cd, c.review_status_cd, c.active_status_cd,
   c.active_status_prsnl_id, c.data_status_prsnl_id, c.active_ind,
   c.active_status_dt_tm, c.data_status_dt_tm, c.beg_effective_dt_tm,
   c.end_effective_dt_tm
   FROM concept c
   DETAIL
    IF (count1 < max)
     count1 = (count1+ 1), count2 = (count2+ 1), reply->concepts[count1].concept_name = c
     .concept_name,
     reply->concepts[count1].concept_identifier = c.concept_identifier, reply->concepts[count1].
     concept_source_cd = c.concept_source_cd, reply->concepts[count1].data_status_cd = c
     .data_status_cd,
     reply->concepts[count1].review_status_cd = c.review_status_cd, reply->concepts[count1].
     active_ind = c.active_ind, reply->concepts[count1].active_status_prsnl_id = c
     .active_status_prsnl_id,
     reply->concepts[count1].data_status_prsnl_id = c.data_status_prsnl_id, reply->concepts[count1].
     active_status_cd = c.active_status_cd, reply->concepts[count1].active_status_dt_tm = c
     .active_status_dt_tm,
     reply->concepts[count1].data_status_dt_tm = c.data_status_dt_tm, reply->concepts[count1].
     beg_effective_dt_tm = c.beg_effective_dt_tm, reply->concepts[count1].end_effective_dt_tm = c
     .end_effective_dt_tm,
     context->concept_identifier = c.concept_identifier
     IF (count1=max)
      context->concept_identifier = c.concept_identifier, context->context_ind = (context->
      context_ind+ 1)
     ENDIF
    ENDIF
   WITH nocounter, maxqual(c,value(max))
  ;end select
 ENDIF
 IF (count2=0)
  SET done = true
 ENDIF
 IF (count1 < max
  AND done=false)
  SET continue = true
  GO TO again
 ELSE
  SET reply->item_cnt = count1
 ENDIF
 IF (count1=0)
  SET reply->status_data.status = "Z"
 ELSEIF (count1 > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
  SET dhtable_name = "CONCEPT"
  SET failed = select_error
  GO TO error_check
 ENDIF
#error_check
 IF (failed=false)
  SET reply->status_data.status = "S"
  IF (((op="UPDATE") OR (op="ADD")) )
   SET reqinfo->commit_ind = true
  ENDIF
 ELSE
  CASE (failed)
   OF select_error:
    SET reply->status_data.subeventstatus[1].operationname = "SELECT"
    SET reply->status_data.status = "Z"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
    SET reply->status_data.status = "Z"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
    SET reqinfo->commit_ind = false
    SET reply->status_data.status = "Z"
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_SEQ_NUM"
    SET reqinfo->commit_ind = false
    SET reply->status_data.status = "Z"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
    SET reply->status_data.status = "Z"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = dhtable_name
  SET reply->status_data.subeventstatus[2].targetobjectname = "CCL_ERROR"
  SET reply->status_data.subeventstatus[2].targetobjectvalue = serrmsg_error
  SET reply->status_data.subeventstatus[2].operationname = "RECEIVE"
  SET reply->status_data.subeventstatus[2].operationstatus = "S"
  SET reqinfo->commit_ind = false
  SET reply->status_data.status = "Z"
 ENDIF
END GO
