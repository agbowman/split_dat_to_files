CREATE PROGRAM bbd_get_shipment_org_pref:dba
 RECORD reply(
   1 org_shipment_id = f8
   1 destroy_expired_ind = i2
   1 req_testing_ind = i2
   1 accept_expired_ind = i2
   1 accept_pos_result_ind = i2
   1 accept_quar_products_ind = i2
   1 updt_cnt = i4
   1 assayqual[*]
     2 accept_pos_test_id = f8
     2 org_shipment_id = f8
     2 task_assay_cd = f8
     2 active_ind = i2
     2 updt_cnt = i4
     2 assayprod[*]
       3 product_cd = f8
   1 reasonqual[*]
     2 accept_quar_reason_id = f8
     2 org_shipment_id = f8
     2 quar_reason_cd = f8
     2 active_ind = i2
     2 updt_cnt = i4
     2 quarprod[*]
       3 product_cd = f8
   1 container_type[*]
     2 container_type_cd = f8
     2 container_type_disp = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET assaycount = 0
 SET reasoncount = 0
 SET assayprodcount = 0
 SET reasonprodcount = 0
 SET containercount = 0
 IF ((request->all_prefs="Y"))
  SELECT INTO "nl:"
   o.destroy_once_expired_ind, o.accept_quarantined_prod_ind, o.req_testing_complete_ind,
   o.accept_pos_result_ind, o.accept_expired_prod_ind, quarantine_reason = uar_get_code_display(r
    .quar_reason_cd),
   side = decode(d2.seq,"Reason",d3.seq,"Container"), c.container_type_cd
   FROM org_shipment o,
    accept_quar_reason r,
    accept_quar_prod_r qp,
    (dummyt d2  WITH seq = 1),
    (dummyt d3  WITH seq = 1),
    container_org_r c
   PLAN (o
    WHERE (((request->organization_id > 0.0)
     AND (o.organization_id=request->organization_id)) OR ((((request->owner_area_cd > 0.0)
     AND (o.owner_area_cd=request->owner_area_cd)) OR ((request->inventory_area_cd > 0.0)
     AND (o.inventory_area_cd=request->inventory_area_cd))) ))
     AND o.active_ind=1)
    JOIN (((d2
    WHERE d2.seq=1)
    JOIN (r
    WHERE r.org_shipment_id=o.org_shipment_id
     AND r.active_ind=1)
    JOIN (qp
    WHERE qp.accept_quar_reason_id=r.accept_quar_reason_id
     AND qp.active_ind=1)
    ) ORJOIN ((d3
    WHERE d3.seq=1)
    JOIN (c
    WHERE (((request->organization_id > 0.0)
     AND (c.organization_id=request->organization_id)) OR ((((request->owner_area_cd > 0.0)
     AND (c.owner_area_cd=request->owner_area_cd)) OR ((request->inventory_area_cd > 0.0)
     AND (c.inventory_area_cd=request->inventory_area_cd))) ))
     AND c.active_ind=1)
    ))
   ORDER BY o.org_shipment_id, r.quar_reason_cd, c.container_type_cd
   HEAD REPORT
    reply->org_shipment_id = o.org_shipment_id, reply->destroy_expired_ind = o
    .destroy_once_expired_ind, reply->req_testing_ind = o.req_testing_complete_ind,
    reply->accept_pos_result_ind = o.accept_pos_result_ind, reply->accept_quar_products_ind = o
    .accept_quarantined_prod_ind, reply->accept_expired_ind = o.accept_expired_prod_ind
   HEAD r.quar_reason_cd
    IF (r.quar_reason_cd > 0
     AND side="Reason")
     reasoncount = (reasoncount+ 1), stat = alterlist(reply->reasonqual,reasoncount), reply->
     reasonqual[reasoncount].quar_reason_cd = r.quar_reason_cd
    ENDIF
   HEAD c.container_type_cd
    IF (c.container_type_cd > 0
     AND side="Container")
     containercount = (containercount+ 1), stat = alterlist(reply->container_type,containercount),
     reply->container_type[containercount].container_type_cd = c.container_type_cd
    ENDIF
   DETAIL
    IF (side="Reason"
     AND reasoncount > 0)
     reasonprodcount = (reasonprodcount+ 1), stat = alterlist(reply->reasonqual[reasoncount].quarprod,
      reasonprodcount), reply->reasonqual[reasoncount].quarprod[reasonprodcount].product_cd = qp
     .product_cd
    ENDIF
   FOOT  c.container_type_cd
    row + 1
   FOOT  r.quar_reason_cd
    row + 1
   WITH counter, outerjoin = d2, outerjoin = d3,
    outerjoin = o.org_shipment_id
  ;end select
 ELSE
  SELECT
   IF ((request->inventory_area_cd=0))
    PLAN (o
     WHERE (o.organization_id=request->organization_id)
      AND o.active_ind=1)
     JOIN (r
     WHERE outerjoin(o.org_shipment_id)=r.org_shipment_id
      AND r.active_ind=outerjoin(1))
   ELSE
    PLAN (o
     WHERE (o.inventory_area_cd=request->inventory_area_cd)
      AND o.active_ind=1)
     JOIN (r
     WHERE outerjoin(o.org_shipment_id)=r.org_shipment_id
      AND r.active_ind=outerjoin(1))
   ENDIF
   INTO "nl:"
   o.org_shipment_id, r.accept_quar_reason_id
   FROM org_shipment o,
    accept_quar_reason r
   ORDER BY r.accept_quar_reason_id
   HEAD REPORT
    reply->org_shipment_id = o.org_shipment_id, reply->destroy_expired_ind = o
    .destroy_once_expired_ind, reply->req_testing_ind = o.req_testing_complete_ind,
    reply->accept_pos_result_ind = o.accept_pos_result_ind, reply->accept_quar_products_ind = o
    .accept_quarantined_prod_ind, reply->accept_expired_ind = o.accept_expired_prod_ind,
    reply->updt_cnt = o.updt_cnt
   HEAD r.accept_quar_reason_id
    row + 1
   FOOT  r.accept_quar_reason_id
    IF (r.accept_quar_reason_id > 0)
     reasoncount = (reasoncount+ 1), stat = alterlist(reply->reasonqual,reasoncount), reply->
     reasonqual[reasoncount].accept_quar_reason_id = r.accept_quar_reason_id,
     reply->reasonqual[reasoncount].org_shipment_id = r.org_shipment_id, reply->reasonqual[
     reasoncount].quar_reason_cd = r.quar_reason_cd, reply->reasonqual[reasoncount].active_ind = r
     .active_ind,
     reply->reasonqual[reasoncount].updt_cnt = r.updt_cnt
    ENDIF
   WITH counter
  ;end select
 ENDIF
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exitscript
END GO
