CREATE PROGRAM afc_del_fav_folder_cat:dba
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 fav_folder_cat_qual = i2
    1 fav_folder_cat[10]
      2 fav_folder_cat_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET action_begin = 1
  SET action_end = request->fav_folder_cat_qual
  SET reply->fav_folder_cat_qual = request->fav_folder_cat_qual
 ENDIF
 RECORD sub_folders(
   1 sub_folders_qual = i2
   1 sub_folders[*]
     2 fav_folder_cat_id = f8
     2 fav_folder_list_id = f8
 )
 RECORD list_items(
   1 list_items_qual = i2
   1 list_items[*]
     2 fav_folder_list_id = f8
 )
 SET reply->status_data.status = "F"
 SET table_name = "FAV_FOLDER_CAT"
 SET active_code = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=48
   AND c.cdf_meaning="INACTIVE"
  DETAIL
   active_code = c.code_value
  WITH nocounter
 ;end select
 CALL del_fav_folder_cat(action_begin,action_end)
 IF (failed != false)
  GO TO check_error
 ENDIF
 SET count1 = 0
 FOR (actionx = action_begin TO action_end)
   CALL get_fav_sub_folder_cat(request->fav_folder_cat[actionx].fav_folder_cat_id)
 ENDFOR
 CALL del_fav_sub_folders(sub_folders->sub_folders_qual)
 SET count1 = 0
 FOR (actionx = action_begin TO action_end)
   CALL get_fav_list_items(request->fav_folder_cat[actionx].fav_folder_cat_id)
 ENDFOR
 CALL del_fav_list_items(list_items->list_items_qual)
 SET count1 = 0
 FOR (actionx = action_begin TO action_end)
   CALL update_parent_child_cat_ind(request->fav_folder_cat[actionx].fav_folder_cat_id)
 ENDFOR
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
 SUBROUTINE del_fav_folder_cat(del_begin,del_end)
   FOR (x = del_begin TO del_end)
    UPDATE  FROM fav_folder_cat f
     SET f.active_ind = false, f.active_status_cd = active_code, f.active_status_prsnl_id = reqinfo->
      updt_id,
      f.active_status_dt_tm = cnvtdatetime(curdate,curtime3), f.updt_cnt = (f.updt_cnt+ 1), f
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      f.updt_id = reqinfo->updt_id, f.updt_applctx = reqinfo->updt_applctx, f.updt_task = reqinfo->
      updt_task
     WHERE (f.fav_folder_cat_id=request->fav_folder_cat[x].fav_folder_cat_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET failed = update_error
     RETURN
    ELSE
     SET stat = alterlist(reply->fav_folder_cat,x)
     SET reply->fav_folder_cat[x].fav_folder_cat_id = request->fav_folder_cat[x].fav_folder_cat_id
    ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE get_fav_sub_folder_cat(favfoldercatid)
  SELECT INTO "nl:"
   FROM fav_folder_cat c,
    fav_folder_list l
   PLAN (l
    WHERE l.fav_folder_cat_id=favfoldercatid
     AND l.list_type=1
     AND l.bill_item_id=0
     AND l.child_fav_folder_cat_id > 0
     AND l.active_ind=1)
    JOIN (c
    WHERE c.fav_folder_cat_id=l.child_fav_folder_cat_id
     AND c.active_ind=1)
   DETAIL
    count1 = (count1+ 1), stat = alterlist(sub_folders->sub_folders,count1), sub_folders->
    sub_folders[count1].fav_folder_cat_id = c.fav_folder_cat_id,
    sub_folders->sub_folders[count1].fav_folder_list_id = l.fav_folder_list_id
   WITH nocounter
  ;end select
  SET sub_folders->sub_folders_qual = count1
 END ;Subroutine
 SUBROUTINE del_fav_sub_folders(qual)
  FOR (x = 1 TO qual)
    UPDATE  FROM fav_folder_cat c
     SET c.active_ind = false, c.active_status_cd = active_code, c.active_status_prsnl_id = reqinfo->
      updt_id,
      c.active_status_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_cnt = (c.updt_cnt+ 1), c
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      c.updt_id = reqinfo->updt_id, c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->
      updt_task
     WHERE (c.fav_folder_cat_id=sub_folders->sub_folders[x].fav_folder_cat_id)
    ;end update
  ENDFOR
  FOR (x = 1 TO qual)
    UPDATE  FROM fav_folder_list l
     SET l.active_ind = false, l.active_status_cd = active_code, l.active_status_prsnl_id = reqinfo->
      updt_id,
      l.active_status_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_cnt = (l.updt_cnt+ 1), l
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      l.updt_id = reqinfo->updt_id, l.updt_applctx = reqinfo->updt_applctx, l.updt_task = reqinfo->
      updt_task
     WHERE (l.fav_folder_list_id=sub_folders->sub_folders[x].fav_folder_list_id)
    ;end update
  ENDFOR
 END ;Subroutine
 SUBROUTINE get_fav_list_items(favfoldercatid)
   CALL echo("Inside GET_FAV_LIST_ITEMS")
   SELECT INTO "nl:"
    FROM fav_folder_list l
    WHERE l.fav_folder_cat_id=favfoldercatid
     AND l.list_type=2
     AND l.bill_item_id > 0
     AND l.child_fav_folder_cat_id=0
     AND l.active_ind=1
    DETAIL
     count1 = (count1+ 1), stat = alterlist(list_items->list_items,count1), list_items->list_items[
     count1].fav_folder_list_id = l.fav_folder_list_id,
     CALL echo(build("fav_folder_list_id is ",l.fav_folder_list_id))
    WITH nocounter
   ;end select
   SET list_items->list_items_qual = count1
   SELECT INTO "nl:"
    FROM fav_folder_list l
    WHERE l.child_fav_folder_cat_id=favfoldercatid
    DETAIL
     count1 = (count1+ 1), stat = alterlist(list_items->list_items,count1), list_items->list_items[
     count1].fav_folder_list_id = l.fav_folder_list_id,
     CALL echo(build("folder fav_folder_list_id is ",l.fav_folder_list_id))
    WITH nocounter
   ;end select
   SET list_items->list_items_qual = count1
 END ;Subroutine
 SUBROUTINE del_fav_list_items(qual)
  CALL echo("Inside DEL_FAV_LIST_ITEMS")
  FOR (x = 1 TO qual)
   UPDATE  FROM fav_folder_list l
    SET l.active_ind = false, l.active_status_cd = active_code, l.active_status_prsnl_id = reqinfo->
     updt_id,
     l.active_status_dt_tm = cnvtdatetime(curdate,curtime3), l.updt_cnt = (l.updt_cnt+ 1), l
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     l.updt_id = reqinfo->updt_id, l.updt_applctx = reqinfo->updt_applctx, l.updt_task = reqinfo->
     updt_task
    WHERE (l.fav_folder_list_id=list_items->list_items[x].fav_folder_list_id)
   ;end update
   CALL echo(build("DONE UPDATING WHERE LIST_ITEMS->LIST_ITEMS[X]->FAV_FOLDER_LIST_ID IS ",list_items
     ->list_items[x].fav_folder_list_id))
  ENDFOR
 END ;Subroutine
 SUBROUTINE update_parent_child_cat_ind(favfoldercatid)
   CALL echo("Inside UPDATE_PARENT_CHILD_CAT_IND")
   SET parentfavfoldercatid = 0.0
   SELECT INTO "nl:"
    FROM fav_folder_list l,
     fav_folder_cat c
    PLAN (l
     WHERE l.child_fav_folder_cat_id=favfoldercatid)
     JOIN (c
     WHERE c.fav_folder_cat_id=l.fav_folder_cat_id
      AND c.active_ind=1)
    DETAIL
     parentfavfoldercatid = c.fav_folder_cat_id
    WITH nocounter
   ;end select
   CALL echo(build("ParentFavFolderCatID: ",parentfavfoldercatid))
   SET nomoresubfolders = 1
   IF (parentfavfoldercatid > 0)
    SELECT INTO "nl:"
     FROM fav_folder_list l
     WHERE l.fav_folder_cat_id=parentfavfoldercatid
      AND l.list_type=1
      AND l.bill_item_id=0
      AND l.active_ind=1
     DETAIL
      nomoresubfolders = 0,
      CALL echo(build("Found active sub folder: ",l.fav_folder_list_id))
     WITH nocounter
    ;end select
   ENDIF
   CALL echo(build("NoMoreSubFolders: ",nomoresubfolders))
   IF (nomoresubfolders > 0
    AND parentfavfoldercatid > 0)
    UPDATE  FROM fav_folder_cat c
     SET c.child_cat_ind = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->
      updt_id,
      c.updt_cnt = (c.updt_cnt+ 1), c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->
      updt_applctx
     WHERE c.fav_folder_cat_id=parentfavfoldercatid
     WITH nocounter
    ;end update
   ENDIF
 END ;Subroutine
#end_program
END GO
