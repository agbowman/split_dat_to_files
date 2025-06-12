CREATE PROGRAM bb_get_label_params:dba
 RECORD reply(
   1 param_list[*]
     2 label_param_id = f8
     2 option_id = f8
     2 orig_product_cd = f8
     2 orig_product_disp = c40
     2 new_product_cd = f8
     2 new_product_disp = c40
     2 label_type_cd = f8
     2 label_type_disp = c40
     2 label_type_desc = c60
     2 label_type_mean = c12
     2 print_ind = i2
     2 supplier_ind = i2
     2 licensed_supplier_ind = i2
     2 licensed_modifier_ind = i2
     2 new_product_ind = i2
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
 SET modify = predeclare
 DECLARE script_name = c19 WITH constant("bb_get_label_params")
 DECLARE errmsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE error_check = i2 WITH protect, noconstant(error(errmsg,1))
 DECLARE uar_error = vc WITH protect, noconstant("")
 DECLARE param_count = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 SELECT
  IF ((request->option_id > 0.0))
   PLAN (bilp
    WHERE (bilp.option_id=request->option_id))
  ELSE
   PLAN (bilp
    WHERE bilp.option_id > 0.0)
  ENDIF
  INTO "nl:"
  bilp.*
  FROM bb_isbt_label_param bilp
  HEAD REPORT
   param_count = 0
  DETAIL
   param_count += 1
   IF (mod(param_count,10)=1)
    stat = alterlist(reply->param_list,(param_count+ 9))
   ENDIF
   reply->param_list[param_count].label_param_id = bilp.bb_isbt_label_param_id, reply->param_list[
   param_count].option_id = bilp.option_id, reply->param_list[param_count].orig_product_cd = bilp
   .orig_product_cd,
   reply->param_list[param_count].new_product_cd = bilp.new_product_cd, reply->param_list[param_count
   ].label_type_cd = bilp.label_type_cd, reply->param_list[param_count].print_ind = bilp.print_ind,
   reply->param_list[param_count].supplier_ind = bilp.supplier_ind, reply->param_list[param_count].
   licensed_supplier_ind = bilp.licensed_supplier_ind, reply->param_list[param_count].
   licensed_modifier_ind = bilp.licensed_modifier_ind,
   reply->param_list[param_count].new_product_ind = bilp.new_product_ind, reply->param_list[
   param_count].updt_cnt = bilp.updt_cnt
  FOOT REPORT
   stat = alterlist(reply->param_list,param_count)
  WITH nocounter
 ;end select
 SET error_check = error(errmsg,0)
 IF (error_check != 0)
  CALL errorhandler("F","Select ISBT label params",errmsg)
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
   SET reply->status_data.subeventstatus[error_cnt].operationname = script_name
   SET reply->status_data.subeventstatus[error_cnt].operationstatus = operationstatus
   SET reply->status_data.subeventstatus[error_cnt].targetobjectname = targetobjectname
   SET reply->status_data.subeventstatus[error_cnt].targetobjectvalue = targetobjectvalue
   GO TO exit_script
 END ;Subroutine
#set_status
 IF (param_count=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
END GO
