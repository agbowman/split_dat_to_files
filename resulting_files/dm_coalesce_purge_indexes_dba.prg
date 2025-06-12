CREATE PROGRAM dm_coalesce_purge_indexes:dba
 DECLARE dcpi_templatenbr = i4 WITH protect, noconstant(0)
 DECLARE dcpi_indexcnt = i4 WITH protect, noconstant(0)
 DECLARE dcpi_lvalidx = i4 WITH protect, noconstant(0)
 DECLARE dcpi_curidx = i4 WITH protect, noconstant(0)
 DECLARE dcpi_expandidx = i4 WITH protect, noconstant(0)
 DECLARE dcpi_loop = i4 WITH protect, noconstant(0)
 DECLARE dcpi_subloop = i4 WITH protect, noconstant(0)
 DECLARE dcpi_tablecnt = i4 WITH protect, noconstant(0)
 DECLARE dcpi_parentrowcnt = i4 WITH protect, noconstant(0)
 DECLARE dcpi_childrowcnt = i4 WITH protect, noconstant(0)
 DECLARE dcpi_parserstmt = vc WITH protect, noconstant("")
 DECLARE dcpi_runfrompurgearchind = i2 WITH protect, noconstant(0)
 DECLARE dcpi_coalesceindicator = i2 WITH protect, noconstant(- (1))
 DECLARE dcpi_collectpurgedtblsind = i2 WITH protect, noconstant(0)
 DECLARE dcpi_curstartdttm = dq8 WITH protect, noconstant(0.0)
 DECLARE dcpi_runtime = f8 WITH protect, noconstant(0.0)
 DECLARE dcpi_floattemplatenbr = f8 WITH protect, noconstant(0.0)
 DECLARE dcpi_lastrundttm = dq8 WITH protect, noconstant(0.0)
 DECLARE dcpi_numdaysbetweenpurge = i4 WITH protect, noconstant(0)
 DECLARE dcpi_hasdaysbetweenrowind = i2 WITH protect, noconstant(0)
 DECLARE dcpi_masteractivationind = i2 WITH protect, noconstant(- (1))
 FREE RECORD dcpi_indexes
 RECORD dcpi_indexes(
   1 list_0[*]
     2 indexname = vc
 )
 FREE RECORD dcpi_tablenames
 RECORD dcpi_tablenames(
   1 list_0[*]
     2 tablename = vc
 )
 FREE RECORD dcpi_userobjectsinfo
 RECORD dcpi_userobjectsinfo(
   1 tablecount = i4
   1 list_0[*]
     2 tablename = vc
     2 lastddltime = dq8
 )
 SET dcpi_templatenbr =  $1
 IF (dcpi_templatenbr=0)
  CALL echo("Invalid template number passed in")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DM PURGE COALESCE"
   AND di.info_name="MASTER COALESCE ACTIVATION"
  DETAIL
   dcpi_masteractivationind = di.info_number
  WITH nocounter
 ;end select
 IF (dcpi_masteractivationind=0)
  CALL echo("Master inactivation row dictates that no coalescing will be performed; exiting.")
  GO TO exit_script
 ENDIF
 IF ((validate(c_audit,- (3)) != - (3)))
  SET dcpi_runfrompurgearchind = 1
  IF ((jobs->data[job_ndx].purge_flag=c_audit))
   CALL echo("Purge is in audit mode; exiting coalescing process")
   GO TO exit_script
  ENDIF
 ENDIF
 SET dcpi_floattemplatenbr = cnvtreal(dcpi_templatenbr)
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DM PURGE COALESCE"
   AND di.info_name="COALESCE DAYS BETWEEN"
  DETAIL
   dcpi_hasdaysbetweenrowind = 1, dcpi_numdaysbetweenpurge = di.info_number
  WITH nocounter
 ;end select
 IF (dcpi_hasdaysbetweenrowind=0)
  SET dcpi_numdaysbetweenpurge = 30
  INSERT  FROM dm_info di
   SET di.info_name = "COALESCE DAYS BETWEEN", di.info_domain = "DM PURGE COALESCE", di.info_number
     = 30,
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_task = reqinfo->updt_task, di
    .updt_applctx = reqinfo->updt_applctx,
    di.updt_id = reqinfo->updt_id, di.updt_cnt = 0
   WITH nocounter
  ;end insert
  COMMIT
 ENDIF
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DM PURGE COALESCE"
   AND di.info_name=concat("Coalesce indicator for ",trim(cnvtstring(dcpi_templatenbr),3))
   AND di.info_long_id=dcpi_floattemplatenbr
  DETAIL
   dcpi_coalesceindicator = di.info_number
   IF (nullind(di.info_date)=1)
    IF (nullind(di.updt_dt_tm)=1)
     dcpi_lastrundttm = cnvtdatetime("01-JAN-1800 00:00:00.00")
    ELSE
     dcpi_lastrundttm = di.updt_dt_tm
    ENDIF
   ELSE
    dcpi_lastrundttm = di.info_date
   ENDIF
  WITH nocounter
 ;end select
 IF ((dcpi_coalesceindicator=- (1)))
  INSERT  FROM dm_info di
   SET di.info_name = concat("Coalesce indicator for ",trim(cnvtstring(dcpi_templatenbr),3)), di
    .info_domain = "DM PURGE COALESCE", di.info_long_id = dcpi_floattemplatenbr,
    di.info_number = 1, di.updt_applctx = reqinfo->updt_applctx, di.updt_cnt = 0,
    di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di.updt_id = reqinfo->updt_id, di.updt_task =
    reqinfo->updt_task
   WITH nocounter
  ;end insert
  COMMIT
 ELSEIF (dcpi_coalesceindicator=0)
  CALL echo("Coalescing for this purge template has been inactivated; exiting coalescing process")
  GO TO exit_script
 ELSEIF (datetimediff(cnvtdatetime(curdate,curtime3),dcpi_lastrundttm,1) < dcpi_numdaysbetweenpurge)
  CALL echo(concat("It has been less than ",build(dcpi_numdaysbetweenpurge),
    " days since this coalesce last ran; exiting"))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM user_objects uo
  WHERE uo.object_type="TABLE"
   AND ((uo.object_name IN (
  (SELECT DISTINCT
   cnvtupper(dpt1.parent_table)
   FROM dm_purge_table dpt1
   WHERE dpt1.template_nbr=dcpi_templatenbr))) OR (uo.object_name IN (
  (SELECT DISTINCT
   cnvtupper(dpt2.child_table)
   FROM dm_purge_table dpt2
   WHERE dpt2.template_nbr=dcpi_templatenbr
    AND dpt2.child_table > " "
    AND dpt2.child_table IS NOT null))))
  DETAIL
   dcpi_userobjectsinfo->tablecount = (dcpi_userobjectsinfo->tablecount+ 1)
   IF (mod(dcpi_userobjectsinfo->tablecount,10)=1)
    stat = alterlist(dcpi_userobjectsinfo->list_0,(dcpi_userobjectsinfo->tablecount+ 9))
   ENDIF
   dcpi_userobjectsinfo->list_0[dcpi_userobjectsinfo->tablecount].lastddltime = uo.last_ddl_time,
   dcpi_userobjectsinfo->list_0[dcpi_userobjectsinfo->tablecount].tablename = uo.object_name
  FOOT REPORT
   stat = alterlist(dcpi_userobjectsinfo->list_0,dcpi_userobjectsinfo->tablecount)
  WITH nocounter
 ;end select
 IF (dcpi_runfrompurgearchind=1)
  IF ((jobs->data[job_ndx].purge_flag=c_del_dtl_log))
   SET dcpi_collectpurgedtblsind = 1
  ENDIF
 ENDIF
 IF (dcpi_collectpurgedtblsind=1)
  SELECT INTO "nl:"
   FROM dm_purge_job_log_tab pjlt
   WHERE (pjlt.log_id=
   (SELECT
    max(dpjl.log_id)
    FROM dm_purge_job_log dpjl
    WHERE (dpjl.job_id=jobs->data[job_ndx].job_id)))
    AND pjlt.num_rows > 0
   ORDER BY pjlt.table_name
   HEAD pjlt.table_name
    dcpi_curidx = locateval(dcpi_lvalidx,1,dcpi_userobjectsinfo->tablecount,cnvtupper(pjlt.table_name
      ),dcpi_userobjectsinfo->list_0[dcpi_lvalidx].tablename)
    IF (datetimediff(cnvtdatetime(curdate,curtime3),dcpi_userobjectsinfo->list_0[dcpi_curidx].
     lastddltime,1) >= dcpi_numdaysbetweenpurge)
     dcpi_tablecnt = (dcpi_tablecnt+ 1), stat = alterlist(dcpi_tablenames->list_0,dcpi_tablecnt),
     dcpi_tablenames->list_0[dcpi_tablecnt].tablename = cnvtupper(pjlt.table_name)
    ELSE
     CALL echo(concat("Table ",trim(pjlt.table_name,3),
      " has had DDL run against it recently; omitting from coalescing"))
    ENDIF
   WITH nocounter
  ;end select
 ELSE
  SELECT INTO "nl:"
   FROM dm_purge_job_log pjl
   WHERE (pjl.job_id=
   (SELECT
    dpj.job_id
    FROM dm_purge_job dpj
    WHERE dpj.template_nbr=dcpi_templatenbr))
    AND (pjl.log_id=
   (SELECT
    max(pjl2.log_id)
    FROM dm_purge_job_log pjl2
    WHERE pjl2.job_id=pjl.job_id))
   DETAIL
    dcpi_parentrowcnt = pjl.parent_rows, dcpi_childrowcnt = pjl.child_rows
   WITH nocounter
  ;end select
  IF (dcpi_parentrowcnt > 0)
   SELECT INTO "nl:"
    dpt.parent_table
    FROM dm_purge_table dpt
    WHERE dpt.template_nbr=dcpi_templatenbr
     AND (dpt.schema_dt_tm=
    (SELECT
     max(dpt2.schema_dt_tm)
     FROM dm_purge_table dpt2
     WHERE dpt2.template_nbr=dpt.template_nbr))
     AND  NOT ( EXISTS (
    (SELECT
     1
     FROM dm_purge_table dpt3
     WHERE dpt3.template_nbr=dpt.template_nbr
      AND dpt3.schema_dt_tm=dpt.schema_dt_tm
      AND dpt3.child_table=dpt.parent_table)))
    GROUP BY dpt.parent_table
    DETAIL
     dcpi_curidx = locateval(dcpi_lvalidx,1,dcpi_userobjectsinfo->tablecount,cnvtupper(dpt
       .parent_table),dcpi_userobjectsinfo->list_0[dcpi_lvalidx].tablename)
     IF (datetimediff(cnvtdatetime(curdate,curtime3),dcpi_userobjectsinfo->list_0[dcpi_curidx].
      lastddltime,1) >= dcpi_numdaysbetweenpurge)
      dcpi_tablecnt = (dcpi_tablecnt+ 1), stat = alterlist(dcpi_tablenames->list_0,dcpi_tablecnt),
      dcpi_tablenames->list_0[dcpi_tablecnt].tablename = cnvtupper(dpt.parent_table)
     ELSE
      CALL echo(concat("Table ",trim(dpt.parent_table,3),
       " has had DDL run against it recently; omitting from coalescing"))
     ENDIF
    WITH nocounter
   ;end select
   IF (dcpi_childrowcnt > 0)
    SELECT INTO "nl:"
     dpt.child_table
     FROM dm_purge_table dpt
     WHERE dpt.template_nbr=dcpi_templatenbr
      AND (dpt.schema_dt_tm=
     (SELECT
      max(dpt2.schema_dt_tm)
      FROM dm_purge_table dpt2
      WHERE dpt2.template_nbr=dpt.template_nbr))
      AND dpt.child_table > " "
      AND dpt.child_table IS NOT null
      AND (dpt.child_table != dcpi_tablenames->list_0[1].tablename)
     GROUP BY dpt.child_table
     DETAIL
      dcpi_curidx = locateval(dcpi_lvalidx,1,dcpi_userobjectsinfo->tablecount,cnvtupper(dpt
        .child_table),dcpi_userobjectsinfo->list_0[dcpi_lvalidx].tablename)
      IF (datetimediff(cnvtdatetime(curdate,curtime3),dcpi_userobjectsinfo->list_0[dcpi_curidx].
       lastddltime,1) >= dcpi_numdaysbetweenpurge)
       dcpi_tablecnt = (dcpi_tablecnt+ 1), stat = alterlist(dcpi_tablenames->list_0,dcpi_tablecnt),
       dcpi_tablenames->list_0[dcpi_tablecnt].tablename = cnvtupper(dpt.child_table)
      ELSE
       CALL echo(concat("Table ",trim(dpt.child_table,3),
        " has had DDL run against it recently; omitting from coalescing"))
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
  ELSE
   CALL echo("No rows purged in last run of purge job; exiting...")
   GO TO exit_script
  ENDIF
 ENDIF
 IF (dcpi_tablecnt=0)
  CALL echo("No tables found that qualified for the purge; exiting...")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  ui.index_name
  FROM user_indexes ui
  WHERE expand(dcpi_expandidx,1,dcpi_tablecnt,ui.table_name,dcpi_tablenames->list_0[dcpi_expandidx].
   tablename)
   AND ui.index_type="NORMAL"
  DETAIL
   dcpi_indexcnt = (dcpi_indexcnt+ 1)
   IF (mod(dcpi_indexcnt,10)=1)
    stat = alterlist(dcpi_indexes->list_0,(dcpi_indexcnt+ 9))
   ENDIF
   dcpi_indexes->list_0[dcpi_indexcnt].indexname = cnvtupper(ui.index_name)
  FOOT REPORT
   stat = alterlist(dcpi_indexes->list_0,dcpi_indexcnt)
  WITH nocounter
 ;end select
 FOR (dcpi_loop = 1 TO dcpi_indexcnt)
   SET dcpi_parserstmt = concat("rdb asis(^ ALTER INDEX ",dcpi_indexes->list_0[dcpi_loop].indexname,
    " COALESCE ^) go")
   IF (validate(request->debug_mode,"Z") != "Z")
    CALL echo(dcpi_parserstmt)
   ENDIF
   IF (dcpi_runfrompurgearchind=1)
    SET dcpi_curstartdttm = cnvtdatetime(curdate,curtime3)
    CALL parser(dcpi_parserstmt)
    SET dcpi_runtime = datetimediff(cnvtdatetime(curdate,curtime3),dcpi_curstartdttm,4)
    INSERT  FROM dm_purge_job_log_timing jlt
     SET jlt.job_log_timing_id = seq(dm_clinical_seq,nextval), jlt.log_id = v_log_id, jlt.value_key
       = concat(v_logging_idx_prefix,dcpi_indexes->list_0[dcpi_loop].indexname),
      jlt.value_nbr = dcpi_runtime, jlt.updt_applctx = reqinfo->updt_applctx, jlt.updt_cnt = 0,
      jlt.updt_dt_tm = cnvtdatetime(curdate,curtime3), jlt.updt_id = reqinfo->updt_id, jlt.updt_task
       = reqinfo->updt_task
     WITH nocounter
    ;end insert
    COMMIT
   ELSE
    CALL parser(dcpi_parserstmt)
   ENDIF
 ENDFOR
 UPDATE  FROM dm_info di
  SET di.info_date = cnvtdatetime(curdate,curtime3), di.updt_task = reqinfo->updt_task, di.updt_id =
   reqinfo->updt_id,
   di.updt_applctx = reqinfo->updt_applctx, di.updt_dt_tm = cnvtdatetime(curdate,curtime3), di
   .updt_cnt = (di.updt_cnt+ 1)
  WHERE di.info_domain="DM PURGE COALESCE"
   AND di.info_long_id=dcpi_floattemplatenbr
  WITH nocounter
 ;end update
 COMMIT
#exit_script
 FREE RECORD dcpi_indexes
 FREE RECORD dcpi_tablenames
 FREE RECORD dcpi_userobjectsinfo
END GO
