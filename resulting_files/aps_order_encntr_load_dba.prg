CREATE PROGRAM aps_order_encntr_load:dba
 SELECT INTO "nl:"
  e.encntr_id
  FROM encounter e
  WHERE (order_encntr_info->encntr_id=e.encntr_id)
  HEAD REPORT
   order_encntr_info->encntr_financial_id = 0.0, order_encntr_info->location_cd = 0.0,
   order_encntr_info->loc_facility_cd = 0.0,
   order_encntr_info->loc_nurse_unit_cd = 0.0, order_encntr_info->loc_room_cd = 0.0,
   order_encntr_info->loc_bed_cd = 0.0
  DETAIL
   order_encntr_info->encntr_financial_id = e.encntr_financial_id, order_encntr_info->location_cd = e
   .location_cd, order_encntr_info->loc_facility_cd = e.loc_facility_cd,
   order_encntr_info->loc_nurse_unit_cd = e.loc_nurse_unit_cd, order_encntr_info->loc_room_cd = e
   .loc_room_cd, order_encntr_info->loc_bed_cd = e.loc_bed_cd
  WITH nocounter
 ;end select
END GO
