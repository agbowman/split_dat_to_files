CREATE PROGRAM aps_get_wp_template_text2:dba
 SET max_text_cnt = 1
 SET text_cnt = 0
 SET template_id = 0.0
 DECLARE org_facility_cd = f8 WITH public, constant(uar_get_code_by("MEANING",30620,"WPTEMPLATE"))
 IF ((request->suppress_unassociated=0))
  SELECT DISTINCT INTO "nl:"
   wp.template_id, wp.activity_type_cd, wp.person_id,
   activity_type_cd = wp.activity_type_cd, person_id = wp.person_id
   FROM wp_template wp
   PLAN (wp
    WHERE wp.template_type_cd=template_type_cd
     AND (wp.short_desc=request->code)
     AND wp.active_ind=1
     AND ((((wp.activity_type_cd=null) OR (wp.activity_type_cd=0))
     AND ((wp.person_id=null) OR (wp.person_id=0)) ) OR ((( $1) OR ((( $2) OR ( $3)) )) ))
     AND  NOT ( EXISTS (
    (SELECT
     fer.parent_entity_id
     FROM filter_entity_reltn fer
     WHERE fer.parent_entity_id=wp.template_id
      AND fer.parent_entity_name="WP_TEMPLATE"
      AND fer.filter_entity1_name="ORGANIZATION"
      AND fer.filter_type_cd=org_facility_cd
      AND fer.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND fer.end_effective_dt_tm >= cnvtdatetime(sysdate)))))
   ORDER BY person_id, activity_type_cd, 0
   HEAD REPORT
    template_id = 0.0
   DETAIL
    template_id = wp.template_id, reply->template_id = wp.template_id, reply->person_id = person_id,
    reply->activity_type_cd = activity_type_cd, reply->result_layout_exists_ind = wp
    .result_layout_exists_ind
   WITH nocounter
  ;end select
 ENDIF
 IF (size(request->org_qual,5) > 0
  AND template_id=0.0)
  SELECT DISTINCT INTO "nl:"
   wp.template_id, wp.activity_type_cd, wp.person_id,
   activity_type_cd = wp.activity_type_cd, person_id = wp.person_id
   FROM wp_template wp,
    filter_entity_reltn fer,
    (dummyt d1  WITH seq = size(request->org_qual,5))
   PLAN (wp
    WHERE wp.template_type_cd=template_type_cd
     AND (wp.short_desc=request->code)
     AND wp.active_ind=1
     AND ((((wp.activity_type_cd=null) OR (wp.activity_type_cd=0))
     AND ((wp.person_id=null) OR (wp.person_id=0)) ) OR ((( $1) OR ((( $2) OR ( $3)) )) )) )
    JOIN (fer
    WHERE fer.parent_entity_id=wp.template_id
     AND fer.parent_entity_name="WP_TEMPLATE"
     AND fer.filter_entity1_name="ORGANIZATION"
     AND fer.filter_type_cd=org_facility_cd
     AND fer.beg_effective_dt_tm <= cnvtdatetime(sysdate)
     AND fer.end_effective_dt_tm >= cnvtdatetime(sysdate))
    JOIN (d1
    WHERE (fer.filter_entity1_id=request->org_qual[d1.seq].organization_id))
   ORDER BY person_id, activity_type_cd, 0
   HEAD REPORT
    template_id = 0.0
   DETAIL
    template_id = wp.template_id, reply->template_id = wp.template_id, reply->person_id = person_id,
    reply->activity_type_cd = activity_type_cd, reply->result_layout_exists_ind = wp
    .result_layout_exists_ind
   WITH nocounter
  ;end select
 ENDIF
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "WP_TEMPLATE"
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 SET stat = alterlist(reply->qual,5)
 SELECT INTO "nl:"
  wp.sequence, lt.long_text_id, wp.pcs_rslt_layout_id,
  wp.pcs_rslt_frmt_vrsn_id, prtd.pcs_rslt_frmt_vrsn_id, prtd.pcs_rslt_layout_id,
  prl.pcs_rslt_layout_id
  FROM wp_template_text wp,
   long_text lt,
   pcs_rslt_tmplt_dflt prtd,
   pcs_rslt_layout prl
  PLAN (wp
   WHERE wp.template_id=template_id)
   JOIN (lt
   WHERE wp.long_text_id=lt.long_text_id)
   JOIN (prtd
   WHERE wp.pcs_rslt_layout_id=prtd.pcs_rslt_layout_id
    AND ((prtd.active_ind=1) OR (prtd.pcs_rslt_layout_id=0))
    AND cnvtdatetime(sysdate) BETWEEN prtd.beg_effective_dt_tm AND prtd.end_effective_dt_tm)
   JOIN (prl
   WHERE prl.pcs_rslt_layout_id=prtd.pcs_rslt_layout_id
    AND cnvtdatetime(sysdate) BETWEEN prl.beg_effective_dt_tm AND prl.end_effective_dt_tm)
  ORDER BY wp.sequence
  HEAD REPORT
   max_text_cnt = 5, text_cnt = 0
  DETAIL
   text_cnt += 1
   IF (text_cnt > max_text_cnt)
    stat = alterlist(reply->qual,text_cnt), max_text_cnt = text_cnt
   ENDIF
   reply->qual[text_cnt].result_layout_id = wp.pcs_rslt_layout_id
   IF (wp.pcs_rslt_frmt_vrsn_id=0)
    reply->qual[text_cnt].format_id = prtd.pcs_rslt_frmt_vrsn_id
   ELSE
    reply->qual[text_cnt].format_id = wp.pcs_rslt_frmt_vrsn_id
   ENDIF
   reply->qual[text_cnt].text = lt.long_text
  FOOT REPORT
   stat = alterlist(reply->qual,text_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "WP_TEMPLATE_TEXT"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 FREE RECORD sac_org
END GO
