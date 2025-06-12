CREATE PROGRAM bed_ens_nomen_cat:dba
 FREE SET reply
 RECORD reply(
   1 nlist[*]
     2 nomen_cat_id = f8
     2 nomen_cat_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc
 SET error_flag = "N"
 SET ncnt = size(request->nlist,5)
 SET stat = alterlist(reply->nlist,ncnt)
 FOR (x = 1 TO ncnt)
  SET reply->nlist[x].nomen_cat_name = request->nlist[x].nomen_cat_name
  IF ((request->nlist[x].action_flag=1))
   SET new_id = 0.0
   SELECT INTO "NL:"
    j = seq(nomenclature_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_id = cnvtreal(j)
    WITH format, counter
   ;end select
   SET reply->nlist[x].nomen_cat_id = new_id
   INSERT  FROM nomen_category n
    SET n.nomen_category_id = new_id, n.category_name = request->nlist[x].nomen_cat_name, n
     .category_type_cd = request->nlist[x].category_type_code_value,
     n.parent_entity_id = request->nlist[x].parent_entity_id, n.parent_entity_name = request->nlist[x
     ].parent_entity_name, n.updt_id = reqinfo->updt_id,
     n.updt_task = reqinfo->updt_task, n.updt_cnt = 0, n.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert ",trim(request->nlist[x].nomen_cat_name),
     " into the nomen_category table.")
    GO TO exit_script
   ENDIF
  ELSEIF ((request->nlist[x].action_flag=2))
   UPDATE  FROM nomen_category n
    SET n.category_name = request->nlist[x].nomen_cat_name, n.category_type_cd = request->nlist[x].
     category_type_code_value, n.parent_entity_id = request->nlist[x].parent_entity_id,
     n.parent_entity_name = request->nlist[x].parent_entity_name, n.updt_id = reqinfo->updt_id, n
     .updt_task = reqinfo->updt_task,
     n.updt_cnt = (n.updt_cnt+ 1), n.updt_applctx = reqinfo->updt_applctx
    WHERE (n.nomen_category_id=request->nlist[x].nomen_cat_id)
    WITH nocounter
   ;end update
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to update ",trim(request->nlist[x].nomen_cat_name),
     " into the nomen_category table.")
    GO TO exit_script
   ENDIF
   SET reply->nlist[x].nomen_cat_id = request->nlist[x].nomen_cat_id
  ELSEIF ((request->nlist[x].action_flag=3))
   DELETE  FROM nomen_category n
    WHERE (n.nomen_category_id=request->nlist[x].nomen_cat_id)
    WITH nocounter
   ;end delete
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to delete ",trim(request->nlist[x].nomen_cat_name),
     " into the nomen_category table.")
    GO TO exit_script
   ENDIF
   SET reply->nlist[x].nomen_cat_id = request->nlist[x].nomen_cat_id
  ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_NOMEN_CAT","  >> ERROR MSG: ",error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
