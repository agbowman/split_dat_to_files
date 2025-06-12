CREATE PROGRAM ccl_dlg_get_promptobjnames
 PROMPT
  "object type (0, 1, 2)" = "0",
  "Search " = "*",
  "Group " = 0
  WITH objtype, search, grpno
 EXECUTE ccl_prompt_api_dataset "autoset"
 CASE (cnvtint( $OBJTYPE))
  OF 0:
   SELECT
    name = program_name
    FROM ccl_prompt_definitions
    WHERE position=0
     AND program_name=patstring(cnvtupper( $SEARCH))
     AND group_no=cnvtint( $GRPNO)
    ORDER BY program_name
    HEAD REPORT
     stat = makedataset(0)
    DETAIL
     stat = writerecord(0)
    FOOT REPORT
     stat = closedataset(0)
    WITH reporthelp, check
   ;end select
  OF 1:
   SELECT
    name = program_name
    FROM ccl_prompt_programs
    WHERE program_name=patstring(cnvtupper( $SEARCH))
     AND group_no=cnvtint( $GRPNO)
    ORDER BY program_name
    HEAD REPORT
     stat = makedataset(0)
    DETAIL
     stat = writerecord(0)
    FOOT REPORT
     stat = closedataset(0)
    WITH reporthelp, check
   ;end select
  OF 2:
   SELECT
    name = concat(trim(cf.folder_name,3),trim(cf.file_name,3))
    FROM ccl_prompt_file cf
    WHERE cf.collation_seq=0
     AND cf.folder_name=patstring(cnvtupper( $SEARCH))
    ORDER BY cf.folder_name, cf.file_name
    HEAD REPORT
     stat = makedataset(0)
    DETAIL
     stat = writerecord(0)
    FOOT REPORT
     stat = closedataset(0)
    WITH reporthelp, check
   ;end select
  ELSE
   SELECT
    name = program_name
    FROM ccl_prompt_definitions
    WHERE position=0
     AND program_name=patstring(cnvtupper( $SEARCH))
     AND group_no=cnvtint( $GRPNO)
    ORDER BY program_name
    HEAD REPORT
     stat = makedataset(0)
    DETAIL
     stat = writerecord(0)
    FOOT REPORT
     stat = closedataset(0)
    WITH reporthelp, check
   ;end select
 ENDCASE
END GO
