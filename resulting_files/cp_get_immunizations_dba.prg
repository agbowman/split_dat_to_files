CREATE PROGRAM cp_get_immunizations:dba
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
 SET log_program_name = "CP_GET_IMMUNIZATIONS"
 RECORD reply(
   1 immunizations[*]
     2 event_cd = f8
     2 vaccine = c40
     2 date_given = dq8
     2 date_given_tz = i4
     2 result_stat_mean = c12
     2 result_stat_disp = c40
     2 provider_id = f8
     2 admin_person_id = f8
     2 manufacturer = c40
     2 lot_num = c20
     2 site = c40
     2 expiration_dt_tm = dq8
     2 admin_note = vc
     2 dosage_amount = f8
     2 dosage_unit = c40
     2 event_id = f8
     2 order_id = f8
     2 event_admin_note[2]
       3 admin_note = gc32000
     2 updt_dt_tm = dq8
     2 event_end_dt_tm = dq8
     2 event_end_tz = i4
   1 order_list[*]
     2 order_id = f8
     2 long_text = gc32000
     2 order_mnemonic = vc
     2 comment_dt_tm = dq8
     2 comment_tz = i4
   1 event_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD sort_struct(
   1 immunizations[*]
     2 event_cd = f8
     2 vaccine = c40
     2 date_given = dq8
     2 date_given_tz = i4
     2 result_stat_mean = c12
     2 result_stat_disp = c40
     2 provider_id = f8
     2 admin_person_id = f8
     2 manufacturer = c40
     2 lot_num = c20
     2 site = c40
     2 expiration_dt_tm = dq8
     2 admin_note = vc
     2 dosage_amount = f8
     2 dosage_unit = c40
     2 event_id = f8
     2 order_id = f8
     2 updt_dt_tm = dq8
     2 event_end_dt_tm = dq8
     2 event_end_tz = i4
 )
 RECORD event_set_flat(
   1 event_cds[*]
     2 event_cd = f8
 )
 DECLARE v_until_dt = q8 WITH constant(cnvtdatetime("31-DEC-2100")), protect
 DECLARE placehold_class_cd = f8 WITH constant(uar_get_code_by("MEANING",53,"PLACEHOLDER")), protect
 DECLARE ordcomm_cd = f8 WITH constant(uar_get_code_by("MEANING",14,"ORD COMMENT")), protect
 DECLARE rnadminnote_cd = f8 WITH constant(uar_get_code_by("MEANING",14,"RNADMINNOTE")), protect
 DECLARE rescomm_cd = f8 WITH constant(uar_get_code_by("MEANING",14,"RES COMMENT")), protect
 DECLARE ocfcomp_cd = f8 WITH constant(uar_get_code_by("MEANING",120,"OCFCOMP")), protect
 DECLARE rtf_cd = f8 WITH constant(uar_get_code_by("MEANING",23,"RTF")), protect
 DECLARE bind_cnt = i4 WITH constant(50)
 DECLARE orderfound = i2 WITH noconstant(0)
 DECLARE csm_request_viewer_task = i4 WITH constant(1030024), protect
 DECLARE getqualifyingimmuns(null) = null
 DECLARE sortimmunsbydate(null) = null
 DECLARE geteventimmuns(null) = null
 DECLARE getordercomments(null) = null
 DECLARE getadminnotes(null) = null
 CALL log_message("Starting script: cp_get_immunizations",log_level_debug)
 SET reply->status_data.status = "F"
 CALL geteventimmuns(null)
 CALL sortimmunsbydate(null)
 IF ((reply->event_ind > 0))
  CALL getadminnotes(null)
  IF (orderfound > 0)
   CALL getordercomments(null)
  ENDIF
 ENDIF
 SUBROUTINE geteventimmuns(null)
   CALL log_message("In GetEventImmuns()",log_level_debug)
   DECLARE dta_chart_format_id = f8 WITH constant(request->chart_format_id)
   DECLARE dta_chart_section_id = f8 WITH constant(request->chart_section_id)
   DECLARE dta_get_ap_history = i2
   DECLARE dta_check_ap_flag = i2
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
        activity_rec->activity[activitycnt].chart_group_id = cg.chart_group_id, activity_rec->
        activity[activitycnt].group_seq = cg.cg_sequence, activity_rec->activity[activitycnt].zone =
        cges.zone,
        activity_rec->activity[activitycnt].procedure_seq = cges.event_set_seq, activity_rec->
        activity[activitycnt].procedure_type_flag = cges.procedure_type_flag, activity_rec->activity[
        activitycnt].event_set_name = cges.event_set_name,
        activity_rec->activity[activitycnt].catalog_cd = cges.order_catalog_cd, activity_rec->
        activity[activitycnt].flex_type_flag = cff.flex_type, activity_rec->activity[activitycnt].
        doc_type_flag = cdf.doc_type_flag
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
       activity_rec->activity[activitycnt].chart_group_id = cg.chart_group_id, activity_rec->
       activity[activitycnt].group_seq = cg.cg_sequence, activity_rec->activity[activitycnt].zone =
       cges.zone,
       activity_rec->activity[activitycnt].procedure_seq = cges.event_set_seq, activity_rec->
       activity[activitycnt].procedure_type_flag = cges.procedure_type_flag, activity_rec->activity[
       activitycnt].event_set_name = cges.event_set_name,
       activity_rec->activity[activitycnt].catalog_cd = cges.order_catalog_cd, activity_rec->
       activity[activitycnt].flex_type_flag = 0, activity_rec->activity[activitycnt].doc_type_flag =
       cdf.doc_type_flag
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
      activitycnt].procedure_type_flag = cges.procedure_type_flag, activity_rec->activity[activitycnt
      ].event_set_name = cges.event_set_name,
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
   IF (size(activity_rec->activity,5) > 0)
    SET reply->event_ind = 1
    DECLARE act_cnt = i4 WITH constant(size(activity_rec->activity,5))
    DECLARE e_cnt = i4 WITH noconstant(0)
    DECLARE act_event_cnt = i4 WITH noconstant(0)
    DECLARE act_catalog_cnt = i4 WITH noconstant(0)
    FOR (i = 1 TO act_cnt)
     SET e_cnt = size(activity_rec->activity[i].event_cds,5)
     FOR (x = 1 TO e_cnt)
       SET act_event_cnt += 1
       SET stat = alterlist(event_set_flat->event_cds,act_event_cnt)
       SET event_set_flat->event_cds[act_event_cnt].event_cd = activity_rec->activity[i].event_cds[x]
       .event_cd
     ENDFOR
    ENDFOR
    DECLARE nrecordsize = i4 WITH noconstant(0)
    SET nrecordsize = size(event_set_flat->event_cds,5)
    IF (nrecordsize > 0)
     DECLARE idx = i4 WITH noconstant(0)
     DECLARE idxstart = i4 WITH noconstant(1)
     SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
     SET stat = alterlist(event_set_flat->event_cds,noptimizedtotal)
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
       clinical_event ce,
       ce_med_result cmr
      PLAN (d
       WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
       JOIN (ce
       WHERE (ce.person_id=request->person_id)
        AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
        AND ce.publish_flag=1
        AND ce.event_class_cd != placehold_class_cd
        AND expand(idx,idxstart,((idxstart+ bind_cnt) - 1),ce.event_cd,event_set_flat->event_cds[idx]
        .event_cd,
        bind_cnt))
       JOIN (cmr
       WHERE (cmr.event_id= Outerjoin(ce.event_id))
        AND (cmr.valid_until_dt_tm>= Outerjoin(cnvtdatetime("31-Dec-2100"))) )
      ORDER BY ce.event_id, cmr.valid_from_dt_tm DESC
      HEAD REPORT
       immuncnt = 0
      HEAD ce.event_id
       immuncnt += 1
       IF (mod(immuncnt,10)=1)
        stat = alterlist(sort_struct->immunizations,(immuncnt+ 9))
       ENDIF
       sort_struct->immunizations[immuncnt].event_id = ce.event_id, sort_struct->immunizations[
       immuncnt].order_id = ce.order_id
       IF (ce.order_id > 0)
        orderfound = 1
       ENDIF
       sort_struct->immunizations[immuncnt].event_cd = ce.event_cd, sort_struct->immunizations[
       immuncnt].vaccine = uar_get_code_display(ce.event_cd), sort_struct->immunizations[immuncnt].
       date_given = cmr.admin_start_dt_tm,
       sort_struct->immunizations[immuncnt].date_given_tz = validate(cmr.admin_start_tz,0),
       sort_struct->immunizations[immuncnt].result_stat_mean = uar_get_code_meaning(ce
        .result_status_cd), sort_struct->immunizations[immuncnt].result_stat_disp =
       uar_get_code_display(ce.result_status_cd),
       sort_struct->immunizations[immuncnt].provider_id = cmr.admin_prov_id, sort_struct->
       immunizations[immuncnt].updt_dt_tm = cmr.updt_dt_tm, sort_struct->immunizations[immuncnt].
       admin_person_id = cmr.updt_id,
       sort_struct->immunizations[immuncnt].event_end_dt_tm = ce.event_end_dt_tm, sort_struct->
       immunizations[immuncnt].event_end_tz = validate(ce.event_end_tz,0), sort_struct->
       immunizations[immuncnt].manufacturer = uar_get_code_display(cmr.substance_manufacturer_cd),
       sort_struct->immunizations[immuncnt].lot_num = cmr.substance_lot_number, sort_struct->
       immunizations[immuncnt].site = uar_get_code_display(cmr.admin_site_cd), sort_struct->
       immunizations[immuncnt].expiration_dt_tm = cmr.substance_exp_dt_tm,
       sort_struct->immunizations[immuncnt].admin_note = cmr.admin_note, sort_struct->immunizations[
       immuncnt].dosage_amount = cmr.admin_dosage, sort_struct->immunizations[immuncnt].dosage_unit
        = uar_get_code_display(cmr.dosage_unit_cd)
      FOOT  ce.event_id
       do_nothing = 0
      FOOT REPORT
       stat = alterlist(sort_struct->immunizations,immuncnt)
      WITH nocounter
     ;end select
     CALL error_and_zero_check(curqual,"CLINICAL_EVENT","GETEVENTIMMUNS",1,1)
     SET reply->status_data.status = "S"
    ENDIF
   ELSE
    CALL getqualifyingimmuns(null)
   ENDIF
 END ;Subroutine
 SUBROUTINE getqualifyingimmuns(null)
   CALL log_message("In GetQualifyingImmuns()",log_level_debug)
   SELECT DISTINCT INTO "nl:"
    vaccine_upp = cnvtupper(uar_get_code_display(ce.event_cd)), ce.event_id
    FROM clinical_event ce,
     ce_med_result cmr
    PLAN (ce
     WHERE (ce.person_id=request->person_id)
      AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
      AND ((ce.order_id+ 0)=0)
      AND ce.catalog_cd=0
      AND ce.publish_flag=1
      AND ce.event_class_cd != placehold_class_cd)
     JOIN (cmr
     WHERE cmr.event_id=ce.event_id
      AND cmr.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
    ORDER BY ce.event_id, cmr.valid_from_dt_tm DESC
    HEAD REPORT
     immuncnt = 0
    HEAD ce.event_id
     immuncnt += 1
     IF (mod(immuncnt,10)=1)
      stat = alterlist(sort_struct->immunizations,(immuncnt+ 9))
     ENDIF
     sort_struct->immunizations[immuncnt].event_id = ce.event_id, sort_struct->immunizations[immuncnt
     ].event_cd = ce.event_cd, sort_struct->immunizations[immuncnt].vaccine = uar_get_code_display(ce
      .event_cd),
     sort_struct->immunizations[immuncnt].date_given = cmr.admin_start_dt_tm, sort_struct->
     immunizations[immuncnt].date_given_tz = validate(cmr.admin_start_tz,0), sort_struct->
     immunizations[immuncnt].result_stat_mean = uar_get_code_meaning(ce.result_status_cd),
     sort_struct->immunizations[immuncnt].result_stat_disp = uar_get_code_display(ce.result_status_cd
      ), sort_struct->immunizations[immuncnt].provider_id = cmr.admin_prov_id, sort_struct->
     immunizations[immuncnt].updt_dt_tm = cmr.updt_dt_tm,
     sort_struct->immunizations[immuncnt].admin_person_id = cmr.updt_id, sort_struct->immunizations[
     immuncnt].event_end_dt_tm = ce.event_end_dt_tm, sort_struct->immunizations[immuncnt].
     event_end_tz = validate(ce.event_end_tz,0),
     sort_struct->immunizations[immuncnt].manufacturer = uar_get_code_display(cmr
      .substance_manufacturer_cd), sort_struct->immunizations[immuncnt].lot_num = cmr
     .substance_lot_number, sort_struct->immunizations[immuncnt].site = uar_get_code_display(cmr
      .admin_site_cd),
     sort_struct->immunizations[immuncnt].expiration_dt_tm = cmr.substance_exp_dt_tm, sort_struct->
     immunizations[immuncnt].admin_note = cmr.admin_note, sort_struct->immunizations[immuncnt].
     dosage_amount = cmr.admin_dosage,
     sort_struct->immunizations[immuncnt].dosage_unit = uar_get_code_display(cmr.dosage_unit_cd)
    FOOT  ce.event_id
     do_nothing = 0
    FOOT REPORT
     stat = alterlist(sort_struct->immunizations,immuncnt)
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"CE_MED_RESULT","GETQUALIFYINGIMMUNS",1,1)
   SET reply->status_data.status = "S"
 END ;Subroutine
 SUBROUTINE sortimmunsbydate(null)
   CALL log_message("In SortImmunsByDate()",log_level_debug)
   SET stat = alterlist(reply->immunizations,size(sort_struct->immunizations,5))
   SELECT
    IF ((request->sort_order_ind=1))
     ORDER BY vaccine_upper, sort_struct->immunizations[d.seq].date_given DESC
    ELSE
     ORDER BY vaccine_upper, sort_struct->immunizations[d.seq].date_given
    ENDIF
    INTO "nl:"
    vaccine_upper = cnvtupper(sort_struct->immunizations[d.seq].vaccine)
    FROM (dummyt d  WITH seq = size(sort_struct->immunizations,5))
    HEAD REPORT
     immuncnt = 0
    DETAIL
     immuncnt += 1, reply->immunizations[immuncnt].event_id = sort_struct->immunizations[d.seq].
     event_id, reply->immunizations[immuncnt].order_id = sort_struct->immunizations[d.seq].order_id,
     reply->immunizations[immuncnt].event_cd = sort_struct->immunizations[d.seq].event_cd, reply->
     immunizations[immuncnt].vaccine = sort_struct->immunizations[d.seq].vaccine, reply->
     immunizations[immuncnt].date_given = sort_struct->immunizations[d.seq].date_given,
     reply->immunizations[immuncnt].date_given_tz = sort_struct->immunizations[d.seq].date_given_tz,
     reply->immunizations[immuncnt].result_stat_mean = sort_struct->immunizations[d.seq].
     result_stat_mean, reply->immunizations[immuncnt].result_stat_disp = sort_struct->immunizations[d
     .seq].result_stat_disp,
     reply->immunizations[immuncnt].provider_id = sort_struct->immunizations[d.seq].provider_id,
     reply->immunizations[immuncnt].updt_dt_tm = sort_struct->immunizations[d.seq].updt_dt_tm, reply
     ->immunizations[immuncnt].admin_person_id = sort_struct->immunizations[d.seq].admin_person_id,
     reply->immunizations[immuncnt].event_end_dt_tm = sort_struct->immunizations[d.seq].
     event_end_dt_tm, reply->immunizations[immuncnt].event_end_tz = sort_struct->immunizations[d.seq]
     .event_end_tz, reply->immunizations[immuncnt].manufacturer = sort_struct->immunizations[d.seq].
     manufacturer,
     reply->immunizations[immuncnt].lot_num = sort_struct->immunizations[d.seq].lot_num, reply->
     immunizations[immuncnt].site = sort_struct->immunizations[d.seq].site, reply->immunizations[
     immuncnt].expiration_dt_tm = sort_struct->immunizations[d.seq].expiration_dt_tm,
     reply->immunizations[immuncnt].admin_note = sort_struct->immunizations[d.seq].admin_note, reply
     ->immunizations[immuncnt].dosage_amount = sort_struct->immunizations[d.seq].dosage_amount, reply
     ->immunizations[immuncnt].dosage_unit = sort_struct->immunizations[d.seq].dosage_unit
    WITH nocounter
   ;end select
   CALL error_and_zero_check(curqual,"DUMMYT","SORTIMMUNSBYDATE",1,0)
 END ;Subroutine
 SUBROUTINE getordercomments(null)
   CALL log_message("In GetOrderComments()",log_level_debug)
   DECLARE nrecordsize = i4
   SET nrecordsize = size(reply->immunizations,5)
   IF (nrecordsize > 0)
    DECLARE idx = i4 WITH noconstant(0), protect
    DECLARE idxstart = i4 WITH noconstant(1), protect
    SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
    SET stat = alterlist(reply->immunizations,noptimizedtotal)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      clinical_event ce,
      order_comment oc,
      long_text lt,
      orders o
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (ce
      WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),ce.event_id,reply->immunizations[idx].
       event_id,
       bind_cnt))
      JOIN (oc
      WHERE oc.order_id=ce.order_id
       AND oc.comment_type_cd=ordcomm_cd
       AND oc.order_id > 0)
      JOIN (lt
      WHERE lt.long_text_id=oc.long_text_id)
      JOIN (o
      WHERE o.order_id=oc.order_id)
     ORDER BY oc.order_id, oc.action_sequence
     HEAD REPORT
      x = 0
     FOOT  oc.order_id
      x += 1
      IF (mod(x,5)=1)
       stat = alterlist(reply->order_list,(x+ 4))
      ENDIF
      reply->order_list[x].order_id = oc.order_id, reply->order_list[x].long_text = lt.long_text,
      reply->order_list[x].order_mnemonic = o.order_mnemonic,
      reply->order_list[x].comment_dt_tm = ce.event_end_dt_tm, reply->order_list[x].comment_tz =
      validate(ce.event_end_tz,0)
     FOOT REPORT
      stat = alterlist(reply->order_list,x)
     WITH nocounter
    ;end select
    SET stat = alterlist(reply->immunizations,nrecordsize)
   ENDIF
 END ;Subroutine
 SUBROUTINE getadminnotes(null)
   CALL log_message("In GetAdminNotes()",log_level_debug)
   DECLARE nrecordsize = i4 WITH noconstant(size(reply->immunizations,5)), protect
   IF (nrecordsize > 0)
    DECLARE idx = i4 WITH noconstant(0), protect
    DECLARE idxstart = i4 WITH noconstant(1), protect
    SET noptimizedtotal = (ceil((cnvtreal(nrecordsize)/ bind_cnt)) * bind_cnt)
    SET stat = alterlist(reply->immunizations,noptimizedtotal)
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      order_comment oc,
      long_text lt
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (oc
      WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),oc.order_id,reply->immunizations[idx].
       order_id,
       bind_cnt)
       AND oc.comment_type_cd=rnadminnote_cd
       AND oc.order_id > 0)
      JOIN (lt
      WHERE lt.long_text_id=oc.long_text_id
       AND lt.active_ind=1)
     ORDER BY oc.order_id, oc.action_sequence
     HEAD REPORT
      do_nothing = 0
     DETAIL
      locval = locateval(idx,1,size(reply->immunizations,5),oc.order_id,reply->immunizations[idx].
       order_id), reply->immunizations[locval].event_admin_note[1].admin_note = trim(lt.long_text)
     WITH nocounter
    ;end select
    SET idx = 0
    SET idxstart = 1
    SET locval = 0
    SELECT INTO "nl:"
     blength = textlen(lb.long_blob)
     FROM (dummyt d  WITH seq = value((1+ ((noptimizedtotal - 1)/ bind_cnt)))),
      ce_event_note cen,
      long_blob lb
     PLAN (d
      WHERE initarray(idxstart,evaluate(d.seq,1,1,(idxstart+ bind_cnt))))
      JOIN (cen
      WHERE expand(idx,idxstart,((idxstart+ bind_cnt) - 1),cen.event_id,reply->immunizations[idx].
       event_id,
       bind_cnt)
       AND cen.note_type_cd=rescomm_cd
       AND cen.valid_until_dt_tm >= cnvtdatetime(v_until_dt)
       AND ((cen.non_chartable_flag=0) OR (cen.updt_task=csm_request_viewer_task)) )
      JOIN (lb
      WHERE lb.parent_entity_name="CE_EVENT_NOTE"
       AND lb.parent_entity_id=cen.ce_event_note_id
       AND lb.active_ind=1)
     ORDER BY cen.event_note_id, cen.note_dt_tm
     HEAD cen.event_note_id
      do_nothing = 0
     FOOT  cen.event_note_id
      locval = locateval(idx,1,size(reply->immunizations,5),cen.event_id,reply->immunizations[idx].
       event_id), blob_out = fillstring(32000," "), blob_out2 = fillstring(32000," ")
      IF (cen.compression_cd=ocfcomp_cd)
       blob_ret_len = 0,
       CALL uar_ocf_uncompress(lb.long_blob,blength,blob_out,32000,blob_ret_len), y1 = size(trim(
         blob_out))
       IF (cen.note_format_cd=rtf_cd)
        CALL uar_rtf(blob_out,blob_ret_len,blob_out2,30000,blob_ret_len,1), reply->immunizations[
        locval].event_admin_note[2].admin_note = blob_out2
       ELSE
        reply->immunizations[locval].event_admin_note[2].admin_note = blob_out
       ENDIF
      ELSE
       y1 = size(trim(lb.long_blob)), blob_out = substring(1,(y1 - 8),lb.long_blob)
       IF (cen.note_format_cd=rtf_cd)
        CALL uar_rtf(blob_out,blob_ret_len,blob_out2,30000,blob_ret_len,1), reply->immunizations[
        locval].event_admin_note[2].admin_note = blob_out2
       ELSE
        reply->immunizations[locval].event_admin_note[2].admin_note = blob_out
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    SET stat = alterlist(reply->immunizations,nrecordsize)
   ENDIF
 END ;Subroutine
#exit_script
 CALL log_message("Exiting script: cp_get_immunizations",log_level_debug)
END GO
