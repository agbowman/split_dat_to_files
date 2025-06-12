CREATE PROGRAM core_ens_cd_value_group:dba
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
 DECLARE insert_cd_value_group(aidx=i4) = null
 DECLARE update_cd_value_group(aidx=i4) = null
 DECLARE delete_cd_value_group(aidx=i4) = null
 DECLARE create_message(action=i2,parent_cd=f8,child_cd=f8) = null
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE req_cnt = i4 WITH public, noconstant(size(request->cd_value_grp_list,5))
 DECLARE xvar = i4 WITH public, noconstant(0)
 DECLARE error_text = vc WITH public, noconstant(" ")
 DECLARE errmsg = vc WITH public, noconstant(fillstring(132," "))
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->qual,req_cnt)
 FOR (xvar = 1 TO req_cnt)
   CASE (request->cd_value_grp_list[xvar].action_type_flag)
    OF 1:
     CALL insert_cd_value_group(xvar)
    OF 2:
     CALL update_cd_value_group(xvar)
    OF 3:
     CALL delete_cd_value_group(xvar)
    ELSE
     SET failed = "T"
     SET stat = alterlist(reply->qual,xvar)
     SET reply->qual[xvar].status = 0
     SET reply->qual[xvar].error_msg = build("Could not recognize"," action_type_flag:",request->
      cd_value_grp_list[xvar].action_type_flag,".")
     GO TO exit_script
   ENDCASE
 ENDFOR
 GO TO exit_script
 SUBROUTINE insert_cd_value_group(aidx)
   SELECT INTO "nl:"
    cvg.seq
    FROM code_value_group cvg
    PLAN (cvg
     WHERE (cvg.parent_code_value=request->cd_value_grp_list[aidx].parent_code_value)
      AND (cvg.child_code_value=request->cd_value_grp_list[aidx].child_code_value))
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET failed = "T"
    SET stat = alterlist(reply->qual,aidx)
    SET reply->qual[aidx].status = 0
    CALL create_message(request->cd_value_grp_list[aidx].action_type_flag,request->cd_value_grp_list[
     aidx].parent_code_value,request->cd_value_grp_list[aidx].child_code_value)
    SET reply->qual[aidx].error_msg = error_text
    GO TO exit_script
   ENDIF
   INSERT  FROM code_value_group cvg
    SET cvg.child_code_value = request->cd_value_grp_list[aidx].child_code_value, cvg.code_set =
     IF ((request->cd_value_grp_list[aidx].code_set <= 0)) 0
     ELSE request->cd_value_grp_list[aidx].code_set
     ENDIF
     , cvg.collation_seq =
     IF ((request->cd_value_grp_list[aidx].collation_seq <= 0)) 0
     ELSE request->cd_value_grp_list[aidx].collation_seq
     ENDIF
     ,
     cvg.parent_code_value = request->cd_value_grp_list[aidx].parent_code_value, cvg.updt_applctx =
     reqinfo->updt_applctx, cvg.updt_cnt = 0,
     cvg.updt_dt_tm = cnvtdatetime(curdate,curtime3), cvg.updt_id = reqinfo->updt_id, cvg.updt_task
      = reqinfo->updt_task
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
 SUBROUTINE update_cd_value_group(aidx)
   SELECT INTO "nl:"
    cvg.seq
    FROM code_value_group cvg
    PLAN (cvg
     WHERE (cvg.parent_code_value=request->cd_value_grp_list[aidx].parent_code_value)
      AND (cvg.child_code_value=request->cd_value_grp_list[aidx].child_code_value))
    WITH nocounter
   ;end select
   IF (curqual <= 0)
    SET failed = "T"
    SET stat = alterlist(reply->qual,aidx)
    SET reply->qual[aidx].status = 0
    CALL create_message(request->cd_value_grp_list[aidx].action_type_flag,request->cd_value_grp_list[
     aidx].parent_code_value,request->cd_value_grp_list[aidx].child_code_value)
    SET reply->qual[aidx].error_msg = error_text
    GO TO exit_script
   ENDIF
   UPDATE  FROM code_value_group cvg
    SET cvg.code_set =
     IF ((request->cd_value_grp_list[aidx].code_set <= 0)) 0
     ELSE request->cd_value_grp_list[aidx].code_set
     ENDIF
     , cvg.collation_seq =
     IF ((request->cd_value_grp_list[aidx].collation_seq <= 0)) 0
     ELSE request->cd_value_grp_list[aidx].collation_seq
     ENDIF
     , cvg.updt_applctx = reqinfo->updt_applctx,
     cvg.updt_cnt = (cvg.updt_cnt+ 1), cvg.updt_dt_tm = cnvtdatetime(curdate,curtime3), cvg.updt_id
      = reqinfo->updt_id,
     cvg.updt_task = reqinfo->updt_task
    WHERE (cvg.child_code_value=request->cd_value_grp_list[aidx].child_code_value)
     AND (cvg.parent_code_value=request->cd_value_grp_list[aidx].parent_code_value)
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
 SUBROUTINE delete_cd_value_group(aidx)
   SELECT INTO "nl:"
    cvg.seq
    FROM code_value_group cvg
    PLAN (cvg
     WHERE (cvg.parent_code_value=request->cd_value_grp_list[aidx].parent_code_value)
      AND (cvg.child_code_value=request->cd_value_grp_list[aidx].child_code_value))
    WITH nocounter
   ;end select
   IF (curqual <= 0)
    SET failed = "T"
    SET stat = alterlist(reply->qual,aidx)
    SET reply->qual[aidx].status = 0
    CALL create_message(request->cd_value_grp_list[aidx].action_type_flag,request->cd_value_grp_list[
     aidx].parent_code_value,request->cd_value_grp_list[aidx].child_code_value)
    SET reply->qual[aidx].error_msg = error_text
    GO TO exit_script
   ENDIF
   DELETE  FROM code_value_group cvg
    WHERE (cvg.child_code_value=request->cd_value_grp_list[aidx].child_code_value)
     AND (cvg.parent_code_value=request->cd_value_grp_list[aidx].parent_code_value)
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
 SUBROUTINE create_message(action,parent_cd,child_cd)
   SET error_text = ""
   SET parent_disp = uar_get_code_display(parent_cd)
   SET child_disp = uar_get_code_display(child_cd)
   SET error_text = "The code value group with parent code value ( "
   SET error_text = concat(error_text,parent_disp)
   SET error_text = concat(error_text,") and child code value (")
   SET error_text = concat(error_text,child_disp)
   SET error_text = concat(error_text,") could not be ")
   CASE (action)
    OF 1:
     SET error_text = concat(error_text," inserted because it already exists ")
    OF 2:
     SET error_text = concat(error_text," updated because it does not exist ")
    OF 3:
     SET error_text = concat(error_text," deleted because it does not exist ")
   ENDCASE
   SET error_text = concat(error_text," on the CODE_VALUE_GROUP table.")
   SET error_text = concat(error_text,"  No changes were applied to the database.")
   CALL echo(error_text)
 END ;Subroutine
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 SET script_version = "000 03/12/03 JF8275"
END GO
