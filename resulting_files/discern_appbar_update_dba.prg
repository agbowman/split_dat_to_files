CREATE PROGRAM discern_appbar_update:dba
 DECLARE errmsg = c132 WITH protect
 DECLARE errcode = i4 WITH protect, noconstant(0)
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 SET readme_data->status = "F"
 SET readme_data->message = "Readme failure.  Starting Discern Appbar update ."
 SET errmsg = fillstring(132," ")
 EXECUTE dm_ocd_upd_atr "APPLICATION", 3050000
 SET errcode = error(errmsg,0)
 CALL checkerror(errcode,errmsg,"Error updating app. Visual Explorer ")
 EXECUTE dm_ocd_upd_atr "APPLICATION", 3070000
 SET errcode = error(errmsg,0)
 CALL checkerror(errcode,errmsg,"Error updating app. Explorer Menu ")
 EXECUTE dm_ocd_upd_atr "APPLICATION", 3030000
 SET errcode = error(errmsg,0)
 CALL checkerror(errcode,errmsg,"Error updating app. Discern Expert ")
 EXECUTE dm_ocd_upd_atr "APPLICATION", 3001000
 SET errcode = error(errmsg,0)
 CALL checkerror(errcode,errmsg,"Error updating app. Discern Launch ")
 EXECUTE dm_ocd_upd_atr "REQUEST", 3000016
 SET errcode = error(errmsg,0)
 CALL checkerror(errcode,errmsg,"Error updating request EKS_GET_TABLES ")
 EXECUTE dm_ocd_upd_atr "REQUEST", 3000017
 SET errcode = error(errmsg,0)
 CALL checkerror(errcode,errmsg,"Error updating request EKS_GET_TABLES_FLDS ")
 EXECUTE dm_ocd_upd_atr "APPLICATION", 950001
 SET errcode = error(errmsg,0)
 CALL checkerror(errcode,errmsg,"Error updating app. Discern Analytics ")
 EXECUTE dm_ocd_upd_atr "APPLICATION", 956100
 SET errcode = error(errmsg,0)
 CALL checkerror(errcode,errmsg,"Error updating app. Discern Analytics Administrator ")
 EXECUTE dm_ocd_upd_atr "APPLICATION", 3010000
 SET errcode = error(errmsg,0)
 CALL checkerror(errcode,errmsg,"Error updating app. Discern Visual Developer ")
 SET readme_data->message = "Discern Appbar update readme complete..."
 SET readme_data->status = "S"
 GO TO end_program
 SUBROUTINE (checkerror(icode=i4,smsg=c132,sexecuting=vc) =null)
   IF (icode > 0)
    ROLLBACK
    SET readme_data->message = concat(sexecuting,smsg)
    GO TO end_program
   ENDIF
 END ;Subroutine
#end_program
 EXECUTE dm_readme_status
 CALL echorecord(readme_data)
END GO
