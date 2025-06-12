CREATE PROGRAM bed_ens_app_category:dba
 RECORD requestin(
   1 list_0[*]
     2 display_group_category = c40
     2 sequence = c2
     2 category = c40
     2 cat_sequence = c2
 )
 FREE SET reply
 RECORD reply(
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET error_flag = "N"
 DECLARE error_msg = vc
 SET cat_cnt = size(requestin->list_0,5)
 FOR (x = 1 TO cat_cnt)
   SET new_id = 0.0
   SELECT INTO "NL:"
    j = seq(reference_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     new_id = cnvtreal(j)
    WITH format, counter
   ;end select
   INSERT  FROM br_app_category bac
    SET bac.active_ind = 1, bac.category_id = new_id, bac.description = requestin->list_0[x].category,
     bac.sequence = cnvtint(requestin->list_0[x].cat_sequence), bac.display_group_desc = requestin->
     list_0[x].display_group_category, bac.display_group_seq = cnvtint(requestin->list_0[x].sequence),
     bac.updt_dt_tm = cnvtdatetime(curdate,curtime3), bac.updt_id = reqinfo->updt_id, bac.updt_task
      = reqinfo->updt_task,
     bac.updt_applctx = reqinfo->updt_applctx, bac.updt_cnt = 0
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET error_msg = concat("Unable to insert application group category ",trim(requestin->list_0[x].
      category)," into the br_app_category table.")
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reply->error_msg = concat("  >> PROGRAM NAME: BED_ENS_APP_CATEGORY","  >> ERROR MSG: ",
   error_msg)
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
