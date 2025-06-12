CREATE PROGRAM bb_upd_print_servers:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE script_name = c20 WITH constant("bb_upd_print_servers")
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE add_ind = i2 WITH constant(1)
 DECLARE change_ind = i2 WITH constant(2)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 FOR (i_idx = 1 TO size(request->serverlist,5))
   SELECT INTO "nl:"
    FROM bb_print_server ps
    WHERE (ps.bb_print_server_id=request->serverlist[i_idx].bb_print_server_id)
    WITH nocounter, forupdate(ps)
   ;end select
   IF (curqual > 0
    AND (request->serverlist[i_idx].add_change_ind=add_ind))
    SET request->serverlist[i_idx].add_change_ind = change_ind
   ENDIF
   IF ((request->serverlist[i_idx].add_change_ind=change_ind)
    AND (request->serverlist[i_idx].active_ind=1))
    UPDATE  FROM bb_print_server ps
     SET ps.active_ind = request->serverlist[i_idx].active_ind, ps.ip_addr = request->serverlist[
      i_idx].ip_addr, ps.port_addr = request->serverlist[i_idx].port_addr,
      ps.redun_parent_server_id = request->serverlist[i_idx].redun_parent_server_id, ps
      .server_description_txt = request->serverlist[i_idx].server_description_txt, ps.server_name =
      request->serverlist[i_idx].server_name,
      ps.updt_cnt = (ps.updt_cnt+ 1), ps.updt_applctx = reqinfo->updt_applctx, ps.updt_dt_tm =
      cnvtdatetime(sysdate),
      ps.updt_id = reqinfo->updt_id, ps.updt_task = reqinfo->updt_task
     WHERE (ps.bb_print_server_id=request->serverlist[i_idx].bb_print_server_id)
     WITH nocounter
    ;end update
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("F","Upd bb_print_server",errmsg)
    ENDIF
   ELSEIF ((request->serverlist[i_idx].add_change_ind=change_ind)
    AND (request->serverlist[i_idx].active_ind=0))
    DELETE  FROM bb_print_server ps
     WHERE (ps.bb_print_server_id=request->serverlist[i_idx].bb_print_server_id)
     WITH nocounter
    ;end delete
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("F","Del bb_print_server",errmsg)
    ENDIF
   ELSEIF ((request->serverlist[i_idx].add_change_ind=add_ind))
    INSERT  FROM bb_print_server ps
     SET ps.active_ind = request->serverlist[i_idx].active_ind, ps.active_status_cd = reqdata->
      active_status_cd, ps.active_status_dt_tm = cnvtdatetime(sysdate),
      ps.active_status_prsnl_id = reqinfo->updt_id, ps.bb_print_server_id = request->serverlist[i_idx
      ].bb_print_server_id, ps.ip_addr = request->serverlist[i_idx].ip_addr,
      ps.port_addr = request->serverlist[i_idx].port_addr, ps.redun_parent_server_id = request->
      serverlist[i_idx].redun_parent_server_id, ps.server_description_txt = request->serverlist[i_idx
      ].server_description_txt,
      ps.server_name = request->serverlist[i_idx].server_name
     WITH nocounter
    ;end insert
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("F","Insert bb_print_server.",errmsg)
    ENDIF
   ENDIF
 ENDFOR
 GO TO set_status
 SUBROUTINE (errorhandler(operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc) =null)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt += 1
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = script_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   SET reqinfo->commit_ind = 0
   GO TO exit_script
 END ;Subroutine
#set_status
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
END GO
