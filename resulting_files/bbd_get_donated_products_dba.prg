CREATE PROGRAM bbd_get_donated_products:dba
 RECORD reply(
   1 donatedlist[*]
     2 product_cd = f8
     2 drawn_dt_tm = dq8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET modify = predeclare
 DECLARE script_name = c24 WITH constant("bbd_get_donated_products")
 DECLARE errmsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH noconstant(error(errmsg,1))
 DECLARE donated_count = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  dp.*, dr.*, pr.*
  FROM bbd_don_product_r dp,
   bbd_donation_results dr,
   product pr
  PLAN (dp
   WHERE (dp.person_id=request->person_id)
    AND dp.active_ind=1)
   JOIN (dr
   WHERE dr.donation_result_id=dp.donation_results_id
    AND dr.active_ind=1)
   JOIN (pr
   WHERE pr.product_id=dp.product_id)
  HEAD REPORT
   donated_count = 0
  DETAIL
   donated_count = (donated_count+ 1)
   IF (mod(donated_count,10)=1)
    stat = alterlist(reply->donatedlist,(donated_count+ 9))
   ENDIF
   reply->donatedlist[donated_count].product_cd = pr.product_cd, reply->donatedlist[donated_count].
   drawn_dt_tm = dr.drawn_dt_tm
  FOOT REPORT
   stat = alterlist(reply->donatedlist,donated_count)
  WITH nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("SELECT","Multiple tables",errmsg)
 ENDIF
 GO TO set_status
 DECLARE errorhandler(operationstatus=c1,targetobjectname=c25,targetobjectvalue=vc) = null
 SUBROUTINE errorhandler(operationstatus,targetobjectname,targetobjectvalue)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt = (error_cnt+ 1)
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = script_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   GO TO exit_script
 END ;Subroutine
#set_status
 IF (donated_count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
