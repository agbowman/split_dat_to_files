CREATE PROGRAM bbd_get_init_product_state:dba
 RECORD reply(
   1 qual[*]
     2 initial_product_state_id = f8
     2 state_cd = f8
     2 state_cd_disp = vc
     2 updt_cnt = i4
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
  i.*
  FROM initial_product_state i
  WHERE (i.procedure_cd=request->procedure_cd)
   AND (i.outcome_cd=request->outcome_cd)
   AND i.active_ind=1
  DETAIL
   count = (count+ 1), stat = alterlist(reply->qual,count), reply->qual[count].
   initial_product_state_id = i.initial_product_state_id,
   reply->qual[count].state_cd = i.state_cd, reply->qual[count].updt_cnt = i.updt_cnt
  WITH counter
 ;end select
 IF (curqual != 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exitscript
END GO
