CREATE PROGRAM core_ens_cd_set_ext:dba
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
 DECLARE insert_cd_set_ext(aidx=i4) = null
 DECLARE update_cd_set_ext(aidx=i4) = null
 DECLARE delete_cd_set_ext(aidx=i4) = null
 DECLARE create_message(action=i2,code_set=i4,field_name=vc) = null
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE req_cnt = i4 WITH public, noconstant(size(request->ext_list,5))
 DECLARE xvar = i4 WITH public, noconstant(0)
 DECLARE cv_cnt = i4 WITH public, noconstant(0)
 DECLARE error_text = vc WITH public, noconstant(" ")
 DECLARE errmsg = c132 WITH public, noconstant(fillstring(132," "))
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->qual,req_cnt)
 FOR (xvar = 1 TO req_cnt)
   CASE (request->ext_list[xvar].action_type_flag)
    OF 1:
     CALL insert_cd_set_ext(xvar)
    OF 2:
     CALL update_cd_set_ext(xvar)
    OF 3:
     CALL delete_cd_set_ext(xvar)
    ELSE
     SET failed = "T"
     SET stat = alterlist(reply->qual,xvar)
     SET reply->qual[xvar].status = 0
     SET reply->qual[xvar].error_msg = build("Could not recognize"," action_type_flag:",request->
      ext_list[xvar].action_type_flag,".")
     GO TO exit_script
   ENDCASE
 ENDFOR
 GO TO exit_script
 SUBROUTINE insert_cd_set_ext(aidx)
   SELECT INTO "nl:"
    cse.seq
    FROM code_set_extension cse
    PLAN (cse
     WHERE (cse.code_set=request->ext_list[aidx].code_set)
      AND (cse.field_name=request->ext_list[aidx].field_name))
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET failed = "T"
    SET stat = alterlist(reply->qual,aidx)
    SET reply->qual[aidx].status = 0
    CALL create_message(request->ext_list[aidx].action_type_flag,request->ext_list[aidx].code_set,
     request->ext_list[aidx].field_name)
    SET reply->qual[aidx].error_msg = error_text
    GO TO exit_script
   ENDIF
   INSERT  FROM code_set_extension cse
    SET cse.code_set = request->ext_list[aidx].code_set, cse.field_default =
     IF ((request->ext_list[aidx].field_default='""')) null
     ELSE trim(substring(1,50,request->ext_list[aidx].field_default),3)
     ENDIF
     , cse.field_help =
     IF ((request->ext_list[aidx].field_help='""')) null
     ELSE trim(substring(1,100,request->ext_list[aidx].field_help),3)
     ENDIF
     ,
     cse.field_in_mask =
     IF ((request->ext_list[aidx].field_in_mask='""')) null
     ELSE trim(substring(1,50,request->ext_list[aidx].field_in_mask),3)
     ENDIF
     , cse.field_len =
     IF ((request->ext_list[aidx].field_len <= 0)) 0
     ELSE request->ext_list[aidx].field_len
     ENDIF
     , cse.field_name = trim(substring(1,32,request->ext_list[aidx].field_name),3),
     cse.field_out_mask =
     IF ((request->ext_list[aidx].field_out_mask='""')) null
     ELSE trim(substring(1,50,request->ext_list[aidx].field_out_mask),3)
     ENDIF
     , cse.field_prompt =
     IF ((request->ext_list[aidx].field_prompt='""')) null
     ELSE trim(substring(1,50,request->ext_list[aidx].field_prompt),3)
     ENDIF
     , cse.field_seq =
     IF ((request->ext_list[aidx].field_seq <= 0)) 0
     ELSE request->ext_list[aidx].field_seq
     ENDIF
     ,
     cse.field_type =
     IF ((request->ext_list[aidx].field_type <= 0)) 0
     ELSE request->ext_list[aidx].field_type
     ENDIF
     , cse.updt_applctx = reqinfo->updt_applctx, cse.updt_cnt = 0,
     cse.updt_dt_tm = cnvtdatetime(curdate,curtime3), cse.updt_id = reqinfo->updt_id, cse.updt_task
      = reqinfo->updt_task,
     cse.validation_code_set =
     IF ((request->ext_list[aidx].validation_code_set <= 0.0)) 0.0
     ELSE request->ext_list[aidx].validation_code_set
     ENDIF
     , cse.validation_condition =
     IF ((request->ext_list[aidx].validation_condition='""')) null
     ELSE trim(substring(1,100,request->ext_list[aidx].validation_condition),3)
     ENDIF
    WITH nocounter
   ;end insert
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
   UPDATE  FROM code_value_set cs
    SET cs.extension_ind = 1
    PLAN (cs
     WHERE (cs.code_set=request->ext_list[aidx].code_set))
    WITH nocounter
   ;end update
   IF (curqual <= 0)
    SET failed = "T"
    SET stat = alterlist(reply->qual,aidx)
    SET reply->qual[aidx].status = 0
    SET reply->qual[aidx].error_msg = concat("The extension indicator could ",
     "not be set in CODE_VALUE_SET.")
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE update_cd_set_ext(aidx)
   SELECT INTO "nl:"
    cse.seq
    FROM code_set_extension cse
    PLAN (cse
     WHERE (cse.code_set=request->ext_list[aidx].code_set)
      AND (cse.field_name=request->ext_list[aidx].field_name))
    WITH nocounter
   ;end select
   IF (curqual <= 0)
    SET failed = "T"
    SET stat = alterlist(reply->qual,aidx)
    SET reply->qual[aidx].status = 0
    CALL create_message(request->ext_list[aidx].action_type_flag,request->ext_list[aidx].code_set,
     request->ext_list[aidx].field_name)
    SET reply->qual[aidx].error_msg = error_text
    GO TO exit_script
   ENDIF
   UPDATE  FROM code_set_extension cse
    SET cse.field_default =
     IF ((request->ext_list[aidx].field_default='""')) null
     ELSE trim(substring(1,50,request->ext_list[aidx].field_default),3)
     ENDIF
     , cse.field_help =
     IF ((request->ext_list[aidx].field_help='""')) null
     ELSE trim(substring(1,100,request->ext_list[aidx].field_help),3)
     ENDIF
     , cse.field_in_mask =
     IF ((request->ext_list[aidx].field_in_mask='""')) null
     ELSE trim(substring(1,50,request->ext_list[aidx].field_in_mask),3)
     ENDIF
     ,
     cse.field_len =
     IF ((request->ext_list[aidx].field_len <= 0)) 0
     ELSE request->ext_list[aidx].field_len
     ENDIF
     , cse.field_out_mask =
     IF ((request->ext_list[aidx].field_out_mask='""')) null
     ELSE trim(substring(1,50,request->ext_list[aidx].field_out_mask),3)
     ENDIF
     , cse.field_prompt =
     IF ((request->ext_list[aidx].field_prompt='""')) null
     ELSE trim(substring(1,50,request->ext_list[aidx].field_prompt),3)
     ENDIF
     ,
     cse.field_seq =
     IF ((request->ext_list[aidx].field_seq <= 0)) 0
     ELSE request->ext_list[aidx].field_seq
     ENDIF
     , cse.field_type =
     IF ((request->ext_list[aidx].field_type <= 0)) 0
     ELSE request->ext_list[aidx].field_type
     ENDIF
     , cse.updt_applctx = reqinfo->updt_applctx,
     cse.updt_cnt = (cse.updt_cnt+ 1), cse.updt_dt_tm = cnvtdatetime(curdate,curtime3), cse.updt_id
      = reqinfo->updt_id,
     cse.updt_task = reqinfo->updt_task, cse.validation_code_set =
     IF ((request->ext_list[aidx].validation_code_set <= 0.0)) 0.0
     ELSE request->ext_list[aidx].validation_code_set
     ENDIF
     , cse.validation_condition =
     IF ((request->ext_list[aidx].validation_condition='""')) null
     ELSE trim(substring(1,100,request->ext_list[aidx].validation_condition),3)
     ENDIF
    WHERE (cse.code_set=request->ext_list[aidx].code_set)
     AND (cse.field_name=request->ext_list[aidx].field_name)
    WITH nocounter
   ;end update
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
 SUBROUTINE delete_cd_set_ext(aidx)
   SELECT INTO "nl:"
    cse.seq
    FROM code_set_extension cse
    PLAN (cse
     WHERE (cse.code_set=request->ext_list[aidx].code_set)
      AND (cse.field_name=request->ext_list[aidx].field_name))
    WITH nocounter
   ;end select
   IF (curqual <= 0)
    SET failed = "T"
    SET stat = alterlist(reply->qual,aidx)
    SET reply->qual[aidx].status = 0
    CALL create_message(request->ext_list[aidx].action_type_flag,request->ext_list[aidx].code_set,
     request->ext_list[aidx].field_name)
    SET reply->qual[aidx].error_msg = error_text
    GO TO exit_script
   ENDIF
   DELETE  FROM code_value_extension cve
    WHERE (cve.code_set=request->ext_list[aidx].code_set)
     AND (cve.field_name=request->ext_list[aidx].field_name)
    WITH nocounter
   ;end delete
   DELETE  FROM code_set_extension cse
    WHERE (cse.code_set=request->ext_list[aidx].code_set)
     AND (cse.field_name=request->ext_list[aidx].field_name)
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
 SUBROUTINE create_message(action,code_set,field_name)
   SET error_text = ""
   SET code_set_disp = trim(cnvtstring(code_set))
   SET field_name_disp = trim(field_name)
   SET error_text = "The code set extension with code set ( "
   SET error_text = concat(error_text,code_set_disp)
   SET error_text = concat(error_text,") and field name (")
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
   SET error_text = concat(error_text," on the CODE_SET_EXTENSION table.")
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
