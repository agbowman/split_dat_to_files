CREATE PROGRAM ccl_dic_import_objects:dba
 PROMPT
  "Enter object name(s) to import: " = " ",
  "Enter object group: " = 0,
  "Overwrite live object(s): " = "D"
 DECLARE synch_data_id = f8
 DECLARE source_endian = i2 WITH noconstant(0)
 DECLARE target_endian = i2 WITH noconstant(0)
 SET import_begin_dt_tm = cnvtdatetime(curdate,curtime3)
 SET import_end_dt_tm = cnvtdatetime(curdate,curtime3)
 DECLARE addcnt = i4
 SET object_names = cnvtupper(trim( $1))
 SET object_len = textlen(trim(object_names))
 SET object_group =  $2
 SET import_type = cnvtupper(substring(1,1, $3))
 IF (object_len <= 4
  AND substring(object_len,1,object_names)=patstring("*"))
  CALL echo(concat("Error on object name= ",object_names,
    ": The minimum length of a wildcard name for object import is 3 characters."))
  CALL echo("Exiting Program..")
  GO TO exit_program
 ENDIF
 DECLARE errmsg = vc WITH protect, noconstant(" ")
 DECLARE errcnt = i4 WITH noconstant(0)
 DECLARE ccl_node = c20
 DECLARE audit_status = c10
 DECLARE cclwarning = vc WITH constant("WARNING")
 DECLARE cclerror = vc WITH constant("ERROR")
 DECLARE cclfatal = vc WITH constant("FATAL")
 RECORD error_log(
   1 qual[*]
     2 type = c10
     2 text = vc
 )
 SET audit_status = "FAILED"
 DECLARE ccl_debug_ind = i4 WITH noconstant(0)
 IF (validate(dm_debug,- (1))=1)
  SET ccl_debug_ind = 1
 ENDIF
 SET ccl_node = cnvtupper(trim(curnode))
 SUBROUTINE log_error(errtype,errtext)
   SET errcnt = size(error_log->qual,5)
   SET stat = alterlist(error_log->qual,(errcnt+ 1))
   SET error_log->qual[errcnt].type = errtype
   SET error_log->qual[errcnt].text = errtext
 END ;Subroutine
 DECLARE databuf = c850
 DECLARE tmp = c4
 SUBROUTINE byteswap(p_len,p_off)
  SET tmp = substring(p_off,p_len,databuf)
  FOR (p_num = 1 TO p_len)
    SET stat = movestring(tmp,p_num,databuf,(p_off+ (p_len - p_num)),1)
  ENDFOR
 END ;Subroutine
 SET logical "SHRCCLDICUTIL" "CER_EXE:SHRCCLDICUTIL.EXE"
 DECLARE uar_ccldicutil_vmstounix(p1=vc(ref),p2=i4(value),p3=i4(value)) = i4 WITH image_axp =
 "shrccldicutil", image_aix = "libccldicutil.a(shobjccldicutil.o)", uar = "ccldicutil_vmstounix"
 IF (error(errmsg,0) > 0)
  CALL log_error(cclwarning,concat("declare uar_ccldicutil_vmstounix failed: ",errmsg))
 ENDIF
 CALL echo(concat("Import object name(s)= ",object_names,", import type= ",import_type,", Node= ",
   ccl_node))
 CASE (cursys2)
  OF "AIX":
   SET target_endian = 1
  OF "HPX":
   SET target_endian = 1
  OF "LNX":
   SET target_endian = 0
  OF "WIN":
   SET target_endian = 0
  OF "AXP":
   SET target_endian = 0
  ELSE
   CALL echo(concat("ERROR! CURSYS= ",cursys," not supported."))
   CALL echo("Exiting program.")
   GO TO exit_program
 ENDCASE
 FREE RECORD object_list
 RECORD object_list(
   1 qual[*]
     2 object_type = c1
     2 object_name = c30
     2 group = i1
     2 checksum = f8
     2 major_version = i4
     2 minor_version = i4
     2 endian_platform = i2
     2 datestamp = i4
     2 timestamp = i4
     2 dprotect_data[*]
       3 databuf = c850
     2 dic_data[*]
       3 rcode = c1
       3 qual = i4
       3 databuf = c850
 )
 SELECT
  IF (import_type="D")DISTINCT INTO "NL:"
   s.object_type, s.object_name, s.cclgroup
   FROM ccl_synch_objects s,
    dprotect dp
   PLAN (s
    WHERE s.object_name=patstring(object_names)
     AND s.cclgroup=object_group
     AND s.rcode="5")
    JOIN (dp
    WHERE s.dic_key1=dp.key1
     AND cnvtdatetime(dp.datestamp,dp.timestamp) >= s.timestamp_dt_tm)
   ORDER BY s.object_type, s.object_name
   WITH counter, outerjoin = s, dontexist
  ELSEIF (import_type="Y")DISTINCT INTO "NL:"
   s.object_type, s.object_name, s.cclgroup
   FROM ccl_synch_objects s
   PLAN (s
    WHERE s.object_name=patstring(object_names)
     AND s.cclgroup=object_group
     AND s.rcode="5")
   ORDER BY s.object_type, s.object_name
   WITH nocounter
  ELSE
  ENDIF
  DETAIL
   addcnt = (addcnt+ 1)
   IF (mod(addcnt,10)=1)
    stat = alterlist(object_list->qual,(addcnt+ 9))
   ENDIF
   object_list->qual[addcnt].object_type = s.object_type, object_list->qual[addcnt].object_name = s
   .object_name, object_list->qual[addcnt].group = s.cclgroup,
   object_list->qual[addcnt].checksum = s.checksum, object_list->qual[addcnt].major_version = s
   .major_version, object_list->qual[addcnt].minor_version = s.minor_version,
   object_list->qual[addcnt].endian_platform = s.endian_platform
  FOOT REPORT
   stat = alterlist(object_list->qual,addcnt), source_endian = s.endian_platform
  WITH counter
 ;end select
 IF (curqual=0)
  IF (error(errmsg,0) > 0)
   CALL log_error(cclerror,concat("Failed to read CCL_SYNCH_OBJECT records: ",errmsg))
  ELSE
   SET audit_status = "NODATA"
  ENDIF
  GO TO update_stats
 ENDIF
 IF (ccl_debug_ind=1)
  CALL echo("Objects to be imported")
  CALL echorecord(object_list)
 ENDIF
 IF (addcnt > 0)
  INSERT  FROM ccl_synch_backup csb,
    (dgeneric dp  WITH access_code = "5"),
    (dummyt d  WITH seq = value(addcnt))
   SET csb.ccl_synch_backup_id = seq(ccl_dic_synch_seq,nextval), csb.object_type = object_list->qual[
    d.seq].object_type, csb.object_name = object_list->qual[d.seq].object_name,
    csb.cclgroup = object_list->qual[d.seq].group, csb.timestamp_dt_tm = cnvtdatetime(
     import_begin_dt_tm), csb.rcode = "5",
    csb.node_name = ccl_node, csb.major_version = object_list->qual[d.seq].major_version, csb
    .minor_version = object_list->qual[d.seq].minor_version,
    csb.endian_platform = source_endian, csb.checksum = object_list->qual[d.seq].checksum, csb
    .dic_key0 =
    IF (target_endian=0) dp.key1
    ELSE ""
    ENDIF
    ,
    csb.dic_key1 =
    IF (target_endian=1) dp.key1
    ELSE ""
    ENDIF
    , csb.dic_data0 =
    IF (target_endian=0) dp.data
    ELSE ""
    ENDIF
    , csb.dic_data1 =
    IF (target_endian=1) dp.data
    ELSE ""
    ENDIF
    ,
    csb.updt_dt_tm = cnvtdatetime(curdate,curtime3), csb.updt_id = reqinfo->updt_id, csb.updt_task =
    reqinfo->updt_task,
    csb.updt_applctx = reqinfo->updt_applctx, csb.updt_cnt = 0
   PLAN (d)
    JOIN (dp
    WHERE concat("H0000","5",object_list->qual[d.seq].object_type,object_list->qual[d.seq].
     object_name,char(object_list->qual[d.seq].group),
     fillstring(40,char(0))) <= dp.key1
     AND concat("H0000","5",object_list->qual[d.seq].object_type,object_list->qual[d.seq].object_name,
     char(object_list->qual[d.seq].group),
     fillstring(40,char(255))) >= dp.key1
     AND (object_list->qual[d.seq].group=ichar(substring(38,1,dp.key1))))
    JOIN (csb
    WHERE ((csb.dic_key0=dp.key1) OR (csb.dic_key1=dp.key1)) )
   WITH counter, outerjoin = dp
  ;end insert
  IF (curqual=0
   AND error(errmsg,0) > 0)
   CALL log_error(cclerror,concat("Insert to ccl_synch_backup failed: ",errmsg))
  ENDIF
  CALL echo("-")
  CALL echo(build("Dprotect records backed up = ",curqual))
  CALL echo("-")
  INSERT  FROM ccl_synch_backup csb,
    (dgeneric dp  WITH access_code = "9"),
    (dummyt d  WITH seq = value(addcnt))
   SET csb.ccl_synch_backup_id = seq(ccl_dic_synch_seq,nextval), csb.object_type = object_list->qual[
    d.seq].object_type, csb.object_name = object_list->qual[d.seq].object_name,
    csb.cclgroup = object_list->qual[d.seq].group, csb.timestamp_dt_tm = cnvtdatetime(
     import_begin_dt_tm), csb.rcode = "9",
    csb.node_name = ccl_node, csb.major_version = object_list->qual[d.seq].major_version, csb
    .minor_version = object_list->qual[d.seq].minor_version,
    csb.endian_platform = source_endian, csb.checksum = object_list->qual[d.seq].checksum, csb
    .dic_key0 =
    IF (target_endian=0) dp.key1
    ELSE ""
    ENDIF
    ,
    csb.dic_key1 =
    IF (target_endian=1) dp.key1
    ELSE ""
    ENDIF
    , csb.dic_data0 =
    IF (target_endian=0) dp.data
    ELSE ""
    ENDIF
    , csb.dic_data1 =
    IF (target_endian=1) dp.data
    ELSE ""
    ENDIF
    ,
    csb.updt_dt_tm = cnvtdatetime(curdate,curtime3), csb.updt_id = reqinfo->updt_id, csb.updt_task =
    reqinfo->updt_task,
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
    WHERE ((csb.dic_key0=dp.key1) OR (csb.dic_key1=dp.key1)) )
   WITH counter, outerjoin = dp
  ;end insert
  IF (curqual=0
   AND error(errmsg,0) > 0)
   CALL log_error(cclerror,concat("Insert to ccl_synch_backup failed: ",errmsg))
  ENDIF
  CALL echo("-")
  CALL echo(build("Dcompile records backed up = ",curqual))
  CALL echo("-")
  IF (curqual > 0)
   COMMIT
  ENDIF
  FOR (cnt = 1 TO addcnt)
   SET prog_exists = checkdic(object_list->qual[cnt].object_name,object_list->qual[cnt].object_type,
    object_list->qual[cnt].group)
   IF (prog_exists=2)
    IF ((object_list->qual[cnt].object_type IN ("E", "M", "P")))
     FREE SET com
     IF ((object_list->qual[cnt].group=0))
      SET com = concat("drop program ",trim(value(object_list->qual[cnt].object_name)),":DBA go")
     ELSE
      SET com = concat("drop program ",trim(value(object_list->qual[cnt].object_name)),":group",trim(
        cnvtstring(value(object_list->qual[cnt].group)))," go")
     ENDIF
    ELSE
     FREE SET com
     IF ((object_list->qual[cnt].group=0))
      SET com = concat("drop ekmodule ",trim(value(object_list->qual[cnt].object_name)),":DBA go")
     ELSE
      SET com = concat("drop ekmodule ",trim(value(object_list->qual[cnt].object_name)),":group",trim
       (cnvtstring(value(object_list->qual[cnt].group)))," go")
     ENDIF
    ENDIF
    CALL echo(com)
    CALL parser(com)
   ELSEIF (prog_exists=1)
    CALL echo(concat("ERROR on checkdic(). Object: ",object_list->qual[cnt].object_name,
      " exists but cannot be accessed."))
   ENDIF
  ENDFOR
  CALL echo(build("source_endian= ",source_endian,", target_endian= ",target_endian))
  CALL echo("Importing records to dic.dat directly from ccl_synch_objects..")
  SELECT
   IF (target_endian=0)
    key1 = cso.dic_key0, data = cso.dic_data0
   ELSE
    key1 = cso.dic_key1, data = cso.dic_data1
   ENDIF
   INTO TABLE "ccldir:dic"
   FROM (dummyt d  WITH seq = value(addcnt)),
    ccl_synch_objects cso
   PLAN (d)
    JOIN (cso
    WHERE (object_list->qual[d.seq].object_type=cso.object_type)
     AND (object_list->qual[d.seq].object_name=cso.object_name)
     AND (object_list->qual[d.seq].group=cso.cclgroup))
   ORDER BY key1
   WITH append, organization = i
  ;end select
  CALL echo(build("DPROTECT/DCOMPILE Records imported:",curqual))
  IF (curqual=0
   AND error(errmsg,0) > 0)
   CALL log_error(cclerror,concat("Insert of records to ccldir:dic failed: ",errmsg))
  ELSE
   SET audit_status = "SUCCESS"
  ENDIF
  GO TO update_stats
 ENDIF
#update_stats
 IF (size(error_log->qual,5) > 0)
  CALL echo("Errors occurred:")
  CALL echorecord(error_log)
 ENDIF
 INSERT  FROM ccl_synch_audit c
  SET c.ccl_synch_audit_id = seq(ccl_dic_synch_seq,nextval), c.node_name = ccl_node, c.object_name =
   object_names,
   c.operation = "IMPORT", c.op_mode = import_type, c.status = audit_status,
   c.begin_dt_tm = cnvtdatetime(import_begin_dt_tm), c.end_dt_tm = cnvtdatetime(curdate,curtime3), c
   .updt_dt_tm = cnvtdatetime(curdate,curtime3),
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
