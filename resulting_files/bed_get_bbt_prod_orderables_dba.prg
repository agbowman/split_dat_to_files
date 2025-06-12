CREATE PROGRAM bed_get_bbt_prod_orderables:dba
 RECORD reply(
   1 oc_list[*]
     2 catalog_code_value = f8
     2 primary_mnemonic = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 DECLARE error_flag = vc WITH protect
 DECLARE serrmsg = vc WITH protect
 DECLARE ierrcode = i4 WITH protect
 SET error_flag = "N"
 SET serrmsg = fillstring(132," ")
 SET ierrcode = error(serrmsg,1)
 DECLARE bederror(errordescription=vc) = null
 DECLARE bederrorcheck(errordescription=vc) = null
 SUBROUTINE bederror(errordescription)
   SET error_flag = "Y"
   SET reply->status_data.subeventstatus[1].targetobjectname = errordescription
   GO TO exit_script
 END ;Subroutine
 SUBROUTINE bederrorcheck(errordescription)
  SET ierrcode = error(serrmsg,1)
  IF (ierrcode > 0)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
   CALL bederror(errordescription)
  ENDIF
 END ;Subroutine
 DECLARE bb_orderable_proc_cs = i4 WITH protect, constant(1635)
 DECLARE activity_type_cs = i4 WITH protect, constant(106)
 DECLARE catalog_type_cs = i4 WITH protect, constant(6000)
 DECLARE prod_req_order_mean = vc WITH protect, constant("PRODUCT ORDR")
 DECLARE prod_req_order_cd = f8 WITH protect, noconstant(0.0)
 DECLARE bb_activity_type_mean = c12 WITH protect, constant("BB")
 DECLARE bb_activity_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE gen_lab_cat_type_mean = c12 WITH protect, constant("GENERAL LAB")
 DECLARE gen_lab_cat_type_cd = f8 WITH protect, noconstant(0.0)
 DECLARE count = i4 WITH protect, noconstant(0)
 SET gen_lab_cat_type_cd = uar_get_code_by("MEANING",catalog_type_cs,nullterm(gen_lab_cat_type_mean))
 IF (gen_lab_cat_type_cd <= 0.0)
  CALL bederror(concat("CODE_BY_MEAN_ERR(",catalog_type_cs,")"))
 ENDIF
 SET bb_activity_type_cd = uar_get_code_by("MEANING",activity_type_cs,nullterm(bb_activity_type_mean)
  )
 IF (bb_activity_type_cd <= 0.0)
  CALL bederror(concat("CODE_BY_MEAN_ERR(",activity_type_cs,")"))
 ENDIF
 SET prod_req_order_cd = uar_get_code_by("MEANING",bb_orderable_proc_cs,nullterm(prod_req_order_mean)
  )
 IF (prod_req_order_cd <= 0.0)
  CALL bederror(concat("CODE_BY_MEAN_ERR(",bb_orderable_proc_cs,")"))
 ENDIF
 SELECT INTO "nl:"
  FROM order_catalog oc,
   service_directory sd
  PLAN (oc
   WHERE oc.active_ind=1
    AND oc.catalog_type_cd=gen_lab_cat_type_cd
    AND oc.activity_type_cd=bb_activity_type_cd)
   JOIN (sd
   WHERE sd.catalog_cd=oc.catalog_cd
    AND sd.bb_processing_cd=prod_req_order_cd)
  HEAD REPORT
   count = 0
  DETAIL
   count = (count+ 1), stat = alterlist(reply->oc_list,count), reply->oc_list[count].
   catalog_code_value = oc.catalog_cd,
   reply->oc_list[count].primary_mnemonic = oc.primary_mnemonic
  FOOT REPORT
   stat = alterlist(reply->oc_list,count)
  WITH nocounter
 ;end select
 CALL bederrorcheck("SELECT_ERR")
 CALL bederrorcheck("Descriptive error message not provided.")
#exit_script
 IF (error_flag="N")
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "F"
 ENDIF
 CALL echorecord(reply)
END GO
