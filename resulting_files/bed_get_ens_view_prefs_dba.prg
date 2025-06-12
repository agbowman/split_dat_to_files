CREATE PROGRAM bed_get_ens_view_prefs:dba
 FREE SET reply
 RECORD reply(
   1 vplist[*]
     2 view_prefs_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET listcount = 0
 SET listcount = size(request->vplist,5)
 SET stat = alterlist(reply->vplist,listcount)
 FOR (lvar = 1 TO listcount)
   IF ((request->vplist[lvar].action_flag="0"))
    SET reply->vplist[lvar].view_prefs_id = 0.0
    SELECT INTO "NL:"
     FROM view_prefs vp
     WHERE (vp.application_number=request->vplist[lvar].application_number)
      AND (vp.position_cd=request->vplist[lvar].position_cd)
      AND (vp.prsnl_id=request->vplist[lvar].prsnl_id)
      AND (vp.frame_type=request->vplist[lvar].frame_type)
      AND (vp.view_name=request->vplist[lvar].view_name)
      AND (vp.view_seq=request->vplist[lvar].view_seq)
      AND vp.active_ind=1
     DETAIL
      reply->vplist[lvar].view_prefs_id = vp.view_prefs_id
     WITH nocounter
    ;end select
   ELSEIF ((request->vplist[lvar].action_flag="1"))
    SET reply->vplist[lvar].view_prefs_id = 0.0
    SELECT INTO "nl:"
     z = seq(carenet_seq,nextval)
     FROM dual
     DETAIL
      reply->vplist[lvar].view_prefs_id = cnvtreal(z)
     WITH format, nocounter
    ;end select
    IF ((reply->vplist[lvar].view_prefs_id > 0))
     INSERT  FROM view_prefs vp
      SET vp.view_prefs_id = reply->vplist[lvar].view_prefs_id, vp.application_number = request->
       vplist[lvar].application_number, vp.position_cd = request->vplist[lvar].position_cd,
       vp.prsnl_id = request->vplist[lvar].prsnl_id, vp.frame_type = request->vplist[lvar].frame_type,
       vp.view_name = request->vplist[lvar].view_name,
       vp.view_seq = request->vplist[lvar].view_seq, vp.active_ind = 1, vp.updt_cnt = 0,
       vp.updt_id = reqinfo->updt_id, vp.updt_dt_tm = cnvtdatetime(curdate,curtime), vp.updt_task =
       reqinfo->updt_task,
       vp.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ENDIF
   ELSEIF ((request->vplist[lvar].action_flag="3"))
    DELETE  FROM view_prefs vp
     WHERE (vp.application_number=request->vplist[lvar].application_number)
      AND (vp.position_cd=request->vplist[lvar].position_cd)
      AND (vp.prsnl_id=request->vplist[lvar].prsnl_id)
      AND (vp.frame_type=request->vplist[lvar].frame_type)
      AND (vp.view_name=request->vplist[lvar].view_name)
      AND (vp.view_seq=request->vplist[lvar].view_seq)
     WITH nocounter
    ;end delete
   ENDIF
 ENDFOR
END GO
