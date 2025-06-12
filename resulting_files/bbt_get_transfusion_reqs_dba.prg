CREATE PROGRAM bbt_get_transfusion_reqs:dba
 RECORD reply(
   1 qual[1]
     2 code_set = i4
     2 code_value = f8
     2 display = c40
     2 description = c40
     2 definition = vc
     2 anti_d_ind = i2
     2 active_type_cd = f8
     2 active_ind = i2
     2 significance_ind = i2
     2 updt_cnt = i4
     2 transreq_desc = vc
     2 transreq_updtcnt = i4
     2 reltn_cnt = i4
     2 qual2[1]
       3 relationship_id = f8
       3 special_testing_cd = f8
       3 special_testing_disp = c40
       3 warn_ind = i2
       3 override_ind = i2
       3 spectst_active_ind = i2
       3 spectst_updt_cnt = i4
     2 excluded_product_cat_cnt = i4
     2 excluded_product_cat_qual[*]
       3 excld_trans_req_prod_cat_r_id = f8
       3 product_cat_cd = f8
       3 product_cat_disp = vc
       3 active_ind = i2
       3 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data[1].status = "F"
 SET anti_cnt = 0
 SET neg_cnt = 0
 SET stat = alter(reply->qual,20)
 SET max_anti = 20
 SET max_neg = 1
 SET cnt = 0
 SET transfusion_req_cs = 1611
 SELECT INTO "nl:"
  c.*, t.*, n.*
  FROM transfusion_requirements t,
   code_value c,
   (dummyt d  WITH seq = 1),
   trans_req_r n
  PLAN (t
   WHERE (((request->requirement_cd > 0)
    AND (t.requirement_cd=request->requirement_cd)) OR ((request->requirement_cd=0)
    AND t.requirement_cd > 0
    AND (((request->code_set=0)) OR ((request->code_set=t.codeset))) )) )
   JOIN (c
   WHERE t.requirement_cd=c.code_value)
   JOIN (d
   WHERE d.seq=1)
   JOIN (n
   WHERE (((request->request_type_ind=1)
    AND t.requirement_cd=n.requirement_cd) OR ((request->request_type_ind=0)
    AND t.requirement_cd=n.requirement_cd
    AND n.active_ind=1)) )
  ORDER BY t.requirement_cd
  HEAD t.requirement_cd
   neg_cnt = 0, anti_cnt = (anti_cnt+ 1)
   IF (anti_cnt > max_anti)
    max_anti = anti_cnt, stat = alter(reply->qual,max_anti)
   ENDIF
   reply->qual[anti_cnt].code_set = t.codeset, reply->qual[anti_cnt].code_value = c.code_value, reply
   ->qual[anti_cnt].display = c.display,
   reply->qual[anti_cnt].description = c.description, reply->qual[anti_cnt].definition = c.definition,
   reply->qual[anti_cnt].active_type_cd = c.active_type_cd,
   reply->qual[anti_cnt].active_ind = c.active_ind, reply->qual[anti_cnt].updt_cnt = c.updt_cnt,
   reply->qual[anti_cnt].transreq_desc = t.description,
   reply->qual[anti_cnt].anti_d_ind = t.anti_d_ind, reply->qual[anti_cnt].transreq_updtcnt = t
   .updt_cnt, reply->qual[anti_cnt].significance_ind = t.significance_ind
  DETAIL
   IF (n.special_testing_cd > 0)
    neg_cnt = (neg_cnt+ 1)
    IF (neg_cnt > max_neg)
     max_neg = neg_cnt, stat = alter(reply->qual.qual2,max_neg)
    ENDIF
    reply->qual[anti_cnt].qual2[neg_cnt].relationship_id = n.relationship_id, reply->qual[anti_cnt].
    qual2[neg_cnt].special_testing_cd = n.special_testing_cd, reply->qual[anti_cnt].qual2[neg_cnt].
    warn_ind = n.warn_ind,
    reply->qual[anti_cnt].qual2[neg_cnt].override_ind = n.allow_override_ind, reply->qual[anti_cnt].
    qual2[neg_cnt].spectst_active_ind = n.active_ind, reply->qual[anti_cnt].qual2[neg_cnt].
    spectst_updt_cnt = n.updt_cnt
   ENDIF
  FOOT  t.requirement_cd
   reply->qual[anti_cnt].reltn_cnt = neg_cnt
  WITH nocounter, outerjoin = d
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 IF ((request->requirement_cd > 0)
  AND size(reply->qual,5) > 0
  AND (reply->qual[1].code_set=transfusion_req_cs))
  SELECT INTO "nl:"
   FROM excld_trans_req_prod_cat_r etp
   PLAN (etp
    WHERE (etp.requirement_cd=request->requirement_cd)
     AND etp.active_ind=1)
   HEAD REPORT
    cnt = 0
   DETAIL
    cnt = (cnt+ 1)
    IF (cnt > size(reply->qual[1].excluded_product_cat_qual,5))
     stat = alterlist(reply->qual[1].excluded_product_cat_qual,cnt)
    ENDIF
    reply->qual[1].excluded_product_cat_qual[cnt].excld_trans_req_prod_cat_r_id = etp
    .excld_trans_req_prod_cat_r_id, reply->qual[1].excluded_product_cat_qual[cnt].product_cat_cd =
    etp.product_cat_cd, reply->qual[1].excluded_product_cat_qual[cnt].active_ind = etp.active_ind,
    reply->qual[1].excluded_product_cat_qual[cnt].updt_cnt = etp.updt_cnt
   FOOT REPORT
    reply->qual[1].excluded_product_cat_cnt = cnt
   WITH nocounter
  ;end select
 ENDIF
END GO
