CREATE PROGRAM ecf_cleanup_alpha_resp:dba
 FREE SET nomlist
 RECORD nomlist(
   1 list[*]
     2 source_string = vc
     2 old_nomen_id = f8
     2 new_nomen_id = f8
 )
 DECLARE nomlist_cnt = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  FROM nomenclature t1,
   alpha_responses t2
  PLAN (t1
   WHERE (t1.principle_type_cd=
   (SELECT
    code_value
    FROM code_value
    WHERE cdf_meaning="ALPHA RESPON"
     AND code_set=401
     AND active_ind=1))
    AND (t1.contributor_system_cd=
   (SELECT
    code_value
    FROM code_value
    WHERE cdf_meaning="POWERCHART"
     AND code_set=89
     AND active_ind=1)))
   JOIN (t2
   WHERE t1.source_string=t2.description
    AND t1.nomenclature_id != t2.nomenclature_id
    AND  NOT (t2.nomenclature_id IN (
   (SELECT
    nomenclature_id
    FROM nomenclature))))
  GROUP BY t1.source_string, t2.nomenclature_id, t1.nomenclature_id
  DETAIL
   nomlist_cnt = (nomlist_cnt+ 1), stat = alterlist(nomlist->list,nomlist_cnt), nomlist->list[
   nomlist_cnt].source_string = t1.source_string,
   nomlist->list[nomlist_cnt].old_nomen_id = t2.nomenclature_id, nomlist->list[nomlist_cnt].
   new_nomen_id = t1.nomenclature_id
  WITH check, nocounter
 ;end select
 CALL echorecord(nomlist)
 IF (nomlist_cnt > 0)
  UPDATE  FROM qc_result t1,
    (dummyt d  WITH seq = value(nomlist_cnt))
   SET t1.nomenclature_id = nomlist->list[d.seq].new_nomen_id, t1.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), t1.updt_cnt = (t1.updt_cnt+ 1)
   PLAN (d
    WHERE d.seq > 0)
    JOIN (t1
    WHERE (t1.nomenclature_id=nomlist->list[d.seq].old_nomen_id))
   WITH nocounter
  ;end update
  UPDATE  FROM qc_alpha_responses t1,
    (dummyt d  WITH seq = value(nomlist_cnt))
   SET t1.nomenclature_id = nomlist->list[d.seq].new_nomen_id, t1.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), t1.updt_cnt = (t1.updt_cnt+ 1)
   PLAN (d
    WHERE d.seq > 0)
    JOIN (t1
    WHERE (t1.nomenclature_id=nomlist->list[d.seq].old_nomen_id))
   WITH nocounter
  ;end update
  UPDATE  FROM person_rh_pheno_result t1,
    (dummyt d  WITH seq = value(nomlist_cnt))
   SET t1.nomenclature_id = nomlist->list[d.seq].new_nomen_id, t1.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), t1.updt_cnt = (t1.updt_cnt+ 1)
   PLAN (d
    WHERE d.seq > 0)
    JOIN (t1
    WHERE (t1.nomenclature_id=nomlist->list[d.seq].old_nomen_id))
   WITH nocounter
  ;end update
  UPDATE  FROM person_rh_phenotype t1,
    (dummyt d  WITH seq = value(nomlist_cnt))
   SET t1.nomenclature_id = nomlist->list[d.seq].new_nomen_id, t1.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), t1.updt_cnt = (t1.updt_cnt+ 1)
   PLAN (d
    WHERE d.seq > 0)
    JOIN (t1
    WHERE (t1.nomenclature_id=nomlist->list[d.seq].old_nomen_id))
   WITH nocounter
  ;end update
  UPDATE  FROM pathway_focus t1,
    (dummyt d  WITH seq = value(nomlist_cnt))
   SET t1.nomenclature_id = nomlist->list[d.seq].new_nomen_id, t1.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), t1.updt_cnt = (t1.updt_cnt+ 1)
   PLAN (d
    WHERE d.seq > 0)
    JOIN (t1
    WHERE (t1.nomenclature_id=nomlist->list[d.seq].old_nomen_id))
   WITH nocounter
  ;end update
  UPDATE  FROM outcome_criteria t1,
    (dummyt d  WITH seq = value(nomlist_cnt))
   SET t1.nomenclature_id = nomlist->list[d.seq].new_nomen_id, t1.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), t1.updt_cnt = (t1.updt_cnt+ 1)
   PLAN (d
    WHERE d.seq > 0)
    JOIN (t1
    WHERE (t1.nomenclature_id=nomlist->list[d.seq].old_nomen_id))
   WITH nocounter
  ;end update
  UPDATE  FROM hm_expect_sat t1,
    (dummyt d  WITH seq = value(nomlist_cnt))
   SET t1.nomenclature_id = nomlist->list[d.seq].new_nomen_id, t1.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), t1.updt_cnt = (t1.updt_cnt+ 1)
   PLAN (d
    WHERE d.seq > 0)
    JOIN (t1
    WHERE (t1.nomenclature_id=nomlist->list[d.seq].old_nomen_id))
   WITH nocounter
  ;end update
  UPDATE  FROM fhx_activity t1,
    (dummyt d  WITH seq = value(nomlist_cnt))
   SET t1.nomenclature_id = nomlist->list[d.seq].new_nomen_id, t1.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), t1.updt_cnt = (t1.updt_cnt+ 1)
   PLAN (d
    WHERE d.seq > 0)
    JOIN (t1
    WHERE (t1.nomenclature_id=nomlist->list[d.seq].old_nomen_id))
   WITH nocounter
  ;end update
  UPDATE  FROM cyto_endocerv_alpha_r t1,
    (dummyt d  WITH seq = value(nomlist_cnt))
   SET t1.nomenclature_id = nomlist->list[d.seq].new_nomen_id, t1.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), t1.updt_cnt = (t1.updt_cnt+ 1)
   PLAN (d
    WHERE d.seq > 0)
    JOIN (t1
    WHERE (t1.nomenclature_id=nomlist->list[d.seq].old_nomen_id))
   WITH nocounter
  ;end update
  UPDATE  FROM cyto_adequacy_alpha_r t1,
    (dummyt d  WITH seq = value(nomlist_cnt))
   SET t1.nomenclature_id = nomlist->list[d.seq].new_nomen_id, t1.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), t1.updt_cnt = (t1.updt_cnt+ 1)
   PLAN (d
    WHERE d.seq > 0)
    JOIN (t1
    WHERE (t1.nomenclature_id=nomlist->list[d.seq].old_nomen_id))
   WITH nocounter
  ;end update
  UPDATE  FROM ce_susceptibility t1,
    (dummyt d  WITH seq = value(nomlist_cnt))
   SET t1.nomenclature_id = nomlist->list[d.seq].new_nomen_id, t1.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), t1.updt_cnt = (t1.updt_cnt+ 1)
   PLAN (d
    WHERE d.seq > 0)
    JOIN (t1
    WHERE (t1.nomenclature_id=nomlist->list[d.seq].old_nomen_id))
   WITH nocounter
  ;end update
  UPDATE  FROM shx_alpha_response t1,
    (dummyt d  WITH seq = value(nomlist_cnt))
   SET t1.nomenclature_id = nomlist->list[d.seq].new_nomen_id, t1.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), t1.updt_cnt = (t1.updt_cnt+ 1)
   PLAN (d
    WHERE d.seq > 0)
    JOIN (t1
    WHERE (t1.nomenclature_id=nomlist->list[d.seq].old_nomen_id))
   WITH nocounter
  ;end update
  UPDATE  FROM bill_item t1,
    (dummyt d  WITH seq = value(nomlist_cnt))
   SET t1.ext_child_reference_id = nomlist->list[d.seq].new_nomen_id, t1.updt_dt_tm = cnvtdatetime(
     curdate,curtime3), t1.updt_cnt = (t1.updt_cnt+ 1)
   PLAN (d
    WHERE d.seq > 0)
    JOIN (t1
    WHERE (t1.ext_child_reference_id=nomlist->list[d.seq].old_nomen_id)
     AND (t1.ext_child_contributor_cd=
    (SELECT
     code_value
     FROM code_value
     WHERE code_set=13016
      AND active_ind=1
      AND cdf_meaning="ALPHA RESP")))
   WITH nocounter
  ;end update
  UPDATE  FROM charge_event_act t1,
    (dummyt d  WITH seq = value(nomlist_cnt))
   SET t1.alpha_nomen_id = nomlist->list[d.seq].new_nomen_id, t1.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), t1.updt_cnt = (t1.updt_cnt+ 1)
   PLAN (d
    WHERE d.seq > 0)
    JOIN (t1
    WHERE (t1.alpha_nomen_id=nomlist->list[d.seq].old_nomen_id))
   WITH nocounter
  ;end update
  UPDATE  FROM perform_result t1,
    (dummyt d  WITH seq = value(nomlist_cnt))
   SET t1.nomenclature_id = nomlist->list[d.seq].new_nomen_id, t1.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), t1.updt_cnt = (t1.updt_cnt+ 1)
   PLAN (d
    WHERE d.seq > 0)
    JOIN (t1
    WHERE (t1.nomenclature_id=nomlist->list[d.seq].old_nomen_id))
   WITH nocounter
  ;end update
  UPDATE  FROM ce_coded_result t1,
    (dummyt d  WITH seq = value(nomlist_cnt))
   SET t1.nomenclature_id = nomlist->list[d.seq].new_nomen_id, t1.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), t1.updt_cnt = (t1.updt_cnt+ 1)
   PLAN (d
    WHERE d.seq > 0)
    JOIN (t1
    WHERE (t1.nomenclature_id=nomlist->list[d.seq].old_nomen_id))
   WITH nocounter
  ;end update
  UPDATE  FROM alpha_responses t1,
    (dummyt d  WITH seq = value(nomlist_cnt))
   SET t1.nomenclature_id = nomlist->list[d.seq].new_nomen_id, t1.updt_dt_tm = cnvtdatetime(curdate,
     curtime3), t1.updt_cnt = (t1.updt_cnt+ 1)
   PLAN (d
    WHERE d.seq > 0)
    JOIN (t1
    WHERE (t1.nomenclature_id=nomlist->list[d.seq].old_nomen_id))
   WITH nocounter
  ;end update
  COMMIT
 ENDIF
 DELETE  FROM shx_activity
  WHERE shx_activity_id IN (
  (SELECT
   shx_activity_id
   FROM shx_response
   WHERE shx_response_id IN (
   (SELECT
    shx_response_id
    FROM shx_alpha_response
    WHERE  NOT (nomenclature_id IN (
    (SELECT
     nomenclature_id
     FROM nomenclature)))))))
  WITH nocounter
 ;end delete
 DELETE  FROM shx_response
  WHERE shx_response_id IN (
  (SELECT
   shx_response_id
   FROM shx_alpha_response
   WHERE  NOT (nomenclature_id IN (
   (SELECT
    nomenclature_id
    FROM nomenclature)))))
  WITH nocounter
 ;end delete
 DELETE  FROM shx_alpha_response
  WHERE  NOT (nomenclature_id IN (
  (SELECT
   nomenclature_id
   FROM nomenclature)))
  WITH nocounter
 ;end delete
 COMMIT
END GO
