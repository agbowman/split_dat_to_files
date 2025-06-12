CREATE PROGRAM dcp_add_td_r_afc:dba
 DECLARE code_set = f8 WITH public, noconstant(0.0)
 DECLARE cdf_meaning = vc WITH public, noconstant("")
 DECLARE cnt = i4 WITH public, noconstant(0)
 DECLARE largestchildsize = i4 WITH public, noconstant(0)
 DECLARE task_cnt = i4 WITH public, noconstant(0)
 DECLARE taskidx = i4 WITH public, noconstant(0)
 DECLARE task_assay_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",13016,"TASK ASSAY"))
 DECLARE taskcat_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",13016,"TASKCAT"))
 DECLARE task_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",106,"TASK"))
 RECORD dta_list(
   1 qual[*]
     2 task_assay_cd = f8
     2 description = vc
     2 mnemonic = vc
     2 activity_type_cd = f8
 )
 FREE SET temp_td_list
 RECORD temp_td_list(
   1 nbr_of_recs = i4
   1 qual[*]
     2 reference_task_id = f8
     2 task_description = vc
     2 task_description_key = c50
     2 input_type = i4
     2 dta[*]
       3 task_assay_cd = f8
       3 required_ind = i2
       3 sequence = i4
       3 description = c100
       3 mnemonic = c50
       3 activity_type_cd = f8
 )
 EXECUTE dcp_add_td_r
 FREE SET request
 RECORD request(
   1 nbr_of_recs = i2
   1 qual[*]
     2 action = i2
     2 ext_id = f8
     2 ext_contributor_cd = f8
     2 parent_qual_ind = f8
     2 ext_owner_cd = f8
     2 ext_description = vc
     2 ext_short_desc = c50
     2 build_ind = i2
     2 careset_ind = i2
     2 workload_only_ind = i2
     2 child_qual = i2
     2 price_qual = i2
     2 prices[*]
       3 price_sched_id = f8
       3 price = f8
     2 billcode_qual = i2
     2 billcodes[*]
       3 billcode_sched_cd = f8
       3 billcode = c25
     2 children[*]
       3 ext_id = f8
       3 ext_contributor_cd = f8
       3 ext_description = c100
       3 ext_short_desc = c50
       3 build_ind = i2
       3 ext_owner_cd = f8
 )
 SET task_cnt = size(temp_td_list->qual,5)
 SET stat = alterlist(request->qual,task_cnt)
 SET request->nbr_of_recs = task_cnt
 FOR (task_idx = 1 TO task_cnt)
   SET request->qual[task_idx].child_qual = size(temp_td_list->qual[task_idx].dta,5)
   SET stat = alterlist(request->qual[task_idx].children,request->qual[task_idx].child_qual)
   IF ((request->qual[task_idx].child_qual > largestchildsize))
    SET largestchildsize = request->qual[task_idx].child_qual
   ENDIF
 ENDFOR
 SELECT INTO "nl:"
  d1.seq, d2.seq
  FROM (dummyt d1  WITH seq = value(task_cnt)),
   (dummyt d2  WITH seq = value(largestchildsize)),
   discrete_task_assay dta
  PLAN (d1
   WHERE (request->qual[d1.seq].child_qual > 0))
   JOIN (d2
   WHERE (d2.seq <= request->qual[d1.seq].child_qual))
   JOIN (dta
   WHERE (temp_td_list->qual[d1.seq].dta[d2.seq].task_assay_cd=dta.task_assay_cd))
  ORDER BY d1.seq
  HEAD d1.seq
   request->qual[d1.seq].action = 1, request->qual[d1.seq].ext_id = temp_td_list->qual[d1.seq].
   reference_task_id, request->qual[d1.seq].ext_contributor_cd = taskcat_cd,
   request->qual[d1.seq].parent_qual_ind = 1, request->qual[d1.seq].careset_ind = 0, request->qual[d1
   .seq].ext_owner_cd = task_cd,
   request->qual[d1.seq].ext_description = temp_td_list->qual[d1.seq].task_description, request->
   qual[d1.seq].ext_short_desc = temp_td_list->qual[d1.seq].task_description_key, request->qual[d1
   .seq].child_qual = size(temp_td_list->qual[d1.seq].dta,5)
  DETAIL
   request->qual[d1.seq].children[d2.seq].ext_id = dta.task_assay_cd, request->qual[d1.seq].children[
   d2.seq].ext_contributor_cd = task_assay_cd, request->qual[d1.seq].children[d2.seq].ext_description
    = dta.description,
   request->qual[d1.seq].children[d2.seq].ext_owner_cd = dta.activity_type_cd, request->qual[d1.seq].
   children[d2.seq].ext_short_desc = dta.mnemonic
  WITH nocounter
 ;end select
 EXECUTE afc_add_reference_api
END GO
