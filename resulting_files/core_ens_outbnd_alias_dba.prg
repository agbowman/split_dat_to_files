CREATE PROGRAM core_ens_outbnd_alias:dba
 FREE RECORD reply
 RECORD reply(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE insert_outbnd_alias(aidx=i4) = null
 DECLARE update_outbnd_alias(aidx=i4) = null
 DECLARE delete_outbnd_alias(aidx=i4) = null
 DECLARE create_message(action=i2,contributor=f8,code=f8) = null
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE req_cnt = i4 WITH public, noconstant(size(request->outbnd_alias_list,5))
 DECLARE xvar = i4 WITH public, noconstant(0)
 DECLARE errmsg = c132 WITH public, noconstant(fillstring(132," "))
 DECLARE error_text = vc WITH public, noconstant(" ")
 DECLARE alias_type_meaning = vc WITH public, noconstant(" ")
 DECLARE old_alias_type_meaning = vc WITH public, noconstant(" ")
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->qual,req_cnt)
 FOR (xvar = 1 TO req_cnt)
   IF (cnvtlower(request->outbnd_alias_list[xvar].alias)="<sp>")
    SET request->outbnd_alias_list[xvar].alias = " "
   ENDIF
   IF ((request->outbnd_alias_list[xvar].alias_type_meaning > " "))
    SET alias_type_meaning = trim(cnvtupper(substring(1,12,request->outbnd_alias_list[xvar].
       alias_type_meaning)))
   ELSE
    SET alias_type_meaning = " "
   ENDIF
   IF ((request->outbnd_alias_list[xvar].old_alias_type_meaning > " "))
    SET old_alias_type_meaning = trim(cnvtupper(substring(1,12,request->outbnd_alias_list[xvar].
       old_alias_type_meaning)))
   ELSE
    SET old_alias_type_meaning = " "
   ENDIF
   CASE (request->outbnd_alias_list[xvar].action_type_flag)
    OF 1:
     CALL insert_outbnd_alias(xvar)
    OF 2:
     CALL update_outbnd_alias(xvar)
    OF 3:
     CALL delete_outbnd_alias(xvar)
    ELSE
     SET failed = "T"
     SET stat = alterlist(reply->qual,xvar)
     SET reply->qual[xvar].status = 0
     SET reply->qual[xvar].error_msg = build("Could not recognize"," action_type_flag:",request->
      outbnd_alias_list[xvar].action_type_flag,".")
     GO TO exit_script
   ENDCASE
 ENDFOR
 GO TO exit_script
 SUBROUTINE insert_outbnd_alias(aidx)
   SELECT INTO "nl:"
    cvo.contributor_source_cd, cvo.alias, cvo.code_set
    FROM code_value_outbound cvo
    PLAN (cvo
     WHERE (cvo.contributor_source_cd=request->outbnd_alias_list[aidx].contributor_source_cd)
      AND (cvo.code_value=request->outbnd_alias_list[aidx].code_value)
      AND cvo.alias_type_meaning=alias_type_meaning)
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET failed = "T"
    SET stat = alterlist(reply->qual,aidx)
    SET reply->qual[aidx].status = 0
    CALL create_message(request->outbnd_alias_list[aidx].action_type_flag,request->outbnd_alias_list[
     aidx].contributor_source_cd,request->outbnd_alias_list[aidx].code_value,request->
     outbnd_alias_list[aidx].alias_type_meaning)
    SET reply->qual[aidx].error_msg = error_text
    GO TO exit_script
   ENDIF
   INSERT  FROM code_value_outbound cvo
    SET cvo.alias = request->outbnd_alias_list[aidx].alias, cvo.alias_type_meaning =
     alias_type_meaning, cvo.contributor_source_cd = request->outbnd_alias_list[aidx].
     contributor_source_cd,
     cvo.code_value = request->outbnd_alias_list[aidx].code_value, cvo.code_set = request->
     outbnd_alias_list[aidx].code_set, cvo.updt_dt_tm = cnvtdatetime(curdate,curtime3),
     cvo.updt_id = reqinfo->updt_id, cvo.updt_cnt = 0, cvo.updt_task = reqinfo->updt_task,
     cvo.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   SET reply->curqual = (reply->curqual+ curqual)
   SET errorcode = error(errmsg,0)
   IF (errorcode != 0)
    SET reply->qual[aidx].status = 0
    SET reply->qual[aidx].error_num = errorcode
    SET reply->qual[aidx].error_msg = errmsg
    SET reply->status_data.status = "F"
   ELSE
    SET reply->qual[aidx].status = curqual
    SET reply->qual[aidx].error_num = 0
    SET reply->qual[aidx].error_msg = ""
    SET reply->status_data.status = "S"
   ENDIF
   IF ((reply->status_data.status="F"))
    SET failed = "T"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE update_outbnd_alias(aidx)
   SELECT INTO "nl:"
    cvo.contributor_source_cd, cvo.code_value
    FROM code_value_outbound cvo
    PLAN (cvo
     WHERE (cvo.contributor_source_cd=request->outbnd_alias_list[aidx].old_contributor_source_cd)
      AND (cvo.code_value=request->outbnd_alias_list[aidx].code_value)
      AND cvo.alias_type_meaning=old_alias_type_meaning)
    WITH nocounter
   ;end select
   IF (curqual <= 0)
    SET failed = "T"
    SET stat = alterlist(reply->qual,aidx)
    SET reply->qual[aidx].status = 0
    CALL create_message(request->outbnd_alias_list[aidx].action_type_flag,request->outbnd_alias_list[
     aidx].old_contributor_source_cd,request->outbnd_alias_list[aidx].code_value,request->
     outbnd_alias_list[aidx].old_alias_type_meaning)
    SET reply->qual[aidx].error_msg = error_text
    GO TO exit_script
   ENDIF
   IF ((request->outbnd_alias_list[aidx].contributor_source_cd != request->outbnd_alias_list[aidx].
   old_contributor_source_cd))
    SELECT INTO "nl:"
     cvo.contributor_source_cd, cvo.alias, cvo.code_set
     FROM code_value_outbound cvo
     PLAN (cvo
      WHERE (cvo.contributor_source_cd=request->outbnd_alias_list[aidx].contributor_source_cd)
       AND (cvo.code_value=request->outbnd_alias_list[aidx].code_value)
       AND cvo.alias_type_meaning=alias_type_meaning)
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET failed = "T"
     SET stat = alterlist(reply->qual,aidx)
     SET reply->qual[aidx].status = 0
     CALL create_message(1,request->outbnd_alias_list[aidx].contributor_source_cd,request->
      outbnd_alias_list[aidx].code_value,request->outbnd_alias_list[aidx].alias_type_meaning)
     SET reply->qual[aidx].error_msg = error_text
     GO TO exit_script
    ENDIF
   ENDIF
   UPDATE  FROM code_value_outbound cvo
    SET cvo.alias = request->outbnd_alias_list[aidx].alias, cvo.alias_type_meaning =
     alias_type_meaning, cvo.contributor_source_cd = request->outbnd_alias_list[aidx].
     contributor_source_cd,
     cvo.updt_dt_tm = cnvtdatetime(curdate,curtime3), cvo.updt_id = reqinfo->updt_id, cvo.updt_cnt =
     (cvo.updt_cnt+ 1),
     cvo.updt_task = reqinfo->updt_task, cvo.updt_applctx = reqinfo->updt_applctx
    PLAN (cvo
     WHERE (cvo.contributor_source_cd=request->outbnd_alias_list[aidx].old_contributor_source_cd)
      AND (cvo.code_value=request->outbnd_alias_list[aidx].code_value)
      AND cvo.alias_type_meaning=old_alias_type_meaning)
    WITH nocounter
   ;end update
   SET reply->curqual = (reply->curqual+ curqual)
   SET errorcode = error(errmsg,0)
   IF (errorcode != 0)
    SET reply->qual[aidx].status = 0
    SET reply->qual[aidx].error_num = errorcode
    SET reply->qual[aidx].error_msg = errmsg
    SET reply->status_data.status = "F"
   ELSE
    SET reply->qual[aidx].status = curqual
    SET reply->qual[aidx].error_num = 0
    SET reply->qual[aidx].error_msg = ""
    SET reply->status_data.status = "S"
   ENDIF
   IF ((reply->status_data.status="F"))
    SET failed = "T"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE delete_outbnd_alias(aidx)
   SELECT INTO "nl:"
    cvo.contributor_source_cd, cvo.code_value, cvo.alias_type_meaning
    FROM code_value_outbound cvo
    PLAN (cvo
     WHERE (cvo.contributor_source_cd=request->outbnd_alias_list[aidx].contributor_source_cd)
      AND (cvo.code_value=request->outbnd_alias_list[aidx].code_value)
      AND cvo.alias_type_meaning=alias_type_meaning)
    WITH nocounter
   ;end select
   IF (curqual <= 0)
    SET failed = "T"
    SET stat = alterlist(reply->qual,aidx)
    SET reply->qual[aidx].status = 0
    CALL create_message(request->outbnd_alias_list[aidx].action_type_flag,request->outbnd_alias_list[
     aidx].contributor_source_cd,request->outbnd_alias_list[aidx].code_value,request->
     outbnd_alias_list[aidx].alias_type_meaning)
    SET reply->qual[aidx].error_msg = error_text
    GO TO exit_script
   ENDIF
   DELETE  FROM code_value_outbound cvo
    WHERE (cvo.contributor_source_cd=request->outbnd_alias_list[aidx].contributor_source_cd)
     AND (cvo.code_value=request->outbnd_alias_list[aidx].code_value)
     AND cvo.alias_type_meaning=alias_type_meaning
    WITH nocounter
   ;end delete
   SET reply->curqual = (reply->curqual+ curqual)
   SET errorcode = error(errmsg,0)
   IF (errorcode != 0)
    SET reply->qual[aidx].status = 0
    SET reply->qual[aidx].error_num = errorcode
    SET reply->qual[aidx].error_msg = errmsg
    SET reply->status_data.status = "F"
   ELSE
    SET reply->qual[aidx].status = curqual
    SET reply->qual[aidx].error_num = 0
    SET reply->qual[aidx].error_msg = ""
    SET reply->status_data.status = "S"
   ENDIF
   IF ((reply->status_data.status="F"))
    SET failed = "T"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE create_message(action,contributor,code,atm)
   SET error_text = ""
   SET contributor_disp = uar_get_code_display(contributor)
   SET code_disp = trim(cnvtstring(code))
   SET atm_disp = trim(atm)
   SET error_text = "The code value alias with contributor source ( "
   SET error_text = concat(error_text,contributor_disp)
   SET error_text = concat(error_text,"), code value (")
   SET error_text = concat(error_text,code_disp)
   SET error_text = concat(error_text,"), and alias type meaning (")
   SET error_text = concat(error_text,atm_disp)
   SET error_text = concat(error_text,") could not be ")
   CASE (action)
    OF 1:
     SET error_text = concat(error_text," inserted because it already exists ")
    OF 2:
     SET error_text = concat(error_text," updated because it does not exist ")
    OF 3:
     SET error_text = concat(error_text," deleted because it does not exist ")
   ENDCASE
   SET error_text = concat(error_text," on the CODE_VALUE_OUTBOUND table.")
   SET error_text = concat(error_text,"  No changes were applied to the database.")
 END ;Subroutine
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 SET script_version = "000 08/10/07 KV011080"
END GO
