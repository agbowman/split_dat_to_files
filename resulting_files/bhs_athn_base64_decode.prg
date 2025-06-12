CREATE PROGRAM bhs_athn_base64_decode
 IF (validate(request)=0)
  FREE RECORD request
  RECORD request(
    1 blob = vc
    1 url_source_ind = i2
  ) WITH protect
 ENDIF
 IF (validate(reply)=0)
  FREE RECORD reply
  RECORD reply(
    1 blob = vc
  ) WITH protect
 ENDIF
 DECLARE encoded_blob = vc WITH protect, noconstant(request->blob)
 IF (textlen(encoded_blob)=0)
  CALL echo("INVALID REQUEST BLOB...EXITING")
  GO TO exit_script
 ENDIF
 IF ((request->url_source_ind=1))
  SET encoded_blob = replace(encoded_blob,".","+",0)
  SET encoded_blob = replace(encoded_blob,"_","/",0)
  SET encoded_blob = replace(encoded_blob,"-","=",0)
 ENDIF
 DECLARE uar_si_decode_base64(p1=vc(ref),p2=i4(ref),p3=vc(ref),p4=i4(ref),p5=i4(ref)) = i4 WITH
 persist
 DECLARE outblob_size = i4 WITH public, noconstant(0)
 DECLARE temp_blob = vc WITH public, noconstant(encoded_blob)
 SET stat = uar_si_decode_base64(encoded_blob,size(encoded_blob),temp_blob,size(temp_blob),
  outblob_size)
 IF (stat > 0)
  SET reply->blob = substring(1,outblob_size,temp_blob)
 ENDIF
#exit_script
END GO
