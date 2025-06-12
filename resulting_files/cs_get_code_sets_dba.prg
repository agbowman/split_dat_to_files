CREATE PROGRAM cs_get_code_sets:dba
 RECORD reply(
   1 codeset[500]
     2 code_set = i4
     2 display = vc
     2 display_key = vc
     2 description = vc
     2 definition = vc
     2 table_name = vc
     2 contributor = vc
     2 owner_module = vc
     2 cache_ind = i2
     2 extension_ind = i2
     2 add_access_ind = i2
     2 chg_access_ind = i2
     2 del_access_ind = i2
     2 inq_access_ind = i2
     2 domain_qualifier_ind = i2
     2 domain_code_set = i4
     2 display_dup_ind = i2
     2 display_key_dup_ind = i2
     2 cdf_meaning_dup_ind = i2
     2 active_ind_dup_ind = i2
     2 updt_dt_tm = dq8
     2 updt_id = f8
     2 updt_cnt = i4
     2 updt_task = i4
     2 code_set_hits = i4
     2 code_values_cnt = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET count1 = 0
 SELECT INTO "nl:"
  c.code_set, c.display, c.display_key,
  c.description, c.definition, c.table_name,
  c.contributor, c.owner_module, c.cache_ind,
  c.extension_ind, c.add_access_ind, c.chg_access_ind,
  c.del_access_ind, c.inq_access_ind, c.domain_qualifier_ind,
  c.domain_code_set, c.display_dup_ind, c.display_key_dup_ind,
  c.cdf_meaning_dup_ind, c.active_ind_dup_ind, c.updt_dt_tm,
  c.updt_id, c.updt_cnt, c.updt_task,
  c.code_set_hits, c.code_values_cnt
  FROM code_value_set c
  WHERE c.code_set > 0
  HEAD REPORT
   count1 = 0
  HEAD c.code_set
   count1 = (count1+ 1)
   IF (count1 > 500)
    IF (mod(count1,50)=1)
     stat = alter(reply->codeset,(count1+ 50))
    ENDIF
   ENDIF
   reply->codeset[count1].code_set = c.code_set, reply->codeset[count1].display = c.display, reply->
   codeset[count1].display_key = cnvtupper(cnvtalphanum(c.display_key)),
   reply->codeset[count1].description = c.description, reply->codeset[count1].definition = c
   .definition, reply->codeset[count1].table_name = c.table_name,
   reply->codeset[count1].contributor = c.contributor, reply->codeset[count1].owner_module = c
   .owner_module, reply->codeset[count1].cache_ind = c.cache_ind,
   reply->codeset[count1].extension_ind = c.extension_ind, reply->codeset[count1].add_access_ind = c
   .add_access_ind, reply->codeset[count1].chg_access_ind = c.chg_access_ind,
   reply->codeset[count1].del_access_ind = c.del_access_ind, reply->codeset[count1].inq_access_ind =
   c.inq_access_ind, reply->codeset[count1].domain_qualifier_ind = c.domain_qualifier_ind,
   reply->codeset[count1].domain_code_set = c.domain_code_set, reply->codeset[count1].display_dup_ind
    = c.display_dup_ind, reply->codeset[count1].display_key_dup_ind = c.display_key_dup_ind,
   reply->codeset[count1].cdf_meaning_dup_ind = c.cdf_meaning_dup_ind, reply->codeset[count1].
   active_ind_dup_ind = c.active_ind_dup_ind, reply->codeset[count1].updt_dt_tm = c.updt_dt_tm,
   reply->codeset[count1].updt_id = c.updt_id, reply->codeset[count1].updt_cnt = c.updt_cnt, reply->
   codeset[count1].updt_task = c.updt_task,
   reply->codeset[count1].code_set_hits = c.code_set_hits, reply->codeset[count1].code_values_cnt = c
   .code_values_cnt
  WITH nocounter
 ;end select
 IF (count1 != 0)
  SET stat = alter(reply->codeset,count1)
  SET reply->status_data.status = "S"
 ENDIF
END GO
