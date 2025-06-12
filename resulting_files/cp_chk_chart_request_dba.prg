CREATE PROGRAM cp_chk_chart_request:dba
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
 SET log_program_name = "CP_CHK_CHART_REQUEST"
 RECORD reply(
   1 requested_ind = i2
   1 status_flag = i2
   1 status_cd = f8
   1 status_cd_disp = vc
   1 name_first = vc
   1 name_last = vc
   1 request_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET section
 RECORD section(
   1 sec_list[*]
     2 sec_type = i2
 )
 FREE RECORD ce_events
 RECORD ce_events(
   1 events[*]
     2 event_id = f8
 )
 DECLARE del_stat_cd = f8 WITH constant(uar_get_code_by("MEANING",48,"DELETED")), protect
 DECLARE auth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"AUTH")), protect
 DECLARE unauth_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"UNAUTH")), protect
 DECLARE mod_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"MODIFIED")), protect
 DECLARE super_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"SUPERSEDED")), protect
 DECLARE inlab_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"IN LAB")), protect
 DECLARE inprog_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"IN PROGRESS")), protect
 DECLARE trans_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"TRANSCRIBED")), protect
 DECLARE alt_cd = f8 WITH constant(uar_get_code_by("MEANING",8,"ALTERED")), protect
 DECLARE rad_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"RAD")), protect
 DECLARE doc_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"DOC")), protect
 DECLARE placeholder_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"PLACEHOLDER")),
 protect
 DECLARE micro_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"MBO")), protect
 DECLARE mdoc_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"MDOC")), protect
 DECLARE dpowerchartcd = f8 WITH constant(uar_get_code_by("MEANING",89,"POWERCHART")), protect
 DECLARE grp_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"GRP")), protect
 DECLARE proc_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"PROCEDURE")), protect
 DECLARE procstatus_cd = f8 WITH constant(uar_get_code_by("MEANING",4000341,"SIGNED")), protect
 DECLARE ecg_cd = f8 WITH constant(uar_get_code_by("MEANING",5801,"ECG")), protect
 DECLARE dicom_siuid_cd = f8 WITH constant(uar_get_code_by("MEANING",25,"DICOM_SIUID")), protect
 DECLARE acrnema_cd = f8 WITH constant(uar_get_code_by("MEANING",23,"ACRNEMA")), protect
 DECLARE paper_format_code = f8 WITH constant(uar_get_code_by("MEANING",23,"PAPER")), protect
 DECLARE where_clause = vc WITH noconstant(""), protect
 DECLARE person_clause = vc WITH noconstant(""), protect
 DECLARE date_clause = vc WITH noconstant(""), protect
 DECLARE other_clause = vc WITH noconstant(""), protect
 DECLARE event_clause = vc WITH noconstant(""), protect
 DECLARE c1 = vc WITH noconstant(""), protect
 DECLARE c2 = vc WITH noconstant(""), protect
 DECLARE c3 = vc WITH noconstant(""), protect
 DECLARE ce_filter = vc WITH noconstant("")
 DECLARE ce_pending = vc WITH noconstant("")
 DECLARE mill_micro_clause = vc WITH noconstant("")
 DECLARE fsi_micro_clause = vc WITH noconstant("")
 DECLARE event_id_cnt = i4 WITH noconstant(0)
 DECLARE count1 = i4 WITH noconstant(0)
 DECLARE flex_sect_type = i4 WITH constant(6)
 DECLARE rad_sect_type = i4 WITH constant(14)
 DECLARE ap_sect_type = i4 WITH constant(18)
 DECLARE pwrfrm_sect_type = i4 WITH constant(21)
 DECLARE hla_sect_type = i4 WITH constant(22)
 DECLARE doc_sect_type = i4 WITH constant(25)
 DECLARE allergy_sect_type = i4 WITH constant(30)
 DECLARE prblm_sect_type = i4 WITH constant(31)
 DECLARE orders_sect_type = i4 WITH constant(33)
 DECLARE mar_sect_type = i4 WITH constant(34)
 DECLARE namehst_sect_type = i4 WITH constant(35)
 DECLARE immun_sect_type = i4 WITH constant(37)
 DECLARE prochst_sect_type = i4 WITH constant(38)
 DECLARE care_plan_type = i4 WITH constant(40)
 DECLARE expedite_request_type = i2 WITH constant(2)
 DECLARE encntr_nbr = i4 WITH constant(size(request->encntr_list,5)), protect
 DECLARE event_nbr = i4 WITH noconstant(size(request->event_list,5)), protect
 DECLARE section_nbr = i4 WITH noconstant(size(request->section_list,5)), protect
 DECLARE found_namehist_section_ind = i2 WITH noconstant(0), protect
 DECLARE radiologyeventcodecount_es = i4 WITH noconstant(0), protect
 DECLARE radiologyeventcodecount_cc = i4 WITH noconstant(0), protect
 DECLARE nonradiologyeventcodecount_es = i4 WITH noconstant(0), protect
 DECLARE nonradiologyeventcodecount_cc = i4 WITH noconstant(0), protect
 DECLARE bind_cnt = i4 WITH constant(50), protect
 DECLARE encntr_level_doc = i2 WITH constant(1)
 DECLARE patient_level_doc = i2 WITH constant(2)
 DECLARE getallsections(null) = null
 DECLARE checkformatfornoeventsections(null) = null
 DECLARE buildpersonclause(null) = null
 DECLARE builddateclause(null) = null
 DECLARE buildotherclause(null) = null
 DECLARE buildeventclause(null) = null
 DECLARE geteventsetordercatcounters(null) = null
 DECLARE checkdocumentsectionactivity(null) = null
 SET reply->status_data.status = "Z"
 IF ((request->date_range_ind=1))
  SET begin_dt_tm = cnvtdatetime(request->begin_dt_tm)
  SET end_dt_tm = cnvtdatetime(request->end_dt_tm)
 ELSE
  SET begin_dt_tm = cnvtdatetime("01-jan-1800 00:00:00.00")
  SET end_dt_tm = cnvtdatetime(sysdate)
 ENDIF
 IF (section_nbr=0)
  CALL getallsections(null)
 ENDIF
 CALL checkformatfornoeventsections(null)
 DECLARE dta_chart_format_id = f8 WITH constant(request->chart_format_id)
 DECLARE dta_chart_section_id = f8 WITH constant(0.0)
 DECLARE dta_get_ap_history = i2 WITH constant(0)
 DECLARE dta_check_ap_flag = i2 WITH constant(0)
 RECORD dta_specific_event_cds(
   1 qual[*]
     2 event_cd = f8
 )
 FREE RECORD activity_rec
 RECORD activity_rec(
   1 activity[*]
     2 chart_section_id = f8
     2 section_seq = i4
     2 section_type_flag = i2
     2 chart_group_id = f8
     2 group_seq = i4
     2 zone = i4
     2 flex_type_flag = i2
     2 doc_type_flag = i2
     2 procedure_seq = i4
     2 procedure_type_flag = i2
     2 event_set_name = vc
     2 dcp_forms_ref_id = f8
     2 catalog_cd = f8
     2 event_cds[*]
       3 event_cd = f8
       3 task_assay_cd = f8
       3 suppressed_ind = i2
   1 parent_event_ids[*]
     2 parent_event_id = f8
   1 inerr_events[*]
     2 event_id = f8
 )
 DECLARE parser_clause = vc WITH private
 DECLARE hit_bbxm_section = i2 WITH noconstant(0)
 DECLARE added_ec_for_es_bbxm_section = i2 WITH noconstant(0)
 DECLARE bbproduct = f8 WITH constant(uar_get_code_by("DISPLAYKEY",72,"BBPRODUCT")), protect
 IF (dta_chart_section_id > 0)
  SET parser_clause = build("cfs.chart_format_id = ",dta_chart_format_id,
   " and cfs.chart_section_id = ",dta_chart_section_id)
 ELSE
  SET parser_clause = build("cfs.chart_format_id = ",dta_chart_format_id)
 ENDIF
 IF (dta_get_ap_history=0)
  IF (size(dta_specific_event_cds->qual,5)=0)
   SELECT DISTINCT INTO "nl:"
    check = decode(esc.seq,"esc",cver.seq,"orc")
    FROM chart_form_sects cfs,
     chart_section cs,
     chart_group cg,
     chart_ap_format caf,
     chart_flex_format cff,
     chart_grp_evnt_set cges,
     v500_event_set_code esc,
     v500_event_set_explode ese,
     profile_task_r ptr,
     code_value_event_r cver,
     chart_grp_evnt_suppress cgess,
     chart_doc_format cdf,
     dummyt d1,
     dummyt d2
    PLAN (cfs
     WHERE parser(parser_clause))
     JOIN (cs
     WHERE cs.chart_section_id=cfs.chart_section_id)
     JOIN (cg
     WHERE cg.chart_section_id=cs.chart_section_id)
     JOIN (caf
     WHERE (caf.chart_group_id= Outerjoin(cg.chart_group_id)) )
     JOIN (cff
     WHERE (cff.chart_group_id= Outerjoin(cg.chart_group_id)) )
     JOIN (cges
     WHERE cges.chart_group_id=cg.chart_group_id)
     JOIN (cdf
     WHERE (cdf.chart_group_id= Outerjoin(cg.chart_group_id)) )
     JOIN (d1)
     JOIN (((esc
     WHERE cges.procedure_type_flag=0
      AND esc.event_set_name=cges.event_set_name)
     JOIN (ese
     WHERE ese.event_set_cd=esc.event_set_cd)
     ) ORJOIN ((d2)
     JOIN (ptr
     WHERE cges.procedure_type_flag=1
      AND ptr.catalog_cd=cges.order_catalog_cd
      AND ptr.catalog_cd > 0)
     JOIN (cgess
     WHERE (cgess.chart_group_id= Outerjoin(cges.chart_group_id))
      AND (cgess.order_catalog_cd= Outerjoin(ptr.catalog_cd))
      AND (cgess.task_assay_cd= Outerjoin(ptr.task_assay_cd)) )
     JOIN (cver
     WHERE ((cver.parent_cd=ptr.task_assay_cd) OR (cver.parent_cd=ptr.catalog_cd))
      AND cver.parent_cd > 0)
     ))
    ORDER BY cfs.cs_sequence_num, cg.cg_sequence, cges.zone,
     cges.event_set_seq, ese.event_cd, cver.event_cd
    HEAD REPORT
     activitycnt = 0, codecnt = 0
    HEAD cfs.cs_sequence_num
     IF (cs.section_type_flag=6
      AND cff.flex_type=0)
      hit_bbxm_section = 1, added_ec_for_es_bbxm_section = 0
     ENDIF
    HEAD cg.cg_sequence
     do_nothing = 0
    HEAD cges.zone
     do_nothing = 0
    HEAD cges.event_set_seq
     IF (((dta_check_ap_flag=1
      AND caf.ap_history_flag=0) OR (dta_check_ap_flag=0)) )
      activitycnt += 1
      IF (mod(activitycnt,10)=1)
       stat = alterlist(activity_rec->activity[activitycnt],(activitycnt+ 9))
      ENDIF
      activity_rec->activity[activitycnt].chart_section_id = cfs.chart_section_id, activity_rec->
      activity[activitycnt].section_seq = cfs.cs_sequence_num, activity_rec->activity[activitycnt].
      section_type_flag = cs.section_type_flag,
      activity_rec->activity[activitycnt].chart_group_id = cg.chart_group_id, activity_rec->activity[
      activitycnt].group_seq = cg.cg_sequence, activity_rec->activity[activitycnt].zone = cges.zone,
      activity_rec->activity[activitycnt].procedure_seq = cges.event_set_seq, activity_rec->activity[
      activitycnt].procedure_type_flag = cges.procedure_type_flag, activity_rec->activity[activitycnt
      ].event_set_name = cges.event_set_name,
      activity_rec->activity[activitycnt].catalog_cd = cges.order_catalog_cd, activity_rec->activity[
      activitycnt].flex_type_flag = cff.flex_type, activity_rec->activity[activitycnt].doc_type_flag
       = cdf.doc_type_flag
     ENDIF
    DETAIL
     IF (((dta_check_ap_flag=1
      AND caf.ap_history_flag=0) OR (dta_check_ap_flag=0)) )
      IF (cgess.task_assay_cd=0
       AND cgess.event_cd=0)
       codecnt += 1
       IF (mod(codecnt,10)=1)
        stat = alterlist(activity_rec->activity[activitycnt].event_cds,(codecnt+ 9))
       ENDIF
       IF (check="esc")
        IF (hit_bbxm_section=0)
         activity_rec->activity[activitycnt].event_cds[codecnt].event_cd = ese.event_cd
        ELSE
         IF (added_ec_for_es_bbxm_section=0)
          activity_rec->activity[activitycnt].event_cds[codecnt].event_cd = bbproduct,
          added_ec_for_es_bbxm_section = 1
         ENDIF
        ENDIF
       ELSE
        IF (hit_bbxm_section=0)
         activity_rec->activity[activitycnt].event_cds[codecnt].event_cd = cver.event_cd
        ELSE
         activity_rec->activity[activitycnt].event_cds[codecnt].event_cd = bbproduct
        ENDIF
       ENDIF
      ENDIF
     ENDIF
    FOOT  cges.event_set_seq
     IF (((dta_check_ap_flag=1
      AND caf.ap_history_flag=0) OR (dta_check_ap_flag=0)) )
      stat = alterlist(activity_rec->activity[activitycnt].event_cds,codecnt), codecnt = 0
     ENDIF
    FOOT  cges.zone
     do_nothing = 0
    FOOT  cg.cg_sequence
     do_nothing = 0
    FOOT  cfs.cs_sequence_num
     hit_bbxm_section = 0
    FOOT REPORT
     stat = alterlist(activity_rec->activity,activitycnt)
    WITH nocounter
   ;end select
  ELSE
   SELECT DISTINCT INTO "nl:"
    FROM chart_form_sects cfs,
     chart_section cs,
     chart_group cg,
     chart_grp_evnt_set cges,
     v500_event_set_code esc,
     v500_event_set_explode ese,
     chart_doc_format cdf,
     (dummyt d  WITH seq = value(size(dta_specific_event_cds->qual,5)))
    PLAN (d)
     JOIN (ese
     WHERE (ese.event_cd=dta_specific_event_cds->qual[d.seq].event_cd))
     JOIN (esc
     WHERE esc.event_set_cd=ese.event_set_cd)
     JOIN (cges
     WHERE cges.event_set_name=esc.event_set_name
      AND cges.procedure_type_flag=0)
     JOIN (cg
     WHERE cg.chart_group_id=cges.chart_group_id)
     JOIN (cdf
     WHERE cdf.chart_group_id=cges.chart_group_id)
     JOIN (cfs
     WHERE parser(parser_clause)
      AND cfs.chart_section_id=cg.chart_section_id)
     JOIN (cs
     WHERE cs.chart_section_id=cfs.chart_section_id)
    ORDER BY cfs.cs_sequence_num, cg.cg_sequence, cges.zone,
     cges.event_set_seq, ese.event_cd
    HEAD REPORT
     activitycnt = 0, codecnt = 0
    HEAD cfs.cs_sequence_num
     do_nothing = 0
    HEAD cg.cg_sequence
     do_nothing = 0
    HEAD cges.zone
     do_nothing = 0
    HEAD cges.event_set_seq
     activitycnt += 1
     IF (mod(activitycnt,5)=1)
      stat = alterlist(activity_rec->activity[activitycnt],(activitycnt+ 4))
     ENDIF
     activity_rec->activity[activitycnt].chart_section_id = cfs.chart_section_id, activity_rec->
     activity[activitycnt].section_seq = cfs.cs_sequence_num, activity_rec->activity[activitycnt].
     section_type_flag = cs.section_type_flag,
     activity_rec->activity[activitycnt].chart_group_id = cg.chart_group_id, activity_rec->activity[
     activitycnt].group_seq = cg.cg_sequence, activity_rec->activity[activitycnt].zone = cges.zone,
     activity_rec->activity[activitycnt].procedure_seq = cges.event_set_seq, activity_rec->activity[
     activitycnt].procedure_type_flag = cges.procedure_type_flag, activity_rec->activity[activitycnt]
     .event_set_name = cges.event_set_name,
     activity_rec->activity[activitycnt].catalog_cd = cges.order_catalog_cd, activity_rec->activity[
     activitycnt].flex_type_flag = 0, activity_rec->activity[activitycnt].doc_type_flag = cdf
     .doc_type_flag
    DETAIL
     codecnt += 1
     IF (mod(codecnt,5)=1)
      stat = alterlist(activity_rec->activity[activitycnt].event_cds,(codecnt+ 4))
     ENDIF
     activity_rec->activity[activitycnt].event_cds[codecnt].event_cd = ese.event_cd
    FOOT  cges.event_set_seq
     stat = alterlist(activity_rec->activity[activitycnt].event_cds,codecnt), codecnt = 0
    FOOT  cges.zone
     do_nothing = 0
    FOOT  cg.cg_sequence
     do_nothing = 0
    FOOT  cfs.cs_sequence_num
     do_nothing = 0
    FOOT REPORT
     stat = alterlist(activity_rec->activity,activitycnt)
    WITH nocounter
   ;end select
  ENDIF
 ELSE
  SELECT DISTINCT INTO "nl:"
   check = decode(esc.seq,"esc",ptr.seq,"orc")
   FROM chart_format cf,
    chart_section cs,
    chart_form_sects cfs,
    chart_group cg,
    chart_ap_format caf,
    chart_grp_evnt_set cges,
    v500_event_set_code esc,
    v500_event_set_explode ese,
    profile_task_r ptr,
    code_value_event_r cver,
    dummyt d1,
    dummyt d2
   PLAN (cf
    WHERE cf.chart_format_id=dta_chart_format_id)
    JOIN (cs
    WHERE cs.section_type_flag=18)
    JOIN (cfs
    WHERE cfs.chart_format_id=cf.chart_format_id
     AND cfs.chart_section_id=cs.chart_section_id)
    JOIN (cg
    WHERE cg.chart_section_id=cfs.chart_section_id)
    JOIN (caf
    WHERE caf.chart_group_id=cg.chart_group_id
     AND caf.ap_history_flag=1)
    JOIN (cges
    WHERE cges.chart_group_id=cg.chart_group_id)
    JOIN (d1)
    JOIN (((esc
    WHERE cges.procedure_type_flag=0
     AND esc.event_set_name=cges.event_set_name)
    JOIN (ese
    WHERE ese.event_set_cd=esc.event_set_cd)
    ) ORJOIN ((d2)
    JOIN (ptr
    WHERE cges.procedure_type_flag=1
     AND ptr.catalog_cd=cges.order_catalog_cd
     AND ptr.catalog_cd > 0)
    JOIN (cver
    WHERE ((cver.parent_cd=ptr.task_assay_cd) OR (cver.parent_cd=ptr.catalog_cd))
     AND cver.parent_cd > 0)
    ))
   ORDER BY cfs.cs_sequence_num, cg.cg_sequence, cges.zone,
    cges.event_set_seq, ese.event_cd, cver.event_cd
   HEAD REPORT
    activitycnt = 0, codecnt = 0
   HEAD cfs.cs_sequence_num
    do_nothing = 0
   HEAD cg.cg_sequence
    do_nothing = 0
   HEAD cges.zone
    do_nothing = 0
   HEAD cges.event_set_seq
    activitycnt += 1
    IF (mod(activitycnt,10)=1)
     stat = alterlist(activity_rec->activity[activitycnt],(activitycnt+ 9))
    ENDIF
    activity_rec->activity[activitycnt].chart_section_id = cfs.chart_section_id, activity_rec->
    activity[activitycnt].section_seq = cfs.cs_sequence_num, activity_rec->activity[activitycnt].
    section_type_flag = 18,
    activity_rec->activity[activitycnt].chart_group_id = cg.chart_group_id, activity_rec->activity[
    activitycnt].group_seq = cg.cg_sequence, activity_rec->activity[activitycnt].zone = cges.zone,
    activity_rec->activity[activitycnt].procedure_seq = cges.event_set_seq, activity_rec->activity[
    activitycnt].procedure_type_flag = cges.procedure_type_flag, activity_rec->activity[activitycnt].
    event_set_name = cges.event_set_name,
    activity_rec->activity[activitycnt].catalog_cd = cges.order_catalog_cd
   DETAIL
    codecnt += 1
    IF (mod(codecnt,10)=1)
     stat = alterlist(activity_rec->activity[activitycnt].event_cds,(codecnt+ 9))
    ENDIF
    IF (check="esc")
     activity_rec->activity[activitycnt].event_cds[codecnt].event_cd = ese.event_cd
    ELSE
     activity_rec->activity[activitycnt].event_cds[codecnt].event_cd = cver.event_cd
    ENDIF
   FOOT  cges.event_set_seq
    stat = alterlist(activity_rec->activity[activitycnt].event_cds,codecnt), codecnt = 0
   FOOT  cges.zone
    do_nothing = 0
   FOOT  cg.cg_sequence
    do_nothing = 0
   FOOT  cfs.cs_sequence_num
    do_nothing = 0
   FOOT REPORT
    stat = alterlist(activity_rec->activity,activitycnt)
   WITH nocounter
  ;end select
 ENDIF
 CALL buildpersonclause(null)
 CALL builddateclause(null)
 CALL buildotherclause(null)
 CALL buildeventclause(null)
 SET where_clause = concat(person_clause," ",date_clause," ",other_clause,
  " ",event_clause)
 CALL log_message(build("where_clause = ",where_clause),log_level_debug)
 SELECT DISTINCT INTO "nl:"
  FROM clinical_event ce
  WHERE parser(where_clause)
  HEAD REPORT
   event_id_cnt = 0
  DETAIL
   event_id_cnt += 1
   IF (mod(event_id_cnt,15)=1)
    stat = alterlist(ce_events->events,(event_id_cnt+ 14))
   ENDIF
   ce_events->events[event_id_cnt].event_id = ce.event_id
  FOOT REPORT
   stat = alterlist(ce_events->events,event_id_cnt)
  WITH nocounter
 ;end select
 CALL geteventsetordercatcounters(null)
 CALL checkdocumentsectionactivity(null)
 CALL log_message("CHECKING EVENT SETS W/ RADIOLOGY",log_level_debug)
 CALL log_message(build("event_id_cnt = ",event_id_cnt),log_level_debug)
 CALL log_message(build("RadiologyEventCodeCount_ES = ",radiologyeventcodecount_es),log_level_debug)
 IF (radiologyeventcodecount_es > 0)
  SELECT
   IF (event_id_cnt > radiologyeventcodecount_es)
    FROM clinical_event ce,
     ce_linked_result clr,
     (dummyt d1  WITH seq = value(size(activity_rec->activity,5))),
     (dummyt d2  WITH seq = value(size(request->section_list,5))),
     (dummyt d3  WITH seq = 1)
    PLAN (d1
     WHERE (activity_rec->activity[d1.seq].procedure_type_flag=0)
      AND (activity_rec->activity[d1.seq].section_type_flag=rad_sect_type))
     JOIN (d2
     WHERE (request->section_list[d2.seq].section_id=activity_rec->activity[d1.seq].chart_section_id)
      AND maxrec(d3,size(activity_rec->activity[d1.seq].event_cds,5)))
     JOIN (d3)
     JOIN (ce
     WHERE parser(where_clause)
      AND ce.event_class_cd=rad_class_cd
      AND ce.publish_flag=1
      AND (ce.event_cd=activity_rec->activity[d1.seq].event_cds[d3.seq].event_cd))
     JOIN (clr
     WHERE clr.event_id=ce.event_id
      AND clr.event_id > 0)
   ELSE
    FROM clinical_event ce,
     ce_linked_result clr,
     (dummyt d1  WITH seq = value(size(ce_events->events,5))),
     (dummyt d2  WITH seq = value(size(activity_rec->activity,5))),
     (dummyt d3  WITH seq = value(size(request->section_list,5))),
     (dummyt d4  WITH seq = 1)
    PLAN (d1)
     JOIN (ce
     WHERE (ce.event_id=ce_events->events[d1.seq].event_id)
      AND ce.event_class_cd=rad_class_cd
      AND ce.publish_flag=1
      AND parser(where_clause))
     JOIN (clr
     WHERE clr.event_id=ce.event_id
      AND clr.event_id > 0)
     JOIN (d2
     WHERE (activity_rec->activity[d2.seq].procedure_type_flag=0)
      AND (activity_rec->activity[d2.seq].section_type_flag=rad_sect_type))
     JOIN (d3
     WHERE (request->section_list[d3.seq].section_id=activity_rec->activity[d2.seq].chart_section_id)
      AND maxrec(d4,size(activity_rec->activity[d2.seq].event_cds,5)))
     JOIN (d4
     WHERE (activity_rec->activity[d2.seq].event_cds[d4.seq].event_cd=ce.event_cd))
   ENDIF
   INTO "nl:"
   WITH nocounter
  ;end select
  CALL error_and_zero_check(curqual,"CLINICAL_EVENT","ESWITHRAD",1,0)
  IF (curqual > 0)
   SET reply->status_data.status = "S"
   GO TO exit_script
  ENDIF
 ENDIF
 CALL log_message("CHECKING ORDER CATALOGS W/ RADIOLOGY",log_level_debug)
 CALL log_message(build("event_id_cnt = ",event_id_cnt),log_level_debug)
 CALL log_message(build("RadiologyEventCodeCount_CC = ",radiologyeventcodecount_cc),log_level_debug)
 IF (radiologyeventcodecount_cc > 0)
  SELECT
   IF (event_id_cnt > radiologyeventcodecount_cc)
    FROM clinical_event ce,
     ce_linked_result clr,
     (dummyt d1  WITH seq = value(size(activity_rec->activity,5))),
     (dummyt d2  WITH seq = value(size(request->section_list,5))),
     (dummyt d3  WITH seq = 1)
    PLAN (d1
     WHERE (activity_rec->activity[d1.seq].procedure_type_flag=1)
      AND (activity_rec->activity[d1.seq].section_type_flag=rad_sect_type))
     JOIN (d2
     WHERE (request->section_list[d2.seq].section_id=activity_rec->activity[d1.seq].chart_section_id)
      AND maxrec(d3,size(activity_rec->activity[d1.seq].event_cds,5)))
     JOIN (d3)
     JOIN (ce
     WHERE parser(where_clause)
      AND ce.event_class_cd=rad_class_cd
      AND ce.publish_flag=1
      AND (ce.catalog_cd=activity_rec->activity[d1.seq].catalog_cd)
      AND (ce.event_cd=activity_rec->activity[d1.seq].event_cds[d3.seq].event_cd))
     JOIN (clr
     WHERE clr.event_id=ce.event_id
      AND clr.event_id > 0)
   ELSE
    FROM clinical_event ce,
     ce_linked_result clr,
     (dummyt d1  WITH seq = value(size(ce_events->events,5))),
     (dummyt d2  WITH seq = value(size(request->section_list,5))),
     (dummyt d3  WITH seq = value(size(activity_rec->activity,5))),
     (dummyt d4  WITH seq = 1)
    PLAN (d1)
     JOIN (ce
     WHERE (ce.event_id=ce_events->events[d1.seq].event_id)
      AND ce.event_class_cd=rad_class_cd
      AND ce.publish_flag=1
      AND parser(where_clause))
     JOIN (clr
     WHERE clr.event_id=ce.event_id
      AND clr.event_id > 0)
     JOIN (d2)
     JOIN (d3
     WHERE (activity_rec->activity[d3.seq].procedure_type_flag=1)
      AND (activity_rec->activity[d3.seq].section_type_flag=rad_sect_type)
      AND (activity_rec->activity[d3.seq].chart_section_id=request->section_list[d2.seq].section_id)
      AND maxrec(d4,size(activity_rec->activity[d3.seq].event_cds,5)))
     JOIN (d4
     WHERE (activity_rec->activity[d3.seq].catalog_cd=ce.catalog_cd)
      AND (activity_rec->activity[d3.seq].event_cds[d4.seq].event_cd=ce.event_cd))
   ENDIF
   INTO "nl:"
   WITH nocounter
  ;end select
  CALL error_and_zero_check(curqual,"CLINICAL_EVENT","OCWITHRAD",1,0)
  IF (curqual > 0)
   SET reply->status_data.status = "S"
   GO TO exit_script
  ENDIF
 ENDIF
 CALL log_message("CHECKING EVENT SETS W/O RADIOLOGY",log_level_debug)
 CALL log_message(build("event_id_cnt = ",event_id_cnt),log_level_debug)
 CALL log_message(build("NonRadiologyEventCodeCount_ES = ",nonradiologyeventcodecount_es),
  log_level_debug)
 IF (nonradiologyeventcodecount_es > 0)
  SELECT
   IF (event_id_cnt > nonradiologyeventcodecount_es)
    sect_type = activity_rec->activity[d1.seq].section_type_flag, flex_type = activity_rec->activity[
    d1.seq].flex_type_flag
    FROM clinical_event ce,
     (dummyt d1  WITH seq = value(size(activity_rec->activity,5))),
     (dummyt d2  WITH seq = value(size(request->section_list,5))),
     (dummyt d3  WITH seq = 1)
    PLAN (d1
     WHERE (activity_rec->activity[d1.seq].procedure_type_flag=0)
      AND  NOT ((activity_rec->activity[d1.seq].section_type_flag IN (rad_sect_type, doc_sect_type)))
     )
     JOIN (d2
     WHERE (request->section_list[d2.seq].section_id=activity_rec->activity[d1.seq].chart_section_id)
      AND maxrec(d3,size(activity_rec->activity[d1.seq].event_cds,5)))
     JOIN (d3)
     JOIN (ce
     WHERE parser(where_clause)
      AND ce.event_class_cd != rad_class_cd
      AND (ce.event_cd=activity_rec->activity[d1.seq].event_cds[d3.seq].event_cd))
   ELSE
    sect_type = activity_rec->activity[d2.seq].section_type_flag, flex_type = activity_rec->activity[
    d2.seq].flex_type_flag
    FROM clinical_event ce,
     (dummyt d1  WITH seq = value(size(ce_events->events,5))),
     (dummyt d2  WITH seq = value(size(activity_rec->activity,5))),
     (dummyt d3  WITH seq = value(size(request->section_list,5))),
     (dummyt d4  WITH seq = 1)
    PLAN (d1)
     JOIN (ce
     WHERE (ce.event_id=ce_events->events[d1.seq].event_id)
      AND ce.event_class_cd != rad_class_cd
      AND parser(where_clause))
     JOIN (d2
     WHERE (activity_rec->activity[d2.seq].procedure_type_flag=0)
      AND  NOT ((activity_rec->activity[d2.seq].section_type_flag IN (rad_sect_type, doc_sect_type)))
     )
     JOIN (d3
     WHERE (request->section_list[d3.seq].section_id=activity_rec->activity[d2.seq].chart_section_id)
      AND maxrec(d4,size(activity_rec->activity[d2.seq].event_cds,5)))
     JOIN (d4
     WHERE (activity_rec->activity[d2.seq].event_cds[d4.seq].event_cd=ce.event_cd))
   ENDIF
   INTO "nl:"
   HEAD REPORT
    count1 = 0
   DETAIL
    IF (((sect_type=flex_sect_type
     AND flex_type=0
     AND ce.view_level=0
     AND ce.publish_flag=1) OR (((sect_type=flex_sect_type
     AND flex_type=1
     AND ce.view_level=1
     AND ce.publish_flag=1) OR (((sect_type=ap_sect_type
     AND (request->pending_flag=0)
     AND ce.view_level=0
     AND ce.publish_flag=1) OR (((sect_type=ap_sect_type
     AND (request->pending_flag > 0)
     AND ce.view_level=0
     AND ce.publish_flag > 0) OR (((sect_type=pwrfrm_sect_type
     AND ce.view_level >= 0
     AND ce.publish_flag=1) OR (((sect_type=hla_sect_type
     AND ce.view_level=1
     AND ce.publish_flag=1) OR (sect_type != flex_sect_type
     AND sect_type != ap_sect_type
     AND sect_type != pwrfrm_sect_type
     AND sect_type != hla_sect_type
     AND sect_type != doc_sect_type
     AND ce.view_level > 0
     AND ce.publish_flag=1)) )) )) )) )) )) )
     count1 += 1
    ENDIF
   WITH nocounter
  ;end select
  CALL error_and_zero_check(curqual,"CLINICAL_EVENT","ESWITHOUTRAD",1,0)
  IF (count1 > 0)
   SET reply->status_data.status = "S"
   GO TO exit_script
  ENDIF
 ENDIF
 CALL log_message("CHECKING ORDER CATALOGS W/O RADIOLOGY",log_level_debug)
 CALL log_message(build("event_id_cnt = ",event_id_cnt),log_level_debug)
 CALL log_message(build("NonRadiologyEventCodeCount_CC = ",nonradiologyeventcodecount_cc),
  log_level_debug)
 IF (nonradiologyeventcodecount_cc > 0)
  SELECT
   IF (event_id_cnt > nonradiologyeventcodecount_cc)
    sect_type = activity_rec->activity[d1.seq].section_type_flag, flex_type = activity_rec->activity[
    d1.seq].flex_type_flag
    FROM clinical_event ce,
     (dummyt d1  WITH seq = value(size(activity_rec->activity,5))),
     (dummyt d2  WITH seq = value(size(request->section_list,5))),
     (dummyt d3  WITH seq = 1)
    PLAN (d1
     WHERE (activity_rec->activity[d1.seq].procedure_type_flag=1)
      AND  NOT ((activity_rec->activity[d1.seq].section_type_flag IN (rad_sect_type, doc_sect_type)))
     )
     JOIN (d2
     WHERE (request->section_list[d2.seq].section_id=activity_rec->activity[d1.seq].chart_section_id)
      AND maxrec(d3,size(activity_rec->activity[d1.seq].event_cds,5)))
     JOIN (d3)
     JOIN (ce
     WHERE parser(where_clause)
      AND ce.event_class_cd != rad_class_cd
      AND (ce.catalog_cd=activity_rec->activity[d1.seq].catalog_cd)
      AND (ce.event_cd=activity_rec->activity[d1.seq].event_cds[d3.seq].event_cd))
   ELSE
    sect_type = activity_rec->activity[d3.seq].section_type_flag, flex_type = activity_rec->activity[
    d3.seq].flex_type_flag
    FROM clinical_event ce,
     (dummyt d1  WITH seq = value(size(ce_events->events,5))),
     (dummyt d2  WITH seq = value(size(request->section_list,5))),
     (dummyt d3  WITH seq = value(size(activity_rec->activity,5))),
     (dummyt d4  WITH seq = 1)
    PLAN (d1)
     JOIN (ce
     WHERE (ce.event_id=ce_events->events[d1.seq].event_id)
      AND ce.event_class_cd != rad_class_cd
      AND parser(where_clause))
     JOIN (d2)
     JOIN (d3
     WHERE (activity_rec->activity[d3.seq].procedure_type_flag=1)
      AND (activity_rec->activity[d3.seq].chart_section_id=request->section_list[d2.seq].section_id)
      AND  NOT ((activity_rec->activity[d3.seq].section_type_flag IN (rad_sect_type, doc_sect_type)))
      AND maxrec(d4,size(activity_rec->activity[d3.seq].event_cds,5)))
     JOIN (d4
     WHERE (activity_rec->activity[d3.seq].catalog_cd=ce.catalog_cd)
      AND (activity_rec->activity[d3.seq].event_cds[d4.seq].event_cd=ce.event_cd))
   ENDIF
   INTO "nl:"
   HEAD REPORT
    count1 = 0
   DETAIL
    IF (((sect_type=flex_sect_type
     AND flex_type=0
     AND ce.view_level=0
     AND ce.publish_flag=1) OR (((sect_type=flex_sect_type
     AND flex_type=1
     AND ce.view_level=1
     AND ce.publish_flag=1) OR (((sect_type=ap_sect_type
     AND (request->pending_flag=0)
     AND ce.view_level=0
     AND ce.publish_flag=1) OR (((sect_type=ap_sect_type
     AND (request->pending_flag > 0)
     AND ce.view_level=0
     AND ce.publish_flag > 0) OR (((sect_type=pwrfrm_sect_type
     AND ce.view_level >= 0
     AND ce.publish_flag=1) OR (((sect_type=hla_sect_type
     AND ce.view_level=1
     AND ce.publish_flag=1) OR (sect_type != flex_sect_type
     AND sect_type != ap_sect_type
     AND sect_type != pwrfrm_sect_type
     AND sect_type != hla_sect_type
     AND sect_type != doc_sect_type
     AND ce.view_level > 0
     AND ce.publish_flag=1)) )) )) )) )) )) )
     count1 += 1
    ENDIF
   WITH nocounter
  ;end select
  CALL error_and_zero_check(curqual,"CLINICAL_EVENT","OCWITHOUTRAD",1,0)
  IF (count1 > 0)
   SET reply->status_data.status = "S"
   GO TO exit_script
  ENDIF
 ENDIF
 SUBROUTINE getallsections(null)
   CALL log_message("In GetAllSections()",log_level_debug)
   CALL log_message("Section-level authentication not supported",log_level_debug)
   SELECT INTO "nl:"
    FROM chart_form_sects cfs
    WHERE (cfs.chart_format_id=request->chart_format_id)
     AND cfs.active_ind=1
    DETAIL
     section_nbr += 1
     IF (mod(section_nbr,10)=1)
      stat = alterlist(request->section_list,(section_nbr+ 9))
     ENDIF
     request->section_list[section_nbr].section_id = cfs.chart_section_id
    FOOT REPORT
     stat = alterlist(request->section_list,section_nbr)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_FORM_SECTS","GETALLSECTIONS",1,0)
   CALL echorecord(request)
 END ;Subroutine
 SUBROUTINE buildpersonclause(null)
  CALL log_message("In BuildPersonClause()",log_level_debug)
  CASE (request->scope_flag)
   OF 1:
    SET person_clause = build("ce.person_id = ",request->person_id)
   OF 2:
    SET c1 = build("ce.person_id = ",request->person_id)
    SET c2 = build(" and ce.encntr_id = ",request->encntr_id," and ce.encntr_id > 0")
    SET person_clause = concat(c1," ",c2)
   OF 4:
    SET c1 = build("ce.accession_nbr = '",request->accession_nbr,"'")
    SET c2 = build(" and ce.person_id+0 = ",request->person_id)
    SET c3 = build(" and ce.encntr_id+0 = ",request->encntr_id)
    SET person_clause = concat(c1," ",c2," ",c3)
   OF 5:
    SET c1 = build("ce.person_id = ",request->person_id)
    SET encntrcnt = size(request->encntr_list,5)
    IF (encntrcnt > 0)
     SET c2 = " and ce.encntr_id in ("
     FOR (i = 1 TO encntrcnt)
      SET c2 = build(c2,request->encntr_list[i].encntr_id)
      IF (i < encntrcnt)
       SET c2 = build(c2,", ")
      ENDIF
     ENDFOR
     SET c2 = build(c2,")")
    ENDIF
    SET person_clause = concat(c1," ",c2)
  ENDCASE
 END ;Subroutine
 SUBROUTINE builddateclause(null)
   CALL log_message("In BuildDateClause()",log_level_debug)
   SET c1 = "and ce.valid_until_dt_tm >= cnvtdatetime('31-Dec-2100')"
   IF ((request->request_type=expedite_request_type))
    SET c2 = "(ce.verified_dt_tm between cnvtdatetime(begin_dt_tm) and cnvtdatetime(end_dt_tm)"
    SET c2 = concat(c2," or ce.performed_dt_tm between ",
     "cnvtdatetime(begin_dt_tm) and cnvtdatetime(end_dt_tm)")
    SET c2 = concat(c2," or ce.event_end_dt_tm between ",
     "cnvtdatetime(begin_dt_tm) and cnvtdatetime(end_dt_tm))")
   ELSE
    IF ((request->result_lookup_ind=1))
     SET c2 = "(ce.event_end_dt_tm+0"
    ELSE
     SET c2 = "(ce.clinsig_updt_dt_tm+0"
    ENDIF
    SET c2 = concat(c2," between cnvtdatetime(begin_dt_tm) and cnvtdatetime(end_dt_tm))")
   ENDIF
   SET date_clause = concat(c1," and ",c2)
 END ;Subroutine
 SUBROUTINE buildotherclause(null)
   CALL log_message("In BuildOtherClause()",log_level_debug)
   SET ce_filter =
   " and ce.view_level >= 0 and ce.publish_flag > 0 and ce.event_class_cd != placeholder_class_cd"
   SET ce_filter = concat(ce_filter," and ce.record_status_cd != del_stat_cd")
   IF ((request->pending_flag=0))
    SET ce_pending = "ce.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd)"
   ELSEIF ((request->pending_flag=1))
    SET ce_pending =
    "ce.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd, inlab_cd, inprog_cd)"
   ELSE
    SET ce_pending =
    "ce.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd, inlab_cd, inprog_cd, trans_cd, unauth_cd)"
   ENDIF
   SET fsi_micro_clause = concat(ce_pending," and ce.event_class_cd = micro_class_cd",
    " and ce.contributor_system_cd != dPowerchartCd")
   SET mill_micro_clause =
   "ce.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd,inlab_cd, inprog_cd, trans_cd, unauth_cd)"
   SET mill_micro_clause = concat(mill_micro_clause," and ce.event_class_cd = micro_class_cd",
    " and ce.contributor_system_cd = dPowerchartCd")
   SET ce_pending = concat(ce_pending," and ce.event_class_cd != micro_class_cd")
   SET other_clause = concat(ce_filter," and ((",ce_pending,") OR (",fsi_micro_clause,
    ") OR (",mill_micro_clause,"))")
 END ;Subroutine
 SUBROUTINE buildeventclause(null)
  CALL log_message("In BuildEventClause()",log_level_debug)
  IF (event_nbr != 0)
   CALL getchildevents(null)
   SET c1 = " and ce.event_id in ("
   FOR (i = 1 TO event_nbr)
    SET c1 = build(c1,request->event_list[i].event_id)
    IF (i < event_nbr)
     SET c1 = build(c1,", ")
    ENDIF
   ENDFOR
   SET event_clause = build(c1,")")
  ENDIF
 END ;Subroutine
 SUBROUTINE checkformatfornoeventsections(null)
   CALL log_message("In CheckFormatForNoEventSections()",log_level_debug)
   DECLARE sec_nbr = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    cs.section_type_flag
    FROM chart_form_sects cfs,
     chart_section cs,
     (dummyt st  WITH seq = value(section_nbr))
    PLAN (st)
     JOIN (cfs
     WHERE (cfs.chart_format_id=request->chart_format_id)
      AND cfs.active_ind=1
      AND (cfs.chart_section_id=request->section_list[st.seq].section_id))
     JOIN (cs
     WHERE cs.chart_section_id=cfs.chart_section_id
      AND cs.active_ind=1
      AND cs.section_type_flag IN (allergy_sect_type, prblm_sect_type, orders_sect_type,
     mar_sect_type, namehst_sect_type,
     immun_sect_type, prochst_sect_type, care_plan_type))
    HEAD REPORT
     sec_nbr = 0
    DETAIL
     sec_nbr += 1
     IF (mod(sec_nbr,10)=1)
      stat = alterlist(section->sec_list,(sec_nbr+ 9))
     ENDIF
     section->sec_list[sec_nbr].sec_type = cs.section_type_flag
     IF (cs.section_type_flag=namehst_sect_type)
      found_namehist_section_ind = 1
     ENDIF
    FOOT REPORT
     stat = alterlist(section->sec_list,sec_nbr)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHART_FORM_SECTS","CHECKFORMATFORNOEVENTSECTIONS",1,0)
   IF (found_namehist_section_ind=1)
    SET reply->status_data.status = "S"
    GO TO exit_script
   ENDIF
   IF (sec_nbr > 0)
    FOR (i = 1 TO sec_nbr)
      CASE (section->sec_list[i].sec_type)
       OF allergy_sect_type:
        CALL check_allergy(i)
       OF prblm_sect_type:
        CALL check_problem(i)
       OF orders_sect_type:
        CALL check_orders(i)
       OF mar_sect_type:
        CALL check_mar(i)
       OF immun_sect_type:
        CALL check_immunization(i)
       OF prochst_sect_type:
        CALL check_procedure_hist(i)
      ENDCASE
    ENDFOR
   ENDIF
 END ;Subroutine
 SUBROUTINE check_allergy(j)
   CALL log_message("In check_allergy()",log_level_debug)
   SELECT INTO "nl:"
    FROM allergy a,
     prsnl p
    PLAN (a
     WHERE (a.person_id=request->person_id)
      AND a.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND a.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (p
     WHERE p.person_id=a.created_prsnl_id)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"ALLERGY","CHECK_ALLERGY",1,0)
   IF (curqual > 0)
    SET reply->status_data.status = "S"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE check_problem(j)
   CALL log_message("In check_problem()",log_level_debug)
   SELECT INTO "nl:"
    FROM problem p,
     nomenclature n,
     prsnl pr
    PLAN (p
     WHERE (p.person_id=request->person_id)
      AND p.problem_id > 0
      AND p.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND p.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (n
     WHERE n.nomenclature_id=p.nomenclature_id)
     JOIN (pr
     WHERE pr.person_id=p.updt_id)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"PROBLEM","CHECK_PROBLEM",1,0)
   IF (curqual > 0)
    SET reply->status_data.status = "S"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE check_orders(j)
   CALL log_message("In check_orders()",log_level_debug)
   DECLARE scope_clause = vc WITH noconstant(""), protect
   DECLARE date_clause = vc WITH noconstant(""), protect
   DECLARE add_alias_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"ADD ALIAS")), protect
   DECLARE clear_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"CLEAR")), protect
   DECLARE collection_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"COLLECTION")), protect
   DECLARE complete_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"COMPLETE")), protect
   DECLARE demogchange_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"DEMOGCHANGE")), protect
   DECLARE statuschange_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"STATUSCHANGE")),
   protect
   DECLARE undo_cd = f8 WITH constant(uar_get_code_by("MEANING",6003,"UNDO")), protect
   CASE (request->scope_flag)
    OF 1:
     SET scope_clause = build("o.person_id = ",request->person_id)
    OF 2:
     SET scope_clause = build("o.person_id = ",request->person_id," AND o.encntr_id = ",request->
      encntr_id)
    OF 4:
     SET scope_clause = build("o.order_id = aor.order_id"," AND o.person_id+0 = ",request->person_id,
      " AND o.encntr_id+0 = ",request->encntr_id)
   ENDCASE
   SET date_clause = "oa.action_dt_tm BETWEEN CNVTDATETIME(begin_dt_tm) AND CNVTDATETIME(end_dt_tm)"
   CASE (request->scope_flag)
    OF 4:
     SELECT INTO "nl:"
      FROM accession_order_r aor,
       orders o,
       order_action oa
      PLAN (aor
       WHERE (aor.accession=request->accession_nbr))
       JOIN (o
       WHERE parser(scope_clause))
       JOIN (oa
       WHERE oa.order_id=o.order_id
        AND parser(date_clause)
        AND  NOT (oa.action_type_cd IN (add_alias_cd, clear_cd, collection_cd, complete_cd,
       demogchange_cd,
       statuschange_cd, undo_cd)))
      WITH nocounter, maxqual(o,1)
     ;end select
    OF 5:
     SELECT INTO "nl:"
      FROM orders o,
       order_action oa,
       (dummyt d  WITH seq = value(encntr_nbr))
      PLAN (d)
       JOIN (o
       WHERE (o.encntr_id=request->encntr_list[d.seq].encntr_id))
       JOIN (oa
       WHERE oa.order_id=o.order_id
        AND parser(date_clause)
        AND  NOT (oa.action_type_cd IN (add_alias_cd, clear_cd, collection_cd, complete_cd,
       demogchange_cd,
       statuschange_cd, undo_cd)))
      WITH nocounter, maxqual(o,1)
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM orders o,
       order_action oa
      PLAN (o
       WHERE parser(scope_clause))
       JOIN (oa
       WHERE oa.order_id=o.order_id
        AND parser(date_clause)
        AND  NOT (oa.action_type_cd IN (add_alias_cd, clear_cd, collection_cd, complete_cd,
       demogchange_cd,
       statuschange_cd, undo_cd)))
      WITH nocounter, maxqual(o,1)
     ;end select
   ENDCASE
   CALL error_and_zero_check(curqual,"ORDER_ACTION","CHECK_ORDERS",1,0)
   IF (curqual > 0)
    SET reply->status_data.status = "S"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE check_mar(j)
   CALL log_message("In check_mar()",log_level_debug)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "cp_chk_chart_request"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "SELECT"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "ERROR! - This Chart Format contains an invalid MAR section.  Please remove from the chart format."
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE check_immunization(j)
   CALL log_message("In check_immunization()",log_level_debug)
   SELECT INTO "nl:"
    FROM clinical_event ce,
     ce_med_result cmr
    PLAN (ce
     WHERE (ce.person_id=request->person_id)
      AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
      AND ((ce.order_id+ 0)=0)
      AND ce.catalog_cd=0
      AND ce.publish_flag=1)
     JOIN (cmr
     WHERE cmr.event_id=ce.event_id
      AND cmr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
    WITH nocounter, maxqual(cmr,1)
   ;end select
   CALL error_and_zero_check(curqual,"CE_MED_RESULT","CHECK_IMMUNIZATION",1,0)
   IF (curqual > 0)
    SET reply->status_data.status = "S"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE check_procedure_hist(j)
   CALL log_message("In check_procedure_hist()",log_level_debug)
   SELECT INTO "nl:"
    FROM encounter e,
     procedure p
    PLAN (e
     WHERE (e.person_id=request->person_id)
      AND e.active_ind=1)
     JOIN (p
     WHERE p.encntr_id=e.encntr_id)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"PROCEDURE","CHECK_PROCEDURE_HIST",1,0)
   IF (curqual > 0)
    SET reply->status_data.status = "S"
    GO TO exit_script
   ENDIF
 END ;Subroutine
 SUBROUTINE getchildevents(null)
   CALL log_message("In GetChildEvents()",log_level_debug)
   DECLARE idx = i4 WITH noconstant(0), protect
   DECLARE idxstart = i4 WITH noconstant(1), protect
   DECLARE noptimizedtotal = i4 WITH noconstant(0), protect
   DECLARE nrecordsize = i4 WITH noconstant(0), protect
   DECLARE x = i4 WITH noconstant(0), protect
   RECORD flat_rec(
     1 qual[*]
       2 event_id = f8
   )
   SET stat = alterlist(flat_rec->qual,size(request->event_list,5))
   FOR (x = 1 TO size(request->event_list,5))
     SET flat_rec->qual[x].event_id = request->event_list[x].event_id
   ENDFOR
   SET nrecordsize = size(flat_rec->qual,5)
   SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
   SET stat = alterlist(flat_rec->qual,noptimizedtotal)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET flat_rec->qual[i].event_id = flat_rec->qual[nrecordsize].event_id
   ENDFOR
   SELECT DISTINCT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     clinical_event ce1,
     clinical_event ce2
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (ce1
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),ce1.event_id,flat_rec->qual[idx].event_id,
      bind_cnt)
      AND ce1.parent_event_id=ce1.event_id
      AND ce1.event_class_cd IN (mdoc_class_cd, doc_class_cd, grp_class_cd, proc_class_cd))
     JOIN (ce2
     WHERE ce2.parent_event_id=ce1.event_id
      AND ce2.parent_event_id != ce2.event_id
      AND ce2.event_class_cd=doc_class_cd
      AND ce2.publish_flag=1
      AND  NOT (expand(idx,idxstart,((idxstart+ bind_cnt) - 1),ce2.event_id,flat_rec->qual[idx].
      event_id,
      bind_cnt)))
    ORDER BY ce1.event_id, ce2.event_id, ce2.event_cd
    HEAD REPORT
     donothing = 0
    DETAIL
     event_nbr += 1
     IF (event_nbr > size(request->event_list,5))
      stat = alterlist(request->event_list,(event_nbr+ 9))
     ENDIF
     request->event_list[event_nbr].event_id = ce2.event_id
    FOOT REPORT
     stat = alterlist(request->event_list,event_nbr)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CHILD_CLINICAL_EVENT","GETCHILDEVENTS",1,0)
 END ;Subroutine
 SUBROUTINE geteventsetordercatcounters(null)
  CALL log_message("In GetEventSetOrderCatCounters()",log_level_debug)
  FOR (i = 1 TO size(activity_rec->activity,5))
    IF ((activity_rec->activity[i].procedure_type_flag=0)
     AND (activity_rec->activity[i].section_type_flag=rad_sect_type))
     SET radiologyeventcodecount_es += size(activity_rec->activity[i].event_cds,5)
    ELSEIF ((activity_rec->activity[i].procedure_type_flag=1)
     AND (activity_rec->activity[i].section_type_flag=rad_sect_type))
     SET radiologyeventcodecount_cc += size(activity_rec->activity[i].event_cds,5)
    ELSEIF ((activity_rec->activity[i].procedure_type_flag=0)
     AND (activity_rec->activity[i].section_type_flag != rad_sect_type))
     SET nonradiologyeventcodecount_es += size(activity_rec->activity[i].event_cds,5)
    ELSEIF ((activity_rec->activity[i].procedure_type_flag=1)
     AND (activity_rec->activity[i].section_type_flag != rad_sect_type))
     SET nonradiologyeventcodecount_cc += size(activity_rec->activity[i].event_cds,5)
    ENDIF
  ENDFOR
 END ;Subroutine
 SUBROUTINE checkdocumentsectionactivity(null)
   CALL log_message("In CheckDocumentSectionActivity()",log_level_debug)
   CALL log_message(build("event_id_cnt = ",event_id_cnt),log_level_debug)
   CALL log_message(build("NonRadiologyEventCodeCount_ES = ",nonradiologyeventcodecount_es),
    log_level_debug)
   FREE RECORD mdoc_flat_rec
   RECORD mdoc_flat_rec(
     1 qual[*]
       2 event_id = f8
   )
   FREE RECORD ecg_flat_rec
   RECORD ecg_flat_rec(
     1 qual[*]
       2 event_id = f8
   )
   IF (nonradiologyeventcodecount_es > 0)
    SELECT
     IF (event_id_cnt > nonradiologyeventcodecount_es)
      FROM clinical_event ce,
       (dummyt d2  WITH seq = value(size(activity_rec->activity,5))),
       (dummyt d3  WITH seq = value(size(request->section_list,5))),
       (dummyt d4  WITH seq = 1)
      PLAN (d2
       WHERE (activity_rec->activity[d2.seq].procedure_type_flag=0)
        AND (activity_rec->activity[d2.seq].section_type_flag=doc_sect_type))
       JOIN (d3
       WHERE (request->section_list[d3.seq].section_id=activity_rec->activity[d2.seq].
       chart_section_id)
        AND maxrec(d4,size(activity_rec->activity[d2.seq].event_cds,5)))
       JOIN (d4)
       JOIN (ce
       WHERE parser(where_clause)
        AND ce.event_class_cd != rad_class_cd
        AND (ce.event_cd=activity_rec->activity[d2.seq].event_cds[d4.seq].event_cd))
     ELSE
      FROM clinical_event ce,
       (dummyt d1  WITH seq = value(size(ce_events->events,5))),
       (dummyt d2  WITH seq = value(size(activity_rec->activity,5))),
       (dummyt d3  WITH seq = value(size(request->section_list,5))),
       (dummyt d4  WITH seq = 1)
      PLAN (d1)
       JOIN (ce
       WHERE (ce.event_id=ce_events->events[d1.seq].event_id)
        AND ce.event_class_cd IN (mdoc_class_cd, doc_class_cd, grp_class_cd, proc_class_cd)
        AND parser(where_clause))
       JOIN (d2
       WHERE (activity_rec->activity[d2.seq].procedure_type_flag=0)
        AND (activity_rec->activity[d2.seq].section_type_flag=doc_sect_type))
       JOIN (d3
       WHERE (request->section_list[d3.seq].section_id=activity_rec->activity[d2.seq].
       chart_section_id)
        AND maxrec(d4,size(activity_rec->activity[d2.seq].event_cds,5)))
       JOIN (d4
       WHERE (activity_rec->activity[d2.seq].event_cds[d4.seq].event_cd=ce.event_cd))
     ENDIF
     INTO "nl:"
     HEAD REPORT
      count1 = 0
     DETAIL
      IF ((((request->result_lookup_ind=0)
       AND ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(begin_dt_tm) AND cnvtdatetime(end_dt_tm)
       AND ce.event_class_cd IN (mdoc_class_cd, doc_class_cd, proc_class_cd)
       AND ce.view_level > 0
       AND ce.publish_flag=1
       AND (request->request_type != expedite_request_type)
       AND (activity_rec->activity[d2.seq].doc_type_flag=0)) OR ((((request->result_lookup_ind=1)
       AND ce.event_end_dt_tm BETWEEN cnvtdatetime(begin_dt_tm) AND cnvtdatetime(end_dt_tm)
       AND ce.event_class_cd IN (mdoc_class_cd, doc_class_cd, proc_class_cd)
       AND ce.view_level > 0
       AND ce.publish_flag=1
       AND (request->request_type != expedite_request_type)
       AND (activity_rec->activity[d2.seq].doc_type_flag=0)) OR (((ce.event_class_cd IN (doc_class_cd
      )
       AND ce.view_level >= 0
       AND ce.publish_flag=1
       AND (request->request_type=expedite_request_type)
       AND (activity_rec->activity[d2.seq].doc_type_flag=0)) OR (((ce.event_class_cd IN (doc_class_cd
      )
       AND ce.view_level >= 0
       AND ce.publish_flag=1
       AND (request->request_type=expedite_request_type)
       AND (((activity_rec->activity[d2.seq].doc_type_flag=encntr_level_doc)
       AND ((ce.encntr_id+ 0) > 0.0)) OR ((activity_rec->activity[d2.seq].doc_type_flag=
      patient_level_doc)
       AND ((ce.encntr_id+ 0)=0.0))) ) OR ((((((activity_rec->activity[d2.seq].doc_type_flag=
      encntr_level_doc)
       AND ((ce.encntr_id+ 0) > 0.0)) OR ((activity_rec->activity[d2.seq].doc_type_flag=
      patient_level_doc)
       AND ((ce.encntr_id+ 0)=0.0)))
       AND (request->result_lookup_ind=0)
       AND ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(begin_dt_tm) AND cnvtdatetime(end_dt_tm)
       AND ce.event_class_cd IN (mdoc_class_cd, doc_class_cd, proc_class_cd)
       AND ce.view_level > 0
       AND ce.publish_flag=1) OR ((((activity_rec->activity[d2.seq].doc_type_flag=encntr_level_doc)
       AND ((ce.encntr_id+ 0) > 0.0)) OR ((activity_rec->activity[d2.seq].doc_type_flag=
      patient_level_doc)
       AND ((ce.encntr_id+ 0)=0.0)))
       AND (request->result_lookup_ind=1)
       AND ce.event_end_dt_tm BETWEEN cnvtdatetime(begin_dt_tm) AND cnvtdatetime(end_dt_tm)
       AND ce.event_class_cd IN (mdoc_class_cd, doc_class_cd, proc_class_cd)
       AND ce.view_level > 0
       AND ce.publish_flag=1)) )) )) )) )) )
       IF (ce.event_class_cd IN (mdoc_class_cd))
        y = size(mdoc_flat_rec->qual,5), y += 1, stat = alterlist(mdoc_flat_rec->qual,y),
        mdoc_flat_rec->qual[y].event_id = ce.event_id
       ELSEIF (ce.event_class_cd IN (proc_class_cd))
        y = size(ecg_flat_rec->qual,5), y += 1, stat = alterlist(ecg_flat_rec->qual,y),
        ecg_flat_rec->qual[y].event_id = ce.event_id
       ELSE
        count1 += 1
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CLINICAL_EVENT","CHECKDOCSECTION",1,0)
    IF (count1 > 0)
     SET reply->status_data.status = "S"
     GO TO exit_script
    ENDIF
    DECLARE i = i4 WITH noconstant(0), protect
    DECLARE idx = i4 WITH noconstant(0), protect
    DECLARE idxstart = i4 WITH noconstant(1), protect
    DECLARE noptimizedtotal = i4 WITH noconstant(0), protect
    DECLARE nrecordsize = i4 WITH noconstant(0), protect
    DECLARE countecg = i4 WITH noconstant(0), protect
    IF (size(ecg_flat_rec->qual,5) > 0)
     DECLARE ecg_date_clause = vc
     IF ((request->result_lookup_ind=1))
      SET ecg_date_clause =
      "(ce.event_end_dt_tm+0 between cnvtdatetime(begin_dt_tm) and cnvtdatetime(end_dt_tm))"
     ELSE
      SET ecg_date_clause =
      "(ce.clinsig_updt_dt_tm+0 between cnvtdatetime(begin_dt_tm) and cnvtdatetime(end_dt_tm))"
     ENDIF
     SET nrecordsize = size(ecg_flat_rec->qual,5)
     SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
     SET stat = alterlist(ecg_flat_rec->qual,noptimizedtotal)
     FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
       SET ecg_flat_rec->qual[i].event_id = ecg_flat_rec->qual[nrecordsize].event_id
     ENDFOR
     CALL echorecord(ecg_flat_rec)
     FREE RECORD ecg_qual_rec
     RECORD ecg_qual_rec(
       1 qual[*]
         2 event_id = f8
     )
     CALL echo(ecg_date_clause)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
       clinical_event ce,
       clinical_event ce2,
       cv_proc cv,
       ce_blob_result cbr
      PLAN (d
       WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
       JOIN (ce
       WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),ce.event_id,ecg_flat_rec->qual[idx].
        event_id,
        bind_cnt)
        AND ce.event_class_cd=proc_class_cd
        AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
        AND parser(ecg_date_clause))
       JOIN (ce2
       WHERE ce2.parent_event_id=ce.event_id
        AND ce2.event_class_cd=doc_class_cd
        AND ce2.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
       JOIN (cv
       WHERE cv.group_event_id=ce.event_id
        AND cv.proc_status_cd=procstatus_cd
        AND cv.activity_subtype_cd=ecg_cd)
       JOIN (cbr
       WHERE cbr.event_id=ce2.event_id
        AND cbr.storage_cd=dicom_siuid_cd
        AND cbr.format_cd=acrnema_cd
        AND cbr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
      HEAD REPORT
       countecg = 0
      DETAIL
       countecg += 1, stat = alterlist(ecg_qual_rec->qual,countecg), ecg_qual_rec->qual[countecg].
       event_id = ce.event_id
      WITH nocounter
     ;end select
     CALL error_and_zero_check(curqual,"CV_PROC","CHECKDOCSECTION",1,0)
     IF (curqual > 0)
      SET reply->status_data.status = "S"
      GO TO exit_script
     ENDIF
    ENDIF
    IF (size(mdoc_flat_rec->qual,5) > 0)
     SET i = 0
     SET idx = 0
     SET idxstart = 1
     SET noptimizedtotal = 0
     SET nrecordsize = 0
     SET nrecordsize = size(mdoc_flat_rec->qual,5)
     SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
     SET stat = alterlist(mdoc_flat_rec->qual,noptimizedtotal)
     FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
       SET mdoc_flat_rec->qual[i].event_id = mdoc_flat_rec->qual[nrecordsize].event_id
     ENDFOR
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
       clinical_event ce,
       ce_blob_result cbr
      PLAN (d
       WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
       JOIN (ce
       WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),ce.parent_event_id,mdoc_flat_rec->qual[
        idx].event_id,
        bind_cnt)
        AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
        AND ce.view_level >= 0
        AND ce.publish_flag=1)
       JOIN (cbr
       WHERE cbr.event_id=ce.event_id
        AND cbr.format_cd != paper_format_code
        AND cbr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
      WITH nocounter
     ;end select
     CALL error_and_zero_check(curqual,"CE_BLOB_RESULT","CHECKDOCSECTION",1,0)
     IF (curqual > 0)
      SET reply->status_data.status = "S"
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
 END ;Subroutine
#exit_script
 CALL log_message("Exiting script: cp_chk_chart_request",log_level_debug)
END GO
