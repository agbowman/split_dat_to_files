CREATE PROGRAM core_ens_cdf_meaning:dba
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
 DECLARE insert_cd_set(aidx=i4) = null
 DECLARE create_message(action=i2,code_set=i4,cdf_meaning=vc) = null
 DECLARE script_version = vc WITH public, noconstant(" ")
 DECLARE failed = c1 WITH public, noconstant("F")
 DECLARE req_cnt = i4 WITH public, noconstant(size(request->cdf_mean_list,5))
 DECLARE xvar = i4 WITH public, noconstant(0)
 DECLARE error_text = vc WITH public, noconstant(" ")
 DECLARE errmsg = vc WITH public, noconstant(fillstring(132," "))
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->qual,req_cnt)
 FOR (xvar = 1 TO req_cnt)
   CASE (request->cdf_mean_list[xvar].action_type_flag)
    OF 1:
     CALL insert_cdf_mean(xvar)
    OF 2:
     SET failed = "T"
     SET stat = alterlist(reply->qual,xvar)
     SET reply->qual[xvar].status = 0
     SET reply->qual[xvar].error_msg = concat("Updates are not allowed ",
      "for the COMMON_DATA_FOUNDATION table.")
     GO TO exit_script
    OF 3:
     SET failed = "T"
     SET stat = alterlist(reply->qual,xvar)
     SET reply->qual[xvar].status = 0
     SET reply->qual[xvar].error_msg = concat("Deletes are not allowed ",
      "for the COMMON_DATA_FOUNDATION table.")
     GO TO exit_script
    ELSE
     SET failed = "T"
     SET stat = alterlist(reply->qual,xvar)
     SET reply->qual[xvar].status = 0
     SET reply->qual[xvar].error_msg = build("Could not recognize"," action_type_flag:",request->
      cdf_mean_list[xvar].action_type_flag,".")
     GO TO exit_script
   ENDCASE
 ENDFOR
 GO TO exit_script
 SUBROUTINE insert_cdf_mean(aidx)
   IF ((( NOT (trim(substring(1,12,request->cdf_mean_list[aidx].cdf_meaning),3) > " ")) OR ((request
   ->cdf_mean_list[aidx].code_set <= 0))) )
    SET failed = "T"
    SET stat = alterlist(reply->qual,aidx)
    SET reply->qual[aidx].status = 0
    SET reply->qual[aidx].error_msg = concat("The values for both CDF_MEANING and ",
     "CODE_SET must be a valid.")
    GO TO exit_script
   ENDIF
   SELECT INTO "nl:"
    cdf.seq
    FROM common_data_foundation cdf
    PLAN (cdf
     WHERE cdf.cdf_meaning=cnvtupper(request->cdf_mean_list[aidx].cdf_meaning)
      AND (cdf.code_set=request->cdf_mean_list[aidx].code_set))
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET failed = "T"
    SET stat = alterlist(reply->qual,aidx)
    SET reply->qual[aidx].status = 0
    CALL create_message(request->cdf_mean_list[aidx].action_type_flag,request->cdf_mean_list[aidx].
     code_set,request->cdf_mean_list[aidx].cdf_meaning)
    SET reply->qual[aidx].error_msg = error_text
    GO TO exit_script
   ENDIF
   INSERT  FROM common_data_foundation cdf
    SET cdf.cdf_meaning = trim(cnvtupper(substring(1,12,request->cdf_mean_list[aidx].cdf_meaning)),3),
     cdf.code_set = request->cdf_mean_list[aidx].code_set, cdf.definition =
     IF ((request->cdf_mean_list[aidx].definition='""')) null
     ELSE trim(request->cdf_mean_list[aidx].definition,3)
     ENDIF
     ,
     cdf.display =
     IF ((request->cdf_mean_list[aidx].display='""')) null
     ELSE trim(substring(1,40,request->cdf_mean_list[aidx].display),3)
     ENDIF
     , cdf.updt_applctx = reqinfo->updt_applctx, cdf.updt_cnt = 0,
     cdf.updt_dt_tm = cnvtdatetime(curdate,curtime3), cdf.updt_id = reqinfo->updt_id, cdf.updt_task
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
 SUBROUTINE create_message(action,code_set,cdf_meaning)
   SET error_text = ""
   SET code_set_disp = trim(cnvtstring(code_set))
   SET cdf_meaning_disp = trim(cdf_meaning)
   SET error_text = "The meaning with code_set ( "
   SET error_text = concat(error_text,code_set_disp)
   SET error_text = concat(error_text,") and cdf_meaning (")
   SET error_text = concat(error_text,cdf_meaning_disp)
   SET error_text = concat(error_text,") could not be ")
   CASE (action)
    OF 1:
     SET error_text = concat(error_text," inserted because it already exists ")
    OF 2:
     SET error_text = concat(error_text," updated because it does not exist ")
    OF 3:
     SET error_text = concat(error_text," deleted because it does not exist ")
   ENDCASE
   SET error_text = concat(error_text," on the COMMON_DATA_FOUNDATION table.")
   SET error_text = concat(error_text,"  No changes were applied to the database.")
 END ;Subroutine
#exit_script
 IF (failed="T")
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
 SET script_version = "000 03/14/03 JF8275"
END GO
