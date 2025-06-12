CREATE PROGRAM core_ens_cd_set:dba
 IF ((validate(reply->curqual,- (123))=- (123)))
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
 ENDIF
 DECLARE insert_cd_set(aidx=i4) = null
 DECLARE update_cd_set(aidx=i4) = null
 DECLARE create_message(action=i2,code_set=i4) = null
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE req_cnt = i4 WITH public, noconstant(size(request->cd_set_list,5))
 DECLARE xvar = i4 WITH public, noconstant(0)
 DECLARE error_text = vc WITH public, noconstant(" ")
 DECLARE errmsg = vc WITH public, noconstant(fillstring(132," "))
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->qual,req_cnt)
 FOR (xvar = 1 TO req_cnt)
   CASE (request->cd_set_list[xvar].action_type_flag)
    OF 1:
     CALL insert_cd_set(xvar)
    OF 2:
     CALL update_cd_set(xvar)
    OF 3:
     SET failed = "T"
     SET stat = alterlist(reply->qual,xvar)
     SET reply->qual[xvar].status = 0
     SET reply->qual[xvar].error_msg = concat("Deletes are not allowed ",
      "for the CODE_VALUE_SET table.")
     GO TO exit_script
    ELSE
     SET failed = "T"
     SET stat = alterlist(reply->qual,xvar)
     SET reply->qual[xvar].status = 0
     SET reply->qual[xvar].error_msg = build("Could not recognize"," action_type_flag:",request->
      cd_set_list[xvar].action_type_flag,".")
     GO TO exit_script
   ENDCASE
 ENDFOR
 GO TO exit_script
 SUBROUTINE insert_cd_set(aidx)
   SELECT INTO "nl:"
    cvs.seq
    FROM code_value_set cvs
    PLAN (cvs
     WHERE (cvs.code_set=request->cd_set_list[aidx].code_set))
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET failed = "T"
    SET stat = alterlist(reply->qual,aidx)
    SET reply->qual[aidx].status = 0
    CALL create_message(request->cd_set_list[aidx].action_type_flag,request->cd_set_list[aidx].
     code_set)
    SET reply->qual[aidx].error_msg = error_text
    GO TO exit_script
   ENDIF
   INSERT  FROM code_value_set cvs
    SET cvs.active_ind_dup_ind = request->cd_set_list[aidx].active_ind_dup_ind, cvs.add_access_ind =
     request->cd_set_list[aidx].add_access_ind, cvs.alias_dup_ind = request->cd_set_list[aidx].
     alias_dup_ind,
     cvs.cache_ind = request->cd_set_list[aidx].cache_ind, cvs.cdf_meaning_dup_ind = request->
     cd_set_list[aidx].cdf_meaning_dup_ind, cvs.chg_access_ind = request->cd_set_list[aidx].
     chg_access_ind,
     cvs.code_set = request->cd_set_list[aidx].code_set, cvs.definition =
     IF ((request->cd_set_list[aidx].definition='""')) null
     ELSE trim(request->cd_set_list[aidx].definition,3)
     ENDIF
     , cvs.definition_dup_ind = request->cd_set_list[aidx].definition_dup_ind,
     cvs.del_access_ind = request->cd_set_list[aidx].del_access_ind, cvs.description =
     IF ((request->cd_set_list[aidx].description='""')) null
     ELSE trim(substring(1,60,request->cd_set_list[aidx].description),3)
     ENDIF
     , cvs.display =
     IF ((request->cd_set_list[aidx].display='""')) null
     ELSE trim(substring(1,40,request->cd_set_list[aidx].display),3)
     ENDIF
     ,
     cvs.display_dup_ind = request->cd_set_list[aidx].display_dup_ind, cvs.display_key =
     IF ((request->cd_set_list[aidx].display='""')) null
     ELSE cnvtupper(cnvtalphanum(request->cd_set_list[aidx].display))
     ENDIF
     , cvs.display_key_dup_ind = request->cd_set_list[aidx].display_key_dup_ind,
     cvs.inq_access_ind = request->cd_set_list[aidx].inq_access_ind, cvs.updt_applctx = reqinfo->
     updt_applctx, cvs.updt_cnt = 0,
     cvs.updt_dt_tm = cnvtdatetime(curdate,curtime3), cvs.updt_id = reqinfo->updt_id, cvs.updt_task
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
 SUBROUTINE update_cd_set(aidx)
   SELECT INTO "nl:"
    cvs.seq
    FROM code_value_set cvs
    PLAN (cvs
     WHERE (cvs.code_set=request->cd_set_list[aidx].code_set))
    WITH nocounter
   ;end select
   IF (curqual <= 0)
    SET failed = "T"
    SET stat = alterlist(reply->qual,aidx)
    SET reply->qual[aidx].status = 0
    CALL create_message(request->cd_set_list[aidx].action_type_flag,request->cd_set_list[aidx].
     code_set)
    SET reply->qual[aidx].error_msg = error_text
    GO TO exit_script
   ENDIF
   UPDATE  FROM code_value_set cvs
    SET cvs.active_ind_dup_ind = request->cd_set_list[aidx].active_ind_dup_ind, cvs.add_access_ind =
     request->cd_set_list[aidx].add_access_ind, cvs.alias_dup_ind = request->cd_set_list[aidx].
     alias_dup_ind,
     cvs.cache_ind = request->cd_set_list[aidx].cache_ind, cvs.cdf_meaning_dup_ind = request->
     cd_set_list[aidx].cdf_meaning_dup_ind, cvs.chg_access_ind = request->cd_set_list[aidx].
     chg_access_ind,
     cvs.definition =
     IF ((request->cd_set_list[aidx].definition='""')) null
     ELSE trim(request->cd_set_list[aidx].definition,3)
     ENDIF
     , cvs.definition_dup_ind = request->cd_set_list[aidx].definition_dup_ind, cvs.del_access_ind =
     request->cd_set_list[aidx].del_access_ind,
     cvs.description =
     IF ((request->cd_set_list[aidx].description='""')) null
     ELSE trim(substring(1,60,request->cd_set_list[aidx].description),3)
     ENDIF
     , cvs.display =
     IF ((request->cd_set_list[aidx].display='""')) null
     ELSE trim(substring(1,40,request->cd_set_list[aidx].display),3)
     ENDIF
     , cvs.display_dup_ind = request->cd_set_list[aidx].display_dup_ind,
     cvs.display_key =
     IF ((request->cd_set_list[aidx].display='""')) null
     ELSE cnvtupper(cnvtalphanum(substring(1,40,request->cd_set_list[aidx].display)))
     ENDIF
     , cvs.display_key_dup_ind = request->cd_set_list[aidx].display_key_dup_ind, cvs.inq_access_ind
      = request->cd_set_list[aidx].inq_access_ind,
     cvs.updt_applctx = reqinfo->updt_applctx, cvs.updt_cnt = (cvs.updt_cnt+ 1), cvs.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     cvs.updt_id = reqinfo->updt_id, cvs.updt_task = reqinfo->updt_task
    WHERE (cvs.code_set=request->cd_set_list[aidx].code_set)
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
 SUBROUTINE create_message(action,code_set)
   SET error_text = ""
   SET code_set_disp = trim(cnvtstring(code_set))
   SET error_text = "The code set ("
   SET error_text = concat(error_text,code_set_disp)
   SET error_text = concat(error_text,") could not be ")
   CASE (action)
    OF 1:
     SET error_text = concat(error_text," inserted because it already exists ")
    OF 2:
     SET error_text = concat(error_text," updated because it does not exist ")
    OF 3:
     SET error_text = concat(error_text," deleted because it does not exist ")
   ENDCASE
   SET error_text = concat(error_text," on the CODE_VALUE_SET table.")
   SET error_text = concat(error_text,"  No changes were applied to the database.")
 END ;Subroutine
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 SET script_version = "000 03/13/03 JF8275"
END GO
