CREATE PROGRAM bed_ens_psn_tasks:dba
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET singletaskrequest
 RECORD singletaskrequest(
   1 action = c1
   1 application_number = i4
   1 position_cd = f8
   1 prsnl_id = f8
 )
 FREE SET singletaskreply
 RECORD singletaskreply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET multitaskrequest
 RECORD multitaskrequest(
   1 action = c1
   1 task_list[*]
     2 task = c50
     2 on_off_ind = i2
   1 application_number = i4
   1 position_cd = f8
   1 prsnl_id = f8
 )
 FREE SET multitaskreply
 RECORD multitaskreply(
   1 status_data
     2 status_list[*]
       3 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 FREE SET misctaskrequest
 RECORD misctaskrequest(
   1 action = c1
   1 task_list[*]
     2 task = c50
     2 on_off_ind = i2
   1 website_url = vc
   1 website_display = vc
   1 application_number = i4
   1 position_cd = f8
   1 prsnl_id = f8
 )
 FREE SET misctaskreply
 RECORD misctaskreply(
   1 status_data
     2 status_list[*]
       3 status = c1
     2 website_url = vc
     2 website_display = vc
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 RECORD temp2(
   1 bpcclist[*]
     2 category_id = f8
     2 sequence = i4
 )
 SET reply->status_data.status = "F"
 SET pcnt = size(request->plist,5)
 SET psncnt = 0
 SET singletaskrequest->application_number = 961000
 SET singletaskrequest->position_cd = request->position_code_value
 SET singletaskrequest->prsnl_id = 0.0
 SET multitaskrequest->application_number = 961000
 SET multitaskrequest->position_cd = request->position_code_value
 SET multitaskrequest->prsnl_id = 0.0
 SET misctaskrequest->application_number = 961000
 SET misctaskrequest->position_cd = request->position_code_value
 SET misctaskrequest->prsnl_id = 0.0
 SET deskscan_ind = 0
 SELECT INTO "nl:"
  FROM br_name_value bnv
  PLAN (bnv
   WHERE bnv.br_nv_key1="LICENSE"
    AND bnv.br_name="DESKSCAN"
    AND bnv.default_selected_ind=1)
  DETAIL
   deskscan_ind = 1
  WITH nocounter
 ;end select
 SET medstudent_ind = 0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=88
    AND (c.code_value=request->position_code_value))
  DETAIL
   IF (c.cdf_meaning="MEDSTUDENT")
    medstudent_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SET acute_care_psn_ind = 0
 SET physician_ind = 0
 SELECT INTO "nl:"
  FROM br_position_cat_comp bpcc,
   br_position_category bpc
  PLAN (bpcc
   WHERE (bpcc.position_cd=request->position_code_value))
   JOIN (bpc
   WHERE bpc.category_id=bpcc.category_id)
  ORDER BY bpcc.category_id, bpcc.position_cd, bpcc.br_client_id DESC
  HEAD bpcc.position_cd
   IF (bpc.step_cat_mean="ACUTE")
    acute_care_psn_ind = 1
   ENDIF
   physician_ind = bpcc.physician_ind
  WITH nocounter
 ;end select
 SET viewressch_idx = 0
 SET viewapptbk_idx = 0
 SET indptarr_idx = 0
 SET updimm_idx = 0
 SET updhlthmnt_idx = 0
 SET pedgrwthch_idx = 0
 SET emassist_idx = 0
 SET viewcharge_idx = 0
 SET pubmedrec_idx = 0
 SET viewallergy_idx = 0
 SET updallergy_idx = 0
 SET viewprob_idx = 0
 SET updprob_idx = 0
 SET viewprochist_idx = 0
 SET updprochist_idx = 0
 SET order_idx = 0
 SET vieword_idx = 0
 SET ordpro_idx = 0
 SET cancel_idx = 0
 SET complete_idx = 0
 SET modmsord_idx = 0
 SET modord_idx = 0
 SET repeat_idx = 0
 SET resched_idx = 0
 SET suspend_idx = 0
 SET void_idx = 0
 SET viewmed_idx = 0
 SET updpc_idx = 0
 SET updmed_idx = 0
 SET reprint_idx = 0
 SET ordertorx_idx = 0
 SET rxtoacute_idx = 0
 SET rxtoamb_idx = 0
 SET viewnote_idx = 0
 SET updnote_idx = 0
 SET scan_idx = 0
 SET savedoc_idx = 0
 SET signdoc_idx = 0
 SET precomp_idx = 0
 SET orddiag_idx = 0
 SET rxstruct_idx = 0
 SET mineonly_idx = 0
 SET certcare_idx = 0
 SET viewhist_idx = 0
 SET updhist_idx = 0
 SET viewrslt_idx = 0
 SET commrslt_idx = 0
 SET viewform_idx = 0
 SET saveform_idx = 0
 SET signform_idx = 0
 SET viewtask_idx = 0
 SET updtask_idx = 0
 SET rsltend_idx = 0
 SET signpatdoc_idx = 0
 SET revpatrslt_idx = 0
 SET signpatrslt_idx = 0
 SET correspond_idx = 0
 SET fwdinbox_idx = 0
 SET fwdemail_idx = 0
 SET revpatdoc_idx = 0
 SET recdictdoc_idx = 0
 SET savephone_idx = 0
 SET addphone_idx = 0
 SET recphone_idx = 0
 SET ordtoapp_idx = 0
 SET saveddoc_idx = 0
 SET sentitems_idx = 0
 FOR (s = 1 TO pcnt)
   IF ((request->plist[s].task_mean="VIEWRESSCHED"))
    SET viewressch_idx = s
   ELSEIF ((request->plist[s].task_mean="VIEWAPPTBOOK"))
    SET viewapptbk_idx = s
   ELSEIF ((request->plist[s].task_mean="INDPTARRIVAL"))
    SET indptarr_idx = s
   ELSEIF ((request->plist[s].task_mean="UPDIMMUN"))
    SET updimm_idx = s
   ELSEIF ((request->plist[s].task_mean="UPDHLTHMAINT"))
    SET updhlthmnt_idx = s
   ELSEIF ((request->plist[s].task_mean="PEDGROWTHCHART"))
    SET pedgrwthch_idx = s
   ELSEIF ((request->plist[s].task_mean="EVALMGMTASSIST"))
    SET emassist_idx = s
   ELSEIF ((request->plist[s].task_mean="VIEWCHARGES"))
    SET viewcharge_idx = s
   ELSEIF ((request->plist[s].task_mean="PUBMEDREC"))
    SET pubmedrec_idx = s
   ELSEIF ((request->plist[s].task_mean="VIEWALLERGY"))
    SET viewallergy_idx = s
   ELSEIF ((request->plist[s].task_mean="UPDALLERGY"))
    SET updallergy_idx = s
   ELSEIF ((request->plist[s].task_mean="VIEWPROBLEM"))
    SET viewprob_idx = s
   ELSEIF ((request->plist[s].task_mean="UPDPROBLEM"))
    SET updprob_idx = s
   ELSEIF ((request->plist[s].task_mean="VIEWPROCHIST"))
    SET viewprochist_idx = s
   ELSEIF ((request->plist[s].task_mean="UPDPROCHIST"))
    SET updprochist_idx = s
   ELSEIF ((request->plist[s].task_mean="ORDER"))
    SET order_idx = s
   ELSEIF ((request->plist[s].task_mean="VIEWORDER"))
    SET vieword_idx = s
   ELSEIF ((request->plist[s].task_mean="ORDERPROFILE"))
    SET ordpro_idx = s
   ELSEIF ((request->plist[s].task_mean="CANCELORDER"))
    SET cancel_idx = s
   ELSEIF ((request->plist[s].task_mean="COMPLETEORDER"))
    SET complete_idx = s
   ELSEIF ((request->plist[s].task_mean="MODIFYMEDSTUDORDER"))
    SET modmsord_idx = s
   ELSEIF ((request->plist[s].task_mean="MODIFYORDER"))
    SET modord_idx = s
   ELSEIF ((request->plist[s].task_mean="REPEATORDER"))
    SET repeat_idx = s
   ELSEIF ((request->plist[s].task_mean="RESCHEDORDER"))
    SET resched_idx = s
   ELSEIF ((request->plist[s].task_mean="SUSPENDORDER"))
    SET suspend_idx = s
   ELSEIF ((request->plist[s].task_mean="VOIDORDER"))
    SET void_idx = s
   ELSEIF ((request->plist[s].task_mean="VIEWMEDS"))
    SET viewmed_idx = s
   ELSEIF ((request->plist[s].task_mean="UPDPASTANDCURRENTMEDS"))
    SET updpc_idx = s
   ELSEIF ((request->plist[s].task_mean="UPDMEDS"))
    SET updmed_idx = s
   ELSEIF ((request->plist[s].task_mean="RXREPRINT"))
    SET reprint_idx = s
   ELSEIF ((request->plist[s].task_mean="ORDERTORX"))
    SET ordertorx_idx = s
   ELSEIF ((request->plist[s].task_mean="RXTOACUTEORDER"))
    SET rxtoacute_idx = s
   ELSEIF ((request->plist[s].task_mean="RXTOAMBORDER"))
    SET rxtoamb_idx = s
   ELSEIF ((request->plist[s].task_mean="VIEWNOTES"))
    SET viewnote_idx = s
   ELSEIF ((request->plist[s].task_mean="UPDNOTES"))
    SET updnote_idx = s
   ELSEIF ((request->plist[s].task_mean="SCANNOTES"))
    SET scan_idx = s
   ELSEIF ((request->plist[s].task_mean="SAVESTRUCTDOC"))
    SET savedoc_idx = s
   ELSEIF ((request->plist[s].task_mean="SIGNSTRUCTDOC"))
    SET signdoc_idx = s
   ELSEIF ((request->plist[s].task_mean="PRECOMPNOTES"))
    SET precomp_idx = s
   ELSEIF ((request->plist[s].task_mean="ORDDIAGSTRUCTDOC"))
    SET orddiag_idx = s
   ELSEIF ((request->plist[s].task_mean="RXSTRUCTDOC"))
    SET rxstruct_idx = s
   ELSEIF ((request->plist[s].task_mean="MINEONLYSTRUCTDOC"))
    SET mineonly_idx = s
   ELSEIF ((request->plist[s].task_mean="CERTAINCAREDESIGNS"))
    SET certcare_idx = s
   ELSEIF ((request->plist[s].task_mean="VIEWFORM"))
    SET viewform_idx = s
   ELSEIF ((request->plist[s].task_mean="SAVEFORM"))
    SET saveform_idx = s
   ELSEIF ((request->plist[s].task_mean="SIGNFORM"))
    SET signform_idx = s
   ELSEIF ((request->plist[s].task_mean="VIEWPTHIST"))
    SET viewhist_idx = s
   ELSEIF ((request->plist[s].task_mean="UPDPTHIST"))
    SET updhist_idx = s
   ELSEIF ((request->plist[s].task_mean="VIEWRESULT"))
    SET viewrslt_idx = s
   ELSEIF ((request->plist[s].task_mean="COMMENTRESULT"))
    SET commrslt_idx = s
   ELSEIF ((request->plist[s].task_mean="VIEWTASK"))
    SET viewtask_idx = s
   ELSEIF ((request->plist[s].task_mean="UPDTASK"))
    SET updtask_idx = s
   ELSEIF ((request->plist[s].task_mean="RESULTTOENDORSE"))
    SET rsltend_idx = s
   ELSEIF ((request->plist[s].task_mean="SIGNPATDOC"))
    SET signpatdoc_idx = s
   ELSEIF ((request->plist[s].task_mean="REVPATRSLT"))
    SET revpatrslt_idx = s
   ELSEIF ((request->plist[s].task_mean="SIGNPATRSLT"))
    SET signpatrslt_idx = s
   ELSEIF ((request->plist[s].task_mean="CORRESPOND"))
    SET correspond_idx = s
   ELSEIF ((request->plist[s].task_mean="FORWARDRESULTINBOX"))
    SET fwdinbox_idx = s
   ELSEIF ((request->plist[s].task_mean="FORWARDRESULTEMAIL"))
    SET fwdemail_idx = s
   ELSEIF ((request->plist[s].task_mean="REVPATDOC"))
    SET revpatdoc_idx = s
   ELSEIF ((request->plist[s].task_mean="RECEIVEDICTDOC"))
    SET recdictdoc_idx = s
   ELSEIF ((request->plist[s].task_mean="SAVEPHONEMSGTOCHART"))
    SET savephone_idx = s
   ELSEIF ((request->plist[s].task_mean="ADDPHONEMSGENCNTR"))
    SET addphone_idx = s
   ELSEIF ((request->plist[s].task_mean="RECEIVEPHONEMSG"))
    SET recphone_idx = s
   ELSEIF ((request->plist[s].task_mean="ORDERSTOAPPROVE"))
    SET ordtoapp_idx = s
   ELSEIF ((request->plist[s].task_mean="SAVEDDOC"))
    SET saveddoc_idx = s
   ELSEIF ((request->plist[s].task_mean="SENTITEMS"))
    SET sentitems_idx = s
   ENDIF
 ENDFOR
 IF (viewressch_idx > 0)
  IF ((request->plist[viewressch_idx].action_flag > 0))
   IF ((request->plist[viewressch_idx].action_flag=1))
    SET singletaskrequest->action = "2"
   ELSE
    SET singletaskrequest->action = "3"
   ENDIF
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_sched  WITH replace("REQUEST",singletaskrequest), replace("REPLY",
    singletaskreply)
  ENDIF
 ENDIF
 IF (viewapptbk_idx > 0)
  IF ((request->plist[viewapptbk_idx].action_flag > 0))
   IF ((request->plist[viewapptbk_idx].action_flag=1))
    SET singletaskrequest->action = "2"
   ELSE
    SET singletaskrequest->action = "3"
   ENDIF
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_apptbook  WITH replace("REQUEST",singletaskrequest), replace("REPLY",
    singletaskreply)
  ENDIF
 ENDIF
 IF (indptarr_idx > 0)
  IF ((request->plist[indptarr_idx].action_flag > 0))
   IF ((request->plist[indptarr_idx].action_flag=1))
    SET singletaskrequest->action = "2"
   ELSE
    SET singletaskrequest->action = "3"
   ENDIF
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_ptarrival  WITH replace("REQUEST",singletaskrequest), replace("REPLY",
    singletaskreply)
  ENDIF
 ENDIF
 IF (updimm_idx > 0)
  IF ((request->plist[updimm_idx].action_flag > 0))
   IF ((request->plist[updimm_idx].action_flag=1))
    SET singletaskrequest->action = "2"
   ELSE
    SET singletaskrequest->action = "3"
   ENDIF
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_immun  WITH replace("REQUEST",singletaskrequest), replace("REPLY",
    singletaskreply)
  ENDIF
 ENDIF
 IF (updhlthmnt_idx > 0)
  IF ((request->plist[updhlthmnt_idx].action_flag > 0))
   IF ((request->plist[updhlthmnt_idx].action_flag=1))
    SET singletaskrequest->action = "2"
   ELSE
    SET singletaskrequest->action = "3"
   ENDIF
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_hlthmaint  WITH replace("REQUEST",singletaskrequest), replace("REPLY",
    singletaskreply)
  ENDIF
 ENDIF
 IF (pedgrwthch_idx > 0)
  IF ((request->plist[pedgrwthch_idx].action_flag > 0))
   IF ((request->plist[pedgrwthch_idx].action_flag=1))
    SET singletaskrequest->action = "2"
   ELSE
    SET singletaskrequest->action = "3"
   ENDIF
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_pedgwthch  WITH replace("REQUEST",singletaskrequest), replace("REPLY",
    singletaskreply)
  ENDIF
 ENDIF
 IF (emassist_idx > 0)
  IF ((request->plist[emassist_idx].action_flag > 0))
   IF ((request->plist[emassist_idx].action_flag=1))
    SET singletaskrequest->action = "2"
   ELSE
    SET singletaskrequest->action = "3"
   ENDIF
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_emassist  WITH replace("REQUEST",singletaskrequest), replace("REPLY",
    singletaskreply)
  ENDIF
 ENDIF
 IF (viewcharge_idx > 0)
  IF ((request->plist[viewcharge_idx].action_flag > 0))
   IF ((request->plist[viewcharge_idx].action_flag=1))
    SET singletaskrequest->action = "2"
   ELSE
    SET singletaskrequest->action = "3"
   ENDIF
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_charge  WITH replace("REQUEST",singletaskrequest), replace("REPLY",
    singletaskreply)
  ENDIF
 ENDIF
 IF (pubmedrec_idx > 0)
  IF ((request->plist[pubmedrec_idx].action_flag > 0))
   IF ((request->plist[pubmedrec_idx].action_flag=1))
    SET singletaskrequest->action = "2"
   ELSE
    SET singletaskrequest->action = "3"
   ENDIF
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_pubmedrec  WITH replace("REQUEST",singletaskrequest), replace("REPLY",
    singletaskreply)
  ENDIF
 ENDIF
 IF (viewallergy_idx > 0
  AND updallergy_idx > 0)
  IF ((((request->plist[viewallergy_idx].action_flag > 0)) OR ((request->plist[updallergy_idx].
  action_flag > 0))) )
   SET curr_view = " "
   SET curr_upd = " "
   SET stat = alterlist(multitaskrequest->task_list,2)
   SET stat = alterlist(multitaskreply->status_data.status_list,2)
   SET multitaskrequest->task_list[1].task = "VIEWALLERGY"
   SET multitaskrequest->task_list[2].task = "UPDALLERGY"
   SET multitaskrequest->action = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_allergy  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
    multitaskreply)
   SET curr_view = multitaskreply->status_data.status_list[1].status
   SET curr_upd = multitaskreply->status_data.status_list[2].status
   IF ((request->plist[viewallergy_idx].action_flag=0))
    IF (curr_view="0")
     SET multitaskrequest->task_list[1].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[1].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[1].on_off_ind = request->plist[viewallergy_idx].action_flag
   ENDIF
   IF ((request->plist[updallergy_idx].action_flag=0))
    IF (curr_upd="0")
     SET multitaskrequest->task_list[2].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[2].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[2].on_off_ind = request->plist[updallergy_idx].action_flag
   ENDIF
   SET multitaskrequest->action = "2"
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_allergy  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
    multitaskreply)
  ENDIF
 ENDIF
 IF (viewprob_idx > 0
  AND updprob_idx > 0)
  IF ((((request->plist[viewprob_idx].action_flag > 0)) OR ((request->plist[updprob_idx].action_flag
   > 0))) )
   SET curr_view = " "
   SET curr_upd = " "
   SET stat = alterlist(multitaskrequest->task_list,2)
   SET stat = alterlist(multitaskreply->status_data.status_list,2)
   SET multitaskrequest->task_list[1].task = "VIEWPROBLEM"
   SET multitaskrequest->task_list[2].task = "UPDPROBLEM"
   SET multitaskrequest->action = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_problem  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
    multitaskreply)
   SET curr_view = multitaskreply->status_data.status_list[1].status
   SET curr_upd = multitaskreply->status_data.status_list[2].status
   IF ((request->plist[viewprob_idx].action_flag=0))
    IF (curr_view="0")
     SET multitaskrequest->task_list[1].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[1].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[1].on_off_ind = request->plist[viewprob_idx].action_flag
   ENDIF
   IF ((request->plist[updprob_idx].action_flag=0))
    IF (curr_upd="0")
     SET multitaskrequest->task_list[2].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[2].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[2].on_off_ind = request->plist[updprob_idx].action_flag
   ENDIF
   SET multitaskrequest->action = "2"
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_problem  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
    multitaskreply)
  ENDIF
 ENDIF
 IF (viewprochist_idx > 0
  AND updprochist_idx > 0)
  IF ((((request->plist[viewprochist_idx].action_flag > 0)) OR ((request->plist[updprochist_idx].
  action_flag > 0))) )
   SET curr_view = " "
   SET curr_upd = " "
   SET stat = alterlist(multitaskrequest->task_list,2)
   SET stat = alterlist(multitaskreply->status_data.status_list,2)
   SET multitaskrequest->task_list[1].task = "VIEWPROCHIST"
   SET multitaskrequest->task_list[2].task = "UPDPROCHIST"
   SET multitaskrequest->action = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_prochist  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
    multitaskreply)
   SET curr_view = multitaskreply->status_data.status_list[1].status
   SET curr_upd = multitaskreply->status_data.status_list[2].status
   IF ((request->plist[viewprochist_idx].action_flag=0))
    IF (curr_view="0")
     SET multitaskrequest->task_list[1].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[1].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[1].on_off_ind = request->plist[viewprochist_idx].action_flag
   ENDIF
   IF ((request->plist[updprochist_idx].action_flag=0))
    IF (curr_upd="0")
     SET multitaskrequest->task_list[2].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[2].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[2].on_off_ind = request->plist[updprochist_idx].action_flag
   ENDIF
   SET multitaskrequest->action = "2"
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_prochist  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
    multitaskreply)
  ENDIF
 ENDIF
 IF (vieword_idx > 0
  AND ordpro_idx > 0)
  IF ((((request->plist[order_idx].action_flag > 0)) OR ((((request->plist[vieword_idx].action_flag
   > 0)) OR ((((request->plist[ordpro_idx].action_flag > 0)) OR ((((request->plist[cancel_idx].
  action_flag > 0)) OR ((((request->plist[complete_idx].action_flag > 0)) OR ((((request->plist[
  modmsord_idx].action_flag > 0)) OR ((((request->plist[modord_idx].action_flag > 0)) OR ((((request
  ->plist[repeat_idx].action_flag > 0)) OR ((((request->plist[resched_idx].action_flag > 0)) OR ((((
  request->plist[suspend_idx].action_flag > 0)) OR ((request->plist[void_idx].action_flag > 0))) ))
  )) )) )) )) )) )) )) )) )
   SET curr_order = " "
   SET curr_view = " "
   SET curr_ordpro = " "
   SET curr_cancel = " "
   SET curr_complete = " "
   SET curr_modms = " "
   SET curr_mod = " "
   SET curr_repeat = " "
   SET curr_resched = " "
   SET curr_suspend = " "
   SET curr_void = " "
   SET stat = alterlist(multitaskrequest->task_list,11)
   SET stat = alterlist(multitaskreply->status_data.status_list,11)
   SET multitaskrequest->task_list[1].task = "ORDER"
   SET multitaskrequest->task_list[2].task = "VIEWORDER"
   SET multitaskrequest->task_list[3].task = "ORDERPROFILE"
   SET multitaskrequest->task_list[4].task = "CANCELORDER"
   SET multitaskrequest->task_list[5].task = "COMPLETEORDER"
   SET multitaskrequest->task_list[6].task = "MODIFYMEDSTUDORDER"
   SET multitaskrequest->task_list[7].task = "MODIFYORDER"
   SET multitaskrequest->task_list[8].task = "REPEATORDER"
   SET multitaskrequest->task_list[9].task = "RESCHEDORDER"
   SET multitaskrequest->task_list[10].task = "SUSPENDORDER"
   SET multitaskrequest->task_list[11].task = "VOIDORDER"
   SET multitaskrequest->action = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_order  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
    multitaskreply)
   SET curr_order = multitaskreply->status_data.status_list[1].status
   SET curr_view = multitaskreply->status_data.status_list[2].status
   SET curr_ordpro = multitaskreply->status_data.status_list[3].status
   SET curr_cancel = multitaskreply->status_data.status_list[4].status
   SET curr_complete = multitaskreply->status_data.status_list[5].status
   SET curr_modms = multitaskreply->status_data.status_list[6].status
   SET curr_mod = multitaskreply->status_data.status_list[7].status
   SET curr_repeat = multitaskreply->status_data.status_list[8].status
   SET curr_resched = multitaskreply->status_data.status_list[9].status
   SET curr_suspend = multitaskreply->status_data.status_list[10].status
   SET curr_void = multitaskreply->status_data.status_list[11].status
   IF ((request->plist[order_idx].action_flag=0))
    IF (curr_order="0")
     SET multitaskrequest->task_list[1].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[1].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[1].on_off_ind = request->plist[order_idx].action_flag
   ENDIF
   IF ((request->plist[vieword_idx].action_flag=0))
    IF (curr_view="0")
     SET multitaskrequest->task_list[2].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[2].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[2].on_off_ind = request->plist[vieword_idx].action_flag
   ENDIF
   IF ((request->plist[ordpro_idx].action_flag=0))
    IF (curr_ordpro="0")
     SET multitaskrequest->task_list[3].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[3].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[3].on_off_ind = request->plist[ordpro_idx].action_flag
   ENDIF
   IF ((request->plist[cancel_idx].action_flag=0))
    IF (curr_cancel="0")
     SET multitaskrequest->task_list[4].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[4].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[4].on_off_ind = request->plist[cancel_idx].action_flag
   ENDIF
   IF ((request->plist[complete_idx].action_flag=0))
    IF (curr_complete="0")
     SET multitaskrequest->task_list[5].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[5].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[5].on_off_ind = request->plist[complete_idx].action_flag
   ENDIF
   IF ((request->plist[modmsord_idx].action_flag=0))
    IF (curr_modms="0")
     SET multitaskrequest->task_list[6].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[6].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[6].on_off_ind = request->plist[modmsord_idx].action_flag
   ENDIF
   IF ((request->plist[modord_idx].action_flag=0))
    IF (curr_mod="0")
     SET multitaskrequest->task_list[7].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[7].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[7].on_off_ind = request->plist[modord_idx].action_flag
   ENDIF
   IF ((request->plist[repeat_idx].action_flag=0))
    IF (curr_repeat="0")
     SET multitaskrequest->task_list[8].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[8].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[8].on_off_ind = request->plist[repeat_idx].action_flag
   ENDIF
   IF ((request->plist[resched_idx].action_flag=0))
    IF (curr_resched="0")
     SET multitaskrequest->task_list[9].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[9].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[9].on_off_ind = request->plist[resched_idx].action_flag
   ENDIF
   IF ((request->plist[suspend_idx].action_flag=0))
    IF (curr_suspend="0")
     SET multitaskrequest->task_list[10].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[10].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[10].on_off_ind = request->plist[suspend_idx].action_flag
   ENDIF
   IF ((request->plist[void_idx].action_flag=0))
    IF (curr_void="0")
     SET multitaskrequest->task_list[11].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[11].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[11].on_off_ind = request->plist[void_idx].action_flag
   ENDIF
   SET multitaskrequest->action = "2"
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_order  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
    multitaskreply)
  ENDIF
 ENDIF
 IF (viewmed_idx > 0
  AND updpc_idx > 0
  AND updmed_idx > 0)
  IF ((((request->plist[viewmed_idx].action_flag > 0)) OR ((((request->plist[updpc_idx].action_flag
   > 0)) OR ((((request->plist[updmed_idx].action_flag > 0)) OR ((((request->plist[reprint_idx].
  action_flag > 0)) OR ((((request->plist[ordertorx_idx].action_flag > 0)) OR ((((request->plist[
  rxtoacute_idx].action_flag > 0)) OR ((request->plist[rxtoamb_idx].action_flag > 0))) )) )) )) ))
  )) )
   SET curr_view = " "
   SET curr_updpc = " "
   SET curr_upd = " "
   SET curr_reprint = " "
   SET curr_order = " "
   SET curr_acute = " "
   SET curr_amb = " "
   SET stat = alterlist(multitaskrequest->task_list,7)
   SET stat = alterlist(multitaskreply->status_data.status_list,7)
   SET multitaskrequest->task_list[1].task = "VIEWMEDS"
   SET multitaskrequest->task_list[2].task = "UPDPASTANDCURRENTMEDS"
   SET multitaskrequest->task_list[3].task = "UPDMEDS"
   SET multitaskrequest->task_list[4].task = "RXREPRINT"
   SET multitaskrequest->task_list[5].task = "ORDERTORX"
   SET multitaskrequest->task_list[6].task = "RXTOACUTEORDER"
   SET multitaskrequest->task_list[7].task = "RXTOAMBORDER"
   SET multitaskrequest->action = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_med  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
    multitaskreply)
   SET curr_view = multitaskreply->status_data.status_list[1].status
   SET curr_updpc = multitaskreply->status_data.status_list[2].status
   SET curr_upd = multitaskreply->status_data.status_list[3].status
   SET curr_reprint = multitaskreply->status_data.status_list[4].status
   SET curr_order = multitaskreply->status_data.status_list[5].status
   SET curr_acute = multitaskreply->status_data.status_list[6].status
   SET curr_amb = multitaskreply->status_data.status_list[7].status
   IF ((request->plist[viewmed_idx].action_flag=0))
    IF (curr_view="0")
     SET multitaskrequest->task_list[1].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[1].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[1].on_off_ind = request->plist[viewmed_idx].action_flag
   ENDIF
   IF ((request->plist[updpc_idx].action_flag=0))
    IF (curr_updpc="0")
     SET multitaskrequest->task_list[2].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[2].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[2].on_off_ind = request->plist[updpc_idx].action_flag
   ENDIF
   IF ((request->plist[updmed_idx].action_flag=0))
    IF (curr_upd="0")
     SET multitaskrequest->task_list[3].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[3].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[3].on_off_ind = request->plist[updmed_idx].action_flag
   ENDIF
   IF ((request->plist[reprint_idx].action_flag=0))
    IF (curr_reprint="0")
     SET multitaskrequest->task_list[4].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[4].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[4].on_off_ind = request->plist[reprint_idx].action_flag
   ENDIF
   IF ((request->plist[ordertorx_idx].action_flag=0))
    IF (curr_order="0")
     SET multitaskrequest->task_list[5].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[5].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[5].on_off_ind = request->plist[ordertorx_idx].action_flag
   ENDIF
   IF ((request->plist[rxtoacute_idx].action_flag=0))
    IF (curr_acute="0")
     SET multitaskrequest->task_list[6].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[6].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[6].on_off_ind = request->plist[rxtoacute_idx].action_flag
   ENDIF
   IF ((request->plist[rxtoamb_idx].action_flag=0))
    IF (curr_amb="0")
     SET multitaskrequest->task_list[7].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[7].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[7].on_off_ind = request->plist[rxtoamb_idx].action_flag
   ENDIF
   SET multitaskrequest->action = "2"
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_med  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
    multitaskreply)
  ENDIF
 ENDIF
 IF (viewnote_idx > 0
  AND updnote_idx > 0)
  SET curr_view = " "
  SET curr_upd = " "
  SET curr_scan = " "
  SET stat = alterlist(multitaskrequest->task_list,3)
  SET stat = alterlist(multitaskreply->status_data.status_list,3)
  SET multitaskrequest->task_list[1].task = "VIEWNOTES"
  SET multitaskrequest->task_list[2].task = "UPDNOTES"
  SET multitaskrequest->task_list[3].task = "SCANNOTES"
  SET multitaskrequest->action = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_tasks_note  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
   multitaskreply)
  SET curr_view = multitaskreply->status_data.status_list[1].status
  SET curr_upd = multitaskreply->status_data.status_list[2].status
  SET curr_scan = multitaskreply->status_data.status_list[3].status
  IF ((request->plist[viewnote_idx].action_flag=0))
   IF (curr_view="0")
    SET multitaskrequest->task_list[1].on_off_ind = 3
   ELSE
    SET multitaskrequest->task_list[1].on_off_ind = 1
   ENDIF
  ELSE
   SET multitaskrequest->task_list[1].on_off_ind = request->plist[viewnote_idx].action_flag
  ENDIF
  SET multitaskrequest->task_list[2].on_off_ind = request->plist[updnote_idx].action_flag
  IF ((request->plist[scan_idx].action_flag=0))
   IF (curr_scan="0")
    SET multitaskrequest->task_list[3].on_off_ind = 3
   ELSE
    SET multitaskrequest->task_list[3].on_off_ind = 1
   ENDIF
  ELSE
   SET multitaskrequest->task_list[3].on_off_ind = request->plist[scan_idx].action_flag
  ENDIF
  SET multitaskrequest->action = "2"
  SET trace = recpersist
  EXECUTE bed_get_ens_tasks_note  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
   multitaskreply)
 ENDIF
 IF (savedoc_idx > 0
  AND signdoc_idx > 0)
  IF ((((request->plist[savedoc_idx].action_flag > 0)) OR ((((request->plist[signdoc_idx].action_flag
   > 0)) OR ((((request->plist[precomp_idx].action_flag > 0)) OR ((((request->plist[orddiag_idx].
  action_flag > 0)) OR ((((request->plist[rxstruct_idx].action_flag > 0)) OR ((((request->plist[
  mineonly_idx].action_flag > 0)) OR ((request->plist[certcare_idx].action_flag > 0))) )) )) )) ))
  )) )
   SET curr_save = " "
   SET curr_sign = " "
   SET curr_precomp = " "
   SET curr_ord = " "
   SET curr_rx = " "
   SET curr_mineonly = " "
   SET curr_certcare = " "
   SET stat = alterlist(multitaskrequest->task_list,7)
   SET stat = alterlist(multitaskreply->status_data.status_list,7)
   SET multitaskrequest->task_list[1].task = "SAVESTRUCTDOC"
   SET multitaskrequest->task_list[2].task = "SIGNSTRUCTDOC"
   SET multitaskrequest->task_list[3].task = "PRECOMPNOTES"
   SET multitaskrequest->task_list[4].task = "ORDDIAGSTRUCTDOC"
   SET multitaskrequest->task_list[5].task = "RXSTRUCTDOC"
   SET multitaskrequest->task_list[6].task = "MINEONLYSTRUCTDOC"
   SET multitaskrequest->task_list[7].task = "CERTAINCAREDESIGNS"
   SET multitaskrequest->action = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_structdoc  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
    multitaskreply)
   SET curr_save = multitaskreply->status_data.status_list[1].status
   SET curr_sign = multitaskreply->status_data.status_list[2].status
   SET curr_precomp = multitaskreply->status_data.status_list[3].status
   SET curr_ord = multitaskreply->status_data.status_list[4].status
   SET curr_rx = multitaskreply->status_data.status_list[5].status
   SET curr_mineonly = multitaskreply->status_data.status_list[6].status
   SET curr_certcare = multitaskreply->status_data.status_list[7].status
   IF ((request->plist[savedoc_idx].action_flag=0))
    IF (curr_save="0")
     SET multitaskrequest->task_list[1].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[1].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[1].on_off_ind = request->plist[savedoc_idx].action_flag
   ENDIF
   IF ((request->plist[signdoc_idx].action_flag=0))
    IF (curr_sign="0")
     SET multitaskrequest->task_list[2].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[2].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[2].on_off_ind = request->plist[signdoc_idx].action_flag
   ENDIF
   IF ((request->plist[precomp_idx].action_flag=0))
    IF (curr_precomp="0")
     SET multitaskrequest->task_list[3].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[3].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[3].on_off_ind = request->plist[precomp_idx].action_flag
   ENDIF
   IF ((request->plist[orddiag_idx].action_flag=0))
    IF (curr_ord="0")
     SET multitaskrequest->task_list[4].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[4].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[4].on_off_ind = request->plist[orddiag_idx].action_flag
   ENDIF
   IF ((request->plist[rxstruct_idx].action_flag=0))
    IF (curr_rx="0")
     SET multitaskrequest->task_list[5].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[5].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[5].on_off_ind = request->plist[rxstruct_idx].action_flag
   ENDIF
   IF ((request->plist[mineonly_idx].action_flag=0))
    IF (curr_mineonly="0")
     SET multitaskrequest->task_list[6].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[6].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[6].on_off_ind = request->plist[mineonly_idx].action_flag
   ENDIF
   IF ((request->plist[certcare_idx].action_flag=0))
    IF (curr_certcare="0")
     SET multitaskrequest->task_list[7].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[7].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[7].on_off_ind = request->plist[certcare_idx].action_flag
   ENDIF
   SET multitaskrequest->action = "2"
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_structdoc  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
    multitaskreply)
  ENDIF
 ENDIF
 IF (viewform_idx > 0
  AND saveform_idx > 0
  AND signform_idx > 0)
  IF ((((request->plist[viewform_idx].action_flag > 0)) OR ((((request->plist[saveform_idx].
  action_flag > 0)) OR ((request->plist[signform_idx].action_flag > 0))) )) )
   SET curr_view = " "
   SET curr_save = " "
   SET curr_sign = " "
   SET stat = alterlist(multitaskrequest->task_list,3)
   SET stat = alterlist(multitaskreply->status_data.status_list,3)
   SET multitaskrequest->task_list[1].task = "VIEWFORM"
   SET multitaskrequest->task_list[2].task = "SAVEFORM"
   SET multitaskrequest->task_list[3].task = "SIGNFORM"
   SET multitaskrequest->action = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_form  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
    multitaskreply)
   SET curr_view = multitaskreply->status_data.status_list[1].status
   SET curr_save = multitaskreply->status_data.status_list[2].status
   SET curr_sign = multitaskreply->status_data.status_list[3].status
   IF ((request->plist[viewform_idx].action_flag=0))
    IF (curr_view="0")
     SET multitaskrequest->task_list[1].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[1].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[1].on_off_ind = request->plist[viewform_idx].action_flag
   ENDIF
   IF ((request->plist[saveform_idx].action_flag=0))
    IF (curr_save="0")
     SET multitaskrequest->task_list[2].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[2].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[2].on_off_ind = request->plist[saveform_idx].action_flag
   ENDIF
   IF ((request->plist[signform_idx].action_flag=0))
    IF (curr_sign="0")
     SET multitaskrequest->task_list[3].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[3].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[3].on_off_ind = request->plist[signform_idx].action_flag
   ENDIF
   SET multitaskrequest->action = "2"
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_form  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
    multitaskreply)
  ENDIF
 ENDIF
 IF (viewhist_idx > 0
  AND updhist_idx > 0)
  SET curr_viewhist = " "
  SET curr_updhist = " "
  SET curr_viewrslt = " "
  SET curr_commrslt = " "
  SET stat = alterlist(multitaskrequest->task_list,4)
  SET stat = alterlist(multitaskreply->status_data.status_list,4)
  SET multitaskrequest->task_list[1].task = "VIEWPTHIST"
  SET multitaskrequest->task_list[2].task = "UPDPTHIST"
  SET multitaskrequest->task_list[3].task = "VIEWRESULT"
  SET multitaskrequest->task_list[4].task = "COMMENTRESULT"
  SET multitaskrequest->action = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_tasks_pthistrslt  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
   multitaskreply)
  SET curr_viewhist = multitaskreply->status_data.status_list[1].status
  SET curr_updhist = multitaskreply->status_data.status_list[2].status
  SET curr_viewrslt = multitaskreply->status_data.status_list[3].status
  SET curr_commrslt = multitaskreply->status_data.status_list[4].status
  IF ((request->plist[viewhist_idx].action_flag=0))
   IF (curr_viewhist="0")
    SET multitaskrequest->task_list[1].on_off_ind = 3
   ELSE
    SET multitaskrequest->task_list[1].on_off_ind = 1
   ENDIF
  ELSE
   SET multitaskrequest->task_list[1].on_off_ind = request->plist[viewhist_idx].action_flag
  ENDIF
  IF ((request->plist[updhist_idx].action_flag=0))
   IF (curr_updhist="0")
    SET multitaskrequest->task_list[2].on_off_ind = 3
   ELSE
    SET multitaskrequest->task_list[2].on_off_ind = 1
   ENDIF
  ELSE
   SET multitaskrequest->task_list[2].on_off_ind = request->plist[updhist_idx].action_flag
  ENDIF
  IF ((request->plist[viewrslt_idx].action_flag=0))
   IF (curr_viewrslt="0")
    SET multitaskrequest->task_list[3].on_off_ind = 3
   ELSE
    SET multitaskrequest->task_list[3].on_off_ind = 1
   ENDIF
  ELSE
   SET multitaskrequest->task_list[3].on_off_ind = request->plist[viewrslt_idx].action_flag
  ENDIF
  SET multitaskrequest->task_list[4].on_off_ind = request->plist[commrslt_idx].action_flag
  SET multitaskrequest->action = "2"
  SET trace = recpersist
  EXECUTE bed_get_ens_tasks_pthistrslt  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
   multitaskreply)
 ENDIF
 IF (viewtask_idx > 0
  AND updtask_idx > 0)
  IF ((((request->plist[viewtask_idx].action_flag > 0)) OR ((request->plist[updtask_idx].action_flag
   > 0))) )
   SET curr_view = " "
   SET curr_upd = " "
   SET stat = alterlist(multitaskrequest->task_list,2)
   SET stat = alterlist(multitaskreply->status_data.status_list,2)
   SET multitaskrequest->task_list[1].task = "VIEWTASK"
   SET multitaskrequest->task_list[2].task = "UPDTASK"
   SET multitaskrequest->action = "0"
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_charttask  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
    multitaskreply)
   SET curr_view = multitaskreply->status_data.status_list[1].status
   SET curr_upd = multitaskreply->status_data.status_list[2].status
   IF ((request->plist[viewtask_idx].action_flag=0))
    IF (curr_view="0")
     SET multitaskrequest->task_list[1].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[1].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[1].on_off_ind = request->plist[viewtask_idx].action_flag
   ENDIF
   IF ((request->plist[updtask_idx].action_flag=0))
    IF (curr_upd="0")
     SET multitaskrequest->task_list[2].on_off_ind = 3
    ELSE
     SET multitaskrequest->task_list[2].on_off_ind = 1
    ENDIF
   ELSE
    SET multitaskrequest->task_list[2].on_off_ind = request->plist[updtask_idx].action_flag
   ENDIF
   SET multitaskrequest->action = "2"
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_charttask  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
    multitaskreply)
  ENDIF
 ENDIF
 IF (((rsltend_idx > 0) OR (((signpatdoc_idx > 0) OR (((revpatrslt_idx > 0) OR (((signpatrslt_idx > 0
 ) OR (((correspond_idx > 0) OR (((fwdinbox_idx > 0) OR (((fwdemail_idx > 0) OR (((revpatdoc_idx > 0)
  OR (((recdictdoc_idx > 0) OR (((savephone_idx > 0) OR (((addphone_idx > 0) OR (((recphone_idx > 0)
  OR (((ordtoapp_idx > 0) OR (((saveddoc_idx > 0) OR (sentitems_idx > 0)) )) )) )) )) )) )) )) )) ))
 )) )) )) )) )
  SET curr_rsltend = " "
  SET curr_signpatdoc = " "
  SET curr_revpatrslt = " "
  SET curr_signpatrslt = " "
  SET curr_correspond = " "
  SET curr_fwdinbox = " "
  SET curr_fwdemail = " "
  SET curr_revpatdoc = " "
  SET curr_recdictdoc = " "
  SET curr_savephone = " "
  SET curr_addphone = " "
  SET curr_recphone = " "
  SET curr_ordtoapp = " "
  SET curr_saveddoc = " "
  SET curr_sentitems = " "
  SET stat = alterlist(multitaskrequest->task_list,15)
  SET stat = alterlist(multitaskreply->status_data.status_list,15)
  SET multitaskrequest->task_list[1].task = "RESULTTOENDORSE"
  SET multitaskrequest->task_list[2].task = "SIGNPATDOC"
  SET multitaskrequest->task_list[3].task = "REVPATRSLT"
  SET multitaskrequest->task_list[4].task = "SIGNPATRSLT"
  SET multitaskrequest->task_list[5].task = "CORRESPOND"
  SET multitaskrequest->task_list[6].task = "FORWARDRESULTINBOX"
  SET multitaskrequest->task_list[7].task = "FORWARDRESULTEMAIL"
  SET multitaskrequest->task_list[8].task = "REVPATDOC"
  SET multitaskrequest->task_list[9].task = "RECEIVEDICTDOC"
  SET multitaskrequest->task_list[10].task = "SAVEPHONEMSGTOCHART"
  SET multitaskrequest->task_list[11].task = "ADDPHONEMSGENCNTR"
  SET multitaskrequest->task_list[12].task = "RECEIVEPHONEMSG"
  SET multitaskrequest->task_list[13].task = "ORDERSTOAPPROVE"
  SET multitaskrequest->task_list[14].task = "SAVEDDOC"
  SET multitaskrequest->task_list[15].task = "SENTITEMS"
  SET multitaskrequest->action = "0"
  SET trace = recpersist
  EXECUTE bed_get_ens_tasks_inbox  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
   multitaskreply)
  SET curr_rsltend = multitaskreply->status_data.status_list[1].status
  SET curr_signpatdoc = multitaskreply->status_data.status_list[2].status
  SET curr_revpatrslt = multitaskreply->status_data.status_list[3].status
  SET curr_signpatrslt = multitaskreply->status_data.status_list[4].status
  SET curr_correspond = multitaskreply->status_data.status_list[5].status
  SET curr_fwdinbox = multitaskreply->status_data.status_list[6].status
  SET curr_fwdemail = multitaskreply->status_data.status_list[7].status
  SET curr_revpatdoc = multitaskreply->status_data.status_list[8].status
  SET curr_recdictdoc = multitaskreply->status_data.status_list[9].status
  SET curr_savephone = multitaskreply->status_data.status_list[10].status
  SET curr_addphone = multitaskreply->status_data.status_list[11].status
  SET curr_recphone = multitaskreply->status_data.status_list[12].status
  SET curr_ordtoapp = multitaskreply->status_data.status_list[13].status
  SET curr_saveddoc = multitaskreply->status_data.status_list[14].status
  SET curr_sentitems = multitaskreply->status_data.status_list[15].status
  IF ((request->plist[rsltend_idx].action_flag=0))
   IF (curr_rsltend="0")
    SET multitaskrequest->task_list[1].on_off_ind = 3
   ELSE
    SET multitaskrequest->task_list[1].on_off_ind = 1
   ENDIF
  ELSE
   SET multitaskrequest->task_list[1].on_off_ind = request->plist[rsltend_idx].action_flag
  ENDIF
  IF ((request->plist[signpatdoc_idx].action_flag=0))
   IF (curr_signpatdoc="0")
    SET multitaskrequest->task_list[2].on_off_ind = 3
   ELSE
    SET multitaskrequest->task_list[2].on_off_ind = 1
   ENDIF
  ELSE
   SET multitaskrequest->task_list[2].on_off_ind = request->plist[signpatdoc_idx].action_flag
  ENDIF
  IF ((request->plist[revpatrslt_idx].action_flag=0))
   IF (curr_revpatrslt="0")
    SET multitaskrequest->task_list[3].on_off_ind = 3
   ELSE
    SET multitaskrequest->task_list[3].on_off_ind = 1
   ENDIF
  ELSE
   SET multitaskrequest->task_list[3].on_off_ind = request->plist[revpatrslt_idx].action_flag
  ENDIF
  IF ((request->plist[signpatrslt_idx].action_flag=0))
   IF (curr_signpatrslt="0")
    SET multitaskrequest->task_list[4].on_off_ind = 3
   ELSE
    SET multitaskrequest->task_list[4].on_off_ind = 1
   ENDIF
  ELSE
   SET multitaskrequest->task_list[4].on_off_ind = request->plist[signpatrslt_idx].action_flag
  ENDIF
  IF ((request->plist[correspond_idx].action_flag=0))
   IF (curr_correspond="0")
    SET multitaskrequest->task_list[5].on_off_ind = 3
   ELSE
    SET multitaskrequest->task_list[5].on_off_ind = 1
   ENDIF
  ELSE
   SET multitaskrequest->task_list[5].on_off_ind = request->plist[correspond_idx].action_flag
  ENDIF
  IF ((request->plist[fwdinbox_idx].action_flag=0))
   IF (curr_fwdinbox="0")
    SET multitaskrequest->task_list[6].on_off_ind = 3
   ELSE
    SET multitaskrequest->task_list[6].on_off_ind = 1
   ENDIF
  ELSE
   SET multitaskrequest->task_list[6].on_off_ind = request->plist[fwdinbox_idx].action_flag
  ENDIF
  IF ((request->plist[fwdemail_idx].action_flag=0))
   IF (curr_fwdemail="0")
    SET multitaskrequest->task_list[7].on_off_ind = 3
   ELSE
    SET multitaskrequest->task_list[7].on_off_ind = 1
   ENDIF
  ELSE
   SET multitaskrequest->task_list[7].on_off_ind = request->plist[fwdemail_idx].action_flag
  ENDIF
  IF ((request->plist[revpatdoc_idx].action_flag=0))
   IF (curr_revpatdoc="0")
    SET multitaskrequest->task_list[8].on_off_ind = 3
   ELSE
    SET multitaskrequest->task_list[8].on_off_ind = 1
   ENDIF
  ELSE
   SET multitaskrequest->task_list[8].on_off_ind = request->plist[revpatdoc_idx].action_flag
  ENDIF
  IF ((request->plist[recdictdoc_idx].action_flag=0))
   IF (curr_recdictdoc="0")
    SET multitaskrequest->task_list[9].on_off_ind = 3
   ELSE
    SET multitaskrequest->task_list[9].on_off_ind = 1
   ENDIF
  ELSE
   SET multitaskrequest->task_list[9].on_off_ind = request->plist[recdictdoc_idx].action_flag
  ENDIF
  IF ((request->plist[savephone_idx].action_flag=0))
   IF (curr_savephone="0")
    SET multitaskrequest->task_list[10].on_off_ind = 3
   ELSE
    SET multitaskrequest->task_list[10].on_off_ind = 1
   ENDIF
  ELSE
   SET multitaskrequest->task_list[10].on_off_ind = request->plist[savephone_idx].action_flag
  ENDIF
  IF ((request->plist[addphone_idx].action_flag=0))
   IF (curr_addphone="0")
    SET multitaskrequest->task_list[11].on_off_ind = 3
   ELSE
    SET multitaskrequest->task_list[11].on_off_ind = 1
   ENDIF
  ELSE
   SET multitaskrequest->task_list[11].on_off_ind = request->plist[addphone_idx].action_flag
  ENDIF
  IF ((request->plist[recphone_idx].action_flag=0))
   IF (curr_recphone="0")
    SET multitaskrequest->task_list[12].on_off_ind = 3
   ELSE
    SET multitaskrequest->task_list[12].on_off_ind = 1
   ENDIF
  ELSE
   SET multitaskrequest->task_list[12].on_off_ind = request->plist[recphone_idx].action_flag
  ENDIF
  IF ((request->plist[ordtoapp_idx].action_flag=0))
   IF (curr_ordtoapp="0")
    SET multitaskrequest->task_list[13].on_off_ind = 3
   ELSE
    SET multitaskrequest->task_list[13].on_off_ind = 1
   ENDIF
  ELSE
   SET multitaskrequest->task_list[13].on_off_ind = request->plist[ordtoapp_idx].action_flag
  ENDIF
  IF ((request->plist[saveddoc_idx].action_flag=0))
   IF (curr_saveddoc="0")
    SET multitaskrequest->task_list[14].on_off_ind = 3
   ELSE
    SET multitaskrequest->task_list[14].on_off_ind = 1
   ENDIF
  ELSE
   SET multitaskrequest->task_list[14].on_off_ind = request->plist[saveddoc_idx].action_flag
  ENDIF
  IF ((request->plist[sentitems_idx].action_flag=0))
   IF (curr_sentitems="0")
    SET multitaskrequest->task_list[15].on_off_ind = 3
   ELSE
    SET multitaskrequest->task_list[15].on_off_ind = 1
   ENDIF
  ELSE
   SET multitaskrequest->task_list[15].on_off_ind = request->plist[sentitems_idx].action_flag
  ENDIF
  SET multitaskrequest->action = "2"
  SET trace = recpersist
  EXECUTE bed_get_ens_tasks_inbox  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
   multitaskreply)
 ENDIF
 SET stat = alterlist(misctaskrequest->task_list,17)
 SET stat = alterlist(misctaskreply->status_data.status_list,17)
 SET misctaskrequest->task_list[1].task = " "
 SET misctaskrequest->task_list[2].task = " "
 SET misctaskrequest->task_list[3].task = " "
 SET misctaskrequest->task_list[4].task = " "
 SET misctaskrequest->task_list[5].task = " "
 SET misctaskrequest->task_list[6].task = " "
 SET misctaskrequest->task_list[7].task = " "
 SET misctaskrequest->task_list[8].task = " "
 SET misctaskrequest->task_list[9].task = " "
 SET misctaskrequest->task_list[10].task = " "
 SET misctaskrequest->task_list[11].task = " "
 SET misctaskrequest->task_list[12].task = " "
 SET misctaskrequest->task_list[13].task = " "
 SET misctaskrequest->task_list[14].task = " "
 SET misctaskrequest->task_list[15].task = " "
 SET misctaskrequest->task_list[16].task = " "
 SET misctaskrequest->task_list[17].task = " "
 SET misc_idx = 0
 FOR (s = 1 TO pcnt)
   IF ((request->plist[s].action_flag > 0))
    IF ((((request->plist[s].task_mean="PATIENTLIST")) OR ((((request->plist[s].task_mean=
    "INTELLISTRIP")) OR ((((request->plist[s].task_mean="PROVRELTN")) OR ((((request->plist[s].
    task_mean="ENCOUNTERS")) OR ((((request->plist[s].task_mean="HEALTHPLANS")) OR ((((request->
    plist[s].task_mean="POWERORDERS")) OR ((((request->plist[s].task_mean="MAR")) OR ((((request->
    plist[s].task_mean="WEBSITE")) OR ((((request->plist[s].task_mean="SHIFTASSIGN")) OR ((((request
    ->plist[s].task_mean="COSIGNORDER")) OR ((((request->plist[s].task_mean="ADVGRAPH")) OR ((((
    request->plist[s].task_mean="IANDO")) OR ((((request->plist[s].task_mean="CHARTSUMMARY")) OR ((((
    request->plist[s].task_mean="PATIENTACCESS")) OR ((((request->plist[s].task_mean=
    "VIEWSTICKYNOTES")) OR ((((request->plist[s].task_mean="ADDSTICKYNOTES")) OR ((request->plist[s].
    task_mean="REPORTS"))) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )) )
     SET misc_idx = (misc_idx+ 1)
     SET misctaskrequest->task_list[misc_idx].task = request->plist[s].task_mean
     SET misctaskrequest->task_list[misc_idx].on_off_ind = request->plist[s].action_flag
    ENDIF
   ENDIF
 ENDFOR
 IF (misc_idx > 0)
  SET misctaskrequest->website_url = request->website_url
  SET misctaskrequest->website_display = request->website_display
  SET misctaskrequest->action = "2"
  SET trace = recpersist
  EXECUTE bed_get_ens_tasks_misc  WITH replace("REQUEST",misctaskrequest), replace("REPLY",
   misctaskreply)
 ENDIF
 IF ((request->set_reviewed_ind=1))
  SELECT INTO "nl:"
   FROM br_name_value bnv
   PLAN (bnv
    WHERE bnv.br_nv_key1="REVIEWED"
     AND bnv.br_name="PCOSECURITY"
     AND bnv.br_value=cnvtstring(request->position_code_value))
   WITH nocounter
  ;end select
  IF (curqual=0)
   INSERT  FROM br_name_value bnv
    SET bnv.br_name_value_id = seq(bedrock_seq,nextval), bnv.br_nv_key1 = "REVIEWED", bnv.br_name =
     "PCOSECURITY",
     bnv.br_value = cnvtstring(request->position_code_value), bnv.updt_id = reqinfo->updt_id, bnv
     .updt_task = reqinfo->updt_task,
     bnv.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
  ENDIF
 ENDIF
 IF ((((request->physassist_code_value > 0)
  AND (request->physassist_action_flag=2)) OR ((((request->nursepract_code_value > 0)
  AND (request->nursepract_action_flag=2)) OR ((request->position_code_value > 0)
  AND (request->newposition_action_flag=2))) )) )
  SET no_cd = 0.0
  SET yes_cd = 0.0
  SELECT INTO "nl:"
   FROM code_value c
   PLAN (c
    WHERE c.code_set=6017
     AND c.cdf_meaning IN ("YES", "NO"))
   DETAIL
    IF (c.cdf_meaning="YES")
     yes_cd = c.code_value
    ELSE
     no_cd = c.code_value
    ENDIF
   WITH nocounter
  ;end select
  SET rxphysproxy_cd = 0.0
  SET mlskipcosign_cd = 0.0
  SELECT INTO "nl:"
   FROM code_value c
   PLAN (c
    WHERE c.code_set=6016
     AND c.cdf_meaning IN ("RXPHYSPROXY", "MLSKIPCOSIGN"))
   DETAIL
    IF (c.cdf_meaning="RXPHYSPROXY")
     rxphysproxy_cd = c.code_value
    ELSE
     mlskipcosign_cd = c.code_value
    ENDIF
   WITH nocounter
  ;end select
 ENDIF
 IF ((request->physassist_code_value > 0)
  AND (request->physassist_action_flag=2))
  IF ((request->physassist_rx_flag=1))
   SET stat = midlevel_ens(request->physassist_code_value,1,no_cd,yes_cd)
  ELSEIF ((request->physassist_rx_flag=2))
   SET stat = midlevel_ens(request->physassist_code_value,- (1),yes_cd,yes_cd)
  ELSEIF ((request->physassist_rx_flag=3))
   SET stat = midlevel_ens(request->physassist_code_value,- (1),yes_cd,no_cd)
  ELSEIF ((request->physassist_rx_flag=4))
   SET stat = midlevel_ens(request->physassist_code_value,0,no_cd,yes_cd)
  ELSEIF ((request->physassist_rx_flag=0))
   SET stat = delete_privs(request->physassist_code_value)
   IF ((request->physassist_chg_flag=0))
    SET stat = midlevel_ens(request->physassist_code_value,0,- (1),- (1))
   ENDIF
  ENDIF
  IF ((request->physassist_chg_flag=1))
   SET stat = midlevel_ens(request->physassist_code_value,1,- (1),- (1))
  ELSEIF ((request->physassist_chg_flag=2))
   SET stat = midlevel_ens(request->physassist_code_value,0,- (1),- (1))
  ENDIF
 ENDIF
 IF ((request->nursepract_code_value > 0)
  AND (request->nursepract_action_flag=2))
  IF ((request->nursepract_rx_flag=1))
   SET stat = midlevel_ens(request->nursepract_code_value,1,no_cd,yes_cd)
  ELSEIF ((request->nursepract_rx_flag=2))
   SET stat = midlevel_ens(request->nursepract_code_value,- (1),yes_cd,yes_cd)
  ELSEIF ((request->nursepract_rx_flag=3))
   SET stat = midlevel_ens(request->nursepract_code_value,- (1),yes_cd,no_cd)
  ELSEIF ((request->nursepract_rx_flag=4))
   SET stat = midlevel_ens(request->nursepract_code_value,0,no_cd,yes_cd)
  ELSEIF ((request->nursepract_rx_flag=0))
   SET stat = delete_privs(request->nursepract_code_value)
   IF ((request->nursepract_chg_flag=0))
    SET stat = midlevel_ens(request->nursepract_code_value,0,- (1),- (1))
   ENDIF
  ENDIF
  IF ((request->nursepract_chg_flag=1))
   SET stat = midlevel_ens(request->nursepract_code_value,1,- (1),- (1))
  ELSEIF ((request->nursepract_chg_flag=2))
   SET stat = midlevel_ens(request->nursepract_code_value,0,- (1),- (1))
  ENDIF
 ENDIF
 IF ((request->position_code_value > 0)
  AND (request->newposition_action_flag=2))
  IF ((request->newposition_rx_flag=1))
   SET stat = midlevel_ens(request->position_code_value,1,no_cd,yes_cd)
  ELSEIF ((request->newposition_rx_flag=2))
   SET stat = midlevel_ens(request->position_code_value,- (1),yes_cd,yes_cd)
  ELSEIF ((request->newposition_rx_flag=3))
   SET stat = midlevel_ens(request->position_code_value,- (1),yes_cd,no_cd)
  ELSEIF ((request->newposition_rx_flag=4))
   SET stat = midlevel_ens(request->position_code_value,0,no_cd,yes_cd)
  ELSEIF ((request->newposition_rx_flag=0))
   SET stat = delete_privs(request->position_code_value)
   IF ((request->newposition_chg_flag=0))
    SET stat = midlevel_ens(request->position_code_value,0,- (1),- (1))
   ENDIF
  ENDIF
  IF ((request->newposition_chg_flag=1))
   SET stat = midlevel_ens(request->position_code_value,1,- (1),- (1))
  ELSEIF ((request->newposition_chg_flag=2))
   SET stat = midlevel_ens(request->position_code_value,0,- (1),- (1))
  ENDIF
 ENDIF
 GO TO exit_script
 SUBROUTINE midlevel_ens(psn_cd,phys_ind,rxphys_cd,mlskip_cd)
   SET priv_loc_reltn_flag = 0
   SET privilege_flag = 0
   IF (phys_ind IN (0, 1))
    SET bpcccnt = 0
    SELECT INTO "nl:"
     FROM br_position_cat_comp bpcc
     PLAN (bpcc
      WHERE bpcc.position_cd=psn_cd
       AND bpcc.physician_ind != phys_ind)
     DETAIL
      bpcccnt = (bpcccnt+ 1), stat = alterlist(temp2->bpcclist,bpcccnt), temp2->bpcclist[bpcccnt].
      category_id = bpcc.category_id
     WITH nocounter
    ;end select
    IF (bpcccnt > 0)
     FOR (b = 1 TO bpcccnt)
       UPDATE  FROM br_position_cat_comp bpcc
        SET bpcc.physician_ind = phys_ind, bpcc.updt_dt_tm = cnvtdatetime(curdate,curtime), bpcc
         .updt_id = reqinfo->updt_id,
         bpcc.updt_cnt = (bpcc.updt_cnt+ 1), bpcc.updt_task = reqinfo->updt_task, bpcc.updt_applctx
          = reqinfo->updt_applctx
        WHERE bpcc.position_cd=psn_cd
         AND (bpcc.category_id=temp2->bpcclist[b].category_id)
        WITH nocounter
       ;end update
     ENDFOR
    ENDIF
   ENDIF
   IF (rxphys_cd > 0
    AND mlskip_cd > 0)
    SET plr_id = 0.0
    SELECT INTO "nl:"
     FROM priv_loc_reltn plr
     PLAN (plr
      WHERE plr.position_cd=psn_cd
       AND plr.person_id=0
       AND plr.ppr_cd=0
       AND plr.location_cd=0)
     DETAIL
      plr_id = plr.priv_loc_reltn_id
     WITH nocounter
    ;end select
    IF (plr_id=0.0)
     SELECT INTO "nl:"
      y = seq(reference_seq,nextval)"##################;rp0"
      FROM dual
      DETAIL
       plr_id = cnvtreal(y)
      WITH format, counter
     ;end select
     INSERT  FROM priv_loc_reltn plr
      SET plr.priv_loc_reltn_id = plr_id, plr.person_id = 0, plr.position_cd = psn_cd,
       plr.ppr_cd = 0, plr.location_cd = 0, plr.updt_cnt = 0,
       plr.updt_dt_tm = cnvtdatetime(curdate,curtime), plr.updt_id = reqinfo->updt_id, plr.updt_task
        = reqinfo->updt_task,
       plr.updt_applctx = reqinfo->updt_applctx, plr.active_ind = 1, plr.active_status_dt_tm =
       cnvtdatetime(curdate,curtime),
       plr.active_status_prsnl_id = reqinfo->updt_id, plr.beg_effective_dt_tm = cnvtdatetime(curdate,
        curtime), plr.end_effective_dt_tm = cnvtdatetime("31-DEC-2100")
      WITH nocounter
     ;end insert
    ENDIF
    SET privilege_flag = 1
    SELECT INTO "nl:"
     FROM privilege p
     PLAN (p
      WHERE p.priv_loc_reltn_id=plr_id
       AND p.privilege_cd=rxphysproxy_cd)
     DETAIL
      IF (p.priv_value_cd=rxphys_cd)
       privilege_flag = 0
      ELSEIF (p.priv_value_cd != rxphys_cd)
       privilege_flag = 2
      ENDIF
     WITH nocounter
    ;end select
    IF (privilege_flag=2)
     UPDATE  FROM privilege p
      SET p.priv_value_cd = rxphys_cd, p.updt_dt_tm = cnvtdatetime(curdate,curtime), p.updt_id =
       reqinfo->updt_id,
       p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = (p
       .updt_cnt+ 1)
      WHERE p.priv_loc_reltn_id=plr_id
       AND p.privilege_cd=rxphysproxy_cd
      WITH nocounter
     ;end update
    ELSEIF (privilege_flag=1)
     INSERT  FROM privilege p
      SET p.privilege_id = seq(reference_seq,nextval), p.priv_loc_reltn_id = plr_id, p.privilege_cd
        = rxphysproxy_cd,
       p.priv_value_cd = rxphys_cd, p.updt_dt_tm = cnvtdatetime(curdate,curtime), p.updt_id = reqinfo
       ->updt_id,
       p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0,
       p.active_ind = 1, p.active_status_dt_tm = cnvtdatetime(curdate,curtime), p
       .active_status_prsnl_id = reqinfo->updt_id
      WITH nocounter
     ;end insert
    ENDIF
    SET privilege_flag = 1
    SELECT INTO "nl:"
     FROM privilege p
     PLAN (p
      WHERE p.priv_loc_reltn_id=plr_id
       AND p.privilege_cd=mlskipcosign_cd)
     DETAIL
      IF (p.priv_value_cd=mlskip_cd)
       privilege_flag = 0
      ELSEIF (p.priv_value_cd != mlskip_cd)
       privilege_flag = 2
      ENDIF
     WITH nocounter
    ;end select
    IF (privilege_flag=2)
     UPDATE  FROM privilege p
      SET p.priv_value_cd = mlskip_cd, p.updt_dt_tm = cnvtdatetime(curdate,curtime), p.updt_id =
       reqinfo->updt_id,
       p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = (p
       .updt_cnt+ 1)
      WHERE p.priv_loc_reltn_id=plr_id
       AND p.privilege_cd=mlskipcosign_cd
      WITH nocounter
     ;end update
    ELSEIF (privilege_flag=1)
     INSERT  FROM privilege p
      SET p.privilege_id = seq(reference_seq,nextval), p.priv_loc_reltn_id = plr_id, p.privilege_cd
        = mlskipcosign_cd,
       p.priv_value_cd = mlskip_cd, p.updt_dt_tm = cnvtdatetime(curdate,curtime), p.updt_id = reqinfo
       ->updt_id,
       p.updt_task = reqinfo->updt_task, p.updt_applctx = reqinfo->updt_applctx, p.updt_cnt = 0,
       p.active_ind = 1, p.active_status_dt_tm = cnvtdatetime(curdate,curtime), p
       .active_status_prsnl_id = reqinfo->updt_id
      WITH nocounter
     ;end insert
    ENDIF
   ENDIF
   RETURN(1.0)
 END ;Subroutine
 SUBROUTINE delete_privs(position_cd)
   SET plr_id = 0.0
   SELECT INTO "nl:"
    FROM priv_loc_reltn plr
    PLAN (plr
     WHERE plr.position_cd=position_cd
      AND plr.person_id=0
      AND plr.ppr_cd=0
      AND plr.location_cd=0)
    DETAIL
     plr_id = plr.priv_loc_reltn_id
    WITH nocounter
   ;end select
   IF (plr_id > 0)
    DELETE  FROM privilege p
     WHERE p.priv_loc_reltn_id=plr_id
      AND p.privilege_cd=rxphysproxy_cd
     WITH nocounter
    ;end delete
    DELETE  FROM privilege p
     WHERE p.priv_loc_reltn_id=plr_id
      AND p.privilege_cd=mlskipcosign_cd
     WITH nocounter
    ;end delete
   ENDIF
 END ;Subroutine
#exit_script
 SET reply->status_data.status = "S"
 SET reqinfo->commit_ind = 1
END GO
