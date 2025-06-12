CREATE PROGRAM cpm_get_dprotect_object:dba
 RECORD reply(
   1 objecttype = i1
   1 name = vc
   1 group = i1
   1 timestamp = i4
   1 datestamp = i4
   1 binarycnt = i4
 )
 DECLARE objecttype = vc WITH noconstant(char(cnvtint(request->objecttype)))
 SELECT INTO "nl:"
  FROM dprotect d
  WHERE d.object=objecttype
   AND (d.group=request->group)
   AND d.object_name=nullterm(request->name)
  DETAIL
   reply->name = request->name, reply->datestamp = d.datestamp, reply->timestamp = d.timestamp,
   reply->binarycnt = d.binary_cnt
  WITH nocounter
 ;end select
END GO
