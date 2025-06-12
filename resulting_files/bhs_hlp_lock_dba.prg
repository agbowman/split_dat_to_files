CREATE PROGRAM bhs_hlp_lock:dba
 EXECUTE bhs_hlp_err
 EXECUTE bhs_hlp_csv
 IF (validate(rl_debug_flag)=0)
  DECLARE rl_debug_flag = i4 WITH persistscript, constant(validate(bhs_debug_flag,0))
 ENDIF
 IF (validate(rs_lock_log)=0)
  DECLARE rs_lock_log = vc WITH persistscript, constant("bhscust:bhs_lock.log")
  DECLARE rl_lock_status_unknown = i4 WITH persistscript, constant(- (99))
  DECLARE rl_lock_success = i4 WITH persistscript, constant(1)
  DECLARE rl_lock_held_elsewhere = i4 WITH persistscript, constant(0)
  DECLARE rl_lock_error = i4 WITH persistscript, constant(- (1))
  DECLARE rl_lock_does_not_exist = i4 WITH persistscript, constant(- (2))
 ENDIF
 IF (rl_debug_flag >= 10)
  CALL echo(concat(curprog," helper script executed."))
  IF (rl_debug_flag >= 50)
   CALL echo("  Subroutine bhs_lock        declared.")
   CALL echo("  Subroutine bhs_last_locked declared.")
  ENDIF
 ENDIF
 DECLARE bhs_lock(p_domain=vc,p_name=vc,p_assert_ind=i2,p_wait_cnt=i4,p_status_flag=i4(ref)) = i2
 WITH persistscript
 SUBROUTINE bhs_lock(p_domain,p_name,p_assert_ind,p_wait_cnt,p_status_flag)
   DECLARE ml_loop_cnt = i4 WITH protect, noconstant(0)
   DECLARE ml_info_char = vc WITH protect, constant(concat("BHS LOCK -- See ",rs_lock_log,
     " for lock log."))
   SET p_status_flag = bhs_lock_helper(p_domain,p_name,0)
   IF (rl_debug_flag >= 70)
    CALL echo(concat("bhs_lock status after initial lock helper: ",build(p_status_flag)))
   ENDIF
   IF (p_status_flag=rl_lock_does_not_exist
    AND p_assert_ind > 0)
    IF (rl_debug_flag >= 70)
     CALL echo(concat("Lock does not exist for Domain[",p_domain,"] Name[",p_name,"].  Inserting...")
      )
    ENDIF
    INSERT  FROM dm_info di
     SET di.info_domain = p_domain, di.info_name = p_name, di.info_date = sysdate,
      di.info_char = ml_info_char, di.info_number = 0, di.info_long_id = 0,
      di.updt_applctx = validate(reqinfo->updt_applctx,0), di.updt_dt_tm = cnvtdatetime(curdate,
       curtime3), di.updt_cnt = 0,
      di.updt_id = validate(reqinfo->updt_id,0), di.updt_task = validate(reqinfo->updt_task,0), di
      .info_domain_id = 0
     WITH nocounter
    ;end insert
    IF (bhs_error_thrown(0)=1)
     ROLLBACK
     SET p_status_flag = rl_lock_does_not_exist
    ELSE
     COMMIT
     SET p_status_flag = bhs_lock_helper(p_domain,p_name,0)
     IF (rl_debug_flag >= 70)
      CALL echo(concat("bhs_lock status after lock helper post-insert: ",build(p_status_flag)))
     ENDIF
    ENDIF
   ENDIF
   IF (p_status_flag=rl_lock_held_elsewhere
    AND p_wait_cnt > 0)
    FOR (ml_loop_cnt = 1 TO p_wait_cnt)
      IF (rl_debug_flag >= 60)
       CALL echo(concat("Attempting to gain lock with wait.  Attempt [",build(ml_loop_cnt),"/",build(
          p_wait_cnt),"] for Domain[",
         p_domain,"] Name[",p_name,"]"))
      ENDIF
      SET p_status_flag = bhs_lock_helper(p_domain,p_name,1)
      IF (rl_debug_flag >= 70)
       CALL echo(concat("bhs_lock status after lock helper with wait: ",build(p_status_flag)))
      ENDIF
      IF (p_status_flag != rl_lock_held_elsewhere)
       CALL echo(concat("BHS Lock timeout [",build(ml_loop_cnt),"/",build(p_wait_cnt),"]"))
      ELSE
       SET ml_loop_cnt = p_wait_cnt
      ENDIF
    ENDFOR
   ENDIF
   SET stat = bhs_lock_log_helper(p_domain,p_name,p_status_flag)
   SET stat = bhs_clear_error(0)
   IF (p_status_flag=rl_lock_success)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 DECLARE bhs_last_locked(p_domain=vc,p_name=vc,p_status=i4,p_log_line=vc(ref)) = i2 WITH
 persistscript
 SUBROUTINE bhs_last_locked(p_domain,p_name,p_status,p_log_line)
   IF (findfile(rs_lock_log,2)=0)
    RETURN(0)
   ENDIF
   DECLARE mn_log_found = i2 WITH protect, noconstant(0)
   DECLARE ms_tempstr = vc WITH protect, noconstant(" ")
   FREE DEFINE rtl2
   DEFINE rtl2 rs_lock_log
   SELECT INTO "nl:"
    FROM rtl2t r
    WHERE r.line > " "
     AND r.line != "Date,Status,Lock_Domain,Lock_Name,Owner_Name,Owner_Prog,Owner_Node*"
    DETAIL
     IF (getcsvcolumnatindex(r.line,2,ms_tempstr,",",'"')=1)
      IF (build(ms_tempstr)=p_status)
       IF (getcsvcolumnatindex(r.line,3,ms_tempstr,",",'"')=1)
        IF (build(ms_tempstr)=p_domain)
         IF (getcsvcolumnatindex(r.line,4,ms_tempstr,",",'"')=1)
          IF (build(ms_tempstr)=p_name)
           p_log_line = ms_tempstr
          ENDIF
         ENDIF
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    WITH nocounter
   ;end select
   IF (bhs_error_thrown(0)=1)
    IF (rl_debug_flag >= 50)
     CALL echo(concat("Error encountered while checking lock log file entry for Domain[",p_domain,
       "] Name[",p_name,"]"))
    ENDIF
    RETURN(0)
   ENDIF
   IF (mn_log_found=0)
    IF (rl_debug_flag >= 50)
     CALL echo(concat("Lock log file entry NOT found for Domain[",p_domain,"] Name[",p_name,"]"))
    ENDIF
    RETURN(0)
   ENDIF
   IF (rl_debug_flag >= 50)
    CALL echo(concat("Lock log file entry found for Domain[",p_domain,"] Name[",p_name,"]"))
    CALL echo(p_log_line)
   ENDIF
   RETURN(1)
 END ;Subroutine
 DECLARE bhs_lock_helper(p_domain=vc,p_name=vc,p_wait_ind=i2) = i4 WITH persistscript
 SUBROUTINE bhs_lock_helper(p_domain,p_name,p_wait_ind)
   DECLARE ms_error_54 = vc WITH protect, constant("ORA-00054")
   DECLARE ms_error_2049 = vc WITH protect, constant("ORA-02049")
   DECLARE ms_errtxt = vc WITH protect, noconstant(" ")
   DECLARE ml_lock_curqual = i4 WITH protect, noconstant(0)
   SELECT
    IF (p_wait_ind=1)
     WITH nocounter, forupdatewait(di)
    ELSE
     WITH nocounter, forupdate(di)
    ENDIF
    INTO "nl:"
    FROM dm_info di
    PLAN (di
     WHERE di.info_domain=p_domain
      AND di.info_name=p_name)
    WITH nocounter
   ;end select
   SET ml_lock_curqual = curqual
   IF (bhs_error_thrown(0)=1)
    SET stat = bhs_get_error(1,ms_errtxt)
    IF (((findstring(ms_error_54,ms_errtxt) > 0) OR (findstring(ms_error_2049,ms_errtxt) > 0)) )
     RETURN(rl_lock_held_elsewhere)
    ELSE
     RETURN(rl_lock_error)
    ENDIF
   ENDIF
   IF (ml_lock_curqual > 0)
    RETURN(rl_lock_success)
   ELSE
    RETURN(rl_lock_does_not_exist)
   ENDIF
 END ;Subroutine
 DECLARE bhs_lock_log_helper(p_domain=vc,p_name=vc,p_status_flag=i4) = i2 WITH persistscript
 SUBROUTINE bhs_lock_log_helper(p_domain,p_name,p_status_flag)
   IF (findfile(rs_lock_log,2)=0)
    SELECT INTO value(rs_lock_log)
     FROM (dummyt d  WITH seq = 1)
     DETAIL
      ms_line = "Date,Status,Lock_Domain,Lock_Name,Owner_Name,Owner_Prog,Owner_Node", row 0, col 0,
      ms_line
     WITH nocounter, format = variable, formfeed = none,
      maxcol = 500
    ;end select
   ENDIF
   SELECT INTO value(rs_lock_log)
    FROM (dummyt d  WITH seq = 1)
    DETAIL
     ms_line = build(format(cnvtdatetime(curdate,curtime3),"YYYYMMDDHHMMSS;;D"),",",build(
       p_status_flag),",",'"',
      p_domain,'"',",",'"',p_name,
      '"',",",curuser,",",curprog,
      ",",curnode), row 0, col 0,
     ms_line
    WITH nocounter, append, format = variable,
     formfeed = none, maxcol = 500
   ;end select
   IF (bhs_error_thrown(0)=1)
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
END GO
