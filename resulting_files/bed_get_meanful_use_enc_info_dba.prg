CREATE PROGRAM bed_get_meanful_use_enc_info:dba
 FREE SET reply
 RECORD reply(
   1 encounter_types[*]
     2 code_value = f8
     2 display = vc
     2 mean = vc
   1 encounter_relations[*]
     2 code_value = f8
     2 display = vc
     2 mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET ecnt = 0
 SELECT INTO "nl:"
  FROM br_name_value b,
   code_value cv
  PLAN (b
   WHERE b.br_nv_key1="MEANFULUSEENCTYPE")
   JOIN (cv
   WHERE cv.code_value=cnvtreal(b.br_value)
    AND cv.active_ind=1)
  DETAIL
   ecnt = (ecnt+ 1), stat = alterlist(reply->encounter_types,ecnt), reply->encounter_types[ecnt].
   code_value = cv.code_value,
   reply->encounter_types[ecnt].display = cv.display, reply->encounter_types[ecnt].mean = cv
   .cdf_meaning
  WITH nocounter
 ;end select
 SET ecnt = 0
 SELECT INTO "nl:"
  FROM br_name_value b,
   code_value cv
  PLAN (b
   WHERE b.br_nv_key1="MEANFULUSEENCRELTN")
   JOIN (cv
   WHERE cv.code_value=cnvtreal(b.br_value)
    AND cv.active_ind=1)
  DETAIL
   ecnt = (ecnt+ 1), stat = alterlist(reply->encounter_relations,ecnt), reply->encounter_relations[
   ecnt].code_value = cv.code_value,
   reply->encounter_relations[ecnt].display = cv.display, reply->encounter_relations[ecnt].mean = cv
   .cdf_meaning
  WITH nocounter
 ;end select
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
