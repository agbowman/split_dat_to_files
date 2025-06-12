CREATE PROGRAM ccl_dic_synch_import:dba
 DECLARE synch_data_id = f8
 DECLARE last_import_date = i4
 DECLARE last_import_time = i4
 SET last_import_begin_dt_tm = cnvtdatetime((curdate+ 1),curtime3)
 SET import_begin_dt_tm = cnvtdatetime(sysdate)
 SET import_end_dt_tm = cnvtdatetime(sysdate)
 DECLARE addcnt = i4
 DECLARE ccl_node = c20
 SET ccl_node = cnvtupper(logical("JOU_INSTANCE"))
 SELECT INTO "NL:"
  c.ccl_synch_data_id
  FROM ccl_synch_data c
  WHERE c.node_name=ccl_node
   AND c.export_only_ind=1
  WITH nocounter
 ;end select
 IF (curqual > 0)
  CALL echo(concat("Node: ",trim(ccl_node)," is export only."))
  CALL echo("Dictionary Synch Import will not be performed.")
  CALL echo("Exiting Program")
  GO TO exit_program
 ENDIF
 SELECT INTO "NL:"
  c.import_begin_dt_tm, c.ccl_synch_data_id
  FROM ccl_synch_data c
  WHERE c.node_name=ccl_node
  DETAIL
   synch_data_id = c.ccl_synch_data_id, last_import_begin_dt_tm = c.import_begin_dt_tm,
   last_import_date = cnvtdate(cnvtint(format(c.import_begin_dt_tm,"mmddyyyy;;d"))),
   last_import_time = cnvtint(format(c.import_begin_dt_tm,"hhmmss"))
  WITH nocounter, forupdate(c)
 ;end select
 IF (curqual=0)
  CALL echo("The last import date/time could not be determined.")
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
 )
 SELECT DISTINCT INTO "NL:"
  s.object, s.object_name, s.cclgroup
  FROM ccl_synch_objects s,
   dprotect dp
  PLAN (s
   WHERE s.timestamp_dt_tm > cnvtdatetime(last_import_begin_dt_tm)
    AND s.rcode="5")
   JOIN (dp
   WHERE s.dic_key=dp.key1
    AND cnvtdatetime(dp.datestamp,dp.timestamp) >= s.timestamp_dt_tm)
  ORDER BY s.object, s.object_name
  DETAIL
   addcnt += 1
   IF (mod(addcnt,10)=1)
    stat = alterlist(object_list->qual,(addcnt+ 9))
   ENDIF
   object_list->qual[addcnt].object = s.object, object_list->qual[addcnt].object_name = s.object_name,
   object_list->qual[addcnt].group = s.cclgroup,
   object_list->qual[addcnt].checksum = s.checksum, object_list->qual[addcnt].major_version = s
   .major_version, object_list->qual[addcnt].minor_version = s.minor_version
  FOOT REPORT
   stat = alterlist(object_list->qual,addcnt)
  WITH counter, outerjoin = s, dontexist
 ;end select
 CALL echo("Objects to be imported")
 CALL echorecord(object_list)
 IF (addcnt > 0)
  INSERT  FROM ccl_synch_backup csb,
    (dgeneric dp  WITH access_code = "5"),
    (dummyt d  WITH seq = value(addcnt))
   SET csb.ccl_synch_backup_id = seq(ccl_dic_synch_seq,nextval), csb.object = object_list->qual[d.seq
    ].object, csb.object_name = object_list->qual[d.seq].object_name,
    csb.cclgroup = object_list->qual[d.seq].group, csb.timestamp_dt_tm = cnvtdatetime(
     import_begin_dt_tm), csb.rcode = "5",
    csb.node_name = ccl_node, csb.major_version = object_list->qual[d.seq].major_version, csb
    .minor_version = object_list->qual[d.seq].minor_version,
    csb.checksum = object_list->qual[d.seq].checksum, csb.dic_key = dp.key1, csb.dic_data = dp.data,
    csb.updt_dt_tm = cnvtdatetime(sysdate), csb.updt_id = reqinfo->updt_id, csb.updt_task = reqinfo->
    updt_task,
    csb.updt_applctx = reqinfo->updt_applctx, csb.updt_cnt = 0
   PLAN (d)
    JOIN (dp
    WHERE concat("H0000","5",object_list->qual[d.seq].object,object_list->qual[d.seq].object_name,
     char(object_list->qual[d.seq].group),
     fillstring(40,char(0))) <= dp.key1
     AND concat("H0000","5",object_list->qual[d.seq].object,object_list->qual[d.seq].object_name,char
     (object_list->qual[d.seq].group),
     fillstring(40,char(255))) >= dp.key1
     AND (object_list->qual[d.seq].group=ichar(substring(38,1,dp.key1))))
    JOIN (csb
    WHERE csb.dic_key=dp.key1)
   WITH counter, outerjoin = dp
  ;end insert
  CALL echo("-")
  CALL echo(build("Dprotect records backed up = ",curqual))
  CALL echo("-")
  INSERT  FROM ccl_synch_backup csb,
    (dgeneric dp  WITH access_code = "9"),
    (dummyt d  WITH seq = value(addcnt))
   SET csb.ccl_synch_backup_id = seq(ccl_dic_synch_seq,nextval), csb.object = object_list->qual[d.seq
    ].object, csb.object_name = object_list->qual[d.seq].object_name,
    csb.cclgroup = object_list->qual[d.seq].group, csb.timestamp_dt_tm = cnvtdatetime(
     import_begin_dt_tm), csb.rcode = "9",
    csb.node_name = ccl_node, csb.major_version = object_list->qual[d.seq].major_version, csb
    .minor_version = object_list->qual[d.seq].minor_version,
    csb.checksum = object_list->qual[d.seq].checksum, csb.dic_key = dp.key1, csb.dic_data = dp.data,
    csb.updt_dt_tm = cnvtdatetime(sysdate), csb.updt_id = reqinfo->updt_id, csb.updt_task = reqinfo->
    updt_task,
    csb.updt_applctx = reqinfo->updt_applctx, csb.updt_cnt = 0
   PLAN (d)
    JOIN (dp
    WHERE concat("H0000","9","P",object_list->qual[d.seq].object_name,char(object_list->qual[d.seq].
      group),
     fillstring(40,char(0))) <= dp.key1
     AND concat("H0000","9","P",object_list->qual[d.seq].object_name,char(object_list->qual[d.seq].
      group),
     fillstring(40,char(255))) >= dp.key1
     AND (object_list->qual[d.seq].group=ichar(substring(38,1,dp.key1))))
    JOIN (csb
    WHERE csb.dic_key=dp.key1)
   WITH counter, outerjoin = dp
  ;end insert
  CALL echo("-")
  CALL echo(build("Dcompile records backed up = ",curqual))
  CALL echo("-")
  IF (curqual > 0)
   COMMIT
  ENDIF
  FOR (cnt = 1 TO addcnt)
    IF ((object_list->qual[cnt].object IN ("E", "M", "P")))
     FREE SET com
     IF ((object_list->qual[cnt].group=0))
      SET com = concat("drop program ",trim(value(object_list->qual[cnt].object_name)),":DBA"," go")
     ELSE
      SET com = concat("drop program ",trim(value(object_list->qual[cnt].object_name)),":group",trim(
        cnvtstring(value(object_list->qual[cnt].group)))," go")
     ENDIF
    ELSE
     FREE SET com
     IF ((object_list->qual[cnt].group=0))
      SET com = concat("drop ekmodule ",trim(value(object_list->qual[cnt].object_name)),":DBA"," go")
     ELSE
      SET com = concat("drop ekmodule ",trim(value(object_list->qual[cnt].object_name)),":group",trim
       (cnvtstring(value(object_list->qual[cnt].group)))," go")
     ENDIF
    ENDIF
    CALL echo(com)
    CALL parser(com)
  ENDFOR
  SELECT INTO TABLE "ccldir:dic"
   key1 = cso.dic_key, data = cso.dic_data
   FROM (dummyt d  WITH seq = value(addcnt)),
    ccl_synch_objects cso
   PLAN (d)
    JOIN (cso
    WHERE (object_list->qual[d.seq].object=cso.object)
     AND (object_list->qual[d.seq].object_name=cso.object_name)
     AND (object_list->qual[d.seq].group=cso.cclgroup))
   ORDER BY key1
   WITH append, organization = i
  ;end select
  CALL echo(build("Records imported:",curqual))
 ENDIF
 UPDATE  FROM ccl_synch_data c
  SET c.import_begin_dt_tm = cnvtdatetime(import_begin_dt_tm), c.import_end_dt_tm = cnvtdatetime(
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
   "IMPORT",
   c.begin_dt_tm = cnvtdatetime(import_begin_dt_tm), c.end_dt_tm = cnvtdatetime(sysdate), c
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
