CREATE PROGRAM ccllabel:dba
 SET reclen_label = 0
 SET reclen_qmlpm = 0
 SET reclen_qmmlm = 0
 SET reclen_qmblm = 0
 SELECT INTO "NL:"
  f.max_reclen
  FROM dfile f
  WHERE f.file_name IN ("LABEL", "QMLPM", "QMMLM", "QMBLM")
  DETAIL
   CASE (f.file_name)
    OF "LABEL":
     reclen_label = (f.max_reclen+ 1)
    OF "QMLPM":
     reclen_qmlpm = (f.max_reclen+ 1)
    OF "QMMLM":
     reclen_qmmlm = (f.max_reclen+ 1)
    OF "QMBLM":
     reclen_qmblm = (f.max_reclen+ 1)
   ENDCASE
  WITH nocounter
 ;end select
 SELECT INTO "CCLDIR:LABEL"
  dummyt.seq
  FROM dummyt
  DETAIL
   FOR (num = 1 TO (reclen_label - 1))
     " "
   ENDFOR
  WITH maxrow = 1, maxcol = value(reclen_label), noformfeed,
   format = variable
 ;end select
 SELECT INTO "CCLDIR:QMLPM"
  dummyt.seq
  FROM dummyt
  DETAIL
   FOR (num = 1 TO (reclen_qmlpm - 1))
     " "
   ENDFOR
  WITH maxrow = 1, maxcol = value(reclen_qmlpm), noformfeed,
   format = variable
 ;end select
 SELECT INTO "CCLDIR:QMMLM"
  dummyt.seq
  FROM dummyt
  DETAIL
   FOR (num = 1 TO (reclen_qmmlm - 1))
     " "
   ENDFOR
  WITH maxrow = 1, maxcol = value(reclen_qmmlm), noformfeed,
   format = variable
 ;end select
 SELECT INTO "CCLDIR:QMBLM"
  dummyt.seq
  FROM dummyt
  DETAIL
   FOR (num = 1 TO (reclen_qmblm - 1))
     " "
   ENDFOR
  WITH maxrow = 1, maxcol = value(reclen_qmblm), noformfeed,
   format = variable
 ;end select
END GO
