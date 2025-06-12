CREATE PROGRAM dm_refresh_purge_template:dba
 FREE SET reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE v_env_id = f8 WITH noconstant(0.0)
 SELECT INTO "nl:"
  b.environment_id
  FROM dm_info a,
   dm_environment b
  WHERE a.info_name="DM_ENV_ID"
   AND a.info_domain="DATA MANAGEMENT"
   AND a.info_number=b.environment_id
  DETAIL
   v_env_id = b.environment_id
  WITH nocounter
 ;end select
 RECORD purge(
   1 data[*]
     2 template_nbr = f8
     2 feature_nbr = f8
     2 schema_dt_tm = dq8
 )
 SELECT INTO "nl:"
  pse.proj_name, pse.feature, pse.schema_date
  FROM dm_project_status_env pse
  WHERE pse.environment_id=v_env_id
   AND pse.proj_type="PURGE TEMPLATE"
   AND (list(pse.proj_name,pse.schema_date)=
  (SELECT
   pse2.proj_name, max(pse2.schema_date)
   FROM dm_project_status_env pse2
   WHERE pse2.environment_id=pse.environment_id
    AND pse2.proj_type=pse.proj_type
    AND pse2.dm_status = null
    AND  NOT ( EXISTS (
   (SELECT
    "X"
    FROM dm_project_status_env pse3
    WHERE pse3.environment_id=pse2.environment_id
     AND pse3.proj_type=pse2.proj_type
     AND pse3.proj_name=pse2.proj_name
     AND pse3.dm_status="RUNNING")))
   GROUP BY pse2.proj_name))
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt = (cnt+ 1)
   IF (mod(cnt,10)=1)
    stat = alterlist(purge->data,(cnt+ 9))
   ENDIF
   purge->data[cnt].template_nbr = cnvtreal(pse.proj_name), purge->data[cnt].feature_nbr = pse
   .feature, purge->data[cnt].schema_dt_tm = pse.schema_date
  FOOT REPORT
   stat = alterlist(purge->data,cnt)
  WITH nocounter, forupdatewait(pse)
 ;end select
 IF (size(purge->data,5) > 0)
  UPDATE  FROM dm_project_status_env pse,
    (dummyt d  WITH seq = value(size(purge->data,5)))
   SET pse.dm_status = "RUNNING"
   PLAN (d)
    JOIN (pse
    WHERE (cnvtreal(pse.proj_name)=purge->data[d.seq].template_nbr)
     AND pse.proj_type="PURGE TEMPLATE"
     AND pse.environment_id=v_env_id
     AND ((pse.dm_status = null) OR (pse.dm_status="FAILED")) )
   WITH nocounter
  ;end update
  COMMIT
 ENDIF
 FOR (prg_ndx = 1 TO size(purge->data,5))
   DELETE  FROM dm_purge_template pt
    WHERE (pt.template_nbr=purge->data[prg_ndx].template_nbr)
     AND (pt.feature_nbr=purge->data[prg_ndx].feature_nbr)
   ;end delete
   INSERT  FROM dm_purge_template pt
    (pt.template_nbr, pt.feature_nbr, pt.schema_dt_tm,
    name, pt.program_str, pt.active_ind,
    pt.updt_id, pt.updt_dt_tm, pt.updt_task,
    pt.updt_cnt, pt.updt_applctx)(SELECT
     apt.template_nbr, purge->data[prg_ndx].feature_nbr, apt.schema_dt_tm,
     apt.name, apt.program_str, apt.active_ind,
     reqinfo->updt_id, cnvtdatetime(curdate,curtime3), reqinfo->updt_task,
     1, reqinfo->updt_applctx
     FROM dm_adm_purge_template apt
     WHERE (apt.template_nbr=purge->data[prg_ndx].template_nbr)
      AND apt.schema_dt_tm=cnvtdatetime(purge->data[prg_ndx].schema_dt_tm))
   ;end insert
   IF (curqual=0)
    ROLLBACK
    UPDATE  FROM dm_project_status_env pse
     SET pse.dm_status = "FAILED", pse.err_code = 98
     WHERE (cnvtreal(pse.proj_name)=purge->data[prg_ndx].template_nbr)
      AND pse.schema_date <= cnvtdatetime(purge->data[prg_ndx].schema_dt_tm)
      AND pse.environment_id=v_env_id
      AND pse.proj_type="PURGE TEMPLATE"
      AND pse.dm_status="RUNNING"
    ;end update
   ELSE
    DELETE  FROM dm_purge_token pt
     WHERE (pt.template_nbr=purge->data[prg_ndx].template_nbr)
      AND (pt.feature_nbr=purge->data[prg_ndx].feature_nbr)
    ;end delete
    INSERT  FROM dm_purge_token pt
     (template_nbr, feature_nbr, token_str,
     prompt_str, data_type_flag, schema_dt_tm,
     updt_id, updt_dt_tm, updt_task,
     updt_cnt, updt_applctx)(SELECT
      apt.template_nbr, purge->data[prg_ndx].feature_nbr, apt.token_str,
      apt.prompt_str, apt.data_type_flag, apt.schema_dt_tm,
      reqinfo->updt_id, cnvtdatetime(curdate,curtime3), reqinfo->updt_task,
      0, reqinfo->updt_applctx
      FROM dm_adm_purge_token apt
      WHERE (apt.template_nbr=purge->data[prg_ndx].template_nbr)
       AND apt.schema_dt_tm=cnvtdatetime(purge->data[prg_ndx].schema_dt_tm))
    ;end insert
    DELETE  FROM dm_purge_table pt
     WHERE (pt.template_nbr=purge->data[prg_ndx].template_nbr)
      AND (pt.feature_nbr=purge->data[prg_ndx].feature_nbr)
    ;end delete
    INSERT  FROM dm_purge_table pt
     (template_nbr, feature_nbr, schema_dt_tm,
     parent_table, child_table, child_where,
     purge_type_flag, parent_col1, child_col1,
     parent_col2, child_col2, parent_col3,
     child_col3, parent_col4, child_col4,
     parent_col5, child_col5, updt_id,
     updt_dt_tm, updt_task, updt_cnt,
     updt_applctx)(SELECT
      apt.template_nbr, purge->data[prg_ndx].feature_nbr, apt.schema_dt_tm,
      apt.parent_table, apt.child_table, apt.child_where,
      apt.purge_type_flag, apt.parent_col1, apt.child_col1,
      apt.parent_col2, apt.child_col2, apt.parent_col3,
      apt.child_col3, apt.parent_col4, apt.child_col4,
      apt.parent_col5, apt.child_col5, reqinfo->updt_id,
      cnvtdatetime(curdate,curtime3), reqinfo->updt_task, 0,
      reqinfo->updt_applctx
      FROM dm_adm_purge_table apt
      WHERE (apt.template_nbr=purge->data[prg_ndx].template_nbr)
       AND apt.schema_dt_tm=cnvtdatetime(purge->data[prg_ndx].schema_dt_tm))
    ;end insert
    COMMIT
    UPDATE  FROM dm_project_status_env pse
     SET pse.dm_status = "SUCCESS"
     WHERE (cnvtreal(pse.proj_name)=purge->data[prg_ndx].template_nbr)
      AND pse.environment_id=v_env_id
      AND pse.proj_type="PURGE TEMPLATE"
      AND pse.dm_status="RUNNING"
      AND pse.schema_date <= cnvtdatetime(purge->data[prg_ndx].schema_dt_tm)
    ;end update
    COMMIT
   ENDIF
 ENDFOR
 COMMIT
 SET reply->status_data.status = "S"
 FREE RECORD purge
END GO
