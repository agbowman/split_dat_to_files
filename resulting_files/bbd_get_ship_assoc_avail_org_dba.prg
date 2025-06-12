CREATE PROGRAM bbd_get_ship_assoc_avail_org:dba
 RECORD reply(
   1 qual[*]
     2 org_name = c100
     2 org_id = f8
     2 org_shipment_id = f8
   1 assayqual[*]
     2 accept_pos_test_id = f8
     2 org_shipment_id = f8
     2 task_assay_cd = f8
     2 task_assay_cd_disp = c40
   1 reasonqual[*]
     2 accept_quar_reason_id = f8
     2 org_shipment_id = f8
     2 quar_reason_cd = f8
     2 quar_reason_cd_disp = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SET assaycount = 0
 SET reasoncount = 0
 SELECT INTO "nl:"
  s.*, inventory_area = uar_get_code_display(s.inventory_area_cd)
  FROM org_shipment s,
   organization o,
   (dummyt d1  WITH seq = 1),
   accept_quar_reason r
  PLAN (s
   WHERE ((s.accept_pos_result_ind=1) OR (s.accept_quarantined_prod_ind=1))
    AND s.active_ind=1)
   JOIN (o
   WHERE o.organization_id=outerjoin(s.organization_id)
    AND o.organization_id > outerjoin(0)
    AND o.active_ind=outerjoin(1))
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (r
   WHERE r.org_shipment_id=s.org_shipment_id
    AND r.active_ind=1)
  ORDER BY o.org_name, s.org_shipment_id, r.accept_quar_reason_id
  HEAD s.org_shipment_id
   count = (count+ 1), stat = alterlist(reply->qual,count)
   IF (o.organization_id=0.0)
    reply->qual[count].org_name = inventory_area, reply->qual[count].org_id = s.inventory_area_cd
   ELSE
    reply->qual[count].org_name = o.org_name, reply->qual[count].org_id = o.organization_id
   ENDIF
   reply->qual[count].org_shipment_id = s.org_shipment_id
  HEAD r.accept_quar_reason_id
   IF (r.accept_quar_reason_id > 0)
    reasoncount = (reasoncount+ 1), stat = alterlist(reply->reasonqual,reasoncount), reply->
    reasonqual[reasoncount].accept_quar_reason_id = r.accept_quar_reason_id,
    reply->reasonqual[reasoncount].org_shipment_id = r.org_shipment_id, reply->reasonqual[reasoncount
    ].quar_reason_cd = r.quar_reason_cd
   ENDIF
  WITH counter, outerjoin = d1
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exitscript
END GO
