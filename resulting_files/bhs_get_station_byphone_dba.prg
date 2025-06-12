CREATE PROGRAM bhs_get_station_byphone:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Enter Phone number" = ""
  WITH outdev, prompt1
 DECLARE areacode = c3
 DECLARE exchange = c3
 DECLARE suffix = c4
 DECLARE phone_number = vc
 SET phone_number = replace( $2,"-","",0)
 SET phone_number = replace(phone_number,"(","",0)
 SET phone_number = replace(phone_number,")","",0)
 SET areacode = substring(1,3,trim(phone_number))
 SET exchange = substring(4,3,trim(phone_number))
 SET suffix = substring(7,4,trim(phone_number))
 SELECT INTO  $1
  d.description, d_device_disp = uar_get_code_display(d.device_cd), d_device_function_disp =
  uar_get_code_display(d.device_function_cd),
  d_device_type_disp = uar_get_code_display(d.device_type_cd), d.distribution_flag, d.dms_service_id,
  d.local_address, d_location_disp = uar_get_code_display(d.location_cd), d.name,
  d.physical_device_name, d.rowid, d.updt_applctx,
  d.updt_cnt, d.updt_dt_tm, d.updt_id,
  d.updt_task, r_access_disp = uar_get_code_display(r.access_cd), r.area_code,
  r.country_access, r_device_address_type_disp = uar_get_code_display(r.device_address_type_cd),
  r_device_disp = uar_get_code_display(r.device_cd),
  r.exchange, r.local_flag, r.phone_mask_id,
  r.phone_suffix, r.remote_dev_type_id, r.rowid,
  r.updt_applctx, r.updt_cnt, r.updt_dt_tm,
  r.updt_id, r.updt_task
  FROM device d,
   remote_device r
  PLAN (d
   WHERE d.device_type_cd=2282.00)
   JOIN (r
   WHERE r.device_cd=d.device_cd
    AND r.phone_suffix=suffix
    AND r.exchange=exchange
    AND r.area_code=areacode)
  WITH nocounter, separator = " ", format
 ;end select
END GO
