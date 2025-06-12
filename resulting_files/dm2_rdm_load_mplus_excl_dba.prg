CREATE PROGRAM dm2_rdm_load_mplus_excl:dba
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
 SET readme_data->message = "Readme Failed: Starting script dm2_rdm_load_mplus_excl..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 FREE RECORD copy_requestin
 RECORD copy_requestin(
   1 list_0[*]
     2 table_name = vc
     2 exclusion_reason_flag = i4
     2 exclusion_comment_txt = vc
     2 active_ind = i4
     2 exists_ind = i4
 )
 SET stat = alterlist(copy_requestin->list_0,size(requestin->list_0,5))
 FOR (loop = 1 TO size(requestin->list_0,5))
   SET copy_requestin->list_0[loop].table_name = cnvtupper(requestin->list_0[loop].table_name)
   SET copy_requestin->list_0[loop].exclusion_reason_flag = cnvtreal(requestin->list_0[loop].
    exclusion_reason_flag)
   SET copy_requestin->list_0[loop].exclusion_comment_txt = requestin->list_0[loop].
   exclusion_comment_txt
   SET copy_requestin->list_0[loop].active_ind = cnvtreal(requestin->list_0[loop].active_ind)
   SET copy_requestin->list_0[loop].exists_ind = cnvtreal(0)
 ENDFOR
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to copy requestin: ",errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  mte.table_name
  FROM dm_mplus_table_exclusion mte,
   (dummyt d  WITH seq = value(size(copy_requestin->list_0,5)))
  PLAN (d)
   JOIN (mte
   WHERE (mte.table_name=copy_requestin->list_0[d.seq].table_name))
  DETAIL
   copy_requestin->list_0[d.seq].exists_ind = cnvtreal(1)
  WITH nocounter
 ;end select
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to select from DM_MPLUS_TABLE_EXCLUSION: ",errmsg)
  GO TO exit_script
 ENDIF
 UPDATE  FROM dm_mplus_table_exclusion mte,
   (dummyt d  WITH seq = value(size(copy_requestin->list_0,5)))
  SET mte.table_name = copy_requestin->list_0[d.seq].table_name, mte.exclusion_reason_flag =
   copy_requestin->list_0[d.seq].exclusion_reason_flag, mte.exclusion_comment_txt = copy_requestin->
   list_0[d.seq].exclusion_comment_txt,
   mte.active_ind = copy_requestin->list_0[d.seq].active_ind, mte.updt_dt_tm = cnvtdatetime(curdate,
    curtime3)
  PLAN (d
   WHERE (copy_requestin->list_0[d.seq].exists_ind=cnvtreal(1)))
   JOIN (mte
   WHERE (mte.table_name=copy_requestin->list_0[d.seq].table_name))
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update DM_MPLUS_TABLE_EXCLUSION: ",errmsg)
  GO TO exit_script
 ENDIF
 INSERT  FROM dm_mplus_table_exclusion mte,
   (dummyt d  WITH seq = value(size(copy_requestin->list_0,5)))
  SET mte.table_name = copy_requestin->list_0[d.seq].table_name, mte.exclusion_reason_flag =
   copy_requestin->list_0[d.seq].exclusion_reason_flag, mte.exclusion_comment_txt = copy_requestin->
   list_0[d.seq].exclusion_comment_txt,
   mte.active_ind = copy_requestin->list_0[d.seq].active_ind, mte.updt_cnt = 0, mte.updt_dt_tm =
   cnvtdatetime(curdate,curtime3),
   mte.updt_id = reqinfo->updt_id, mte.updt_task = reqinfo->updt_task
  PLAN (d
   WHERE (copy_requestin->list_0[d.seq].exists_ind=cnvtreal(0)))
   JOIN (mte)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to insert into DM_MPLUS_TABLE_EXCLUSION: ",errmsg)
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
