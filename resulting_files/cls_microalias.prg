CREATE PROGRAM cls_microalias
 PROMPT
  "Output to File/Printer/MINE" = mine
  WITH outdev
 SELECT INTO  $OUTDEV
  cv1.code_value, cv1.display, cv1.description,
  cv1.active_ind, cv1.code_set, c.alias,
  c.code_set, c_contributor_source_disp = uar_get_code_display(c.contributor_source_cd)
  FROM code_value cv1,
   code_value_outbound c
  PLAN (cv1
   WHERE ((cv1.code_set=1028) OR (cv1.code_set=2052)) )
   JOIN (c
   WHERE cv1.code_value=c.code_value
    AND c.contributor_source_cd=703454)
  ORDER BY cv1.code_set, cv1.display
 ;end select
END GO
