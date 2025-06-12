CREATE PROGRAM bb_upd_qc_troubleshooting:dba
 SET modify = predeclare
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
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 DECLARE ninformational = i2 WITH protect, constant(0)
 DECLARE ninsert = i2 WITH protect, constant(1)
 DECLARE nupdate = i2 WITH protect, constant(2)
 DECLARE ndelete = i2 WITH protect, constant(3)
 DECLARE nerrorcnt = i2 WITH protect, noconstant(0)
 DECLARE ncount1 = i2 WITH protect, noconstant(0)
 DECLARE serror = c132 WITH protect, noconstant(" ")
 DECLARE dcurdate = f8 WITH protect, constant(cnvtdatetime(curdate,curtime3))
 DECLARE denddate = f8 WITH protect, constant(cnvtdatetime("31-DEC-2100 23:59:59.99"))
 SET reply->status_data.status = "F"
 IF (size(request->troubleshootinglist,5) > 0)
  FOR (ncount1 = 1 TO size(request->troubleshootinglist,5))
    IF ((request->troubleshootinglist[ncount1].save_flag=nupdate))
     SET nerrorcnt = 0
     SELECT INTO "nl:"
      *
      FROM bb_qc_troubleshooting bbqct
      WHERE (bbqct.troubleshooting_id=request->troubleshootinglist[ncount1].troubleshooting_id)
      DETAIL
       IF ((request->troubleshootinglist[ncount1].updt_cnt != bbqct.updt_cnt))
        stat = subevent_add("SELECT","F","BB_QC_TROUBLESHOOTING",build("troubleshooting id=",request
          ->troubleshootinglist[ncount1].troubleshooting_id,"with update count=",request->
          troubleshootinglist[ncount1].updt_cnt,
          " has been updated by another process since loaded by this application.")), nerrorcnt = (
        nerrorcnt+ 1)
       ENDIF
      WITH nocounter, forupdate(bbqct)
     ;end select
     IF (error(serror,0) > 0)
      CALL subevent_add("EXECUTE","F","bb_upd_qc_troubleshooting",serror)
      GO TO exit_script
     ENDIF
     SELECT INTO "nl:"
      *
      FROM long_text_reference lt
      WHERE (lt.long_text_id=request->troubleshootinglist[ncount1].troubleshooting_text_id)
      DETAIL
       IF ((request->troubleshootinglist[ncount1].updt_cnt != lt.updt_cnt))
        stat = subevent_add("SELECT","F","LONG_TEXT_REFERENCE",build("long text id=",request->
          troubleshootinglist[ncount1].troubleshooting_text_id,"with update count=",request->
          troubleshootinglist[ncount1].updt_cnt,
          " has been updated by another process since being loaded by this application.")), nerrorcnt
         = (nerrorcnt+ 1)
       ENDIF
      WITH nocounter, forupdate(lt)
     ;end select
     IF (error(serror,0) > 0)
      CALL subevent_add("EXECUTE","F","bb_upd_qc_troubleshooting",serror)
      GO TO exit_script
     ENDIF
     UPDATE  FROM bb_qc_troubleshooting bbqct
      SET bbqct.troubleshooting_id = request->troubleshootinglist[ncount1].troubleshooting_id, bbqct
       .troubleshooting_text_id = request->troubleshootinglist[ncount1].troubleshooting_text_id,
       bbqct.active_ind = request->troubleshootinglist[ncount1].active_ind,
       bbqct.end_effective_dt_tm =
       IF ((request->troubleshootinglist[ncount1].active_ind=0)) cnvtdatetime(dcurdate)
       ELSE cnvtdatetime(denddate)
       ENDIF
       , bbqct.updt_cnt = (request->troubleshootinglist[ncount1].updt_cnt+ 1), bbqct.updt_applctx =
       reqinfo->updt_applctx,
       bbqct.updt_dt_tm = cnvtdatetime(curdate,curtime3), bbqct.updt_id = reqinfo->updt_id, bbqct
       .updt_task = reqinfo->updt_task
      WHERE (bbqct.troubleshooting_id=request->troubleshootinglist[ncount1].troubleshooting_id)
      WITH nocounter
     ;end update
     IF (error(serror,0) > 0)
      CALL subevent_add("EXECUTE","F","bb_upd_qc_troubleshooting",serror)
      GO TO exit_script
     ENDIF
     UPDATE  FROM long_text_reference lt
      SET lt.active_ind = request->troubleshootinglist[ncount1].active_ind, lt.long_text = request->
       troubleshootinglist[ncount1].long_text, lt.active_status_cd =
       IF ((request->troubleshootinglist[ncount1].active_ind=0)) reqdata->inactive_status_cd
       ELSE reqdata->active_status_cd
       ENDIF
       ,
       lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo->
       updt_id, lt.parent_entity_name = "BB_QC_TROUBLESHOOTING",
       lt.parent_entity_id = request->troubleshootinglist[ncount1].troubleshooting_id, lt.updt_cnt =
       (lt.updt_cnt+ 1), lt.updt_applctx = reqinfo->updt_applctx,
       lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt.updt_id = reqinfo->updt_id, lt.updt_task =
       reqinfo->updt_task
      WHERE (lt.long_text_id=request->troubleshootinglist[ncount1].troubleshooting_text_id)
      WITH nocounter
     ;end update
     IF (error(serror,0) > 0)
      CALL subevent_add("EXECUTE","F","bb_upd_qc_troubleshooting",serror)
      GO TO exit_script
     ENDIF
    ELSEIF ((request->troubleshootinglist[ncount1].save_flag=ninsert))
     INSERT  FROM long_text_reference lt
      SET lt.long_text_id = request->troubleshootinglist[ncount1].troubleshooting_text_id, lt
       .active_ind = request->troubleshootinglist[ncount1].active_ind, lt.long_text = request->
       troubleshootinglist[ncount1].long_text,
       lt.active_status_cd =
       IF ((request->troubleshootinglist[ncount1].active_ind=0)) reqdata->inactive_status_cd
       ELSE reqdata->active_status_cd
       ENDIF
       , lt.active_status_dt_tm = cnvtdatetime(curdate,curtime3), lt.active_status_prsnl_id = reqinfo
       ->updt_id,
       lt.parent_entity_name = "BB_QC_TROUBLESHOOTING", lt.parent_entity_id = request->
       troubleshootinglist[ncount1].troubleshooting_id, lt.updt_cnt = 0,
       lt.updt_applctx = reqinfo->updt_applctx, lt.updt_dt_tm = cnvtdatetime(curdate,curtime3), lt
       .updt_id = reqinfo->updt_id,
       lt.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (error(serror,0) > 0)
      CALL subevent_add("EXECUTE","F","bb_upd_qc_troubleshooting",serror)
      GO TO exit_script
     ENDIF
     INSERT  FROM bb_qc_troubleshooting bbqct
      SET bbqct.troubleshooting_id = request->troubleshootinglist[ncount1].troubleshooting_id, bbqct
       .troubleshooting_text_id = request->troubleshootinglist[ncount1].troubleshooting_text_id,
       bbqct.active_ind = request->troubleshootinglist[ncount1].active_ind,
       bbqct.beg_effective_dt_tm = cnvtdatetime(dcurdate), bbqct.end_effective_dt_tm = cnvtdatetime(
        denddate), bbqct.updt_cnt = 0,
       bbqct.updt_applctx = reqinfo->updt_applctx, bbqct.updt_dt_tm = cnvtdatetime(curdate,curtime3),
       bbqct.updt_id = reqinfo->updt_id,
       bbqct.updt_task = reqinfo->updt_task
      WITH nocounter
     ;end insert
     IF (error(serror,0) > 0)
      CALL subevent_add("EXECUTE","F","bb_upd_qc_troubleshooting",serror)
      GO TO exit_script
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 IF (error(serror,0) > 0)
  CALL subevent_add("EXECUTE","F","bb_upd_qc_troubleshooting",serror)
  GO TO exit_script
 ENDIF
 IF (value(size(request->troubleshootinglist,5))=0)
  SET reply->status_data.status = "Z"
  CALL subevent_add("UPDATE","Z","bb_upd_qc_troubleshooting","No troubleshooting steps found.")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
END GO
