CREATE PROGRAM dcp_load_dta_for_afc
 FREE SET request
 RECORD request(
   1 nbr_of_recs = i2
   1 qual[*]
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
 EXECUTE cclseclogin
 DECLARE cdfmeaning_criticalcare = f8 WITH constant(uar_get_code_by("MEANING",106,"CRITICALCARE"))
 IF ((cdfmeaning_criticalcare=- (1)))
  CALL echo("Not able upload the code cache manager user not logged in")
  GO TO exit_script
 ENDIF
 DECLARE cdfmeaning_genlab = f8 WITH constant(uar_get_code_by("MEANING",106,"GLB"))
 DECLARE cdfmeaning_rad = f8 WITH constant(uar_get_code_by("MEANING",106,"RADIOLOGY"))
 DECLARE cdfmeaning_ap = f8 WITH constant(uar_get_code_by("MEANING",106,"AP"))
 DECLARE cdfmeaning_bb = f8 WITH constant(uar_get_code_by("MEANING",106,"BB"))
 DECLARE cdfmeaning_bbproduct = f8 WITH constant(uar_get_code_by("MEANING",106,"BB PRODUCT"))
 DECLARE cdfmeaning_bbdonor = f8 WITH constant(uar_get_code_by("MEANING",106,"BBDONOR"))
 DECLARE cdfmeaning_bbdonorprod = f8 WITH constant(uar_get_code_by("MEANING",106,"BBDONORPROD"))
 DECLARE cdfmeaning_hla = f8 WITH constant(uar_get_code_by("MEANING",106,"HLA"))
 DECLARE cdfmeaning_microbiology = f8 WITH constant(uar_get_code_by("MEANING",106,"MICROBIOLOGY"))
 DECLARE cdfmeaning_task_assay = f8 WITH constant(uar_get_code_by("MEANING",13016,"TASK ASSAY"))
 DECLARE cdfmeaning_code_value = f8 WITH constant(uar_get_code_by("MEANING",13016,"CODEVALUE"))
 SELECT INTO "nl;"
  FROM bill_item bi
  WHERE bi.ext_child_contributor_cd=0
   AND bi.ext_parent_contributor_cd=cdfmeaning_task_assay
   AND bi.active_ind=1
   AND bi.updt_task=600112
  WITH nocounter
 ;end select
 IF (curqual=0)
  UPDATE  FROM bill_item bi
   SET bi.active_ind = 0
   WHERE bi.ext_child_contributor_cd=0
    AND bi.ext_parent_contributor_cd=cdfmeaning_task_assay
    AND bi.active_ind=1
    AND bi.updt_task=600112
   WITH nocounter
  ;end update
 ENDIF
 DECLARE status_flag = i2 WITH constant(0)
 DECLARE dtacnt = i4 WITH noconstant(0)
 SET request->nbr_of_recs = 1
 SET stat = alterlist(request->qual,1)
 SET request->qual[1].ext_description = "DCP_GENERIC"
 SET request->qual[1].ext_contributor_cd = cdfmeaning_code_value
 SET request->qual[1].parent_qual_ind = 1
 SET request->qual[1].ext_owner_cd = cdfmeaning_criticalcare
 SELECT INTO "nl:"
  FROM code_value_alias cva
  WHERE cva.alias="DCPGENERIC"
   AND cva.code_set=72
  DETAIL
   request->qual[1].ext_id = cva.code_value
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("Unable to get the code_value for dcp_generic")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl;"
  FROM discrete_task_assay dta
  WHERE  NOT (dta.activity_type_cd IN (cdfmeaning_genlab, cdfmeaning_rad, cdfmeaning_ap,
  cdfmeaning_bb, cdfmeaning_bbproduct,
  cdfmeaning_bbdonor, cdfmeaning_bbdonorprod, cdfmeaning_hla, cdfmeaning_microbiology))
   AND dta.active_ind=1
  DETAIL
   dtacnt = (dtacnt+ 1)
   IF (dtacnt > size(request->qual[1].children,5))
    stat = alterlist(request->qual[1].children,(dtacnt+ 100))
   ENDIF
   request->qual[1].children[dtacnt].ext_id = dta.task_assay_cd, request->qual[1].children[dtacnt].
   ext_contributor_cd = cdfmeaning_task_assay, request->qual[1].children[dtacnt].ext_owner_cd = dta
   .activity_type_cd,
   request->qual[1].children[dtacnt].ext_description = dta.description, request->qual[1].children[
   dtacnt].ext_short_desc = dta.mnemonic
  WITH nocounter
 ;end select
 SET stat = alterlist(request->qual[1].children,dtacnt)
 IF (curqual=0)
  CALL echo("not able to find dta's for the activity type")
  GO TO exit_script
 ENDIF
 SET request->qual[1].child_qual = dtacnt
 EXECUTE afc_add_reference_api
#exit_script
END GO
