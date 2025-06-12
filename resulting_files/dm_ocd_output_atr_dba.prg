CREATE PROGRAM dm_ocd_output_atr:dba
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
END GO
