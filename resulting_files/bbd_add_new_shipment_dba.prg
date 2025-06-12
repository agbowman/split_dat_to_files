CREATE PROGRAM bbd_add_new_shipment:dba
 RECORD reply(
   1 shipment_nbr = i4
   1 shipment_id = f8
   1 organization_id = f8
   1 owner_area_cd = f8
   1 inventory_area_cd = f8
   1 needed_dt_tm = di8
   1 order_placed_by = vc
   1 shipment_status_flag = i2
   1 order_dt_tm = di8
   1 order_priority_cd = f8
   1 from_facility_cd = f8
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
 SET modify = predeclare
 DECLARE failed = c1 WITH protect, noconstant("F")
 DECLARE ship_id = f8 WITH protect, noconstant(0.0)
 DECLARE ship_nbr = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  seqn = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   ship_id = seqn
  WITH format, nocounter
 ;end select
 SELECT INTO "nl:"
  seqn = seq(bb_shipment_seq,nextval)
  FROM dual
  DETAIL
   ship_nbr = seqn
  WITH format, nocounter
 ;end select
 SET reply->shipment_nbr = ship_nbr
 SET reply->shipment_id = ship_id
 SET reply->organization_id = request->organization_id
 SET reply->inventory_area_cd = request->inventory_area_cd
 SET reply->owner_area_cd = request->owner_area_cd
 SET reply->needed_dt_tm = request->needed_dt_tm
 SET reply->order_placed_by = request->order_placed_by
 SET reply->shipment_status_flag = 0
 SET reply->order_dt_tm = request->order_dt_tm
 SET reply->order_priority_cd = request->order_priority_cd
 SET reply->from_facility_cd = request->from_facility_cd
 INSERT  FROM bb_shipment s
  SET s.shipment_id = ship_id, s.shipment_nbr = ship_nbr, s.shipment_dt_tm = null,
   s.long_text_id = 0.0, s.shipment_status_flag = 0, s.needed_dt_tm = cnvtdatetime(request->
    needed_dt_tm),
   s.order_dt_tm = cnvtdatetime(request->order_dt_tm), s.courier_cd = 0.0, s.order_placed_by =
   request->order_placed_by,
   s.recorded_by_prsnl_id = 0.0, s.owner_area_cd = request->owner_area_cd, s.inventory_area_cd =
   request->inventory_area_cd,
   s.organization_id = request->organization_id, s.order_priority_cd = request->order_priority_cd, s
   .from_facility_cd = request->from_facility_cd,
   s.active_status_cd = reqdata->active_status_cd, s.active_status_dt_tm = cnvtdatetime(curdate,
    curtime3), s.active_status_prsnl_id = reqinfo->updt_id,
   s.active_ind = 1, s.updt_applctx = reqinfo->updt_applctx, s.updt_dt_tm = cnvtdatetime(curdate,
    curtime3),
   s.updt_id = reqinfo->updt_id, s.updt_task = reqinfo->updt_task, s.updt_cnt = 0
 ;end insert
 IF (curqual=0)
  SET failed = "T"
  SET reply->status_data.subeventstatus[1].sourceobjectname = "bbd_add_new_shipment.prg"
  SET reply->status_data.subeventstatus[1].operationname = "Insert"
  SET reply->status_data.subeventstatus[1].targetobjectname = "bbd_add_new_shipment"
  SET reply->status_data.subeventstatus[1].targetobjectvalue =
  "Error on inserting new shipment information."
  SET reply->status_data.subeventstatus[1].sourceobjectqual = 1
  GO TO exit_script
 ENDIF
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
