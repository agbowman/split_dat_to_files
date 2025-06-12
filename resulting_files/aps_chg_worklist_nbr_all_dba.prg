CREATE PROGRAM aps_chg_worklist_nbr_all:dba
 RECORD reply(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
   1 exception_reason = c4
   1 new_worklist_nbr = i4
 )
 RECORD temp(
   1 new_worklist_cd = f8
   1 proc_qual[5]
     2 processing_task_id = f8
   1 qual[1]
     2 service_resource_cd = f8
 )
 DECLARE var_field_name = vc WITH protect, noconstant(" ")
 SET var_field_name = "Processing Run Number"
 SET var_field_type = 1
 SET var_field_value = 1
 SET var_updt_cnt = 0
#script
 SET reply->status_data.status = "F"
 SET error_cnt = 0
 SET build_pt_select = fillstring(500," ")
 SET build_pc_select = fillstring(500," ")
 DECLARE code_set = i4 WITH public, noconstant(0)
 DECLARE code_value = f8 WITH public, noconstant(0.0)
 DECLARE cdf_meaning = c12 WITH public, noconstant(fillstring(12," "))
 DECLARE code_cnt = i4 WITH public, noconstant(1)
 DECLARE stat = i4 WITH public, noconstant(0)
 DECLARE dorderedstatuscd = f8 WITH protect, noconstant(0.0)
 SET dorderedstatuscd = 0.0
 SET code_set = 1305
 SET code_value = 0.0
 SET cdf_meaning = "ORDERED     "
 SET stat = uar_get_meaning_by_codeset(code_set,cdf_meaning,code_cnt,code_value)
 SET dorderedstatuscd = code_value
 SET child_cntr = 0
 SELECT INTO "nl:"
  rg.child_service_resource_cd
  FROM resource_group rg
  WHERE (request->service_resource_cd=rg.parent_service_resource_cd)
   AND rg.active_ind=1
   AND rg.beg_effective_dt_tm < cnvtdatetime(curdate,curtime3)
   AND rg.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
  HEAD REPORT
   child_cntr = (child_cntr+ 1), temp->qual[child_cntr].service_resource_cd = request->
   service_resource_cd
  DETAIL
   child_cntr = (child_cntr+ 1)
   IF (child_cntr > size(temp->qual,5))
    stat = alter(temp->qual,(child_cntr+ 4))
   ENDIF
   temp->qual[child_cntr].service_resource_cd = rg.child_service_resource_cd
  FOOT REPORT
   stat = alter(temp->qual,child_cntr)
  WITH nocounter
 ;end select
 IF (child_cntr=0)
  SET temp->qual[1].service_resource_cd = request->service_resource_cd
 ENDIF
 IF (child_cntr > 0)
  FOR (spnnr = 1 TO child_cntr)
    IF (spnnr > 1)
     SET build_pt_select = build(build_pt_select,",",cnvtstring(temp->qual[spnnr].service_resource_cd,
       32,2))
    ELSE
     SET build_pt_select = cnvtstring(temp->qual[spnnr].service_resource_cd,32,2)
    ENDIF
  ENDFOR
  SET build_pt_select = build("pt.service_resource_cd in (",build_pt_select,")")
  SET build_pt_defined = "T"
 ELSE
  IF ((request->service_resource_cd > 0))
   SET build_pt_select = build("pt.service_resource_cd = ",request->service_resource_cd)
   SET build_pt_defined = "T"
  ELSE
   SET build_pt_select = "0 = 0"
   SET build_pt_defined = "F"
  ENDIF
 ENDIF
 IF ((request->task_assay_cd > 0))
  SET build_pt_select = build(build_pt_select," and pt.task_assay_cd = ",request->task_assay_cd)
 ENDIF
 IF (build_pt_defined="T")
  SET build_pt_select = build(build_pt_select," and "," pt.worklist_nbr = 0 ")
 ELSE
  SET build_pt_select = "pt.worklist_nbr = 0"
 ENDIF
 IF ((request->beg_acc > " "))
  IF (build_pt_defined="T")
   SET build_pc_select = "pc.accession_nbr between request->beg_acc and request->end_acc"
   SET build_pc_defined = "T"
  ELSE
   SET build_pc_select = "0 = 0"
   SET build_pc_defined = "F"
  ENDIF
 ELSE
  SET build_pc_select = "0 = 0"
  SET build_pc_defined = "F"
 ENDIF
 EXECUTE sub_chg_worklist_nbr_all parser(trim(build_pc_select)), parser(trim(build_pt_select))
END GO
