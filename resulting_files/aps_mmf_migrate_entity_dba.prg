CREATE PROGRAM aps_mmf_migrate_entity:dba
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
 DECLARE lstat = i4 WITH protect, noconstant(0)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 dicom_handle = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ELSE
  SET lstat = initrec(reply)
  IF (size(reply->status_data.subeventstatus,5) != 1)
   SET lstat = alter(reply->status_data.subeventstatus,1)
  ENDIF
 ENDIF
 RECORD image_list(
   1 img_cnt = i4
   1 img_qual[*]
     2 dicom_uid = vc
     2 mmf_identifier = vc
 )
 RECORD dicom_retrieve_req(
   1 dicom_uid = vc
   1 dicom_services_handle = i4
 )
 RECORD dicom_retrieve_rep(
   1 image_pathname = vc
   1 dicom_services_handle = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD mmf_store_req(
   1 filename = vc
   1 patient_id = f8
   1 case_id = f8
 )
 RECORD mmf_store_rep(
   1 blob_handle = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 RECORD update_ids(
   1 id_cnt = i4
   1 id_qual[*]
     2 id = f8
     2 replace_indx = i4
 )
 DECLARE logcclerror(soperation=vc(value),stable=vc(value)) = i2 WITH protect
 DECLARE lcurindx = i4 WITH protect, noconstant(0)
 DECLARE ldicomhandle = i4 WITH protect, noconstant(0)
 DECLARE lqualcnt = i4 WITH protect, noconstant(0)
 DECLARE dmigrateid = f8 WITH protect, noconstant(0.0)
 DECLARE scclerror = vc WITH protect, noconstant(" ")
 DECLARE dpersonid = f8 WITH protect, noconstant(0.0)
 DECLARE ddicomstoragecd = f8 WITH protect, noconstant(0.0)
 DECLARE dcachestoragecd = f8 WITH protect, noconstant(0.0)
 DECLARE dmmfstoragecd = f8 WITH protect, noconstant(0.0)
 SET reply->status_data.status = "F"
 SET ldicomhandle = request->dicom_handle
 SET lstat = error(scclerror,1)
 SET image_list->img_cnt = 0
 SET lstat = uar_get_meaning_by_codeset(25,"DICOM_SIUID",1,ddicomstoragecd)
 IF (ddicomstoragecd=0.0)
  CALL subevent_add("codecache","F","DICOM_SIUID","Failed")
  GO TO exit_script
 ENDIF
 SET lstat = uar_get_meaning_by_codeset(25,"IMGCACHE",1,dcachestoragecd)
 IF (dcachestoragecd=0.0)
  CALL subevent_add("codecache","F","IMGCACHE","Failed")
  GO TO exit_script
 ENDIF
 SET lstat = uar_get_meaning_by_codeset(25,"MMF",1,dmmfstoragecd)
 IF (dcachestoragecd=0.0)
  CALL subevent_add("codecache","F","MMF","Failed")
  GO TO exit_script
 ENDIF
 IF ((request->case_id != 0.0))
  SELECT DISTINCT INTO "nl:"
   shandle = decode(br.seq,br.blob_handle,cbr.seq,cbr.blob_handle," "), pc.person_id
   FROM pathology_case pc,
    case_report cr,
    report_detail_image rdi,
    blob_reference br,
    clinical_event ce,
    ce_blob_result cbr,
    dummyt d1,
    dummyt d2
   PLAN (pc
    WHERE (pc.case_id=request->case_id))
    JOIN (((d1)
    JOIN (cr
    WHERE cr.case_id=pc.case_id)
    JOIN (rdi
    WHERE rdi.report_id=cr.report_id)
    JOIN (br
    WHERE br.parent_entity_name="REPORT_DETAIL_IMAGE"
     AND br.parent_entity_id=rdi.report_detail_id
     AND br.storage_cd IN (ddicomstoragecd, dcachestoragecd))
    ) ORJOIN ((d2)
    JOIN (ce
    WHERE ce.accession_nbr=trim(pc.accession_nbr))
    JOIN (cbr
    WHERE cbr.event_id=ce.event_id
     AND cbr.storage_cd IN (ddicomstoragecd, dcachestoragecd))
    ))
   ORDER BY shandle, 0
   HEAD REPORT
    dpersonid = pc.person_id
   DETAIL
    IF (textlen(trim(shandle)) > 0)
     image_list->img_cnt = (image_list->img_cnt+ 1)
     IF ((size(image_list->img_qual,5) < image_list->img_cnt))
      ldmy = alterlist(image_list->img_qual,(image_list->img_cnt+ 9))
     ENDIF
     image_list->img_qual[image_list->img_cnt].dicom_uid = shandle, image_list->img_qual[image_list->
     img_cnt].mmf_identifier = " "
    ENDIF
   WITH nocounter
  ;end select
  IF (logcclerror("SELECT","PATHOLOGY_CASE")=0)
   GO TO exit_script
  ENDIF
 ELSEIF ((request->discrete_entity_id != 0.0))
  SET dpersonid = 0.0
  SELECT DISTINCT INTO "nl:"
   shandle = br.blob_handle
   FROM blob_reference br
   PLAN (br
    WHERE br.parent_entity_name="AP_DISCRETE_ENTITY"
     AND (br.parent_entity_id=request->discrete_entity_id)
     AND br.storage_cd IN (ddicomstoragecd, dcachestoragecd))
   ORDER BY shandle, 0
   DETAIL
    IF (textlen(trim(shandle)) > 0)
     image_list->img_cnt = (image_list->img_cnt+ 1)
     IF ((size(image_list->img_qual,5) < image_list->img_cnt))
      ldmy = alterlist(image_list->img_qual,(image_list->img_cnt+ 9))
     ENDIF
     image_list->img_qual[image_list->img_cnt].dicom_uid = shandle, image_list->img_qual[image_list->
     img_cnt].mmf_identifier = " "
    ENDIF
   WITH nocounter
  ;end select
  IF (logcclerror("SELECT","BLOB_REFERENCE")=0)
   GO TO exit_script
  ENDIF
 ENDIF
 IF ((image_list->img_cnt < 1))
  SET reply->status_data.status = "Z"
  GO TO exit_script
 ENDIF
 FOR (lcurindx = 1 TO image_list->img_cnt)
   SELECT INTO "nl:"
    aim.mmf_blob_handle_ident
    FROM ap_image_migrated aim
    PLAN (aim
     WHERE (aim.dicom_blob_handle_ident=image_list->img_qual[lcurindx].dicom_uid))
    DETAIL
     image_list->img_qual[lcurindx].mmf_identifier = aim.mmf_blob_handle_ident
    WITH nocounter
   ;end select
   SET lqualcnt = curqual
   IF (logcclerror("SELECT","AP_IMAGE_MIGRATED")=0)
    GO TO exit_script
   ELSEIF (lqualcnt=0)
    SET dicom_retrieve_req->dicom_services_handle = ldicomhandle
    SET dicom_retrieve_req->dicom_uid = image_list->img_qual[lcurindx].dicom_uid
    EXECUTE aps_retrieve_dicom  WITH replace("REQUEST","DICOM_RETRIEVE_REQ"), replace("REPLY",
     "DICOM_RETRIEVE_REP")
    SET ldicomhandle = dicom_retrieve_rep->dicom_services_handle
    IF ((dicom_retrieve_rep->status_data.status != "S"))
     CALL subevent_add("DICOM","F","RETRIEVE",image_list->img_qual[lcurindx].dicom_uid)
     CALL subevent_add(dicom_retrieve_rep->status_data.subeventstatus[1].operationname,"F",
      dicom_retrieve_rep->status_data.subeventstatus[1].targetobjectname,dicom_retrieve_rep->
      status_data.subeventstatus[1].targetobjectvalue)
     GO TO exit_script
    ENDIF
    SET mmf_store_req->filename = dicom_retrieve_rep->image_pathname
    SET mmf_store_req->case_id = request->case_id
    SET mmf_store_req->patient_id = dpersonid
    EXECUTE aps_mmf_store_image  WITH replace("REQUEST","MMF_STORE_REQ"), replace("REPLY",
     "MMF_STORE_REP")
    IF ((mmf_store_rep->status_data.status != "S"))
     CALL subevent_add("MMF","F","STORE",image_list->img_qual[lcurindx].dicom_uid)
     CALL subevent_add(dicom_retrieve_rep->status_data.subeventstatus[1].operationname,"F",
      dicom_retrieve_rep->status_data.subeventstatus[1].targetobjectname,dicom_retrieve_rep->
      status_data.subeventstatus[1].targetobjectvalue)
     GO TO exit_script
    ENDIF
    SET image_list->img_qual[lcurindx].mmf_identifier = mmf_store_rep->blob_handle
    SELECT INTO "nl:"
     seq_nbr = seq(pathnet_seq,nextval)"##################;rp0"
     FROM dual
     DETAIL
      dmigrateid = cnvtreal(seq_nbr)
     WITH format, nocounter
    ;end select
    IF (logcclerror("SELECT","pathnet_seq")=0)
     GO TO exit_script
    ENDIF
    INSERT  FROM ap_image_migrated aim
     SET aim.ap_image_migrated_id = dmigrateid, aim.case_id = request->case_id, aim
      .dicom_blob_handle_ident = image_list->img_qual[lcurindx].dicom_uid,
      aim.entity_id = request->discrete_entity_id, aim.mmf_blob_handle_ident = image_list->img_qual[
      lcurindx].mmf_identifier, aim.updt_dt_tm = cnvtdatetime(curdate,curtime3),
      aim.updt_id = reqinfo->updt_id, aim.updt_task = reqinfo->updt_task, aim.updt_applctx = reqinfo
      ->updt_applctx,
      aim.updt_cnt = 0
     WITH nocounter
    ;end insert
    IF (logcclerror("INSERT","AP_IMAGE_MIGRATED")=0)
     ROLLBACK
     GO TO exit_script
    ELSE
     COMMIT
     IF (logcclerror("COMMIT",image_list->img_qual[lcurindx].dicom_uid)=0)
      ROLLBACK
      GO TO exit_script
     ENDIF
    ENDIF
   ENDIF
 ENDFOR
 IF ((request->update_references_ind=0))
  SET reply->status_data.status = "S"
  GO TO exit_script
 ENDIF
 IF ((request->case_id != 0))
  SET update_ids->id_cnt = 0
  SELECT DISTINCT INTO "nl:"
   ce.event_id, cbr.blob_handle
   FROM (dummyt d  WITH seq = value(image_list->img_cnt)),
    pathology_case pc,
    clinical_event ce,
    ce_blob_result cbr
   PLAN (d)
    JOIN (pc
    WHERE (pc.case_id=request->case_id))
    JOIN (ce
    WHERE ce.accession_nbr=trim(pc.accession_nbr))
    JOIN (cbr
    WHERE cbr.event_id=ce.event_id
     AND (cbr.blob_handle=image_list->img_qual[d.seq].dicom_uid)
     AND cbr.storage_cd IN (ddicomstoragecd, dcachestoragecd))
   ORDER BY ce.event_id, cbr.blob_handle, 0
   DETAIL
    update_ids->id_cnt = (update_ids->id_cnt+ 1)
    IF ((size(update_ids->id_qual,5) < update_ids->id_cnt))
     lstat = alterlist(update_ids->id_qual,(update_ids->id_cnt+ 9))
    ENDIF
    update_ids->id_qual[update_ids->id_cnt].id = ce.event_id, update_ids->id_qual[update_ids->id_cnt]
    .replace_indx = d.seq
   WITH nocounter, forupdate
  ;end select
  IF (logcclerror("SELECT","CLINICAL_EVENT")=0)
   ROLLBACK
   GO TO exit_script
  ENDIF
  IF ((update_ids->id_cnt > 0))
   UPDATE  FROM ce_blob_result cbr,
     (dummyt d  WITH seq = value(update_ids->id_cnt))
    SET cbr.blob_handle = image_list->img_qual[update_ids->id_qual[d.seq].replace_indx].
     mmf_identifier, cbr.storage_cd = dmmfstoragecd
    PLAN (d)
     JOIN (cbr
     WHERE (cbr.event_id=update_ids->id_qual[d.seq].id)
      AND (cbr.blob_handle=image_list->img_qual[update_ids->id_qual[d.seq].replace_indx].dicom_uid)
      AND cbr.storage_cd IN (ddicomstoragecd, dcachestoragecd))
    WITH nocounter
   ;end update
  ENDIF
  IF (logcclerror("UPDATE","CE_BLOB_RESULT")=0)
   ROLLBACK
   GO TO exit_script
  ENDIF
 ENDIF
 UPDATE  FROM blob_reference br,
   (dummyt d  WITH seq = value(image_list->img_cnt))
  SET br.blob_handle = image_list->img_qual[d.seq].mmf_identifier, br.storage_cd = dmmfstoragecd
  PLAN (d)
   JOIN (br
   WHERE (br.blob_handle=image_list->img_qual[d.seq].dicom_uid)
    AND br.storage_cd IN (ddicomstoragecd, dcachestoragecd)
    AND br.parent_entity_name IN ("AP_DISCRETE_ENTITY", "REPORT_DETAIL_IMAGE"))
 ;end update
 IF (logcclerror("UPDATE","BLOB_REFERENCE")=0)
  ROLLBACK
  GO TO exit_script
 ENDIF
 IF ((request->update_references_ind != - (1)))
  COMMIT
  IF (logcclerror("COMMIT","References")=0)
   ROLLBACK
   GO TO exit_script
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
 GO TO exit_script
 SUBROUTINE logcclerror(soperation,stablename)
  IF (error(scclerror,1) != 0)
   CALL subevent_add(build(soperation),"F",build(stablename),scclerror)
   RETURN(0)
  ENDIF
  RETURN(1)
 END ;Subroutine
#exit_script
 SET reply->dicom_handle = ldicomhandle
 FREE SET image_list
 FREE SET dicom_retrieve_req
 FREE SET dicom_retrieve_rep
 FREE SET mmf_store_req
 FREE SET mmf_store_rep
 FREE SET update_ids
END GO
