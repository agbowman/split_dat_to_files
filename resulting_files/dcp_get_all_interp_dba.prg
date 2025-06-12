CREATE PROGRAM dcp_get_all_interp:dba
 RECORD dta_interp_list(
   1 qual[*]
     2 task_assay_cd = f8
 )
 SET count = 0
 SET stat = 0
 SELECT INTO "nl:"
  i.task_assay_cd
  FROM dcp_interp i
  WHERE i.updt_dt_tm < cnvtdatetime(curdate,curtime)
  ORDER BY i.task_assay_cd
  HEAD i.task_assay_cd
   count = (count+ 1)
   IF (count < size(dta_interp_list->qual))
    stat = alterlist(dta_interp_list->qual,(count+ 5))
   ENDIF
   dta_interp_list->qual[count].task_assay_cd = i.task_assay_cd
  WITH nocounter
 ;end select
 CALL echo(build("count:",count))
 SET stat = alterlist(dta_interp_list->qual,count)
 SET k = 0
 FOR (k = 1 TO count)
   EXECUTE dcp_get_exp_interp dta_interp_list->qual[i].task_assay_cd
 ENDFOR
 SET reqinfo->commit_ind = 1
END GO
