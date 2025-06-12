CREATE PROGRAM aps_get_wp_template:dba
 RECORD reply(
   1 template_id = f8
   1 short_desc = vc
   1 description = vc
   1 type_cd = f8
   1 activity_type_cd = f8
   1 person_id = f8
   1 user_name = vc
   1 active_ind = i2
   1 updt_cnt = i4
   1 text_qual[*]
     2 template_id = f8
     2 sequence = i4
     2 text = vc
     2 updt_cnt = i4
     2 result_layout_id = f8
     2 format_id = f8
   1 org_qual[*]
     2 organization_id = f8
     2 filter_entity_id = f8
     2 organization_name = vc
   1 result_layout_exists_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET max_text_cnt = 1
 SET text_cnt = 0
 DECLARE org_filter_cd = f8 WITH protected, noconstant(0.0)
 SET org_filter_cd = uar_get_code_by("MEANING",30620,"WPTEMPLATE")
 SELECT INTO "nl:"
  FROM filter_entity_reltn fer,
   organization o
  PLAN (fer
   WHERE (fer.parent_entity_id=request->template_id)
    AND fer.parent_entity_name="WP_TEMPLATE"
    AND fer.filter_entity1_name="ORGANIZATION"
    AND fer.filter_type_cd=org_filter_cd
    AND fer.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    AND fer.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   JOIN (o
   WHERE fer.filter_entity1_id=o.organization_id)
  HEAD REPORT
   org_cnt = 0
  DETAIL
   org_cnt = (org_cnt+ 1)
   IF (mod(org_cnt,5)=1)
    stat = alterlist(reply->org_qual,(org_cnt+ 4))
   ENDIF
   reply->org_qual[org_cnt].filter_entity_id = fer.filter_entity_reltn_id, reply->org_qual[org_cnt].
   organization_id = fer.filter_entity1_id, reply->org_qual[org_cnt].organization_name = o.org_name
  FOOT REPORT
   stat = alterlist(reply->org_qual,org_cnt)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  t.template_id, lt.long_text_id, tt.template_id,
  p.person_id, t.result_layout_exists_ind, tt.pcs_rslt_layout_id,
  tt.pcs_rslt_frmt_vrsn_id
  FROM wp_template t,
   wp_template_text tt,
   long_text lt,
   prsnl p
  PLAN (t
   WHERE (t.template_id=request->template_id))
   JOIN (tt
   WHERE t.template_id=tt.template_id)
   JOIN (lt
   WHERE tt.long_text_id=lt.long_text_id)
   JOIN (p
   WHERE t.person_id=p.person_id)
  ORDER BY t.template_id
  HEAD REPORT
   max_text_cnt = 5, text_cnt = 0
  HEAD t.template_id
   stat = alterlist(reply->text_qual,max_text_cnt), reply->template_id = t.template_id, reply->
   short_desc = trim(t.short_desc),
   reply->description = trim(t.description), reply->type_cd = t.template_type_cd, reply->
   activity_type_cd = t.activity_type_cd,
   reply->person_id = t.person_id, reply->user_name = p.username, reply->active_ind = t.active_ind,
   reply->updt_cnt = t.updt_cnt, reply->result_layout_exists_ind = t.result_layout_exists_ind
  DETAIL
   text_cnt = (text_cnt+ 1)
   IF (text_cnt > max_text_cnt)
    stat = alterlist(reply->text_qual,text_cnt), max_text_cnt = text_cnt
   ENDIF
   reply->text_qual[text_cnt].template_id = tt.template_id, reply->text_qual[text_cnt].sequence = tt
   .sequence, reply->text_qual[text_cnt].text = lt.long_text,
   reply->text_qual[text_cnt].updt_cnt = tt.updt_cnt, reply->text_qual[text_cnt].result_layout_id =
   tt.pcs_rslt_layout_id, reply->text_qual[text_cnt].format_id = tt.pcs_rslt_frmt_vrsn_id
  FOOT REPORT
   stat = alterlist(reply->text_qual,text_cnt)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "Z"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "WP_TEMPLATE"
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
