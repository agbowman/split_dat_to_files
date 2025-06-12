CREATE PROGRAM amb_mp_imx_pat_rpt:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Person_id" = 0,
  "Encounter Id:" = 0.0,
  "Json String" = ""
  WITH outdev, person_id, encntr_id,
  jsonstr
 DECLARE gatherpersondemo(null) = null WITH protect, copy
 DECLARE gatherprsnldemo(null) = null WITH protect, copy
 DECLARE gatherorgdemo(null) = null WITH protect, copy
 FREE RECORD report_data
 RECORD report_data(
   1 pt_name = vc
   1 pt_dob = vc
   1 pt_mrn = vc
   1 pt_age = vc
   1 print_dt = vc
   1 print_by = vc
   1 fac = vc
   1 fac_addr1 = vc
   1 fac_addr2 = vc
   1 fac_city = vc
   1 fac_state = vc
   1 fac_zip = vc
   1 fac_phone = vc
   1 pcp = vc
   1 filename = vc
   1 htmlpage = vc
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
 SET log_program_name = "AMB_MP_IMX_PAT_RPT"
 DECLARE current_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), protect
 DECLARE age_str = vc
 DECLARE years = i2
 DECLARE 4_mrn = f8 WITH constant(uar_get_code_by("MEANING",4,"MRN")), protect
 DECLARE 212_business = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!8009")), protect
 DECLARE 43_business = f8 WITH constant(uar_get_code_by_cki("CKI.CODEVALUE!9598")), protect
 DECLARE 331_pcp = f8 WITH public, constant(uar_get_code_by("MEANING",331,"PCP"))
 DECLARE gseq = i2 WITH noconstant(0)
 DECLARE cseq = i2 WITH noconstant(0)
 DECLARE ocnt = i2 WITH noconstant(0)
 DECLARE gcnt = i2 WITH noconstant(0)
 DECLARE grppos = i2 WITH noconstant(0)
 DECLARE foundpos = i2 WITH noconstant(0)
 DECLARE grpcnt = i2 WITH noconstant(0)
 DECLARE grppos2 = i2 WITH noconstant(0)
 DECLARE foundpos2 = i2 WITH noconstant(0)
 DECLARE fcnt = i2 WITH noconstant(0)
 CALL log_message(concat("Begin script: ",log_program_name),log_level_debug)
 SET report_data->status_data.status = "F"
 CALL echo("here")
 CALL echo( $JSONSTR)
 IF (( $JSONSTR > " "))
  CALL log_message("Begin CnvtJSONRec",log_level_debug)
  DECLARE cnvtbeg_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
  DECLARE jrec = i4
  CALL echo("converting to record")
  SET jrec = cnvtjsontorec(trim( $JSONSTR))
  CALL echo("converting to record done")
  CALL log_message(build("Finish CnvtJSONRec(), Elapsed time in seconds:",datetimediff(cnvtdatetime(
      sysdate),cnvtbeg_date_time,5)),log_level_debug)
  IF (validate(brec))
   IF (validate(brec->edata))
    SET brec->status = "S"
    CALL echorecord(brec)
    CALL gatherpersondemo(null)
    CALL gatherprsnldemo(null)
    CALL gatherorgdemo(null)
    SET report_data->print_dt = format(cnvtdatetime(sysdate),"MM/DD/YYYY;;d")
    DECLARE cmd = vc
    DECLARE stat = i4
    DECLARE len = i4
    EXECUTE cpm_create_file_name "patrpt", "dat"
    IF ((cpm_cfn_info->status_data.status != "S"))
     SET failed = file_fail
     SET error_message = "Failed to create MPage Reply File"
     GO TO exit_script
    ENDIF
    SET report_data->filename = cpm_cfn_info->file_name_full_path
    EXECUTE amb_imx_patient_report value(report_data->filename)
    EXECUTE ccl_readfile  $OUTDEV, value(report_data->filename), 0,
    11, 8.5
    SET report_data->status_data.status = "S"
   ENDIF
  ENDIF
 ELSE
  SELECT INTO  $OUTDEV
   FROM (dummyt  WITH seq = 1)
   DETAIL
    col 0, "test"
   WITH nocounter
  ;end select
 ENDIF
 SUBROUTINE gatherpersondemo(null)
   CALL log_message("In GatherPersonDemo()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    dob = format(datetimezone(p.birth_dt_tm,p.birth_tz),"MM/DD/YYYY;4;D")
    FROM person p,
     person_alias pa
    PLAN (p
     WHERE (p.person_id= $PERSON_ID))
     JOIN (pa
     WHERE (pa.person_id= Outerjoin(p.person_id))
      AND (pa.active_ind= Outerjoin(1))
      AND (pa.person_alias_type_cd= Outerjoin(4_mrn))
      AND (pa.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
    HEAD p.person_id
     report_data->pt_dob = dob, report_data->pt_name = trim(p.name_full_formatted), report_data->
     pt_age = cnvtage(p.birth_dt_tm),
     report_data->pt_mrn = trim(pa.alias)
    WITH nocounter
   ;end select
   CALL error_and_zero_check_rec(curqual,"PWX_IMX_person","gatherPersonDemo",1,0,
    report_data)
   SELECT INTO "nl:"
    FROM person_prsnl_reltn ppr,
     prsnl pr
    PLAN (ppr
     WHERE (ppr.person_id= $PERSON_ID)
      AND ppr.person_prsnl_r_cd=331_pcp
      AND ppr.active_ind=1
      AND ((cnvtdatetime(sysdate) BETWEEN ppr.beg_effective_dt_tm AND ppr.end_effective_dt_tm) OR (
     cnvtdatetime(sysdate) > ppr.beg_effective_dt_tm
      AND ppr.end_effective_dt_tm = null)) )
     JOIN (pr
     WHERE (pr.person_id= Outerjoin(ppr.prsnl_person_id)) )
    ORDER BY ppr.beg_effective_dt_tm DESC
    DETAIL
     IF (ppr.prsnl_person_id != 0)
      report_data->pcp = trim(pr.name_full_formatted,3)
     ELSE
      report_data->pcp = ppr.ft_prsnl_name
     ENDIF
    WITH maxrec = 1
   ;end select
   CALL error_and_zero_check_rec(curqual,"PWX_IMX_person_prsnl","gatherPersonDemo",1,0,
    report_data)
   CALL log_message(build("Exit gatherPersonDemo(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE gatherprsnldemo(null)
   CALL log_message("In GatherPrsnlDemo()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM prsnl pr
    PLAN (pr
     WHERE (pr.person_id=reqinfo->updt_id))
    DETAIL
     report_data->print_by = trim(pr.name_full_formatted)
    WITH nocounter
   ;end select
   CALL error_and_zero_check_rec(curqual,"PWX_IMX_person","GatherPrsnlDemo",1,0,
    report_data)
   CALL log_message(build("Exit GatherPrsnlDemo(), Elapsed time in seconds:",datetimediff(
      cnvtdatetime(sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
 SUBROUTINE gatherorgdemo(null)
   CALL log_message("In GatherOrgDemo()",log_level_debug)
   DECLARE begin_date_time = dq8 WITH constant(cnvtdatetime(sysdate)), private
   SELECT INTO "nl:"
    FROM encounter e,
     address a,
     phone p
    PLAN (e
     WHERE (e.encntr_id= $ENCNTR_ID))
     JOIN (a
     WHERE (a.parent_entity_id= Outerjoin(e.loc_building_cd))
      AND (a.address_type_cd= Outerjoin(212_business))
      AND (a.parent_entity_name= Outerjoin("LOCATION"))
      AND (a.active_ind= Outerjoin(1))
      AND (a.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
      AND (a.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
     JOIN (p
     WHERE (p.parent_entity_id= Outerjoin(e.loc_building_cd))
      AND (p.phone_type_cd= Outerjoin(43_business))
      AND (p.parent_entity_name= Outerjoin("LOCATION"))
      AND (p.phone_type_seq= Outerjoin(1))
      AND (p.active_ind= Outerjoin(1))
      AND (p.beg_effective_dt_tm<= Outerjoin(cnvtdatetime(sysdate)))
      AND (p.end_effective_dt_tm> Outerjoin(cnvtdatetime(sysdate))) )
    DETAIL
     report_data->fac = uar_get_code_description(e.loc_nurse_unit_cd), report_data->fac_addr1 = a
     .street_addr, report_data->fac_addr2 = a.street_addr2,
     report_data->fac_city = a.city, report_data->fac_state =
     IF (a.state_cd > 0) uar_get_code_display(a.state_cd)
     ELSE a.state
     ENDIF
     , report_data->fac_zip = a.zipcode,
     report_data->fac_phone = cnvtphone(p.phone_num,p.phone_format_cd,2)
    WITH nocounter
   ;end select
   CALL error_and_zero_check_rec(curqual,"PWX_pt_report","gatherOrgDemo",1,0,
    report_data)
   CALL log_message(build("Exit gatherOrgDemo(), Elapsed time in seconds:",datetimediff(cnvtdatetime(
       sysdate),begin_date_time,5)),log_level_debug)
 END ;Subroutine
#exit_script
 CALL log_message(concat("Exiting script: ",log_program_name),log_level_debug)
 CALL log_message(build("Total time in seconds:",datetimediff(cnvtdatetime(sysdate),current_date_time,
    5)),log_level_debug)
END GO
