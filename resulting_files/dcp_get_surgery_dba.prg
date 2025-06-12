CREATE PROGRAM dcp_get_surgery:dba
 RECORD reply(
   1 orders[*]
     2 catalog_type_cd = f8
     2 description = vc
     2 catalog_cd = f8
     2 active_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET orders_cnt = 0
 SET surgery = 0.0
 SET failed = "F"
 SELECT INTO "nl:"
  c.code_value
  FROM code_value c
  WHERE c.code_set=6000
   AND c.cdf_meaning="SURGERY"
  DETAIL
   surgery = c.code_value
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  oc.catalog_cd
  FROM order_catalog oc
  WHERE oc.catalog_type_cd=surgery
  DETAIL
   orders_cnt = (orders_cnt+ 1)
   IF (orders_cnt > size(reply->orders,5))
    stat = alterlist(reply->orders,(orders_cnt+ 10))
   ENDIF
   reply->orders[orders_cnt].catalog_type_cd = oc.catalog_type_cd, reply->orders[orders_cnt].
   description = oc.description, reply->orders[orders_cnt].catalog_cd = oc.catalog_cd,
   reply->orders[orders_cnt].active_ind = oc.active_ind
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->orders,orders_cnt)
 CALL echo(build("The orders count is: ",orders_cnt))
#exit_script
 IF (failed="T")
  SET reply->status_data.status = "F"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
