CREATE PROGRAM bbt_solcap_2010h1_bridge:dba
 SET stat = alterlist(reply->solcap,1)
 SET reply->solcap[1].identifier = "2010.1.00091.3"
 FREE SET fac_count
 DECLARE fac_count = i4 WITH noconstant(0)
 FREE SET total_products
 DECLARE total_products = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  products = count(bep.bb_edn_product_id)
  FROM bb_edn_admin bea,
   bb_edn_product bep,
   code_value cv
  PLAN (bea
   WHERE bea.admin_dt_tm BETWEEN cnvtdatetime(request->start_dt_tm) AND cnvtdatetime(request->
    end_dt_tm)
    AND bea.protocol_nbr=5)
   JOIN (bep
   WHERE bep.bb_edn_admin_id=bea.bb_edn_admin_id)
   JOIN (cv
   WHERE cv.code_set=1664
    AND cv.code_value=bep.status_cd
    AND cv.cdf_meaning="TRANSFUSE")
  GROUP BY bea.destination_loc_cd
  DETAIL
   fac_count = (fac_count+ 1)
   IF (mod(fac_count,10)=1)
    stat = alterlist(reply->solcap[1].facility,(fac_count+ 9))
   ENDIF
   reply->solcap[1].facility[fac_count].display = uar_get_code_display(bea.destination_loc_cd), reply
   ->solcap[1].facility[fac_count].value_num = products,
   CALL echo(build(bea.destination_loc_cd)),
   total_products = (products+ total_products)
  FOOT REPORT
   stat = alterlist(reply->solcap[1].facility,fac_count)
 ;end select
 SET reply->solcap[1].degree_of_use_num = total_products WITH nocounter
END GO
