CREATE PROGRAM cd:dba
 SELECT INTO mine
  cd.*
  FROM chart_distribution cd
  WHERE (cd.distribution_id= $1)
  WITH nocounter
 ;end select
END GO
