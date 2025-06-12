CREATE PROGRAM bb_get_relation_in_use:dba
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 bb_qc_groups[*]
      2 group_name = vc
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
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
 DECLARE serror = vc WITH noconstant(""), protect
 SET reply->status_data.status = "F"
 SELECT INTO "nl:"
  *
  FROM bb_qc_grp_reagent_lot b,
   bb_qc_group b2
  PLAN (b
   WHERE (b.related_reagent_id=request->related_reagent_id)
    AND b.active_ind=1)
   JOIN (b2
   WHERE b2.group_id=b.group_id)
  HEAD REPORT
   ncount = 0
  DETAIL
   ncount = (ncount+ 1)
   IF (ncount > size(reply->bb_qc_groups,5))
    nstatus = alterlist(reply->bb_qc_groups,(ncount+ 10))
   ENDIF
   reply->bb_qc_groups[ncount].group_name = b2.group_name
  FOOT REPORT
   nstatus = alterlist(reply->bb_qc_groups,ncount)
  WITH nocounter
 ;end select
 IF (error(serror,0) > 0)
  CALL subevent_add("EXECUTE","F","bb_get_relation_in_use",serror)
  GO TO exit_script
 ENDIF
 SET reply->status_data.status = "S"
#exit_script
END GO
