CREATE PROGRAM dm_upd_dm_info:dba
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
 DECLARE errmsg = vc WITH protect
 SET readme_data->message = "Readme failure.  Starting dm_upd_dm_info script."
 SET readme_data->status = "F"
 SELECT INTO "nl:"
  dm.info_domain, dm.info_name
  FROM dm_info dm,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d)
   JOIN (dm
   WHERE (dm.info_domain=requestin->list_0[d.seq].info_domain)
    AND (dm.info_name=requestin->list_0[d.seq].info_name))
  DETAIL
   requestin->list_0[d.seq].exists_ind = cnvtstring(1)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  ROLLBACK
  SET readme_data->message = concat("Failed to select from dm_info: ",errmsg)
  GO TO exit_script
 ENDIF
 UPDATE  FROM dm_info dm,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  SET dm.info_number = cnvtreal(requestin->list_0[d.seq].info_number), dm.info_char =
   IF ((requestin->list_0[d.seq].info_name="ESM_GATHER_MSGLOG")
    AND cursys="AIX") "EOD ALL NODES"
   ELSE requestin->list_0[d.seq].info_char
   ENDIF
   , dm.info_date = cnvtdatetime(curdate,curtime3),
   dm.updt_applctx = reqinfo->updt_applctx, dm.updt_cnt = (dm.updt_cnt+ 1), dm.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   dm.updt_id = reqinfo->updt_id, dm.updt_task = reqinfo->updt_task
  PLAN (d
   WHERE (requestin->list_0[d.seq].exists_ind=cnvtstring(1))
    AND (requestin->list_0[d.seq].del_ind=cnvtstring(0)))
   JOIN (dm
   WHERE (dm.info_domain=requestin->list_0[d.seq].info_domain)
    AND (dm.info_name=requestin->list_0[d.seq].info_name))
  WITH nocounter
 ;end update
 IF (error(errmsg,0) != 0)
  ROLLBACK
  SET readme_data->message = concat("Failed to updated dm_info: ",errmsg)
  GO TO exit_script
 ENDIF
 INSERT  FROM dm_info dm,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  SET dm.info_domain = requestin->list_0[d.seq].info_domain, dm.info_name = requestin->list_0[d.seq].
   info_name, dm.info_number = cnvtreal(requestin->list_0[d.seq].info_number),
   dm.info_char =
   IF ((requestin->list_0[d.seq].info_name="ESM_GATHER_MSGLOG")
    AND cursys="AIX") "EOD ALL NODES"
   ELSE requestin->list_0[d.seq].info_char
   ENDIF
   , dm.info_date = cnvtdatetime(curdate,curtime3), dm.updt_applctx = reqinfo->updt_applctx,
   dm.updt_cnt = 0, dm.updt_dt_tm = cnvtdatetime(curdate,curtime3), dm.updt_id = reqinfo->updt_id,
   dm.updt_task = reqinfo->updt_task
  PLAN (d
   WHERE (requestin->list_0[d.seq].exists_ind=cnvtstring(0))
    AND (requestin->list_0[d.seq].del_ind=cnvtstring(0)))
   JOIN (dm)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) != 0)
  ROLLBACK
  SET readme_data->message = concat("Failed to insert into dm_info: ",errmsg)
  GO TO exit_script
 ENDIF
 DELETE  FROM dm_info dm,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  SET dm.seq = 1
  PLAN (d
   WHERE (requestin->list_0[d.seq].del_ind=cnvtstring(1)))
   JOIN (dm
   WHERE (dm.info_domain=requestin->list_0[d.seq].info_domain)
    AND (dm.info_name=requestin->list_0[d.seq].info_name))
  WITH nocounter
 ;end delete
 IF (error(errmsg,0) != 0)
  ROLLBACK
  SET readme_data->message = concat("Failed to delete from dm_info: ",errmsg)
  GO TO exit_script
 ENDIF
 SET cnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  WHERE (requestin->list_0[d.seq].del_ind=cnvtstring(0))
  DETAIL
   cnt = (cnt+ 1)
  WITH nocounter
 ;end select
 SET rud_cnt = 0
 SELECT INTO "nl:"
  dm.info_domain, dm.info_name, dm.info_char,
  dm.info_number
  FROM dm_info dm,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d
   WHERE (requestin->list_0[d.seq].del_ind=cnvtstring(0)))
   JOIN (dm
   WHERE (dm.info_domain=requestin->list_0[d.seq].info_domain)
    AND (dm.info_name=requestin->list_0[d.seq].info_name)
    AND (dm.info_char=
   IF ((requestin->list_0[d.seq].info_name="ESM_GATHER_MSGLOG")
    AND cursys="AIX") "EOD ALL NODES"
   ELSE requestin->list_0[d.seq].info_char
   ENDIF
   )
    AND dm.info_number=cnvtreal(requestin->list_0[d.seq].info_number))
  DETAIL
   rud_cnt = (rud_cnt+ 1)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  ROLLBACK
  SET readme_data->message = concat("Failed to determine if update/insert was successful: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (rud_cnt != cnt)
  ROLLBACK
  SET readme_data->message = "Failed - not all dm_info rows inserted and update successfully."
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info dm,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  PLAN (d
   WHERE (requestin->list_0[d.seq].del_ind=cnvtstring(1)))
   JOIN (dm
   WHERE (dm.info_domain=requestin->list_0[d.seq].info_domain)
    AND (dm.info_name=requestin->list_0[d.seq].info_name))
  WITH nocounter
 ;end select
 IF (error(errmsg,0) != 0)
  ROLLBACK
  SET readme_data->message = concat("Failed to determine if delete was successful: ",errmsg)
  GO TO exit_script
 ENDIF
 IF (curqual != 0)
  ROLLBACK
  SET readme_data->message = "Failed to delete designated dm_info rows"
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success - dm_info rows inserted, updated, and deleted successfully."
 COMMIT
#exit_script
END GO
