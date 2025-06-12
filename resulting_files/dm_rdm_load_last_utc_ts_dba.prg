CREATE PROGRAM dm_rdm_load_last_utc_ts:dba
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
 SET readme_data->message = "Readme Failed: Starting script dm_rdm_load_last_utc_ts..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 FREE RECORD copy_requestin
 RECORD copy_requestin(
   1 list_0[*]
     2 info_domain = vc
     2 info_name = vc
     2 info_char = vc
     2 info_number = f8
     2 updt_applctx = f8
     2 exists_ind = i4
 )
 SET stat = alterlist(copy_requestin->list_0,size(requestin->list_0,5))
 FOR (loop = 1 TO size(requestin->list_0,5))
   SET copy_requestin->list_0[loop].info_domain = cnvtupper(requestin->list_0[loop].info_domain)
   SET copy_requestin->list_0[loop].info_name = cnvtupper(requestin->list_0[loop].info_name)
   SET copy_requestin->list_0[loop].info_char = requestin->list_0[loop].info_char
   SET copy_requestin->list_0[loop].info_number = cnvtreal(requestin->list_0[loop].info_number)
   SET copy_requestin->list_0[loop].updt_applctx = cnvtreal(requestin->list_0[loop].updt_applctx)
   SET copy_requestin->list_0[loop].exists_ind = cnvtreal(0)
 ENDFOR
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to copy requestin: ",errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  dm.info_domain, dm.info_name
  FROM dm_info dm,
   (dummyt d  WITH seq = value(size(copy_requestin->list_0,5)))
  PLAN (d)
   JOIN (dm
   WHERE (dm.info_domain=copy_requestin->list_0[d.seq].info_domain)
    AND (dm.info_name=copy_requestin->list_0[d.seq].info_name))
  DETAIL
   copy_requestin->list_0[d.seq].exists_ind = cnvtreal(1)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to select from DM_INFO: ",errmsg)
  GO TO exit_script
 ENDIF
 UPDATE  FROM dm_info dm,
   (dummyt d  WITH seq = value(size(copy_requestin->list_0,5)))
  SET dm.info_number = copy_requestin->list_0[d.seq].info_number, dm.info_char = copy_requestin->
   list_0[d.seq].info_char, dm.updt_applctx = copy_requestin->list_0[d.seq].updt_applctx,
   dm.info_date = cnvtdatetime(curdate,curtime3)
  PLAN (d
   WHERE (copy_requestin->list_0[d.seq].exists_ind=cnvtreal(1)))
   JOIN (dm
   WHERE (dm.info_domain=copy_requestin->list_0[d.seq].info_domain)
    AND (dm.info_name=copy_requestin->list_0[d.seq].info_name)
    AND dm.updt_id != 722)
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update DM_INFO: ",errmsg)
  GO TO exit_script
 ENDIF
 INSERT  FROM dm_info dm,
   (dummyt d  WITH seq = value(size(copy_requestin->list_0,5)))
  SET dm.info_domain = copy_requestin->list_0[d.seq].info_domain, dm.info_name = copy_requestin->
   list_0[d.seq].info_name, dm.info_number = copy_requestin->list_0[d.seq].info_number,
   dm.info_char = copy_requestin->list_0[d.seq].info_char, dm.info_date = cnvtdatetime(curdate,
    curtime3), dm.updt_applctx = copy_requestin->list_0[d.seq].updt_applctx,
   dm.updt_cnt = 0, dm.updt_dt_tm = cnvtdatetime(curdate,curtime3), dm.updt_id = reqinfo->updt_id,
   dm.updt_task = reqinfo->updt_task
  PLAN (d
   WHERE (copy_requestin->list_0[d.seq].exists_ind=cnvtreal(0)))
   JOIN (dm)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to insert into DM_INFO: ",errmsg)
  GO TO exit_script
 ENDIF
 UPDATE  FROM dm_info di
  SET di.updt_applctx = 0
  WHERE di.info_domain IN ("DM2_INSTALL_LUTS:TRGLUTS", "DM2_INSTALL_LUTS:TRGSCN")
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update DM_INFO: ",errmsg)
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: Batch data loaded successfully"
#exit_script
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
 FREE RECORD copy_requestin
END GO
