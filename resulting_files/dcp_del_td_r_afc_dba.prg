CREATE PROGRAM dcp_del_td_r_afc:dba
 DECLARE task_assay_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",13016,"TASK ASSAY"))
 DECLARE taskcat_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",13016,"TASKCAT"))
 DECLARE task_cd = f8 WITH public, noconstant(uar_get_code_by("MEANING",106,"TASK"))
 FREE SET request
 RECORD request(
   1 nbr_of_recs = i2
   1 qual[1]
     2 action = i2
     2 ext_id = f8
     2 ext_contributor_cd = f8
     2 parent_qual_ind = f8
     2 ext_owner_cd = f8
     2 ext_description = c100
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
 SET request->nbr_of_recs = 1
 SET request->qual[1].action = 1
 SET request->qual[1].ext_id = temp_reference_task_id
 SET request->qual[1].ext_contributor_cd = taskcat_cd
 SET request->qual[1].parent_qual_ind = 1
 SET request->qual[1].careset_ind = 0
 SET request->qual[1].ext_owner_cd = task_cd
 SET request->qual[1].ext_description = ""
 SET request->qual[1].ext_short_desc = ""
 SET request->qual[1].price_qual = 0
 SET request->qual[1].billcode_qual = 0
 SET stat = alterlist(request->qual[1].children,1)
 SET request->qual[1].child_qual = 1
 SET request->qual[1].children[1].ext_id = 0
 SET request->qual[1].children[1].ext_contributor_cd = task_assay_cd
 EXECUTE dcp_del_td_r
 EXECUTE afc_add_reference_api
END GO
