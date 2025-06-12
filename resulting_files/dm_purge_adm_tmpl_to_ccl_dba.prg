CREATE PROGRAM dm_purge_adm_tmpl_to_ccl:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET c_df = "YYYYMMDDHHMMSScc;;d"
 SET c_del_high_log = 1
 SET c_del_dtl_log = 2
 SET c_audit = 3
 SET c_ptf_delete = 1
 SET c_ptf_update = 2
 SET c_active = 1
 SET c_inactive = 2
 SET c_tmpl_changed = 3
 SET c_sf_success = 1
 SET c_sf_failed = 2
 DECLARE v_schema_date = vc
 SET reply->status_data.status = "F"
 CALL echo("/* Start of PURGE TEMPLATE changes/additions */")
 FOR (t_ndx = 1 TO size(request->data,5))
   SET v_schema_date = " "
   SET v_template_nbr = request->data[t_ndx].template_nbr
   SET v_feature_nbr = request->data[t_ndx].feature_nbr
   SELECT INTO "nl:"
    schema_date = format(apt.schema_dt_tm,c_df), apt.name, apt.program_str,
    apt.active_ind
    FROM dm_adm_purge_template apt
    WHERE apt.feature_nbr=v_feature_nbr
     AND apt.template_nbr=v_template_nbr
    DETAIL
     v_schema_date = schema_date,
     CALL echo(concat("insert into dm_adm_purge_template pt"," set pt.template_nbr = ",trim(
       cnvtstring(v_template_nbr)),","," pt.feature_nbr = ",
      trim(cnvtstring(v_feature_nbr)),",",' pt.schema_dt_tm = cnvtdatetime(cnvtdate2(substring(1,8,"',
      trim(v_schema_date,3),'"),"YYYYMMDD"),cnvtint(substring(9,6,"',
      trim(v_schema_date,3),'"))),',' pt.name = "',trim(replace(apt.name,'"',"'",0)),'",',
      ' pt.program_str = "',trim(replace(apt.program_str,'"',"'",0)),'",'," pt.active_ind = ",trim(
       cnvtstring(apt.active_ind)),
      ","," pt.updt_task = reqinfo->updt_task,"," pt.updt_id = reqinfo->updt_id,",
      " pt.updt_applctx = reqinfo->updt_applctx,"," pt.updt_dt_tm = cnvtdatetime(curdate,curtime3),",
      " pt.updt_cnt = 0 go  "))
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SELECT INTO "nl:"
     apt.token_str, apt.prompt_str, apt.data_type_flag
     FROM dm_adm_purge_token apt
     WHERE apt.feature_nbr=v_feature_nbr
      AND apt.template_nbr=v_template_nbr
     DETAIL
      CALL echo(concat("insert into dm_adm_purge_token pt"," set pt.template_nbr = ",trim(cnvtstring(
         v_template_nbr)),","," pt.feature_nbr = ",
       trim(cnvtstring(v_feature_nbr)),",",' pt.token_str = "',trim(replace(apt.token_str,'"',"'",0)),
       '",',
       ' pt.prompt_str = "',trim(replace(apt.prompt_str,'"',"'",0)),'",'," pt.data_type_flag = ",trim
       (cnvtstring(apt.data_type_flag)),
       ",",' pt.schema_dt_tm = cnvtdatetime(cnvtdate2(substring(1,8,"',trim(v_schema_date,3),
       '"),"YYYYMMDD"),cnvtint(substring(9,6,"',trim(v_schema_date,3),
       '"))),'," pt.updt_task = reqinfo->updt_task,"," pt.updt_id = reqinfo->updt_id,",
       " pt.updt_applctx = reqinfo->updt_applctx,"," pt.updt_dt_tm = cnvtdatetime(curdate,curtime3),",
       " pt.updt_cnt = 0 go  "))
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     apt.parent_table, apt.child_table, apt.child_where,
     apt.purge_type_flag, apt.parent_col1, apt.child_col1,
     apt.parent_col2, apt.child_col2, apt.parent_col3,
     apt.child_col3, apt.parent_col4, apt.child_col4,
     apt.parent_col5, apt.child_col5
     FROM dm_adm_purge_table apt
     WHERE apt.feature_nbr=v_feature_nbr
      AND apt.template_nbr=v_template_nbr
     DETAIL
      CALL echo(concat("insert into dm_adm_purge_table pt"," set pt.template_nbr = ",trim(cnvtstring(
         v_template_nbr)),","," pt.feature_nbr = ",
       trim(cnvtstring(v_feature_nbr)),",",' pt.parent_table = "',trim(replace(apt.parent_table,'"',
         "'",0)),'",',
       ' pt.child_table = "',trim(replace(apt.child_table,'"',"'",0)),'",',' pt.child_where = "',trim
       (replace(apt.child_where,'"',"'",0)),
       '",'," pt.purge_type_flag = ",trim(cnvtstring(apt.purge_type_flag)),",",' pt.parent_col1 = "',
       trim(replace(apt.parent_col1,'"',"'",0)),'",',' pt.child_col1 = "',trim(replace(apt.child_col1,
         '"',"'",0)),'",',
       ' pt.parent_col2 = "',trim(replace(apt.parent_col2,'"',"'",0)),'",',' pt.child_col2 = "',trim(
        replace(apt.child_col2,'"',"'",0)),
       '",',' pt.parent_col3 = "',trim(replace(apt.parent_col3,'"',"'",0)),'",',' pt.child_col3 = "',
       trim(replace(apt.child_col3,'"',"'",0)),'",',' pt.parent_col4 = "',trim(replace(apt
         .parent_col4,'"',"'",0)),'",',
       ' pt.child_col4 = "',trim(replace(apt.child_col4,'"',"'",0)),'",',' pt.parent_col5 = "',trim(
        replace(apt.parent_col5,'"',"'",0)),
       '",',' pt.child_col5 = "',trim(replace(apt.child_col5,'"',"'",0)),'",',
       ' pt.schema_dt_tm = cnvtdatetime(cnvtdate2(substring(1,8,"',
       trim(v_schema_date,3),'"),"YYYYMMDD"),cnvtint(substring(9,6,"',trim(v_schema_date,3),'"))),',
       " pt.updt_task = reqinfo->updt_task,",
       " pt.updt_id = reqinfo->updt_id,"," pt.updt_applctx = reqinfo->updt_applctx,",
       " pt.updt_dt_tm = cnvtdatetime(curdate,curtime3),"," pt.updt_cnt = 0 go  "))
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 CALL echo("/* End of PURGE TEMPLATE changes/additions */")
 SET reply->status_data.status = "S"
END GO
