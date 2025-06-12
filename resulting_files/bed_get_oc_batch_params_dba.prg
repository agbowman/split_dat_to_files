CREATE PROGRAM bed_get_oc_batch_params:dba
 FREE SET reply
 RECORD reply(
   1 olist[*]
     2 catalog_cd = f8
     2 dlist[*]
       3 dup_check_level = i2
       3 look_behind_action_cd = f8
       3 look_behind_action_display = c40
       3 look_behind_action_cdf_mean = c12
       3 look_behind_minutes = i4
       3 look_ahead_action_cd = f8
       3 look_ahead_action_display = c40
       3 look_ahead_action_cdf_mean = c12
       3 look_ahead_minutes = i4
       3 exact_match_action_cd = f8
       3 exact_match_action_display = c40
       3 exact_match_action_cdf_mean = c12
     2 clin_cat_cd = f8
     2 clin_cat_display = c40
     2 clin_cat_cdf_mean = c12
     2 schedulable_ind = i2
     2 slist[*]
       3 pat_type_cd = f8
       3 pat_type_display = c40
       3 pat_type_cdf_mean = c12
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET ocnt = 0
 SET ocnt = size(request->oclist,5)
 SET stat = alterlist(reply->olist,ocnt)
 FOR (o = 1 TO ocnt)
   SET reply->olist[o].catalog_cd = request->oclist[o].catalog_cd
 ENDFOR
 IF ((request->dup_check_ind=1))
  IF (ocnt > 0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = ocnt),
     order_catalog oc,
     dup_checking dc,
     code_value cv1,
     code_value cv2,
     code_value cv3
    PLAN (d)
     JOIN (oc
     WHERE (oc.catalog_cd=request->oclist[d.seq].catalog_cd))
     JOIN (dc
     WHERE dc.catalog_cd=outerjoin(oc.catalog_cd)
      AND dc.active_ind=outerjoin(1))
     JOIN (cv1
     WHERE cv1.code_value=outerjoin(dc.min_behind_action_cd))
     JOIN (cv2
     WHERE cv2.code_value=outerjoin(dc.min_ahead_action_cd))
     JOIN (cv3
     WHERE cv3.code_value=outerjoin(dc.exact_hit_action_cd))
    ORDER BY oc.catalog_cd, dc.dup_check_seq
    HEAD oc.catalog_cd
     stat = alterlist(reply->olist[d.seq].dlist,3), alterlist_cnt = 0, dcnt = 0
    HEAD dc.dup_check_seq
     IF (dc.dup_check_seq > 0)
      alterlist_cnt = (alterlist_cnt+ 1)
      IF (alterlist_cnt > 3)
       stat = alterlist(reply->olist[d.seq].dlist,(dcnt+ 3)), alterlist_cnt = 1
      ENDIF
      dcnt = (dcnt+ 1), reply->olist[d.seq].dlist[dcnt].dup_check_level = dc.dup_check_seq, reply->
      olist[d.seq].dlist[dcnt].look_behind_action_cd = dc.min_behind_action_cd,
      reply->olist[d.seq].dlist[dcnt].look_behind_action_display = cv1.display, reply->olist[d.seq].
      dlist[dcnt].look_behind_action_cdf_mean = cv1.cdf_meaning, reply->olist[d.seq].dlist[dcnt].
      look_behind_minutes = dc.min_behind,
      reply->olist[d.seq].dlist[dcnt].look_ahead_action_cd = dc.min_ahead_action_cd, reply->olist[d
      .seq].dlist[dcnt].look_ahead_action_display = cv2.display, reply->olist[d.seq].dlist[dcnt].
      look_ahead_action_cdf_mean = cv2.cdf_meaning,
      reply->olist[d.seq].dlist[dcnt].look_ahead_minutes = dc.min_ahead, reply->olist[d.seq].dlist[
      dcnt].exact_match_action_cd = dc.exact_hit_action_cd, reply->olist[d.seq].dlist[dcnt].
      exact_match_action_display = cv3.display,
      reply->olist[d.seq].dlist[dcnt].exact_match_action_cdf_mean = cv3.cdf_meaning
     ENDIF
    FOOT  oc.catalog_cd
     stat = alterlist(reply->olist[d.seq].dlist,dcnt)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF ((((request->clin_cat_ind=1)) OR ((request->sched_params_ind=1))) )
  IF (ocnt > 0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = ocnt),
     order_catalog oc,
     code_value cv
    PLAN (d)
     JOIN (oc
     WHERE (oc.catalog_cd=request->oclist[d.seq].catalog_cd))
     JOIN (cv
     WHERE cv.code_value=outerjoin(oc.dcp_clin_cat_cd))
    DETAIL
     IF ((request->clin_cat_ind=1))
      reply->olist[d.seq].clin_cat_cd = oc.dcp_clin_cat_cd, reply->olist[d.seq].clin_cat_display = cv
      .display, reply->olist[d.seq].clin_cat_cdf_mean = cv.cdf_meaning
     ENDIF
     IF ((request->sched_params_ind=1))
      reply->olist[d.seq].schedulable_ind = oc.schedule_ind
     ENDIF
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 IF ((request->sched_params_ind=1))
  IF (ocnt > 0)
   SELECT INTO "NL:"
    FROM (dummyt d  WITH seq = ocnt),
     dcp_entity_reltn der,
     code_value cv
    PLAN (d)
     JOIN (der
     WHERE (der.entity1_id=request->oclist[d.seq].catalog_cd)
      AND der.entity_reltn_mean="ORC/SCHENCTP"
      AND der.active_ind=1)
     JOIN (cv
     WHERE cv.code_value=outerjoin(der.entity2_id))
    ORDER BY der.entity1_id
    HEAD der.entity1_id
     stat = alterlist(reply->olist[d.seq].slist,10), alterlist_cnt = 0, scnt = 0
    DETAIL
     alterlist_cnt = (alterlist_cnt+ 1)
     IF (alterlist_cnt > 10)
      stat = alterlist(reply->olist[d.seq].slist,(scnt+ 10)), alterlist_cnt = 1
     ENDIF
     scnt = (scnt+ 1), reply->olist[d.seq].slist[scnt].pat_type_cd = der.entity2_id
     IF (der.entity2_id > 0)
      reply->olist[d.seq].slist[scnt].pat_type_display = cv.display, reply->olist[d.seq].slist[scnt].
      pat_type_cdf_mean = cv.cdf_meaning
     ELSE
      reply->olist[d.seq].slist[scnt].pat_type_display = "Future"
     ENDIF
    FOOT  der.entity1_id
     stat = alterlist(reply->olist[d.seq].slist,scnt)
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
