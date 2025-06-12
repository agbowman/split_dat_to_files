CREATE PROGRAM aps_get_inquiry_12:dba
 RANGE OF cp IS case_provider
 RANGE OF cs1 IS case_specimen
 SET cnt = 0
 SET mrn_alias_type_cd = 0.0
 SET rpt_cnt = 0
 SELECT INTO "nl:"
  cv.code_value
  FROM code_value cv
  WHERE cv.code_set=319
   AND cv.cdf_meaning="MRN"
  HEAD REPORT
   mrn_alias_type_cd = 0.0
  DETAIL
   mrn_alias_type_cd = cv.code_value
  WITH nocounter
 ;end select
#main_select
 SELECT INTO "nl:"
  pc.case_id, pc.accession_nbr, join_path = decode(d1.seq,"S","R"),
  t.tag_group_id, t.tag_sequence
  FROM person p,
   pathology_case pc,
   prsnl pr,
   (dummyt d1  WITH seq = 1),
   case_specimen cs,
   ap_tag t,
   (dummyt d2  WITH seq = 1),
   case_report cr,
   service_directory sd
  PLAN (pc
   WHERE  $1
    AND  $2
    AND  $3
    AND pc.reserved_ind != 1)
   JOIN (pr
   WHERE pc.requesting_physician_id=pr.person_id)
   JOIN (p
   WHERE pc.person_id=p.person_id)
   JOIN (((d1
   WHERE 1=d1.seq)
   JOIN (cs
   WHERE pc.case_id=cs.case_id)
   JOIN (t
   WHERE cs.specimen_tag_id=t.tag_id)
   ) ORJOIN ((d2
   WHERE 1=d2.seq)
   JOIN (cr
   WHERE pc.case_id=cr.case_id)
   JOIN (sd
   WHERE cr.catalog_cd=sd.catalog_cd)
   ))
  ORDER BY pc.accession_nbr DESC, cr.report_sequence, sd.short_description,
   t.tag_group_id, t.tag_sequence
  HEAD REPORT
   reply->context_more_data = "F"
  HEAD pc.accession_nbr
   cnt = (cnt+ 1)
   IF ((cnt < (maxqualrows+ 1)))
    IF (mod(cnt,10)=1
     AND cnt != 1)
     stat = alter(reply->qual,(cnt+ 9))
    ENDIF
    spec_cnt = 0, rpt_cnt = 0, stat = alterlist(reply->qual[cnt].spec_qual,5),
    stat = alterlist(reply->qual[cnt].rpt_qual,5), reply->qual[cnt].case_id = pc.case_id, reply->
    qual[cnt].encntr_id = pc.encntr_id,
    reply->qual[cnt].pc_cancel_cd = pc.cancel_cd, reply->qual[cnt].pc_cancel_id = pc.cancel_id, reply
    ->qual[cnt].pc_cancel_dt_tm = pc.cancel_dt_tm,
    reply->qual[cnt].accession_nbr = pc.accession_nbr, reply->qual[cnt].blob_bitmap = pc.blob_bitmap,
    reply->qual[cnt].case_collect_dt_tm = cnvtdatetime(pc.case_collect_dt_tm),
    reply->qual[cnt].case_received_dt_tm = cnvtdatetime(pc.case_received_dt_tm), reply->qual[cnt].
    case_received_by_id = pc.accession_prsnl_id, reply->qual[cnt].prefix_cd = pc.prefix_id,
    reply->qual[cnt].case_year = pc.case_year, reply->qual[cnt].case_number = pc.case_number, reply->
    qual[cnt].case_comment_long_text_id = pc.comments_long_text_id,
    reply->qual[cnt].req_physician_name = pr.name_full_formatted, reply->qual[cnt].req_physician_id
     = pr.person_id, reply->qual[cnt].person_id = p.person_id,
    reply->qual[cnt].person_name = p.name_full_formatted, reply->qual[cnt].sex_cd = p.sex_cd, reply->
    qual[cnt].responsible_pathologist_id = pc.responsible_pathologist_id,
    reply->qual[cnt].responsible_resident_id = pc.responsible_resident_id, reply->qual[cnt].
    birth_dt_tm = cnvtdatetime(p.birth_dt_tm), reply->qual[cnt].birth_tz = validate(p.birth_tz,0)
    IF (nullind(p.deceased_dt_tm)=0)
     reply->qual[cnt].deceased_dt_tm = cnvtdatetime(p.deceased_dt_tm)
    ELSE
     reply->qual[cnt].deceased_dt_tm = 0
    ENDIF
   ENDIF
   IF ((cnt=(maxqualrows+ 1)))
    reply->context_more_data = "T", context->prefix_cnt = giveme_prefix_cnt, context->prefix_qual[1].
    prefix_cd = giveme_prefix_cd,
    context->pat_info_ind = giveme_pat_info_ind, context->single_case_ind = giveme_single_case_ind,
    context->bretrievecanceled = giveme_canceled,
    context->accession_nbr = pc.accession_nbr, context->case_year = pc.case_year, context->
    case_number = pc.case_number,
    context->context_ind = 1, context->maxqual = maxqualrows
   ENDIF
  DETAIL
   IF ((cnt < (maxqualrows+ 1)))
    CASE (join_path)
     OF "S":
      spec_cnt = (spec_cnt+ 1),
      IF (mod(spec_cnt,5)=1
       AND spec_cnt != 1)
       stat = alterlist(reply->qual[cnt].spec_qual,(spec_cnt+ 4))
      ENDIF
      ,reply->qual[cnt].spec_cnt = spec_cnt,reply->qual[cnt].spec_qual[spec_cnt].case_specimen_id =
      cs.case_specimen_id,reply->qual[cnt].spec_qual[spec_cnt].specimen_tag_group_cd = t.tag_group_id,
      reply->qual[cnt].spec_qual[spec_cnt].specimen_tag_sequence = t.tag_sequence,reply->qual[cnt].
      spec_qual[spec_cnt].specimen_tag_display = t.tag_disp,reply->qual[cnt].spec_qual[spec_cnt].
      specimen_tag_cd = cs.specimen_tag_id,
      reply->qual[cnt].spec_qual[spec_cnt].specimen_description = trim(cs.specimen_description),reply
      ->qual[cnt].spec_qual[spec_cnt].specimen_cd = cs.specimen_cd
     OF "R":
      rpt_cnt = (rpt_cnt+ 1),
      IF (mod(rpt_cnt,5)=1
       AND rpt_cnt != 1)
       stat = alterlist(reply->qual[cnt].rpt_qual,(rpt_cnt+ 4))
      ENDIF
      ,reply->qual[cnt].rpt_cnt = rpt_cnt,reply->qual[cnt].rpt_qual[rpt_cnt].report_id = cr.report_id,
      reply->qual[cnt].rpt_qual[rpt_cnt].blob_bitmap = cr.blob_bitmap,
      reply->qual[cnt].rpt_qual[rpt_cnt].report_sequence = cr.report_sequence,reply->qual[cnt].
      rpt_qual[rpt_cnt].catalog_cd = cr.catalog_cd,reply->qual[cnt].rpt_qual[rpt_cnt].
      short_description = sd.short_description,
      reply->qual[cnt].rpt_qual[rpt_cnt].long_description = sd.description,reply->qual[cnt].rpt_qual[
      rpt_cnt].event_id = cr.event_id,reply->qual[cnt].rpt_qual[rpt_cnt].status_cd = cr.status_cd
    ENDCASE
   ENDIF
  FOOT  pc.accession_nbr
   IF ((cnt < (maxqualrows+ 1)))
    stat = alterlist(reply->qual[cnt].spec_qual,spec_cnt), stat = alterlist(reply->qual[cnt].rpt_qual,
     rpt_cnt)
   ENDIF
  WITH nocounter
 ;end select
 IF (curqual=0)
  IF (bfirsttime="T")
   SET bfirsttime = "F"
   IF (max_num=0
    AND min_num=0)
    IF (original_case_year="T")
     GO TO check_curqual
    ENDIF
   ENDIF
   SET max_num = (min_num - 1)
   SET min_num = (min_num - maxqualrows)
   SET case_where_number = concat("pc.case_number between ",cnvtstring(min_num)," and ",cnvtstring(
     max_num))
   SET curqualcnt = 1
   GO TO main_select
  ELSE
   SET curqualcnt = (curqualcnt+ 1)
   IF (curqualcnt < 6)
    IF ((min_num < (maxqualrows - 1)))
     SET giveme_case_year = (giveme_case_year - 1)
     SET original_case_year = "F"
     SET case_where_year = concat("( ",cnvtstring(giveme_case_year)," = PC.CASE_YEAR )")
     SELECT INTO "nl:"
      my_max_num = max(pc.case_number), my_min_num = min(pc.case_number)
      FROM pathology_case pc
      WHERE pc.case_year=giveme_case_year
       AND (pc.prefix_id=request->prefix_qual[1].prefix_cd)
      DETAIL
       accession_max_num = my_max_num, accession_min_num = my_min_num, max_num = my_max_num,
       min_num = my_min_num
      WITH nocounter
     ;end select
     IF (max_num=0
      AND min_num=0)
      GO TO check_curqual
     ENDIF
     SET min_num = (max_num - maxqualrows)
     SET case_where_number = concat("pc.case_number between ",cnvtstring(min_num)," and ",cnvtstring(
       max_num))
     SET bfirsttime = "T"
     GO TO main_select
    ELSE
     SET min_num = (min_num - maxqualrows)
     SET max_num = (max_num - maxqualrows)
     SET case_where_number = concat("pc.case_number between ",cnvtstring(min_num)," and ",cnvtstring(
       max_num))
     GO TO main_select
    ENDIF
   ELSE
    IF ((min_num < (maxqualrows+ 1)))
     SET giveme_case_year = (giveme_case_year - 1)
     SET original_case_year = "F"
     SET case_where_year = concat("( ",cnvtstring(giveme_case_year)," = PC.CASE_YEAR )")
     SELECT INTO "nl:"
      my_max_num = max(pc.case_number), my_min_num = min(pc.case_number)
      FROM pathology_case pc
      WHERE pc.case_year=giveme_case_year
       AND (pc.prefix_id=request->prefix_qual[1].prefix_cd)
      DETAIL
       accession_max_num = my_max_num, accession_min_num = my_min_num, max_num = my_max_num,
       min_num = my_min_num
      WITH nocounter
     ;end select
     IF (max_num=0
      AND min_num=0)
      GO TO check_curqual
     ENDIF
     SET min_num = (max_num - maxqualrows)
     SET case_where_number = concat("pc.case_number between ",cnvtstring(min_num)," and ",cnvtstring(
       max_num))
     SET bfirsttime = "T"
     GO TO main_select
    ELSE
     IF (bwidenrange="F")
      SET bwidenrange = "T"
      SET min_num = (min_num - 1)
      SET case_where_number = concat("pc.case_number <= ",cnvtstring(min_num))
      GO TO main_select
     ENDIF
    ENDIF
   ENDIF
  ENDIF
 ELSE
  IF ((cnt < (maxqualrows+ 1)))
   SET min_num = (min_num - maxqualrows)
   SET max_num = (min_num+ (maxqualrows - 1))
   IF (max_num < accession_min_num
    AND original_case_year="F")
    GO TO check_curqual
   ENDIF
   SET case_where_number = concat("pc.case_number between ",cnvtstring(min_num)," and ",cnvtstring(
     max_num))
   SET bfirsttime = "T"
   GO TO main_select
  ENDIF
 ENDIF
#check_curqual
 IF (curqual=0
  AND cnt=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "PATHOLOGY_CASE"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF (cnt <= maxqualrows)
  SET stat = alter(reply->qual,cnt)
 ELSE
  SET stat = alter(reply->qual,maxqualrows)
 ENDIF
 SELECT INTO "nl:"
  ea.encntr_id, frmt_mrn = cnvtalias(ea.alias,ea.alias_pool_cd), ea.alias
  FROM (dummyt d1  WITH seq = value(size(reply->qual,5))),
   encntr_alias ea,
   encounter e
  PLAN (d1
   WHERE (reply->qual[d1.seq].encntr_id > 0))
   JOIN (e
   WHERE (reply->qual[d1.seq].encntr_id=e.encntr_id)
    AND e.active_ind=1
    AND e.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
    AND ((e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)) OR (e.end_effective_dt_tm=null)) )
   JOIN (ea
   WHERE ea.encntr_id=e.encntr_id
    AND ea.encntr_alias_type_cd=mrn_alias_type_cd
    AND ea.active_ind=1
    AND ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
  ORDER BY d1.seq
  DETAIL
   reply->qual[d1.seq].person_num = frmt_mrn
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  lt.long_text_id
  FROM (dummyt d1  WITH seq = value(size(reply->qual,5))),
   long_text lt
  PLAN (d1
   WHERE (reply->qual[d1.seq].case_comment_long_text_id > 0))
   JOIN (lt
   WHERE (reply->qual[d1.seq].case_comment_long_text_id=lt.long_text_id))
  DETAIL
   reply->qual[d1.seq].case_comment = trim(lt.long_text)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  lt.long_text_id, reply->qual[d1.seq].accession_nbr, lt.long_text
  FROM (dummyt d1  WITH seq = value(size(reply->qual,5))),
   (dummyt d2  WITH seq = value(rpt_cnt)),
   long_text lt,
   report_task rt
  PLAN (d1
   WHERE (reply->qual[d1.seq].case_id > 0))
   JOIN (d2
   WHERE (d2.seq <= reply->qual[d1.seq].rpt_cnt))
   JOIN (rt
   WHERE (reply->qual[d1.seq].rpt_qual[d2.seq].report_id=rt.report_id)
    AND rt.comments_long_text_id > 0)
   JOIN (lt
   WHERE rt.comments_long_text_id=lt.long_text_id)
  DETAIL
   reply->qual[d1.seq].rpt_qual[d2.seq].comment_long_text_id = lt.long_text_id, reply->qual[d1.seq].
   rpt_qual[d2.seq].comment = lt.long_text
  WITH nocounter
 ;end select
 IF (giveme_canceled=1)
  SELECT INTO "nl:"
   p.name_full_formatted
   FROM (dummyt d  WITH seq = value(size(reply->qual,5))),
    prsnl p
   PLAN (d
    WHERE (reply->qual[d.seq].pc_cancel_id > 0))
    JOIN (p
    WHERE (reply->qual[d.seq].pc_cancel_id=p.person_id))
   DETAIL
    reply->qual[d.seq].pc_cancel_name = p.name_full_formatted
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   p.name_full_formatted
   FROM (dummyt d  WITH seq = value(size(reply->qual,5))),
    prsnl p
   PLAN (d
    WHERE (reply->qual[d.seq].case_received_by_id > 0))
    JOIN (p
    WHERE (reply->qual[d.seq].case_received_by_id=p.person_id))
   DETAIL
    reply->qual[d.seq].case_received_by_name = p.name_full_formatted
   WITH nocounter
  ;end select
 ENDIF
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM (dummyt d  WITH seq = value(size(reply->qual,5))),
   prsnl p
  PLAN (d
   WHERE (reply->qual[d.seq].responsible_pathologist_id > 0))
   JOIN (p
   WHERE (reply->qual[d.seq].responsible_pathologist_id=p.person_id))
  DETAIL
   reply->qual[d.seq].responsible_pathologist_name = p.name_full_formatted
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  p.name_full_formatted
  FROM (dummyt d  WITH seq = value(size(reply->qual,5))),
   prsnl p
  PLAN (d
   WHERE (reply->qual[d.seq].responsible_resident_id > 0))
   JOIN (p
   WHERE (reply->qual[d.seq].responsible_resident_id=p.person_id))
  DETAIL
   reply->qual[d.seq].responsible_resident_name = p.name_full_formatted
  WITH nocounter
 ;end select
 IF ((context->context_ind=0))
  FREE SET context
 ENDIF
END GO
