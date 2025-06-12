CREATE PROGRAM bbt_solcap_2010h1_isbtrecon
 DECLARE pool_event_cd = f8 WITH noconstant(0.0)
 SET pool_event_cd = uar_get_code_by("MEANING",1610,"18")
 DECLARE products = i4 WITH noconstant(0)
 DECLARE option_count = i4 WITH noconstant(0)
 SET stat = alterlist(reply->solcap,1)
 SET stat = alterlist(reply->solcap[1].other,1)
 SET reply->solcap[1].identifier = "2010.1.00091.7"
 SELECT INTO "nl:"
  FROM product_event pe,
   product p,
   bb_mod_option bmo
  PLAN (pe
   WHERE pe.event_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    end_dt_tm)
    AND pe.event_type_cd=pool_event_cd)
   JOIN (p
   WHERE p.product_id=pe.product_id)
   JOIN (bmo
   WHERE bmo.option_id=p.pool_option_id
    AND bmo.recon_rbc_ind=1)
  ORDER BY bmo.option_id
  HEAD REPORT
   reply->solcap[1].other[1].category_name = "Reconstitution Options", option_count = 0
  HEAD bmo.option_id
   option_count = (option_count+ 1)
   IF (mod(option_count,10)=1)
    stat = alterlist(reply->solcap[1].other[1].value,(option_count+ 9))
   ENDIF
   reply->solcap[1].other[1].value[option_count].display = bmo.display, products = 0
  DETAIL
   products = (products+ 1)
  FOOT  bmo.option_id
   reply->solcap[1].other[1].value[option_count].value_num = products
  FOOT REPORT
   stat = alterlist(reply->solcap[1].other[1].value,option_count), reply->solcap[1].degree_of_use_num
    = count(p.product_id)
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  users = count(DISTINCT pe.event_prsnl_id)
  FROM product_event pe,
   product p,
   bb_mod_option bmo
  PLAN (pe
   WHERE pe.event_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    end_dt_tm)
    AND pe.event_type_cd=pool_event_cd)
   JOIN (p
   WHERE p.product_id=pe.product_id)
   JOIN (bmo
   WHERE bmo.option_id=p.pool_option_id
    AND bmo.recon_rbc_ind=1)
  FOOT REPORT
   reply->solcap[1].distinct_user_count = users
  WITH nocounter
 ;end select
END GO
