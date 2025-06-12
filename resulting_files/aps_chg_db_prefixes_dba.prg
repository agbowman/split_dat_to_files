CREATE PROGRAM aps_chg_db_prefixes:dba
 RECORD req_cd_value(
   1 cd_value_list[*]
     2 action_type_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
 )
 RECORD rep_cd_value(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
     2 code_value = f8
     2 cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET y = 1
#start_of_prefixes
 IF (y != 1)
  ROLLBACK
 ENDIF
 FOR (y = y TO request->group_qual[x].pre_cnt)
  IF ((request->group_qual[x].prefix_qual[y].pre_act_ind="a"))
   IF ((request->group_qual[x].prefix_qual[y].accession_format_cd=0.0))
    SET stat = alterlist(req_cd_value->cd_value_list,1)
    SET req_cd_value->cd_value_list[1].action_type_flag = 1
    SET req_cd_value->cd_value_list[1].code_set = 2057
    SET req_cd_value->cd_value_list[1].description = request->group_qual[x].prefix_qual[y].
    prefix_name
    SET req_cd_value->cd_value_list[1].display = request->group_qual[x].prefix_qual[y].prefix_name
    SET req_cd_value->cd_value_list[1].display_key = cnvtupper(cnvtalphanum(request->group_qual[x].
      prefix_qual[y].prefix_name))
    SET req_cd_value->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE core_ens_cd_value  WITH replace("REQUEST",req_cd_value), replace("REPLY",rep_cd_value)
    SET trace = norecpersist
    IF ((rep_cd_value->status_data.status != "S"))
     CALL handle_errors("INSERT","F","TABLE","CODE_VALUE, 2057")
     SET y += 1
     GO TO start_of_prefixes
    ELSE
     SET next_acc_code = rep_cd_value->qual[1].code_value
    ENDIF
   ELSE
    SET next_acc_code = request->group_qual[x].prefix_qual[y].accession_format_cd
   ENDIF
   INSERT  FROM accession_assign_xref aax
    SET aax.site_prefix_cd = request->group_qual[x].site_cd, aax.accession_format_cd = next_acc_code,
     aax.accession_assignment_pool_id = request->group_qual[x].group_cd,
     aax.activity_type_cd = ap_act_code, aax.updt_dt_tm = cnvtdatetime(curdate,curtime), aax.updt_id
      = reqinfo->updt_id,
     aax.updt_task = reqinfo->updt_task, aax.updt_applctx = reqinfo->updt_applctx, aax.updt_cnt = 0
    WITH counter
   ;end insert
   SET request->group_qual[x].prefix_qual[y].accession_format_cd = next_acc_code
   IF (curqual=0)
    CALL handle_errors("NEXTVAL","F","SEQUENCE","ACCESSION_ASSIGN_XREF")
    SET y += 1
    GO TO start_of_prefixes
   ENDIF
   SELECT INTO "nl:"
    seq_nbr = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     next_pre_code = cnvtreal(seq_nbr)
    WITH format, counter
   ;end select
   IF (curqual=0)
    CALL handle_errors("NEXTVAL","F","SEQUENCE","REFERENCE_SEQ")
    SET y += 1
    GO TO start_of_prefixes
   ENDIF
   INSERT  FROM ap_prefix ap
    SET ap.prefix_id = next_pre_code, ap.group_id = request->group_qual[x].group_cd, ap.prefix_name
      = request->group_qual[x].prefix_qual[y].prefix_name,
     ap.prefix_desc = request->group_qual[x].prefix_qual[y].prefix_desc, ap.case_type_cd = request->
     group_qual[x].prefix_qual[y].case_type_cd, ap.order_catalog_cd = request->group_qual[x].
     prefix_qual[y].order_catalog_cd,
     ap.default_proc_catalog_cd = request->group_qual[x].prefix_qual[y].task_default_cd, ap
     .initiate_protocol_ind = request->group_qual[x].prefix_qual[y].initiate_tasks_ind, ap.active_ind
      = request->group_qual[x].prefix_qual[y].active_ind,
     ap.site_cd = request->group_qual[x].site_cd, ap.accession_format_cd = request->group_qual[x].
     prefix_qual[y].accession_format_cd, ap.service_resource_cd = request->group_qual[x].prefix_qual[
     y].service_resource_cd,
     ap.interface_flag = request->group_qual[x].prefix_qual[y].interface_flag, ap
     .tracking_service_resource_cd = request->group_qual[x].prefix_qual[y].
     tracking_service_resource_cd, ap.imaging_interface_ind = request->group_qual[x].prefix_qual[y].
     imaging_interface_ind,
     ap.imaging_service_resource_cd = request->group_qual[x].prefix_qual[y].
     imaging_service_resource_cd, ap.updt_dt_tm = cnvtdatetime(curdate,curtime), ap.updt_id = reqinfo
     ->updt_id,
     ap.updt_task = reqinfo->updt_task, ap.updt_applctx = reqinfo->updt_applctx, ap.updt_cnt = 0
    WITH counter
   ;end insert
   IF (curqual=0)
    CALL handle_errors("INSERT","F","TABLE","AP_PREFIX")
    SET y += 1
    GO TO start_of_prefixes
   ENDIF
   SET request->group_qual[x].prefix_qual[y].prefix_cd = next_pre_code
  ELSEIF ((request->group_qual[x].prefix_qual[y].pre_act_ind="c"))
   SELECT INTO "nl:"
    ap.*
    FROM ap_prefix ap
    WHERE (request->group_qual[x].prefix_qual[y].prefix_cd=ap.prefix_id)
    DETAIL
     cur_updt_cnt = ap.updt_cnt
    WITH forupdate(ap)
   ;end select
   IF (curqual=0)
    CALL handle_errors("SELECT","F","TABLE","AP_PREFIX")
    SET y += 1
    GO TO start_of_prefixes
   ELSE
    IF ((request->group_qual[x].prefix_qual[y].ap_updt_cnt != cur_updt_cnt))
     CALL handle_errors("LOCK","F","TABLE","AP_PREFIX")
     SET y += 1
     GO TO start_of_prefixes
    ELSE
     SET cur_updt_cnt += 1
     UPDATE  FROM ap_prefix ap
      SET ap.prefix_id = request->group_qual[x].prefix_qual[y].prefix_cd, ap.group_id = request->
       group_qual[x].group_cd, ap.prefix_name = request->group_qual[x].prefix_qual[y].prefix_name,
       ap.prefix_desc = request->group_qual[x].prefix_qual[y].prefix_desc, ap.case_type_cd = request
       ->group_qual[x].prefix_qual[y].case_type_cd, ap.order_catalog_cd = request->group_qual[x].
       prefix_qual[y].order_catalog_cd,
       ap.default_proc_catalog_cd = request->group_qual[x].prefix_qual[y].task_default_cd, ap
       .initiate_protocol_ind = request->group_qual[x].prefix_qual[y].initiate_tasks_ind, ap
       .service_resource_cd = request->group_qual[x].prefix_qual[y].service_resource_cd,
       ap.interface_flag = request->group_qual[x].prefix_qual[y].interface_flag, ap
       .tracking_service_resource_cd = request->group_qual[x].prefix_qual[y].
       tracking_service_resource_cd, ap.imaging_interface_ind = request->group_qual[x].prefix_qual[y]
       .imaging_interface_ind,
       ap.imaging_service_resource_cd = request->group_qual[x].prefix_qual[y].
       imaging_service_resource_cd, ap.active_ind = request->group_qual[x].prefix_qual[y].active_ind,
       ap.updt_dt_tm = cnvtdatetime(curdate,curtime),
       ap.updt_id = reqinfo->updt_id, ap.updt_task = reqinfo->updt_task, ap.updt_applctx = reqinfo->
       updt_applctx,
       ap.updt_cnt = cur_updt_cnt
      WHERE (request->group_qual[x].prefix_qual[y].prefix_cd=ap.prefix_id)
      WITH counter
     ;end update
     IF (curqual=0)
      CALL handle_errors("UPDATE","F","TABLE","AP_PREFIX")
      SET y += 1
      GO TO start_of_prefixes
     ENDIF
    ENDIF
   ENDIF
  ENDIF
  EXECUTE aps_chg_db_schemes
 ENDFOR
 GO TO end_of_prefixes
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET error_cnt += 1
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
#end_of_prefixes
END GO
