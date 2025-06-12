CREATE PROGRAM aps_chg_folder_role:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET failed = "F"
 SET reply->status_data.status = "F"
 SET updt_cnt = 0
 SET permission_bitmap = 0.0
 SET default_cnt = 0
 SET anonymous_cnt = 0
 SET proxy_cnt = 0
 SELECT INTO "nl:"
  afr.role_id
  FROM ap_folder_role afr
  WHERE (afr.role_id=request->role_id)
  DETAIL
   updt_cnt = afr.updt_cnt, permission_bitmap = afr.permission_bitmap
  WITH nocounter, forupdate(afr)
 ;end select
 IF (curqual != 1)
  GO TO afr_sel_failed
 ENDIF
 IF ((request->updt_cnt != updt_cnt))
  GO TO afr_cnt_failed
 ENDIF
 UPDATE  FROM ap_folder_role afr
  SET afr.role_name = request->role_name, afr.role_name_key = cnvtupper(request->role_name), afr
   .permission_bitmap = request->permission_bitmap,
   afr.updt_dt_tm = cnvtdatetime(curdate,curtime3), afr.updt_id = reqinfo->updt_id, afr.updt_task =
   reqinfo->updt_task,
   afr.updt_applctx = reqinfo->updt_applctx, afr.updt_cnt = (request->updt_cnt+ 1)
  WHERE (afr.role_id=request->role_id)
   AND afr.role_id != 0.0
  WITH nocounter
 ;end update
 IF (curqual != 1)
  GO TO afr_upd_failed
 ENDIF
 SELECT INTO "nl:"
  afp.folder_id
  FROM ap_folder_proxy afp
  WHERE afp.permission_bitmap=permission_bitmap
  DETAIL
   proxy_cnt = (proxy_cnt+ 1)
  WITH nocounter, forupdate(afp)
 ;end select
 UPDATE  FROM ap_folder_proxy afp
  SET afp.permission_bitmap = request->permission_bitmap, afp.updt_dt_tm = cnvtdatetime(curdate,
    curtime3), afp.updt_id = reqinfo->updt_id,
   afp.updt_task = reqinfo->updt_task, afp.updt_applctx = reqinfo->updt_applctx, afp.updt_cnt = (afp
   .updt_cnt+ 1)
  WHERE afp.permission_bitmap=permission_bitmap
  WITH nocounter
 ;end update
 IF (curqual != proxy_cnt)
  GO TO afp_upd_failed
 ENDIF
 SELECT INTO "nl:"
  af.folder_id
  FROM ap_folder af
  WHERE af.default_bitmap=permission_bitmap
  DETAIL
   default_cnt = (default_cnt+ 1)
  WITH nocounter, forupdate(af)
 ;end select
 UPDATE  FROM ap_folder af
  SET af.default_bitmap = request->permission_bitmap, af.updt_dt_tm = cnvtdatetime(curdate,curtime3),
   af.updt_id = reqinfo->updt_id,
   af.updt_task = reqinfo->updt_task, af.updt_applctx = reqinfo->updt_applctx, af.updt_cnt = (request
   ->updt_cnt+ 1)
  WHERE af.default_bitmap=permission_bitmap
  WITH nocounter
 ;end update
 IF (curqual != default_cnt)
  GO TO af_upd_failed
 ENDIF
 SELECT INTO "nl:"
  af.folder_id
  FROM ap_folder af
  WHERE af.anonymous_bitmap=permission_bitmap
  DETAIL
   anonymous_cnt = (anonymous_cnt+ 1)
  WITH nocounter, forupdate(af)
 ;end select
 UPDATE  FROM ap_folder af
  SET af.anonymous_bitmap = request->permission_bitmap, af.updt_dt_tm = cnvtdatetime(curdate,curtime3
    ), af.updt_id = reqinfo->updt_id,
   af.updt_task = reqinfo->updt_task, af.updt_applctx = reqinfo->updt_applctx, af.updt_cnt = (request
   ->updt_cnt+ 1)
  WHERE af.anonymous_bitmap=permission_bitmap
  WITH nocounter
 ;end update
 IF (curqual != anonymous_cnt)
  GO TO af_upd_failed
 ENDIF
 GO TO exit_script
#afr_sel_failed
 SET reply->status_data.subeventstatus[1].operationname = "LOCK"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_FOLDER_ROLE"
 SET failed = "T"
 GO TO exit_script
#afr_upd_failed
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_FOLDER_ROLE"
 SET failed = "T"
 GO TO exit_script
#afr_cnt_failed
 SET reply->status_data.subeventstatus[1].operationname = "VERIFYCHG"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_FOLDER_ROLE"
 SET failed = "T"
 GO TO exit_script
#afp_upd_failed
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_FOLDER_PROXY"
 SET failed = "T"
 GO TO exit_script
#af_upd_failed
 SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
 SET reply->status_data.subeventstatus[1].operationstatus = "F"
 SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
 SET reply->status_data.subeventstatus[1].targetobjectvalue = "AP_FOLDER"
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
