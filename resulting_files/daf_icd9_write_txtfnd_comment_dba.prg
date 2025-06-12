CREATE PROGRAM daf_icd9_write_txtfnd_comment:dba
 RECORD reply(
   1 comment_list[*]
     2 data_id = f8
     2 cat_id = f8
     2 comment_person_name = vc
   1 message = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE catid = f8 WITH public, noconstant(0.0)
 DECLARE errmsg = vc WITH public
 DECLARE errcode = i4 WITH public, noconstant(0)
 DECLARE personname = vc WITH public
 IF (size(request->comment_list,5)=0)
  SET reply->status_data.status = "S"
  SET reply->message = concat("No comment rows were provided to be written.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  dtfc.dm_text_find_cat_id
  FROM dm_text_find_cat dtfc
  WHERE dtfc.find_category="ICD9"
   AND dtfc.active_ind=1
  DETAIL
   catid = dtfc.dm_text_find_cat_id
  WITH nocounter
 ;end select
 IF (catid=0.0)
  SET reply->status_data.status = "F"
  SET reply->message = concat("No category matching ",request->find_category," could be found")
  GO TO exit_script
 ENDIF
 FOR (loopctr = 1 TO size(request->comment_list,5))
   INSERT  FROM dm_text_find_comment dtfc
    SET dtfc.dm_text_find_comment_id = seq(dm_clinical_seq,nextval), dtfc.dm_text_find_data_id =
     request->comment_list[loopctr].data_id, dtfc.dm_text_find_cat_id = catid,
     dtfc.comment_type_flag = request->comment_list[loopctr].comment_type_flag, dtfc
     .comment_state_flag = request->comment_list[loopctr].comment_state_flag, dtfc.data_source =
     request->comment_list[loopctr].data_source,
     dtfc.comment_col_name = request->comment_list[loopctr].comment_col_name, dtfc.comment_col_dt_tm
      = cnvtdatetime(request->comment_list[loopctr].comment_col_dt_tm), dtfc.comment_prsnl_id =
     reqinfo->updt_id,
     dtfc.comment_dt_tm = cnvtdatetime(curdate,curtime3), dtfc.comment_text = request->comment_list[
     loopctr].comment_text, dtfc.updt_applctx = reqinfo->updt_applctx,
     dtfc.updt_cnt = 0, dtfc.updt_dt_tm = cnvtdatetime(curdate,curtime3), dtfc.updt_id = reqinfo->
     updt_id
    WITH nocounter
   ;end insert
   SET errcode = error(errmsg,1)
   IF (errcode != 0)
    SET reply->status_data.status = "F"
    SET reply->message = concat("Failed inserting comment row:",errmsg)
    ROLLBACK
    GO TO exit_script
   ENDIF
   COMMIT
   IF ((reqinfo->updt_id > 0))
    SET personname = ""
    SELECT INTO "nl:"
     p.name_full_formatted
     FROM prsnl p
     WHERE (p.person_id=reqinfo->updt_id)
     DETAIL
      personname = p.name_full_formatted
     WITH nocounter
    ;end select
   ELSE
    SET personname = " "
   ENDIF
   SET stat = alterlist(reply->comment_list,loopctr)
   SET reply->comment_list[loopctr].data_id = request->comment_list[loopctr].data_id
   SET reply->comment_list[loopctr].cat_id = catid
   SET reply->comment_list[loopctr].comment_person_name = personname
 ENDFOR
 SET reply->status_data.status = "S"
 SET reply->message = "All rows written successfully"
#exit_script
END GO
