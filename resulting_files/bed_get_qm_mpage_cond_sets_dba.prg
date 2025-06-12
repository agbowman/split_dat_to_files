CREATE PROGRAM bed_get_qm_mpage_cond_sets:dba
 FREE SET reply
 RECORD reply(
   1 condition_sets[*]
     2 value = f8
     2 description = vc
     2 meaning = vc
     2 sequence = i4
     2 br_dmart_cat_ind = i2
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 FREE RECORD tmp
 RECORD tmp(
   1 condition_sets[*]
     2 definition = vc
 )
 SET tcnt = 0
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=4002560
    AND cv.active_ind=1)
  DETAIL
   tcnt = (tcnt+ 1), stat = alterlist(reply->condition_sets,tcnt), stat = alterlist(tmp->
    condition_sets,tcnt),
   tmp->condition_sets[tcnt].definition = cv.definition, reply->condition_sets[tcnt].value = cv
   .code_value, reply->condition_sets[tcnt].description = cv.description,
   reply->condition_sets[tcnt].meaning = cv.cdf_meaning, reply->condition_sets[tcnt].sequence = cv
   .collation_seq
  WITH nocounter
 ;end select
 IF (tcnt > 0)
  SELECT INTO "nl:"
   FROM (dummyt d  WITH seq = value(tcnt)),
    br_datamart_category br_dc
   PLAN (d)
    JOIN (br_dc
    WHERE (br_dc.category_mean=tmp->condition_sets[d.seq].definition)
     AND br_dc.category_type_flag IN (0, 1))
   DETAIL
    reply->condition_sets[d.seq].br_dmart_cat_ind = 1
   WITH nocounter
  ;end select
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
