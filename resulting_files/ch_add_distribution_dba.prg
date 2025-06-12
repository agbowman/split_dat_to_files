CREATE PROGRAM ch_add_distribution:dba
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
 SET log_program_name = "CH_ADD_DISTRIBUTION"
 RECORD reply(
   1 distribution_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE getuniquedistributionid(null) = f8
 DECLARE number_to_get = i4 WITH noconstant(0)
 DECLARE new_nbr = f8 WITH noconstant(0.0)
 DECLARE leaf_new_nbr = i4 WITH noconstant(0)
 DECLARE x = i4 WITH noconstant(0)
 DECLARE t = i4 WITH noconstant(0)
 DECLARE v = i4 WITH noconstant(0)
 DECLARE z = i4 WITH noconstant(0)
 DECLARE prov_type_cnt = i4 WITH noconstant(0)
 DECLARE prov_cnt = i4 WITH noconstant(0)
 DECLARE logical_domain_id = f8 WITH noconstant(0.0)
 DECLARE active_code = f8 WITH constant(uar_get_code_by("MEANING",48,"ACTIVE")), protect
 DECLARE dist_filter_desc_char_limit = i4 WITH constant(60)
 IF ((request->requesting_prsnl_id > 0.0))
  SELECT INTO "NL:"
   p.logical_domain_id
   FROM prsnl p,
    logical_domain ld
   PLAN (p
    WHERE (p.person_id=request->requesting_prsnl_id))
    JOIN (ld
    WHERE ld.logical_domain_id=p.logical_domain_id)
   DETAIL
    logical_domain_id = p.logical_domain_id
   WITH nocounter
  ;end select
 ENDIF
 CALL log_message("Start of script: ch_add_distribution",log_level_debug)
 SET reply->status_data.status = "F"
 SET new_nbr = getuniquedistributionid(null)
 CALL echo(build("new_nbr: ",new_nbr))
 CALL insertinfochartdistribution(new_nbr)
 CALL insertinfochartdistfilter(new_nbr)
 SET reqinfo->commit_ind = 1
 SET reply->status_data.status = "S"
 SUBROUTINE getuniquedistributionid(null)
   CALL log_message("In GetUniqueDistributionId()",log_level_debug)
   DECLARE new_distribution_id = f8 WITH noconstant(0.0), protect
   SELECT INTO "nl:"
    y = seq(reference_seq,nextval)
    FROM dual
    DETAIL
     new_distribution_id = y
    WITH format, counter
   ;end select
   CALL error_and_zero_check(curqual,"DUAL","GETUNIQUEDISTRIBUTIONID",1,1)
   SET reply->distribution_id = new_distribution_id
   RETURN(new_distribution_id)
 END ;Subroutine
 SUBROUTINE (insertinfochartdistribution(new_distribution_id=f8(ref)) =null)
   CALL log_message("In InsertInfoChartDistribution()",log_level_debug)
   INSERT  FROM chart_distribution c
    SET c.distribution_id = new_distribution_id, c.dist_descr = request->chart_distribution[1].
     dist_descr, c.dist_type = request->chart_distribution[1].dist_type,
     c.days_till_chart = request->chart_distribution[1].days_till_chart, c.sort_sequence_flag =
     request->chart_distribution[1].sort_sequence_flag, c.reader_group = request->chart_distribution[
     1].reader_group,
     c.cutoff_pages = request->chart_distribution[1].cutoff_pages, c.cutoff_days = request->
     chart_distribution[1].cutoff_days, c.cutoff_and_or_ind = request->chart_distribution[1].
     cutoff_and_or_ind,
     c.banner_page = request->chart_distribution[1].banner_page, c.delete_old_distr_flag = request->
     chart_distribution[1].delete_old_distr_flag, c.max_lookback_days = request->chart_distribution[1
     ].max_lookback_days,
     c.print_lookback_ind = request->chart_distribution[1].print_lookback_ind, c.max_lookback_dt_tm
      = cnvtdatetime(request->chart_distribution[1].max_lookback_dt_tm), c.max_lookback_ind = request
     ->chart_distribution[1].max_lookback_ind,
     c.first_qualification_days = request->chart_distribution[1].first_qualification_days, c
     .first_qualification_dt_tm = cnvtdatetime(request->chart_distribution[1].
      first_qualification_dt_tm), c.absolute_qualification_days = request->chart_distribution[1].
     absolute_qualification_days,
     c.absolute_qualification_dt_tm = cnvtdatetime(request->chart_distribution[1].
      absolute_qualification_dt_tm), c.absolute_lookback_ind = request->chart_distribution[1].
     absolute_lookback_ind, c.active_ind = 1,
     c.active_status_cd = active_code, c.active_status_prsnl_id = reqinfo->updt_id, c
     .active_status_dt_tm = cnvtdatetime(sysdate),
     c.updt_cnt = 0, c.updt_dt_tm = cnvtdatetime(curdate,curtime), c.updt_id = reqinfo->updt_id,
     c.updt_applctx = reqinfo->updt_applctx, c.updt_task = reqinfo->updt_task, c.logical_domain_id =
     logical_domain_id
    WITH nocounter
   ;end insert
   CALL error_and_zero_check(curqual,"CHART_DISTRIBUTION","INSERT",1,0)
 END ;Subroutine
 SUBROUTINE (insertinfochartdistfilter(new_distribution_id=f8(ref)) =null)
   CALL log_message("In InsertInfoChartDistFilter()",log_level_debug)
   DECLARE number_to_get = i4 WITH constant(size(request->chart_distribution[1].dist_filter,5))
   FOR (z = 1 TO number_to_get)
     INSERT  FROM chart_dist_filter cdf
      SET cdf.distribution_id = new_distribution_id, cdf.type_flag = request->chart_distribution[1].
       dist_filter[z].type_flag, cdf.included_flag = request->chart_distribution[1].dist_filter[z].
       include_flag,
       cdf.active_ind = 1, cdf.active_status_cd = active_code, cdf.active_status_prsnl_id = reqinfo->
       updt_id,
       cdf.active_status_dt_tm = cnvtdatetime(sysdate), cdf.updt_cnt = 0, cdf.updt_dt_tm =
       cnvtdatetime(curdate,curtime),
       cdf.updt_id = reqinfo->updt_id, cdf.updt_applctx = reqinfo->updt_applctx, cdf.updt_task =
       reqinfo->updt_task
      WITH nocounter
     ;end insert
     CALL error_and_zero_check(curqual,"CHART_DIST_FILTER","INSERT",1,0)
     SET sequence = 0
     IF ((request->chart_distribution[1].dist_filter[z].type_flag=2))
      SET prov_cnt = size(request->chart_distribution[1].prov_filter,5)
      FOR (x = 1 TO prov_cnt)
       SET prov_type_cnt = size(request->chart_distribution[1].prov_filter[x].qual,5)
       FOR (t = 1 TO prov_type_cnt)
         SET sequence += 1
         INSERT  FROM chart_dist_filter_value cdfv
          SET cdfv.description = substring(1,dist_filter_desc_char_limit,request->chart_distribution[
            1].dist_filter[z].filter_value[x].filter_description), cdfv.distribution_id =
           new_distribution_id, cdfv.type_flag = request->chart_distribution[1].dist_filter[z].
           type_flag,
           cdfv.key_sequence = sequence, cdfv.parent_entity_id = request->chart_distribution[1].
           dist_filter[z].filter_value[x].filter_value_cd, cdfv.parent_entity_name = evaluate(request
            ->chart_distribution[1].dist_filter[z].type_flag,1,"ORGANIZATION",2,"PRSNL",
            "CODE_VALUE"),
           cdfv.reltn_type_cd = request->chart_distribution[1].prov_filter[x].qual[t].prov_type_cd,
           cdfv.active_ind = 1, cdfv.active_status_cd = active_code,
           cdfv.active_status_dt_tm = cnvtdatetime(sysdate), cdfv.active_status_prsnl_id = reqinfo->
           updt_id, cdfv.updt_cnt = 0,
           cdfv.updt_dt_tm = cnvtdatetime(curdate,curtime), cdfv.updt_id = reqinfo->updt_id, cdfv
           .updt_applctx = reqinfo->updt_applctx,
           cdfv.updt_task = reqinfo->updt_task
          WITH nocounter
         ;end insert
         CALL error_and_zero_check(curqual,"CHART_DIST_FILTER_VALUE1","INSERT",1,0)
       ENDFOR
      ENDFOR
     ELSE
      SET filter_values_to_get = size(request->chart_distribution[1].dist_filter[z].filter_value,5)
      FOR (y = 1 TO filter_values_to_get)
        SET sequence += 1
        CALL echo(build("sequence is: ",sequence))
        INSERT  FROM chart_dist_filter_value cdfv
         SET cdfv.description = substring(1,dist_filter_desc_char_limit,request->chart_distribution[1
           ].dist_filter[z].filter_value[y].filter_description), cdfv.distribution_id = new_nbr, cdfv
          .type_flag = request->chart_distribution[1].dist_filter[z].type_flag,
          cdfv.key_sequence = sequence, cdfv.parent_entity_id = request->chart_distribution[1].
          dist_filter[z].filter_value[y].filter_value_cd, cdfv.parent_entity_name = evaluate(request
           ->chart_distribution[1].dist_filter[z].type_flag,1,"ORGANIZATION",2,"PRSNL",
           "CODE_VALUE"),
          cdfv.reltn_type_cd = 0.0, cdfv.active_ind = 1, cdfv.active_status_cd = active_code,
          cdfv.active_status_dt_tm = cnvtdatetime(sysdate), cdfv.active_status_prsnl_id = reqinfo->
          updt_id, cdfv.updt_cnt = 0,
          cdfv.updt_dt_tm = cnvtdatetime(curdate,curtime), cdfv.updt_id = reqinfo->updt_id, cdfv
          .updt_applctx = reqinfo->updt_applctx,
          cdfv.updt_task = reqinfo->updt_task
         WITH nocounter
        ;end insert
        CALL error_and_zero_check(curqual,"CHART_DIST_FILTER_VALUE2","INSERT",1,0)
      ENDFOR
     ENDIF
   ENDFOR
 END ;Subroutine
#exit_script
 CALL log_message("End of script: ch_add_distribution",log_level_debug)
END GO
