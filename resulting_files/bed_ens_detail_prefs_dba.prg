CREATE PROGRAM bed_ens_detail_prefs:dba
 FREE SET reply
 RECORD reply(
   1 dplist[*]
     2 detail_prefs_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET listcount = 0
 SET listcount = size(request->dplist,5)
 SET stat = alterlist(reply->dplist,listcount)
 FOR (lvar = 1 TO listcount)
   IF ((request->dplist[lvar].action_flag="1"))
    SET reply->dplist[lvar].detail_prefs_id = 0.0
    SELECT INTO "nl:"
     z = seq(carenet_seq,nextval)
     FROM dual
     DETAIL
      reply->dplist[lvar].detail_prefs_id = cnvtreal(z)
     WITH format, nocounter
    ;end select
    IF ((reply->dplist[lvar].detail_prefs_id > 0))
     INSERT  FROM detail_prefs dp
      SET dp.detail_prefs_id = reply->dplist[lvar].detail_prefs_id, dp.application_number = request->
       dplist[lvar].application_number, dp.position_cd = request->dplist[lvar].position_cd,
       dp.prsnl_id = request->dplist[lvar].prsnl_id, dp.person_id = request->dplist[lvar].person_id,
       dp.view_name = request->dplist[lvar].view_name,
       dp.view_seq = request->dplist[lvar].view_seq, dp.comp_name = request->dplist[lvar].comp_name,
       dp.comp_seq = request->dplist[lvar].comp_seq,
       dp.active_ind = 1, dp.updt_cnt = 0, dp.updt_id = reqinfo->updt_id,
       dp.updt_dt_tm = cnvtdatetime(curdate,curtime), dp.updt_task = reqinfo->updt_task, dp
       .updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ENDIF
   ELSEIF ((request->dplist[lvar].action_flag="3"))
    DELETE  FROM detail_prefs dp
     WHERE (dp.application_number=request->dplist[lvar].application_number)
      AND (dp.position_cd=request->dplist[lvar].position_cd)
      AND (dp.prsnl_id=request->dplist[lvar].prsnl_id)
      AND (dp.person_id=request->dplist[lvar].person_id)
      AND (dp.view_name=request->dplist[lvar].view_name)
      AND (dp.view_seq=request->dplist[lvar].view_seq)
      AND (dp.comp_name=request->dplist[lvar].comp_name)
      AND (dp.comp_seq=request->dplist[lvar].comp_seq)
     WITH nocounter
    ;end delete
   ENDIF
 ENDFOR
END GO
