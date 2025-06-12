CREATE PROGRAM cdm_call_cclinsert:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET errormsg = fillstring(255," ")
 SET error_check = error(errormsg,1)
 SET reply->status_data.status = "F"
 SET afdnumber = request->afdnumber
 IF ((request->ostype="VMS"))
  SET executeline = concat("@cer_proc:processafd -number ",trim(afdnumber))
 ELSE
  SET executeline = concat("$cer_proc/processafd -number ",trim(afdnumber))
 ENDIF
 SET varlen = size(trim(executeline))
 SET status = 0
 CALL dcl(executeline,varlen,status)
 SET afdname = concat("dicafd",format(afdnumber,"######;P0"),".dat")
 EXECUTE cclafdimport value(afdname)
 SET fname = fillstring(50," ")
 SET env_name = logical("ENVIRONMENT")
#exit_script
 SET error_check = error(errormsg,0)
 IF (error_check=0)
  SET reply->status_data.status = "S"
 ENDIF
END GO
