CREATE PROGRAM core_ens_inbnd_alias:dba
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
 DECLARE insert_inbnd_alias(aidx=i4) = null
 DECLARE update_inbnd_alias(aidx=i4) = null
 DECLARE delete_inbnd_alias(aidx=i4) = null
 DECLARE create_message(action=i2,cs_cd=f8,cv=f8,cs=i4,alias=vc) = null
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE req_cnt = i4 WITH public, noconstant(size(request->inbnd_alias_list,5))
 DECLARE xvar = i4 WITH public, noconstant(0)
 DECLARE errmsg = vc WITH public, noconstant(fillstring(132," "))
 DECLARE error_text = vc WITH public, noconstant(" ")
 DECLARE alias_type_meaning = vc WITH public, noconstant(" ")
 DECLARE old_alias_type_meaning = vc WITH public, noconstant(" ")
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->qual,req_cnt)
 FOR (xvar = 1 TO req_cnt)
   IF (cnvtlower(request->inbnd_alias_list[xvar].alias)="<sp>")
    SET request->inbnd_alias_list[xvar].alias = " "
   ENDIF
   IF (cnvtlower(request->inbnd_alias_list[xvar].old_alias)="<sp>")
    SET request->inbnd_alias_list[xvar].old_alias = " "
   ENDIF
   IF ((request->inbnd_alias_list[xvar].alias_type_meaning > " "))
    SET alias_type_meaning = trim(cnvtupper(substring(1,12,request->inbnd_alias_list[xvar].
       alias_type_meaning)))
   ELSE
    SET alias_type_meaning = " "
   ENDIF
   IF ((request->inbnd_alias_list[xvar].old_alias_type_meaning > " "))
    SET old_alias_type_meaning = trim(cnvtupper(substring(1,12,request->inbnd_alias_list[xvar].
       old_alias_type_meaning)))
   ELSE
    SET old_alias_type_meaning = " "
   ENDIF
   CASE (request->inbnd_alias_list[xvar].action_type_flag)
    OF 1:
     CALL insert_inbnd_alias(xvar)
    OF 2:
     CALL update_inbnd_alias(xvar)
    OF 3:
     CALL delete_inbnd_alias(xvar)
    ELSE
     SET failed = "T"
     SET stat = alterlist(reply->qual,xvar)
     SET reply->qual[xvar].status = 0
     SET reply->qual[xvar].error_msg = build("Could not recognize"," action_type_flag:",request->
      inbnd_alias_list[xvar].action_type_flag,".")
     GO TO exit_script
   ENDCASE
 ENDFOR
 GO TO exit_script
 SUBROUTINE insert_inbnd_alias(aidx)
   SELECT INTO "nl:"
    cva.contributor_source_cd, cva.alias, cva.code_set,
    cva.alias_type_meaning
    FROM code_value_alias cva
    PLAN (cva
     WHERE (cva.contributor_source_cd=request->inbnd_alias_list[aidx].contributor_source_cd)
      AND (cva.alias=request->inbnd_alias_list[aidx].alias)
      AND (cva.code_set=request->inbnd_alias_list[aidx].code_set)
      AND cva.alias_type_meaning=alias_type_meaning)
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET failed = "T"
    SET stat = alterlist(reply->qual,aidx)
    SET reply->qual[aidx].status = 0
    CALL create_message(request->inbnd_alias_list[aidx].action_type_flag,request->inbnd_alias_list[
     aidx].contributor_source_cd,request->inbnd_alias_list[aidx].code_value,request->
     inbnd_alias_list[aidx].code_set,request->inbnd_alias_list[aidx].alias,
     request->inbnd_alias_list[aidx].alias_type_meaning)
    SET reply->qual[aidx].error_msg = error_text
    GO TO exit_script
   ENDIF
   INSERT  FROM code_value_alias cva
    SET cva.alias = request->inbnd_alias_list[aidx].alias, cva.alias_type_meaning =
     alias_type_meaning, cva.primary_ind =
     IF ((request->inbnd_alias_list[aidx].primary_ind <= 0)) 0
     ELSE request->inbnd_alias_list[aidx].primary_ind
     ENDIF
     ,
     cva.contributor_source_cd = request->inbnd_alias_list[aidx].contributor_source_cd, cva.code_set
      = request->inbnd_alias_list[aidx].code_set, cva.code_value = request->inbnd_alias_list[aidx].
     code_value,
     cva.updt_dt_tm = cnvtdatetime(curdate,curtime3), cva.updt_id = reqinfo->updt_id, cva.updt_cnt =
     0,
     cva.updt_task = reqinfo->updt_task, cva.updt_applctx = reqinfo->updt_applctx
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
 SUBROUTINE update_inbnd_alias(aidx)
   SELECT INTO "nl:"
    cva.contributor_source_cd, cva.alias, cva.code_set,
    cva.alias_type_meaning
    FROM code_value_alias cva
    PLAN (cva
     WHERE (cva.contributor_source_cd=request->inbnd_alias_list[aidx].old_contributor_source_cd)
      AND (cva.alias=request->inbnd_alias_list[aidx].old_alias)
      AND (cva.code_set=request->inbnd_alias_list[aidx].code_set)
      AND (cva.code_value=request->inbnd_alias_list[aidx].code_value)
      AND cva.alias_type_meaning=old_alias_type_meaning)
    WITH nocounter
   ;end select
   IF (curqual <= 0)
    SET failed = "T"
    SET stat = alterlist(reply->qual,aidx)
    SET reply->qual[aidx].status = 0
    CALL create_message(request->inbnd_alias_list[aidx].action_type_flag,request->inbnd_alias_list[
     aidx].old_contributor_source_cd,request->inbnd_alias_list[aidx].code_value,request->
     inbnd_alias_list[aidx].code_set,request->inbnd_alias_list[aidx].old_alias,
     request->inbnd_alias_list[aidx].old_alias_type_meaning)
    SET reply->qual[aidx].error_msg = error_text
    GO TO exit_script
   ENDIF
   IF ((((request->inbnd_alias_list[aidx].contributor_source_cd != request->inbnd_alias_list[aidx].
   old_contributor_source_cd)) OR ((((request->inbnd_alias_list[aidx].alias != request->
   inbnd_alias_list[aidx].old_alias)) OR ((request->inbnd_alias_list[aidx].alias_type_meaning !=
   request->inbnd_alias_list[aidx].old_alias_type_meaning))) )) )
    SELECT INTO "nl:"
     cva.contributor_source_cd, cva.alias, cva.code_set,
     cva.alias_type_meaning
     FROM code_value_alias cva
     PLAN (cva
      WHERE (cva.contributor_source_cd=request->inbnd_alias_list[aidx].contributor_source_cd)
       AND (cva.alias=request->inbnd_alias_list[aidx].alias)
       AND (cva.code_set=request->inbnd_alias_list[aidx].code_set)
       AND cva.alias_type_meaning=alias_type_meaning)
     WITH nocounter
    ;end select
    IF (curqual > 0)
     SET failed = "T"
     SET stat = alterlist(reply->qual,aidx)
     SET reply->qual[aidx].status = 0
     CALL create_message(1,request->inbnd_alias_list[aidx].contributor_source_cd,request->
      inbnd_alias_list[aidx].code_value,request->inbnd_alias_list[aidx].code_set,request->
      inbnd_alias_list[aidx].alias,
      request->inbnd_alias_list[aidx].alias_type_meaning)
     SET reply->qual[aidx].error_msg = error_text
     GO TO exit_script
    ENDIF
   ENDIF
   UPDATE  FROM code_value_alias cva
    SET cva.alias = request->inbnd_alias_list[aidx].alias, cva.alias_type_meaning =
     alias_type_meaning, cva.primary_ind =
     IF ((request->inbnd_alias_list[aidx].primary_ind <= 0)) 0
     ELSE request->inbnd_alias_list[aidx].primary_ind
     ENDIF
     ,
     cva.contributor_source_cd = request->inbnd_alias_list[aidx].contributor_source_cd, cva
     .updt_dt_tm = cnvtdatetime(curdate,curtime3), cva.updt_id = reqinfo->updt_id,
     cva.updt_cnt = (cva.updt_cnt+ 1), cva.updt_task = reqinfo->updt_task, cva.updt_applctx = reqinfo
     ->updt_applctx
    PLAN (cva
     WHERE (cva.code_set=request->inbnd_alias_list[aidx].code_set)
      AND (cva.contributor_source_cd=request->inbnd_alias_list[aidx].old_contributor_source_cd)
      AND (cva.alias=request->inbnd_alias_list[aidx].old_alias)
      AND (cva.code_value=request->inbnd_alias_list[aidx].code_value)
      AND cva.alias_type_meaning=old_alias_type_meaning)
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
 SUBROUTINE delete_inbnd_alias(aidx)
   SELECT INTO "nl:"
    cva.contributor_source_cd, cva.alias, cva.code_set,
    cva.alias_type_meaning
    FROM code_value_alias cva
    PLAN (cva
     WHERE (cva.contributor_source_cd=request->inbnd_alias_list[aidx].contributor_source_cd)
      AND (cva.alias=request->inbnd_alias_list[aidx].alias)
      AND (cva.code_set=request->inbnd_alias_list[aidx].code_set)
      AND (cva.code_value=request->inbnd_alias_list[aidx].code_value)
      AND cva.alias_type_meaning=alias_type_meaning)
    WITH nocounter
   ;end select
   IF (curqual <= 0)
    SET failed = "T"
    SET stat = alterlist(reply->qual,aidx)
    SET reply->qual[aidx].status = 0
    CALL create_message(request->inbnd_alias_list[aidx].action_type_flag,request->inbnd_alias_list[
     aidx].contributor_source_cd,request->inbnd_alias_list[aidx].code_value,request->
     inbnd_alias_list[aidx].code_set,request->inbnd_alias_list[aidx].alias,
     request->inbnd_alias_list[aidx].alias_type_meaning)
    SET reply->qual[aidx].error_msg = error_text
    GO TO exit_script
   ENDIF
   DELETE  FROM code_value_alias cva
    WHERE (cva.contributor_source_cd=request->inbnd_alias_list[aidx].contributor_source_cd)
     AND (cva.alias=request->inbnd_alias_list[aidx].alias)
     AND (cva.code_set=request->inbnd_alias_list[aidx].code_set)
     AND (cva.code_value=request->inbnd_alias_list[aidx].code_value)
     AND cva.alias_type_meaning=alias_type_meaning
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
 SUBROUTINE create_message(action,cs_cd,cv,cs,alias,atm)
   SET error_text = ""
   SET contributor_disp = uar_get_code_display(cs_cd)
   SET code_value_disp = trim(cnvtstring(cv))
   SET code_set_disp = trim(cnvtstring(cs))
   SET alias_disp = trim(alias)
   SET atm_disp = trim(atm)
   SET error_text = "The code value alias with contributor source ( "
   SET error_text = concat(error_text,contributor_disp)
   SET error_text = concat(error_text,"), code set (")
   SET error_text = concat(error_text,code_set_disp)
   SET error_text = concat(error_text,"), code value (")
   SET error_text = concat(error_text,code_value_disp)
   SET error_text = concat(error_text,"), alias (")
   SET error_text = concat(error_text,alias_disp)
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
   SET error_text = concat(error_text," on the CODE_VALUE_ALIAS table.")
   SET error_text = concat(error_text,"  No changes were applied to the database.")
   CALL echo(error_text)
 END ;Subroutine
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 SET script_version = "002 08/10/07 KV011080"
END GO
