CREATE PROGRAM daf_migrator_write_staged:dba
 IF ((validate(request->environment_id,- (1))=- (1)))
  FREE RECORD request
  RECORD request(
    1 environment_id = f8
    1 list_length = i4
    1 comment_text = vc
    1 obj_list[*]
      2 script_name = vc
      2 script_group = i2
      2 script_date = dq8
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
 FREE RECORD daf_write_scripts
 RECORD daf_write_scripts(
   1 new_list[*]
     2 script_name = vc
     2 script_group = i2
     2 script_date = dq8
     2 stage_id = f8
 )
 SET stat = alterlist(daf_write_scripts->new_list,request->list_length)
 FOR (i = 1 TO request->list_length)
   SET daf_write_scripts->new_list[i].script_name = trim(request->obj_list[i].script_name,3)
   SET daf_write_scripts->new_list[i].script_group = request->obj_list[i].script_group
   SET daf_write_scripts->new_list[i].script_date = request->obj_list[i].script_date
   SELECT INTO "nl:"
    seq_val = seq(dm_ref_seq,nextval)
    FROM dual
    DETAIL
     daf_write_scripts->new_list[i].stage_id = seq_val
    WITH nocounter
   ;end select
 ENDFOR
 INSERT  FROM dm_script_migration_stage dsms,
   (dummyt d  WITH seq = value(request->list_length))
  SET dsms.dm_script_migration_stage_id = daf_write_scripts->new_list[d.seq].stage_id, dsms
   .script_name = daf_write_scripts->new_list[d.seq].script_name, dsms.script_group_nbr =
   daf_write_scripts->new_list[d.seq].script_group,
   dsms.target_environment_id = request->environment_id, dsms.commit_compile_dt_tm = cnvtdatetime(
    daf_write_scripts->new_list[d.seq].script_date), dsms.commit_dt_tm = cnvtdatetime(curdate,
    curtime3),
   dsms.commit_updt_id = reqinfo->updt_id, dsms.active_ind = 1, dsms.comment_text = request->
   comment_text,
   dsms.updt_applctx = reqinfo->updt_applctx, dsms.updt_cnt = 0, dsms.updt_dt_tm = cnvtdatetime(
    curdate,curtime3),
   dsms.updt_id = reqinfo->updt_id, dsms.updt_task = reqinfo->updt_task
  PLAN (d)
   JOIN (dsms)
  WITH nocounter
 ;end insert
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
END GO
