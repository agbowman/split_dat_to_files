CREATE PROGRAM bb_upd_printers:dba
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
 DECLARE script_name = c20 WITH constant("bb_upd_printers")
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE add_ind = i2 WITH constant(1)
 DECLARE change_ind = i2 WITH constant(2)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 FOR (i_idx = 1 TO size(request->printerlist,5))
   SELECT INTO "nl:"
    FROM bb_printer p
    WHERE (p.bb_printer_id=request->printerlist[i_idx].bb_printer_id)
    WITH nocounter, forupdate(p)
   ;end select
   IF (curqual > 0
    AND (request->printerlist[i_idx].add_change_ind=add_ind))
    SET request->printerlist[i_idx].add_change_ind = change_ind
   ENDIF
   IF ((request->printerlist[i_idx].add_change_ind=change_ind)
    AND (request->printerlist[i_idx].active_ind=1))
    UPDATE  FROM bb_printer p
     SET p.active_ind = request->printerlist[i_idx].active_ind, p.baud_rate_nbr = request->
      printerlist[i_idx].baud_rate_nbr, p.bb_printer_id = request->printerlist[i_idx].bb_printer_id,
      p.crc_ind = request->printerlist[i_idx].crc_ind, p.horizontal_offset_nbr = request->
      printerlist[i_idx].horizontal_offset_nbr, p.printer_addr = request->printerlist[i_idx].
      printer_addr,
      p.label_type_cd = request->printerlist[i_idx].label_type_cd, p.model_cd = request->printerlist[
      i_idx].model_cd, p.port_addr = request->printerlist[i_idx].port_addr,
      p.printer_description_txt = request->printerlist[i_idx].printer_description_txt, p.printer_name
       = request->printerlist[i_idx].printer_name, p.printer_name_key = request->printerlist[i_idx].
      printer_name_key,
      p.vertical_offset_nbr = request->printerlist[i_idx].vertical_offset_nbr, p.updt_cnt = (p
      .updt_cnt+ 1), p.updt_applctx = reqinfo->updt_applctx,
      p.updt_dt_tm = cnvtdatetime(sysdate), p.updt_id = reqinfo->updt_id, p.updt_task = reqinfo->
      updt_task
     WHERE (p.bb_printer_id=request->printerlist[i_idx].bb_printer_id)
     WITH nocounter
    ;end update
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("F","Upd bb_printer",errmsg)
    ENDIF
   ELSEIF ((request->printerlist[i_idx].add_change_ind=add_ind))
    INSERT  FROM bb_printer p
     SET p.active_ind = request->printerlist[i_idx].active_ind, p.active_status_cd = reqdata->
      active_status_cd, p.active_status_dt_tm = cnvtdatetime(sysdate),
      p.active_status_prsnl_id = reqinfo->updt_id, p.bb_printer_id = request->printerlist[i_idx].
      bb_printer_id, p.baud_rate_nbr = request->printerlist[i_idx].baud_rate_nbr,
      p.crc_ind = request->printerlist[i_idx].crc_ind, p.horizontal_offset_nbr = request->
      printerlist[i_idx].horizontal_offset_nbr, p.printer_addr = request->printerlist[i_idx].
      printer_addr,
      p.label_type_cd = request->printerlist[i_idx].label_type_cd, p.model_cd = request->printerlist[
      i_idx].model_cd, p.port_addr = request->printerlist[i_idx].port_addr,
      p.printer_description_txt = request->printerlist[i_idx].printer_description_txt, p.printer_name
       = request->printerlist[i_idx].printer_name, p.printer_name_key = request->printerlist[i_idx].
      printer_name_key,
      p.vertical_offset_nbr = request->printerlist[i_idx].vertical_offset_nbr
     WITH nocounter
    ;end insert
    SET error_check = error(errmsg,0)
    IF (error_check != 0)
     CALL errorhandler("F","Insert bb_printer",errmsg)
    ENDIF
   ENDIF
   FOR (j_idx = 1 TO size(request->printerlist[i_idx].serverprinterreltn,5))
    SELECT INTO "nl:"
     FROM bb_server_printer_r spr
     WHERE (spr.bb_server_printer_r_id=request->printerlist[i_idx].serverprinterreltn[j_idx].
     bb_server_printer_r_id)
     WITH nocounter, forupdate(spr)
    ;end select
    IF ((request->printerlist[i_idx].add_change_ind=change_ind)
     AND (request->printerlist[i_idx].active_ind=1))
     UPDATE  FROM bb_server_printer_r spr
      SET spr.active_ind = request->printerlist[i_idx].active_ind, spr.bb_print_server_id = request->
       printerlist[i_idx].serverprinterreltn[j_idx].bb_print_server_id, spr.bb_server_printer_r_id =
       request->printerlist[i_idx].serverprinterreltn[j_idx].bb_server_printer_r_id,
       spr.updt_cnt = (spr.updt_cnt+ 1), spr.updt_applctx = reqinfo->updt_applctx, spr.updt_dt_tm =
       cnvtdatetime(sysdate),
       spr.updt_id = reqinfo->updt_id, spr.updt_task = reqinfo->updt_task
      WHERE (spr.bb_server_printer_r_id=request->printerlist[i_idx].serverprinterreltn[j_idx].
      bb_server_printer_r_id)
      WITH nocounter
     ;end update
     SET error_check = error(errmsg,0)
     IF (error_check != 0)
      CALL errorhandler("F","Upd bb_server_printer_r",errmsg)
     ENDIF
    ELSEIF ((request->printerlist[i_idx].add_change_ind=change_ind)
     AND (request->printerlist[i_idx].active_ind=0))
     DELETE  FROM bb_server_printer_r spr
      WHERE (spr.bb_server_printer_r_id=request->printerlist[i_idx].serverprinterreltn[j_idx].
      bb_server_printer_r_id)
      WITH nocounter
     ;end delete
     SET error_check = error(errmsg,0)
     IF (error_check != 0)
      CALL errorhandler("F","Del bb_server_printer_r",errmsg)
     ENDIF
     DELETE  FROM bb_printer p
      WHERE (p.bb_printer_id=request->printerlist[i_idx].bb_printer_id)
      WITH nocounter
     ;end delete
     SET error_check = error(errmsg,0)
     IF (error_check != 0)
      CALL errorhandler("F","Del bb_printer",errmsg)
     ENDIF
    ELSEIF ((request->printerlist[i_idx].add_change_ind=add_ind))
     INSERT  FROM bb_server_printer_r spr
      SET spr.active_ind = request->printerlist[i_idx].active_ind, spr.active_status_cd = reqdata->
       active_status_cd, spr.active_status_dt_tm = cnvtdatetime(sysdate),
       spr.active_status_prsnl_id = reqinfo->updt_id, spr.bb_printer_id = request->printerlist[i_idx]
       .bb_printer_id, spr.bb_print_server_id = request->printerlist[i_idx].serverprinterreltn[j_idx]
       .bb_print_server_id,
       spr.bb_server_printer_r_id = request->printerlist[i_idx].serverprinterreltn[j_idx].
       bb_server_printer_r_id
      WITH nocounter
     ;end insert
     SET error_check = error(errmsg,0)
     IF (error_check != 0)
      CALL errorhandler("F","Ins bb_server_printer_r",errmsg)
     ENDIF
    ENDIF
   ENDFOR
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
