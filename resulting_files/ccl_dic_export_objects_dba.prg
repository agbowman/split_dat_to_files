CREATE PROGRAM ccl_dic_export_objects:dba
 PROMPT
  "Enter object name to export: " = " ",
  "Enter object group: " = 0,
  "Overwrite previously exported objects (Y,N,D):" = "D"
 DECLARE addcnt = i4
 DECLARE synch_data_id = f8
 DECLARE source_endian = i2 WITH noconstant(0)
 SET export_begin_dt_tm = cnvtdatetime(curdate,curtime3)
 SET object_names = cnvtupper(trim( $1))
 SET object_len = textlen(trim(object_names))
 SET object_group =  $2
 SET export_type = cnvtupper(substring(1,1, $3))
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
 CALL echo(concat("Export object name(s)= ",object_names,", export_type= ",export_type,", Node= ",
   ccl_node))
 CASE (cursys2)
  OF "AIX":
   SET source_endian = 1
  OF "HPX":
   SET source_endian = 1
  OF "LNX":
   SET source_endian = 0
  OF "WIN":
   SET source_endian = 0
  OF "AXP":
   SET source_endian = 0
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
     2 datestamp = i4
     2 timestamp = i4
     2 dprotect_data = c850
     2 dcompile[*]
       3 qual = i2
       3 databuf = c850
 )
 SET qualmax = 1000
 RECORD rec1(
   1 qual[1000]
     2 buf = c850
 )
 DECLARE show_object = i4 WITH noconstant(1)
 SELECT
  IF (export_type="D")
   FROM dprotect dp,
    dcompile dc,
    ccl_synch_objects cso
   PLAN (dp
    WHERE dp.platform="H0000"
     AND dp.rcode="5"
     AND dp.object IN ("E", "M", "P")
     AND dp.group=object_group
     AND dp.object_name=patstring(object_names))
    JOIN (dc
    WHERE "P"=dc.object
     AND dp.group=dc.group
     AND dp.object_name=dc.object_name)
    JOIN (cso
    WHERE ((cso.dic_key0=dp.key1) OR (cso.dic_key1=dp.key1))
     AND cso.timestamp_dt_tm >= cnvtdatetime(dp.datestamp,dp.timestamp))
   WITH counter, outerjoin = dc, dontexist
  ELSEIF (export_type="Y")
   FROM dprotect dp,
    dcompile dc
   PLAN (dp
    WHERE dp.platform="H0000"
     AND dp.rcode="5"
     AND dp.object IN ("E", "M", "P")
     AND dp.group=object_group
     AND dp.object_name=patstring(object_names))
    JOIN (dc
    WHERE "P"=dc.object
     AND dp.group=dc.group
     AND dp.object_name=dc.object_name)
  ELSE
  ENDIF
  INTO "NL:"
  grp = concat(dp.object,dp.object_name), dp.object, dp.object_name,
  dp.key1, bindata = check(substring(41,800,dc.datarec))
  ORDER BY grp
  HEAD REPORT
   addcnt = 0
  HEAD grp
   checksum = 0.0, ival = 0, addcnt = (addcnt+ 1)
   IF (mod(addcnt,10)=1)
    stat = alterlist(object_list->qual,(addcnt+ 9))
   ENDIF
   qualcnt = 0, overflow = 0
  DETAIL
   FOR (num = 1 TO 800)
    ival = ichar(substring(num,1,bindata)),
    IF (ival != 32)
     checksum = (checksum+ ival)
    ENDIF
   ENDFOR
   qualcnt = (qualcnt+ 1)
   IF (mod(qualcnt,10)=1)
    stat = alterlist(object_list->qual[addcnt].dcompile,(qualcnt+ 9))
   ENDIF
   object_list->qual[addcnt].dcompile[qualcnt].qual = dc.qual
   IF (qualcnt < qualmax)
    rec1->qual[qualcnt].buf = dc.datarec
   ELSE
    overflow = 1
   ENDIF
  FOOT  grp
   object_list->qual[addcnt].object_type = dp.object, object_list->qual[addcnt].object_name = dp
   .object_name, object_list->qual[addcnt].group = dp.group,
   object_list->qual[addcnt].datestamp = dp.datestamp, object_list->qual[addcnt].timestamp = dp
   .timestamp, object_list->qual[addcnt].checksum = checksum,
   object_list->qual[addcnt].major_version = dp.app_major_version, object_list->qual[addcnt].
   minor_version = dp.app_minor_version, databuf = substring(41,247,dp.datarec),
   CALL byteswap(4,193),
   CALL byteswap(4,197),
   CALL byteswap(4,201),
   CALL byteswap(4,205),
   CALL byteswap(4,209),
   CALL byteswap(4,213),
   CALL byteswap(4,217),
   CALL byteswap(4,221), stat = movestring(fillstring(8,char(0)),1,databuf,225,8),
   stat = movestring(fillstring(15," "),1,databuf,233,15), object_list->qual[addcnt].dprotect_data =
   databuf, stat = alterlist(object_list->qual[addcnt].dcompile,qualcnt)
   IF (overflow=1)
    CALL log_error(cclwarning,build("Object:",dp.object_name," exceeds ",qualmax,
     " records, will be skipped"))
   ELSEIF (qualcnt != dp.binary_cnt)
    CALL log_error(cclwarning,build("Object:",dp.object_name," dcompile=",qualcnt,
     " does not match dprotect=",
     dp.binary_cnt,", will be skipped"))
   ELSE
    stat = uar_ccldicutil_vmstounix(rec1,qualcnt,show_object)
    IF (stat)
     FOR (cnt2 = 1 TO qualcnt)
       databuf = rec1->qual[cnt2].buf,
       CALL byteswap(2,39), object_list->qual[addcnt].dcompile[cnt2].databuf = databuf
     ENDFOR
    ELSE
     CALL echo(build("Object:",dp.object_name," corrupt and will be skipped"))
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(object_list->qual,addcnt)
  WITH counter
 ;end select
 IF (curqual=0)
  IF (error(errmsg,0) > 0)
   CALL log_error(cclerror,concat("Failed to read DPROTECT/DCOMPILE records: ",errmsg))
  ELSE
   SET audit_status = "NODATA"
  ENDIF
  GO TO update_stats
 ENDIF
 IF (addcnt > 0
  AND export_type IN ("D", "Y"))
  DELETE  FROM ccl_synch_objects cso,
    (dummyt d  WITH seq = value(addcnt))
   SET cso.seq = 1
   PLAN (d)
    JOIN (cso
    WHERE (cso.object_type=object_list->qual[d.seq].object_type)
     AND (cso.object_name=object_list->qual[d.seq].object_name)
     AND (cso.cclgroup=object_list->qual[d.seq].group))
  ;end delete
  IF (curqual > 0)
   COMMIT
  ENDIF
 ENDIF
 IF (ccl_debug_ind=1)
  CALL echo("Objects to be exported")
  CALL echorecord(object_list)
 ENDIF
 IF (addcnt > 0)
  INSERT  FROM ccl_synch_objects cso,
    (dgeneric dp  WITH access_code = "5"),
    (dummyt d  WITH seq = value(addcnt))
   SET cso.ccl_synch_objects_id = seq(ccl_dic_synch_seq,nextval), cso.object_type = object_list->
    qual[d.seq].object_type, cso.object_name = object_list->qual[d.seq].object_name,
    cso.cclgroup = object_list->qual[d.seq].group, cso.timestamp_dt_tm = cnvtdatetime(object_list->
     qual[d.seq].datestamp,object_list->qual[d.seq].timestamp), cso.rcode = "5",
    cso.node_name = ccl_node, cso.major_version = object_list->qual[d.seq].major_version, cso
    .minor_version = object_list->qual[d.seq].minor_version,
    cso.endian_platform = source_endian, cso.checksum = object_list->qual[d.seq].checksum, cso
    .dic_key0 = dp.key1,
    cso.dic_key1 = dp.key1, cso.dic_data0 =
    IF (source_endian=0) dp.data
    ELSE object_list->qual[d.seq].dprotect_data
    ENDIF
    , cso.dic_data1 =
    IF (source_endian=1) dp.data
    ELSE object_list->qual[d.seq].dprotect_data
    ENDIF
    ,
    cso.updt_dt_tm = cnvtdatetime(curdate,curtime3), cso.updt_id = reqinfo->updt_id, cso.updt_task =
    reqinfo->updt_task,
    cso.updt_applctx = reqinfo->updt_applctx, cso.updt_cnt = 0
   PLAN (d)
    JOIN (dp
    WHERE concat("H0000","5",object_list->qual[d.seq].object_type,object_list->qual[d.seq].
     object_name,char(object_list->qual[d.seq].group),
     fillstring(40,char(0))) <= dp.key1
     AND concat("H0000","5",object_list->qual[d.seq].object_type,object_list->qual[d.seq].object_name,
     char(object_list->qual[d.seq].group),
     fillstring(40,char(255))) >= dp.key1
     AND (object_list->qual[d.seq].group=ichar(substring(38,1,dp.key1))))
    JOIN (cso
    WHERE cso.dic_key1=dp.key1)
   WITH counter, outerjoin = dp, dontexist
  ;end insert
  CALL echo("-")
  CALL echo(build("Dprotect records exported = ",curqual))
  CALL echo("-")
  IF (curqual=0
   AND error(errmsg,0) > 0)
   CALL log_error(cclerror,concat("Insert to ccl_synch_objects failed: ",errmsg))
   GO TO update_stats
  ENDIF
  DECLARE qualchar = i4 WITH noconstant(0)
  IF (source_endian=1)
   SET qualchar = 40
  ELSE
   SET qualchar = 39
  ENDIF
  FOR (nseq = 1 TO addcnt)
    CALL echo(concat("Object= ",object_list->qual[nseq].object_name,", binary_cnt= ",build(size(
        object_list->qual[nseq].dcompile,5))))
    INSERT  FROM ccl_synch_objects cso,
      (dgeneric dp  WITH access_code = "9"),
      (dummyt d  WITH seq = value(size(object_list->qual[nseq].dcompile,5)))
     SET cso.ccl_synch_objects_id = seq(ccl_dic_synch_seq,nextval), cso.object_type = object_list->
      qual[nseq].object_type, cso.object_name = object_list->qual[nseq].object_name,
      cso.cclgroup = object_list->qual[nseq].group, cso.timestamp_dt_tm = cnvtdatetime(object_list->
       qual[nseq].datestamp,object_list->qual[nseq].timestamp), cso.rcode = "9",
      cso.node_name = ccl_node, cso.major_version = object_list->qual[nseq].major_version, cso
      .minor_version = object_list->qual[nseq].minor_version,
      cso.endian_platform = source_endian, cso.checksum = object_list->qual[nseq].checksum, cso
      .dic_key0 =
      IF (source_endian=0) dp.key1
      ELSE notrim(substring(1,40,object_list->qual[nseq].dcompile[d.seq].databuf))
      ENDIF
      ,
      cso.dic_key1 =
      IF (source_endian=1) dp.key1
      ELSE notrim(substring(1,40,object_list->qual[nseq].dcompile[d.seq].databuf))
      ENDIF
      , cso.dic_data0 =
      IF (source_endian=0) dp.data
      ELSE notrim(substring(41,810,object_list->qual[nseq].dcompile[d.seq].databuf))
      ENDIF
      , cso.dic_data1 =
      IF (source_endian=1) dp.data
      ELSE notrim(substring(41,810,object_list->qual[nseq].dcompile[d.seq].databuf))
      ENDIF
      ,
      cso.qual = object_list->qual[nseq].dcompile[d.seq].qual, cso.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), cso.updt_id = reqinfo->updt_id,
      cso.updt_task = reqinfo->updt_task, cso.updt_applctx = reqinfo->updt_applctx, cso.updt_cnt = 0
     PLAN (d)
      JOIN (dp
      WHERE concat("H0000","9","P",object_list->qual[nseq].object_name,char(object_list->qual[nseq].
        group),
       fillstring(40,char(0))) <= dp.key1
       AND concat("H0000","9","P",object_list->qual[nseq].object_name,char(object_list->qual[nseq].
        group),
       fillstring(40,char(255))) >= dp.key1
       AND (object_list->qual[nseq].group=ichar(substring(38,1,dp.key1)))
       AND (object_list->qual[nseq].dcompile[d.seq].qual=ichar(substring(qualchar,1,dp.key1))))
      JOIN (cso
      WHERE ((cso.dic_key0=dp.key1) OR (cso.dic_key1=dp.key1)) )
     WITH counter, outerjoin = dp, dontexist
    ;end insert
    CALL echo("-")
    CALL echo(build("Dcompile records exported = ",curqual))
    CALL echo("-")
    IF (curqual=0
     AND error(errmsg,0) > 0)
     CALL log_error(cclerror,concat("Insert to ccl_synch_objects failed: ",errmsg))
    ENDIF
    IF (curqual > 0)
     COMMIT
    ENDIF
  ENDFOR
  SET audit_status = "SUCCESS"
 ENDIF
#update_stats
 IF (size(error_log->qual,5) > 0)
  CALL echo("Errors occurred:")
  CALL echorecord(error_log)
 ENDIF
 INSERT  FROM ccl_synch_audit c
  SET c.ccl_synch_audit_id = seq(ccl_dic_synch_seq,nextval), c.node_name = ccl_node, c.object_name =
   object_names,
   c.operation = "EXPORT", c.op_mode = export_type, c.status = audit_status,
   c.begin_dt_tm = cnvtdatetime(export_begin_dt_tm), c.end_dt_tm = cnvtdatetime(curdate,curtime3), c
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
