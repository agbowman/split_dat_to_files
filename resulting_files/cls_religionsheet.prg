CREATE PROGRAM cls_religionsheet
 SELECT
  cv1.code_set, cv1.display, c.alias
  FROM code_value cv1,
   code_value_alias c
  PLAN (cv1
   WHERE cv1.code_set IN (38, 49))
   JOIN (c
   WHERE c.code_value=cv1.code_value
    AND c.contributor_source_cd=673943)
  ORDER BY cv1.code_set, cv1.display
 ;end select
END GO
