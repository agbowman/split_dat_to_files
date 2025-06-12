CREATE PROGRAM cr_upd_sequence_groups:dba
 DECLARE log_program_name = vc WITH protect, noconstant("")
 DECLARE log_override_ind = i2 WITH protect, noconstant(0)
 SET log_program_name = curprog
 SET log_override_ind = 0
 DECLARE log_level_error = i2 WITH protect, noconstant(0)
 DECLARE log_level_warning = i2 WITH protect, noconstant(1)
 DECLARE log_level_audit = i2 WITH protect, noconstant(2)
 DECLARE log_level_info = i2 WITH protect, noconstant(3)
 DECLARE log_level_debug = i2 WITH protect, noconstant(4)
 DECLARE hsys = i4 WITH protect, noconstant(0)
 DECLARE sysstat = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = c132 WITH protect, noconstant(" ")
 DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
 DECLARE crsl_msg_default = h WITH protect, noconstant(0)
 DECLARE crsl_msg_level = h WITH protect, noconstant(0)
 EXECUTE msgrtl
 SET crsl_msg_default = uar_msgdefhandle()
 SET crsl_msg_level = uar_msggetlevel(crsl_msg_default)
 DECLARE lcrslsubeventcnt = i4 WITH protect, noconstant(0)
 DECLARE icrslloggingstat = i2 WITH protect, noconstant(0)
 DECLARE lcrslsubeventsize = i4 WITH protect, noconstant(0)
 DECLARE icrslloglvloverrideind = i2 WITH protect, noconstant(0)
 DECLARE scrsllogtext = vc WITH protect, noconstant("")
 DECLARE scrsllogevent = vc WITH protect, noconstant("")
 DECLARE icrslholdloglevel = i2 WITH protect, noconstant(0)
 DECLARE icrslerroroccured = i2 WITH protect, noconstant(0)
 DECLARE lcrsluarmsgwritestat = i4 WITH protect, noconstant(0)
 DECLARE crsl_info_domain = vc WITH protect, constant("CLINRPT SCRIPT LOGGING")
 DECLARE crsl_logging_on = c1 WITH protect, constant("L")
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=crsl_info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=crsl_logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET icrslloglvloverrideind = 0
   SET scrsllogtext = ""
   SET scrsllogevent = ""
   SET scrsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET icrslholdloglevel = loglvl
   ELSE
    IF (crsl_msg_level < loglvl)
     SET icrslholdloglevel = crsl_msg_level
     SET icrslloglvloverrideind = 1
    ELSE
     SET icrslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (icrslloglvloverrideind=1)
    SET scrsllogevent = "Script_Override"
   ELSE
    CASE (icrslholdloglevel)
     OF log_level_error:
      SET scrsllogevent = "Script_Error"
     OF log_level_warning:
      SET scrsllogevent = "Script_Warning"
     OF log_level_audit:
      SET scrsllogevent = "Script_Audit"
     OF log_level_info:
      SET scrsllogevent = "Script_Info"
     OF log_level_debug:
      SET scrsllogevent = "Script_Debug"
    ENDCASE
   ENDIF
   SET lcrsluarmsgwritestat = uar_msgwrite(crsl_msg_default,0,nullterm(scrsllogevent),
    icrslholdloglevel,nullterm(scrsllogtext))
   CALL echo(logmsg)
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     SET reply->status_data.status = "F"
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus(opname,"F",serrmsg,logmsg)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   IF (icrslerroroccured=1
    AND errorforceexit=1)
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF (qualnum=0
    AND zeroforceexit=1)
    SET reply->status_data.status = "Z"
    CALL populate_subeventstatus(opname,"Z","No records qualified",logmsg)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(reply->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      operationstatus))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectname))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectvalue))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt += 1
     SET icrslloggingstat = alter(reply->status_data.subeventstatus,lcrslsubeventcnt)
    ENDIF
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].targetobjectvalue = targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((crsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SET log_program_name = "CR_UPD_SEQUENCE_GROUPS"
 RECORD reply(
   1 route_type_flag = i2
   1 chart_route_id = f8
   1 route_name = vc
   1 group_qual[*]
     2 sequence_group_id = f8
     2 group_name = vc
     2 sequence_nbr = i4
   1 operations[*]
     2 operation_name = vc
     2 charting_operations_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD delete_seq_group_ids
 RECORD delete_seq_group_ids(
   1 item_qual[*]
     2 sequence_group_id = f8
 )
 FREE RECORD insert_seq_group_reltn
 RECORD insert_seq_group_reltn(
   1 item_qual[*]
     2 location_cd = f8
     2 organization_id = f8
     2 prsnl_id = f8
     2 sequence_group_id = f8
     2 sequence_nbr = i4
 )
 DECLARE nno_error = i2 WITH protect, constant(1)
 DECLARE nccl_error = i2 WITH protect, constant(2)
 DECLARE nupdate_cnt_error = i2 WITH protect, constant(3)
 DECLARE ngen_nbr_error = i2 WITH protect, constant(4)
 DECLARE nroute_in_use = i2 WITH protect, constant(5)
 DECLARE nprovider = i2 WITH protect, constant(1)
 DECLARE norganization = i2 WITH protect, constant(2)
 DECLARE nlocation = i2 WITH protect, constant(3)
 DECLARE sdefault_end_dt_tm = vc WITH public, constant("31-DEC-2100 00:00:00.00")
 DECLARE lroutestops = i4 WITH protect, constant(size(request->group_qual,5))
 DECLARE lcount = i4 WITH protect, noconstant(0)
 DECLARE lloopcounter = i4 WITH protect, noconstant(0)
 DECLARE lselectresult = i4 WITH protect, noconstant(0)
 DECLARE dactivecd = f8 WITH public, noconstant(0.0)
 DECLARE dinactivecd = f8 WITH public, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(48,"ACTIVE",1,dactivecd)
 SET stat = uar_get_meaning_by_codeset(48,"INACTIVE",1,dinactivecd)
 SET stat = alterlist(reply->group_qual,lroutestops)
 SET reply->status_data.status = "F"
 SET reply->route_type_flag = request->route_type_flag
 SET reply->route_name = request->route_name
 SET reply->chart_route_id = request->chart_route_id
 FOR (lloopcounter = 1 TO lroutestops)
   SET reply->group_qual[lloopcounter].sequence_group_id = request->group_qual[lloopcounter].
   sequence_group_id
   SET reply->group_qual[lloopcounter].sequence_nbr = request->group_qual[lloopcounter].sequence_nbr
   SET reply->group_qual[lloopcounter].group_name = request->group_qual[lloopcounter].group_name
 ENDFOR
 SET lselectresult = nno_error
 SET reqinfo->commit_ind = 0
 IF ((request->debug_ind=1))
  CALL echorecord(request)
 ENDIF
 IF ((request->active_ind=0))
  IF ((request->chart_route_id=0))
   CALL log_message("Can not create a new inactive chart route.",log_level_debug)
   GO TO exit_script
  ENDIF
  SELECT INTO "nl:"
   FROM charting_operations co
   WHERE co.active_ind=1
    AND co.param_type_flag=21
    AND co.param=cnvtstring(request->chart_route_id)
   HEAD REPORT
    lcount = 0
   DETAIL
    lcount += 1
    IF (lcount > size(reply->operations,5))
     stat = alterlist(reply->operations,(lcount+ 5))
    ENDIF
    reply->operations[lcount].operation_name = co.batch_name, reply->operations[lcount].
    charting_operations_id = co.charting_operations_id
   FOOT REPORT
    stat = alterlist(reply->operations,lcount)
   WITH nocounter
  ;end select
  IF (curqual > 0)
   SET lselectresult = nroute_in_use
   GO TO exit_script
  ENDIF
 ENDIF
 CALL log_message("Finished with start of script checks.",log_level_debug)
 IF ((request->chart_route_id != 0))
  SELECT INTO "nl:"
   FROM chart_route cr
   WHERE (cr.chart_route_id=request->chart_route_id)
   DETAIL
    IF ((cr.updt_cnt != request->updt_cnt))
     lselectresult = nupdate_cnt_error
    ENDIF
   WITH nocounter, forupdate(cr)
  ;end select
  IF (lselectresult=nupdate_cnt_error)
   GO TO exit_script
  ENDIF
  IF (error_message(1) > 0)
   SET lselectresult = nccl_error
   GO TO exit_script
  ENDIF
  IF (curqual > 0)
   UPDATE  FROM chart_route cr
    SET cr.active_ind = request->active_ind, cr.route_name = request->route_name, cr.route_name_key
      = request->route_name_key,
     cr.route_type_flag = request->route_type_flag, cr.banner_page_ind = request->banner_page_ind, cr
     .updt_applctx = reqinfo->updt_applctx,
     cr.updt_cnt = (cr.updt_cnt+ 1), cr.updt_dt_tm = cnvtdatetime(sysdate), cr.updt_id = reqinfo->
     updt_id,
     cr.updt_task = reqinfo->updt_task
    WHERE (cr.chart_route_id=request->chart_route_id)
    WITH nocounter
   ;end update
   IF (error_message(1) > 0)
    SET lselectresult = nccl_error
    GO TO exit_script
   ENDIF
  ENDIF
 ELSEIF ((request->chart_route_id=0))
  SELECT INTO "nl:"
   newid = seq(reference_seq,nextval)
   FROM dual
   DETAIL
    reply->chart_route_id = newid
   WITH nocounter
  ;end select
  IF (curqual=0)
   SET lselectresult = ngen_nbr_error
   GO TO exit_script
  ENDIF
  INSERT  FROM chart_route cr
   SET cr.chart_route_id = reply->chart_route_id, cr.active_ind = request->active_ind, cr.route_name
     = request->route_name,
    cr.route_name_key = request->route_name_key, cr.route_type_flag = request->route_type_flag, cr
    .banner_page_ind = request->banner_page_ind,
    cr.updt_applctx = reqinfo->updt_applctx, cr.updt_cnt = 0, cr.updt_dt_tm = cnvtdatetime(sysdate),
    cr.updt_id = reqinfo->updt_id, cr.updt_task = reqinfo->updt_task
   WITH nocounter
  ;end insert
  IF (error_message(1) > 0)
   SET lselectresult = nccl_error
   GO TO exit_script
  ENDIF
 ENDIF
 CALL log_message("Finished with CHART_ROUTE update.",log_level_debug)
 IF ((request->active_ind=0))
  UPDATE  FROM chart_sequence_group csg
   SET csg.active_ind = 0
   WHERE (csg.chart_route_id=reply->chart_route_id)
   WITH nocounter
  ;end update
  IF (error_message(1) > 0)
   SET lselectresult = nccl_error
   GO TO exit_script
  ENDIF
 ELSEIF (lroutestops > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(lroutestops)),
    chart_sequence_group csg
   PLAN (d
    WHERE (request->group_qual[d.seq].sequence_group_id > 0))
    JOIN (csg
    WHERE (csg.sequence_group_id=request->group_qual[d.seq].sequence_group_id))
   DETAIL
    IF ((csg.updt_cnt != request->group_qual[d.seq].updt_cnt))
     lselectresult = nupdate_cnt_error
    ENDIF
   WITH nocounter, forupdate(cr)
  ;end select
  IF (lselectresult=nupdate_cnt_error)
   GO TO exit_script
  ENDIF
  IF (error_message(1) > 0)
   SET lselectresult = nccl_error
   GO TO exit_script
  ENDIF
  IF ((request->debug_ind=1))
   CALL echo("Finished checking for locks to update CHART_SEQUENCE_GROUP")
  ENDIF
  IF (curqual > 0)
   IF ((request->debug_ind=1))
    CALL echo("Locks found for update to CHART_SEQUENCE_GROUP")
   ENDIF
   UPDATE  FROM (dummyt d  WITH seq = value(lroutestops)),
     chart_sequence_group csg
    SET csg.active_ind = request->group_qual[d.seq].active_ind, csg.active_status_cd = evaluate(
      request->group_qual[d.seq].active_ind,1,dactivecd,0,dinactivecd), csg.active_status_dt_tm =
     cnvtdatetime(sysdate),
     csg.active_status_prsnl_id = reqinfo->updt_id, csg.chart_route_id = reply->chart_route_id, csg
     .group_name = request->group_qual[d.seq].group_name,
     csg.sequence_nbr = request->group_qual[d.seq].sequence_nbr, csg.updt_applctx = reqinfo->
     updt_applctx, csg.updt_cnt = (csg.updt_cnt+ 1),
     csg.updt_dt_tm = cnvtdatetime(sysdate), csg.updt_id = reqinfo->updt_id, csg.updt_task = reqinfo
     ->updt_task
    PLAN (d
     WHERE (request->group_qual[d.seq].sequence_group_id > 0))
     JOIN (csg
     WHERE (csg.sequence_group_id=request->group_qual[d.seq].sequence_group_id))
    WITH nocounter
   ;end update
   IF (error_message(1) > 0)
    SET lselectresult = nccl_error
    GO TO exit_script
   ENDIF
  ENDIF
  FOR (lloopcounter = 1 TO lroutestops)
    IF ((request->group_qual[lloopcounter].sequence_group_id=0))
     CALL echo("attempting to get a sequence number for group sequence")
     SELECT INTO "nl:"
      newid = seq(reference_seq,nextval)
      FROM dual
      DETAIL
       reply->group_qual[lloopcounter].sequence_group_id = newid
      WITH nocountert
     ;end select
     IF (curqual=0)
      SET lselectresult = ngen_nbr_error
      GO TO exit_script
     ENDIF
    ENDIF
  ENDFOR
  CALL echorecord(reply)
  IF (lroutestops > 0)
   INSERT  FROM chart_sequence_group csg,
     (dummyt d  WITH seq = value(lroutestops))
    SET csg.active_ind = request->group_qual[d.seq].active_ind, csg.active_status_cd = evaluate(
      request->group_qual[d.seq].active_ind,1,dactivecd,0,dinactivecd), csg.active_status_dt_tm =
     cnvtdatetime(sysdate),
     csg.active_status_prsnl_id = reqinfo->updt_id, csg.chart_route_id = reply->chart_route_id, csg
     .group_name = request->group_qual[d.seq].group_name,
     csg.sequence_group_id = reply->group_qual[d.seq].sequence_group_id, csg.sequence_nbr = request->
     group_qual[d.seq].sequence_nbr, csg.updt_applctx = reqinfo->updt_applctx,
     csg.updt_cnt = 0, csg.updt_dt_tm = cnvtdatetime(sysdate), csg.updt_id = reqinfo->updt_id,
     csg.updt_task = reqinfo->updt_task
    PLAN (d
     WHERE (request->group_qual[d.seq].sequence_group_id=0))
     JOIN (csg)
    WITH nocounter
   ;end insert
   IF (error_message(1) > 0)
    SET lselectresult = nccl_error
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 CALL log_message("Finished with update and insert of CHART_SEQUENCE_GROUP.",log_level_debug)
 IF ((request->active_ind=0))
  DELETE  FROM chart_seq_group_reltn csgr
   WHERE csgr.sequence_group_id IN (
   (SELECT
    csg.sequence_group_id
    FROM chart_sequence_group csg
    WHERE (csg.chart_route_id=request->chart_route_id)
    WITH nocounter))
   WITH nocounter
  ;end delete
  IF (error_message(1) > 0)
   SET lselectresult = nccl_error
   GO TO exit_script
  ENDIF
 ELSEIF (lroutestops > 0)
  SET lcount = 0
  FOR (lloopcounter = 1 TO lroutestops)
    IF ((((request->group_qual[lloopcounter].sequence_group_id > 0)
     AND size(request->group_qual[lloopcounter].item_qual,5) > 0) OR ((request->group_qual[
    lloopcounter].active_ind=0))) )
     SET lcount += 1
     IF (lcount > size(delete_seq_group_ids->item_qual,5))
      SET stat = alterlist(delete_seq_group_ids->item_qual,(lcount+ 10))
     ENDIF
     SET delete_seq_group_ids->item_qual[lcount].sequence_group_id = request->group_qual[lloopcounter
     ].sequence_group_id
    ENDIF
  ENDFOR
  SET stat = alterlist(delete_seq_group_ids->item_qual,lcount)
  IF ((request->debug_ind=1))
   CALL echorecord(delete_seq_group_ids)
  ENDIF
  IF (size(delete_seq_group_ids->item_qual,5) > 0)
   DELETE  FROM chart_seq_group_reltn csgr,
     (dummyt d  WITH seq = value(size(delete_seq_group_ids->item_qual,5)))
    SET csgr.seq = 1
    PLAN (d)
     JOIN (csgr
     WHERE (csgr.sequence_group_id=delete_seq_group_ids->item_qual[d.seq].sequence_group_id))
    WITH nocounter
   ;end delete
   IF (error_message(1) > 0)
    SET lselectresult = nccl_error
    GO TO exit_script
   ENDIF
  ENDIF
  IF ((request->debug_ind=1))
   CALL echo("building a List of rows to insert.")
  ENDIF
  SELECT INTO "nl:"
   FROM (dummyt d1  WITH seq = value(lroutestops)),
    (dummyt d2  WITH seq = 1)
   PLAN (d1
    WHERE maxrec(d2,size(request->group_qual[d1.seq].item_qual,5)))
    JOIN (d2)
   HEAD REPORT
    lcount = 0
   DETAIL
    IF ((request->group_qual[d1.seq].active_ind > 0))
     lcount += 1
     IF (lcount > size(insert_seq_group_reltn->item_qual,5))
      stat = alterlist(insert_seq_group_reltn->item_qual,(lcount+ 10))
     ENDIF
     insert_seq_group_reltn->item_qual[lcount].sequence_group_id = reply->group_qual[d1.seq].
     sequence_group_id, insert_seq_group_reltn->item_qual[lcount].sequence_nbr = request->group_qual[
     d1.seq].item_qual[d2.seq].sequence_nbr
     CASE (request->route_type_flag)
      OF nprovider:
       insert_seq_group_reltn->item_qual[lcount].prsnl_id = request->group_qual[d1.seq].item_qual[d2
       .seq].entity_id
      OF norganization:
       insert_seq_group_reltn->item_qual[lcount].organization_id = request->group_qual[d1.seq].
       item_qual[d2.seq].entity_id
      OF nlocation:
       insert_seq_group_reltn->item_qual[lcount].location_cd = request->group_qual[d1.seq].item_qual[
       d2.seq].entity_id
     ENDCASE
    ENDIF
   FOOT REPORT
    stat = alterlist(insert_seq_group_reltn->item_qual,lcount)
   WITH nocounter
  ;end select
  IF (error_message(1) > 0)
   SET lselectresult = nccl_error
   GO TO exit_script
  ENDIF
  IF ((request->debug_ind=1))
   CALL echorecord(insert_seq_group_reltn)
  ENDIF
  IF (lcount > 0)
   INSERT  FROM (dummyt d  WITH seq = value(size(insert_seq_group_reltn->item_qual,5))),
     chart_seq_group_reltn csgr
    SET csgr.active_ind = 1, csgr.active_status_cd = dactivecd, csgr.active_status_dt_tm =
     cnvtdatetime(sysdate),
     csgr.active_status_prsnl_id = reqinfo->updt_id, csgr.group_reltn_id = seq(reference_seq,nextval),
     csgr.prsnl_id = insert_seq_group_reltn->item_qual[d.seq].prsnl_id,
     csgr.organization_id = insert_seq_group_reltn->item_qual[d.seq].organization_id, csgr
     .location_cd = insert_seq_group_reltn->item_qual[d.seq].location_cd, csgr.sequence_group_id =
     insert_seq_group_reltn->item_qual[d.seq].sequence_group_id,
     csgr.sequence_nbr = insert_seq_group_reltn->item_qual[d.seq].sequence_nbr, csgr.updt_applctx =
     reqinfo->updt_applctx, csgr.updt_cnt = 0,
     csgr.updt_dt_tm = cnvtdatetime(sysdate), csgr.updt_id = reqinfo->updt_id, csgr.updt_task =
     reqinfo->updt_task
    PLAN (d)
     JOIN (csgr)
    WITH nocounter
   ;end insert
   IF (error_message(1) > 0)
    SET lselectresult = nccl_error
    GO TO exit_script
   ENDIF
  ENDIF
 ENDIF
 CALL log_message("Finished with CHART_SEQ_GROUP_RELTN update.",log_level_debug)
#exit_script
 CASE (lselectresult)
  OF nno_error:
   CALL log_message("Queues successfully updated.",log_level_debug)
   SET reply->status_data.status = "S"
   SET reqinfo->commit_ind = 1
  OF nccl_error:
   CALL log_message("CCL error message was logged.",log_level_debug)
   SET reply->status_data.status = "F"
  OF nupdate_cnt_error:
   CALL log_message("Update counters do not match.",log_level_debug)
   SET reply->status_data.status = "U"
  OF ngen_nbr_error:
   CALL log_message("Unable to retrieve new ID.",log_level_debug)
   SET reply->status_data.status = "F"
  OF nroute_in_use:
   CALL log_message("Route is being used by an operation.",log_level_debug)
   SET reply->status_data.status = "D"
  ELSE
   CALL log_message("Unknown error.",log_level_debug)
   SET reply->status_data.status = "F"
 ENDCASE
 IF ((request->debug_ind=1))
  CALL echorecord(reply)
 ENDIF
 FREE RECORD insert_chart_sequence_groups
 FREE RECORD delete_seq_group_ids
 FREE RECORD insert_seq_group_reltn
 CALL log_message("End of script: cr_upd_sequence_groups",log_level_debug)
END GO
