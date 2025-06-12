CREATE PROGRAM bed_ens_rel_nomen_cat:dba
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
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
 SET new_id = 0.0
 SET rel_cnt = size(request->rel_list,5)
 FOR (x = 1 TO rel_cnt)
   IF ((request->rel_list[x].action_flag=1))
    SET new_id = 0.0
    SELECT INTO "NL:"
     j = seq(nomenclature_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_id = cnvtreal(j)
     WITH format, counter
    ;end select
    INSERT  FROM nomen_cat_list nl
     SET nl.nomen_cat_list_id = new_id, nl.parent_category_id = request->rel_list[x].nomen_cat_id, nl
      .nomenclature_id = request->rel_list[x].nomenclature_id,
      nl.list_sequence = request->rel_list[x].sequence, nl.child_category_id = 0.0, nl.child_flag = 2,
      nl.updt_dt_tm = cnvtdatetime(curdate,curtime3), nl.updt_id = reqinfo->updt_id, nl.updt_task =
      reqinfo->updt_task,
      nl.updt_cnt = 1, nl.updt_applctx = reqinfo->updt_applctx
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to insert nomen_cat_id = ",cnvtstring(request->rel_list[x].
       nomen_cat_id)," nomenclature_id = ",cnvtstring(request->rel_list[x].nomenclature_id),
      " into nomen_cat_list table.")
     GO TO exit_script
    ENDIF
   ELSEIF ((request->rel_list[x].action_flag=2))
    UPDATE  FROM nomen_cat_list nl
     SET nl.list_sequence = request->rel_list[x].sequence, nl.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), nl.updt_id = reqinfo->updt_id,
      nl.updt_task = reqinfo->updt_task, nl.updt_cnt = (nl.updt_cnt+ 1), nl.updt_applctx = reqinfo->
      updt_applctx
     WHERE (nl.parent_category_id=request->rel_list[x].nomen_cat_id)
      AND (nl.nomenclature_id=request->rel_list[x].nomenclature_id)
     WITH nocounter
    ;end update
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to update nomen_cat_id = ",cnvtstring(request->rel_list[x].
       nomen_cat_id)," nomenclature_id = ",cnvtstring(request->rel_list[x].nomenclature_id),
      " into nomen_cat_list table.")
     GO TO exit_script
    ENDIF
   ELSEIF ((request->rel_list[x].action_flag=3))
    DELETE  FROM nomen_cat_list nl
     WHERE (nl.parent_category_id=request->rel_list[x].nomen_cat_id)
      AND (nl.nomenclature_id=request->rel_list[x].nomenclature_id)
     WITH nocounter
    ;end delete
    IF (curqual=0)
     SET error_flag = "Y"
     SET error_msg = concat("Unable to delete nomen_cat_id = ",cnvtstring(request->rel_list[x].
       nomen_cat_id)," nomenclature_id = ",cnvtstring(request->rel_list[x].nomenclature_id),
      " into nomen_cat_list table.")
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_REL_NOMEN_CAT","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
