CREATE PROGRAM afc_rpt_dup_tier_matrix:dba
 FREE SET reqinfo
 RECORD reqinfo(
   1 commit_ind = i4
   1 updt_id = f8
   1 updt_applctx = i4
   1 updt_task = i4
 )
 SET reqinfo->updt_id = 2208
 SET reqinfo->updt_applctx = 951000
 SET reqinfo->updt_task = 951000
 FREE SET request
 RECORD request(
   1 tier_matrix_qual = i2
   1 tier_matrix[*]
     2 tier_cell_id = f8
     2 active_status_cd = f8
 )
 SELECT
  t.tier_group_cd, t.tier_cell_id, t.tier_row_num,
  t.tier_col_num, t.tier_cell_type_cd, t.tier_cell_value,
  t.beg_effective_dt_tm, t.end_effective_dt_tm, end_dt_tm = format(t.end_effective_dt_tm,
   "MM/DD/YYYY;;D"),
  t.updt_dt_tm, t.tier_group_cd, c1.display,
  c2.display
  FROM tier_matrix t,
   code_value c1,
   code_value c2
  PLAN (t
   WHERE ((t.active_ind=1
    AND t.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime)
    AND t.end_effective_dt_tm >= cnvtdatetime(curdate,curtime)
    AND ( $2=1)) OR (t.active_ind=1
    AND ( $2 != 1))) )
   JOIN (c1
   WHERE c1.code_value=t.tier_group_cd)
   JOIN (c2
   WHERE c2.code_value=t.tier_cell_type_cd)
  ORDER BY t.tier_group_cd, t.beg_effective_dt_tm, t.tier_row_num,
   t.tier_col_num
  HEAD REPORT
   col 01, "Tier Matrix Report", col 80,
   curdate, col 90, curtime3,
   row + 2, pagecnt = 0, dupcnt = 0
  HEAD PAGE
   pagecnt = (pagecnt+ 1), col 80, "Page: ",
   col 90, pagecnt, row + 2,
   col 10, "ID", col 25,
   "Row", col 38, "Col",
   col 45, "Cell Type", col 60,
   "Value", col 75, "Begin Dt",
   col 90, "End Dt", row + 1,
   col 05, "==============", col 20,
   "============", col 33, "===========",
   col 45, "==========", col 56,
   "==================", col 75, "==============",
   col 90, "==============", row + 1
  HEAD t.tier_group_cd
   last_col = 0, last_row = 0, row + 1,
   col 05, "Tier Group:", col 20,
   c1.display, row + 1
  DETAIL
   IF (last_row=t.tier_row_num
    AND last_col=t.tier_col_num)
    dupcnt = (dupcnt+ 1), col 01, "dup",
    request->tier_matrix_qual = (request->tier_matrix_qual+ 1), stat = alterlist(request->tier_matrix,
     (request->tier_matrix_qual+ 1)), request->tier_matrix[request->tier_matrix_qual].tier_cell_id =
    t.tier_cell_id
   ELSEIF (last_row=t.tier_row_num
    AND last_col != t.tier_col_num)
    last_col = t.tier_col_num, col 33, t.tier_col_num
   ELSE
    row + 1, last_row = t.tier_row_num, last_col = t.tier_col_num,
    col 20, t.tier_row_num, col 33,
    t.tier_col_num
   ENDIF
   col 05, t.tier_cell_id, col 45,
   c2.display, col 56, t.tier_cell_value,
   col 75, t.beg_effective_dt_tm, col 90,
   end_dt_tm, col 110, t.updt_dt_tm,
   row + 1
  FOOT  t.end_effective_dt_tm
   col 10,
   "------------------------------------------------------------------------------------------", row
    + 1
  FOOT REPORT
   col 05, dupcnt, col 20,
   "Duplicates"
  WITH nocounter
 ;end select
 IF (( $1=1))
  CALL echo("DELETING DUPS")
  EXECUTE afc_del_tier_matrix
  CALL echo(concat(cnvtstring(request->tier_matrix_qual),
    " Duplicate entries deleted.  Type 'Commit Go' to commit the changes"))
 ELSE
  CALL echo("DUPS NOT DELETED")
 ENDIF
END GO
