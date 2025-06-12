CREATE PROGRAM ccl_dic_synch_export:dba
 PROMPT
  "Enter object name to export: " = "*"
 DECLARE ccl_node = c20
 DECLARE synch_data_id = f8
 DECLARE last_export_date = i4
 DECLARE last_export_time = i4
 SET last_export_begin_dt_tm = cnvtdatetime(sysdate)
 SET export_begin_dt_tm = cnvtdatetime(sysdate)
 SET export_end_dt_tm = cnvtdatetime(sysdate)
 DECLARE addcnt = i4
 SET ccl_node = cnvtupper(logical("JOU_INSTANCE"))
 SELECT INTO "NL:"
  c.export_begin_dt_tm, c.ccl_synch_data_id
  FROM ccl_synch_data c
  WHERE c.node_name=ccl_node
  DETAIL
   synch_data_id = c.ccl_synch_data_id, last_export_begin_dt_tm = c.export_begin_dt_tm,
   last_export_date = cnvtdate(cnvtint(format(c.export_begin_dt_tm,"mmddyyyy;;d"))),
   last_export_time = cnvtint(format(c.export_begin_dt_tm,"hhmmss"))
  WITH nocounter, forupdate(c)
 ;end select
 IF (curqual=0)
  CALL echo("The last export date/time could not be determined.")
  CALL echo(concat("No record for node: ",trim(ccl_node)," found on the CCL_SYNCH_DATA table."))
  CALL echo("Exiting Program")
  GO TO exit_program
 ENDIF
 FREE RECORD object_list
 RECORD object_list(
   1 qual[*]
     2 object = c1
     2 object_name = c30
     2 group = i1
     2 checksum = f8
     2 major_version = i4
     2 minor_version = i4
     2 datestamp = i4
     2 timestamp = i4
 )
 SELECT INTO "NL:"
  grp = concat(dp.object,dp.object_name), dp.object, dp.object_name,
  dp.key1, bindata = check(substring(41,800,dc.datarec))
  FROM dprotect dp,
   dcompile dc,
   ccl_synch_objects cso
  PLAN (dp
   WHERE dp.platform="H0000"
    AND dp.rcode="5"
    AND dp.object IN ("E", "M", "P")
    AND dp.group=0
    AND (dp.object_name= $1)
    AND cnvtdatetime(dp.datestamp,dp.timestamp) >= last_export_begin_dt_tm)
   JOIN (dc
   WHERE "P"=dc.object
    AND dp.group=dc.group
    AND dp.object_name=dc.object_name)
   JOIN (cso
   WHERE cso.dic_key=dp.key1
    AND cso.timestamp_dt_tm >= cnvtdatetime(dp.datestamp,dp.timestamp))
  HEAD REPORT
   addcnt = 0
  HEAD grp
   checksum = 0.0, ival = 0
  DETAIL
   FOR (num = 1 TO 800)
    ival = ichar(substring(num,1,bindata)),
    IF (ival != 32)
     checksum += ival
    ENDIF
   ENDFOR
  FOOT  grp
   addcnt += 1
   IF (mod(addcnt,10)=1)
    stat = alterlist(object_list->qual,(addcnt+ 9))
   ENDIF
   object_list->qual[addcnt].object = dp.object, object_list->qual[addcnt].object_name = dp
   .object_name, object_list->qual[addcnt].group = dp.group,
   object_list->qual[addcnt].datestamp = dp.datestamp, object_list->qual[addcnt].timestamp = dp
   .timestamp, object_list->qual[addcnt].checksum = checksum,
   object_list->qual[addcnt].major_version = dp.app_major_version, object_list->qual[addcnt].
   minor_version = dp.app_minor_version
  FOOT REPORT
   stat = alterlist(object_list->qual,addcnt)
  WITH counter, outerjoin = dc, dontexist
 ;end select
 IF (addcnt > 0)
  DELETE  FROM ccl_synch_objects cso,
    (dummyt d  WITH seq = value(addcnt))
   SET cso.seq = 1
   PLAN (d)
    JOIN (cso
    WHERE (cso.object=object_list->qual[d.seq].object)
     AND (cso.object_name=object_list->qual[d.seq].object_name)
     AND (cso.cclgroup=object_list->qual[d.seq].group)
     AND cso.timestamp_dt_tm < cnvtdatetime(object_list->qual[d.seq].datestamp,object_list->qual[d
     .seq].timestamp))
  ;end delete
  IF (curqual > 0)
   COMMIT
  ENDIF
 ENDIF
 IF (addcnt > 0)
  INSERT  FROM ccl_synch_objects cso,
    (dgeneric dp  WITH access_code = "5"),
    (dummyt d  WITH seq = value(addcnt))
   SET cso.ccl_synch_objects_id = seq(ccl_dic_synch_seq,nextval), cso.object = object_list->qual[d
    .seq].object, cso.object_name = object_list->qual[d.seq].object_name,
    cso.cclgroup = object_list->qual[d.seq].group, cso.timestamp_dt_tm = cnvtdatetime(object_list->
     qual[d.seq].datestamp,object_list->qual[d.seq].timestamp), cso.rcode = "5",
    cso.node_name = ccl_node, cso.major_version = object_list->qual[d.seq].major_version, cso
    .minor_version = object_list->qual[d.seq].minor_version,
    cso.checksum = object_list->qual[d.seq].checksum, cso.dic_key = dp.key1, cso.dic_data = dp.data,
    cso.updt_dt_tm = cnvtdatetime(sysdate), cso.updt_id = reqinfo->updt_id, cso.updt_task = reqinfo->
    updt_task,
    cso.updt_applctx = reqinfo->updt_applctx, cso.updt_cnt = 0
   PLAN (d)
    JOIN (dp
    WHERE concat("H0000","5",object_list->qual[d.seq].object,object_list->qual[d.seq].object_name,
     char(object_list->qual[d.seq].group),
     fillstring(40,char(0))) <= dp.key1
     AND concat("H0000","5",object_list->qual[d.seq].object,object_list->qual[d.seq].object_name,char
     (object_list->qual[d.seq].group),
     fillstring(40,char(255))) >= dp.key1
     AND (object_list->qual[d.seq].group=ichar(substring(38,1,dp.key1))))
    JOIN (cso
    WHERE cso.dic_key=dp.key1)
   WITH counter, outerjoin = dp, dontexist
  ;end insert
  CALL echo("-")
  CALL echo(build("Dprotect records exported = ",curqual))
  CALL echo("-")
  INSERT  FROM ccl_synch_objects cso,
    (dgeneric dp  WITH access_code = "9"),
    (dummyt d  WITH seq = value(addcnt))
   SET cso.ccl_synch_objects_id = seq(ccl_dic_synch_seq,nextval), cso.object = object_list->qual[d
    .seq].object, cso.object_name = object_list->qual[d.seq].object_name,
    cso.cclgroup = object_list->qual[d.seq].group, cso.timestamp_dt_tm = cnvtdatetime(object_list->
     qual[d.seq].datestamp,object_list->qual[d.seq].timestamp), cso.rcode = "9",
    cso.node_name = ccl_node, cso.major_version = object_list->qual[d.seq].major_version, cso
    .minor_version = object_list->qual[d.seq].minor_version,
    cso.checksum = object_list->qual[d.seq].checksum, cso.dic_key = dp.key1, cso.dic_data = dp.data,
    cso.updt_dt_tm = cnvtdatetime(sysdate), cso.updt_id = reqinfo->updt_id, cso.updt_task = reqinfo->
    updt_task,
    cso.updt_applctx = reqinfo->updt_applctx, cso.updt_cnt = 0
   PLAN (d)
    JOIN (dp
    WHERE concat("H0000","9","P",object_list->qual[d.seq].object_name,char(object_list->qual[d.seq].
      group),
     fillstring(40,char(0))) <= dp.key1
     AND concat("H0000","9","P",object_list->qual[d.seq].object_name,char(object_list->qual[d.seq].
      group),
     fillstring(40,char(255))) >= dp.key1
     AND (object_list->qual[d.seq].group=ichar(substring(38,1,dp.key1))))
    JOIN (cso
    WHERE cso.dic_key=dp.key1)
   WITH counter, outerjoin = dp, dontexist
  ;end insert
  CALL echo("-")
  CALL echo(build("Dcompile records exported = ",curqual))
  CALL echo("-")
  IF (curqual > 0)
   COMMIT
  ENDIF
 ENDIF
 UPDATE  FROM ccl_synch_data c
  SET c.export_begin_dt_tm = cnvtdatetime(export_begin_dt_tm), c.export_end_dt_tm = cnvtdatetime(
    sysdate), c.updt_dt_tm = cnvtdatetime(sysdate),
   c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->
   updt_applctx,
   c.updt_cnt = (c.updt_cnt+ 1)
  WHERE c.ccl_synch_data_id=synch_data_id
  WITH nocounter
 ;end update
 IF (curqual > 0)
  COMMIT
 ENDIF
 INSERT  FROM ccl_synch_audit c
  SET c.ccl_synch_audit_id = seq(ccl_dic_synch_seq,nextval), c.node_name = ccl_node, c.operation =
   "EXPORT",
   c.begin_dt_tm = cnvtdatetime(export_begin_dt_tm), c.end_dt_tm = cnvtdatetime(sysdate), c
   .updt_dt_tm = cnvtdatetime(sysdate),
   c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->
   updt_applctx,
   c.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual > 0)
  COMMIT
 ENDIF
#exit_program
END GO
