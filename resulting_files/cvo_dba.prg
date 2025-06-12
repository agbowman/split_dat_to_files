CREATE PROGRAM cvo:dba
 SELECT INTO mine
  cvo.*
  FROM code_value_outbound cvo
  WHERE (cvo.code_value= $1)
   AND cvo.contributor_source_cd > 0
  WITH nocounter
 ;end select
END GO
