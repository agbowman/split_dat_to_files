CREATE PROGRAM bbt_get_all_task_assays
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
 RECORD reply(
   1 qual[*]
     2 task_assay_cd = f8
     2 task_assay_disp = c40
     2 task_assay_desc = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE lcs_activity_type = i4 WITH protect, constant(106)
 DECLARE dbbtypecd = f8 WITH protect, noconstant(0.0)
 DECLARE dbbprodtypecd = f8 WITH protect, noconstant(0.0)
 DECLARE lassaycnt = i4 WITH protect, noconstant(0)
 DECLARE lstat = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET stat = uar_get_meaning_by_codeset(lcs_activity_type,"BB",1,dbbtypecd)
 SET stat = uar_get_meaning_by_codeset(lcs_activity_type,"BB PRODUCT",1,dbbprodtypecd)
 IF (((dbbtypecd=0) OR (dbbprodtypecd=0)) )
  CALL subevent_add("SELECT","Z","CODE_VALUE","Code values for activity type not found.")
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM discrete_task_assay dta
  WHERE ((dta.activity_type_cd=dbbtypecd) OR (dta.activity_type_cd=dbbprodtypecd
   AND dta.active_ind=1))
  DETAIL
   lassaycnt = (lassaycnt+ 1)
   IF (lassaycnt > size(reply->qual,5))
    lstat = alterlist(reply->qual,(lassaycnt+ 9))
   ENDIF
   reply->qual[lassaycnt].task_assay_cd = dta.task_assay_cd, reply->qual[lassaycnt].task_assay_disp
    = uar_get_code_display(dta.task_assay_cd), reply->qual[lassaycnt].task_assay_desc =
   uar_get_code_description(dta.task_assay_cd)
  FOOT REPORT
   lstat = alterlist(reply->qual,lassaycnt)
  WITH nocounter
 ;end select
 IF (lassaycnt > 0)
  SET reply->status_data.status = "S"
 ELSE
  SET reply->status_data.status = "Z"
 ENDIF
#exit_script
END GO
