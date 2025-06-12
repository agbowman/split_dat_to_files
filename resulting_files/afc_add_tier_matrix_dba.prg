CREATE PROGRAM afc_add_tier_matrix:dba
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 IF (validate(logsolutioncapability,char(128))=char(128))
  SUBROUTINE (logsolutioncapability(teamname=vc,capability_ident=vc,entityid=f8,entity_name=vc) =i2)
    RECORD capabilityrequest(
      1 teamname = vc
      1 capability_ident = vc
      1 entities[1]
        2 entity_id = f8
        2 entity_name = vc
    ) WITH protect
    RECORD capabilityreply(
      1 status_data
        2 status = c1
        2 subeventstatus[1]
          3 operationname = c25
          3 operationstatus = c1
          3 targetobjectname = c25
          3 targetobjectvalue = vc
    ) WITH protect
    SET capabilityrequest->teamname = teamname
    SET capabilityrequest->capability_ident = capability_ident
    SET capabilityrequest->entities[1].entity_id = entityid
    SET capabilityrequest->entities[1].entity_name = entity_name
    EXECUTE pft_log_solution_capability  WITH replace("REQUEST",capabilityrequest), replace("REPLY",
     capabilityreply)
    IF ((capabilityreply->status_data.status != "S"))
     RETURN(false)
    ENDIF
    RETURN(true)
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(log_error)))
  DECLARE log_error = i4 WITH protect, constant(0)
 ENDIF
 IF ( NOT (validate(log_warning)))
  DECLARE log_warning = i4 WITH protect, constant(1)
 ENDIF
 IF ( NOT (validate(log_audit)))
  DECLARE log_audit = i4 WITH protect, constant(2)
 ENDIF
 IF ( NOT (validate(log_info)))
  DECLARE log_info = i4 WITH protect, constant(3)
 ENDIF
 IF ( NOT (validate(log_debug)))
  DECLARE log_debug = i4 WITH protect, constant(4)
 ENDIF
 DECLARE __lpahsys = i4 WITH protect, noconstant(0)
 DECLARE __lpalsysstat = i4 WITH protect, noconstant(0)
 IF (validate(logmessage,char(128))=char(128))
  SUBROUTINE (logmessage(psubroutine=vc,pmessage=vc,plevel=i4) =null)
    DECLARE cs23372_failed_cd = f8 WITH protect, constant(uar_get_code_by("MEANING",23372,"FAILED"))
    DECLARE hmsg = i4 WITH protect, noconstant(0)
    DECLARE hreq = i4 WITH protect, noconstant(0)
    DECLARE hrep = i4 WITH protect, noconstant(0)
    DECLARE hobjarray = i4 WITH protect, noconstant(0)
    DECLARE srvstatus = i4 WITH protect, noconstant(0)
    DECLARE submit_log = i4 WITH protect, constant(4099455)
    CALL echo("")
    CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
    IF (size(trim(psubroutine,3)) > 0)
     CALL echo(concat(curprog," : ",psubroutine,"() : ",pmessage))
    ELSE
     CALL echo(concat(curprog," : ",pmessage))
    ENDIF
    CALL echo("::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::")
    CALL echo("")
    SET __lpahsys = 0
    SET __lpalsysstat = 0
    CALL uar_syscreatehandle(__lpahsys,__lpalsysstat)
    IF (__lpahsys > 0)
     CALL uar_sysevent(__lpahsys,plevel,curprog,nullterm(pmessage))
     CALL uar_sysdestroyhandle(__lpahsys)
    ENDIF
    IF (plevel=log_error)
     SET hmsg = uar_srvselectmessage(submit_log)
     SET hreq = uar_srvcreaterequest(hmsg)
     SET hrep = uar_srvcreatereply(hmsg)
     SET hobjarray = uar_srvadditem(hreq,"objArray")
     SET stat = uar_srvsetdouble(hobjarray,"final_status_cd",cs23372_failed_cd)
     SET stat = uar_srvsetstring(hobjarray,"task_name",nullterm(curprog))
     SET stat = uar_srvsetstring(hobjarray,"completion_msg",nullterm(pmessage))
     SET stat = uar_srvsetdate(hobjarray,"end_dt_tm",cnvtdatetime(sysdate))
     SET stat = uar_srvsetstring(hobjarray,"current_node_name",nullterm(curnode))
     SET stat = uar_srvsetstring(hobjarray,"server_name",nullterm(build(curserver)))
     SET srvstatus = uar_srvexecute(hmsg,hreq,hrep)
     IF (srvstatus != 0)
      CALL echo(build2("Execution of pft_save_system_activity_log was not successful"))
     ENDIF
     CALL uar_srvdestroyinstance(hreq)
     CALL uar_srvdestroyinstance(hrep)
    ENDIF
  END ;Subroutine
 ENDIF
 IF ( NOT (validate(go_to_exit_script)))
  DECLARE go_to_exit_script = i2 WITH constant(1)
 ENDIF
 IF ( NOT (validate(dont_go_to_exit_script)))
  DECLARE dont_go_to_exit_script = i2 WITH constant(0)
 ENDIF
 IF (validate(beginservice,char(128))=char(128))
  SUBROUTINE (beginservice(pversion=vc) =null)
   CALL logmessage("",concat("version:",pversion," :Begin Service"),log_debug)
   CALL setreplystatus("F","Begin Service")
  END ;Subroutine
 ENDIF
 IF (validate(exitservicesuccess,char(128))=char(128))
  SUBROUTINE (exitservicesuccess(pmessage=vc) =null)
    DECLARE errmsg = vc WITH noconstant(" ")
    DECLARE errcode = i2 WITH noconstant(1)
    IF (size(trim(pmessage,3)) > 0)
     CALL logmessage("",pmessage,log_info)
    ENDIF
    IF ((((currevminor2+ (currevminor * 100))+ (currev * 10000)) >= 080311))
     IF (curdomain IN ("SURROUND", "SOLUTION"))
      SET errmsg = fillstring(132," ")
      SET errcode = error(errmsg,1)
      IF (errcode != 0)
       CALL exitservicefailure(errmsg,true)
      ELSE
       CALL logmessage("","Exit Service - SUCCESS",log_debug)
       CALL setreplystatus("S",evaluate(pmessage,"","Exit Service - SUCCESS",pmessage))
       SET reqinfo->commit_ind = true
      ENDIF
     ELSE
      CALL logmessage("","Exit Service - SUCCESS",log_debug)
      CALL setreplystatus("S",evaluate(pmessage,"","Exit Service - SUCCESS",pmessage))
      SET reqinfo->commit_ind = true
     ENDIF
    ELSE
     CALL logmessage("","Exit Service - SUCCESS",log_debug)
     CALL setreplystatus("S",evaluate(pmessage,"","Exit Service - SUCCESS",pmessage))
     SET reqinfo->commit_ind = true
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(exitservicefailure,char(128))=char(128))
  SUBROUTINE (exitservicefailure(pmessage=vc,exitscriptind=i2) =null)
    CALL addtracemessage("",evaluate(trim(pmessage),trim(""),"Exit Service - FAILURE",pmessage))
    CALL logmessage("",evaluate(trim(pmessage),trim(""),"Exit Service - FAILURE",pmessage),log_error)
    IF (validate(reply->failure_stack.failures))
     SET reply->status_data.status = "F"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].operationname = reply->failure_stack.failures[1].
     programname
     SET reply->status_data.subeventstatus[1].targetobjectname = reply->failure_stack.failures[1].
     routinename
     SET reply->status_data.subeventstatus[1].targetobjectvalue = reply->failure_stack.failures[1].
     message
    ELSE
     CALL setreplystatus("F",evaluate(trim(pmessage),trim(""),"Exit Service - FAILURE",pmessage))
    ENDIF
    SET reqinfo->commit_ind = false
    IF (exitscriptind)
     GO TO exit_script
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(exitservicenodata,char(128))=char(128))
  SUBROUTINE (exitservicenodata(pmessage=vc,exitscriptind=i2) =null)
    IF (size(trim(pmessage,3)) > 0)
     CALL logmessage("",pmessage,log_info)
    ENDIF
    CALL logmessage("","Exit Service - NO DATA",log_debug)
    CALL setreplystatus("Z",evaluate(pmessage,"","Exit Service - NO DATA",pmessage))
    SET reqinfo->commit_ind = false
    IF (exitscriptind)
     GO TO exit_script
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(setreplystatus,char(128))=char(128))
  SUBROUTINE (setreplystatus(pstatus=vc,pmessage=vc) =null)
    IF (validate(reply->status_data))
     SET reply->status_data.status = nullterm(pstatus)
     SET reply->status_data.subeventstatus[1].operationstatus = nullterm(pstatus)
     SET reply->status_data.subeventstatus[1].operationname = nullterm(curprog)
     SET reply->status_data.subeventstatus[1].targetobjectvalue = nullterm(pmessage)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(addtracemessage,char(128))=char(128))
  SUBROUTINE (addtracemessage(proutinename=vc,pmessage=vc) =null)
   CALL logmessage(proutinename,pmessage,log_debug)
   IF (validate(reply->failure_stack))
    DECLARE failcnt = i4 WITH protect, noconstant((size(reply->failure_stack.failures,5)+ 1))
    SET stat = alterlist(reply->failure_stack.failures,failcnt)
    SET reply->failure_stack.failures[failcnt].programname = nullterm(curprog)
    SET reply->failure_stack.failures[failcnt].routinename = nullterm(proutinename)
    SET reply->failure_stack.failures[failcnt].message = nullterm(pmessage)
   ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(addstatusdetail,char(128))=char(128))
  SUBROUTINE (addstatusdetail(pentityid=f8,pdetailflag=i4,pdetailmessage=vc) =null)
    IF (validate(reply->status_detail))
     DECLARE detailcnt = i4 WITH protect, noconstant((size(reply->status_detail.details,5)+ 1))
     SET stat = alterlist(reply->status_detail.details,detailcnt)
     SET reply->status_detail.details[detailcnt].entityid = pentityid
     SET reply->status_detail.details[detailcnt].detailflag = pdetailflag
     SET reply->status_detail.details[detailcnt].detailmessage = nullterm(pdetailmessage)
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(copystatusdetails,char(128))=char(128))
  SUBROUTINE (copystatusdetails(pfromrecord=vc(ref),prtorecord=vc(ref)) =null)
    IF (validate(pfromrecord->status_detail)
     AND validate(prtorecord->status_detail))
     DECLARE fromidx = i4 WITH protect, noconstant(0)
     DECLARE fromcnt = i4 WITH protect, noconstant(size(pfromrecord->status_detail.details,5))
     DECLARE toidx = i4 WITH protect, noconstant(size(prtorecord->status_detail.details,5))
     DECLARE fromparamidx = i4 WITH protect, noconstant(0)
     DECLARE toparamcnt = i4 WITH protect, noconstant(0)
     FOR (fromidx = 1 TO fromcnt)
       SET toidx += 1
       SET stat = alterlist(prtorecord->status_detail.details,toidx)
       SET prtorecord->status_detail.details[toidx].entityid = pfromrecord->status_detail.details[
       fromidx].entityid
       SET prtorecord->status_detail.details[toidx].detailflag = pfromrecord->status_detail.details[
       fromidx].detailflag
       SET prtorecord->status_detail.details[toidx].detailmessage = pfromrecord->status_detail.
       details[fromidx].detailmessage
       SET toparamcnt = 0
       FOR (fromparamidx = 1 TO size(pfromrecord->status_detail.details[fromidx].parameters,5))
         SET toparamcnt += 1
         SET stat = alterlist(prtorecord->status_detail.details[toidx].parameters,toparamcnt)
         SET prtorecord->status_detail.details[toidx].parameters[toparamcnt].paramname = pfromrecord
         ->status_detail.details[fromidx].parameters[fromparamidx].paramname
         SET prtorecord->status_detail.details[toidx].parameters[toparamcnt].paramvalue = pfromrecord
         ->status_detail.details[fromidx].parameters[fromparamidx].paramvalue
       ENDFOR
     ENDFOR
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(addstatusdetailparam,char(128))=char(128))
  SUBROUTINE (addstatusdetailparam(pdetailidx=i4,pparamname=vc,pparamvalue=vc) =null)
    IF (validate(reply->status_detail))
     IF (validate(reply->status_detail.details[pdetailidx].parameters))
      DECLARE paramcnt = i4 WITH protect, noconstant((size(reply->status_detail.details[pdetailidx].
        parameters,5)+ 1))
      SET stat = alterlist(reply->status_detail.details[pdetailidx].parameters,paramcnt)
      SET reply->status_detail.details[pdetailidx].parameters[paramcnt].paramname = pparamname
      SET reply->status_detail.details[pdetailidx].parameters[paramcnt].paramvalue = pparamvalue
     ENDIF
    ENDIF
  END ;Subroutine
 ENDIF
 IF (validate(copytracemessages,char(128))=char(128))
  SUBROUTINE (copytracemessages(pfromrecord=vc(ref),prtorecord=vc(ref)) =null)
    IF (validate(pfromrecord->failure_stack)
     AND validate(prtorecord->failure_stack))
     DECLARE fromidx = i4 WITH protect, noconstant(0)
     DECLARE fromcnt = i4 WITH protect, noconstant(size(pfromrecord->failure_stack.failures,5))
     DECLARE toidx = i4 WITH protect, noconstant(size(prtorecord->failure_stack.failures,5))
     FOR (fromidx = 1 TO fromcnt)
       SET toidx += 1
       SET stat = alterlist(prtorecord->failure_stack.failures,toidx)
       SET prtorecord->failure_stack.failures[toidx].programname = pfromrecord->failure_stack.
       failures[fromidx].programname
       SET prtorecord->failure_stack.failures[toidx].routinename = pfromrecord->failure_stack.
       failures[fromidx].routinename
       SET prtorecord->failure_stack.failures[toidx].message = pfromrecord->failure_stack.failures[
       fromidx].message
     ENDFOR
    ENDIF
  END ;Subroutine
 ENDIF
 CALL beginservice("CHARGSRV-15373.009")
 IF (validate(reply->status_data.status,"Z")="Z")
  RECORD reply(
    1 tier_matrix_qual = i4
    1 tier_matrix[10]
      2 tier_cell_id = f8
      2 tier_col_num = i4
      2 tier_row_num = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c8
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
  SET action_begin = 1
  SET action_end = request->tier_matrix_qual
  SET reply->tier_matrix_qual = request->tier_matrix_qual
 ENDIF
 DECLARE active_code = f8 WITH public, noconstant(0.0)
 DECLARE pstype_cd = f8 WITH public, noconstant(0.0)
 DECLARE ortype_cd = f8 WITH public, noconstant(0.0)
 DECLARE inttype_cd = f8 WITH public, noconstant(0.0)
 DECLARE flatdisctype_cd = f8 WITH public, noconstant(0.0)
 DECLARE priceadjfactype_cd = f8 WITH public, noconstant(0.0)
 DECLARE diagreqdtype_cd = f8 WITH public, noconstant(0.0)
 DECLARE physreqdtype_cd = f8 WITH public, noconstant(0.0)
 DECLARE instfinnbrtype_cd = f8 WITH public, noconstant(0.0)
 DECLARE renderingphys_cd = f8 WITH protect, noconstant(0.0)
 DECLARE orderingphys_cd = f8 WITH protect, noconstant(0.0)
 DECLARE renderingphysgroup_cd = f8 WITH protect, noconstant(0.0)
 DECLARE orderingphysgroup_cd = f8 WITH protect, noconstant(0.0)
 DECLARE insorg_cd = f8 WITH protect, noconstant(0.0)
 DECLARE cpt_modifier_cd = f8 WITH protect, noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(48,"ACTIVE",1,active_code)
 SET stat = uar_get_meaning_by_codeset(13036,"PRICESCHED",1,pstype_cd)
 SET stat = uar_get_meaning_by_codeset(13036,"ORG",1,ortype_cd)
 SET stat = uar_get_meaning_by_codeset(13036,"INTERFACE",1,inttype_cd)
 SET stat = uar_get_meaning_by_codeset(13036,"FLAT_DISC",1,flatdisctype_cd)
 SET stat = uar_get_meaning_by_codeset(13036,"PRICEADJFAC",1,priceadjfactype_cd)
 SET stat = uar_get_meaning_by_codeset(13036,"DIAGREQD",1,diagreqdtype_cd)
 SET stat = uar_get_meaning_by_codeset(13036,"PHYSREQD",1,physreqdtype_cd)
 SET stat = uar_get_meaning_by_codeset(13036,"INSTFINNBR",1,instfinnbrtype_cd)
 SET stat = uar_get_meaning_by_codeset(13036,"RENDERINGPHY",1,renderingphys_cd)
 SET stat = uar_get_meaning_by_codeset(13036,"ORDERINGPHYS",1,orderingphys_cd)
 SET stat = uar_get_meaning_by_codeset(13036,"RENDPHYSGRP",1,renderingphysgroup_cd)
 SET stat = uar_get_meaning_by_codeset(13036,"ORDERPHYSGRP",1,orderingphysgroup_cd)
 SET stat = uar_get_meaning_by_codeset(13036,"INSURANCEORG",1,insorg_cd)
 SET stat = uar_get_meaning_by_codeset(13036,"CPT MODIFIER",1,cpt_modifier_cd)
 SET reply->status_data.status = "F"
 SET table_name = "TIER_MATRIX"
 CALL add_tier_matrix(action_begin,action_end)
 IF (failed != false)
  GO TO check_error
 ENDIF
#check_error
 IF (failed=false)
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = true
 ELSE
  CASE (failed)
   OF gen_nbr_error:
    SET reply->status_data.subeventstatus[1].operationname = "GEN_NBR"
   OF insert_error:
    SET reply->status_data.subeventstatus[1].operationname = "INSERT"
   OF update_error:
    SET reply->status_data.subeventstatus[1].operationname = "UPDATE"
   OF replace_error:
    SET reply->status_data.subeventstatus[1].operationname = "REPLACE"
   OF delete_error:
    SET reply->status_data.subeventstatus[1].operationname = "DELETE"
   OF undelete_error:
    SET reply->status_data.subeventstatus[1].operationname = "UNDELETE"
   OF remove_error:
    SET reply->status_data.subeventstatus[1].operationname = "REMOVE"
   OF attribute_error:
    SET reply->status_data.subeventstatus[1].operationname = "ATTRIBUTE"
   OF lock_error:
    SET reply->status_data.subeventstatus[1].operationname = "LOCK"
   ELSE
    SET reply->status_data.subeventstatus[1].operationname = "UNKNOWN"
  ENDCASE
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = table_name
  SET reqinfo->commit_ind = false
 ENDIF
 GO TO end_program
 SUBROUTINE add_tier_matrix(add_begin,add_end)
  CALL echorecord(request)
  FOR (x = add_begin TO add_end)
    SET new_nbr = 0.0
    SELECT INTO "nl:"
     y = seq(price_sched_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      new_nbr = cnvtreal(y)
     WITH format, counter
    ;end select
    IF (curqual=0)
     SET failed = gen_nbr_error
     RETURN
    ELSE
     SET request->tier_matrix[x].tier_cell_id = new_nbr
    ENDIF
    INSERT  FROM tier_matrix t
     SET t.tier_cell_id = new_nbr, t.tier_group_cd =
      IF ((request->tier_matrix[x].tier_group_cd=0)) 0
      ELSE request->tier_matrix[x].tier_group_cd
      ENDIF
      , t.tier_col_num =
      IF ((request->tier_matrix[x].tier_col_num=0)) null
      ELSE request->tier_matrix[x].tier_col_num
      ENDIF
      ,
      t.tier_row_num =
      IF ((request->tier_matrix[x].tier_row_num=0)) null
      ELSE request->tier_matrix[x].tier_row_num
      ENDIF
      , t.tier_cell_type_cd =
      IF ((request->tier_matrix[x].tier_cell_type_cd=0)) 0
      ELSE request->tier_matrix[x].tier_cell_type_cd
      ENDIF
      , t.tier_cell_value =
      IF ((request->tier_matrix[x].tier_cell_value=0)) 0
      ELSEIF ((request->tier_matrix[x].tier_cell_type_cd IN (flatdisctype_cd, diagreqdtype_cd,
      physreqdtype_cd, instfinnbrtype_cd, priceadjfactype_cd))) request->tier_matrix[x].
       tier_cell_value
      ELSE 0
      ENDIF
      ,
      t.tier_cell_value_id =
      IF ((request->tier_matrix[x].tier_cell_value=0)) 0
      ELSEIF ((request->tier_matrix[x].tier_cell_type_cd IN (flatdisctype_cd, diagreqdtype_cd,
      physreqdtype_cd, instfinnbrtype_cd, priceadjfactype_cd))) 0
      ELSE request->tier_matrix[x].tier_cell_value
      ENDIF
      , t.tier_cell_string =
      IF ((request->tier_matrix[x].tier_cell_string=" ")) null
      ELSE request->tier_matrix[x].tier_cell_string
      ENDIF
      , t.beg_effective_dt_tm =
      IF ((request->tier_matrix[x].beg_effective_dt_tm <= 0)) cnvtdatetimeutc(cnvtdatetime(curdate,0),
        0)
      ELSE cnvtdatetimeutc(request->tier_matrix[x].beg_effective_dt_tm,0)
      ENDIF
      ,
      t.end_effective_dt_tm =
      IF ((request->tier_matrix[x].end_effective_dt_tm <= 0)) cnvtdatetimeutc("31-DEC-2100 00:00:00",
        0)
      ELSE cnvtdatetimeutc(request->tier_matrix[x].end_effective_dt_tm,0)
      ENDIF
      , t.active_ind =
      IF ((request->tier_matrix[x].active_ind_ind=false)) true
      ELSE request->tier_matrix[x].active_ind
      ENDIF
      , t.active_status_cd =
      IF ((request->tier_matrix[x].active_status_cd=0)) active_code
      ELSE request->tier_matrix[x].active_status_cd
      ENDIF
      ,
      t.active_status_prsnl_id = reqinfo->updt_id, t.active_status_dt_tm = cnvtdatetime(sysdate), t
      .updt_cnt = 0,
      t.updt_dt_tm = cnvtdatetime(sysdate), t.updt_id = reqinfo->updt_id, t.updt_applctx = reqinfo->
      updt_applctx,
      t.updt_task = reqinfo->updt_task, t.tier_cell_entity_name =
      IF ((request->tier_matrix[x].tier_cell_type_cd=pstype_cd)) "PRICE_SCHED"
      ELSEIF ((request->tier_matrix[x].tier_cell_type_cd IN (ortype_cd, insorg_cd))) "ORGANIZATION"
      ELSEIF ((request->tier_matrix[x].tier_cell_type_cd=inttype_cd)) "INTERFACE_FILE"
      ELSEIF ((request->tier_matrix[x].tier_cell_type_cd IN (renderingphys_cd, orderingphys_cd)))
       "PRSNL"
      ELSEIF ((request->tier_matrix[x].tier_cell_type_cd IN (renderingphysgroup_cd,
      orderingphysgroup_cd))) "PRSNL_GROUP"
      ELSEIF ((request->tier_matrix[x].tier_cell_type_cd IN (flatdisctype_cd, priceadjfactype_cd,
      diagreqdtype_cd, physreqdtype_cd, instfinnbrtype_cd))) " "
      ELSE "CODE_VALUE"
      ENDIF
     WITH nocounter
    ;end insert
    IF (curqual=0)
     SET failed = insert_error
     RETURN
    ELSE
     SET reply->tier_matrix_qual += 1
     SET stat = alterlist(reply->tier_matrix,reply->tier_matrix_qual)
     SET reply->tier_matrix[reply->tier_matrix_qual].tier_cell_id = request->tier_matrix[x].
     tier_cell_id
     SET reply->tier_matrix[reply->tier_matrix_qual].tier_row_num = request->tier_matrix[x].
     tier_row_num
     SET reply->tier_matrix[reply->tier_matrix_qual].tier_col_num = request->tier_matrix[x].
     tier_col_num
     IF ((request->tier_matrix[x].tier_cell_type_cd=cpt_modifier_cd))
      CALL logsolutioncapability("PATIENT_ACCOUNTING","2015.2.00015.1",new_nbr,"TIER_MATRIX")
     ENDIF
    ENDIF
  ENDFOR
 END ;Subroutine
#end_program
END GO
