CREATE PROGRAM ct_get_doc:dba
 RECORD reply(
   1 long_blob = gvc
   1 blob_length = i4
   1 debug = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE report_failure(opname=vc,opstatus=c1,targetname=vc,targetvalue=vc) = null
 DECLARE last_mod = c3 WITH private, noconstant(fillstring(3," "))
 DECLARE mod_date = c30 WITH private, noconstant(fillstring(30," "))
 DECLARE length = i4 WITH private, noconstant(0)
 DECLARE failed = c1 WITH protect, noconstant("S")
 SELECT INTO "nl:"
  FROM ct_document_blob blob
  PLAN (blob
   WHERE (blob.ct_document_version_id=request->ct_document_version_id)
    AND blob.active_ind=1)
  HEAD REPORT
   outbuf = fillstring(30000," "), offset = 0, retlen = 0
  DETAIL
   IF (blob.ct_document_blob_id > 0)
    retlen = 1
    WHILE (retlen > 0)
      retlen = blobget(outbuf,offset,blob.long_blob)
      IF (retlen=size(outbuf))
       reply->long_blob = notrim(concat(reply->long_blob,outbuf))
      ELSEIF (retlen > 0)
       reply->long_blob = notrim(concat(reply->long_blob,substring(1,retlen,outbuf)))
      ENDIF
      offset = (offset+ retlen)
    ENDWHILE
    reply->blob_length = blob.blob_length
   ENDIF
  WITH nocounter, rdbarrayfetch = 1
 ;end select
 IF (curqual=0)
  CALL report_failure("SELECT","F","CT_GET_DOC","Error finding blob.")
  GO TO exit_script
 ENDIF
 SET length = size(reply->long_blob,1)
 CALL echo(build("reply->blob_length",reply->blob_length))
 CALL echo(build("length",length))
 IF ((length != reply->blob_length))
  CALL report_failure("SELECT","F","CT_GET_DOC","Blob_length comparison failed.")
  GO TO exit_script
 ENDIF
 SUBROUTINE report_failure(opname,opstatus,targetname,targetvalue)
   SET failed = opstatus
   SET reply->status_data.subeventstatus[1].operationname = trim(opname)
   SET reply->status_data.subeventstatus[1].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[1].targetobjectname = trim(targetname)
   SET reply->status_data.subeventstatus[1].targetobjectvalue = trim(targetvalue)
 END ;Subroutine
#exit_script
 IF (failed != "S")
  SET reply->status_data.status = failed
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 SET last_mod = "002"
 SET mod_date = "November 1, 2010"
END GO
