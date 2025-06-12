CREATE PROGRAM bbt_get_interp_results:dba
 RECORD reply(
   1 qual[*]
     2 interp_result_id = f8
     2 result_nomenclature_id = f8
     2 result_nomenclature_disp = vc
     2 result_cd = f8
     2 result_cd_disp = vc
     2 hash_pattern = vc
     2 result_text = vc
     2 updt_cnt = i4
     2 long_text_id = f8
     2 text_updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 IF ((request->text_ind=2)
  AND (request->alpha_ind=2))
  SELECT INTO "nl:"
   ir.*
   FROM interp_result ir,
    (dummyt d  WITH seq = 1),
    (dummyt d2  WITH seq = 1),
    long_text_reference l,
    nomenclature n
   PLAN (ir
    WHERE (ir.interp_id=request->interp_id)
     AND ir.active_ind=1)
    JOIN (d
    WHERE d.seq=1)
    JOIN (l
    WHERE l.long_text_id=ir.long_text_id
     AND l.parent_entity_name="INTERP_RESULT"
     AND l.active_ind=1)
    JOIN (d2
    WHERE d2.seq=1)
    JOIN (n
    WHERE n.nomenclature_id=ir.result_nomenclature_id)
   DETAIL
    count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].interp_result_id = ir
    .interp_result_id,
    reply->qual[count].result_nomenclature_id = ir.result_nomenclature_id, reply->qual[count].
    result_nomenclature_disp = n.mnemonic, reply->qual[count].result_cd = ir.result_cd,
    reply->qual[count].hash_pattern = ir.hash_pattern
    IF (l.long_text_id=0)
     reply->qual[count].result_text = ""
    ELSE
     reply->qual[count].result_text = l.long_text
    ENDIF
    reply->qual[count].text_updt_cnt = l.updt_cnt, reply->qual[count].long_text_id = l.long_text_id,
    reply->qual[count].updt_cnt = ir.updt_cnt
   WITH counter, outerjoin = d2, outerjoin = d,
    dontcare = l
  ;end select
 ELSEIF ((request->text_ind=1)
  AND (request->alpha_ind=1))
  SELECT INTO "nl:"
   ir.*
   FROM interp_result ir,
    long_text_reference l,
    nomenclature n
   PLAN (ir
    WHERE (ir.interp_id=request->interp_id)
     AND ir.active_ind=1)
    JOIN (l
    WHERE l.long_text_id=ir.long_text_id
     AND l.parent_entity_name="INTERP_RESULT"
     AND l.active_ind=1)
    JOIN (n
    WHERE n.nomenclature_id=ir.result_nomenclature_id)
   ORDER BY ir.interp_result_id
   DETAIL
    count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].interp_result_id = ir
    .interp_result_id,
    reply->qual[count].result_nomenclature_id = ir.result_nomenclature_id, reply->qual[count].
    result_nomenclature_disp = n.mnemonic, reply->qual[count].result_cd = ir.result_cd,
    reply->qual[count].hash_pattern = ir.hash_pattern
    IF (l.long_text_id=0)
     reply->qual[count].result_text = ""
    ELSE
     reply->qual[count].result_text = l.long_text
    ENDIF
    reply->qual[count].text_updt_cnt = l.updt_cnt, reply->qual[count].long_text_id = l.long_text_id,
    reply->qual[count].updt_cnt = ir.updt_cnt
   WITH counter
  ;end select
 ELSEIF ((request->text_ind=1)
  AND (request->alpha_ind=0))
  SELECT INTO "nl:"
   ir.*
   FROM interp_result ir,
    long_text_reference l
   PLAN (ir
    WHERE (ir.interp_id=request->interp_id)
     AND ir.active_ind=1)
    JOIN (l
    WHERE l.long_text_id=ir.long_text_id
     AND l.parent_entity_name="INTERP_RESULT"
     AND l.active_ind=1)
   ORDER BY ir.interp_result_id
   DETAIL
    count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].interp_result_id = ir
    .interp_result_id,
    reply->qual[count].result_nomenclature_id = ir.result_nomenclature_id, reply->qual[count].
    result_nomenclature_disp = "", reply->qual[count].result_cd = ir.result_cd,
    reply->qual[count].hash_pattern = ir.hash_pattern
    IF (l.long_text_id=0)
     reply->qual[count].result_text = ""
    ELSE
     reply->qual[count].result_text = l.long_text
    ENDIF
    reply->qual[count].text_updt_cnt = l.updt_cnt, reply->qual[count].long_text_id = l.long_text_id,
    reply->qual[count].updt_cnt = ir.updt_cnt
   WITH counter
  ;end select
 ELSEIF ((request->text_ind=0)
  AND (request->alpha_ind=1))
  SELECT INTO "nl:"
   ir.*
   FROM interp_result ir,
    nomenclature n
   PLAN (ir
    WHERE (ir.interp_id=request->interp_id)
     AND ir.active_ind=1)
    JOIN (n
    WHERE n.nomenclature_id=ir.result_nomenclature_id)
   ORDER BY ir.interp_result_id
   DETAIL
    count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].interp_result_id = ir
    .interp_result_id,
    reply->qual[count].result_nomenclature_id = ir.result_nomenclature_id, reply->qual[count].
    result_nomenclature_disp = n.mnemonic, reply->qual[count].result_cd = ir.result_cd,
    reply->qual[count].hash_pattern = ir.hash_pattern, reply->qual[count].result_text = "", reply->
    qual[count].text_updt_cnt = 0,
    reply->qual[count].long_text_id = 0, reply->qual[count].updt_cnt = ir.updt_cnt
   WITH counter
  ;end select
 ELSE
  SELECT INTO "nl:"
   ir.*
   FROM interp_result ir
   PLAN (ir
    WHERE (ir.interp_id=request->interp_id)
     AND ir.active_ind=1)
   ORDER BY ir.interp_result_id
   DETAIL
    count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].interp_result_id = ir
    .interp_result_id,
    reply->qual[count].result_nomenclature_id = ir.result_nomenclature_id, reply->qual[count].
    result_nomenclature_disp = "", reply->qual[count].result_cd = ir.result_cd,
    reply->qual[count].hash_pattern = ir.hash_pattern, reply->qual[count].result_text = "", reply->
    qual[count].text_updt_cnt = 0,
    reply->qual[count].long_text_id = 0, reply->qual[count].updt_cnt = ir.updt_cnt
   WITH counter
  ;end select
 ENDIF
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
