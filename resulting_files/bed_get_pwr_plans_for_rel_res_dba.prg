CREATE PROGRAM bed_get_pwr_plans_for_rel_res:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 powerplans[*]
      2 id = f8
      2 description = vc
      2 related_results_ind = i2
      2 phases[*]
        3 id = f8
        3 description = vc
        3 related_results_ind = i2
    1 too_many_results_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD temp(
   1 powerplans[*]
     2 id = f8
     2 description = vc
     2 related_results_ind = i2
     2 phase_has_related_results_ind = i2
     2 phases[*]
       3 id = f8
       3 description = vc
       3 related_results_ind = i2
       3 sequence = i4
 )
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 DECLARE pc1_parse = vc
 IF (validate(request->show_inactive_powerplans_ind))
  IF ((request->show_inactive_powerplans_ind=1))
   SET pc1_parse = "pc1.active_ind in (0,1)"
  ELSE
   SET pc1_parse = "pc1.active_ind = 1"
  ENDIF
 ENDIF
 IF ((request->search_string > " "))
  IF (cnvtupper(request->search_type_flag)="C")
   SET pc1_parse = build(pc1_parse," and cnvtupper(pc1.display_description) = '*",cnvtupper(request->
     search_string),"*'")
  ELSE
   SET pc1_parse = build(pc1_parse," and cnvtupper(pc1.display_description) = '",cnvtupper(request->
     search_string),"*'")
  ENDIF
 ENDIF
 IF ((request->powerplan_type_code_value > 0))
  SET pc1_parse = build(pc1_parse," and pc1.pathway_type_cd = ",request->powerplan_type_code_value)
 ENDIF
 SET cnt = 0
 SET plancnt = 0
 SELECT INTO "nl:"
  FROM pathway_catalog pc1,
   pw_evidence_reltn per1,
   pw_cat_reltn pcr,
   pathway_catalog pc2,
   pw_evidence_reltn per2
  PLAN (pc1
   WHERE parser(pc1_parse)
    AND pc1.type_mean IN ("CAREPLAN", "PATHWAY")
    AND pc1.ref_owner_person_id=0
    AND pc1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND pc1.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
   JOIN (per1
   WHERE per1.pathway_catalog_id=outerjoin(pc1.pathway_catalog_id)
    AND per1.type_mean=outerjoin("EVENTSET"))
   JOIN (pcr
   WHERE pcr.pw_cat_s_id=outerjoin(pc1.pathway_catalog_id)
    AND pcr.type_mean=outerjoin("GROUP"))
   JOIN (pc2
   WHERE pc2.pathway_catalog_id=outerjoin(pcr.pw_cat_t_id))
   JOIN (per2
   WHERE per2.pathway_catalog_id=outerjoin(pc2.pathway_catalog_id)
    AND per2.type_mean=outerjoin("EVENTSET"))
  ORDER BY pc1.display_description, pc2.description, pc1.pathway_catalog_id,
   pc2.pathway_catalog_id
  HEAD REPORT
   cnt = 10, plancnt = 0, stat = alterlist(temp->powerplans,cnt)
  HEAD pc1.pathway_catalog_id
   cnt = (cnt+ 1), plancnt = (plancnt+ 1)
   IF (cnt > 10)
    cnt = 1, stat = alterlist(temp->powerplans,(plancnt+ 10))
   ENDIF
   temp->powerplans[plancnt].id = pc1.pathway_catalog_id, temp->powerplans[plancnt].description = pc1
   .display_description
   IF (pc1.type_mean="CAREPLAN"
    AND per1.pw_evidence_reltn_id > 0)
    temp->powerplans[plancnt].related_results_ind = 1
   ENDIF
   phasecnt = 0
  HEAD pc2.pathway_catalog_id
   IF (pc1.type_mean="PATHWAY")
    IF (pcr.pw_cat_t_id > 0)
     phasecnt = (phasecnt+ 1), stat = alterlist(temp->powerplans[plancnt].phases,phasecnt), temp->
     powerplans[plancnt].phases[phasecnt].id = pc2.pathway_catalog_id,
     temp->powerplans[plancnt].phases[phasecnt].description = pc2.description
     IF (per2.pw_evidence_reltn_id > 0)
      temp->powerplans[plancnt].phases[phasecnt].related_results_ind = 1, temp->powerplans[plancnt].
      phase_has_related_results_ind = 1
     ENDIF
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(temp->powerplans,plancnt)
  WITH nocounter
 ;end select
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
 SET replyplancnt = 0
 FOR (p = 1 TO plancnt)
   IF ((((request->related_results_filter_ind=0)) OR ((((request->related_results_filter_ind=1)
    AND (((temp->powerplans[p].related_results_ind=1)) OR ((temp->powerplans[p].
   phase_has_related_results_ind=1))) ) OR ((request->related_results_filter_ind=2)
    AND (temp->powerplans[p].related_results_ind=0)
    AND (temp->powerplans[p].phase_has_related_results_ind=0))) )) )
    SET replyplancnt = (replyplancnt+ 1)
    SET stat = alterlist(reply->powerplans,replyplancnt)
    SET reply->powerplans[replyplancnt].id = temp->powerplans[p].id
    SET reply->powerplans[replyplancnt].description = temp->powerplans[p].description
    SET reply->powerplans[replyplancnt].related_results_ind = temp->powerplans[p].related_results_ind
    SET phasecnt = size(temp->powerplans[p].phases,5)
    SET stat = alterlist(reply->powerplans[replyplancnt].phases,phasecnt)
    IF (phasecnt > 0)
     SET pcnt = 0
     SELECT INTO "nl:"
      FROM (dummyt d  WITH seq = value(phasecnt))
      PLAN (d)
      ORDER BY temp->powerplans[p].phases[d.seq].sequence
      DETAIL
       pcnt = (pcnt+ 1), reply->powerplans[replyplancnt].phases[pcnt].id = temp->powerplans[p].
       phases[d.seq].id, reply->powerplans[replyplancnt].phases[pcnt].description = temp->powerplans[
       p].phases[d.seq].description,
       reply->powerplans[replyplancnt].phases[pcnt].related_results_ind = temp->powerplans[p].phases[
       d.seq].related_results_ind
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
 ENDFOR
 IF ((request->max_reply > 0)
  AND (replyplancnt > request->max_reply))
  SET stat = alterlist(reply->powerplans,0)
  SET reply->too_many_results_ind = 1
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
