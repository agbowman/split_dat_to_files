CREATE PROGRAM dm_fill_dm_cmb_children:dba
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
 SET dm_debug_ind = 0
 IF (validate(dm_debug,0)=1)
  SET dm_debug_ind = 1
 ENDIF
 FREE RECORD rdm1738_log
 RECORD rdm1738_log(
   1 uniq_log_file = vc
 )
 SET rdm1738_log->uniq_log_file = build("rdm1738err",rand(0),".log")
 SET readme_data->status = "F"
 SET readme_data->message = "Readme Failed: Starting dm_fill_dm_cmb_children.prg script"
 SET trig_chk = 1
 SET hh_env_id = 0
 SELECT INTO "nl:"
  FROM dm_info d
  WHERE d.info_domain="DATA MANAGEMENT"
   AND d.info_name="DM_ENV_ID"
  DETAIL
   hh_env_id = d.info_number
  WITH nocounter
 ;end select
 IF ( NOT (hh_env_id))
  SET readme_data->status = "F"
  SET readme_data->message = "Environment ID not found."
  GO TO exit_script
 ENDIF
 SET readme_data->message = build("Calling script dm_ins_cmb_children with id:",hh_env_id)
 FREE RECORD ct_error
 RECORD ct_error(
   1 message = vc
   1 err_ind = i2
 )
 SET dfd_err_msg = fillstring(132," ")
 EXECUTE dm_ins_cmb_children_main value(hh_env_id)
 IF ((ct_error->err_ind != 0))
  IF ((ct_error->err_ind=- (1)))
   SET trig_chk = 0
  ELSE
   SET readme_data->status = "F"
   SET readme_data->message = ct_error->message
   GO TO exit_script
  ENDIF
 ENDIF
 IF (error(dfd_err_msg,1))
  SET readme_data->status = "F"
  SET readme_data->message = dfd_err_msg
  GO TO exit_script
 ENDIF
 FREE RECORD dcc_chk
 RECORD dcc_chk(
   1 qual[*]
     2 parent_table = vc
     2 child_table = vc
     2 child_fk = vc
     2 child_column = vc
     2 prsnl_ind = i2
     2 pk_ind = i2
     2 child_ind = i2
 )
 SET dcc_cnt = 0
 SET ucons_cnt = 0
 SET cc_cnt = 0
 IF (dm_debug_ind)
  SET begin_dt_tm = cnvtdatetime(curdate,curtime3)
  CALL echo(format(begin_dt_tm,";;q"))
 ENDIF
 SELECT INTO "nl:"
  FROM user_cons_columns dcc,
   user_constraints dc,
   user_constraints uc,
   dm_tables_doc t,
   dm_tables_doc t1
  PLAN (uc
   WHERE uc.table_name IN ("ENCOUNTER", "PERSON", "ENCOUNTER0077", "PERSON4859")
    AND uc.constraint_type="P")
   JOIN (dc
   WHERE uc.constraint_name=dc.r_constraint_name
    AND findstring("$",dc.table_name)=0
    AND dc.constraint_type="R")
   JOIN (dcc
   WHERE dc.constraint_name=dcc.constraint_name
    AND dc.table_name=dcc.table_name
    AND dcc.position=1)
   JOIN (t
   WHERE uc.table_name=t.table_name)
   JOIN (t1
   WHERE dc.table_name=t1.table_name)
  HEAD REPORT
   stat = alterlist(dcc_chk->qual,100)
  DETAIL
   dcc_cnt = (dcc_cnt+ 1)
   IF (mod(dcc_cnt,100)=1
    AND dcc_cnt != 1)
    stat = alterlist(dcc_chk->qual,(dcc_cnt+ 100))
   ENDIF
   dcc_chk->qual[dcc_cnt].parent_table = uc.table_name, dcc_chk->qual[dcc_cnt].child_table = dc
   .table_name, dcc_chk->qual[dcc_cnt].child_fk = dc.constraint_name,
   dcc_chk->qual[dcc_cnt].child_column = dcc.column_name
  FOOT REPORT
   stat = alterlist(dcc_chk->qual,dcc_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  dcc_chk->qual[du.seq].child_table
  FROM (dummyt du  WITH seq = dcc_cnt),
   user_constraints u,
   user_cons_columns ucc
  PLAN (du)
   JOIN (u
   WHERE u.owner=currdbuser
    AND u.r_constraint_name IN ("XPKPRSNL", "XPKPRSNL0386")
    AND (u.table_name=dcc_chk->qual[du.seq].child_table))
   JOIN (ucc
   WHERE ucc.owner=u.owner
    AND ucc.constraint_name=u.constraint_name
    AND (ucc.column_name=dcc_chk->qual[du.seq].child_column))
  DETAIL
   dcc_chk->qual[du.seq].prsnl_ind = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  dcc_chk->qual[du.seq].child_table
  FROM (dummyt du  WITH seq = dcc_cnt),
   user_constraints u1
  PLAN (du
   WHERE (dcc_chk->qual[du.seq].prsnl_ind=0))
   JOIN (u1
   WHERE (u1.table_name=dcc_chk->qual[du.seq].child_table)
    AND u1.constraint_type="P")
  DETAIL
   dcc_chk->qual[du.seq].pk_ind = 1, ucons_cnt = (ucons_cnt+ 1)
  WITH nocounter
 ;end select
 IF (currdb="ORACLE")
  SELECT INTO "nl:"
   FROM dm_cmb_children d,
    (dummyt t  WITH seq = dcc_cnt)
   PLAN (t
    WHERE (dcc_chk->qual[t.seq].prsnl_ind=0)
     AND (dcc_chk->qual[t.seq].pk_ind=1))
    JOIN (d
    WHERE (d.parent_table=dcc_chk->qual[t.seq].parent_table)
     AND (d.child_table=dcc_chk->qual[t.seq].child_table)
     AND (d.child_column=dcc_chk->qual[t.seq].child_column))
   DETAIL
    cc_cnt = (cc_cnt+ 1), dcc_chk->qual[t.seq].child_ind = 1
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM dm_cmb_children d,
    (dummyt t  WITH seq = dcc_cnt),
    dm_tables_doc dt1,
    dm_tables_doc dt2
   PLAN (t
    WHERE (dcc_chk->qual[t.seq].prsnl_ind=0)
     AND (dcc_chk->qual[t.seq].pk_ind=1))
    JOIN (dt1
    WHERE (dt1.table_name=dcc_chk->qual[t.seq].parent_table))
    JOIN (dt2
    WHERE (dt2.table_name=dcc_chk->qual[t.seq].child_table))
    JOIN (d
    WHERE d.parent_table=dt1.full_table_name
     AND d.child_table=dt2.full_table_name
     AND (d.child_column=dcc_chk->qual[t.seq].child_column))
   DETAIL
    cc_cnt = (cc_cnt+ 1), dcc_chk->qual[t.seq].child_ind = 1
   WITH nocounter
  ;end select
 ENDIF
 CALL echo(build("ucons_cnt=",ucons_cnt))
 CALL echo(build("cc_cnt=",cc_cnt))
 IF (ucons_cnt != cc_cnt)
  SELECT INTO value(rdm1738_log->uniq_log_file)
   FROM (dummyt d  WITH seq = dcc_cnt)
   WHERE (dcc_chk->qual[d.seq].prsnl_ind=0)
    AND (dcc_chk->qual[d.seq].pk_ind=1)
    AND (dcc_chk->qual[d.seq].child_ind=0)
   HEAD REPORT
    col 0,
    "***************************************************************************************************",
    row + 1,
    "**------------------ These tables have a foreign key relationship to the ------------------------**",
    row + 1,
    "**--------------- PERSON/ENCOUNTER table but do not exist on DM_CMB_CHILDREN --------------------**",
    row + 1,
    "***************************************************************************************************",
    row + 1,
    " Parent Table                    Child Table                     Child Column", row + 1,
    " -------------                   ------------                    -------------"
   DETAIL
    row + 1, col 1, dcc_chk->qual[d.seq].parent_table,
    col 33, dcc_chk->qual[d.seq].child_table, col 65,
    dcc_chk->qual[d.seq].child_column
   FOOT REPORT
    row + 2,
    "***************************************************************************************************"
   WITH nocounter, maxcol = 200, format = variable
  ;end select
  SET readme_data->status = "F"
  SET readme_data->message = concat(
   "ERROR: DM_CMB_CHILDREN not populated correctly, please review log file: ",rdm1738_log->
   uniq_log_file)
  GO TO exit_script
 ENDIF
 IF (dm_debug_ind)
  SET end_dt_tm = cnvtdatetime(curdate,curtime3)
  CALL echo(format(end_dt_tm,";;q"))
  SET diff = datetimediff(end_dt_tm,begin_dt_tm,5)
  CALL echo(build("duration for dm_cmb_children chk =",diff))
  SET begin_dt_tm = cnvtdatetime(curdate,curtime3)
  CALL echo(format(begin_dt_tm,";;q"))
 ENDIF
 IF (trig_chk=1)
  SET cmb_cnt = 0
  SET trig_cnt = 0
  SELECT INTO "nl:"
   c.child_table, c.child_column
   FROM dm_cmb_children c
   WHERE c.parent_table IN ("PERSON", "ENCOUNTER")
    AND c.child_column > " "
    AND c.child_pk > " "
    AND  NOT ( EXISTS (
   (SELECT
    "w"
    FROM dm_cmb_exception x
    WHERE x.child_entity=c.child_table
     AND x.parent_entity=c.parent_table
     AND x.operation_type="COMBINE"
     AND x.script_name="NONE")))
    AND  NOT ( EXISTS (
   (SELECT
    "x"
    FROM dm_info di
    WHERE di.info_domain=concat("COMBINE_TRIGGER_TYPE_",evaluate(c.parent_table,"ENCOUNTER","ENCNTR",
      "PERSON"))
     AND di.info_name=c.child_table
     AND di.info_char="NULL")))
    AND  NOT ( EXISTS (
   (SELECT
    "y"
    FROM dm_info di2
    WHERE di2.info_domain="OBSOLETE_OBJECT"
     AND di2.info_char="TABLE"
     AND di2.info_name=c.child_table)))
   ORDER BY c.child_table, c.child_column
   HEAD c.child_table
    row + 0
   HEAD c.child_column
    cmb_cnt = (cmb_cnt+ 1)
   FOOT  c.child_column
    row + 0
   FOOT  c.child_table
    row + 0
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM user_triggers u
   WHERE u.trigger_name="TRG*CMB*"
    AND substring(1,4,u.trigger_name)="TRG_"
    AND u.status IN ("ENABLED", "Y")
    AND  NOT ( EXISTS (
   (SELECT
    "w"
    FROM dm_cmb_exception x
    WHERE x.child_entity=u.table_name
     AND x.parent_entity=evaluate(findstring("TRG_PCMB",u.trigger_name),1,"PERSON","ENCOUNTER")
     AND x.operation_type="COMBINE"
     AND x.script_name="NONE")))
    AND  NOT ( EXISTS (
   (SELECT
    "x"
    FROM dm_info di
    WHERE di.info_domain=concat("COMBINE_TRIGGER_TYPE_",evaluate(findstring("TRG_PCMB",u.trigger_name
       ),1,"PERSON","ENCNTR"))
     AND di.info_name=u.table_name
     AND di.info_char="NULL")))
    AND  NOT ( EXISTS (
   (SELECT
    "y"
    FROM dm_info di2
    WHERE di2.info_domain="OBSOLETE_OBJECT"
     AND di2.info_char="TABLE"
     AND di2.info_name=u.table_name)))
   ORDER BY u.table_name
   DETAIL
    trig_cnt = (trig_cnt+ 1)
   WITH nocounter
  ;end select
  CALL echo(build("cmb_cnt =",cmb_cnt))
  CALL echo(build("trig_cnt =",trig_cnt))
  IF (currdb="ORACLE")
   IF ((trig_cnt=(cmb_cnt+ 4)))
    SET readme_data->message =
    "Import for dm_cmb_children and combine triggers creation were successful."
    SET readme_data->status = "S"
   ELSE
    IF ((trig_cnt > (cmb_cnt+ 4)))
     SELECT INTO value(rdm1738_log->uniq_log_file)
      FROM user_triggers ut,
       dm_tables_doc dt
      PLAN (ut
       WHERE ut.trigger_name="TRG*CMB*"
        AND  NOT (ut.table_name IN ("PHONE", "ADDRESS", "CHART_REQUEST_AUDIT"))
        AND substring(1,4,ut.trigger_name)="TRG_"
        AND ut.status IN ("ENABLED", "Y")
        AND  NOT ( EXISTS (
       (SELECT
        dc.child_table
        FROM dm_cmb_children dc
        WHERE dc.child_table=ut.table_name
         AND dc.parent_table IN ("PERSON", "ENCOUNTER")
         AND dc.child_column > " "
         AND dc.child_pk > " "))))
       JOIN (dt
       WHERE ut.table_name=dt.table_name
        AND dt.drop_ind=0)
      HEAD REPORT
       col 0, "************************************************************", row + 1,
       "**--------- These tables have combine triggers -----------**", row + 1,
       "**--------- but do not exist on DM_CMB_CHILDREN ----------**",
       row + 1, "************************************************************", row + 1,
       " Table Name                      Trigger Name", row + 1,
       " -----------                     -------------"
      DETAIL
       row + 1, col 1, ut.table_name,
       col 33, ut.trigger_name
      FOOT REPORT
       row + 2, "************************************************************"
      WITH nocounter, maxcol = 200, format = variable
     ;end select
    ELSEIF ((trig_cnt < (cmb_cnt+ 4)))
     SELECT INTO value(rdm1738_log->uniq_log_file)
      FROM dm_cmb_children dc
      WHERE dc.parent_table IN ("PERSON", "ENCOUNTER")
       AND dc.child_column > " "
       AND dc.child_pk > " "
       AND  NOT ( EXISTS (
      (SELECT
       "w"
       FROM dm_cmb_exception x
       WHERE x.child_entity=dc.child_table
        AND x.parent_entity=dc.parent_table
        AND x.operation_type="COMBINE"
        AND x.script_name="NONE")))
       AND  NOT ( EXISTS (
      (SELECT
       "x"
       FROM dm_info di
       WHERE di.info_domain=concat("COMBINE_TRIGGER_TYPE_",evaluate(dc.parent_table,"ENCOUNTER",
         "ENCNTR","PERSON"))
        AND di.info_name=dc.child_table
        AND di.info_char="NULL")))
       AND  NOT ( EXISTS (
      (SELECT
       "y"
       FROM dm_info di2
       WHERE di2.info_domain="OBSOLETE_OBJECT"
        AND di2.info_char="TABLE"
        AND di2.info_name=dc.child_table)))
       AND  NOT ( EXISTS (
      (SELECT
       "z"
       FROM user_triggers ut
       WHERE ut.table_name=dc.child_table
        AND ut.trigger_name="TRG*CMB*"
        AND substring(1,4,ut.trigger_name)="TRG_"
        AND ut.status IN ("ENABLED", "Y"))))
      HEAD REPORT
       col 0,
       "***************************************************************************************************",
       row + 1,
       "**----------- These tables are on DM_CMB_CHILDREN, but do not have a combine trigger ------------**",
       row + 1,
       "***************************************************************************************************",
       row + 1, " Parent Table                    Child Table                     Child Column", row
        + 1,
       " -------------                   ------------                    -------------"
      DETAIL
       row + 1, col 1, dc.parent_table,
       col 33, dc.child_table, col 65,
       dc.child_column
      FOOT REPORT
       row + 2,
       "***************************************************************************************************"
      WITH nocounter, maxcol = 200, format = variable
     ;end select
    ENDIF
    SET readme_data->status = "F"
    SET readme_data->message = concat(
     "ERROR: Combine trigger creation failed, please review log file: ",rdm1738_log->uniq_log_file)
   ENDIF
  ELSEIF (currdb="DB2UDB")
   IF ((trig_cnt=((cmb_cnt * 2)+ 8)))
    SET readme_data->status = "S"
    SET readme_data->message =
    "Import for dm_cmb_children and combine triggers creation were successful."
   ELSE
    SET readme_data->status = "F"
    SET readme_data->message = "Combine trigger creation failed."
   ENDIF
  ENDIF
 ELSE
  SET readme_data->status = "S"
  SET readme_data->message = "Import for dm_cmb_children was successful."
 ENDIF
 IF (dm_debug_ind)
  SET end_dt_tm = cnvtdatetime(curdate,curtime3)
  CALL echo(format(end_dt_tm,";;q"))
  SET diff = datetimediff(end_dt_tm,begin_dt_tm,5)
  CALL echo(build("duration for trigger chk =",diff))
 ENDIF
#exit_script
 EXECUTE dm_readme_status
 FREE RECORD rdm1738_log
 CALL echorecord(readme_data)
END GO
