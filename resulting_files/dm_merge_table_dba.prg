CREATE PROGRAM dm_merge_table:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
     2 err_num = i4
     2 err_msg = c255
 )
 SET sql_stmt_one = fillstring(132," ")
 SET sql_stmt_two = fillstring(132," ")
 SET sql_stmt_three = fillstring(132," ")
 SET parser_buf[4] = fillstring(132," ")
 RECORD pending_requests(
   1 qual[*]
     2 from_value = f8
     2 from_rowid = c18
     2 to_value = f8
     2 to_rowid = c18
     2 merge_id = f8
     2 table_name = c30
     2 column_name = c30
     2 restrict_clause = c255
     2 child_ind = i2
     2 audit_ind = i2
     2 master_ind = i2
     2 code_set = i2
   1 db_link = c20
   1 env_source_id = f8
   1 env_target_id = f8
 )
 DECLARE min_merge_id = f8
 SET preq_cnt = 0
 SELECT INTO "NL:"
  FROM dm_merge_action dma
  WHERE dma.merge_status_flag=1
   AND  NOT ( EXISTS (
  (SELECT
   "X"
   FROM v$session v
   WHERE v.process=dma.process)))
  WITH nocounter
 ;end select
 IF (curqual > 0)
  UPDATE  FROM dm_merge_action dma
   SET dma.merge_status_flag = 7
   WHERE dma.merge_status_flag=1
    AND  NOT ( EXISTS (
   (SELECT
    "X"
    FROM v$session v
    WHERE v.process=dma.process)))
  ;end update
 ENDIF
 SET incomplete_process = 1
 WHILE (incomplete_process=1)
   SELECT INTO "NL:"
    FROM dm_merge_action dma
    WHERE dma.merge_status_flag=7
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET incomplete_process = 1
   ELSE
    SET incomplete_process = 0
   ENDIF
   SET min_merge_id = 0
   SELECT INTO "nl:"
    x = min(dma.merge_id)
    FROM dm_merge_action dma
    WHERE dma.merge_status_flag=7
    DETAIL
     min_merge_id = x
    WITH nocounter
   ;end select
   SET preq_cnt = 0
   SELECT INTO "nl:"
    dma.*
    FROM dm_merge_action dma
    WHERE dma.merge_id=min_merge_id
    DETAIL
     preq_cnt = (preq_cnt+ 1), stat = alterlist(pending_requests->qual,preq_cnt)
     IF (preq_cnt=1)
      pending_requests->db_link = dma.db_link, pending_requests->env_source_id = dma.env_source_id,
      pending_requests->env_target_id = dma.env_target_id
     ENDIF
     pending_requests->qual[preq_cnt].restrict_clause = " ", pending_requests->qual[preq_cnt].
     audit_ind = dma.audit_ind, pending_requests->qual[preq_cnt].child_ind = 1,
     pending_requests->qual[preq_cnt].code_set = dma.code_set, pending_requests->qual[preq_cnt].
     master_ind = dma.master_ind, pending_requests->qual[preq_cnt].table_name = dma.table_name,
     pending_requests->qual[preq_cnt].from_rowid = dma.from_rowid, pending_requests->qual[preq_cnt].
     to_rowid = dma.to_rowid, pending_requests->qual[preq_cnt].merge_id = dma.merge_id
    WITH nocounter, forupdatewait(dma)
   ;end select
   FOR (icnt = 1 TO preq_cnt)
     SET trace symbol mark
     SET sql_stmt_one = concat('RDB ASIS(" begin DM_MERGE_PACKAGE.DM_RECURSIVE_MERGE(0,',"'",trim(
       pending_requests->qual[icnt].from_rowid),"', 0, '",trim(pending_requests->qual[icnt].to_rowid),
      "',",'")')
     SET sql_stmt_two = concat(' ASIS(" ',"'",trim(pending_requests->qual[icnt].table_name),"','",
      trim(pending_requests->qual[icnt].column_name),
      "',",cnvtstring(pending_requests->env_source_id,12),",",cnvtstring(pending_requests->
       env_target_id,12),",'",
      trim(pending_requests->db_link),"',",'") ')
     SET sql_stmt_three = concat(' ASIS(",',cnvtstring(pending_requests->qual[icnt].child_ind,5,0,r),
      ",",cnvtstring(pending_requests->qual[icnt].audit_ind,5,0,r),",",
      cnvtstring(pending_requests->qual[icnt].code_set,5,0,r),",",cnvtstring(pending_requests->qual[
       icnt].master_ind,5,0,r),",",cnvtstring(pending_requests->qual[icnt].merge_id,12),
      '); end; ")'," GO")
     SET parser_buf[1] = sql_stmt_one
     SET parser_buf[2] = sql_stmt_two
     SET parser_buf[3] = concat("'",trim(substring(1,130,pending_requests->qual[icnt].restrict_clause
        )),"'")
     SET parser_buf[4] = sql_stmt_three
     FOR (cnt = 1 TO 4)
       CALL parser(parser_buf[cnt],1)
     ENDFOR
     SET trace symbol release
   ENDFOR
 ENDWHILE
END GO
