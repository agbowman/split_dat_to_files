CREATE PROGRAM cp_get_activity_by_section:dba
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
 SET log_program_name = "CP_GET_ACTIVITY_BY_SECTION"
 FREE RECORD reply
 RECORD reply(
   1 activity[*]
     2 chart_section_id = f8
     2 section_seq = i4
     2 chart_group_id = f8
     2 group_seq = i4
     2 zone = i4
     2 procedure_seq = i4
     2 procedure_type_flag = i2
     2 event_set_name = vc
     2 order_catalog_cd = f8
     2 event_cd_list[*]
       3 event_cd = f8
   1 parent_event_ids[*]
     2 parent_event_id = f8
   1 inerr_events[*]
     2 event_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE dta_chart_format_id = f8 WITH constant(request->chart_format_id)
 DECLARE dta_chart_section_id = f8 WITH constant(request->chart_section_id)
 DECLARE dta_get_ap_history = i2 WITH constant(0)
 DECLARE dta_check_ap_flag = i2 WITH constant(1)
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
 RECORD prelim_events(
   1 events[*]
     2 event_id = f8
     2 dontcare = i2
 )
 FREE RECORD event_set_flat
 RECORD event_set_flat(
   1 event_cds[*]
     2 event_cd = f8
 )
 FREE RECORD catalog_cds_flat
 RECORD catalog_cds_flat(
   1 catalog_cds[*]
     2 catalog_cd = f8
     2 event_cd = f8
 )
 DECLARE flex_section_type = i4 WITH constant(6)
 DECLARE mic_section_type = i4 WITH constant(10)
 DECLARE rad_section_type = i4 WITH constant(14)
 DECLARE ap_section_type = i4 WITH constant(18)
 DECLARE pwrfrm_section_type = i4 WITH constant(21)
 DECLARE hla_section_type = i4 WITH constant(22)
 DECLARE doc_section_type = i4 WITH constant(25)
 DECLARE date_clause = vc
 DECLARE scope_clause = vc
 DECLARE other_clause = vc
 DECLARE where_clause = vc
 DECLARE error_clause = vc
 DECLARE result_clause = vc WITH noconstant("")
 DECLARE mill_micro_clause = vc WITH noconstant("")
 DECLARE encounter_level_doc = i2 WITH constant(1)
 DECLARE patient_level_doc = i2 WITH constant(2)
 DECLARE doc_type = i2 WITH noconstant(0)
 DECLARE auth_cd = f8
 DECLARE unauth_cd = f8
 DECLARE mod_cd = f8
 DECLARE alt_cd = f8
 DECLARE super_cd = f8
 DECLARE inlab_cd = f8
 DECLARE inprog_cd = f8
 DECLARE trans_cd = f8
 DECLARE inerror1_cd = f8
 DECLARE inerror2_cd = f8
 DECLARE inerrornomut_cd = f8
 DECLARE inerrornoview_cd = f8
 DECLARE cancelled_cd = f8
 DECLARE rejected_cd = f8
 DECLARE del_stat_cd = f8
 DECLARE doc_class_cd = f8
 DECLARE mdoc_class_cd = f8
 DECLARE rad_class_cd = f8
 DECLARE placehold_class_cd = f8
 DECLARE dpowerchartcd = f8 WITH constant(uar_get_code_by("MEANING",89,"POWERCHART")), protect
 DECLARE event_id_cnt = i4
 DECLARE event_cd_cnt = i4
 DECLARE req_size = i4
 DECLARE section_id = f8
 DECLARE activity_req_size = i4 WITH constant(size(activity_rec,5)), protect
 DECLARE idx = i4
 DECLARE idxstart = i4 WITH noconstant(1)
 DECLARE noptimizedtotal = i4
 DECLARE nrecordsize = i4
 DECLARE bind_cnt = i4 WITH constant(50)
 DECLARE act_cnt = i4 WITH constant(size(activity_rec->activity,5))
 DECLARE act_event_cnt = i4 WITH noconstant(0)
 DECLARE act_catalog_cnt = i4 WITH noconstant(0)
 DECLARE e_cnt = i4 WITH noconstant(0)
 DECLARE eventtotalcnt = i4 WITH noconstant(0)
 DECLARE buildscopeclause(null) = null
 DECLARE builddateclause(null) = null
 DECLARE buildotherclause(null) = null
 DECLARE buildwhereclause(null) = null
 DECLARE buildresultclause(null) = vc
 DECLARE getdocevents(null) = null
 DECLARE getotherevents(null) = null
 DECLARE getprelimevents(null) = null
 DECLARE getvalidevents(null) = null
 DECLARE getinerrevents(null) = null
 DECLARE getpredocumentevents(null) = null
 DECLARE getpreflexibleevents(null) = null
 DECLARE getpreradiologyevents(null) = null
 DECLARE getpreotherevents(null) = null
 DECLARE addeventidtoprelimrec(null) = null
 CALL log_message("Starting script: cp_get_activity_by_section",log_level_debug)
 SET reply->status_data.status = "F"
 CALL buildwhereclause(null)
 CALL echo(concat("Where Clause = ",where_clause))
 IF ((request->section_type_flag=doc_section_type))
  CALL getdocevents(null)
 ELSE
  CALL getotherevents(null)
 ENDIF
 IF (size(reply->activity,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SUBROUTINE buildwhereclause(null)
   CALL log_message("In BuildWhereClause()",log_level_debug)
   CALL builddateclause(null)
   CALL buildscopeclause(null)
   CALL buildotherclause(null)
   SET where_clause = concat(scope_clause," and ",date_clause," and ",other_clause)
 END ;Subroutine
 SUBROUTINE buildscopeclause(null)
  IF ((request->section_type_flag=doc_section_type))
   SET section_id = request->chart_section_id
   SET index = locateval(idx,idxstart,activity_req_size,section_id,activity_rec->activity[idx].
    chart_section_id)
   SET doc_type = activity_rec->activity[index].doc_type_flag
  ENDIF
  IF ((request->section_type_flag=hla_section_type))
   SET scope_clause = build("ce.person_id = ",request->person_id)
  ELSEIF ((request->section_type_flag=doc_section_type)
   AND doc_type=encounter_level_doc
   AND (request->scope_flag=1))
   SET scope_clause = build("ce.person_id = ",request->person_id," and ce.encntr_id+0 > 0.0")
  ELSEIF ((request->section_type_flag=doc_section_type)
   AND doc_type=patient_level_doc)
   SET scope_clause = build("ce.person_id = ",request->person_id," and ce.encntr_id+0 = 0.0")
  ELSE
   CASE (request->scope_flag)
    OF 1:
     SET scope_clause = build("ce.person_id = ",request->person_id)
    OF 2:
     IF ((((request->request_type=1)) OR ((request->request_type=8))) )
      SET scope_clause = build("ce.encntr_id = ",request->encntr_id," and ce.person_id = ",request->
       person_id)
     ELSE
      SET scope_clause = build("ce.encntr_id+0 = ",request->encntr_id," and ce.person_id = ",request
       ->person_id)
     ENDIF
    OF 3:
     SET scope_clause = build("ce.person_id+0 = ",request->person_id," and ce.encntr_id+0 = ",request
      ->encntr_id," and ce.order_id in ",
      " (select order_id from "," chart_request_order "," where chart_request_id = ",request->
      request_id,")")
    OF 4:
     SET scope_clause = build("ce.accession_nbr = request->accession_nbr"," and ce.encntr_id+0 = ",
      request->encntr_id," and ce.person_id+0 = ",request->person_id)
    OF 5:
     SET scope_clause = build("ce.person_id = ",request->person_id," and ce.encntr_id in ",
      " (select encntr_id from "," chart_request_encntr ",
      " where chart_request_id = ",request->request_id,")")
   ENDCASE
  ENDIF
 END ;Subroutine
 SUBROUTINE builddateclause(null)
   DECLARE s_date = vc
   DECLARE e_date = vc
   IF ((request->date_range_ind=1))
    IF ((request->begin_dt_tm > 0))
     SET s_date = "cnvtdatetime(request->begin_dt_tm)"
    ELSE
     SET s_date = "cnvtdatetime('01-Jan-1800')"
    ENDIF
    IF ((request->end_dt_tm > 0))
     SET e_date = "cnvtdatetime(request->end_dt_tm)"
    ELSE
     SET e_date = "cnvtdatetime('31-Dec-2100')"
    ENDIF
    IF ((request->request_type=2)
     AND (request->mcis_ind=0))
     SET date_clause = concat(" (ce.verified_dt_tm between ",s_date," and ",e_date)
     IF ((((request->pending_flag=1)) OR ((request->pending_flag=2))) )
      SET date_clause = concat(date_clause," or ce.performed_dt_tm between ",s_date," and ",e_date)
     ENDIF
     IF ((request->pending_flag=2))
      SET date_clause = concat(date_clause," or ce.event_end_dt_tm between ",s_date," and ",e_date)
     ENDIF
     SET date_clause = concat(date_clause,")")
    ELSE
     IF ((request->result_lookup_ind=1))
      SET date_clause = concat(" (ce.event_end_dt_tm+0 between ",s_date," and ",e_date,")")
     ELSE
      SET date_clause = concat(" (ce.clinsig_updt_dt_tm+0 between ",s_date," and ",e_date,")")
     ENDIF
    ENDIF
   ELSE
    SET date_clause = "1=1"
   ENDIF
 END ;Subroutine
 SUBROUTINE buildotherclause(null)
   SET stat = uar_get_meaning_by_codeset(8,"AUTH",1,auth_cd)
   SET stat = uar_get_meaning_by_codeset(8,"UNAUTH",1,unauth_cd)
   SET stat = uar_get_meaning_by_codeset(8,"MODIFIED",1,mod_cd)
   SET stat = uar_get_meaning_by_codeset(8,"ALTERED",1,alt_cd)
   SET stat = uar_get_meaning_by_codeset(8,"SUPERSEDED",1,super_cd)
   SET stat = uar_get_meaning_by_codeset(8,"IN LAB",1,inlab_cd)
   SET stat = uar_get_meaning_by_codeset(8,"IN PROGRESS",1,inprog_cd)
   SET stat = uar_get_meaning_by_codeset(8,"TRANSCRIBED",1,trans_cd)
   SET stat = uar_get_meaning_by_codeset(53,"DOC",1,doc_class_cd)
   SET stat = uar_get_meaning_by_codeset(53,"MDOC",1,mdoc_class_cd)
   SET stat = uar_get_meaning_by_codeset(53,"RAD",1,rad_class_cd)
   SET stat = uar_get_meaning_by_codeset(8,"INERROR",1,inerror1_cd)
   SET stat = uar_get_meaning_by_codeset(8,"IN ERROR",1,inerror2_cd)
   SET stat = uar_get_meaning_by_codeset(8,"INERRNOMUT",1,inerrornomut_cd)
   SET stat = uar_get_meaning_by_codeset(8,"INERRNOVIEW",1,inerrornoview_cd)
   SET stat = uar_get_meaning_by_codeset(8,"CANCELLED",1,cancelled_cd)
   SET stat = uar_get_meaning_by_codeset(8,"REJECTED",1,rejected_cd)
   SET stat = uar_get_meaning_by_codeset(48,"DELETED",1,del_stat_cd)
   SET stat = uar_get_meaning_by_codeset(53,"PLACEHOLD",1,placehold_class_cd)
   SET other_clause =
   "ce.event_class_cd != placehold_class_cd and ce.record_status_cd != del_stat_cd and"
   CASE (request->section_type_flag)
    OF flex_section_type:
     SET other_clause = concat(other_clause," ce.view_level in (0, 1) and ce.publish_flag = 1")
    OF doc_section_type:
     SET other_clause = concat(other_clause," ce.view_level > 0 and ce.publish_flag = 1",
      " and ce.event_class_cd in (doc_class_cd, mdoc_class_cd)")
    OF ap_section_type:
     IF ((request->pending_flag > 0))
      SET other_clause = concat(other_clause," ce.view_level = 0 and ce.publish_flag > 0")
     ELSE
      SET other_clause = concat(other_clause," ce.view_level = 0 and ce.publish_flag = 1")
     ENDIF
    OF hla_section_type:
     SET other_clause = concat(other_clause," ce.view_level = 1 and ce.publish_flag = 1")
    OF pwrfrm_section_type:
     SET other_clause = concat(other_clause," ce.view_level >= 0 and ce.publish_flag = 1")
    ELSE
     SET other_clause = concat(other_clause," ce.view_level > 0 and ce.publish_flag = 1")
   ENDCASE
   SET error_clause = concat(other_clause,
    " and ce.result_status_cd in (inerror1_cd, inerror2_cd, inerrornomut_cd, inerrornoview_cd, rejected_cd, cancelled_cd)"
    )
   SET other_clause = concat(other_clause,buildresultclause(null))
 END ;Subroutine
 SUBROUTINE buildresultclause(null)
   SET mill_micro_clause =
   "ce.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd,inlab_cd, inprog_cd, trans_cd, unauth_cd)"
   IF ((request->pending_flag=0))
    SET result_clause = "ce.result_status_cd in  (auth_cd, mod_cd, super_cd, alt_cd)"
   ELSEIF ((request->pending_flag=1))
    SET result_clause =
    "ce.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd, inlab_cd, inprog_cd)"
   ELSE
    SET result_clause =
    "ce.result_status_cd in (auth_cd,mod_cd,super_cd,alt_cd,inlab_cd,inprog_cd,trans_cd,unauth_cd)"
   ENDIF
   IF ((request->section_type_flag=mic_section_type))
    SET result_clause = concat(" and ((",result_clause,
     " and ce.contributor_system_cd != dPowerchartCd) OR (",mill_micro_clause,
     " and ce.contributor_system_cd = dPowerchartCd))")
   ELSE
    SET result_clause = concat(" and ",result_clause)
   ENDIF
   RETURN(result_clause)
 END ;Subroutine
 SUBROUTINE getdocevents(null)
   CALL log_message("In GetDocEvents()",log_level_debug)
   DECLARE eventcnt = i4
   DECLARE activitycnt = i4
   CALL getprelimevents(null)
   IF (size(prelim_events->events,5) > 0)
    SELECT DISTINCT INTO "nl:"
     FROM clinical_event cce,
      clinical_event ce,
      (dummyt d  WITH seq = value(size(prelim_events->events,5)))
     PLAN (d)
      JOIN (cce
      WHERE (cce.event_id=prelim_events->events[d.seq].event_id)
       AND cce.parent_event_id != 0)
      JOIN (ce
      WHERE ce.event_id=cce.parent_event_id
       AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
     ORDER BY cce.event_id, cce.valid_until_dt_tm DESC, ce.valid_until_dt_tm DESC
     HEAD cce.event_id
      IF (ce.result_status_cd IN (inerror1_cd, inerror2_cd, inerrornomut_cd, inerrornoview_cd,
      rejected_cd,
      cancelled_cd))
       prelim_events->events[d.seq].dontcare = 1
      ENDIF
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CLINICAL_EVENT","GETDOCEVENTS",1,0)
    CALL getvalidevents(null)
    SELECT DISTINCT INTO "nl:"
     FROM (dummyt d  WITH seq = value(size(prelim_events->events,5))),
      chart_req_inerr_event cre
     PLAN (d
      WHERE (prelim_events->events[d.seq].dontcare=1))
      JOIN (cre
      WHERE (cre.chart_request_id=request->request_id)
       AND (cre.event_id=prelim_events->events[d.seq].event_id))
     HEAD REPORT
      inerr_nbr = 0
     HEAD d.seq
      IF (cre.event_id=0)
       inerr_nbr += 1
       IF (mod(inerr_nbr,5)=1)
        stat = alterlist(reply->inerr_events,(inerr_nbr+ 4))
       ENDIF
       reply->inerr_events[inerr_nbr].event_id = prelim_events->events[d.seq].event_id
      ENDIF
     FOOT REPORT
      stat = alterlist(reply->inerr_events,inerr_nbr)
     WITH outerjoin = d, nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CHART_REQ_INERR_EVENT","GETDOCEVENTS",1,0)
   ENDIF
 END ;Subroutine
 SUBROUTINE getotherevents(null)
   CALL log_message("In GetOtherEvents()",log_level_debug)
   CALL getprelimevents(null)
   IF (size(prelim_events->events,5) > 0)
    CALL getvalidevents(null)
    IF ((request->section_type_flag IN (ap_section_type, rad_section_type)))
     CALL getinerrevents(null)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE getprelimevents(null)
   CALL log_message("In GetPrelimEvents()",log_level_debug)
   FOR (i = 1 TO act_cnt)
    SET e_cnt = size(activity_rec->activity[i].event_cds,5)
    FOR (x = 1 TO e_cnt)
      IF ((activity_rec->activity[i].procedure_type_flag=1))
       SET act_catalog_cnt += 1
       SET stat = alterlist(catalog_cds_flat->catalog_cds,act_catalog_cnt)
       SET catalog_cds_flat->catalog_cds[act_catalog_cnt].catalog_cd = activity_rec->activity[i].
       catalog_cd
       SET catalog_cds_flat->catalog_cds[act_catalog_cnt].event_cd = activity_rec->activity[i].
       event_cds[x].event_cd
      ELSE
       SET act_event_cnt += 1
       SET stat = alterlist(event_set_flat->event_cds,act_event_cnt)
       SET event_set_flat->event_cds[act_event_cnt].event_cd = activity_rec->activity[i].event_cds[x]
       .event_cd
      ENDIF
    ENDFOR
   ENDFOR
   IF (((size(event_set_flat->event_cds,5) > 0) OR (size(catalog_cds_flat->catalog_cds,5))) )
    IF ((request->section_type_flag=doc_section_type))
     CALL getpredocumentevents(null)
    ELSEIF ((request->section_type_flag=flex_section_type))
     CALL getpreflexibleevents(null)
    ELSEIF ((request->section_type_flag=rad_section_type))
     CALL getpreradiologyevents(null)
    ELSE
     CALL getpreotherevents(null)
    ENDIF
   ENDIF
 END ;Subroutine
 SUBROUTINE getvalidevents(null)
   CALL log_message("In GetValidEvents()",log_level_debug)
   SELECT DISTINCT INTO "nl:"
    group_seq = activity_rec->activity[d2.seq].group_seq, zone = activity_rec->activity[d2.seq].zone,
    procedure_seq = activity_rec->activity[d2.seq].procedure_seq,
    event_cd = activity_rec->activity[d2.seq].event_cds[d3.seq].event_cd
    FROM clinical_event ce,
     (dummyt d1  WITH seq = value(size(prelim_events->events,5))),
     (dummyt d2  WITH seq = value(size(activity_rec->activity,5))),
     (dummyt d3  WITH seq = 1)
    PLAN (d1
     WHERE (prelim_events->events[d1.seq].dontcare=0))
     JOIN (ce
     WHERE (ce.event_id=prelim_events->events[d1.seq].event_id)
      AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
      AND parser(other_clause)
      AND parser(date_clause))
     JOIN (d2
     WHERE maxrec(d3,size(activity_rec->activity[d2.seq].event_cds,5)))
     JOIN (d3
     WHERE (((activity_rec->activity[d2.seq].procedure_type_flag=0)
      AND (activity_rec->activity[d2.seq].event_cds[d3.seq].event_cd=ce.event_cd)) OR ((activity_rec
     ->activity[d2.seq].procedure_type_flag=1)
      AND (activity_rec->activity[d2.seq].catalog_cd=ce.catalog_cd)
      AND (activity_rec->activity[d2.seq].event_cds[d3.seq].event_cd=ce.event_cd))) )
    ORDER BY group_seq, zone, procedure_seq,
     event_cd
    HEAD REPORT
     activitycnt = 0, eventcdcnt = 0
    HEAD group_seq
     do_nothing = 0
    HEAD zone
     do_nothing = 0
    HEAD procedure_seq
     IF ((((request->section_type_flag=flex_section_type)
      AND (((activity_rec->activity[d2.seq].flex_type_flag=0)
      AND ce.view_level=0) OR ((activity_rec->activity[d2.seq].flex_type_flag=1)
      AND ce.view_level=1)) ) OR ((request->section_type_flag != flex_section_type))) )
      activitycnt += 1
      IF (mod(activitycnt,5)=1)
       stat = alterlist(reply->activity,(activitycnt+ 4))
      ENDIF
      reply->activity[activitycnt].chart_section_id = activity_rec->activity[d2.seq].chart_section_id,
      reply->activity[activitycnt].section_seq = activity_rec->activity[d2.seq].section_seq, reply->
      activity[activitycnt].chart_group_id = activity_rec->activity[d2.seq].chart_group_id,
      reply->activity[activitycnt].group_seq = activity_rec->activity[d2.seq].group_seq, reply->
      activity[activitycnt].zone = activity_rec->activity[d2.seq].zone, reply->activity[activitycnt].
      procedure_seq = activity_rec->activity[d2.seq].procedure_seq,
      reply->activity[activitycnt].procedure_type_flag = activity_rec->activity[d2.seq].
      procedure_type_flag, reply->activity[activitycnt].event_set_name = activity_rec->activity[d2
      .seq].event_set_name, reply->activity[activitycnt].order_catalog_cd = activity_rec->activity[d2
      .seq].catalog_cd
     ENDIF
    DETAIL
     IF ((((request->section_type_flag=flex_section_type)
      AND (((activity_rec->activity[d2.seq].flex_type_flag=0)
      AND ce.view_level=0) OR ((activity_rec->activity[d2.seq].flex_type_flag=1)
      AND ce.view_level=1)) ) OR ((request->section_type_flag != flex_section_type))) )
      eventcdcnt += 1
      IF (mod(eventcdcnt,5)=1)
       stat = alterlist(reply->activity[activitycnt].event_cd_list,(eventcdcnt+ 4))
      ENDIF
      reply->activity[activitycnt].event_cd_list[eventcdcnt].event_cd = event_cd
     ENDIF
    FOOT  procedure_seq
     stat = alterlist(reply->activity[activitycnt].event_cd_list,eventcdcnt), eventcdcnt = 0
    FOOT  zone
     do_nothing = 0
    FOOT  group_seq
     do_nothing = 0
    FOOT REPORT
     stat = alterlist(reply->activity,activitycnt)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CLINICAL_EVENT","GETVALIDEVENTS",1,1)
 END ;Subroutine
 SUBROUTINE getinerrevents(null)
   CALL log_message("In GetInErrEvents()",log_level_debug)
   SET idx = 0
   SET idxstart = 1
   SET nrecordsize = size(prelim_events->events,5)
   SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
   SET stat = alterlist(prelim_events->events,noptimizedtotal)
   FOR (i = (nrecordsize+ 1) TO noptimizedtotal)
     SET prelim_events->events[i].event_id = prelim_events->events[nrecordsize].event_id
   ENDFOR
   SELECT DISTINCT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     clinical_event ce
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (ce
     WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),ce.event_id,prelim_events->events[idx].
      event_id,
      bind_cnt)
      AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
      AND parser(error_clause)
      AND  NOT (ce.event_id IN (
     (SELECT
      event_id
      FROM chart_req_inerr_event
      WHERE (chart_request_id=request->request_id)))))
    ORDER BY ce.event_id
    HEAD REPORT
     inerr_nbr = 0
    HEAD ce.event_id
     inerr_nbr += 1
     IF (mod(inerr_nbr,5)=1)
      stat = alterlist(reply->inerr_events,(inerr_nbr+ 4))
     ENDIF
     reply->inerr_events[inerr_nbr].event_id = ce.event_id
    FOOT REPORT
     stat = alterlist(reply->inerr_events,inerr_nbr)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"ERROR_EVENTS_CLINICAL_EVENT","GETINERREVENTS",1,0)
 END ;Subroutine
 SUBROUTINE getpredocumentevents(null)
   CALL log_message("In GetPreDocumentEvents()",log_level_debug)
   SET idx = 0
   SET idxstart = 1
   DECLARE paper_format_code = f8 WITH constant(uar_get_code_by("MEANING",23,"PAPER")), protect
   DECLARE grp_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"GRP")), protect
   FREE RECORD mdoc_flat_rec
   RECORD mdoc_flat_rec(
     1 qual[*]
       2 event_id = f8
   )
   SET nrecordsize = size(event_set_flat->event_cds,5)
   CALL optimizedtotalevents(nrecordsize)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
     clinical_event ce
    PLAN (d
     WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
     JOIN (ce
     WHERE parser(where_clause)
      AND expand(idx,idxstart,act_event_cnt,ce.event_cd,event_set_flat->event_cds[idx].event_cd))
    ORDER BY ce.event_id
    HEAD REPORT
     eventcnt = 0
    HEAD ce.event_id
     IF ((((request->result_lookup_ind=0)
      AND ce.clinsig_updt_dt_tm BETWEEN cnvtdatetime(request->begin_dt_tm) AND cnvtdatetime(request->
      end_dt_tm)
      AND ce.event_class_cd IN (mdoc_class_cd, doc_class_cd)
      AND ce.view_level > 0
      AND ce.publish_flag=1) OR ((request->result_lookup_ind=1)
      AND ce.event_end_dt_tm BETWEEN cnvtdatetime(request->begin_dt_tm) AND cnvtdatetime(request->
      end_dt_tm)
      AND ce.event_class_cd IN (mdoc_class_cd, doc_class_cd)
      AND ce.view_level > 0
      AND ce.publish_flag=1)) )
      IF (ce.event_class_cd IN (mdoc_class_cd, grp_class_cd))
       y = size(mdoc_flat_rec->qual,5), y += 1, stat = alterlist(mdoc_flat_rec->qual,y),
       mdoc_flat_rec->qual[y].event_id = ce.event_id
      ELSE
       eventcnt += 1
       IF (mod(eventcnt,10)=1)
        stat = alterlist(prelim_events->events,(eventcnt+ 9))
       ENDIF
       prelim_events->events[eventcnt].event_id = ce.event_id
      ENDIF
     ENDIF
    FOOT REPORT
     stat = alterlist(prelim_events->events,eventcnt)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"DOC_EVENT_CDS_CLINICAL_EVENT","GETPREDOCUMENTEVENTS",1,0)
   SET nrecordsize = size(mdoc_flat_rec->qual,5)
   IF (nrecordsize > 0)
    SET idx = 0
    SET idxstart = 1
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
      WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),ce.parent_event_id,mdoc_flat_rec->qual[idx
       ].event_id,
       bind_cnt)
       AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
       AND ce.view_level >= 0
       AND ce.publish_flag=1)
      JOIN (cbr
      WHERE cbr.event_id=ce.event_id
       AND cbr.format_cd != paper_format_code
       AND cbr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
     HEAD REPORT
      eventcnt = size(prelim_events->events,5)
     DETAIL
      eventcnt += 1
      IF (eventcnt > size(prelim_events->events,5))
       stat = alterlist(prelim_events->events,(eventcnt+ 9))
      ENDIF
      prelim_events->events[eventcnt].event_id = ce.parent_event_id
     FOOT REPORT
      stat = alterlist(prelim_events->events,eventcnt)
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"DOC_MDOCFLAT_CLINICAL_EVENT","GETPREDOCUMENTEVENTS",1,0)
   ENDIF
 END ;Subroutine
 SUBROUTINE getpreflexibleevents(null)
   CALL log_message("In GetPreFlexibleEvents()",log_level_debug)
   DECLARE flex_flag = i2 WITH noconstant(0)
   SET idx = 0
   SET idxstart = 1
   SET flex_flag = activity_rec->activity[1].flex_type_flag
   SET nrecordsize = size(event_set_flat->event_cds,5)
   IF (nrecordsize > 0)
    CALL optimizedtotalevents(nrecordsize)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      clinical_event ce
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (ce
      WHERE parser(where_clause)
       AND expand(idx,idxstart,act_event_cnt,ce.event_cd,event_set_flat->event_cds[idx].event_cd)
       AND ((flex_flag=0
       AND ce.view_level=0) OR (flex_flag=1
       AND ce.view_level=1)) )
     ORDER BY ce.event_id
     HEAD ce.event_id
      CALL addeventidtoprelimrec(null)
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"FLEX_EVENT_CDS_CLINICAL_EVENT","GETPREFLEXIBLEEVENTS",1,0)
   ENDIF
   SET nrecordsize = size(catalog_cds_flat->catalog_cds,5)
   IF (nrecordsize > 0)
    SET idx = 0
    SET idxstart = 1
    CALL optimizedtotalcatalogs(nrecordsize)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      clinical_event ce
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (ce
      WHERE parser(where_clause)
       AND expand(idx,idxstart,act_catalog_cnt,ce.catalog_cd,catalog_cds_flat->catalog_cds[idx].
       catalog_cd,
       ce.event_cd,catalog_cds_flat->catalog_cds[idx].event_cd)
       AND ((flex_flag=0
       AND ce.view_level=0) OR (flex_flag=1
       AND ce.view_level=1)) )
     ORDER BY ce.event_id
     HEAD ce.event_id
      CALL addeventidtoprelimrec(null)
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"FLEX_CATALOG_CDS_CLINICAL_EVENT","GETPREFLEXIBLEEVENTS",1,0)
   ENDIF
   SET stat = alterlist(prelim_events->events,eventtotalcnt)
 END ;Subroutine
 SUBROUTINE getpreradiologyevents(null)
   CALL log_message("In GetPreRadiologyEvents()",log_level_debug)
   SET idx = 0
   SET idxstart = 1
   SET nrecordsize = size(event_set_flat->event_cds,5)
   IF (nrecordsize > 0)
    CALL optimizedtotalevents(nrecordsize)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      clinical_event ce,
      ce_linked_result clr
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (ce
      WHERE parser(where_clause)
       AND ce.event_class_cd=rad_class_cd
       AND expand(idx,idxstart,act_event_cnt,ce.event_cd,event_set_flat->event_cds[idx].event_cd))
      JOIN (clr
      WHERE (clr.event_id= Outerjoin(ce.event_id))
       AND clr.event_id > 0)
     ORDER BY ce.event_id
     HEAD ce.event_id
      CALL addeventidtoprelimrec(null)
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"RAD_EVENT_CDS_CLINICAL_EVENT","GETPRERADIOLOGYEVENTS",1,0)
   ENDIF
   SET nrecordsize = size(catalog_cds_flat->catalog_cds,5)
   IF (nrecordsize > 0)
    SET idx = 0
    SET idxstart = 1
    CALL optimizedtotalcatalogs(nrecordsize)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      clinical_event ce,
      ce_linked_result clr
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (ce
      WHERE parser(where_clause)
       AND ce.event_class_cd=rad_class_cd
       AND expand(idx,idxstart,act_catalog_cnt,ce.catalog_cd,catalog_cds_flat->catalog_cds[idx].
       catalog_cd,
       ce.event_cd,catalog_cds_flat->catalog_cds[idx].event_cd))
      JOIN (clr
      WHERE (clr.event_id= Outerjoin(ce.event_id))
       AND clr.event_id > 0)
     ORDER BY ce.event_id
     HEAD ce.event_id
      CALL addeventidtoprelimrec(null)
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"RAD_CATALOG_CDS_CLINICAL_EVENT","GETPRERADIOLOGYEVENTS",1,0)
   ENDIF
   SET stat = alterlist(prelim_events->events,eventtotalcnt)
 END ;Subroutine
 SUBROUTINE getpreotherevents(null)
   CALL log_message("In GetPreOtherEvents()",log_level_debug)
   SET idx = 0
   SET idxstart = 1
   SET nrecordsize = size(event_set_flat->event_cds,5)
   IF (nrecordsize > 0)
    CALL optimizedtotalevents(nrecordsize)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      clinical_event ce
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (ce
      WHERE parser(where_clause)
       AND expand(idx,idxstart,act_event_cnt,ce.event_cd,event_set_flat->event_cds[idx].event_cd))
     ORDER BY ce.event_id
     HEAD ce.event_id
      CALL addeventidtoprelimrec(null)
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"EVENT_CDS_CLINICAL_EVENT","GETPREOTHEREVENTS",1,0)
   ENDIF
   SET nrecordsize = size(catalog_cds_flat->catalog_cds,5)
   IF (nrecordsize > 0)
    SET idx = 0
    SET idxstart = 1
    CALL optimizedtotalcatalogs(nrecordsize)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      clinical_event ce
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (ce
      WHERE parser(where_clause)
       AND expand(idx,idxstart,act_catalog_cnt,ce.catalog_cd,catalog_cds_flat->catalog_cds[idx].
       catalog_cd,
       ce.event_cd,catalog_cds_flat->catalog_cds[idx].event_cd))
     ORDER BY ce.event_id
     HEAD ce.event_id
      CALL addeventidtoprelimrec(null)
     WITH nocounter
    ;end select
    CALL error_and_zero_check(curqual,"CATALOG_CDS_CLINICAL_EVENT","GETPREOTHEREVENTS",1,0)
   ENDIF
   SET stat = alterlist(prelim_events->events,eventtotalcnt)
 END ;Subroutine
 SUBROUTINE addeventidtoprelimrec(null)
   SET eventtotalcnt += 1
   IF (mod(eventtotalcnt,10)=1)
    SET stat = alterlist(prelim_events->events,(eventtotalcnt+ 9))
   ENDIF
   SET prelim_events->events[eventtotalcnt].event_id = ce.event_id
 END ;Subroutine
 SUBROUTINE (optimizedtotalevents(irecsize=i4) =null)
   SET noptimizedtotal = (ceil((cnvtreal(irecsize)/ bind_cnt)) * bind_cnt)
   SET stat = alterlist(event_set_flat->event_cds,noptimizedtotal)
   FOR (i = (irecsize+ 1) TO noptimizedtotal)
     SET event_set_flat->event_cds[i].event_cd = event_set_flat->event_cds[irecsize].event_cd
   ENDFOR
 END ;Subroutine
 SUBROUTINE (optimizedtotalcatalogs(irecsize=i4) =null)
   SET noptimizedtotal = (ceil((cnvtreal(irecsize)/ bind_cnt)) * bind_cnt)
   SET stat = alterlist(catalog_cds_flat->catalog_cds,noptimizedtotal)
   FOR (i = (irecsize+ 1) TO noptimizedtotal)
    SET catalog_cds_flat->catalog_cds[i].event_cd = catalog_cds_flat->catalog_cds[irecsize].event_cd
    SET catalog_cds_flat->catalog_cds[i].catalog_cd = catalog_cds_flat->catalog_cds[irecsize].
    catalog_cd
   ENDFOR
 END ;Subroutine
#exit_script
 CALL log_message("Exiting script: cp_get_activity_by_section",log_level_debug)
 CALL echorecord(reply)
END GO
