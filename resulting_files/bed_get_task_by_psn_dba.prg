CREATE PROGRAM bed_get_task_by_psn:dba
 FREE SET reply
 RECORD reply(
   1 qual[*]
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
 RECORD multitaskrequest(
   1 action = c1
   1 task_list[*]
     2 task = c50
     2 on_off_ind = c1
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
 RECORD misctaskrequest(
   1 action = c1
   1 task_list[*]
     2 task = c50
     2 on_off_ind = c1
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
 RECORD temp(
   1 plist[*]
     2 process_name = vc
     2 process_ind = i2
 )
 SET reply->status_data.status = "F"
 SET at_least_one_display_ind = 0
 IF ((request->tlist[1].task_mean > " "))
  SET all_tasks = 0
 ELSE
  SET all_tasks = 1
 ENDIF
 SET pco_who_works = 0
 SELECT INTO "NL:"
  FROM br_name_value b
  WHERE b.br_nv_key1="PCOPSNSELECTED"
  DETAIL
   pco_who_works = 1
  WITH nocounter
 ;end select
 SET psn_cnt = size(request->plist,5)
 IF (psn_cnt > 0)
  SET stat = alterlist(reply->qual,psn_cnt)
 ELSE
  GO TO enditnow
 ENDIF
 SET singletaskrequest->action = "0"
 SET singletaskrequest->application_number = 961000
 SET singletaskrequest->prsnl_id = 0.0
 SET multitaskrequest->action = "0"
 SET multitaskrequest->application_number = 961000
 SET multitaskrequest->prsnl_id = 0.0
 SET misctaskrequest->action = "0"
 SET misctaskrequest->application_number = 961000
 SET misctaskrequest->prsnl_id = 0.0
 SET process_cnt = 0
 SELECT INTO "nl:"
  FROM br_name_value bnv
  PLAN (bnv
   WHERE bnv.br_nv_key1="AUTOPROCESSES")
  HEAD REPORT
   process_cnt = 0
  DETAIL
   IF (cnvtint(bnv.br_value)=1)
    process_cnt = (process_cnt+ 1), stat = alterlist(temp->plist,process_cnt), temp->plist[
    process_cnt].process_name = bnv.br_name,
    temp->plist[process_cnt].process_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (process_cnt=0)
  SET process_cnt = (process_cnt+ 1)
  SET stat = alterlist(temp->plist,process_cnt)
  SET temp->plist[process_cnt].process_name = "ALL"
  SET temp->plist[process_cnt].process_ind = 1
 ENDIF
 SET profit_ind = 0
 SET cvnet_ind = 0
 SET inet_ind = 0
 SET mtm_ind = 0
 SET iqhealth_ind = 0
 SET profile_ind = 0
 SET esm_ind = 0
 SET mrp_ind = 0
 SET rows_exist = 0
 SELECT INTO "nl:"
  FROM br_name_value bnv
  PLAN (bnv
   WHERE bnv.br_nv_key1="STEP_CAT_MEAN")
  DETAIL
   rows_exist = 1
   IF (bnv.default_selected_ind=1)
    IF (bnv.br_name="PROFIT")
     profit_ind = 1
    ELSEIF (bnv.br_name="CVNET")
     cvnet_ind = 1
    ELSEIF (bnv.br_name="INET")
     inet_ind = 1
    ELSEIF (bnv.br_name="MTM")
     mtm_ind = 1
    ELSEIF (bnv.br_name="IQHEALTH")
     iqhealth_ind = 1
    ELSEIF (bnv.br_name="PROFILE")
     profile_ind = 1
    ELSEIF (bnv.br_name="ESM")
     esm_ind = 1
    ELSEIF (bnv.br_name="MEDREC")
     mrp_ind = 1
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_name_value bnv
  PLAN (bnv
   WHERE bnv.br_nv_key1="SOLUTION_STATUS"
    AND bnv.br_name IN ("LIVE_IN_PROD", "GOING_LIVE"))
  DETAIL
   rows_exist = 1
   IF (bnv.br_value="PROFIT")
    profit_ind = 1
   ELSEIF (bnv.br_value="CVNET")
    cvnet_ind = 1
   ELSEIF (bnv.br_value="INET")
    inet_ind = 1
   ELSEIF (bnv.br_value="MTM")
    mtm_ind = 1
   ELSEIF (bnv.br_value="IQHEALTH")
    iqhealth_ind = 1
   ELSEIF (bnv.br_value="PROFILE")
    profile_ind = 1
   ELSEIF (bnv.br_value="ESM")
    esm_ind = 1
   ELSEIF (bnv.br_value="MEDREC")
    mrp_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (rows_exist=0)
  SET profit_ind = 1
  SET cvnet_ind = 1
  SET inet_ind = 1
  SET mtm_ind = 1
  SET iqhealth_ind = 1
  SET profile_ind = 1
  SET esm_ind = 1
  SET mrp_ind = 1
 ENDIF
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
 IF (all_tasks=0)
  FOR (p = 1 TO psn_cnt)
    SET medstudent_ind = 0
    SELECT INTO "nl:"
     FROM code_value c
     PLAN (c
      WHERE c.code_set=88
       AND (c.code_value=request->plist[p].position_code_value))
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
      WHERE (bpcc.position_cd=request->plist[p].position_code_value))
      JOIN (bpc
      WHERE bpc.category_id=bpcc.category_id)
     ORDER BY bpcc.category_id, bpcc.position_cd
     HEAD bpcc.position_cd
      IF (bpc.step_cat_mean="ACUTE")
       acute_care_psn_ind = 1
      ENDIF
      physician_ind = bpcc.physician_ind
     WITH nocounter
    ;end select
    SET reply->qual[p].position_code_value = request->plist[p].position_code_value
    SET singletaskrequest->position_cd = request->plist[p].position_code_value
    SET multitaskrequest->position_cd = request->plist[p].position_code_value
    SET misctaskrequest->position_cd = request->plist[p].position_code_value
    SET reply_cnt = 1
    SET task_cnt = size(request->tlist,5)
    FOR (tasknbr = 1 TO task_cnt)
      IF ((((request->tlist[tasknbr].task_mean="VIEWALLERGY")) OR ((request->tlist[tasknbr].task_mean
      ="UPDALLERGY"))) )
       SET stat = alterlist(reply->qual[p].rlist,reply_cnt)
       SET reply->qual[p].rlist[reply_cnt].task_mean = request->tlist[tasknbr].task_mean
       FOR (y = 1 TO process_cnt)
         IF ((temp->plist[y].process_name IN ("CHARTPREP", "PTINTAKE", "PROVASSESS", "NONPROVVISIT",
         "SUPERBILL",
         "EASYSCRIPT", "MEDADMIN", "IMMADMIN", "PHONEMSG", "HIM",
         "MEDREFILL", "ALL")))
          SET reply->qual[p].rlist[reply_cnt].display_ind = 1
          SET at_least_one_display_ind = 1
          SET y = (process_cnt+ 1)
         ENDIF
       ENDFOR
       IF ((reply->qual[p].rlist[reply_cnt].display_ind=1))
        SET stat = alterlist(multitaskrequest->task_list,1)
        SET stat = alterlist(multitaskreply->status_data.status_list,1)
        SET multitaskrequest->task_list[1].task = reply->qual[p].rlist[reply_cnt].task_mean
        SET trace = recpersist
        EXECUTE bed_get_ens_tasks_allergy  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
         multitaskreply)
        SET reply->qual[p].rlist[reply_cnt].default_selected_ind = cnvtint(multitaskreply->
         status_data.status_list[1].status)
       ENDIF
       SET reply_cnt = (reply_cnt+ 1)
      ENDIF
      IF ((((request->tlist[tasknbr].task_mean="VIEWPROBLEM")) OR ((request->tlist[tasknbr].task_mean
      ="UPDPROBLEM"))) )
       SET stat = alterlist(reply->qual[p].rlist,reply_cnt)
       SET reply->qual[p].rlist[reply_cnt].task_mean = request->tlist[tasknbr].task_mean
       FOR (y = 1 TO process_cnt)
         IF ((temp->plist[y].process_name IN ("CHARTPREP", "PTINTAKE", "PROVASSESS", "NONPROVVISIT",
         "SUPERBILL",
         "ALL")))
          SET reply->qual[p].rlist[reply_cnt].display_ind = 1
          SET at_least_one_display_ind = 1
          SET y = (process_cnt+ 1)
         ENDIF
       ENDFOR
       IF ((reply->qual[p].rlist[reply_cnt].display_ind=1))
        SET stat = alterlist(multitaskrequest->task_list,1)
        SET stat = alterlist(multitaskreply->status_data.status_list,1)
        SET multitaskrequest->task_list[1].task = reply->qual[p].rlist[reply_cnt].task_mean
        SET trace = recpersist
        EXECUTE bed_get_ens_tasks_problem  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
         multitaskreply)
        SET reply->qual[p].rlist[reply_cnt].default_selected_ind = cnvtint(multitaskreply->
         status_data.status_list[1].status)
       ENDIF
       SET reply_cnt = (reply_cnt+ 1)
      ENDIF
      IF ((((request->tlist[tasknbr].task_mean="VIEWPROCHIST")) OR ((request->tlist[tasknbr].
      task_mean="UPDPROCHIST"))) )
       SET stat = alterlist(reply->qual[p].rlist,reply_cnt)
       SET reply->qual[p].rlist[reply_cnt].task_mean = request->tlist[tasknbr].task_mean
       FOR (y = 1 TO process_cnt)
         IF ((temp->plist[y].process_name IN ("CHARTPREP", "PTINTAKE", "PROVASSESS", "NONPROVVISIT",
         "ALL")))
          SET reply->qual[p].rlist[reply_cnt].display_ind = 1
          SET at_least_one_display_ind = 1
          SET y = (process_cnt+ 1)
         ENDIF
       ENDFOR
       IF ((reply->qual[p].rlist[reply_cnt].display_ind=1))
        SET stat = alterlist(multitaskrequest->task_list,1)
        SET stat = alterlist(multitaskreply->status_data.status_list,1)
        SET multitaskrequest->task_list[1].task = reply->qual[p].rlist[reply_cnt].task_mean
        SET trace = recpersist
        EXECUTE bed_get_ens_tasks_prochist  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
         multitaskreply)
        SET reply->qual[p].rlist[reply_cnt].default_selected_ind = cnvtint(multitaskreply->
         status_data.status_list[1].status)
       ENDIF
       SET reply_cnt = (reply_cnt+ 1)
      ENDIF
      IF ((request->tlist[tasknbr].task_mean="VIEWRESSCHED"))
       SET stat = alterlist(reply->qual[p].rlist,reply_cnt)
       SET reply->qual[p].rlist[reply_cnt].task_mean = "VIEWRESSCHED"
       CALL get_viewressched(reply_cnt)
       SET reply_cnt = (reply_cnt+ 1)
      ENDIF
      IF ((request->tlist[tasknbr].task_mean="VIEWAPPTBOOK"))
       SET stat = alterlist(reply->qual[p].rlist,reply_cnt)
       SET reply->qual[p].rlist[reply_cnt].task_mean = "VIEWAPPTBOOK"
       CALL get_viewapptbook(reply_cnt)
       SET reply_cnt = (reply_cnt+ 1)
      ENDIF
      IF ((request->tlist[tasknbr].task_mean="INDPTARRIVAL"))
       SET stat = alterlist(reply->qual[p].rlist,reply_cnt)
       SET reply->qual[p].rlist[reply_cnt].task_mean = "INDPTARRIVAL"
       CALL get_indptarrival(reply_cnt)
       SET reply_cnt = (reply_cnt+ 1)
      ENDIF
      IF ((request->tlist[tasknbr].task_mean="ALLERGY"))
       SET stat = alterlist(reply->qual[p].rlist,(reply_cnt+ 1))
       SET reply->qual[p].rlist[reply_cnt].task_mean = "VIEWALLERGY"
       SET reply->qual[p].rlist[(reply_cnt+ 1)].task_mean = "UPDALLERGY"
       CALL get_allergy(reply_cnt)
       SET reply_cnt = (reply_cnt+ 2)
      ENDIF
      IF ((request->tlist[tasknbr].task_mean="PROBLEM"))
       SET stat = alterlist(reply->qual[p].rlist,(reply_cnt+ 1))
       SET reply->qual[p].rlist[reply_cnt].task_mean = "VIEWPROBLEM"
       SET reply->qual[p].rlist[(reply_cnt+ 1)].task_mean = "UPDPROBLEM"
       CALL get_problem(reply_cnt)
       SET reply_cnt = (reply_cnt+ 2)
      ENDIF
      IF ((request->tlist[tasknbr].task_mean="PROCHIST"))
       SET stat = alterlist(reply->qual[p].rlist,(reply_cnt+ 1))
       SET reply->qual[p].rlist[reply_cnt].task_mean = "VIEWPROCHIST"
       SET reply->qual[p].rlist[(reply_cnt+ 1)].task_mean = "UPDPROCHIST"
       CALL get_prochist(reply_cnt)
       SET reply_cnt = (reply_cnt+ 2)
      ENDIF
      IF ((request->tlist[tasknbr].task_mean="UPDIMMUN"))
       SET stat = alterlist(reply->qual[p].rlist,reply_cnt)
       SET reply->qual[p].rlist[reply_cnt].task_mean = "UPDIMMUN"
       CALL get_updimmun(reply_cnt)
       SET reply_cnt = (reply_cnt+ 1)
      ENDIF
      IF ((request->tlist[tasknbr].task_mean="UPDHLTHMAINT"))
       SET stat = alterlist(reply->qual[p].rlist,reply_cnt)
       SET reply->qual[p].rlist[reply_cnt].task_mean = "UPDHLTHMAINT"
       CALL get_updhlthmaint(reply_cnt)
       SET reply_cnt = (reply_cnt+ 1)
      ENDIF
      IF ((request->tlist[tasknbr].task_mean="ORDCHARGE"))
       SET stat = alterlist(reply->qual[p].rlist,(reply_cnt+ 10))
       SET reply->qual[p].rlist[reply_cnt].task_mean = "ORDER"
       SET reply->qual[p].rlist[(reply_cnt+ 1)].task_mean = "VIEWORDER"
       SET reply->qual[p].rlist[(reply_cnt+ 2)].task_mean = "ORDERPROFILE"
       SET reply->qual[p].rlist[(reply_cnt+ 3)].task_mean = "CANCELORDER"
       SET reply->qual[p].rlist[(reply_cnt+ 4)].task_mean = "COMPLETEORDER"
       SET reply->qual[p].rlist[(reply_cnt+ 5)].task_mean = "MODIFYMEDSTUDORDER"
       SET reply->qual[p].rlist[(reply_cnt+ 6)].task_mean = "MODIFYORDER"
       SET reply->qual[p].rlist[(reply_cnt+ 7)].task_mean = "REPEATORDER"
       SET reply->qual[p].rlist[(reply_cnt+ 8)].task_mean = "RESCHEDORDER"
       SET reply->qual[p].rlist[(reply_cnt+ 9)].task_mean = "SUSPENDORDER"
       SET reply->qual[p].rlist[(reply_cnt+ 10)].task_mean = "VOIDORDER"
       CALL get_order(reply_cnt)
       SET reply_cnt = (reply_cnt+ 11)
      ENDIF
      IF ((request->tlist[tasknbr].task_mean="MED"))
       SET stat = alterlist(reply->qual[p].rlist,(reply_cnt+ 6))
       SET reply->qual[p].rlist[reply_cnt].task_mean = "VIEWMEDS"
       SET reply->qual[p].rlist[(reply_cnt+ 1)].task_mean = "UPDPASTANDCURRENTMEDS"
       SET reply->qual[p].rlist[(reply_cnt+ 2)].task_mean = "UPDMEDS"
       SET reply->qual[p].rlist[(reply_cnt+ 3)].task_mean = "RXREPRINT"
       SET reply->qual[p].rlist[(reply_cnt+ 4)].task_mean = "ORDERTORX"
       SET reply->qual[p].rlist[(reply_cnt+ 5)].task_mean = "RXTOACUTEORDER"
       SET reply->qual[p].rlist[(reply_cnt+ 6)].task_mean = "RXTOAMBORDER"
       CALL get_med(reply_cnt)
       SET reply_cnt = (reply_cnt+ 7)
      ENDIF
      IF ((request->tlist[tasknbr].task_mean="NOTE"))
       SET stat = alterlist(reply->qual[p].rlist,(reply_cnt+ 2))
       SET reply->qual[p].rlist[reply_cnt].task_mean = "VIEWNOTES"
       SET reply->qual[p].rlist[(reply_cnt+ 1)].task_mean = "UPDNOTES"
       SET reply->qual[p].rlist[(reply_cnt+ 2)].task_mean = "SCANNOTES"
       CALL get_note(reply_cnt)
       SET reply_cnt = (reply_cnt+ 3)
      ENDIF
      IF ((request->tlist[tasknbr].task_mean="STRUCTDOC"))
       SET stat = alterlist(reply->qual[p].rlist,(reply_cnt+ 6))
       SET reply->qual[p].rlist[reply_cnt].task_mean = "SAVESTRUCTDOC"
       SET reply->qual[p].rlist[(reply_cnt+ 1)].task_mean = "SIGNSTRUCTDOC"
       SET reply->qual[p].rlist[(reply_cnt+ 2)].task_mean = "PRECOMPNOTES"
       SET reply->qual[p].rlist[(reply_cnt+ 3)].task_mean = "ORDDIAGSTRUCTDOC"
       SET reply->qual[p].rlist[(reply_cnt+ 4)].task_mean = "RXSTRUCTDOC"
       SET reply->qual[p].rlist[(reply_cnt+ 5)].task_mean = "MINEONLYSTRUCTDOC"
       SET reply->qual[p].rlist[(reply_cnt+ 6)].task_mean = "CERTAINCAREDESIGNS"
       CALL get_structdoc(reply_cnt)
       SET reply_cnt = (reply_cnt+ 7)
      ENDIF
      IF ((request->tlist[tasknbr].task_mean="FORM"))
       SET stat = alterlist(reply->qual[p].rlist,(reply_cnt+ 2))
       SET reply->qual[p].rlist[reply_cnt].task_mean = "VIEWFORM"
       SET reply->qual[p].rlist[(reply_cnt+ 1)].task_mean = "SAVEFORM"
       SET reply->qual[p].rlist[(reply_cnt+ 2)].task_mean = "SIGNFORM"
       CALL get_form(reply_cnt)
       SET reply_cnt = (reply_cnt+ 3)
      ENDIF
      IF ((request->tlist[tasknbr].task_mean="PEDGROWTHCHART"))
       SET stat = alterlist(reply->qual[p].rlist,reply_cnt)
       SET reply->qual[p].rlist[reply_cnt].task_mean = "PEDGROWTHCHART"
       CALL get_pedgrowthchart(reply_cnt)
       SET reply_cnt = (reply_cnt+ 1)
      ENDIF
      IF ((request->tlist[tasknbr].task_mean="PTHISTRSLT"))
       SET stat = alterlist(reply->qual[p].rlist,(reply_cnt+ 3))
       SET reply->qual[p].rlist[reply_cnt].task_mean = "VIEWPTHIST"
       SET reply->qual[p].rlist[(reply_cnt+ 1)].task_mean = "UPDPTHIST"
       SET reply->qual[p].rlist[(reply_cnt+ 2)].task_mean = "VIEWRESULT"
       SET reply->qual[p].rlist[(reply_cnt+ 3)].task_mean = "COMMENTRESULT"
       CALL get_pthistrslt(reply_cnt)
       SET reply_cnt = (reply_cnt+ 4)
      ENDIF
      IF ((request->tlist[tasknbr].task_mean="TASK"))
       SET stat = alterlist(reply->qual[p].rlist,(reply_cnt+ 1))
       SET reply->qual[p].rlist[reply_cnt].task_mean = "VIEWTASK"
       SET reply->qual[p].rlist[(reply_cnt+ 1)].task_mean = "UPDTASK"
       CALL get_task(reply_cnt)
       SET reply_cnt = (reply_cnt+ 2)
      ENDIF
      IF ((request->tlist[tasknbr].task_mean="EVALMGMTASSIST"))
       SET stat = alterlist(reply->qual[p].rlist,reply_cnt)
       SET reply->qual[p].rlist[reply_cnt].task_mean = "EVALMGMTASSIST"
       CALL get_evalmgmtassist(reply_cnt)
       SET reply_cnt = (reply_cnt+ 1)
      ENDIF
      IF ((request->tlist[tasknbr].task_mean="VIEWCHARGES"))
       SET stat = alterlist(reply->qual[p].rlist,reply_cnt)
       SET reply->qual[p].rlist[reply_cnt].task_mean = "VIEWCHARGES"
       CALL get_viewcharges(reply_cnt)
       SET reply_cnt = (reply_cnt+ 1)
      ENDIF
      IF ((request->tlist[tasknbr].task_mean="INBOX"))
       SET stat = alterlist(reply->qual[p].rlist,(reply_cnt+ 14))
       SET reply->qual[p].rlist[reply_cnt].task_mean = "RESULTTOENDORSE"
       SET reply->qual[p].rlist[(reply_cnt+ 1)].task_mean = "SIGNPATDOC"
       SET reply->qual[p].rlist[(reply_cnt+ 2)].task_mean = "REVPATRSLT"
       SET reply->qual[p].rlist[(reply_cnt+ 3)].task_mean = "SIGNPATRSLT"
       SET reply->qual[p].rlist[(reply_cnt+ 4)].task_mean = "CORRESPOND"
       SET reply->qual[p].rlist[(reply_cnt+ 5)].task_mean = "FORWARDRESULTINBOX"
       SET reply->qual[p].rlist[(reply_cnt+ 6)].task_mean = "FORWARDRESULTEMAIL"
       SET reply->qual[p].rlist[(reply_cnt+ 7)].task_mean = "REVPATDOC"
       SET reply->qual[p].rlist[(reply_cnt+ 8)].task_mean = "RECEIVEDICTDOC"
       SET reply->qual[p].rlist[(reply_cnt+ 9)].task_mean = "SAVEPHONEMSGTOCHART"
       SET reply->qual[p].rlist[(reply_cnt+ 10)].task_mean = "ADDPHONEMSGENCNTR"
       SET reply->qual[p].rlist[(reply_cnt+ 11)].task_mean = "RECEIVEPHONEMSG"
       SET reply->qual[p].rlist[(reply_cnt+ 12)].task_mean = "ORDERSTOAPPROVE"
       SET reply->qual[p].rlist[(reply_cnt+ 13)].task_mean = "SAVEDDOC"
       SET reply->qual[p].rlist[(reply_cnt+ 14)].task_mean = "SENTITEMS"
       CALL get_inbox(reply_cnt)
       SET reply_cnt = (reply_cnt+ 15)
      ENDIF
      IF ((request->tlist[tasknbr].task_mean="MISCELLANEOUS"))
       SET stat = alterlist(reply->qual[p].rlist,(reply_cnt+ 16))
       SET reply->qual[p].rlist[reply_cnt].task_mean = "PATIENTLIST"
       SET reply->qual[p].rlist[(reply_cnt+ 1)].task_mean = "INTELLISTRIP"
       SET reply->qual[p].rlist[(reply_cnt+ 2)].task_mean = "PROVRELTN"
       SET reply->qual[p].rlist[(reply_cnt+ 3)].task_mean = "ENCOUNTERS"
       SET reply->qual[p].rlist[(reply_cnt+ 4)].task_mean = "HEALTHPLANS"
       SET reply->qual[p].rlist[(reply_cnt+ 5)].task_mean = "POWERORDERS"
       SET reply->qual[p].rlist[(reply_cnt+ 6)].task_mean = "MAR"
       SET reply->qual[p].rlist[(reply_cnt+ 7)].task_mean = "WEBSITE"
       SET reply->qual[p].rlist[(reply_cnt+ 8)].task_mean = "SHIFTASSIGN"
       SET reply->qual[p].rlist[(reply_cnt+ 9)].task_mean = "COSIGNORDER"
       SET reply->qual[p].rlist[(reply_cnt+ 10)].task_mean = "ADVGRAPH"
       SET reply->qual[p].rlist[(reply_cnt+ 11)].task_mean = "IANDO"
       SET reply->qual[p].rlist[(reply_cnt+ 12)].task_mean = "CHARTSUMMARY"
       SET reply->qual[p].rlist[(reply_cnt+ 13)].task_mean = "PATIENTACCESS"
       SET reply->qual[p].rlist[(reply_cnt+ 14)].task_mean = "VIEWSTICKYNOTES"
       SET reply->qual[p].rlist[(reply_cnt+ 15)].task_mean = "ADDSTICKYNOTES"
       SET reply->qual[p].rlist[(reply_cnt+ 16)].task_mean = "REPORTS"
       CALL get_misc_1(reply_cnt)
       SET stat = alterlist(misctaskrequest->task_list,6)
       SET stat = alterlist(misctaskreply->status_data.status_list,6)
       SET misctaskrequest->task_list[1].task = " "
       SET misctaskrequest->task_list[2].task = " "
       SET misctaskrequest->task_list[3].task = " "
       SET misctaskrequest->task_list[4].task = " "
       SET misctaskrequest->task_list[5].task = " "
       SET misctaskrequest->task_list[6].task = " "
       CALL get_misc_2((reply_cnt+ 5))
       SET reply_cnt = (reply_cnt+ 17)
      ENDIF
      IF ((request->tlist[tasknbr].task_mean="PUBMEDREC"))
       SET stat = alterlist(reply->qual[p].rlist,reply_cnt)
       SET reply->qual[p].rlist[reply_cnt].task_mean = "PUBMEDREC"
       CALL get_pubmedrec(reply_cnt)
       SET reply_cnt = (reply_cnt+ 1)
      ENDIF
    ENDFOR
  ENDFOR
  GO TO enditnow
 ENDIF
 FOR (p = 1 TO psn_cnt)
   SET medstudent_ind = 0
   SELECT INTO "nl:"
    FROM code_value c
    PLAN (c
     WHERE c.code_set=88
      AND (c.code_value=request->plist[p].position_code_value))
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
     WHERE (bpcc.position_cd=request->plist[p].position_code_value))
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
   SET stat = alterlist(reply->qual[p].rlist,84)
   SET reply->qual[p].position_code_value = request->plist[p].position_code_value
   SET singletaskrequest->position_cd = request->plist[p].position_code_value
   SET multitaskrequest->position_cd = request->plist[p].position_code_value
   SET misctaskrequest->position_cd = request->plist[p].position_code_value
   SET reply->qual[p].rlist[1].task_mean = "VIEWRESSCHED"
   CALL get_viewressched(1)
   SET reply->qual[p].rlist[2].task_mean = "VIEWAPPTBOOK"
   CALL get_viewapptbook(2)
   SET reply->qual[p].rlist[3].task_mean = "INDPTARRIVAL"
   CALL get_indptarrival(3)
   SET reply->qual[p].rlist[4].task_mean = "VIEWALLERGY"
   SET reply->qual[p].rlist[5].task_mean = "UPDALLERGY"
   CALL get_allergy(4)
   SET reply->qual[p].rlist[6].task_mean = "VIEWPROBLEM"
   SET reply->qual[p].rlist[7].task_mean = "UPDPROBLEM"
   CALL get_problem(6)
   SET reply->qual[p].rlist[8].task_mean = "VIEWPROCHIST"
   SET reply->qual[p].rlist[9].task_mean = "UPDPROCHIST"
   CALL get_prochist(8)
   SET reply->qual[p].rlist[10].task_mean = "UPDIMMUN"
   CALL get_updimmun(10)
   SET reply->qual[p].rlist[11].task_mean = "UPDHLTHMAINT"
   CALL get_updhlthmaint(11)
   SET reply->qual[p].rlist[12].task_mean = "ORDER"
   SET reply->qual[p].rlist[13].task_mean = "VIEWORDER"
   SET reply->qual[p].rlist[14].task_mean = "ORDERPROFILE"
   SET reply->qual[p].rlist[15].task_mean = "CANCELORDER"
   SET reply->qual[p].rlist[16].task_mean = "COMPLETEORDER"
   SET reply->qual[p].rlist[17].task_mean = "MODIFYMEDSTUDORDER"
   SET reply->qual[p].rlist[18].task_mean = "MODIFYORDER"
   SET reply->qual[p].rlist[19].task_mean = "REPEATORDER"
   SET reply->qual[p].rlist[20].task_mean = "RESCHEDORDER"
   SET reply->qual[p].rlist[21].task_mean = "SUSPENDORDER"
   SET reply->qual[p].rlist[22].task_mean = "VOIDORDER"
   CALL get_order(12)
   SET reply->qual[p].rlist[23].task_mean = "VIEWMEDS"
   SET reply->qual[p].rlist[24].task_mean = "UPDPASTANDCURRENTMEDS"
   SET reply->qual[p].rlist[25].task_mean = "UPDMEDS"
   SET reply->qual[p].rlist[26].task_mean = "RXREPRINT"
   SET reply->qual[p].rlist[27].task_mean = "ORDERTORX"
   SET reply->qual[p].rlist[28].task_mean = "RXTOACUTEORDER"
   SET reply->qual[p].rlist[29].task_mean = "RXTOAMBORDER"
   CALL get_med(23)
   SET reply->qual[p].rlist[30].task_mean = "VIEWNOTES"
   SET reply->qual[p].rlist[31].task_mean = "UPDNOTES"
   SET reply->qual[p].rlist[32].task_mean = "SCANNOTES"
   CALL get_note(30)
   SET reply->qual[p].rlist[33].task_mean = "SAVESTRUCTDOC"
   SET reply->qual[p].rlist[34].task_mean = "SIGNSTRUCTDOC"
   SET reply->qual[p].rlist[35].task_mean = "PRECOMPNOTES"
   SET reply->qual[p].rlist[36].task_mean = "ORDDIAGSTRUCTDOC"
   SET reply->qual[p].rlist[37].task_mean = "RXSTRUCTDOC"
   SET reply->qual[p].rlist[38].task_mean = "MINEONLYSTRUCTDOC"
   SET reply->qual[p].rlist[39].task_mean = "CERTAINCAREDESIGNS"
   CALL get_structdoc(33)
   SET reply->qual[p].rlist[40].task_mean = "VIEWFORM"
   SET reply->qual[p].rlist[41].task_mean = "SAVEFORM"
   SET reply->qual[p].rlist[42].task_mean = "SIGNFORM"
   CALL get_form(40)
   SET reply->qual[p].rlist[43].task_mean = "PEDGROWTHCHART"
   CALL get_pedgrowthchart(43)
   SET reply->qual[p].rlist[44].task_mean = "VIEWPTHIST"
   SET reply->qual[p].rlist[45].task_mean = "UPDPTHIST"
   SET reply->qual[p].rlist[46].task_mean = "VIEWRESULT"
   SET reply->qual[p].rlist[47].task_mean = "COMMENTRESULT"
   CALL get_pthistrslt(44)
   SET reply->qual[p].rlist[48].task_mean = "VIEWTASK"
   SET reply->qual[p].rlist[49].task_mean = "UPDTASK"
   CALL get_task(48)
   SET reply->qual[p].rlist[50].task_mean = "EVALMGMTASSIST"
   CALL get_evalmgmtassist(50)
   SET reply->qual[p].rlist[51].task_mean = "VIEWCHARGES"
   CALL get_viewcharges(51)
   SET reply->qual[p].rlist[52].task_mean = "RESULTTOENDORSE"
   SET reply->qual[p].rlist[53].task_mean = "SIGNPATDOC"
   SET reply->qual[p].rlist[54].task_mean = "REVPATRSLT"
   SET reply->qual[p].rlist[55].task_mean = "SIGNPATRSLT"
   SET reply->qual[p].rlist[56].task_mean = "CORRESPOND"
   SET reply->qual[p].rlist[57].task_mean = "FORWARDRESULTINBOX"
   SET reply->qual[p].rlist[58].task_mean = "FORWARDRESULTEMAIL"
   SET reply->qual[p].rlist[59].task_mean = "REVPATDOC"
   SET reply->qual[p].rlist[60].task_mean = "RECEIVEDICTDOC"
   SET reply->qual[p].rlist[61].task_mean = "SAVEPHONEMSGTOCHART"
   SET reply->qual[p].rlist[62].task_mean = "ADDPHONEMSGENCNTR"
   SET reply->qual[p].rlist[63].task_mean = "RECEIVEPHONEMSG"
   SET reply->qual[p].rlist[64].task_mean = "ORDERSTOAPPROVE"
   SET reply->qual[p].rlist[65].task_mean = "SAVEDDOC"
   SET reply->qual[p].rlist[66].task_mean = "SENTITEMS"
   CALL get_inbox(52)
   SET reply->qual[p].rlist[67].task_mean = "PATIENTLIST"
   SET reply->qual[p].rlist[68].task_mean = "INTELLISTRIP"
   SET reply->qual[p].rlist[69].task_mean = "PROVRELTN"
   SET reply->qual[p].rlist[70].task_mean = "ENCOUNTERS"
   SET reply->qual[p].rlist[71].task_mean = "HEALTHPLANS"
   SET reply->qual[p].rlist[73].task_mean = "MAR"
   SET reply->qual[p].rlist[74].task_mean = "WEBSITE"
   SET reply->qual[p].rlist[79].task_mean = "CHARTSUMMARY"
   SET reply->qual[p].rlist[80].task_mean = "PATIENTACCESS"
   SET reply->qual[p].rlist[81].task_mean = "VIEWSTICKYNOTES"
   SET reply->qual[p].rlist[82].task_mean = "ADDSTICKYNOTES"
   SET reply->qual[p].rlist[83].task_mean = "REPORTS"
   CALL get_misc_1(67)
   SET stat = alterlist(misctaskrequest->task_list,6)
   SET stat = alterlist(misctaskreply->status_data.status_list,6)
   SET misctaskrequest->task_list[1].task = " "
   SET misctaskrequest->task_list[2].task = " "
   SET misctaskrequest->task_list[3].task = " "
   SET misctaskrequest->task_list[4].task = " "
   SET misctaskrequest->task_list[5].task = " "
   SET misctaskrequest->task_list[6].task = " "
   SET reply->qual[p].rlist[72].task_mean = "POWERORDERS"
   SET reply->qual[p].rlist[75].task_mean = "SHIFTASSIGN"
   SET reply->qual[p].rlist[76].task_mean = "COSIGNORDER"
   SET reply->qual[p].rlist[77].task_mean = "ADVGRAPH"
   SET reply->qual[p].rlist[78].task_mean = "IANDO"
   CALL get_misc_2(72)
   SET reply->qual[p].rlist[84].task_mean = "PUBMEDREC"
   CALL get_pubmedrec(84)
 ENDFOR
#enditnow
 IF (at_least_one_display_ind=1)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
 CALL echorecord(reply)
 GO TO exitscript
 SUBROUTINE get_viewressched(tnbr)
  FOR (y = 1 TO process_cnt)
    IF ((temp->plist[y].process_name IN ("CHARTPREP", "CHECKIN", "PTINTAKE", "PROVASSESS",
    "NONPROVVISIT",
    "CHECKOUT", "ALL")))
     SET reply->qual[p].rlist[tnbr].display_ind = 1
     SET at_least_one_display_ind = 1
     SET y = (process_cnt+ 1)
    ENDIF
  ENDFOR
  IF ((reply->qual[p].rlist[tnbr].display_ind=1))
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_sched  WITH replace("REQUEST",singletaskrequest), replace("REPLY",
    singletaskreply)
   IF ((singletaskreply->status_data.status="S"))
    SET reply->qual[p].rlist[tnbr].default_selected_ind = 1
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE get_viewapptbook(tnbr)
  IF (esm_ind=1)
   FOR (y = 1 TO process_cnt)
     IF ((temp->plist[y].process_name IN ("CHECKIN", "ALL")))
      SET reply->qual[p].rlist[tnbr].display_ind = 1
      SET at_least_one_display_ind = 1
      SET y = (process_cnt+ 1)
     ENDIF
   ENDFOR
  ENDIF
  IF ((reply->qual[p].rlist[tnbr].display_ind=1))
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_apptbook  WITH replace("REQUEST",singletaskrequest), replace("REPLY",
    singletaskreply)
   IF ((singletaskreply->status_data.status="S"))
    SET reply->qual[p].rlist[tnbr].default_selected_ind = 1
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE get_indptarrival(tnbr)
  FOR (y = 1 TO process_cnt)
    IF ((temp->plist[y].process_name IN ("CHECKIN", "PTINTAKE", "PROVASSESS", "CHECKOUT", "ALL")))
     SET reply->qual[p].rlist[tnbr].display_ind = 1
     SET at_least_one_display_ind = 1
     SET y = (process_cnt+ 1)
    ENDIF
  ENDFOR
  IF ((reply->qual[p].rlist[tnbr].display_ind=1))
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_ptarrival  WITH replace("REQUEST",singletaskrequest), replace("REPLY",
    singletaskreply)
   IF ((singletaskreply->status_data.status="S"))
    SET reply->qual[p].rlist[tnbr].default_selected_ind = 1
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE get_allergy(tnbr)
  FOR (y = 1 TO process_cnt)
    IF ((temp->plist[y].process_name IN ("CHARTPREP", "PTINTAKE", "PROVASSESS", "NONPROVVISIT",
    "SUPERBILL",
    "EASYSCRIPT", "MEDADMIN", "IMMADMIN", "PHONEMSG", "HIM",
    "MEDREFILL", "ALL")))
     SET reply->qual[p].rlist[tnbr].display_ind = 1
     SET reply->qual[p].rlist[(tnbr+ 1)].display_ind = 1
     SET at_least_one_display_ind = 1
     SET y = (process_cnt+ 1)
    ENDIF
  ENDFOR
  IF ((reply->qual[p].rlist[tnbr].display_ind=1))
   SET stat = alterlist(multitaskrequest->task_list,2)
   SET stat = alterlist(multitaskreply->status_data.status_list,2)
   SET multitaskrequest->task_list[1].task = "VIEWALLERGY"
   SET multitaskrequest->task_list[2].task = "UPDALLERGY"
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_allergy  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
    multitaskreply)
   SET reply->qual[p].rlist[tnbr].default_selected_ind = cnvtint(multitaskreply->status_data.
    status_list[1].status)
   SET reply->qual[p].rlist[(tnbr+ 1)].default_selected_ind = cnvtint(multitaskreply->status_data.
    status_list[2].status)
  ENDIF
 END ;Subroutine
 SUBROUTINE get_problem(tnbr)
  FOR (y = 1 TO process_cnt)
    IF ((temp->plist[y].process_name IN ("CHARTPREP", "PTINTAKE", "PROVASSESS", "NONPROVVISIT",
    "SUPERBILL",
    "ALL")))
     SET reply->qual[p].rlist[tnbr].display_ind = 1
     SET reply->qual[p].rlist[(tnbr+ 1)].display_ind = 1
     SET at_least_one_display_ind = 1
     SET y = (process_cnt+ 1)
    ENDIF
  ENDFOR
  IF ((reply->qual[p].rlist[tnbr].display_ind=1))
   SET stat = alterlist(multitaskrequest->task_list,2)
   SET stat = alterlist(multitaskreply->status_data.status_list,2)
   SET multitaskrequest->task_list[1].task = "VIEWPROBLEM"
   SET multitaskrequest->task_list[2].task = "UPDPROBLEM"
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_problem  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
    multitaskreply)
   SET reply->qual[p].rlist[tnbr].default_selected_ind = cnvtint(multitaskreply->status_data.
    status_list[1].status)
   SET reply->qual[p].rlist[(tnbr+ 1)].default_selected_ind = cnvtint(multitaskreply->status_data.
    status_list[2].status)
  ENDIF
 END ;Subroutine
 SUBROUTINE get_prochist(tnbr)
  FOR (y = 1 TO process_cnt)
    IF ((temp->plist[y].process_name IN ("CHARTPREP", "PTINTAKE", "PROVASSESS", "NONPROVVISIT", "ALL"
    )))
     SET reply->qual[p].rlist[tnbr].display_ind = 1
     SET reply->qual[p].rlist[(tnbr+ 1)].display_ind = 1
     SET at_least_one_display_ind = 1
     SET y = (process_cnt+ 1)
    ENDIF
  ENDFOR
  IF ((reply->qual[p].rlist[tnbr].display_ind=1))
   SET stat = alterlist(multitaskrequest->task_list,2)
   SET stat = alterlist(multitaskreply->status_data.status_list,2)
   SET multitaskrequest->task_list[1].task = "VIEWPROCHIST"
   SET multitaskrequest->task_list[2].task = "UPDPROCHIST"
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_prochist  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
    multitaskreply)
   SET reply->qual[p].rlist[tnbr].default_selected_ind = cnvtint(multitaskreply->status_data.
    status_list[1].status)
   SET reply->qual[p].rlist[(tnbr+ 1)].default_selected_ind = cnvtint(multitaskreply->status_data.
    status_list[2].status)
  ENDIF
 END ;Subroutine
 SUBROUTINE get_updimmun(tnbr)
  FOR (y = 1 TO process_cnt)
    IF ((temp->plist[y].process_name IN ("CHARTPREP", "PTINTAKE", "PROVASSESS", "NONPROVVISIT",
    "SUPERBILL",
    "IMMADMIN", "ALL")))
     SET reply->qual[p].rlist[tnbr].display_ind = 1
     SET at_least_one_display_ind = 1
     SET y = (process_cnt+ 1)
    ENDIF
  ENDFOR
  IF ((reply->qual[p].rlist[tnbr].display_ind=1))
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_immun  WITH replace("REQUEST",singletaskrequest), replace("REPLY",
    singletaskreply)
   IF ((singletaskreply->status_data.status="S"))
    SET reply->qual[p].rlist[tnbr].default_selected_ind = 1
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE get_updhlthmaint(tnbr)
  FOR (y = 1 TO process_cnt)
    IF ((temp->plist[y].process_name IN ("CHARTPREP", "PTINTAKE", "PROVASSESS", "NONPROVVISIT", "ALL"
    )))
     SET reply->qual[p].rlist[tnbr].display_ind = 1
     SET at_least_one_display_ind = 1
     SET y = (process_cnt+ 1)
    ENDIF
  ENDFOR
  IF ((reply->qual[p].rlist[tnbr].display_ind=1))
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_hlthmaint  WITH replace("REQUEST",singletaskrequest), replace("REPLY",
    singletaskreply)
   IF ((singletaskreply->status_data.status="S"))
    SET reply->qual[p].rlist[tnbr].default_selected_ind = 1
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE get_order(tnbr)
   SET medstudent_cv = 0
   SELECT INTO "nl:"
    FROM code_value c
    WHERE c.code_set=88
     AND c.cdf_meaning="MEDSTUDENT"
    DETAIL
     medstudent_cv = c.code_value
    WITH nocounter
   ;end select
   SET medstudent_used = 0
   IF (medstudent_cv > 0)
    IF (pco_who_works=1)
     SELECT INTO "nl:"
      FROM br_name_value
      WHERE br_nv_key1="PCOPSNSELECTED"
       AND br_name="CVFROMCS88"
       AND br_value=cnvtstring(medstudent_cv)
      DETAIL
       medstudent_used = 1
      WITH nocounter
     ;end select
    ELSE
     SET medstudent_used = 1
    ENDIF
   ENDIF
   FOR (y = 1 TO process_cnt)
     IF ((temp->plist[y].process_name IN ("SUPERBILL", "MEDADMIN", "IMMADMIN", "COSIGN", "ALL")))
      SET reply->qual[p].rlist[tnbr].display_ind = 1
      SET at_least_one_display_ind = 1
      SET y = (process_cnt+ 1)
     ENDIF
   ENDFOR
   FOR (y = 1 TO process_cnt)
     IF ((temp->plist[y].process_name IN ("SUPERBILL", "MEDADMIN", "PTINTAKE", "PROVASSESS",
     "NONPROVVISIT",
     "ORDERCOMP", "IMMADMIN", "COSIGN", "ALL")))
      SET reply->qual[p].rlist[(tnbr+ 1)].display_ind = 1
      SET reply->qual[p].rlist[(tnbr+ 2)].display_ind = 1
      IF (medstudent_used=1)
       SET reply->qual[p].rlist[(tnbr+ 5)].display_ind = 1
      ENDIF
      SET at_least_one_display_ind = 1
      SET y = (process_cnt+ 1)
     ENDIF
   ENDFOR
   FOR (y = 1 TO process_cnt)
     IF ((temp->plist[y].process_name IN ("SUPERBILL", "MEDADMIN", "PTINTAKE", "PROVASSESS",
     "NONPROVVISIT",
     "ORDERCOMP", "IMMADMIN", "COSIGN", "ALL")))
      IF (medstudent_ind=0)
       SET reply->qual[p].rlist[(tnbr+ 3)].display_ind = 1
       SET reply->qual[p].rlist[(tnbr+ 4)].display_ind = 1
       SET reply->qual[p].rlist[(tnbr+ 6)].display_ind = 1
       SET reply->qual[p].rlist[(tnbr+ 8)].display_ind = 1
       SET reply->qual[p].rlist[(tnbr+ 9)].display_ind = 1
      ENDIF
      SET reply->qual[p].rlist[(tnbr+ 7)].display_ind = 1
      SET reply->qual[p].rlist[(tnbr+ 10)].display_ind = 1
      SET at_least_one_display_ind = 1
      SET y = (process_cnt+ 1)
     ENDIF
   ENDFOR
   IF ((((reply->qual[p].rlist[tnbr].display_ind=1)) OR ((((reply->qual[p].rlist[(tnbr+ 1)].
   display_ind=1)) OR ((((reply->qual[p].rlist[(tnbr+ 2)].display_ind=1)) OR ((((reply->qual[p].
   rlist[(tnbr+ 3)].display_ind=1)) OR ((((reply->qual[p].rlist[(tnbr+ 4)].display_ind=1)) OR ((((
   reply->qual[p].rlist[(tnbr+ 5)].display_ind=1)) OR ((((reply->qual[p].rlist[(tnbr+ 6)].display_ind
   =1)) OR ((((reply->qual[p].rlist[(tnbr+ 7)].display_ind=1)) OR ((((reply->qual[p].rlist[(tnbr+ 8)]
   .display_ind=1)) OR ((((reply->qual[p].rlist[(tnbr+ 9)].display_ind=1)) OR ((reply->qual[p].rlist[
   (tnbr+ 10)].display_ind=1))) )) )) )) )) )) )) )) )) )) )
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
    SET trace = recpersist
    EXECUTE bed_get_ens_tasks_order  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
     multitaskreply)
    IF ((reply->qual[p].rlist[tnbr].display_ind=1))
     SET reply->qual[p].rlist[tnbr].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[1].status)
    ELSE
     SET reply->qual[p].rlist[tnbr].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 1)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 1)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[2].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 1)].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 2)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 2)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[3].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 2)].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 3)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 3)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[4].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 3)].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 4)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 4)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[5].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 4)].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 5)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 5)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[6].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 5)].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 6)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 6)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[7].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 6)].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 7)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 7)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[8].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 7)].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 8)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 8)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[9].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 8)].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 9)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 9)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[10].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 9)].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 10)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 10)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[11].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 10)].default_selected_ind = 0
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE get_med(tnbr)
   FOR (y = 1 TO process_cnt)
     IF ((temp->plist[y].process_name IN ("CHARTPREP", "EASYSCRIPT", "PHONEMSG", "COSIGN",
     "MEDREFILL",
     "PTINTAKE", "PROVASSESS", "NONPROVVISIT", "ALL")))
      SET reply->qual[p].rlist[tnbr].display_ind = 1
      SET reply->qual[p].rlist[(tnbr+ 1)].display_ind = 1
      SET reply->qual[p].rlist[(tnbr+ 2)].display_ind = 1
      SET at_least_one_display_ind = 1
      SET y = (process_cnt+ 1)
     ENDIF
   ENDFOR
   FOR (y = 1 TO process_cnt)
     IF ((temp->plist[y].process_name IN ("CHARTPREP", "PTINTAKE", "PROVASSESS", "EASYSCRIPT",
     "NONPROVVISIT",
     "MEDREFILL", "PHONEMSG", "COSIGN", "ALL")))
      SET reply->qual[p].rlist[(tnbr+ 3)].display_ind = 1
      SET at_least_one_display_ind = 1
      SET y = (process_cnt+ 1)
     ENDIF
   ENDFOR
   FOR (y = 1 TO process_cnt)
     IF ((temp->plist[y].process_name IN ("CHARTPREP", "PTINTAKE", "PROVASSESS", "EASYSCRIPT",
     "NONPROVVISIT",
     "MEDREFILL", "ALL")))
      SET reply->qual[p].rlist[(tnbr+ 4)].display_ind = 1
      SET reply->qual[p].rlist[(tnbr+ 5)].display_ind = 1
      SET reply->qual[p].rlist[(tnbr+ 6)].display_ind = 1
      SET at_least_one_display_ind = 1
      SET y = (process_cnt+ 1)
     ENDIF
   ENDFOR
   IF ((((reply->qual[p].rlist[tnbr].display_ind=1)) OR ((((reply->qual[p].rlist[(tnbr+ 1)].
   display_ind=1)) OR ((((reply->qual[p].rlist[(tnbr+ 2)].display_ind=1)) OR ((((reply->qual[p].
   rlist[(tnbr+ 3)].display_ind=1)) OR ((((reply->qual[p].rlist[(tnbr+ 4)].display_ind=1)) OR ((((
   reply->qual[p].rlist[(tnbr+ 5)].display_ind=1)) OR ((reply->qual[p].rlist[(tnbr+ 6)].display_ind=1
   ))) )) )) )) )) )) )
    SET stat = alterlist(multitaskrequest->task_list,7)
    SET stat = alterlist(multitaskreply->status_data.status_list,7)
    SET multitaskrequest->task_list[1].task = "VIEWMEDS"
    SET multitaskrequest->task_list[2].task = "UPDPASTANDCURRENTMEDS"
    SET multitaskrequest->task_list[3].task = "UPDMEDS"
    SET multitaskrequest->task_list[4].task = "RXREPRINT"
    SET multitaskrequest->task_list[5].task = "ORDERTORX"
    SET multitaskrequest->task_list[6].task = "RXTOACUTEORDER"
    SET multitaskrequest->task_list[7].task = "RXTOAMBORDER"
    SET trace = recpersist
    EXECUTE bed_get_ens_tasks_med  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
     multitaskreply)
    IF ((reply->qual[p].rlist[tnbr].display_ind=1))
     SET reply->qual[p].rlist[tnbr].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[1].status)
    ELSE
     SET reply->qual[p].rlist[tnbr].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 1)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 1)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[2].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 1)].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 2)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 2)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[3].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 2)].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 3)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 3)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[4].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 3)].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 4)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 4)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[5].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 4)].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 5)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 5)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[6].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 5)].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 6)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 6)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[7].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 6)].default_selected_ind = 0
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE get_note(tnbr)
  FOR (y = 1 TO process_cnt)
    IF ((temp->plist[y].process_name IN ("CHARTPREP", "PTINTAKE", "PROVASSESS", "CHECKIN",
    "NONPROVVISIT",
    "SIGNTRANS", "HIM", "TRANS", "ALL")))
     SET reply->qual[p].rlist[tnbr].display_ind = 1
     SET reply->qual[p].rlist[(tnbr+ 1)].display_ind = 1
     IF (deskscan_ind=1)
      SET reply->qual[p].rlist[(tnbr+ 2)].display_ind = 1
     ENDIF
     SET at_least_one_display_ind = 1
     SET y = (process_cnt+ 1)
    ENDIF
  ENDFOR
  IF ((reply->qual[p].rlist[tnbr].display_ind=1))
   SET stat = alterlist(multitaskrequest->task_list,3)
   SET stat = alterlist(multitaskreply->status_data.status_list,3)
   SET multitaskrequest->task_list[1].task = "VIEWNOTES"
   SET multitaskrequest->task_list[2].task = "UPDNOTES"
   SET multitaskrequest->task_list[3].task = "SCANNOTES"
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_note  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
    multitaskreply)
   SET reply->qual[p].rlist[tnbr].default_selected_ind = cnvtint(multitaskreply->status_data.
    status_list[1].status)
   SET reply->qual[p].rlist[(tnbr+ 1)].default_selected_ind = cnvtint(multitaskreply->status_data.
    status_list[2].status)
   SET reply->qual[p].rlist[(tnbr+ 2)].default_selected_ind = cnvtint(multitaskreply->status_data.
    status_list[3].status)
  ENDIF
 END ;Subroutine
 SUBROUTINE get_structdoc(tnbr)
   FOR (y = 1 TO process_cnt)
     IF ((temp->plist[y].process_name IN ("POWERNOTE", "ALLDOCTYPES", "ALL")))
      SET reply->qual[p].rlist[tnbr].display_ind = 1
      SET reply->qual[p].rlist[(tnbr+ 1)].display_ind = 1
      SET reply->qual[p].rlist[(tnbr+ 2)].display_ind = 1
      SET reply->qual[p].rlist[(tnbr+ 3)].display_ind = 1
      SET reply->qual[p].rlist[(tnbr+ 4)].display_ind = 1
      SET reply->qual[p].rlist[(tnbr+ 5)].display_ind = 1
      SET at_least_one_display_ind = 1
      SET y = (process_cnt+ 1)
     ENDIF
   ENDFOR
   SET reply->qual[p].rlist[(tnbr+ 6)].display_ind = 0
   IF ((reply->qual[p].rlist[tnbr].display_ind=1))
    SET stat = alterlist(multitaskrequest->task_list,7)
    SET stat = alterlist(multitaskreply->status_data.status_list,7)
    SET multitaskrequest->task_list[1].task = "SAVESTRUCTDOC"
    SET multitaskrequest->task_list[2].task = "SIGNSTRUCTDOC"
    SET multitaskrequest->task_list[3].task = "PRECOMPNOTES"
    SET multitaskrequest->task_list[4].task = "ORDDIAGSTRUCTDOC"
    SET multitaskrequest->task_list[5].task = "RXSTRUCTDOC"
    SET multitaskrequest->task_list[6].task = "MINEONLYSTRUCTDOC"
    SET multitaskrequest->task_list[7].task = "CERTAINCAREDESIGNS"
    SET trace = recpersist
    EXECUTE bed_get_ens_tasks_structdoc  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
     multitaskreply)
    SET reply->qual[p].rlist[tnbr].default_selected_ind = cnvtint(multitaskreply->status_data.
     status_list[1].status)
    SET reply->qual[p].rlist[(tnbr+ 1)].default_selected_ind = cnvtint(multitaskreply->status_data.
     status_list[2].status)
    SET reply->qual[p].rlist[(tnbr+ 2)].default_selected_ind = cnvtint(multitaskreply->status_data.
     status_list[3].status)
    SET reply->qual[p].rlist[(tnbr+ 3)].default_selected_ind = cnvtint(multitaskreply->status_data.
     status_list[4].status)
    SET reply->qual[p].rlist[(tnbr+ 4)].default_selected_ind = cnvtint(multitaskreply->status_data.
     status_list[5].status)
    SET reply->qual[p].rlist[(tnbr+ 5)].default_selected_ind = cnvtint(multitaskreply->status_data.
     status_list[6].status)
    SET reply->qual[p].rlist[(tnbr+ 6)].default_selected_ind = cnvtint(multitaskreply->status_data.
     status_list[7].status)
   ENDIF
 END ;Subroutine
 SUBROUTINE get_form(tnbr)
  FOR (y = 1 TO process_cnt)
    IF ((temp->plist[y].process_name IN ("PTINTAKE", "NONPROVVISIT", "PROVASSESS", "CHECKOUT", "ALL")
    ))
     SET reply->qual[p].rlist[tnbr].display_ind = 1
     SET reply->qual[p].rlist[(tnbr+ 1)].display_ind = 1
     SET reply->qual[p].rlist[(tnbr+ 2)].display_ind = 1
     SET at_least_one_display_ind = 1
     SET y = (process_cnt+ 1)
    ENDIF
  ENDFOR
  IF ((reply->qual[p].rlist[tnbr].display_ind=1))
   SET stat = alterlist(multitaskrequest->task_list,3)
   SET stat = alterlist(multitaskreply->status_data.status_list,3)
   SET multitaskrequest->task_list[1].task = "VIEWFORM"
   SET multitaskrequest->task_list[2].task = "SAVEFORM"
   SET multitaskrequest->task_list[3].task = "SIGNFORM"
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_form  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
    multitaskreply)
   SET reply->qual[p].rlist[tnbr].default_selected_ind = cnvtint(multitaskreply->status_data.
    status_list[1].status)
   SET reply->qual[p].rlist[(tnbr+ 1)].default_selected_ind = cnvtint(multitaskreply->status_data.
    status_list[2].status)
   SET reply->qual[p].rlist[(tnbr+ 2)].default_selected_ind = cnvtint(multitaskreply->status_data.
    status_list[3].status)
  ENDIF
 END ;Subroutine
 SUBROUTINE get_pedgrowthchart(tnbr)
  FOR (y = 1 TO process_cnt)
    IF ((temp->plist[y].process_name IN ("PTINTAKE", "NONPROVVISIT", "PROVASSESS", "ALL")))
     SET reply->qual[p].rlist[tnbr].display_ind = 1
     SET at_least_one_display_ind = 1
     SET y = (process_cnt+ 1)
    ENDIF
  ENDFOR
  IF ((reply->qual[p].rlist[tnbr].display_ind=1))
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_pedgwthch  WITH replace("REQUEST",singletaskrequest), replace("REPLY",
    singletaskreply)
   IF ((singletaskreply->status_data.status="S"))
    SET reply->qual[p].rlist[tnbr].default_selected_ind = 1
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE get_pthistrslt(tnbr)
   FOR (y = 1 TO process_cnt)
     IF ((temp->plist[y].process_name IN ("PTINTAKE", "NONPROVVISIT", "PROVASSESS", "ALL")))
      SET reply->qual[p].rlist[tnbr].display_ind = 1
      SET reply->qual[p].rlist[(tnbr+ 1)].display_ind = 1
      SET at_least_one_display_ind = 1
      SET y = (process_cnt+ 1)
     ENDIF
   ENDFOR
   FOR (y = 1 TO process_cnt)
     IF ((temp->plist[y].process_name IN ("PTINTAKE", "NONPROVVISIT", "PROVASSESS", "RESULTNOTIFY",
     "ALL")))
      SET reply->qual[p].rlist[(tnbr+ 2)].display_ind = 1
      SET reply->qual[p].rlist[(tnbr+ 3)].display_ind = 1
      SET at_least_one_display_ind = 1
      SET y = (process_cnt+ 1)
     ENDIF
   ENDFOR
   IF ((((reply->qual[p].rlist[tnbr].display_ind=1)) OR ((((reply->qual[p].rlist[(tnbr+ 1)].
   display_ind=1)) OR ((((reply->qual[p].rlist[(tnbr+ 2)].display_ind=1)) OR ((reply->qual[p].rlist[(
   tnbr+ 3)].display_ind=1))) )) )) )
    SET stat = alterlist(multitaskrequest->task_list,4)
    SET stat = alterlist(multitaskreply->status_data.status_list,4)
    SET multitaskrequest->task_list[1].task = "VIEWPTHIST"
    SET multitaskrequest->task_list[2].task = "UPDPTHIST"
    SET multitaskrequest->task_list[3].task = "VIEWRESULT"
    SET multitaskrequest->task_list[4].task = "COMMENTRESULT"
    SET trace = recpersist
    EXECUTE bed_get_ens_tasks_pthistrslt  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
     multitaskreply)
    IF ((reply->qual[p].rlist[tnbr].display_ind=1))
     SET reply->qual[p].rlist[tnbr].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[1].status)
    ELSE
     SET reply->qual[p].rlist[tnbr].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 1)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 1)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[2].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 1)].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 2)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 2)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[3].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 2)].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 3)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 3)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[4].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 3)].default_selected_ind = 0
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE get_task(tnbr)
  FOR (y = 1 TO process_cnt)
    IF ((temp->plist[y].process_name IN ("PTINTAKE", "NONPROVVISIT", "PROVASSESS", "MEDADMIN",
    "IMMADMIN",
    "ALL")))
     SET reply->qual[p].rlist[tnbr].display_ind = 1
     SET reply->qual[p].rlist[(tnbr+ 1)].display_ind = 1
     SET at_least_one_display_ind = 1
     SET y = (process_cnt+ 1)
    ENDIF
  ENDFOR
  IF ((reply->qual[p].rlist[tnbr].display_ind=1))
   SET stat = alterlist(multitaskrequest->task_list,2)
   SET stat = alterlist(multitaskreply->status_data.status_list,2)
   SET multitaskrequest->task_list[1].task = "VIEWTASK"
   SET multitaskrequest->task_list[2].task = "UPDTASK"
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_charttask  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
    multitaskreply)
   SET reply->qual[p].rlist[tnbr].default_selected_ind = cnvtint(multitaskreply->status_data.
    status_list[1].status)
   SET reply->qual[p].rlist[(tnbr+ 1)].default_selected_ind = cnvtint(multitaskreply->status_data.
    status_list[2].status)
  ENDIF
 END ;Subroutine
 SUBROUTINE get_evalmgmtassist(tnbr)
  SET reply->qual[p].rlist[tnbr].display_ind = 0
  SET reply->qual[p].rlist[tnbr].default_selected_ind = 0
 END ;Subroutine
 SUBROUTINE get_viewcharges(tnbr)
  FOR (y = 1 TO process_cnt)
    IF ((temp->plist[y].process_name IN ("PTINTAKE", "NONPROVVISIT", "PROVASSESS", "ALL")))
     SET reply->qual[p].rlist[tnbr].display_ind = 1
     SET at_least_one_display_ind = 1
     SET y = (process_cnt+ 1)
    ENDIF
  ENDFOR
  IF ((reply->qual[p].rlist[tnbr].display_ind=1))
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_charge  WITH replace("REQUEST",singletaskrequest), replace("REPLY",
    singletaskreply)
   IF ((singletaskreply->status_data.status="S"))
    SET reply->qual[p].rlist[tnbr].default_selected_ind = 1
   ENDIF
  ENDIF
 END ;Subroutine
 SUBROUTINE get_inbox(tnbr)
   FOR (y = 1 TO process_cnt)
     IF ((temp->plist[y].process_name IN ("RESULTNOTIFY", "ALL")))
      SET reply->qual[p].rlist[(tnbr+ 2)].display_ind = 1
      SET reply->qual[p].rlist[(tnbr+ 3)].display_ind = 1
      IF (physician_ind=1)
       SET reply->qual[p].rlist[tnbr].display_ind = 1
      ENDIF
      IF (mtm_ind=1)
       SET reply->qual[p].rlist[(tnbr+ 4)].display_ind = 1
      ENDIF
      IF (iqhealth_ind=1)
       SET reply->qual[p].rlist[(tnbr+ 6)].display_ind = 1
      ENDIF
      SET at_least_one_display_ind = 1
      SET y = (process_cnt+ 1)
     ENDIF
   ENDFOR
   FOR (y = 1 TO process_cnt)
     IF ((temp->plist[y].process_name IN ("HIM", "SIGNTRANS", "PROVASSESS", "TRANS", "ALL")))
      SET reply->qual[p].rlist[(tnbr+ 1)].display_ind = 1
      SET at_least_one_display_ind = 1
      SET y = (process_cnt+ 1)
     ENDIF
   ENDFOR
   FOR (y = 1 TO process_cnt)
     IF ((temp->plist[y].process_name IN ("RESULTNOTIFY", "SIGNTRANS", "TRANS", "ALL")))
      SET reply->qual[p].rlist[(tnbr+ 5)].display_ind = 1
      SET at_least_one_display_ind = 1
      SET y = (process_cnt+ 1)
     ENDIF
   ENDFOR
   FOR (y = 1 TO process_cnt)
     IF ((temp->plist[y].process_name IN ("HIM", "SIGNTRANS", "PROVASSESS", "RESULTNOTIFY", "TRANS",
     "ALL")))
      SET reply->qual[p].rlist[(tnbr+ 7)].display_ind = 1
      SET at_least_one_display_ind = 1
      SET y = (process_cnt+ 1)
     ENDIF
   ENDFOR
   IF (profile_ind=1)
    FOR (y = 1 TO process_cnt)
      IF ((temp->plist[y].process_name IN ("SIGNTRANS", "PROVASSESS", "TRANS", "ALL")))
       SET reply->qual[p].rlist[(tnbr+ 8)].display_ind = 1
       SET at_least_one_display_ind = 1
       SET y = (process_cnt+ 1)
      ENDIF
    ENDFOR
   ENDIF
   FOR (y = 1 TO process_cnt)
     IF ((temp->plist[y].process_name IN ("PHONEMSG", "HIM", "MEDREFILL", "ALL")))
      SET reply->qual[p].rlist[(tnbr+ 9)].display_ind = 1
      SET reply->qual[p].rlist[(tnbr+ 10)].display_ind = 1
      SET at_least_one_display_ind = 1
      SET y = (process_cnt+ 1)
     ENDIF
   ENDFOR
   FOR (y = 1 TO process_cnt)
     IF ((temp->plist[y].process_name IN ("PHONEMSG", "HIM", "MEDREFILL", "ALL")))
      SET reply->qual[p].rlist[(tnbr+ 11)].display_ind = 1
      SET at_least_one_display_ind = 1
      SET y = (process_cnt+ 1)
     ENDIF
   ENDFOR
   IF (physician_ind=1)
    FOR (y = 1 TO process_cnt)
      IF ((temp->plist[y].process_name IN ("COSIGN", "ALL")))
       SET reply->qual[p].rlist[(tnbr+ 12)].display_ind = 1
       SET at_least_one_display_ind = 1
       SET y = (process_cnt+ 1)
      ENDIF
    ENDFOR
   ENDIF
   FOR (y = 1 TO process_cnt)
     IF ((temp->plist[y].process_name IN ("PTINTAKE", "PROVASSESS", "NONPROVVISIT", "ALL")))
      SET reply->qual[p].rlist[(tnbr+ 13)].display_ind = 1
      SET at_least_one_display_ind = 1
      SET y = (process_cnt+ 1)
     ENDIF
   ENDFOR
   SET reply->qual[p].rlist[(tnbr+ 14)].display_ind = 0
   IF ((((reply->qual[p].rlist[tnbr].display_ind=1)) OR ((((reply->qual[p].rlist[(tnbr+ 1)].
   display_ind=1)) OR ((((reply->qual[p].rlist[(tnbr+ 2)].display_ind=1)) OR ((((reply->qual[p].
   rlist[(tnbr+ 3)].display_ind=1)) OR ((((reply->qual[p].rlist[(tnbr+ 4)].display_ind=1)) OR ((((
   reply->qual[p].rlist[(tnbr+ 5)].display_ind=1)) OR ((((reply->qual[p].rlist[(tnbr+ 6)].display_ind
   =1)) OR ((((reply->qual[p].rlist[(tnbr+ 7)].display_ind=1)) OR ((((reply->qual[p].rlist[(tnbr+ 8)]
   .display_ind=1)) OR ((((reply->qual[p].rlist[(tnbr+ 9)].display_ind=1)) OR ((((reply->qual[p].
   rlist[(tnbr+ 10)].display_ind=1)) OR ((((reply->qual[p].rlist[(tnbr+ 11)].display_ind=1)) OR ((((
   reply->qual[p].rlist[(tnbr+ 12)].display_ind=1)) OR ((((reply->qual[p].rlist[(tnbr+ 13)].
   display_ind=1)) OR ((reply->qual[p].rlist[(tnbr+ 14)].display_ind=1))) )) )) )) )) )) )) )) )) ))
   )) )) )) )) )
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
    SET trace = recpersist
    EXECUTE bed_get_ens_tasks_inbox  WITH replace("REQUEST",multitaskrequest), replace("REPLY",
     multitaskreply)
    IF ((reply->qual[p].rlist[tnbr].display_ind=1))
     SET reply->qual[p].rlist[tnbr].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[1].status)
    ELSE
     SET reply->qual[p].rlist[tnbr].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 1)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 1)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[2].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 1)].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 2)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 2)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[3].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 2)].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 3)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 3)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[4].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 3)].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 4)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 4)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[5].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 4)].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 5)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 5)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[6].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 5)].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 6)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 6)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[7].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 6)].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 7)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 7)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[8].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 7)].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 8)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 8)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[9].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 8)].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 9)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 9)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[10].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 9)].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 10)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 10)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[11].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 10)].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 11)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 11)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[12].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 11)].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 12)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 12)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[13].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 12)].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 13)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 13)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[14].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 13)].default_selected_ind = 0
    ENDIF
    IF ((reply->qual[p].rlist[(tnbr+ 14)].display_ind=1))
     SET reply->qual[p].rlist[(tnbr+ 14)].default_selected_ind = cnvtint(multitaskreply->status_data.
      status_list[15].status)
    ELSE
     SET reply->qual[p].rlist[(tnbr+ 14)].default_selected_ind = 0
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE get_misc_1(tnbr)
   SET reply->qual[p].rlist[tnbr].display_ind = 1
   SET reply->qual[p].rlist[(tnbr+ 1)].display_ind = 0
   SET reply->qual[p].rlist[(tnbr+ 2)].display_ind = 1
   SET reply->qual[p].rlist[(tnbr+ 3)].display_ind = 1
   SET reply->qual[p].rlist[(tnbr+ 4)].display_ind = 1
   SET reply->qual[p].rlist[(tnbr+ 6)].display_ind = 1
   SET reply->qual[p].rlist[(tnbr+ 7)].display_ind = 1
   IF (acute_care_psn_ind=1)
    SET reply->qual[p].rlist[(tnbr+ 12)].display_ind = 1
   ENDIF
   SET reply->qual[p].rlist[(tnbr+ 13)].display_ind = 1
   SET reply->qual[p].rlist[(tnbr+ 14)].display_ind = 1
   SET reply->qual[p].rlist[(tnbr+ 15)].display_ind = 1
   SET reply->qual[p].rlist[(tnbr+ 16)].display_ind = 1
   SET at_least_one_display_ind = 1
   SET stat = alterlist(misctaskrequest->task_list,12)
   SET stat = alterlist(misctaskreply->status_data.status_list,12)
   SET misctaskrequest->task_list[1].task = "PATIENTLIST"
   SET misctaskrequest->task_list[2].task = "INTELLISTRIP"
   SET misctaskrequest->task_list[3].task = "PROVRELTN"
   SET misctaskrequest->task_list[4].task = "ENCOUNTERS"
   SET misctaskrequest->task_list[5].task = "HEALTHPLANS"
   SET misctaskrequest->task_list[6].task = "MAR"
   SET misctaskrequest->task_list[7].task = "WEBSITE"
   SET misctaskrequest->task_list[8].task = "CHARTSUMMARY"
   SET misctaskrequest->task_list[9].task = "PATIENTACCESS"
   SET misctaskrequest->task_list[10].task = "VIEWSTICKYNOTES"
   SET misctaskrequest->task_list[11].task = "ADDSTICKYNOTES"
   SET misctaskrequest->task_list[12].task = "REPORTS"
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_misc  WITH replace("REQUEST",misctaskrequest), replace("REPLY",
    misctaskreply)
   SET reply->qual[p].rlist[tnbr].default_selected_ind = cnvtint(misctaskreply->status_data.
    status_list[1].status)
   SET reply->qual[p].rlist[(tnbr+ 1)].default_selected_ind = cnvtint(misctaskreply->status_data.
    status_list[2].status)
   SET reply->qual[p].rlist[(tnbr+ 2)].default_selected_ind = cnvtint(misctaskreply->status_data.
    status_list[3].status)
   SET reply->qual[p].rlist[(tnbr+ 3)].default_selected_ind = cnvtint(misctaskreply->status_data.
    status_list[4].status)
   SET reply->qual[p].rlist[(tnbr+ 4)].default_selected_ind = cnvtint(misctaskreply->status_data.
    status_list[5].status)
   SET reply->qual[p].rlist[(tnbr+ 6)].default_selected_ind = cnvtint(misctaskreply->status_data.
    status_list[6].status)
   SET reply->qual[p].rlist[(tnbr+ 7)].default_selected_ind = cnvtint(misctaskreply->status_data.
    status_list[7].status)
   SET reply->qual[p].rlist[(tnbr+ 12)].default_selected_ind = cnvtint(misctaskreply->status_data.
    status_list[8].status)
   SET reply->qual[p].rlist[(tnbr+ 13)].default_selected_ind = cnvtint(misctaskreply->status_data.
    status_list[9].status)
   SET reply->qual[p].rlist[(tnbr+ 14)].default_selected_ind = cnvtint(misctaskreply->status_data.
    status_list[10].status)
   SET reply->qual[p].rlist[(tnbr+ 15)].default_selected_ind = cnvtint(misctaskreply->status_data.
    status_list[11].status)
   SET reply->qual[p].rlist[(tnbr+ 16)].default_selected_ind = cnvtint(misctaskreply->status_data.
    status_list[12].status)
   SET reply->qual[p].website_url = misctaskreply->status_data.website_url
   SET reply->qual[p].website_display = misctaskreply->status_data.website_display
 END ;Subroutine
 SUBROUTINE get_misc_2(tnbr)
   SET tlcnt = 0
   IF (acute_care_psn_ind=1)
    FOR (y = 1 TO process_cnt)
      IF ((temp->plist[y].process_name IN ("SUPERBILL", "ALL")))
       SET tlcnt = (tlcnt+ 1)
       SET misctaskrequest->task_list[tlcnt].task = "POWERORDERS"
       SET reply->qual[p].rlist[tnbr].display_ind = 1
       SET at_least_one_display_ind = 1
       SET y = (process_cnt+ 1)
      ENDIF
    ENDFOR
   ENDIF
   IF (acute_care_psn_ind=1)
    SET tlcnt = (tlcnt+ 1)
    SET misctaskrequest->task_list[tlcnt].task = "SHIFTASSIGN"
    SET tlcnt = (tlcnt+ 1)
    SET misctaskrequest->task_list[tlcnt].task = "IANDO"
    SET reply->qual[p].rlist[(tnbr+ 3)].display_ind = 1
    SET reply->qual[p].rlist[(tnbr+ 6)].display_ind = 1
    SET at_least_one_display_ind = 1
   ENDIF
   IF (physician_ind=1)
    SET tlcnt = (tlcnt+ 1)
    SET misctaskrequest->task_list[tlcnt].task = "COSIGNORDER"
    SET reply->qual[p].rlist[(tnbr+ 4)].display_ind = 1
    SET at_least_one_display_ind = 1
   ENDIF
   IF (inet_ind=1)
    SET tlcnt = (tlcnt+ 1)
    SET misctaskrequest->task_list[tlcnt].task = "ADVGRAPH"
    SET reply->qual[p].rlist[(tnbr+ 5)].display_ind = 1
    SET at_least_one_display_ind = 1
   ENDIF
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_misc  WITH replace("REQUEST",misctaskrequest), replace("REPLY",
    misctaskreply)
   SET reply->qual[p].rlist[tnbr].default_selected_ind = 0
   SET reply->qual[p].rlist[(tnbr+ 3)].default_selected_ind = 0
   SET reply->qual[p].rlist[(tnbr+ 4)].default_selected_ind = 0
   SET reply->qual[p].rlist[(tnbr+ 5)].default_selected_ind = 0
   SET reply->qual[p].rlist[(tnbr+ 6)].default_selected_ind = 0
   FOR (scnt = 1 TO tlcnt)
     IF ((misctaskrequest->task_list[scnt].task="POWERORDERS"))
      SET reply->qual[p].rlist[tnbr].default_selected_ind = cnvtint(misctaskreply->status_data.
       status_list[scnt].status)
     ELSEIF ((misctaskrequest->task_list[scnt].task="SHIFTASSIGN"))
      SET reply->qual[p].rlist[(tnbr+ 3)].default_selected_ind = cnvtint(misctaskreply->status_data.
       status_list[scnt].status)
     ELSEIF ((misctaskrequest->task_list[scnt].task="COSIGNORDER"))
      SET reply->qual[p].rlist[(tnbr+ 4)].default_selected_ind = cnvtint(misctaskreply->status_data.
       status_list[scnt].status)
     ELSEIF ((misctaskrequest->task_list[scnt].task="ADVGRAPH"))
      SET reply->qual[p].rlist[(tnbr+ 5)].default_selected_ind = cnvtint(misctaskreply->status_data.
       status_list[scnt].status)
     ELSEIF ((misctaskrequest->task_list[scnt].task="IANDO"))
      SET reply->qual[p].rlist[(tnbr+ 6)].default_selected_ind = cnvtint(misctaskreply->status_data.
       status_list[scnt].status)
     ENDIF
   ENDFOR
 END ;Subroutine
 SUBROUTINE get_pubmedrec(tnbr)
  IF (mrp_ind=1)
   SET reply->qual[p].rlist[tnbr].display_ind = 1
   SET at_least_one_display_ind = 1
  ENDIF
  IF ((reply->qual[p].rlist[tnbr].display_ind=1))
   SET trace = recpersist
   EXECUTE bed_get_ens_tasks_pubmedrec  WITH replace("REQUEST",singletaskrequest), replace("REPLY",
    singletaskreply)
   IF ((singletaskreply->status_data.status="S"))
    SET reply->qual[p].rlist[tnbr].default_selected_ind = 1
   ENDIF
  ENDIF
 END ;Subroutine
#exitscript
END GO
