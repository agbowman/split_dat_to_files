CREATE PROGRAM bhs_athn_get_social_hx
 RECORD orequest(
   1 person_id = f8
   1 prsnl_id = f8
   1 category_qual[*]
     2 shx_category_ref_id = f8
 )
 RECORD hrequest(
   1 qual[*]
     2 shx_activity_group_id = f8
 )
 RECORD prequest(
   1 chk_prsnl_ind = i2
   1 prsnl_id = f8
   1 chk_psn_ind = i2
   1 position_cd = f8
   1 chk_ppr_ind = i2
   1 ppr_cd = f8
   1 plist[*]
     2 privilege_cd = f8
     2 privilege_mean = c12
 )
 RECORD out_rec(
   1 can_view = vc
   1 excepts[*]
     2 exception_entity_name = vc
     2 exception_type_disp = vc
     2 exception_type_desc = vc
     2 exception_type_mean = vc
     2 exception_type_value = vc
   1 activity[*]
     2 shx_category_ref_id = vc
     2 shx_category_def_id = vc
     2 category_cd = vc
     2 category = vc
     2 shx_activity_id = vc
     2 shx_activity_group_id = vc
     2 type_mean = vc
     2 status_cd = vc
     2 status = vc
     2 last_review_dt_tm = dq8
     2 last_updt_dt_tm = dq8
     2 last_updt_prsnl_name = vc
     2 responses[*]
       3 task_assay_cd = vc
       3 task_assay_disp = vc
       3 response_type = vc
       3 nomenclature_id = vc
       3 nomenclature_disp = vc
       3 freetext = vc
       3 response_val = vc
       3 response_units = vc
       3 alpha_response[*]
         4 nomenclature_id = vc
         4 nomenclature_disp = vc
         4 other_text = vc
     2 comments[*]
       3 comment = vc
       3 comment_prsnl = vc
       3 comment_dt_tm = dq8
 )
 DECLARE c_cnt = i4
 SET orequest->person_id =  $2
 SELECT INTO "nl:"
  FROM prsnl p
  PLAN (p
   WHERE (p.person_id= $3))
  HEAD REPORT
   prequest->position_cd = p.position_cd
  WITH nocounter, time = 30
 ;end select
 SET prequest->chk_psn_ind = 1
 SELECT INTO "nl:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.cdf_meaning="VIEWSOCHIST"
    AND cv.code_set=6016
    AND cv.active_ind=1)
  HEAD REPORT
   p_cnt = 0
  HEAD cv.code_value
   p_cnt = (p_cnt+ 1), stat = alterlist(prequest->plist,p_cnt), prequest->plist[p_cnt].privilege_mean
    = cv.cdf_meaning,
   prequest->plist[p_cnt].privilege_cd = cv.code_value
  WITH nocounter, time = 30
 ;end select
 SET stat = tdbexecute(4250111,500286,500286,"REC",prequest,
  "REC",preply)
 IF ((preply->qual[1].priv_value_mean="YES"))
  SET out_rec->can_view = "Yes"
 ENDIF
 SET stat = alterlist(out_rec->excepts,preply->qual[1].except_cnt)
 FOR (i = 1 TO preply->qual[1].except_cnt)
   SET out_rec->excepts[i].exception_entity_name = preply->qual[1].excepts[i].exception_entity_name
   SET out_rec->excepts[i].exception_type_disp = preply->qual[1].excepts[i].exception_type_disp
   SET out_rec->excepts[i].exception_type_desc = preply->qual[1].excepts[i].exception_type_desc
   SET out_rec->excepts[i].exception_type_mean = preply->qual[1].excepts[i].exception_type_mean
   SET out_rec->excepts[i].exception_type_value = trim(cnvtstring(preply->qual[1].excepts[i].
     exception_type_cd))
 ENDFOR
 IF ((out_rec->can_view="No"))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM shx_category_ref scr
  PLAN (scr
   WHERE scr.shx_category_ref_id > 0)
  ORDER BY scr.shx_category_ref_id
  HEAD scr.shx_category_ref_id
   c_cnt = (c_cnt+ 1), stat = alterlist(orequest->category_qual,c_cnt), orequest->category_qual[c_cnt
   ].shx_category_ref_id = scr.shx_category_ref_id
  WITH nocounter, time = 30
 ;end select
 SET stat = tdbexecute(600005,601029,601052,"REC",orequest,
  "REC",oreply)
 SET stat = alterlist(out_rec->activity,size(oreply->activity_qual,5))
 SET stat = alterlist(hrequest->qual,size(oreply->activity_qual,5))
 FOR (i = 1 TO size(oreply->activity_qual,5))
   SET out_rec->activity[i].shx_category_ref_id = trim(cnvtstring(oreply->activity_qual[i].
     shx_category_ref_id))
   SET out_rec->activity[i].shx_category_def_id = trim(cnvtstring(oreply->activity_qual[i].
     shx_category_def_id))
   SET out_rec->activity[i].shx_activity_group_id = trim(cnvtstring(oreply->activity_qual[i].
     shx_activity_group_id))
   SET out_rec->activity[i].shx_activity_id = trim(cnvtstring(oreply->activity_qual[i].
     shx_activity_id))
   SET out_rec->activity[i].type_mean = oreply->activity_qual[i].type_mean
   SET out_rec->activity[i].status_cd = trim(cnvtstring(oreply->activity_qual[i].status_cd))
   SET out_rec->activity[i].status = uar_get_code_display(oreply->activity_qual[i].status_cd)
   SET out_rec->activity[i].last_review_dt_tm = oreply->activity_qual[i].last_review_dt_tm
   SET out_rec->activity[i].last_updt_dt_tm = oreply->activity_qual[i].last_updt_dt_tm
   SET out_rec->activity[i].last_updt_prsnl_name = oreply->activity_qual[i].last_updt_prsnl_name
   SET hrequest->qual[i].shx_activity_group_id = oreply->activity_qual[i].shx_activity_group_id
 ENDFOR
 SET stat = tdbexecute(600005,601029,601053,"REC",hrequest,
  "REC",hreply)
 SET stat = alterlist(out_rec->activity,size(hreply->activity_qual,5))
 FOR (i = 1 TO size(hreply->activity_qual,5))
   SET stat = alterlist(out_rec->activity[i].responses,size(hreply->activity_qual[i].response_qual,5)
    )
   FOR (j = 1 TO size(hreply->activity_qual[i].response_qual,5))
     SET out_rec->activity[i].responses[j].task_assay_cd = trim(cnvtstring(hreply->activity_qual[i].
       response_qual[j].task_assay_cd))
     SET out_rec->activity[i].responses[j].task_assay_disp = uar_get_code_description(hreply->
      activity_qual[i].response_qual[j].task_assay_cd)
     SET out_rec->activity[i].responses[j].response_type = hreply->activity_qual[i].response_qual[j].
     response_type
     SET out_rec->activity[i].responses[j].response_val = hreply->activity_qual[i].response_qual[j].
     response_val
     SET out_rec->activity[i].responses[j].response_units = uar_get_code_display(hreply->
      activity_qual[i].response_qual[j].response_unit_cd)
     SET stat = alterlist(out_rec->activity[i].responses[j].alpha_response,size(hreply->
       activity_qual[i].response_qual[j].alpha_response_qual,5))
     FOR (k = 1 TO size(hreply->activity_qual[i].response_qual[j].alpha_response_qual,5))
       SET out_rec->activity[i].responses[j].alpha_response[k].nomenclature_id = trim(cnvtstring(
         hreply->activity_qual[i].response_qual[j].alpha_response_qual[k].nomenclature_id))
       SET out_rec->activity[i].responses[j].alpha_response[k].other_text = hreply->activity_qual[i].
       response_qual[j].alpha_response_qual[k].other_text
       SELECT INTO "nl:"
        FROM nomenclature n
        PLAN (n
         WHERE (n.nomenclature_id=hreply->activity_qual[i].response_qual[j].alpha_response_qual[k].
         nomenclature_id))
        DETAIL
         out_rec->activity[i].responses[j].alpha_response[k].nomenclature_disp = n.source_string
        WITH nocounter, time = 30
       ;end select
     ENDFOR
   ENDFOR
   SET stat = alterlist(out_rec->activity[i].comments,size(hreply->activity_qual[i].comment_qual,5))
   FOR (l = 1 TO size(hreply->activity_qual[i].comment_qual,5))
     SET out_rec->activity[i].comments[l].comment = hreply->activity_qual[i].comment_qual[l].
     long_text
     SET out_rec->activity[i].comments[l].comment_dt_tm = hreply->activity_qual[i].comment_qual[l].
     comment_dt_tm
     SET out_rec->activity[i].comments[l].comment_prsnl = hreply->activity_qual[i].comment_qual[l].
     comment_prsnl_full_name
   ENDFOR
 ENDFOR
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = size(out_rec->activity,5)),
   shx_category_ref scr
  PLAN (d)
   JOIN (scr
   WHERE scr.shx_category_ref_id=cnvtreal(out_rec->activity[d.seq].shx_category_ref_id))
  DETAIL
   out_rec->activity[d.seq].category_cd = trim(cnvtstring(scr.category_cd)), out_rec->activity[d.seq]
   .category = uar_get_code_display(scr.category_cd)
  WITH nocounter, time = 30
 ;end select
#exit_script
 CALL echojson(out_rec, $1)
END GO
