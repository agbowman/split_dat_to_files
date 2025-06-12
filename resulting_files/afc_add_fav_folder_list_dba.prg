CREATE PROGRAM afc_add_fav_folder_list:dba
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
 SET active_code = 0.0
 SELECT INTO "nl:"
  FROM code_value c
  WHERE c.code_set=48
   AND c.cdf_meaning="ACTIVE"
  DETAIL
   active_code = c.code_value
  WITH nocounter
 ;end select
 SET table_name = "FAV_FOLDER_LIST"
 CALL add_fav_folder_list(action_begin,action_end)
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
 SUBROUTINE add_fav_folder_list(add_begin,add_end)
   FOR (x = add_begin TO add_end)
     SET blank_date = cnvtdatetime("01-JAN-1800 00:00:00.00")
     SET found = 0
     SELECT INTO "nl:"
      FROM fav_folder_list l
      WHERE (l.fav_folder_cat_id=request->fav_folder_list[x].fav_folder_cat_id)
       AND l.list_type=2
       AND (l.bill_item_id=request->fav_folder_list[x].bill_item_id)
       AND l.active_ind=1
      DETAIL
       found = 1
      WITH nocounter
     ;end select
     IF (found=0)
      SET new_nbr = 0.0
      SELECT INTO "nl:"
       y = seq(fav_folder_cat_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        new_nbr = cnvtreal(y)
       WITH format, counter
      ;end select
      IF (curqual=0)
       SET failed = gen_nbr_error
       RETURN
      ELSE
       SET request->fav_folder_list[x].fav_folder_list_id = new_nbr
      ENDIF
      INSERT  FROM fav_folder_list f
       SET f.fav_folder_list_id = new_nbr, f.fav_folder_cat_id =
        IF ((request->fav_folder_list[x].fav_folder_cat_id <= 0)) 0
        ELSE request->fav_folder_list[x].fav_folder_cat_id
        ENDIF
        , f.list_type =
        IF ((request->fav_folder_list[x].list_type=0)) 0
        ELSE request->fav_folder_list[x].list_type
        ENDIF
        ,
        f.child_fav_folder_cat_id =
        IF ((request->fav_folder_list[x].child_fav_folder_cat_id <= 0)) 0
        ELSE request->fav_folder_list[x].child_fav_folder_cat_id
        ENDIF
        , f.bill_item_id =
        IF ((request->fav_folder_list[x].bill_item_id <= 0)) 0
        ELSE request->fav_folder_list[x].bill_item_id
        ENDIF
        , f.active_ind = 1,
        f.active_status_cd = active_code, f.active_status_prsnl_id = reqinfo->updt_id, f
        .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
        f.updt_cnt = 0, f.updt_dt_tm = cnvtdatetime(curdate,curtime3), f.updt_id = reqinfo->updt_id,
        f.updt_applctx = reqinfo->updt_applctx, f.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
      IF (curqual=0)
       SET failed = insert_error
       RETURN
      ELSE
       SET stat = alterlist(reply->fav_folder_list,x)
       SET reply->fav_folder_list[x].fav_folder_list_id = request->fav_folder_list[x].
       fav_folder_list_id
      ENDIF
      IF ((request->fav_folder_list[x].bill_item_id IN (0, null)))
       UPDATE  FROM fav_folder_cat c
        SET c.child_cat_ind = 1, c.updt_dt_tm = cnvtdatetime(curdate,curtime3), c.updt_id = reqinfo->
         updt_id,
         c.updt_cnt = (c.updt_cnt+ 1), c.updt_task = reqinfo->updt_task, c.updt_applctx = reqinfo->
         updt_applctx
        WHERE (c.fav_folder_cat_id=request->fav_folder_list[x].fav_folder_cat_id)
        WITH nocounter
       ;end update
      ENDIF
     ENDIF
   ENDFOR
 END ;Subroutine
#end_program
END GO
