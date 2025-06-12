CREATE PROGRAM dcp_get_surgery_gen:dba
 RECORD reply(
   1 qual[*]
     2 gendouble = f8
     2 genstring = vc
     2 genind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE ordercount = i2 WITH noconstant(0)
 DECLARE codevalue = f8 WITH noconstant(0.0)
 SET codevalue = uar_get_code_by("MEANING",6000,"SURGERY")
 SELECT INTO "nl:"
  oc.catalog_cd
  FROM order_catalog oc
  WHERE oc.catalog_type_cd=codevalue
   AND oc.active_ind=1
  ORDER BY cnvtupper(oc.description)
  DETAIL
   ordercount += 1
   IF (ordercount > size(reply->qual,5))
    stat = alterlist(reply->qual,(ordercount+ 10))
   ENDIF
   reply->qual[ordercount].gendouble = oc.catalog_cd, reply->qual[ordercount].genstring = oc
   .description
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->qual,ordercount)
 CALL echorecord(reply)
#exit_script
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
END GO
