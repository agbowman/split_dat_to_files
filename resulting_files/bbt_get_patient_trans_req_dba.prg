CREATE PROGRAM bbt_get_patient_trans_req:dba
 RECORD reply(
   1 reqs[*]
     2 requirement_cd = f8
     2 requirement_disp = c40
     2 requirement_desc = c40
     2 requirement_seq = i4
     2 antigenneg_cnt = i4
     2 antigen_neg_list[*]
       3 antigen_cd = f8
       3 antigen_disp = c40
       3 antigen_mean = c12
       3 antigen_seq = i4
       3 warn_ind = i2
       3 allow_override_ind = i2
       3 special_isbt = vc
     2 excluded_product_category_list[*]
       3 product_cat_cd = f8
       3 product_cat_disp = vc
   1 antibody[*]
     2 antibody_cd = f8
     2 antibody_disp = c40
     2 antibody_desc = c40
     2 antibody_seq = i4
     2 antigenneg_cnt = i4
     2 anti_d_ind = i2
     2 significance_ind = i2
     2 antigen_neg_list[*]
       3 antigen_cd = f8
       3 antigen_disp = c40
       3 antigen_seq = i4
       3 warn_ind = i2
       3 allow_override_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET anti_cnt = 0
 SET neg_cnt = 0
 SET excld_prod_cat_cnt = 0
#get_transfusion_requirements
 SELECT DISTINCT INTO "nl:"
  p.requirement_cd, a.special_testing_cd
  FROM person_trans_req p,
   trans_req_r a,
   bb_isbt_attribute_r biar,
   bb_isbt_attribute bia
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND p.active_ind=1)
   JOIN (a
   WHERE (a.requirement_cd= Outerjoin(p.requirement_cd))
    AND (a.active_ind= Outerjoin(1)) )
   JOIN (biar
   WHERE (biar.attribute_cd= Outerjoin(a.special_testing_cd))
    AND (biar.active_ind= Outerjoin(1)) )
   JOIN (bia
   WHERE (bia.bb_isbt_attribute_id= Outerjoin(biar.bb_isbt_attribute_id))
    AND (bia.active_ind= Outerjoin(1)) )
  ORDER BY p.requirement_cd
  HEAD p.requirement_cd
   neg_cnt = 0, anti_cnt += 1, stat = alterlist(reply->reqs,anti_cnt),
   reply->reqs[anti_cnt].requirement_cd = p.requirement_cd
  DETAIL
   IF (a.special_testing_cd > 0)
    neg_cnt += 1, stat = alterlist(reply->reqs[anti_cnt].antigen_neg_list,neg_cnt), reply->reqs[
    anti_cnt].antigen_neg_list[neg_cnt].antigen_cd = a.special_testing_cd,
    reply->reqs[anti_cnt].antigen_neg_list[neg_cnt].warn_ind = a.warn_ind, reply->reqs[anti_cnt].
    antigen_neg_list[neg_cnt].allow_override_ind = a.allow_override_ind, reply->reqs[anti_cnt].
    antigen_neg_list[neg_cnt].special_isbt = bia.standard_display
   ENDIF
  FOOT  p.requirement_cd
   reply->reqs[anti_cnt].antigenneg_cnt = neg_cnt
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SELECT INTO "nl:"
  FROM excld_trans_req_prod_cat_r etp,
   (dummyt d  WITH seq = value(size(reply->reqs,5)))
  PLAN (d)
   JOIN (etp
   WHERE (etp.requirement_cd=reply->reqs[d.seq].requirement_cd)
    AND etp.active_ind=1)
  ORDER BY etp.requirement_cd
  HEAD etp.requirement_cd
   excld_prod_cat_cnt = 0
  DETAIL
   IF (etp.product_cat_cd > 0)
    excld_prod_cat_cnt += 1, stat = alterlist(reply->reqs[d.seq].excluded_product_category_list,
     excld_prod_cat_cnt), reply->reqs[d.seq].excluded_product_category_list[excld_prod_cat_cnt].
    product_cat_cd = etp.product_cat_cd,
    reply->reqs[d.seq].excluded_product_category_list[excld_prod_cat_cnt].product_cat_disp =
    uar_get_code_display(etp.product_cat_cd)
   ENDIF
  WITH nocounter
 ;end select
#get_antibody_info
 SET anti_cnt = 0
 SET neg_cnt = 0
 SET max_anti = 0
 SET max_neg = 0
 SELECT DISTINCT INTO "nl:"
  p.antibody_cd, t.special_testing_cd
  FROM person_antibody p,
   transfusion_requirements tr,
   dummyt d,
   trans_req_r t
  PLAN (p
   WHERE (p.person_id=request->person_id)
    AND p.active_ind=1)
   JOIN (tr
   WHERE p.antibody_cd=tr.requirement_cd)
   JOIN (d
   WHERE d.seq=1)
   JOIN (t
   WHERE p.antibody_cd=t.requirement_cd
    AND t.active_ind=1)
  ORDER BY p.antibody_cd, t.special_testing_cd
  HEAD p.antibody_cd
   neg_cnt = 0, anti_cnt += 1, stat = alterlist(reply->antibody,anti_cnt),
   reply->antibody[anti_cnt].antibody_cd = p.antibody_cd, reply->antibody[anti_cnt].anti_d_ind = tr
   .anti_d_ind, reply->antibody[anti_cnt].significance_ind = tr.significance_ind
  DETAIL
   IF (t.special_testing_cd > 0)
    neg_cnt += 1, stat = alterlist(reply->antibody[anti_cnt].antigen_neg_list,neg_cnt), reply->
    antibody[anti_cnt].antigen_neg_list[neg_cnt].antigen_cd = t.special_testing_cd,
    reply->antibody[anti_cnt].antigen_neg_list[neg_cnt].warn_ind = t.warn_ind, reply->antibody[
    anti_cnt].antigen_neg_list[neg_cnt].allow_override_ind = t.allow_override_ind
   ENDIF
  FOOT  p.antibody_cd
   reply->antibody[anti_cnt].antigenneg_cnt = neg_cnt
  WITH nocounter, outerjoin = d
 ;end select
 IF (curqual > 0
  AND (reply->status_data.status != "F"))
  SET reply->status_data.status = "S"
 ENDIF
END GO
