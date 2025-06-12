CREATE PROGRAM bbt_get_bb_mod_pool_nbrs:dba
 RECORD reply(
   1 qual[*]
     2 year = i4
     2 sequence = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE stat = i4 WITH noconstant(0)
 DECLARE count = i4 WITH noconstant(0)
 DECLARE errmsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH noconstant(error(errmsg,1))
 SET reply->status_data.status = "F"
 SET modify = predeclare
 SELECT INTO "nl:"
  bmp.year, bmp.seq
  FROM bb_mod_pool_nbr bmp
  WHERE (bmp.isbt_supplier_fin=request->isbt_fin_nbr)
   AND bmp.option_id=0
  HEAD REPORT
   count = 0
  DETAIL
   IF (bmp.year=year(cnvtdatetime(sysdate)))
    count += 1
    IF (count > size(reply->qual,5))
     stat = alterlist(reply->qual,(count+ 9))
    ENDIF
    reply->qual[count].year = bmp.year, reply->qual[count].sequence = (bmp.seq_nbr+ 1)
   ENDIF
  FOOT REPORT
   stat = alterlist(reply->qual,count)
  WITH nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("SELECT","F","BBT_GET_BB_MOD_POOL_NBRS",errmsg)
  GO TO set_status
 ENDIF
 SUBROUTINE (errorhandler(operationname=vc,operationstatus=c1,targetobjectname=vc,targetobjectvalue=
  vc) =null)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt += 1
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = operationname
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
 END ;Subroutine
#set_status
 IF (error_check != 0)
  SET reply->status_data.status = "F"
 ELSEIF (count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
