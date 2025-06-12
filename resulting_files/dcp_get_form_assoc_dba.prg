CREATE PROGRAM dcp_get_form_assoc:dba
 RECORD reply(
   1 qual[10]
     2 form_association_cd = f8
     2 sequence_nbr = i2
     2 input_form_cd = f8
     2 version_nbr = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET failed = "F"
 SET count1 = 0
 SET reply->status_data.status = "F"
 SELECT
  IF ((request->association_type_flag=1))
   WHERE (request->catalog_cd=fat.catalog_cd)
    AND fat.association_type_flag=1
  ELSEIF ((request->association_type_flag=2))
   WHERE (request->reference_task_id=fat.reference_task_id)
    AND fat.association_type_flag=2
  ELSEIF ((request->association_type_flag=3))
   WHERE (request->order_type_flag=fat.order_type_flag)
    AND fat.association_type_flag=3
  ELSEIF ((request->association_type_flag=4))
   WHERE (request->catalog_cd=fat.catalog_cd)
    AND (request->location_cd=fat.location_cd)
    AND fat.association_type_flag=4
  ELSE
  ENDIF
  INTO "nl:"
  form_association_id
  FROM form_association fat
  DETAIL
   count1 = (count1+ 1)
   IF (count1 > size(reply->qual,5))
    stat = alter(reply->qual,(count1+ 10))
   ENDIF
   reply->qual[count1].form_association_cd = fat.form_association_id, reply->qual[count1].
   sequence_nbr = fat.sequence_nbr, reply->qual[count1].input_form_cd = fat.input_form_cd,
   reply->qual[count1].version_nbr = - (1)
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET stat = alter(reply->qual,count1)
END GO
