CREATE PROGRAM bb_ref_get_tags_labels:dba
 RECORD reply(
   1 print_component_tag_ind = i2
   1 print_crossmatch_tag_ind = i2
   1 print_emergency_tag_ind = i2
   1 print_pilot_label_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE d1662cd = f8
 SET serrormsg = fillstring(255," ")
 SET serror_check = error(serrormsg,1)
 SET reply->status_data.status = "F"
 SET stat = uar_get_meaning_by_codeset(1662,request->cdf_meaning,1,d1662cd)
 IF (d1662cd=0)
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "Code lookup in codeset 1662 failed"
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  cve.*
  FROM code_value_extension cve
  WHERE cve.code_value=d1662cd
  DETAIL
   CASE (trim(cve.field_name))
    OF "Component Tag":
     IF (trim(cve.field_value)="1")
      reply->print_component_tag_ind = 1
     ELSE
      reply->print_component_tag_ind = 0
     ENDIF
    OF "Crossmatch Tag":
     IF (trim(cve.field_value)="1")
      reply->print_crossmatch_tag_ind = 1
     ELSE
      reply->print_crossmatch_tag_ind = 0
     ENDIF
    OF "Emergency Tag":
     IF (trim(cve.field_value)="1")
      reply->print_emergency_tag_ind = 1
     ELSE
      reply->print_emergency_tag_ind = 0
     ENDIF
    OF "Pilot Label":
     IF (trim(cve.field_value)="1")
      reply->print_pilot_label_ind = 1
     ELSE
      reply->print_pilot_label_ind = 0
     ENDIF
   ENDCASE
  WITH nocounter
 ;end select
 SET serror_check = error(serrormsg,0)
 IF (serror_check=0)
  IF (curqual > 0)
   SET reply->status_data.status = "S"
  ELSE
   SET reply->status_data.status = "Z"
  ENDIF
 ELSE
  SET reply->status_data.status = "F"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrormsg
 ENDIF
#exit_script
END GO
