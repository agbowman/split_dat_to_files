CREATE PROGRAM bed_get_transfer_cat_reltn:dba
 FREE SET reply
 RECORD reply(
   1 transfer_categories[*]
     2 id = f8
     2 relationships[*]
       3 source_event_code_value = f8
       3 source_event_name = vc
       3 target_event_code_value = f8
       3 target_event_name = vc
       3 assoc_ident_code_value = f8
       3 assoc_ident_display = vc
       3 reltn_sequence = i4
       3 dcp_cf_trans_event_cd_r_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET tcnt = size(request->transfer_categories,5)
 SET stat = alterlist(reply->transfer_categories,tcnt)
 FOR (t = 1 TO tcnt)
   SET reply->transfer_categories[t].id = request->transfer_categories[t].id
 ENDFOR
 IF (tcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = tcnt),
    dcp_cf_trans_cat_reltn d1,
    dcp_cf_trans_event_cd_r d2,
    v500_event_code v1,
    v500_event_code v2,
    code_value cv
   PLAN (d)
    JOIN (d1
    WHERE (d1.dcp_cf_trans_cat_id=request->transfer_categories[d.seq].id)
     AND d1.active_ind=1)
    JOIN (d2
    WHERE d2.dcp_cf_trans_event_cd_r_id=d1.dcp_cf_trans_event_cd_r_id
     AND (d2.cf_transfer_type_cd=request->transfer_type_code_value)
     AND d2.active_ind=1)
    JOIN (v1
    WHERE v1.event_cd=d2.source_event_cd)
    JOIN (v2
    WHERE v2.event_cd=d2.target_event_cd)
    JOIN (cv
    WHERE cv.code_value=d2.association_identifier_cd
     AND cv.active_ind=1)
   ORDER BY d.seq
   HEAD d.seq
    rcnt = 0
   DETAIL
    rcnt = (rcnt+ 1), stat = alterlist(reply->transfer_categories[d.seq].relationships,rcnt), reply->
    transfer_categories[d.seq].relationships[rcnt].source_event_code_value = d2.source_event_cd,
    reply->transfer_categories[d.seq].relationships[rcnt].source_event_name = v1.event_cd_disp, reply
    ->transfer_categories[d.seq].relationships[rcnt].target_event_code_value = d2.target_event_cd,
    reply->transfer_categories[d.seq].relationships[rcnt].target_event_name = v2.event_cd_disp,
    reply->transfer_categories[d.seq].relationships[rcnt].assoc_ident_code_value = d2
    .association_identifier_cd, reply->transfer_categories[d.seq].relationships[rcnt].
    assoc_ident_display = cv.display, reply->transfer_categories[d.seq].relationships[rcnt].
    reltn_sequence = d1.reltn_sequence,
    reply->transfer_categories[d.seq].relationships[rcnt].dcp_cf_trans_event_cd_r_id = d2
    .dcp_cf_trans_event_cd_r_id
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
