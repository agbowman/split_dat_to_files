CREATE PROGRAM bhs_sys_exe_req_966302
 RECORD hm_ref_req(
   1 last_load_dt_tm = dq8
 ) WITH persist
 RECORD hm_ref_reply(
   1 load_dt_tm = dq8
   1 sched_cnt = i4
   1 sched[*]
     2 expect_sched_id = f8
     2 expect_sched_name = vc
     2 expect_sched_meaning = vc
     2 expect_sched_type_flag = i2
     2 expect_sched_loc_cd = f8
     2 expect_sched_loc_disp = vc
     2 expect_sched_loc_mean = vc
     2 on_time_start_age = i4
     2 sched_level_flag = i2
     2 series_cnt = i4
     2 series[*]
       3 expect_series_id = f8
       3 expect_series_name = vc
       3 series_meaning = vc
       3 priority_meaning = vc
       3 priority_disp = vc
       3 priority_seq = i4
       3 rule_associated_ind = i2
       3 first_step_age = i4
       3 expect_cnt = i4
       3 expect[*]
         4 expect_id = f8
         4 expect_name = vc
         4 expect_meaning = vc
         4 step_count = i4
         4 interval_only_ind = i2
         4 seq_nbr = i4
         4 max_age = i4
         4 step_cnt = i4
         4 step[*]
           5 expect_step_id = f8
           5 expect_step_name = vc
           5 step_meaning = vc
           5 valid_recommend_start_age = i4
           5 valid_recommend_end_age = i4
           5 step_nbr = i4
           5 max_interval_to_count = i4
           5 min_interval_to_count = i4
           5 min_interval_to_admin = i4
           5 recommended_interval = i4
           5 min_age = i4
           5 skip_age = i4
           5 due_duration = i4
           5 audience_flag = i4
           5 start_time_of_year = i4
           5 end_time_of_year = i4
         4 satisfier_cnt = i4
         4 satisfier[*]
           5 expect_sat_id = f8
           5 expect_sat_name = vc
           5 satisfier_meaning = vc
           5 parent_type_flag = i2
           5 parent_nbr = f8
           5 parent_value = vc
           5 seq_nbr = i4
           5 entry_type_cd = f8
           5 entry_type_disp = vc
           5 entry_type_mean = vc
           5 entry_nbr = f8
           5 entry_value = vc
           5 pending_duration = i4
           5 satisfied_duration = i4
           5 nomenclature_id = f8
   1 status_data
     2 status = vc
     2 status_value = i4
     2 subeventstatus[*]
       3 operationname = vc
       3 operationstatus = vc
       3 targetobjectname = vc
       3 targetobjectvalue = vc
 ) WITH persist
 DECLARE crmstatus = i4 WITH public, noconstant(0)
 DECLARE failed_action = c12 WITH public, noconstant(" ")
 DECLARE serrmsg = vc
 DECLARE appnum = i4 WITH public, constant(966300)
 DECLARE tasknum = i4 WITH public, constant(966310)
 DECLARE reqnum = i4 WITH public, constant(966302)
 DECLARE happ = i4 WITH public, noconstant(0)
 DECLARE htask = i4 WITH public, noconstant(0)
 DECLARE hreq = i4 WITH public, noconstant(0)
 DECLARE hstep = i4 WITH public, noconstant(0)
 DECLARE hschedreq = i4 WITH public, noconstant(0)
 DECLARE hproblemreq = i4 WITH public, noconstant(0)
 DECLARE hprocedurereq = i4 WITH public, noconstant(0)
 DECLARE hdiagnosisreq = i4 WITH public, noconstant(0)
 DECLARE hreply = i4 WITH public, noconstant(0)
 DECLARE hstruct = i4 WITH public, noconstant(0)
 DECLARE hsched = i4 WITH public, noconstant(0)
 DECLARE hseries = i4 WITH public, noconstant(0)
 DECLARE hexpect = i4 WITH public, noconstant(0)
 DECLARE hexpectstep = i4 WITH public, noconstant(0)
 SET crmstatus = uar_crmbeginapp(appnum,happ)
 IF (crmstatus != 0)
  SET failed_action = "begin_app"
  SET serrmsg = concat("uar_crmbeginapp(",trim(cnvtstring(appnum)),",happ) = ",trim(cnvtstring(
     crmstatus)))
  CALL uar_crmendapp(happ)
  GO TO exit_script
 ENDIF
 SET crmstatus = uar_crmbegintask(happ,tasknum,htask)
 IF (crmstatus != 0)
  SET failed_action = "begin_task"
  SET serrmsg = concat("uar_crmbegintask(happ,",trim(cnvtstring(tasknum)),",htask) = ",trim(
    cnvtstring(crmstatus)))
  CALL uar_crmendtask(htask)
  CALL uar_crmendapp(happ)
  GO TO exit_script
 ENDIF
 SET crmstatus = uar_crmbeginreq(htask,hreq,reqnum,hstep)
 IF (crmstatus != 0)
  SET failed_action = "begin_req"
  SET serrmsg = concat("uar_crmbeginreq(htask,hreq,",trim(cnvtstring(reqnum)),",hstep) = ",trim(
    cnvtstring(crmstatus)))
  CALL uar_crmendreq(hstep)
  CALL uar_crmendtask(htask)
  CALL uar_crmendapp(happ)
  GO TO exit_script
 ENDIF
 SET hreq = uar_crmgetrequest(hstep)
 IF (hreq <= 0)
  SET failed_action = "init_req"
  SET serrmsg = "uar_crmgetrequest(hstep) failed"
  CALL uar_crmendreq(hstep)
  CALL uar_crmendtask(htask)
  CALL uar_crmendapp(happ)
  GO TO exit_script
 ENDIF
 SET stat = uar_srvsetdate(hreq,"last_load_dt_tm",cnvtdatetime(hm_ref_req->last_load_dt_tm))
 SET crmstatus = uar_crmperform(hstep)
 IF (crmstatus != 0)
  SET failed_action = "perform_req"
  SET serrmsg = concat("uar_crmperform(hstep) = ",trim(cnvtstring(crmstatus)))
  CALL uar_crmendreq(hstep)
  CALL uar_crmendtask(htask)
  CALL uar_crmendapp(happ)
  GO TO exit_script
 ENDIF
 SET hreply = uar_crmgetreply(hstep)
 IF (hreply <= 0)
  SET failed_action = "get_reply"
  SET serrmsg = "uar_crmgetreply(hstep)"
  CALL uar_crmendreq(hstep)
  CALL uar_crmendtask(htask)
  CALL uar_crmendapp(happ)
  GO TO exit_script
 ENDIF
 SET hstruct = uar_srvgetstruct(hreply,"status_data")
 SET statusvalue = trim(uar_srvgetstringptr(hstruct,"status"))
 IF (statusvalue != "S")
  SET failed_action = "exe_error"
  SET serrmsg = concat("the perform of ",trim(cnvtstring(reqnum))," failed")
  CALL uar_crmendreq(hstep)
  CALL uar_crmendtask(htask)
  CALL uar_crmendapp(happ)
  GO TO exit_script
 ENDIF
 CALL uar_srvgetdate(hreply,"load_dt_tm",hm_ref_reply->load_dt_tm)
 SET hm_ref_reply->sched_cnt = uar_srvgetitemcount(hreply,"sched")
 SET stat = alterlist(hm_ref_reply->sched,hm_ref_reply->sched_cnt)
 FOR (sched = 1 TO hm_ref_reply->sched_cnt)
   SET hsched = uar_srvgetitem(hreply,"sched",(sched - 1))
   SET hm_ref_reply->sched[sched].expect_sched_id = uar_srvgetdouble(hsched,"expect_sched_id")
   SET hm_ref_reply->sched[sched].expect_sched_name = uar_srvgetstringptr(hsched,"expect_sched_name")
   SET hm_ref_reply->sched[sched].expect_sched_meaning = uar_srvgetstringptr(hsched,
    "expect_sched_meaning")
   SET hm_ref_reply->sched[sched].expect_sched_type_flag = uar_srvgetshort(hsched,
    "expect_sched_type_flag")
   SET hm_ref_reply->sched[sched].expect_sched_loc_cd = uar_srvgetdouble(hsched,"expect_sched_loc_cd"
    )
   SET hm_ref_reply->sched[sched].expect_sched_loc_disp = uar_srvgetstringptr(hsched,
    "expect_sched_loc_disp")
   SET hm_ref_reply->sched[sched].expect_sched_loc_mean = uar_srvgetstringptr(hsched,
    "expect_sched_loc_mean")
   SET hm_ref_reply->sched[sched].on_time_start_age = uar_srvgetlong(hsched,"on_time_start_age")
   SET hm_ref_reply->sched[sched].sched_level_flag = uar_srvgetshort(hsched,"sched_level_flag")
   SET hm_ref_reply->sched[sched].series_cnt = uar_srvgetitemcount(hsched,"series")
   SET stat = alterlist(hm_ref_reply->sched[sched].series,hm_ref_reply->sched[sched].series_cnt)
   FOR (series = 1 TO hm_ref_reply->sched[sched].series_cnt)
     SET hseries = uar_srvgetitem(hsched,"series",(series - 1))
     SET hm_ref_reply->sched[sched].series[series].expect_series_id = uar_srvgetdouble(hseries,
      "expect_series_id")
     SET hm_ref_reply->sched[sched].series[series].expect_series_name = uar_srvgetstringptr(hseries,
      "expect_series_name")
     SET hm_ref_reply->sched[sched].series[series].series_meaning = uar_srvgetstringptr(hseries,
      "series_meaning")
     SET hm_ref_reply->sched[sched].series[series].priority_meaning = uar_srvgetstringptr(hseries,
      "priority_meaning")
     SET hm_ref_reply->sched[sched].series[series].priority_disp = uar_srvgetstringptr(hseries,
      "priority_disp")
     SET hm_ref_reply->sched[sched].series[series].priority_seq = uar_srvgetlong(hseries,
      "priority_seq")
     SET hm_ref_reply->sched[sched].series[series].rule_associated_ind = uar_srvgetshort(hseries,
      "rule_associated_ind")
     SET hm_ref_reply->sched[sched].series[series].first_step_age = uar_srvgetlong(hseries,
      "first_step_age")
     SET hm_ref_reply->sched[sched].series[series].expect_cnt = uar_srvgetitemcount(hseries,"expect")
     SET stat = alterlist(hm_ref_reply->sched[sched].series[series].expect,hm_ref_reply->sched[sched]
      .series[series].expect_cnt)
     FOR (expect = 1 TO hm_ref_reply->sched[sched].series[series].expect_cnt)
       SET hexpect = uar_srvgetitem(hseries,"expect",(expect - 1))
       SET hm_ref_reply->sched[sched].series[series].expect[expect].expect_id = uar_srvgetdouble(
        hexpect,"expect_id")
       SET hm_ref_reply->sched[sched].series[series].expect[expect].expect_name = uar_srvgetstringptr
       (hexpect,"expect_name")
       SET hm_ref_reply->sched[sched].series[series].expect[expect].expect_meaning =
       uar_srvgetstringptr(hexpect,"expect_meaning")
       SET hm_ref_reply->sched[sched].series[series].expect[expect].interval_only_ind =
       uar_srvgetshort(hexpect,"interval_only_ind")
       SET hm_ref_reply->sched[sched].series[series].expect[expect].seq_nbr = uar_srvgetlong(hexpect,
        "seq_nbr")
       SET hm_ref_reply->sched[sched].series[series].expect[expect].max_age = uar_srvgetlong(hexpect,
        "max_age")
       SET hm_ref_reply->sched[sched].series[series].expect[expect].step_cnt = uar_srvgetitemcount(
        hexpect,"step")
       SET stat = alterlist(hm_ref_reply->sched[sched].series[series].expect[expect].step,
        hm_ref_reply->sched[sched].series[series].expect[expect].step_cnt)
       FOR (step = 1 TO hm_ref_reply->sched[sched].series[series].expect[expect].step_cnt)
         SET hexpectstep = uar_srvgetitem(hexpect,"step",(step - 1))
         SET hm_ref_reply->sched[sched].series[series].expect[expect].step[step].expect_step_id =
         uar_srvgetdouble(hexpectstep,"expect_step_id")
         SET hm_ref_reply->sched[sched].series[series].expect[expect].step[step].expect_step_name =
         uar_srvgetstringptr(hexpectstep,"expect_step_name")
         SET hm_ref_reply->sched[sched].series[series].expect[expect].step[step].step_meaning =
         uar_srvgetstringptr(hexpectstep,"step_meaning")
         SET hm_ref_reply->sched[sched].series[series].expect[expect].step[step].
         valid_recommend_start_age = uar_srvgetlong(hexpectstep,"valid_recommend_start_age")
         SET hm_ref_reply->sched[sched].series[series].expect[expect].step[step].
         valid_recommend_end_age = uar_srvgetlong(hexpectstep,"valid_recommend_end_age")
         SET hm_ref_reply->sched[sched].series[series].expect[expect].step[step].step_nbr =
         uar_srvgetlong(hexpectstep,"step_nbr")
         SET hm_ref_reply->sched[sched].series[series].expect[expect].step[step].
         max_interval_to_count = uar_srvgetlong(hexpectstep,"max_interval_to_count")
         SET hm_ref_reply->sched[sched].series[series].expect[expect].step[step].
         min_interval_to_count = uar_srvgetlong(hexpectstep,"min_interval_to_count")
         SET hm_ref_reply->sched[sched].series[series].expect[expect].step[step].
         min_interval_to_admin = uar_srvgetlong(hexpectstep,"min_interval_to_admin")
         SET hm_ref_reply->sched[sched].series[series].expect[expect].step[step].recommended_interval
          = uar_srvgetlong(hexpectstep,"recommended_interval")
         SET hm_ref_reply->sched[sched].series[series].expect[expect].step[step].min_age =
         uar_srvgetlong(hexpectstep,"min_age")
         SET hm_ref_reply->sched[sched].series[series].expect[expect].step[step].skip_age =
         uar_srvgetlong(hexpectstep,"skip_age")
         SET hm_ref_reply->sched[sched].series[series].expect[expect].step[step].due_duration =
         uar_srvgetlong(hexpectstep,"due_duration")
         SET hm_ref_reply->sched[sched].series[series].expect[expect].step[step].audience_flag =
         uar_srvgetlong(hexpectstep,"audience_flag")
         SET hm_ref_reply->sched[sched].series[series].expect[expect].step[step].start_time_of_year
          = uar_srvgetlong(hexpectstep,"start_time_of_year")
         SET hm_ref_reply->sched[sched].series[series].expect[expect].step[step].end_time_of_year =
         uar_srvgetlong(hexpectstep,"end_time_of_year")
       ENDFOR
       SET hm_ref_reply->sched[sched].series[series].expect[expect].satisfier_cnt =
       uar_srvgetitemcount(hexpect,"satisfier")
       SET stat = alterlist(hm_ref_reply->sched[sched].series[series].expect[expect].satisfier,
        hm_ref_reply->sched[sched].series[series].expect[expect].satisfier_cnt)
       FOR (satisfier = 1 TO hm_ref_reply->sched[sched].series[series].expect[expect].satisfier_cnt)
         SET hsatisfier = uar_srvgetitem(hexpect,"satisfier",(satisfier - 1))
         SET hm_ref_reply->sched[sched].series[series].expect[expect].satisfier[satisfier].
         expect_sat_id = uar_srvgetdouble(hsatisfier,"expect_sat_id")
         SET hm_ref_reply->sched[sched].series[series].expect[expect].satisfier[satisfier].
         expect_sat_name = uar_srvgetstringptr(hsatisfier,"expect_sat_name")
         SET hm_ref_reply->sched[sched].series[series].expect[expect].satisfier[satisfier].
         satisfier_meaning = uar_srvgetstringptr(hsatisfier,"satisfier_meaning")
         SET hm_ref_reply->sched[sched].series[series].expect[expect].satisfier[satisfier].
         parent_type_flag = uar_srvgetshort(hsatisfier,"parent_type_flag")
         SET hm_ref_reply->sched[sched].series[series].expect[expect].satisfier[satisfier].parent_nbr
          = uar_srvgetdouble(hsatisfier,"parent_nbr")
         SET hm_ref_reply->sched[sched].series[series].expect[expect].satisfier[satisfier].
         parent_value = uar_srvgetstringptr(hsatisfier,"parent_value")
         SET hm_ref_reply->sched[sched].series[series].expect[expect].satisfier[satisfier].seq_nbr =
         uar_srvgetlong(hsatisfier,"seq_nbr")
         SET hm_ref_reply->sched[sched].series[series].expect[expect].satisfier[satisfier].
         entry_type_cd = uar_srvgetdouble(hsatisfier,"entry_type_cd")
         SET hm_ref_reply->sched[sched].series[series].expect[expect].satisfier[satisfier].
         entry_type_disp = uar_srvgetstringptr(hsatisfier,"entry_type_disp")
         SET hm_ref_reply->sched[sched].series[series].expect[expect].satisfier[satisfier].
         entry_type_mean = uar_srvgetstringptr(hsatisfier,"entry_type_mean")
         SET hm_ref_reply->sched[sched].series[series].expect[expect].satisfier[satisfier].entry_nbr
          = uar_srvgetlong(hsatisfier,"entry_nbr")
         SET hm_ref_reply->sched[sched].series[series].expect[expect].satisfier[satisfier].
         entry_value = uar_srvgetstringptr(hsatisfier,"entry_value")
         SET hm_ref_reply->sched[sched].series[series].expect[expect].satisfier[satisfier].
         pending_duration = uar_srvgetlong(hsatisfier,"pending_duration")
         SET hm_ref_reply->sched[sched].series[series].expect[expect].satisfier[satisfier].
         satisfied_duration = uar_srvgetlong(hsatisfier,"satisfied_duration")
         SET hm_ref_reply->sched[sched].series[series].expect[expect].satisfier[satisfier].
         nomenclature_id = uar_srvgetdouble(hsatisfier,"nomenclature_id")
       ENDFOR
     ENDFOR
   ENDFOR
 ENDFOR
 CALL uar_crmendreq(hstep)
 CALL uar_crmendtask(htask)
 CALL uar_crmendapp(happ)
#exit_script
 IF (validate(debug_mode,0)=1)
  CALL echo(serrmsg)
  CALL echorecord(hm_ref_reply)
 ENDIF
END GO
