CREATE PROGRAM dm_ins_user_cmb_children:dba
 FREE SET c
 FREE RECORD c
 RECORD c(
   1 child_cnt = i4
   1 qual[*]
     2 parent_table = vc
     2 child_table = vc
     2 child_column = vc
     2 child_cons_name = vc
     2 child_pk = vc
     2 exists_ind = i4
     2 pk_exists_ind = i4
     2 update_ind = i4
 )
 SET c->child_cnt = 0
 FREE RECORD diu_trig_tabs
 RECORD diu_trig_tabs(
   1 tab_cnt = i4
   1 tabs[*]
     2 table_name = vc
     2 drop_ind = i2
 )
 IF ( NOT (validate(ct_error,0)))
  FREE RECORD ct_error
  RECORD ct_error(
    1 message = vc
    1 err_ind = i2
  )
 ENDIF
 DECLARE diu_cnt = i4 WITH protect, noconstant(0)
 DECLARE diu_ndx = i4 WITH protect, noconstant(0)
 SET diu_err_msg = fillstring(132," ")
 DECLARE diu_check_admin = i2 WITH protect, noconstant(0)
 DECLARE diu_sub_query = vc WITH protect, noconstant("")
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="COMBINE_TRIGGER_TYPE_PERSON"
  WITH nocounter, maxqual(di,1)
 ;end select
 IF (curqual=0)
  SET diu_check_admin = 1
 ENDIF
 IF (diu_check_admin=1)
  SELECT INTO "nl:"
   FROM dm_tables_doc dtd
   WITH nocounter, maxqual(dtd,1)
  ;end select
  CALL err_chk(0)
 ENDIF
 IF (diu_check_admin=1)
  SET diu_sub_query =
  "exists(select 'x' from dm_tables_doc dtd where dtd.table_name = dcc.table_name)"
 ELSE
  SET diu_sub_query = concat(
   "exists(select 'x' from dm_info di where di.info_domain = 'COMBINE_TRIGGER_TYPE_PERSON' ",
   " and di.info_name = dcc.table_name)")
 ENDIF
 SELECT INTO "nl:"
  FROM user_cons_columns dcc,
   user_constraints dc,
   user_constraints uc
  WHERE uc.table_name IN ("ENCOUNTER", "PERSON")
   AND uc.constraint_type="P"
   AND uc.constraint_name=dc.r_constraint_name
   AND findstring("$",dc.table_name)=0
   AND dc.constraint_type="R"
   AND dc.constraint_name=dcc.constraint_name
   AND dc.table_name=dcc.table_name
   AND dcc.position=1
   AND parser(diu_sub_query)
  DETAIL
   c->child_cnt += 1, stat = alterlist(c->qual,c->child_cnt), c->qual[c->child_cnt].parent_table = uc
   .table_name,
   c->qual[c->child_cnt].child_table = dc.table_name, c->qual[c->child_cnt].child_column = dcc
   .column_name, c->qual[c->child_cnt].child_cons_name = dcc.constraint_name,
   c->qual[c->child_cnt].exists_ind = 0, c->qual[c->child_cnt].pk_exists_ind = 0
  WITH nocounter
 ;end select
 CALL err_chk(0)
 SELECT INTO "nl:"
  FROM dm_cmb_children dcc,
   (dummyt d  WITH seq = value(c->child_cnt))
  PLAN (d)
   JOIN (dcc
   WHERE (dcc.parent_table=c->qual[d.seq].parent_table)
    AND (dcc.child_table=c->qual[d.seq].child_table)
    AND (dcc.child_column=c->qual[d.seq].child_column))
  DETAIL
   c->qual[d.seq].exists_ind = 1
   IF ((c->qual[d.seq].child_cons_name != dcc.child_cons_name))
    c->qual[d.seq].update_ind = 1,
    CALL echo(build("updated table:",dcc.child_table))
   ENDIF
  WITH nocounter
 ;end select
 CALL err_chk(0)
 SELECT INTO "nl:"
  FROM user_cons_columns dcc,
   user_constraints dc,
   (dummyt d  WITH seq = value(c->child_cnt))
  PLAN (d)
   JOIN (dc
   WHERE (c->qual[d.seq].child_table=dc.table_name)
    AND dc.constraint_type="P")
   JOIN (dcc
   WHERE dc.table_name=dcc.table_name
    AND dc.constraint_name=dcc.constraint_name
    AND dcc.position=1)
  DETAIL
   c->qual[d.seq].child_pk = dcc.column_name, c->qual[d.seq].pk_exists_ind = 1
  WITH nocounter
 ;end select
 CALL err_chk(0)
 UPDATE  FROM dm_cmb_children dcc,
   (dummyt d  WITH seq = value(c->child_cnt))
  SET dcc.child_cons_name = c->qual[d.seq].child_cons_name, dcc.updt_dt_tm = cnvtdatetime(sysdate),
   dcc.updt_cnt = (dcc.updt_cnt+ 1),
   dcc.updt_id = reqinfo->updt_id, dcc.updt_task = reqinfo->updt_task, dcc.updt_applctx = reqinfo->
   updt_applctx
  PLAN (d
   WHERE (c->qual[d.seq].update_ind=1)
    AND (c->qual[d.seq].pk_exists_ind=1))
   JOIN (dcc
   WHERE (dcc.parent_table=c->qual[d.seq].parent_table)
    AND (dcc.child_table=c->qual[d.seq].child_table)
    AND (dcc.child_column=c->qual[d.seq].child_column))
  WITH nocounter
 ;end update
 INSERT  FROM dm_cmb_children dcc,
   (dummyt d  WITH seq = value(c->child_cnt))
  SET dcc.parent_table = c->qual[d.seq].parent_table, dcc.child_table = c->qual[d.seq].child_table,
   dcc.child_column = c->qual[d.seq].child_column,
   dcc.child_pk = c->qual[d.seq].child_pk, dcc.create_dt_tm = cnvtdatetime(sysdate), dcc
   .child_cons_name = c->qual[d.seq].child_cons_name,
   dcc.updt_dt_tm = cnvtdatetime(sysdate), dcc.updt_cnt = 0, dcc.updt_id = reqinfo->updt_id,
   dcc.updt_task = reqinfo->updt_task, dcc.updt_applctx = reqinfo->updt_applctx
  PLAN (d
   WHERE (c->qual[d.seq].pk_exists_ind=1)
    AND (c->qual[d.seq].exists_ind=0))
   JOIN (dcc)
  WITH nocounter
 ;end insert
 CALL err_chk(0)
 CALL echo(concat("Inserted ",build(curqual)," rows."))
 SET cmb_last_updt = cnvtdatetime(sysdate)
 UPDATE  FROM dm_info
  SET info_date = cnvtdatetime(cmb_last_updt), updt_dt_tm = cnvtdatetime(sysdate), updt_applctx =
   reqinfo->updt_applctx,
   updt_cnt = (updt_cnt+ 1), updt_id = reqinfo->updt_id, updt_task = reqinfo->updt_task
  WHERE info_domain="DATA MANAGEMENT"
   AND info_name="CMB_LAST_UPDT"
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM dm_info
   SET info_domain = "DATA MANAGEMENT", info_name = "CMB_LAST_UPDT", info_date = cnvtdatetime(
     cmb_last_updt),
    info_char = null, info_number = null, info_long_id = 0,
    updt_dt_tm = cnvtdatetime(sysdate), updt_applctx = reqinfo->updt_applctx, updt_cnt = 0,
    updt_id = reqinfo->updt_id, updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
 ENDIF
 CALL err_chk(0)
 FREE RECORD hh_delete
 RECORD hh_delete(
   1 cnt = i4
   1 qual[*]
     2 parent_table = c30
     2 child_table = c30
     2 child_column = c30
 )
 SET hh_delete->cnt = 0
 IF (diu_check_admin=1)
  SET diu_sub_query = "exists(select 'x' from dm_tables_doc dtd where dtd.table_name = b.table_name)"
 ELSE
  SET diu_sub_query = concat(
   "exists(select 'x' from dm_info di where di.info_domain = 'COMBINE_TRIGGER_TYPE_PERSON' ",
   " and di.info_name = b.table_name)")
 ENDIF
 SELECT INTO "nl:"
  a.parent_table, a.child_table, a.child_column
  FROM dm_cmb_children a,
   user_constraints b,
   user_cons_columns c
  PLAN (a
   WHERE a.parent_table="PERSON")
   JOIN (b
   WHERE b.owner=currdbuser
    AND b.table_name=a.child_table
    AND b.r_constraint_name="XPKPRSNL"
    AND parser(diu_sub_query))
   JOIN (c
   WHERE c.owner=b.owner
    AND c.constraint_name=b.constraint_name
    AND c.column_name=a.child_column)
  DETAIL
   hh_delete->cnt += 1, stat = alterlist(hh_delete->qual,hh_delete->cnt), hh_delete->qual[hh_delete->
   cnt].parent_table = a.parent_table,
   hh_delete->qual[hh_delete->cnt].child_table = a.child_table, hh_delete->qual[hh_delete->cnt].
   child_column = a.child_column
  WITH nocounter
 ;end select
 CALL err_chk(0)
 IF ((hh_delete->cnt > 0))
  DELETE  FROM dm_cmb_children a,
    (dummyt d  WITH seq = value(hh_delete->cnt))
   SET a.seq = 1
   PLAN (d)
    JOIN (a
    WHERE (a.parent_table=hh_delete->qual[d.seq].parent_table)
     AND (a.child_table=hh_delete->qual[d.seq].child_table)
     AND (a.child_column=hh_delete->qual[d.seq].child_column))
   WITH nocounter
  ;end delete
  CALL err_chk(0)
  COMMIT
  CALL echo(concat("Removed ",build(curqual)," rows."))
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di,
   dm_cmb_children dcc
  PLAN (dcc
   WHERE dcc.parent_table="PERSON"
    AND  EXISTS (
   (SELECT
    "x"
    FROM dm_cmb_exception x
    WHERE x.child_entity=dcc.child_table
     AND x.parent_entity=dcc.parent_table
     AND x.operation_type="COMBINE"
     AND x.script_name="NONE"))
    AND  EXISTS (
   (SELECT
    "x"
    FROM user_triggers ut
    WHERE ut.table_name=dcc.child_table
     AND ut.trigger_name="TRG_PCMB*"))
    AND  NOT ( EXISTS (
   (SELECT
    "x"
    FROM dm_info di2
    WHERE di2.info_domain="OBSOLETE_OBJECT"
     AND di2.info_char="TABLE"
     AND di2.info_name=dcc.child_table))))
   JOIN (di
   WHERE di.info_domain="COMBINE_TRIGGER_TYPE_PERSON"
    AND di.info_name=dcc.child_table
    AND ((di.info_char = null) OR (((cnvtupper(trim(di.info_char,3)) IN ("AUTO", "DEFAULT")) OR (di
   .info_char <= char(32))) )) )
  DETAIL
   IF (locateval(diu_ndx,1,diu_trig_tabs->tab_cnt,dcc.child_table,diu_trig_tabs->tabs[diu_ndx].
    table_name)=0)
    diu_trig_tabs->tab_cnt += 1, stat = alterlist(diu_trig_tabs->tabs,diu_trig_tabs->tab_cnt),
    diu_trig_tabs->tabs[diu_trig_tabs->tab_cnt].table_name = dcc.child_table
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dm_info di,
   dm_cmb_children dcc
  PLAN (dcc
   WHERE dcc.parent_table="ENCOUNTER"
    AND  EXISTS (
   (SELECT
    "x"
    FROM dm_cmb_exception x
    WHERE x.child_entity=dcc.child_table
     AND x.parent_entity=dcc.parent_table
     AND x.operation_type="COMBINE"
     AND x.script_name="NONE"))
    AND  EXISTS (
   (SELECT
    "x"
    FROM user_triggers ut
    WHERE ut.table_name=dcc.child_table
     AND ut.trigger_name="TRG_ECMB*"))
    AND  NOT ( EXISTS (
   (SELECT
    "x"
    FROM dm_info di2
    WHERE di2.info_domain="OBSOLETE_OBJECT"
     AND di2.info_char="TABLE"
     AND di2.info_name=dcc.child_table))))
   JOIN (di
   WHERE di.info_domain="COMBINE_TRIGGER_TYPE_ENCNTR"
    AND di.info_name=dcc.child_table
    AND ((di.info_char = null) OR (((cnvtupper(trim(di.info_char,3)) IN ("AUTO", "DEFAULT")) OR (di
   .info_char <= char(32))) )) )
  DETAIL
   IF (locateval(diu_ndx,1,diu_trig_tabs->tab_cnt,dcc.child_table,diu_trig_tabs->tabs[diu_ndx].
    table_name)=0)
    diu_trig_tabs->tab_cnt += 1, stat = alterlist(diu_trig_tabs->tabs,diu_trig_tabs->tab_cnt),
    diu_trig_tabs->tabs[diu_trig_tabs->tab_cnt].table_name = dcc.child_table
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dm_info di,
   dm_cmb_children dcc
  PLAN (dcc
   WHERE dcc.parent_table="PERSON"
    AND  NOT ( EXISTS (
   (SELECT
    "x"
    FROM dm_cmb_exception x
    WHERE x.child_entity=dcc.child_table
     AND x.parent_entity=dcc.parent_table
     AND x.operation_type="COMBINE"
     AND x.script_name="NONE")))
    AND  NOT ( EXISTS (
   (SELECT
    "x"
    FROM user_triggers ut
    WHERE ut.table_name=dcc.child_table
     AND ut.trigger_name="TRG_PCMB*"
     AND ut.status="ENABLED"
     AND findstring(concat("new.",dcc.child_column),ut.when_clause) > 0))))
   JOIN (di
   WHERE di.info_domain="COMBINE_TRIGGER_TYPE_PERSON"
    AND di.info_name=dcc.child_table
    AND ((di.info_char = null) OR (((cnvtupper(trim(di.info_char,3)) IN ("AUTO", "DEFAULT")) OR (di
   .info_char <= char(32))) )) )
  DETAIL
   IF (locateval(diu_ndx,1,diu_trig_tabs->tab_cnt,dcc.child_table,diu_trig_tabs->tabs[diu_ndx].
    table_name)=0)
    diu_trig_tabs->tab_cnt += 1, stat = alterlist(diu_trig_tabs->tabs,diu_trig_tabs->tab_cnt),
    diu_trig_tabs->tabs[diu_trig_tabs->tab_cnt].table_name = dcc.child_table
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dm_info di,
   dm_cmb_children dcc
  PLAN (dcc
   WHERE dcc.parent_table="ENCOUNTER"
    AND  NOT ( EXISTS (
   (SELECT
    "x"
    FROM dm_cmb_exception x
    WHERE x.child_entity=dcc.child_table
     AND x.parent_entity=dcc.parent_table
     AND x.operation_type="COMBINE"
     AND x.script_name="NONE")))
    AND  NOT ( EXISTS (
   (SELECT
    "x"
    FROM user_triggers ut
    WHERE ut.table_name=dcc.child_table
     AND ut.trigger_name="TRG_ECMB*"
     AND ut.status="ENABLED"
     AND findstring(concat("new.",dcc.child_column),ut.when_clause) > 0))))
   JOIN (di
   WHERE di.info_domain="COMBINE_TRIGGER_TYPE_ENCNTR"
    AND di.info_name=dcc.child_table
    AND ((di.info_char = null) OR (((cnvtupper(trim(di.info_char,3)) IN ("AUTO", "DEFAULT")) OR (di
   .info_char <= char(32))) )) )
  DETAIL
   IF (locateval(diu_ndx,1,diu_trig_tabs->tab_cnt,dcc.child_table,diu_trig_tabs->tabs[diu_ndx].
    table_name)=0)
    diu_trig_tabs->tab_cnt += 1, stat = alterlist(diu_trig_tabs->tabs,diu_trig_tabs->tab_cnt),
    diu_trig_tabs->tabs[diu_trig_tabs->tab_cnt].table_name = dcc.child_table
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM dm_info di,
   user_tab_cols utc
  PLAN (utc
   WHERE ((utc.table_name="ADDRESS"
    AND utc.column_name="PARENT_ENTITY_ID") OR (((utc.table_name="PHONE"
    AND utc.column_name="PARENT_ENTITY_ID") OR (((utc.table_name="CHART_REQUEST_AUDIT"
    AND utc.column_name="DEST_PE_ID") OR (utc.table_name="CHART_REQUEST_AUDIT"
    AND utc.column_name="REQUESTOR_PE_ID")) )) ))
    AND  NOT ( EXISTS (
   (SELECT
    "x"
    FROM user_triggers ut
    WHERE ut.table_name=utc.table_name
     AND ut.trigger_name="TRG_PCMB*"
     AND ut.status="ENABLED"
     AND findstring(concat("new.",utc.column_name),ut.when_clause) > 0))))
   JOIN (di
   WHERE di.info_domain="COMBINE_TRIGGER_TYPE_PERSON"
    AND di.info_name=utc.table_name
    AND ((di.info_char = null) OR (((cnvtupper(trim(di.info_char,3)) IN ("AUTO", "DEFAULT")) OR (di
   .info_char <= char(32))) )) )
  DETAIL
   IF (locateval(diu_ndx,1,diu_trig_tabs->tab_cnt,utc.table_name,diu_trig_tabs->tabs[diu_ndx].
    table_name)=0)
    diu_trig_tabs->tab_cnt += 1, stat = alterlist(diu_trig_tabs->tabs,diu_trig_tabs->tab_cnt),
    diu_trig_tabs->tabs[diu_trig_tabs->tab_cnt].table_name = utc.table_name
   ENDIF
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  di.info_name
  FROM dm_info c,
   dm_info di,
   dm_cmb_children dcc
  PLAN (dcc
   WHERE dcc.parent_table IN ("PERSON", "ENCOUNTER")
    AND  NOT ( EXISTS (
   (SELECT
    "x"
    FROM dm_cmb_exception x
    WHERE x.child_entity=dcc.child_table
     AND x.parent_entity=dcc.parent_table
     AND x.operation_type="COMBINE"
     AND x.script_name="NONE"))))
   JOIN (di
   WHERE di.info_domain=concat("COMBINE_TRIGGER_TYPE_",evaluate(dcc.parent_table,"ENCOUNTER","ENCNTR",
     "PERSON"))
    AND di.info_name=dcc.child_table)
   JOIN (c
   WHERE c.info_domain="DATA MANAGEMENT"
    AND c.info_name="CMB_TRG_UPDT"
    AND di.updt_dt_tm > c.updt_dt_tm)
  DETAIL
   IF (locateval(diu_ndx,1,diu_trig_tabs->tab_cnt,di.info_name,diu_trig_tabs->tabs[diu_ndx].
    table_name)=0)
    diu_trig_tabs->tab_cnt += 1, stat = alterlist(diu_trig_tabs->tabs,diu_trig_tabs->tab_cnt),
    diu_trig_tabs->tabs[diu_trig_tabs->tab_cnt].table_name = di.info_name
   ENDIF
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  ut.table_name
  FROM user_triggers ut
  WHERE ut.trigger_name="TRG*CMB*"
   AND substring(1,4,ut.trigger_name)="TRG_"
   AND substring(11,4,ut.trigger_name)=substring(1,4,ut.table_name)
  DETAIL
   IF (locateval(diu_ndx,1,diu_trig_tabs->tab_cnt,ut.table_name,diu_trig_tabs->tabs[diu_ndx].
    table_name)=0)
    diu_trig_tabs->tab_cnt += 1, stat = alterlist(diu_trig_tabs->tabs,diu_trig_tabs->tab_cnt),
    diu_trig_tabs->tabs[diu_trig_tabs->tab_cnt].table_name = ut.table_name
   ENDIF
  WITH nocounter
 ;end select
 FOR (diu_cnt = 1 TO diu_trig_tabs->tab_cnt)
   SET ct_error->err_ind = 0
   SET ct_error->message = ""
   EXECUTE dm2_combine_triggers diu_trig_tabs->tabs[diu_cnt].table_name
   IF ((ct_error->err_ind=0))
    SET stat = write_to_dm_info(ct_error->message,diu_trig_tabs->tabs[diu_cnt].table_name)
   ELSE
    CALL echo("*")
    CALL echo(concat("Error during dm2_combine_triggers: ",ct_error->message))
    CALL echo("*")
    GO TO exit_program
   ENDIF
 ENDFOR
 UPDATE  FROM dm_info di
  SET di.info_date = cnvtdatetime(sysdate), di.updt_dt_tm = cnvtdatetime(sysdate), di.updt_applctx =
   reqinfo->updt_applctx,
   di.updt_cnt = (di.updt_cnt+ 1), di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
  WHERE info_domain="DATA MANAGEMENT"
   AND info_name="CMB_TRG_UPDT"
  WITH nocounter
 ;end update
 IF (curqual=0)
  INSERT  FROM dm_info di
   SET di.info_domain = "DATA MANAGEMENT", di.info_name = "CMB_TRG_UPDT", di.info_date = cnvtdatetime
    (sysdate),
    di.updt_dt_tm = cnvtdatetime(sysdate), di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = 0,
    di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
 ENDIF
 COMMIT
#exit_program
 FREE RECORD hh_delete
 SUBROUTINE err_chk(dummy)
   IF (error(diu_err_msg,0) > 0)
    IF (validate(ct_error->err_ind,99) != 99)
     SET ct_error->err_ind = 1
    ENDIF
    IF (validate(ct_error->message,"ZZ") != "ZZ")
     SET ct_error->message = diu_err_msg
    ELSE
     CALL echo(diu_err_msg)
    ENDIF
    GO TO exit_program
   ENDIF
 END ;Subroutine
 SUBROUTINE write_to_dm_info(sddl_description,schild_tab)
   UPDATE  FROM dm_info di
    SET di.info_date = cnvtdatetime(sysdate), di.info_char = substring(1,4000,sddl_description), di
     .updt_applctx = reqinfo->updt_applctx,
     di.updt_cnt = (di.updt_cnt+ 1), di.updt_dt_tm = cnvtdatetime(sysdate), di.updt_id = reqinfo->
     updt_id,
     di.updt_task = reqinfo->updt_task
    WHERE di.info_domain="COMBINE TRIGGER"
     AND di.info_name=schild_tab
    WITH nocounter
   ;end update
   IF (curqual=0)
    INSERT  FROM dm_info di
     SET di.info_domain = "COMBINE TRIGGER", di.info_name = schild_tab, di.info_char = substring(1,
       4000,sddl_description),
      di.info_date = cnvtdatetime(sysdate), di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = 0,
      di.updt_dt_tm = cnvtdatetime(sysdate), di.updt_id = reqinfo->updt_id, di.updt_task = reqinfo->
      updt_task
     WITH nocounter
    ;end insert
   ENDIF
   COMMIT
   RETURN(null)
 END ;Subroutine
END GO
