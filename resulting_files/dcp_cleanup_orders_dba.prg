CREATE PROGRAM dcp_cleanup_orders:dba
 PAINT
 SET task_cancel_cd = 0.0
 SET task_pending_cd = 0.0
 SET task_overdue_cd = 0.0
 SET task_inprocess_cd = 0.0
 SET cancel_cd = 0.0
 SET discontinue_cd = 0.0
 SET complete_cd = 0.0
 SET dept_canceled_cd = 0.0
 SET dept_discontinued_cd = 0.0
 SET dept_completed_cd = 0.0
 SET system_prsnl_id = 0.0
 SET catalog_cd = 0.0
 SET catalog_disp = fillstring(45," ")
 SET mode = 0
 SET cleanup_type = fillstring(8," ")
 SET nbr_days = 0
 SET now = cnvtdatetime(curdate,curtime3)
 SET printer = fillstring(20," ")
 SET tot_pages = 0
 SET print_queue_cd = 0.0
 SET printer_cd = 0.0
 RECORD hold(
   1 tot_ord_cnt = f8
   1 enc_cnt = i4
   1 enc[*]
     2 encntr_id = f8
     2 disch_dt_tm = dq8
     2 name = c30
     2 ord_cnt = i4
     2 ord[*]
       3 order_id = f8
       3 order_status_cd = f8
       3 cont_order = c1
       3 last_action_sequence = i4
       3 curr_start_dt_tm = dq8
       3 curr_start_tz = dq8
       3 mnem = c36
 )
 RECORD ostatus(
   1 ordered_cd = f8
   1 inprocess_cd = f8
   1 canceled_cd = f8
   1 discontinued_cd = f8
   1 completed_cd = f8
   1 deleted_cd = f8
   1 suspended_cd = f8
 )
 RECORD task_info(
   1 task_cnt = i4
   1 task[*]
     2 task_id = f8
     2 task_dt_tm = dq8
     2 task_status_cd = f8
     2 task_action_seq = i4
 )
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=79
  DETAIL
   CASE (c.cdf_meaning)
    OF "DELETED":
     task_cancel_cd = c.code_value
    OF "PENDING":
     task_pending_cd = c.code_value
    OF "OVERDUE":
     task_overdue_cd = c.code_value
    OF "INPROCESS":
     task_inprocess_cd = c.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=3000
  DETAIL
   CASE (c.cdf_meaning)
    OF "PRINT QUEUE":
     print_queue_cd = c.code_value
    OF "PRINTER":
     printer_cd = c.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=6003
  DETAIL
   CASE (c.cdf_meaning)
    OF "CANCEL":
     cancel_cd = c.code_value
    OF "DISCONTINUE":
     discontinue_cd = c.code_value
    OF "COMPLETE":
     complete_cd = c.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=6004
  DETAIL
   CASE (c.cdf_meaning)
    OF "ORDERED":
     ostatus->ordered_cd = c.code_value
    OF "INPROCESS":
     ostatus->inprocess_cd = c.code_value
    OF "CANCELED":
     ostatus->canceled_cd = c.code_value
    OF "DISCONTINUED":
     ostatus->discontinued_cd = c.code_value
    OF "COMPLETED":
     ostatus->completed_cd = c.code_value
    OF "DELETED":
     ostatus->deleted_cd = c.code_value
    OF "SUSPENDED":
     ostatus->suspended_cd = c.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=14281
  DETAIL
   CASE (c.cdf_meaning)
    OF "CANCELED":
     dept_canceled_cd = c.code_value
    OF "DISCONTINUED":
     dept_discontinued_cd = c.code_value
    OF "COMPLETED":
     dept_completed_cd = c.code_value
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "nl"
  p.person_id
  FROM prsnl p
  WHERE p.name_last_key="SYSTEM"
   AND p.name_first_key="SYSTEM"
  DETAIL
   system_prsnl_id = p.person_id
  WITH nocounter
 ;end select
#1000_main
 CALL video(s)
 CALL clear(1,1)
 CALL box(2,1,22,80)
 CALL line(4,1,80,"XH")
 CALL text(3,3,"Clean up orders")
 CALL text(24,67,"(PF3 to EXIT)")
 CALL text(7,3,"Catalog Type:")
 CALL text(9,3,"Cleanup Mode:")
 EXECUTE FROM 1200_catalog_type TO 1299_catalog_type_exit
 EXECUTE FROM 1300_mode TO 1399_mode_exit
 CALL clear(3,3,60)
 CASE (mode)
  OF 1:
   SET text = concat("Query all active orders on discharged patients - ",substring(1,27,catalog_disp)
    )
   CALL text(3,3,trim(text))
  OF 2:
   SET text = concat("Query active orders more than ",trim(cnvtstring(nbr_days))," days old - ",
    substring(1,31,catalog_disp))
   CALL text(3,3,trim(text))
  OF 3:
   SET text = concat("Clean all active orders on discharged patients - ",substring(1,27,catalog_disp)
    )
   CALL text(3,3,trim(text))
   EXECUTE FROM 1600_cleanup_type TO 1699_cleanup_type_exit
   CALL video(r)
   IF (cleanup_type="CANCEL")
    CALL text(15,8,concat("This will cancel all active ",trim(catalog_disp)))
   ELSE
    CALL text(15,8,concat("This will complete all active ",trim(catalog_disp)))
   ENDIF
   CALL text(16,8,"orders on discharged patients.")
   CALL video(n)
  OF 4:
   SET text = concat("Clean active orders more than ",trim(cnvtstring(nbr_days))," days old - ",
    substring(1,31,catalog_disp))
   CALL text(3,3,trim(text))
   EXECUTE FROM 1600_cleanup_type TO 1699_cleanup_type_exit
   CALL video(r)
   IF (cleanup_type="CANCEL")
    CALL text(15,8,concat("This will cancel active ",trim(catalog_disp)))
   ELSE
    CALL text(15,8,concat("This will complete active ",trim(catalog_disp)))
   ENDIF
   CALL text(16,8,concat("orders on discharged patients over ",trim(cnvtstring(nbr_days)),
     " days old."))
   CALL video(n)
 ENDCASE
 EXECUTE FROM 1500_prompt_printer TO 1599_prompt_printer_exit
 EXECUTE FROM 1400_prompt_ok TO 1499_prompt_ok_exit
 CALL clear(15,3,60)
 CALL clear(16,3,60)
 EXECUTE FROM 2000_fill_hold TO 2099_fill_hold_exit
 IF (mode IN (1, 2))
  EXECUTE FROM 2100_query TO 2199_query_exit
 ELSE
  EXECUTE FROM 2100_query TO 2199_query_exit
  EXECUTE FROM 2200_clean TO 2299_clean_exit
 ENDIF
 GO TO 9000_end
#1099_main_exit
#1200_catalog_type
 CALL clear(7,18,60)
 SET help =
 SELECT INTO "nl:"
  catalog_cd = c.code_value"##########;r", catalog_type = c.display
  FROM code_value c
  WHERE c.code_set=6000
   AND cnvtupper(c.definition)="CER_EXE:GENERIC_SHRORDER"
  ORDER BY c.display
  WITH nocounter
 ;end select
 SET validate =
 SELECT INTO "nl:"
  catalog_cd = c.code_value"##########;r"
  FROM code_value c
  WHERE c.code_set=6000
   AND cnvtupper(c.definition)="CER_EXE:GENERIC_SHRORDER"
   AND c.code_value=curaccept
  WITH nocounter
 ;end select
 SET validate = required
 SET validate = 1
 CALL accept(7,18,"9(10);DSF")
 SET catalog_cd = curaccept
 SET help = off
 SET validate = off
 SELECT INTO "nl:"
  c.display
  FROM code_value c
  WHERE c.code_value=catalog_cd
  DETAIL
   catalog_disp = c.display
  WITH nocounter
 ;end select
#1299_catalog_type_exit
#1300_mode
 CALL clear(9,18,60)
 SET help_item = concat("1",'"',"Query all active orders on discharged patients",'",',"2",
  '"',"Query active orders more than < > days old",'",',"3",'"',
  "Clean all active orders on discharged patients",'",',"4",'"',
  "Clean active orders more than < > days old",
  '"')
 SET help = fix(value(help_item))
 CALL accept(9,18,"9;F"
  WHERE cnvtint(curaccept) IN (1, 2, 3, 4))
 SET help = off
 SET mode = curaccept
#1350_mode_nbr_days
 SET nbr_days = 0
 IF (mode=2)
  CALL text(24,1,"Value must be > 30")
  CALL text(11,8,"Query active orders more than     days old.")
  CALL accept(11,38,"NNN;CU"
   WHERE cnvtint(curaccept) > 30)
  SET nbr_days = cnvtint(curaccept)
 ELSEIF (mode=4)
  CALL text(24,1,"Value must be > 30")
  CALL text(11,8,"Clean active orders more than     days old.")
  CALL accept(11,38,"NNN;CU"
   WHERE cnvtint(curaccept) > 30)
  SET nbr_days = cnvtint(curaccept)
 ENDIF
 CALL clear(24,1,60)
 CALL clear(11,3,60)
 SET now_minus_days = datetimeadd(now,- (nbr_days))
#1399_mode_exit
#1400_prompt_ok
 CALL text(24,1,"Correct?   (Y/N)")
 CALL accept(24,10,"P;CU"
  WHERE curaccept IN ("Y", "N"))
 IF (curaccept="N")
  GO TO 1000_main
 ENDIF
#1499_prompt_ok_exit
#1500_prompt_printer
 CALL text(20,3,"Report Destination:")
 SET help =
 SELECT INTO "nl:"
  queue = d.name, description = d.description
  FROM device d
  WHERE d.device_type_cd IN (print_queue_cd, printer_cd)
  ORDER BY d.name
  WITH nocounter
 ;end select
 CALL text(24,1,"Help Available (Shift + F5)")
 CALL accept(20,23,"P(20);CU")
 SET printer = curaccept
 CALL clear(24,1,60)
 SET help = off
#1599_prompt_printer_exit
#1600_cleanup_type
 CALL text(19,3,"Cancel or Complete Outstanding orders:")
 SET help = fix("CANCEL,COMPLETE")
 CALL accept(19,42,"P(8);CU","CANCEL"
  WHERE curaccept IN ("COMPLETE", "CANCEL"))
 SET cleanup_type = curaccept
 SET help = off
#1699_cleanup_type_exit
#2000_fill_hold
 CALL clear(24,1)
 CALL video(b)
 CALL text(24,1,"Reading database for orders on discharged patients")
 CALL video(n)
 SELECT INTO "nl:"
  e.encntr_id, e.disch_dt_tm, p.name_last_key,
  o.order_id, o.catalog_type_cd, o.order_mnemonic
  FROM encounter e,
   person p,
   orders o
  PLAN (e
   WHERE ((e.encntr_id+ 0) > 0)
    AND e.disch_dt_tm < cnvtdatetime(curdate,curtime))
   JOIN (p
   WHERE p.person_id=e.person_id)
   JOIN (o
   WHERE o.person_id=p.person_id
    AND ((o.encntr_id+ 0)=e.encntr_id)
    AND ((o.order_status_cd+ 0) IN (ostatus->ordered_cd, ostatus->inprocess_cd, ostatus->suspended_cd
   ))
    AND ((o.current_start_dt_tm+ 0) < cnvtdatetime(now_minus_days))
    AND o.catalog_type_cd=catalog_cd)
  ORDER BY e.disch_dt_tm DESC, e.encntr_id, o.order_id DESC
  HEAD REPORT
   hold->tot_ord_cnt = 0, hold->enc_cnt = 0
  HEAD e.encntr_id
   hold->enc_cnt = (hold->enc_cnt+ 1), ec = hold->enc_cnt
   IF (ec > size(hold->enc,5))
    stat = alterlist(hold->enc,(ec+ 10))
   ENDIF
   hold->enc[ec].encntr_id = e.encntr_id, hold->enc[ec].name = p.name_full_formatted, hold->enc[ec].
   disch_dt_tm = e.disch_dt_tm,
   hold->enc[ec].ord_cnt = 0
  HEAD o.order_id
   IF (o.current_start_dt_tm < now_minus_days)
    hold->tot_ord_cnt = (hold->tot_ord_cnt+ 1), hold->enc[ec].ord_cnt = (hold->enc[ec].ord_cnt+ 1),
    oc = hold->enc[ec].ord_cnt
    IF (oc > size(hold->enc[ec].ord,5))
     stat = alterlist(hold->enc[ec].ord,(oc+ 10))
    ENDIF
    hold->enc[ec].ord[oc].order_id = o.order_id, hold->enc[ec].ord[oc].mnem = o.hna_order_mnemonic,
    hold->enc[ec].ord[oc].curr_start_dt_tm = o.current_start_dt_tm,
    hold->enc[ec].ord[oc].curr_start_tz = o.current_start_tz, hold->enc[ec].ord[oc].
    last_action_sequence = o.last_action_sequence
    IF (o.template_order_flag=1)
     hold->enc[ec].ord[oc].cont_order = "Y"
    ELSE
     hold->enc[ec].ord[oc].cont_order = " "
    ENDIF
   ENDIF
  FOOT  e.encntr_id
   stat = alterlist(hold->enc[ec].ord,hold->enc[ec].ord_cnt)
  FOOT REPORT
   stat = alterlist(hold->enc,hold->enc_cnt)
  WITH nocounter
 ;end select
 CALL clear(24,1,60)
#2099_fill_hold_exit
#2100_query
 CALL clear(24,1)
 CALL video(b)
 CALL text(24,1,"Printing Report")
 CALL video(n)
 SELECT INTO value(printer)
  d.seq
  FROM (dummyt d  WITH seq = 1)
  PLAN (d)
  HEAD REPORT
   line = fillstring(108,"-")
  HEAD PAGE
   CALL center("*** DCP_CLEANUP_ORDERS REPORT ***",0,100), row + 1, col 0,
   curdate"mm/dd/yy;;d", " ", curtime"hh:mm;l;m",
   col 99, "Page: ", curpage"#####;l;i",
   row + 2, col 0, "Encntr ID",
   col 11, "Name", col 43,
   "Dischg", col 52, "Order ID",
   col 63, "Mnemonic", col 96,
   "Curr Start DT", row + 1, col 0,
   line, row + 1
  DETAIL
   FOR (ec = 1 TO hold->enc_cnt)
     FOR (oc = 1 TO hold->enc[ec].ord_cnt)
       col 0, hold->enc[ec].encntr_id"#########;rp0", col 11,
       hold->enc[ec].name, col 43, hold->enc[ec].disch_dt_tm"@SHORTDATE;;Q",
       col 52, hold->enc[ec].ord[oc].order_id"#########;rp0"
       IF ((hold->enc[ec].ord[oc].cont_order="Y"))
        col 62, "*"
       ENDIF
       col 63, hold->enc[ec].ord[oc].mnem, col 101,
       hold->enc[ec].ord[oc].curr_start_dt_tm"@SHORTDATE;;Q", row + 1
     ENDFOR
   ENDFOR
  FOOT REPORT
   row + 3,
   CALL center("*** End of Report ***",0,100)
  WITH nocounter
 ;end select
 CALL clear(24,1,60)
#2199_query_exit
#2200_clean
 CALL video(b)
 CALL text(24,1,"Canceling/Completing Orders")
 CALL video(n)
 FOR (vv = 1 TO hold->enc_cnt)
  FOR (oo = 1 TO hold->enc[vv].ord_cnt)
    IF ((hold->enc[vv].ord[oo].cont_order="Y"))
     UPDATE  FROM orders o
      SET o.order_status_cd = ostatus->discontinued_cd, o.dept_status_cd = dept_discontinued_cd, o
       .updt_dt_tm = cnvtdatetime(curdate,curtime3),
       o.updt_id = 99999999, o.last_action_sequence = (hold->enc[vv].ord[oo].last_action_sequence+ 1),
       o.updt_task = 0,
       o.updt_cnt = (o.updt_cnt+ 1)
      WHERE (o.order_id=hold->enc[vv].ord[oo].order_id)
      WITH nocounter
     ;end update
     DELETE  FROM eco_queue e
      WHERE (e.order_id=hold->enc[vv].ord[oo].order_id)
      WITH nocounter
     ;end delete
     INSERT  FROM order_action o
      SET o.order_id = hold->enc[vv].ord[oo].order_id, o.action_type_cd = discontinue_cd, o
       .action_personnel_id = system_prsnl_id,
       o.action_sequence = (hold->enc[vv].ord[oo].last_action_sequence+ 1), o.communication_type_cd
        = 0, o.action_rejected_ind = 0,
       o.order_conversation_id = 0, o.contributor_system_cd = 0, o.order_convs_seq = 0,
       o.order_locn_cd = 0, o.order_dt_tm = cnvtdatetime(curdate,curtime3), o.order_tz =
       curtimezoneapp,
       o.action_dt_tm = cnvtdatetime(curdate,curtime3), o.action_tz = curtimezoneapp, o
       .effective_dt_tm = cnvtdatetime(curdate,curtime3),
       o.effective_tz = curtimezoneapp, o.order_provider_id = 0, o.incomplete_order_ind = 0,
       o.order_status_cd = ostatus->discontinued_cd, o.dept_status_cd = dept_discontinued_cd, o
       .sch_state_cd = 0,
       o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = 99999999, o.updt_task = 0,
       o.updt_cnt = 0, o.updt_applctx = 0, o.order_app_nbr = 0,
       o.order_action_id = seq(order_seq,nextval), o.needs_verify_ind = 0, o.inactive_flag = 0,
       o.medstudent_action_ind = 0, o.clinical_display_line = null, o.order_detail_display_line =
       null
      WITH nocounter
     ;end insert
    ELSE
     IF (cleanup_type="CANCEL")
      UPDATE  FROM orders o
       SET o.order_status_cd = ostatus->canceled_cd, o.dept_status_cd = dept_canceled_cd, o
        .updt_dt_tm = cnvtdatetime(curdate,curtime3),
        o.updt_id = 99999999, o.last_action_sequence = (hold->enc[vv].ord[oo].last_action_sequence+ 1
        ), o.updt_task = 0,
        o.updt_cnt = (o.updt_cnt+ 1)
       WHERE (o.order_id=hold->enc[vv].ord[oo].order_id)
       WITH nocounter
      ;end update
      INSERT  FROM order_action o
       SET o.order_id = hold->enc[vv].ord[oo].order_id, o.action_type_cd = cancel_cd, o
        .action_personnel_id = system_prsnl_id,
        o.action_sequence = (hold->enc[vv].ord[oo].last_action_sequence+ 1), o.communication_type_cd
         = 0, o.action_rejected_ind = 0,
        o.order_conversation_id = 0, o.contributor_system_cd = 0, o.order_convs_seq = 0,
        o.order_locn_cd = 0, o.order_dt_tm = cnvtdatetime(curdate,curtime3), o.order_tz =
        curtimezoneapp,
        o.action_dt_tm = cnvtdatetime(curdate,curtime3), o.action_tz = curtimezoneapp, o
        .effective_dt_tm = cnvtdatetime(curdate,curtime3),
        o.effective_tz = curtimezoneapp, o.order_provider_id = 0, o.incomplete_order_ind = 0,
        o.order_status_cd = ostatus->canceled_cd, o.dept_status_cd = dept_canceled_cd, o.sch_state_cd
         = 0,
        o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = 99999999, o.updt_task = 0,
        o.updt_cnt = 0, o.updt_applctx = 0, o.order_app_nbr = 0,
        o.order_action_id = seq(order_seq,nextval), o.needs_verify_ind = 0, o.inactive_flag = 0,
        o.medstudent_action_ind = 0, o.clinical_display_line = null, o.order_detail_display_line =
        null
       WITH nocounter
      ;end insert
     ELSEIF (cleanup_type="COMPLETE")
      UPDATE  FROM orders o
       SET o.order_status_cd = ostatus->completed_cd, o.dept_status_cd = dept_completed_cd, o
        .updt_dt_tm = cnvtdatetime(curdate,curtime3),
        o.updt_id = 99999999, o.last_action_sequence = (hold->enc[vv].ord[oo].last_action_sequence+ 1
        ), o.updt_task = 0,
        o.updt_cnt = (o.updt_cnt+ 1)
       WHERE (o.order_id=hold->enc[vv].ord[oo].order_id)
       WITH nocounter
      ;end update
      INSERT  FROM order_action o
       SET o.order_id = hold->enc[vv].ord[oo].order_id, o.action_type_cd = complete_cd, o
        .action_personnel_id = system_prsnl_id,
        o.action_sequence = (hold->enc[vv].ord[oo].last_action_sequence+ 1), o.communication_type_cd
         = 0, o.action_rejected_ind = 0,
        o.order_conversation_id = 0, o.contributor_system_cd = 0, o.order_convs_seq = 0,
        o.order_locn_cd = 0, o.order_dt_tm = cnvtdatetime(curdate,curtime3), o.order_tz =
        curtimezoneapp,
        o.action_dt_tm = cnvtdatetime(curdate,curtime3), o.action_tz = curtimezoneapp, o
        .effective_dt_tm = cnvtdatetime(curdate,curtime3),
        o.effective_tz = curtimezoneapp, o.order_provider_id = 0, o.incomplete_order_ind = 0,
        o.order_status_cd = ostatus->completed_cd, o.dept_status_cd = dept_completed_cd, o
        .sch_state_cd = 0,
        o.updt_dt_tm = cnvtdatetime(curdate,curtime3), o.updt_id = 99999999, o.updt_task = 0,
        o.updt_cnt = 0, o.updt_applctx = 0, o.order_app_nbr = 0,
        o.order_action_id = seq(order_seq,nextval), o.needs_verify_ind = 0, o.inactive_flag = 0,
        o.medstudent_action_ind = 0, o.clinical_display_line = null, o.order_detail_display_line =
        null
       WITH nocounter
      ;end insert
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     FROM task_activity ta
     PLAN (ta
      WHERE (ta.order_id=hold->enc[vv].ord[oo].order_id)
       AND ta.task_status_cd IN (task_pending_cd, task_overdue_cd, task_inprocess_cd))
     HEAD REPORT
      task_info->task_cnt = 0
     DETAIL
      task_info->task_cnt = (task_info->task_cnt+ 1), tc = task_info->task_cnt
      IF (tc > size(task_info->task,5))
       stat = alterlist(task_info->task,tc)
      ENDIF
      task_info->task[tc].task_id = ta.task_id, task_info->task[tc].task_dt_tm = ta.task_dt_tm,
      task_info->task[tc].task_status_cd = ta.task_status_cd
     WITH nocounter
    ;end select
    FOR (tc = 1 TO task_info->task_cnt)
      IF ((task_info->task[tc].task_status_cd != 0))
       UPDATE  FROM task_activity ta
        SET ta.task_status_cd = task_cancel_cd, ta.updt_dt_tm = cnvtdatetime(curdate,curtime3), ta
         .updt_id = 99999999,
         ta.updt_task = 0, ta.updt_cnt = (ta.updt_cnt+ 1)
        WHERE (ta.task_id=task_info->task[tc].task_id)
        WITH nocounter
       ;end update
       SET task_info->task[tc].task_action_seq = 0
       SELECT INTO "nl:"
        FROM task_action tac
        WHERE (tac.task_id=task_info->task[tc].task_id)
        ORDER BY tac.task_action_seq DESC
        DETAIL
         task_info->task[tc].task_action_seq = tac.task_action_seq
        WITH maxqual(tac,1), nocounter
       ;end select
       INSERT  FROM task_action tac
        SET tac.task_id = task_info->task[tc].task_id, tac.task_action_seq = (task_info->task[tc].
         task_action_seq+ 1), tac.task_status_cd = task_cancel_cd,
         tac.task_dt_tm = cnvtdatetime(curdate,curtime3), tac.task_status_reason_cd = 0, tac
         .reschedule_reason_cd = 0,
         tac.updt_dt_tm = cnvtdatetime(curdate,curtime3), tac.updt_id = 99999999, tac.updt_task = 0,
         tac.updt_cnt = 0, tac.updt_applctx = 0
        WITH nocounter
       ;end insert
      ENDIF
    ENDFOR
    SET stat = alterlist(task_info->task,0)
    SET task_info->task_cnt = 0
  ENDFOR
  COMMIT
 ENDFOR
 CALL clear(24,1,60)
#2299_clean_exit
#9000_end
END GO
