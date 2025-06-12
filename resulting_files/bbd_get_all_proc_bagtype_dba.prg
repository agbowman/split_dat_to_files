CREATE PROGRAM bbd_get_all_proc_bagtype:dba
 RECORD reply(
   1 qual[*]
     2 cnt = i4
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
 SELECT INTO "nl:"
  p.*
  FROM procedure_bag_type_r p
  WHERE p.active_ind=1
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].cnt = count
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exitscript
END GO
