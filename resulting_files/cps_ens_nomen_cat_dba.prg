CREATE PROGRAM cps_ens_nomen_cat:dba
 IF ((validate(false,- (1))=- (1)))
  SET false = 0
 ENDIF
 IF ((validate(true,- (1))=- (1)))
  SET true = 1
 ENDIF
 SET gen_nbr_error = 3
 SET insert_error = 4
 SET update_error = 5
 SET delete_error = 6
 SET select_error = 7
 SET lock_error = 8
 SET input_error = 9
 SET exe_error = 10
 SET failed = false
 SET table_name = fillstring(50," ")
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 SET ierrcode = 0
 SET add = 1
 SET upd = 2
 SET del = 3
 FREE SET reply
 RECORD reply(
   1 qual_knt = i4
   1 qual[*]
     2 action_ind = i2
     2 category_id = f8
     2 category_name = vc
     2 category_type_cd = f8
     2 parent_entity_name = vc
     2 parent_entity_id = f8
     2 success_ind = i2
     2 child_knt = i4
     2 child[*]
       3 action_ind = i2
       3 nomen_cat_list_id = f8
       3 child_category_id = f8
       3 nomenclature_id = f8
       3 list_sequence = i4
       3 success_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET stat = alterlist(reply->qual,request->qual_knt)
 SET reply->qual_knt = request->qual_knt
 IF ((reply->qual_knt < 1))
  SET failed = input_error
  SET table_name = "REQUEST"
  SET serrmsg = "REQUEST->QUAL_KNT must be greater then 0"
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO reply->qual_knt)
   SET reply->qual[i].action_ind = request->qual[i].action_ind
   SET reply->qual[i].category_id = request->qual[i].category_id
   IF ((request->qual[i].category_name > " "))
    SET reply->qual[i].category_name = request->qual[i].category_name
   ELSE
    SET reply->qual[i].category_name = " "
   ENDIF
   SET reply->qual[i].category_type_cd = request->qual[i].category_type_cd
   SET reply->qual[i].parent_entity_name = cnvtupper(request->qual[i].parent_entity_name)
   SET reply->qual[i].parent_entity_id = request->qual[i].parent_entity_id
   SET reply->qual[i].child_knt = request->qual[i].child_knt
   SET stat = alterlist(reply->qual[i].child,reply->qual[i].child_knt)
   IF ((reply->qual[i].action_ind=add))
    SET ierrcode = 0
    SELECT INTO "nl:"
     nextseqnum = seq(nomenclature_seq,nextval)
     FROM dual
     DETAIL
      reply->qual[i].category_id = cnvtreal(nextseqnum)
     WITH format, nocounter
    ;end select
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = gen_nbr_error
     SET table_name = "NOMENCLATURE_SEQ"
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    INSERT  FROM nomen_category nc
     SET nc.nomen_category_id = reply->qual[i].category_id, nc.category_name = reply->qual[i].
      category_name, nc.category_type_cd = reply->qual[i].category_type_cd,
      nc.parent_entity_name = reply->qual[i].parent_entity_name, nc.parent_entity_id = reply->qual[i]
      .parent_entity_id, nc.updt_cnt = 0,
      nc.updt_dt_tm = cnvtdatetime(curdate,curtime3), nc.updt_applctx = reqinfo->updt_applctx, nc
      .updt_id = reqinfo->updt_id,
      nc.updt_task = reqinfo->updt_task
     PLAN (nc
      WHERE 0=0)
     WITH nocounter
    ;end insert
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = insert_error
     SET table_name = "NOMEN_CATEGORY"
     SET reply->qual[i].category_id = - (1)
     GO TO exit_script
    ENDIF
    COMMIT
   ELSEIF ((reply->qual[i].action_ind=upd)
    AND (reply->qual[i].category_id > 0))
    SET ierrcode = 0
    UPDATE  FROM nomen_category nc
     SET nc.category_type_cd = reply->qual[i].category_type_cd, nc.category_name = reply->qual[i].
      category_name, nc.parent_entity_name = reply->qual[i].parent_entity_name,
      nc.parent_entity_id = reply->qual[i].parent_entity_id, nc.updt_cnt = (nc.updt_cnt+ 1), nc
      .updt_dt_tm = cnvtdatetime(curdate,curtime3),
      nc.updt_applctx = reqinfo->updt_applctx, nc.updt_id = reqinfo->updt_id, nc.updt_task = reqinfo
      ->updt_task
     PLAN (nc
      WHERE (nc.nomen_category_id=reply->qual[i].category_id))
     WITH nocounter
    ;end update
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = update_error
     SET table_name = "NOMEN_CATEGORY"
     GO TO exit_script
    ENDIF
    COMMIT
   ELSEIF ((reply->qual[i].action_ind=del)
    AND (reply->qual[i].category_id > 0))
    SET ierrcode = 0
    DELETE  FROM nomen_cat_list ncl
     PLAN (ncl
      WHERE (ncl.child_category_id=reply->qual[i].category_id))
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = delete_error
     SET table_name = "NOMEN_CAT_LIST"
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    DELETE  FROM nomen_cat_list ncl
     PLAN (ncl
      WHERE (ncl.parent_category_id=reply->qual[i].category_id))
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = delete_error
     SET table_name = "NOMEN_CAT_LIST"
     GO TO exit_script
    ENDIF
    SET ierrcode = 0
    DELETE  FROM nomen_category nc
     PLAN (nc
      WHERE (nc.nomen_category_id=reply->qual[i].category_id))
     WITH nocounter
    ;end delete
    SET ierrcode = error(serrmsg,1)
    IF (ierrcode > 0)
     SET failed = delete_error
     SET table_name = "NOMEN_CATEGORY"
     GO TO exit_script
    ENDIF
    COMMIT
   ENDIF
   SET reply->qual[i].success_ind = 1
   IF ((reply->qual[i].child_knt > 0))
    FOR (j = 1 TO reply->qual[i].child_knt)
      SET reply->qual[i].child[j].action_ind = request->qual[i].child[j].action_ind
      SET reply->qual[i].child[j].nomen_cat_list_id = request->qual[i].child[j].nomen_cat_list_id
      SET reply->qual[i].child[j].child_category_id = request->qual[i].child[j].child_category_id
      SET reply->qual[i].child[j].nomenclature_id = request->qual[i].child[j].nomenclature_id
      SET reply->qual[i].child[j].list_sequence = request->qual[i].child[j].list_sequence
      IF ((reply->qual[i].child[j].action_ind=add)
       AND (reply->qual[i].category_id > 0))
       SET ierrcode = 0
       SELECT INTO "nl:"
        nextseqnum = seq(nomenclature_seq,nextval)
        FROM dual
        DETAIL
         reply->qual[i].child[j].nomen_cat_list_id = cnvtreal(nextseqnum)
        WITH format, nocounter
       ;end select
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = gen_nbr_error
        SET table_name = "NOMENCLATURE_SEQ"
        GO TO exit_script
       ENDIF
       SET ierrcode = 0
       INSERT  FROM nomen_cat_list ncl
        SET ncl.nomen_cat_list_id = reply->qual[i].child[j].nomen_cat_list_id, ncl.parent_category_id
          = reply->qual[i].category_id, ncl.child_category_id = reply->qual[i].child[j].
         child_category_id,
         ncl.nomenclature_id = reply->qual[i].child[j].nomenclature_id, ncl.list_sequence = reply->
         qual[i].child[j].list_sequence, ncl.child_flag =
         IF ((reply->qual[i].child[j].child_category_id > 0)) 1
         ELSE 2
         ENDIF
         ,
         ncl.updt_cnt = 0, ncl.updt_dt_tm = cnvtdatetime(curdate,curtime3), ncl.updt_applctx =
         reqinfo->updt_applctx,
         ncl.updt_id = reqinfo->updt_id, ncl.updt_task = reqinfo->updt_task
        PLAN (ncl
         WHERE 0=0)
        WITH nocounter
       ;end insert
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = insert_error
        SET table_name = "NOMEN_CAT_LIST"
        SET reply->qual[i].child[j].nomen_cat_list_id = - (1)
        GO TO exit_script
       ENDIF
       COMMIT
      ELSEIF ((reply->qual[i].child[j].action_ind=upd)
       AND (reply->qual[i].child[j].nomen_cat_list_id > 0))
       SET ierrcode = 0
       UPDATE  FROM nomen_cat_list ncl
        SET ncl.child_category_id = reply->qual[i].child[j].child_category_id, ncl.nomenclature_id =
         reply->qual[i].child[j].nomenclature_id, ncl.list_sequence = reply->qual[i].child[j].
         list_sequence,
         ncl.child_flag =
         IF ((reply->qual[i].child[j].child_category_id > 0)) 1
         ELSE 2
         ENDIF
         , ncl.updt_cnt = (ncl.updt_cnt+ 1), ncl.updt_dt_tm = cnvtdatetime(curdate,curtime3),
         ncl.updt_applctx = reqinfo->updt_applctx, ncl.updt_id = reqinfo->updt_id, ncl.updt_task =
         reqinfo->updt_task
        PLAN (ncl
         WHERE (ncl.nomen_cat_list_id=reply->qual[i].child[j].nomen_cat_list_id))
        WITH nocounter
       ;end update
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = update_error
        SET table_name = "NOMEN_CAT_LIST"
        GO TO exit_script
       ENDIF
       COMMIT
      ELSEIF ((reply->qual[i].child[j].action_ind=del)
       AND (reply->qual[i].child[j].nomen_cat_list_id > 0))
       SET ierrcode = 0
       DELETE  FROM nomen_cat_list ncl
        PLAN (ncl
         WHERE (ncl.nomen_cat_list_id=reply->qual[i].child[j].nomen_cat_list_id))
        WITH nocounter
       ;end delete
       SET ierrcode = error(serrmsg,1)
       IF (ierrcode > 0)
        SET failed = delete_error
        SET table_name = "NOMEN_CAT_LIST"
        GO TO exit_script
       ENDIF
       COMMIT
      ENDIF
      SET reply->qual[i].child[j].success_ind = 1
    ENDFOR
   ENDIF
 ENDFOR
#exit_script
 IF (failed != false)
  ROLLBACK
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
  SET reply->status_data.subeventstatus[1].targetobjectname = table_name
  IF (failed=select_error)
   SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  ELSEIF (failed=insert_error)
   SET reply->status_data.subeventstatus[1].operationname = "INSERT"
  ELSEIF (failed=gen_nbr_error)
   SET reply->status_data.subeventstatus[1].operationname = "GEN_SEQ_NBR"
  ELSEIF (failed=update_error)
   SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
  ELSEIF (failed=input_error)
   SET reply->status_data.subeventstatus[1].operationname = "VALIDATE"
  ELSEIF (failed=lock_error)
   SET reply->status_data.subeventstatus[1].operationname = "LOCK"
  ELSE
   SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDIF
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
