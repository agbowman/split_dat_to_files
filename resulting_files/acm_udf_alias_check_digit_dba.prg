CREATE PROGRAM acm_udf_alias_check_digit:dba
 FREE RECORD reply
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 action_type = vc
   1 valid_ind = i2
   1 next_alias = vc
 )
 DECLARE next_subeventstatus(null) = null
 DECLARE stx1 = i4 WITH private, noconstant(0)
 SET user_defined_script_name = trim(request->user_defined_script_name,3)
 SET reply->status_data.status = "F"
 IF (size(user_defined_script_name) > 0)
  FREE SET pm_check_digit
  RECORD pm_check_digit(
    1 old_alias = vc
    1 new_alias = vc
    1 check = i2
    1 valid = i2
  )
  CASE (cnvtupper(trim(request->action_type,3)))
   OF "VALIDATE":
    IF ((request->alias > " "))
     SET pm_check_digit->old_alias = request->alias
     SET pm_check_digit->new_alias = request->alias
     SET pm_check_digit->check = 1
     EXECUTE value(user_defined_script_name)
     IF ((reply->status_data.status="S"))
      SET reply->action_type = "VALIDATE"
      IF (pm_check_digit->valid)
       SET reply->valid_ind = 1
      ENDIF
     ELSE
      SET reply->status_data.status = "F"
      CALL add_subeventstatus("VALIDATE","Validation of alias returned an error.")
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     CALL add_subeventstatus("VALIDATE","Alias not provided for validation.")
    ENDIF
   OF "GENERATE":
    IF ((request->alias > " "))
     SET pm_check_digit->old_alias = request->alias
     EXECUTE value(user_defined_script_name)
     IF ((reply->status_data.status="S"))
      SET reply->next_alias = pm_check_digit->new_alias
      SET reply->action_type = "GENERATE"
     ELSE
      SET reply->status_data.status = "F"
      CALL add_subeventstatus("GENERATE","Generation of alias returned an error.")
     ENDIF
    ELSE
     SET reply->status_data.status = "F"
     CALL add_subeventstatus("GENERATE","Alias not provided for check digit generation.")
    ENDIF
   ELSE
    SET reply->status_data.status = "F"
    CALL add_subeventstatus("INVALILD ACTION","Action passed in is invalid.")
  ENDCASE
 ELSE
  SET reply->status_data.status = "F"
  CALL add_subeventstatus("NO USERDEFINED SCRIPT NAME","User defined script name not provided.")
 ENDIF
 SUBROUTINE (add_subeventstatus(s_oname=vc,s_tvalue=vc) =null)
   SET stx1 = size(reply->status_data.subeventstatus,5)
   IF ((((reply->status_data.subeventstatus[stx1].operationname > " ")) OR ((((reply->status_data.
   subeventstatus[stx1].operationstatus > " ")) OR ((((reply->status_data.subeventstatus[stx1].
   targetobjectname > " ")) OR ((reply->status_data.subeventstatus[stx1].targetobjectvalue > " ")))
   )) )) )
    SET stx1 += 1
    CALL alter(reply->status_data.subeventstatus,stx1)
   ENDIF
   SET reply->status_data.subeventstatus[stx1].operationname = s_oname
   SET reply->status_data.subeventstatus[stx1].operationstatus = "F"
   SET reply->status_data.subeventstatus[stx1].targetobjectname = "acm_udf_alias_check_digit"
   SET reply->status_data.subeventstatus[stx1].targetobjectvalue = s_tvalue
 END ;Subroutine
END GO
