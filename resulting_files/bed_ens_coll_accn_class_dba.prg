CREATE PROGRAM bed_ens_coll_accn_class:dba
 FREE SET reply
 RECORD reply(
   1 rlist[*]
     2 display = c40
     2 code_value = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD request_cv(
   1 cd_value_list[1]
     2 action_flag = i2
     2 cdf_meaning = vc
     2 cki = vc
     2 code_set = i4
     2 code_value = f8
     2 collation_seq = i4
     2 concept_cki = vc
     2 definition = vc
     2 description = vc
     2 display = vc
     2 begin_effective_dt_tm = dq8
     2 end_effective_dt_tm = dq8
     2 active_ind = i2
     2 display_key = vc
 )
 FREE RECORD reply_cv
 RECORD reply_cv(
   1 curqual = i4
   1 qual[*]
     2 status = i2
     2 error_num = i4
     2 error_msg = vc
     2 code_value = f8
     2 cki = vc
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET dcnt = 0
 SET dcnt = size(request->dlist,5)
 SET stat = alterlist(reply->rlist,dcnt)
 FOR (d = 1 TO dcnt)
   IF ((request->dlist[d].action_flag=1))
    SET reply->rlist[d].display = request->dlist[d].display
    SET curr_code_value = 0
    SET curr_status = 0
    SELECT INTO "NL:"
     FROM code_value cv
     WHERE cv.code_set=2056
      AND cv.display_key=cnvtupper(cnvtalphanum(request->dlist[d].display))
     DETAIL
      curr_code_value = cv.code_value, curr_status = cv.active_ind
     WITH nocounter
    ;end select
    IF (curr_code_value > 0)
     SET reply->rlist[d].code_value = curr_code_value
     IF (curr_status=0)
      SET request_cv->cd_value_list[1].action_flag = 2
      SET request_cv->cd_value_list[1].code_set = 2056
      SET request_cv->cd_value_list[1].code_value = curr_code_value
      SET request_cv->cd_value_list[1].display = request->dlist[d].display
      SET request_cv->cd_value_list[1].description = request->dlist[d].description
      SET request_cv->cd_value_list[1].definition = request->dlist[d].display
      SET request_cv->cd_value_list[1].active_ind = 1
      SET trace = recpersist
      EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
     ENDIF
    ELSE
     SET request_cv->cd_value_list[1].action_flag = 1
     SET request_cv->cd_value_list[1].code_set = 2056
     SET request_cv->cd_value_list[1].display = request->dlist[d].display
     SET request_cv->cd_value_list[1].description = request->dlist[d].description
     SET request_cv->cd_value_list[1].definition = request->dlist[d].display
     SET request_cv->cd_value_list[1].active_ind = 1
     SET trace = recpersist
     EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
     IF ((reply_cv->status_data.status="S")
      AND (reply_cv->qual[1].code_value > 0))
      SET reply->rlist[d].code_value = reply_cv->qual[1].code_value
      INSERT  FROM accession_class ac
       SET ac.accession_class_cd = reply_cv->qual[1].code_value, ac.accession_format_cd = 0.0, ac
        .updt_applctx = reqinfo->updt_applctx,
        ac.updt_cnt = 0, ac.updt_dt_tm = cnvtdatetime(curdate,curtime), ac.updt_id = reqinfo->updt_id,
        ac.updt_task = reqinfo->updt_task
       WITH nocounter
      ;end insert
     ENDIF
    ENDIF
   ELSEIF ((request->dlist[d].action_flag=2))
    SET request_cv->cd_value_list[1].action_flag = 2
    SET request_cv->cd_value_list[1].code_set = 2056
    SET request_cv->cd_value_list[1].code_value = request->dlist[d].code_value
    SET request_cv->cd_value_list[1].display = request->dlist[d].display
    SET request_cv->cd_value_list[1].description = request->dlist[d].description
    SET request_cv->cd_value_list[1].definition = request->dlist[d].display
    SET request_cv->cd_value_list[1].active_ind = 1
    SET trace = recpersist
    EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   ELSE
    GO TO exit_script
   ENDIF
 ENDFOR
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 CALL echorecord(reply)
END GO
