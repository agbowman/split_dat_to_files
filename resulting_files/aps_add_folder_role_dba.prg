CREATE PROGRAM aps_add_folder_role:dba
 IF (validate(reply->status_data.status,null)=null)
  RECORD reply(
    1 role_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
#script
 SET failed = "F"
 SET reply->status_data.status = "F"
 DECLARE role_id = f8 WITH protect, noconstant(0.0)
 SELECT INTO "nl:"
  seq_nbr = seq(pathnet_seq,nextval)
  FROM dual
  DETAIL
   role_id = seq_nbr, reply->role_id = role_id
  WITH format, counter
 ;end select
 IF (curqual=0)
  GO TO seq_failed
 ENDIF
 INSERT  FROM ap_folder_role afr
  SET afr.role_id = role_id, afr.role_name = request->role_name, afr.role_name_key = cnvtupper(
    request->role_name),
   afr.permission_bitmap = request->permission_bitmap, afr.updt_dt_tm = cnvtdatetime(curdate,curtime3
    ), afr.updt_id = reqinfo->updt_id,
   afr.updt_task = reqinfo->updt_task, afr.updt_applctx = reqinfo->updt_applctx, afr.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual != 1)
  GO TO afr_ins_failed
 ENDIF
 GO TO exit_script
#seq_failed
 SET reply->status_data.subeventstatus[1].operationname = "nextval"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "seq"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "reference_seq"
 SET failed = "T"
 GO TO exit_script
#afr_ins_failed
 SET reply->status_data.subeventstatus[1].operationname = "INSERT"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_FOLDER_ROLE"
 SET failed = "T"
 GO TO exit_script
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
