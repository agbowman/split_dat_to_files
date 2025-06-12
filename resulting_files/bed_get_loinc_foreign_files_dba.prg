CREATE PROGRAM bed_get_loinc_foreign_files:dba
 SET modify = predeclare
 FREE SET reply
 RECORD reply(
   1 foreign_files[*]
     2 source_identifier = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE count = i4 WITH public, noconstant(0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE error_check = i4 WITH protect, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 SET reply->status_data.status = "F"
 SET count = 0
 SELECT INTO "nl:"
  FROM br_dta_loinc bdl
  WHERE (bdl.wizard_mean_txt=request->wizard_mean)
  ORDER BY bdl.source_identifier_name
  HEAD bdl.source_identifier_name
   count = (count+ 1)
   IF (mod(count,10)=1)
    stat = alterlist(reply->foreign_files,(count+ 9))
   ENDIF
   reply->foreign_files[count].source_identifier = bdl.source_identifier_name
  DETAIL
   row + 0
  FOOT  bdl.source_identifier_name
   row + 0
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->foreign_files,count)
#exit_script
 SET error_check = error(serrormsg,0)
 IF (error_check != 0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
 ELSEIF (count > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
END GO
