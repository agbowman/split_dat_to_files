CREATE PROGRAM cpmnotify_dcp_r2e:dba
 SET modify = predeclare
 RECORD reply(
   1 run_dt_tm = dq8
   1 overlay_ind = i2
   1 entity_list[*]
     2 entity_id = f8
     2 datalist[*]
       3 encntr_id = f8
       3 event_list[*]
         4 event_cd = f8
         4 event_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) = null
 DECLARE fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) = null
 SUBROUTINE reportfailure(opname,opstatus,targetname,targetvalue)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE fillsubeventstatus(opname,opstatus,objname,objvalue)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt = (dcp_substatus_cnt+ 1)
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 DECLARE initialize(null) = null
 DECLARE loadresults(null) = null
 DECLARE finalize(null) = null
 DECLARE printdebugmsg(msg=vc) = null
 DECLARE last_mod = c12 WITH private, noconstant(fillstring(12," "))
 DECLARE total_script_timer = dq8 WITH protect, noconstant(cnvtdatetime(curdate,curtime3))
 DECLARE subroutine_timer = dq8 WITH protect, noconstant(0)
 DECLARE query_timer = dq8 WITH protect, noconstant(0)
 DECLARE error_msg = vc WITH protect, noconstant("")
 DECLARE error_cd = i2 WITH protect, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE script_debug_ind = i2 WITH protect, noconstant(0)
 DECLARE entitysize = i4 WITH protect, noconstant(size(request->entity_list,5))
 DECLARE action_type_order = f8 WITH protect, constant(uar_get_code_by("MEANING",21,"ORDER"))
 DECLARE event_class_med = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"MED"))
 DECLARE event_class_immun = f8 WITH protect, constant(uar_get_code_by("MEANING",53,"IMMUN"))
 DECLARE nsize = i4 WITH protect, constant(60)
 IF (validate(request->debug_ind))
  SET script_debug_ind = request->debug_ind
 ENDIF
 CALL initialize(null)
 CALL loadresults(null)
 CALL finalize(null)
 SUBROUTINE initialize(null)
   CALL printdebugmsg("***SUBROUTINE Initialize()***")
   DECLARE idx = i4 WITH protect, noconstant(0)
   SET reply->run_dt_tm = cnvtdatetime(curdate,curtime3)
   SET reply->overlay_ind = 1
   SET reply->status_data.status = "F"
   SET stat = alterlist(reply->entity_list,entitysize)
   FOR (idx = 1 TO entitysize)
     SET reply->entity_list[idx].entity_id = request->entity_list[idx].entity_id
     SET stat = alterlist(reply->entity_list[idx].datalist,1)
     SET reply->entity_list[idx].datalist[1].encntr_id = 0
   ENDFOR
 END ;Subroutine
 SUBROUTINE finalize(null)
   CALL printdebugmsg("***SUBROUTINE Finalize()***")
   DECLARE elapsedtime = f8 WITH protect, noconstant(datetimediff(cnvtdatetime(curdate,curtime3),
     total_script_timer,5))
   SET error_cd = error(error_msg,1)
   IF (error_cd != 0)
    CALL echo("*********************************")
    CALL echo(build("ERROR MESSAGE : ",error_msg))
    CALL echo("*********************************")
    SET reply->status_data.status = "F"
    CALL fillsubeventstatus("ERROR","F","cpmnotify_dcp_r2e",error_msg)
   ELSE
    SET reply->status_data.status = "S"
    CALL fillsubeventstatus("SELECT","S","cpmnotify_dcp_r2e",build("Total time = ",elapsedtime))
   ENDIF
   IF (script_debug_ind > 0)
    CALL echo("***********************************")
    CALL echorecord(reply)
    CALL echo("-----------------------------------------------------------")
    CALL echo(build("Total Script Time = ",elapsedtime))
    CALL echo("***********************************")
   ENDIF
 END ;Subroutine
 SUBROUTINE loadresults(null)
   CALL printdebugmsg("***SUBROUTINE LoadResults()***")
   SET subroutine_timer = cnvtdatetime(curdate,curtime3)
   DECLARE idx = i4 WITH protect, noconstant(0)
   DECLARE encntr_idx = i4 WITH protect, noconstant(0)
   DECLARE event_cd_idx = i4 WITH protect, noconstant(0)
   DECLARE person_idx = i4 WITH protect, noconstant(0)
   DECLARE entity_idx = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    FROM ce_event_action cea,
     v500_event_set_explode ese,
     v500_event_set_code esc
    PLAN (cea
     WHERE expand(entity_idx,1,entitysize,cea.person_id,request->entity_list[entity_idx].entity_id)
      AND ((cea.action_type_cd+ 0)=action_type_order)
      AND  NOT (((cea.event_class_cd+ 0) IN (event_class_med, event_class_immun))))
     JOIN (ese
     WHERE ese.event_cd=cea.event_cd)
     JOIN (esc
     WHERE esc.event_set_cd=ese.event_set_cd
      AND esc.event_set_name="ALL RESULT SECTIONS")
    ORDER BY cea.person_id, cea.encntr_id, cea.event_cd
    HEAD REPORT
     CALL printdebugmsg(build("*****LoadResults() Query Time = ",datetimediff(cnvtdatetime(curdate,
        curtime3),subroutine_timer,5)))
    HEAD cea.person_id
     person_idx = locateval(idx,1,entitysize,cea.person_id,reply->entity_list[idx].entity_id),
     encntr_idx = 0
    HEAD cea.encntr_id
     encntr_idx = (encntr_idx+ 1)
     IF (encntr_idx > size(reply->entity_list[person_idx].datalist,5))
      stat = alterlist(reply->entity_list[person_idx].datalist,(encntr_idx+ 9))
     ENDIF
     reply->entity_list[person_idx].datalist[encntr_idx].encntr_id = cea.encntr_id, event_cd_idx = 0
    HEAD cea.event_cd
     event_cd_idx = (event_cd_idx+ 1)
     IF (event_cd_idx > size(reply->entity_list[person_idx].datalist[encntr_idx].event_list,5))
      stat = alterlist(reply->entity_list[person_idx].datalist[encntr_idx].event_list,(event_cd_idx+
       9))
     ENDIF
     reply->entity_list[person_idx].datalist[encntr_idx].event_list[event_cd_idx].event_cd = cea
     .event_cd
    HEAD cea.event_id
     IF (cea.event_id > 0)
      reply->entity_list[person_idx].datalist[encntr_idx].event_list[event_cd_idx].event_cnt = (reply
      ->entity_list[person_idx].datalist[encntr_idx].event_list[event_cd_idx].event_cnt+ 1)
     ENDIF
    FOOT  cea.event_cd
     stat = alterlist(reply->entity_list[person_idx].datalist[encntr_idx].event_list,event_cd_idx)
    FOOT  cea.encntr_id
     stat = alterlist(reply->entity_list[person_idx].datalist,encntr_idx)
    FOOT REPORT
     CALL printdebugmsg(build("*****LoadResults() Query Total Time = ",datetimediff(cnvtdatetime(
        curdate,curtime3),subroutine_timer,5)))
    WITH nocounter
   ;end select
   CALL printdebugmsg(build("*****LoadResults() SUBROUTINE Timer = ",datetimediff(cnvtdatetime(
       curdate,curtime3),subroutine_timer,5)))
 END ;Subroutine
 SUBROUTINE printdebugmsg(msg)
   IF (script_debug_ind > 0)
    CALL echo(msg)
   ENDIF
 END ;Subroutine
 SET last_mod = "001 05/11/11"
 CALL echo(build("###> Last Mod: ",last_mod))
 SET modify = nopredeclare
END GO
