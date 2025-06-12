CREATE PROGRAM dm_stat_export_range
 FREE RECORD snapshot_ids
 RECORD snapshot_ids(
   1 qual[*]
     2 snapshot_type = vc
 )
 SET stat = alterlist(snapshot_ids->qual,139)
 SET snapshot_ids->qual[1].snapshot_type = "APP_VOLUMES - NON-PHYS DISTINCT USERS"
 SET snapshot_ids->qual[2].snapshot_type = "DEPRECATED_APP_VOLUMES - NON-PHYSICIAN LOG INS"
 SET snapshot_ids->qual[3].snapshot_type = "DEPRECATED_APP_VOLUMES - NON-PHYSICIAN MINUTES"
 SET snapshot_ids->qual[4].snapshot_type = "APP_VOLUMES - PHYSICIAN DISTINCT USERS"
 SET snapshot_ids->qual[5].snapshot_type = "DEPRECATED_APP_VOLUMES - PHYSICIAN LOG INS"
 SET snapshot_ids->qual[6].snapshot_type = "DEPRECATED_APP_VOLUMES - PHYSICIAN MINUTES"
 SET snapshot_ids->qual[7].snapshot_type = "DEPRECATED_CHART_OPEN_VOLUMES"
 SET snapshot_ids->qual[8].snapshot_type = "DEPRECATED_DB SCORE"
 SET snapshot_ids->qual[9].snapshot_type = "DB_CONFIG"
 SET snapshot_ids->qual[10].snapshot_type = "DEPRECATED_DB_STATS_DELTA"
 SET snapshot_ids->qual[11].snapshot_type = "DEPRECATED_TOP_SQL_SMRY"
 SET snapshot_ids->qual[12].snapshot_type = "DEPRECATED_ESM_RRD_SMRY"
 SET snapshot_ids->qual[13].snapshot_type = "ESI Interface Volumes"
 SET snapshot_ids->qual[14].snapshot_type = "DEPRECATED_ESM_MILLCONFIG"
 SET snapshot_ids->qual[15].snapshot_type = "DEPRECATED_ESM_MSGLOG_SMRY"
 SET snapshot_ids->qual[16].snapshot_type = "ESM_OSCONFIG"
 SET snapshot_ids->qual[17].snapshot_type = "ESM_OSSTAT_SMRY"
 SET snapshot_ids->qual[18].snapshot_type = "DEPRECATED_ESM_SMON_SMRY"
 SET snapshot_ids->qual[19].snapshot_type = "DEPRECATED_ESO COM Srv Transactions Ignored"
 SET snapshot_ids->qual[20].snapshot_type = "DEPRECATED_ESO COM Srv Transactions Sent"
 SET snapshot_ids->qual[21].snapshot_type = "ESO Outbound Interface Volumes"
 SET snapshot_ids->qual[22].snapshot_type = "DEPRECATED_FIRSTNET VOLUMES"
 SET snapshot_ids->qual[23].snapshot_type = "DEPRECATED_INDEX_SIZE_DISTINCT_KEYS"
 SET snapshot_ids->qual[24].snapshot_type = "DEPRECATED_INDEX_SIZE_LEAF_BYTES"
 SET snapshot_ids->qual[25].snapshot_type = "DEPRECATED_INDEX_USAGE"
 SET snapshot_ids->qual[26].snapshot_type = "DEPRECATED_MONTHLY_VOLUME"
 SET snapshot_ids->qual[27].snapshot_type = "ORDER_VOLUMES - BY CATALOG BY ACTION"
 SET snapshot_ids->qual[28].snapshot_type = "DEPRECATED_ORDER_VOLUMES - BY CATALOG BY ACTIVITY"
 SET snapshot_ids->qual[29].snapshot_type = "DEPRECATED_ORDER_VOLUMES - BY CATALOG BY CARE SET"
 SET snapshot_ids->qual[30].snapshot_type = "DEPRECATED_ORDER_VOLUMES - IV BY CATALOG TYPE"
 SET snapshot_ids->qual[31].snapshot_type = "DEPRECATED_ORDER_VOLUMES - NON-BILL ONLY BY CATALOG"
 SET snapshot_ids->qual[32].snapshot_type = "DEPRECATED_ORDER_VOLUMES - NON-IV BY CATALOG TYPE"
 SET snapshot_ids->qual[33].snapshot_type = "DEPRECATED_ORDER_VOLUMES - NON-PHYS BY CATALOG TYPE"
 SET snapshot_ids->qual[34].snapshot_type = "DEPRECATED_ORDER_VOLUMES - NON-PRN BY CATALOG TYPE"
 SET snapshot_ids->qual[35].snapshot_type = "DEPRECATED_ORDER_VOLUMES - PRN BY CATALOG TYPE"
 SET snapshot_ids->qual[36].snapshot_type = "DEPRECATED_ORDER_VOLUMES - PYXIS"
 SET snapshot_ids->qual[37].snapshot_type = "DEPRECATED_ORDER_VOLUMES -BILL ONLY BY CATALOG TYPE"
 SET snapshot_ids->qual[38].snapshot_type = "DEPRECATED_ORDER_VOLUMES -PHYSICIAN BY CATALOG TYPE"
 SET snapshot_ids->qual[39].snapshot_type = "DEPRECATED_PATHNET_VOLUMES - ACCESSIONS"
 SET snapshot_ids->qual[40].snapshot_type = "DEPRECATED_PATHNET_VOLUMES - GEN LAB CONTAINERS"
 SET snapshot_ids->qual[41].snapshot_type = "DEPRECATED_PATHNET_VOLUMES - GEN LAB LISTS"
 SET snapshot_ids->qual[42].snapshot_type = "DEPRECATED_PATHNET_VOLUMES - RESULTS"
 SET snapshot_ids->qual[43].snapshot_type = "DEPRECATED_PERSONNEL-ACTIVE OTHER WITH NOSIGNON"
 SET snapshot_ids->qual[44].snapshot_type = "DEPRECATED_PERSONNEL-ACTIVE OTHER WITH SIGNON"
 SET snapshot_ids->qual[45].snapshot_type = "DEPRECATED_PERSONNEL-ACTIVE PHYSICIAN WITH NOSIGNON"
 SET snapshot_ids->qual[46].snapshot_type = "DEPRECATED_PERSONNEL-ACTIVE PHYSICIAN WITH SIGNON"
 SET snapshot_ids->qual[47].snapshot_type = "DEPRECATED_PERSONNEL-INACTIVE OTHER WITH NOSIGNON"
 SET snapshot_ids->qual[48].snapshot_type = "DEPRECATED_PERSONNEL-INACTIVE OTHER WITH SIGNON"
 SET snapshot_ids->qual[49].snapshot_type = "DEPRECATED_PERSONNEL-INACTIVE PHYS WITH NOSIGNON"
 SET snapshot_ids->qual[50].snapshot_type = "DEPRECATED_PERSONNEL-INACTIVE PHYSICIAN WITH SIGNON"
 SET snapshot_ids->qual[51].snapshot_type = "PM VOLUMES"
 SET snapshot_ids->qual[52].snapshot_type = "Pathnet Volumes"
 SET snapshot_ids->qual[53].snapshot_type = "DEPRECATED_Pharmacy Volumes"
 SET snapshot_ids->qual[54].snapshot_type = "DEPRECATED_TABLE_SIZE_ROWS"
 SET snapshot_ids->qual[55].snapshot_type = "DEPRECATED_RADIOLOGY_VOLUMES - ORDERS"
 SET snapshot_ids->qual[56].snapshot_type = "DEPRECATED_RADIOLOGY_VOLUMES - ORDERS BY RPT STATUS"
 SET snapshot_ids->qual[57].snapshot_type = "DEPRECATED_RADIOLOGY_VOLUMES -ORDERS BY EXAM STATUS"
 SET snapshot_ids->qual[58].snapshot_type = "SCHEDULING VOLUMES"
 SET snapshot_ids->qual[59].snapshot_type = "SEQUENCE_VALUE_CHECK"
 SET snapshot_ids->qual[60].snapshot_type = "SLA_AGGREGATE_HOURLY"
 SET snapshot_ids->qual[61].snapshot_type = "DEPRECATED_TABLE_SIZE_BYTES"
 SET snapshot_ids->qual[62].snapshot_type = "DM_CBO_IMPLEMENTER"
 SET snapshot_ids->qual[63].snapshot_type = "DEPRECATED_DB_TOTAL_HOURLY"
 SET snapshot_ids->qual[64].snapshot_type = "DEPRECATED_V500_TOP_SQL"
 SET snapshot_ids->qual[65].snapshot_type = "DEPRECATED_V500_SHARE_MEM_SQL"
 SET snapshot_ids->qual[66].snapshot_type = "DEPRECATED_OTHER_TOP_SQL"
 SET snapshot_ids->qual[67].snapshot_type = "DEPRECATED_OTHER_SHARE_MEM_SQL"
 SET snapshot_ids->qual[68].snapshot_type = "SQL_TEXT"
 SET snapshot_ids->qual[69].snapshot_type = "TABLE_INFO"
 SET snapshot_ids->qual[70].snapshot_type = "INDEX_INFO"
 SET snapshot_ids->qual[71].snapshot_type = "DB_METRICS"
 SET snapshot_ids->qual[72].snapshot_type = "DB_STATS"
 SET snapshot_ids->qual[73].snapshot_type = "DEPRECATED_BEDROCK_XRAYS"
 SET snapshot_ids->qual[74].snapshot_type = "UE_RTMS"
 SET snapshot_ids->qual[75].snapshot_type = "UE_INBOX_ACTIVITIES"
 SET snapshot_ids->qual[76].snapshot_type = "UE_ORDERS"
 SET snapshot_ids->qual[77].snapshot_type = "UE_PROBLEMS_DIAGNOSIS"
 SET snapshot_ids->qual[78].snapshot_type = "UE_ALLERGIES_HISTORIES"
 SET snapshot_ids->qual[79].snapshot_type = "UE_DOCUMENTATION"
 SET snapshot_ids->qual[80].snapshot_type = "DEPRECATED_UE_ALERTS"
 SET snapshot_ids->qual[81].snapshot_type = "UE_POWERPLANS"
 SET snapshot_ids->qual[82].snapshot_type = "OPENED_CHART_VOLUMES"
 SET snapshot_ids->qual[83].snapshot_type = "UE_CHART_OPENS"
 SET snapshot_ids->qual[84].snapshot_type = "TABLE_MOD_INFO"
 SET snapshot_ids->qual[85].snapshot_type = "COLUMN_INFO"
 SET snapshot_ids->qual[86].snapshot_type = "BEDROCK_COMPLIANCE"
 SET snapshot_ids->qual[87].snapshot_type = "DEPRECATED"
 SET snapshot_ids->qual[88].snapshot_type = "CLINICAL_OUTCOMES"
 SET snapshot_ids->qual[89].snapshot_type = "EM_PLAN_SUMMARY"
 SET snapshot_ids->qual[90].snapshot_type = "EM_PLAN_SUMMARY_DTL"
 SET snapshot_ids->qual[91].snapshot_type = "PRSNL_TABLE"
 SET snapshot_ids->qual[92].snapshot_type = "UE_NURSING_ASSESSMENTS"
 SET snapshot_ids->qual[93].snapshot_type = "UE_NURSING_TASKS"
 SET snapshot_ids->qual[94].snapshot_type = "UE_NURSING_MEDS"
 SET snapshot_ids->qual[95].snapshot_type = "UE_NURSING_CHARTING-NON_MEDS"
 SET snapshot_ids->qual[96].snapshot_type = "UE_NURSING_CHARTING-MEDS"
 SET snapshot_ids->qual[97].snapshot_type = "UE_WORKFLOW"
 SET snapshot_ids->qual[98].snapshot_type = "DB_NODE_IDENT"
 SET snapshot_ids->qual[99].snapshot_type = "AWR_SQL"
 SET snapshot_ids->qual[100].snapshot_type = "BEDROCK_USAGE"
 SET snapshot_ids->qual[101].snapshot_type = "UE_PARENT_ORDERS"
 SET snapshot_ids->qual[102].snapshot_type = "LIGHTHOUSE_MEASURES"
 SET snapshot_ids->qual[103].snapshot_type = "RTMS_DISCRETE"
 SET snapshot_ids->qual[104].snapshot_type = "UE_ALERT_DETAILS"
 SET snapshot_ids->qual[105].snapshot_type = "PERSONNEL-ACTIVE USERS WITH SIGNON"
 SET snapshot_ids->qual[106].snapshot_type = "RRD STATISTICS"
 SET snapshot_ids->qual[107].snapshot_type = "WORKFLOW_DISCRETE"
 SET snapshot_ids->qual[108].snapshot_type = "CCLSCRIPTGRANT_INFO"
 SET snapshot_ids->qual[109].snapshot_type = "ORACLEBASELINE_INFO"
 SET snapshot_ids->qual[110].snapshot_type = "PURGE_TEMPLATES"
 SET snapshot_ids->qual[111].snapshot_type = "PURGE_JOBS"
 SET snapshot_ids->qual[112].snapshot_type = "UE_PARENT_ORDERS_ENCOUNTER"
 SET snapshot_ids->qual[113].snapshot_type = "DEPRECATED"
 SET snapshot_ids->qual[114].snapshot_type = "DEPRECATED"
 SET snapshot_ids->qual[115].snapshot_type = "MPAGES"
 SET snapshot_ids->qual[116].snapshot_type = "CODE_SETS"
 SET snapshot_ids->qual[117].snapshot_type = "DEPRECATED"
 SET snapshot_ids->qual[118].snapshot_type = "NOTE_TYPE"
 SET snapshot_ids->qual[119].snapshot_type = "ALT_SEL_CAT"
 SET snapshot_ids->qual[120].snapshot_type = "DEPRECATED"
 SET snapshot_ids->qual[121].snapshot_type = "DEPRECATED"
 SET snapshot_ids->qual[122].snapshot_type = "DEPRECATED"
 SET snapshot_ids->qual[123].snapshot_type = "DEPRECATED"
 SET snapshot_ids->qual[124].snapshot_type = "UE_ERX_ENCOUNTER"
 SET snapshot_ids->qual[125].snapshot_type = "COMBINES_DISCRETE"
 SET snapshot_ids->qual[126].snapshot_type = "DETAIL_PREF_BUILD"
 SET snapshot_ids->qual[127].snapshot_type = "VIEW_PREF_BUILD"
 SET snapshot_ids->qual[128].snapshot_type = "VIEW_COMP_PREF_BUILD"
 SET snapshot_ids->qual[129].snapshot_type = "README_DATA"
 SET snapshot_ids->qual[130].snapshot_type = "UE_PATIENTS_SEEN"
 SET snapshot_ids->qual[131].snapshot_type = "UE_MULTUM_ALERTS"
 SET snapshot_ids->qual[132].snapshot_type = "ICDX_USAGE"
 SET snapshot_ids->qual[133].snapshot_type = "REV_CYC_PARENT"
 SET snapshot_ids->qual[134].snapshot_type = "MPAGE_CONFIG"
 SET snapshot_ids->qual[135].snapshot_type = "UK_PRSNL_SPEC"
 SET snapshot_ids->qual[136].snapshot_type = "PREF_PHARM"
 SET snapshot_ids->qual[137].snapshot_type = "UE_ICD10_METRICS"
 SET snapshot_ids->qual[138].snapshot_type = "CTP_AUTO_TRACKING"
 SET snapshot_ids->qual[139].snapshot_type = "DM_STAT_SCRIPT_LOG"
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
 RECORD export_request(
   1 mnemonic = vc
   1 domain = vc
   1 node = vc
   1 export_from_dt = f8
   1 export_to_dt = f8
 )
 DECLARE export_dt = c8
 DECLARE export_tm = c8
 DECLARE filename = vc
 DECLARE url = vc
 DECLARE urlquarterly = vc
 DECLARE file_flag = i4 WITH noconstant(0)
 DECLARE strformat = vc WITH noconstant(" ")
 DECLARE whereclause = vc
 DECLARE existsclause = vc
 SET export_dt = format(curdate,"mmddyyyy;;d")
 SET export_tm = format(cnvtdatetime(curdate,curtime3),"hhmmss;3;M")
 DECLARE createfile(snapshottype=vc,fname=vc) = null
 SET url = "http://www.cerner.com/Engineering/ClientData/DMSTATS/1"
 SET urlquarterly = "http://www.cerner.com/Engineering/ClientData/DMSTATSQUARTERLY/1"
 DECLARE export_err_msg = c255
 DECLARE dse_temp_vc_in = vc
 DECLARE dse_temp_vc_out = vc
 SELECT INTO "nl:"
  FROM dm_info di
  WHERE di.info_domain="DATA MANAGEMENT"
   AND di.info_name="CLIENT MNEMONIC"
  DETAIL
   export_request->mnemonic = di.info_char
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL esmerror("ERROR: Client mnemonic not set",esmexit)
 ENDIF
 IF (((validate(dm_stat_export_from_dt,999)=999) OR (validate(dm_stat_export_to_dt,999)=999)) )
  SET prev_date = cnvtdate(datetimeadd(cnvtdatetime(curdate,0),- (1)))
  SET default_from_dt = cnvtdatetime(prev_date,0)
  SET default_to_dt = cnvtdatetime(prev_date,235959)
  CALL clear(1,1)
  CALL echo(
   "Please enter the time range for the data to export (Default: yesterday, midnight to midnight)")
  CALL echo("Start time: ")
  CALL echo("Stop time: ")
  CALL accept(2,13,"99DAAAD9999D99D99D99;CU",format(default_from_dt,"dd-mmm-yyyy hh:mm:ss;;D")
   WHERE cnvtint(substring(1,2,curaccept)) >= 1
    AND cnvtint(substring(1,2,curaccept)) <= 31
    AND substring(4,3,curaccept) IN ("JAN", "FEB", "MAR", "APR", "MAY",
   "JUN", "JUL", "AUG", "SEP", "OCT",
   "NOV", "DEC")
    AND cnvtint(substring(8,4,curaccept)) >= 1800
    AND cnvtint(substring(13,2,curaccept)) >= 0
    AND cnvtint(substring(13,2,curaccept)) < 24
    AND cnvtint(substring(16,2,curaccept)) >= 0
    AND cnvtint(substring(16,2,curaccept)) < 60
    AND cnvtint(substring(19,2,curaccept)) >= 0
    AND cnvtint(substring(19,2,curaccept)) < 60)
  SET export_request->export_from_dt = cnvtdatetime(curaccept)
  CALL accept(3,13,"99DAAAD9999D99D99D99;CU",format(default_to_dt,"dd-mmm-yyyy hh:mm:ss;;D")
   WHERE cnvtint(substring(1,2,curaccept)) >= 1
    AND cnvtint(substring(1,2,curaccept)) <= 31
    AND substring(4,3,curaccept) IN ("JAN", "FEB", "MAR", "APR", "MAY",
   "JUN", "JUL", "AUG", "SEP", "OCT",
   "NOV", "DEC")
    AND cnvtint(substring(8,4,curaccept)) >= 1800
    AND cnvtint(substring(13,2,curaccept)) >= 0
    AND cnvtint(substring(13,2,curaccept)) < 24
    AND cnvtint(substring(16,2,curaccept)) >= 0
    AND cnvtint(substring(16,2,curaccept)) < 60
    AND cnvtint(substring(19,2,curaccept)) >= 0
    AND cnvtint(substring(19,2,curaccept)) < 60)
  SET export_request->export_to_dt = cnvtdatetime(curaccept)
 ELSE
  SET export_request->export_from_dt = dm_stat_export_from_dt
  SET export_request->export_to_dt = dm_stat_export_to_dt
 ENDIF
 FREE SET dm_stat_export_from_dt
 FREE SET dm_stat_export_to_dt
 CALL echo(build("Start: ",export_request->export_from_dt))
 CALL echo(build("       (",format(export_request->export_from_dt,"dd-mmm-yyyy hh:mm:ss;;D"),")"))
 CALL echo(build("Stop:  ",export_request->export_to_dt))
 CALL echo(build("       (",format(export_request->export_to_dt,"dd-mmm-yyyy hh:mm:ss;;D"),")"))
 SET export_request->node = trim(curnode)
 SET export_request->domain = reqdata->domain
 DECLARE env_id = vc WITH noconstant("")
 SELECT INTO "nl:"
  di.info_number
  FROM dm_info di
  WHERE di.info_name="DM_ENV_ID"
  DETAIL
   env_id = cnvtstring(di.info_number,11,2)
  WITH nocounter
 ;end select
 FOR (itr = 1 TO size(snapshot_ids->qual,5))
   SET whereclause = build("dm.info_name LIKE '",snapshot_ids->qual[itr].snapshot_type,
    ".*' or dm.info_name = '",snapshot_ids->qual[itr].snapshot_type,"'")
   SET existsclause = build("dm1.info_name LIKE '",snapshot_ids->qual[itr].snapshot_type,
    ".*' or dm1.info_name = '",snapshot_ids->qual[itr].snapshot_type,"'")
   SELECT INTO "nl:"
    dm.info_name
    FROM dm_info dm
    WHERE parser(whereclause)
     AND dm.info_domain="DM_STAT_EXPORT"
     AND  NOT ( EXISTS (
    (SELECT
     1
     FROM dm_info dm1
     WHERE info_domain="DM_STAT_EXPORT_EXCLUDE"
      AND parser(existsclause))))
    WITH nocounter
   ;end select
   IF (curqual=0)
    IF (size(snapshot_ids->qual[itr].snapshot_type,3) > 10
     AND substring(1,10,snapshot_ids->qual[itr].snapshot_type)="DEPRECATED")
     CALL echo(build("Snapshot  ",snapshot_ids->qual[itr].snapshot_type,
       " has been deprecated and will not return."))
    ELSE
     CALL esmerror(build("ERROR: Invalid snapshot_type: ",snapshot_ids->qual[itr].snapshot_type),
      esmreturn)
    ENDIF
   ELSE
    SET filename = build("msa_",cnvtlower(export_request->node),"_",itr,"_",
     export_dt,"_",export_tm,".xml")
    CALL createfile(snapshot_ids->qual[itr].snapshot_type,filename)
    IF (file_flag > 0)
     INSERT  FROM dm_stat_resend_retry drr
      SET drr.dm_stat_resend_retry_id = seq(dm_clinical_seq,nextval), drr.file_name = cnvtupper(
        filename), drr.resend_retry_cnt = - (1),
       drr.ccts_resend_retry_cnt = - (1), drr.resend_retry_dt_tm = cnvtdatetime(curdate,curtime3),
       drr.updt_id = reqinfo->updt_id,
       drr.updt_dt_tm = cnvtdatetime(curdate,curtime3), drr.updt_task = reqinfo->updt_task, drr
       .updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
     IF (error(export_err_msg,0) != 0)
      ROLLBACK
      CALL esmerror(export_err_msg,esmexit)
     ELSE
      COMMIT
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 SUBROUTINE createfile(snapshottype,fname)
   SET file_flag = 0
   SET whereclause = build("d.snapshot_type LIKE '",snapshottype,".*' or d.snapshot_type = '",
    snapshottype,"'")
   SELECT INTO "nl:"
    ret_cnt = count(*)
    FROM dm_stat_snaps d,
     dm_stat_snaps_values v
    PLAN (d
     WHERE parser(whereclause)
      AND d.stat_snap_dt_tm BETWEEN cnvtdatetime(export_request->export_from_dt) AND cnvtdatetime(
      export_request->export_to_dt)
      AND (d.node_name=export_request->node)
      AND (d.domain_name=export_request->domain))
     JOIN (v
     WHERE d.dm_stat_snap_id=v.dm_stat_snap_id)
    DETAIL
     file_flag = ret_cnt
    WITH nocounter
   ;end select
   IF (file_flag > 0)
    SELECT INTO value(fname)
     snapshot = d.dm_stat_snap_id, stat_name = v.stat_name
     FROM dm_stat_snaps d,
      dm_stat_snaps_values v
     PLAN (d
      WHERE parser(whereclause)
       AND d.stat_snap_dt_tm BETWEEN cnvtdatetime(export_request->export_from_dt) AND cnvtdatetime(
       export_request->export_to_dt)
       AND (d.node_name=export_request->node)
       AND (d.domain_name=export_request->domain))
      JOIN (v
      WHERE d.dm_stat_snap_id=v.dm_stat_snap_id)
     ORDER BY d.dm_stat_snap_id, v.stat_name
     HEAD REPORT
      MACRO (convert_special_chars)
       dse_temp_vc_in = replace(dse_temp_vc_in,char(0),"",0), dse_temp_vc_in = replace(dse_temp_vc_in,
        char(1),"",0), dse_temp_vc_in = replace(dse_temp_vc_in,char(2),"",0),
       dse_temp_vc_in = replace(dse_temp_vc_in,char(3),"",0), dse_temp_vc_in = replace(dse_temp_vc_in,
        char(4),"",0), dse_temp_vc_in = replace(dse_temp_vc_in,char(5),"",0),
       dse_temp_vc_in = replace(dse_temp_vc_in,char(6),"",0), dse_temp_vc_in = replace(dse_temp_vc_in,
        char(7),"",0), dse_temp_vc_in = replace(dse_temp_vc_in,char(8),"",0),
       dse_temp_vc_in = replace(dse_temp_vc_in,char(9),"",0), dse_temp_vc_in = replace(dse_temp_vc_in,
        char(11),"",0), dse_temp_vc_in = replace(dse_temp_vc_in,char(12),"",0),
       dse_temp_vc_in = replace(dse_temp_vc_in,char(14),"",0), dse_temp_vc_in = replace(
        dse_temp_vc_in,char(15),"",0), dse_temp_vc_in = replace(dse_temp_vc_in,char(16),"",0),
       dse_temp_vc_in = replace(dse_temp_vc_in,char(17),"",0), dse_temp_vc_in = replace(
        dse_temp_vc_in,char(18),"",0), dse_temp_vc_in = replace(dse_temp_vc_in,char(19),"",0),
       dse_temp_vc_in = replace(dse_temp_vc_in,char(20),"",0), dse_temp_vc_in = replace(
        dse_temp_vc_in,char(21),"",0), dse_temp_vc_in = replace(dse_temp_vc_in,char(22),"",0),
       dse_temp_vc_in = replace(dse_temp_vc_in,char(23),"",0), dse_temp_vc_in = replace(
        dse_temp_vc_in,char(24),"",0), dse_temp_vc_in = replace(dse_temp_vc_in,char(25),"",0),
       dse_temp_vc_in = replace(dse_temp_vc_in,char(26),"",0), dse_temp_vc_in = replace(
        dse_temp_vc_in,char(27),"",0), dse_temp_vc_in = replace(dse_temp_vc_in,char(28),"",0),
       dse_temp_vc_in = replace(dse_temp_vc_in,char(29),"",0), dse_temp_vc_in = replace(
        dse_temp_vc_in,char(30),"",0), dse_temp_vc_in = replace(dse_temp_vc_in,char(31),"",0),
       dse_temp_vc_in = replace(dse_temp_vc_in,"&","&amp;",0), dse_temp_vc_in = replace(
        dse_temp_vc_in,"<","&lt;",0), dse_temp_vc_in = replace(dse_temp_vc_in,">","&gt;",0),
       dse_temp_vc_in = replace(dse_temp_vc_in,'"',"&quot;",0), dse_temp_vc_out = trim(replace(
         dse_temp_vc_in,"'","&apos;",0))
      ENDMACRO
      , col 0, '<?xml version="1.0" encoding="iso-8859-15" ?>',
      row + 1
      IF (size(snapshottype,3) >= 10
       AND ((substring(1,10,snapshottype)="INDEX_INFO") OR (((substring(1,10,snapshottype)=
      "COLUMN_INF") OR (((substring(1,10,snapshottype)="DETAIL_PRE") OR (((substring(1,10,
       snapshottype)="VIEW_PREF_") OR (substring(1,10,snapshottype)="VIEW_COMP_")) )) )) )) )
       col 0, "<DMSTATS xmlns=", '"',
       urlquarterly, '"', ">"
      ELSE
       col 0, "<DMSTATS xmlns=", '"',
       url, '"', ">"
      ENDIF
      row + 1, col 0, "<DM_STATS>",
      row + 1
     HEAD snapshot
      col 0, "<DM_STAT>", row + 1
      IF (isnumeric(format(d.stat_snap_dt_tm,"YYYYMMDDHHMMSS;;D")))
       strformat = build("<Stat_Snap_Dt_Tm>",format(d.stat_snap_dt_tm,"YYYYMMDDHHMMSS;;D"),
        "</Stat_Snap_Dt_Tm>"), col 0, strformat
      ELSE
       col 0, "<Stat_Snap_Dt_Tm/>"
      ENDIF
      row + 1
      IF (size(d.snapshot_type,1))
       strformat = build("<Snapshot_Type>",d.snapshot_type,"</Snapshot_Type>"), col 0, strformat
      ELSE
       col 0, "<Snapshot_Type/>"
      ENDIF
      row + 1
      IF (size(d.domain_name,1))
       strformat = build("<Domain_Name>",d.domain_name,"</Domain_Name>"), col 0, strformat
      ELSE
       col 0, "<Domain_Name/>"
      ENDIF
      row + 1
      IF (size(d.node_name,1))
       strformat = build("<Node_Name>",d.node_name,"</Node_Name>"), col 0, strformat
      ELSE
       col 0, "<Node_Name/>"
      ENDIF
      row + 1
      IF (size(env_id,1))
       strformat = build("<Env_Id>",env_id,"</Env_Id>"), col 0, strformat
      ELSE
       col 0, "<Env_Id/>"
      ENDIF
      row + 1, col 0, "<VALUES>",
      row + 1
     DETAIL
      col 0, "<VALUE>", row + 1
      IF (size(trim(v.stat_name),1))
       dse_temp_vc_in = trim(v.stat_name), convert_special_chars, col 0,
       "<Stat_Name>", dse_temp_vc_out, "</Stat_Name>"
      ELSE
       col 0, "<Stat_Name/>"
      ENDIF
      row + 1
      IF (v.stat_type)
       strformat = build("<Stat_Type>",cnvtstring(v.stat_type,1),"</Stat_Type>"), col 0, strformat
      ELSE
       col 0, "<Stat_Type/>"
      ENDIF
      row + 1
      IF (size(v.stat_number_val,1))
       strformat = build("<Stat_Number_Val>",cnvtstring(v.stat_number_val,20,2),"</Stat_Number_Val>"),
       col 0, strformat
      ELSE
       col 0, "<Stat_Number_Val/>"
      ENDIF
      row + 1
      IF (size(v.stat_seq,1))
       strformat = build("<Stat_Seq>",cnvtstring(v.stat_seq),"</Stat_Seq>"), col 0, strformat
      ELSE
       col 0, "<Stat_Seq/>"
      ENDIF
      row + 1
      IF (size(v.stat_str_val,1))
       dse_temp_vc_in = trim(v.stat_str_val), convert_special_chars, strformat = build(
        "<Stat_Str_Val>",dse_temp_vc_out,"</Stat_Str_Val>"),
       col 0, strformat
      ELSE
       col 0, "<Stat_Str_Val/>"
      ENDIF
      row + 1, col 0, "<Stat_Date_Val/>",
      row + 1
      IF (size(v.stat_clob_val,1))
       dse_temp_vc_in = trim(v.stat_clob_val), convert_special_chars, strformat = build(
        "<Stat_Clob_Val>",dse_temp_vc_out,"</Stat_Clob_Val>"),
       col 0, strformat
      ELSE
       col 0, "<Stat_Clob_Val/>"
      ENDIF
      row + 1, col 0, "</VALUE>",
      row + 1
     FOOT  snapshot
      col 0, "</VALUES>", row + 1,
      col 0, "</DM_STAT>", row + 1
     FOOT REPORT
      col 0, "</DM_STATS>", row + 1,
      col 0, "</DMSTATS>"
     WITH nocounter, noformfeed, maxrow = 1,
      maxcol = 32032, format = variable
    ;end select
    IF (error(export_err_msg,0) != 0)
     CALL esmerror(export_err_msg,esmreturn)
    ELSE
     CALL echo(build("file: ",fname," created."))
    ENDIF
   ENDIF
 END ;Subroutine
#exit_program
 FREE RECORD export_request
END GO
