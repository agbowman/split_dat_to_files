CREATE PROGRAM dm_merge_batch:dba
 IF ((validate(env_info->env_target_id,- (1))=- (1)))
  SET trace = recpersist
  RECORD env_info(
    1 env_target_id = i4
    1 env_source_id = i4
  )
  SELECT INTO "nl:"
   FROM dm_info dm
   WHERE dm.info_domain="DATA MANAGEMENT"
    AND dm.info_name="DM_ENV_ID"
   DETAIL
    env_info->env_target_id = dm.info_number
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM dm_info@loc_mrg_link dm
   WHERE dm.info_domain="DATA MANAGEMENT"
    AND dm.info_name="DM_ENV_ID"
   DETAIL
    env_info->env_source_id = dm.info_number
   WITH nocounter
  ;end select
  SET trace = norecpersist
 ENDIF
 RECORD request(
   1 qual[*]
     2 to_value = f8
     2 from_value = f8
     2 from_rowid = vc
     2 to_rowid = vc
     2 row_index = i4
     2 merge_id = f8
   1 table_name = vc
   1 column_name = vc
   1 children_ind = i4
   1 restrict_clause = vc
   1 env_source_id = i4
   1 env_target_id = i4
   1 ref_domain_name = vc
   1 master_ind = i2
   1 code_set = i2
   1 audit_ind = i2
   1 db_link = c20
 )
 SET stat = alterlist(request->qual,1)
 SET request->audit_ind = 0
 SET request->db_link = "LOC_MRG_LINK"
 SET request->env_source_id = env_info->env_source_id
 SET request->env_target_id = env_info->env_target_id
 SET request->qual[1].merge_id = 0
 SET request->qual[1].from_rowid =  $1
 SET request->qual[1].to_rowid =  $2
 SET request->table_name =  $3
 SET request->ref_domain_name =  $4
 SET request->master_ind =  $5
 IF ((validate(reply->qual[1].merge_id,- (1))=- (1)))
  RECORD reply(
    1 qual[*]
      2 from_value = f8
      2 to_value = f8
      2 from_rowid = vc
      2 old_merge_id = f8
      2 target_rowid = vc
      2 merge_id = f8
      2 row_index = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 sourceobjectname = c15
        3 sourceobjectqual = i4
        3 sourceobjectvalue = c50
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c50
        3 sub_event_dt_tm = di8
      2 err_num = i4
      2 err_msg = c255
  )
 ENDIF
 EXECUTE dm_merge_action_add
 SET request->qual[1].merge_id = reply->qual[1].merge_id
 CALL echo(concat("merge_id = ",cnvtstring(reply->qual[1].merge_id)))
 EXECUTE dm_merge_table
END GO
