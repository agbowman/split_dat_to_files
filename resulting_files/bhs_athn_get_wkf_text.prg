CREATE PROGRAM bhs_athn_get_wkf_text
 RECORD orequest(
   1 query_mode = i4
   1 query_mode_ind = i2
   1 event_id = f8
   1 contributor_system_cd = f8
   1 reference_nbr = vc
   1 dataset_uid = vc
   1 subtable_bit_map = i4
   1 subtable_bit_map_ind = i2
   1 valid_from_dt_tm = dq8
   1 valid_from_dt_tm_ind = i2
   1 decode_flag = i2
   1 ordering_provider_id = f8
   1 action_prsnl_id = f8
   1 event_id_list[*]
     2 event_id = f8
   1 action_type_cd_list[*]
     2 action_type_cd = f8
   1 src_event_id_ind = i2
   1 action_prsnl_group_id = f8
   1 query_mode2 = i4
   1 event_uuid = vc
 )
 RECORD out_rec(
   1 event_id = vc
   1 text = vc
 )
 DECLARE event_id = f8
 SELECT INTO "nl:"
  FROM wkf_workflow ww,
   wkf_component wc,
   ce_result_set_link crsl
  PLAN (ww
   WHERE (ww.encntr_id= $2)
    AND (ww.updt_id= $3)
    AND ww.service_dt_tm = null)
   JOIN (wc
   WHERE wc.wkf_workflow_id=ww.wkf_workflow_id
    AND (wc.component_concept= $4))
   JOIN (crsl
   WHERE crsl.result_set_id=wc.component_entity_id
    AND crsl.valid_until_dt_tm > sysdate
    AND crsl.valid_from_dt_tm < sysdate)
  ORDER BY ww.updt_dt_tm DESC
  HEAD REPORT
   event_id = crsl.event_id
  WITH nocounter, time = 30
 ;end select
 IF (event_id > 0)
  SET orequest->event_id = event_id
  SET orequest->query_mode = 1
  SET orequest->valid_from_dt_tm_ind = 1
  SET orequest->decode_flag = 1
  SET orequest->subtable_bit_map_ind = 1
  SET stat = tdbexecute(3200000,3200200,1000011,"REC",orequest,
   "REC",oreply)
  SET out_rec->event_id = cnvtstring(event_id)
  SET out_rec->text = replace(replace(replace(replace(replace(replace(oreply->rb_list[1].blob_result[
        1].blob[1].blob_contents,"Â "," "),"â€¨","<br>"),"â€¦","&hellip;"),"Â",""),"½",
    "&frac12;"),"â€™","&rsquo;")
 ENDIF
 CALL echojson(out_rec, $1)
END GO
