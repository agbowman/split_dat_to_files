CREATE PROGRAM aps_chg_db_spec_grouping:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 exception_data[1]
     2 category_cd = f8
     2 category_desc = vc
 )
 SET reply->status_data.status = "F"
 SET cur_updt_cnt = 0
 SET nbr_of_groupings = size(request->qual,5)
 SET x = 1
 SET error_cnt = 0
 SET cur_updt_cnt2[500] = 0
 SET count1 = 0
#start_of_script
 FOR (x = x TO nbr_of_groupings)
   IF ((request->qual[x].action="A"))
    SELECT INTO "nl:"
     next_seq_nbr = seq(reference_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      request->qual[x].category_cd = cnvtreal(next_seq_nbr)
     WITH format, nocounter
    ;end select
    IF (curqual=0)
     CALL handle_errors("NEXTVAL","F","SEQUENCE","REFERENCE_SEQ")
     GO TO start_of_script
    ENDIF
    INSERT  FROM code_value c
     SET c.code_value =
      IF ((request->qual[x].category_cd=0)) null
      ELSE request->qual[x].category_cd
      ENDIF
      , c.code_set = 1312, c.display = request->qual[x].category_desc,
      c.display_key = cnvtupper(cnvtalphanum(request->qual[x].category_desc)), c.description =
      request->qual[x].category_desc, c.updt_dt_tm = cnvtdatetime(curdate,curtime),
      c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->
      updt_applctx,
      c.active_ind = 1, c.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (curqual=0)
     CALL handle_errors("INSERT","F","TABLE","CODE_VALUE, 1312")
     GO TO start_of_script
    ENDIF
   ELSEIF ((request->qual[x].action="C"))
    SELECT INTO "nl:"
     c.*
     FROM code_value c
     WHERE c.code_set=1312
      AND (c.code_value=request->qual[x].category_cd)
     DETAIL
      cur_updt_cnt = c.updt_cnt
     WITH forupdate(c)
    ;end select
    IF (curqual=0)
     CALL handle_errors("SELECT","F","TABLE","CODE_VALUE, 1312")
     GO TO start_of_script
    ENDIF
    IF ((request->qual[x].updt_cnt != cur_updt_cnt))
     CALL handle_errors("LOCK","F","TABLE","CODE_VALUE, 1312")
     GO TO start_of_script
    ENDIF
    SET cur_updt_cnt = (cur_updt_cnt+ 1)
    UPDATE  FROM code_value c
     SET c.display = request->qual[x].category_desc, c.display_key = cnvtupper(cnvtalphanum(request->
        qual[x].category_desc)), c.description = request->qual[x].category_desc,
      c.updt_dt_tm = cnvtdatetime(curdate,curtime), c.updt_cnt = cur_updt_cnt, c.updt_id = reqinfo->
      updt_id,
      c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->updt_applctx
     WHERE c.code_set=1312
      AND (c.code_value=request->qual[x].category_cd)
     WITH nocounter
    ;end update
    IF (curqual=0)
     CALL handle_errors("UPDATE","F","TABLE","CODE_VALUE, 1312")
     GO TO start_of_script
    ENDIF
   ELSEIF ((request->qual[x].action="D"))
    DELETE  FROM specimen_grouping_r spgr_r
     WHERE (request->qual[x].category_cd=spgr_r.category_cd)
     WITH nocounter
    ;end delete
    DELETE  FROM code_value c
     WHERE c.code_set=1312
      AND (c.code_value=request->qual[x].category_cd)
     WITH nocounter
    ;end delete
   ENDIF
   IF ((request->qual[x].source_del_cnt > 0))
    DELETE  FROM specimen_grouping_r spgr_r,
      (dummyt d  WITH seq = value(request->qual[x].source_del_cnt))
     SET spgr_r.seq = 1
     PLAN (d)
      JOIN (spgr_r
      WHERE (request->qual[x].category_cd=spgr_r.category_cd)
       AND (request->qual[x].source_del_qual[d.seq].source_cd=spgr_r.source_cd))
     WITH nocounter
    ;end delete
    IF ((curqual != request->qual[x].source_del_cnt))
     CALL handle_errors("DELETE","F","TABLE","SPEC_GROUP_R")
     GO TO start_of_script
    ENDIF
   ENDIF
   IF ((request->qual[x].source_add_cnt > 0)
    AND (request->qual[x].category_cd > 0))
    INSERT  FROM specimen_grouping_r spgr_r,
      (dummyt d  WITH seq = value(request->qual[x].source_add_cnt))
     SET spgr_r.category_cd = request->qual[x].category_cd, spgr_r.source_cd = request->qual[x].
      source_add_qual[d.seq].source_cd, spgr_r.updt_dt_tm = cnvtdatetime(curdate,curtime),
      spgr_r.updt_id = reqinfo->updt_id, spgr_r.updt_task = reqinfo->updt_task, spgr_r.updt_applctx
       = reqinfo->updt_applctx,
      spgr_r.updt_cnt = 0
     PLAN (d)
      JOIN (spgr_r)
     WITH nocounter
    ;end insert
    IF ((curqual != request->qual[x].source_add_cnt))
     CALL handle_errors("ADD","F","TABLE","SPEC_GROUP_R")
     GO TO start_of_script
    ENDIF
   ENDIF
   IF ((request->qual[x].prefix_cnt > 0))
    SELECT INTO "nl:"
     ap.prefix_id
     FROM ap_prefix ap,
      (dummyt d  WITH seq = value(request->qual[x].prefix_cnt))
     PLAN (d)
      JOIN (ap
      WHERE (request->qual[x].prefix_qual[d.seq].prefix_cd=ap.prefix_id))
     HEAD REPORT
      count1 = 0
     DETAIL
      count1 = (count1+ 1), cur_updt_cnt2[count1] = ap.updt_cnt
     WITH forupdate(ap)
    ;end select
    IF (((curqual=0) OR ((count1 != request->qual[x].prefix_cnt))) )
     CALL handle_errors("SELECT","F","TABLE","AP_PREFIX")
    ENDIF
    FOR (xx = 1 TO request->qual[x].prefix_cnt)
      IF ((request->qual[x].prefix_qual[xx].updt_cnt != cur_updt_cnt2[xx]))
       CALL handle_errors("LOCK","F","TABLE","AP_PREFIX")
      ENDIF
    ENDFOR
    UPDATE  FROM ap_prefix ap,
      (dummyt d  WITH seq = value(request->qual[x].prefix_cnt))
     SET ap.specimen_grouping_cd = request->qual[x].category_cd, ap.updt_cnt = (cur_updt_cnt2[d.seq]
      + 1)
     PLAN (d)
      JOIN (ap
      WHERE (request->qual[x].prefix_qual[d.seq].prefix_cd=ap.prefix_id))
     WITH counter
    ;end update
    IF (curqual=0)
     CALL handle_errors("UPDATE","F","TABLE","AP_PREFIX")
    ENDIF
   ENDIF
   COMMIT
 ENDFOR
#exit_script
 IF (error_cnt > 0)
  IF (error_cnt=nbr_of_groupings)
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "P"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   ROLLBACK
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
    SET stat = alter(reply->exception_data,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
   IF ((request->qual[x].action="A"))
    SET reply->exception_data[error_cnt].category_desc = request->qual[x].category_desc
   ELSE
    SET reply->exception_data[error_cnt].category_cd = request->qual[x].category_cd
   ENDIF
   SET x = (x+ 1)
 END ;Subroutine
END GO
