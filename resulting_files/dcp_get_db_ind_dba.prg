CREATE PROGRAM dcp_get_db_ind:dba
 SET modify = predeclare
 RECORD reply(
   1 allstatus_ind = i2
   1 complete_ind = i2
   1 pending_ind = i2
   1 overdue_ind = i2
   1 inprocess_ind = i2
   1 discontinued_ind = i2
   1 alltimeparam_ind = i2
   1 scheduled_ind = i2
   1 nonscheduled_ind = i2
   1 prn_ind = i2
   1 continuous_ind = i2
   1 physorder_ind = i2
   1 nonphysorder_ind = i2
   1 nonpatient_ind = i2
   1 med_flag = i2
   1 iv_ind = i2
   1 tpn_ind = i2
   1 position_flag = i2
   1 position_cd = f8
   1 type_flag = i2
   1 type_list[*]
     2 task_type_cd = f8
   1 location_group_cd = f8
   1 location_list[*]
     2 location_cd = f8
   1 loc_bed_list[*]
     2 loc_bed_cd = f8
   1 pendingvalidation_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE last_mod = c12 WITH private, noconstant(fillstring(12," "))
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE ierrorcode = i2 WITH protect, noconstant(0)
 DECLARE tab_found = i2 WITH protect, noconstant(0)
 DECLARE count1 = i4 WITH protect, noconstant(0)
 DECLARE temp_location_group_cd = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  tc.tl_tab_id
  FROM tl_tab_content tc
  WHERE (tc.tl_tab_id=request->tl_tab_id)
  HEAD REPORT
   reply->allstatus_ind = tc.allstatus_ind, reply->complete_ind = tc.complete_ind, reply->pending_ind
    = tc.pending_ind,
   reply->overdue_ind = tc.overdue_ind, reply->inprocess_ind = tc.inprocess_ind, reply->
   discontinued_ind = tc.discontinued_ind,
   reply->alltimeparam_ind = tc.alltimeparam_ind, reply->scheduled_ind = tc.scheduled_ind, reply->
   nonscheduled_ind = 1,
   reply->prn_ind = tc.prn_ind, reply->continuous_ind = tc.continuous_ind, reply->physorder_ind = tc
   .physorder_ind,
   reply->nonphysorder_ind = tc.nonphysorder_ind, reply->nonpatient_ind = tc.nonpatient_ind, reply->
   med_flag = tc.med_flag,
   reply->iv_ind = tc.iv_ind, reply->tpn_ind = tc.tpn_ind, reply->position_flag = tc.position_flag,
   reply->position_cd = tc.position_cd, reply->type_flag = tc.type_flag, reply->location_group_cd =
   tc.location_cd,
   reply->pendingvalidation_ind = tc.pendingvalidation_ind
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("tl_tab_id does not exist on the tl_tab_content table.")
  SET tab_found = 0
  GO TO exit_script
 ELSE
  SET tab_found = 1
 ENDIF
 SELECT INTO "nl:"
  FROM tl_eligible_task_code etc
  WHERE (etc.tl_tab_id=request->tl_tab_id)
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->type_list,5))
    stat = alterlist(reply->type_list,(count1+ 10))
   ENDIF
   reply->type_list[count1].task_type_cd = etc.task_type_cd
  FOOT REPORT
   stat = alterlist(reply->type_list,count1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("No task types exist on the tl_eligible_task_code table for the tl_tab_id.")
 ENDIF
 SELECT INTO "nl:"
  nvp.name_value_prefs_id
  FROM name_value_prefs nvp
  WHERE nvp.parent_entity_name="TL_TAB_CONTENT"
   AND (parent_entity_id=request->tl_tab_id)
   AND pvc_name="TL_PERSONAL_LOC_FILTER"
  HEAD REPORT
   loc_cnt = 0, stat = alterlist(reply->location_list,10)
  DETAIL
   IF (nvp.name_value_prefs_id > 0)
    loc_cnt = (loc_cnt+ 1)
    IF (mod(loc_cnt,10)=1)
     stat = alterlist(reply->location_list,(loc_cnt+ 9))
    ENDIF
    reply->location_list[loc_cnt].location_cd = cnvtreal(nvp.pvc_value)
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->location_list,loc_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("No locations exist on the name_value_prefs table for the tl_tab_id.")
 ENDIF
 IF ((reply->location_group_cd > 0))
  SET temp_location_group_cd = reply->location_group_cd
  EXECUTE dcp_get_tsk_loc_group
 ENDIF
#exit_script
 SET ierrorcode = error(serrormsg,1)
 IF (ierrorcode != 0)
  CALL echo(build("ERROR: ",serrormsg))
  SET reply->status_data.status = "F"
 ELSEIF (tab_found=0)
  CALL echo("***** Tab was not found *******")
  SET reply->status_data.status = "Z"
 ELSE
  CALL echo("**** Success ********")
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "005 08/06/10"
 CALL echo(build("Last Modified = ",last_mod))
 SET modify = nopredeclare
END GO
