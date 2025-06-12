CREATE PROGRAM cls_cs2052rpt2
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 SELECT INTO  $OUTDEV
  code = cv.code_value, desc = substring(1,40,cv.description), codeset = cv.code_set,
  active = uar_get_code_meaning(cv.active_ind), alias = decode(cva.seq,substring(1,40,cva.alias)," ")
  FROM code_value cv,
   code_value_outbound cva
  PLAN (cv
   WHERE cv.code_set=2052
    AND cv.active_ind=1)
   JOIN (cva
   WHERE outerjoin(cv.code_value)=cva.code_value
    AND cva.contributor_source_cd=703454)
  ORDER BY desc
 ;end select
END GO
