CREATE PROGRAM cpm_get_dprotect_count:dba
 RECORD reply(
   1 discern_count = i4
 )
 SELECT INTO "nl:"
  d.object_name
  FROM dprotect d
  WHERE d.object IN ("T", "P", "E")
   AND d.group=0
  WITH nocounter
 ;end select
 SET reply->discern_count = curqual
END GO
