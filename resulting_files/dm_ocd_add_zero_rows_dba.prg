CREATE PROGRAM dm_ocd_add_zero_rows:dba
 PROMPT
  "Enter OCD number:  " = ""
 IF (build( $1) != char(42))
  IF (build( $1)="")
   CALL echo(concat("Usage:  ",curprog," <OCD number> GO"))
   GO TO end_of_program
  ENDIF
 ENDIF
 SET c_mod = "DM_OCD_ADD_ZERO_ROWS 001"
 FREE RECORD ozr
 RECORD ozr(
   1 cnt = i4
   1 tbl[*]
     2 tbl_name = vc
 )
 SET stat = alterlist(ozr->tbl,0)
 SET ozr->cnt = 0
 SELECT INTO "nl:"
  FROM dm_afd_tables d
  WHERE (d.alpha_feature_nbr= $1)
  DETAIL
   ozr->cnt = (ozr->cnt+ 1), stat = alterlist(ozr->tbl,ozr->cnt), ozr->tbl[ozr->cnt].tbl_name = d
   .table_name
  WITH nocounter
 ;end select
 FOR (ozi = 1 TO ozr->cnt)
   CALL parser(build("execute dm2_add_default_rows '",ozr->tbl[ozi].tbl_name,"' go"),1)
 ENDFOR
END GO
