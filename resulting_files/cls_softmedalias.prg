CREATE PROGRAM cls_softmedalias
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 SELECT
  alias = substring(0,25,c.alias), desc = substring(0,60,cv1.description), c.code_set,
  c.code_value, c.contributor_source_cd, c_contributor_source_disp = uar_get_code_display(c
   .contributor_source_cd),
  c.updt_dt_tm, cv1.code_value
  FROM code_value_alias c,
   code_value cv1
  PLAN (c
   WHERE c.contributor_source_cd=689444
    AND c.code_set=200)
   JOIN (cv1
   WHERE c.code_value=cv1.code_value)
  ORDER BY alias, desc
 ;end select
END GO
