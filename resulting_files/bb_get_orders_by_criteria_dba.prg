CREATE PROGRAM bb_get_orders_by_criteria:dba
 RECORD reply(
   1 order_list[*]
     2 order_id = f8
     2 accession = c20
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value))
  = null WITH protect
 SUBROUTINE subevent_add(op_name,op_status,obj_name,obj_value)
   DECLARE se_itm = i4 WITH protect, noconstant(0)
   DECLARE stat = i2 WITH protect, noconstant(0)
   SET se_itm = size(reply->status_data.subeventstatus,5)
   SET stat = alter(reply->status_data.subeventstatus,(se_itm+ 1))
   SET reply->status_data.subeventstatus[se_itm].operationname = cnvtupper(substring(1,25,trim(
      op_name)))
   SET reply->status_data.subeventstatus[se_itm].operationstatus = cnvtupper(substring(1,1,trim(
      op_status)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectname = cnvtupper(substring(1,25,trim(
      obj_name)))
   SET reply->status_data.subeventstatus[se_itm].targetobjectvalue = obj_value
 END ;Subroutine
 SET modify = predeclare
 DECLARE getcodevalues(null) = i2
 DECLARE lactivity_type_cs = i4 WITH protect, constant(106)
 DECLARE sbb_cdf = c12 WITH protect, constant("BB")
 DECLARE sbb_product_cdf = c12 WITH protect, constant("BB PRODUCT")
 DECLARE lorder_status_cs = i4 WITH protect, constant(6004)
 DECLARE scanceled_cdf = c12 WITH protect, constant("CANCELED")
 DECLARE scompleted_cdf = c12 WITH protect, constant("COMPLETED")
 DECLARE sdiscontinued_cdf = c12 WITH protect, constant("DISCONTINUED")
 DECLARE ldept_status_cs = i4 WITH protect, constant(14281)
 DECLARE sinlab_cdf = c12 WITH protect, constant("LABINLAB")
 DECLARE sinprocess_cdf = c12 WITH protect, constant("LABINPROCESS")
 DECLARE dbb_cv = f8 WITH protect, noconstant(0.0)
 DECLARE dbb_product_cv = f8 WITH protect, noconstant(0.0)
 DECLARE dcanceled_cv = f8 WITH protect, noconstant(0.0)
 DECLARE dcompleted_cv = f8 WITH protect, noconstant(0.0)
 DECLARE ddiscontinued_cv = f8 WITH protect, noconstant(0.0)
 DECLARE dinlab_cv = f8 WITH protect, noconstant(0.0)
 DECLARE dinprocess_cv = f8 WITH protect, noconstant(0.0)
 DECLARE lstat = i4 WITH protect, noconstant(0)
 DECLARE select_ok_flag = i2 WITH protect, noconstant(0)
 DECLARE nidx = i2 WITH protect, noconstant(0)
 DECLARE nidx2 = i2 WITH protect, noconstant(0)
 DECLARE nproceduresize = i2 WITH protect, noconstant(size(request->procedure_list,5))
 DECLARE nprioritysize = i2 WITH protect, noconstant(size(request->priority_list,5))
 DECLARE nuarfailure = i2 WITH protect, noconstant(0)
 SET lstat = getcodevalues(null)
 IF (lstat=0)
  SET nuarfailure = 1
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM orders o,
   order_laboratory ol,
   accession_order_r aor,
   order_serv_res_container osrc,
   bb_worklist_detail w,
   (dummyt d  WITH seq = 1)
  PLAN (o
   WHERE o.orig_order_dt_tm BETWEEN cnvtdatetime(request->ordered_from_dt_tm) AND cnvtdatetime(
    request->ordered_to_dt_tm)
    AND ((o.activity_type_cd+ 0) IN (dbb_cv, dbb_product_cv))
    AND ((o.dept_status_cd+ 0) IN (dinlab_cv, dinprocess_cv))
    AND  NOT (((o.order_status_cd+ 0) IN (dcanceled_cv, dcompleted_cv, ddiscontinued_cv)))
    AND ((o.product_id+ 0)=0)
    AND ((nproceduresize=0) OR (nproceduresize > 0
    AND expand(nidx,1,nproceduresize,o.catalog_cd,request->procedure_list[nidx].procedure_cd))) )
   JOIN (ol
   WHERE ol.order_id=o.order_id
    AND ((nprioritysize=0) OR (nprioritysize > 0
    AND expand(nidx2,1,nprioritysize,ol.report_priority_cd,request->priority_list[nidx2].priority_cd)
   )) )
   JOIN (aor
   WHERE aor.order_id=o.order_id
    AND aor.primary_flag=0)
   JOIN (osrc
   WHERE osrc.order_id=o.order_id
    AND (((request->service_resource_cd=0)) OR ((request->service_resource_cd > 0)
    AND (osrc.service_resource_cd=request->service_resource_cd))) )
   JOIN (d)
   JOIN (w
   WHERE w.order_id=o.order_id)
  ORDER BY o.order_id
  HEAD REPORT
   nordercnt = 0
  HEAD o.order_id
   IF (size(reply->order_list,5) <= nordercnt)
    lstat = alterlist(reply->order_list,(nordercnt+ 10))
   ENDIF
   IF ((request->not_on_worksheet_ind=1))
    IF (w.worklist_detail_id=0)
     nordercnt = (nordercnt+ 1), reply->order_list[nordercnt].order_id = o.order_id, reply->
     order_list[nordercnt].accession = aor.accession
    ENDIF
   ELSE
    nordercnt = (nordercnt+ 1), reply->order_list[nordercnt].order_id = o.order_id, reply->
    order_list[nordercnt].accession = aor.accession
   ENDIF
  DETAIL
   row + 0
  FOOT REPORT
   lstat = alterlist(reply->order_list,nordercnt), select_ok_flag = 1
  WITH nocounter, outerjoin = d
 ;end select
 IF (curqual=0)
  SET select_ok_flag = 2
 ENDIF
 SUBROUTINE getcodevalues(null)
   DECLARE code_cnt = i4 WITH protected, noconstant(1)
   SET lstat = uar_get_meaning_by_codeset(lactivity_type_cs,nullterm(sbb_cdf),code_cnt,dbb_cv)
   IF (dbb_cv=0.0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_get_prod_ord_by_criteria.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Unable to retrieve the code_value for the cdf_meaning BB in code_set 106."
    SET reply->status = "F"
    RETURN(0)
   ENDIF
   SET lstat = uar_get_meaning_by_codeset(lactivity_type_cs,nullterm(sbb_product_cdf),code_cnt,
    dbb_product_cv)
   IF (dbb_product_cv=0.0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_get_prod_ord_by_criteria.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Unable to retrieve the code_value for the cdf_meaning BB_PRODUCT in code_set 106."
    SET reply->status = "F"
    RETURN(0)
   ENDIF
   SET lstat = uar_get_meaning_by_codeset(lorder_status_cs,nullterm(scanceled_cdf),code_cnt,
    dcanceled_cv)
   IF (dcanceled_cv=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_get_prod_ord_by_criteria.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Unable to retrieve the code_value for the cdf_meaning CANCELED in code_set 6004."
    SET reply->status = "F"
    RETURN(0)
   ENDIF
   SET lstat = uar_get_meaning_by_codeset(lorder_status_cs,nullterm(scompleted_cdf),code_cnt,
    dcompleted_cv)
   IF (dcompleted_cv=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_get_prod_ord_by_criteria.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Unable to retrieve the code_value for the cdf_meaning COMPLETED in code_set 6004."
    SET reply->status = "F"
    RETURN(0)
   ENDIF
   SET lstat = uar_get_meaning_by_codeset(lorder_status_cs,nullterm(sdiscontinued_cdf),code_cnt,
    ddiscontinued_cv)
   IF (ddiscontinued_cv=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_get_prod_ord_by_criteria.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Unable to retrieve the code_value for the cdf_meaning DISCONTINUED in code_set 6004."
    SET reply->status = "F"
    RETURN(0)
   ENDIF
   SET lstat = uar_get_meaning_by_codeset(ldept_status_cs,nullterm(sinlab_cdf),code_cnt,dinlab_cv)
   IF (dinlab_cv=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_get_prod_ord_by_criteria.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Unable to retrieve the code_value for the cdf_meaning LABINLAB in code_set 14281."
    SET reply->status = "F"
    RETURN(0)
   ENDIF
   SET lstat = uar_get_meaning_by_codeset(ldept_status_cs,nullterm(sinprocess_cdf),code_cnt,
    dinprocess_cv)
   IF (dinprocess_cv=0)
    SET reply->status_data.status = "F"
    SET reply->status_data.subeventstatus[1].operationname = "bb_get_prod_ord_by_criteria.prg"
    SET reply->status_data.subeventstatus[1].operationstatus = "F"
    SET reply->status_data.subeventstatus[1].targetobjectname = "uar_get_meaning_by_codeset"
    SET reply->status_data.subeventstatus[1].targetobjectvalue =
    "Unable to retrieve the code_value for the cdf_meaning LABINPROCESS in code_set 14281."
    SET reply->status = "F"
    RETURN(0)
   ENDIF
   RETURN(1)
 END ;Subroutine
#exit_script
 IF (nuarfailure=0)
  IF (select_ok_flag=0)
   SET reply->status_data.status = "F"
   SET reply->status_data.subeventstatus[1].operationname = "Select failed"
   SET reply->status_data.subeventstatus[1].operationstatus = "F"
   SET reply->status_data.subeventstatus[1].targetobjectname = "BB_GET_PROD_ORD_BY_CRITERIA"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Failed to retrieve data."
  ELSEIF (select_ok_flag=1)
   SET reply->status_data.status = "S"
   SET reply->status_data.subeventstatus[1].operationname = "Select successful"
   SET reply->status_data.subeventstatus[1].operationstatus = "S"
   SET reply->status_data.subeventstatus[1].targetobjectname = "BB_GET_PROD_ORD_BY_CRITERIA"
   SET reply->status_data.subeventstatus[1].targetobjectvalue =
   "All possible data generated successfully."
  ELSEIF (select_ok_flag=2)
   SET reply->status_data.status = "Z"
   SET reply->status_data.subeventstatus[1].operationname = "Select successful"
   SET reply->status_data.subeventstatus[1].operationstatus = "Z"
   SET reply->status_data.subeventstatus[1].targetobjectname = "BB_GET_PROD_ORD_BY_CRITERIA"
   SET reply->status_data.subeventstatus[1].targetobjectvalue = "Data does not exist."
  ENDIF
 ENDIF
END GO
