CREATE PROGRAM cp_chk_chart_against_patient:dba
 RECORD reply(
   1 reply_list1[*]
     2 sect_sequence_num = i4
     2 group_sequence = i4
     2 event_set_seq = i4
     2 sect_descr = vc
     2 evnt_set_name = vc
   1 reply_list2[*]
     2 sect_sequence_num = i4
     2 group_sequence = i4
     2 event_set_seq = i4
     2 sect_descr = vc
     2 evnt_set_name = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE getceevents(null) = null
 DECLARE getprelimevents(null) = null
 DECLARE killinvalidevents(null) = null
 DECLARE getvalidevents(null) = null
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
     WHERE caf.chart_group_id=outerjoin(cg.chart_group_id))
     JOIN (cff
     WHERE cff.chart_group_id=outerjoin(cg.chart_group_id))
     JOIN (cges
     WHERE cges.chart_group_id=cg.chart_group_id)
     JOIN (cdf
     WHERE cdf.chart_group_id=outerjoin(cg.chart_group_id))
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
     WHERE cgess.chart_group_id=outerjoin(cges.chart_group_id)
      AND cgess.order_catalog_cd=outerjoin(ptr.catalog_cd)
      AND cgess.task_assay_cd=outerjoin(ptr.task_assay_cd))
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
      activitycnt = (activitycnt+ 1)
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
       codecnt = (codecnt+ 1)
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
     activitycnt = (activitycnt+ 1)
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
     codecnt = (codecnt+ 1)
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
    activitycnt = (activitycnt+ 1)
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
    codecnt = (codecnt+ 1)
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
 DECLARE where_clause = vc
 DECLARE person_clause = vc
 DECLARE date_clause = vc
 DECLARE other_clause = vc
 DECLARE ce_filter = vc WITH noconstant("")
 DECLARE ce_pending = vc WITH noconstant("")
 DECLARE mill_micro_clause = vc WITH noconstant("")
 DECLARE fsi_micro_clause = vc WITH noconstant("")
 DECLARE c1 = vc
 DECLARE c2 = vc
 DECLARE c3 = vc
 DECLARE count1 = i4
 DECLARE count2 = i4
 DECLARE auth_cd = f8
 DECLARE unauth_cd = f8
 DECLARE mod_cd = f8
 DECLARE super_cd = f8
 DECLARE inlab_cd = f8
 DECLARE inprog_cd = f8
 DECLARE trans_cd = f8
 DECLARE alt_cd = f8
 DECLARE del_stat_cd = f8
 DECLARE inerror1_cd = f8
 DECLARE inerror2_cd = f8
 DECLARE inerrornomut_cd = f8
 DECLARE inerrornoview_cd = f8
 DECLARE cancelled_cd = f8
 DECLARE rejected_cd = f8
 DECLARE mdoc_class_cd = f8
 DECLARE doc_class_cd = f8
 DECLARE proc_class_cd = f8
 DECLARE grp_class_cd = f8
 DECLARE rad_class_cd = f8
 DECLARE event_id_cnt = i4
 DECLARE event_cd_cnt = i4
 DECLARE placeholder_class_cd = f8
 DECLARE micro_class_cd = f8
 DECLARE dpowerchartcd = f8 WITH constant(uar_get_code_by("MEANING",89,"POWERCHART")), protect
 SET stat = uar_get_meaning_by_codeset(8,"AUTH",1,auth_cd)
 SET stat = uar_get_meaning_by_codeset(8,"UNAUTH",1,unauth_cd)
 SET stat = uar_get_meaning_by_codeset(8,"MODIFIED",1,mod_cd)
 SET stat = uar_get_meaning_by_codeset(8,"ALTERED",1,alt_cd)
 SET stat = uar_get_meaning_by_codeset(8,"SUPERSEDED",1,super_cd)
 SET stat = uar_get_meaning_by_codeset(8,"IN LAB",1,inlab_cd)
 SET stat = uar_get_meaning_by_codeset(8,"IN PROGRESS",1,inprog_cd)
 SET stat = uar_get_meaning_by_codeset(8,"TRANSCRIBED",1,trans_cd)
 SET stat = uar_get_meaning_by_codeset(8,"INERROR",1,inerror1_cd)
 SET stat = uar_get_meaning_by_codeset(8,"IN ERROR",1,inerror2_cd)
 SET stat = uar_get_meaning_by_codeset(8,"INERRNOMUT",1,inerrornomut_cd)
 SET stat = uar_get_meaning_by_codeset(8,"INERRNOVIEW",1,inerrornoview_cd)
 SET stat = uar_get_meaning_by_codeset(8,"CANCELLED",1,cancelled_cd)
 SET stat = uar_get_meaning_by_codeset(8,"REJECTED",1,rejected_cd)
 SET stat = uar_get_meaning_by_codeset(48,"DELETED",1,del_stat_cd)
 SET stat = uar_get_meaning_by_codeset(53,"MDOC",1,mdoc_class_cd)
 SET stat = uar_get_meaning_by_codeset(53,"DOC",1,doc_class_cd)
 SET stat = uar_get_meaning_by_codeset(53,"PROCEDURE",1,proc_class_cd)
 SET stat = uar_get_meaning_by_codeset(53,"GRP",1,grp_class_cd)
 SET stat = uar_get_meaning_by_codeset(53,"RAD",1,rad_class_cd)
 SET stat = uar_get_meaning_by_codeset(53,"PLACEHOLDER",1,placeholder_class_cd)
 SET stat = uar_get_meaning_by_codeset(53,"MBO",1,micro_class_cd)
 DECLARE flex_section_type = i4 WITH constant(6)
 DECLARE rad_section_type = i4 WITH constant(14)
 DECLARE ap_section_type = i4 WITH constant(18)
 DECLARE pwrfrm_section_type = i4 WITH constant(21)
 DECLARE hla_section_type = i4 WITH constant(22)
 DECLARE doc_section_type = i4 WITH constant(25)
 FREE RECORD ce_events
 RECORD ce_events(
   1 events[*]
     2 event_id = f8
 )
 FREE RECORD temp_events
 RECORD temp_events(
   1 events[*]
     2 event_id = f8
     2 dont_care = i2
     2 section_type_flag = i4
     2 chart_section_id = f8
 )
 IF ((request->event_ind=1)
  AND (request->request_type=2))
  SET request->scope_flag = 6
 ENDIF
 CASE (request->scope_flag)
  OF 1:
   SET c1 = build("ce.person_id = ",request->person_id)
  OF 2:
   SET c1 = build("ce.person_id = ",request->person_id)
   SET c2 = build("and ce.encntr_id+0 = ",request->encntr_id)
  OF 3:
   SET c1 = build("ce.person_id+0 = ",request->person_id)
   SET c2 = build(" and ce.encntr_id+0 = ",request->encntr_id)
   SET c3 =
   "and ce.order_id in (select order_id from chart_request_order where chart_request_id = request->request_id)"
  OF 4:
   SET c1 = build("ce.accession_nbr = ","request->accession_nbr")
   SET c2 = build("and ce.person_id+0 = ",request->person_id)
   SET c3 = build("and ce.encntr_id+0 = ",request->encntr_id)
  OF 5:
   SET c1 = build("ce.person_id = ",request->person_id)
   SET c2 =
   "and ce.encntr_id+0 in (select encntr_id from chart_request_encntr where chart_request_id = request->request_id)"
  OF 6:
   SET c1 = build("ce.person_id+0 = ",request->person_id)
   SET c2 =
   "and ce.event_id in (select event_id from chart_request_event where chart_request_id = request->request_id)"
 ENDCASE
 SET person_clause = trim(concat(c1," ",c2," ",c3))
 SET c1 = " "
 SET c2 = " "
 SET c3 = " "
 SET v_until_dt = cnvtdatetime("31-Dec-2100 00:00:00.00")
 IF ((request->date_range_ind=1))
  IF ((request->begin_dt_tm > 0))
   SET s_date = cnvtdatetime(request->begin_dt_tm)
  ELSE
   SET s_date = cnvtdatetime("01-jan-1800 00:00:00.00")
  ENDIF
  IF ((request->end_dt_tm > 0))
   SET e_date = cnvtdatetime(request->end_dt_tm)
  ELSE
   SET e_date = cnvtdatetime("31-dec-2100 23:59:59.99")
  ENDIF
  IF ((request->request_type=2))
   SET c1 = " and (ce.verified_dt_tm between cnvtdatetime(s_date) and cnvtdatetime(e_date)"
   IF ((((request->pending_flag=1)) OR ((request->pending_flag=2))) )
    SET c2 = "or ce.performed_dt_tm between cnvtdatetime(s_date) and cnvtdatetime(e_date)"
   ENDIF
   IF ((request->pending_flag=2))
    SET c3 = "or ce.event_end_dt_tm between cnvtdatetime(s_date) and cnvtdatetime(e_date))"
   ELSE
    SET c3 = ")"
   ENDIF
  ELSE
   IF ((request->result_lookup_ind=1))
    SET c1 = " and (ce.event_end_dt_tm+0"
   ELSE
    SET c1 = " and (ce.clinsig_updt_dt_tm+0"
   ENDIF
   SET c1 = concat(c1," between cnvtdatetime(s_date) and cnvtdatetime(e_date))")
  ENDIF
  SET date_clause = trim(concat(c1," ",c2," ",c3))
 ENDIF
 SET ce_filter =
 "ce.view_level >= 0 and ce.publish_flag > 0 and ce.record_status_cd != del_stat_cd and "
 SET ce_filter = concat(ce_filter," ce.event_class_cd != placeholder_class_cd")
 IF ((request->pending_flag=0))
  SET ce_pending = "ce.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd)"
 ELSEIF ((request->pending_flag=1))
  SET ce_pending = "ce.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd, inlab_cd, inprog_cd)"
 ELSE
  SET ce_pending =
  "ce.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd, inlab_cd, inprog_cd, trans_cd, unauth_cd)"
 ENDIF
 SET fsi_micro_clause = concat(ce_pending," and ce.event_class_cd = micro_class_cd",
  " and ce.contributor_system_cd != dPowerchartCd")
 SET mill_micro_clause =
 "ce.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd, inlab_cd, inprog_cd, trans_cd, unauth_cd)"
 SET mill_micro_clause = concat(mill_micro_clause," and ce.event_class_cd = micro_class_cd",
  " and ce.contributor_system_cd = dPowerchartCd")
 SET ce_pending = concat(ce_pending," and ce.event_class_cd != micro_class_cd")
 SET other_clause = concat(ce_filter," and ((",ce_pending,") OR (",fsi_micro_clause,
  ") OR (",mill_micro_clause,"))")
 SET where_clause = concat(person_clause," ",date_clause," and ",other_clause)
 CALL echo(where_clause)
 CALL getceevents(null)
 CALL getprelimevents(null)
 IF (size(temp_events->events,5) > 0)
  CALL killinvalidevents(null)
  CALL getvalidevents(null)
 ELSE
  GO TO exit_script
 ENDIF
 SUBROUTINE getceevents(null)
  CALL echo("In GetCEEvents")
  SELECT DISTINCT INTO "nl:"
   FROM clinical_event ce
   WHERE parser(where_clause)
   HEAD REPORT
    event_id_cnt = 0
   DETAIL
    event_id_cnt = (event_id_cnt+ 1)
    IF (mod(event_id_cnt,15)=1)
     stat = alterlist(ce_events->events,(event_id_cnt+ 14))
    ENDIF
    ce_events->events[event_id_cnt].event_id = ce.event_id
   FOOT REPORT
    stat = alterlist(ce_events->events,event_id_cnt)
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE getprelimevents(null)
   CALL echo("In GetPrelimEvents")
   SET event_cd_cnt = 0
   IF ((request->chart_section_ind=1))
    SELECT INTO "nl:"
     FROM chart_request_section crs,
      (dummyt d  WITH seq = value(size(activity_rec->activity,5)))
     PLAN (crs
      WHERE (crs.chart_request_id=request->request_id))
      JOIN (d
      WHERE (activity_rec->activity[d.seq].chart_section_id=crs.chart_section_id))
     DETAIL
      event_cd_cnt = (event_cd_cnt+ size(activity_rec->activity[d.seq].event_cds,5))
     WITH nocounter
    ;end select
   ELSE
    FOR (i = 1 TO size(activity_rec->activity,5))
      SET event_cd_cnt = (event_cd_cnt+ size(activity_rec->activity[i].event_cds,5))
    ENDFOR
   ENDIF
   CALL echo(build("event_id_cnt = ",event_id_cnt))
   CALL echo(build("event_cd_cnt = ",event_cd_cnt))
   SELECT
    IF ((request->scope_flag=6))
     section_type = activity_rec->activity[d2.seq].section_type_flag, flex_type = activity_rec->
     activity[d2.seq].flex_type_flag, section_id = activity_rec->activity[d2.seq].chart_section_id
     FROM clinical_event ce,
      ce_linked_result clr,
      (dummyt d1  WITH seq = value(size(ce_events->events,5))),
      (dummyt d2  WITH seq = value(size(activity_rec->activity,5))),
      (dummyt d3  WITH seq = 1)
     PLAN (d1)
      JOIN (ce
      WHERE (ce.event_id=ce_events->events[d1.seq].event_id))
      JOIN (clr
      WHERE clr.event_id=outerjoin(ce.event_id))
      JOIN (d2
      WHERE maxrec(d3,size(activity_rec->activity[d2.seq].event_cds,5)))
      JOIN (d3
      WHERE (((activity_rec->activity[d2.seq].procedure_type_flag=0)
       AND (ce.event_cd=activity_rec->activity[d2.seq].event_cds[d3.seq].event_cd)) OR ((activity_rec
      ->activity[d2.seq].procedure_type_flag=1)
       AND (ce.catalog_cd=activity_rec->activity[d2.seq].catalog_cd)
       AND (ce.event_cd=activity_rec->activity[d2.seq].event_cds[d3.seq].event_cd))) )
    ELSEIF ((request->chart_section_ind=0)
     AND event_id_cnt > event_cd_cnt)
     section_type = activity_rec->activity[d1.seq].section_type_flag, flex_type = activity_rec->
     activity[d1.seq].flex_type_flag, section_id = activity_rec->activity[d1.seq].chart_section_id
     FROM clinical_event ce,
      ce_linked_result clr,
      (dummyt d1  WITH seq = value(size(activity_rec->activity,5))),
      (dummyt d2  WITH seq = 1)
     PLAN (d1
      WHERE maxrec(d2,size(activity_rec->activity[d1.seq].event_cds,5)))
      JOIN (d2)
      JOIN (ce
      WHERE parser(where_clause)
       AND (((activity_rec->activity[d1.seq].procedure_type_flag=0)
       AND (ce.event_cd=activity_rec->activity[d1.seq].event_cds[d2.seq].event_cd)) OR ((activity_rec
      ->activity[d1.seq].procedure_type_flag=1)
       AND (ce.catalog_cd=activity_rec->activity[d1.seq].catalog_cd)
       AND (ce.event_cd=activity_rec->activity[d1.seq].event_cds[d2.seq].event_cd))) )
      JOIN (clr
      WHERE clr.event_id=outerjoin(ce.event_id))
    ELSEIF ((request->chart_section_ind=0)
     AND event_id_cnt <= event_cd_cnt)
     section_type = activity_rec->activity[d2.seq].section_type_flag, flex_type = activity_rec->
     activity[d2.seq].flex_type_flag, section_id = activity_rec->activity[d2.seq].chart_section_id
     FROM clinical_event ce,
      ce_linked_result clr,
      (dummyt d1  WITH seq = value(size(ce_events->events,5))),
      (dummyt d2  WITH seq = value(size(activity_rec->activity,5))),
      (dummyt d3  WITH seq = 1)
     PLAN (d1)
      JOIN (ce
      WHERE (ce.event_id=ce_events->events[d1.seq].event_id))
      JOIN (clr
      WHERE clr.event_id=outerjoin(ce.event_id))
      JOIN (d2
      WHERE maxrec(d3,size(activity_rec->activity[d2.seq].event_cds,5)))
      JOIN (d3
      WHERE (((activity_rec->activity[d2.seq].procedure_type_flag=0)
       AND (ce.event_cd=activity_rec->activity[d2.seq].event_cds[d3.seq].event_cd)) OR ((activity_rec
      ->activity[d2.seq].procedure_type_flag=1)
       AND (ce.catalog_cd=activity_rec->activity[d2.seq].catalog_cd)
       AND (ce.event_cd=activity_rec->activity[d2.seq].event_cds[d3.seq].event_cd))) )
    ELSEIF ((request->event_ind=0)
     AND event_id_cnt > event_cd_cnt)
     section_type = activity_rec->activity[d1.seq].section_type_flag, flex_type = activity_rec->
     activity[d1.seq].flex_type_flag, section_id = activity_rec->activity[d1.seq].chart_section_id
     FROM clinical_event ce,
      ce_linked_result clr,
      chart_request_section crs,
      (dummyt d1  WITH seq = value(size(activity_rec->activity,5))),
      (dummyt d2  WITH seq = 1)
     PLAN (crs
      WHERE (crs.chart_request_id=request->request_id))
      JOIN (d1
      WHERE (activity_rec->activity[d1.seq].chart_section_id=crs.chart_section_id)
       AND maxrec(d2,size(activity_rec->activity[d1.seq].event_cds,5)))
      JOIN (d2)
      JOIN (ce
      WHERE parser(where_clause)
       AND (((activity_rec->activity[d1.seq].procedure_type_flag=0)
       AND (ce.event_cd=activity_rec->activity[d1.seq].event_cds[d2.seq].event_cd)) OR ((activity_rec
      ->activity[d1.seq].procedure_type_flag=1)
       AND (ce.catalog_cd=activity_rec->activity[d1.seq].catalog_cd)
       AND (ce.event_cd=activity_rec->activity[d1.seq].event_cds[d2.seq].event_cd))) )
      JOIN (clr
      WHERE clr.event_id=outerjoin(ce.event_id))
    ELSEIF ((request->event_ind=0)
     AND event_id_cnt <= event_cd_cnt)
     section_type = activity_rec->activity[d2.seq].section_type_flag, flex_type = activity_rec->
     activity[d2.seq].flex_type_flag, section_id = activity_rec->activity[d2.seq].chart_section_id
     FROM clinical_event ce,
      ce_linked_result clr,
      chart_request_section crs,
      (dummyt d1  WITH seq = value(size(ce_events->events,5))),
      (dummyt d2  WITH seq = value(size(activity_rec->activity,5))),
      (dummyt d3  WITH seq = 1)
     PLAN (d1)
      JOIN (ce
      WHERE (ce.event_id=ce_events->events[d1.seq].event_id))
      JOIN (clr
      WHERE clr.event_id=outerjoin(ce.event_id))
      JOIN (crs
      WHERE (crs.chart_request_id=request->request_id))
      JOIN (d2
      WHERE (activity_rec->activity[d2.seq].chart_section_id=crs.chart_section_id)
       AND maxrec(d3,size(activity_rec->activity[d2.seq].event_cds,5)))
      JOIN (d3
      WHERE (((activity_rec->activity[d2.seq].procedure_type_flag=0)
       AND (ce.event_cd=activity_rec->activity[d2.seq].event_cds[d3.seq].event_cd)) OR ((activity_rec
      ->activity[d2.seq].procedure_type_flag=1)
       AND (ce.catalog_cd=activity_rec->activity[d2.seq].catalog_cd)
       AND (ce.event_cd=activity_rec->activity[d2.seq].event_cds[d3.seq].event_cd))) )
    ELSE
     section_type = activity_rec->activity[d1.seq].section_type_flag, flex_type = activity_rec->
     activity[d1.seq].flex_type_flag, section_id = activity_rec->activity[d1.seq].chart_section_id
     FROM clinical_event ce,
      ce_linked_result clr,
      chart_request_section crs,
      chart_request_event cre,
      (dummyt d1  WITH seq = value(size(activity_rec->activity,5))),
      (dummyt d2  WITH seq = 1),
      (dummyt d3  WITH seq = 1),
      (dummyt d4  WITH seq = 1)
     PLAN (d1
      WHERE maxrec(d2,size(activity_rec->activity[d1.seq].event_cds,5)))
      JOIN (d2)
      JOIN (ce
      WHERE parser(where_clause)
       AND (((activity_rec->activity[d1.seq].procedure_type_flag=0)
       AND (ce.event_cd=activity_rec->activity[d1.seq].event_cds[d2.seq].event_cd)) OR ((activity_rec
      ->activity[d1.seq].procedure_type_flag=1)
       AND (ce.catalog_cd=activity_rec->activity[d1.seq].catalog_cd)
       AND (ce.event_cd=activity_rec->activity[d1.seq].event_cds[d2.seq].event_cd))) )
      JOIN (clr
      WHERE clr.event_id=outerjoin(ce.event_id))
      JOIN (d3)
      JOIN (((cre
      WHERE (cre.chart_request_id=request->request_id)
       AND cre.event_id=ce.event_id)
      ) ORJOIN ((d4)
      JOIN (crs
      WHERE (crs.chart_request_id=request->request_id)
       AND (crs.chart_section_id=activity_rec->activity[d1.seq].chart_section_id))
      ))
    ENDIF
    INTO "nl:"
    ORDER BY section_id, ce.event_id, ce.valid_until_dt_tm DESC
    HEAD REPORT
     eventcnt = 0
    HEAD section_id
     first_version = 1
    DETAIL
     IF (first_version=1)
      first_version = 0
      IF (((section_type=doc_section_type
       AND ce.publish_flag=1
       AND ce.event_class_cd IN (mdoc_class_cd, doc_class_cd, grp_class_cd, proc_class_cd)) OR (((
      section_type=hla_section_type
       AND ce.view_level=1
       AND ce.publish_flag=1) OR (((section_type=pwrfrm_section_type
       AND ce.publish_flag=1) OR (((section_type=flex_section_type
       AND ce.publish_flag=1
       AND ((flex_type=0
       AND ce.view_level=0) OR (flex_type=1
       AND ce.view_level=1)) ) OR (((section_type=ap_section_type
       AND ce.view_level=0
       AND (((request->pending_flag=0)
       AND ce.publish_flag=1) OR ((request->pending_flag > 0)
       AND ce.publish_flag > 0)) ) OR ( NOT (section_type IN (doc_section_type, hla_section_type,
      pwrfrm_section_type, flex_section_type, ap_section_type))
       AND ce.view_level > 0
       AND ce.publish_flag=1)) )) )) )) )) )
       IF (((ce.event_class_cd != rad_class_cd) OR (ce.event_class_cd=rad_class_cd
        AND clr.event_id > 0.0)) )
        eventcnt = (eventcnt+ 1)
        IF (mod(eventcnt,10)=1)
         stat = alterlist(temp_events->events,(eventcnt+ 9))
        ENDIF
        temp_events->events[eventcnt].event_id = ce.event_id, temp_events->events[eventcnt].
        section_type_flag = section_type, temp_events->events[eventcnt].chart_section_id = section_id
       ENDIF
      ENDIF
     ENDIF
    FOOT  section_id
     do_nothing = 0
    FOOT REPORT
     stat = alterlist(temp_events->events,eventcnt)
    WITH nocounter
   ;end select
   SET has_hla_section = 0
   IF ( NOT ((request->scope_flag IN (1, 6))))
    FOR (i = 1 TO size(activity_rec->activity,5))
      IF ((activity_rec->activity[i].section_type_flag=hla_section_type))
       SET has_hla_section = 1
       SET i = (size(activity_rec->activity,5)+ 1)
      ENDIF
    ENDFOR
    IF (has_hla_section)
     SELECT
      IF ((request->chart_section_ind=0))
       section_id = activity_rec->activity[d1.seq].chart_section_id
       FROM clinical_event ce,
        (dummyt d1  WITH seq = value(size(activity_rec->activity,5))),
        (dummyt d2  WITH seq = 1)
       PLAN (d1
        WHERE (activity_rec->activity[d1.seq].section_type_flag=hla_section_type)
         AND (activity_rec->activity[d1.seq].procedure_type_flag=0)
         AND maxrec(d2,size(activity_rec->activity[d1.seq].event_cds,5)))
        JOIN (d2)
        JOIN (ce
        WHERE (ce.person_id=request->person_id)
         AND (ce.event_cd=activity_rec->activity[d1.seq].event_cds[d2.seq].event_cd)
         AND ce.publish_flag=1
         AND ce.view_level=1)
      ELSE
       section_id = activity_rec->activity[d1.seq].chart_section_id
       FROM clinical_event ce,
        chart_request_section crs,
        (dummyt d1  WITH seq = value(size(activity_rec->activity,5))),
        (dummyt d2  WITH seq = 1)
       PLAN (crs
        WHERE (crs.chart_request_id=request->request_id))
        JOIN (d1
        WHERE (activity_rec->activity[d1.seq].chart_section_id=crs.chart_section_id)
         AND (activity_rec->activity[d1.seq].section_type_flag=hla_section_type)
         AND (activity_rec->activity[d1.seq].procedure_type_flag=0)
         AND maxrec(d2,size(activity_rec->activity[d1.seq].event_cds,5)))
        JOIN (d2)
        JOIN (ce
        WHERE (ce.person_id=request->person_id)
         AND (ce.event_cd=activity_rec->activity[d1.seq].event_cds[d2.seq].event_cd)
         AND ce.publish_flag=1
         AND ce.view_level=1)
      ENDIF
      INTO "nl:"
      ORDER BY section_id, ce.event_id, ce.valid_until_dt_tm DESC
      HEAD REPORT
       eventcnt = size(temp_events->events,5)
      HEAD section_id
       first_version = 1
      DETAIL
       IF (first_version=1)
        first_version = 0, eventcnt = (eventcnt+ 1), stat = alterlist(temp_events->events,eventcnt),
        temp_events->events[eventcnt].event_id = ce.event_id, temp_events->events[eventcnt].
        section_type_flag = hla_section_type, temp_events->events[eventcnt].chart_section_id =
        section_id
       ENDIF
      FOOT  section_id
       do_nothing = 0
      FOOT REPORT
       do_nothing = 0
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   CALL echo(build("temp_events size = ",size(temp_events->events,5)))
   FREE RECORD ce_events
 END ;Subroutine
 SUBROUTINE killinvalidevents(null)
  CALL echo("In KillInvalidEvents")
  SELECT DISTINCT INTO "nl:"
   FROM clinical_event cce,
    clinical_event ce,
    (dummyt d  WITH seq = value(size(temp_events->events,5)))
   PLAN (d)
    JOIN (cce
    WHERE (cce.event_id=temp_events->events[d.seq].event_id)
     AND (temp_events->events[d.seq].section_type_flag=doc_section_type)
     AND cce.parent_event_id != 0)
    JOIN (ce
    WHERE ce.event_id=cce.parent_event_id
     AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100"))
   ORDER BY cce.event_id, cce.valid_until_dt_tm DESC
   HEAD cce.event_id
    IF (ce.result_status_cd IN (inerror1_cd, inerror2_cd, inerrornomut_cd, inerrornoview_cd,
    rejected_cd,
    cancelled_cd))
     temp_events->events[d.seq].dont_care = 1
    ENDIF
   WITH nocounter
  ;end select
 END ;Subroutine
 SUBROUTINE getvalidevents(null)
  CALL echo("In GetValidEvents")
  SELECT DISTINCT INTO "nl:"
   section_seq = activity_rec->activity[d2.seq].section_seq, group_seq = activity_rec->activity[d2
   .seq].group_seq, procedure_seq = activity_rec->activity[d2.seq].procedure_seq,
   procedure_name =
   IF ((activity_rec->activity[d2.seq].procedure_type_flag=0)) activity_rec->activity[d2.seq].
    event_set_name
   ELSE uar_get_code_display(activity_rec->activity[d2.seq].catalog_cd)
   ENDIF
   FROM clinical_event ce,
    chart_section cs,
    (dummyt d1  WITH seq = value(size(temp_events->events,5))),
    (dummyt d2  WITH seq = value(size(activity_rec->activity,5))),
    (dummyt d3  WITH seq = 1)
   PLAN (d1
    WHERE (temp_events->events[d1.seq].dont_care=0))
    JOIN (ce
    WHERE (ce.event_id=temp_events->events[d1.seq].event_id)
     AND ce.valid_until_dt_tm >= cnvtdatetime("31-Dec-2100")
     AND parser(other_clause))
    JOIN (d2
    WHERE (activity_rec->activity[d2.seq].chart_section_id=temp_events->events[d1.seq].
    chart_section_id)
     AND maxrec(d3,size(activity_rec->activity[d2.seq].event_cds,5)))
    JOIN (d3
    WHERE (((activity_rec->activity[d2.seq].procedure_type_flag=0)
     AND (activity_rec->activity[d2.seq].event_cds[d3.seq].event_cd=ce.event_cd)) OR ((activity_rec->
    activity[d2.seq].procedure_type_flag=1)
     AND (activity_rec->activity[d2.seq].catalog_cd=ce.catalog_cd)
     AND (activity_rec->activity[d2.seq].event_cds[d3.seq].event_cd=ce.event_cd))) )
    JOIN (cs
    WHERE (cs.chart_section_id=activity_rec->activity[d2.seq].chart_section_id))
   ORDER BY section_seq, group_seq, procedure_seq,
    procedure_name
   HEAD REPORT
    count1 = 0, count2 = 0
   HEAD section_seq
    do_nothing = 0
   HEAD group_seq
    do_nothing = 0
   HEAD procedure_seq
    do_nothing = 0
   DETAIL
    IF ((activity_rec->activity[d2.seq].procedure_type_flag=0))
     count1 = (count1+ 1)
     IF (mod(count1,10)=1)
      stat = alterlist(reply->reply_list1,(count1+ 9))
     ENDIF
     reply->reply_list1[count1].sect_sequence_num = section_seq, reply->reply_list1[count1].
     group_sequence = group_seq, reply->reply_list1[count1].event_set_seq = procedure_seq,
     reply->reply_list1[count1].sect_descr = cs.chart_section_desc, reply->reply_list1[count1].
     evnt_set_name = procedure_name
    ELSE
     count2 = (count2+ 1)
     IF (mod(count2,10)=1)
      stat = alterlist(reply->reply_list2,(count2+ 9))
     ENDIF
     reply->reply_list2[count2].sect_sequence_num = section_seq, reply->reply_list2[count2].
     group_sequence = group_seq, reply->reply_list2[count2].event_set_seq = procedure_seq,
     reply->reply_list2[count2].sect_descr = cs.chart_section_desc, reply->reply_list2[count2].
     evnt_set_name = procedure_name
    ENDIF
   FOOT  procedure_seq
    do_nothing = 0
   FOOT  group_seq
    do_nothing = 0
   FOOT  section_seq
    do_nothing = 0
   FOOT REPORT
    stat = alterlist(reply->reply_list1,count1), stat = alterlist(reply->reply_list2,count2)
   WITH nocounter
  ;end select
 END ;Subroutine
#exit_script
 IF (size(reply->reply_list1,5)=0
  AND size(reply->reply_list2,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
END GO
