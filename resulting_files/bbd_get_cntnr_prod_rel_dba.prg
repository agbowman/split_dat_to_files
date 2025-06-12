CREATE PROGRAM bbd_get_cntnr_prod_rel:dba
 RECORD reply(
   1 container_type[*]
     2 container_type_cd = f8
     2 container_type_disp = c40
     2 condition[*]
       3 condition_cd = f8
       3 condition_disp = c40
       3 product[*]
         4 product_cd = f8
         4 product_disp = c40
         4 quantity = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 sourceobjectname = c30
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c30
       3 targetobjectvalue = vc
       3 sourceobjectqual = i4
 )
 SET contcount = 0
 SET condcount = 0
 SET prodcount = 0
 SELECT INTO "nl:"
  cc.container_type_cd, cc.condition_cd, cp.product_cd,
  cp.quantity, cp.volume, cp.unit_of_meas_cd
  FROM container_condition_r cc,
   contnr_type_prod_r cp
  PLAN (cc
   WHERE cc.active_ind=1)
   JOIN (cp
   WHERE cp.container_condition_id=cc.container_condition_id
    AND cp.active_ind=1)
  ORDER BY cc.container_type_cd, cc.condition_cd
  HEAD cc.container_type_cd
   IF (cc.container_type_cd > 0.0)
    contcount = (contcount+ 1), stat = alterlist(reply->container_type,contcount), reply->
    container_type[contcount].container_type_cd = cc.container_type_cd,
    condcount = 0
   ENDIF
  HEAD cc.condition_cd
   IF (cc.condition_cd > 0.0)
    condcount = (condcount+ 1), stat = alterlist(reply->container_type[contcount].condition,condcount
     ), reply->container_type[contcount].condition[condcount].condition_cd = cc.condition_cd,
    prodcount = 0
   ENDIF
  DETAIL
   IF (cp.product_cd > 0.0)
    prodcount = (prodcount+ 1), stat = alterlist(reply->container_type[contcount].condition[condcount
     ].product,prodcount), reply->container_type[contcount].condition[condcount].product[prodcount].
    product_cd = cp.product_cd,
    reply->container_type[contcount].condition[condcount].product[prodcount].quantity = cp.quantity
   ENDIF
  FOOT  cc.condition_cd
   row + 1
  FOOT  cc.container_type_cd
   row + 1
  WITH nocounter
 ;end select
#exit_script
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
