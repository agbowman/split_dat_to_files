CREATE PROGRAM bed_ens_rad_acc_class:dba
 FREE SET reply
 RECORD reply(
   1 accession_class[*]
     2 code_value = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET request_cv
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
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET cnt = size(request->accession_class,5)
 SET stat = alterlist(reply->accession_class,cnt)
 FOR (x = 1 TO cnt)
   SET request_cv->cd_value_list[1].action_flag = 1
   SET request_cv->cd_value_list[1].code_set = 2056
   SET request_cv->cd_value_list[1].concept_cki = ""
   SET request_cv->cd_value_list[1].display = substring(1,40,request->accession_class[x].display)
   SET request_cv->cd_value_list[1].description = substring(1,60,request->accession_class[x].display)
   SET request_cv->cd_value_list[1].definition = request->accession_class[x].display
   SET request_cv->cd_value_list[1].active_ind = 1
   SET trace = recpersist
   EXECUTE bed_ens_cd_value  WITH replace("REQUEST",request_cv), replace("REPLY",reply_cv)
   IF ((reply_cv->status_data.status="S")
    AND (reply_cv->qual[1].code_value > 0))
    SET reply->accession_class[x].code_value = reply_cv->qual[1].code_value
   ELSE
    SET error_flag = "Y"
    SET reply->error_msg = concat("Unable to insert ",trim(request->accession_class[x].display),
     " into codeset 2056.")
    GO TO exit_script
   ENDIF
   INSERT  FROM accession_class a
    SET a.accession_class_cd = reply->accession_class[x].code_value, a.accession_format_cd = 0, a
     .updt_dt_tm = cnvtdatetime(curdate,curtime3),
     a.updt_id = reqinfo->updt_id, a.updt_task = reqinfo->updt_task, a.updt_cnt = 0,
     a.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET error_flag = "Y"
    SET reply->error_msg = concat("Unable to insert accession class: ",trim(request->accession_class[
      x].display)," into the accession_class table.")
    GO TO exit_script
   ENDIF
 ENDFOR
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
 CALL echorecord(reply)
END GO
