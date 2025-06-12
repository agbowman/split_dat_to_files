CREATE PROGRAM aps_chg_db_schemes:dba
#start_of_tags
 SET count1 = 0
 SET error_cnt = 0
 SET cur_updt_cnt2[500] = 0
 SET z = 1
 SET tag_error_ind = 0
 SET total_possible = ((request->group_qual[x].prefix_qual[y].del_cnt+ request->group_qual[x].
 prefix_qual[y].chg_cnt)+ request->group_qual[x].prefix_qual[y].add_cnt)
 IF ((request->group_qual[x].prefix_qual[y].del_cnt > 0))
  DELETE  FROM ap_prefix_tag_group_r aptg_r,
    (dummyt d  WITH seq = value(request->group_qual[x].prefix_qual[y].del_cnt))
   SET aptg_r.seq = 1
   PLAN (d)
    JOIN (aptg_r
    WHERE (request->group_qual[x].prefix_qual[y].prefix_cd=aptg_r.prefix_id)
     AND (request->group_qual[x].prefix_qual[y].del_qual[d.seq].tag_type_flag=aptg_r.tag_type_flag)
     AND (request->group_qual[x].prefix_qual[y].del_qual[d.seq].tag_group_cd=aptg_r.tag_group_id))
   WITH counter
  ;end delete
  IF ((curqual != request->group_qual[x].prefix_qual[y].del_cnt))
   SET tag_error_ind = 1
   CALL handle_errors("DELETE","F","TABLE","AP_PREFIX_TAG_GROUP_R")
  ENDIF
 ENDIF
 IF ((request->group_qual[x].prefix_qual[y].add_cnt > 0))
  INSERT  FROM ap_prefix_tag_group_r aptg_r,
    (dummyt d  WITH seq = value(request->group_qual[x].prefix_qual[y].add_cnt))
   SET aptg_r.prefix_id = request->group_qual[x].prefix_qual[y].prefix_cd, aptg_r.tag_type_flag =
    request->group_qual[x].prefix_qual[y].add_qual[d.seq].tag_type_flag, aptg_r.tag_group_id =
    request->group_qual[x].prefix_qual[y].add_qual[d.seq].tag_group_cd,
    aptg_r.primary_ind = request->group_qual[x].prefix_qual[y].add_qual[d.seq].primary_ind, aptg_r
    .tag_separator = request->group_qual[x].prefix_qual[y].add_qual[d.seq].tag_separator, aptg_r
    .updt_cnt = 0,
    aptg_r.updt_dt_tm = cnvtdatetime(curdate,curtime), aptg_r.updt_id = reqinfo->updt_id, aptg_r
    .updt_task = reqinfo->updt_task,
    aptg_r.updt_applctx = reqinfo->updt_applctx
   PLAN (d)
    JOIN (aptg_r)
   WITH counter
  ;end insert
  IF (((curqual=0) OR ((curqual != request->group_qual[x].prefix_qual[y].add_cnt))) )
   SET tag_error_ind = 1
   CALL handle_errors("INSERT","F","TABLE","AP_PREFIX_TAG_GROUP_R")
  ENDIF
 ENDIF
 IF ((request->group_qual[x].prefix_qual[y].chg_cnt > 0))
  SELECT INTO "nl:"
   aptg_r.*
   FROM ap_prefix_tag_group_r aptg_r,
    (dummyt d  WITH seq = value(request->group_qual[x].prefix_qual[y].chg_cnt))
   PLAN (d)
    JOIN (aptg_r
    WHERE (request->group_qual[x].prefix_qual[y].prefix_cd=aptg_r.prefix_id)
     AND (request->group_qual[x].prefix_qual[y].change_qual[d.seq].tag_type_flag=aptg_r.tag_type_flag
    ))
   HEAD REPORT
    count1 = 0
   DETAIL
    count1 += 1, cur_updt_cnt2[count1] = aptg_r.updt_cnt
   WITH forupdate(aptg_r)
  ;end select
  IF (((curqual=0) OR ((count1 != request->group_qual[x].prefix_qual[y].chg_cnt))) )
   SET tag_error_ind = 1
   CALL handle_errors("SELECT","F","TABLE","AP_PREFIX_TAG_GROUP_R")
  ENDIF
  FOR (xx = 1 TO request->group_qual[x].prefix_qual[y].chg_cnt)
    IF ((request->group_qual[x].prefix_qual[y].change_qual[xx].updt_cnt != cur_updt_cnt2[xx]))
     SET tag_error_ind = 1
     CALL handle_errors("LOCK","F","TABLE","AP_PREFIX_TAG_GROUP_R")
    ENDIF
  ENDFOR
  UPDATE  FROM ap_prefix_tag_group_r aptg_r,
    (dummyt d  WITH seq = value(request->group_qual[x].prefix_qual[y].chg_cnt))
   SET aptg_r.tag_type_flag = request->group_qual[x].prefix_qual[y].change_qual[d.seq].tag_type_flag,
    aptg_r.tag_group_id = request->group_qual[x].prefix_qual[y].change_qual[d.seq].tag_group_cd,
    aptg_r.primary_ind = request->group_qual[x].prefix_qual[y].change_qual[d.seq].primary_ind,
    aptg_r.tag_separator = request->group_qual[x].prefix_qual[y].change_qual[d.seq].tag_separator,
    aptg_r.updt_cnt = (cur_updt_cnt2[d.seq]+ 1), aptg_r.updt_dt_tm = cnvtdatetime(curdate,curtime),
    aptg_r.updt_id = reqinfo->updt_id, aptg_r.updt_task = reqinfo->updt_task, aptg_r.updt_applctx =
    reqinfo->updt_applctx
   PLAN (d)
    JOIN (aptg_r
    WHERE (request->group_qual[x].prefix_qual[y].prefix_cd=aptg_r.prefix_id)
     AND (request->group_qual[x].prefix_qual[y].change_qual[d.seq].tag_type_flag=aptg_r.tag_type_flag
    ))
   WITH counter
  ;end update
  IF (curqual=0)
   SET tag_error_ind = 1
   CALL handle_errors("UPDATE","F","TABLE","AP_PREFIX_TAG_GROUP_R")
  ENDIF
 ENDIF
#exit_script
 SET stat = alterlist(reply->exception_data,tag_error_cnt)
 IF (error_cnt > 0)
  IF (error_cnt=total_possible)
   SET reply->status_data.status = "F"
  ELSE
   SET reply->status_data.status = "P"
  ENDIF
  ROLLBACK
 ELSE
  SET reply->status_data.status = "S"
  COMMIT
 ENDIF
END GO
