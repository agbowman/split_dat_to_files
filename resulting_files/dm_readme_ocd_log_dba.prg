CREATE PROGRAM dm_readme_ocd_log:dba
 DECLARE dipr_setup_install_itinerary(dsit_plan_id=f8,dsit_plan_type=vc) = i2
 DECLARE dipr_add_itin_step(dais_mode=vc,dais_level=i2,dais_step_nbr=i2,dais_step_name=vc,
  dais_itin_key=vc) = i2
 DECLARE dipr_get_install_itinerary(dgit_plan_id=f8) = i2
 DECLARE dipr_update_install_itinerary(duit_status=i2,duit_itin_id=f8,duit_plan_id=f8) = i2
 DECLARE dipr_get_cur_dpe_data(dgcdd_install_plan=f8) = i2
 DECLARE dipr_get_plan_nbr(null) = i2
 DECLARE dipr_disp_error_msg(null) = i2
 IF ((validate(dip_itin_rs->itin_cnt,- (1))=- (1))
  AND (validate(dip_itin_rs->itin_cnt,- (2))=- (2)))
  FREE RECORD dip_itin_rs
  RECORD dip_itin_rs(
    1 install_plan_id = f8
    1 itin_cnt = i4
    1 itin_step[*]
      2 dm_process_event_id = f8
      2 event_status = vc
      2 begin_dt_tm = dq8
      2 end_dt_tm = dq8
      2 message_txt = vc
      2 itinerary_key = vc
      2 install_mode = vc
      2 level_number = i2
      2 step_number = i4
      2 step_name = vc
      2 parent_step_name = vc
      2 parent_level_number = i2
  )
 ENDIF
 IF ((validate(dipm_misc_data->install_plan_id,- (1))=- (1))
  AND (validate(dipm_misc_data->install_plan_id,- (2))=- (2)))
  FREE RECORD dipm_misc_data
  RECORD dipm_misc_data(
    1 install_plan_id = f8
    1 cur_dpe_id = f8
    1 cur_mode = vc
    1 cur_itin_dpe_id = f8
    1 cur_appl_id = f8
    1 cur_method = vc
    1 cur_dpe_status = vc
    1 cur_install_event = vc
  )
  SET dipm_misc_data->install_plan_id = 0.0
  SET dipm_misc_data->cur_dpe_id = 0.0
  SET dipm_misc_data->cur_mode = "DM2NOTSET"
  SET dipm_misc_data->cur_itin_dpe_id = 0.0
  SET dipm_misc_data->cur_appl_id = 0.0
  SET dipm_misc_data->cur_method = "DM2NOTSET"
  SET dipm_misc_data->cur_dpe_status = "DM2NOTSET"
  SET dipm_misc_data->cur_install_event = "DM2NOTSET"
 ENDIF
 SUBROUTINE dipr_update_install_itinerary(duit_status,duit_itin_id,duit_plan_id)
   DECLARE duit_msg = vc WITH protect, noconstant("")
   DECLARE duit_optimizer_hint = vc WITH protect, noconstant("")
   SET duit_optimizer_hint = concat(" LEADING(DP DPE)","INDEX(DP XAK1DM_PROCESS)",
    "INDEX(DPE XIE1DM_PROCESS_EVENT)")
   CASE (duit_status)
    OF 2:
     SET duit_msg = "PAUSED"
    OF 0:
     SET duit_msg = "STOPPED"
    OF 1:
     SET duit_msg = "EXECUTING"
   ENDCASE
   IF (duit_itin_id=0)
    SET dm_err->eproc = "Update itinerary status"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    UPDATE  FROM dm_process_event dpe1
     SET dpe1.event_status = duit_msg, dpe1.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE dpe1.dm_process_event_id IN (
     (SELECT
      dpe.dm_process_event_id
      FROM dm_process dp,
       dm_process_event dpe
      WHERE dp.dm_process_id=dpe.dm_process_id
       AND dp.process_name=dpl_package_install
       AND dp.action_type=dpl_itinerary_event
       AND dpe.install_plan_id=duit_plan_id
       AND  NOT (dpe.event_status IN (dpl_failed, dpl_complete, dpl_success, dpl_failure))
       AND ((dpe.begin_dt_tm > cnvtdatetime("01-JAN-1900")) OR (dpe.begin_dt_tm = null))
      WITH orahintcbo(value(duit_optimizer_hint))))
      AND dpe1.event_status != duit_msg
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ELSE
    SET dm_err->eproc = "Update itinerary status for event_id"
    IF ((dm_err->debug_flag > 0))
     CALL disp_msg("",dm_err->logfile,0)
    ENDIF
    UPDATE  FROM dm_process_event dpe
     SET dpe.event_status = duit_msg, dpe.updt_dt_tm = cnvtdatetime(curdate,curtime3)
     WHERE dpe.dm_process_event_id=duit_itin_id
      AND dpe.event_status != duit_msg
     WITH nocounter
    ;end update
    IF (check_error(dm_err->eproc)=1)
     CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
     ROLLBACK
     RETURN(0)
    ELSE
     COMMIT
    ENDIF
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dipr_setup_install_itinerary(dsit_plan_id,dsit_plan_type)
   DECLARE dsit_cnt = i4 WITH protect, noconstant(0)
   DECLARE dsit_ndx = i4 WITH protect, noconstant(0)
   SET dip_itin_rs->itin_cnt = 0
   SET stat = alterlist(dip_itin_rs->itin_step,dip_itin_rs->itin_cnt)
   SET dip_itin_rs->install_plan_id = dsit_plan_id
   SET stat = alterlist(dip_itin_rs->itin_step,9)
   CALL dipr_add_itin_step("BATCHUP",1,1,"Setup","BATCHUP:SETUP")
   CALL dipr_add_itin_step("BATCHUP",1,2,"Code Sets","BATCHUP:CODE_SETS")
   CALL dipr_add_itin_step("BATCHUP",1,3,"Pre-Schema Readmes","BATCHUP:PRE-SCHEMA_READMES")
   CALL dipr_add_itin_step("BATCHUP",1,4,"Schema","BATCHUP:SCHEMA")
   CALL dipr_add_itin_step("BATCHUP",1,5,"Application / Task / Request (ATRs)","BATCHUP:ATRS")
   CALL dipr_add_itin_step("BATCHUP",1,6,"Purge Templates","BATCHUP:PURGE_TEMPLATES")
   CALL dipr_add_itin_step("BATCHUP",1,7,"Post-Schema Readmes","BATCHUP:POST-SCHEMA_READMES")
   IF (dsit_plan_type="NO-DT")
    CALL dipr_add_itin_step("BATCHPRECYCLE",1,2,"Readmes","BATCHPRECYCLE:READMES")
   ENDIF
   IF (dsit_plan_type != "NO-DT")
    CALL dipr_add_itin_step("BATCHDOWN",1,2,"Readmes","BATCHDOWN:READMES")
   ENDIF
   CALL dipr_add_itin_step("BATCHPOST",1,2,"Readmes","BATCHPOST:READMES")
   SET dm_err->eproc = "Query for itinerary information"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_process dp,
     dm_process_event dpe,
     dm_process_event_dtl dped
    WHERE dp.process_name=dpl_package_install
     AND dp.action_type=dpl_itinerary_event
     AND dpe.dm_process_id=dp.dm_process_id
     AND (dpe.install_plan_id=dip_itin_rs->install_plan_id)
     AND dped.dm_process_event_id=dpe.dm_process_event_id
     AND dped.detail_type="ITINERARY_KEY"
    DETAIL
     dsit_ndx = locateval(dsit_ndx,1,dip_itin_rs->itin_cnt,dped.detail_text,dip_itin_rs->itin_step[
      dsit_ndx].itinerary_key)
     IF (dsit_ndx > 0)
      dip_itin_rs->itin_step[dsit_ndx].dm_process_event_id = dpe.dm_process_event_id
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dip_itin_rs)
   ENDIF
   FOR (dsit_cnt = 1 TO dip_itin_rs->itin_cnt)
     IF ((dip_itin_rs->itin_step[dsit_cnt].dm_process_event_id=0))
      SET dm2_process_event_rs->begin_dt_tm = cnvtdatetime("01-JAN-1900")
      SET dm2_process_event_rs->end_dt_tm = cnvtdatetime("01-JAN-1900")
      SET dm2_process_event_rs->install_plan_id = dsit_plan_id
      CALL dm2_process_log_add_detail_text("ITINERARY_KEY",dip_itin_rs->itin_step[dsit_cnt].
       itinerary_key)
      CALL dm2_process_log_add_detail_text("INSTALL_MODE",dip_itin_rs->itin_step[dsit_cnt].
       install_mode)
      CALL dm2_process_log_add_detail_text("STEP_NAME",dip_itin_rs->itin_step[dsit_cnt].step_name)
      CALL dm2_process_log_add_detail_number("STEP_NUMBER",cnvtreal(dip_itin_rs->itin_step[dsit_cnt].
        step_number))
      CALL dm2_process_log_add_detail_number("LEVEL_NUMBER",cnvtreal(dip_itin_rs->itin_step[dsit_cnt]
        .level_number))
      IF (dm2_process_log_row(dpl_package_install,dpl_itinerary_event,dpl_no_prev_id,1)=0)
       RETURN(0)
      ENDIF
      SET dip_itin_rs->itin_step[dsit_cnt].dm_process_event_id = dm2_process_event_rs->
      dm_process_event_id
     ENDIF
   ENDFOR
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dip_itin_rs)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dipr_add_itin_step(dais_mode,dais_level,dais_step_nbr,dais_step_name,dais_itin_key)
   SET dip_itin_rs->itin_cnt = (dip_itin_rs->itin_cnt+ 1)
   SET stat = alterlist(dip_itin_rs->itin_step,dip_itin_rs->itin_cnt)
   SET dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].install_mode = dais_mode
   SET dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].level_number = dais_level
   SET dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].step_number = dais_step_nbr
   SET dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].step_name = dais_step_name
   SET dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].itinerary_key = dais_itin_key
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dipr_get_install_itinerary(dgit_plan_id)
   SET dip_itin_rs->install_plan_id = dgit_plan_id
   SET dm_err->eproc = "Load itinerary data from process tables"
   IF ((dm_err->debug_flag > 0))
    CALL disp_msg("",dm_err->logfile,0)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_process dp,
     dm_process_event dpe,
     dm_process_event_dtl dped
    WHERE dp.dm_process_id=dpe.dm_process_id
     AND dp.process_name=dpl_package_install
     AND dp.action_type=dpl_itinerary_event
     AND (dpe.install_plan_id=dip_itin_rs->install_plan_id)
     AND dpe.dm_process_event_id=dped.dm_process_event_id
    ORDER BY dpe.dm_process_event_id, dped.detail_type
    HEAD REPORT
     dip_itin_rs->itin_cnt = 0
    HEAD dpe.dm_process_event_id
     dip_itin_rs->itin_cnt = (dip_itin_rs->itin_cnt+ 1), stat = alterlist(dip_itin_rs->itin_step,
      dip_itin_rs->itin_cnt), dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].dm_process_event_id = dpe
     .dm_process_event_id
    DETAIL
     CASE (dped.detail_type)
      OF dpl_install_mode:
       dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].install_mode = dped.detail_text,
       IF (cnvtdatetime(dpe.begin_dt_tm) > cnvtdatetime("01-JAN-1900"))
        dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].begin_dt_tm = cnvtdatetime(dpe.begin_dt_tm)
       ENDIF
       ,
       IF (cnvtdatetime(dpe.end_dt_tm) > cnvtdatetime("01-JAN-1900"))
        dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].end_dt_tm = cnvtdatetime(dpe.end_dt_tm)
       ENDIF
       ,dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].event_status = dpe.event_status
      OF dpl_itinerary_key:
       dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].itinerary_key = dped.detail_text
      OF dpl_step_number:
       dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].step_number = dped.detail_number
      OF dpl_level:
       dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].level_number = dped.detail_number
      OF dpl_step_name:
       dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].step_name = dped.detail_text
      OF dpl_parent_step_name:
       dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].parent_step_name = dped.detail_text
      OF dpl_parent_level_number:
       dip_itin_rs->itin_step[dip_itin_rs->itin_cnt].parent_level_number = dped.detail_number
     ENDCASE
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL disp_msg(dm_err->emsg,dm_err->logfile,1)
    RETURN(0)
   ENDIF
   IF ((dm_err->debug_flag > 0))
    CALL echorecord(dip_itin_rs)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dipr_get_plan_nbr(null)
   DECLARE dgpn_continue = i2 WITH protect, noconstant(1)
   DECLARE dgpn_invalid = i2 WITH protect, noconstant(0)
   DECLARE dgpn_notfound = i2 WITH protect, noconstant(0)
   SET dm_err->eproc = "Obtaining Plan ID"
   WHILE (dgpn_continue=1)
     SET message = window
     CALL clear(1,1)
     CALL box(1,1,3,132)
     CALL text(2,2,"INSTALL PLAN MENU [GET PLAN]")
     IF (dgpn_invalid=1)
      CALL text(4,2,concat(drr_flex_sched->pkg_number," is an Invalid Plan ID. Please Retry."))
      SET dgpn_invalid = 0
     ELSEIF (dgpn_notfound=1)
      CALL text(4,2,concat("Install activity not found for Install Plan Number: ",drr_flex_sched->
        pkg_number,". Please Retry"))
      SET dgpn_notfound = 0
     ENDIF
     CALL text(5,2,"Install Plan ID: ")
     SET help = pos(5,50,10,60)
     SET help =
     SELECT DISTINCT INTO "nl:"
      plan_id = install_plan_id
      FROM dm_install_plan
      ORDER BY install_plan_id DESC
      WITH nocounter
     ;end select
     CALL accept(5,20,"9(11);F")
     SET drr_flex_sched->pkg_number = cnvtstring(abs(curaccept))
     CALL text(7,2,"(C)ontinue, (M)odify, (B)ack :")
     CALL accept(7,34,"p;cu","C"
      WHERE curaccept IN ("C", "M", "B"))
     SET message = nowindow
     CASE (curaccept)
      OF "B":
       SET dm_err->emsg = "Plan ID was not provided"
       SET dm_err->err_ind = 1
       SET dgpn_continue = 0
      OF "C":
       CALL text(8,2,"Validating Install Plan...")
       SET dm_err->eproc = "Verifying that Install Plan ID exists"
       SELECT INTO "nl:"
        FROM dm_install_plan dip
        WHERE dip.install_plan_id=cnvtreal(drr_flex_sched->pkg_number)
        WITH nocounter, maxqual(dip,1)
       ;end select
       IF (check_error(dm_err->eproc)=1)
        CALL dipr_disp_error_msg(null)
        RETURN(0)
       ENDIF
       IF (curqual=0)
        SET dgpn_invalid = 1
       ELSE
        SET dm_err->eproc = "Verifying that Install Plan ID has current activity"
        SELECT INTO "nl:"
         FROM dm_process dp,
          dm_process_event dpe
         PLAN (dp
          WHERE dp.process_name=value(dpl_package_install)
           AND dp.action_type=value(dpl_execution)
           AND dp.program_name="DM2_INSTALL_PKG")
          JOIN (dpe
          WHERE dp.dm_process_id=dpe.dm_process_id
           AND dpe.install_plan_id=cnvtreal(drr_flex_sched->pkg_number))
         WITH nocounter
        ;end select
        IF (check_error(dm_err->eproc)=1)
         CALL dipr_disp_error_msg(null)
         RETURN(0)
        ENDIF
        IF (curqual > 0)
         SET dgpn_continue = 0
        ELSE
         SET dgpn_notfound = 1
        ENDIF
       ENDIF
      OF "M":
       SET dgpn_continue = 1
     ENDCASE
   ENDWHILE
   SET dipm_misc_data->install_plan_id = cnvtreal(drr_flex_sched->pkg_number)
   IF (check_error(dm_err->eproc)=1)
    CALL dipr_disp_error_msg(null)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 SUBROUTINE dipr_disp_error_msg(null)
   SET message = nowindow
   CALL disp_msg(dm_err->emsg,dm_err->logfile,dm_err->err_ind)
   RETURN(null)
 END ;Subroutine
 SUBROUTINE dipr_get_cur_dpe_data(dgcdd_install)
   SET dipm_misc_data->cur_mode = "DM2NOTSET"
   SET dm_err->eproc = "Retrieving most recent dm_process_event row for package install execution"
   IF ((dm_err->debug_flag > 0))
    CALL dipr_disp_error_msg(null)
   ENDIF
   SELECT INTO "nl:"
    FROM dm_process dp,
     dm_process_event dpe,
     dm_process_event_dtl dped
    PLAN (dpe
     WHERE dpe.install_plan_id=dgcdd_install)
     JOIN (dp
     WHERE dpe.dm_process_id=dp.dm_process_id
      AND dp.process_name=value(dpl_package_install)
      AND dp.action_type=value(dpl_execution)
      AND dp.program_name="DM2_INSTALL_PKG")
     JOIN (dped
     WHERE dpe.dm_process_event_id=dped.dm_process_event_id
      AND dped.detail_type=value(dpl_install_mode))
    ORDER BY dpe.begin_dt_tm DESC
    HEAD REPORT
     cur_dpe_set = 0
    DETAIL
     IF (cur_dpe_set=0)
      IF (cnvtupper(trim(dped.detail_text)) != "BATCHPREVIEW")
       cur_dpe_set = 1
      ENDIF
      IF (cnvtupper(dipm_misc_data->cur_mode) != cnvtupper(trim(dped.detail_text)))
       dipm_misc_data->cur_dpe_id = dpe.dm_process_event_id, dir_ui_misc->dm_process_event_id = dpe
       .dm_process_event_id, dipm_misc_data->cur_dpe_status = dpe.event_status,
       dipm_misc_data->cur_mode = cnvtupper(trim(dped.detail_text))
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (check_error(dm_err->eproc)=1)
    CALL dipr_disp_error_msg(null)
    RETURN(0)
   ENDIF
   IF (curqual=0)
    SET dm_err->emsg = "Unable to retrieve current package install execution"
    SET dm_err->err_ind = 1
    CALL dipr_disp_error_msg(null)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
 EXECUTE FROM 1000_initialize TO 1999_initialize_exit
 EXECUTE FROM 2000_report TO 2999_report_exit
 GO TO 9999_exit_program
#1000_initialize
 SET mode = 1
 SET ocd = 0
 SET ocd =  $1
 IF ((dipm_misc_data->install_plan_id=0.0))
  SET dipm_misc_data->install_plan_id = abs(ocd)
 ENDIF
#1999_initialize_exit
#2000_report
 EXECUTE dm_readme_log
#2999_report_exit
#9999_exit_program
END GO
