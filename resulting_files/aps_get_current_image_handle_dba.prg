CREATE PROGRAM aps_get_current_image_handle:dba
 SET modify = predeclare
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
     2 old_handle = vc
     2 old_storage_cd = f8
     2 new_handle = vc
     2 new_storage_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD temp_image(
   1 qual[*]
     2 old_handle = vc
     2 old_storage_cd = f8
 )
 DECLARE ddicomstoragecd = f8 WITH protect, noconstant(0.0)
 DECLARE dcachestoragecd = f8 WITH protect, noconstant(0.0)
 DECLARE dmmfstoragecd = f8 WITH protect, noconstant(0.0)
 DECLARE stat = i2 WITH protect, noconstant(0)
 DECLARE lreqcnt = i4 WITH protect, noconstant(0)
 DECLARE limagecnt = i4 WITH protect, noconstant(0)
 DECLARE lreplycnt = i4 WITH protect, noconstant(0)
 DECLARE lidx = i4 WITH protect, noconstant(0)
 DECLARE lidx1 = i4 WITH protect, noconstant(0)
 DECLARE lidx2 = i4 WITH protect, noconstant(0)
 SET reply->status_data.status = "F"
 SET stat = uar_get_meaning_by_codeset(25,"DICOM_SIUID",1,ddicomstoragecd)
 IF (ddicomstoragecd=0)
  CALL subevent_add("UAR","F","UAR","CODE_VALUE (25 - DICOM_SIUID)")
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(25,"IMGCACHE",1,dcachestoragecd)
 IF (dcachestoragecd=0)
  CALL subevent_add("UAR","F","UAR","CODE_VALUE (25 - IMGCACHE)")
  GO TO exit_script
 ENDIF
 SET stat = uar_get_meaning_by_codeset(25,"MMF",1,dmmfstoragecd)
 IF (dmmfstoragecd=0)
  CALL subevent_add("UAR","F","UAR","CODE_VALUE (25 - MMF)")
  GO TO exit_script
 ENDIF
 SET lreqcnt = size(request->qual,5)
 FOR (lidx = 1 TO lreqcnt)
  IF ((((request->qual[lidx].storage_cd=ddicomstoragecd)) OR ((request->qual[lidx].storage_cd=
  dcachestoragecd))) )
   SET limagecnt = (limagecnt+ 1)
   IF (size(temp_image->qual,5) < limagecnt)
    SET stat = alterlist(temp_image->qual,(limagecnt+ 5))
   ENDIF
   SET temp_image->qual[limagecnt].old_handle = request->qual[lidx].blob_handle
   SET temp_image->qual[limagecnt].old_storage_cd = request->qual[lidx].storage_cd
  ENDIF
  SET stat = alterlist(temp_image->qual,limagecnt)
 ENDFOR
 IF (limagecnt > 0)
  SET stat = alterlist(reply->qual,limagecnt)
  SELECT INTO "nl:"
   aim.mmf_blob_handle_ident
   FROM ap_image_migrated aim
   PLAN (aim
    WHERE expand(lidx1,1,limagecnt,aim.dicom_blob_handle_ident,temp_image->qual[lidx1].old_handle,
     limagecnt))
   DETAIL
    lreplycnt = (lreplycnt+ 1), lidx2 = locateval(lidx1,1,limagecnt,aim.dicom_blob_handle_ident,
     temp_image->qual[lidx1].old_handle), reply->qual[lreplycnt].old_handle = temp_image->qual[lidx2]
    .old_handle,
    reply->qual[lreplycnt].old_storage_cd = temp_image->qual[lidx2].old_storage_cd, reply->qual[
    lreplycnt].new_handle = aim.mmf_blob_handle_ident, reply->qual[lreplycnt].new_storage_cd =
    dmmfstoragecd
   WITH nocounter
  ;end select
  SET stat = alterlist(reply->qual,lreplycnt)
 ENDIF
 IF (size(reply->qual,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
#exit_script
 SET modify = nopredeclare
END GO
