CREATE PROGRAM bed_aud_pwr_rel_results:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 powerplans_and_phases[*]
      2 id = f8
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 collist[*]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist[*]
      2 celllist[*]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist[*]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c15
        3 operationstatus = c1
        3 targetobjectname = c15
        3 targetobjectvalue = c100
  )
 ENDIF
 SET reply->status_data.status = "F"
 RECORD reqtemp(
   1 powerplans_and_phases[*]
     2 id = f8
 )
 RECORD temp(
   1 powerplans[*]
     2 description = vc
     2 related_results_ind = i2
     2 phase_has_related_results_ind = i2
     2 event_sets[*]
       3 display = vc
       3 description = vc
       3 sequence = i4
     2 phases[*]
       3 id = f8
       3 description = vc
       3 sequence = i4
       3 related_results_ind = i2
       3 event_sets[*]
         4 display = vc
         4 description = vc
         4 sequence = i4
 )
 SET req_dummy_seq = 1
 DECLARE pc1_parse = vc
 SET pc1_parse = "pc1.active_ind = 1"
 SET req_id_cnt = 0
 IF (validate(request->powerplans_and_phases[1].id))
  SET req_id_cnt = size(request->powerplans_and_phases,5)
 ENDIF
 IF (req_id_cnt > 0)
  SET stat = alterlist(reqtemp->powerplans_and_phases,req_id_cnt)
  FOR (p = 1 TO req_id_cnt)
    SET reqtemp->powerplans_and_phases[p].id = request->powerplans_and_phases[p].id
  ENDFOR
  SET req_dummy_seq = req_id_cnt
  SET pc1_parse = build2(pc1_parse,
   " and pc1.pathway_catalog_id = reqtemp->powerplans_and_phases[d.seq].id")
 ENDIF
 SET total_related_results = 0
 SET cnt = 0
 SET plancnt = 0
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(req_dummy_seq)),
   pathway_catalog pc1,
   pw_evidence_reltn per1,
   v500_event_set_code v1,
   pw_cat_reltn pcr,
   pathway_catalog pc2,
   pw_evidence_reltn per2,
   v500_event_set_code v2
  PLAN (d)
   JOIN (pc1
   WHERE parser(pc1_parse)
    AND pc1.type_mean IN ("CAREPLAN", "PATHWAY")
    AND pc1.ref_owner_person_id=0
    AND pc1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pc1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (per1
   WHERE per1.pathway_catalog_id=outerjoin(pc1.pathway_catalog_id)
    AND per1.type_mean=outerjoin("EVENTSET"))
   JOIN (v1
   WHERE v1.event_set_name=outerjoin(per1.evidence_locator))
   JOIN (pcr
   WHERE pcr.pw_cat_s_id=outerjoin(pc1.pathway_catalog_id)
    AND pcr.type_mean=outerjoin("GROUP"))
   JOIN (pc2
   WHERE pc2.pathway_catalog_id=outerjoin(pcr.pw_cat_t_id))
   JOIN (per2
   WHERE per2.pathway_catalog_id=outerjoin(pc2.pathway_catalog_id)
    AND per2.type_mean=outerjoin("EVENTSET"))
   JOIN (v2
   WHERE v2.event_set_name=outerjoin(per2.evidence_locator))
  ORDER BY cnvtupper(pc1.display_description), cnvtupper(pc2.description), per1.evidence_sequence,
   per2.evidence_sequence, pc1.pathway_catalog_id, per1.pw_evidence_reltn_id,
   pc2.pathway_catalog_id, per2.pw_evidence_reltn_id
  HEAD REPORT
   cnt = 10, plancnt = 0, stat = alterlist(temp->powerplans,cnt)
  HEAD pc1.pathway_catalog_id
   cnt = (cnt+ 1), plancnt = (plancnt+ 1)
   IF (cnt > 10)
    cnt = 1, stat = alterlist(temp->powerplans,(plancnt+ 10))
   ENDIF
   temp->powerplans[plancnt].description = pc1.display_description, phasecnt = 0, planeventcnt = 0
  HEAD per1.pw_evidence_reltn_id
   IF (pc1.type_mean="CAREPLAN"
    AND per1.pw_evidence_reltn_id > 0)
    temp->powerplans[plancnt].related_results_ind = 1, total_related_results = (total_related_results
    + 1), planeventcnt = (planeventcnt+ 1),
    stat = alterlist(temp->powerplans[plancnt].event_sets,planeventcnt), temp->powerplans[plancnt].
    event_sets[planeventcnt].sequence = per1.evidence_sequence, temp->powerplans[plancnt].event_sets[
    planeventcnt].display = v1.event_set_cd_disp,
    temp->powerplans[plancnt].event_sets[planeventcnt].description = v1.event_set_cd_descr
   ENDIF
  HEAD pc2.pathway_catalog_id
   IF (pc1.type_mean="PATHWAY"
    AND pcr.pw_cat_t_id > 0)
    phasecnt = (phasecnt+ 1), stat = alterlist(temp->powerplans[plancnt].phases,phasecnt), temp->
    powerplans[plancnt].phases[phasecnt].id = pc2.pathway_catalog_id,
    temp->powerplans[plancnt].phases[phasecnt].description = pc2.description
   ENDIF
   phaseeventcnt = 0
  HEAD per2.pw_evidence_reltn_id
   IF (pc1.type_mean="PATHWAY"
    AND per2.pw_evidence_reltn_id > 0)
    temp->powerplans[plancnt].phases[phasecnt].related_results_ind = 1, temp->powerplans[plancnt].
    phase_has_related_results_ind = 1, total_related_results = (total_related_results+ 1),
    phaseeventcnt = (phaseeventcnt+ 1), stat = alterlist(temp->powerplans[plancnt].phases[phasecnt].
     event_sets,phaseeventcnt), temp->powerplans[plancnt].phases[phasecnt].event_sets[phaseeventcnt].
    sequence = per2.evidence_sequence,
    temp->powerplans[plancnt].phases[phasecnt].event_sets[phaseeventcnt].display = v2
    .event_set_cd_disp, temp->powerplans[plancnt].phases[phasecnt].event_sets[phaseeventcnt].
    description = v2.event_set_cd_descr
   ENDIF
  FOOT REPORT
   stat = alterlist(temp->powerplans,plancnt)
  WITH nocounter
 ;end select
 IF ((request->skip_volume_check_ind=0))
  IF (total_related_results > 3000)
   SET reply->high_volume_flag = 2
   GO TO exit_script
  ELSEIF (total_related_results > 1500)
   SET reply->high_volume_flag = 1
   GO TO exit_script
  ENDIF
 ENDIF
 FOR (p = 1 TO plancnt)
   SET phasecnt = size(temp->powerplans[p].phases,5)
   IF (phasecnt=1)
    SET temp->powerplans[p].phases[1].sequence = 1
   ENDIF
   IF (phasecnt > 1)
    SET parent_id = 0.0
    SELECT INTO "nl:"
     FROM (dummyt d  WITH seq = phasecnt),
      pw_cat_reltn pcr1
     PLAN (d)
      JOIN (pcr1
      WHERE (pcr1.pw_cat_s_id=temp->powerplans[p].phases[d.seq].id)
       AND pcr1.type_mean="SUCCEED"
       AND  NOT ( EXISTS (
      (SELECT
       pcr.pw_cat_t_id
       FROM pw_cat_reltn pcr
       WHERE pcr.type_mean="SUCCEED"
        AND pcr.pw_cat_t_id=pcr1.pw_cat_s_id))))
     DETAIL
      parent_id = pcr1.pw_cat_s_id, temp->powerplans[p].phases[d.seq].sequence = 1
     WITH nocounter
    ;end select
    SET p_id = 0.0
    SET p_id = parent_id
    SET s = 1
    SELECT INTO "NL:"
     FROM (dummyt d  WITH seq = (phasecnt - 1)),
      pw_cat_reltn pcr
     PLAN (d)
      JOIN (pcr
      WHERE pcr.pw_cat_s_id=p_id
       AND pcr.type_mean="SUCCEED")
     HEAD d.seq
      p_id = pcr.pw_cat_t_id, s = (s+ 1), d = 0,
      index = locateval(d,1,phasecnt,pcr.pw_cat_t_id,temp->powerplans[p].phases[d].id), temp->
      powerplans[p].phases[index].sequence = s
     WITH nocounter
    ;end select
   ENDIF
 ENDFOR
 SET stat = alterlist(reply->collist,5)
 SET reply->collist[1].header_text = "PowerPlan"
 SET reply->collist[1].data_type = 1
 SET reply->collist[1].hide_ind = 0
 SET reply->collist[2].header_text = "Phase"
 SET reply->collist[2].data_type = 1
 SET reply->collist[2].hide_ind = 0
 SET reply->collist[3].header_text = "Related Result Display"
 SET reply->collist[3].data_type = 1
 SET reply->collist[3].hide_ind = 0
 SET reply->collist[4].header_text = "Related Result Description"
 SET reply->collist[4].data_type = 1
 SET reply->collist[4].hide_ind = 0
 SET reply->collist[5].header_text = "Sequence"
 SET reply->collist[5].data_type = 1
 SET reply->collist[5].hide_ind = 0
 SET row_nbr = 0
 FOR (p = 1 TO plancnt)
  SET phasecnt = size(temp->powerplans[p].phases,5)
  IF (phasecnt=0)
   IF ((temp->powerplans[p].related_results_ind=1))
    SET planeventcnt = size(temp->powerplans[p].event_sets,5)
    FOR (e = 1 TO planeventcnt)
      SET row_nbr = (row_nbr+ 1)
      SET stat = alterlist(reply->rowlist,row_nbr)
      SET stat = alterlist(reply->rowlist[row_nbr].celllist,5)
      SET reply->rowlist[row_nbr].celllist[1].string_value = temp->powerplans[p].description
      SET reply->rowlist[row_nbr].celllist[2].string_value = " "
      SET reply->rowlist[row_nbr].celllist[3].string_value = temp->powerplans[p].event_sets[e].
      display
      SET reply->rowlist[row_nbr].celllist[4].string_value = temp->powerplans[p].event_sets[e].
      description
      SET reply->rowlist[row_nbr].celllist[5].string_value = cnvtstring(temp->powerplans[p].
       event_sets[e].sequence)
    ENDFOR
   ENDIF
  ELSE
   SELECT INTO "nl:"
    FROM (dummyt d  WITH seq = value(phasecnt)),
     (dummyt d2  WITH seq = 1)
    PLAN (d
     WHERE maxrec(d2,size(temp->powerplans[p].phases[d.seq].event_sets,5)))
     JOIN (d2)
    ORDER BY temp->powerplans[p].phases[d.seq].sequence
    DETAIL
     row_nbr = (row_nbr+ 1), stat = alterlist(reply->rowlist,row_nbr), stat = alterlist(reply->
      rowlist[row_nbr].celllist,5),
     reply->rowlist[row_nbr].celllist[1].string_value = temp->powerplans[p].description, reply->
     rowlist[row_nbr].celllist[2].string_value = temp->powerplans[p].phases[d.seq].description, reply
     ->rowlist[row_nbr].celllist[3].string_value = temp->powerplans[p].phases[d.seq].event_sets[d2
     .seq].display,
     reply->rowlist[row_nbr].celllist[4].string_value = temp->powerplans[p].phases[d.seq].event_sets[
     d2.seq].description, reply->rowlist[row_nbr].celllist[5].string_value = cnvtstring(temp->
      powerplans[p].phases[d.seq].event_sets[d2.seq].sequence)
    WITH nocounter
   ;end select
  ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 IF ((reply->high_volume_flag IN (1, 2)))
  SET reply->output_filename = build("powerplan_related_results.csv")
 ENDIF
 IF ((request->output_filename > " "))
  EXECUTE bed_rpt_file
 ENDIF
 CALL echorecord(reply)
END GO
