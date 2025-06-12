CREATE PROGRAM cp_get_activity2:dba
 RECORD reply(
   1 qual[*]
     2 event_id = f8
     2 event_cd = f8
     2 parent_event_id = f8
     2 mdoc_id = f8
     2 view_level = i4
     2 publish_flag = i2
     2 catalog_cd = f8
     2 chart_format_id = f8
     2 chart_section_id = f8
     2 section_type_flag = i2
     2 section_seq = i4
     2 chart_group_id = f8
     2 group_seq = i4
     2 zone = i4
     2 procedure_seq = i4
     2 procedure_type_flag = i2
     2 event_set_name = vc
     2 order_catalog_cd = f8
     2 ap_history_ind = i2
     2 encntr_id = f8
     2 order_id = f8
     2 accession_nbr = vc
     2 flex_type_flag = i2
     2 hla_type_flag = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET all_events
 RECORD all_events(
   1 qual[*]
     2 event_id = f8
     2 event_cd = f8
     2 parent_event_id = f8
     2 mdoc_id = f8
     2 catalog_cd = f8
     2 view_level = i2
     2 publish_flag = i2
     2 encntr_id = f8
     2 order_id = f8
     2 accession_nbr = vc
     2 dontcare = i2
 )
 FREE SET format_events
 RECORD format_events(
   1 qual[*]
     2 event_id = f8
     2 event_cd = f8
     2 parent_event_id = f8
     2 mdoc_id = f8
     2 catalog_cd = f8
     2 view_level = i2
     2 publish_flag = i2
     2 encntr_id = f8
     2 order_id = f8
     2 accession_nbr = vc
     2 chart_format_id = f8
     2 chart_section_id = f8
     2 section_type_flag = i2
     2 section_seq = i4
     2 chart_group_id = f8
     2 group_seq = i4
     2 zone = i4
     2 procedure_seq = i4
     2 procedure_type_flag = i2
     2 event_set_name = vc
     2 order_catalog_cd = f8
     2 ap_history_ind = i2
     2 flex_type_flag = i2
     2 hla_type_flag = i2
 )
 SET rad_event_class_cd = 0.0
 SET stat = uar_get_meaning_by_codeset(53,"RAD",1,rad_event_class_cd)
 DECLARE del_stat_cd = f8
 DECLARE replyeventscnt = i4
 DECLARE alleventscnt = i4
 DECLARE formateventscnt = i4
 DECLARE where_clause = vc
 DECLARE person_clause = vc
 DECLARE date_clause = vc
 DECLARE other_clause = vc
 DECLARE c1 = vc
 DECLARE c2 = vc
 DECLARE c3 = vc
 DECLARE c4 = vc
 DECLARE c5 = vc
 SET reply->status_data.status = "F"
 SET auth_cd = 0.0
 SET unauth_cd = 0.0
 SET mod_cd = 0.0
 SET alt_cd = 0.0
 SET super_cd = 0.0
 SET inlab_cd = 0.0
 SET inprog_cd = 0.0
 SET trans_cd = 0.0
 SET inerror1_cd = 0.0
 SET inerror2_cd = 0.0
 SET inerrornomut_cd = 0.0
 SET inerrornoview_cd = 0.0
 SET cancelled_cd = 0.0
 SET rejected_cd = 0.0
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
 CASE (request->scope_flag)
  OF 1:
   SET c1 = concat(" ce.person_id = ",cnvtstring(request->person_id))
  OF 2:
   SET c1 = concat("  ce.encntr_id = ",cnvtstring(request->encntr_id))
   SET c2 = concat("  and ce.person_id = ",cnvtstring(request->person_id))
  OF 3:
   SET c1 = concat("  ce.order_id = ",cnvtstring(request->order_id))
   SET c2 = concat("  and ce.encntr_id = ",cnvtstring(request->encntr_id))
   SET c3 = concat("  and ce.person_id = ",cnvtstring(request->person_id))
  OF 4:
   SET c1 = concat("  ce.accession_nbr = ","request->accession_nbr")
   SET c2 = concat("  and ce.encntr_id+0 = ",cnvtstring(request->encntr_id))
   SET c3 = concat("  and ce.person_id+0 = ",cnvtstring(request->person_id))
  OF 5:
   SET c1 = concat(" ce.person_id = ",cnvtstring(request->person_id))
   SET c2 =
   " and ce.encntr_id in (select encntr_id from chart_request_encntr where chart_request_id = request->request_id)"
  OF 6:
   SET c1 = concat(" ce.person_id = ",cnvtstring(request->person_id))
   SET c2 =
   " and ce.event_id in (select event_id from chart_request_event where chart_request_id = request->request_id)"
 ENDCASE
 SET person_clause = concat(trim(c1)," ",trim(c2)," ",trim(c3))
 SET c1 = " "
 SET c2 = " "
 SET c3 = " "
 SET c4 = " "
 SET c5 = " "
 SET v_until_dt = cnvtdatetime("31-Dec-2100 00:00:00.00")
 IF ((request->date_range_ind=0))
  SET c1 = " ce.valid_until_dt_tm >= cnvtdatetime(v_until_dt)"
 ELSE
  IF ((request->request_type > 1))
   SET c1 = " ce.valid_until_dt_tm >= cnvtdatetime(request->end_dt_tm)"
  ELSE
   SET c1 = " ce.valid_until_dt_tm > cnvtdatetime(request->end_dt_tm)"
   SET c5 = " and ce.valid_from_dt_tm < cnvtdatetime(request->end_dt_tm)"
  ENDIF
 ENDIF
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
  SET c2 = " and (ce.verified_dt_tm between cnvtdatetime(s_date) and cnvtdatetime(e_date)"
  IF ((((request->pending_flag=1)) OR ((request->pending_flag=2))) )
   SET c3 = " or ce.performed_dt_tm between cnvtdatetime(s_date) and cnvtdatetime(e_date)"
  ENDIF
  IF ((request->pending_flag=2))
   SET c4 = " or ce.event_end_dt_tm between cnvtdatetime(s_date) and cnvtdatetime(e_date))"
  ELSE
   SET c3 = concat(trim(c3),")")
  ENDIF
 ENDIF
 SET date_clause = concat(trim(c1)," ",trim(c5)," ",trim(c2),
  " ",trim(c3)," ",trim(c4))
 SET c1 = " and ce.view_level >= 0"
 IF ((request->pending_flag=0))
  SET c2 = " and ce.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd)"
 ELSE
  IF ((request->pending_flag=1))
   SET c2 = " and ce.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd, inlab_cd, inprog_cd)"
  ELSE
   SET c2 =
   " and ce.result_status_cd in (auth_cd, mod_cd, super_cd, alt_cd, inlab_cd, inprog_cd, trans_cd, unauth_cd)"
  ENDIF
 ENDIF
 SET c4 = " and ce.record_status_cd != del_stat_cd"
 SET other_clause = concat(trim(c1)," ",trim(c2)," ",trim(c4))
 SET where_clause = concat(trim(person_clause)," and ",trim(date_clause)," ",trim(other_clause))
 IF ((request->radiology_ind=1))
  SELECT DISTINCT INTO "nl:"
   FROM clinical_event ce,
    ce_linked_result lr,
    ce_linked_result lr2
   PLAN (ce
    WHERE parser(where_clause))
    JOIN (lr
    WHERE lr.event_id=outerjoin(ce.event_id))
    JOIN (lr2
    WHERE lr2.linked_event_id=outerjoin(lr.linked_event_id))
   HEAD REPORT
    alleventscnt = 0
   HEAD ce.event_id
    do_nothing = 0
   DETAIL
    do_nothing = 0
   FOOT  ce.event_id
    IF (((ce.event_class_cd != rad_event_class_cd) OR (ce.event_class_cd=rad_event_class_cd
     AND lr.event_id > 0.0)) )
     alleventscnt = (alleventscnt+ 1)
     IF (mod(alleventscnt,10)=1)
      stat = alterlist(all_events->qual,(alleventscnt+ 9))
     ENDIF
     all_events->qual[alleventscnt].event_id = ce.event_id, all_events->qual[alleventscnt].event_cd
      = ce.event_cd, all_events->qual[alleventscnt].parent_event_id = ce.parent_event_id,
     all_events->qual[alleventscnt].mdoc_id = lr2.linked_event_id, all_events->qual[alleventscnt].
     view_level = ce.view_level, all_events->qual[alleventscnt].publish_flag = ce.publish_flag,
     all_events->qual[alleventscnt].catalog_cd = ce.catalog_cd, all_events->qual[alleventscnt].
     encntr_id = ce.encntr_id, all_events->qual[alleventscnt].order_id = ce.order_id,
     all_events->qual[alleventscnt].accession_nbr = ce.accession_nbr
    ENDIF
   FOOT REPORT
    stat = alterlist(all_events->qual,alleventscnt)
   WITH nocounter
  ;end select
 ELSE
  SELECT DISTINCT INTO "nl:"
   FROM clinical_event ce
   PLAN (ce
    WHERE parser(where_clause))
   HEAD REPORT
    alleventscnt = 0
   HEAD ce.event_id
    do_nothing = 0
   DETAIL
    do_nothing = 0
   FOOT  ce.event_id
    alleventscnt = (alleventscnt+ 1)
    IF (mod(alleventscnt,10)=1)
     stat = alterlist(all_events->qual,(alleventscnt+ 9))
    ENDIF
    all_events->qual[alleventscnt].event_id = ce.event_id, all_events->qual[alleventscnt].event_cd =
    ce.event_cd, all_events->qual[alleventscnt].parent_event_id = ce.parent_event_id,
    all_events->qual[alleventscnt].mdoc_id = 0, all_events->qual[alleventscnt].view_level = ce
    .view_level, all_events->qual[alleventscnt].publish_flag = ce.publish_flag,
    all_events->qual[alleventscnt].catalog_cd = ce.catalog_cd, all_events->qual[alleventscnt].
    encntr_id = ce.encntr_id, all_events->qual[alleventscnt].order_id = ce.order_id,
    all_events->qual[alleventscnt].accession_nbr = ce.accession_nbr
   FOOT REPORT
    stat = alterlist(all_events->qual,alleventscnt)
   WITH nocounter
  ;end select
 ENDIF
 SELECT DISTINCT INTO "nl:"
  FROM clinical_event cce,
   clinical_event ce,
   (dummyt d  WITH seq = value(alleventscnt))
  PLAN (d)
   JOIN (cce
   WHERE (cce.event_id=all_events->qual[d.seq].event_id)
    AND cce.parent_event_id != 0)
   JOIN (ce
   WHERE ce.event_id=cce.parent_event_id
    AND parser(date_clause))
  ORDER BY cce.event_id, cce.valid_until_dt_tm DESC, ce.valid_until_dt_tm DESC
  HEAD cce.event_id
   IF (ce.result_status_cd IN (inerror1_cd, inerror2_cd, inerrornomut_cd, inerrornoview_cd,
   rejected_cd,
   cancelled_cd))
    all_events->qual[d.seq].dontcare = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (alleventscnt)
  IF ((((request->chart_section_ind=0)) OR ((request->scope_flag=6))) )
   SELECT INTO "nl:"
    FROM chart_format_codes cfc,
     chart_form_sects cfs,
     (dummyt d1  WITH seq = value(alleventscnt))
    PLAN (cfc
     WHERE (cfc.chart_format_id=request->chart_format_id))
     JOIN (cfs
     WHERE cfs.chart_section_id=cfc.chart_section_id)
     JOIN (d1
     WHERE (((cfc.event_cd=all_events->qual[d1.seq].event_cd)) OR ((cfc.order_catalog_cd=all_events->
     qual[d1.seq].catalog_cd)
      AND cfc.order_catalog_cd != 0.0))
      AND (all_events->qual[d1.seq].dontcare=0))
    ORDER BY cfc.cs_sequence_num, cfc.cg_sequence_num, cfc.event_set_seq,
     all_events->qual[d1.seq].view_level, all_events->qual[d1.seq].publish_flag, all_events->qual[d1
     .seq].encntr_id,
     all_events->qual[d1.seq].order_id, all_events->qual[d1.seq].accession_nbr
    HEAD REPORT
     replyeventscnt = 0
    DETAIL
     replyeventscnt = (replyeventscnt+ 1)
     IF (mod(replyeventscnt,10)=1)
      stat = alterlist(reply->qual,(replyeventscnt+ 9))
     ENDIF
     reply->qual[replyeventscnt].event_id = all_events->qual[d1.seq].event_id, reply->qual[
     replyeventscnt].event_cd = all_events->qual[d1.seq].event_cd, reply->qual[replyeventscnt].
     parent_event_id = all_events->qual[d1.seq].parent_event_id,
     reply->qual[replyeventscnt].mdoc_id = all_events->qual[d1.seq].mdoc_id, reply->qual[
     replyeventscnt].view_level = all_events->qual[d1.seq].view_level, reply->qual[replyeventscnt].
     publish_flag = all_events->qual[d1.seq].publish_flag,
     reply->qual[replyeventscnt].catalog_cd = all_events->qual[d1.seq].catalog_cd, reply->qual[
     replyeventscnt].encntr_id = all_events->qual[d1.seq].encntr_id, reply->qual[replyeventscnt].
     order_id = all_events->qual[d1.seq].order_id,
     reply->qual[replyeventscnt].accession_nbr = all_events->qual[d1.seq].accession_nbr, reply->qual[
     replyeventscnt].chart_format_id = cfc.chart_format_id, reply->qual[replyeventscnt].
     chart_section_id = cfc.chart_section_id,
     reply->qual[replyeventscnt].section_type_flag = cfc.section_type_flag, reply->qual[
     replyeventscnt].section_seq = cfc.cs_sequence_num, reply->qual[replyeventscnt].chart_group_id =
     cfc.chart_group_id,
     reply->qual[replyeventscnt].group_seq = cfc.cg_sequence_num, reply->qual[replyeventscnt].zone =
     cfc.zone, reply->qual[replyeventscnt].procedure_seq = cfc.event_set_seq,
     reply->qual[replyeventscnt].procedure_type_flag = cfc.procedure_type_flag, reply->qual[
     replyeventscnt].event_set_name = cfc.event_set_name, reply->qual[replyeventscnt].
     order_catalog_cd = cfc.order_catalog_cd,
     reply->qual[replyeventscnt].ap_history_ind = cfc.ap_history_flag, reply->qual[replyeventscnt].
     flex_type_flag = cfc.flex_type_flag, reply->qual[replyeventscnt].hla_type_flag = cfc
     .hla_type_flag
    FOOT REPORT
     stat = alterlist(reply->qual,replyeventscnt)
    WITH nocounter
   ;end select
  ELSE
   IF ((request->event_ind=0))
    SELECT INTO "nl:"
     FROM chart_format_codes cfc,
      chart_form_sects cfs,
      (dummyt d1  WITH seq = value(alleventscnt)),
      chart_request_section crs
     PLAN (cfc
      WHERE (cfc.chart_format_id=request->chart_format_id))
      JOIN (cfs
      WHERE cfs.chart_section_id=cfc.chart_section_id)
      JOIN (crs
      WHERE (crs.chart_request_id=request->request_id)
       AND crs.chart_section_id=cfs.chart_section_id)
      JOIN (d1
      WHERE (((cfc.event_cd=all_events->qual[d1.seq].event_cd)) OR ((cfc.order_catalog_cd=all_events
      ->qual[d1.seq].catalog_cd)
       AND cfc.order_catalog_cd != 0.0))
       AND (all_events->qual[d1.seq].dontcare=0))
     ORDER BY cfc.cs_sequence_num, cfc.cg_sequence_num, cfc.event_set_seq,
      all_events->qual[d1.seq].view_level, all_events->qual[d1.seq].publish_flag, all_events->qual[d1
      .seq].encntr_id,
      all_events->qual[d1.seq].order_id, all_events->qual[d1.seq].accession_nbr
     HEAD REPORT
      replyeventscnt = 0
     DETAIL
      replyeventscnt = (replyeventscnt+ 1)
      IF (mod(replyeventscnt,10)=1)
       stat = alterlist(reply->qual,(replyeventscnt+ 9))
      ENDIF
      reply->qual[replyeventscnt].event_id = all_events->qual[d1.seq].event_id, reply->qual[
      replyeventscnt].event_cd = all_events->qual[d1.seq].event_cd, reply->qual[replyeventscnt].
      parent_event_id = all_events->qual[d1.seq].parent_event_id,
      reply->qual[replyeventscnt].mdoc_id = all_events->qual[d1.seq].mdoc_id, reply->qual[
      replyeventscnt].view_level = all_events->qual[d1.seq].view_level, reply->qual[replyeventscnt].
      publish_flag = all_events->qual[d1.seq].publish_flag,
      reply->qual[replyeventscnt].catalog_cd = all_events->qual[d1.seq].catalog_cd, reply->qual[
      replyeventscnt].encntr_id = all_events->qual[d1.seq].encntr_id, reply->qual[replyeventscnt].
      order_id = all_events->qual[d1.seq].order_id,
      reply->qual[replyeventscnt].accession_nbr = all_events->qual[d1.seq].accession_nbr, reply->
      qual[replyeventscnt].chart_format_id = cfc.chart_format_id, reply->qual[replyeventscnt].
      chart_section_id = cfc.chart_section_id,
      reply->qual[replyeventscnt].section_type_flag = cfc.section_type_flag, reply->qual[
      replyeventscnt].section_seq = cfc.cs_sequence_num, reply->qual[replyeventscnt].chart_group_id
       = cfc.chart_group_id,
      reply->qual[replyeventscnt].group_seq = cfc.cg_sequence_num, reply->qual[replyeventscnt].zone
       = cfc.zone, reply->qual[replyeventscnt].procedure_seq = cfc.event_set_seq,
      reply->qual[replyeventscnt].procedure_type_flag = cfc.procedure_type_flag, reply->qual[
      replyeventscnt].event_set_name = cfc.event_set_name, reply->qual[replyeventscnt].
      order_catalog_cd = cfc.order_catalog_cd,
      reply->qual[replyeventscnt].ap_history_ind = cfc.ap_history_flag, reply->qual[replyeventscnt].
      flex_type_flag = cfc.flex_type_flag, reply->qual[replyeventscnt].hla_type_flag = cfc
      .hla_type_flag
     FOOT REPORT
      stat = alterlist(reply->qual,replyeventscnt)
     WITH nocounter
    ;end select
   ELSE
    SELECT INTO "nl:"
     FROM chart_format_codes cfc,
      chart_form_sects cfs,
      (dummyt d1  WITH seq = value(alleventscnt))
     PLAN (cfc
      WHERE (cfc.chart_format_id=request->chart_format_id))
      JOIN (cfs
      WHERE cfs.chart_section_id=cfc.chart_section_id)
      JOIN (d1
      WHERE (((cfc.event_cd=all_events->qual[d1.seq].event_cd)) OR ((cfc.order_catalog_cd=all_events
      ->qual[d1.seq].catalog_cd)
       AND cfc.order_catalog_cd != 0.0))
       AND (all_events->qual[d1.seq].dontcare=0))
     ORDER BY cfc.cs_sequence_num, cfc.cg_sequence_num, cfc.event_set_seq,
      all_events->qual[d1.seq].view_level, all_events->qual[d1.seq].publish_flag, all_events->qual[d1
      .seq].encntr_id,
      all_events->qual[d1.seq].order_id, all_events->qual[d1.seq].accession_nbr
     HEAD REPORT
      formateventscnt = 0
     DETAIL
      formateventscnt = (formateventscnt+ 1)
      IF (mod(formateventscnt,10)=1)
       stat = alterlist(format_events->qual,(formateventscnt+ 9))
      ENDIF
      format_events->qual[formateventscnt].event_id = all_events->qual[d1.seq].event_id,
      format_events->qual[formateventscnt].event_cd = all_events->qual[d1.seq].event_cd,
      format_events->qual[formateventscnt].parent_event_id = all_events->qual[d1.seq].parent_event_id,
      format_events->qual[formateventscnt].mdoc_id = all_events->qual[d1.seq].mdoc_id, format_events
      ->qual[formateventscnt].view_level = all_events->qual[d1.seq].view_level, format_events->qual[
      formateventscnt].publish_flag = all_events->qual[d1.seq].publish_flag,
      format_events->qual[formateventscnt].catalog_cd = all_events->qual[d1.seq].catalog_cd,
      format_events->qual[formateventscnt].encntr_id = all_events->qual[d1.seq].encntr_id,
      format_events->qual[formateventscnt].order_id = all_events->qual[d1.seq].order_id,
      format_events->qual[formateventscnt].accession_nbr = all_events->qual[d1.seq].accession_nbr,
      format_events->qual[formateventscnt].chart_format_id = cfc.chart_format_id, format_events->
      qual[formateventscnt].chart_section_id = cfc.chart_section_id,
      format_events->qual[formateventscnt].section_type_flag = cfc.section_type_flag, format_events->
      qual[formateventscnt].section_seq = cfc.cs_sequence_num, format_events->qual[formateventscnt].
      chart_group_id = cfc.chart_group_id,
      format_events->qual[formateventscnt].group_seq = cfc.cg_sequence_num, format_events->qual[
      formateventscnt].zone = cfc.zone, format_events->qual[formateventscnt].procedure_seq = cfc
      .event_set_seq,
      format_events->qual[formateventscnt].procedure_type_flag = cfc.procedure_type_flag,
      format_events->qual[formateventscnt].event_set_name = cfc.event_set_name, format_events->qual[
      formateventscnt].order_catalog_cd = cfc.order_catalog_cd,
      format_events->qual[formateventscnt].ap_history_ind = cfc.ap_history_flag, format_events->qual[
      formateventscnt].flex_type_flag = cfc.flex_type_flag, format_events->qual[formateventscnt].
      hla_type_flag = cfc.hla_type_flag
     FOOT REPORT
      stat = alterlist(format_events->qual,formateventscnt)
     WITH nocounter
    ;end select
    IF (formateventscnt > 0)
     SELECT INTO "nl:"
      FROM (dummyt d2  WITH seq = value(formateventscnt)),
       chart_request_section crs,
       chart_request_event cre,
       (dummyt dt1  WITH seq = 1),
       (dummyt dt2  WITH seq = 1)
      PLAN (d2)
       JOIN (dt1)
       JOIN (((cre
       WHERE (cre.chart_request_id=request->request_id)
        AND (cre.event_id=format_events->qual[d2.seq].event_id))
       ) ORJOIN ((dt2)
       JOIN (crs
       WHERE (crs.chart_request_id=request->request_id)
        AND (crs.chart_section_id=format_events->qual[d2.seq].chart_section_id))
       ))
      ORDER BY format_events->qual[d2.seq].section_seq, format_events->qual[d2.seq].group_seq,
       format_events->qual[d2.seq].procedure_seq,
       format_events->qual[d2.seq].view_level, format_events->qual[d2.seq].publish_flag,
       format_events->qual[d2.seq].encntr_id,
       format_events->qual[d2.seq].order_id, format_events->qual[d2.seq].accession_nbr
      HEAD REPORT
       replyeventscnt = 0
      DETAIL
       replyeventscnt = (replyeventscnt+ 1)
       IF (mod(replyeventscnt,10)=1)
        stat = alterlist(reply->qual,(replyeventscnt+ 9))
       ENDIF
       reply->qual[replyeventscnt].event_id = format_events->qual[d2.seq].event_id, reply->qual[
       replyeventscnt].event_cd = format_events->qual[d2.seq].event_cd, reply->qual[replyeventscnt].
       parent_event_id = format_events->qual[d2.seq].parent_event_id,
       reply->qual[replyeventscnt].mdoc_id = format_events->qual[d2.seq].mdoc_id, reply->qual[
       replyeventscnt].view_level = format_events->qual[d2.seq].view_level, reply->qual[
       replyeventscnt].publish_flag = format_events->qual[d2.seq].publish_flag,
       reply->qual[replyeventscnt].catalog_cd = format_events->qual[d2.seq].catalog_cd, reply->qual[
       replyeventscnt].encntr_id = format_events->qual[d2.seq].encntr_id, reply->qual[replyeventscnt]
       .order_id = format_events->qual[d2.seq].order_id,
       reply->qual[replyeventscnt].accession_nbr = format_events->qual[d2.seq].accession_nbr, reply->
       qual[replyeventscnt].chart_format_id = format_events->qual[d2.seq].chart_format_id, reply->
       qual[replyeventscnt].chart_section_id = format_events->qual[d2.seq].chart_section_id,
       reply->qual[replyeventscnt].section_type_flag = format_events->qual[d2.seq].section_type_flag,
       reply->qual[replyeventscnt].section_seq = format_events->qual[d2.seq].section_seq, reply->
       qual[replyeventscnt].chart_group_id = format_events->qual[d2.seq].chart_group_id,
       reply->qual[replyeventscnt].group_seq = format_events->qual[d2.seq].group_seq, reply->qual[
       replyeventscnt].zone = format_events->qual[d2.seq].zone, reply->qual[replyeventscnt].
       procedure_seq = format_events->qual[d2.seq].procedure_seq,
       reply->qual[replyeventscnt].procedure_type_flag = format_events->qual[d2.seq].
       procedure_type_flag, reply->qual[replyeventscnt].event_set_name = format_events->qual[d2.seq].
       event_set_name, reply->qual[replyeventscnt].order_catalog_cd = format_events->qual[d2.seq].
       order_catalog_cd,
       reply->qual[replyeventscnt].ap_history_ind = format_events->qual[d2.seq].ap_history_ind, reply
       ->qual[replyeventscnt].flex_type_flag = format_events->qual[d2.seq].flex_type_flag, reply->
       qual[replyeventscnt].hla_type_flag = format_events->qual[d2.seq].hla_type_flag
      FOOT REPORT
       stat = alterlist(reply->qual,replyeventscnt)
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
  ENDIF
 ENDIF
 IF (replyeventscnt=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
  CALL echo(build("curqual =",replyeventscnt))
 ENDIF
END GO
