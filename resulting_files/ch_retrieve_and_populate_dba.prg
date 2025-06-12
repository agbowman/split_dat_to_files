CREATE PROGRAM ch_retrieve_and_populate:dba
 DECLARE log_program_name = vc WITH protect, noconstant("")
 DECLARE log_override_ind = i2 WITH protect, noconstant(0)
 SET log_program_name = curprog
 SET log_override_ind = 0
 DECLARE log_level_error = i2 WITH protect, noconstant(0)
 DECLARE log_level_warning = i2 WITH protect, noconstant(1)
 DECLARE log_level_audit = i2 WITH protect, noconstant(2)
 DECLARE log_level_info = i2 WITH protect, noconstant(3)
 DECLARE log_level_debug = i2 WITH protect, noconstant(4)
 DECLARE hsys = i4 WITH protect, noconstant(0)
 DECLARE sysstat = i4 WITH protect, noconstant(0)
 DECLARE serrmsg = c132 WITH protect, noconstant(" ")
 DECLARE ierrcode = i4 WITH protect, noconstant(error(serrmsg,1))
 DECLARE crsl_msg_default = h WITH protect, noconstant(0)
 DECLARE crsl_msg_level = h WITH protect, noconstant(0)
 EXECUTE msgrtl
 SET crsl_msg_default = uar_msgdefhandle()
 SET crsl_msg_level = uar_msggetlevel(crsl_msg_default)
 DECLARE lcrslsubeventcnt = i4 WITH protect, noconstant(0)
 DECLARE icrslloggingstat = i2 WITH protect, noconstant(0)
 DECLARE lcrslsubeventsize = i4 WITH protect, noconstant(0)
 DECLARE icrslloglvloverrideind = i2 WITH protect, noconstant(0)
 DECLARE scrsllogtext = vc WITH protect, noconstant("")
 DECLARE scrsllogevent = vc WITH protect, noconstant("")
 DECLARE icrslholdloglevel = i2 WITH protect, noconstant(0)
 DECLARE icrslerroroccured = i2 WITH protect, noconstant(0)
 DECLARE lcrsluarmsgwritestat = i4 WITH protect, noconstant(0)
 DECLARE crsl_info_domain = vc WITH protect, constant("CLINRPT SCRIPT LOGGING")
 DECLARE crsl_logging_on = c1 WITH protect, constant("L")
 SELECT INTO "nl:"
  FROM dm_info dm
  PLAN (dm
   WHERE dm.info_domain=crsl_info_domain
    AND dm.info_name=curprog)
  DETAIL
   IF (dm.info_char=crsl_logging_on)
    log_override_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 SUBROUTINE (log_message(logmsg=vc,loglvl=i4) =null)
   SET icrslloglvloverrideind = 0
   SET scrsllogtext = ""
   SET scrsllogevent = ""
   SET scrsllogtext = concat("{{Script::",value(log_program_name),"}} ",logmsg)
   IF (log_override_ind=0)
    SET icrslholdloglevel = loglvl
   ELSE
    IF (crsl_msg_level < loglvl)
     SET icrslholdloglevel = crsl_msg_level
     SET icrslloglvloverrideind = 1
    ELSE
     SET icrslholdloglevel = loglvl
    ENDIF
   ENDIF
   IF (icrslloglvloverrideind=1)
    SET scrsllogevent = "Script_Override"
   ELSE
    CASE (icrslholdloglevel)
     OF log_level_error:
      SET scrsllogevent = "Script_Error"
     OF log_level_warning:
      SET scrsllogevent = "Script_Warning"
     OF log_level_audit:
      SET scrsllogevent = "Script_Audit"
     OF log_level_info:
      SET scrsllogevent = "Script_Info"
     OF log_level_debug:
      SET scrsllogevent = "Script_Debug"
    ENDCASE
   ENDIF
   SET lcrsluarmsgwritestat = uar_msgwrite(crsl_msg_default,0,nullterm(scrsllogevent),
    icrslholdloglevel,nullterm(scrsllogtext))
   CALL echo(logmsg)
 END ;Subroutine
 SUBROUTINE (error_message(logstatusblockind=i2) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     SET reply->status_data.status = "F"
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus(opname,"F",serrmsg,logmsg)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   IF (icrslerroroccured=1
    AND errorforceexit=1)
    SET reply->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF (qualnum=0
    AND zeroforceexit=1)
    SET reply->status_data.status = "Z"
    CALL populate_subeventstatus(opname,"Z","No records qualified",logmsg)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   IF (validate(reply->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(reply->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      operationstatus))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectname))
    SET lcrslsubeventsize += size(trim(reply->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectvalue))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt += 1
     SET icrslloggingstat = alter(reply->status_data.subeventstatus,lcrslsubeventcnt)
    ENDIF
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET reply->status_data.subeventstatus[lcrslsubeventcnt].targetobjectvalue = targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_msg(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),loglevel=i2(value)) =i2)
  CALL populate_subeventstatus(operationname,operationstatus,targetobjectname,targetobjectvalue)
  CALL log_message(targetobjectvalue,loglevel)
 END ;Subroutine
 SUBROUTINE (check_log_level(arg_log_level=i4) =i2)
   IF (((crsl_msg_level >= arg_log_level) OR (log_override_ind=1)) )
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
 SET log_program_name = "CH_RETRIEVE_AND_POPULATE"
 RECORD reply(
   1 distribution_id = f8
   1 dist_type = i4
   1 days_till_chart = i4
   1 sort_sequence_flag = i2
   1 reader_group = c15
   1 cutoff_pages = i4
   1 cutoff_days = i4
   1 cutoff_and_or_ind = i2
   1 banner_page = vc
   1 delete_old_distr_flag = i2
   1 max_lookback_days = i4
   1 print_lookback_ind = i2
   1 dist_filter[*]
     2 type_flag = i2
     2 included_flag = i2
     2 filter_value[*]
       3 filter_value_cd = f8
       3 filter_description = vc
       3 cdf_meaning = c12
   1 prov_filter[*]
     2 provider_id = f8
     2 provider_name = vc
     2 qual[*]
       3 prov_type_cd = f8
   1 related_ops[*]
     2 batch_name = vc
     2 run_type_cd = f8
     2 qualified_date_str = vc
     2 chart_format_id = f8
     2 report_template_id = f8
   1 last_update = vc
   1 max_lookback_dt_tm = dq8
   1 max_lookback_ind = i2
   1 first_qualification_days = i4
   1 first_qualification_dt_tm = dq8
   1 absolute_qualification_days = i4
   1 absolute_qualification_dt_tm = dq8
   1 absolute_lookback_ind = i2
   1 no_label_updt_dt_tm = dq8
   1 modifier_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE populateproviderarray(null) = null
 DECLARE getlastdistributionupdate(null) = null
 DECLARE getdistributiondetails(null) = null
 DECLARE getopsjobs(null) = null
 DECLARE getlastdistributionqualification(null) = null
 FREE RECORD prov_array
 RECORD prov_array(
   1 qual[*]
     2 provider_id = f8
     2 provider_name = vc
     2 reltn_type[*]
       3 prov_type_cd = f8
 )
 SET reply->status_data.status = "F"
 DECLARE start_name = f8 WITH noconstant(0.0)
 SET filter_count = 0
 SET filter_value_count = 0
 SET start_name = request->start_name
 SET size_of_prov = 0
 CALL log_message("Start of script: ch_retrieve_and_populate",log_level_debug)
 CALL populateproviderarray(null)
 CALL getlastdistributionupdate(null)
 CALL getdistributiondetails(null)
 CALL getopsjobs(null)
 CALL getlastdistributionqualification(null)
 SET reply->status_data.status = "S"
 SUBROUTINE populateproviderarray(null)
   CALL log_message("In PopulateProviderArray()",log_level_debug)
   SELECT INTO "nl:"
    FROM chart_dist_filter_value cdfv
    WHERE cdfv.distribution_id=start_name
     AND cdfv.type_flag=2
    ORDER BY cdfv.description, cdfv.parent_entity_id
    HEAD REPORT
     distinct_prov_id_cnt = 0
    HEAD cdfv.description
     donothing = 0
    HEAD cdfv.parent_entity_id
     cnt1 = 0, distinct_prov_id_cnt += 1
     IF (mod(distinct_prov_id_cnt,10)=1)
      stat = alterlist(reply->prov_filter,(distinct_prov_id_cnt+ 9))
     ENDIF
     reply->prov_filter[distinct_prov_id_cnt].provider_id = cdfv.parent_entity_id, reply->
     prov_filter[distinct_prov_id_cnt].provider_name = cdfv.description
    DETAIL
     cnt1 += 1
     IF (mod(cnt1,10)=1)
      stat = alterlist(reply->prov_filter[distinct_prov_id_cnt].qual,(cnt1+ 9))
     ENDIF
     reply->prov_filter[distinct_prov_id_cnt].qual[cnt1].prov_type_cd = cdfv.reltn_type_cd
    FOOT  cdfv.parent_entity_id
     stat = alterlist(reply->prov_filter[distinct_prov_id_cnt].qual,cnt1)
    FOOT  cdfv.description
     donothing = 0
    FOOT REPORT
     stat = alterlist(reply->prov_filter,distinct_prov_id_cnt)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_DIST_FILTER_VALUE","POPULATEPROVIDERARRAY",1,0)
 END ;Subroutine
 SUBROUTINE getlastdistributionupdate(null)
   CALL log_message("In GetLastDistributionUpdate()",log_level_debug)
   SELECT INTO "nl:"
    p.name_full_formatted, name = trim(substring(1,30,p.name_full_formatted)), cd.updt_dt_tm
    FROM chart_distribution cd,
     prsnl p
    PLAN (cd
     WHERE cd.distribution_id=start_name)
     JOIN (p
     WHERE p.person_id=cd.updt_id)
    HEAD REPORT
     reply->last_update = fillstring(100," ")
    DETAIL
     reply->last_update = concat("Last modified by: ",trim(name),"  (",format(cd.updt_dt_tm,
       "@SHORTDATETIME"),")"), reply->no_label_updt_dt_tm = cd.updt_dt_tm, reply->modifier_name =
     trim(name)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"PRSNL","GETLASTDISTRIBUTIONUPDATE",1,0)
 END ;Subroutine
 SUBROUTINE getdistributiondetails(null)
   CALL log_message("In GetDistributionDetails()",log_level_debug)
   SELECT INTO "nl:"
    c.distribution_id, cdf.type_flag, cdfv.parent_entity_id
    FROM chart_distribution c,
     chart_dist_filter cdf,
     chart_dist_filter_value cdfv,
     (dummyt t1  WITH seq = 1),
     (dummyt t2  WITH seq = 1),
     dummyt d1,
     organization o,
     dummyt d2
    PLAN (c
     WHERE c.distribution_id=start_name
      AND c.active_ind=1)
     JOIN (t1)
     JOIN (cdf
     WHERE cdf.distribution_id=c.distribution_id)
     JOIN (t2)
     JOIN (cdfv
     WHERE cdfv.distribution_id=cdf.distribution_id
      AND cdfv.type_flag=cdf.type_flag)
     JOIN (d1)
     JOIN (d2)
     JOIN (o
     WHERE o.organization_id=cdfv.parent_entity_id)
    ORDER BY cdfv.type_flag, cdfv.description
    HEAD REPORT
     reply->distribution_id = c.distribution_id, reply->dist_type = c.dist_type, reply->
     days_till_chart = c.days_till_chart,
     reply->sort_sequence_flag = c.sort_sequence_flag, reply->reader_group = c.reader_group, reply->
     cutoff_pages = c.cutoff_pages,
     reply->cutoff_days = c.cutoff_days, reply->cutoff_and_or_ind = c.cutoff_and_or_ind, reply->
     banner_page = c.banner_page,
     reply->delete_old_distr_flag = c.delete_old_distr_flag, reply->max_lookback_days = c
     .max_lookback_days, reply->print_lookback_ind = c.print_lookback_ind,
     reply->max_lookback_dt_tm = c.max_lookback_dt_tm, reply->max_lookback_ind = c.max_lookback_ind,
     reply->first_qualification_days = c.first_qualification_days,
     reply->first_qualification_dt_tm = c.first_qualification_dt_tm, reply->
     absolute_qualification_days = c.absolute_qualification_days, reply->absolute_qualification_dt_tm
      = c.absolute_qualification_dt_tm,
     reply->absolute_lookback_ind = c.absolute_lookback_ind
    HEAD cdf.type_flag
     filter_value_count = 0, filter_count += 1
     IF (mod(filter_count,10)=1)
      stat = alterlist(reply->dist_filter[filter_count],(filter_count+ 10))
     ENDIF
     reply->dist_filter[filter_count].type_flag = cdf.type_flag, reply->dist_filter[filter_count].
     included_flag = cdf.included_flag
    DETAIL
     IF (cdfv.type_flag != 2)
      filter_value_count += 1
      IF (mod(filter_value_count,10)=1)
       stat = alterlist(reply->dist_filter[filter_count].filter_value,(filter_value_count+ 10))
      ENDIF
      reply->dist_filter[filter_count].filter_value[filter_value_count].filter_value_cd = cdfv
      .parent_entity_id
      IF (cdfv.type_flag IN (0, 3, 4, 5))
       reply->dist_filter[filter_count].filter_value[filter_value_count].filter_description =
       uar_get_code_description(cdfv.parent_entity_id)
      ELSEIF (cdfv.type_flag=1)
       reply->dist_filter[filter_count].filter_value[filter_value_count].filter_description = o
       .org_name
      ENDIF
      IF (cdfv.type_flag=3)
       reply->dist_filter[filter_count].filter_value[filter_value_count].cdf_meaning =
       uar_get_code_meaning(cdfv.parent_entity_id)
      ELSE
       reply->dist_filter[filter_count].filter_value[filter_value_count].cdf_meaning = " "
      ENDIF
     ENDIF
    FOOT  cdf.type_flag
     stat = alterlist(reply->dist_filter[filter_count].filter_value,filter_value_count)
    FOOT REPORT
     stat = alterlist(reply->dist_filter[filter_count],filter_count)
    WITH nocounter, outerjoin = d1, outerjoin = d2,
     dontcare = o
   ;end select
   CALL error_and_zero_check(curqual,"CHART_DISTRIBUTION","GETDISTRIBUTIONDETAILS",1,0)
 END ;Subroutine
 SUBROUTINE getopsjobs(null)
   CALL log_message("In GetOpsJobs()",log_level_debug)
   SELECT DISTINCT INTO "nl:"
    co.batch_name
    FROM charting_operations co,
     charting_operations co2,
     charting_operations co3
    PLAN (co
     WHERE co.active_ind=1
      AND co.param=cnvtstring(reply->distribution_id)
      AND co.param_type_flag=2)
     JOIN (co2
     WHERE co2.charting_operations_id=co.charting_operations_id
      AND co2.param_type_flag=3)
     JOIN (co3
     WHERE co3.charting_operations_id=co.charting_operations_id
      AND co3.param_type_flag=4)
    ORDER BY co.batch_name
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt += 1, stat = alterlist(reply->related_ops,cnt), reply->related_ops[cnt].batch_name = co
     .batch_name,
     reply->related_ops[cnt].run_type_cd = cnvtreal(co2.param), reply->related_ops[cnt].
     report_template_id = cnvtreal(co3.param)
    WITH nocounter
   ;end select
   DECLARE itotal = i4 WITH constant(size(reply->related_ops,5)), protect
   DECLARE idx = i4 WITH noconstant(0)
   DECLARE idx2 = i4 WITH noconstant(0)
   SELECT DISTINCT INTO "nl:"
    FROM chart_format cf
    WHERE expand(idx,1,itotal,cf.chart_format_id,reply->related_ops[idx].report_template_id)
    DETAIL
     index = locateval(idx2,1,itotal,cf.chart_format_id,reply->related_ops[idx2].report_template_id)
     WHILE (index != 0)
       reply->related_ops[index].report_template_id = 0, reply->related_ops[index].chart_format_id =
       cf.chart_format_id, index = locateval(idx2,(index+ 1),itotal,cf.chart_format_id,reply->
        related_ops[idx2].report_template_id)
     ENDWHILE
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHARTING_OPERATIONS","GETOPSJOBS",1,0)
 END ;Subroutine
 SUBROUTINE getlastdistributionqualification(null)
   CALL log_message("In GetLastDistributionQualification()",log_level_debug)
   DECLARE idx = i4 WITH noconstant(0)
   DECLARE itotal = i4 WITH constant(size(reply->related_ops,5)), protect
   DECLARE idx2 = i4 WITH noconstant(0)
   SET count = 0
   IF (itotal > 0)
    SELECT INTO "nl:"
     FROM chart_request cr
     WHERE (cr.distribution_id=reply->distribution_id)
      AND expand(idx,1,itotal,cr.dist_run_type_cd,reply->related_ops[idx].run_type_cd)
     ORDER BY cr.dist_run_type_cd, cr.dist_run_dt_tm DESC
     HEAD cr.dist_run_type_cd
      index = locateval(idx2,1,itotal,cr.dist_run_type_cd,reply->related_ops[idx2].run_type_cd)
      WHILE (index != 0)
       IF ((reply->related_ops[index].chart_format_id != 0))
        reply->related_ops[index].qualified_date_str = format(cr.dist_run_dt_tm,"@SHORTDATETIME"),
        count += 1
       ENDIF
       ,index = locateval(idx2,(index+ 1),itotal,cr.dist_run_type_cd,reply->related_ops[idx2].
        run_type_cd)
      ENDWHILE
     HEAD cr.dist_run_dt_tm
      donothing = 0
     DETAIL
      donothing = 0
     FOOT  cr.dist_run_dt_tm
      donothing = 0
     FOOT  cr.dist_run_type_cd
      donothing = 0
     WITH nocounter
    ;end select
    IF (count < itotal)
     DECLARE idx3 = i4 WITH noconstant(0)
     DECLARE idx4 = i4 WITH noconstant(0)
     SELECT INTO "nl:"
      FROM cr_report_request cr
      WHERE (cr.distribution_id=reply->distribution_id)
       AND expand(idx3,1,itotal,cr.dist_run_type_cd,reply->related_ops[idx3].run_type_cd)
      ORDER BY cr.dist_run_type_cd, cr.dist_run_dt_tm DESC
      HEAD cr.dist_run_type_cd
       index = locateval(idx4,1,itotal,cr.dist_run_type_cd,reply->related_ops[idx4].run_type_cd)
       WHILE (index != 0)
        IF ((reply->related_ops[index].report_template_id != 0))
         reply->related_ops[index].qualified_date_str = format(cr.dist_run_dt_tm,"@SHORTDATETIME")
        ENDIF
        ,index = locateval(idx4,(index+ 1),itotal,cr.dist_run_type_cd,reply->related_ops[idx4].
         run_type_cd)
       ENDWHILE
      HEAD cr.dist_run_dt_tm
       donothing = 0
      DETAIL
       donothing = 0
      FOOT  cr.dist_run_dt_tm
       donothing = 0
      FOOT  cr.dist_run_type_cd
       donothing = 0
      WITH nocounter
     ;end select
    ENDIF
    CALL error_and_zero_check(curqual,"CHART_REQUEST","GETLASTDISTRIBUTIONQUALIFICATION",1,0)
   ENDIF
 END ;Subroutine
#exit_script
 CALL log_message("End of script: ch_retrieve_and_populate",log_level_debug)
END GO
