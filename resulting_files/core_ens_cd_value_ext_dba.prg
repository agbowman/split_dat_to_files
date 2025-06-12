CREATE PROGRAM core_ens_cd_value_ext:dba
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
 DECLARE insert_cd_value_ext(aidx=i4) = null
 DECLARE update_cd_value_ext(aidx=i4) = null
 DECLARE delete_cd_value_ext(aidx=i4) = null
 DECLARE create_message(action=i2,code_value=f8,field_name=vc,code_set=i4) = null
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE req_cnt = i4 WITH public, noconstant(size(request->extension_list,5))
 DECLARE xvar = i4 WITH public, noconstant(0)
 DECLARE error_text = vc WITH public, noconstant(" ")
 DECLARE errmsg = c132 WITH public, noconstant(fillstring(132," "))
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->qual,req_cnt)
 FOR (xvar = 1 TO req_cnt)
  IF ((request->extension_list[xvar].action_type_flag=1))
   SELECT INTO "nl:"
    cve.seq
    FROM code_value_extension cve
    PLAN (cve
     WHERE (cve.code_set=request->extension_list[xvar].code_set)
      AND (cve.code_value=request->extension_list[xvar].code_value)
      AND (cve.field_name=request->extension_list[xvar].field_name))
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET request->extension_list[xvar].action_type_flag = 2
   ENDIF
  ENDIF
  CASE (request->extension_list[xvar].action_type_flag)
   OF 1:
    CALL insert_cd_value_ext(xvar)
   OF 2:
    CALL update_cd_value_ext(xvar)
   OF 3:
    CALL delete_cd_value_ext(xvar)
   ELSE
    SET failed = "T"
    SET stat = alterlist(reply->qual,xvar)
    SET reply->qual[xvar].status = 0
    SET reply->qual[xvar].error_msg = build("Could not recognize"," action_type_flag:",request->
     extension_list[xvar].action_type_flag,".")
    GO TO exit_script
  ENDCASE
 ENDFOR
 GO TO exit_script
 SUBROUTINE insert_cd_value_ext(aidx)
   SELECT INTO "nl:"
    cve.seq
    FROM code_value_extension cve
    PLAN (cve
     WHERE (cve.code_set=request->extension_list[aidx].code_set)
      AND (cve.code_value=request->extension_list[aidx].code_value)
      AND (cve.field_name=request->extension_list[aidx].field_name))
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET failed = "T"
    SET stat = alterlist(reply->qual,aidx)
    SET reply->qual[aidx].status = 0
    CALL create_message(request->extension_list[aidx].action_type_flag,request->extension_list[aidx].
     code_value,request->extension_list[aidx].field_name,request->extension_list[aidx].code_set)
    SET reply->qual[aidx].error_msg = error_text
    GO TO exit_script
   ENDIF
   INSERT  FROM code_value_extension cve
    SET cve.code_set = request->extension_list[aidx].code_set, cve.code_value = request->
     extension_list[aidx].code_value, cve.field_name = trim(substring(1,32,request->extension_list[
       aidx].field_name),3),
     cve.field_type =
     IF ((request->extension_list[aidx].field_type <= 0)) 0
     ELSE request->extension_list[aidx].field_type
     ENDIF
     , cve.field_value =
     IF ((request->extension_list[aidx].field_value='""')) null
     ELSE trim(request->extension_list[aidx].field_value,3)
     ENDIF
     , cve.updt_applctx = reqinfo->updt_applctx,
     cve.updt_cnt = 0, cve.updt_dt_tm = cnvtdatetime(curdate,curtime3), cve.updt_id = reqinfo->
     updt_id,
     cve.updt_task = reqinfo->updt_task
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
    SET reply->qual[aidx].status = 1
    SET reply->qual[aidx].error_num = 0
    SET reply->qual[aidx].error_msg = ""
    SET reply->status_data.status = "S"
   ENDIF
   IF ((reply->status_data.status="F"))
    SET failed = "T"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE update_cd_value_ext(aidx)
   SELECT INTO "nl:"
    cve.seq
    FROM code_value_extension cve
    PLAN (cve
     WHERE (cve.code_set=request->extension_list[aidx].code_set)
      AND (cve.code_value=request->extension_list[aidx].code_value)
      AND (cve.field_name=request->extension_list[aidx].field_name))
    WITH nocounter
   ;end select
   IF (curqual <= 0)
    SET failed = "T"
    SET stat = alterlist(reply->qual,aidx)
    SET reply->qual[aidx].status = 0
    CALL create_message(request->extension_list[aidx].action_type_flag,request->extension_list[aidx].
     code_value,request->extension_list[aidx].field_name,request->extension_list[aidx].code_set)
    SET reply->qual[aidx].error_msg = error_text
    GO TO exit_script
   ENDIF
   UPDATE  FROM code_value_extension cve
    SET cve.field_type =
     IF ((request->extension_list[aidx].field_type <= 0)) 0
     ELSE request->extension_list[aidx].field_type
     ENDIF
     , cve.field_value =
     IF ((request->extension_list[aidx].field_value='""')) null
     ELSE trim(request->extension_list[aidx].field_value,3)
     ENDIF
     , cve.updt_applctx = reqinfo->updt_applctx,
     cve.updt_cnt = (cve.updt_cnt+ 1), cve.updt_dt_tm = cnvtdatetime(curdate,curtime3), cve.updt_id
      = reqinfo->updt_id,
     cve.updt_task = reqinfo->updt_task
    WHERE (cve.code_set=request->extension_list[aidx].code_set)
     AND (cve.code_value=request->extension_list[aidx].code_value)
     AND (cve.field_name=request->extension_list[aidx].field_name)
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
    SET reply->qual[aidx].status = 1
    SET reply->qual[aidx].error_num = 0
    SET reply->qual[aidx].error_msg = ""
    SET reply->status_data.status = "S"
   ENDIF
   IF ((reply->status_data.status="F"))
    SET failed = "T"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE delete_cd_value_ext(aidx)
   SELECT INTO "nl:"
    cve.seq
    FROM code_value_extension cve
    PLAN (cve
     WHERE (cve.code_set=request->extension_list[aidx].code_set)
      AND (cve.code_value=request->extension_list[aidx].code_value)
      AND (cve.field_name=request->extension_list[aidx].field_name))
    WITH nocounter
   ;end select
   IF (curqual <= 0)
    SET failed = "T"
    SET stat = alterlist(reply->qual,aidx)
    SET reply->qual[aidx].status = 0
    CALL create_message(request->extension_list[aidx].action_type_flag,request->extension_list[aidx].
     code_value,request->extension_list[aidx].field_name,request->extension_list[aidx].code_set)
    SET reply->qual[aidx].error_msg = error_text
    GO TO exit_script
   ENDIF
   DELETE  FROM code_value_extension cve
    WHERE (cve.code_set=request->extension_list[aidx].code_set)
     AND (cve.code_value=request->extension_list[aidx].code_value)
     AND (cve.field_name=request->extension_list[aidx].field_name)
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
    SET reply->qual[aidx].status = 1
    SET reply->qual[aidx].error_num = 0
    SET reply->qual[aidx].error_msg = ""
    SET reply->status_data.status = "S"
   ENDIF
   IF ((reply->status_data.status="F"))
    SET failed = "T"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE create_message(action,code_value,field_name,code_set)
   SET error_text = ""
   SET code_value_disp = trim(cnvtstring(code_value))
   SET field_name_disp = trim(field_name)
   SET code_set_disp = trim(cnvtstring(code_set))
   SET error_text = "The code value extension with code value ( "
   SET error_text = concat(error_text,code_value_disp)
   SET error_text = concat(error_text,"), code set (")
   SET error_text = concat(error_text,code_set_disp)
   SET error_text = concat(error_text,"), and field name (")
   SET error_text = concat(error_text,field_name_disp)
   SET error_text = concat(error_text,") could not be ")
   CASE (action)
    OF 1:
     SET error_text = concat(error_text," inserted because it already exists ")
    OF 2:
     SET error_text = concat(error_text," updated because it does not exist ")
    OF 3:
     SET error_text = concat(error_text," deleted because it does not exist ")
   ENDCASE
   SET error_text = concat(error_text," on the CODE_VALUE_EXTENSION table.")
   SET error_text = concat(error_text,"  No changes were applied to the database.")
   CALL echo(error_text)
 END ;Subroutine
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 SET script_version = "000 03/18/03 JF8275"
END GO
