CREATE PROGRAM bmdi_add_adt_stub:dba
 RECORD req(
   1 person_id = f8
   1 device_alias = c40
   1 parent_entity_name = c32
   1 parent_entity_id = f8
   1 mode = i2
   1 device_cd = f8
   1 location_cd = f8
   1 encntr_id = f8
   1 start_dt_tm = dq8
   1 stop_dt_tm = dq8
   1 assoc_prsnl_id = f8
   1 dissoc_prsnl_id = f8
   1 upd_status_cd = f8
   1 hint_id = f8
   1 monitored_device_id = f8
   1 resource_loc_cd = f8
 )
 RECORD temp(
   1 qual[*]
     2 device_cd = f8
     2 location_cd = f8
     2 resource_loc_cd = f8
     2 monitored_device_id = f8
 )
 DECLARE count = i2
 DECLARE index = i2
 DECLARE mode = i2
 SELECT INTO "nl:"
  FROM bmdi_acquired_data_track badt
  WHERE badt.monitored_device_id > 0
  WITH nocounter
 ;end select
 IF (curqual=0)
  SELECT INTO "nl:"
   FROM bmdi_acquired_data_track badt
  ;end select
  IF (curqual=0)
   SET mode = 0
  ELSE
   SET mode = 9
  ENDIF
 ELSE
  SELECT INTO "nl:"
   FROM bmdi_acquired_data_track badt
   WHERE badt.monitored_device_id=0
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET mode = 0
  ELSE
   SET mode = 9
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  FROM bmdi_monitored_device bmd
  WHERE bmd.monitored_device_id > 0
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1), stat = alterlist(temp->qual,count), temp->qual[count].device_cd = bmd
   .device_cd,
   temp->qual[count].location_cd = bmd.location_cd, temp->qual[count].resource_loc_cd = bmd
   .resource_loc_cd, temp->qual[count].monitored_device_id = bmd.monitored_device_id
  WITH nocounter
 ;end select
 SET index = 1
 WHILE (index <= size(temp->qual,5))
   SET req->mode = mode
   SET req->device_cd = temp->qual[index].device_cd
   SET req->location_cd = temp->qual[index].location_cd
   SET req->resource_loc_cd = temp->qual[index].resource_loc_cd
   SET req->monitored_device_id = temp->qual[index].monitored_device_id
   EXECUTE bmdi_manage_adt  WITH replace("REQUEST","REQ")
   SET index = (index+ 1)
 ENDWHILE
END GO
