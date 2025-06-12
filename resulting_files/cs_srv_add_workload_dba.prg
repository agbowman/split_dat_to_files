CREATE PROGRAM cs_srv_add_workload:dba
 CALL echo(concat("CS_SRV_ADD_WORKLOAD - ",format(curdate,"MMM DD, YYYY;;D"),format(curtime3,
    " - HH:MM:SS;;S")))
 IF ((g_srvproperties->logreqrep=1))
  CALL echorecord(request)
 ENDIF
 SET workloadcnt = 0
 SET workloadcnt = size(request->workload_items,5)
 FOR (workloadloop = 1 TO workloadcnt)
   SELECT INTO "nl:"
    y = seq(workload_seq,nextval)"##################;rp0"
    FROM dual
    DETAIL
     request->workload_items[workloadloop].workload_id = cnvtreal(y)
    WITH nocounter
   ;end select
 ENDFOR
 CALL echo("Insert into workload table")
 INSERT  FROM workload w,
   (dummyt d  WITH seq = value(workloadcnt))
  SET w.workload_id = request->workload_items[d.seq].workload_id, w.charge_event_act_id = request->
   workload_items[d.seq].charge_event_act_id, w.charge_event_id = request->workload_items[d.seq].
   charge_event_id,
   w.bill_item_id = request->workload_items[d.seq].bill_item_id, w.org_id = request->workload_items[d
   .seq].org_id, w.institution_cd = request->workload_items[d.seq].institution_cd,
   w.dept_cd = request->workload_items[d.seq].dept_cd, w.section_cd = request->workload_items[d.seq].
   section_cd, w.subsection_cd = request->workload_items[d.seq].subsection_cd,
   w.service_resource_cd = request->workload_items[d.seq].service_resource_cd, w.workload_standard_id
    = request->workload_items[d.seq].workload_standard_id, w.person_id = request->workload_items[d
   .seq].person_id,
   w.encntr_id = request->workload_items[d.seq].encntr_id, w.accession = substring(1,20,trim(request
     ->workload_items[d.seq].accession)), w.projected_ind = request->workload_items[d.seq].
   projected_ind,
   w.wl_code = substring(1,50,trim(request->workload_items[d.seq].wl_code)), w.wl_code_desc =
   substring(1,200,trim(request->workload_items[d.seq].wl_code_desc)), w.units = request->
   workload_items[d.seq].units,
   w.multiplier = request->workload_items[d.seq].multiplier, w.extended_units = request->
   workload_items[d.seq].extended_units, w.pat_loc_cd = request->workload_items[d.seq].pat_loc_cd,
   w.prsnl_id = request->workload_items[d.seq].prsnl_id, w.service_dt_tm =
   IF ((request->workload_items[d.seq].service_dt_tm <= 0)) cnvtdatetime(sysdate)
   ELSE cnvtdatetime(request->workload_items[d.seq].service_dt_tm)
   ENDIF
   , w.projected_dt_tm = cnvtdatetime(request->workload_items[d.seq].projected_dt_tm),
   w.accrued_dt_tm = cnvtdatetime(request->workload_items[d.seq].accrued_dt_tm), w.ord_phys_id =
   request->workload_items[d.seq].ord_phys_id, w.def_bill_item_id = request->workload_items[d.seq].
   def_bill_item_id,
   w.updt_cnt = 0, w.updt_dt_tm = cnvtdatetime(sysdate), w.updt_task = reqinfo->updt_task,
   w.active_ind = 1, w.beg_effective_dt_tm = cnvtdatetime(sysdate), w.updt_id = reqinfo->updt_id,
   w.updt_applctx = reqinfo->updt_applctx, w.qty = request->workload_items[d.seq].quantity, w
   .raw_count = request->workload_items[d.seq].raw_count,
   w.encntr_type_cd = request->workload_items[d.seq].encntr_type_cd, w.position_cd = request->
   workload_items[d.seq].position_cd, w.item_for_count_cd = request->workload_items[d.seq].
   item_for_count_cd,
   w.activity_type_cd = request->workload_items[d.seq].activity_type_cd, w.wl_book_cd = request->
   workload_items[d.seq].wl_book_cd, w.wl_chapter_cd = request->workload_items[d.seq].wl_chapter_cd,
   w.wl_section_cd = request->workload_items[d.seq].wl_section_cd, w.wl_code_sched_cd = request->
   workload_items[d.seq].wl_code_sched_cd, w.med_service_cd = request->workload_items[d.seq].
   med_service_cd,
   w.workload_type_cd = request->workload_items[d.seq].workload_type_cd, w.repeat_ind = request->
   workload_items[d.seq].repeat_ind
  PLAN (d)
   JOIN (w)
  WITH nocounter
 ;end insert
END GO
