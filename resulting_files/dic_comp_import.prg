CREATE PROGRAM dic_comp_import
 INSERT  FROM dprotectocd dp,
   dprotect dpocd,
   (dummyt d  WITH seq = 1)
  SET dpocd.datarec = dp.datarec
  PLAN (d)
   JOIN (dp
   WHERE "H0000"=dp.platform
    AND "5"=dp.rcode
    AND "P"=dp.object
    AND ( $1=dp.object_name))
   JOIN (dpocd
   WHERE dp.platform=dpocd.platform
    AND dp.rcode=dpocd.rcode
    AND dp.object=dpocd.object
    AND dp.object_name=dpocd.object_name
    AND dp.group=dpocd.group)
  WITH outerjoin = dp, dontexist
 ;end insert
 INSERT  FROM dcompileocd dc,
   dcompile dcocd,
   (dummyt d  WITH seq = 1)
  SET dcocd.datarec = dc.datarec
  PLAN (d)
   JOIN (dc
   WHERE "H0000"=dc.platform
    AND "9"=dc.rcode
    AND "P"=dc.object
    AND ( $1=dc.object_name))
   JOIN (dcocd
   WHERE dc.platform=dcocd.platform
    AND dc.rcode=dcocd.rcode
    AND dc.object=dcocd.object
    AND dc.object_name=dcocd.object_name
    AND dc.group=dcocd.group
    AND dc.qual=dcocd.qual)
  WITH outerjoin = dc, dontexist
 ;end insert
END GO
