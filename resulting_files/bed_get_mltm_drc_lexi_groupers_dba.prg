CREATE PROGRAM bed_get_mltm_drc_lexi_groupers:dba
 FREE SET reply
 RECORD reply(
   1 groupers[*]
     2 grouper_id = f8
     2 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 FREE SET temp_grp
 RECORD temp_grp(
   1 groupers[*]
     2 grouper_id = f8
     2 display = vc
     2 drc_id = f8
     2 custom_ind = i2
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 SET tot_cnt = 0
 IF (findfile("cer_install:lexicomp_drc_extract.csv")=1)
  SELECT INTO "nl:"
   FROM mltm_drc_premise m,
    dcp_entity_reltn der,
    code_value cv,
    code_value cv2
   PLAN (m
    WHERE m.parent_premise_id=0
     AND ((m.age_low_nbr < 18) OR (((m.age_low_nbr=18
     AND m.age_operator_txt="<"
     AND m.age_unit_disp="year(s)") OR (m.age_unit_disp != "year(s)")) ))
     AND  NOT ( EXISTS (
    (SELECT
     1
     FROM cmt_import_log_msg c
     WHERE c.cmt_import_log_id=cmt_import_log_id
      AND c.log_message=m.grouper_name))))
    JOIN (der
    WHERE der.entity_reltn_mean="DRC/ROUTE"
     AND der.entity1_id=m.route_id
     AND der.active_ind=1)
    JOIN (cv
    WHERE cv.cki=outerjoin(m.dose_unit_cki)
     AND cv.code_set=outerjoin(54)
     AND cv.active_ind=outerjoin(1)
     AND cv.cki > outerjoin(" "))
    JOIN (cv2
    WHERE cv2.cki=outerjoin(m.max_dose_unit_cki)
     AND cv2.code_set=outerjoin(54)
     AND cv2.active_ind=outerjoin(1)
     AND cv2.cki > outerjoin(" "))
   ORDER BY cnvtupper(m.grouper_name)
   HEAD REPORT
    cnt = 0, tot_cnt = 0, stat = alterlist(temp_grp->groupers,100),
    match_ind = 1
   HEAD m.grouper_name
    IF (match_ind=1)
     cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
     IF (cnt > 100)
      stat = alterlist(temp_grp->groupers,(tot_cnt+ 100)), cnt = 1
     ENDIF
    ENDIF
    temp_grp->groupers[tot_cnt].grouper_id = m.grouper_id, temp_grp->groupers[tot_cnt].display = m
    .grouper_name, match_ind = 0
   DETAIL
    IF (((m.dose_range_type_id=5
     AND m.comment_txt > " ") OR (m.dose_range_type_id != 5
     AND cv.code_value > 0)) )
     IF (((m.max_dose_unit_cki > " "
      AND cv2.code_value > 0) OR (m.max_dose_unit_cki IN ("", " ", null))) )
      match_ind = 1
     ENDIF
    ENDIF
   FOOT REPORT
    IF (tot_cnt > 0
     AND match_ind=0)
     stat = alterlist(temp_grp->groupers,(tot_cnt - 1)), tot_cnt = (tot_cnt - 1)
    ELSE
     stat = alterlist(temp_grp->groupers,tot_cnt)
    ENDIF
   WITH nocounter
  ;end select
  IF (tot_cnt > 0)
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = tot_cnt),
     dose_range_check drc
    PLAN (d)
     JOIN (drc
     WHERE (drc.dose_range_check_name=temp_grp->groupers[d.seq].display))
    ORDER BY d.seq
    DETAIL
     temp_grp->groupers[d.seq].drc_id = drc.dose_range_check_id
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = tot_cnt),
     drc_premise dp
    PLAN (d
     WHERE (temp_grp->groupers[d.seq].drc_id > 0))
     JOIN (dp
     WHERE (dp.dose_range_check_id=temp_grp->groupers[d.seq].drc_id)
      AND ((dp.updt_task=4170171) OR ( EXISTS (
     (SELECT
      1
      FROM drc_dose_range ddr
      WHERE ddr.drc_premise_id=dp.parent_premise_id
       AND ddr.custom_ind=1)))) )
    ORDER BY d.seq
    HEAD d.seq
     temp_grp->groupers[d.seq].custom_ind = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = tot_cnt),
     drc_dose_range ddr
    PLAN (d
     WHERE (temp_grp->groupers[d.seq].custom_ind=0)
      AND (temp_grp->groupers[d.seq].drc_id > 0))
     JOIN (ddr
     WHERE ddr.drc_premise_id IN (
     (SELECT
      d2.drc_premise_id
      FROM drc_premise d2
      WHERE (d2.dose_range_check_id=temp_grp->groupers[d.seq].drc_id)))
      AND ddr.active_ind=1
      AND ((ddr.updt_task=4170171) OR (ddr.custom_ind=1)) )
    ORDER BY d.seq
    HEAD d.seq
     temp_grp->groupers[d.seq].custom_ind = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = tot_cnt),
     long_text l
    PLAN (d
     WHERE (temp_grp->groupers[d.seq].custom_ind=0)
      AND (temp_grp->groupers[d.seq].drc_id > 0))
     JOIN (l
     WHERE (l.long_text_id=
     (SELECT
      d1.long_text_id
      FROM drc_dose_range d1
      WHERE d1.drc_premise_id IN (
      (SELECT
       d2.drc_premise_id
       FROM drc_premise d2
       WHERE (d2.dose_range_check_id=temp_grp->groupers[d.seq].drc_id)))
       AND d1.active_ind=1))
      AND ((l.updt_task=4170171) OR ( EXISTS (
     (SELECT
      1
      FROM drc_dose_range d1
      WHERE d1.long_text_id=l.long_text_id
       AND d1.custom_ind=1)))) )
    ORDER BY d.seq
    HEAD d.seq
     temp_grp->groupers[d.seq].custom_ind = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = tot_cnt),
     drc_premise_list dpl
    PLAN (d
     WHERE (temp_grp->groupers[d.seq].custom_ind=0)
      AND (temp_grp->groupers[d.seq].drc_id > 0))
     JOIN (dpl
     WHERE dpl.drc_premise_id IN (
     (SELECT
      d2.drc_premise_id
      FROM drc_premise d2
      WHERE (d2.dose_range_check_id=temp_grp->groupers[d.seq].drc_id)))
      AND ((dpl.updt_task=4170171) OR ( EXISTS (
     (SELECT
      1
      FROM drc_dose_range ddr
      WHERE ddr.drc_premise_id IN (
      (SELECT
       dp.parent_premise_id
       FROM drc_premise dp
       WHERE dp.drc_premise_id=dpl.drc_premise_id))
       AND ddr.custom_ind=1)))) )
    ORDER BY d.seq
    HEAD d.seq
     temp_grp->groupers[d.seq].custom_ind = 1
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = tot_cnt)
    PLAN (d
     WHERE (temp_grp->groupers[d.seq].custom_ind=0)
      AND (temp_grp->groupers[d.seq].drc_id > 0))
    HEAD REPORT
     cnt = 0, tot_cnt = 0, stat = alterlist(reply->groupers,100)
    DETAIL
     cnt = (cnt+ 1), tot_cnt = (tot_cnt+ 1)
     IF (cnt > 100)
      stat = alterlist(reply->groupers,(tot_cnt+ 100)), cnt = 1
     ENDIF
     reply->groupers[tot_cnt].grouper_id = temp_grp->groupers[d.seq].grouper_id, reply->groupers[
     tot_cnt].display = temp_grp->groupers[d.seq].display
    FOOT REPORT
     stat = alterlist(reply->groupers,tot_cnt)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
