CREATE PROGRAM ccl_dic_synch_backout:dba
 PROMPT
  "Enter the start date and time of the import you are backing out: " = " ",
  "Enter the Object Type of the object you are wanting to backout:  " = " ",
  "Enter the Object Name of the object you are wanting to backout:  " = " "
 SET backout_begin_dt_tm = cnvtdatetime(sysdate)
 SET ccl_node = cnvtupper(logical("JOU_INSTANCE"))
 DECLARE addcnt = i4
 FREE RECORD object_list
 RECORD object_list(
   1 qual[*]
     2 object = c1
     2 object_name = c30
     2 group = i1
 )
 SELECT DISTINCT INTO "NL:"
  csb.object, csb.object_name, csb.cclgroup
  FROM ccl_synch_backup csb
  WHERE csb.timestamp_dt_tm=cnvtdatetime( $1)
   AND csb.object=patstring(cnvtupper( $2))
   AND csb.object_name=patstring(cnvtupper( $3))
  ORDER BY csb.timestamp_dt_tm, csb.object, csb.object_name
  DETAIL
   addcnt += 1
   IF (mod(addcnt,10)=1)
    stat = alterlist(object_list->qual,(addcnt+ 9))
   ENDIF
   object_list->qual[addcnt].object = csb.object, object_list->qual[addcnt].object_name = csb
   .object_name, object_list->qual[addcnt].group = csb.cclgroup
  FOOT REPORT
   stat = alterlist(object_list->qual,addcnt)
  WITH counter
 ;end select
 IF (addcnt > 0)
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
     SET com = concat("drop ekmodule ",trim(value(object_list->qual[cnt].object_name)),":group",trim(
       cnvtstring(value(object_list->qual[cnt].group)))," go")
    ENDIF
   ENDIF
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
  SET dir = ccluserdir
 ENDIF
 INSERT  FROM ccl_synch_audit c
  SET c.ccl_synch_audit_id = seq(ccl_dic_synch_seq,nextval), c.node_name = ccl_node, c.operation =
   "BACKOUT",
   c.begin_dt_tm = cnvtdatetime(backout_begin_dt_tm), c.end_dt_tm = cnvtdatetime(sysdate), c
   .updt_dt_tm = cnvtdatetime(sysdate),
   c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->
   updt_applctx,
   c.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual > 0)
  COMMIT
 ENDIF
END GO
