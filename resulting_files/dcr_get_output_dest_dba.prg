CREATE PROGRAM dcr_get_output_dest:dba
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
 SET log_program_name = "dcr_get_output_dest"
 IF (validate(reply) != 1)
  FREE RECORD reply
  RECORD reply(
    1 qual[*]
      2 name = c20
      2 device_cd = f8
      2 device_type_cd = f8
      2 device_type_disp = c40
      2 device_type_desc = c60
      2 device_type_mean = c12
      2 dms_enabled_ind = i2
    1 has_more_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 CALL log_message("Starting script: dcr_get_output_dest",log_level_debug)
 IF ((validate(passive_check_define,- (99))=- (99)))
  DECLARE passive_check_define = i4 WITH constant(1)
  DECLARE column_exists(stable,scolumn) = i4
  SUBROUTINE column_exists(stable,scolumn)
    DECLARE ce_flag = i4
    SET ce_flag = 0
    DECLARE ce_temp = vc WITH noconstant("")
    SET stable = cnvtupper(stable)
    SET scolumn = cnvtupper(scolumn)
    IF (((currev=8
     AND currevminor=2
     AND currevminor2 >= 4) OR (((currev=8
     AND currevminor > 2) OR (currev > 8)) )) )
     SET ce_temp = build('"',stable,".",scolumn,'"')
     SET stat = checkdic(parser(ce_temp),"A",0)
     IF (stat > 0)
      SET ce_flag = 1
     ENDIF
    ELSE
     SELECT INTO "nl:"
      l.attr_name
      FROM dtableattr a,
       dtableattrl l
      WHERE a.table_name=stable
       AND l.attr_name=scolumn
       AND l.structtype="F"
       AND btest(l.stat,11)=0
      DETAIL
       ce_flag = 1
      WITH nocounter
     ;end select
    ENDIF
    RETURN(ce_flag)
  END ;Subroutine
 ENDIF
 IF (validate(ld_concept_person)=0)
  DECLARE ld_concept_person = i2 WITH public, constant(1)
 ENDIF
 IF (validate(ld_concept_prsnl)=0)
  DECLARE ld_concept_prsnl = i2 WITH public, constant(2)
 ENDIF
 IF (validate(ld_concept_organization)=0)
  DECLARE ld_concept_organization = i2 WITH public, constant(3)
 ENDIF
 IF (validate(ld_concept_healthplan)=0)
  DECLARE ld_concept_healthplan = i2 WITH public, constant(4)
 ENDIF
 IF (validate(ld_concept_alias_pool)=0)
  DECLARE ld_concept_alias_pool = i2 WITH public, constant(5)
 ENDIF
 IF (validate(ld_concept_minvalue)=0)
  DECLARE ld_concept_minvalue = i2 WITH public, constant(1)
 ENDIF
 IF (validate(ld_concept_maxvalue)=0)
  DECLARE ld_concept_maxvalue = i2 WITH public, constant(5)
 ENDIF
 IF ((validate(get_logical_domain_define,- (99))=- (99)))
  DECLARE get_logical_domain_define = i4 WITH constant(1)
  FREE RECORD logical_domains
  RECORD logical_domains(
    1 qual[*]
      2 logical_domain_id = f8
  )
  DECLARE logical_domain = f8 WITH noconstant(0.0)
  DECLARE ld_success = i4 WITH constant(0)
  DECLARE ld_no_user = i4 WITH constant(1)
  DECLARE ld_no_logical_domains = i4 WITH constant(2)
  DECLARE ld_invalid_concept = i4 WITH constant(3)
  DECLARE ld_no_schema = i4 WITH constant(4)
  SUBROUTINE (get_logical_domain(parent_entity_name=vc) =i4)
   DECLARE b_logicaldomain = i4 WITH constant(column_exists(cnvtupper(parent_entity_name),
     "LOGICAL_DOMAIN_ID"))
   IF (b_logicaldomain > 0)
    DECLARE lerrorcode = i4 WITH noconstant(0)
    FREE RECORD acm_get_curr_logical_domain_req
    FREE RECORD acm_get_curr_logical_domain_rep
    RECORD acm_get_curr_logical_domain_req(
      1 concept = i4
    )
    RECORD acm_get_curr_logical_domain_rep(
      1 logical_domain_id = f8
      1 status_block
        2 status_ind = i2
        2 error_code = i4
    )
    DECLARE concept_id = i4 WITH noconstant(0)
    CASE (parent_entity_name)
     OF "PERSON":
      SET concept_id = ld_concept_person
     OF "PRSNL":
      SET concept_id = ld_concept_prsnl
     OF "ORGANIZATION":
      SET concept_id = ld_concept_organization
     OF "HEALTH_PLAN":
      SET concept_id = ld_concept_healthplan
     OF "ALIAS_POOL":
      SET concept_id = ld_concept_alias_pool
     ELSE
      SET concept_id = 0
    ENDCASE
    IF (concept_id=0)
     RETURN(ld_invalid_concept)
    ENDIF
    SET acm_get_curr_logical_domain_req->concept = concept_id
    EXECUTE acm_get_curr_logical_domain
    SET logical_domain = acm_get_curr_logical_domain_rep->logical_domain_id
    SET lerrorcode = acm_get_curr_logical_domain_rep->status_block.error_code
    FREE RECORD acm_get_curr_logical_domain_req
    FREE RECORD acm_get_curr_logical_domain_rep
    RETURN(lerrorcode)
   ELSE
    RETURN(ld_no_schema)
   ENDIF
  END ;Subroutine
  SUBROUTINE (get_logical_domains(parent_entity_name=vc) =i4)
   DECLARE b_logicaldomain = i4 WITH constant(column_exists(cnvtupper(parent_entity_name),
     "LOGICAL_DOMAIN_ID"))
   IF (b_logicaldomain > 0)
    DECLARE lcount = i4 WITH noconstant(0)
    DECLARE lerrorcode = i4 WITH noconstant(0)
    FREE RECORD acm_get_acc_logical_domains_req
    FREE RECORD acm_get_acc_logical_domains_rep
    RECORD acm_get_acc_logical_domains_req(
      1 write_mode_ind = i2
      1 concept = i4
    )
    RECORD acm_get_acc_logical_domains_rep(
      1 logical_domain_grp_id = f8
      1 logical_domains_cnt = i4
      1 logical_domains[*]
        2 logical_domain_id = f8
      1 status_block
        2 status_ind = i2
        2 error_code = i4
    )
    DECLARE concept_id = i4 WITH noconstant(0)
    CASE (parent_entity_name)
     OF "PERSON":
      SET concept_id = ld_concept_person
     OF "PRSNL":
      SET concept_id = ld_concept_prsnl
     OF "ORGANIZATION":
      SET concept_id = ld_concept_organization
     OF "HEALTH_PLAN":
      SET concept_id = ld_concept_healthplan
     OF "ALIAS_POOL":
      SET concept_id = ld_concept_alias_pool
     ELSE
      SET concept_id = 0
    ENDCASE
    IF (concept_id=0)
     RETURN(ld_invalid_concept)
    ENDIF
    SET acm_get_acc_logical_domains_req->concept = concept_id
    SET acm_get_acc_logical_domains_req->write_mode_ind = 0
    EXECUTE acm_get_acc_logical_domains
    SET lerrorcode = acm_get_acc_logical_domains_rep->status_block.error_code
    IF (lerrorcode=ld_success)
     FOR (lcount = 1 TO acm_get_acc_logical_domains_rep->logical_domains_cnt)
      IF (mod(lcount,10)=1)
       SET stat = alterlist(logical_domains->qual,(lcount+ 9))
      ENDIF
      SET logical_domains->qual[lcount].logical_domain_id = acm_get_acc_logical_domains_rep->
      logical_domains[lcount].logical_domain_id
     ENDFOR
     SET stat = alterlist(logical_domains->qual,acm_get_acc_logical_domains_rep->logical_domains_cnt)
    ENDIF
    FREE RECORD acm_get_acc_logical_domains_req
    FREE RECORD acm_get_acc_logical_domains_rep
    RETURN(lerrorcode)
   ELSE
    RETURN(ld_no_schema)
   ENDIF
  END ;Subroutine
 ENDIF
 DECLARE logicaldomainlookup(null) = null
 SET reply->status_data.status = "F"
 CALL logicaldomainlookup(null)
 DECLARE errmsg = c132 WITH protect
 DECLARE printer_type_cd = f8 WITH constant(uar_get_code_by("MEANING",3000,"PRINTER")), protect
 DECLARE fax_type_cd = f8 WITH constant(uar_get_code_by("MEANING",3000,"FAX")), protect
 DECLARE page_size = i4 WITH noconstant(63999)
 DECLARE start_row = i4 WITH noconstant(0)
 DECLARE end_row = i4 WITH noconstant(0)
 DECLARE cur_page = i4 WITH noconstant(1)
 IF ((request->cur_page > 1))
  SET cur_page = request->cur_page
 ENDIF
 IF (validate(debug_ind,0)=2)
  CALL log_message(
"Debugging has been turned on and page size will be severly limited which could lead to performance issues.    This debug l\
evel should only be used during development testing.\
",log_level_info)
  SET page_size = 5
 ENDIF
 SET start_row = (((cur_page - 1) * page_size)+ 1)
 SET end_row = (start_row+ page_size)
 SELECT DISTINCT INTO "nl:"
  x.name
  FROM (
   (
   (SELECT
    d.name, d.device_cd, d.device_type_cd,
    d.dms_service_id, d.distribution_flag, row_num = dense_rank() OVER(
    ORDER BY cnvtupper(d.name))
    FROM device d
    WHERE d.device_type_cd IN (printer_type_cd, fax_type_cd)
     AND ((d.location_cd=0) OR ( EXISTS (
    (SELECT
     loc.location_cd
     FROM location loc,
      organization org
     WHERE loc.location_cd=d.location_cd
      AND org.organization_id=loc.organization_id
      AND org.organization_id > 0
      AND org.active_ind=1
      AND org.logical_domain_id=logical_domain))))
     AND  EXISTS (
    (SELECT
     o.device_cd
     FROM output_dest o
     WHERE o.device_cd=d.device_cd))
     AND  EXISTS (
    (SELECT
     ds.dms_service_id
     FROM dms_service ds
     WHERE ds.dms_service_id=d.dms_service_id))
    ORDER BY cnvtupper(d.name)
    WITH sqltype("c20","f8","f8","f8","f8",
      "f8")))
   x)
  WHERE x.row_num BETWEEN start_row AND end_row
  ORDER BY cnvtupper(x.name)
  HEAD REPORT
   count = 0, stat = alterlist(reply->qual,(page_size+ 1))
  DETAIL
   IF (count <= page_size)
    count += 1, reply->qual[count].name = x.name, reply->qual[count].device_cd = x.device_cd,
    reply->qual[count].device_type_cd = x.device_type_cd
    IF (x.dms_service_id > 0.0
     AND x.distribution_flag=1)
     reply->qual[count].dms_enabled_ind = 1
    ELSEIF (x.device_type_cd=fax_type_cd)
     reply->qual[count].dms_enabled_ind = 1
    ENDIF
   ENDIF
  FOOT REPORT
   IF (count <= page_size)
    stat = alterlist(reply->qual,count), reply->has_more_ind = 0
   ELSEIF (page_size < count)
    stat = alterlist(reply->qual,page_size), reply->has_more_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 CALL error_and_zero_check(curqual,"SelectPrinters","Selecting printers failed.  Exiting script.",1,1
  )
 SET reply->status_data.status = "S"
 SUBROUTINE logicaldomainlookup(null)
   DECLARE lgetldstatus = i4 WITH private, noconstant(0)
   SET lgetldstatus = get_logical_domain("ORGANIZATION")
   CALL echo(build("lGetLDStatus: ",lgetldstatus))
   IF (lgetldstatus != ld_success)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "dcr_get_output_dest"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "EXECUTE"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "ERROR! - CCL errors occurred in pm_get_logical_domain! Exiting Job."
    GO TO exit_script
   ENDIF
 END ;Subroutine
#exit_script
 CALL log_message("End of script: dcr_get_output_dest",log_level_debug)
END GO
