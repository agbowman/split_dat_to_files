CREATE PROGRAM afc_upt_fav_folder_list:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 fav_folder_list_qual = i2
    1 fav_folder_list[10]
      2 fav_folder_list_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET action_begin = 1
  SET action_end = request->fav_folder_list_qual
  SET reply->fav_folder_list_qual = request->fav_folder_list_qual
 ENDIF
 SET reply->status_data.status = "F"
 SET table_name = "FAV_FOLDER_LIST"
 CALL upt_fav_folder_list(action_begin,action_end)
 IF (failed != false)
  GO TO check_error
 ENDIF
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF replace_error:
    SET reply->status_data.subeventstatus[1].operationname = "REPLACE"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   OF undelete_error:
    SET reply->status_data.subeventstatus[1].operationname = "UNDELETE"
   OF remove_error:
    SET reply->status_data.subeventstatus[1].operationname = "REMOVE"
   OF attribute_error:
    SET reply->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
 ENDIF
 GO TO end_program
 SUBROUTINE upt_fav_folder_list(upt_begin,upt_end)
   FOR (x = upt_begin TO upt_end)
     SET blank_date = cnvtdatetime("01-JAN-1800 00:00:00.00")
     UPDATE  FROM fav_folder_list f
      SET f.fav_folder_cat_id = evaluate(request->fav_folder_list[x].fav_folder_cat_id,0.0,f
        .fav_folder_cat_id,- (1.0),0.0,
        request->fav_folder_list[x].fav_folder_cat_id), f.list_type = evaluate(request->
        fav_folder_list[x].list_type,0,f.list_type,- (1),0.0,
        request->fav_folder_list[x].list_type), f.child_fav_folder_cat_id = evaluate(request->
        fav_folder_list[x].child_fav_folder_cat_id,0.0,f.child_fav_folder_cat_id,- (1.0),0.0,
        request->fav_folder_list[x].child_fav_folder_cat_id),
       f.bill_item_id = evaluate(request->fav_folder_list[x].bill_item_id,0.0,f.bill_item_id,- (1.0),
        0.0,
        request->fav_folder_list[x].bill_item_id), f.updt_cnt = (f.updt_cnt+ 1), f.updt_dt_tm =
       cnvtdatetime(curdate,curtime3),
       f.updt_id = reqinfo->updt_id, f.updt_applctx = reqinfo->updt_applctx, f.updt_task = reqinfo->
       updt_task
      WHERE (f.fav_folder_list_id=request->fav_folder_list[x].fav_folder_list_id)
      WITH nocounter
     ;end update
     IF (curqual=0)
      SET failed = update_error
      RETURN
     ELSE
      SET stat = alterlist(reply->fav_folder_list,x)
      SET reply->fav_folder_list[x].fav_folder_list_id = request->fav_folder_list[x].
      fav_folder_list_id
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
