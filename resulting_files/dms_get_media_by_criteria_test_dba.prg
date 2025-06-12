CREATE PROGRAM dms_get_media_by_criteria_test:dba
 SET modify = predeclare
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 identifier_list[*]
      2 identifier = vc
      2 version = i4
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 DECLARE maketags(index=i4(value)) = null
 IF ( NOT (validate(xml,0)))
  RECORD xml(
    1 qual[*]
      2 statement = vc
      2 tagpath = vc
      2 tagvalue = vc
  )
 ENDIF
 IF ( NOT (validate(rec,0)))
  RECORD rec(
    1 buffer[32]
      2 code = vc
  )
 ENDIF
 DECLARE contentclause = vc WITH protect, noconstant("1=1")
 DECLARE createdclause = vc WITH protect, noconstant("1=1")
 DECLARE mediaclause = vc WITH protect, noconstant("1=1")
 DECLARE sizecontent = i2 WITH protect, noconstant(0)
 DECLARE sizecreated = i2 WITH protect, noconstant(0)
 DECLARE sizemedia = i2 WITH protect, noconstant(0)
 DECLARE xmlpath = vc WITH protect, noconstant("")
 DECLARE beginposition = i4 WITH protect, noconstant(1)
 DECLARE endposition = i4 WITH protect, noconstant(0)
 DECLARE xmlcount = i4 WITH protect, noconstant(0)
 DECLARE count = i4 WITH protect, noconstant(0)
 DECLARE num = i2 WITH protect, noconstant(0)
 DECLARE stat = f8 WITH protect, noconstant(0.0)
 DECLARE xmlpathsize = i4 WITH protect, noconstant(0)
 DECLARE x = i4 WITH protect, noconstant(0)
 DECLARE size = i4 WITH protect, noconstant(0)
 DECLARE count1 = i4 WITH protect, noconstant(0)
 SET xmlpath = request->xpath_statement
 SET reply->status_data.status = "F"
 SET stat = alterlist(reply->identifier_list,10)
 IF ((request->created_begin_dt <= 0))
  GO TO end_script
 ENDIF
 IF ((request->created_end_dt <= 0))
  GO TO end_script
 ENDIF
 SET sizecontent = size(request->content_type_key_list,5)
 IF (sizecontent > 0)
  SET contentclause =
  "expand(num,1,sizeContent,dct.content_type_key,request->content_type_key_list[num]->content_type_key)"
 ELSE
  GO TO end_script
 ENDIF
 SET sizemedia = size(request->media_type_list,5)
 IF (sizemedia > 0)
  SET mediaclause =
  "expand(num, 1, sizeMedia, dmi.media_type, request->media_type_list[num]->media_type)"
 ENDIF
 SET sizecreated = size(request->created_by_list,5)
 IF (sizecreated > 0)
  SET createdclause =
  "expand(num, 1, sizeCreated, dmi.created_by_id, request->created_by_list[num]->created_by_id)"
 ENDIF
 IF (size(xmlpath,1) > 0)
  SET stat = alterlist(xml->qual,3)
  SET endposition = findstring("|",xmlpath,1,0)
  WHILE (endposition > 0)
    SET xmlcount = (xmlcount+ 1)
    IF (mod(xmlcount,3)=1
     AND xmlcount > 3)
     SET stat = alterlist(xml->qual,(xmlcount+ 3))
    ENDIF
    SET xml->qual[xmlcount].statement = substring(beginposition,(endposition - beginposition),xmlpath
     )
    CALL maketags(xmlcount)
    SET beginposition = (endposition+ 1)
    SET endposition = findstring("|",xmlpath,beginposition,0)
  ENDWHILE
  SET endposition = (size(xmlpath,1)+ 1)
  SET xmlcount = (xmlcount+ 1)
  SET xml->qual[xmlcount].statement = substring(beginposition,(endposition - beginposition),xmlpath)
  CALL maketags(xmlcount)
 ENDIF
 SET stat = alterlist(xml->qual,xmlcount)
 SET count = ((xmlcount * 5)+ 25)
 IF (count > size(rec->buffer,1))
  SET stat = alter(rec->buffer,count)
 ENDIF
 SELECT INTO "n1:"
  *
  FROM dms_media_instance dmi,
   dms_content_type dct,
   dms_media_metadata dmm1,
   dms_media_metadata dmm2,
   dms_media_metadata dmm3
  PLAN (dct
   WHERE expand(num,1,sizecontent,dct.content_type_key,request->content_type_key_list[num].
    content_type_key))
   JOIN (dmi
   WHERE dct.dms_content_type_id=dmi.dms_content_type_id
    AND dmi.created_dt_tm BETWEEN cnvtdatetime(request->created_begin_dt) AND cnvtdatetime(request->
    created_end_dt))
   JOIN (dmm1
   WHERE dmm1.dms_media_instance_id=dmi.dms_media_instance_id
    AND dmm1.tag_name IS NOT null
    AND dmm1.tag_path=patstring(xml->qual[1].tagpath)
    AND dmm1.tag_value=patstring(xml->qual[1].tagvalue))
   JOIN (dmm2
   WHERE dmm2.dms_media_instance_id=dmi.dms_media_instance_id
    AND dmm2.tag_name IS NOT null
    AND dmm2.tag_path=patstring(xml->qual[2].tagpath)
    AND dmm2.tag_value=patstring(xml->qual[2].tagvalue))
   JOIN (dmm3
   WHERE dmm3.dms_media_instance_id=dmi.dms_media_instance_id
    AND dmm3.tag_name IS NOT null
    AND dmm3.tag_path=patstring(xml->qual[3].tagpath)
    AND dmm3.tag_value=patstring(xml->qual[3].tagvalue))
  ORDER BY dmi.identifier, dmi.version DESC
  HEAD dmi.identifier
   count1 = (count1+ 1)
   IF (mod(count1,10)=1
    AND count1 > 1)
    stat = alterlist(reply->identifier_list,(count1+ 9))
   ENDIF
   reply->identifier_list[count1].identifier = dmi.identifier, reply->identifier_list[count1].version
    = dmi.version
  WITH nocounter
 ;end select
 SET stat = alterlist(reply->identifier_list,count1)
 CALL echorecord(xml)
 IF (curqual=0)
  SET reply->status_data.status = "Z"
 ELSE
  SET reply->status_data.status = "S"
 ENDIF
 CALL echorecord(reply)
#end_script
 CALL echo("at END_SCRIPT")
 FREE RECORD xml
 SUBROUTINE maketags(index)
   DECLARE pos = i4
   DECLARE length = i4
   SET xml->qual[index].statement = replace(xml->qual[index].statement,"[","",0)
   SET xml->qual[index].statement = replace(xml->qual[index].statement,"]","",0)
   SET length = size(xml->qual[index].statement,1)
   SET pos = findstring("=",xml->qual[index].statement,1,0)
   IF (pos > 1)
    SET xml->qual[index].tagpath = substring(1,(pos - 1),xml->qual[index].statement)
    SET xml->qual[index].tagvalue = substring((pos+ 1),(length - pos),xml->qual[index].statement)
   ENDIF
   IF (findstring("//",xml->qual[index].statement,1,0)=1)
    SET xml->qual[index].tagpath = replace(xml->qual[index].tagpath,"//","*",1)
   ENDIF
 END ;Subroutine
END GO
