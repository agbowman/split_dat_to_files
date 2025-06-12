CREATE PROGRAM bed_get_ens_app_prefs:dba
 FREE SET reply
 RECORD reply(
   1 aplist[*]
     2 app_prefs_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET listcount = 0
 SET listcount = size(request->aplist,5)
 SET stat = alterlist(reply->aplist,listcount)
 FOR (lvar = 1 TO listcount)
   IF ((request->aplist[lvar].action_flag="0"))
    SET reply->aplist[lvar].app_prefs_id = 0.0
    SELECT INTO "NL:"
     FROM app_prefs ap
     WHERE (ap.application_number=request->aplist[lvar].application_number)
      AND (ap.position_cd=request->aplist[lvar].position_cd)
      AND (ap.prsnl_id=request->aplist[lvar].prsnl_id)
      AND ap.active_ind=1
     DETAIL
      reply->aplist[lvar].app_prefs_id = ap.app_prefs_id
     WITH nocounter
    ;end select
   ELSEIF ((request->aplist[lvar].action_flag="1"))
    SET reply->aplist[lvar].app_prefs_id = 0.0
    SELECT INTO "nl:"
     z = seq(carenet_seq,nextval)
     FROM dual
     DETAIL
      reply->aplist[lvar].app_prefs_id = cnvtreal(z)
     WITH format, nocounter
    ;end select
    IF ((reply->aplist[lvar].app_prefs_id > 0))
     INSERT  FROM app_prefs ap
      SET ap.app_prefs_id = reply->aplist[lvar].app_prefs_id, ap.application_number = request->
       aplist[lvar].application_number, ap.position_cd = request->aplist[lvar].position_cd,
       ap.prsnl_id = request->aplist[lvar].prsnl_id, ap.active_ind = 1, ap.updt_cnt = 0,
       ap.updt_id = reqinfo->updt_id, ap.updt_dt_tm = cnvtdatetime(curdate,curtime), ap.updt_task =
       reqinfo->updt_task,
       ap.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ENDIF
   ELSEIF ((request->aplist[lvar].action_flag="3"))
    DELETE  FROM app_prefs ap
     WHERE (ap.application_number=request->aplist[lvar].application_number)
      AND (ap.position_cd=request->aplist[lvar].position_cd)
      AND (ap.prsnl_id=request->aplist[lvar].prsnl_id)
     WITH nocounter
    ;end delete
   ENDIF
 ENDFOR
END GO
