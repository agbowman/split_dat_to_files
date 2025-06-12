CREATE PROGRAM cp_print_dist_details:dba
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
 SET log_program_name = "CP_PRINT_DIST_DETAILS"
 RECORD reply(
   1 qual[*]
     2 line = c132
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE RECORD dist_details
 RECORD dist_details(
   1 distribution_id = f8
   1 distribution_description = vc
   1 distribution_type = i4
   1 days_till_chart = i4
   1 updt_id = f8
   1 updt_dt_tm = dq8
   1 updt_name = vc
   1 dist_type = i4
   1 cutoff_days = i4
   1 cutoff_and_or_ind = i2
   1 cutoff_pages = i4
   1 banner_page = vc
   1 reader_group = c15
   1 print_lookback_ind = i2
   1 max_lookback_dt_tm = dq8
   1 max_lookback_dt_tm_str = vc
   1 max_lookback_ind = i2
   1 max_lookback_days = i4
   1 first_qualification_days = i4
   1 first_qualification_dt_tm = dq8
   1 first_qualification_dt_tm_str = vc
   1 absolute_qualification_days = i4
   1 absolute_qualification_dt_tm = dq8
   1 absolute_qualification_dt_tm_str = vc
   1 absolute_lookback_ind = i2
   1 related_ops[*]
     2 batch_name = vc
     2 run_type_cd = f8
     2 qualified_date_str = vc
 )
 FREE RECORD include_rec
 RECORD include_rec(
   1 encntr_type = i2
   1 client = i2
   1 provider = i2
   1 location = i2
   1 med_service = i2
 )
 FREE RECORD filter_rec
 RECORD filter_rec(
   1 qual[*]
     2 filter[*]
       3 filter_value_cd = f8
       3 filter_value_meaning = vc
 )
 FREE RECORD providers
 RECORD providers(
   1 qual[*]
     2 provider_id = f8
     2 provider_name = vc
     2 reltns[*]
       3 reltn_type_cd = f8
       3 reltn_type_meaning = vc
 )
 FREE RECORD ops_details
 RECORD ops_details(
   1 charting_operations_id = f8
   1 batch_name = vc
   1 updt_id = f8
   1 updt_name = vc
   1 updt_dt_tm = dq8
   1 scope = i2
   1 distribution_id = f8
   1 distribution_name = vc
   1 run_type_meaning = vc
   1 chart_format_id = f8
   1 chart_format_desc = vc
   1 print_finals = i2
   1 distribution_routing = i2
   1 default_printer = f8
   1 default_printer_name = vc
   1 file_storage_cd = f8
   1 file_storage = vc
   1 file_storage_location = vc
   1 sort_sequence = f8
   1 sort_sequence_disp = vc
   1 default_chart = i2
   1 law_id = f8
   1 law_desc = vc
   1 order_prov_flag = i2
   1 prov_routing_flag = i2
   1 prov_list[*]
     2 prov_id = f8
     2 prov_name = c25
   1 chart_route_id = f8
   1 chart_route_name = vc
   1 expire_ind = i2
   1 file_name = vc
   1 ftp_storage_location = vc
   1 report_template_id = f8
   1 report_template_desc = vc
 )
 FREE RECORD ops_providers
 RECORD ops_providers(
   1 qual[*]
     2 provider_type = vc
     2 provider_type_cd = f8
 )
 FREE RECORD acthold
 RECORD acthold(
   1 qual[*]
     2 acthold = c40
 )
 FREE RECORD orderhold
 RECORD orderhold(
   1 qual[*]
     2 orderhold = c40
 )
 FREE RECORD law_details
 RECORD law_details(
   1 law_id = f8
   1 law_description = vc
   1 lookback_days = i4
   1 lookback_type_ind = i2
   1 updt_id = f8
   1 updt_dt_tm = dq8
   1 updt_name = vc
 )
 FREE RECORD law_include_rec
 RECORD law_include_rec(
   1 encntr_type = i2
   1 client = i2
   1 provider = i2
   1 location = i2
   1 med_service = i2
 )
 FREE RECORD law_filter_rec
 RECORD law_filter_rec(
   1 qual[*]
     2 filter[*]
       3 filter_value_cd = f8
       3 filter_value_meaning = vc
 )
 FREE RECORD law_providers
 RECORD law_providers(
   1 qual[*]
     2 provider_id = f8
     2 provider_name = vc
     2 reltns[*]
       3 reltn_type_cd = f8
       3 reltn_type_meaning = vc
 )
 DECLARE order_doc_cd = f8 WITH constant(uar_get_code_by("MEANING",333,"ORDERDOC")), protect
 DECLARE tempval = i4 WITH noconstant(0)
 DECLARE tempstr = vc WITH noconstant("")
 DECLARE outfile = vc WITH noconstant(""), protect
 DECLARE all_ind = i2 WITH noconstant(0)
 DECLARE report_template_ind = i2 WITH noconstant(0)
 DECLARE param_scope = i4 WITH constant(1)
 DECLARE param_distid = i4 WITH constant(2)
 DECLARE param_chartformat = i4 WITH constant(4)
 DECLARE param_runtype = i4 WITH constant(5)
 DECLARE param_printfinals = i4 WITH constant(7)
 DECLARE param_distrouting = i4 WITH constant(9)
 DECLARE param_defaultprinter = i4 WITH constant(10)
 DECLARE param_filestoragecd = i4 WITH constant(14)
 DECLARE param_sortsequence = i4 WITH constant(15)
 DECLARE param_defaultchart = i4 WITH constant(16)
 DECLARE param_filestoragelocation = i4 WITH constant(17)
 DECLARE param_lawid = i4 WITH constant(18)
 DECLARE param_orderprovflag = i4 WITH constant(19)
 DECLARE param_provroutingflag = i4 WITH constant(20)
 DECLARE param_chartrouteid = i4 WITH constant(21)
 DECLARE param_expireind = i4 WITH constant(22)
 DECLARE param_filename = i4 WITH constant(23)
 DECLARE param_ftplocation = i4 WITH constant(24)
 IF (validate(i18nuar_def,999)=999)
  CALL echo("Declaring i18nuar_def")
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit(p1=i4,p2=vc,p3=vc,p4=f8) = i4 WITH persist
  DECLARE uar_i18ngetmessage(p1=i4,p2=vc,p3=vc) = vc WITH persist
  DECLARE uar_i18nbuildmessage() = vc WITH persist
  DECLARE uar_i18ngethijridate(imonth=i2(val),iday=i2(val),iyear=i2(val),sdateformattype=vc(ref)) =
  c50 WITH image_axp = "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar =
  "uar_i18nGetHijriDate",
  persist
  DECLARE uar_i18nbuildfullformatname(sfirst=vc(ref),slast=vc(ref),smiddle=vc(ref),sdegree=vc(ref),
   stitle=vc(ref),
   sprefix=vc(ref),ssuffix=vc(ref),sinitials=vc(ref),soriginal=vc(ref)) = c250 WITH image_axp =
  "shri18nuar", image_aix = "libi18n_locale.a(libi18n_locale.o)", uar = "i18nBuildFullFormatName",
  persist
  DECLARE uar_i18ngetarabictime(ctime=vc(ref)) = c20 WITH image_axp = "shri18nuar", image_aix =
  "libi18n_locale.a(libi18n_locale.o)", uar = "i18n_GetArabicTime",
  persist
 ENDIF
 DECLARE h = i4
 DECLARE i18nhandle = i4 WITH noconstant(0)
 SET h = uar_i18nlocalizationinit(i18nhandle,curprog,"",curcclrev)
 DECLARE getdistributiondetails(null) = null
 DECLARE getdistopsjobs(null) = null
 DECLARE getlastdistributionqualification(null) = null
 DECLARE createdistributionfile(null) = null
 DECLARE getoperationdetails(null) = null
 DECLARE getopsdetails(null) = null
 DECLARE getopsprsnl(null) = null
 DECLARE getopsextendeddetails(null) = null
 DECLARE getopsprovidersactivityholdorderhold(null) = null
 DECLARE createoperationfile(null) = null
 DECLARE getencounterlawdetails(null) = null
 DECLARE createlawfile(null) = null
 DECLARE sendfiletoreply(null) = null
 CALL log_message("Start of script: cp_print_dist_details",log_level_debug)
 SET reply->status_data.status = "F"
 IF ((request->print_type=1))
  CALL getdistributiondetails(null)
 ELSEIF ((request->print_type=2))
  CALL getoperationdetails(null)
 ELSEIF ((request->print_type=3))
  CALL getencounterlawdetails(null)
 ELSE
  CALL log_message("Invalid print_type",log_level_debug)
  GO TO exit_script
 ENDIF
 CALL sendfiletoreply(null)
 SET reply->status_data.status = "S"
 SUBROUTINE getdistributiondetails(null)
   CALL log_message("In GetDistributionDetails()",log_level_debug)
   DECLARE dist_id = f8 WITH constant(request->distribution_id), protect
   CALL getdistdetails(dist_id)
   CALL getchartdistfilterinfo(dist_id)
   CALL getchartdistfiltervalueinfo(dist_id)
   CALL getdistopsjobs(null)
   CALL getlastdistributionqualification(null)
   CALL createdistributionfile(null)
 END ;Subroutine
 SUBROUTINE getoperationdetails(null)
   CALL log_message("In GetOperationDetails()",log_level_debug)
   CALL getopsdetails(null)
   IF ((ops_details->prov_routing_flag > 0))
    CALL getopsprsnl(null)
   ENDIF
   CALL getopsextendeddetails(null)
   CALL getopsprovidersactivityholdorderhold(null)
   CALL createoperationfile(null)
 END ;Subroutine
 SUBROUTINE getencounterlawdetails(null)
   CALL log_message("In GetEncounterLawDetails()",log_level_debug)
   DECLARE law_id = f8 WITH constant(request->law_id)
   CALL getlawdetails(law_id)
   CALL getchartlawfilter(law_id)
   CALL getchartlawfiltervalue(law_id)
   CALL getlawproviders(law_id)
   CALL createlawfile(null)
 END ;Subroutine
 SUBROUTINE (getdistdetails(dist_id=f8(val)) =null)
   CALL log_message("In GetDistDetails()",log_level_debug)
   SELECT INTO "nl:"
    FROM chart_distribution cd,
     person p
    PLAN (cd
     WHERE cd.distribution_id=dist_id)
     JOIN (p
     WHERE p.person_id=cd.updt_id)
    HEAD REPORT
     do_nothing = 0
    DETAIL
     dist_details->distribution_id = cd.distribution_id, dist_details->distribution_description = cd
     .dist_descr, dist_details->distribution_type = cd.dist_type,
     dist_details->days_till_chart = cd.days_till_chart, dist_details->updt_id = cd.updt_id,
     dist_details->updt_dt_tm = cnvtdatetime(cd.updt_dt_tm),
     dist_details->updt_name = p.name_full_formatted, dist_details->dist_type = cd.dist_type,
     dist_details->cutoff_days = cd.cutoff_days,
     dist_details->cutoff_and_or_ind = cd.cutoff_and_or_ind, dist_details->cutoff_pages = cd
     .cutoff_pages, dist_details->banner_page = cd.banner_page,
     dist_details->reader_group = cd.reader_group, dist_details->print_lookback_ind = cd
     .print_lookback_ind, dist_details->max_lookback_dt_tm = cnvtdatetime(cd.max_lookback_dt_tm),
     dist_details->max_lookback_dt_tm_str = format(cd.max_lookback_dt_tm,"@LONGDATETIME"),
     dist_details->max_lookback_ind = cd.max_lookback_ind, dist_details->max_lookback_days = cd
     .max_lookback_days,
     dist_details->first_qualification_days = cd.first_qualification_days, dist_details->
     first_qualification_dt_tm = cnvtdatetime(cd.first_qualification_dt_tm), dist_details->
     first_qualification_dt_tm_str = format(cd.first_qualification_dt_tm,"@LONGDATETIME"),
     dist_details->absolute_qualification_days = cd.absolute_qualification_days, dist_details->
     absolute_qualification_dt_tm = cnvtdatetime(cd.absolute_qualification_dt_tm), dist_details->
     absolute_qualification_dt_tm_str = format(cd.absolute_qualification_dt_tm,"@LONGDATETIME"),
     dist_details->absolute_lookback_ind = cd.absolute_lookback_ind
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_DISTRIBUTION","GETDISTDETAILS",1,0)
 END ;Subroutine
 SUBROUTINE (getchartdistfilterinfo(dist_id=f8(val)) =null)
   CALL log_message("In GetChartDistFilterInfo()",log_level_debug)
   SET include_rec->encntr_type = 99
   SET include_rec->client = 99
   SET include_rec->provider = 99
   SET include_rec->location = 99
   SET include_rec->med_service = 99
   SELECT INTO "nl:"
    cdf.included_flag
    FROM chart_dist_filter cdf
    WHERE cdf.distribution_id=dist_id
    ORDER BY cdf.type_flag
    HEAD REPORT
     do_nothing = 0
    DETAIL
     IF (cdf.type_flag=0)
      include_rec->encntr_type = cdf.included_flag
     ELSEIF (cdf.type_flag=1)
      include_rec->client = cdf.included_flag
     ELSEIF (cdf.type_flag=2)
      include_rec->provider = cdf.included_flag
     ELSEIF (cdf.type_flag=3)
      include_rec->location = cdf.included_flag
     ELSEIF (cdf.type_flag=4)
      include_rec->med_service = cdf.included_flag
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_DIST_FILTER","GETDISTDETAILS",1,0)
 END ;Subroutine
 SUBROUTINE (getchartdistfiltervalueinfo(dist_id=f8(val)) =null)
   CALL log_message("In GetChartDistFilterValueInfo()",log_level_debug)
   SET stat = alterlist(filter_rec->qual,5)
   SELECT INTO "nl:"
    cdfv.type_flag, cdfv.parent_entity_id
    FROM chart_dist_filter_value cdfv,
     dummyt d1,
     code_value cv,
     dummyt d2,
     organization o
    PLAN (cdfv
     WHERE cdfv.distribution_id=dist_id)
     JOIN (d1)
     JOIN (cv
     WHERE cv.code_value=cdfv.parent_entity_id)
     JOIN (d2)
     JOIN (o
     WHERE o.organization_id=cdfv.parent_entity_id)
    ORDER BY cdfv.type_flag, cdfv.description
    HEAD REPORT
     do_nothing = 0, cnt_0 = 0, cnt_1 = 0,
     cnt_3 = 0, cnt_4 = 0
    DETAIL
     IF (cdfv.type_flag=0)
      cnt_0 += 1, stat = alterlist(filter_rec->qual[1].filter,cnt_0), filter_rec->qual[1].filter[
      cnt_0].filter_value_cd = cdfv.parent_entity_id,
      filter_rec->qual[1].filter[cnt_0].filter_value_meaning = cv.description
     ELSEIF (cdfv.type_flag=1)
      cnt_1 += 1, stat = alterlist(filter_rec->qual[2].filter,cnt_1), filter_rec->qual[2].filter[
      cnt_1].filter_value_cd = cdfv.parent_entity_id,
      filter_rec->qual[2].filter[cnt_1].filter_value_meaning = o.org_name
     ELSEIF (cdfv.type_flag=3)
      cnt_3 += 1, stat = alterlist(filter_rec->qual[4].filter,cnt_3), filter_rec->qual[4].filter[
      cnt_3].filter_value_cd = cdfv.parent_entity_id,
      filter_rec->qual[4].filter[cnt_3].filter_value_meaning = cv.description
     ELSEIF (cdfv.type_flag=4)
      cnt_4 += 1, stat = alterlist(filter_rec->qual[5].filter,cnt_4), filter_rec->qual[5].filter[
      cnt_4].filter_value_cd = cdfv.parent_entity_id,
      filter_rec->qual[5].filter[cnt_4].filter_value_meaning = cv.description
     ENDIF
    WITH nocounter, outerjoin = d1, outerjoin = d2,
     dontcare = cv, dontcare = o
   ;end select
   CALL error_and_zero_check(curqual,"CHART_DIST_FILTER_VALUE","ORGANIZATIONS",1,0)
   SELECT INTO "nl:"
    cdfv.parent_entity_id, cdfv.description, p.name_full_formatted,
    cdfv.reltn_type_cd, reltn_meaning = uar_get_code_display(cdfv.reltn_type_cd)
    FROM chart_dist_filter_value cdfv,
     prsnl p
    PLAN (cdfv
     WHERE cdfv.distribution_id=dist_id
      AND cdfv.type_flag=2)
     JOIN (p
     WHERE p.person_id=cdfv.parent_entity_id)
    ORDER BY cdfv.description, reltn_meaning
    HEAD REPORT
     do_nothing = 0, provider_cnt = 0, reltn_cnt = 0
    HEAD cdfv.description
     provider_cnt += 1, stat = alterlist(providers->qual,provider_cnt), providers->qual[provider_cnt]
     .provider_id = cdfv.parent_entity_id,
     providers->qual[provider_cnt].provider_name = p.name_full_formatted, reltn_cnt = 0
    DETAIL
     reltn_cnt += 1, stat = alterlist(providers->qual[provider_cnt].reltns,reltn_cnt), providers->
     qual[provider_cnt].reltns[reltn_cnt].reltn_type_cd = cdfv.reltn_type_cd,
     providers->qual[provider_cnt].reltns[reltn_cnt].reltn_type_meaning = reltn_meaning
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_DIST_FILTER_VALUE","PRSNL",1,0)
 END ;Subroutine
 SUBROUTINE getdistopsjobs(null)
   CALL log_message("In GetDistOpsJobs()",log_level_debug)
   SELECT DISTINCT INTO "nl:"
    co.batch_name
    FROM charting_operations co,
     charting_operations co2
    PLAN (co
     WHERE co.active_ind=1
      AND co.param=cnvtstring(request->distribution_id))
     JOIN (co2
     WHERE co2.charting_operations_id=co.charting_operations_id
      AND co2.param_type_flag=3)
    ORDER BY co.batch_name
    HEAD REPORT
     cnt = 0
    DETAIL
     cnt += 1, stat = alterlist(dist_details->related_ops,cnt), dist_details->related_ops[cnt].
     batch_name = co.batch_name,
     dist_details->related_ops[cnt].run_type_cd = cnvtreal(co2.param)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHARTING_OPERATIONS","GETDISTOPSJOBS",1,0)
 END ;Subroutine
 SUBROUTINE getlastdistributionqualification(null)
   CALL log_message("In GetLastDistributionQualification()",log_level_debug)
   DECLARE idx = i4 WITH noconstant(0)
   DECLARE itotal = i4 WITH constant(size(dist_details->related_ops,5)), protect
   DECLARE idx2 = i4 WITH noconstant(0)
   IF (itotal > 0)
    SELECT INTO "nl:"
     FROM chart_request cr
     WHERE (cr.distribution_id=request->distribution_id)
      AND expand(idx,1,itotal,cr.dist_run_type_cd,dist_details->related_ops[idx].run_type_cd)
     ORDER BY cr.dist_run_type_cd, cr.dist_run_dt_tm DESC
     HEAD cr.dist_run_type_cd
      index = locateval(idx2,1,itotal,cr.dist_run_type_cd,dist_details->related_ops[idx2].run_type_cd
       )
      WHILE (index != 0)
       dist_details->related_ops[index].qualified_date_str = format(cr.dist_run_dt_tm,
        "@SHORTDATETIME"),index = locateval(idx2,(index+ 1),itotal,cr.dist_run_type_cd,dist_details->
        related_ops[idx2].run_type_cd)
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
    CALL error_and_zero_check(curqual,"CHART_REQUEST","GETLASTDISTRIBUTIONQUALIFICATION",1,0)
   ENDIF
 END ;Subroutine
 SUBROUTINE createdistributionfile(null)
   CALL log_message("In CreateDistributionFile()",log_level_debug)
   SET outfile = "dist_details"
   DECLARE size_encntr_types = i4 WITH constant(size(filter_rec->qual[1].filter,5)), protect
   DECLARE size_clients = i4 WITH constant(size(filter_rec->qual[2].filter,5)), protect
   DECLARE size_locations = i4 WITH constant(size(filter_rec->qual[4].filter,5)), protect
   DECLARE size_med_service = i4 WITH constant(size(filter_rec->qual[5].filter,5)), protect
   DECLARE size_providers = i4 WITH constant(size(providers->qual,5)), protect
   DECLARE size_reltns = i4 WITH noconstant(0), protect
   SELECT INTO value(outfile)
    cd.distribution_id
    FROM chart_distribution cd
    WHERE (cd.distribution_id=request->distribution_id)
    HEAD REPORT
     row 1, tempstr = uar_i18ngetmessage(i18nhandle,"DISTSUM",
      "* * * * * * * DISTRIBUTION SUMMARY * * * * * * *"),
     CALL center(tempstr,0,125),
     row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"PRNTDTTM","Print Date/Time:"), col 1,
     tempstr, col + 2, curdate"MM/DD/YYYY;;D",
     col + 2, curtime"HH:MM;;S", row + 2,
     tempstr = uar_i18ngetmessage(i18nhandle,"DISTID","DISTRIBUTION ID:"), col 1, tempstr,
     col 20, dist_details->distribution_id, row + 1,
     tempstr = uar_i18ngetmessage(i18nhandle,"DISTNAME","DISTRIBUTION NAME:"), col 1, tempstr,
     tempval = size(trim(dist_details->distribution_description),1)
     IF (tempval > 60)
      tempstr = substring(1,60,dist_details->distribution_description), col 20, tempstr,
      x = 61
      WHILE (x <= tempval)
        IF (((x+ 60) > tempval))
         x += 60
        ELSE
         tempstr = substring(x,60,dist_details->distribution_description), row + 1, col 20,
         tempstr, x += 60
        ENDIF
      ENDWHILE
      row + 1, tempstr = substring((x - 60),tempval,dist_details->distribution_description), col 20,
      tempstr
     ELSE
      col 20, dist_details->distribution_description
     ENDIF
     row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"LASTUPD","LAST UPDATED:"), col 1,
     tempstr, col 20, dist_details->updt_dt_tm"mm/dd/yyyy hh:mm:ss;;d",
     col + 3, "  -  ", col + 3,
     dist_details->updt_name, row + 2, tempstr = uar_i18ngetmessage(i18nhandle,"DISTTYPE",
      "DISTRIBUTION TYPE:"),
     col 1, tempstr
     IF ((dist_details->distribution_type=1))
      tempstr = uar_i18ngetmessage(i18nhandle,"NONONLY","NON-DISCHARGED ONLY"), col 20, tempstr
     ELSEIF ((dist_details->distribution_type=2))
      tempstr = uar_i18ngetmessage(i18nhandle,"DISONLY","DISCHARGED ONLY"), col 20, tempstr
     ELSEIF ((dist_details->distribution_type=3))
      tempstr = uar_i18ngetmessage(i18nhandle,"DISNONDIS","BOTH NON-DISCHARGED & DISCHARGED"), col 20,
      tempstr
     ENDIF
     row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"DTILLCH","DAYS TILL CHART:"), col 1,
     tempstr, col 20, dist_details->days_till_chart,
     row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"RDRDRP","READER GROUP:"), col 1,
     tempstr, col 20, dist_details->reader_group,
     row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"CUTOFF","CUTOFF LOGIC:"), col 1,
     tempstr, col 20, dist_details->cutoff_pages,
     tempstr = uar_i18ngetmessage(i18nhandle,"PAGES"," PAGES "), col + 2, tempstr
     IF ((dist_details->cutoff_and_or_ind=1))
      tempstr = uar_i18ngetmessage(i18nhandle,"AND"," AND "), col + 2, tempstr
     ELSE
      tempstr = uar_i18ngetmessage(i18nhandle,"OR"," OR "), col + 2, tempstr
     ENDIF
     col + 2, dist_details->cutoff_days, tempstr = uar_i18ngetmessage(i18nhandle,"DAYS"," DAYS "),
     col + 2, tempstr, row + 1,
     tempstr = uar_i18ngetmessage(i18nhandle,"BNRPAGE","BANNER PAGE:"), col 1, tempstr,
     tempval = size(trim(dist_details->banner_page),1)
     IF (tempval > 60)
      tempstr = substring(1,60,dist_details->banner_page), col 20, tempstr,
      x = 61
      WHILE (x <= tempval)
        IF (((x+ 60) > tempval))
         x += 60
        ELSE
         tempstr = substring(x,60,dist_details->banner_page), row + 1, col 20,
         tempstr, x += 60
        ENDIF
      ENDWHILE
      row + 1, tempstr = substring((x - 60),tempval,dist_details->banner_page), col 20,
      tempstr
     ELSE
      col 20, dist_details->banner_page
     ENDIF
     daystr = uar_i18ngetmessage(i18nhandle,"DAYSTR","Days"), datestr = uar_i18ngetmessage(i18nhandle,
      "DATESTR","Date: "), patstr = uar_i18ngetmessage(i18nhandle,"PATADMITDATE","Patient admit date"
      ),
     prevstr = uar_i18ngetmessage(i18nhandle,"PREVDISTRUN","Previous distribution run"), row + 1,
     tempstr = uar_i18ngetmessage(i18nhandle,"INITLOOKBACK","INITIAL DISTRIBUTION LOOKBACK:"),
     col 1, tempstr, row + 1
     IF ((dist_details->max_lookback_ind=0))
      col 20, datestr, col + 1,
      dist_details->max_lookback_dt_tm_str
     ELSE
      col 20, dist_details->max_lookback_days, col + 1,
      daystr
     ENDIF
     row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"FIRSTLOOKBACK","FIRST QUALIFICATION LOOKBACK:"
      ), col 1,
     tempstr, row + 1
     IF ((dist_details->print_lookback_ind=0))
      col 20, datestr, col + 1,
      dist_details->first_qualification_dt_tm_str
     ELSEIF ((dist_details->print_lookback_ind=2))
      col 20, patstr
     ELSEIF ((dist_details->print_lookback_ind=1))
      col 20, prevstr
     ELSE
      col 20, dist_details->first_qualification_days, col + 1,
      daystr
     ENDIF
     row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"ABSOLUTELOOKBACK","ABSOLUTE LOOKBACK:"), col 1,
     tempstr, row + 1
     IF ((dist_details->absolute_lookback_ind=0))
      col 20, datestr, col + 1,
      dist_details->absolute_qualification_dt_tm_str
     ELSE
      col 20, dist_details->absolute_qualification_days, col + 1,
      daystr
     ENDIF
     row + 2, tempstr = uar_i18ngetmessage(i18nhandle,"ENCTYP","ENCOUNTER TYPES"), col 1,
     tempstr
     IF ((include_rec->encntr_type=99))
      col + 1, " "
     ELSEIF ((include_rec->encntr_type=1))
      tempstr = uar_i18ngetmessage(i18nhandle,"INC"," (INCLUDE):"), col + 1, tempstr
     ELSEIF ((include_rec->encntr_type=0))
      tempstr = uar_i18ngetmessage(i18nhandle,"EXC"," (EXCLUDE):"), col + 1, tempstr
     ENDIF
     FOR (x = 1 TO size_encntr_types)
       row + 1, col 1, filter_rec->qual[1].filter[x].filter_value_cd,
       col 20, filter_rec->qual[1].filter[x].filter_value_meaning
     ENDFOR
     row + 2, col 1, "CLIENTS"
     IF ((include_rec->client=99))
      col + 1, " "
     ELSEIF ((include_rec->client=1))
      tempstr = uar_i18ngetmessage(i18nhandle,"INC"," (INCLUDE):"), col + 1, tempstr
     ELSEIF ((include_rec->client=0))
      tempstr = uar_i18ngetmessage(i18nhandle,"EXC"," (EXCLUDE):"), col + 1, tempstr
     ENDIF
     FOR (x = 1 TO size_clients)
       row + 1, col 1, filter_rec->qual[2].filter[x].filter_value_cd,
       col 20, filter_rec->qual[2].filter[x].filter_value_meaning
     ENDFOR
     row + 2, col 1, "PROVIDERS"
     IF ((include_rec->provider=99))
      col + 1, " "
     ELSEIF ((include_rec->provider=1))
      tempstr = uar_i18ngetmessage(i18nhandle,"INC"," (INCLUDE):"), col + 1, tempstr
     ELSEIF ((include_rec->provider=0))
      tempstr = uar_i18ngetmessage(i18nhandle,"EXC"," (EXCLUDE):"), col + 1, tempstr
     ENDIF
     FOR (x = 1 TO size_providers)
       row + 2, col 1, providers->qual[x].provider_id,
       col 25, providers->qual[x].provider_name, size_reltns = size(providers->qual[x].reltns,5)
       FOR (y = 1 TO size_reltns)
         row + 1, col 12, providers->qual[x].reltns[y].reltn_type_cd,
         col 32, ">", col 34,
         providers->qual[x].reltns[y].reltn_type_meaning
       ENDFOR
     ENDFOR
     row + 2, col 1, "LOCATIONS"
     IF ((include_rec->location=99))
      col + 1, " "
     ELSEIF ((include_rec->location=1))
      tempstr = uar_i18ngetmessage(i18nhandle,"INC"," (INCLUDE):"), col + 1, tempstr
     ELSEIF ((include_rec->location=0))
      tempstr = uar_i18ngetmessage(i18nhandle,"EXC"," (EXCLUDE):"), col + 1, tempstr
     ENDIF
     FOR (x = 1 TO size_locations)
       row + 1, col 1, filter_rec->qual[4].filter[x].filter_value_cd,
       col 20, filter_rec->qual[4].filter[x].filter_value_meaning
     ENDFOR
     row + 2, col 1, "MEDICAL SERVICE"
     IF ((include_rec->med_service=99))
      col + 1, " "
     ELSEIF ((include_rec->med_service=1))
      tempstr = uar_i18ngetmessage(i18nhandle,"INC"," (INCLUDE):"), col + 1, tempstr
     ELSEIF ((include_rec->med_service=0))
      tempstr = uar_i18ngetmessage(i18nhandle,"EXC"," (EXCLUDE):"), col + 1, tempstr
     ENDIF
     FOR (x = 1 TO size_med_service)
       row + 1, col 1, filter_rec->qual[5].filter[x].filter_value_cd,
       col 20, filter_rec->qual[5].filter[x].filter_value_meaning
     ENDFOR
     row + 2, tempstr = uar_i18ngetmessage(i18nhandle,"RELATEDOPS","RELATED OPERATIONS:"),
     lastopsqual = uar_i18ngetmessage(i18nhandle,"LASTOPSQUAL","Last Operation Qualification:"),
     nolastopsqual = uar_i18ngetmessage(i18nhandle,"NOLASTOPSQUAL","No previuos qualifications")
     IF (size(dist_details->related_ops,5) > 0)
      col 1, tempstr
      FOR (x = 1 TO size(dist_details->related_ops,5))
        row + 1, col 20, dist_details->related_ops[x].batch_name,
        row + 1
        IF (trim(dist_details->related_ops[x].qualified_date_str)="")
         col 25, lastopsqual, col + 1,
         nolastopsqual
        ELSE
         col 25, lastopsqual, col + 1,
         dist_details->related_ops[x].qualified_date_str
        ENDIF
      ENDFOR
     ENDIF
     row + 2
    DETAIL
     do_nothing = 0
    FOOT REPORT
     do_nothing = 0
    WITH compress, nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_DISTRIBUTION","REPORT",1,0)
 END ;Subroutine
 SUBROUTINE getopsdetails(null)
   CALL log_message("In GetOpsDetails()",log_level_debug)
   SELECT INTO "nl:"
    co.charting_operations_id, co.batch_name, co.updt_id,
    co.updt_dt_tm, updt_name = p.name_full_formatted
    FROM charting_operations co,
     prsnl p
    PLAN (co
     WHERE (co.charting_operations_id=request->operation_id)
      AND co.param_type_flag=1
      AND co.active_ind=1)
     JOIN (p
     WHERE p.person_id=co.updt_id)
    HEAD REPORT
     do_nothing = 0
    DETAIL
     ops_details->charting_operations_id = co.charting_operations_id, ops_details->batch_name = co
     .batch_name, ops_details->updt_id = co.updt_id,
     ops_details->updt_name = p.name_full_formatted, ops_details->updt_dt_tm = cnvtdatetime(co
      .updt_dt_tm)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHARTING_OPERATIONS1","GETOPSDETAILS",1,0)
   SELECT INTO "nl:"
    co.param, co.param_type_flag
    FROM charting_operations co,
     cr_mask cm
    PLAN (co
     WHERE (co.charting_operations_id=request->operation_id)
      AND co.active_ind=1)
     JOIN (cm
     WHERE co.param_type_flag=param_filename
      AND cm.cr_mask_id=cnvtreal(co.param))
    HEAD REPORT
     do_nothing = 0
    DETAIL
     ops_details->file_name = cm.cr_mask_text
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHARTING_OPERATIONS/CR_MASK","GETOPSDETAILS",1,0)
   SELECT INTO "nl:"
    co.param, co.param_type_flag
    FROM charting_operations co
    WHERE (co.charting_operations_id=request->operation_id)
     AND co.active_ind=1
    HEAD REPORT
     do_nothing = 0
    DETAIL
     IF (co.param_type_flag=param_scope)
      ops_details->scope = cnvtint(co.param)
     ELSEIF (co.param_type_flag=param_distid)
      ops_details->distribution_id = cnvtreal(co.param)
     ELSEIF (co.param_type_flag=param_chartformat)
      ops_details->chart_format_id = cnvtreal(co.param)
     ELSEIF (co.param_type_flag=param_runtype)
      ops_details->run_type_meaning = co.param
     ELSEIF (co.param_type_flag=param_printfinals)
      ops_details->print_finals = cnvtint(co.param)
     ELSEIF (co.param_type_flag=param_distrouting)
      ops_details->distribution_routing = cnvtint(co.param)
     ELSEIF (co.param_type_flag=param_defaultprinter)
      ops_details->default_printer = cnvtreal(co.param)
     ELSEIF (co.param_type_flag=param_filestoragecd)
      ops_details->file_storage_cd = cnvtreal(co.param)
     ELSEIF (co.param_type_flag=param_sortsequence)
      ops_details->sort_sequence = cnvtreal(co.param)
     ELSEIF (co.param_type_flag=param_defaultchart)
      ops_details->default_chart = cnvtint(co.param)
     ELSEIF (co.param_type_flag=param_filestoragelocation)
      ops_details->file_storage_location = co.param
     ELSEIF (co.param_type_flag=param_ftplocation)
      ops_details->ftp_storage_location = co.param
     ELSEIF (co.param_type_flag=param_lawid)
      ops_details->law_id = cnvtreal(co.param)
     ELSEIF (co.param_type_flag=param_orderprovflag)
      ops_details->order_prov_flag = cnvtint(co.param)
     ELSEIF (co.param_type_flag=param_provroutingflag)
      ops_details->prov_routing_flag = cnvtint(co.param)
     ELSEIF (co.param_type_flag=param_chartrouteid)
      ops_details->chart_route_id = cnvtreal(co.param)
     ELSEIF (co.param_type_flag=param_expireind)
      ops_details->expire_ind = cnvtint(co.param)
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHARTING_OPERATIONS2","GETOPSDETAILS",1,0)
 END ;Subroutine
 SUBROUTINE getopsprsnl(null)
   CALL log_message("In GetOpsPrsnl()",log_level_debug)
   SELECT INTO "nl:"
    cop.prsnl_id
    FROM charting_operations_prsnl cop,
     prsnl p
    PLAN (cop
     WHERE (cop.charting_operations_id=request->operation_id))
     JOIN (p
     WHERE p.person_id=cop.prsnl_id)
    HEAD REPORT
     count = 0
    DETAIL
     count += 1
     IF (mod(count,10)=1)
      stat = alterlist(ops_details->prov_list,(count+ 9))
     ENDIF
     ops_details->prov_list[count].prov_id = p.person_id, ops_details->prov_list[count].prov_name = p
     .name_full_formatted
    FOOT REPORT
     stat = alterlist(ops_details->prov_list,count)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHARTING_OPERATIONS_PRSNL","GETOPSPRSNL",1,0)
 END ;Subroutine
 SUBROUTINE getopsextendeddetails(null)
   CALL log_message("In GetOpsExtendedDetails()",log_level_debug)
   SELECT INTO "nl:"
    cd.dist_descr
    FROM chart_distribution cd
    WHERE (cd.distribution_id=ops_details->distribution_id)
    HEAD REPORT
     do_nothing = 0
    DETAIL
     ops_details->distribution_name = cd.dist_descr
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_DISTRIBUTION","GETOPSEXTDTL",1,0)
   SELECT INTO "nl:"
    cf.chart_format_desc
    FROM chart_format cf
    WHERE (cf.chart_format_id=ops_details->chart_format_id)
    HEAD REPORT
     do_nothing = 0
    DETAIL
     report_template_ind = 0, ops_details->chart_format_desc = cf.chart_format_desc
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_FORMAT","GETOPSEXTDTL",1,0)
   SELECT INTO "nl:"
    rt.template_name
    FROM cr_report_template rt
    WHERE (rt.report_template_id=ops_details->chart_format_id)
    HEAD REPORT
     do_nothing = 0
    DETAIL
     report_template_ind = 1, ops_details->report_template_desc = rt.template_name
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"REPORT_TEMPLATE","GETOPSEXTDTL",1,0)
   SELECT INTO "nl:"
    od.name
    FROM output_dest od
    WHERE (od.output_dest_cd=ops_details->default_printer)
    HEAD REPORT
     do_nothing = 0
    DETAIL
     ops_details->default_printer_name = od.name
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"OUTPUT_DEST","GETOPSEXTDTL",1,0)
   SELECT INTO "nl:"
    cv.display
    FROM code_value cv
    WHERE (cv.code_value=ops_details->sort_sequence)
    HEAD REPORT
     do_nothing = 0
    DETAIL
     ops_details->sort_sequence_disp = cv.display
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CODE_VALUE1","GETOPSEXTDTL",1,0)
   SELECT INTO "nl:"
    cv.display
    FROM code_value cv
    WHERE (cv.code_value=ops_details->file_storage_cd)
    HEAD REPORT
     do_nothing = 0
    DETAIL
     ops_details->file_storage = cv.display
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CODE_VALUE2","GETOPSEXTDTL",1,0)
   SELECT INTO "nl:"
    FROM chart_law cl
    WHERE (cl.law_id=ops_details->law_id)
    DETAIL
     ops_details->law_desc = cl.law_descr
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_LAW","GETOPSEXTDTL",1,0)
   SELECT INTO "nl:"
    FROM chart_route cr
    WHERE (cr.chart_route_id=ops_details->chart_route_id)
    DETAIL
     ops_details->chart_route_name = cr.route_name
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_ROUTE","GETOPSEXTDTL",1,0)
 END ;Subroutine
 SUBROUTINE getopsprovidersactivityholdorderhold(null)
   CALL log_message("In GetOpsProvidersActivityHoldOrderHold()",log_level_debug)
   SELECT INTO "nl:"
    co.param
    FROM charting_operations co
    WHERE (co.charting_operations_id=request->operation_id)
     AND co.param_type_flag=6
     AND co.active_ind=1
    HEAD REPORT
     provider_cnt = 0
    DETAIL
     IF (co.param="ALL")
      all_ind = 1, provider_cnt += 1, stat = alterlist(ops_providers->qual,provider_cnt),
      ops_providers->qual[provider_cnt].provider_type = uar_i18ngetmessage(i18nhandle,"ALL","ALL")
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHARTING_OPERATIONS1","GETOPSPROVACTORD",1,0)
   SELECT INTO "nl:"
    co.param_type_flag, co.param, display = uar_get_code_display(cnvtreal(co.param))
    FROM charting_operations co
    WHERE (co.charting_operations_id=request->operation_id)
     AND co.param_type_flag IN (6, 12, 13)
     AND co.active_ind=1
    HEAD REPORT
     provider_cnt = 0, acthold_cnt = 0, orderhold_cnt = 0
    DETAIL
     IF (co.param_type_flag=6
      AND all_ind=0)
      provider_cnt += 1, stat = alterlist(ops_providers->qual,provider_cnt), ops_providers->qual[
      provider_cnt].provider_type_cd = cnvtreal(co.param),
      ops_providers->qual[provider_cnt].provider_type = display
     ELSEIF (co.param_type_flag=12)
      acthold_cnt += 1, stat = alterlist(acthold->qual,acthold_cnt), acthold->qual[acthold_cnt].
      acthold = display
     ELSEIF (co.param_type_flag=13)
      orderhold_cnt += 1, stat = alterlist(orderhold->qual,orderhold_cnt), orderhold->qual[
      orderhold_cnt].orderhold = display
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHARTING_OPERATIONS2","GETOPSPROVACTORD",1,0)
 END ;Subroutine
 SUBROUTINE createoperationfile(null)
   CALL log_message("In CreateOperationFile()",log_level_debug)
   SET outfile = "ops_details"
   DECLARE size_providers = i4 WITH constant(size(ops_providers->qual,5)), protect
   DECLARE size_acthold = i4 WITH constant(size(acthold->qual,5)), protect
   DECLARE size_orders = i4 WITH constant(size(orderhold->qual,5)), protect
   SELECT INTO value(outfile)
    co.charting_operations_id
    FROM charting_operations co
    WHERE (co.charting_operations_id=request->operation_id)
    HEAD REPORT
     row 1, tempstr = uar_i18ngetmessage(i18nhandle,"2OPSSUM",
      "* * * * * * * OPERATION SUMMARY * * * * * * *"),
     CALL center(tempstr,0,125),
     row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"2PRNTDTTM","Print Date/Time:"), col 1,
     tempstr, col + 2, curdate"MM/DD/YYYY;;D",
     col + 2, curtime"HH:MM;;S", row + 2,
     tempstr = uar_i18ngetmessage(i18nhandle,"2OPSID","CHARTING OPERATIONS ID:"), col 1, tempstr,
     col 30, ops_details->charting_operations_id, row + 1,
     tempstr = uar_i18ngetmessage(i18nhandle,"2CHOPSNAME","CHARTING OPERATIONS NAME:"), col 1,
     tempstr,
     col 30, ops_details->batch_name, row + 1,
     tempstr = uar_i18ngetmessage(i18nhandle,"2LSTUPD","LAST UPDATED:"), col 1, tempstr,
     col 30, ops_details->updt_dt_tm"mm/dd/yyyy hh:mm:ss;;d", col + 3,
     "  -  ", col + 3, ops_details->updt_name,
     row + 2, tempstr = uar_i18ngetmessage(i18nhandle,"2CHRTSCOPE","CHART SCOPE:"), col 1,
     tempstr
     IF ((ops_details->scope=1))
      tempstr = uar_i18ngetmessage(i18nhandle,"2SCOPEPER","PERSON-LEVEL"), col 25, tempstr
     ELSEIF ((ops_details->scope=2))
      tempstr = uar_i18ngetmessage(i18nhandle,"2SCOPEENC","ENCOUNTER-LEVEL"), col 25, tempstr
     ELSEIF ((ops_details->scope=4))
      tempstr = uar_i18ngetmessage(i18nhandle,"2SCOPEACC","ACCESSION-LEVEL"), col 25, tempstr
     ELSEIF ((ops_details->scope=5))
      tempstr = uar_i18ngetmessage(i18nhandle,"2SCOPEXE","CROSS-ENCOUNTER-LEVEL"), col 25, tempstr
     ELSEIF ((ops_details->scope=6))
      tempstr = uar_i18ngetmessage(i18nhandle,"2SCOPEDOC","DOCUMENT-LEVEL"), col 25, tempstr
     ENDIF
     row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"2DIST","DISTRIBUTION:"), col 1,
     tempstr, tempval = size(trim(ops_details->distribution_name),1)
     IF (tempval > 55)
      tempstr = substring(1,55,ops_details->distribution_name), col 25, tempstr,
      x = 56
      WHILE (x <= tempval)
        IF (((x+ 55) > tempval))
         x += 55
        ELSE
         tempstr = substring(x,55,ops_details->distribution_name), row + 1, col 25,
         tempstr, x += 55
        ENDIF
      ENDWHILE
      row + 1, tempstr = substring((x - 55),tempval,ops_details->distribution_name), col 25,
      tempstr
     ELSE
      col 25, ops_details->distribution_name
     ENDIF
     row + 1, col 25, "[",
     col 27, ops_details->distribution_id, col + 1,
     "]", row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"2RNTYPE","RUN-TYPE:"),
     col 1, tempstr, col 25,
     ops_details->run_type_meaning, row + 1
     IF (report_template_ind=0)
      tempstr = uar_i18ngetmessage(i18nhandle,"2CHRTFRMT","CHART FORMAT:"), col 1, tempstr,
      col 25, ops_details->chart_format_desc
     ELSE
      tempstr = uar_i18ngetmessage(i18nhandle,"2RPTTEMPLATE","REPORT TEMPLATE:"), col 1, tempstr,
      col 25, ops_details->report_template_desc
     ENDIF
     IF ((ops_details->scope=5))
      row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"2LAW","CROSS-ENCOUNTER LAW:"), col 1,
      tempstr, tempval = size(trim(ops_details->law_desc),1)
      IF (tempval > 55)
       tempstr = substring(1,55,ops_details->law_desc), col 25, tempstr,
       x = 56
       WHILE (x <= tempval)
         IF (((x+ 55) > tempval))
          x += 55
         ELSE
          tempstr = substring(x,55,ops_details->law_desc), row + 1, col 25,
          tempstr, x += 55
         ENDIF
       ENDWHILE
       row + 1, tempstr = substring((x - 55),tempval,ops_details->law_desc), col 25,
       tempstr
      ELSE
       col 25, ops_details->law_desc
      ENDIF
     ENDIF
     row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"2PRNTFIN","PRINT FINALS:"), col 1,
     tempstr
     IF ((ops_details->print_finals=0))
      tempstr = uar_i18ngetmessage(i18nhandle,"2VERONLY","VERIFIED RESULTS ONLY"), col 25, tempstr
     ELSE
      tempstr = uar_i18ngetmessage(i18nhandle,"2VERPEND","VERIFIED AND PENDING RESULTS"), col 25,
      tempstr
     ENDIF
     row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"2DISTROUT","DISTRIBUTION ROUTING:"), col 1,
     tempstr
     IF ((ops_details->distribution_routing=0))
      tempstr = uar_i18ngetmessage(i18nhandle,"2ASSDEV","ASSIGNED DEVICE"), col 25, tempstr
     ELSEIF ((ops_details->distribution_routing=1))
      tempstr = uar_i18ngetmessage(i18nhandle,"2ORGCLT","ORGANIZATION CLIENT"), col 25, tempstr
     ELSEIF ((ops_details->distribution_routing=2))
      tempstr = uar_i18ngetmessage(i18nhandle,"2PATLOC","PATIENT LOCATION"), col 25, tempstr
     ELSEIF ((ops_details->distribution_routing=3))
      tempstr = uar_i18ngetmessage(i18nhandle,"2ORDLOC","ORDER LOCATION"), col 25, tempstr
     ELSEIF ((ops_details->distribution_routing=4))
      tempstr = uar_i18ngetmessage(i18nhandle,"2PATLOCTMORD","PATIENT LOCATION AT TIME OF ORDER"),
      col 25, tempstr
     ELSEIF ((ops_details->distribution_routing=5))
      tempstr = uar_i18ngetmessage(i18nhandle,"2PROVTYP","PROVIDER TYPES SELECTED"), col 25, tempstr
     ENDIF
     row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"2DEFPRNT","DEFAULT PRINTER:"), col 1,
     tempstr, col 25, ops_details->default_printer_name,
     row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"2SRTSEQ","SORT SEQUENCE:"), col 1,
     tempstr, col 25, ops_details->sort_sequence_disp,
     row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"2FILESTRG","FILE STORAGE:"), col 1,
     tempstr, col 25, ops_details->file_storage,
     row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"2FILESTRGLOC","FILE STORAGE LOCATION:"), col 1,
     tempstr, tempval = size(trim(ops_details->file_storage_location),1)
     IF (tempval > 55)
      tempstr = substring(1,55,ops_details->file_storage_location), col 25, tempstr,
      x = 56
      WHILE (x <= tempval)
        IF (((x+ 55) > tempval))
         x += 55
        ELSE
         tempstr = substring(x,55,ops_details->file_storage_location), row + 1, col 25,
         tempstr, x += 55
        ENDIF
      ENDWHILE
      row + 1, tempstr = substring((x - 55),tempval,ops_details->file_storage_location), col 25,
      tempstr
     ELSE
      col 25, ops_details->file_storage_location
     ENDIF
     row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"2FTPSTRGLOC","FTP STORAGE LOCATION:"), col 1,
     tempstr, tempval = size(trim(ops_details->ftp_storage_location),1)
     IF (tempval > 55)
      tempstr = substring(1,55,ops_details->ftp_storage_location), col 25, tempstr,
      x = 56
      WHILE (x <= tempval)
        IF (((x+ 55) > tempval))
         x += 55
        ELSE
         tempstr = substring(x,55,ops_details->ftp_storage_location), row + 1, col 25,
         tempstr, x += 55
        ENDIF
      ENDWHILE
      row + 1, tempstr = substring((x - 55),tempval,ops_details->ftp_storage_location), col 25,
      tempstr
     ELSE
      col 25, ops_details->ftp_storage_location
     ENDIF
     row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"FILEMASKNAME","FILE NAME:"), col 1,
     tempstr, tempval = size(trim(ops_details->file_name),1)
     IF (tempval > 55)
      tempstr = substring(1,55,ops_details->file_name), col 25, tempstr,
      x = 56
      WHILE (x <= tempval)
        IF (((x+ 55) > tempval))
         x += 55
        ELSE
         tempstr = substring(x,55,ops_details->file_name), row + 1, col 25,
         tempstr, x += 55
        ENDIF
      ENDWHILE
      row + 1, tempstr = substring((x - 55),tempval,ops_details->file_name), col 25,
      tempstr
     ELSE
      col 25, ops_details->file_name
     ENDIF
     row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"2DEFCHRT2","DEFAULT CHART:"), col 1,
     tempstr
     IF ((ops_details->default_chart=0))
      tempstr = uar_i18ngetmessage(i18nhandle,"2NO","NO"), col 25, tempstr
     ELSEIF ((ops_details->default_chart=1))
      tempstr = uar_i18ngetmessage(i18nhandle,"2YES","YES"), col 25, tempstr
     ENDIF
     row + 1
     IF ((ops_details->chart_route_id > 0))
      tempstr = uar_i18ngetmessage(i18nhandle,"CHARTROUTE","CHART ROUTE: "), col 1, tempstr,
      col 25, ops_details->chart_route_name
     ENDIF
     row + 1
     IF ((ops_details->expire_ind > 0))
      tempstr = uar_i18ngetmessage(i18nhandle,"EXPIREDIND1","EXCLUDE EXPIRED RELATIONSHIPS: YES")
     ELSE
      tempstr = uar_i18ngetmessage(i18nhandle,"EXPIREDIND2","EXCLUDE EXPIRED RELATIONSHIPS: NO")
     ENDIF
     col 1, tempstr, row + 2,
     tempstr = uar_i18ngetmessage(i18nhandle,"2CPYTO","COPIES TO:"), col 1, tempstr
     FOR (x = 1 TO size_providers)
       row + 1, col 10, ops_providers->qual[x].provider_type
       IF ((ops_details->scope=4)
        AND ((all_ind=1) OR ((ops_providers->qual[x].provider_type_cd=order_doc_cd))) )
        row + 1
        IF ((ops_details->order_prov_flag=0))
         tempstr = uar_i18ngetmessage(i18nhandle,"2ORGORDPHY","- Original Ordering Physician"), col
         25, tempstr
        ELSEIF ((ops_details->order_prov_flag=1))
         tempstr = uar_i18ngetmessage(i18nhandle,"2CURORDPHY","- Current Ordering Physician"), col 25,
         tempstr
        ELSEIF ((ops_details->order_prov_flag=2))
         tempstr = uar_i18ngetmessage(i18nhandle,"2ORGCURORDPHY",
          "- Original and Current Ordering Physician"), col 25, tempstr
        ELSEIF ((ops_details->order_prov_flag=3))
         tempstr = uar_i18ngetmessage(i18nhandle,"2ALLORDPHY","- All Ordering Physician"), col 25,
         tempstr
        ENDIF
       ENDIF
     ENDFOR
     row + 2, tempstr = uar_i18ngetmessage(i18nhandle,"2ACTHLD","ACTIVITY HOLD:"), col 1,
     tempstr
     FOR (x = 1 TO size_acthold)
       row + 1, col 10, acthold->qual[x].acthold
     ENDFOR
     row + 2, tempstr = uar_i18ngetmessage(i18nhandle,"2ORDSTATHLD","ORDER STATUS HOLD:"), col 1,
     tempstr
     FOR (x = 1 TO size_orders)
       row + 1, col 10, orderhold->qual[x].orderhold
     ENDFOR
     row + 2
     IF ((ops_details->prov_routing_flag > 0))
      tempstr = uar_i18ngetmessage(i18nhandle,"2PROVROUT","PROVIDER ROUTING: "), col 1, tempstr
      IF ((ops_details->prov_routing_flag=1))
       tempstr = uar_i18ngetmessage(i18nhandle,"2INCPROV","INCLUDE SPECIFIC PROVIDERS"), col 20,
       tempstr
      ELSE
       tempstr = uar_i18ngetmessage(i18nhandle,"2EXPROV","EXCLUDE SPECIFIC PROVIDERS"), col 20,
       tempstr
      ENDIF
      FOR (x = 1 TO size(ops_details->prov_list,5))
        row + 1, col 5, ops_details->prov_list[x].prov_name,
        x += 1
        IF (x <= size(ops_details->prov_list,5))
         col 33, ops_details->prov_list[x].prov_name
        ENDIF
        x += 1
        IF (x <= size(ops_details->prov_list,5))
         col 61, ops_details->prov_list[x].prov_name
        ENDIF
      ENDFOR
     ENDIF
    DETAIL
     do_nothing = 0
    FOOT REPORT
     do_nothing = 0
    WITH compress, nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHARTING_OPERATIONS","CREATEOPERATIONFILE",1,0)
 END ;Subroutine
 SUBROUTINE (getlawdetails(law_id=f8(val)) =null)
   CALL log_message("In GetLawDetails()",log_level_debug)
   SELECT INTO "nl:"
    cl.law_id, cl.law_descr, cl.lookback_days,
    cl.lookback_type_ind, cl.updt_dt_tm, cl.updt_id,
    p.name_full_formatted
    FROM chart_law cl,
     person p
    PLAN (cl
     WHERE (cl.law_id=request->law_id))
     JOIN (p
     WHERE p.person_id=cl.updt_id)
    HEAD REPORT
     do_nothing = 0
    DETAIL
     law_details->law_id = cl.law_id, law_details->law_description = cl.law_descr, law_details->
     lookback_days = cl.lookback_days,
     law_details->lookback_type_ind = cl.lookback_type_ind, law_details->updt_id = cl.updt_id,
     law_details->updt_dt_tm = cnvtdatetime(cl.updt_dt_tm),
     law_details->updt_name = p.name_full_formatted
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_LAW","GETLAWDETAILS",1,0)
 END ;Subroutine
 SUBROUTINE (getchartlawfilter(law_id=f8(val)) =null)
   CALL log_message("In GetChartLawFilter()",log_level_debug)
   SET law_include_rec->encntr_type = 99
   SET law_include_rec->client = 99
   SET law_include_rec->provider = 99
   SET law_include_rec->location = 99
   SET law_include_rec->med_service = 99
   SELECT INTO "nl:"
    clf.included_flag
    FROM chart_law_filter clf
    WHERE (clf.law_id=request->law_id)
    ORDER BY clf.type_flag
    HEAD REPORT
     do_nothing = 0
    DETAIL
     IF (clf.type_flag=0)
      law_include_rec->encntr_type = clf.included_flag
     ELSEIF (clf.type_flag=1)
      law_include_rec->client = clf.included_flag
     ELSEIF (clf.type_flag=2)
      law_include_rec->provider = clf.included_flag
     ELSEIF (clf.type_flag=3)
      law_include_rec->location = clf.included_flag
     ELSEIF (clf.type_flag=4)
      law_include_rec->med_service = clf.included_flag
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_LAW_FILTER","GETCHARTLAWDETAILS",1,0)
 END ;Subroutine
 SUBROUTINE (getchartlawfiltervalue(law_id=f8(val)) =null)
   CALL log_message("In GetChartLawFilterValue()",log_level_debug)
   SET stat = alterlist(law_filter_rec->qual,5)
   SELECT INTO "nl:"
    clfv.type_flag, clfv.parent_entity_id
    FROM chart_law_filter_value clfv,
     dummyt d1,
     code_value cv,
     dummyt d2,
     organization o
    PLAN (clfv
     WHERE (clfv.law_id=request->law_id)
      AND clfv.type_flag IN (0, 1, 3, 4))
     JOIN (d1)
     JOIN (cv
     WHERE cv.code_value=clfv.parent_entity_id)
     JOIN (d2)
     JOIN (o
     WHERE o.organization_id=clfv.parent_entity_id)
    ORDER BY clfv.type_flag, clfv.description
    HEAD REPORT
     do_nothing = 0, cnt_0 = 0, cnt_1 = 0,
     cnt_3 = 0, cnt_4 = 0
    DETAIL
     IF (clfv.type_flag=0)
      cnt_0 += 1, stat = alterlist(law_filter_rec->qual[1].filter,cnt_0), law_filter_rec->qual[1].
      filter[cnt_0].filter_value_cd = clfv.parent_entity_id,
      law_filter_rec->qual[1].filter[cnt_0].filter_value_meaning = cv.description
     ELSEIF (clfv.type_flag=1)
      cnt_1 += 1, stat = alterlist(law_filter_rec->qual[2].filter,cnt_1), law_filter_rec->qual[2].
      filter[cnt_1].filter_value_cd = clfv.parent_entity_id,
      law_filter_rec->qual[2].filter[cnt_1].filter_value_meaning = o.org_name
     ELSEIF (clfv.type_flag=3)
      cnt_3 += 1, stat = alterlist(law_filter_rec->qual[4].filter,cnt_3), law_filter_rec->qual[4].
      filter[cnt_3].filter_value_cd = clfv.parent_entity_id,
      law_filter_rec->qual[4].filter[cnt_3].filter_value_meaning = cv.description
     ELSEIF (clfv.type_flag=4)
      cnt_4 += 1, stat = alterlist(law_filter_rec->qual[5].filter,cnt_4), law_filter_rec->qual[5].
      filter[cnt_4].filter_value_cd = clfv.parent_entity_id,
      law_filter_rec->qual[5].filter[cnt_4].filter_value_meaning = cv.description
     ENDIF
    WITH nocounter, outerjoin = d1, outerjoin = d2,
     dontcare = cv, dontcare = o
   ;end select
   CALL error_and_zero_check(curqual,"CHART_LAW_FILTER_VALUE","GETCHARTLAWDETAILS",1,0)
 END ;Subroutine
 SUBROUTINE (getlawproviders(law_id=f8(val)) =null)
   CALL log_message("In GetChartLawFilterValue()",log_level_debug)
   SELECT INTO "nl:"
    clfv.parent_entity_id, clfv.description, p.name_full_formatted,
    clfv.reltn_type_cd, reltn_meaning = uar_get_code_display(clfv.reltn_type_cd)
    FROM chart_law_filter_value clfv,
     prsnl p
    PLAN (clfv
     WHERE (clfv.law_id=request->law_id)
      AND clfv.type_flag=2)
     JOIN (p
     WHERE p.person_id=clfv.parent_entity_id)
    ORDER BY clfv.description, reltn_meaning
    HEAD REPORT
     do_nothing = 0, provider_cnt = 0, reltn_cnt = 0
    HEAD clfv.description
     provider_cnt += 1, stat = alterlist(law_providers->qual,provider_cnt), law_providers->qual[
     provider_cnt].provider_id = clfv.parent_entity_id,
     law_providers->qual[provider_cnt].provider_name = p.name_full_formatted, reltn_cnt = 0
    DETAIL
     reltn_cnt += 1, stat = alterlist(law_providers->qual[provider_cnt].reltns,reltn_cnt),
     law_providers->qual[provider_cnt].reltns[reltn_cnt].reltn_type_cd = clfv.reltn_type_cd,
     law_providers->qual[provider_cnt].reltns[reltn_cnt].reltn_type_meaning = reltn_meaning
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_LAW_FILTER_VALUE","GETLAWPROVIDERS",1,0)
 END ;Subroutine
 SUBROUTINE createlawfile(null)
   CALL log_message("In CreateLawFile()",log_level_debug)
   SET outfile = "law_details"
   DECLARE size_encntr_types = i4 WITH constant(size(law_filter_rec->qual[1].filter,5)), protect
   DECLARE size_clients = i4 WITH constant(size(law_filter_rec->qual[2].filter,5)), protect
   DECLARE size_locations = i4 WITH constant(size(law_filter_rec->qual[4].filter,5)), protect
   DECLARE size_med_service = i4 WITH constant(size(law_filter_rec->qual[5].filter,5)), protect
   DECLARE size_providers = i4 WITH constant(size(law_providers->qual,5)), protect
   DECLARE size_reltns = i4 WITH noconstant(0), protect
   SELECT INTO value(outfile)
    cl.law_id
    FROM chart_law cl
    WHERE (cl.law_id=request->law_id)
    HEAD REPORT
     row 1, tempstr = uar_i18ngetmessage(i18nhandle,"3XENCNTRSUM",
      "* * * * * * * CROSS-ENCOUNTER LAW SUMMARY * * * * * * *"),
     CALL center(tempstr,0,125),
     row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"3PRNTDTTM","Print Date/Time:"), col 1,
     tempstr, col + 2, curdate"MM/DD/YYYY;;D",
     col + 2, curtime"HH:MM;;S", row + 2,
     tempstr = uar_i18ngetmessage(i18nhandle,"3LAWID","LAW ID:"), col 1, tempstr,
     col 20, law_details->law_id, row + 1,
     tempstr = uar_i18ngetmessage(i18nhandle,"3LAWNM","LAW NAME:"), col 1, tempstr,
     tempval = size(trim(law_details->law_description),1)
     IF (tempval > 60)
      tempstr = substring(1,60,law_details->law_description), col 20, tempstr,
      x = 61
      WHILE (x <= tempval)
        IF (((x+ 60) > tempval))
         x += 60
        ELSE
         tempstr = substring(x,60,law_details->law_description), row + 1, col 20,
         tempstr, x += 60
        ENDIF
      ENDWHILE
      row + 1, tempstr = substring((x - 60),tempval,law_details->law_description), col 20,
      tempstr
     ELSE
      col 20, law_details->law_description
     ENDIF
     row + 1, tempstr = uar_i18ngetmessage(i18nhandle,"3LSTUPD","LAST UPDATED:"), col 1,
     tempstr, col 20, law_details->updt_dt_tm"mm/dd/yyyy hh:mm:ss;;d",
     col + 3, "  -  ", col + 3,
     law_details->updt_name, row + 2, tempstr = uar_i18ngetmessage(i18nhandle,"3LKBKDYS",
      "LOOKBACK DAYS:"),
     col 1, tempstr, col 20,
     law_details->lookback_days
     IF ((law_details->lookback_type_ind=1))
      tempstr = uar_i18ngetmessage(i18nhandle,"3DISCRGDTTM","(By Discharge Date/Time)"), col + 3,
      tempstr
     ELSE
      tempstr = uar_i18ngetmessage(i18nhandle,"3CLINACTDTTM","(By Clinical Activity Date/Time)"), col
       + 3, tempstr
     ENDIF
     row + 2, tempstr = uar_i18ngetmessage(i18nhandle,"3ENCNTRTYP","ENCOUNTER TYPES"), col 1,
     tempstr
     IF ((law_include_rec->encntr_type=99))
      col + 1, " "
     ELSEIF ((law_include_rec->encntr_type=1))
      tempstr = uar_i18ngetmessage(i18nhandle,"3INC"," (INCLUDE):"), col + 1, tempstr
     ELSEIF ((law_include_rec->encntr_type=0))
      tempstr = uar_i18ngetmessage(i18nhandle,"3EXC"," (EXCLUDE):"), col + 1, tempstr
     ENDIF
     FOR (x = 1 TO size_encntr_types)
       row + 1, col 1, law_filter_rec->qual[1].filter[x].filter_value_cd,
       col 20, law_filter_rec->qual[1].filter[x].filter_value_meaning
     ENDFOR
     row + 2, col 1, "CLIENTS"
     IF ((law_include_rec->client=99))
      col + 1, " "
     ELSEIF ((law_include_rec->client=1))
      tempstr = uar_i18ngetmessage(i18nhandle,"3INC"," (INCLUDE):"), col + 1, tempstr
     ELSEIF ((law_include_rec->client=0))
      tempstr = uar_i18ngetmessage(i18nhandle,"3EXC"," (EXCLUDE):"), col + 1, tempstr
     ENDIF
     FOR (x = 1 TO size_clients)
       row + 1, col 1, law_filter_rec->qual[2].filter[x].filter_value_cd,
       col 20, law_filter_rec->qual[2].filter[x].filter_value_meaning
     ENDFOR
     row + 2, col 1, "PROVIDERS"
     IF ((law_include_rec->provider=99))
      col + 1, " "
     ELSEIF ((law_include_rec->provider=1))
      tempstr = uar_i18ngetmessage(i18nhandle,"3INC"," (INCLUDE):"), col + 1, tempstr
     ELSEIF ((law_include_rec->provider=0))
      tempstr = uar_i18ngetmessage(i18nhandle,"3EXC"," (EXCLUDE):"), col + 1, tempstr
     ENDIF
     FOR (x = 1 TO size_providers)
       row + 2, col 1, law_providers->qual[x].provider_id,
       col 25, law_providers->qual[x].provider_name, size_reltns = size(law_providers->qual[x].reltns,
        5)
       FOR (y = 1 TO size_reltns)
         row + 1, col 12, law_providers->qual[x].reltns[y].reltn_type_cd,
         col 32, ">", col 34,
         law_providers->qual[x].reltns[y].reltn_type_meaning
       ENDFOR
     ENDFOR
     row + 2, col 1, "LOCATIONS"
     IF ((law_include_rec->location=99))
      col + 1, " "
     ELSEIF ((law_include_rec->location=1))
      tempstr = uar_i18ngetmessage(i18nhandle,"3INC"," (INCLUDE):"), col + 1, tempstr
     ELSEIF ((law_include_rec->location=0))
      tempstr = uar_i18ngetmessage(i18nhandle,"3EXC"," (EXCLUDE):"), col + 1, tempstr
     ENDIF
     FOR (x = 1 TO size_locations)
       row + 1, col 1, law_filter_rec->qual[4].filter[x].filter_value_cd,
       col 20, law_filter_rec->qual[4].filter[x].filter_value_meaning
     ENDFOR
     row + 2, col 1, "MEDICAL SERVICE"
     IF ((law_include_rec->med_service=99))
      col + 1, " "
     ELSEIF ((law_include_rec->med_service=1))
      tempstr = uar_i18ngetmessage(i18nhandle,"3INC"," (INCLUDE):"), col + 1, tempstr
     ELSEIF ((law_include_rec->med_service=0))
      tempstr = uar_i18ngetmessage(i18nhandle,"3EXC"," (EXCLUDE):"), col + 1, tempstr
     ENDIF
     FOR (x = 1 TO size_med_service)
       row + 1, col 1, law_filter_rec->qual[5].filter[x].filter_value_cd,
       col 20, law_filter_rec->qual[5].filter[x].filter_value_meaning
     ENDFOR
     row + 2
    DETAIL
     do_nothing = 0
    FOOT REPORT
     do_nothing = 0
    WITH compress, nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_LAW","REPORT",1,0)
 END ;Subroutine
 SUBROUTINE sendfiletoreply(null)
   CALL log_message("In SendFileToReply()",log_level_debug)
   DECLARE outfile1 = vc WITH noconstant(""), protect
   SET outfile1 = build("ccluserdir:",outfile)
   SET outfile1 = concat(outfile1,".dat")
   FREE DEFINE rtl
   DEFINE rtl value(outfile1)
   SELECT INTO "nl:"
    r.line
    FROM rtlt r
    HEAD REPORT
     count1 = 0
    DETAIL
     count1 += 1, stat = alterlist(reply->qual,count1), reply->qual[count1].line = r.line
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"RTLT","SENDFILETOREPLY",1,1)
 END ;Subroutine
#exit_script
 CALL log_message("End of script: cp_print_dist_details",log_level_debug)
END GO
