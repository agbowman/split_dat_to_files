CREATE PROGRAM amb_mp_imx_medicare_prev:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Person Id:" = 0.0,
  "Personnel Id:" = 0.0,
  "Encounter Id:" = 0.0,
  "Position Code:" = 0.0,
  "FIN classes:" = "",
  "Plan types:" = ""
  WITH outdev, person_id, user_id,
  encntr_id, position_cd, fin_classes,
  plan_types
 DECLARE PUBLIC::gatherhealthplan(null) = null WITH protect, copy
 DECLARE PUBLIC::gatheruserprsnlalias(null) = null WITH protect, copy
 DECLARE PUBLIC::gatherpersondemo(null) = null WITH protect, copy
 DECLARE PUBLIC::gatherpersonhp(null) = null WITH protect, copy
 DECLARE PUBLIC::gatherorgnpi(null) = null WITH protect, copy
 FREE RECORD record_data
 RECORD record_data(
   1 health_plan_ind = i2
   1 access_ind = i2
   1 faccode = f8
   1 username = vc
   1 npi = vc
   1 facility_code = vc
   1 dob = vc
   1 first_name = vc
   1 last_name = vc
   1 mid_inital = vc
   1 sex = c1
   1 zip = vc
   1 medicareid = vc
   1 grp_cnt = i2
   1 grp[1]
     2 orderlist[*]
       3 catalog_cd = f8
       3 display = vc
       3 cpt_code = vc
     2 foundlist[*]
       3 catalog_cd = f8
       3 display = vc
       3 ord_date_utc = vc
       3 order_prov = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
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
 DECLARE crsl_msg_default = i4 WITH protect, noconstant(0)
 DECLARE crsl_msg_level = i4 WITH protect, noconstant(0)
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
 DECLARE crsl_info_domain = vc WITH protect, constant("DISCERNABU SCRIPT LOGGING")
 DECLARE crsl_logging_on = c1 WITH protect, constant("L")
 IF (((logical("MP_LOGGING_ALL") > " ") OR (logical(concat("MP_LOGGING_",log_program_name)) > " ")) )
  SET log_override_ind = 1
 ENDIF
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
     IF (validate(reply))
      SET reply->status_data.status = "F"
     ENDIF
     CALL log_message(serrmsg,log_level_audit)
     IF (logstatusblockind=1)
      IF (validate(reply))
       CALL populate_subeventstatus("EXECUTE","F","CCL SCRIPT",serrmsg)
      ENDIF
     ENDIF
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check_rec(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=
  i2,recorddata=vc(ref)) =i2)
   SET icrslerroroccured = 0
   SET ierrcode = error(serrmsg,0)
   WHILE (ierrcode > 0)
     SET icrslerroroccured = 1
     CALL log_message(serrmsg,log_level_audit)
     CALL populate_subeventstatus_rec(opname,"F",serrmsg,logmsg,recorddata)
     SET ierrcode = error(serrmsg,0)
   ENDWHILE
   IF (icrslerroroccured=1
    AND errorforceexit=1)
    SET recorddata->status_data.status = "F"
    GO TO exit_script
   ENDIF
   IF (qualnum=0
    AND zeroforceexit=1)
    SET recorddata->status_data.status = "Z"
    CALL populate_subeventstatus_rec(opname,"Z","No records qualified",logmsg,recorddata)
    GO TO exit_script
   ENDIF
   RETURN(icrslerroroccured)
 END ;Subroutine
 SUBROUTINE (error_and_zero_check(qualnum=i4,opname=vc,logmsg=vc,errorforceexit=i2,zeroforceexit=i2
  ) =i2)
   RETURN(error_and_zero_check_rec(qualnum,opname,logmsg,errorforceexit,zeroforceexit,
    reply))
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus_rec(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value),recorddata=vc(ref)) =i2)
   IF (validate(recorddata->status_data.status,"-1") != "-1")
    SET lcrslsubeventcnt = size(recorddata->status_data.subeventstatus,5)
    SET lcrslsubeventsize = size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationname))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      operationstatus))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectname))
    SET lcrslsubeventsize += size(trim(recorddata->status_data.subeventstatus[lcrslsubeventcnt].
      targetobjectvalue))
    IF (lcrslsubeventsize > 0)
     SET lcrslsubeventcnt += 1
     SET icrslloggingstat = alter(recorddata->status_data.subeventstatus,lcrslsubeventcnt)
    ENDIF
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationname = substring(1,25,
     operationname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].operationstatus = substring(1,1,
     operationstatus)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectname = substring(1,25,
     targetobjectname)
    SET recorddata->status_data.subeventstatus[lcrslsubeventcnt].targetobjectvalue =
    targetobjectvalue
   ENDIF
 END ;Subroutine
 SUBROUTINE (populate_subeventstatus(operationname=vc(value),operationstatus=vc(value),
  targetobjectname=vc(value),targetobjectvalue=vc(value)) =i2)
   CALL populate_subeventstatus_rec(operationname,operationstatus,targetobjectname,targetobjectvalue,
    reply)
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
 SET log_program_name = "AMB_MP_IMX_MEDICARE_PREV"
 DECLARE current_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), protect
 DECLARE fin_class_pars = vc WITH noconstant("1=1")
 DECLARE plan_type_pars = vc WITH noconstant("1=1")
 DECLARE 212_home = f8 WITH public, constant(uar_get_code_by("MEANING",212,"HOME"))
 DECLARE 320_imxaccessind = f8 WITH public, constant(uar_get_code_by("MEANING",320,"IMXACCESSIND"))
 DECLARE 334_npi = f8 WITH public, constant(uar_get_code_by_cki("CKI.CODEVALUE!2160654022"))
 DECLARE enc_orgid = f8 WITH noconstant(0.0)
 DECLARE enc_logdomainid = f8 WITH noconstant(0.0)
 DECLARE enc_loccd = f8 WITH noconstant(0.0)
 CALL log_message(concat("Begin script: ",log_program_name),log_level_debug)
 SET record_data->status_data.status = "F"
 SET stat = alterlist(record_data->grp[1].orderlist,1)
 SET record_data->grp[1].orderlist[1].catalog_cd = 0.0
 SET stat = alterlist(record_data->grp[1].foundlist,1)
 SET record_data->grp[1].foundlist[1].catalog_cd = 0.0
 SET record_data->grp_cnt = 24
 SELECT INTO "nl:"
  FROM encounter e,
   organization o
  PLAN (e
   WHERE (e.encntr_id= $ENCNTR_ID))
   JOIN (o
   WHERE o.organization_id=e.organization_id)
  DETAIL
   record_data->faccode = e.loc_facility_cd, enc_orgid = e.organization_id, enc_logdomainid = o
   .logical_domain_id
   IF (e.loc_nurse_unit_cd > 0)
    enc_loccd = e.loc_nurse_unit_cd
   ELSEIF (e.loc_building_cd > 0)
    enc_loccd = e.loc_building_cd
   ELSE
    enc_loccd = e.loc_facility_cd
   ENDIF
  WITH nocounter
 ;end select
 CALL checkforfacilityaccess(record_data->faccode, $POSITION_CD)
 IF ((record_data->access_ind=0))
  CALL gatheruserprsnlalias(null)
 ENDIF
 IF ((record_data->access_ind=1))
  SET plan_type_pars = concat("hp.plan_type_cd IN (", $PLAN_TYPES,")")
  SET fin_class_pars = concat("hp.financial_class_cd IN (", $FIN_CLASSES,")")
  CALL gatherpersonhp(null)
 ENDIF
 IF ((record_data->health_plan_ind=1))
  CALL gatherpersondemo(null)
  CALL gatherorgnpi(null)
 ENDIF
 SUBROUTINE PUBLIC::gatherpersondemo(null)
   CALL log_message("In GatherPersonDemo()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    dob = format(datetimezone(p.birth_dt_tm,p.birth_tz),"YYYYMMDD;4;D"), gender =
    uar_get_code_display(p.sex_cd), fname = trim(p.name_first_key),
    lname = trim(p.name_last_key), mname = trim(p.name_middle_key)
    FROM person p,
     address a
    PLAN (p
     WHERE (p.person_id= $PERSON_ID))
     JOIN (a
     WHERE (a.parent_entity_id= Outerjoin(p.person_id))
      AND (a.address_type_cd= Outerjoin(212_home))
      AND (a.parent_entity_name= Outerjoin("PERSON"))
      AND (a.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
      AND (a.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate)))
      AND (a.active_ind= Outerjoin(1)) )
    ORDER BY p.person_id, a.address_type_cd, a.address_type_seq DESC
    HEAD p.person_id
     record_data->dob = dob, record_data->sex = substring(1,1,gender), record_data->first_name =
     fname,
     record_data->last_name = lname, record_data->mid_inital = substring(1,1,mname)
     IF (a.address_id > 0)
      record_data->zip = trim(a.zipcode)
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check_rec(curqual,"PWX_IMX_person","gatherPersonDemo",1,0,
    record_data)
   SELECT INTO "nl:"
    FROM encounter e,
     organization o
    PLAN (e
     WHERE (e.encntr_id= $ENCNTR_ID))
     JOIN (o
     WHERE o.organization_id=e.organization_id)
    DETAIL
     record_data->facility_code = concat(trim(curdomain),"|",trim(cnvtstring(o.logical_domain_id)),
      "|",trim(cnvtstring(o.organization_id)),
      "|",trim(cnvtstring(enc_loccd)),"|",trim(cnvtstring( $USER_ID)))
    WITH nocounter
   ;end select
   CALL error_and_zero_check_rec(curqual,"PWX_IMX_faccode","gatherPersonDemo",1,0,
    record_data)
   CALL log_message(build("Exit gatherPersonDemo(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE PUBLIC::gatherpersonhp(null)
   CALL log_message("In GatherPersonHP()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM person_plan_reltn ppr,
     health_plan hp
    PLAN (ppr
     WHERE (ppr.person_id= $PERSON_ID)
      AND ppr.active_ind=1
      AND ppr.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND ppr.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (hp
     WHERE hp.health_plan_id=ppr.health_plan_id
      AND parser(fin_class_pars)
      AND parser(plan_type_pars))
    ORDER BY ppr.priority_seq, ppr.beg_effective_dt_tm DESC
    HEAD ppr.person_id
     record_data->health_plan_ind = 1, record_data->medicareid = ppr.member_nbr
    WITH nocounter
   ;end select
   CALL error_and_zero_check_rec(curqual,"PWX_IMX_HP","GatherPersonHP",1,0,
    record_data)
   CALL log_message(build("Exit GatherPersonHP(), Elapsed time in seconds:",datetimediff(cnvtdatetime
      (sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE PUBLIC::gatheruserprsnlalias(null)
   CALL log_message("In GatherUserPrsnlAlias()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    pa.person_id, aliaslen = textlen(trim(pa.alias))
    FROM prsnl_alias pa
    PLAN (pa
     WHERE (pa.person_id= $USER_ID)
      AND pa.prsnl_alias_type_cd=320_imxaccessind
      AND pa.active_ind=1
      AND pa.end_effective_dt_tm > cnvtdatetime(curdate,curtime))
    DETAIL
     CALL echo(aliaslen)
     IF (aliaslen > 0)
      record_data->access_ind = 1
     ENDIF
    WITH nocounter
   ;end select
   CALL error_and_zero_check_rec(curqual,"PWX_IMX_ALIAS","GatherUserPrsnlAlias",1,0,
    record_data)
   CALL log_message(build("Exit GatherUserPrsnlAlias(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE PUBLIC::gatherorgnpi(null)
   CALL log_message("In GatherOrgNPI()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM organization_alias oa
    PLAN (oa
     WHERE oa.organization_id=enc_orgid
      AND oa.org_alias_type_cd=334_npi
      AND oa.active_ind=1
      AND oa.end_effective_dt_tm > cnvtdatetime(sysdate))
    DETAIL
     record_data->npi = trim(oa.alias)
    WITH nocounter
   ;end select
   CALL error_and_zero_check_rec(curqual,"PWX_IMX_ORGNPI","  GatherOrgNPI",1,0,
    record_data)
   CALL log_message(build("Exit   GatherOrgNPI(), Elapsed time in seconds:",datetimediff(cnvtdatetime
      (sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE (PUBLIC::checkforfacilityaccess(facilitycd=f8,positioncd=f8) =null WITH protect, copy)
   CALL log_message("In CheckForFacilityAccess()",log_level_debug)
   DECLARE flexid = f8 WITH protect, noconstant(0.0)
   SELECT INTO "nl:"
    FROM br_datamart_filter bf,
     br_datamart_value bv,
     br_datamart_flex bx,
     code_value cv
    PLAN (bf
     WHERE bf.filter_mean="IMX_LOC_ACCESS")
     JOIN (bv
     WHERE bv.br_datamart_category_id=bf.br_datamart_category_id)
     JOIN (bx
     WHERE bx.br_datamart_flex_id=bv.br_datamart_flex_id
      AND bx.parent_entity_id=positioncd)
     JOIN (cv
     WHERE cv.code_value=bv.parent_entity_id
      AND cv.code_set=220)
    WITH nocounter
   ;end select
   IF (curqual > 0)
    SET flexid = positioncd
   ENDIF
   SELECT INTO "nl:"
    FROM br_datamart_filter bf,
     br_datamart_value bv,
     br_datamart_flex bx
    PLAN (bf
     WHERE bf.filter_mean="IMX_LOC_ACCESS")
     JOIN (bv
     WHERE bv.br_datamart_category_id=bf.br_datamart_category_id
      AND bv.parent_entity_id=facilitycd)
     JOIN (bx
     WHERE bx.br_datamart_flex_id=bv.br_datamart_flex_id
      AND bx.parent_entity_id=flexid)
    DETAIL
     record_data->access_ind = 1
    WITH nocounter
   ;end select
 END ;Subroutine
#exit_script
 SET record_data->status_data.status = "S"
 CALL echorecord(record_data)
 SET _memory_reply_string = cnvtrectojson(record_data)
 CALL log_message(concat("Exiting script: ",log_program_name),log_level_debug)
 CALL log_message(build("Total time in seconds:",datetimediff(cnvtdatetime(sysdate),current_date_time,
    5)),log_level_debug)
 FREE RECORD record_data
END GO
