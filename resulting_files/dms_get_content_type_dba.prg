CREATE PROGRAM dms_get_content_type:dba
 CALL echo("<==================== Entering DMS_GET_CONTENT_TYPE Script ====================>")
 CALL echorecord(request)
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 qual[*]
      2 dms_content_type_id = f8
      2 content_type_key = vc
      2 display = vc
      2 description = vc
      2 max_versions = i4
      2 expiration_duration = i4
      2 audit_name = vc
      2 latest_metadata_ver = i4
      2 signature_req_ind = i2
      2 active_ind = i2
      2 audit_ind = i2
      2 dms_repository_id = f8
      2 cerner_ind = i2
      2 ownership_ind = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 SET reply->status_data.status = "F"
 DECLARE qualcount = i4 WITH noconstant(0)
 DECLARE idsize = i4 WITH noconstant(size(request->ids,5))
 DECLARE num = i4 WITH noconstant(0)
 SELECT
  IF (size(trim(request->content_type_key)) > 0)
   PLAN (dct
    WHERE dct.content_type_key=cnvtupper(request->content_type_key)
     AND dct.dms_content_type_id > 0.0)
    JOIN (dmmr
    WHERE (dmmr.dms_content_type_id= Outerjoin(dct.dms_content_type_id)) )
  ELSEIF (idsize > 0)
   PLAN (dct
    WHERE expand(num,1,idsize,dct.dms_content_type_id,request->ids[num].id)
     AND dct.dms_content_type_id > 0.0)
    JOIN (dmmr
    WHERE (dmmr.dms_content_type_id= Outerjoin(dct.dms_content_type_id)) )
  ELSE
   PLAN (dct
    WHERE dct.dms_content_type_id > 0.0)
    JOIN (dmmr
    WHERE (dmmr.dms_content_type_id= Outerjoin(dct.dms_content_type_id)) )
  ENDIF
  INTO "nl:"
  dct.*, nullschema = nullind(dmmr.dms_media_metadata_ref_id), dmmr.version
  FROM dms_content_type dct,
   dms_media_metadata_ref dmmr
  ORDER BY dct.dms_content_type_id, dmmr.version DESC
  HEAD REPORT
   qualcount = 0
  HEAD dct.dms_content_type_id
   qualcount += 1
   IF (mod(qualcount,10)=1)
    stat = alterlist(reply->qual,(qualcount+ 9))
   ENDIF
   reply->qual[qualcount].dms_content_type_id = dct.dms_content_type_id, reply->qual[qualcount].
   content_type_key = dct.content_type_key, reply->qual[qualcount].display = dct.display,
   reply->qual[qualcount].description = dct.description, reply->qual[qualcount].max_versions = dct
   .max_versions, reply->qual[qualcount].expiration_duration = dct.expiration_duration,
   reply->qual[qualcount].audit_name = dct.audit_name
   IF ( NOT (nullschema))
    reply->qual[qualcount].latest_metadata_ver = dmmr.version
   ENDIF
   reply->qual[qualcount].signature_req_ind = dct.signature_req_ind, reply->qual[qualcount].
   active_ind = dct.active_ind, reply->qual[qualcount].audit_ind = dct.audit_ind,
   reply->qual[qualcount].dms_repository_id = dct.dms_repository_id, reply->qual[qualcount].
   cerner_ind = dct.cerner_ind, reply->qual[qualcount].ownership_ind = dct.ownership_ind
  FOOT REPORT
   stat = alterlist(reply->qual,qualcount)
  WITH nocounter
 ;end select
 IF (curqual <= 0)
  SET reply->status_data.status = "Z"
  GO TO end_script
 ENDIF
 SET reply->status_data.status = "S"
#end_script
 CALL echorecord(reply)
 CALL echo("<==================== Exiting DMS_GET_CONTENT_TYPE Script ====================>")
END GO
