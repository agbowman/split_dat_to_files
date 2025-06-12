CREATE PROGRAM bb_get_alpha_responses:dba
 SET modify = predeclare
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 responselist[*]
      2 nomenclature_id = f8
      2 description = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
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
 DECLARE ncurrent = i2 WITH protect, noconstant(0)
 DECLARE serror = c132 WITH protect, noconstant(" ")
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  FROM reference_range_factor rrf,
   alpha_responses ar,
   nomenclature n
  PLAN (rrf
   WHERE (rrf.task_assay_cd=request->task_assay_cd)
    AND rrf.beg_effective_dt_tm < cnvtdatetime(sysdate)
    AND rrf.end_effective_dt_tm > cnvtdatetime(sysdate))
   JOIN (ar
   WHERE ar.reference_range_factor_id=rrf.reference_range_factor_id
    AND ar.active_ind=1)
   JOIN (n
   WHERE n.nomenclature_id=ar.nomenclature_id)
  ORDER BY n.nomenclature_id
  HEAD REPORT
   ncurrent = 0
  HEAD n.nomenclature_id
   ncurrent += 1
   IF (ncurrent > size(reply->responselist,5))
    nstatus = alterlist(reply->responselist,(ncurrent+ 9))
   ENDIF
   reply->responselist[ncurrent].nomenclature_id = n.nomenclature_id, reply->responselist[ncurrent].
   description = n.source_string
  FOOT REPORT
   nstatus = alterlist(reply->responselist,ncurrent)
  WITH nocounter
 ;end select
 IF (error(serror,0) > 0)
  CALL subevent_add("EXECUTE","F","bb_get_alpha_responses",serror)
  GO TO exit_script
 ENDIF
 IF (value(size(reply->responselist,5))=0)
  SET reply->status_data.status = "Z"
  CALL subevent_add("SELECT","Z","bb_get_alpha_responses","No alpha responses found.")
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
END GO
