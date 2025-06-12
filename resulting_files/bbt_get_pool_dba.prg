CREATE PROGRAM bbt_get_pool:dba
 RECORD reply(
   1 new_product_cd = f8
   1 new_product_disp = c40
   1 prompt_vol_ind = i2
   1 calculate_vol_ind = i2
   1 default_exp_hrs = i4
   1 product_nbr_prefix = c10
   1 generate_prod_nbr_ind = i2
   1 default_supplier_id = f8
   1 require_assign_ind = i2
   1 allow_no_aborh_ind = i2
   1 pool_nbr = i4
   1 year = i4
   1 pooled_updt_cnt = i4
   1 active_ind = i2
   1 updt_cnt = i4
   1 qual[*]
     2 active_ind = i2
     2 product_cd = f8
     2 product_cd_disp = c40
     2 updt_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET err_cnt = 0
 SET prod_cnt = 0
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  p.new_product_cd, p.prompt_vol_ind, p.calculate_vol_ind,
  p.default_exp_hrs, p.product_nbr_prefix, p.generate_prod_nbr_ind,
  p.default_supplier_id, p.require_assign_ind, p.allow_no_aborh_ind,
  p.active_ind, p.updt_cnt, c.active_ind,
  c.product_cd, c.updt_cnt, pp.pool_nbr,
  pp.year, pp.updt_cnt, pp.seq,
  pooled_yn = decode(pp.seq,"Y",p.seq,"N","Z")
  FROM pool_option p,
   component c,
   dummyt d1,
   pooled_product pp
  PLAN (p
   WHERE (request->option_id=p.option_id))
   JOIN (c
   WHERE p.option_id=c.option_id)
   JOIN (d1
   WHERE d1.seq=1)
   JOIN (pp
   WHERE p.option_id=pp.pool_option_id
    AND pp.active_ind=1)
  HEAD REPORT
   err_cnt = 0, prod_cnt = 0
  DETAIL
   reply->new_product_cd = p.new_product_cd, reply->prompt_vol_ind = p.prompt_vol_ind, reply->
   calculate_vol_ind = p.calculate_vol_ind,
   reply->default_exp_hrs = p.default_exp_hrs, reply->product_nbr_prefix = p.product_nbr_prefix,
   reply->generate_prod_nbr_ind = p.generate_prod_nbr_ind,
   reply->default_supplier_id = p.default_supplier_id, reply->require_assign_ind = p
   .require_assign_ind, reply->allow_no_aborh_ind = p.allow_no_aborh_ind,
   reply->active_ind = p.active_ind, reply->updt_cnt = p.updt_cnt
   IF (pooled_yn="Y")
    reply->pooled_updt_cnt = pp.updt_cnt, reply->pool_nbr = pp.pool_nbr, reply->year = pp.year
   ENDIF
   prod_cnt = (prod_cnt+ 1), stat = alterlist(reply->qual,prod_cnt), reply->qual[prod_cnt].active_ind
    = c.active_ind,
   reply->qual[prod_cnt].product_cd = c.product_cd, reply->qual[prod_cnt].updt_cnt = c.updt_cnt
  WITH format, nocounter, outerjoin = d1
 ;end select
 IF (curqual=0)
  SET err_cnt = (err_cnt+ 1)
  SET reply->status_data.subeventstatus[err_cnt].operationname = "select"
  SET reply->status_data.subeventstatus[err_cnt].operationstatus = "F"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectname = "SEQUENCE"
  SET reply->status_data.subeventstatus[err_cnt].targetobjectvalue =
  "unable to return pool option specified"
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
