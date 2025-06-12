CREATE PROGRAM afc_srv_add_workload:dba
 RECORD reply(
   1 workload_id = f8
 )
 CALL echo("*****PM_HEADER_CCL.inc - 668615****")
 IF ((validate(gen_nbr_error,- (9))=- (9)))
  DECLARE gen_nbr_error = i2 WITH constant(3)
 ENDIF
 IF ((validate(insert_error,- (9))=- (9)))
  DECLARE insert_error = i2 WITH constant(4)
 ENDIF
 IF ((validate(update_error,- (9))=- (9)))
  DECLARE update_error = i2 WITH constant(5)
 ENDIF
 IF ((validate(replace_error,- (9))=- (9)))
  DECLARE replace_error = i2 WITH constant(6)
 ENDIF
 IF ((validate(delete_error,- (9))=- (9)))
  DECLARE delete_error = i2 WITH constant(7)
 ENDIF
 IF ((validate(undelete_error,- (9))=- (9)))
  DECLARE undelete_error = i2 WITH constant(8)
 ENDIF
 IF ((validate(remove_error,- (9))=- (9)))
  DECLARE remove_error = i2 WITH constant(9)
 ENDIF
 IF ((validate(attribute_error,- (9))=- (9)))
  DECLARE attribute_error = i2 WITH constant(10)
 ENDIF
 IF ((validate(lock_error,- (9))=- (9)))
  DECLARE lock_error = i2 WITH constant(11)
 ENDIF
 IF ((validate(none_found,- (9))=- (9)))
  DECLARE none_found = i2 WITH constant(12)
 ENDIF
 IF ((validate(select_error,- (9))=- (9)))
  DECLARE select_error = i2 WITH constant(13)
 ENDIF
 IF ((validate(add_history_error,- (9))=- (9)))
  DECLARE add_history_error = i2 WITH constant(14)
 ENDIF
 IF ((validate(transaction_error,- (9))=- (9)))
  DECLARE transaction_error = i2 WITH constant(15)
 ENDIF
 IF ((validate(none_found_ft,- (9))=- (9)))
  DECLARE none_found_ft = i2 WITH constant(16)
 ENDIF
 IF ((validate(failed,- (9))=- (9)))
  DECLARE failed = i2 WITH noconstant(false)
 ENDIF
 IF (validate(table_name,"ZZZ")="ZZZ")
  DECLARE table_name = vc WITH noconstant("")
  SET table_name = fillstring(50," ")
 ENDIF
 IF (validate(reqinfo->updt_id,999)=999)
  RECORD reqinfo(
    1 updt_id = f8
    1 updt_applctx = f8
    1 updt_task = f8
  )
  SET reqinfo->updt_id = 0
  SET reqinfo->updt_applctx = 0
  SET reqinfo->updt_task = 951020
 ENDIF
 SET blank_date = cnvtdatetime("01-JAN-1800 00:00:00.00")
 SET active_code = 0.0
 SET new_nbr = 0.0
 SELECT INTO "nl:"
  y = seq(workload_seq,nextval)"##################;rp0"
  FROM dual
  DETAIL
   new_nbr = cnvtreal(y),
   CALL echo(build("got new_nbr: ",new_nbr))
  WITH format, counter
 ;end select
 IF (curqual=0)
  SET reply->workload_id = - (2)
  GO TO end_program
 ELSE
  SET reply->workload_id = new_nbr
 ENDIF
 INSERT  FROM workload w
  SET w.workload_id = new_nbr, w.charge_event_act_id =
   IF ((request->charge_event_act_id <= 0)) 0
   ELSE request->charge_event_act_id
   ENDIF
   , w.charge_event_id =
   IF ((request->charge_event_id <= 0)) 0
   ELSE request->charge_event_id
   ENDIF
   ,
   w.parent_workload_id =
   IF ((request->parent_workload_id <= 0)) 0
   ELSE request->parent_workload_id
   ENDIF
   , w.bill_item_id =
   IF ((request->bill_item_id <= 0)) 0
   ELSE request->bill_item_id
   ENDIF
   , w.org_id =
   IF ((request->org_id <= 0)) 0
   ELSE request->org_id
   ENDIF
   ,
   w.dept_cd =
   IF ((request->dept_cd <= 0)) 0
   ELSE request->dept_cd
   ENDIF
   , w.section_cd =
   IF ((request->section_cd <= 0)) 0
   ELSE request->section_cd
   ENDIF
   , w.subsection_cd =
   IF ((request->subsection_cd <= 0)) 0
   ELSE request->subsection_cd
   ENDIF
   ,
   w.service_resource_cd =
   IF ((request->service_resource_cd <= 0)) 0
   ELSE request->service_resource_cd
   ENDIF
   , w.workload_standard_id =
   IF ((request->workload_standard_id <= 0)) 0
   ELSE request->workload_standard_id
   ENDIF
   , w.person_id = request->person_id,
   w.encntr_id = request->encntr_id, w.accession =
   IF ((request->accession='""')) null
   ELSE substring(1,20,trim(request->accession))
   ENDIF
   , w.projected_ind =
   IF ((request->projected_ind_ind=false)) null
   ELSE request->projected_ind
   ENDIF
   ,
   w.wl_code =
   IF ((request->wl_code='""')) null
   ELSE substring(1,50,trim(request->wl_code))
   ENDIF
   , w.wl_code_desc =
   IF ((request->wl_code_desc='""')) null
   ELSE substring(1,200,trim(request->wl_code_desc))
   ENDIF
   , w.units = request->units,
   w.multiplier = request->multiplier, w.extended_units = request->extended_units, w.pat_loc_cd =
   IF ((request->pat_loc_cd <= 0)) 0
   ELSE request->pat_loc_cd
   ENDIF
   ,
   w.prsnl_id = request->prsnl_id, w.service_dt_tm =
   IF ((((request->service_dt_tm <= 0)) OR ((request->service_dt_tm=blank_date))) ) cnvtdatetime(
     sysdate)
   ELSE cnvtdatetime(request->service_dt_tm)
   ENDIF
   , w.projected_dt_tm =
   IF ((((request->projected_dt_tm <= 0)) OR ((request->projected_dt_tm=blank_date))) ) null
   ELSE cnvtdatetime(request->projected_dt_tm)
   ENDIF
   ,
   w.accrued_dt_tm =
   IF ((((request->accrued_dt_tm <= 0)) OR ((request->accrued_dt_tm=blank_date))) ) cnvtdatetime(
     sysdate)
   ELSE cnvtdatetime(request->accrued_dt_tm)
   ENDIF
   , w.ord_phys_id =
   IF ((request->ord_phys_id <= 0)) 0
   ELSE request->ord_phys_id
   ENDIF
   , w.def_bill_item_id =
   IF ((request->def_bill_item_id <= 0)) 0
   ELSE request->def_bill_item_id
   ENDIF
   ,
   w.beg_effective_dt_tm =
   IF ((((request->beg_effective_dt_tm <= 0)) OR ((request->beg_effective_dt_tm=blank_date))) )
    cnvtdatetime(sysdate)
   ELSE cnvtdatetime(request->beg_effective_dt_tm)
   ENDIF
   , w.raw_count =
   IF ((request->raw_count <= 0)) 0
   ELSE request->raw_count
   ENDIF
   , w.qty =
   IF ((request->quantity <= 0)) 0
   ELSE request->quantity
   ENDIF
   ,
   w.active_ind =
   IF ((request->active_ind_ind=false)) true
   ELSE request->active_ind
   ENDIF
   , w.updt_cnt = 0, w.updt_dt_tm = cnvtdatetime(sysdate),
   w.updt_id = reqinfo->updt_id, w.updt_applctx = reqinfo->updt_applctx, w.updt_task = reqinfo->
   updt_task,
   w.position_cd = request->position_cd, w.item_for_count_cd = request->item_for_count_cd, w
   .activity_type_cd = request->activity_type_cd,
   w.encntr_type_cd = request->encntr_type_cd, w.wl_code_sched_cd = request->wl_code_sched_cd, w
   .med_service_cd = request->med_service_cd
  WITH nocounter
 ;end insert
 IF (curqual=0)
  SET request->workload_id = - (3)
 ELSE
  SET reqinfo->commit_ind = true
 ENDIF
#end_program
END GO
