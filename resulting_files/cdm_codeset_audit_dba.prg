CREATE PROGRAM cdm_codeset_audit:dba
 SELECT
  IF ((request->opt_all_cd_sets=1))
   FROM code_value c,
    code_value_set cs,
    (dummyt d1  WITH seq = 1),
    code_value_extension x,
    (dummyt d2  WITH seq = 1),
    person p
   PLAN (c)
    JOIN (cs
    WHERE c.code_set=cs.code_set)
    JOIN (d1
    WHERE 1=d1.seq)
    JOIN (p
    WHERE c.updt_id=p.person_id)
    JOIN (x
    WHERE c.code_value=x.code_value)
    JOIN (d2
    WHERE 1=d2.seq)
  ELSE
   FROM (dummyt d  WITH seq = value(request->numrecs)),
    code_value c,
    code_value_set cs,
    (dummyt d1  WITH seq = 1),
    code_value_extension x,
    (dummyt d2  WITH seq = 1),
    person p
   PLAN (d)
    JOIN (c
    WHERE (request->qual[d.seq].codeset=c.code_set))
    JOIN (cs
    WHERE c.code_set=cs.code_set)
    JOIN (d1
    WHERE 1=d1.seq)
    JOIN (p
    WHERE c.updt_id=p.person_id)
    JOIN (x
    WHERE c.code_value=x.code_value)
    JOIN (d2
    WHERE 1=d.seq)
  ENDIF
  INTO trim(request->output_device)
  c.*, cs.*, x.*,
  x_data = decode(d2.seq,"Y","N")
  ORDER BY c.code_set, c.code_value
  HEAD REPORT
   under = fillstring(131,"="), hpage = "T"
  HEAD PAGE
   hpage = "T", col 0, curdate"dd-mmm-yyyy;;d",
   col 120, "Page:", col + 1,
   curpage"###;l", col 42, "C O D E S E T   A U D I T   R E P O R T",
   row + 1, col 0, col 0,
   "Code Value", col 15, "Code Value Display",
   col 60, "Code Value Description", row + 1,
   col 0, under, row + 1,
   col 0, "CODESET NUMBER:  ", cs.code_set"##############;l",
   row + 1, col 0, "CODESET DISPLAY: ",
   cs.display, row + 1, col 0,
   "CODESET DESCRPT: ", cs.description
  HEAD c.code_set
   IF (row > 57)
    BREAK
   ENDIF
   IF (hpage="F")
    col 0, "CODESET: ", cs.code_set"##############;l",
    row + 1, col 0, "CS DISPLAY: ",
    cs.display, row + 1, col 0,
    "CS DESCRPT: ", cs.description
   ELSE
    hpage = "F"
   ENDIF
  DETAIL
   col 0, c.code_value"##############;l", col 15,
   c.display, col 60, c.description
   IF (x_data="Y")
    IF (row > 57)
     BREAK
    ENDIF
    row + 1, col 0, "Ext Field Name: ",
    x.field_name, col + 1, col 62,
    "Ext Field Type: ", x.field_type"##############;l", col + 1,
    col 62, "Ext Value: ",
    CALL print(trim(x.field_value))
   ENDIF
   IF ((request->opt_full_audit=1))
    IF (row > 57)
     BREAK
    ENDIF
    row + 1, col 0, "CDF Meaning: ",
    c.cdf_meaning, col 47, "Col Seq: ",
    c.collation_seq"######;l", row + 1, col 0,
    "Act Type: ", c.active_type_cd"########;l", col 40,
    "Act Ind: ", c.active_ind"##;l", col 52,
    "Act/Inact Dt-tm: ", c.active_dt_tm"dd-mmm-yyyy-hhmm;;d", "/",
    c.inactive_dt_tm"dd-mmm-yyyy-hhmm;;d", row + 1, col 0,
    "Updt Info: ID: ", c.updt_id"#########;l", col + 1,
    "Dt/Tm: ", c.updt_dt_tm"dd-mmm-yyyy-hhmm;;d"
   ENDIF
   row + 2
  FOOT  c.code_set
   hpage = "F"
  WITH outerjoin = d1, maxcol = 132
 ;end select
END GO
