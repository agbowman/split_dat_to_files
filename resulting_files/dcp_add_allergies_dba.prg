CREATE PROGRAM dcp_add_allergies:dba
 RECORD reply(
   1 allergy_cnt = i4
   1 allergy[*]
     2 allergy_instance_id = f8
     2 allergy_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c8
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = c100
 )
 SET reply->status_data.status = "S"
 SET reply->allergy_cnt = 0
 SET react_id_cnt = 0
 SET x = 0
 SET code_set = 0.0
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET active_cd = 0.0
 SET unauth_cd = 0.0
 SET allergic_reaction_cd = 0.0
 SET active_reaction_cd = 0.0
 SET allergy_instance_id = 0.0
 SET allergy_id = 0.0
 SET allergy_comment_id = 0.0
 SET code_set = 48
 SET cdf_meaning = "ACTIVE"
 EXECUTE cpm_get_cd_for_cdf
 SET active_cd = code_value
 SET code_set = 8
 SET cdf_meaning = "UNAUTH"
 EXECUTE cpm_get_cd_for_cdf
 SET unauth_cd = code_value
 SET code_set = 12025
 SET cdf_meaning = "ACTIVE"
 EXECUTE cpm_get_cd_for_cdf
 SET active_reaction_cd = code_value
 FOR (x = 1 TO request->allergy_cnt)
   SELECT INTO "nl:"
    num = seq(health_status_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     allergy_id = cnvtreal(num)
    WITH format, counter
   ;end select
   SET allergy_instance_id = allergy_id
   CALL echo(allergy_id)
   INSERT  FROM allergy a
    SET a.allergy_instance_id = allergy_instance_id, a.allergy_id = allergy_id, a.person_id = request
     ->allergy[x].person_id,
     a.encntr_id = request->allergy[x].encntr_id, a.substance_nom_id = request->allergy[x].
     substance_nom_id, a.substance_ftdesc = request->allergy[x].substance_ftdesc,
     a.severity_cd = request->allergy[x].severity_cd, a.source_of_info_cd = request->allergy[x].
     source_cd, a.reaction_class_cd = request->allergy[x].reaction_class_cd,
     a.onset_dt_tm = cnvtdatetime(request->allergy[x].onset_dt_tm), a.reaction_status_cd =
     active_reaction_cd, a.created_dt_tm = cnvtdatetime(curdate,curtime3),
     a.created_prsnl_id = reqinfo->updt_id, a.data_status_cd = unauth_cd, a.data_status_dt_tm =
     cnvtdatetime(curdate,curtime3),
     a.data_status_prsnl_id = reqinfo->updt_id, a.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3
      ), a.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"),
     a.active_ind = 1, a.active_status_cd = active_cd, a.active_status_prsnl_id = reqinfo->updt_id,
     a.active_status_dt_tm = cnvtdatetime(curdate,curtime3), a.updt_cnt = 0, a.updt_dt_tm =
     cnvtdatetime(curdate,curtime3),
     a.updt_id = reqinfo->updt_id, a.updt_applctx = reqinfo->updt_applctx, a.updt_task = reqinfo->
     updt_task
    WITH nocounter
   ;end insert
   IF (curqual=0)
    SET reply->status_data.status = "F"
    GO TO exit_script
   ELSE
    IF (x > size(reply->allergy,5))
     SET stat = alterlist(reply->allergy,(x+ 5))
    ENDIF
    SET reply->allergy[x].allergy_instance_id = allergy_instance_id
    SET reply->allergy[x].allergy_id = allergy_id
   ENDIF
   IF ((request->allergy[x].comment_cnt > 0))
    FOR (comment_id = 1 TO request->allergy[x].comment_cnt)
      SELECT INTO "nl:"
       num = seq(health_status_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        allergy_comment_id = cnvtreal(num)
       WITH format, counter
      ;end select
      CALL echo(allergy_comment_id)
      INSERT  FROM allergy_comment ac
       SET ac.allergy_comment_id = allergy_comment_id, ac.allergy_id = allergy_id, ac
        .allergy_instance_id = allergy_instance_id,
        ac.comment_dt_tm = cnvtdatetime(curdate,curtime), ac.comment_prsnl_id = reqinfo->updt_id, ac
        .allergy_comment = request->allergy[x].comment[comment_id].allergy_comment,
        ac.active_ind = 1, ac.active_status_cd = active_cd, ac.active_status_prsnl_id = reqinfo->
        updt_id,
        ac.active_status_dt_tm = cnvtdatetime(curdate,curtime3), ac.updt_cnt = 0, ac.updt_dt_tm =
        cnvtdatetime(curdate,curtime3),
        ac.updt_id = reqinfo->updt_id, ac.updt_applctx = reqinfo->updt_applctx, ac.updt_task =
        reqinfo->updt_task,
        ac.active_status_prsnl_id = reqinfo->updt_id, ac.data_status_prsnl_id = reqinfo->updt_id, ac
        .active_status_dt_tm = cnvtdatetime(curdate,curtime3),
        ac.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), ac.end_effective_dt_tm =
        cnvtdatetime("31-DEC-2100 00:00:00.00")
       WITH nocounter
      ;end insert
    ENDFOR
   ENDIF
   IF ((request->allergy[x].reaction_cnt > 0))
    FOR (react_id_cnt = 1 TO request->allergy[x].reaction_cnt)
      SELECT INTO "nl:"
       num = seq(health_status_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        request->allergy[x].reaction[react_id_cnt].reaction_id = cnvtreal(num)
       WITH format, counter
      ;end select
    ENDFOR
    INSERT  FROM reaction r,
      (dummyt d1  WITH seq = value(request->allergy[x].reaction_cnt))
     SET r.reaction_id = request->allergy[x].reaction[d1.seq].reaction_id, r.allergy_instance_id =
      allergy_instance_id, r.allergy_id = allergy_id,
      r.reaction_nom_id = request->allergy[x].reaction[d1.seq].reaction_nom_id, r.reaction_ftdesc =
      request->allergy[x].reaction[d1.seq].reaction_ftdesc, r.data_status_cd = unauth_cd,
      r.data_status_dt_tm = cnvtdatetime(curdate,curtime3), r.data_status_prsnl_id = reqinfo->updt_id,
      r.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3),
      r.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00"), r.active_ind = 1, r
      .active_status_cd = active_cd,
      r.active_status_prsnl_id = reqinfo->updt_id, r.active_status_dt_tm = cnvtdatetime(curdate,
       curtime3), r.updt_cnt = 0,
      r.updt_dt_tm = cnvtdatetime(curdate,curtime3), r.updt_id = reqinfo->updt_id, r.updt_applctx =
      reqinfo->updt_applctx,
      r.updt_task = reqinfo->updt_task
     PLAN (d1)
      JOIN (r)
     WITH nocounter
    ;end insert
    IF ((curqual != request->allergy[x].reaction_cnt))
     SET reply->status_data.status = "F"
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SET reply->allergy_cnt = x
 SET stat = alterlist(reply->allergy,reply->allergy_cnt)
#exit_script
 IF ((reply->status_data.status="F"))
  SET reply->status_data.subeventstatus[1].operationname = "ADD ALLERGY"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "ALLERGY"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "ALLERGY"
  SET reqinfo->commit_ind = 0
 ELSE
  SET reqinfo->commit_ind = 1
 ENDIF
END GO
