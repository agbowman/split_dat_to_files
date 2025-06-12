CREATE PROGRAM drr_load_col_exception:dba
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
 DECLARE errmsg = vc WITH protect, noconstant("")
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting script drr_load_col_exception..."
 FREE RECORD copy_requestin
 RECORD copy_requestin(
   1 list_0[*]
     2 info_domain = vc
     2 info_name = vc
     2 active_ind = f8
     2 exists_ind = i4
 )
 SET stat = alterlist(copy_requestin->list_0,size(requestin->list_0,5))
 FOR (loop = 1 TO size(requestin->list_0,5))
   SET copy_requestin->list_0[loop].info_domain = cnvtupper(requestin->list_0[loop].info_domain)
   SET copy_requestin->list_0[loop].info_name = cnvtupper(requestin->list_0[loop].info_name)
   SET copy_requestin->list_0[loop].active_ind = cnvtreal(requestin->list_0[loop].active_ind)
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
 FOR (dlce_idx = 1 TO size(copy_requestin->list_0,5))
   IF ((copy_requestin->list_0[dlce_idx].exists_ind=1))
    IF ((copy_requestin->list_0[dlce_idx].active_ind=0))
     DELETE  FROM dm_info dm
      WHERE (dm.info_domain=copy_requestin->list_0[dlce_idx].info_domain)
       AND (dm.info_name=copy_requestin->list_0[dlce_idx].info_name)
      WITH nocounter
     ;end delete
     IF (error(errmsg,0) > 0)
      ROLLBACK
      SET readme_data->status = "F"
      SET readme_data->message = concat("Failed to delete from DM_INFO: ",errmsg)
      GO TO exit_script
     ENDIF
    ENDIF
   ELSE
    IF ((copy_requestin->list_0[dlce_idx].active_ind=1))
     INSERT  FROM dm_info dm
      SET dm.info_domain = copy_requestin->list_0[dlce_idx].info_domain, dm.info_name =
       copy_requestin->list_0[dlce_idx].info_name, dm.info_date = cnvtdatetime(sysdate),
       dm.updt_applctx = reqinfo->updt_applctx, dm.updt_dt_tm = cnvtdatetime(sysdate), dm.updt_id =
       reqinfo->updt_id,
       dm.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (error(errmsg,0) > 0)
      ROLLBACK
      SET readme_data->status = "F"
      SET readme_data->message = concat("Failed to insert into DM_INFO: ",errmsg)
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SET readme_data->status = "S"
 SET readme_data->message = "Success: DM_INFO table loaded successfully"
#exit_script
 IF ((readme_data->status="F"))
  ROLLBACK
 ELSE
  COMMIT
 ENDIF
 FREE RECORD copy_requestin
END GO
