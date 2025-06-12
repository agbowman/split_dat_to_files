CREATE PROGRAM ct_add_user_domain_info:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE last_mod = c5 WITH private, noconstant(fillstring(5," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 SET reply->status_data.status = "F"
 INSERT  FROM ct_user_domain_info cd
  SET cd.ct_user_domain_info_id = seq(protocol_def_seq,nextval), cd.ct_domain_info_id = request->
   ct_domain_id, cd.person_id = request->person_id,
   cd.user_token_txt = request->user_token_str, cd.updt_dt_tm = cnvtdatetime(curdate,curtime3), cd
   .updt_id = reqinfo->updt_id,
   cd.updt_task = reqinfo->updt_task, cd.updt_applctx = reqinfo->updt_applctx, cd.updt_cnt = 0
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ENDIF
 SET last_mod = "000"
 SET mod_date = "Sept 25, 2008"
END GO
