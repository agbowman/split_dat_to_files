CREATE PROGRAM ce_ins_code_value_alias:dba
 DECLARE error_msg = vc WITH protect, noconstant("")
 SET error_code = 0
 INSERT  FROM code_value_alias cva,
   (dummyt d  WITH seq = value(size(request->request_list,5)))
  SET cva.code_set = request->request_list[d.seq].code_set, cva.contributor_source_cd = request->
   request_list[d.seq].contributor_source_cd, cva.alias = trim(request->request_list[d.seq].alias),
   cva.code_value = request->request_list[d.seq].code_value, cva.primary_ind = request->request_list[
   d.seq].primary_ind, cva.updt_dt_tm = cnvtdatetimeutc(request->request_list[d.seq].updt_dt_tm),
   cva.updt_id = request->request_list[d.seq].updt_id, cva.updt_task = request->request_list[d.seq].
   updt_task, cva.updt_cnt = request->request_list[d.seq].updt_cnt,
   cva.updt_applctx = request->request_list[d.seq].updt_applctx, cva.alias_type_meaning = cnvtupper(
    trim(request->request_list[d.seq].alias_type_meaning))
  PLAN (d)
   JOIN (cva)
  WITH counter
 ;end insert
 SET error_code = error(error_msg,0)
 SET reply->num_inserted = curqual
 SET reply->error_code = error_code
 SET reply->error_msg = error_msg
END GO
