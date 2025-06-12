CREATE PROGRAM cclutil_filecnt2:dba
 PROMPT
  "Enter directory to count lines in files (cclsrc:*.c) : " = "cclsrc",
  "Enter file extensions (*.c,*.h,*.cpp) : " = "*.c,*.h,*.cpp"
 RECORD rec1(
   1 qual[*]
     2 fname = vc
 )
 DECLARE cmd = vc
 DECLARE stat1 = i4
 DECLARE stat2 = i4
 DECLARE cnt = i4
 DECLARE dname = vc
 DECLARE dlog = vc
 SET cmd = build2("dir/col=1/output=jcm.out ", $1,":", $2)
 SET stat1 = dcl(cmd,size(cmd),stat2)
 FREE DEFINE rtl
 DEFINE rtl "jcm.out"
 SELECT INTO nl
  FROM rtlt r
  WHERE r.line="*;*"
  HEAD REPORT
   cnt = 0
  DETAIL
   IF (mod(cnt,10)=0)
    stat1 = alterlist(rec1->qual,(cnt+ 10))
   ENDIF
   cnt += 1, rec1->qual[cnt].fname = substring(1,80,r.line)
  WITH nocounter
 ;end select
 SET stat1 = alterlist(rec1->qual,cnt)
 FREE DEFINE rtl
 SET total = 0
 SET com_line = 0
 FOR (num = 1 TO cnt)
   SET dname = build( $1,":",rec1->qual[num].fname)
   SET logical "dlog" value(dname)
   DEFINE rtl "dlog"
   SET xcnt = 0
   SELECT INTO nl
    FROM rtlt r
    WHERE r.line != " "
    HEAD REPORT
     state = 0
    DETAIL
     IF (state=0
      AND r.line="/\**")
      state = 1
     ENDIF
     IF (state=1
      AND r.line="*\*/*")
      state = 0
     ENDIF
     IF (state=0)
      xcnt += 1
     ELSE
      com_line += 1
     ENDIF
    WITH nocounter
   ;end select
   SET total += xcnt
   FREE DEFINE rtl
 ENDFOR
END GO
