CREATE PROGRAM dm_rdm_ehi_prop_set_load:dba
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
 SET readme_data->message = "Readme Failed: Starting script dm_rdm_dbi_load_tpl..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE loop = i4 WITH protect, noconstant(0)
 FREE RECORD model_properties
 RECORD model_properties(
   1 props[*]
     2 property_set = vc
     2 description = vc
     2 ttl = f8
     2 exists = i2
 )
 SET stat = alterlist(model_properties->props,size(requestin->list_0,5))
 FOR (loop = 1 TO size(requestin->list_0,5))
   SET model_properties->props[loop].property_set = requestin->list_0[loop].property_set
   SET model_properties->props[loop].description = requestin->list_0[loop].description
   SET model_properties->props[loop].ttl = cnvtreal(requestin->list_0[loop].ttl)
 ENDFOR
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to copy requestin: ",errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_property_set dms,
   (dummyt d  WITH seq = size(model_properties->props,5))
  PLAN (d)
   JOIN (dms
   WHERE (dms.property_set_name=model_properties->props[d.seq].property_set))
  DETAIL
   model_properties->props[d.seq].exists = 1
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to find already existing dm_property_sets: ",errmsg)
  GO TO exit_script
 ENDIF
 INSERT  FROM dm_property_set dms,
   (dummyt d  WITH seq = size(model_properties->props,5))
  SET dms.property_set_name = model_properties->props[d.seq].property_set, dms.property_set_desc =
   model_properties->props[d.seq].description, dms.ttl_secs = model_properties->props[d.seq].ttl,
   dms.updt_dt_tm = cnvtdatetime(sysdate), dms.updt_id = reqinfo->updt_id, dms.updt_task = reqinfo->
   updt_task,
   dms.updt_applctx = reqinfo->updt_applctx, dms.updt_cnt = 0
  PLAN (d
   WHERE (model_properties->props[d.seq].exists=0))
   JOIN (dms)
  WITH nocounter, rdbarrayinsert = 1
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to insert dm_property_set: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 UPDATE  FROM dm_property_set dms,
   (dummyt d  WITH seq = size(model_properties->props,5))
  SET dms.property_set_desc = model_properties->props[d.seq].description, dms.ttl_secs =
   model_properties->props[d.seq].ttl, dms.updt_dt_tm = cnvtdatetime(sysdate),
   dms.updt_id = reqinfo->updt_id, dms.updt_task = reqinfo->updt_task, dms.updt_applctx = reqinfo->
   updt_applctx,
   dms.updt_cnt = (dms.updt_cnt+ 1)
  PLAN (d
   WHERE (model_properties->props[d.seq].exists=1))
   JOIN (dms
   WHERE (dms.property_set_name=model_properties->props[d.seq].property_set))
  WITH nocounter, rdbarrayinsert = 1
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update dm_property_set: ",errmsg)
  GO TO exit_script
 ELSE
  COMMIT
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: property set data loaded successfully"
#exit_script
 CALL echorecord(readme_data)
 EXECUTE dm_readme_status
END GO
