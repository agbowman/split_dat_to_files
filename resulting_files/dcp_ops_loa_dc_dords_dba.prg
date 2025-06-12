CREATE PROGRAM dcp_ops_loa_dc_dords:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE size_of_org_list = i2 WITH public, noconstant(0)
 DECLARE determine_organizations_for_time_zone(time_zone=vc) = null
 IF ((validate(dq_parser_rec->buffer_count,- (99))=- (99)))
  CALL echo("*****inside pm_dynamic_query include file *****")
  FREE RECORD dq_parser_rec
  RECORD dq_parser_rec(
    1 buffer_count = i2
    1 plan_count = i2
    1 set_count = i2
    1 table_count = i2
    1 with_count = i2
    1 buffer[*]
      2 line = vc
  )
  SET dq_parser_rec->buffer_count = 0
  SET dq_parser_rec->plan_count = 0
  SET dq_parser_rec->set_count = 0
  SET dq_parser_rec->table_count = 0
  SET dq_parser_rec->with_count = 0
  DECLARE dq_add_detail(dqad_dummy) = null
  DECLARE dq_add_footer(dqaf_target) = null
  DECLARE dq_add_header(dqah_target) = null
  DECLARE dq_add_line(dqal_line) = null
  DECLARE dq_get_line(dqgl_idx) = vc
  DECLARE dq_upt_line(dqul_idx,dqul_line) = null
  DECLARE dq_add_planjoin(dqap_range) = null
  DECLARE dq_add_set(dqas_to,dqas_from) = null
  DECLARE dq_add_table(dqat_table_name,dqat_table_alias) = null
  DECLARE dq_add_with(dqaw_control_option) = null
  DECLARE dq_begin_insert(dqbi_dummy) = null
  DECLARE dq_begin_select(dqbs_distinct_ind,dqbs_output_device) = null
  DECLARE dq_begin_update(dqbu_dummy) = null
  DECLARE dq_echo_query(dqeq_level) = null
  DECLARE dq_end_query(dqes_dummy) = null
  DECLARE dq_execute(dqe_reset) = null
  DECLARE dq_reset_query(dqrb_dummy) = null
  SUBROUTINE dq_add_detail(dqad_dummy)
    CALL dq_add_line("detail")
  END ;Subroutine
  SUBROUTINE dq_add_footer(dqaf_target)
    IF (size(trim(dqaf_target),1) > 0)
     CALL dq_add_line(concat("foot ",dqaf_target))
    ELSE
     CALL dq_add_line("foot report")
    ENDIF
  END ;Subroutine
  SUBROUTINE dq_add_header(dqah_target)
    IF (size(trim(dqah_target),1) > 0)
     CALL dq_add_line(concat("head ",dqah_target))
    ELSE
     CALL dq_add_line("head report")
    ENDIF
  END ;Subroutine
  SUBROUTINE dq_add_line(dqal_line)
    SET dq_parser_rec->buffer_count = (dq_parser_rec->buffer_count+ 1)
    IF (mod(dq_parser_rec->buffer_count,10)=1)
     SET stat = alterlist(dq_parser_rec->buffer,(dq_parser_rec->buffer_count+ 9))
    ENDIF
    SET dq_parser_rec->buffer[dq_parser_rec->buffer_count].line = trim(dqal_line,3)
  END ;Subroutine
  SUBROUTINE dq_get_line(dqgl_idx)
    IF (dqgl_idx > 0
     AND dqgl_idx <= size(dq_parser_rec->buffer,5))
     RETURN(dq_parser_rec->buffer[dqgl_idx].line)
    ENDIF
  END ;Subroutine
  SUBROUTINE dq_upt_line(dqul_idx,dqul_line)
    IF (dqul_idx > 0
     AND dqul_idx <= size(dq_parser_rec->buffer,5))
     SET dq_parser_rec->buffer[dqul_idx].line = dqul_line
    ENDIF
  END ;Subroutine
  SUBROUTINE dq_add_planjoin(dqap_range)
    DECLARE dqap_str = vc WITH private, noconstant(" ")
    IF ((dq_parser_rec->plan_count > 0))
     SET dqap_str = "join"
    ELSE
     SET dqap_str = "plan"
    ENDIF
    IF (size(trim(dqap_range),1) > 0)
     CALL dq_add_line(concat(dqap_str," ",dqap_range," where"))
     SET dq_parser_rec->plan_count = (dq_parser_rec->plan_count+ 1)
    ELSE
     CALL dq_add_line("where ")
    ENDIF
  END ;Subroutine
  SUBROUTINE dq_add_set(dqas_to,dqas_from)
   IF ((dq_parser_rec->set_count > 0))
    CALL dq_add_line(concat(",",dqas_to," = ",dqas_from))
   ELSE
    CALL dq_add_line(concat("set ",dqas_to," = ",dqas_from))
   ENDIF
   SET dq_parser_rec->set_count = (dq_parser_rec->set_count+ 1)
  END ;Subroutine
  SUBROUTINE dq_add_table(dqat_table_name,dqat_table_alias)
    DECLARE dqat_str = vc WITH private, noconstant(" ")
    IF ((dq_parser_rec->table_count > 0))
     SET dqat_str = concat(" , ",dqat_table_name)
    ELSE
     SET dqat_str = concat(" from ",dqat_table_name)
    ENDIF
    IF (size(trim(dqat_table_alias),1) > 0)
     SET dqat_str = concat(dqat_str," ",dqat_table_alias)
    ENDIF
    SET dq_parser_rec->table_count = (dq_parser_rec->table_count+ 1)
    CALL dq_add_line(dqat_str)
  END ;Subroutine
  SUBROUTINE dq_add_with(dqaw_control_option)
   IF ((dq_parser_rec->with_count > 0))
    CALL dq_add_line(concat(",",dqaw_control_option))
   ELSE
    CALL dq_add_line(concat("with ",dqaw_control_option))
   ENDIF
   SET dq_parser_rec->with_count = (dq_parser_rec->with_count+ 1)
  END ;Subroutine
  SUBROUTINE dq_begin_insert(dqbi_dummy)
   CALL dq_reset_query(1)
   CALL dq_add_line("insert")
  END ;Subroutine
  SUBROUTINE dq_begin_select(dqbs_distinct_ind,dqbs_output_device)
    DECLARE dqbs_str = vc WITH noconstant(" ")
    CALL dq_reset_query(1)
    IF (dqbs_distinct_ind=0)
     SET dqbs_str = "select"
    ELSE
     SET dqbs_str = "select distinct"
    ENDIF
    IF (size(trim(dqbs_output_device),1) > 0)
     SET dqbs_str = concat(dqbs_str," into ",dqbs_output_device)
    ENDIF
    CALL dq_add_line(dqbs_str)
  END ;Subroutine
  SUBROUTINE dq_begin_update(dqbu_dummy)
   CALL dq_reset_query(1)
   CALL dq_add_line("update")
  END ;Subroutine
  SUBROUTINE dq_echo_query(dqeq_level)
    DECLARE dqeq_i = i4 WITH private, noconstant(0)
    DECLARE dqeq_j = i4 WITH private, noconstant(0)
    IF (dqeq_level=1)
     CALL echo("-------------------------------------------------------------------")
     CALL echo("Parser Buffer Echo:")
     CALL echo("-------------------------------------------------------------------")
     FOR (dqeq_i = 1 TO dq_parser_rec->buffer_count)
       CALL echo(dq_parser_rec->buffer[dqeq_i].line)
     ENDFOR
     CALL echo("-------------------------------------------------------------------")
    ELSEIF (dqeq_level=2)
     IF (validate(reply->debug[1].line,"-9") != "-9")
      SET dqeq_j = size(reply->debug,5)
      SET stat = alterlist(reply->debug,((dqeq_j+ size(dq_parser_rec->buffer,5))+ 4))
      SET reply->debug[(dqeq_j+ 1)].line =
      "-------------------------------------------------------------------"
      SET reply->debug[(dqeq_j+ 2)].line = "Parser Buffer Echo:"
      SET reply->debug[(dqeq_j+ 3)].line =
      "-------------------------------------------------------------------"
      FOR (dqeq_i = 1 TO dq_parser_rec->buffer_count)
        SET reply->debug[((dqeq_j+ dqeq_i)+ 3)].line = dq_parser_rec->buffer[dqeq_i].line
      ENDFOR
      SET reply->debug[((dqeq_j+ dq_parser_rec->buffer_count)+ 4)].line =
      "-------------------------------------------------------------------"
     ENDIF
    ENDIF
  END ;Subroutine
  SUBROUTINE dq_end_query(dqes_dummy)
   CALL dq_add_line(" go")
   SET stat = alterlist(dq_parser_rec->buffer,dq_parser_rec->buffer_count)
  END ;Subroutine
  SUBROUTINE dq_execute(dqe_reset)
    IF (checkprg("PM_DQ_EXECUTE_PARSER") > 0)
     EXECUTE pm_dq_execute_parser  WITH replace("TEMP_DQ_PARSER_REC","DQ_PARSER_REC")
     IF (dqe_reset=1)
      SET stat = initrec(dq_parser_rec)
     ENDIF
    ELSE
     DECLARE dqe_i = i4 WITH private, noconstant(0)
     FOR (dqe_i = 1 TO dq_parser_rec->buffer_count)
       CALL parser(dq_parser_rec->buffer[dqe_i].line,1)
     ENDFOR
     IF (dqe_reset=1)
      CALL dq_reset_query(1)
     ENDIF
    ENDIF
  END ;Subroutine
  SUBROUTINE dq_reset_query(dqrb_dummy)
    SET stat = alterlist(dq_parser_rec->buffer,0)
    SET dq_parser_rec->buffer_count = 0
    SET dq_parser_rec->plan_count = 0
    SET dq_parser_rec->set_count = 0
    SET dq_parser_rec->table_count = 0
    SET dq_parser_rec->with_count = 0
  END ;Subroutine
 ENDIF
 FREE RECORD orgs_in_tz_inc
 RECORD orgs_in_tz_inc(
   1 orgs[*]
     2 org_id = f8
 )
 SUBROUTINE determine_organizations_for_time_zone(time_zone)
   DECLARE dtzfacilitycd = f8 WITH noconstant(0.0)
   SET stat = uar_get_meaning_by_codeset(222,"FACILITY",1,dtzfacilitycd)
   SELECT INTO "nl:"
    l.organization_id
    FROM time_zone_r tzr,
     location l
    PLAN (tzr
     WHERE tzr.parent_entity_name="LOCATION"
      AND tzr.time_zone=time_zone)
     JOIN (l
     WHERE l.location_cd=tzr.parent_entity_id
      AND ((l.location_type_cd+ 0)=dtzfacilitycd)
      AND l.active_ind=1
      AND ((l.organization_id+ 0) > 0))
    ORDER BY l.organization_id
    HEAD REPORT
     counter = 0
    HEAD l.organization_id
     counter = (counter+ 1)
     IF (mod(counter,100)=1)
      stat = alterlist(orgs_in_tz_inc->orgs,(counter+ 99))
     ENDIF
     orgs_in_tz_inc->orgs[counter].org_id = l.organization_id
    FOOT REPORT
     stat = alterlist(orgs_in_tz_inc->orgs,counter)
    WITH nocounter
   ;end select
   SET size_of_org_list = size(orgs_in_tz_inc->orgs,5)
 END ;Subroutine
 DECLARE determine_facilities_for_time_zone(time_zone=vc) = null
 FREE RECORD facilities_in_timezone
 RECORD facilities_in_timezone(
   1 qual[*]
     2 loc_facility_cd = f8
 )
 SUBROUTINE determine_facilities_for_time_zone(time_zone)
  DECLARE lfaccnt = i4 WITH protect, noconstant(0)
  SELECT INTO "nl:"
   cv.code_value
   FROM code_value cv,
    time_zone_r tzr
   PLAN (cv
    WHERE cv.code_set=220
     AND cv.cdf_meaning="FACILITY"
     AND cv.active_ind=1)
    JOIN (tzr
    WHERE tzr.parent_entity_id=cv.code_value
     AND tzr.parent_entity_name="LOCATION"
     AND tzr.time_zone=time_zone)
   ORDER BY cv.code_value
   HEAD REPORT
    lfaccnt = 0
   HEAD cv.code_value
    IF (cv.code_value > 0.0)
     lfaccnt = (lfaccnt+ 1)
     IF (lfaccnt > size(facilities_in_timezone->qual,5))
      stat = alterlist(facilities_in_timezone->qual,(lfaccnt+ 99))
     ENDIF
     facilities_in_timezone->qual[lfaccnt].loc_facility_cd = cv.code_value
    ENDIF
   FOOT REPORT
    stat = alterlist(facilities_in_timezone->qual,lfaccnt)
   WITH nocounter
  ;end select
 END ;Subroutine
 SET reply->status_data.status = "F"
 DECLARE failed_ind = i2
 SET failed_ind = 0
 DECLARE orgnum = i4 WITH noconstant(0)
 DECLARE org_size_cnt = i4 WITH noconstant(0)
 RECORD hold(
   1 enc_cnt = i4
   1 enc[*]
     2 encntr_id = f8
     2 ord_cnt = i4
     2 ord[*]
       3 order_id = f8
       3 order_status_cd = f8
       3 action_type_cd = f8
       3 action = c20
       3 catalog_cd = f8
       3 catalog_type_cd = f8
       3 updt_cnt = i4
       3 oe_format_id = f8
 )
 RECORD cval(
   1 inprocess_status_cd = f8
   1 ordered_status_cd = f8
   1 discontinued_status_cd = f8
   1 cancel_status_cd = f8
   1 pending_status_cd = f8
   1 medstudent_status_cd = f8
   1 incomplete_status_cd = f8
   1 suspended_status_cd = f8
   1 discontinue_action_cd = f8
   1 cancel_action_cd = f8
   1 pharm_cd = f8
   1 inpatient_cd = f8
   1 disc_type_cd = f8
 )
 RECORD dstat(
   1 cnt = i4
   1 qual[*]
     2 dstat_code_value = f8
 )
 DECLARE extended_cd = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(28720,nullterm("EXTENDED"),1,extended_cd)
 DECLARE active_cd = f8 WITH noconstant(0.0)
 SET stat = uar_get_meaning_by_codeset(261,nullterm("ACTIVE"),1,active_cd)
 DECLARE dsch_hours = f8
 SET dsch_hours = 0.0
 SELECT INTO "nl:"
  cp.config_name
  FROM config_prefs cp
  WHERE cp.config_name="LOA_HRS"
  DETAIL
   dsch_hours = cnvtreal(trim(cp.config_value))
  WITH nocounter
 ;end select
 CALL echo(build("disch hours: ",dsch_hours))
 DECLARE dsch_cancel_flag = i2
 SET dsch_cancel_flag = 3
 DECLARE check_start_ind = i2
 SET check_start_ind = 0
 DECLARE start_plus_hrs = i4
 SET start_plus_hrs = 0
 SET start_check_time = cnvtdatetime(curdate,curtime3)
 SELECT INTO "nl:"
  cp.config_name
  FROM config_prefs cp
  WHERE cp.config_name="LOA_FLAG"
  DETAIL
   tmp_val = substring(1,3,trim(cp.config_value))
   IF (tmp_val="ALL")
    dsch_cancel_flag = 1
   ELSEIF (tmp_val="ORD")
    dsch_cancel_flag = 2
   ELSE
    dsch_cancel_flag = 3
   ENDIF
   IF (((dsch_cancel_flag=1) OR (dsch_cancel_flag=2)) )
    tmp_val2 = substring(4,1,trim(cp.config_value))
    IF (tmp_val2=">")
     tmp_val3 = substring(5,1,trim(cp.config_value))
     IF (tmp_val3 > " ")
      start_plus_hrs = dsch_hours
      IF (start_plus_hrs >= 0)
       check_start_ind = 1
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 CALL echo(build("disch cancel flag: ",dsch_cancel_flag))
 CALL echo(build("start ind",check_start_ind))
 CALL echo(build("start hrs",start_plus_hrs))
 SET now = cnvtdatetime(curdate,curtime3)
 CALL echo(build("now->",now))
 SET now_minus_hours = cnvtdatetime(curdate,curtime3)
 CALL echo(build("now minus hours->",now_minus_hours))
 SET now_minus_days = datetimeadd(now,- (14))
 CALL echo(build("now_minus_days->",now_minus_days))
 IF (dsch_hours > 0)
  SET now_minus_hours = datetimeadd(now,- ((dsch_hours/ 24.0)))
 ENDIF
 IF (curutc)
  CALL determine_organizations_for_time_zone(curtimezone)
  SET org_size_cnt = size(orgs_in_tz_inc->orgs,5)
 ENDIF
 CALL echo(build("now minus hours->",now_minus_hours))
 CALL echo("lookiing up code_values")
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=6004
  DETAIL
   CASE (c.cdf_meaning)
    OF "ORDERED":
     cval->ordered_status_cd = c.code_value
    OF "INPROCESS":
     cval->inprocess_status_cd = c.code_value
    OF "DISCONTINUED":
     cval->discontinued_status_cd = c.code_value
    OF "CANCELED":
     cval->cancel_status_cd = c.code_value
    OF "PENDING":
     cval->pending_status_cd = c.code_value
    OF "INCOMPLETE":
     cval->incomplete_status_cd = c.code_value
    OF "MEDSTUDENT":
     cval->medstudent_status_cd = c.code_value
    OF "SUSPENDED":
     cval->suspended_status_cd = c.code_value
   ENDCASE
  WITH nocounter
 ;end select
 IF ((((cval->cancel_status_cd=0)) OR ((cval->discontinued_status_cd=0))) )
  CALL echo("**** missing an order status code****")
  SET failed_ind = 1
  SET reply->status_data.subeventstatus[1].operationname = "dcp_ops_inp_dc_orders"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "order status missing"
  CALL echo("exit_script #1:**")
  GO TO exit_script
 ENDIF
 SET code_set = 69
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "INPATIENT"
 EXECUTE cpm_get_cd_for_cdf
 SET cval->inpatient_cd = code_value
 IF ((cval->inpatient_cd=0))
  CALL echo("**** missing inpatient encntr type class on codeset 69 ****")
  SET failed_ind = 1
  SET reply->status_data.subeventstatus[1].operationname = "dcp_ops_inp_dc_orders"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "inpatient (cs 69) missing"
  CALL echo("exit_script #2:**")
  GO TO exit_script
 ENDIF
 SET code_set = 4038
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "SYSTEMDISCH"
 EXECUTE cpm_get_cd_for_cdf
 SET cval->disc_type_cd = code_value
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=6003
  DETAIL
   CASE (c.cdf_meaning)
    OF "DISCONTINUE":
     cval->discontinue_action_cd = c.code_value
    OF "CANCEL":
     cval->cancel_action_cd = c.code_value
   ENDCASE
  WITH nocounter
 ;end select
 IF ((((cval->discontinue_action_cd=0)) OR ((cval->cancel_action_cd=0))) )
  CALL echo("**** missing an order action code****")
  SET failed_ind = 1
  SET reply->status_data.subeventstatus[1].operationname = "dcp_ops_inp_dc_orders"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "order action missing"
  CALL echo("exit_script #3:**")
  GO TO exit_script
 ENDIF
 SET code_set = 6000
 SET code_value = 0.0
 SET cdf_meaning = fillstring(12," ")
 SET cdf_meaning = "PHARMACY"
 EXECUTE cpm_get_cd_for_cdf
 SET cval->pharm_cd = code_value
 SELECT INTO "nl:"
  cve.code_value
  FROM code_value_extension cve
  WHERE cve.code_set=14281
   AND cve.field_name="DCP_ALLOW_CANCEL_IND"
  DETAIL
   cancel_ind = cnvtint(trim(cve.field_value))
   IF (cancel_ind=1)
    dstat->cnt = (dstat->cnt+ 1), stat = alterlist(dstat->qual,dstat->cnt), dstat->qual[dstat->cnt].
    dstat_code_value = cve.code_value
   ENDIF
  WITH nocounter
 ;end select
 CALL echo("Filling Order Server Request")
 SET hold->enc_cnt = 0
 CALL echo(build("extend cd is:",extended_cd))
 CALL echo(build("now_minus_days:",now_minus_days))
 CALL echo(build("now_minus_hours:",now_minus_hours))
 IF (dsch_cancel_flag=1)
  SELECT
   IF (curutc
    AND org_size_cnt > 0)INTO "nl:"
    e.encntr_id, o.order_id
    FROM encntr_leave l,
     encounter e,
     orders o
    PLAN (l
     WHERE l.leave_ind=1
      AND l.leave_type_cd=extended_cd
      AND ((l.leave_dt_tm+ 0) > cnvtdatetime(now_minus_days))
      AND ((l.leave_dt_tm+ 0) < cnvtdatetime(now_minus_hours)))
     JOIN (e
     WHERE l.encntr_id=e.encntr_id
      AND ((e.disch_dt_tm+ 0)=null)
      AND ((e.encntr_status_cd+ 0)=active_cd)
      AND expand(orgnum,1,org_size_cnt,e.organization_id,orgs_in_tz_inc->orgs[orgnum].org_id))
     JOIN (o
     WHERE o.encntr_id=e.encntr_id
      AND ((o.order_status_cd+ 0) IN (cval->ordered_status_cd, cval->inprocess_status_cd, cval->
     medstudent_status_cd, cval->incomplete_status_cd, cval->pending_status_cd,
     cval->suspended_status_cd))
      AND o.orig_ord_as_flag IN (0, 5)
      AND o.template_order_flag IN (0, 1, 2))
    ORDER BY e.encntr_id
   ELSE INTO "nl:"
    e.encntr_id, o.order_id
    FROM encntr_leave l,
     encounter e,
     orders o
    PLAN (l
     WHERE l.leave_ind=1
      AND l.leave_type_cd=extended_cd
      AND ((l.leave_dt_tm+ 0) > cnvtdatetime(now_minus_days))
      AND ((l.leave_dt_tm+ 0) < cnvtdatetime(now_minus_hours)))
     JOIN (e
     WHERE l.encntr_id=e.encntr_id
      AND ((e.disch_dt_tm+ 0)=null)
      AND ((e.encntr_status_cd+ 0)=active_cd))
     JOIN (o
     WHERE o.encntr_id=e.encntr_id
      AND ((o.order_status_cd+ 0) IN (cval->ordered_status_cd, cval->inprocess_status_cd, cval->
     medstudent_status_cd, cval->incomplete_status_cd, cval->pending_status_cd,
     cval->suspended_status_cd))
      AND o.orig_ord_as_flag IN (0, 5)
      AND o.template_order_flag IN (0, 1, 2))
    ORDER BY e.encntr_id
   ENDIF
   HEAD e.encntr_id
    hold->enc_cnt = (hold->enc_cnt+ 1)
    IF ((hold->enc_cnt > size(hold->enc,5)))
     stat = alterlist(hold->enc,(hold->enc_cnt+ 5))
    ENDIF
    hold->enc[hold->enc_cnt].ord_cnt = 0, hold->enc[hold->enc_cnt].encntr_id = e.encntr_id
   DETAIL
    cancel_ind = 0
    FOR (dd = 1 TO dstat->cnt)
      IF ((dstat->qual[dd].dstat_code_value=o.dept_status_cd))
       IF (check_start_ind=1)
        start_check_time = datetimeadd(l.leave_dt_tm,(start_plus_hrs/ 24.0))
        IF (o.current_start_dt_tm > cnvtdatetime(start_check_time))
         cancel_ind = 1
        ENDIF
       ELSE
        cancel_ind = 1
       ENDIF
      ENDIF
    ENDFOR
    IF (((o.template_order_flag=1) OR (((o.prn_ind=1) OR (((o.constant_ind=1) OR (o.freq_type_flag=5
    )) )) )) )
     cancel_ind = 1
    ENDIF
    IF (cancel_ind=1)
     hold->enc[hold->enc_cnt].ord_cnt = (hold->enc[hold->enc_cnt].ord_cnt+ 1), oc = hold->enc[hold->
     enc_cnt].ord_cnt
     IF (oc > size(hold->enc[hold->enc_cnt].ord,5))
      stat = alterlist(hold->enc[hold->enc_cnt].ord,(oc+ 10))
     ENDIF
     hold->enc[hold->enc_cnt].ord[oc].order_id = o.order_id, hold->enc[hold->enc_cnt].ord[oc].
     catalog_cd = o.catalog_cd, hold->enc[hold->enc_cnt].ord[oc].catalog_type_cd = o.catalog_type_cd,
     hold->enc[hold->enc_cnt].ord[oc].updt_cnt = o.updt_cnt, hold->enc[hold->enc_cnt].ord[oc].
     oe_format_id = o.oe_format_id
     IF (o.current_start_dt_tm < cnvtdatetime(curdate,curtime3)
      AND (o.order_status_cd != cval->medstudent_status_cd))
      hold->enc[hold->enc_cnt].ord[oc].order_status_cd = cval->discontinued_status_cd, hold->enc[hold
      ->enc_cnt].ord[oc].action_type_cd = cval->discontinue_action_cd, hold->enc[hold->enc_cnt].ord[
      oc].action = "DISCONTINUE"
     ELSE
      hold->enc[hold->enc_cnt].ord[oc].order_status_cd = cval->cancel_status_cd, hold->enc[hold->
      enc_cnt].ord[oc].action_type_cd = cval->cancel_action_cd, hold->enc[hold->enc_cnt].ord[oc].
      action = "CANCEL"
     ENDIF
    ENDIF
   FOOT  e.encntr_id
    stat = alterlist(hold->enc[hold->enc_cnt].ord,oc)
   WITH nocounter
  ;end select
  IF ((hold->enc_cnt=0))
   CALL echo("exit_script called4:**")
   GO TO exit_script
  ENDIF
 ENDIF
 CALL echo("record structure is: ****")
 CALL echorecord(hold)
 IF (dsch_cancel_flag=2)
  SELECT
   IF (curutc
    AND org_size_cnt > 0)INTO "nl:"
    e.encntr_id, o.order_id, oc.catalog_cd
    FROM encntr_leave l,
     encounter e,
     orders o,
     order_catalog oc
    PLAN (l
     WHERE l.leave_ind=1
      AND l.leave_type_cd=extended_cd
      AND ((l.leave_dt_tm+ 0) > cnvtdatetime(now_minus_days))
      AND ((l.leave_dt_tm+ 0) < cnvtdatetime(now_minus_hours)))
     JOIN (e
     WHERE l.encntr_id=e.encntr_id
      AND ((e.disch_dt_tm+ 0)=null)
      AND ((e.encntr_status_cd+ 0)=active_cd)
      AND expand(orgnum,1,org_size_cnt,e.organization_id,orgs_in_tz_inc->orgs[orgnum].org_id))
     JOIN (o
     WHERE o.encntr_id=e.encntr_id
      AND ((o.order_status_cd+ 0) IN (cval->ordered_status_cd, cval->inprocess_status_cd, cval->
     medstudent_status_cd, cval->incomplete_status_cd, cval->pending_status_cd,
     cval->suspended_status_cd))
      AND o.orig_ord_as_flag IN (0, 5)
      AND ((o.template_order_flag+ 0) IN (0, 1, 2)))
     JOIN (oc
     WHERE oc.catalog_cd=o.catalog_cd)
    ORDER BY e.encntr_id
   ELSE INTO "nl:"
    e.encntr_id, o.order_id, oc.catalog_cd
    FROM encntr_leave l,
     encounter e,
     orders o,
     order_catalog oc
    PLAN (l
     WHERE l.leave_ind=1
      AND l.leave_type_cd=extended_cd
      AND ((l.leave_dt_tm+ 0) > cnvtdatetime(now_minus_days))
      AND ((l.leave_dt_tm+ 0) < cnvtdatetime(now_minus_hours)))
     JOIN (e
     WHERE l.encntr_id=e.encntr_id
      AND ((e.disch_dt_tm+ 0)=null)
      AND ((e.encntr_status_cd+ 0)=active_cd))
     JOIN (o
     WHERE o.encntr_id=e.encntr_id
      AND ((o.order_status_cd+ 0) IN (cval->ordered_status_cd, cval->inprocess_status_cd, cval->
     medstudent_status_cd, cval->incomplete_status_cd, cval->pending_status_cd,
     cval->suspended_status_cd))
      AND o.orig_ord_as_flag IN (0, 5)
      AND ((o.template_order_flag+ 0) IN (0, 1, 2)))
     JOIN (oc
     WHERE oc.catalog_cd=o.catalog_cd)
    ORDER BY e.encntr_id
   ENDIF
   HEAD e.encntr_id
    hold->enc_cnt = (hold->enc_cnt+ 1)
    IF ((hold->enc_cnt > size(hold->enc,5)))
     stat = alterlist(hold->enc,(hold->enc_cnt+ 5))
    ENDIF
    hold->enc[hold->enc_cnt].ord_cnt = 0, hold->enc[hold->enc_cnt].encntr_id = e.encntr_id
   DETAIL
    cancel_ind = 0
    FOR (dd = 1 TO dstat->cnt)
      IF ((dstat->qual[dd].dstat_code_value=o.dept_status_cd))
       IF (check_start_ind=1)
        start_check_time = datetimeadd(l.leave_dt_tm,(start_plus_hrs/ 24.0))
        IF (o.current_start_dt_tm > cnvtdatetime(start_check_time))
         cancel_ind = 1
        ENDIF
       ELSE
        cancel_ind = 1
       ENDIF
      ENDIF
    ENDFOR
    orc_cancel_ind = 0
    IF (((o.template_order_flag=1) OR (((o.prn_ind=1) OR (((o.constant_ind=1) OR (((oc
    .auto_cancel_ind=1) OR (o.freq_type_flag=5)) )) )) )) )
     orc_cancel_ind = 1
     IF (((o.template_order_flag=1) OR (((o.prn_ind=1) OR (((o.constant_ind=1) OR (o.freq_type_flag=5
     )) )) )) )
      cancel_ind = 1
     ENDIF
    ENDIF
    IF (cancel_ind=1
     AND orc_cancel_ind=1)
     hold->enc[hold->enc_cnt].ord_cnt = (hold->enc[hold->enc_cnt].ord_cnt+ 1), oc = hold->enc[hold->
     enc_cnt].ord_cnt
     IF (oc > size(hold->enc[hold->enc_cnt].ord,5))
      stat = alterlist(hold->enc[hold->enc_cnt].ord,(oc+ 10))
     ENDIF
     hold->enc[hold->enc_cnt].ord[oc].order_id = o.order_id, hold->enc[hold->enc_cnt].ord[oc].
     catalog_cd = o.catalog_cd, hold->enc[hold->enc_cnt].ord[oc].catalog_type_cd = o.catalog_type_cd,
     hold->enc[hold->enc_cnt].ord[oc].updt_cnt = o.updt_cnt, hold->enc[hold->enc_cnt].ord[oc].
     oe_format_id = o.oe_format_id
     IF (o.current_start_dt_tm < cnvtdatetime(curdate,curtime3)
      AND (o.order_status_cd != cval->medstudent_status_cd))
      hold->enc[hold->enc_cnt].ord[oc].order_status_cd = cval->discontinued_status_cd, hold->enc[hold
      ->enc_cnt].ord[oc].action_type_cd = cval->discontinue_action_cd, hold->enc[hold->enc_cnt].ord[
      oc].action = "DISCONTINUE"
     ELSE
      hold->enc[hold->enc_cnt].ord[oc].order_status_cd = cval->cancel_status_cd, hold->enc[hold->
      enc_cnt].ord[oc].action_type_cd = cval->cancel_action_cd, hold->enc[hold->enc_cnt].ord[oc].
      action = "CANCEL"
     ENDIF
    ENDIF
   FOOT  e.encntr_id
    stat = alterlist(hold->enc[hold->enc_cnt].ord,oc)
   WITH nocounter
  ;end select
  IF ((hold->enc_cnt=0))
   CALL echo("exit_script called5:**")
   GO TO exit_script
  ENDIF
 ENDIF
 CALL echo("record structure is: ****")
 CALL echorecord(hold)
 IF (dsch_cancel_flag=3)
  SELECT
   IF (curutc
    AND org_size_cnt > 0)INTO "nl:"
    e.encntr_id, o.order_id
    FROM encntr_leave l,
     encounter e,
     orders o
    PLAN (l
     WHERE l.leave_ind=1
      AND l.leave_type_cd=extended_cd
      AND ((l.leave_dt_tm+ 0) > cnvtdatetime(now_minus_days))
      AND ((l.leave_dt_tm+ 0) < cnvtdatetime(now_minus_hours)))
     JOIN (e
     WHERE l.encntr_id=e.encntr_id
      AND ((e.disch_dt_tm+ 0)=null)
      AND ((e.encntr_status_cd+ 0)=active_cd)
      AND expand(orgnum,1,org_size_cnt,e.organization_id,orgs_in_tz_inc->orgs[orgnum].org_id))
     JOIN (o
     WHERE o.encntr_id=e.encntr_id
      AND ((o.order_status_cd+ 0) IN (cval->ordered_status_cd, cval->inprocess_status_cd, cval->
     medstudent_status_cd, cval->incomplete_status_cd, cval->pending_status_cd,
     cval->suspended_status_cd))
      AND o.orig_ord_as_flag IN (0, 5)
      AND ((o.template_order_flag=1) OR (((o.prn_ind=1) OR (((o.constant_ind=1) OR (o.freq_type_flag=
     5)) )) )) )
    ORDER BY e.encntr_id
   ELSE INTO "nl:"
    e.encntr_id, o.order_id
    FROM encntr_leave l,
     encounter e,
     orders o
    PLAN (l
     WHERE l.leave_ind=1
      AND l.leave_type_cd=extended_cd
      AND ((l.leave_dt_tm+ 0) > cnvtdatetime(now_minus_days))
      AND ((l.leave_dt_tm+ 0) < cnvtdatetime(now_minus_hours)))
     JOIN (e
     WHERE l.encntr_id=e.encntr_id
      AND ((e.disch_dt_tm+ 0)=null)
      AND ((e.encntr_status_cd+ 0)=active_cd))
     JOIN (o
     WHERE o.encntr_id=e.encntr_id
      AND ((o.order_status_cd+ 0) IN (cval->ordered_status_cd, cval->inprocess_status_cd, cval->
     medstudent_status_cd, cval->incomplete_status_cd, cval->pending_status_cd,
     cval->suspended_status_cd))
      AND o.orig_ord_as_flag IN (0, 5)
      AND ((o.template_order_flag=1) OR (((o.prn_ind=1) OR (((o.constant_ind=1) OR (o.freq_type_flag=
     5)) )) )) )
    ORDER BY e.encntr_id
   ENDIF
   HEAD e.encntr_id
    hold->enc_cnt = (hold->enc_cnt+ 1)
    IF ((hold->enc_cnt > size(hold->enc,5)))
     stat = alterlist(hold->enc,(hold->enc_cnt+ 5))
    ENDIF
    hold->enc[hold->enc_cnt].ord_cnt = 0, hold->enc[hold->enc_cnt].encntr_id = e.encntr_id
   DETAIL
    hold->enc[hold->enc_cnt].ord_cnt = (hold->enc[hold->enc_cnt].ord_cnt+ 1), oc = hold->enc[hold->
    enc_cnt].ord_cnt
    IF (oc > size(hold->enc[hold->enc_cnt].ord,5))
     stat = alterlist(hold->enc[hold->enc_cnt].ord,(oc+ 10))
    ENDIF
    hold->enc[hold->enc_cnt].ord[oc].order_id = o.order_id, hold->enc[hold->enc_cnt].ord[oc].
    catalog_cd = o.catalog_cd, hold->enc[hold->enc_cnt].ord[oc].catalog_type_cd = o.catalog_type_cd,
    hold->enc[hold->enc_cnt].ord[oc].updt_cnt = o.updt_cnt, hold->enc[hold->enc_cnt].ord[oc].
    oe_format_id = o.oe_format_id
    IF (o.current_start_dt_tm < cnvtdatetime(curdate,curtime3)
     AND (o.order_status_cd != cval->medstudent_status_cd))
     hold->enc[hold->enc_cnt].ord[oc].order_status_cd = cval->discontinued_status_cd, hold->enc[hold
     ->enc_cnt].ord[oc].action_type_cd = cval->discontinue_action_cd, hold->enc[hold->enc_cnt].ord[oc
     ].action = "DISCONTINUE"
    ELSE
     hold->enc[hold->enc_cnt].ord[oc].order_status_cd = cval->cancel_status_cd, hold->enc[hold->
     enc_cnt].ord[oc].action_type_cd = cval->cancel_action_cd, hold->enc[hold->enc_cnt].ord[oc].
     action = "CANCEL"
    ENDIF
   FOOT  e.encntr_id
    stat = alterlist(hold->enc[hold->enc_cnt].ord,oc)
   WITH nocounter
  ;end select
  IF ((hold->enc_cnt=0))
   CALL echo("exit_script #6:**")
   GO TO exit_script
  ENDIF
 ENDIF
 SET stat = alterlist(hold->enc,hold->enc_cnt)
 IF ((hold->enc_cnt > 0))
  FOR (encntr = 1 TO hold->enc_cnt)
    SET buf = uar_fill_order_request()
    IF (buf > 0)
     SET reply->status_data.subeventstatus[1].operationname = "dcp_ops_inp_dc_orders"
     SET reply->status_data.subeventstatus[1].operationstatus = "F"
     SET reply->status_data.subeventstatus[1].targetobjectname = "uar_fill_order_request"
     SET reply->status_data.subeventstatus[1].targetobjectvalue = cnvtstring(buf)
     SET failed_ind = 1
    ENDIF
    IF (failed_ind=0
     AND (hold->enc[encntr].ord_cnt > 0))
     FOR (ord = 1 TO hold->enc[encntr].ord_cnt)
       IF ((hold->enc[encntr].ord[ord].order_id > 0))
        SET buf = uar_fill_order_dc(hold->enc[encntr].ord[ord].order_id,hold->enc[encntr].ord[ord].
         order_status_cd,hold->enc[encntr].ord[ord].action_type_cd,hold->enc[encntr].ord[ord].action,
         hold->enc[encntr].ord[ord].catalog_cd,
         hold->enc[encntr].ord[ord].catalog_type_cd,hold->enc[encntr].ord[ord].updt_cnt,hold->enc[
         encntr].ord[ord].oe_format_id,cval->disc_type_cd)
        IF (buf > 0)
         SET reply->status_data.subeventstatus[1].operationname = "dcp_ops_inp_dc_orders"
         SET reply->status_data.subeventstatus[1].operationstatus = "F"
         SET reply->status_data.subeventstatus[1].targetobjectname = "uar_fill_order_dc"
         SET reply->status_data.subeventstatus[1].targetobjectvalue = cnvtstring(buf)
         SET failed_ind = 1
         CALL echo("exit_script #7:**")
         GO TO exit_script
        ENDIF
       ENDIF
     ENDFOR
     IF (failed_ind=0)
      CALL echo("Calling Order Write Synch Server")
      SET buf = uar_order_perform()
      CALL echo("Back from Order Server")
      IF (buf > 0)
       SET reply->status_data.subeventstatus[1].operationname = "dcp_ops_inp_dc_orders"
       SET reply->status_data.subeventstatus[1].operationstatus = "F"
       SET reply->status_data.subeventstatus[1].targetobjectname = "uar_order_perform"
       SET reply->status_data.subeventstatus[1].targetobjectvalue = cnvtstring(buf)
       SET failed_ind = 1
      ENDIF
     ENDIF
    ENDIF
  ENDFOR
 ENDIF
 CALL echo("record structure is: ****")
 CALL echorecord(hold)
#exit_script
 IF (failed_ind=0)
  SET reply->status_data.status = "S"
  CALL echo(build("status ",reply->status_data.status))
 ELSE
  SET reply->status_data.status = "F"
  CALL echo(build("status ",reply->status_data.status))
  CALL echo(build("failed uar:",reply->status_data.subeventstatus[1].targetobjectname))
  CALL echo(build("buf string: ",reply->status_data.subeventstatus[1].targetobjectvalue))
 ENDIF
END GO
