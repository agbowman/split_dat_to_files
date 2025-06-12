CREATE PROGRAM bed_get_concki_bedrock_orders:dba
 FREE SET reply
 RECORD reply(
   1 orderables[*]
     2 code_value = f8
     2 mnemonic = vc
     2 concept_cki = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET cnt = 0
 DECLARE c_string = vc
 CASE (request->content_ind)
  OF 1:
   SET c_string = concat("c.patient_care_ind = 1")
  OF 2:
   SET c_string = concat("c.laboratory_ind = 1")
  OF 3:
   SET c_string = concat("c.radiology_ind = 1")
  OF 4:
   SET c_string = concat("c.surgery_ind = 1")
  OF 5:
   SET c_string = concat("c.cardiology_ind = 1")
  ELSE
   SET c_string = concat("c.catalog_cd > 0")
 ENDCASE
 SELECT INTO "nl:"
  FROM br_auto_order_catalog c
  PLAN (c
   WHERE parser(c_string))
  HEAD c.catalog_cd
   cnt = (cnt+ 1), stat = alterlist(reply->orderables,cnt), reply->orderables[cnt].code_value = c
   .catalog_cd,
   reply->orderables[cnt].mnemonic = c.primary_mnemonic, reply->orderables[cnt].concept_cki = c
   .concept_cki
  WITH nocounter, skipbedrock = 1
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
