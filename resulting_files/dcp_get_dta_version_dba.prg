CREATE PROGRAM dcp_get_dta_version:dba
 SET modify maxvarlen 1000000
 RECORD reply(
   1 version_string[*]
     2 version_string = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE chunk_size = i4 WITH constant(64000)
 DECLARE start = i4 WITH private, noconstant(0)
 DECLARE finish = i4 WITH private, noconstant(0)
 DECLARE length = i4 WITH private, noconstant(0)
 DECLARE length2 = i4 WITH private, noconstant(0)
 DECLARE chunk_cnt = i4 WITH private, noconstant(0)
 DECLARE mnstat = i2 WITH noconstant(0)
 DECLARE failed = c1
 DECLARE errmsg = c132
 DECLARE long_blob_id = f8
 DECLARE xmlstringcompressed = vc
 DECLARE xmlstringuncompressed = vc
 SET failed = "F"
 SET long_blob_id = 0
 SELECT INTO "nl:"
  dtav.long_blob_id
  FROM dta_version dtav
  WHERE (dtav.task_assay_cd=request->task_assay_cd)
   AND (dtav.version_number=request->version_number)
  DETAIL
   long_blob_id = dtav.long_blob_id
  WITH nocounter
 ;end select
 IF (curqual != 1)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "DTA_VERSION"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SELECT
  bloblen = textlen(lb.long_blob)
  FROM long_blob_reference lb
  WHERE lb.long_blob_id=long_blob_id
  HEAD REPORT
   outbuf = fillstring(32000," "), retlen = 0, offset = 0
  HEAD lb.long_blob_id
   offset = 0
  DETAIL
   retlen = 1
   WHILE (retlen > 0)
     retlen = blobget(outbuf,offset,lb.long_blob), xmlstringcompressed = build(xmlstringcompressed,
      outbuf), offset = (offset+ 32000)
   ENDWHILE
  WITH rdbarrayfetch = 1
 ;end select
 IF (curqual=0)
  SET reply->status_data.subeventstatus[1].operationname = "SELECT"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "TABLE"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = "LONG_BLOB_REFERENCE"
  SET failed = "T"
  GO TO exit_script
 ENDIF
 FOR (j = 1 TO 20)
   SET xmlstringuncompressed = build(xmlstringuncompressed,fillstring(50000,"A"))
 ENDFOR
 SET length = 0
 SET flag = uar_ocf_uncompress(xmlstringcompressed,size(xmlstringcompressed),xmlstringuncompressed,
  size(xmlstringuncompressed),length)
 SET xmlstringuncompressed = substring(1,length,xmlstringuncompressed)
 SET mnstat = error(errmsg,1)
 IF (mnstat != 0)
  SET reply->status_data.subeventstatus[1].operationname = "UAR_OCF_COMPRESS"
  SET reply->status_data.subeventstatus[1].operationstatus = "F"
  SET reply->status_data.subeventstatus[1].targetobjectname = "XMLStringCompressed"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = concat(trim(rpt->reports[nrptidx].
    report_name,3),"****",errmsg)
  SET failed = "T"
  GO TO exit_script
 ENDIF
 SET length2 = size(xmlstringuncompressed)
 IF (length2)
  SET start = 1
  SET finish = 0
  SET chunk_cnt = 0
  WHILE (finish < length2)
    SET finish = (finish+ chunk_size)
    IF (finish >= length2)
     SET finish = length2
    ENDIF
    SET chunk_cnt = (chunk_cnt+ 1)
    SET stat = alterlist(reply->version_string,chunk_cnt)
    SET reply->version_string[chunk_cnt].version_string = substring(start,((finish - start)+ 1),
     xmlstringuncompressed)
    SET start = (finish+ 1)
  ENDWHILE
 ENDIF
#exit_script
 IF (failed="F")
  SET reply->status_data.status = "S"
  SET reqinfo->commit_ind = 1
 ELSE
  SET reply->status_data.status = "F"
  SET reqinfo->commit_ind = 0
 ENDIF
END GO
