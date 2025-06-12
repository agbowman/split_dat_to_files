CREATE PROGRAM bmdi_updt_organizationid:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting script bmdi_updt_organizationid..."
 RECORD internal(
   1 qual[*]
     2 service_resource_cd = f8
     2 location_cd = f8
     2 resource_loc_cd = f8
 )
 DECLARE organization_id = f8
 DECLARE service_resource_cd = f8
 DECLARE location_cd = f8
 DECLARE resource_loc_cd = f8
 DECLARE count1 = i4
 DECLARE count2 = i4
 DECLARE errmsg = vc WITH protect, noconstant("")
 SELECT DISTINCT INTO "nl:"
  FROM di_client_config dcc,
   lab_instrument li,
   service_resource_lab_type_r srl,
   service_resource svc,
   organization org,
   logical_domain ld,
   bmdi_monitored_device bmd
  WHERE dcc.active_ind=1
   AND li.service_resource_cd=dcc.service_resource_cd
   AND srl.service_resource_cd=li.service_resource_cd
   AND svc.service_resource_cd=srl.service_resource_cd
   AND bmd.device_cd=svc.service_resource_cd
   AND org.organization_id=svc.organization_id
   AND ld.logical_domain_id=org.logical_domain_id
   AND ld.active_ind=1
   AND svc.organization_id=0
  ORDER BY bmd.device_cd, bmd.location_cd DESC
  HEAD bmd.device_cd
   count1 += 1, stat = alterlist(internal->qual,count1), internal->qual[count1].service_resource_cd
    = bmd.device_cd,
   internal->qual[count1].location_cd = bmd.location_cd, internal->qual[count1].resource_loc_cd = bmd
   .resource_loc_cd
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->message = concat("Failed to select ORGANIZATION_ID: ",errmsg)
  GO TO end_of_program
 ENDIF
 FOR (i = 1 TO count1)
   CALL updateorganizationid(internal->qual[i].service_resource_cd,internal->qual[i].location_cd,
    internal->qual[i].resource_loc_cd)
 ENDFOR
 IF (count1=count2)
  COMMIT
  SET readme_data->status = "S"
  SET readme_data->message = "Readme Success: service_resource table is updated successfully ..."
 ELSE
  ROLLBACK
  SET readme_data->message = "Readme Failed: service_resource table is not updated successfully ..."
 ENDIF
 SUBROUTINE (updateorganizationid(service_resource_cd=f8,location_cd=f8,resource_loc_cd=f8) =vc)
   IF (location_cd > 0)
    SELECT INTO "nl:"
     FROM location loc
     WHERE loc.location_cd=location_cd
     DETAIL
      organization_id = loc.organization_id
     WITH nocounter
    ;end select
    IF (error(errmsg,0) > 0)
     SET readme_data->message = concat("Failed to select ORGANIZATION_ID from location: ",errmsg)
     GO TO end_of_program
    ENDIF
   ELSE
    SELECT INTO "nl:"
     FROM service_resource sr
     WHERE sr.service_resource_cd=resource_loc_cd
     DETAIL
      organization_id = sr.organization_id
     WITH nocounter
    ;end select
    IF (error(errmsg,0) > 0)
     SET readme_data->message = concat("Failed to select ORGANIZATION_ID from SERVICE_RESOURCE: ",
      errmsg)
     GO TO end_of_program
    ENDIF
    IF (organization_id=0)
     SELECT INTO "nl:"
      FROM service_resource sr,
       location loc
      WHERE sr.location_cd=loc.location_cd
       AND sr.service_resource_cd=resource_loc_cd
      DETAIL
       organization_id = loc.organization_id
      WITH nocounter
     ;end select
     IF (error(errmsg,0) > 0)
      SET readme_data->message = concat("Failed to select ORG_ID from SERVICE_RESOURCE & LOCATION: ",
       errmsg)
      GO TO end_of_program
     ENDIF
    ENDIF
   ENDIF
   UPDATE  FROM service_resource sr
    SET sr.organization_id = organization_id
    WHERE sr.service_resource_cd=service_resource_cd
    WITH nocounter
   ;end update
   IF (error(errmsg,0) > 0)
    ROLLBACK
    SET readme_data->message = concat("Failed to update ORG_ID in SERVICE_RESOURCE: ",errmsg)
    GO TO end_of_program
   ENDIF
   IF (curqual=1)
    SET count2 += 1
   ENDIF
 END ;Subroutine
#end_of_program
 FREE SET qual
END GO
