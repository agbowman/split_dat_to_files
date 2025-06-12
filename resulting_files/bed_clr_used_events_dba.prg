CREATE PROGRAM bed_clr_used_events:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 items[*]
      2 br_datamart_value_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE RECORD filtered_values
 RECORD filtered_values(
   1 items[*]
     2 br_datamart_value_id = f8
 )
 DECLARE dta_meaning = vc WITH protect, constant("DTA_ALPHA")
 DECLARE event_meaning = vc WITH protect, constant("EVENT_ALPHA")
 DECLARE negation_meaning = vc WITH protect, constant("NEGATION")
 DECLARE dta_type = f8 WITH protect
 DECLARE event_type = f8 WITH protect
 DECLARE negation_type = f8 WITH protect
 DECLARE req_size = i4 WITH protect
 DECLARE rep_size = i4 WITH protect, noconstant(0)
 DECLARE filtered_count = i4 WITH protect, noconstant(0)
 DECLARE index = i4 WITH protect
 DECLARE ind = i4 WITH protect
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 SET req_size = size(request->items,5)
 IF (req_size < 1)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4002871
   AND cv.cdf_meaning=dta_meaning
  DETAIL
   dta_type = cv.code_value
  WITH noconstant
 ;end select
 CALL bederrorcheck("Failed to select a row from code_value table")
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4002871
   AND cv.cdf_meaning=event_meaning
  DETAIL
   event_type = cv.code_value
  WITH noconstant
 ;end select
 CALL bederrorcheck("Failed to select a row from code_value table")
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=4002871
   AND cv.cdf_meaning=negation_meaning
  DETAIL
   negation_type = cv.code_value
  WITH noconstant
 ;end select
 CALL bederrorcheck("Failed to select a row from code_value table")
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_size)),
   br_datamart_value v1,
   br_datamart_value v2
  PLAN (d)
   JOIN (v1
   WHERE (v1.br_datamart_value_id=request->items[d.seq].br_datamart_value_id)
    AND v1.map_data_type_cd=0)
   JOIN (v2
   WHERE v2.br_datamart_category_id=v1.br_datamart_category_id
    AND v2.br_datamart_filter_id=v1.br_datamart_filter_id
    AND v2.value_seq=v1.value_seq
    AND v2.map_data_type_cd != 0
    AND  NOT (expand(ind,1,req_size,v2.br_datamart_value_id,request->items[ind].br_datamart_value_id)
   ))
  HEAD v1.br_datamart_value_id
   filtered_count = (filtered_count+ 1), stat = alterlist(filtered_values->items,filtered_count),
   filtered_values->items[filtered_count].br_datamart_value_id = request->items[d.seq].
   br_datamart_value_id
  WITH nocounter
 ;end select
 CALL bederrorcheck("SEL br_datamart_value (checking for dependants)")
 FOR (index = 1 TO req_size)
   IF (locateval(ind,1,filtered_count,request->items[index].br_datamart_value_id,filtered_values->
    items[ind].br_datamart_value_id) < 1)
    SET rep_size = (rep_size+ 1)
    SET stat = alterlist(reply->items,rep_size)
    SET reply->items[rep_size].br_datamart_value_id = request->items[index].br_datamart_value_id
   ENDIF
 ENDFOR
 CALL echorecord(reply)
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
