CREATE PROGRAM bed_get_bb_mdia_models:dba
 FREE SET reply
 RECORD reply(
   1 existing_models[*]
     2 code_value = f8
     2 display = vc
     2 instrument_ind = i2
   1 proposed_models[*]
     2 br_bb_model_id = f8
     2 model_name = vc
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
 SET pcnt = 0
 SELECT INTO "nl:"
  FROM code_value c
  PLAN (c
   WHERE c.code_set=73
    AND c.cdf_meaning="BLOODBANK"
    AND c.active_ind=1)
  ORDER BY c.display
  DETAIL
   ecnt = (ecnt+ 1), stat = alterlist(reply->existing_models,ecnt), reply->existing_models[ecnt].
   code_value = c.code_value,
   reply->existing_models[ecnt].display = c.display
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM br_bb_model b
  PLAN (b
   WHERE b.model_cd=0)
  ORDER BY b.model_name
  DETAIL
   pcnt = (pcnt+ 1), stat = alterlist(reply->proposed_models,pcnt), reply->proposed_models[pcnt].
   br_bb_model_id = b.br_bb_model_id,
   reply->proposed_models[pcnt].model_name = b.model_name
  WITH nocounter
 ;end select
 IF (ecnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(ecnt)),
    code_value_group g
   PLAN (d)
    JOIN (g
    WHERE (g.parent_code_value=reply->existing_models[d.seq].code_value)
     AND g.code_set=221)
   ORDER BY d.seq
   HEAD d.seq
    reply->existing_models[d.seq].instrument_ind = 1
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
