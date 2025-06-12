CREATE PROGRAM bed_get_ens_view_comp_prefs:dba
 FREE SET reply
 RECORD reply(
   1 vcplist[*]
     2 view_comp_prefs_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET listcount = 0
 SET listcount = size(request->vcplist,5)
 SET stat = alterlist(reply->vcplist,listcount)
 FOR (lvar = 1 TO listcount)
   IF ((request->vcplist[lvar].action_flag="0"))
    SET reply->vcplist[lvar].view_comp_prefs_id = 0.0
    SELECT INTO "NL:"
     FROM view_comp_prefs vcp
     WHERE (vcp.application_number=request->vcplist[lvar].application_number)
      AND (vcp.position_cd=request->vcplist[lvar].position_cd)
      AND (vcp.prsnl_id=request->vcplist[lvar].prsnl_id)
      AND (vcp.view_name=request->vcplist[lvar].view_name)
      AND (vcp.view_seq=request->vcplist[lvar].view_seq)
      AND (vcp.comp_name=request->vcplist[lvar].comp_name)
      AND (vcp.comp_seq=request->vcplist[lvar].comp_seq)
      AND vcp.active_ind=1
     DETAIL
      reply->vcplist[lvar].view_comp_prefs_id = vcp.view_comp_prefs_id
     WITH nocounter
    ;end select
   ELSEIF ((request->vcplist[lvar].action_flag="1"))
    SET reply->vcplist[lvar].view_comp_prefs_id = 0.0
    SELECT INTO "nl:"
     z = seq(carenet_seq,nextval)
     FROM dual
     DETAIL
      reply->vcplist[lvar].view_comp_prefs_id = cnvtreal(z)
     WITH format, nocounter
    ;end select
    IF ((reply->vcplist[lvar].view_comp_prefs_id > 0))
     INSERT  FROM view_comp_prefs vcp
      SET vcp.view_comp_prefs_id = reply->vcplist[lvar].view_comp_prefs_id, vcp.application_number =
       request->vcplist[lvar].application_number, vcp.position_cd = request->vcplist[lvar].
       position_cd,
       vcp.prsnl_id = request->vcplist[lvar].prsnl_id, vcp.view_name = request->vcplist[lvar].
       view_name, vcp.view_seq = request->vcplist[lvar].view_seq,
       vcp.comp_name = request->vcplist[lvar].comp_name, vcp.comp_seq = request->vcplist[lvar].
       comp_seq, vcp.active_ind = 1,
       vcp.updt_cnt = 0, vcp.updt_id = reqinfo->updt_id, vcp.updt_dt_tm = cnvtdatetime(curdate,
        curtime),
       vcp.updt_task = reqinfo->updt_task, vcp.updt_applctx = reqinfo->updt_applctx
      WITH nocounter
     ;end insert
    ENDIF
   ELSEIF ((request->vcplist[lvar].action_flag="3"))
    DELETE  FROM view_comp_prefs vcp
     WHERE (vcp.application_number=request->vcplist[lvar].application_number)
      AND (vcp.position_cd=request->vcplist[lvar].position_cd)
      AND (vcp.prsnl_id=request->vcplist[lvar].prsnl_id)
      AND (vcp.view_name=request->vcplist[lvar].view_name)
      AND (vcp.view_seq=request->vcplist[lvar].view_seq)
      AND (vcp.comp_name=request->vcplist[lvar].comp_name)
      AND (vcp.comp_seq=request->vcplist[lvar].comp_seq)
     WITH nocounter
    ;end delete
   ENDIF
 ENDFOR
END GO
