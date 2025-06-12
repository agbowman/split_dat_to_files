CREATE PROGRAM daf_migrator_complete_staged:dba
 IF ((validate(request->environment_id,- (1))=- (1)))
  FREE RECORD request
  RECORD request(
    1 environment_id = f8
    1 list_length = i4
    1 comment_text = vc
    1 obj_list[*]
      2 script_name = vc
      2 script_group = i2
  )
 ENDIF
 RECORD reply(
   1 message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE errcode = i4 WITH public, noconstant(0)
 DECLARE errmsg = vc WITH public
 IF ((request->list_length=0))
  SET reply->status_data.status = "S"
  SET reply->message = "No scripts were provided to commit."
  GO TO exit_script
 ENDIF
 FREE RECORD daterec
 RECORD daterec(
   1 date_list[*]
     2 script_date = dq8
     2 script_name = vc
     2 script_group = i4
 )
 SET stat = alterlist(daterec->date_list,request->list_length)
 FOR (i = 1 TO value(request->list_length))
   SELECT INTO "nl:"
    dp.object_name, dp.group, dp.datestamp,
    dp.timestamp
    FROM dprotect dp
    PLAN (dp
     WHERE dp.object_name=cnvtupper(request->obj_list[i].script_name)
      AND (dp.group=request->obj_list[i].script_group)
      AND dp.object="P")
    DETAIL
     daterec->date_list[i].script_name = request->obj_list[i].script_name, daterec->date_list[i].
     script_group = request->obj_list[i].script_group, daterec->date_list[i].script_date =
     cnvtdatetime(dp.datestamp,cnvttime2(format(dp.timestamp,"######;rp0"),"HHMMSS"))
    WITH nocounter
   ;end select
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    ROLLBACK
    SET reply->status_data.status = "F"
    SET reply->message = concat("Unable to read DPROTECT data:",errmsg)
    GO TO exit_script
   ENDIF
   IF (curqual=0)
    ROLLBACK
    SET reply->status_data.status = "F"
    SET reply->message = concat("Unable to find DPROTECT data for ",request->obj_list[i].script_name)
    GO TO exit_script
   ENDIF
 ENDFOR
 UPDATE  FROM dm_script_migration_stage dsms,
   (dummyt d  WITH seq = value(size(daterec->date_list,5)))
  SET dsms.migration_compile_dt_tm = cnvtdatetime(daterec->date_list[d.seq].script_date), dsms
   .migration_dt_tm = cnvtdatetime(curdate,curtime3), dsms.migration_updt_id = reqinfo->updt_id,
   dsms.active_ind = 0, dsms.updt_applctx = reqinfo->updt_applctx, dsms.updt_cnt = (dsms.updt_cnt+ 1),
   dsms.updt_dt_tm = cnvtdatetime(curdate,curtime3), dsms.updt_id = reqinfo->updt_id, dsms.updt_task
    = reqinfo->updt_task
  PLAN (d)
   JOIN (dsms
   WHERE (dsms.target_environment_id=request->environment_id)
    AND (dsms.script_name=daterec->date_list[d.seq].script_name)
    AND (dsms.script_group_nbr=daterec->date_list[d.seq].script_group))
  WITH nocounter
 ;end update
 SET errcode = error(errmsg,1)
 IF (errcode != 0)
  ROLLBACK
  SET reply->status_data.status = "F"
  SET reply->message = concat("Unable to write objects:",errmsg)
  GO TO exit_script
 ENDIF
 COMMIT
 SET reply->status_data.status = "S"
 SET reply->message = "All rows successfully committed."
#exit_script
 FREE RECORD daterec
END GO
