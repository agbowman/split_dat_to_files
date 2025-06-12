CREATE PROGRAM dcp_add_cn_tasks:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD temp(
   1 qual[*]
     2 task_id = f8
     2 person_id = f8
     2 location_cd = f8
     2 reference_task_id = f8
     2 catalog_cd = f8
     2 task_type_cd = f8
     2 encntr_id = f8
     2 order_id = f8
     2 frequency_cd = f8
     2 last_update_provider_id = f8
     2 task_status_cd = f8
     2 task_status_reason_cd = f8
     2 task_dt_tm = dq8
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_task = i4
     2 updt_applctx = i4
 )
 RECORD temp1(
   1 qual[*]
     2 order_id = f8
     2 oe_field_value = f8
 )
 RECORD child(
   1 qual[*]
     2 task_id = f8
     2 order_id = f8
 )
 RECORD subreply(
   1 order_id = f8
 )
 SET cnt = 0
 SELECT INTO "nl:"
  FROM cn_task cn,
   task_activity ta,
   orders o
  PLAN (cn
   WHERE cn.task_id > 0)
   JOIN (ta
   WHERE ta.task_id > 0
    AND ta.active_ind=1
    AND cn.task_id=ta.task_id
    AND ta.updt_dt_tm > cn.updt_dt_tm)
   JOIN (o
   WHERE cn.order_id=o.order_id)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].task_id = ta.task_id,
   temp->qual[cnt].person_id = ta.person_id, temp->qual[cnt].location_cd = ta.location_cd, temp->
   qual[cnt].reference_task_id = ta.reference_task_id,
   temp->qual[cnt].catalog_cd = ta.catalog_cd, temp->qual[cnt].task_type_cd = ta.task_type_cd, temp->
   qual[cnt].encntr_id = ta.encntr_id,
   temp->qual[cnt].order_id = ta.order_id, temp->qual[cnt].last_update_provider_id = o
   .last_update_provider_id, temp->qual[cnt].task_status_cd = ta.task_status_cd,
   temp->qual[cnt].task_status_reason_cd = ta.task_status_reason_cd, temp->qual[cnt].task_dt_tm =
   cnvtdatetime(ta.task_dt_tm), temp->qual[cnt].updt_dt_tm = cnvtdatetime(ta.updt_dt_tm),
   temp->qual[cnt].updt_id = ta.updt_id, temp->qual[cnt].updt_task = ta.updt_task, temp->qual[cnt].
   updt_applctx = ta.updt_applctx
  WITH nocounter
 ;end select
 FOR (x = 1 TO cnt)
   UPDATE  FROM cn_task cn
    SET cn.person_id = temp->qual[x].person_id, cn.location_cd = temp->qual[x].location_cd, cn
     .reference_task_id = temp->qual[x].reference_task_id,
     cn.catalog_cd = temp->qual[x].catalog_cd, cn.task_type_cd = temp->qual[x].task_type_cd, cn
     .encntr_id = temp->qual[x].encntr_id,
     cn.order_id = temp->qual[x].order_id, cn.last_update_provider_id = temp->qual[x].
     last_update_provider_id, cn.task_status_cd = temp->qual[x].task_status_cd,
     cn.task_status_reason_cd = temp->qual[x].task_status_reason_cd, cn.task_dt_tm = cnvtdatetime(
      temp->qual[x].task_dt_tm), cn.updt_dt_tm = cnvtdatetime(temp->qual[x].updt_dt_tm),
     cn.updt_id = temp->qual[x].updt_id, cn.updt_task = temp->qual[x].updt_task, cn.updt_applctx =
     temp->qual[x].updt_applctx
    WHERE (cn.task_id=temp->qual[x].task_id)
    WITH nocounter
   ;end update
 ENDFOR
 SELECT INTO "nl:"
  FROM task_activity taa,
   orders ord
  PLAN (taa
   WHERE taa.task_id > 0
    AND taa.active_ind=1
    AND  NOT ( EXISTS (
   (SELECT
    cnt.task_id
    FROM cn_task cnt
    WHERE cnt.task_id > 0
     AND cnt.task_id=taa.task_id))))
   JOIN (ord
   WHERE taa.order_id=ord.order_id)
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp->qual,cnt), temp->qual[cnt].task_id = taa.task_id,
   temp->qual[cnt].person_id = taa.person_id, temp->qual[cnt].location_cd = taa.location_cd, temp->
   qual[cnt].reference_task_id = taa.reference_task_id,
   temp->qual[cnt].catalog_cd = taa.catalog_cd, temp->qual[cnt].task_type_cd = taa.task_type_cd, temp
   ->qual[cnt].encntr_id = taa.encntr_id,
   temp->qual[cnt].order_id = taa.order_id, temp->qual[cnt].last_update_provider_id = ord
   .last_update_provider_id, temp->qual[cnt].task_status_cd = taa.task_status_cd,
   temp->qual[cnt].task_status_reason_cd = taa.task_status_reason_cd, temp->qual[cnt].task_dt_tm =
   cnvtdatetime(taa.task_dt_tm), temp->qual[cnt].updt_dt_tm = cnvtdatetime(taa.updt_dt_tm),
   temp->qual[cnt].updt_id = taa.updt_id, temp->qual[cnt].updt_task = taa.updt_task, temp->qual[cnt].
   updt_applctx = taa.updt_applctx
  WITH nocounter
 ;end select
 FOR (x = 1 TO cnt)
   IF ((temp->qual[x].task_id > 0))
    INSERT  FROM cn_task cnn
     SET cnn.task_id = temp->qual[x].task_id, cnn.person_id = temp->qual[x].person_id, cnn
      .location_cd = temp->qual[x].location_cd,
      cnn.reference_task_id = temp->qual[x].reference_task_id, cnn.catalog_cd = temp->qual[x].
      catalog_cd, cnn.task_type_cd = temp->qual[x].task_type_cd,
      cnn.encntr_id = temp->qual[x].encntr_id, cnn.order_id = temp->qual[x].order_id, cnn
      .last_update_provider_id = temp->qual[x].last_update_provider_id,
      cnn.task_status_cd = temp->qual[x].task_status_cd, cnn.task_status_reason_cd = temp->qual[x].
      task_status_reason_cd, cnn.task_dt_tm = cnvtdatetime(temp->qual[x].task_dt_tm),
      cnn.updt_dt_tm = cnvtdatetime(temp->qual[x].updt_dt_tm), cnn.updt_id = temp->qual[x].updt_id,
      cnn.updt_task = temp->qual[x].updt_task,
      cnn.updt_applctx = temp->qual[x].updt_applctx, cnn.frequency_cd = 0, cnn.parent_order_id = 0
     WITH nocounter
    ;end insert
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  FROM cn_task ct,
   orders o,
   order_detail od
  PLAN (ct
   WHERE ct.order_id > 0
    AND ct.frequency_cd=0)
   JOIN (o
   WHERE ct.order_id=o.order_id)
   JOIN (od
   WHERE o.template_order_id=od.order_id
    AND od.oe_field_meaning="FREQ")
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(temp1->qual,cnt), temp1->qual[cnt].order_id = o.order_id,
   temp1->qual[cnt].oe_field_value = od.oe_field_value
  WITH nocounter
 ;end select
 FOR (x = 1 TO cnt)
   UPDATE  FROM cn_task ct
    SET ct.frequency_cd = temp1->qual[x].oe_field_value
    WHERE (ct.order_id=temp1->qual[x].order_id)
    WITH nocounter
   ;end update
 ENDFOR
 SELECT INTO "nl:"
  cn.task_id, cn.order_id
  FROM cn_task cn
  WHERE cn.task_id > 0
   AND cn.order_id > 0
   AND ((cn.parent_order_id=0) OR (cn.parent_order_id=null))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1), stat = alterlist(child->qual,cnt), child->qual[cnt].task_id = cn.task_id,
   child->qual[cnt].order_id = cn.order_id
  WITH nocounter
 ;end select
 FOR (x = 1 TO cnt)
  CALL get_parent_order(child->qual[x].order_id)
  UPDATE  FROM cn_task cnupdate
   SET parent_order_id = subreply->order_id
   WHERE (cnupdate.task_id=child->qual[x].task_id)
  ;end update
 ENDFOR
 GO TO end_program
 SUBROUTINE get_parent_order(order_id_in)
   SET order_id = 0
   SET cs_order_id = 0
   SELECT INTO "nl:"
    o.cs_order_id
    FROM orders o
    WHERE o.order_id=order_id_in
    DETAIL
     order_id = o.order_id, cs_order_id = o.cs_order_id
    WITH nocounter
   ;end select
   WHILE (cs_order_id > 0)
    SELECT INTO "nl:"
     o.cs_order_id
     FROM orders o
     WHERE o.order_id=cs_order_id
     DETAIL
      order_id = o.order_id, cs_order_id = o.cs_order_id
     WITH nocounter
    ;end select
    IF (curqual=0)
     SET cs_order_id = 0
    ENDIF
   ENDWHILE
   SET subreply->order_id = order_id
 END ;Subroutine
#end_program
 COMMIT
 SET reply->status_data.status = "S"
END GO
