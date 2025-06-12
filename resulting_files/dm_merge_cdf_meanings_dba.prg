CREATE PROGRAM dm_merge_cdf_meanings:dba
 RECORD cdf(
   1 cdf_cnt = i4
   1 qual[*]
     2 code_set = f8
     2 cdf_meaning = vc
     2 display = vc
     2 definition = vc
     2 updt_applctx = f8
     2 updt_dt_tm = dq8
     2 updt_cnt = f8
     2 updt_task = f8
 )
 SET cdf->cdf_cnt = 0
 SELECT INTO "nl:"
  FROM common_data_foundation@loc_mrg_link cdf
  WHERE  NOT ( EXISTS (
  (SELECT
   "x"
   FROM common_data_foundation cdf1
   WHERE cdf1.code_set=cdf.code_set
    AND cdf1.cdf_meaning=cdf.cdf_meaning)))
  DETAIL
   cdf->cdf_cnt = (cdf->cdf_cnt+ 1), stat = alterlist(cdf->qual,cdf->cdf_cnt), cdf->qual[cdf->cdf_cnt
   ].code_set = cdf.code_set,
   cdf->qual[cdf->cdf_cnt].cdf_meaning = cdf.cdf_meaning, cdf->qual[cdf->cdf_cnt].display = cdf
   .display, cdf->qual[cdf->cdf_cnt].definition = cdf.definition,
   cdf->qual[cdf->cdf_cnt].updt_applctx = cdf.updt_applctx, cdf->qual[cdf->cdf_cnt].updt_dt_tm = cdf
   .updt_dt_tm, cdf->qual[cdf->cdf_cnt].updt_cnt = cdf.updt_cnt,
   cdf->qual[cdf->cdf_cnt].updt_task = cdf.updt_task
  WITH nocounter
 ;end select
 INSERT  FROM common_data_foundation cdf,
   (dummyt d  WITH seq = value(cdf->cdf_cnt))
  SET cdf.code_set = cdf->qual[d.seq].code_set, cdf.cdf_meaning = cdf->qual[d.seq].cdf_meaning, cdf
   .display = cdf->qual[d.seq].display,
   cdf.definition = cdf->qual[d.seq].definition, cdf.updt_applctx = cdf->qual[d.seq].updt_applctx,
   cdf.updt_dt_tm = cnvtdatetime(cdf->qual[d.seq].updt_dt_tm),
   cdf.updt_id = 0, cdf.updt_cnt = cdf->qual[d.seq].updt_cnt, cdf.updt_task = cdf->qual[d.seq].
   updt_task
  PLAN (d)
   JOIN (cdf)
  WITH nocounter
 ;end insert
 COMMIT
END GO
