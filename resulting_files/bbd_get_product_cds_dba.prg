CREATE PROGRAM bbd_get_product_cds:dba
 RECORD reply(
   1 qual[*]
     2 product_cd = f8
     2 product_disp = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count = 0
 SELECT DISTINCT INTO "nl:"
  pp.product_cd
  FROM donation_procedure d,
   procedure_bag_type_r pb,
   proc_bag_product_r pp
  PLAN (d
   WHERE (d.procedure_cd=request->donation_procedure_cd)
    AND d.active_ind=1)
   JOIN (pb
   WHERE pb.bag_type_cd=d.default_bag_type_cd
    AND pb.procedure_cd=d.procedure_cd
    AND pb.active_ind=1)
   JOIN (pp
   WHERE pp.bag_type_cd=pb.bag_type_cd
    AND pp.procedure_cd=d.procedure_cd
    AND pp.active_ind=1)
  ORDER BY pp.product_cd, 0
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].product_cd = pp
   .product_cd
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exitscript
END GO
