CREATE PROGRAM bbt_get_dest_prod_corr:dba
 RECORD reply(
   1 method_cd = f8
   1 method_cd_disp = vc
   1 manifest_nbr = vc
   1 autoclave_ind = i2
   1 destruction_org_id = f8
   1 updt_cnt = i4
   1 box_nbr = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  d.*
  FROM destruction d
  WHERE (d.product_id=request->product_id)
   AND (d.product_event_id=request->product_event_id)
  HEAD REPORT
   count1 = 0
  DETAIL
   reply->method_cd = d.method_cd, reply->manifest_nbr = d.manifest_nbr, reply->autoclave_ind = d
   .autoclave_ind,
   reply->destruction_org_id = d.destruction_org_id, reply->updt_cnt = d.updt_cnt, reply->box_nbr = d
   .box_nbr
  WITH nocounter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
