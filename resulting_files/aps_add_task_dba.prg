CREATE PROGRAM aps_add_task:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "task_assay_cd" = 0.0
  WITH outdev, task_assay_cd
 RECORD req200150(
   1 case_id = f8
   1 spec_qual[*]
     2 case_specimen_id = f8
     2 case_specimen_order_id = f8
     2 case_specimen_tag_cd = f8
     2 case_specimen_status_cd = f8
     2 case_specimen_updt_cnt = i4
     2 case_comment_new = c1
     2 case_comment = vc
     2 case_comment_long_text_id = f8
     2 case_lt_updt_cnt = i4
     2 add_ind = c1
     2 task_add_qual[*]
       3 processing_task_id = f8
       3 order_id = f8
       3 task_assay_cd = f8
       3 catalog_cd = f8
       3 create_inventory_flag = i2
       3 lt_updt_cnt = i4
       3 comments_long_text_id = f8
       3 comment = vc
       3 service_resource_cd = f8
       3 priority_cd = f8
       3 priority_disp = c40
       3 updt_cnt = i4
       3 no_charge_ind = i2
       3 research_account_id = f8
       3 research_account_name = c40
       3 task_type_flag = i2
     2 del_ind = c1
     2 chg_ind = c1
     2 case_specimen_cd = f8
 )
 DECLARE catalog_cd = f8 WITH protect, noconstant(0.0)
 DECLARE case_id = f8 WITH protect, noconstant(0.0)
 DECLARE case_specimen_tag_id = f8 WITH protect, noconstant(0.0)
 DECLARE case_specimen_order_id = f8 WITH protect, noconstant(0.0)
 DECLARE case_specimen_cd = f8 WITH protect, noconstant(0.0)
 DECLARE case_specimen_id = f8 WITH protect, noconstant(cnvtreal(piece(link_misc1,"|",2,"")))
 DECLARE rt_priority_cd = f8 WITH constant(uar_get_code_by("CONCEPTCKI",1905,
   "CERNER!AEBiWAECoVbsboBMn4waeg"))
 DECLARE rt_priority_disp = vc WITH constant(uar_get_code_display(rt_priority_cd))
 SELECT INTO "nl:"
  FROM profile_task_r ptr
  PLAN (ptr
   WHERE (ptr.task_assay_cd= $TASK_ASSAY_CD)
    AND ptr.active_ind=1)
  DETAIL
   catalog_cd = ptr.catalog_cd
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET retval = - (1)
  SET log_message = concat("Unable to find task_assay_cd: ",cnvtstring( $TASK_ASSAY_CD,19))
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM processing_task pt,
   case_specimen cs
  PLAN (pt
   WHERE pt.case_specimen_id=case_specimen_id
    AND pt.create_inventory_flag=4)
   JOIN (cs
   WHERE cs.case_specimen_id=pt.case_specimen_id)
  DETAIL
   case_id = pt.case_id, case_specimen_tag_id = pt.case_specimen_tag_id, case_specimen_order_id = pt
   .order_id,
   case_specimen_cd = cs.specimen_cd
  WITH nocounter
 ;end select
 SET req200150->case_id = case_id
 SET stat = alterlist(req200150->spec_qual,1)
 SET req200150->spec_qual[1].case_specimen_id = case_specimen_id
 SET req200150->spec_qual[1].case_specimen_tag_cd = case_specimen_tag_id
 SET req200150->spec_qual[1].case_specimen_order_id = case_specimen_order_id
 SET req200150->spec_qual[1].case_specimen_cd = case_specimen_cd
 SET req200150->spec_qual[1].add_ind = "Y"
 SET stat = alterlist(req200150->spec_qual[1].task_add_qual,1)
 SET req200150->spec_qual[1].task_add_qual[1].task_assay_cd =  $TASK_ASSAY_CD
 SET req200150->spec_qual[1].task_add_qual[1].catalog_cd = catalog_cd
 SET req200150->spec_qual[1].task_add_qual[1].task_type_flag = 4
 SET req200150->spec_qual[1].task_add_qual[1].priority_cd = rt_priority_cd
 SET req200150->spec_qual[1].task_add_qual[1].priority_disp = rt_priority_disp
 SET req200150->spec_qual[1].task_add_qual[1].processing_task_id = 0
 SET req200150->spec_qual[1].task_add_qual[1].order_id = 0
 SET req200150->spec_qual[1].task_add_qual[1].create_inventory_flag = 0
 SET req200150->spec_qual[1].task_add_qual[1].lt_updt_cnt = 0
 SET req200150->spec_qual[1].task_add_qual[1].updt_cnt = 0
 SET req200150->spec_qual[1].task_add_qual[1].comments_long_text_id = 0
 SET req200150->spec_qual[1].task_add_qual[1].service_resource_cd = 0
 SET req200150->spec_qual[1].task_add_qual[1].no_charge_ind = 0
 SET req200150->spec_qual[1].task_add_qual[1].research_account_id = 0
 SET req200150->spec_qual[1].del_ind = "N"
 SET req200150->spec_qual[1].chg_ind = "N"
 IF (case_specimen_id > 0
  AND case_specimen_tag_id > 0
  AND case_specimen_cd > 0
  AND case_id > 0)
  SET stat = tdbexecute(200046,200378,200150,"REC",req200150,
   "REC",rep200150)
  IF (stat=0)
   SET retval = 100
   SET log_message = concat("Task successfull ordered. processing_task_id: ",trim(cnvtstring(
      rep200150->proc_qual[1].processing_task_id,11)))
   SET log_orderid = rep200150->proc_qual[1].processing_task_id
   SET log_taskassaycd = rep200150->proc_qual[1].task_assay_cd
  ELSE
   SET log_message = "Failed to execute request 200150"
   SET retval = - (1)
  ENDIF
 ELSE
  SET retval = - (1)
  SET log_message = "Unable to find case details"
 ENDIF
#exit_script
 SET log_personid = trigger_personid
 SET log_encntrid = trigger_encntrid
END GO
