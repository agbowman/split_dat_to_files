CREATE PROGRAM drg_log:dba
 PAINT
 FREE SET all
#accept_script
 CALL clear(1,1)
 CALL box(1,1,22,80)
 CALL text(2,4,"DRG files loaded successfully")
 CALL text(3,4,"Choose from the following:")
 CALL line(4,1,80,xhor)
 CALL text(6,4,"1)  obsolete terms log")
 CALL text(7,4,"2)  obsolete nomenclature log")
 CALL text(8,4,"3)  changed terms import log")
 CALL text(9,4,"4)  new nomenclature import log")
 CALL text(10,4,"5)  drg extension log")
 CALL text(18,4,"99) Exit ")
 CALL text(21,4,"ENTER CHOICE (1,2,3...) ")
 CALL video(r)
 CALL video(n)
 CALL clear(24,02,35)
 SET doc = off
 CALL accept(21,28,"99;",99
  WHERE curaccept IN (1, 2, 3, 4, 5,
  50, 51, 52, 53, 99))
 CASE (curaccept)
  OF 1:
   CALL display_logfile("kia_obs_hcfa_pvterm.log",0)
  OF 2:
   CALL display_logfile("kia_obs_imp_hcfa_nomen.log",0)
  OF 3:
   CALL display_logfile("kia_imp_ins_hcfa_nomen.log",1)
  OF 4:
   CALL display_logfile("kia_imp_ins_hcfa_nomen.log",2)
  OF 5:
   CALL display_logfile("kia_imp_drg_ext.log",0)
  OF 50:
   CALL get_counts("HCFA")
  OF 51:
   CALL obs_report("HCFA")
  OF 52:
   CALL new_nomen_report("HCFA")
  OF 53:
   CALL ext_report("HCFA")
  OF 99:
   GO TO end_program
 ENDCASE
 IF (curscroll=1)
  GO TO accept_script
 ENDIF
 CALL clear(7,15,30)
 CALL clear(9,4,32)
 GO TO accept_script
#end_program
 SUBROUTINE check_script_status(logfile)
   DECLARE script_stat = c1 WITH public, noconstant("F")
   FREE DEFINE rtl2
   DEFINE rtl2 value(logfile)
   SELECT INTO "nl:"
    r.*
    FROM rtl2t r
    HEAD REPORT
     script_stat = "F"
    FOOT REPORT
     IF (((findstring("SUCCESS",cnvtupper(trim(r.line)),0)) OR (findstring("WARNING",cnvtupper(trim(r
        .line)),0))) )
      script_stat = "S"
     ENDIF
    WITH check
   ;end select
   RETURN(script_stat)
 END ;Subroutine
 SUBROUTINE display_logfile(logfile,log_instance)
   DECLARE breakpoint = i2 WITH public, noconstant(1)
   FREE DEFINE rtl2
   DEFINE rtl2 value(logfile)
   SELECT
    r.*
    FROM rtl2t r
    HEAD REPORT
     col 0, "Display log file: ", logfile,
     row + 2
    DETAIL
     IF (log_instance=0)
      log_line = substring(1,130,trim(r.line)), col 0, log_line,
      row + 1
     ELSEIF (findstring("END",cnvtupper(trim(r.line)),0)
      AND ((findstring("WARNING",cnvtupper(trim(r.line)),0)) OR (((findstring("SUCCESS",cnvtupper(
       trim(r.line)),0)) OR (findstring("FAILURE",cnvtupper(trim(r.line))))) )) )
      breakpoint = (breakpoint+ 1)
      IF ((breakpoint=(log_instance+ 1)))
       log_line = substring(1,130,trim(r.line)), col 0, log_line,
       row + 1, log_instance = (log_instance+ 2)
      ENDIF
     ELSEIF (breakpoint=log_instance)
      log_line = substring(1,130,trim(r.line)), col 0, log_line,
      row + 1
     ENDIF
    WITH check
   ;end select
 END ;Subroutine
 SUBROUTINE obs_report(vocab_mean)
   SELECT
    n.source_identifier, n.beg_effective_dt_tm, n.end_effective_dt_tm,
    n.source_string
    FROM nomenclature n,
     code_value cv
    PLAN (cv
     WHERE cv.cdf_meaning=vocab_mean
      AND cv.code_set=400)
     JOIN (n
     WHERE n.source_vocabulary_cd=cv.code_value
      AND n.end_effective_dt_tm=cnvtdatetime("31-DEC-2002")
      AND n.updt_id=0)
    ORDER BY n.source_identifier
    HEAD REPORT
     col 0, "OBSOLETE TERMS AND NOMEN REPORT", row + 2,
     source_id = fillstring(10," ")
    HEAD PAGE
     col 0, "SourceID", col 12,
     "BegDate", col 26, "EndDate",
     col 40, "SourceString", row + 2
    DETAIL
     source_id = substring(1,10,n.source_identifier), col 0, source_id,
     beg_dt = format(n.beg_effective_dt_tm,"dd-mmm-yyyy;;d"), col 12, beg_dt,
     end_dt = format(n.end_effective_dt_tm,"dd-mmm-yyyy;;d"), col 26, end_dt,
     col 40, n.source_string, row + 1
    FOOT  n.source_identifier
     row + 1
    WITH nocounter, maxcol = 500
   ;end select
 END ;Subroutine
 SUBROUTINE new_nomen_report(vocab_mean)
   SELECT
    n.source_identifier, n.beg_effective_dt_tm, n.end_effective_dt_tm,
    n.source_string
    FROM nomenclature n,
     code_value cv
    PLAN (cv
     WHERE cv.cdf_meaning=vocab_mean
      AND cv.code_set=400)
     JOIN (n
     WHERE n.source_vocabulary_cd=cv.code_value
      AND n.beg_effective_dt_tm=cnvtdatetime("01-JAN-2003")
      AND n.updt_id=0)
    ORDER BY n.source_identifier
    HEAD REPORT
     col 0, "NEW AND CHANGED TERMS REPORT", row + 2,
     source_id = fillstring(10," ")
    HEAD PAGE
     col 0, "SourceID", col 12,
     "BegDate", col 26, "EndDate",
     col 40, "SourceString", row + 2
    DETAIL
     source_id = substring(1,10,n.source_identifier), col 0, source_id,
     beg_dt = format(n.beg_effective_dt_tm,"dd-mmm-yyyy;;d"), col 12, beg_dt,
     end_dt = format(n.end_effective_dt_tm,"dd-mmm-yyyy;;d"), col 26, end_dt,
     col 40, n.source_string, row + 1
    FOOT  n.source_identifier
     row + 1
    WITH nocounter, maxcol = 500
   ;end select
 END ;Subroutine
 SUBROUTINE ext_report(vocab_mean)
   SELECT
    a.source_identifier, a.beg_effective_dt_tm, a.end_effective_dt_tm
    FROM apc_extension a
    WHERE a.beg_effective_dt_tm=cnvtdatetime("01-JAN-2003")
     AND a.updt_id=0
    ORDER BY a.source_identifier
    HEAD REPORT
     col 0, "EXTENSION REPORT", row + 2,
     source_id = fillstring(10," ")
    HEAD PAGE
     col 0, "SourceID", col 12,
     "BegDate", col 26, "EndDate",
     row + 2
    DETAIL
     source_id = substring(1,10,a.source_identifier), col 0, source_id,
     beg_dt = format(a.beg_effective_dt_tm,"dd-mmm-yyyy;;d"), col 12, beg_dt,
     end_dt = format(a.end_effective_dt_tm,"dd-mmm-yyyy;;d"), col 26, end_dt,
     row + 1
    FOOT  a.source_identifier
     row + 1
    WITH nocounter, maxcol = 500
   ;end select
 END ;Subroutine
 SUBROUTINE rel_report(vocab_mean)
   SELECT
    v.source_identifier, v.beg_effective_dt_tm, v.end_effective_dt_tm,
    v.related_vocab_cd, v.related_identifier
    FROM vocab_related_code v,
     code_value cv,
     code_value cv1
    PLAN (cv
     WHERE cv.cdf_meaning=vocab_mean
      AND cv.code_set=400)
     JOIN (v
     WHERE v.source_vocab_cd=cv.code_value
      AND v.beg_effective_dt_tm=cnvtdatetime("01-JAN-2003")
      AND v.updt_id=0)
     JOIN (cv1
     WHERE cv1.code_value=v.related_vocab_cd
      AND cv1.code_set=400)
    ORDER BY v.source_identifier
    HEAD REPORT
     col 0, "RELATED REPORT", row + 2,
     source_id = fillstring(10," ")
    HEAD PAGE
     col 0, "APC SourceID", col 16,
     "BegDate", col 30, "EndDate",
     col 44, "RelatedMean", col 58,
     "RelatedID", row + 2
    DETAIL
     source_id = substring(1,10,v.source_identifier), col 0, source_id,
     beg_dt = format(v.beg_effective_dt_tm,"dd-mmm-yyyy;;d"), col 16, beg_dt,
     end_dt = format(v.end_effective_dt_tm,"dd-mmm-yyyy;;d"), col 30, end_dt,
     rel_mean = trim(cv1.cdf_meaning), col 44, rel_mean,
     rel_id = substring(1,10,v.related_identifier), col 58, rel_id,
     row + 1
    FOOT  v.source_identifier
     row + 1
    WITH nocounter, maxcol = 500
   ;end select
 END ;Subroutine
 SUBROUTINE get_counts(vocab_mean)
   DECLARE vocab_cd = f8 WITH public, noconstant(0.0)
   DECLARE new_cnt = i4 WITH public, noconstant(0)
   DECLARE obs_cnt = i4 WITH public, noconstant(0)
   DECLARE ext_cnt = i4 WITH public, noconstant(0)
   DECLARE rel_cnt = i4 WITH public, noconstant(0)
   SELECT INTO "nl:"
    FROM code_value cv
    WHERE cv.cdf_meaning=vocab_mean
     AND cv.code_set=400
    DETAIL
     vocab_cd = cv.code_value
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM nomenclature n
    WHERE n.source_vocabulary_cd=vocab_cd
     AND n.beg_effective_dt_tm=cnvtdatetime("01-JAN-2003")
     AND n.updt_id=0
    DETAIL
     new_cnt = (new_cnt+ 1)
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    FROM nomenclature n
    WHERE n.source_vocabulary_cd=vocab_cd
     AND n.end_effective_dt_tm=cnvtdatetime("31-DEC-2002")
     AND n.updt_id=0
    DETAIL
     obs_cnt = (obs_cnt+ 1)
    WITH nocounter
   ;end select
   IF (vocab_mean="APC")
    SELECT INTO "nl:"
     FROM apc_extension a
     WHERE a.beg_effective_dt_tm=cnvtdatetime("01-JAN-2003")
      AND a.updt_id=0
     DETAIL
      ext_cnt = (ext_cnt+ 1)
     WITH nocounter
    ;end select
    SELECT INTO "nl:"
     FROM vocab_related_code v
     WHERE v.source_vocab_cd=vocab_cd
      AND v.beg_effective_dt_tm=cnvtdatetime("01-JAN-2003")
      AND v.updt_id=0
     DETAIL
      rel_cnt = (rel_cnt+ 1)
     WITH nocounter
    ;end select
   ENDIF
   SELECT
    FROM dual
    HEAD REPORT
     col 0, "Counts report:", row + 2
    DETAIL
     line1 = concat("New and changed terms: ",cnvtstring(new_cnt)), col 0, line1,
     row + 2, line2 = concat("Obs terms and nomen:   ",cnvtstring(obs_cnt)), col 0,
     line2, row + 2
     IF (vocab_mean="APC")
      line3 = concat("Extension:             ",cnvtstring(ext_cnt)), col 0, line3,
      row + 2, line4 = concat("Related                ",cnvtstring(rel_cnt)), col 0,
      line4, row + 2
     ENDIF
    WITH nocounter, maxcol = 500
   ;end select
 END ;Subroutine
END GO
