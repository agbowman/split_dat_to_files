CREATE PROGRAM bsc_get_order_info_from_task:dba
 SET modify = predeclare
 RECORD reply(
   1 task_list[*]
     2 task_id = f8
     2 order_id = f8
     2 template_order_id = f8
     2 task_type_cd = f8
     2 med_order_type_cd = f8
     2 catalog_type_cd = f8
     2 task_description = vc
     2 order_mnemonic = vc
     2 hna_order_mnemonic = vc
     2 ordered_as_mnemonic = vc
     2 ingred_list[*]
       3 event_cd = f8
       3 ingredient_type_flag = i2
       3 last_admin_disp_basis_flag = i2
       3 med_interval_warn_flag = i2
       3 order_mnemonic = vc
       3 hna_order_mnemonic = vc
       3 ordered_as_mnemonic = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD struct(
   1 parent_qual[*]
     2 order_id = f8
     2 last_action_sequence = i4
   1 child_qual[*]
     2 template_order_id = f8
     2 template_core_action_sequence = i4
 )
 DECLARE request_size = i4 WITH protect, noconstant(0)
 SET request_size = size(request->qual,5)
 DECLARE parent_size = i4 WITH protect, noconstant(0)
 SET parent_size = size(struct->parent_qual,5)
 DECLARE child_size = i4 WITH protect, noconstant(0)
 SET child_size = size(struct->child_qual,5)
 DECLARE task_cnt = i4 WITH protect, noconstant(0)
 DECLARE ingred_cnt = i4 WITH protect, noconstant(0)
 DECLARE qual_cnt = i4 WITH protect, noconstant(0)
 DECLARE parent_cnt = i4 WITH protect, noconstant(0)
 DECLARE child_cnt = i4 WITH protect, noconstant(0)
 DECLARE x = i4 WITH protect, noconstant(0)
 DECLARE nstart = i4 WITH protect, noconstant(1)
 DECLARE nsize = i4 WITH protect, constant(20)
 DECLARE ntotal = i4 WITH protect, noconstant((ceil((cnvtreal(request_size)/ nsize)) * nsize))
 DECLARE stat = i4 WITH public, noconstant(0.0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE last_mod = c3 WITH private, noconstant("")
 SET stat = alterlist(request->qual,ntotal)
 FOR (i = request_size TO ntotal)
   SET request->qual[i].task_id = request->qual[request_size].task_id
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d1  WITH seq = value((1+ ((ntotal - 1)/ nsize)))),
   task_activity ta,
   order_task ot,
   orders o
  PLAN (d1
   WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
   JOIN (ta
   WHERE expand(x,nstart,(nstart+ (nsize - 1)),ta.task_id,request->qual[x].task_id))
   JOIN (ot
   WHERE ot.reference_task_id=ta.reference_task_id)
   JOIN (o
   WHERE o.order_id=ta.order_id)
  HEAD REPORT
   task_cnt = 0, parent_cnt = 0, child_cnt = 0
  HEAD ta.task_id
   task_cnt = (task_cnt+ 1)
   IF (task_cnt > size(reply->task_list,5))
    stat = alterlist(reply->task_list,(task_cnt+ 19))
   ENDIF
   reply->task_list[task_cnt].task_id = ta.task_id, reply->task_list[task_cnt].order_id = ta.order_id,
   reply->task_list[task_cnt].template_order_id = o.template_order_id,
   reply->task_list[task_cnt].task_type_cd = ta.task_type_cd, reply->task_list[task_cnt].
   med_order_type_cd = ta.med_order_type_cd, reply->task_list[task_cnt].catalog_type_cd = ta
   .catalog_type_cd,
   reply->task_list[task_cnt].task_description = ot.task_description, reply->task_list[task_cnt].
   order_mnemonic = o.order_mnemonic, reply->task_list[task_cnt].hna_order_mnemonic = o
   .hna_order_mnemonic,
   reply->task_list[task_cnt].ordered_as_mnemonic = o.ordered_as_mnemonic
   IF (o.template_order_id > 0)
    child_cnt = (child_cnt+ 1)
    IF (child_cnt > size(struct->child_qual,5))
     stat = alterlist(struct->child_qual,(child_cnt+ 19))
    ENDIF
    struct->child_qual[child_cnt].template_order_id = o.template_order_id, struct->child_qual[
    child_cnt].template_core_action_sequence = o.template_core_action_sequence
   ELSE
    parent_cnt = (parent_cnt+ 1)
    IF (parent_cnt > size(struct->parent_qual,5))
     stat = alterlist(struct->parent_qual,(parent_cnt+ 19))
    ENDIF
    struct->parent_qual[parent_cnt].order_id = o.order_id, struct->parent_qual[parent_cnt].
    last_action_sequence = o.last_action_sequence
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->task_list,task_cnt), stat = alterlist(struct->child_qual,child_cnt), stat
    = alterlist(struct->parent_qual,parent_cnt)
 ;end select
 SET stat = alterlist(request->qual,request_size)
 DECLARE ntotalchild = i4 WITH protect, noconstant((ceil((cnvtreal(child_size)/ nsize)) * nsize))
 DECLARE task_size = i4 WITH protect, noconstant(20)
 SET task_size = size(reply->task_list,5)
 DECLARE lidx2 = i4 WITH protect, noconstant(0)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 IF (child_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value((1+ ((ntotalchild - 1)/ nsize)))),
    order_action oa
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
    JOIN (oa
    WHERE (oa.order_id=struct->child_qual[d1.seq].template_order_id)
     AND (oa.action_sequence >= struct->child_qual[d1.seq].template_core_action_sequence))
   ORDER BY d1.seq, oa.action_sequence
   HEAD d1.seq
    next_core_action_found = 0
   DETAIL
    IF (next_core_action_found=0
     AND oa.core_ind=0)
     struct->child_qual[d1.seq].template_core_action_sequence = oa.action_sequence
    ELSE
     IF (oa.core_ind=1)
      next_core_action_found = 1
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF (child_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value((1+ ((ntotalchild - 1)/ nsize)))),
    order_ingredient oi,
    code_value_event_r cve,
    order_catalog_synonym ocs
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
    JOIN (oi
    WHERE (oi.order_id=struct->child_qual[d1.seq].template_order_id)
     AND (oi.action_sequence=
    (SELECT
     max(oi2.action_sequence)
     FROM order_ingredient oi2
     WHERE (oi2.order_id=struct->child_qual[d1.seq].template_order_id)
      AND (oi2.action_sequence <= struct->child_qual[d1.seq].template_core_action_sequence))))
    JOIN (cve
    WHERE cve.parent_cd=oi.catalog_cd)
    JOIN (ocs
    WHERE ocs.synonym_id=oi.synonym_id)
   HEAD oi.order_id
    ingred_cnt = 0, lidx2 = locateval(lidx,1,task_size,oi.order_id,reply->task_list[lidx].
     template_order_id)
   DETAIL
    IF (lidx2 > 0)
     ingred_cnt = (ingred_cnt+ 1)
     IF (ingred_cnt > size(reply->task_list[lidx2].ingred_list,5))
      stat = alterlist(reply->task_list[lidx2].ingred_list,(ingred_cnt+ 19))
     ENDIF
     reply->task_list[lidx2].ingred_list[ingred_cnt].ingredient_type_flag = oi.ingredient_type_flag,
     reply->task_list[lidx2].ingred_list[ingred_cnt].event_cd = cve.event_cd, reply->task_list[lidx2]
     .ingred_list[ingred_cnt].last_admin_disp_basis_flag = ocs.last_admin_disp_basis_flag,
     reply->task_list[lidx2].ingred_list[ingred_cnt].med_interval_warn_flag = ocs
     .med_interval_warn_flag, reply->task_list[lidx2].ingred_list[ingred_cnt].order_mnemonic = oi
     .order_mnemonic, reply->task_list[lidx2].ingred_list[ingred_cnt].hna_order_mnemonic = oi
     .hna_order_mnemonic,
     reply->task_list[lidx2].ingred_list[ingred_cnt].ordered_as_mnemonic = oi.ordered_as_mnemonic
    ENDIF
   FOOT  oi.order_id
    stat = alterlist(reply->task_list[lidx2].ingred_list,ingred_cnt)
  ;end select
 ENDIF
 DECLARE ntotalparent = i4 WITH protect, noconstant((ceil((cnvtreal(parent_size)/ nsize)) * nsize))
 SET task_size = size(reply->task_list,5)
 DECLARE lidx3 = i4 WITH protect, noconstant(0)
 DECLARE lidx4 = i4 WITH protect, noconstant(0)
 IF (parent_cnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value((1+ ((ntotalparent - 1)/ nsize)))),
    order_ingredient oi,
    code_value_event_r cve,
    order_catalog_synonym ocs
   PLAN (d1
    WHERE initarray(nstart,evaluate(d1.seq,1,1,(nstart+ nsize))))
    JOIN (oi
    WHERE (oi.order_id=struct->parent_qual[d1.seq].order_id)
     AND (oi.action_sequence=
    (SELECT
     max(oi2.action_sequence)
     FROM order_ingredient oi2
     WHERE (oi2.order_id=struct->parent_qual[d1.seq].order_id)
      AND (oi2.action_sequence <= struct->parent_qual[d1.seq].last_action_sequence))))
    JOIN (cve
    WHERE cve.parent_cd=oi.catalog_cd)
    JOIN (ocs
    WHERE ocs.synonym_id=oi.synonym_id)
   HEAD oi.order_id
    ingred_cnt = 0, lidx3 = locateval(lidx4,1,task_size,oi.order_id,reply->task_list[lidx4].order_id)
   DETAIL
    IF (lidx3 > 0)
     ingred_cnt = (ingred_cnt+ 1)
     IF (ingred_cnt > size(reply->task_list[lidx3].ingred_list,5))
      stat = alterlist(reply->task_list[lidx3].ingred_list,(ingred_cnt+ 19))
     ENDIF
     reply->task_list[lidx3].ingred_list[ingred_cnt].ingredient_type_flag = oi.ingredient_type_flag,
     reply->task_list[lidx3].ingred_list[ingred_cnt].event_cd = cve.event_cd, reply->task_list[lidx3]
     .ingred_list[ingred_cnt].last_admin_disp_basis_flag = ocs.last_admin_disp_basis_flag,
     reply->task_list[lidx3].ingred_list[ingred_cnt].med_interval_warn_flag = ocs
     .med_interval_warn_flag, reply->task_list[lidx3].ingred_list[ingred_cnt].order_mnemonic = oi
     .order_mnemonic, reply->task_list[lidx3].ingred_list[ingred_cnt].hna_order_mnemonic = oi
     .hna_order_mnemonic,
     reply->task_list[lidx3].ingred_list[ingred_cnt].ordered_as_mnemonic = oi.ordered_as_mnemonic
    ENDIF
   FOOT  oi.order_id
    stat = alterlist(reply->task_list[lidx3].ingred_list,ingred_cnt)
  ;end select
 ENDIF
 SET errcode = error(errmsg,1)
 IF (errcode > 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus.operationname = errmsg
 ELSEIF (size(reply->task_list,5) > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 SET last_mod = "002 06/28/12"
 SET modify = nopredeclare
END GO
