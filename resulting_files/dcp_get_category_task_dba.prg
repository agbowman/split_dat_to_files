CREATE PROGRAM dcp_get_category_task:dba
 RECORD reply(
   1 qual_cnt = i4
   1 qual[*]
     2 synonym_id = f8
     2 sequence = i4
     2 mnemonic = vc
     2 active_ind = i2
     2 alt_sel_category_id = f8
     2 list_type = i4
     2 child_alt_sel_cat_id = f8
     2 child_cat_ind = i2
     2 catalog_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET ncnt = 0
 SET reply->qual_cnt = 0
 SET reply->status_data.status = "F"
 IF ((request->honor_task_security_flag > 0))
  SELECT INTO "nl:"
   FROM alt_sel_list a,
    order_task ot,
    alt_sel_cat
   PLAN (a
    WHERE (a.alt_sel_category_id=request->alt_sel_category_id)
     AND ((a.list_type=1) OR (a.list_type=4)) )
    JOIN (ot
    WHERE ot.reference_task_id=a.reference_task_id
     AND ((ot.reference_task_id=0) OR (ot.active_ind=1
     AND ((ot.allpositionchart_ind=1) OR (ot.reference_task_id IN (
    (SELECT
     otpx.reference_task_id
     FROM order_task_position_xref otpx
     WHERE (otpx.position_cd=reqinfo->position_cd))))) )) )
    JOIN (alt_sel_cat
    WHERE alt_sel_cat.alt_sel_category_id=a.child_alt_sel_cat_id)
   ORDER BY a.sequence
   HEAD REPORT
    ncnt = 0
   DETAIL
    ncnt = (ncnt+ 1)
    IF (((ncnt=1) OR (size(reply->qual,5) > ncnt)) )
     stat = alterlist(reply->qual,(ncnt+ 10))
    ENDIF
    reply->qual[ncnt].alt_sel_category_id = a.alt_sel_category_id, reply->qual[ncnt].sequence = a
    .sequence, reply->qual[ncnt].list_type = a.list_type,
    reply->qual[ncnt].child_alt_sel_cat_id = a.child_alt_sel_cat_id, reply->qual[ncnt].child_cat_ind
     = alt_sel_cat.child_cat_ind
    IF (a.list_type=1)
     reply->qual[ncnt].mnemonic = alt_sel_cat.short_description, reply->qual[ncnt].child_cat_ind =
     alt_sel_cat.child_cat_ind
    ENDIF
    IF (a.list_type=4
     AND ot.dcp_forms_ref_id > 0)
     reply->qual[ncnt].mnemonic = trim(ot.task_description), reply->qual[ncnt].active_ind = ot
     .active_ind, reply->qual[ncnt].catalog_cd = ot.reference_task_id,
     reply->qual[ncnt].synonym_id = ot.reference_task_id
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM alt_sel_list a,
    order_task ot,
    alt_sel_cat
   PLAN (a
    WHERE (a.alt_sel_category_id=request->alt_sel_category_id)
     AND ((a.list_type=1) OR (a.list_type=4)) )
    JOIN (ot
    WHERE ot.reference_task_id=a.reference_task_id
     AND ((ot.reference_task_id=0) OR (ot.active_ind=1)) )
    JOIN (alt_sel_cat
    WHERE alt_sel_cat.alt_sel_category_id=a.child_alt_sel_cat_id)
   ORDER BY a.sequence
   HEAD REPORT
    ncnt = 0
   DETAIL
    ncnt = (ncnt+ 1)
    IF (((ncnt=1) OR (size(reply->qual,5) > ncnt)) )
     stat = alterlist(reply->qual,(ncnt+ 10))
    ENDIF
    reply->qual[ncnt].alt_sel_category_id = a.alt_sel_category_id, reply->qual[ncnt].sequence = a
    .sequence, reply->qual[ncnt].list_type = a.list_type,
    reply->qual[ncnt].child_alt_sel_cat_id = a.child_alt_sel_cat_id, reply->qual[ncnt].child_cat_ind
     = alt_sel_cat.child_cat_ind
    IF (a.list_type=1)
     reply->qual[ncnt].mnemonic = alt_sel_cat.short_description, reply->qual[ncnt].child_cat_ind =
     alt_sel_cat.child_cat_ind
    ENDIF
    IF (a.list_type=4
     AND ot.dcp_forms_ref_id > 0)
     reply->qual[ncnt].mnemonic = trim(ot.task_description), reply->qual[ncnt].active_ind = ot
     .active_ind, reply->qual[ncnt].catalog_cd = ot.reference_task_id,
     reply->qual[ncnt].synonym_id = ot.reference_task_id
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->qual_cnt = ncnt
  SET reply->status_data.status = "S"
  SET stat = alterlist(reply->qual,ncnt)
 ENDIF
 CALL echorecord(reply)
END GO
