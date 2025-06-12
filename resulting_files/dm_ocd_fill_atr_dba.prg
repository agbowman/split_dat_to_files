CREATE PROGRAM dm_ocd_fill_atr:dba
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
 SET ocd_atr_filename = build("ocd_schema_",request->alpha_feature_nbr,".ccl")
 SET tempstr = fillstring(110," ")
 SET line130 = fillstring(130," ")
 SET line80 = fillstring(79," ")
 SET bigstr = fillstring(255," ")
 SET app_count = 0
 SET task_count = 0
 SET req_count = 0
 SET app_task_count = 0
 SET task_req_count = 0
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
   row + 1, "commit go", row + 2
  WITH nocounter, maxrow = 1, maxcol = 150,
   format = variable, formfeed = none, append
 ;end select
 SET tempstr = fillstring(110," ")
 SET line130 = fillstring(130," ")
 SET line80 = fillstring(79," ")
 SET bigstr = fillstring(255," ")
 FOR (fi = 1 TO request->feature_num)
   SET app_count = 0
   SET task_count = 0
   SET req_count = 0
   SET app_task_count = 0
   SET task_req_count = 0
   FOR (ai = 1 TO request->feature[fi].app_num)
     SET app_count = (app_count+ 1)
     SET tempstr = fillstring(110," ")
     SET line130 = fillstring(130," ")
     SET line80 = fillstring(79," ")
     SET bigstr = fillstring(255," ")
     INSERT  FROM dm_ocd_application
      (application_number, alpha_feature_nbr, owner,
      description, active_dt_tm, active_ind,
      last_localized_dt_tm, text, inactive_dt_tm,
      log_access_ind, application_ini_ind, object_name,
      direct_access_ind, log_level, request_log_level,
      min_version_required, disable_cache_ind, module,
      feature_number, deleted_ind, schema_date,
      updt_dt_tm, updt_id, updt_task,
      updt_cnt, updt_applctx)(SELECT
       d.application_number, request->alpha_feature_nbr, d.owner,
       d.description, d.active_dt_tm, d.active_ind,
       d.last_localized_dt_tm, d.text, d.inactive_dt_tm,
       d.log_access_ind, d.application_ini_ind, d.object_name,
       d.direct_access_ind, d.log_level, d.request_log_level,
       d.min_version_required, d.disable_cache_ind, d.module,
       d.feature_number, d.deleted_ind, d.schema_date,
       cnvtdatetime(curdate,curtime3), 0, 0,
       0, 0
       FROM dm_application d
       WHERE (d.application_number=request->feature[fi].app[ai].app)
        AND (d.feature_number=request->feature[fi].feature_number))
      WITH nocounter
     ;end insert
     SELECT INTO value(ocd_atr_filename)
      FROM dm_application d
      WHERE (d.application_number=request->feature[fi].app[ai].app)
       AND (d.feature_number=request->feature[fi].feature_number)
      HEAD REPORT
       des = replace(replace(d.description,char(13)," ",0),char(10)," ",0), descr = replace(des,"'",
        "`",0), description = replace(descr,'"',"`",0),
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
       tx = replace(replace(d.text,char(13)," ",0),char(10)," ",0), txt = replace(tx,'"',"`",0), text
        = replace(txt,"'","`",0),
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
       "insert into dm_ocd_application dm", row + 1, line80 = build("  set dm.application_number=",d
        .application_number,","),
       line80, row + 1, line80 = build("  dm.alpha_feature_nbr=",request->alpha_feature_nbr,","),
       line80, row + 1, line80 = build('  dm.owner="',replace(replace(d.owner,char(13)," ",0),char(10
          )," ",0),'",'),
       line80, row + 1
       IF (bigd=0)
        line130 = build('  dm.description="',description,'",'), line130, row + 1
       ELSE
        line80 = "  dm.description = concat(trim(d1),trim(d2)),", line80, row + 1
       ENDIF
       IF (nullind(d.active_dt_tm)=0)
        line80 = build('  dm.active_dt_tm=cnvtdatetime("',format(d.active_dt_tm,";;Q"),'"),')
       ELSE
        line80 = "  dm.active_dt_tm=NULL,"
       ENDIF
       line80, row + 1, line80 = build("  dm.active_ind=",d.active_ind,","),
       line80, row + 1
       IF (nullind(d.last_localized_dt_tm)=0)
        line80 = build('  dm.last_localized_dt_tm=cnvtdatetime("',format(d.last_localized_dt_tm,";;Q"
          ),'"),')
       ELSE
        line80 = "  dm.last_localized_dt_tm=NULL,"
       ENDIF
       line80, row + 1
       IF (bigt=0)
        line130 = build('  dm.text="',text,'",'), line130, row + 1
       ELSE
        line80 = "  dm.text = concat(trim(t1),trim(t2),trim(t3),trim(t4)),", line80, row + 1
       ENDIF
       IF (nullind(d.inactive_dt_tm)=0)
        line80 = build('  dm.inactive_dt_tm=cnvtdatetime("',format(d.inactive_dt_tm,";;Q"),'"),')
       ELSE
        line80 = "  dm.inactive_dt_tm=NULL,"
       ENDIF
       line80, row + 1, line80 = build("  dm.log_access_ind=",d.log_access_ind,","),
       line80, row + 1, line80 = build("  dm.application_ini_ind=",d.application_ini_ind,","),
       line80, row + 1, line80 = build('  dm.object_name="',replace(replace(d.object_name,char(13),
          " ",0),char(10)," ",0),'",'),
       line80, row + 1, line80 = build("  dm.direct_access_ind=",d.direct_access_ind,","),
       line80, row + 1, line80 = build("  dm.log_level=",d.log_level,","),
       line80, row + 1, line80 = build("  dm.request_log_level=",d.request_log_level,","),
       line80, row + 1, line80 = build('  dm.min_version_required="',d.min_version_required,'",'),
       line80, row + 1, line80 = build("  dm.disable_cache_ind=",d.disable_cache_ind,","),
       line80, row + 1, line80 = build('  dm.module="',replace(replace(d.module,char(13)," ",0),char(
          10)," ",0),'",'),
       line80, row + 1, line80 = build("  dm.feature_number=",d.feature_number,","),
       line80, row + 1, line80 = build("  dm.deleted_ind=",d.deleted_ind,","),
       line80, row + 1
       IF (nullind(d.schema_date)=0)
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
       row + 1
      FOOT REPORT
       "commit go", row + 1, row + 1
      WITH nocounter, maxrow = 1, maxcol = 300,
       format = variable, formfeed = none, append
     ;end select
   ENDFOR
   FOR (ti = 1 TO request->feature[fi].task_num)
     SET task_count = (task_count+ 1)
     SET tempstr = fillstring(110," ")
     SET line130 = fillstring(130," ")
     SET line80 = fillstring(79," ")
     SET bigstr = fillstring(255," ")
     INSERT  FROM dm_ocd_task
      (task_number, alpha_feature_nbr, description,
      active_dt_tm, active_ind, text,
      inactive_dt_tm, subordinate_task_ind, optional_required_flag,
      feature_number, deleted_ind, schema_date,
      updt_dt_tm, updt_id, updt_task,
      updt_cnt, updt_applctx)(SELECT
       d.task_number, request->alpha_feature_nbr, d.description,
       d.active_dt_tm, d.active_ind, d.text,
       d.inactive_dt_tm, d.subordinate_task_ind, d.optional_required_flag,
       d.feature_number, d.deleted_ind, d.schema_date,
       cnvtdatetime(curdate,curtime3), 0, 0,
       0, 0
       FROM dm_application_task d
       WHERE (d.task_number=request->feature[fi].task[ti].task)
        AND (d.feature_number=request->feature[fi].feature_number))
      WITH nocounter
     ;end insert
     SELECT INTO value(ocd_atr_filename)
      FROM dm_application_task d
      WHERE (d.task_number=request->feature[fi].task[ti].task)
       AND (d.feature_number=request->feature[fi].feature_number)
      HEAD REPORT
       des = replace(replace(d.description,char(13)," ",0),char(10)," ",0), descr = replace(des,"'",
        "`",0), description = replace(descr,'"',"`",0),
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
       tx = replace(replace(d.text,char(13)," ",0),char(10)," ",0), txt = replace(tx,'"',"`",0), text
        = replace(txt,"'","`",0),
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
       "insert into dm_ocd_task dm", row + 1, line80 = build("  set dm.task_number=",d.task_number,
        ","),
       line80, row + 1, line80 = build("  dm.alpha_feature_nbr=",request->alpha_feature_nbr,","),
       line80, row + 1
       IF (bigd=0)
        line130 = build('  dm.description="',description,'",'), line130, row + 1
       ELSE
        line80 = "  dm.description = concat(trim(d1),trim(d2)),", line80, row + 1
       ENDIF
       IF (nullind(d.active_dt_tm)=0)
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
       IF (nullind(d.inactive_dt_tm)=0)
        line80 = build('  dm.inactive_dt_tm=cnvtdatetime("',format(d.inactive_dt_tm,";;Q"),'"),')
       ELSE
        line80 = "  dm.inactive_dt_tm=NULL,"
       ENDIF
       line80, row + 1, line80 = build("  dm.subordinate_task_ind=",d.subordinate_task_ind,","),
       line80, row + 1, line80 = build("  dm.optional_required_flag=",d.optional_required_flag,","),
       line80, row + 1, line80 = build("  dm.feature_number=",d.feature_number,","),
       line80, row + 1, line80 = build("  dm.deleted_ind=",d.deleted_ind,","),
       line80, row + 1
       IF (nullind(d.schema_date)=0)
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
       row + 1
      FOOT REPORT
       "commit go", row + 1, row + 1
      WITH nocounter, maxrow = 1, maxcol = 300,
       format = variable, formfeed = none, append
     ;end select
   ENDFOR
   FOR (ri = 1 TO request->feature[fi].req_num)
     SET req_count = (req_count+ 1)
     SET tempstr = fillstring(110," ")
     SET line130 = fillstring(130," ")
     SET line80 = fillstring(79," ")
     SET bigstr = fillstring(255," ")
     INSERT  FROM dm_ocd_request
      (request_number, alpha_feature_nbr, description,
      request_name, text, active_dt_tm,
      active_ind, inactive_dt_tm, prolog_script,
      epilog_script, write_to_que_ind, requestclass,
      cachetime, feature_number, deleted_ind,
      schema_date, updt_dt_tm, updt_id,
      updt_task, updt_cnt, updt_applctx)(SELECT
       d.request_number, request->alpha_feature_nbr, d.description,
       d.request_name, d.text, d.active_dt_tm,
       d.active_ind, d.inactive_dt_tm, d.prolog_script,
       d.epilog_script, d.write_to_que_ind, d.requestclass,
       d.cachetime, d.feature_number, d.deleted_ind,
       d.schema_date, cnvtdatetime(curdate,curtime3), 0,
       0, 0, 0
       FROM dm_request d
       WHERE (d.request_number=request->feature[fi].req[ri].req)
        AND (d.feature_number=request->feature[fi].feature_number))
      WITH nocounter
     ;end insert
     SELECT INTO value(ocd_atr_filename)
      FROM dm_request d
      WHERE (d.request_number=request->feature[fi].req[ri].req)
       AND (d.feature_number=request->feature[fi].feature_number)
      HEAD REPORT
       des = replace(replace(d.description,char(13)," ",0),char(10)," ",0), descr = replace(des,"'",
        "`",0), description = replace(descr,'"',"`",0),
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
       tx = replace(replace(d.text,char(13)," ",0),char(10)," ",0), txt = replace(tx,'"',"`",0), text
        = replace(txt,"'","`",0),
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
       "insert into dm_ocd_request dm", row + 1, line80 = build("  set dm.request_number=",d
        .request_number,","),
       line80, row + 1, line80 = build("  dm.alpha_feature_nbr=",request->alpha_feature_nbr,","),
       line80, row + 1
       IF (bigd=0)
        line130 = build('  dm.description="',description,'",'), line130, row + 1
       ELSE
        line80 = "  dm.description = concat(trim(d1),trim(d2)),", line80, row + 1
       ENDIF
       line80 = build('  dm.request_name="',replace(replace(d.request_name,char(13)," ",0),char(10),
         " ",0),'",'), line80, row + 1
       IF (bigt=0)
        line130 = build('  dm.text="',text,'",'), line130, row + 1
       ELSE
        line80 = "  dm.text = concat(trim(t1),trim(t2),trim(t3),trim(t4)),", line80, row + 1
       ENDIF
       line80 = build("  dm.active_ind=",d.active_ind,","), line80, row + 1
       IF (nullind(d.active_dt_tm)=0)
        line80 = build('  dm.active_dt_tm=cnvtdatetime("',format(d.active_dt_tm,";;Q"),'"),')
       ELSE
        line80 = "  dm.active_dt_tm=NULL,"
       ENDIF
       line80, row + 1
       IF (nullind(d.inactive_dt_tm)=0)
        line80 = build('  dm.inactive_dt_tm=cnvtdatetime("',format(d.inactive_dt_tm,";;Q"),'"),')
       ELSE
        line80 = "  dm.inactive_dt_tm=NULL,"
       ENDIF
       line80, row + 1, line80 = build('  dm.prolog_script="',replace(replace(d.prolog_script,char(13
           )," ",0),char(10)," ",0),'",'),
       line80, row + 1, line80 = build('  dm.epilog_script="',replace(replace(d.epilog_script,char(13
           )," ",0),char(10)," ",0),'",'),
       line80, row + 1, line80 = build("  dm.write_to_que_ind=",d.write_to_que_ind,","),
       line80, row + 1, line80 = build("  dm.requestclass=",d.requestclass,","),
       line80, row + 1, line80 = build("  dm.cachetime=",d.cachetime,","),
       line80, row + 1, line80 = build("  dm.feature_number=",d.feature_number,","),
       line80, row + 1, line80 = build("  dm.deleted_ind=",d.deleted_ind,","),
       line80, row + 1
       IF (nullind(d.schema_date)=0)
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
       row + 1
      FOOT REPORT
       "commit go", row + 1, row + 1
      WITH nocounter, maxrow = 1, maxcol = 300,
       format = variable, formfeed = none, append
     ;end select
   ENDFOR
   FOR (ati = 1 TO request->feature[fi].apptask_num)
     SET app_task_count = (app_task_count+ 1)
     SET line130 = fillstring(130," ")
     SET line80 = fillstring(79," ")
     INSERT  FROM dm_ocd_app_task_r
      (application_number, task_number, alpha_feature_nbr,
      feature_number, deleted_ind, schema_date,
      updt_dt_tm, updt_id, updt_task,
      updt_cnt, updt_applctx)(SELECT
       d.application_number, d.task_number, request->alpha_feature_nbr,
       d.feature_number, d.deleted_ind, d.schema_date,
       cnvtdatetime(curdate,curtime3), 0, 0,
       0, 0
       FROM dm_application_task_r d
       WHERE (d.application_number=request->feature[fi].apptask[ati].app)
        AND (d.task_number=request->feature[fi].apptask[ati].task)
        AND (d.feature_number=request->feature[fi].feature_number))
      WITH nocounter
     ;end insert
     SELECT INTO value(ocd_atr_filename)
      FROM dm_application_task_r d
      WHERE (d.application_number=request->feature[fi].apptask[ati].app)
       AND (d.task_number=request->feature[fi].apptask[ati].task)
       AND (d.feature_number=request->feature[fi].feature_number)
      DETAIL
       "insert into dm_ocd_app_task_r dm", row + 1, line80 = build("  set dm.application_number=",d
        .application_number,","),
       line80, row + 1, line80 = build("  dm.task_number=",d.task_number,","),
       line80, row + 1, line80 = build("  dm.alpha_feature_nbr=",request->alpha_feature_nbr,","),
       line80, row + 1, line80 = build("  dm.feature_number=",d.feature_number,","),
       line80, row + 1, line80 = build("  dm.deleted_ind=",d.deleted_ind,","),
       line80, row + 1
       IF (nullind(d.schema_date)=0)
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
       row + 1
      FOOT REPORT
       "commit go", row + 1, row + 1
      WITH nocounter, maxrow = 1, maxcol = 300,
       format = variable, formfeed = none, append
     ;end select
   ENDFOR
   FOR (tri = 1 TO request->feature[fi].taskreq_num)
     SET task_req_count = (task_req_count+ 1)
     SET line130 = fillstring(130," ")
     SET line80 = fillstring(79," ")
     INSERT  FROM dm_ocd_task_req_r
      (task_number, request_number, alpha_feature_nbr,
      feature_number, deleted_ind, schema_date,
      updt_dt_tm, updt_id, updt_task,
      updt_cnt, updt_applctx)(SELECT
       d.task_number, d.request_number, request->alpha_feature_nbr,
       d.feature_number, d.deleted_ind, d.schema_date,
       cnvtdatetime(curdate,curtime3), 0, 0,
       0, 0
       FROM dm_task_request_r d
       WHERE (d.task_number=request->feature[fi].taskreq[tri].task)
        AND (d.request_number=request->feature[fi].taskreq[tri].req)
        AND (d.feature_number=request->feature[fi].feature_number))
      WITH nocounter
     ;end insert
     SELECT INTO value(ocd_atr_filename)
      FROM dm_task_request_r d
      WHERE (d.task_number=request->feature[fi].taskreq[tri].task)
       AND (d.request_number=request->feature[fi].taskreq[tri].req)
       AND (d.feature_number=request->feature[fi].feature_number)
      DETAIL
       "insert into dm_ocd_task_req_r dm", row + 1, line80 = build("  set dm.task_number=",d
        .task_number,","),
       line80, row + 1, line80 = build("  dm.request_number=",d.request_number,","),
       line80, row + 1, line80 = build("  dm.alpha_feature_nbr=",request->alpha_feature_nbr,","),
       line80, row + 1, line80 = build("  dm.feature_number=",d.feature_number,","),
       line80, row + 1, line80 = build("  dm.deleted_ind=",d.deleted_ind,","),
       line80, row + 1
       IF (nullind(d.schema_date)=0)
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
       row + 1
      FOOT REPORT
       "commit go", row + 1, row + 1
      WITH nocounter, maxrow = 1, maxcol = 300,
       format = variable, formfeed = none, append
     ;end select
   ENDFOR
   IF ((((((app_count+ task_count)+ req_count)+ app_task_count)+ task_req_count) > 0))
    UPDATE  FROM dm_ocd_features d
     SET d.schema_ind = 1
     WHERE (d.alpha_feature_nbr=request->alpha_feature_nbr)
      AND (d.feature_number=request->feature[fi].feature_number)
     WITH nocounter
    ;end update
    SELECT INTO value(ocd_atr_filename)
     FROM dual
     DETAIL
      "update into dm_ocd_features d", row + 1, "  set d.schema_ind = 1",
      row + 1, "where d.alpha_feature_nbr = ", request->alpha_feature_nbr,
      row + 1, "  and d.feature_number = ", request->feature[fi].feature_number,
      row + 1, "with nocounter go", row + 1
     WITH nocounter, maxrow = 1, maxcol = 300,
      format = variable, formfeed = none, append
    ;end select
    COMMIT
   ENDIF
 ENDFOR
 COMMIT
 SELECT INTO value(ocd_atr_filename)
  FROM dual
  DETAIL
   "execute dm_ocd_refresh_atr go", row + 1, row + 1
  WITH nocounter, maxrow = 1, maxcol = 300,
   format = variable, formfeed = none, append
 ;end select
 SET reply->status_data.status = "S"
#end_script
END GO
