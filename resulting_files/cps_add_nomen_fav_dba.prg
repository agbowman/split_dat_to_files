CREATE PROGRAM cps_add_nomen_fav:dba
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
    1 category_name = vc
    1 nomen_category_id = f8
    1 nomen_cat_list_id = f8
    1 nomenclature_id = f8
    1 parent_category_id = f8
    1 child_category_id = f8
    1 child_flag = i2
    1 source_string = vc
    1 string_identifier = vc
    1 source_identifier = vc
    1 concept_identifier = vc
    1 concept_source_cd = f8
    1 source_vocabulary_cd = f8
    1 string_source_cd = f8
    1 principle_type_cd = f8
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE category_id = f8 WITH protect, noconstant(0.0)
 DECLARE nomen_cat_list_id = f8 WITH protect, noconstant(0.0)
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET table_name = "NOMEN_CATEGORY"
 SET list = 0
 IF ((request->parent_category_id != 0))
  CALL add_to_nomen_list_table(request->parent_category_id,request->child_category_id,request->
   child_flag,request->nomenclature_id)
 ELSE
  CALL add_to_nomen_category_table(request->category_name)
 ENDIF
 GO TO exit_script
 SUBROUTINE add_to_nomen_category_table(name)
   SELECT INTO "nl:"
    nc.category_name
    FROM nomen_category nc
    PLAN (nc
     WHERE cnvtupper(nc.category_name)=cnvtupper(name))
    WITH nocounter, maxqual(nc,1)
   ;end select
   IF (curqual != 0)
    SET failed = attribute_error
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    nextseqnum = seq(nomenclature_seq,nextval)
    FROM dual
    DETAIL
     category_id = nextseqnum
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET failed = gen_nbr_error
    GO TO exit_script
   ENDIF
   INSERT  FROM nomen_category nc
    SET nc.nomen_category_id = category_id, nc.category_name =
     IF ((request->category_name > " ")) request->category_name
     ELSE " "
     ENDIF
     , nc.updt_dt_tm = cnvtdatetime(sysdate),
     nc.updt_id = reqinfo->updt_id, nc.updt_task = reqinfo->updt_task, nc.updt_applctx = reqinfo->
     updt_applctx,
     nc.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual != 1)
    SET failed = insert_error
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE add_to_nomen_list_table(parent_id,child_id,child_flag,nomen_id)
   SET table_name = "NOMEN_CAT_LIST"
   SELECT INTO "nl:"
    nextseqnum = seq(nomenclature_seq,nextval)
    FROM dual
    DETAIL
     nomen_cat_list_id = nextseqnum
    WITH nocounter
   ;end select
   IF (curqual=0)
    SET failed = gen_nbr_error
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    nc.list_sequence
    FROM nomen_cat_list nc
    WHERE nc.parent_category_id=parent_id
    ORDER BY nc.list_sequence DESC
    HEAD REPORT
     list = nc.list_sequence
    WITH nocounter
   ;end select
   INSERT  FROM nomen_cat_list ncl
    SET ncl.nomen_cat_list_id = nomen_cat_list_id, ncl.nomenclature_id = nomen_id, ncl
     .parent_category_id = parent_id,
     ncl.child_category_id = child_id, ncl.child_flag = child_flag, ncl.list_sequence = (list+ 1),
     ncl.updt_dt_tm = cnvtdatetime(sysdate), ncl.updt_id = reqinfo->updt_id, ncl.updt_task = reqinfo
     ->updt_task,
     ncl.updt_applctx = reqinfo->updt_applctx, ncl.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual != 1)
    SET failed = insert_error
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
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
 SET reply->category_name = request->category_name
 SET reply->nomen_category_id = category_id
 SET reply->nomen_cat_list_id = nomen_cat_list_id
 SET reply->nomenclature_id = request->nomenclature_id
 SET reply->parent_category_id = request->parent_category_id
 SET reply->child_category_id = request->child_category_id
 SET reply->child_flag = request->child_flag
 SET reply->source_string = fillstring(255," ")
 SET reply->string_identifier = fillstring(18," ")
 SET reply->source_identifier = fillstring(50," ")
 SET reply->concept_identifier = fillstring(18," ")
 SET reply->concept_source_cd = 0
 SET reply->source_vocabulary_cd = 0
 SET reply->string_source_cd = 0
 SET reply->principle_type_cd = 0
 IF ((request->child_flag=2)
  AND (request->nomenclature_id != 0))
  SELECT INTO "nl:"
   n.nomenclature_id
   FROM nomenclature n
   PLAN (n
    WHERE (n.nomenclature_id=request->nomenclature_id))
   DETAIL
    reply->source_string = n.source_string, reply->string_identifier = n.string_identifier, reply->
    source_identifier = n.source_identifier,
    reply->concept_identifier = n.concept_identifier, reply->concept_source_cd = n.concept_source_cd,
    reply->source_vocabulary_cd = n.source_vocabulary_cd,
    reply->string_source_cd = n.string_source_cd, reply->principle_type_cd = n.principle_type_cd
   WITH nocounter, maxqual(n,1)
  ;end select
 ENDIF
 SET last_mod = "004"
 SET mod_date = "June 6, 2005"
END GO
