CREATE PROGRAM dm_ins_cmb_children_main:dba
 SELECT INTO "nl:"
  "x"
  FROM dm_cmb_children dcc
  WITH maxqual(dcc,1)
 ;end select
 IF (curqual=0)
  SELECT INTO "nl:"
   "x"
   FROM dm_info di
   WHERE di.info_domain="DM2_SCHEMA_INSTANCE"
   WITH maxqual(di,1)
  ;end select
  IF (curqual > 0)
   INSERT  FROM dm_cmb_children
    (parent_table, child_table, child_column,
    child_pk, create_dt_tm, child_cons_name,
    updt_id, updt_dt_tm, updt_task,
    updt_applctx, updt_cnt)(SELECT
     dc.parent_table_name, dc.table_name, dcc.column_name,
     dcc2.column_name, cnvtdatetime(sysdate), dc.constraint_name,
     reqinfo->updt_id, cnvtdatetime(sysdate), reqinfo->updt_task,
     reqinfo->updt_applctx, 0
     FROM dm_afd_cons_columns dcc2,
      dm_afd_constraints dc2,
      dm_afd_cons_columns dcc,
      dm_afd_constraints dc
     WHERE dc.parent_table_name IN ("ENCOUNTER", "PERSON")
      AND dc.constraint_type="R"
      AND (dc.alpha_feature_nbr=
     (SELECT
      max(dat.alpha_feature_nbr)
      FROM dm_afd_tables dat
      WHERE (dat.schema_instance=
      (SELECT
       di.info_number
       FROM dm_info di
       WHERE di.info_domain="DM2_SCHEMA_INSTANCE"
        AND di.info_name=dat.table_name))
       AND dat.table_name=dc.table_name))
      AND dc.constraint_name=dcc.constraint_name
      AND dc.alpha_feature_nbr=dcc.alpha_feature_nbr
      AND dc.table_name=dcc.table_name
      AND dc2.alpha_feature_nbr=dcc2.alpha_feature_nbr
      AND dc2.constraint_type="P"
      AND dc2.constraint_name=dcc2.constraint_name
      AND dc.table_name=dc2.table_name
      AND dc.alpha_feature_nbr=dc2.alpha_feature_nbr
      AND dcc2.position=1
      AND dcc.position=1
      AND  EXISTS (
     (SELECT
      "x"
      FROM user_tables ut
      WHERE ut.table_name=dc.table_name))
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM dm_info di2
      WHERE di2.info_domain="OBSOLETE_CONSTRAINT"
       AND di2.info_char="CONSTRAINT"
       AND di2.info_name=dc.constraint_name))))
   ;end insert
  ELSE
   SET target_schema_date = cnvtdatetime("01-JAN-1999")
   SELECT INTO "nl:"
    FROM dm_schema_version dsv,
     dm_environment de
    WHERE (de.environment_id= $1)
     AND de.schema_version=dsv.schema_version
    DETAIL
     target_schema_date = dsv.schema_date
    WITH nocounter
   ;end select
   INSERT  FROM dm_cmb_children
    (parent_table, child_table, child_column,
    child_pk, create_dt_tm, child_cons_name,
    updt_id, updt_dt_tm, updt_task,
    updt_applctx, updt_cnt)(SELECT
     dc.parent_table_name, dc.table_name, dcc.column_name,
     dcc2.column_name, cnvtdatetime(sysdate), dc.constraint_name,
     reqinfo->updt_id, cnvtdatetime(sysdate), reqinfo->updt_task,
     reqinfo->updt_applctx, 0
     FROM dm_cons_columns dcc2,
      dm_constraints dc2,
      dm_cons_columns dcc,
      dm_constraints dc
     WHERE dc.parent_table_name IN ("ENCOUNTER", "PERSON")
      AND dc.constraint_type="R"
      AND dc.schema_date=cnvtdatetime(target_schema_date)
      AND dc.constraint_name=dcc.constraint_name
      AND dc.schema_date=dcc.schema_date
      AND dc.table_name=dcc.table_name
      AND dc2.schema_date=dcc2.schema_date
      AND dc2.constraint_type="P"
      AND dc2.constraint_name=dcc2.constraint_name
      AND dc.table_name=dc2.table_name
      AND dc.schema_date=dc2.schema_date
      AND dcc2.position=1
      AND dcc.position=1
      AND  EXISTS (
     (SELECT
      "x"
      FROM user_tables ut
      WHERE ut.table_name=dc.table_name))
      AND  NOT ( EXISTS (
     (SELECT
      "x"
      FROM dm_info di2
      WHERE di2.info_domain="OBSOLETE_CONSTRAINT"
       AND di2.info_char="CONSTRAINT"
       AND di2.info_name=dc.constraint_name))))
   ;end insert
  ENDIF
  COMMIT
  CALL echo(concat("Inserted ",build(curqual)," rows."))
 ENDIF
 EXECUTE dm_ins_user_cmb_children
END GO
