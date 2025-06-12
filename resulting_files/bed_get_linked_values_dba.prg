CREATE PROGRAM bed_get_linked_values:dba
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
 FREE RECORD simples
 RECORD simples(
   1 items[*]
     2 br_datamart_value_id = f8
 )
 FREE RECORD negations
 RECORD negations(
   1 items[*]
     2 br_datamart_value_id = f8
 )
 FREE RECORD blanks
 RECORD blanks(
   1 items[*]
     2 br_datamart_value_id = f8
 )
 FREE RECORD temp_results
 RECORD temp_results(
   1 items[*]
     2 br_datamart_value_id = f8
 )
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
 DECLARE negation_meaning = vc WITH protect, constant("NEGATION")
 DECLARE negation_type = f8 WITH protect
 DECLARE req_size = i4 WITH protect
 DECLARE rep_size = i4 WITH protect
 DECLARE simples_size = i4 WITH protect
 DECLARE blanks_size = i4 WITH protect
 DECLARE negations_size = i4 WITH protect
 DECLARE results_size = i4 WITH protect, noconstant(0)
 DECLARE index = i4 WITH protect
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET req_size = size(request->items,5)
 SET rep_size = 0
 IF (req_size=0)
  GO TO exit_script
 ENDIF
 SET negation_type = uar_get_code_by("MEANING",4002871,negation_meaning)
 SELECT INTO "nl:"
  FROM br_datamart_value v,
   (dummyt d  WITH seq = value(req_size))
  PLAN (d)
   JOIN (v
   WHERE (v.br_datamart_value_id=request->items[d.seq].br_datamart_value_id))
  ORDER BY v.br_datamart_value_id
  HEAD v.br_datamart_value_id
   IF (v.map_data_type_cd != negation_type
    AND v.map_data_type_cd != 0)
    simples_size = (simples_size+ 1), stat = alterlist(simples->items,simples_size), simples->items[
    simples_size].br_datamart_value_id = v.br_datamart_value_id
   ELSEIF (v.map_data_type_cd=negation_type)
    negations_size = (negations_size+ 1), stat = alterlist(negations->items,negations_size),
    negations->items[negations_size].br_datamart_value_id = v.br_datamart_value_id
   ELSEIF (v.map_data_type_cd=0)
    blanks_size = (blanks_size+ 1), stat = alterlist(blanks->items,blanks_size), blanks->items[
    blanks_size].br_datamart_value_id = v.br_datamart_value_id
   ENDIF
   results_size = (results_size+ 1), stat = alterlist(temp_results->items,results_size), temp_results
   ->items[results_size].br_datamart_value_id = v.br_datamart_value_id
  WITH nocounter
 ;end select
 CALL bederrorcheck("SEL br_datamart_value (input split up)")
 IF (simples_size > 0)
  SELECT INTO "nl:"
   FROM br_datamart_value v,
    br_datamart_value v2,
    (dummyt d  WITH seq = value(simples_size))
   PLAN (d)
    JOIN (v
    WHERE (v.br_datamart_value_id=simples->items[d.seq].br_datamart_value_id))
    JOIN (v2
    WHERE v2.br_datamart_category_id=v.br_datamart_category_id
     AND v2.br_datamart_filter_id=v.br_datamart_filter_id
     AND v2.parent_entity_id=v.parent_entity_id
     AND v2.parent_entity_name=v.parent_entity_name
     AND v2.map_data_type_cd=negation_type)
   DETAIL
    results_size = (results_size+ 1), stat = alterlist(temp_results->items,results_size),
    temp_results->items[results_size].br_datamart_value_id = v2.br_datamart_value_id
   WITH nocounter
  ;end select
  CALL bederrorcheck("SEL br_datamart_value (Negations from simples)")
 ENDIF
 IF (negations_size > 0)
  SELECT INTO "nl:"
   FROM br_datamart_value v,
    br_datamart_value v2,
    (dummyt d  WITH seq = value(negations_size))
   PLAN (d)
    JOIN (v
    WHERE (v.br_datamart_value_id=negations->items[d.seq].br_datamart_value_id))
    JOIN (v2
    WHERE v2.br_datamart_category_id=v.br_datamart_category_id
     AND v2.br_datamart_filter_id=v.br_datamart_filter_id
     AND v2.parent_entity_id=v.parent_entity_id
     AND v2.parent_entity_name=v.parent_entity_name
     AND  NOT (v2.map_data_type_cd IN (0, negation_type)))
   DETAIL
    results_size = (results_size+ 1), stat = alterlist(temp_results->items,results_size),
    temp_results->items[results_size].br_datamart_value_id = v2.br_datamart_value_id
   WITH nocounter
  ;end select
  CALL bederrorcheck("SEL br_datamart_value (simples from negations)")
 ENDIF
 IF (negations_size > 0)
  SELECT INTO "nl:"
   FROM br_datamart_value v,
    br_datamart_value v2,
    (dummyt d  WITH seq = value(negations_size))
   PLAN (d)
    JOIN (v
    WHERE (v.br_datamart_value_id=negations->items[d.seq].br_datamart_value_id))
    JOIN (v2
    WHERE v2.br_datamart_category_id=v.br_datamart_category_id
     AND v2.br_datamart_filter_id=v.br_datamart_filter_id
     AND v2.value_seq=v.value_seq
     AND v2.map_data_type_cd=0)
   DETAIL
    results_size = (results_size+ 1), stat = alterlist(temp_results->items,results_size),
    temp_results->items[results_size].br_datamart_value_id = v2.br_datamart_value_id
   WITH nocounter
  ;end select
  CALL bederrorcheck("SEL br_datamart_value (blanks from negations)")
 ENDIF
 IF (simples_size > 0)
  SELECT INTO "nl:"
   FROM br_datamart_value v,
    br_datamart_value v2,
    (dummyt d  WITH seq = value(simples_size))
   PLAN (d)
    JOIN (v
    WHERE (v.br_datamart_value_id=simples->items[d.seq].br_datamart_value_id))
    JOIN (v2
    WHERE v2.br_datamart_category_id=v.br_datamart_category_id
     AND v2.br_datamart_filter_id=v.br_datamart_filter_id
     AND v2.value_seq=v.value_seq
     AND v2.map_data_type_cd=0)
   DETAIL
    results_size = (results_size+ 1), stat = alterlist(temp_results->items,results_size),
    temp_results->items[results_size].br_datamart_value_id = v2.br_datamart_value_id
   WITH nocounter
  ;end select
  CALL bederrorcheck("SEL br_datamart_value (blanks and negations from simples)")
 ENDIF
 IF (blanks_size > 0)
  SELECT INTO "nl:"
   FROM br_datamart_value v,
    br_datamart_value v2,
    (dummyt d  WITH seq = value(blanks_size))
   PLAN (d)
    JOIN (v
    WHERE (v.br_datamart_value_id=blanks->items[d.seq].br_datamart_value_id))
    JOIN (v2
    WHERE v2.br_datamart_category_id=v.br_datamart_category_id
     AND v2.br_datamart_filter_id=v.br_datamart_filter_id
     AND v2.value_seq=v.value_seq
     AND v2.map_data_type_cd != 0)
   DETAIL
    results_size = (results_size+ 1), stat = alterlist(temp_results->items,results_size),
    temp_results->items[results_size].br_datamart_value_id = v2.br_datamart_value_id
   WITH nocounter
  ;end select
  CALL bederrorcheck("SEL br_datamart_value (negations and simples from blanks)")
 ENDIF
 IF (results_size > 0)
  SELECT INTO "nl:"
   x = temp_results->items[d.seq].br_datamart_value_id
   FROM (dummyt d  WITH seq = value(results_size))
   PLAN (d)
   ORDER BY x
   HEAD x
    rep_size = (rep_size+ 1), stat = alterlist(reply->items,rep_size), reply->items[rep_size].
    br_datamart_value_id = x
   WITH nocounter
  ;end select
 ENDIF
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
