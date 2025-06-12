CREATE PROGRAM dm_stat_workflow_summary:dba
 DECLARE esmerror(msg=vc,ret=i2) = i2
 DECLARE esmcheckccl(z=vc) = i2
 DECLARE esmdate = f8
 DECLARE esmmsg = c196
 DECLARE esmcategory = c128
 DECLARE esmerrorcnt = i2
 SET esmexit = 0
 SET esmreturn = 1
 SET esmerrorcnt = 0
 SUBROUTINE esmerror(msg,ret)
   SET esmerrorcnt = (esmerrorcnt+ 1)
   IF (esmerrorcnt <= 3)
    SET esmdate = cnvtdatetime(curdate,curtime3)
    SET esmmsg = fillstring(196," ")
    SET esmmsg = substring(1,195,msg)
    SET esmcategory = fillstring(128," ")
    SET esmcategory = curprog
    EXECUTE dm_stat_error esmdate, esmmsg, esmcategory
    CALL echo(msg)
    CALL esmcheckccl("x")
   ELSE
    GO TO exit_program
   ENDIF
   IF (ret=esmexit)
    GO TO exit_program
   ENDIF
   SET esmerrorcnt = 0
   RETURN(esmreturn)
 END ;Subroutine
 SUBROUTINE esmcheckccl(z)
   SET cclerrmsg = fillstring(132," ")
   SET cclerrcode = error(cclerrmsg,0)
   IF (cclerrcode != 0)
    SET execrc = 1
    CALL esmerror(cclerrmsg,esmexit)
   ENDIF
   RETURN(esmreturn)
 END ;Subroutine
 DECLARE findcomma(x=vc(ref),n=i4) = i4
 DECLARE findchar(x=vc(ref),n=i4,c=vc) = i4
 DECLARE findnextchar(x=vc(ref),c=vc,dmt_position=i4) = i4
 DECLARE findcharworker(x=vc,n=i4,c=vc,dmt_position=i4) = i4
 DECLARE ntharg(x=vc(ref),n=i4,c=vc) = vc
 DECLARE nextarg(x=vc(ref),c=vc) = vc
 DECLARE proflog(x=vc) = null
 SET startpos = 0
 SET endpos = 0
 SUBROUTINE findcomma(x,n)
   RETURN(findchar(x,n,","))
 END ;Subroutine
 SUBROUTINE findnextchar(x,c,dmt_position)
   RETURN(findcharworker(x,1,c,dmt_position))
 END ;Subroutine
 SUBROUTINE findchar(x,n,c)
   RETURN(findcharworker(x,n,c,0))
 END ;Subroutine
 SUBROUTINE findcharworker(x,n,c,dmt_position)
   SET retpos = 1
   SET found = 0
   WHILE (retpos != 0
    AND found != n)
     SET retpos = findstring(c,x,(dmt_position+ 1))
     SET dmt_position = retpos
     IF (dmt_position)
      SET found = (found+ 1)
     ENDIF
   ENDWHILE
   RETURN(dmt_position)
 END ;Subroutine
 SUBROUTINE nextarg(x,c)
   SET str = fillstring(132," ")
   SET len = size(x)
   SET startpos = endpos
   SET startpos = findnextchar(x,c,startpos)
   IF (startpos=0)
    RETURN(trim(str))
   ELSE
    SET endpos = findnextchar(x,c,startpos)
    IF (endpos=0)
     SET endpos = len
    ELSE
     SET endpos = (endpos - 1)
    ENDIF
    SET startpos = (startpos+ 1)
    IF (startpos > endpos)
     RETURN(trim(str))
    ELSE
     RETURN(substring(startpos,((endpos - startpos)+ 1),x))
    ENDIF
   ENDIF
   RETURN(trim(str))
 END ;Subroutine
 SUBROUTINE ntharg(x,n,c)
   SET str = fillstring(132," ")
   SET len = size(x)
   SET startpos = 0
   SET endpos = 0
   IF (len < 1)
    RETURN(trim(str))
   ENDIF
   IF (n < 1)
    RETURN(trim(str))
   ELSE
    IF (n=1)
     SET startpos = 1
    ELSE
     SET startpos = findchar(x,(n - 1),c)
     IF (startpos=len)
      RETURN(trim(str))
     ELSEIF (startpos=0)
      SET startpos = 1
     ELSE
      SET startpos = (startpos+ 1)
     ENDIF
    ENDIF
    SET endpos = findnextchar(x,c,(startpos - 1))
    IF (endpos=1)
     RETURN(trim(str))
    ELSEIF (endpos=0)
     SET endpos = len
    ELSE
     SET endpos = (endpos - 1)
    ENDIF
    SET str = substring(startpos,((endpos - startpos)+ 1),x)
   ENDIF
   RETURN(trim(str))
 END ;Subroutine
 SUBROUTINE proflog(x)
   CALL echo(concat(format(cnvtdatetime(curdate,curtime3),";;Q")," ",curprog,": ",x))
 END ;Subroutine
 IF ( NOT (validate(dsr,0)))
  RECORD dsr(
    1 qual[*]
      2 stat_snap_dt_tm = dq8
      2 snapshot_type = c100
      2 client_mnemonic = c10
      2 domain_name = c20
      2 node_name = c30
      2 qual[*]
        3 stat_name = vc
        3 stat_seq = i4
        3 stat_str_val = vc
        3 stat_type = i4
        3 stat_number_val = f8
        3 stat_date_val = dq8
        3 stat_clob_val = vc
  )
 ENDIF
 RECORD seq_ids(
   1 qual[*]
     2 seq_val = f8
 )
 RECORD m_dm2_seq_stat(
   1 n_status = i4
   1 s_error_msg = vc
 ) WITH protect
 DECLARE functionwquotes = vc
 DECLARE start_pos = i4
 DECLARE end_pos = i4
 DECLARE property_val = f8
 DECLARE order_timer = vc WITH constant("COM.CERNER.POWERCHART.ORDERS.ORDERSESSION")
 DECLARE chart_timer = vc WITH constant("COM.CERNER.POWERCHART.ORDERS.CHARTSESSION")
 DECLARE ds_cnt = i4 WITH noconstant(0)
 DECLARE wrkflw_stats_table_exists = i2 WITH noconstant(0)
 RECORD linestruct(
   1 function = vc
   1 elapsed = f8
   1 username = vc
 )
 RECORD chartproperties(
   1 navigationevents = i4
   1 dataentryevents = i4
   1 tabsvisited = i4
   1 patientid = f8
 )
 RECORD orderproperties(
   1 personid = f8
   1 orderstabnavigationevents = i4
   1 orderstabdataentryevents = i4
   1 orderstabmousedistance = f8
   1 ordercount = i4
   1 favoritesusedcount = i4
   1 foldersusedcount = i4
   1 searchusedcount = i4
   1 powerplansusedcount = i4
   1 caresetusedcount = i4
   1 othertabcount = i4
   1 othertabnavigationevents = i4
   1 othertabdataentryevents = i4
   1 othertabmousedistance = f8
   1 othertabtime = f8
 )
 SUBROUTINE parseline(fileline)
   SET start_pos = 1
   SET end_pos = findstring(",",fileline,start_pos)
   SET start_pos = (end_pos+ 1)
   SET end_pos = findstring(",",fileline,start_pos)
   SET start_pos = (end_pos+ 1)
   SET end_pos = findstring(",",fileline,start_pos)
   SET start_pos = (end_pos+ 1)
   SET end_pos = findstring(",",fileline,start_pos)
   SET functionwquotes = trim(substring(start_pos,(end_pos - start_pos),fileline))
   SET linestruct->function = cnvtupper(substring(2,(size(functionwquotes,1) - 2),functionwquotes))
   SET start_pos = (end_pos+ 1)
   SET end_pos = findstring(",",fileline,start_pos)
   SET linestruct->elapsed = cnvtreal(trim(substring(start_pos,(end_pos - start_pos),fileline)))
   SET start_pos = (end_pos+ 1)
   SET end_pos = findstring(",",fileline,start_pos)
   SET start_pos = (end_pos+ 1)
   SET end_pos = findstring(",",fileline,start_pos)
   SET start_pos = (end_pos+ 1)
   SET end_pos = findstring(",",fileline,start_pos)
   SET start_pos = (end_pos+ 1)
   SET end_pos = findstring(",",fileline,start_pos)
   SET start_pos = (end_pos+ 1)
   SET end_pos = findstring(",",fileline,start_pos)
   SET linestruct->username = cnvtlower(trim(substring(start_pos,(end_pos - start_pos),fileline)))
   IF ((linestruct->function=chart_timer))
    CALL getpropertyvalue("NavigationEvents")
    SET chartproperties->navigationevents = property_val
    CALL getpropertyvalue("DataEntryEvents")
    SET chartproperties->dataentryevents = property_val
    CALL getpropertyvalue("PatientId")
    SET chartproperties->patientid = property_val
    CALL getpropertyvalue("TabsVisited")
    SET chartproperties->tabsvisited = property_val
   ELSEIF ((linestruct->function=order_timer))
    CALL getpropertyvalue("PersonId")
    SET orderproperties->personid = property_val
    CALL getpropertyvalue("OrdersTabNavigationEvents")
    SET orderproperties->orderstabnavigationevents = property_val
    CALL getpropertyvalue("OrdersTabDataEntryEvents")
    SET orderproperties->orderstabdataentryevents = property_val
    CALL getpropertyvalue("OrdersTabMouseDistance")
    SET orderproperties->orderstabmousedistance = property_val
    CALL getpropertyvalue("OrderCount")
    SET orderproperties->ordercount = property_val
    CALL getpropertyvalue("FavoritesUsedCount")
    SET orderproperties->favoritesusedcount = property_val
    CALL getpropertyvalue("FoldersUsedCount")
    SET orderproperties->foldersusedcount = property_val
    CALL getpropertyvalue("PowerPlansUsedCount")
    SET orderproperties->powerplansusedcount = property_val
    CALL getpropertyvalue("CaresetUsedCount")
    SET orderproperties->caresetusedcount = property_val
    CALL getpropertyvalue("OtherTabCount")
    SET orderproperties->othertabcount = property_val
    CALL getpropertyvalue("OtherTabNavigationEvents")
    SET orderproperties->othertabnavigationevents = property_val
    CALL getpropertyvalue("OtherTabDataEntryEvents")
    SET orderproperties->othertabdataentryevents = property_val
    CALL getpropertyvalue("OtherTabMouseDistance")
    SET orderproperties->othertabmousedistance = property_val
    CALL getpropertyvalue("OtherTabTime")
    SET orderproperties->othertabtime = property_val
    CALL getpropertyvalue("SearchUsedCount")
    SET orderproperties->searchusedcount = property_val
   ENDIF
 END ;Subroutine
 RECORD curr_workload_stats(
   1 timerid = c80
   1 username = c50
   1 count = i4
   1 totaltime = f8
   1 extra1 = f8
   1 extra2 = f8
   1 extra3 = f8
   1 extra4 = f8
   1 extra5 = f8
   1 extra6 = f8
   1 extra7 = f8
   1 extra8 = f8
   1 extra9 = f8
   1 extra10 = f8
   1 extra11 = f8
   1 extra12 = f8
   1 extra13 = f8
   1 extra14 = f8
   1 extra15 = f8
   1 extra16 = f8
   1 extra17 = f8
   1 extra18 = f8
   1 extra19 = f8
   1 extra20 = f8
   1 extra21 = f8
 )
 SUBROUTINE summarizeworkflowrecord(x)
   SET curr_workload_stats->username = linestruct->username
   SET curr_workload_stats->count = 0
   SET curr_workload_stats->totaltime = 0.0
   SET curr_workload_stats->timerid = linestruct->function
   SET curr_workload_stats->extra1 = 0.0
   SET curr_workload_stats->extra2 = 0.0
   SET curr_workload_stats->extra3 = 0.0
   SET curr_workload_stats->extra4 = 0.0
   SET curr_workload_stats->extra5 = 0.0
   SET curr_workload_stats->extra6 = 0.0
   SET curr_workload_stats->extra7 = 0.0
   SET curr_workload_stats->extra8 = 0.0
   SET curr_workload_stats->extra9 = 0.0
   SET curr_workload_stats->extra10 = 0.0
   SET curr_workload_stats->extra11 = 0.0
   SET curr_workload_stats->extra12 = 0.0
   SET curr_workload_stats->extra13 = 0.0
   SET curr_workload_stats->extra14 = 0.0
   SET curr_workload_stats->extra15 = 0.0
   SET curr_workload_stats->extra16 = 0.0
   SET curr_workload_stats->extra17 = 0.0
   SET curr_workload_stats->extra18 = 0.0
   SET curr_workload_stats->extra19 = 0.0
   SET curr_workload_stats->extra20 = 0.0
   SET curr_workload_stats->extra21 = 0.0
   SET wf_record_found = 0
   IF (wrkflw_stats_table_exists=1)
    SELECT INTO "nl:"
     FROM wrkflw_stats ws
     WHERE ws.usertimer=concat(curr_workload_stats->username,"||",curr_workload_stats->timerid)
     DETAIL
      curr_workload_stats->count = ws.count, curr_workload_stats->totaltime = ws.totaltime,
      curr_workload_stats->extra1 = ws.extra1,
      curr_workload_stats->extra2 = ws.extra2, curr_workload_stats->extra3 = ws.extra3,
      curr_workload_stats->extra4 = ws.extra4,
      curr_workload_stats->extra5 = ws.extra5, curr_workload_stats->extra6 = ws.extra6,
      curr_workload_stats->extra7 = ws.extra7,
      curr_workload_stats->extra8 = ws.extra8, curr_workload_stats->extra9 = ws.extra9,
      curr_workload_stats->extra10 = ws.extra10,
      curr_workload_stats->extra11 = ws.extra11, curr_workload_stats->extra12 = ws.extra12,
      curr_workload_stats->extra13 = ws.extra13,
      curr_workload_stats->extra14 = ws.extra14, curr_workload_stats->extra15 = ws.extra15,
      curr_workload_stats->extra16 = ws.extra16,
      curr_workload_stats->extra17 = ws.extra17, curr_workload_stats->extra18 = ws.extra18,
      curr_workload_stats->extra19 = ws.extra19,
      curr_workload_stats->extra20 = ws.extra20, curr_workload_stats->extra21 = ws.extra21,
      wf_record_found = 1
     WITH nocounter
    ;end select
   ENDIF
   SET curr_workload_stats->count = (curr_workload_stats->count+ 1)
   SET curr_workload_stats->totaltime = (curr_workload_stats->totaltime+ linestruct->elapsed)
   IF ((linestruct->function=chart_timer))
    SET curr_workload_stats->extra1 = (curr_workload_stats->extra1+ chartproperties->navigationevents
    )
    SET curr_workload_stats->extra2 = (curr_workload_stats->extra2+ chartproperties->dataentryevents)
    IF ((chartproperties->tabsvisited > 0))
     SET curr_workload_stats->extra3 = (curr_workload_stats->extra3+ chartproperties->tabsvisited)
     SET curr_workload_stats->extra4 = (curr_workload_stats->extra4+ 1)
    ENDIF
   ELSEIF ((linestruct->function=order_timer))
    SET curr_workload_stats->extra1 = (curr_workload_stats->extra1+ orderproperties->
    orderstabnavigationevents)
    SET curr_workload_stats->extra2 = (curr_workload_stats->extra2+ orderproperties->
    orderstabdataentryevents)
    SET curr_workload_stats->extra3 = (curr_workload_stats->extra3+ orderproperties->
    orderstabmousedistance)
    SET curr_workload_stats->extra4 = (curr_workload_stats->extra4+ orderproperties->ordercount)
    IF ((orderproperties->favoritesusedcount > 0))
     SET curr_workload_stats->extra5 = (curr_workload_stats->extra5+ 1)
     SET curr_workload_stats->extra6 = (curr_workload_stats->extra6+ orderproperties->
     favoritesusedcount)
    ENDIF
    IF ((orderproperties->foldersusedcount > 0))
     SET curr_workload_stats->extra7 = (curr_workload_stats->extra7+ 1)
     SET curr_workload_stats->extra8 = (curr_workload_stats->extra8+ orderproperties->
     foldersusedcount)
    ENDIF
    IF ((orderproperties->searchusedcount > 0))
     SET curr_workload_stats->extra9 = (curr_workload_stats->extra9+ 1)
     SET curr_workload_stats->extra10 = (curr_workload_stats->extra10+ orderproperties->
     searchusedcount)
    ENDIF
    IF ((orderproperties->caresetusedcount > 0))
     SET curr_workload_stats->extra11 = (curr_workload_stats->extra11+ 1)
     SET curr_workload_stats->extra12 = (curr_workload_stats->extra12+ orderproperties->
     caresetusedcount)
    ENDIF
    IF ((orderproperties->powerplansusedcount > 0))
     SET curr_workload_stats->extra13 = (curr_workload_stats->extra13+ 1)
     SET curr_workload_stats->extra14 = (curr_workload_stats->extra14+ orderproperties->
     powerplansusedcount)
    ENDIF
    IF ((orderproperties->othertabcount > 0))
     SET curr_workload_stats->extra15 = (curr_workload_stats->extra15+ 1)
     SET curr_workload_stats->extra16 = (curr_workload_stats->extra16+ orderproperties->othertabcount
     )
     SET curr_workload_stats->extra17 = (curr_workload_stats->extra17+ orderproperties->othertabtime)
     SET curr_workload_stats->extra18 = (curr_workload_stats->extra18+ orderproperties->
     othertabnavigationevents)
     SET curr_workload_stats->extra19 = (curr_workload_stats->extra19+ orderproperties->
     othertabdataentryevents)
     SET curr_workload_stats->extra20 = (curr_workload_stats->extra20+ orderproperties->
     othertabmousedistance)
    ENDIF
    IF ((orderproperties->searchusedcount=0)
     AND (orderproperties->foldersusedcount=0)
     AND (orderproperties->favoritesusedcount=0))
     SET curr_workload_stats->extra21 = (curr_workload_stats->extra21+ 1)
    ENDIF
   ENDIF
   IF (wrkflw_stats_table_exists=0)
    DECLARE usertimer = c132 WITH noconstant("")
    SELECT INTO TABLE wrkflw_stats
     usertimer = concat(curr_workload_stats->username,"||",curr_workload_stats->timerid), count =
     curr_workload_stats->count, totaltime = curr_workload_stats->totaltime,
     extra1 = curr_workload_stats->extra1, extra2 = curr_workload_stats->extra2, extra3 =
     curr_workload_stats->extra3,
     extra4 = curr_workload_stats->extra4, extra5 = curr_workload_stats->extra5, extra6 =
     curr_workload_stats->extra6,
     extra7 = curr_workload_stats->extra7, extra8 = curr_workload_stats->extra8, extra9 =
     curr_workload_stats->extra9,
     extra10 = curr_workload_stats->extra10, extra11 = curr_workload_stats->extra11, extra12 =
     curr_workload_stats->extra12,
     extra13 = curr_workload_stats->extra13, extra14 = curr_workload_stats->extra14, extra15 =
     curr_workload_stats->extra15,
     extra16 = curr_workload_stats->extra16, extra17 = curr_workload_stats->extra17, extra18 =
     curr_workload_stats->extra18,
     extra19 = curr_workload_stats->extra19, extra20 = curr_workload_stats->extra20, extra21 =
     curr_workload_stats->extra21
     ORDER BY usertimer
     WITH organization = indexed, nocounter
    ;end select
    FREE DEFINE wrkflw_stats
    DEFINE wrkflw_stats  WITH modify
    SET wrkflw_stats_table_exists = 1
   ELSEIF (wf_record_found=0)
    INSERT  FROM wrkflw_stats ws
     SET ws.usertimer = concat(curr_workload_stats->username,"||",curr_workload_stats->timerid), ws
      .count = curr_workload_stats->count, ws.totaltime = curr_workload_stats->totaltime,
      ws.extra1 = curr_workload_stats->extra1, ws.extra2 = curr_workload_stats->extra2, ws.extra3 =
      curr_workload_stats->extra3,
      ws.extra4 = curr_workload_stats->extra4, ws.extra5 = curr_workload_stats->extra5, ws.extra6 =
      curr_workload_stats->extra6,
      ws.extra7 = curr_workload_stats->extra7, ws.extra8 = curr_workload_stats->extra8, ws.extra9 =
      curr_workload_stats->extra9,
      ws.extra10 = curr_workload_stats->extra10, ws.extra11 = curr_workload_stats->extra11, ws
      .extra12 = curr_workload_stats->extra12,
      ws.extra13 = curr_workload_stats->extra13, ws.extra14 = curr_workload_stats->extra14, ws
      .extra15 = curr_workload_stats->extra15,
      ws.extra16 = curr_workload_stats->extra16, ws.extra17 = curr_workload_stats->extra17, ws
      .extra18 = curr_workload_stats->extra18,
      ws.extra19 = curr_workload_stats->extra19, ws.extra20 = curr_workload_stats->extra20, ws
      .extra21 = curr_workload_stats->extra21
     WITH nocounter
    ;end insert
   ELSE
    UPDATE  FROM wrkflw_stats ws
     SET ws.usertimer = concat(curr_workload_stats->username,"||",curr_workload_stats->timerid), ws
      .count = curr_workload_stats->count, ws.totaltime = curr_workload_stats->totaltime,
      ws.extra1 = curr_workload_stats->extra1, ws.extra2 = curr_workload_stats->extra2, ws.extra3 =
      curr_workload_stats->extra3,
      ws.extra4 = curr_workload_stats->extra4, ws.extra5 = curr_workload_stats->extra5, ws.extra6 =
      curr_workload_stats->extra6,
      ws.extra7 = curr_workload_stats->extra7, ws.extra8 = curr_workload_stats->extra8, ws.extra9 =
      curr_workload_stats->extra9,
      ws.extra10 = curr_workload_stats->extra10, ws.extra11 = curr_workload_stats->extra11, ws
      .extra12 = curr_workload_stats->extra12,
      ws.extra13 = curr_workload_stats->extra13, ws.extra14 = curr_workload_stats->extra14, ws
      .extra15 = curr_workload_stats->extra15,
      ws.extra16 = curr_workload_stats->extra16, ws.extra17 = curr_workload_stats->extra17, ws
      .extra18 = curr_workload_stats->extra18,
      ws.extra19 = curr_workload_stats->extra19, ws.extra20 = curr_workload_stats->extra20, ws
      .extra21 = curr_workload_stats->extra21
     WHERE ws.usertimer=concat(curr_workload_stats->username,"||",curr_workload_stats->timerid)
     WITH nocounter
    ;end update
   ENDIF
 END ;Subroutine
 SUBROUTINE dumpdiscretedata(fileline)
   SET ds_cnt = (ds_cnt+ 1)
   IF (mod(ds_cnt,10)=1)
    SET stat = alterlist(dsr->qual[1].qual,(ds_cnt+ 9))
   ENDIF
   SET dsr->qual[1].qual[ds_cnt].stat_name = "WORKFLOW_DISCRETE"
   SET dsr->qual[1].qual[ds_cnt].stat_type = 2
   SET dsr->qual[1].qual[ds_cnt].stat_seq = (ds_cnt - 1)
   SET dsr->qual[1].qual[ds_cnt].stat_str_val = linestruct->function
   IF (size(fileline,3) > 4000)
    SET dsr->qual[1].qual[ds_cnt].stat_clob_val = substring(1,4000,fileline)
   ELSE
    SET dsr->qual[1].qual[ds_cnt].stat_clob_val = fileline
   ENDIF
 END ;Subroutine
 SUBROUTINE preparediscretedata(x)
   SET stat = alterlist(dsr->qual,1)
   SET dsr->qual[1].snapshot_type = "WORKFLOW_DISCRETE.2"
   SET dsr->qual[1].stat_snap_dt_tm = cnvtdatetime((curdate - 1),0)
 END ;Subroutine
 SUBROUTINE finalizediscretedata(x)
  IF (ds_cnt > 0)
   SET stat = alterlist(dsr->qual[1].qual,ds_cnt)
  ELSE
   SET stat = alterlist(dsr->qual[1].qual,1)
   SET dsr->qual[1].qual[1].stat_name = "NO_NEW_DATA"
  ENDIF
  EXECUTE dm_stat_snaps_load
 END ;Subroutine
 DECLARE houritr = i4 WITH noconstant(0)
 DECLARE clientmnemonic = vc WITH noconstant("")
 DECLARE snapid = f8 WITH noconstant(0.0)
 DECLARE snapshotdt = vc WITH noconstant("")
 DECLARE oracleday = i4 WITH noconstant(0)
 DECLARE oraclemonth = i4 WITH noconstant(0)
 DECLARE oracleyear = i4 WITH noconstant(0)
 DECLARE oracletime = vc WITH noconstant("")
 DECLARE oracledatepart = vc WITH noconstant("")
 RECORD temp_workflow_data(
   1 seq_val = f8
   1 stats[*]
     2 user_name = vc
     2 stat_name = vc
     2 stat_number_val = f8
     2 stat_seq = i4
     2 stat_clob_val = vc
 )
 SUBROUTINE writeworkloaddatatotable(x)
   IF (clientmnemonic="")
    SELECT INTO "nl:"
     dmi.info_char
     FROM dm_info dmi
     WHERE dmi.info_domain="DATA MANAGEMENT"
      AND dmi.info_name="CLIENT MNEMONIC"
     DETAIL
      clientmnemonic = dmi.info_char
     WITH nocounter
    ;end select
   ENDIF
   SELECT INTO "nl:"
    dbseq = seq(dm_clinical_seq,nextval)
    FROM dual
    DETAIL
     temp_workflow_data->seq_val = cnvtreal(dbseq)
    WITH nocounter
   ;end select
   INSERT  FROM dm_stat_snaps dss
    SET dss.dm_stat_snap_id = temp_workflow_data->seq_val, dss.stat_snap_dt_tm = cnvtdatetimeutc(
      cnvtdatetime((curdate - 1),0)), dss.client_mnemonic = clientmnemonic,
     dss.domain_name = substring(1,20,reqdata->domain), dss.node_name = trim(curnode), dss
     .snapshot_type = "UE_WORKFLOW",
     dss.updt_id = reqinfo->updt_id, dss.updt_dt_tm = cnvtdatetime(curdate,curtime2), dss.updt_task
      = reqinfo->updt_task,
     dss.updt_applctx = reqinfo->updt_applctx, dss.updt_cnt = 0
    WITH nocounter, maxcommit = 100
   ;end insert
   RDB commit
   END ;Rdb
   CALL esmcheckccl("x")
   COMMIT
   DECLARE order_cnt = i4 WITH noconstant(0)
   DECLARE chart_cnt = i4 WITH noconstant(0)
   DECLARE stat_cnt = i4 WITH noconstant(1)
   DECLARE clob_val = vc WITH noconstant("")
   DECLARE username = vc WITH noconstant("")
   DECLARE timerid = vc WITH noconstant("")
   IF (wrkflw_stats_table_exists=1)
    SELECT INTO "nl:"
     wfs.usertimer, wfs.count, wfs.totaltime,
     wfs.extra1, wfs.extra2, wfs.extra3,
     wfs.extra4, wfs.extra5, wfs.extra6,
     wfs.extra7, wfs.extra8, wfs.extra9,
     wfs.extra10, wfs.extra11, wfs.extra12,
     wfs.extra13, wfs.extra14, wfs.extra15,
     wfs.extra16, wfs.extra17, wfs.extra18,
     wfs.extra19, wfs.extra20
     FROM wrkflw_stats wfs
     HEAD REPORT
      arraysize = 1000, stat = alterlist(temp_workflow_data->stats,arraysize)
     DETAIL
      IF (((stat_cnt+ 1) > arraysize))
       arraysize = (arraysize+ 100), stat = alterlist(temp_workflow_data->stats,arraysize)
      ENDIF
      start_pos = findstring("||",wfs.usertimer,1), username = trim(substring(1,(start_pos - 1),wfs
        .usertimer)), timerid = trim(substring((start_pos+ 2),((size(wfs.usertimer,3) - start_pos) -
        1),wfs.usertimer)),
      temp_workflow_data->stats[stat_cnt].user_name = username, temp_workflow_data->stats[stat_cnt].
      stat_name = timerid, temp_workflow_data->stats[stat_cnt].stat_number_val = 1.0
      IF (timerid=chart_timer)
       clob_val = build(cnvtstring(wfs.count,11,2),"||",cnvtstring(wfs.totaltime,11,3),"||",
        cnvtstring(wfs.extra1,11,2),
        "||",cnvtstring(wfs.extra2,11,2),"||",cnvtstring(wfs.extra3,11,2),"||",
        cnvtstring(wfs.extra4,11,2),"||","-1.00","||")
      ELSEIF (timerid=order_timer)
       clob_val = build(cnvtstring(wfs.count,11,2),"||",cnvtstring(wfs.totaltime,11,3),"||",
        cnvtstring(wfs.extra1,11,2),
        "||",cnvtstring(wfs.extra2,11,2),"||",cnvtstring(wfs.extra3,11,3),"||",
        cnvtstring(wfs.extra4,11,2),"||",cnvtstring(wfs.extra5,11,2),"||",cnvtstring(wfs.extra6,11,2),
        "||",cnvtstring(wfs.extra7,11,2),"||",cnvtstring(wfs.extra8,11,2),"||",
        cnvtstring(wfs.extra9,11,2),"||",cnvtstring(wfs.extra10,11,2),"||",cnvtstring(wfs.extra11,11,
         2),
        "||",cnvtstring(wfs.extra12,11,2),"||",cnvtstring(wfs.extra13,11,2),"||",
        cnvtstring(wfs.extra14,11,2),"||",cnvtstring(wfs.extra15,11,2),"||",cnvtstring(wfs.extra16,11,
         2),
        "||",cnvtstring(wfs.extra17,11,3),"||",cnvtstring(wfs.extra18,11,2),"||",
        cnvtstring(wfs.extra19,11,2),"||",cnvtstring(wfs.extra20,11,3),"||",cnvtstring(wfs.extra21,11,
         2),
        "||")
      ELSE
       clob_val = build(cnvtstring(wfs.count,11,2),"||",cnvtstring(wfs.totaltime,11,3),"||")
      ENDIF
      temp_workflow_data->stats[stat_cnt].stat_clob_val = clob_val, temp_workflow_data->stats[
      stat_cnt].stat_seq = stat_cnt, stat_cnt = (stat_cnt+ 1)
     FOOT REPORT
      stat = alterlist(temp_workflow_data->stats,(stat_cnt - 1))
     WITH nocounter, nullreport
    ;end select
   ELSE
    SET stat = alterlist(temp_workflow_data->stats,1)
    SET temp_workflow_data->stats[1].stat_seq = 0
    SET temp_workflow_data->stats[1].stat_name = "NO_NEW_DATA"
    SET stat_cnt = 2
   ENDIF
   INSERT  FROM dm_stat_snaps_values dssv,
     (dummyt d1  WITH seq = value((stat_cnt - 1)))
    SET dssv.dm_stat_snap_id = temp_workflow_data->seq_val, dssv.stat_name = temp_workflow_data->
     stats[d1.seq].stat_name, dssv.stat_number_val = temp_workflow_data->stats[d1.seq].
     stat_number_val,
     dssv.stat_date_dt_tm = null, dssv.stat_seq = temp_workflow_data->stats[d1.seq].stat_seq, dssv
     .stat_str_val = temp_workflow_data->stats[d1.seq].user_name,
     dssv.stat_clob_val = temp_workflow_data->stats[d1.seq].stat_clob_val, dssv.updt_id = reqinfo->
     updt_id, dssv.updt_dt_tm = cnvtdatetime(curdate,curtime2),
     dssv.updt_task = reqinfo->updt_task, dssv.updt_applctx = reqinfo->updt_applctx, dssv.updt_cnt =
     0
    PLAN (d1)
     JOIN (dssv)
    WITH nocounter, maxcommit = 1000
   ;end insert
   RDB commit
   END ;Rdb
   CALL esmcheckccl("x")
   COMMIT
 END ;Subroutine
 SUBROUTINE getpropertyvalue(property)
   SET property_val = 0
   SET start_pos = findstring(concat(",",property,"="),fileline,1)
   IF (start_pos > 0)
    SET start_pos = ((start_pos+ size(property,3))+ 2)
    SET end_pos = findstring(",",fileline,start_pos)
    IF (end_pos=0)
     SET end_pos = (size(fileline,3)+ 1)
    ENDIF
    SET property_val = cnvtreal(trim(substring(start_pos,(end_pos - start_pos),fileline)))
   ENDIF
 END ;Subroutine
 CALL preparediscretedata(0)
 DECLARE reportdate = vc WITH noconstant("")
 SET reportdate = format(cnvtdatetime((curdate - 1),curtime2),"mmddyy;;D")
 DECLARE curindex = i4 WITH noconstant(1)
 DECLARE fileindex = vc WITH noconstant("")
 SET fileindex = format(curindex,"#####;P0")
 DECLARE cer_temp_path = vc WITH noconstant("")
 SET cer_temp_path = logical("cer_temp")
 IF (cer_temp_path="")
  SET cer_temp_path = logical("CER_TEMP")
 ENDIF
 DECLARE file_path_separator = vc WITH noconstant("")
 IF (cursys="AIX")
  SET file_path_separator = "/"
 ELSE
  SET file_path_separator = " "
 ENDIF
 DECLARE filebase = vc WITH noconstant("")
 SET filebase = concat(cer_temp_path,file_path_separator,"workflow",reportdate,"_",
  trim(cnvtlower(curnode)),"_")
 DECLARE filename = vc WITH noconstant("")
 SET filename = concat(filebase,fileindex,".csv")
 DECLARE inputfile = vc WITH constant("workflowfile")
 SET logical workflowfile value(filename)
 DECLARE filefound = i4 WITH noconstant(0)
 SET filefound = findfile(inputfile)
 IF (filefound < 1)
  CALL esmerror(build2("Cannot find file: ",filename),esmexit)
 ENDIF
 FREE SET uar_fopen
 DECLARE uar_fopen(p1=vc(ref),p2=vc(ref)) = i4 WITH image_axp = "decc$shr", uar_axp = "decc$fopen",
 image_aix = "libc.a(shr.o)",
 uar_aix = "fopen", image_win = "msvcrt.dll", uar_win = "fopen"
 FREE SET uar_fread
 DECLARE uar_fread(p1=vc(ref),p2=i4(value),p3=i4(value),p4=i4(value)) = i4 WITH image_axp =
 "decc$shr", uar_axp = "decc$fread", image_aix = "libc.a(shr.o)",
 uar_aix = "fread", image_win = "msvcrt.dll", uar_win = "fread"
 FREE SET uar_fseek
 DECLARE uar_fseek(p1=i4(value),p2=i4(value),p3=i4(value)) = i4 WITH image_axp = "decc$shr", uar_axp
  = "decc$fseek", image_aix = "libc.a(shr.o)",
 uar_aix = "fseek", image_win = "msvcrt.dll", uar_win = "fseek"
 FREE SET uar_ftell
 DECLARE uar_ftell(p1=i4(value)) = i4 WITH image_axp = "decc$shr", uar_axp = "decc$ftell", image_aix
  = "libc.a(shr.o)",
 uar_aix = "ftell", image_win = "msvcrt.dll", uar_win = "ftell"
 FREE SET uar_fclose
 DECLARE uar_fclose(p1=i4(value)) = i4 WITH image_axp = "decc$shr", uar_axp = "decc$fclose",
 image_aix = "libc.a(shr.o)",
 uar_aix = "fclose", image_win = "msvcrt.dll", uar_win = "fclose"
 DECLARE blocksize = i4 WITH noconstant(65536)
 DECLARE handle = i4 WITH noconstant(0)
 DECLARE mysize = i4 WITH noconstant(0)
 DECLARE mystr = vc
 DECLARE curr = i4 WITH noconstant(0)
 DECLARE currread = i4 WITH noconstant(0)
 DECLARE remain = vc
 DECLARE newline = c1 WITH noconstant(char(10))
 DECLARE start_posn = i4 WITH noconstant(1)
 DECLARE end_posn = i4 WITH noconstant(0)
 DECLARE dmt_temp = vc WITH noconstant("")
 WHILE (filefound=1
  AND curindex <= 99999)
   IF (((((currev * 10000)+ (currevminor * 100))+ currevminor2) >= 080204))
    SET handle = uar_fopen(nullterm(filename),"r")
    IF (handle=0)
     CALL echo(build("Could not open file: ",filename))
     GO TO exit_program
    ENDIF
    CALL echo(build("found file: ",filename))
    SET stat = uar_fseek(handle,0,2)
    SET mysize = uar_ftell(handle)
    SET stat = uar_fseek(handle,0,0)
    SET remain = ""
    SET curr = 0
    WHILE (curr < mysize)
      SET mystr = fillstring(65536,"")
      SET currread = uar_fread(mystr,1,blocksize,handle)
      SET curr = (curr+ currread)
      SET start_posn = 1
      SET end_posn = findstring(newline,mystr,start_posn)
      WHILE (end_posn != 0)
        SET dmt_temp = substring(start_posn,(end_posn - start_posn),mystr)
        IF (remain != "")
         SET dmt_temp = concat(remain,dmt_temp)
         SET remain = ""
        ENDIF
        CALL parseline(dmt_temp)
        CALL summarizeworkflowrecord(0)
        CALL dumpdiscretedata(dmt_temp)
        SET start_posn = (end_posn+ 1)
        SET end_posn = findstring(newline,mystr,start_posn)
      ENDWHILE
      SET remain = substring(start_posn,((blocksize - start_posn)+ 1),mystr)
    ENDWHILE
    SET stat = uar_fclose(handle)
   ELSE
    SELECT INTO "nl:"
     FROM rtl2t r
     WHERE r.line > " "
     DETAIL
      CALL parseline(r.line),
      CALL summarizeworkflowrecord(0),
      CALL dumpdiscretedata(r.line)
     WITH nocounter
    ;end select
   ENDIF
   CALL esmcheckccl("x")
   SET curindex = (curindex+ 1)
   SET fileindex = format(curindex,"#####;P0")
   SET filename = concat(filebase,fileindex,".csv")
   SET logical workflowfile value(filename)
   SET filefound = findfile(inputfile)
 ENDWHILE
 CALL writeworkloaddatatotable(0)
 CALL finalizediscretedata(0)
 FREE DEFINE wrkflw_stats
 DROP TABLE wrkflw_stats
 SET stat = remove("wrkflw_stats.dat")
 SET stat = remove("wrkflw_stats.idx")
#exit_program
END GO
