CREATE PROGRAM dm_cmb_metadata_csv_load:dba
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
 SET readme_data->message = "Readme Failed: Starting script dm_cmb_metadata_csv_load..."
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE loop = i4 WITH protect, noconstant(0)
 DECLARE del = f8 WITH protect, noconstant(0.0)
 DECLARE bypass_uid = f8 WITH protect, noconstant(0.0)
 FREE RECORD copy_requestin
 RECORD copy_requestin(
   1 list_0[*]
     2 parent_table = vc
     2 child_table = vc
     2 child_column = vc
     2 child_pe_name_column = vc
     2 child_pe_name1_txt = vc
     2 child_pe_name2_txt = vc
     2 child_pe_name3_txt = vc
     2 child_pk = vc
     2 child_cons_name = vc
     2 active_only_flag = i2
     2 combine_action_type_val = vc
     2 combine_action_type_cd = f8
     2 exists_ind = i2
 )
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=327
   AND cv.cdf_meaning="DEL"
   AND cv.active_ind=1
  DETAIL
   del = cv.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM code_value cv
  WHERE cv.code_set=327
   AND cv.cdf_meaning="BYPASS_UID"
   AND cv.active_ind=1
  DETAIL
   bypass_uid = cv.code_value
  WITH nocounter
 ;end select
 IF (del <= 1)
  SET readme_data->status = "F"
  SET readme_data->message = "Failed to find the DEL code_value in CS 327"
  GO TO exit_script
 ENDIF
 IF (bypass_uid <= 1)
  SET readme_data->status = "F"
  SET readme_data->message = "Failed to find the BYPASS_UID code_value in CS 327"
  GO TO exit_script
 ENDIF
 SET stat = alterlist(copy_requestin->list_0,size(requestin->list_0,5))
 FOR (loop = 1 TO size(requestin->list_0,5))
   SET copy_requestin->list_0[loop].parent_table = trim(requestin->list_0[loop].parent_table,3)
   SET copy_requestin->list_0[loop].child_table = trim(requestin->list_0[loop].child_table,3)
   SET copy_requestin->list_0[loop].child_column = trim(requestin->list_0[loop].child_column,3)
   SET copy_requestin->list_0[loop].child_pe_name_column = trim(requestin->list_0[loop].
    child_pe_name_column,3)
   SET copy_requestin->list_0[loop].child_pe_name1_txt = trim(requestin->list_0[loop].
    child_pe_name1_txt,3)
   SET copy_requestin->list_0[loop].child_pe_name2_txt = trim(requestin->list_0[loop].
    child_pe_name2_txt,3)
   SET copy_requestin->list_0[loop].child_pe_name3_txt = trim(requestin->list_0[loop].
    child_pe_name3_txt,3)
   SET copy_requestin->list_0[loop].child_pk = trim(requestin->list_0[loop].child_pk,3)
   SET copy_requestin->list_0[loop].child_cons_name = trim(requestin->list_0[loop].child_cons_name,3)
   SET copy_requestin->list_0[loop].active_only_flag = cnvtreal(requestin->list_0[loop].
    active_only_flag)
   SET copy_requestin->list_0[loop].combine_action_type_val = trim(requestin->list_0[loop].
    combine_action_type_cd,3)
   SET copy_requestin->list_0[loop].exists_ind = 0
   IF ((copy_requestin->list_0[loop].combine_action_type_val="DEL"))
    SET copy_requestin->list_0[loop].combine_action_type_cd = del
   ELSE
    IF ((copy_requestin->list_0[loop].combine_action_type_val="BYPASS_UID"))
     SET copy_requestin->list_0[loop].combine_action_type_cd = bypass_uid
    ELSE
     SET copy_requestin->list_0[loop].combine_action_type_cd = 0.0
    ENDIF
   ENDIF
 ENDFOR
 IF (error(errmsg,0) > 0)
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to copy requestin: ",errmsg)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_cmb_metadata dcm,
   (dummyt d  WITH seq = value(size(requestin->list_0,5)))
  PLAN (dcm)
   JOIN (d
   WHERE (dcm.parent_table=copy_requestin->list_0[d.seq].parent_table)
    AND (dcm.child_table=copy_requestin->list_0[d.seq].child_table)
    AND (dcm.child_column=copy_requestin->list_0[d.seq].child_column))
  DETAIL
   copy_requestin->list_0[d.seq].exists_ind = 1
  WITH nocounter
 ;end select
 CALL echo("*****************   DEBUG   ********************")
 CALL echorecord(copy_requestin)
 CALL echo("*****************   DEBUG   ********************")
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to check for updates on DM_CMB_METADATA: ",errmsg)
  GO TO exit_script
 ENDIF
 INSERT  FROM dm_cmb_metadata dcm,
   (dummyt d  WITH seq = value(size(copy_requestin->list_0,5)))
  SET dcm.dm_cmb_metadata_id = seq(combine_seq,nextval), dcm.parent_table = copy_requestin->list_0[d
   .seq].parent_table, dcm.child_table = copy_requestin->list_0[d.seq].child_table,
   dcm.child_column = copy_requestin->list_0[d.seq].child_column, dcm.child_pe_name_column =
   copy_requestin->list_0[d.seq].child_pe_name_column, dcm.child_pe_name1_txt = copy_requestin->
   list_0[d.seq].child_pe_name1_txt,
   dcm.child_pe_name2_txt = copy_requestin->list_0[d.seq].child_pe_name2_txt, dcm.child_pe_name3_txt
    = copy_requestin->list_0[d.seq].child_pe_name3_txt, dcm.child_pk = copy_requestin->list_0[d.seq].
   child_pk,
   dcm.child_cons_name = copy_requestin->list_0[d.seq].child_cons_name, dcm.active_only_flag =
   copy_requestin->list_0[d.seq].active_only_flag, dcm.combine_action_type_cd = copy_requestin->
   list_0[d.seq].combine_action_type_cd,
   dcm.create_dt_tm = cnvtdatetime(sysdate), dcm.updt_applctx = reqinfo->updt_applctx, dcm.updt_cnt
    = 0,
   dcm.updt_dt_tm = cnvtdatetime(sysdate), dcm.updt_id = reqinfo->updt_id, dcm.updt_task = reqinfo->
   updt_task
  PLAN (d
   WHERE (copy_requestin->list_0[d.seq].exists_ind=0))
   JOIN (dcm)
  WITH nocounter
 ;end insert
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to insert rows on DM_CMB_METADATA: ",errmsg)
  GO TO exit_script
 ENDIF
 UPDATE  FROM dm_cmb_metadata dcm,
   (dummyt d  WITH seq = value(size(copy_requestin->list_0,5)))
  SET dcm.child_pe_name_column = copy_requestin->list_0[d.seq].child_pe_name_column, dcm
   .child_pe_name1_txt = copy_requestin->list_0[d.seq].child_pe_name1_txt, dcm.child_pe_name2_txt =
   copy_requestin->list_0[d.seq].child_pe_name2_txt,
   dcm.child_pe_name3_txt = copy_requestin->list_0[d.seq].child_pe_name3_txt, dcm.child_pk =
   copy_requestin->list_0[d.seq].child_pk, dcm.child_cons_name = copy_requestin->list_0[d.seq].
   child_cons_name,
   dcm.active_only_flag = copy_requestin->list_0[d.seq].active_only_flag, dcm.combine_action_type_cd
    = copy_requestin->list_0[d.seq].combine_action_type_cd, dcm.updt_applctx = reqinfo->updt_applctx,
   dcm.updt_cnt = (dcm.updt_cnt+ 1), dcm.updt_dt_tm = cnvtdatetime(sysdate), dcm.updt_id = reqinfo->
   updt_id,
   dcm.updt_task = reqinfo->updt_task
  PLAN (d
   WHERE (copy_requestin->list_0[d.seq].exists_ind=1))
   JOIN (dcm
   WHERE (dcm.parent_table=copy_requestin->list_0[d.seq].parent_table)
    AND (dcm.child_table=copy_requestin->list_0[d.seq].child_table)
    AND (dcm.child_column=copy_requestin->list_0[d.seq].child_column))
  WITH nocounter
 ;end update
 IF (error(errmsg,0) > 0)
  ROLLBACK
  SET readme_data->status = "F"
  SET readme_data->message = concat("Failed to update rows on DM_CMB_METADATA: ",errmsg)
  GO TO exit_script
 ENDIF
 SET readme_data->status = "S"
 SET readme_data->message = "Success: batch data loaded successfully"
#exit_script
END GO
