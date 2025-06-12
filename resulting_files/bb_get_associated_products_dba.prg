CREATE PROGRAM bb_get_associated_products:dba
 RECORD reply(
   1 product_ids[*]
     2 product_id = f8
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
 DECLARE associated_count = i4 WITH noconstant(0)
 DECLARE product_event_cs = i4 WITH constant(1610)
 DECLARE assigned_cdf_mean = c12 WITH constant("1")
 DECLARE assigned_event_cd = f8 WITH noconstant(0.0)
 DECLARE autologous_cdf_mean = c12 WITH constant("10")
 DECLARE autologous_event_cd = f8 WITH noconstant(0.0)
 DECLARE directed_cdf_mean = c12 WITH constant("11")
 DECLARE directed_event_cd = f8 WITH noconstant(0.0)
 DECLARE crossmatch_cdf_mean = c12 WITH constant("3")
 DECLARE crossmatch_event_cd = f8 WITH noconstant(0.0)
 DECLARE script_name = c26 WITH constant("bb_get_associated_products")
 DECLARE uar_error_string = vc WITH noconstant("")
 DECLARE errmsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH noconstant(error(errmsg,1))
 SET assigned_event_cd = uar_get_code_by("MEANING",product_event_cs,nullterm(assigned_cdf_mean))
 SET autologous_event_cd = uar_get_code_by("MEANING",product_event_cs,nullterm(autologous_cdf_mean))
 SET directed_event_cd = uar_get_code_by("MEANING",product_event_cs,nullterm(directed_cdf_mean))
 SET crossmatch_event_cd = uar_get_code_by("MEANING",product_event_cs,nullterm(crossmatch_cdf_mean))
 IF (assigned_event_cd <= 0.0)
  SET uar_error_string = concat("Failed to retrieve Blood Bank event code with meaning of ",trim(
    assigned_cdf_mean),".")
  CALL errorhandler(script_name,"F","uar_get_code_by",uar_error_string)
 ELSEIF (autologous_event_cd <= 0.0)
  SET uar_error_string = concat("Failed to retrieve Blood Bank event code with meaning of ",trim(
    autologous_cdf_mean),".")
  CALL errorhandler(script_name,"F","uar_get_code_by",uar_error_string)
 ELSEIF (directed_event_cd <= 0.0)
  SET uar_error_string = concat("Failed to retrieve Blood Bank event code with meaning of ",trim(
    directed_cdf_mean),".")
  CALL errorhandler(script_name,"F","uar_get_code_by",uar_error_string)
 ELSEIF (crossmatch_event_cd <= 0.0)
  SET uar_error_string = concat("Failed to retrieve Blood Bank event code with meaning of ",trim(
    crossmatch_cdf_mean),".")
  CALL errorhandler(script_name,"F","uar_get_code_by",uar_error_string)
 ENDIF
 SELECT INTO "nl:"
  FROM product_event pe,
   product p
  PLAN (pe
   WHERE (pe.person_id=request->person_id)
    AND (((request->encntr_id > 0.0)
    AND (pe.encntr_id=request->encntr_id)) OR ((request->encntr_id=0.0)))
    AND pe.event_type_cd IN (assigned_event_cd, autologous_event_cd, directed_event_cd,
   crossmatch_event_cd)
    AND pe.active_ind=1)
   JOIN (p
   WHERE p.product_id=pe.product_id
    AND p.locked_ind=0)
  ORDER BY pe.product_id
  HEAD REPORT
   associated_count = 0
  HEAD pe.product_id
   associated_count += 1
   IF (mod(associated_count,10)=1)
    stat = alterlist(reply->product_ids,(associated_count+ 9))
   ENDIF
   reply->product_ids[associated_count].product_id = pe.product_id
  FOOT  pe.product_id
   row + 0
  FOOT REPORT
   stat = alterlist(reply->product_ids,associated_count)
  WITH nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("SELECT","F","BB_ASSOCIATED_EVENT",errmsg)
  GO TO exit_script
 ENDIF
 IF (curqual=0)
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
 IF (associated_count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
