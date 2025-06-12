CREATE PROGRAM bb_get_qc_lot_information:dba
 SUBROUTINE (subevent_add(op_name=vc(value),op_status=vc(value),obj_name=vc(value),obj_value=vc(value
   )) =null WITH protect)
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
 RECORD reply(
   1 lot_list[*]
     2 lot_information_id = f8
     2 lot_ident = c40
     2 lot_status_cd = f8
     2 lot_status_disp = c40
     2 lot_status_mean = c12
     2 manufacturer_cd = f8
     2 manufacturer_disp = c40
     2 service_resource_cd = f8
     2 service_resource_disp = c40
     2 expiration_dt_tm = dq8
     2 reagent_cd = f8
     2 reagent_disp = c40
     2 available_ind = i2
     2 valid_result_list[*]
       3 result_id = f8
       3 result_string = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE nstatus = i2 WITH noconstant(0), protect
 DECLARE lerrorcode = i4 WITH protect, noconstant(0)
 DECLARE serrormsg = c132 WITH protect, noconstant(fillstring(132," "))
 DECLARE nfail = i2 WITH protect, constant(0)
 DECLARE nsuccess = i2 WITH protect, constant(1)
 DECLARE nno_matches = i2 WITH protect, constant(2)
#begin_script
 SET reply->status_data.status = "F"
 SET nstatus = getqclots(0)
 IF (nstatus=nno_matches)
  SET reply->status_data.status = "Z"
  CALL subevent_add("SELECT","Z","PCS_LOT_DEFINITION","No lots found.")
  GO TO exit_script
 ELSEIF (nstatus=nfail)
  CALL subevent_add("SELECT","F","PCS_LOT_DEFINITION","Query for lots failed.")
  GO TO exit_script
 ENDIF
 SET nstatus = getqcvalidresults(0)
 IF (nstatus=nfail)
  CALL subevent_add("SELECT","F","REFERENCE_RANGE_FACTOR","Query for QC results.")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
 SUBROUTINE (getqclots(no_param=i2(value)) =i2 WITH private)
   DECLARE llotcnt = i4 WITH noconstant(0), protect
   DECLARE lcs_activity_type = i4 WITH constant(106), protect
   DECLARE dbbtypecd = f8 WITH noconstant(0.0), protect
   SET nstatus = uar_get_meaning_by_codeset(lcs_activity_type,"BB",1,dbbtypecd)
   IF (dbbtypecd=0.0)
    CALL subevent_add("SELECT","Z","CODE_VALUE","BB Activity type not found.")
    RETURN(nfail)
   ENDIF
   SELECT INTO "nl:"
    FROM pcs_lot_definition ld,
     pcs_lot_information li
    PLAN (ld
     WHERE ld.activity_type_cd=dbbtypecd)
     JOIN (li
     WHERE ld.lot_definition_id=li.lot_definition_id
      AND li.beg_effective_dt_tm <= cnvtdatetime(sysdate)
      AND li.end_effective_dt_tm >= cnvtdatetime(sysdate))
    DETAIL
     llotcnt += 1
     IF (llotcnt > size(reply->lot_list,5))
      nstatus = alterlist(reply->lot_list,(llotcnt+ 10))
     ENDIF
     reply->lot_list[llotcnt].manufacturer_cd = ld.manufacturer_cd, reply->lot_list[llotcnt].
     service_resource_cd = ld.service_resource_cd, reply->lot_list[llotcnt].reagent_cd = ld
     .parent_entity_id,
     reply->lot_list[llotcnt].lot_information_id = li.lot_information_id, reply->lot_list[llotcnt].
     lot_ident = li.lot_ident, reply->lot_list[llotcnt].lot_status_cd = li.status_cd,
     reply->lot_list[llotcnt].expiration_dt_tm = li.expire_dt_tm, reply->lot_list[llotcnt].
     available_ind = ld.available_ind
    FOOT REPORT
     nstatus = alterlist(reply->lot_list,llotcnt)
    WITH nocounter
   ;end select
   SET lerrorcode = error(serrormsg,1)
   IF (lerrorcode > 0)
    RETURN(nfail)
   ELSEIF (size(reply->lot_list,5) > 0)
    RETURN(nsuccess)
   ELSE
    RETURN(nno_matches)
   ENDIF
 END ;Subroutine
 SUBROUTINE (getqcvalidresults(no_param=i2(value)) =i2 WITH private)
   DECLARE lresultcnt = i4 WITH noconstant(0), protect
   SELECT INTO "nl:"
    ar.nomenclature_id
    FROM (dummyt d1  WITH seq = value(size(reply->lot_list,5))),
     reference_range_factor rr,
     alpha_responses ar,
     nomenclature n
    PLAN (d1)
     JOIN (rr
     WHERE (rr.task_assay_cd=reply->lot_list[d1.seq].reagent_cd)
      AND (reply->lot_list[d1.seq].reagent_cd > 0)
      AND rr.beg_effective_dt_tm < cnvtdatetime(sysdate)
      AND rr.end_effective_dt_tm > cnvtdatetime(sysdate))
     JOIN (ar
     WHERE rr.reference_range_factor_id=ar.reference_range_factor_id
      AND ar.active_ind=1)
     JOIN (n
     WHERE n.nomenclature_id=ar.nomenclature_id)
    ORDER BY d1.seq, n.nomenclature_id
    HEAD d1.seq
     lresultcnt = 0
    HEAD n.nomenclature_id
     lresultcnt += 1
     IF (lresultcnt > size(reply->lot_list[d1.seq].valid_result_list,5))
      nstatus = alterlist(reply->lot_list[d1.seq].valid_result_list,(lresultcnt+ 10))
     ENDIF
     reply->lot_list[d1.seq].valid_result_list[lresultcnt].result_id = n.nomenclature_id, reply->
     lot_list[d1.seq].valid_result_list[lresultcnt].result_string = n.source_string
    FOOT  d1.seq
     nstatus = alterlist(reply->lot_list[d1.seq].valid_result_list,lresultcnt)
    WITH nocounter
   ;end select
   SET lerrorcode = error(serrormsg,1)
   IF (lerrorcode > 0)
    RETURN(nfail)
   ELSEIF (size(reply->lot_list,5) > 0)
    RETURN(nsuccess)
   ENDIF
 END ;Subroutine
END GO
