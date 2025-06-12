CREATE PROGRAM d
 PROMPT
  "TASK_ASSAY_CD =  [0]  " = 0
 SELECT
  *
  FROM discrete_task_assay
  WHERE (task_assay_cd= $1)
 ;end select
END GO
