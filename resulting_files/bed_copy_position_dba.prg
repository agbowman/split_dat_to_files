CREATE PROGRAM bed_copy_position:dba
 FREE SET reply
 RECORD reply(
   1 poslist[*]
     2 code_value = f8
     2 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET request_ens_psn
 RECORD request_ens_psn(
   1 plist[*]
     2 action_flag = i2
     2 code_value = f8
     2 display = vc
     2 description = vc
     2 pco_ind = i2
     2 clist[*]
       3 category_id = f8
       3 cat_phys_ind = i2
       3 action_flag = i2
     2 alist[*]
       3 action_flag = i2
       3 app_group_cd = f8
     2 copy_source_position_cd = f8
     2 copy_prefs_ind = i2
     2 copy_privs_ind = i2
     2 copy_prov_rel_ind = i2
 )
 FREE SET reply_ens_psn
 RECORD reply_ens_psn(
   1 plist[*]
     2 code_value = f8
   1 error_msg = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET request_get_task
 RECORD request_get_task(
   1 plist[1]
     2 position_code_value = f8
   1 tlist[1]
     2 task_mean = vc
 )
 FREE SET reply_get_task
 RECORD reply_get_task(
   1 qual[1]
     2 position_code_value = f8
     2 rlist[*]
       3 task_mean = vc
       3 display_ind = i2
       3 default_selected_ind = i2
     2 website_url = vc
     2 website_display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET request_get_workflow
 RECORD request_get_workflow(
   1 position_code_value = f8
 )
 FREE SET reply_get_workflow
 RECORD reply_get_workflow(
   1 wlist[*]
     2 workflow_name = vc
     2 workflow_seq = i2
     2 invalid_comp_ind = i2
     2 slist[*]
       3 step_seq = i2
       3 comp1_name = vc
       3 invalid_comp1_ind = i2
       3 comp2_name = vc
       3 invalid_comp2_ind = i2
       3 layout_orientation = i2
       3 splitter_percent = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET request_ens_task
 RECORD request_ens_task(
   1 position_code_value = f8
   1 set_reviewed_ind = i2
   1 plist[*]
     2 task_mean = vc
     2 action_flag = i2
   1 website_url = vc
   1 website_display = vc
   1 physassist_code_value = f8
   1 physassist_action_flag = i2
   1 physassist_rx_flag = i2
   1 physassist_chg_flag = i2
   1 nursepract_code_value = f8
   1 nursepract_action_flag = i2
   1 nursepract_rx_flag = i2
   1 nursepract_chg_flag = i2
   1 newposition_action_flag = i2
   1 newposition_rx_flag = i2
   1 newposition_chg_flag = i2
 )
 FREE SET reply_ens_task
 RECORD reply_ens_task(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET request_ens_workflow
 RECORD request_ens_workflow(
   1 plist[*]
     2 position_code_value = f8
     2 reviewed_ind = i2
     2 wlist[*]
       3 workflow_name = vc
       3 workflow_seq = i2
       3 slist[*]
         4 step_seq = i2
         4 comp1_name = vc
         4 comp2_name = vc
         4 layout_orientation = i2
         4 splitter_percent = f8
 )
 FREE SET reply_ens_workflow
 RECORD reply_ens_workflow(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD appgrp(
   1 alist[*]
     2 app_group_cd = f8
 )
 SET reply->status_data.status = "F"
 SET newpcnt = size(request->plist,5)
 IF (newpcnt=0)
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->poslist,newpcnt)
 SET request_get_task->plist[1].position_code_value = request->position_code_value
 SET request_get_task->tlist[1].task_mean = " "
 SET trace = recpersist
 EXECUTE bed_get_task_by_psn  WITH replace("REQUEST",request_get_task), replace("REPLY",
  reply_get_task)
 IF ((reply_get_task->status_data.status != "S"))
  GO TO exit_script
 ENDIF
 SET request_get_workflow->position_code_value = request->position_code_value
 SET trace = recpersist
 EXECUTE bed_get_workflow_info  WITH replace("REQUEST",request_get_workflow), replace("REPLY",
  reply_get_workflow)
 IF ((reply_get_workflow->status_data.status != "S"))
  GO TO exit_script
 ENDIF
 SET stat = alterlist(appgrp->alist,10)
 SET alterlist_appgcnt = 0
 SET appgcnt = 0
 SELECT INTO "NL:"
  FROM application_group ag
  WHERE (ag.position_cd=request->position_code_value)
  DETAIL
   alterlist_appgcnt = (alterlist_appgcnt+ 1)
   IF (alterlist_appgcnt > 10)
    stat = alterlist(appgrp->alist,(appgcnt+ 10)), alterlist_appgcnt = 1
   ENDIF
   appgcnt = (appgcnt+ 1), appgrp->alist[appgcnt].app_group_cd = ag.app_group_cd
  WITH nocounter
 ;end select
 SET stat = alterlist(appgrp->alist,appgcnt)
 SET stat = alterlist(request_ens_psn->plist,newpcnt)
 FOR (newp = 1 TO newpcnt)
   SET request_ens_psn->plist[newp].action_flag = 1
   SET request_ens_psn->plist[newp].display = request->plist[newp].display
   SET request_ens_psn->plist[newp].description = request->plist[newp].description
   SET request_ens_psn->plist[newp].pco_ind = request->plist[newp].pco_ind
   SET catcnt = size(request->plist[newp].clist,5)
   SET stat = alterlist(request_ens_psn->plist[newp].clist,catcnt)
   FOR (c = 1 TO catcnt)
     SET request_ens_psn->plist[newp].clist[catcnt].category_id = request->plist[newp].clist[catcnt].
     category_id
     SET request_ens_psn->plist[newp].clist[catcnt].cat_phys_ind = request->plist[newp].clist[catcnt]
     .cat_phys_ind
     SET request_ens_psn->plist[newp].clist[catcnt].action_flag = 1
   ENDFOR
 ENDFOR
 SET trace = recpersist
 EXECUTE bed_ens_position  WITH replace("REQUEST",request_ens_psn), replace("REPLY",reply_ens_psn)
 IF ((reply_ens_psn->status_data.status != "S"))
  GO TO exit_script
 ENDIF
 FOR (newp = 1 TO newpcnt)
   IF ((reply_ens_psn->plist[newp].code_value > 0.0))
    SET reply->poslist[newp].code_value = reply_ens_psn->plist[newp].code_value
    SET reply->poslist[newp].display = request->plist[newp].display
   ELSE
    GO TO exit_script
   ENDIF
 ENDFOR
 SET taskcnt = size(reply_get_task->qual[1].rlist,5)
 IF (taskcnt > 0)
  SET stat = alterlist(request_ens_task->plist,taskcnt)
  SET request_ens_task->set_reviewed_ind = 0
  SET request_ens_task->website_url = reply_get_task->qual[1].website_url
  SET request_ens_task->website_display = reply_get_task->qual[1].website_display
  FOR (tsk = 1 TO taskcnt)
   SET request_ens_task->plist[tsk].task_mean = reply_get_task->qual[1].rlist[tsk].task_mean
   IF ((((request_ens_task->plist[tsk].task_mean="COMMENTRESULT")) OR ((request_ens_task->plist[tsk].
   task_mean="UPDNOTES"))) )
    SET request_ens_task->plist[tsk].action_flag = reply_get_task->qual[1].rlist[tsk].
    default_selected_ind
   ELSE
    IF ((reply_get_task->qual[1].rlist[tsk].default_selected_ind=1))
     SET request_ens_task->plist[tsk].action_flag = 1
    ELSE
     SET request_ens_task->plist[tsk].action_flag = 3
    ENDIF
   ENDIF
  ENDFOR
  FOR (newp = 1 TO newpcnt)
    SET request_ens_task->position_code_value = reply_ens_psn->plist[newp].code_value
    SET trace = recpersist
    EXECUTE bed_ens_psn_tasks  WITH replace("REQUEST",request_ens_task), replace("REPLY",
     reply_ens_task)
    IF ((reply_ens_task->status_data.status != "S"))
     GO TO exit_script
    ENDIF
  ENDFOR
 ENDIF
 SET workcnt = size(reply_get_workflow->wlist,5)
 IF (workcnt > 0)
  SET stat = alterlist(request_ens_workflow->plist,newpcnt)
  FOR (newp = 1 TO newpcnt)
    SET request_ens_workflow->plist[newp].position_code_value = reply_ens_psn->plist[newp].code_value
    SET request_ens_workflow->plist[newp].reviewed_ind = 0
    SET stat = alterlist(request_ens_workflow->plist[newp].wlist,workcnt)
    FOR (work = 1 TO workcnt)
      SET request_ens_workflow->plist[newp].wlist[work].workflow_name = reply_get_workflow->wlist[
      work].workflow_name
      SET request_ens_workflow->plist[newp].wlist[work].workflow_seq = reply_get_workflow->wlist[work
      ].workflow_seq
      SET stepcnt = size(reply_get_workflow->wlist[work].slist,5)
      SET stat = alterlist(request_ens_workflow->plist[newp].wlist[work].slist,stepcnt)
      FOR (step = 1 TO stepcnt)
        SET request_ens_workflow->plist[newp].wlist[work].slist[step].step_seq = reply_get_workflow->
        wlist[work].slist[step].step_seq
        SET request_ens_workflow->plist[newp].wlist[work].slist[step].comp1_name = reply_get_workflow
        ->wlist[work].slist[step].comp1_name
        SET request_ens_workflow->plist[newp].wlist[work].slist[step].comp2_name = reply_get_workflow
        ->wlist[work].slist[step].comp2_name
        SET request_ens_workflow->plist[newp].wlist[work].slist[step].layout_orientation =
        reply_get_workflow->wlist[work].slist[step].layout_orientation
        SET request_ens_workflow->plist[newp].wlist[work].slist[step].splitter_percent =
        reply_get_workflow->wlist[work].slist[step].splitter_percent
      ENDFOR
    ENDFOR
  ENDFOR
  SET trace = recpersist
  EXECUTE bed_ens_workflow_info  WITH replace("REQUEST",request_ens_workflow), replace("REPLY",
   reply_ens_workflow)
  IF ((reply_ens_workflow->status_data.status != "S"))
   GO TO exit_script
  ENDIF
 ENDIF
 IF (appgcnt > 0)
  FOR (newp = 1 TO newpcnt)
    FOR (appg = 1 TO appgcnt)
      SET new_appgrp_id = 0.0
      SELECT INTO "NL:"
       newappgrpid = seq(reference_seq,nextval)"##################;rp0"
       FROM dual
       DETAIL
        new_appgrp_id = cnvtreal(newappgrpid)
       WITH format, counter
      ;end select
      INSERT  FROM application_group ap
       SET ap.application_group_id = new_appgrp_id, ap.position_cd = reply_ens_psn->plist[newp].
        code_value, ap.app_group_cd = appgrp->alist[appg].app_group_cd,
        ap.beg_effective_dt_tm = cnvtdatetime(curdate,curtime3), ap.end_effective_dt_tm =
        cnvtdatetime("31-DEC-2100"), ap.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        ap.updt_id = reqinfo->updt_id, ap.updt_task = reqinfo->updt_task, ap.updt_cnt = 0,
        ap.updt_applctx = reqinfo->updt_applctx
       WITH nocounter
      ;end insert
    ENDFOR
  ENDFOR
 ENDIF
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
#exit_script
 CALL echorecord(reply)
END GO
