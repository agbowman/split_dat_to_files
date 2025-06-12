CREATE PROGRAM aps_chg_db_codeset:dba
 RECORD internal(
   1 qual[1]
     2 status = i1
 )
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 exception_data[1]
     2 code_value = f8
 )
 SET reply->status_data.status = "F"
 SET cur_updt_cnt[500] = 0
 SET count1 = 0
 SET nbr_to_change = size(request->qual,5)
 SET nbr_good_changes = nbr_to_change
 SET stat = alter(internal->qual,nbr_to_change)
 SET failed = "F"
 SET error_cnt = 0
 SELECT INTO "nl:"
  c.*
  FROM code_value c,
   (dummyt d  WITH seq = value(nbr_to_change))
  PLAN (d)
   JOIN (c
   WHERE (c.code_value=request->qual[d.seq].code_value))
  DETAIL
   cur_updt_cnt[d.seq] = c.updt_cnt
  WITH nocounter, forupdate(c)
 ;end select
 FOR (x = 1 TO nbr_to_change)
   IF ((cur_updt_cnt[x] != request->qual[x].updt_cnt))
    CALL handle_errors("LOCK","F","TABLE","CODE_VALUE")
    IF (error_cnt > 1)
     SET stat = alter(reply->exception_data,error_cnt)
    ENDIF
    SET reply->exception_data[error_cnt].code_value = request->qual[x].code_value
    SET request->qual[x].code_value = 0
    SET nbr_good_changes = (nbr_good_changes - 1)
   ENDIF
 ENDFOR
 UPDATE  FROM code_value c,
   (dummyt d  WITH seq = value(nbr_to_change))
  SET c.code_set = request->qual[d.seq].code_set, c.display = request->qual[d.seq].display, c
   .display_key = cnvtupper(cnvtalphanum(request->qual[d.seq].display)),
   c.description = request->qual[d.seq].description, c.collation_seq = request->qual[d.seq].
   collation_seq, c.cdf_meaning =
   IF (trim(request->qual[d.seq].cdf_meaning)="") c.cdf_meaning
   ELSE request->qual[d.seq].cdf_meaning
   ENDIF
   ,
   c.active_ind = request->qual[d.seq].active_ind, c.active_type_cd =
   IF ((request->qual[d.seq].active_ind=1)) reqdata->active_status_cd
   ELSE reqdata->inactive_status_cd
   ENDIF
   , c.updt_dt_tm = cnvtdatetime(curdate,curtime),
   c.updt_id = reqinfo->updt_id, c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->
   updt_applctx,
   c.updt_cnt = (request->qual[d.seq].updt_cnt+ 1)
  PLAN (d)
   JOIN (c
   WHERE (c.code_value=request->qual[d.seq].code_value))
  WITH nocounter, request->qual[d.seq].code_value
 ;end update
 IF (curqual != nbr_good_changes)
  SET failed = "T"
  CALL handle_errors("UPDATE","F","TABLE","CODE_VALUE")
 ENDIF
#exit_script
 IF (failed="F")
  IF (nbr_to_change != nbr_good_changes)
   SET reply->status_data.status = "P"
  ELSE
   SET reply->status_data.status = "S"
  ENDIF
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 SUBROUTINE handle_errors(op_name,op_status,tar_name,tar_value)
   SET error_cnt = (error_cnt+ 1)
   IF (error_cnt > 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[error_cnt].operationname = op_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = op_status
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = tar_name
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = tar_value
 END ;Subroutine
END GO
