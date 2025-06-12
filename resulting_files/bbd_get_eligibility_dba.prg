CREATE PROGRAM bbd_get_eligibility:dba
 RECORD reply(
   1 eligibilitylist[*]
     2 product_cd = f8
     2 product_disp = c40
     2 product_desc = c60
     2 product_mean = c12
     2 previouslist[*]
       3 product_eligibility_id = f8
       3 previous_product_cd = f8
       3 previous_product_disp = c40
       3 previous_product_desc = c60
       3 previous_product_mean = c12
       3 days_until_eligible = i4
     2 list_ind = i2
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
 DECLARE script_name = c19 WITH constant("bbd_get_eligibility")
 DECLARE errmsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH noconstant(error(errmsg,1))
 DECLARE product_count = i4 WITH noconstant(0)
 DECLARE previous_count = i4 WITH noconstant(0)
 SELECT INTO "nl:"
  pe.*
  FROM bbd_product_eligibility pe
  WHERE pe.product_eligibility_id > 0.0
   AND pe.active_ind=1
  ORDER BY pe.product_cd
  HEAD REPORT
   product_count = 0
  HEAD pe.product_cd
   previous_count = 0, product_count = (product_count+ 1)
   IF (mod(product_count,10)=1)
    stat = alterlist(reply->eligibilitylist,(product_count+ 9))
   ENDIF
   reply->eligibilitylist[product_count].product_cd = pe.product_cd, reply->eligibilitylist[
   product_count].list_ind = 0
  DETAIL
   previous_count = (previous_count+ 1)
   IF (mod(previous_count,10)=1)
    stat = alterlist(reply->eligibilitylist[product_count].previouslist,(previous_count+ 9))
   ENDIF
   reply->eligibilitylist[product_count].previouslist[previous_count].product_eligibility_id = pe
   .product_eligibility_id, reply->eligibilitylist[product_count].previouslist[previous_count].
   previous_product_cd = pe.previous_product_cd, reply->eligibilitylist[product_count].previouslist[
   previous_count].days_until_eligible = pe.days_until_eligible
   IF (pe.list_ind=1)
    IF ((reply->eligibilitylist[product_count].list_ind=0))
     reply->eligibilitylist[product_count].list_ind = 1
    ENDIF
   ENDIF
  FOOT  pe.product_cd
   stat = alterlist(reply->eligibilitylist[product_count].previouslist,previous_count)
  FOOT REPORT
   stat = alterlist(reply->eligibilitylist,product_count)
  WITH nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("SELECT","BBD_PRODUCT_ELIGIBILITY",errmsg)
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
 IF (product_count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
