CREATE PROGRAM bb_act_generate_id:dba
 RECORD reply(
   1 generated_id = f8
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
 DECLARE errmsg = c132 WITH noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH noconstant(error(errmsg,1))
 DECLARE seq_error = vc WITH noconstant("")
 IF ((((request->product_seq_ind < 0)) OR ((request->product_seq_ind > 3))) )
  SET seq_error = concat("Invalid sequence indicator.  Unable to generate unique id.")
  CALL errorhandler("F","Invalid sequence",seq_error)
 ENDIF
 SELECT
  IF ((request->product_seq_ind=0))
   seqn = seq(pathnet_seq,nextval)
  ELSEIF ((request->product_seq_ind=1))
   seqn = seq(blood_bank_seq,nextval)
  ELSEIF ((request->product_seq_ind=2))
   seqn = seq(long_data_seq,nextval)
  ELSEIF ((request->product_seq_ind=3))
   seqn = seq(reference_seq,nextval)
  ELSE
  ENDIF
  INTO "nl:"
  FROM dual
  DETAIL
   reply->generated_id = seqn
  WITH format, nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","BB_ACT_GENERATE_ID",errmsg)
  GO TO exit_script
 ENDIF
 GO TO set_status
 SUBROUTINE (errorhandler(operationstatus=c1,targetobjectname=vc,targetobjectvalue=vc) =null)
   DECLARE error_cnt = i2 WITH private, noconstant(0)
   SET error_cnt = size(reply->status_data.subeventstatus,5)
   IF (((error_cnt > 1) OR (error_cnt=1
    AND (reply->status_data.subeventstatus[error_cnt].operationstatus != ""))) )
    SET error_cnt += 1
    SET stat = alter(reply->status_data.subeventstatus,error_cnt)
   ENDIF
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[error_cnt].operationname = "bb_act_generate_id"
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   GO TO exit_script
 END ;Subroutine
#set_status
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
