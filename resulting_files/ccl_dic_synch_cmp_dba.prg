CREATE PROGRAM ccl_dic_synch_cmp:dba
 PROMPT
  "Enter object name : " = "*",
  "Enter number of days in past to collect : " = 1
 SET ccl_node = cnvtupper(logical("JOU_INSTANCE"))
 DELETE  FROM ccl_synch_cmp c
  WHERE c.node_name=ccl_node
  WITH counter
 ;end delete
 FREE RECORD object_list
 RECORD object_list(
   1 qual[*]
     2 object = c1
     2 object_name = c30
     2 group = i1
     2 binary_cnt = i4
     2 checksum = f8
     2 user_name = c12
     2 major_version = i4
     2 minor_version = i4
     2 datestamp = i4
     2 timestamp = i4
 )
 SET addcnt = 0
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
    AND dp.object_name=patstring(cnvtupper( $1))
    AND (dp.datestamp >= (curdate -  $2)))
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
   .timestamp, object_list->qual[addcnt].binary_cnt = dp.binary_cnt,
   object_list->qual[addcnt].checksum = checksum, object_list->qual[addcnt].user_name = dp.user_name,
   object_list->qual[addcnt].major_version = dp.app_major_version,
   object_list->qual[addcnt].minor_version = dp.app_minor_version
  FOOT REPORT
   stat = alterlist(object_list->qual,addcnt)
  WITH counter, outerjoin = dc, dontexist
 ;end select
 INSERT  FROM ccl_synch_cmp c,
   (dummyt d  WITH seq = value(addcnt))
  SET c.object = object_list->qual[d.seq].object, c.object_name = object_list->qual[d.seq].
   object_name, c.cclgroup = object_list->qual[d.seq].group,
   c.node_name = ccl_node, c.timestamp_dt_tm = cnvtdatetime(object_list->qual[d.seq].datestamp,
    object_list->qual[d.seq].timestamp), c.major_version = object_list->qual[d.seq].major_version,
   c.minor_version = object_list->qual[d.seq].minor_version, c.binary_cnt = object_list->qual[d.seq].
   binary_cnt, c.checksum = object_list->qual[d.seq].checksum,
   c.user_name = object_list->qual[d.seq].user_name
  PLAN (d)
   JOIN (c)
  WITH counter
 ;end insert
 IF (curqual > 0)
  COMMIT
 ENDIF
END GO
