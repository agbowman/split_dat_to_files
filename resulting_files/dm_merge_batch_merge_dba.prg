CREATE PROGRAM dm_merge_batch_merge:dba
 PAINT
 CALL clear(1,1)
 CALL text(1,05,"Enter ref_domain: Press Shift F5 for HELP.")
#help_domain_name
 SET help =
 SELECT
  h.ref_domain_name, h.unique_ident_column
  FROM dm_ref_domain h
  WHERE h.unique_ident_column != "*_ID"
   AND h.unique_ident_column != "*_CD"
  ORDER BY h.ref_domain_name
  WITH nocounter
 ;end select
 CALL accept(2,05,"p(65);c")
 SET d_name = curaccept
 CALL text(4,05,"Enter master_ind: (1 = source, 2 = target)")
 CALL accept(5,05,"p(3);c")
 SET mas = curaccept
 RECORD info(
   1 merge[*]
     2 ident = vc
     2 from_id = vc
     2 to_id = vc
     2 tabb = vc
     2 domain = vc
     2 master = vc
   1 add[*]
     2 ident = vc
     2 from_id = vc
     2 to_id = vc
     2 tabb = vc
     2 domain = vc
     2 master = vc
 )
 SET ad = 0
 SET m = 0
 SET merge_no = 0
 SET add_no = 0
 EXECUTE dm_merge_add
 SELECT INTO "MINE"
  FROM dummyt
  HEAD REPORT
   row 1, "The following details the matching information was found.", row + 1,
   merge_no, " matching records were found.", row + 2,
   col 15, "Including the file:", row + 1,
   col 30, "ccluserdir:dm_merge_file.dat", row + 1,
   col 15, "will merge these records.", row + 3
  DETAIL
   m = 0
   FOR (m = 1 TO merge_no)
     row + 1, "Unique ID: ", info->merge[m].ident,
     row + 1, "From row_id: ", info->merge[m].from_id,
     row + 1, "To row_id: ", info->merge[m].to_id,
     row + 1, "Table: ", info->merge[m].tabb,
     row + 1, "Ref_domain: ", info->merge[m].domain
     IF ((info->merge[m].master="1"))
      row + 1, "Master: source"
     ELSEIF ((info->merge[m].master="2"))
      row + 1, "Master: target"
     ENDIF
     row + 2
   ENDFOR
  WITH nocounter, formfeed = none, format = stream,
   maxcol = 300
 ;end select
 SELECT INTO "MINE"
  FROM dummyt
  HEAD REPORT
   row 1, "A match was not found for the following information.", row + 1,
   add_no, " new records were found.", row + 2,
   col 15, "Including the file:", row + 1,
   col 30, "ccluserdir:dm_add_file.dat", row + 1,
   col 15, "will add these records.", row + 3
  DETAIL
   m = 0
   IF (add_no > 0)
    FOR (m = 1 TO add_no)
      row + 1, "Unique ID: ", info->add[ad].ident,
      row + 1, "From row_id: ", info->add[ad].from_id,
      row + 1, "To row_id: ", info->add[ad].to_id,
      row + 1, "Table: ", info->add[ad].tabb,
      row + 1, "Ref_domain: ", info->add[ad].domain
      IF ((info->add[ad].master="1"))
       row + 1, "Master: source"
      ELSEIF ((info->add[ad].master="2"))
       row + 1, "Master: target"
      ENDIF
      row + 2
    ENDFOR
   ENDIF
  WITH nocounter, formfeed = none, format = stream,
   maxcol = 300
 ;end select
END GO
