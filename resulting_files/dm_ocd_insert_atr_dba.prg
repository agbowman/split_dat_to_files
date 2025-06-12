CREATE PROGRAM dm_ocd_insert_atr:dba
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET dm_debug = 0
 IF (validate(dm_ocd_debug,- (1)) > 0)
  SET dm_debug = dm_ocd_debug
 ENDIF
 SET tempstr = fillstring(110," ")
 SET line130 = fillstring(130," ")
 SET line80 = fillstring(79," ")
 SET bigstr = fillstring(255," ")
 SET des = fillstring(200," ")
 SET descr = fillstring(200," ")
 SET description = fillstring(200," ")
 SET tx = fillstring(500," ")
 SET txt = fillstring(500," ")
 SET text = fillstring(500," ")
 SET fi = 0
 SET ai = 0
 SET ti = 0
 SET ri = 0
 SET i = 0
 SET j = 0
 SET k = 0
 SET ocd_atr_filename = build("ocd_schema_",request->alpha_feature_nbr,".ccl")
 EXECUTE FROM get_atr_tree_begin TO get_atr_tree_end
 DELETE  FROM dm_ocd_application dm
  WHERE (dm.alpha_feature_nbr=request->alpha_feature_nbr)
 ;end delete
 DELETE  FROM dm_ocd_task dm
  WHERE (dm.alpha_feature_nbr=request->alpha_feature_nbr)
 ;end delete
 DELETE  FROM dm_ocd_request dm
  WHERE (dm.alpha_feature_nbr=request->alpha_feature_nbr)
 ;end delete
 DELETE  FROM dm_ocd_app_task_r dm
  WHERE (dm.alpha_feature_nbr=request->alpha_feature_nbr)
 ;end delete
 DELETE  FROM dm_ocd_task_req_r dm
  WHERE (dm.alpha_feature_nbr=request->alpha_feature_nbr)
 ;end delete
 COMMIT
 FOR (ai = 1 TO dm_atr->app_num)
  INSERT  FROM dm_ocd_application a
   (a.application_number, a.alpha_feature_nbr, a.owner,
   a.description, a.active_dt_tm, a.active_ind,
   a.last_localized_dt_tm, a.text, a.inactive_dt_tm,
   a.log_access_ind, a.application_ini_ind, a.object_name,
   a.direct_access_ind, a.log_level, a.request_log_level,
   a.min_version_required, a.disable_cache_ind, a.module,
   a.feature_number, a.deleted_ind, a.schema_date,
   a.updt_dt_tm, a.updt_id, a.updt_task,
   a.updt_cnt, a.updt_applctx)(SELECT
    d.application_number, request->alpha_feature_nbr, d.owner,
    d.description, d.active_dt_tm, d.active_ind,
    d.last_localized_dt_tm, d.text, d.inactive_dt_tm,
    d.log_access_ind, d.application_ini_ind, d.object_name,
    d.direct_access_ind, d.log_level, d.request_log_level,
    d.min_version_required, d.disable_cache_ind, d.module,
    dm_atr->app[ai].ocd_feature, d.deleted_ind, d.schema_date,
    cnvtdatetime(curdate,curtime3), 0, 0,
    0, 0
    FROM dm_application d
    WHERE (d.application_number=dm_atr->app[ai].app)
     AND (d.feature_number=dm_atr->app[ai].feature)
     AND d.deleted_ind=0)
   WITH nocounter
  ;end insert
  COMMIT
 ENDFOR
 FOR (ti = 1 TO dm_atr->app_task_num)
  INSERT  FROM dm_ocd_app_task_r a
   (a.application_number, a.task_number, a.alpha_feature_nbr,
   a.feature_number, a.deleted_ind, a.schema_date,
   a.updt_dt_tm, a.updt_id, a.updt_task,
   a.updt_cnt, a.updt_applctx)(SELECT
    d.application_number, d.task_number, request->alpha_feature_nbr,
    d.feature_number, d.deleted_ind, d.schema_date,
    cnvtdatetime(curdate,curtime3), 0, 0,
    0, 0
    FROM dm_application_task_r d
    WHERE (d.application_number=dm_atr->app_task[ti].app)
     AND (d.task_number=dm_atr->app_task[ti].task)
     AND (d.feature_number=dm_atr->app_task[ti].feature)
     AND d.deleted_ind=0)
   WITH nocounter
  ;end insert
  COMMIT
 ENDFOR
 FOR (ti = 1 TO dm_atr->task_num)
  INSERT  FROM dm_ocd_task a
   (a.task_number, a.alpha_feature_nbr, a.description,
   a.active_dt_tm, a.active_ind, a.text,
   a.inactive_dt_tm, a.subordinate_task_ind, a.optional_required_flag,
   a.feature_number, a.deleted_ind, a.schema_date,
   a.updt_dt_tm, a.updt_id, a.updt_task,
   a.updt_cnt, a.updt_applctx)(SELECT
    d.task_number, request->alpha_feature_nbr, d.description,
    d.active_dt_tm, d.active_ind, d.text,
    d.inactive_dt_tm, d.subordinate_task_ind, d.optional_required_flag,
    d.feature_number, d.deleted_ind, d.schema_date,
    cnvtdatetime(curdate,curtime3), 0, 0,
    0, 0
    FROM dm_application_task d
    WHERE (d.task_number=dm_atr->task[ti].task)
     AND (d.feature_number=dm_atr->task[ti].feature)
     AND d.deleted_ind=0)
   WITH nocounter
  ;end insert
  COMMIT
 ENDFOR
 FOR (ri = 1 TO dm_atr->task_req_num)
  INSERT  FROM dm_ocd_task_req_r a
   (a.task_number, a.request_number, a.alpha_feature_nbr,
   a.feature_number, a.deleted_ind, a.schema_date,
   a.updt_dt_tm, a.updt_id, a.updt_task,
   a.updt_cnt, a.updt_applctx)(SELECT
    d.task_number, d.request_number, request->alpha_feature_nbr,
    d.feature_number, d.deleted_ind, d.schema_date,
    cnvtdatetime(curdate,curtime3), 0, 0,
    0, 0
    FROM dm_task_request_r d
    WHERE (d.task_number=dm_atr->task_req[ri].task)
     AND (d.request_number=dm_atr->task_req[ri].req)
     AND (d.feature_number=dm_atr->task_req[ri].feature)
     AND d.deleted_ind=0)
   WITH nocounter
  ;end insert
  COMMIT
 ENDFOR
 FOR (ri = 1 TO dm_atr->req_num)
  INSERT  FROM dm_ocd_request a
   (a.request_number, a.alpha_feature_nbr, a.description,
   a.request_name, a.text, a.active_dt_tm,
   a.active_ind, a.inactive_dt_tm, a.prolog_script,
   a.epilog_script, a.write_to_que_ind, a.requestclass,
   a.cachetime, a.feature_number, a.deleted_ind,
   a.schema_date, a.updt_dt_tm, a.updt_id,
   a.updt_task, a.updt_cnt, a.updt_applctx)(SELECT
    d.request_number, request->alpha_feature_nbr, d.description,
    d.request_name, d.text, d.active_dt_tm,
    d.active_ind, d.inactive_dt_tm, d.prolog_script,
    d.epilog_script, d.write_to_que_ind, d.requestclass,
    d.cachetime, d.feature_number, d.deleted_ind,
    d.schema_date, cnvtdatetime(curdate,curtime3), 0,
    0, 0, 0
    FROM dm_request d
    WHERE (d.request_number=dm_atr->req[ri].req)
     AND (d.feature_number=dm_atr->req[ri].feature)
     AND d.deleted_ind=0)
   WITH nocounter
  ;end insert
  COMMIT
 ENDFOR
 FOR (fi = 1 TO request->feature_num)
   IF ((request->feature[fi].app_num > 0))
    UPDATE  FROM dm_ocd_features d
     SET d.schema_ind = 1
     WHERE (d.alpha_feature_nbr=request->alpha_feature_nbr)
      AND (d.feature_number=request->feature[fi].feature_number)
     WITH nocounter
    ;end update
    COMMIT
    SELECT INTO value(ocd_atr_filename)
     FROM dual
     DETAIL
      "update into dm_ocd_features d", row + 1, "  set d.schema_ind = 1",
      row + 1, "where d.alpha_feature_nbr = ", request->alpha_feature_nbr,
      row + 1, "  and d.feature_number = ", request->feature[fi].feature_number,
      row + 1, "with nocounter go", row + 1,
      "commit go", row + 1, row + 1
     WITH nocounter, maxrow = 1, maxcol = 300,
      format = variable, formfeed = none, append
    ;end select
   ENDIF
 ENDFOR
 SET tempstr = fillstring(110," ")
 SET line130 = fillstring(130," ")
 SET line80 = fillstring(79," ")
 SET bigstr = fillstring(255," ")
 SELECT INTO value(ocd_atr_filename)
  FROM dual
  DETAIL
   "set trace symbol mark go", row + 2, "delete from dm_ocd_application dm",
   row + 1, line80 = build("  where dm.alpha_feature_nbr=",request->alpha_feature_nbr), line80,
   row + 1, "go", row + 1,
   "delete from dm_ocd_task dm", row + 1, line80 = build("  where dm.alpha_feature_nbr=",request->
    alpha_feature_nbr),
   line80, row + 1, "go",
   row + 1, "delete from dm_ocd_request dm", row + 1,
   line80 = build("  where dm.alpha_feature_nbr=",request->alpha_feature_nbr), line80, row + 1,
   "go", row + 1, "delete from dm_ocd_app_task_r dm",
   row + 1, line80 = build("  where dm.alpha_feature_nbr=",request->alpha_feature_nbr), line80,
   row + 1, "go", row + 1,
   "delete from dm_ocd_task_req_r dm", row + 1, line80 = build("  where dm.alpha_feature_nbr=",
    request->alpha_feature_nbr),
   line80, row + 1, "go",
   row + 1, "commit go", row + 2,
   "set trace symbol release go", row + 2
  WITH nocounter, maxrow = 1, maxcol = 150,
   format = variable, formfeed = none, append
 ;end select
 SET tempstr = fillstring(110," ")
 SET line130 = fillstring(130," ")
 SET line80 = fillstring(79," ")
 SET bigstr = fillstring(255," ")
 SET des = fillstring(200," ")
 SET descr = fillstring(200," ")
 SET description = fillstring(200," ")
 SET tx = fillstring(500," ")
 SET txt = fillstring(500," ")
 SET text = fillstring(500," ")
 SELECT INTO value(ocd_atr_filename)
  d.*, n_active = nullind(d.active_dt_tm), n_inactive = nullind(d.inactive_dt_tm),
  n_local = nullind(d.last_localized_dt_tm), n_schema = nullind(d.schema_date)
  FROM dm_ocd_application d
  WHERE (d.alpha_feature_nbr=request->alpha_feature_nbr)
  ORDER BY d.application_number
  HEAD d.application_number
   des = replace(replace(d.description,char(13)," ",0),char(10)," ",0), descr = replace(des,"'","`",0
    ), description = replace(descr,'"',"`",0),
   bigd = 0
   IF (size(trim(d.description)) > 110)
    bigd = 1, "set d1 = fillstring(100,", ") go",
    row + 1, "set d2 = fillstring(100,", ") go",
    row + 1, "set d1 =", row + 1,
    bigstr = build('"',substring(1,100,description),'"'), bigstr, row + 1,
    "go", row + 1, "set d2 =",
    row + 1, bigstr = build('"',substring(101,100,description),'"'), bigstr,
    row + 1, "go", row + 1
   ENDIF
   tx = replace(replace(d.text,char(13)," ",0),char(10)," ",0), txt = replace(tx,'"',"`",0), text =
   replace(txt,"'","`",0),
   bigt = 0
   IF (size(trim(d.text)) > 110)
    bigt = 1, 'set t1 = fillstring(125," ") go', row + 1,
    'set t2 = fillstring(125," ") go', row + 1, 'set t3 = fillstring(125," ") go',
    row + 1, 'set t4 = fillstring(125," ") go', row + 1,
    "set t1 =", row + 1, bigstr = build('"',substring(1,125,text),'"'),
    bigstr, row + 1, "go",
    row + 1, "set t2 =", row + 1,
    bigstr = build('"',substring(126,125,text),'"'), bigstr, row + 1,
    "go", row + 1, "set t3 =",
    row + 1, bigstr = build('"',substring(251,125,text),'"'), bigstr,
    row + 1, "go", row + 1,
    "set t4 =", row + 1, bigstr = build('"',substring(376,125,text),'"'),
    bigstr, row + 1, "go",
    row + 1
   ENDIF
  DETAIL
   "set trace symbol mark go", row + 2, "insert into dm_ocd_application dm",
   row + 1, line80 = build("  set dm.application_number=",d.application_number,","), line80,
   row + 1, line80 = build("  dm.alpha_feature_nbr=",request->alpha_feature_nbr,","), line80,
   row + 1, line80 = build('  dm.owner="',replace(replace(d.owner,char(13)," ",0),char(10)," ",0),
    '",'), line80,
   row + 1
   IF (bigd=0)
    line130 = build('  dm.description="',description,'",'), line130, row + 1
   ELSE
    line80 = "  dm.description = concat(trim(d1),trim(d2)),", line80, row + 1
   ENDIF
   IF (n_active=0)
    line80 = build('  dm.active_dt_tm=cnvtdatetime("',format(d.active_dt_tm,";;Q"),'"),')
   ELSE
    line80 = "  dm.active_dt_tm=NULL,"
   ENDIF
   line80, row + 1, line80 = build("  dm.active_ind=",d.active_ind,","),
   line80, row + 1
   IF (n_local=0)
    line80 = build('  dm.last_localized_dt_tm=cnvtdatetime("',format(d.last_localized_dt_tm,";;Q"),
     '"),')
   ELSE
    line80 = "  dm.last_localized_dt_tm=NULL,"
   ENDIF
   line80, row + 1
   IF (bigt=0)
    line130 = build('  dm.text="',text,'",'), line130, row + 1
   ELSE
    line80 = "  dm.text = concat(trim(t1),trim(t2),trim(t3),trim(t4)),", line80, row + 1
   ENDIF
   IF (n_inactive=0)
    line80 = build('  dm.inactive_dt_tm=cnvtdatetime("',format(d.inactive_dt_tm,";;Q"),'"),')
   ELSE
    line80 = "  dm.inactive_dt_tm=NULL,"
   ENDIF
   line80, row + 1, line80 = build("  dm.log_access_ind=",d.log_access_ind,","),
   line80, row + 1, line80 = build("  dm.application_ini_ind=",d.application_ini_ind,","),
   line80, row + 1, line80 = build('  dm.object_name="',replace(replace(d.object_name,char(13)," ",0),
     char(10)," ",0),'",'),
   line80, row + 1, line80 = build("  dm.direct_access_ind=",d.direct_access_ind,","),
   line80, row + 1, line80 = build("  dm.log_level=",d.log_level,","),
   line80, row + 1, line80 = build("  dm.request_log_level=",d.request_log_level,","),
   line80, row + 1, line80 = build('  dm.min_version_required="',d.min_version_required,'",'),
   line80, row + 1, line80 = build("  dm.disable_cache_ind=",d.disable_cache_ind,","),
   line80, row + 1, line80 = build('  dm.module="',replace(replace(d.module,char(13)," ",0),char(10),
     " ",0),'",'),
   line80, row + 1, line80 = build("  dm.feature_number=",d.feature_number,","),
   line80, row + 1, line80 = build("  dm.deleted_ind=",d.deleted_ind,","),
   line80, row + 1
   IF (n_schema=0)
    line80 = build('  dm.schema_date=cnvtdatetime("',format(d.schema_date,";;Q"),'"),')
   ELSE
    line80 = "  dm.schema_date=cnvtdatetime(curdate,curtime3),"
   ENDIF
   line80, row + 1, line80 = "  dm.updt_dt_tm=cnvtdatetime(curdate,curtime3),",
   line80, row + 1, line80 = "  dm.updt_id=0,",
   line80, row + 1, line80 = "  dm.updt_task=0,",
   line80, row + 1, line80 = "  dm.updt_cnt=0,",
   line80, row + 1, line80 = "  dm.updt_applctx=0",
   line80, row + 1, "go",
   row + 1, "set trace symbol release go", row + 2
  FOOT  d.application_number
   "commit go", row + 1, row + 1
  WITH nocounter, maxrow = 1, maxcol = 300,
   format = variable, formfeed = none, append
 ;end select
 SET tempstr = fillstring(110," ")
 SET line130 = fillstring(130," ")
 SET line80 = fillstring(79," ")
 SET bigstr = fillstring(255," ")
 SET des = fillstring(200," ")
 SET descr = fillstring(200," ")
 SET description = fillstring(200," ")
 SET tx = fillstring(500," ")
 SET txt = fillstring(500," ")
 SET text = fillstring(500," ")
 SELECT INTO value(ocd_atr_filename)
  d.*, n_active = nullind(d.active_dt_tm), n_inactive = nullind(d.inactive_dt_tm),
  n_schema = nullind(d.schema_date)
  FROM dm_ocd_task d
  WHERE (d.alpha_feature_nbr=request->alpha_feature_nbr)
  ORDER BY d.task_number
  HEAD d.task_number
   des = replace(replace(d.description,char(13)," ",0),char(10)," ",0), descr = replace(des,"'","`",0
    ), description = replace(descr,'"',"`",0),
   bigd = 0
   IF (size(trim(d.description)) > 110)
    bigd = 1, "set d1 = fillstring(100,", ") go",
    row + 1, "set d2 = fillstring(100,", ") go",
    row + 1, "set d1 =", row + 1,
    bigstr = build('"',substring(1,100,description),'"'), bigstr, row + 1,
    "go", row + 1, "set d2 =",
    row + 1, bigstr = build('"',substring(101,100,description),'"'), bigstr,
    row + 1, "go", row + 1
   ENDIF
   tx = replace(replace(d.text,char(13)," ",0),char(10)," ",0), txt = replace(tx,'"',"`",0), text =
   replace(txt,"'","`",0),
   bigt = 0
   IF (size(trim(d.text)) > 110)
    bigt = 1, 'set t1 = fillstring(125," ") go', row + 1,
    'set t2 = fillstring(125," ") go', row + 1, 'set t3 = fillstring(125," ") go',
    row + 1, 'set t4 = fillstring(125," ") go', row + 1,
    "set t1 =", row + 1, bigstr = build('"',substring(1,125,text),'"'),
    bigstr, row + 1, "go",
    row + 1, "set t2 =", row + 1,
    bigstr = build('"',substring(126,125,text),'"'), bigstr, row + 1,
    "go", row + 1, "set t3 =",
    row + 1, bigstr = build('"',substring(251,125,text),'"'), bigstr,
    row + 1, "go", row + 1,
    "set t4 =", row + 1, bigstr = build('"',substring(376,125,text),'"'),
    bigstr, row + 1, "go",
    row + 1
   ENDIF
  DETAIL
   "set trace symbol mark go", row + 2, "insert into dm_ocd_task dm",
   row + 1, line80 = build("  set dm.task_number=",d.task_number,","), line80,
   row + 1, line80 = build("  dm.alpha_feature_nbr=",request->alpha_feature_nbr,","), line80,
   row + 1
   IF (bigd=0)
    line130 = build('  dm.description="',description,'",'), line130, row + 1
   ELSE
    line80 = "  dm.description = concat(trim(d1),trim(d2)),", line80, row + 1
   ENDIF
   IF (n_active=0)
    line80 = build('  dm.active_dt_tm=cnvtdatetime("',format(d.active_dt_tm,";;Q"),'"),')
   ELSE
    line80 = "  dm.active_dt_tm=NULL,"
   ENDIF
   line80, row + 1, line80 = build("  dm.active_ind=",d.active_ind,","),
   line80, row + 1
   IF (bigt=0)
    line130 = build('  dm.text="',text,'",'), line130, row + 1
   ELSE
    line80 = "  dm.text = concat(trim(t1),trim(t2),trim(t3),trim(t4)),", line80, row + 1
   ENDIF
   IF (n_inactive=0)
    line80 = build('  dm.inactive_dt_tm=cnvtdatetime("',format(d.inactive_dt_tm,";;Q"),'"),')
   ELSE
    line80 = "  dm.inactive_dt_tm=NULL,"
   ENDIF
   line80, row + 1, line80 = build("  dm.subordinate_task_ind=",d.subordinate_task_ind,","),
   line80, row + 1, line80 = build("  dm.optional_required_flag=",d.optional_required_flag,","),
   line80, row + 1, line80 = build("  dm.feature_number=",d.feature_number,","),
   line80, row + 1, line80 = build("  dm.deleted_ind=",d.deleted_ind,","),
   line80, row + 1
   IF (n_schema=0)
    line80 = build('  dm.schema_date=cnvtdatetime("',format(d.schema_date,";;Q"),'"),')
   ELSE
    line80 = "  dm.schema_date=cnvtdatetime(curdate,curtime3),"
   ENDIF
   line80, row + 1, line80 = "  dm.updt_dt_tm=cnvtdatetime(curdate,curtime3),",
   line80, row + 1, line80 = "  dm.updt_id=0,",
   line80, row + 1, line80 = "  dm.updt_task=0,",
   line80, row + 1, line80 = "  dm.updt_cnt=0,",
   line80, row + 1, line80 = "  dm.updt_applctx=0",
   line80, row + 1, "go",
   row + 1, "set trace symbol release go", row + 2
  FOOT  d.task_number
   "commit go", row + 1, row + 1
  WITH nocounter, maxrow = 1, maxcol = 300,
   format = variable, formfeed = none, append
 ;end select
 SET tempstr = fillstring(110," ")
 SET line130 = fillstring(130," ")
 SET line80 = fillstring(79," ")
 SET bigstr = fillstring(255," ")
 SET des = fillstring(200," ")
 SET descr = fillstring(200," ")
 SET description = fillstring(200," ")
 SET tx = fillstring(500," ")
 SET txt = fillstring(500," ")
 SET text = fillstring(500," ")
 SELECT INTO value(ocd_atr_filename)
  d.*, n_schema = nullind(d.schema_date)
  FROM dm_ocd_app_task_r d
  WHERE (d.alpha_feature_nbr=request->alpha_feature_nbr)
  DETAIL
   "set trace symbol mark go", row + 2, "insert into dm_ocd_app_task_r dm",
   row + 1, line80 = build("  set dm.application_number=",d.application_number,","), line80,
   row + 1, line80 = build("  dm.task_number=",d.task_number,","), line80,
   row + 1, line80 = build("  dm.alpha_feature_nbr=",request->alpha_feature_nbr,","), line80,
   row + 1, line80 = build("  dm.feature_number=",d.feature_number,","), line80,
   row + 1, line80 = build("  dm.deleted_ind=",d.deleted_ind,","), line80,
   row + 1
   IF (n_schema=0)
    line80 = build('  dm.schema_date=cnvtdatetime("',format(d.schema_date,";;Q"),'"),')
   ELSE
    line80 = "  dm.schema_date=cnvtdatetime(curdate,curtime3),"
   ENDIF
   line80, row + 1, line80 = "  dm.updt_dt_tm=cnvtdatetime(curdate,curtime3),",
   line80, row + 1, line80 = "  dm.updt_id=0,",
   line80, row + 1, line80 = "  dm.updt_task=0,",
   line80, row + 1, line80 = "  dm.updt_cnt=0,",
   line80, row + 1, line80 = "  dm.updt_applctx=0",
   line80, row + 1, "go",
   row + 1, "commit go", row + 1,
   row + 1, "set trace symbol release go", row + 2
  WITH nocounter, maxrow = 1, maxcol = 300,
   format = variable, formfeed = none, append
 ;end select
 SET tempstr = fillstring(110," ")
 SET line130 = fillstring(130," ")
 SET line80 = fillstring(79," ")
 SET bigstr = fillstring(255," ")
 SET des = fillstring(200," ")
 SET descr = fillstring(200," ")
 SET description = fillstring(200," ")
 SET tx = fillstring(500," ")
 SET txt = fillstring(500," ")
 SET text = fillstring(500," ")
 SELECT INTO value(ocd_atr_filename)
  d.*, n_active = nullind(d.active_dt_tm), n_inactive = nullind(d.inactive_dt_tm),
  n_schema = nullind(d.schema_date), n_cacheg = nullind(d.cachegrace), n_caches = nullind(d
   .cachestale),
  n_cachet = nullind(d.cachetrim)
  FROM dm_ocd_request d
  WHERE (d.alpha_feature_nbr=request->alpha_feature_nbr)
  ORDER BY d.request_number
  HEAD d.request_number
   des = replace(replace(d.description,char(13)," ",0),char(10)," ",0), descr = replace(des,"'","`",0
    ), description = replace(descr,'"',"`",0),
   bigd = 0
   IF (size(trim(d.description)) > 110)
    bigd = 1, 'set d1 = fillstring(100," ") go', row + 1,
    'set d2 = fillstring(100," ") go', row + 1, "set d1 =",
    row + 1, bigstr = build('"',substring(1,100,description),'"'), bigstr,
    row + 1, "go", row + 1,
    "set d2 =", row + 1, bigstr = build('"',substring(101,100,description),'"'),
    bigstr, row + 1, "go",
    row + 1
   ENDIF
   tx = replace(replace(d.text,char(13)," ",0),char(10)," ",0), txt = replace(tx,'"',"`",0), text =
   replace(txt,"'","`",0),
   bigt = 0
   IF (size(trim(d.text)) > 110)
    bigt = 1, 'set t1 = fillstring(125," ") go', row + 1,
    'set t2 = fillstring(125," ") go', row + 1, 'set t3 = fillstring(125," ") go',
    row + 1, 'set t4 = fillstring(125," ") go', row + 1,
    "set t1 =", row + 1, bigstr = build('"',substring(1,125,text),'"'),
    bigstr, row + 1, "go",
    row + 1, "set t2 =", row + 1,
    bigstr = build('"',substring(126,125,text),'"'), bigstr, row + 1,
    "go", row + 1, "set t3 =",
    row + 1, bigstr = build('"',substring(251,125,text),'"'), bigstr,
    row + 1, "go", row + 1,
    "set t4 =", row + 1, bigstr = build('"',substring(376,125,text),'"'),
    bigstr, row + 1, "go",
    row + 1
   ENDIF
  DETAIL
   "set trace symbol mark go", row + 2, "insert into dm_ocd_request dm",
   row + 1, line80 = build("  set dm.request_number=",d.request_number,","), line80,
   row + 1, line80 = build("  dm.alpha_feature_nbr=",request->alpha_feature_nbr,","), line80,
   row + 1
   IF (bigd=0)
    line130 = build('  dm.description="',description,'",'), line130, row + 1
   ELSE
    line80 = "  dm.description = concat(trim(d1),trim(d2)),", line80, row + 1
   ENDIF
   line80 = build('  dm.request_name="',replace(replace(d.request_name,char(13)," ",0),char(10)," ",0
     ),'",'), line80, row + 1
   IF (bigt=0)
    line130 = build('  dm.text="',text,'",'), line130, row + 1
   ELSE
    line80 = "  dm.text = concat(trim(t1),trim(t2),trim(t3),trim(t4)),", line80, row + 1
   ENDIF
   line80 = build("  dm.active_ind=",d.active_ind,","), line80, row + 1
   IF (n_active=0)
    line80 = build('  dm.active_dt_tm=cnvtdatetime("',format(d.active_dt_tm,";;Q"),'"),')
   ELSE
    line80 = "  dm.active_dt_tm=NULL,"
   ENDIF
   line80, row + 1
   IF (n_inactive=0)
    line80 = build('  dm.inactive_dt_tm=cnvtdatetime("',format(d.inactive_dt_tm,";;Q"),'"),')
   ELSE
    line80 = "  dm.inactive_dt_tm=NULL,"
   ENDIF
   line80, row + 1, line80 = build('  dm.prolog_script="',replace(replace(d.prolog_script,char(13),
      " ",0),char(10)," ",0),'",'),
   line80, row + 1, line80 = build('  dm.epilog_script="',replace(replace(d.epilog_script,char(13),
      " ",0),char(10)," ",0),'",'),
   line80, row + 1, line80 = build("  dm.write_to_que_ind=",d.write_to_que_ind,","),
   line80, row + 1, line80 = build("  dm.requestclass=",d.requestclass,","),
   line80, row + 1, line80 = build("  dm.cachetime=",d.cachetime,","),
   line80, row + 1
   IF (n_cacheg=0)
    line80 = build("  dm.cachegrace=",d.cachegrace,",")
   ELSE
    line80 = build("  dm.cachegrace=NULL,")
   ENDIF
   line80, row + 1
   IF (n_caches=0)
    line80 = build("  dm.cachestale=",d.cachestale,",")
   ELSE
    line80 = build("  dm.cachestale=NULL,")
   ENDIF
   line80, row + 1
   IF (n_cachet=0)
    line80 = build("  dm.cachetrim='",d.cachetrim,"',")
   ELSE
    line80 = build("  dm.cachetrim=NULL,")
   ENDIF
   line80, row + 1, line80 = build("  dm.feature_number=",d.feature_number,","),
   line80, row + 1, line80 = build("  dm.deleted_ind=",d.deleted_ind,","),
   line80, row + 1
   IF (n_schema=0)
    line80 = build('  dm.schema_date=cnvtdatetime("',format(d.schema_date,";;Q"),'"),')
   ELSE
    line80 = "  dm.schema_date=cnvtdatetime(curdate,curtime3),"
   ENDIF
   line80, row + 1, line80 = "  dm.updt_dt_tm=cnvtdatetime(curdate,curtime3),",
   line80, row + 1, line80 = "  dm.updt_id=0,",
   line80, row + 1, line80 = "  dm.updt_task=0,",
   line80, row + 1, line80 = "  dm.updt_cnt=0,",
   line80, row + 1, line80 = "  dm.updt_applctx=0",
   line80, row + 1, "go",
   row + 1, "set trace symbol release go", row + 2
  FOOT  d.request_number
   "commit go", row + 1, row + 1
  WITH nocounter, maxrow = 1, maxcol = 300,
   format = variable, formfeed = none, append
 ;end select
 SET tempstr = fillstring(110," ")
 SET line130 = fillstring(130," ")
 SET line80 = fillstring(79," ")
 SET bigstr = fillstring(255," ")
 SET des = fillstring(200," ")
 SET descr = fillstring(200," ")
 SET description = fillstring(200," ")
 SET tx = fillstring(500," ")
 SET txt = fillstring(500," ")
 SET text = fillstring(500," ")
 SELECT INTO value(ocd_atr_filename)
  d.*, n_schema = nullind(d.schema_date)
  FROM dm_ocd_task_req_r d
  WHERE (d.alpha_feature_nbr=request->alpha_feature_nbr)
  DETAIL
   "set trace symbol mark go", row + 2, "insert into dm_ocd_task_req_r dm",
   row + 1, line80 = build("  set dm.task_number=",d.task_number,","), line80,
   row + 1, line80 = build("  dm.request_number=",d.request_number,","), line80,
   row + 1, line80 = build("  dm.alpha_feature_nbr=",request->alpha_feature_nbr,","), line80,
   row + 1, line80 = build("  dm.feature_number=",d.feature_number,","), line80,
   row + 1, line80 = build("  dm.deleted_ind=",d.deleted_ind,","), line80,
   row + 1
   IF (n_schema=0)
    line80 = build('  dm.schema_date=cnvtdatetime("',format(d.schema_date,";;Q"),'"),')
   ELSE
    line80 = "  dm.schema_date=cnvtdatetime(curdate,curtime3),"
   ENDIF
   line80, row + 1, line80 = "  dm.updt_dt_tm=cnvtdatetime(curdate,curtime3),",
   line80, row + 1, line80 = "  dm.updt_id=0,",
   line80, row + 1, line80 = "  dm.updt_task=0,",
   line80, row + 1, line80 = "  dm.updt_cnt=0,",
   line80, row + 1, line80 = "  dm.updt_applctx=0",
   line80, row + 1, "go",
   row + 1, "commit go", row + 1,
   row + 1, "set trace symbol release go", row + 2
  WITH nocounter, maxrow = 1, maxcol = 300,
   format = variable, formfeed = none, append
 ;end select
 SET cerocd = fillstring(150," ")
 SET line = fillstring(150," ")
 SET len = 0
 IF (abs((request->rev_number - 7.003)) < 0.0001)
  SET cerocd = logical("bld73")
 ELSEIF (abs((request->rev_number - 7.004)) < 0.0001)
  SET cerocd = logical("bld74")
 ELSEIF (abs((request->rev_number - 7.005)) < 0.0001)
  SET cerocd = logical("bld75")
 ELSEIF (abs((request->rev_number - 7.006)) < 0.0001)
  SET cerocd = logical("bld76")
 ELSEIF (abs((request->rev_number - 7.007)) < 0.0001)
  SET cerocd = logical("bld77")
 ELSEIF (abs((request->rev_number - 99.01)) < 0.001)
  SET cerocd = logical("bld78")
 ELSEIF (abs((request->rev_number - 2000.01)) < 0.001)
  SET cerocd = logical("bld2000")
 ENDIF
 IF (cursys != "AIX")
  SET len = findstring("]",cerocd)
  SET line = build(substring(1,(len - 1),cerocd),format(request->alpha_feature_nbr,"######;P0"),"]")
  SET fname = build("ccluserdir:ocd_schema_",request->alpha_feature_nbr,".ccl")
 ELSE
  SET line = build(cerocd,"/",format(request->alpha_feature_nbr,"######;P0"))
  SET fname = build("ccluserdir:ocd_schema_",request->alpha_feature_nbr,".ccl")
 ENDIF
 SET dclcom = fillstring(132," ")
 SET filename = fillstring(50," ")
 IF (cursys != "AIX")
  SET dclcom = concat("create/dir ",trim(line))
  SET len = size(trim(dclcom))
  SET status = 0
  CALL dcl(dclcom,len,status)
  SET filename = build("ocd_schema_",request->alpha_feature_nbr,".ccl")
  SET dclcom = concat("copy CCLUSERDIR:",trim(filename)," ",trim(line))
  SET len = size(trim(dclcom))
  SET status = 0
  CALL dcl(dclcom,len,status)
 ELSE
  SET dclcom = concat("mkdir ",trim(line))
  SET len = size(trim(dclcom))
  SET status = 0
  CALL dcl(dclcom,len,status)
  SET filename = build("ocd_schema_",request->alpha_feature_nbr,".ccl")
  SET dclcom = concat("cp $CCLUSERDIR/",trim(filename)," ",trim(line))
  SET len = size(trim(dclcom))
  SET status = 0
  CALL dcl(dclcom,len,status)
 ENDIF
 SET reply->status_data.status = "S"
 GO TO end_program
#get_atr_tree_begin
 FREE RECORD dm_atr
 RECORD dm_atr(
   1 app_num = i4
   1 app[*]
     2 app = i4
     2 feature = i4
     2 schema_date = dq8
     2 ocd_feature = i4
     2 feature_ind = i2
     2 deleted_ind = i2
   1 task_num = i4
   1 task[*]
     2 task = i4
     2 feature = i4
     2 schema_date = dq8
     2 feature_ind = i2
     2 deleted_ind = i2
   1 app_task_num = i4
   1 app_task[*]
     2 app = i4
     2 task = i4
     2 feature = i4
     2 schema_date = dq8
     2 feature_ind = i2
     2 deleted_ind = i2
     2 checked_ind = i2
   1 req_num = i4
   1 req[*]
     2 req = i4
     2 feature = i4
     2 schema_date = dq8
     2 feature_ind = i2
     2 deleted_ind = i2
   1 task_req_num = i4
   1 task_req[*]
     2 task = i4
     2 req = i4
     2 feature = i4
     2 schema_date = dq8
     2 feature_ind = i2
     2 deleted_ind = i2
     2 checked_ind = i2
 )
 SET dm_atr->app_num = 0
 SET stat = alterlist(dm_atr->app,0)
 SET dm_atr->app_task_num = 0
 SET stat = alterlist(dm_atr->app_task,0)
 SET dm_atr->task_num = 0
 SET stat = alterlist(dm_atr->task,0)
 SET dm_atr->task_req_num = 0
 SET stat = alterlist(dm_atr->task_req,0)
 SET dm_atr->req_num = 0
 SET stat = alterlist(dm_atr->req,0)
 SET ai = 0
 SET ti = 0
 SET ri = 0
 SET acnt = 0
 SET tcnt = 0
 SET rcnt = 0
 FOR (fi = 1 TO request->feature_num)
   IF ((request->feature[fi].app_num > 0))
    SELECT INTO "nl:"
     da.*
     FROM dm_application da,
      (dummyt d  WITH seq = value(request->feature[fi].app_num))
     PLAN (d)
      JOIN (da
      WHERE (da.application_number=request->feature[fi].app[d.seq].app)
       AND da.feature_number > 1)
     ORDER BY da.schema_date DESC
     DETAIL
      found = 0
      FOR (i = 1 TO dm_atr->app_num)
        IF ((dm_atr->app[i].app=da.application_number))
         found = i
         IF (datetimediff(da.schema_date,dm_atr->app[i].schema_date) > 0)
          dm_atr->app[i].schema_date = da.schema_date, dm_atr->app[i].feature = da.feature_number,
          dm_atr->app[i].deleted_ind = da.deleted_ind,
          dm_atr->app[i].feature_ind = 0
          IF (dm_debug=1)
           CALL echo("***"),
           CALL echo(build("*** App:",da.application_number," replace new feature:",da.feature_number,
            " del:",
            da.deleted_ind)),
           CALL echo("***")
          ENDIF
         ENDIF
         i = dm_atr->app_num
        ENDIF
      ENDFOR
      IF (found=0)
       dm_atr->app_num = (dm_atr->app_num+ 1), acnt = dm_atr->app_num, stat = alterlist(dm_atr->app,
        acnt),
       dm_atr->app[acnt].app = da.application_number, dm_atr->app[acnt].feature = da.feature_number,
       dm_atr->app[acnt].schema_date = da.schema_date,
       dm_atr->app[acnt].deleted_ind = da.deleted_ind, dm_atr->app[acnt].feature_ind = 0, dm_atr->
       app[acnt].ocd_feature = request->feature[fi].feature_number
       IF (dm_debug=1)
        CALL echo("***"),
        CALL echo(build("*** Adding app:",da.application_number," feature:",da.feature_number," del:",
         da.deleted_ind)),
        CALL echo("***")
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 IF ((dm_atr->app_num > 0))
  SELECT INTO "nl:"
   da.*
   FROM dm_application da,
    (dummyt f  WITH seq = value(request->feature_num)),
    (dummyt d  WITH seq = value(dm_atr->app_num))
   PLAN (d)
    JOIN (da
    WHERE (da.application_number=dm_atr->app[d.seq].app)
     AND da.feature_number > 1)
    JOIN (f
    WHERE (request->feature[f.seq].feature_number=da.feature_number))
   ORDER BY da.schema_date DESC
   DETAIL
    IF (((datetimediff(da.schema_date,dm_atr->app[d.seq].schema_date) > 0) OR ((dm_atr->app[d.seq].
    feature_ind=0))) )
     dm_atr->app[d.seq].schema_date = da.schema_date, dm_atr->app[d.seq].feature = da.feature_number,
     dm_atr->app[d.seq].deleted_ind = da.deleted_ind,
     dm_atr->app[d.seq].feature_ind = 1
     IF (dm_debug=1)
      CALL echo("***"),
      CALL echo(build("*** App:",da.application_number," replace OCD feature:",da.feature_number,
       " del:",
       da.deleted_ind)),
      CALL echo("***")
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   dat.*
   FROM dm_application_task_r dat,
    (dummyt d  WITH seq = value(dm_atr->app_num))
   PLAN (d)
    JOIN (dat
    WHERE (dat.application_number=dm_atr->app[d.seq].app)
     AND dat.feature_number > 1)
   ORDER BY dat.schema_date DESC
   DETAIL
    found = 0
    FOR (i = 1 TO dm_atr->app_task_num)
      IF ((dm_atr->app_task[i].app=dat.application_number)
       AND (dm_atr->app_task[i].task=dat.task_number))
       found = i
       IF (datetimediff(dat.schema_date,dm_atr->app_task[i].schema_date) > 0)
        dm_atr->app_task[i].schema_date = dat.schema_date, dm_atr->app_task[i].feature = dat
        .feature_number, dm_atr->app_task[i].deleted_ind = dat.deleted_ind,
        dm_atr->app_task[i].feature_ind = 0
        IF (dm_debug=1)
         CALL echo("***"),
         CALL echo(build("*** App-Task:",dat.task_number," replace new feature:",dat.feature_number,
          " del:",
          dat.deleted_ind)),
         CALL echo("***")
        ENDIF
       ENDIF
       i = dm_atr->app_task_num
      ENDIF
    ENDFOR
    IF (found=0)
     dm_atr->app_task_num = (dm_atr->app_task_num+ 1), tcnt = dm_atr->app_task_num, stat = alterlist(
      dm_atr->app_task,tcnt),
     dm_atr->app_task[tcnt].app = dat.application_number, dm_atr->app_task[tcnt].task = dat
     .task_number, dm_atr->app_task[tcnt].feature = dat.feature_number,
     dm_atr->app_task[tcnt].schema_date = dat.schema_date, dm_atr->app_task[tcnt].deleted_ind = dat
     .deleted_ind, dm_atr->app_task[tcnt].feature_ind = 0
     IF (dm_debug=1)
      CALL echo("***"),
      CALL echo(build("*** Adding App-Task:",dat.task_number," feature:",dat.feature_number," del:",
       dat.deleted_ind)),
      CALL echo("***")
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((dm_atr->app_task_num > 0))
  SELECT INTO "nl:"
   dat.*
   FROM dm_application_task_r dat,
    (dummyt f  WITH seq = value(request->feature_num)),
    (dummyt d  WITH seq = value(dm_atr->app_task_num))
   PLAN (d)
    JOIN (dat
    WHERE (dat.application_number=dm_atr->app_task[d.seq].app)
     AND (dat.task_number=dm_atr->app_task[d.seq].task)
     AND dat.feature_number > 1)
    JOIN (f
    WHERE (request->feature[f.seq].feature_number=dat.feature_number))
   ORDER BY dat.schema_date DESC
   DETAIL
    IF (((datetimediff(dat.schema_date,dm_atr->app_task[d.seq].schema_date) > 0) OR ((dm_atr->
    app_task[d.seq].feature_ind=0))) )
     dm_atr->app_task[d.seq].schema_date = dat.schema_date, dm_atr->app_task[d.seq].feature = dat
     .feature_number, dm_atr->app_task[d.seq].deleted_ind = dat.deleted_ind,
     dm_atr->app_task[d.seq].feature_ind = 1
     IF (dm_debug=1)
      CALL echo("***"),
      CALL echo(build("*** App-Task:",dat.task_number," replace OCD feature:",dat.feature_number,
       " del:",
       dat.deleted_ind)),
      CALL echo("***")
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   dt.*
   FROM dm_application_task dt,
    (dummyt d  WITH seq = value(dm_atr->app_task_num))
   PLAN (d)
    JOIN (dt
    WHERE (dt.task_number=dm_atr->app_task[d.seq].task)
     AND dt.feature_number > 1
     AND (dm_atr->app_task[d.seq].deleted_ind=0))
   ORDER BY dt.schema_date DESC
   DETAIL
    found = 0
    FOR (i = 1 TO dm_atr->task_num)
      IF ((dm_atr->task[i].task=dt.task_number))
       found = i
       IF (datetimediff(dt.schema_date,dm_atr->task[i].schema_date) > 0)
        dm_atr->task[i].schema_date = dt.schema_date, dm_atr->task[i].feature = dt.feature_number,
        dm_atr->task[i].deleted_ind = dt.deleted_ind,
        dm_atr->task[i].feature_ind = 0
        IF (dm_debug=1)
         CALL echo("***"),
         CALL echo(build("*** Task:",dt.task_number," replace new feature:",dt.feature_number," del:",
          dt.deleted_ind)),
         CALL echo("***")
        ENDIF
       ENDIF
       i = dm_atr->task_num
      ENDIF
    ENDFOR
    IF (found=0)
     dm_atr->task_num = (dm_atr->task_num+ 1), tcnt = dm_atr->task_num, stat = alterlist(dm_atr->task,
      tcnt),
     dm_atr->task[tcnt].task = dt.task_number, dm_atr->task[tcnt].feature = dt.feature_number, dm_atr
     ->task[tcnt].schema_date = dt.schema_date,
     dm_atr->task[tcnt].deleted_ind = dt.deleted_ind, dm_atr->task[tcnt].feature_ind = 0
     IF (dm_debug=1)
      CALL echo("***"),
      CALL echo(build("*** Adding Task:",dt.task_number," feature:",dt.feature_number," del:",
       dt.deleted_ind)),
      CALL echo("***")
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((dm_atr->task_num > 0))
  SELECT INTO "nl:"
   FROM dm_application_task dt,
    (dummyt f  WITH seq = value(request->feature_num)),
    (dummyt d  WITH seq = value(dm_atr->task_num))
   PLAN (d)
    JOIN (dt
    WHERE (dt.task_number=dm_atr->task[d.seq].task)
     AND dt.feature_number > 1)
    JOIN (f
    WHERE (request->feature[f.seq].feature_number=dt.feature_number))
   ORDER BY dt.schema_date DESC
   DETAIL
    IF (((datetimediff(dt.schema_date,dm_atr->task[d.seq].schema_date) > 0) OR ((dm_atr->task[d.seq].
    feature_ind=0))) )
     dm_atr->task[d.seq].schema_date = dt.schema_date, dm_atr->task[d.seq].feature = dt
     .feature_number, dm_atr->task[d.seq].deleted_ind = dt.deleted_ind,
     dm_atr->task[d.seq].feature_ind = 1
     IF (dm_debug=1)
      CALL echo("***"),
      CALL echo(build("*** Task:",dt.task_number," replace OCD feature:",dt.feature_number," del:",
       dt.deleted_ind)),
      CALL echo("***")
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   dtr.*
   FROM dm_task_request_r dtr,
    (dummyt d  WITH seq = value(dm_atr->task_num))
   PLAN (d)
    JOIN (dtr
    WHERE (dtr.task_number=dm_atr->task[d.seq].task)
     AND dtr.feature_number > 1
     AND (dm_atr->task[d.seq].deleted_ind=0))
   ORDER BY dtr.schema_date DESC
   DETAIL
    found = 0
    FOR (i = 1 TO dm_atr->task_req_num)
      IF ((dm_atr->task_req[i].task=dtr.task_number)
       AND (dm_atr->task_req[i].req=dtr.request_number))
       found = i
       IF (datetimediff(dtr.schema_date,dm_atr->task_req[i].schema_date) > 0)
        dm_atr->task_req[i].schema_date = dtr.schema_date, dm_atr->task_req[i].feature = dtr
        .feature_number, dm_atr->task_req[i].deleted_ind = dtr.deleted_ind,
        dm_atr->task_req[i].feature_ind = 0
        IF (dm_debug=1)
         CALL echo("***"),
         CALL echo(build("*** Task-Req:",dtr.request_number," replace new feature:",dtr
          .feature_number," del:",
          dtr.deleted_ind)),
         CALL echo("***")
        ENDIF
       ENDIF
       i = dm_atr->task_req_num
      ENDIF
    ENDFOR
    IF (found=0)
     dm_atr->task_req_num = (dm_atr->task_req_num+ 1), rcnt = dm_atr->task_req_num, stat = alterlist(
      dm_atr->task_req,rcnt),
     dm_atr->task_req[rcnt].task = dtr.task_number, dm_atr->task_req[rcnt].req = dtr.request_number,
     dm_atr->task_req[rcnt].feature = dtr.feature_number,
     dm_atr->task_req[rcnt].schema_date = dtr.schema_date, dm_atr->task_req[rcnt].deleted_ind = dtr
     .deleted_ind, dm_atr->task_req[rcnt].feature_ind = 0
     IF (dm_debug=1)
      CALL echo("***"),
      CALL echo(build("*** Adding Task-Req:",dtr.request_number," feature:",dtr.feature_number,
       " del:",
       dtr.deleted_ind)),
      CALL echo("***")
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((dm_atr->task_req_num > 0))
  SELECT INTO "nl:"
   FROM dm_task_request_r dtr,
    (dummyt f  WITH seq = value(request->feature_num)),
    (dummyt d  WITH seq = value(dm_atr->task_req_num))
   PLAN (d)
    JOIN (dtr
    WHERE (dtr.task_number=dm_atr->task_req[d.seq].task)
     AND (dtr.request_number=dm_atr->task_req[d.seq].req)
     AND dtr.feature_number > 1)
    JOIN (f
    WHERE (request->feature[f.seq].feature_number=dtr.feature_number))
   ORDER BY dtr.schema_date DESC
   DETAIL
    IF (((datetimediff(dtr.schema_date,dm_atr->task_req[d.seq].schema_date) > 0) OR ((dm_atr->
    task_req[d.seq].feature_ind=0))) )
     dm_atr->task_req[d.seq].feature = dtr.feature_number, dm_atr->task_req[d.seq].schema_date = dtr
     .schema_date, dm_atr->task_req[d.seq].deleted_ind = dtr.deleted_ind,
     dm_atr->task_req[d.seq].feature_ind = 1
     IF (dm_debug=1)
      CALL echo("***"),
      CALL echo(build("*** Task-Req:",dtr.request_number," replace OCD feature:",dtr.feature_number,
       " del:",
       dtr.deleted_ind)),
      CALL echo("***")
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   dr.*
   FROM dm_request dr,
    (dummyt d  WITH seq = value(dm_atr->task_req_num))
   PLAN (d)
    JOIN (dr
    WHERE (dr.request_number=dm_atr->task_req[d.seq].req)
     AND dr.request_number > 1
     AND (dm_atr->task_req[d.seq].deleted_ind=0))
   ORDER BY dr.schema_date DESC
   DETAIL
    found = 0
    FOR (i = 1 TO dm_atr->req_num)
      IF ((dm_atr->req[i].req=dr.request_number))
       found = i
       IF (datetimediff(dr.schema_date,dm_atr->req[i].schema_date) > 0)
        dm_atr->req[i].schema_date = dr.schema_date, dm_atr->req[i].feature = dr.feature_number,
        dm_atr->req[i].deleted_ind = dr.deleted_ind,
        dm_atr->req[i].feature_ind = 0
        IF (dm_debug=1)
         CALL echo("***"),
         CALL echo(build("*** Req:",dr.request_number," replace new feature:",dr.feature_number,
          " del:",
          dr.deleted_ind)),
         CALL echo("***")
        ENDIF
       ENDIF
       i = dm_atr->req_num
      ENDIF
    ENDFOR
    IF (found=0)
     dm_atr->req_num = (dm_atr->req_num+ 1), rcnt = dm_atr->req_num, stat = alterlist(dm_atr->req,
      rcnt),
     dm_atr->req[rcnt].req = dr.request_number, dm_atr->req[rcnt].feature = dr.feature_number, dm_atr
     ->req[rcnt].schema_date = dr.schema_date,
     dm_atr->req[rcnt].deleted_ind = dr.deleted_ind, dm_atr->req[rcnt].feature_ind = 0
     IF (dm_debug=1)
      CALL echo("***"),
      CALL echo(build("*** Adding Req:",dr.request_number," feature:",dr.feature_number," del:",
       dr.deleted_ind)),
      CALL echo("***")
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((dm_atr->req_num > 0))
  SELECT INTO "nl:"
   FROM dm_request dr,
    (dummyt f  WITH seq = value(request->feature_num)),
    (dummyt d  WITH seq = value(dm_atr->req_num))
   PLAN (d)
    JOIN (dr
    WHERE (dr.request_number=dm_atr->req[d.seq].req)
     AND dr.feature_number > 1)
    JOIN (f
    WHERE (request->feature[f.seq].feature_number=dr.feature_number))
   ORDER BY dr.schema_date DESC
   DETAIL
    IF (((datetimediff(dr.schema_date,dm_atr->req[d.seq].schema_date) > 0) OR ((dm_atr->req[d.seq].
    feature_ind=0))) )
     dm_atr->req[d.seq].feature = dr.feature_number, dm_atr->req[d.seq].schema_date = dr.schema_date,
     dm_atr->req[d.seq].deleted_ind = dr.deleted_ind,
     dm_atr->req[d.seq].feature_ind = 1
     IF (dm_debug=1)
      CALL echo("***"),
      CALL echo(build("*** Req:",dr.request_number," replace OCD feature:",dr.feature_number," del:",
       dr.deleted_ind)),
      CALL echo("***")
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
#get_atr_tree_end
#end_program
END GO
