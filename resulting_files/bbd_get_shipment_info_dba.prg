CREATE PROGRAM bbd_get_shipment_info:dba
 RECORD reply(
   1 shipment_nbr = i4
   1 shipment_id = f8
   1 needed_dt_tm = dq8
   1 shipment_dt_tm = dq8
   1 order_dt_tm = dq8
   1 shipment_status_flag = i2
   1 courier_cd = f8
   1 courier_disp = c40
   1 order_placed_by = c100
   1 comments_ind = i2
   1 organization_id = f8
   1 organization_name = vc
   1 inventory_area_cd = f8
   1 inventory_area_display = c40
   1 inventory_area_desc = vc
   1 owner_area_cd = f8
   1 owner_area_display = c40
   1 owner_area_desc = vc
   1 order_priority_cd = f8
   1 container[*]
     2 container_nbr = i4
     2 container_id = f8
     2 container_type_cd = f8
     2 container_type_disp = c40
     2 container_condition_cd = f8
     2 container_condition_disp = c40
     2 total_weight = i4
     2 unit_of_meas_cd = f8
     2 unit_of_meas_disp = c40
     2 temperature = f8
     2 temperature_degree_cd = f8
     2 temperature_degree_disp = c40
     2 product[*]
       3 product_event_id = f8
       3 product_id = f8
       3 from_inventory_area_cd = f8
       3 from_inventory_area_disp = c40
       3 from_owner_area_cd = f8
       3 from_owner_area_disp = c40
       3 return_condition_cd = f8
       3 return_condition_disp = c40
       3 return_vis_insp_cd = f8
       3 return_vis_insp_disp = c40
       3 return_dt_tm = dq8
       3 vis_insp_cd = f8
       3 vis_insp_disp = c40
       3 product_nbr = c20
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
 SET failed = "F"
 SET ccount = 0
 SET pcount = 0
 SELECT INTO "nl:"
  s.shipment_nbr, s.shipment_id, s.courier_cd,
  s.needed_dt_tm, s.shipment_dt_tm, s.order_dt_tm,
  s.shipment_status_flag, s.order_placed_by, s.long_text_id,
  s.recorded_by_prsnl_id, s.organization_id, s.owner_area_cd,
  s.inventory_area_cd, c.container_id, c.container_nbr,
  c.container_type_cd, c.container_condition_cd, c.total_weight,
  c.unit_of_meas_cd, e.product_event_id, e.product_id,
  e.from_inventory_area_cd, e.from_owner_area_cd, e.return_condition_cd,
  e.return_dt_tm, e.return_vis_insp_cd, e.vis_insp_cd,
  p.product_nbr
  FROM bb_shipment s,
   bb_ship_container c,
   bb_ship_event e,
   product p,
   (dummyt d1  WITH seq = 1),
   (dummyt d2  WITH seq = 1)
  PLAN (s
   WHERE (s.shipment_id=request->shipment_id)
    AND s.active_ind=1)
   JOIN (d1)
   JOIN (c
   WHERE c.shipment_id=s.shipment_id
    AND c.active_ind=1)
   JOIN (d2)
   JOIN (e
   WHERE e.shipment_id=c.shipment_id
    AND e.container_id=c.container_id
    AND e.active_ind=1)
   JOIN (p
   WHERE p.product_id=e.product_id
    AND p.active_ind=1)
  ORDER BY c.container_nbr, c.container_id
  HEAD REPORT
   IF (s.shipment_id > 0)
    reply->shipment_nbr = s.shipment_nbr, reply->shipment_id = s.shipment_id, reply->needed_dt_tm = s
    .needed_dt_tm,
    reply->shipment_dt_tm = s.shipment_dt_tm, reply->order_dt_tm = s.order_dt_tm, reply->
    organization_id = s.organization_id,
    reply->inventory_area_cd = s.inventory_area_cd, reply->inventory_area_display =
    uar_get_code_display(s.inventory_area_cd), reply->inventory_area_desc = uar_get_code_description(
     s.inventory_area_cd),
    reply->owner_area_cd = s.owner_area_cd, reply->owner_area_display = uar_get_code_display(s
     .owner_area_cd), reply->owner_area_desc = uar_get_code_description(s.owner_area_cd),
    reply->courier_cd = s.courier_cd, reply->shipment_status_flag = s.shipment_status_flag, reply->
    order_placed_by = s.order_placed_by,
    reply->order_priority_cd = s.order_priority_cd
    IF (s.long_text_id > 0)
     reply->comments_ind = 1
    ELSE
     reply->comments_ind = 0
    ENDIF
   ENDIF
  HEAD c.container_id
   IF (c.container_id > 0)
    ccount = (ccount+ 1), stat = alterlist(reply->container,ccount), reply->container[ccount].
    container_nbr = c.container_nbr,
    reply->container[ccount].container_id = c.container_id, reply->container[ccount].
    container_type_cd = c.container_type_cd, reply->container[ccount].container_condition_cd = c
    .container_condition_cd,
    reply->container[ccount].total_weight = c.total_weight, reply->container[ccount].unit_of_meas_cd
     = c.unit_of_meas_cd, reply->container[ccount].temperature = c.temperature_value,
    reply->container[ccount].temperature_degree_cd = c.temperature_degree_cd
   ENDIF
  DETAIL
   IF (e.container_id > 0.0
    AND e.shipment_id > 0.0)
    pcount = (pcount+ 1), stat = alterlist(reply->container[ccount].product,pcount), reply->
    container[ccount].product[pcount].product_id = e.product_id,
    reply->container[ccount].product[pcount].product_event_id = e.product_event_id, reply->container[
    ccount].product[pcount].from_inventory_area_cd = e.from_inventory_area_cd, reply->container[
    ccount].product[pcount].from_owner_area_cd = e.from_owner_area_cd,
    reply->container[ccount].product[pcount].return_condition_cd = e.return_condition_cd, reply->
    container[ccount].product[pcount].return_dt_tm = e.return_dt_tm, reply->container[ccount].
    product[pcount].return_vis_insp_cd = e.return_vis_insp_cd,
    reply->container[ccount].product[pcount].vis_insp_cd = e.vis_insp_cd, reply->container[ccount].
    product[pcount].product_nbr = p.product_nbr
   ENDIF
  FOOT  c.container_id
   pcount = 0
  WITH counter, outerjoin = d1, outerjoin = d2
 ;end select
 IF ((reply->organization_id > 0.0))
  SELECT INTO "nl:"
   o.org_name
   FROM organization o
   WHERE (o.organization_id=reply->organization_id)
   DETAIL
    reply->organization_name = o.org_name
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
END GO
