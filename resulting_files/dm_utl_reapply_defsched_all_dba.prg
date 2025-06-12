CREATE PROGRAM dm_utl_reapply_defsched_all:dba
 IF (validate(action_none,- (1)) != 0)
  DECLARE action_none = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(action_add,- (1)) != 1)
  DECLARE action_add = i2 WITH protect, noconstant(1)
 ENDIF
 IF (validate(action_chg,- (1)) != 2)
  DECLARE action_chg = i2 WITH protect, noconstant(2)
 ENDIF
 IF (validate(action_del,- (1)) != 3)
  DECLARE action_del = i2 WITH protect, noconstant(3)
 ENDIF
 IF (validate(action_get,- (1)) != 4)
  DECLARE action_get = i2 WITH protect, noconstant(4)
 ENDIF
 IF (validate(action_ina,- (1)) != 5)
  DECLARE action_ina = i2 WITH protect, noconstant(5)
 ENDIF
 IF (validate(action_act,- (1)) != 6)
  DECLARE action_act = i2 WITH protect, noconstant(6)
 ENDIF
 IF (validate(action_temp,- (1)) != 999)
  DECLARE action_temp = i2 WITH protect, noconstant(999)
 ENDIF
 IF (validate(true,- (1)) != 1)
  DECLARE true = i2 WITH protect, noconstant(1)
 ENDIF
 IF (validate(false,- (1)) != 0)
  DECLARE false = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(gen_nbr_error,- (1)) != 3)
  DECLARE gen_nbr_error = i2 WITH protect, noconstant(3)
 ENDIF
 IF (validate(insert_error,- (1)) != 4)
  DECLARE insert_error = i2 WITH protect, noconstant(4)
 ENDIF
 IF (validate(update_error,- (1)) != 5)
  DECLARE update_error = i2 WITH protect, noconstant(5)
 ENDIF
 IF (validate(replace_error,- (1)) != 6)
  DECLARE replace_error = i2 WITH protect, noconstant(6)
 ENDIF
 IF (validate(delete_error,- (1)) != 7)
  DECLARE delete_error = i2 WITH protect, noconstant(7)
 ENDIF
 IF (validate(undelete_error,- (1)) != 8)
  DECLARE undelete_error = i2 WITH protect, noconstant(8)
 ENDIF
 IF (validate(remove_error,- (1)) != 9)
  DECLARE remove_error = i2 WITH protect, noconstant(9)
 ENDIF
 IF (validate(attribute_error,- (1)) != 10)
  DECLARE attribute_error = i2 WITH protect, noconstant(10)
 ENDIF
 IF (validate(lock_error,- (1)) != 11)
  DECLARE lock_error = i2 WITH protect, noconstant(11)
 ENDIF
 IF (validate(none_found,- (1)) != 12)
  DECLARE none_found = i2 WITH protect, noconstant(12)
 ENDIF
 IF (validate(select_error,- (1)) != 13)
  DECLARE select_error = i2 WITH protect, noconstant(13)
 ENDIF
 IF (validate(update_cnt_error,- (1)) != 14)
  DECLARE update_cnt_error = i2 WITH protect, noconstant(14)
 ENDIF
 IF (validate(not_found,- (1)) != 15)
  DECLARE not_found = i2 WITH protect, noconstant(15)
 ENDIF
 IF (validate(version_insert_error,- (1)) != 16)
  DECLARE version_insert_error = i2 WITH protect, noconstant(16)
 ENDIF
 IF (validate(inactivate_error,- (1)) != 17)
  DECLARE inactivate_error = i2 WITH protect, noconstant(17)
 ENDIF
 IF (validate(activate_error,- (1)) != 18)
  DECLARE activate_error = i2 WITH protect, noconstant(18)
 ENDIF
 IF (validate(version_delete_error,- (1)) != 19)
  DECLARE version_delete_error = i2 WITH protect, noconstant(19)
 ENDIF
 IF (validate(uar_error,- (1)) != 20)
  DECLARE uar_error = i2 WITH protect, noconstant(20)
 ENDIF
 IF (validate(duplicate_error,- (1)) != 21)
  DECLARE duplicate_error = i2 WITH protect, noconstant(21)
 ENDIF
 IF (validate(ccl_error,- (1)) != 22)
  DECLARE ccl_error = i2 WITH protect, noconstant(22)
 ENDIF
 IF (validate(execute_error,- (1)) != 23)
  DECLARE execute_error = i2 WITH protect, noconstant(23)
 ENDIF
 IF (validate(failed,- (1)) != 0)
  DECLARE failed = i2 WITH protect, noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH protect, noconstant("")
 ELSE
  SET table_name = fillstring(100," ")
 ENDIF
 IF (validate(call_echo_ind,- (1)) != 0)
  DECLARE call_echo_ind = i2 WITH protect, noconstant(false)
 ENDIF
 IF (validate(i_version,- (1)) != 0)
  DECLARE i_version = i2 WITH protect, noconstant(0)
 ENDIF
 IF (validate(program_name,"ZZZ")="ZZZ")
  DECLARE program_name = vc WITH protect, noconstant(fillstring(30," "))
 ENDIF
 IF (validate(sch_security_id,- (1)) != 0)
  DECLARE sch_security_id = f8 WITH protect, noconstant(0.0)
 ENDIF
 IF (validate(last_mod,"NOMOD")="NOMOD")
  DECLARE last_mod = c5 WITH private, noconstant("")
 ENDIF
 DECLARE loadcodevalue(code_set=i4,cdf_meaning=vc,option_flag=i2) = f8
 DECLARE s_cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE s_code_value = f8 WITH public, noconstant(0.0)
 SUBROUTINE loadcodevalue(code_set,cdf_meaning,option_flag)
   SET s_cdf_meaning = cdf_meaning
   SET s_code_value = 0.0
   SELECT INTO "nl:"
    c.code_value
    FROM code_value c
    WHERE c.code_set=code_set
     AND c.cdf_meaning=s_cdf_meaning
     AND c.active_ind=1
     AND c.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND c.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    DETAIL
     s_code_value = c.code_value
    WITH nocounter
   ;end select
   IF (s_code_value <= 0.0)
    SET s_code_value = 0.0
    CASE (option_flag)
     OF 0:
      SET table_name = build("ERROR-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(table_name)
      SET failed = uar_error
      GO TO exit_script
     OF 1:
      SET table_name = build("INFO-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
       '"',",",option_flag,") not found, CURPROG [",curprog,
       "]")
      CALL echo(table_name)
    ENDCASE
   ELSE
    CALL echo(build("SUCCESS-->loadcodevalue (",code_set,",",'"',s_cdf_meaning,
      '"',",",option_flag,") CODE_VALUE [",s_code_value,
      "]"))
   ENDIF
   RETURN(s_code_value)
 END ;Subroutine
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual_cnt = i4
    1 qual[*]
      2 frequency_id = f8
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->qual_cnt = 0
 SET stat = alterlist(reply->qual,reply->qual_cnt)
 SET failed = false
 SET table_name = curprog
 SET reply->status_data.status = "F"
 DECLARE error_msg = vc WITH protect, noconstant(" ")
 DECLARE num_of_days = i4 WITH protect, noconstant(cnvtint( $1))
 DECLARE system_range_day = i4 WITH protect, noconstant(0)
 DECLARE t_23003_active_cd = f8 WITH protect, constant(loadcodevalue(23003,"ACTIVE",0))
 DECLARE t_23002_defsched_cd = f8 WITH protect, constant(loadcodevalue(23002,"DEFSCHED",0))
 DECLARE t_23010_defrange_type_cd = f8 WITH protect, constant(loadcodevalue(23010,"DEFRANGE",0))
 SELECT INTO "nl:"
  a.pref_id
  FROM sch_pref a
  PLAN (a
   WHERE a.pref_type_cd=t_23010_defrange_type_cd
    AND a.parent_table="SYSTEM"
    AND a.parent_id=0
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  DETAIL
   system_range_day = (a.pref_value/ 1440)
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("System DEFRANGE not defined...")
  GO TO exit_script
 ENDIF
 CALL echo(build("num_of_days = ",num_of_days))
 CALL echo(build("system_range_day = ",system_range_day))
 IF (num_of_days >= 0
  AND num_of_days <= system_range_day)
  SELECT INTO "nl:"
   a.appt_def_id
   FROM sch_appt_def a
   PLAN (a
    WHERE a.appt_def_id > 0)
   WITH nocounter, maxqual(a,1)
  ;end select
  IF (curqual > 0)
   CALL echo(
    "non-zero rows exist in table sch_appt_def, this script should be executed after activity delete..."
    )
   GO TO exit_script
  ENDIF
 ELSEIF ((num_of_days=- (100)))
  SET num_of_days = 0
 ELSE
  CALL echo("Invalid Number of Days...")
  CALL echo("It should be greater or equal to 0 and within the system default range")
  GO TO exit_script
 ENDIF
 SELECT DISTINCT INTO "nl:"
  c.frequency_id
  FROM sch_apply_list a,
   sch_def_apply b,
   sch_freq c
  PLAN (a
   WHERE a.def_beg_dt_tm > cnvtdatetime(curdate,0000)
    AND a.slot_state_meaning != "REMOVED"
    AND ((a.def_apply_id+ 0) > 0)
    AND a.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (b
   WHERE b.def_apply_id=a.def_apply_id
    AND ((b.frequency_id+ 0) > 0)
    AND b.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
   JOIN (c
   WHERE c.frequency_id=b.frequency_id
    AND c.freq_state_meaning="COMPLETE"
    AND c.freq_type_meaning="DEFSCHED"
    AND c.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  DETAIL
   reply->qual_cnt = (reply->qual_cnt+ 1)
   IF (mod(reply->qual_cnt,100)=1)
    stat = alterlist(reply->qual,(reply->qual_cnt+ 99))
   ENDIF
   reply->qual[reply->qual_cnt].frequency_id = c.frequency_id
  WITH nocounter
 ;end select
 IF (error(error_msg,1) != 0)
  SET failed = select_error
  CALL echo(error_msg)
  GO TO exit_script
 ENDIF
 SELECT DISTINCT INTO "nl:"
  c.frequency_id
  FROM sch_freq c
  PLAN (c
   WHERE c.freq_state_cd=t_23003_active_cd
    AND c.freq_type_cd=t_23002_defsched_cd
    AND c.version_dt_tm=cnvtdatetime("31-DEC-2100 00:00:00.00"))
  DETAIL
   reply->qual_cnt = (reply->qual_cnt+ 1)
   IF (mod(reply->qual_cnt,100)=1)
    stat = alterlist(reply->qual,(reply->qual_cnt+ 99))
   ENDIF
   reply->qual[reply->qual_cnt].frequency_id = c.frequency_id
  WITH nocounter
 ;end select
 IF (mod(reply->qual_cnt,100) != 0)
  SET stat = alterlist(reply->qual,reply->qual_cnt)
 ENDIF
 IF (error(error_msg,1) != 0)
  SET failed = select_error
  CALL echo(error_msg)
  GO TO exit_script
 ENDIF
 FOR (i = 1 TO reply->qual_cnt)
  EXECUTE sch_utl_reset_freq reply->qual[i].frequency_id, 0
  IF (error(error_msg,1) != 0)
   SET failed = execute_error
   CALL echo(error_msg)
   GO TO exit_script
  ENDIF
 ENDFOR
 CALL parser("rdb truncate table sch_apply_list reuse storage go")
 IF (error(error_msg,1) != 0)
  SET failed = delete_error
  CALL echo(error_msg)
  GO TO exit_script
 ENDIF
 EXECUTE sch_zero_rows5 "SCH_APPLY_LIST", "APPLY_LIST_ID,"
 IF (error(error_msg,1) != 0)
  SET failed = delete_error
  CALL echo(error_msg)
  GO TO exit_script
 ENDIF
 COMMIT
 IF (num_of_days > 1
  AND num_of_days < system_range_day)
  EXECUTE sch_utl_system_pref "DEFRANGE", num_of_days
 ENDIF
 IF (num_of_days >= 1)
  EXECUTE sch_ops_freq_defsched
 ENDIF
 IF (num_of_days > 1
  AND num_of_days < system_range_day)
  EXECUTE sch_utl_system_pref "DEFRANGE", system_range_day
 ENDIF
#exit_script
 IF (failed=false)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
  IF (failed != true
   AND failed != false)
   IF ((validate(pm_subeventstatus_sub_,- (99))=- (99)))
    DECLARE pm_subeventstatus_sub_ = i2 WITH public, constant(1)
    DECLARE s_next_subeventstatus(s_null=i4) = i4
    DECLARE s_add_subeventstatus(s_oname=vc,s_ostatus=c1,s_tname=vc,s_tvalue=vc) = i4
    DECLARE s_add_subeventstatus_cclerr(s_null=i4) = i4
    DECLARE s_log_subeventstatus(s_null=i4) = i4
    DECLARE s_clear_subeventstatus(s_null=i4) = i4
    SUBROUTINE s_next_subeventstatus(s_null)
      DECLARE s_stat = i4 WITH private, noconstant(0)
      DECLARE stx1 = i4 WITH private, noconstant(size(reply->status_data.subeventstatus,5))
      IF ((((reply->status_data.subeventstatus[stx1].operationname > " ")) OR ((((reply->status_data.
      subeventstatus[stx1].operationstatus > " ")) OR ((((reply->status_data.subeventstatus[stx1].
      targetobjectname > " ")) OR ((reply->status_data.subeventstatus[stx1].targetobjectvalue > " ")
      )) )) )) )
       SET stx1 = (stx1+ 1)
       SET s_stat = alter(reply->status_data.subeventstatus,stx1)
      ENDIF
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE s_add_subeventstatus(s_oname,s_ostatus,s_tname,s_tvalue)
      DECLARE stx1 = i4 WITH private, noconstant(s_next_subeventstatus(1))
      SET reply->status_data.subeventstatus[stx1].operationname = s_oname
      SET reply->status_data.subeventstatus[stx1].operationstatus = s_ostatus
      SET reply->status_data.subeventstatus[stx1].targetobjectname = s_tname
      SET reply->status_data.subeventstatus[stx1].targetobjectvalue = s_tvalue
      RETURN(stx1)
    END ;Subroutine
    SUBROUTINE s_add_subeventstatus_cclerr(s_null)
      DECLARE serrmsg = vc WITH private, noconstant("")
      DECLARE ierrcode = i4 WITH private, noconstant(1)
      WHILE (ierrcode)
       SET ierrcode = error(serrmsg,0)
       IF (ierrcode)
        CALL s_add_subeventstatus("CCLERR","F",trim(curprog),serrmsg)
       ENDIF
      ENDWHILE
      RETURN(1)
    END ;Subroutine
    SUBROUTINE s_log_subeventstatus(s_null)
      DECLARE wi = i4 WITH protect, noconstant(0)
      DECLARE s_curprog = vc WITH protect, constant(curprog)
      FOR (wi = 1 TO size(reply->status_data.subeventstatus,5))
        CALL s_sch_msgview(s_curprog,nullterm(build(reply->status_data.subeventstatus[wi].
           operationname,",",reply->status_data.subeventstatus[wi].operationstatus,",",reply->
           status_data.subeventstatus[wi].targetobjectname,
           ",",reply->status_data.subeventstatus[wi].targetobjectvalue)),0)
      ENDFOR
    END ;Subroutine
    SUBROUTINE s_clear_subeventstatus(s_null)
      SET stat = alter(reply->status_data.subeventstatus,1)
      SET reply->status_data.subeventstatus[1].operationname = ""
      SET reply->status_data.subeventstatus[1].operationstatus = ""
      SET reply->status_data.subeventstatus[1].targetobjectname = ""
      SET reply->status_data.subeventstatus[1].targetobjectvalue = ""
    END ;Subroutine
    DECLARE s_sch_msgview(t_event=vc,t_message=vc,t_log_level=i4) = i2
    SUBROUTINE s_sch_msgview(t_event,t_message,t_log_level)
     IF (t_event > " "
      AND t_log_level BETWEEN 0 AND 4
      AND t_message > " ")
      DECLARE hlog = i4 WITH protect, noconstant(0)
      DECLARE hstat = i4 WITH protect, noconstant(0)
      CALL uar_syscreatehandle(hlog,hstat)
      IF (hlog != 0)
       CALL uar_sysevent(hlog,t_log_level,nullterm(t_event),nullterm(t_message))
       CALL uar_sysdestroyhandle(hlog)
      ENDIF
     ENDIF
     RETURN(1)
    END ;Subroutine
   ENDIF
   CASE (failed)
    OF lock_error:
     CALL s_add_subeventstatus("LOCK","F",trim(curprog),table_name)
    OF select_error:
     CALL s_add_subeventstatus("SELECT","F",trim(curprog),table_name)
    OF update_error:
     CALL s_add_subeventstatus("UPDATE","F",trim(curprog),table_name)
    OF insert_error:
     CALL s_add_subeventstatus("INSERT","F",trim(curprog),table_name)
    OF gen_nbr_error:
     CALL s_add_subeventstatus("GEN_NBR","F",trim(curprog),table_name)
    OF replace_error:
     CALL s_add_subeventstatus("REPLACE","F",trim(curprog),table_name)
    OF delete_error:
     CALL s_add_subeventstatus("DELETE","F",trim(curprog),table_name)
    OF undelete_error:
     CALL s_add_subeventstatus("UNDELETE","F",trim(curprog),table_name)
    OF remove_error:
     CALL s_add_subeventstatus("REMOVE","F",trim(curprog),table_name)
    OF attribute_error:
     CALL s_add_subeventstatus("ATTRIBUTE","F",trim(curprog),table_name)
    OF none_found:
     CALL s_add_subeventstatus("NONE_FOUND","F",trim(curprog),table_name)
    OF update_cnt_error:
     CALL s_add_subeventstatus("UPDATE_CNT","F",trim(curprog),table_name)
    OF not_found:
     CALL s_add_subeventstatus("NOT_FOUND","F",trim(curprog),table_name)
    OF inactivate_error:
     CALL s_add_subeventstatus("INACTIVATE","F",trim(curprog),table_name)
    OF activate_error:
     CALL s_add_subeventstatus("ACTIVATE","F",trim(curprog),table_name)
    OF uar_error:
     CALL s_add_subeventstatus("UAR_ERROR","F",trim(curprog),table_name)
    OF execute_error:
     CALL s_add_subeventstatus("EXECUTE","F",trim(curprog),table_name)
    OF duplicate_error:
     CALL s_add_subeventstatus("DUPLICATE","F",trim(curprog),table_name)
    OF ccl_error:
     CALL s_add_subeventstatus("CCLERROR","F",trim(curprog),table_name)
    ELSE
     CALL s_add_subeventstatus("UNKNOWN","F",trim(curprog),table_name)
   ENDCASE
   SET reqinfo->commit_ind = false
   CALL s_add_subeventstatus_cclerr(1)
   CALL s_log_subeventstatus(1)
  ENDIF
  CALL echorecord(reply)
 ENDIF
END GO
