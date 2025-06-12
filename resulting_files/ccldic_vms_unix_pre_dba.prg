CREATE PROGRAM ccldic_vms_unix_pre:dba
 PROMPT
  "Show object names     (N): " = "N",
  "Converting dictionary to platform (AIX,AXP,HPX,LNX,WIN) : " = "AIX"
 DECLARE swap(p1,p2) = null
 RECORD g_vmsrec(
   1 stat = i4
   1 target_endian = i4
   1 source_endian = i4
 )
 SET g_vmsrec->stat = 0
 CASE (cursys2)
  OF "AIX":
   SET g_vmsrec->source_endian = 1
  OF "HPX":
   SET g_vmsrec->source_endian = 1
  OF "LNX":
   SET g_vmsrec->source_endian = 0
  OF "WIN":
   SET g_vmsrec->source_endian = 0
  OF "AXP":
   SET g_vmsrec->source_endian = 0
  ELSE
   CALL echo("Unsupported source to convert")
   RETURN
 ENDCASE
 CASE (cnvtupper( $2))
  OF "AIX":
   SET g_vmsrec->target_endian = 1
  OF "HPX":
   SET g_vmsrec->target_endian = 1
  OF "LNX":
   SET g_vmsrec->target_endian = 0
  OF "WIN":
   SET g_vmsrec->target_endian = 0
  OF "AXP":
   SET g_vmsrec->target_endian = 0
  ELSE
   CALL echo("Enter 'AIX' or 'AXP' or 'HPX' or 'LNX' or 'WIN' ")
   RETURN
 ENDCASE
 SET g_vmsrec->stat = 1
 SET logical "SHRCCLDICUTIL" "CER_EXE:SHRCCLDICUTIL.EXE"
 DECLARE show_object = i4
 IF (cnvtupper( $1)="Y")
  SET show_object = 1
 ELSE
  SET show_object = 0
 ENDIF
 DECLARE uar_ccldicutil_vmstounix(p1=vc(ref),p2=i4(value),p3=i4(value)) = i4 WITH image_axp =
 "shrccldicutil", image_aix = "libccldicutil.a(shobjccldicutil.o)", image_win = "shrccldicutil",
 uar = "ccldicutil_vmstounix"
 SET bufmax = 5000
 RECORD rec1(
   1 qual[5000]
     2 buf = c850
 )
 DECLARE varsource = vc
 CALL echo(build2(">>>Creating ccldictmp.dat file from ",cursys2," ccldir:dic.dat to use for ",
   cnvtupper( $2)," dictionary"))
 CALL echo(build2(">>>Endian from ",evaluate(g_vmsrec->source_endian,0,"little","big")," to ",
   evaluate(g_vmsrec->target_endian,0,"little","big")))
 EXECUTE ccldic_vms_unix_check
 DECLARE buf = c850
 DECLARE tmp = c4
 DECLARE num = i4
 SET stat = remove("ccldictmp.dat")
 SET testmode = 0
 SUBROUTINE swap(p_len,p_off)
   IF ((g_vmsrec->target_endian != g_vmsrec->source_endian))
    SET tmp = substring(p_off,p_len,buf)
    FOR (p_num = 1 TO p_len)
      SET stat = movestring(tmp,p_num,buf,(p_off+ (p_len - p_num)),1)
    ENDFOR
   ENDIF
 END ;Subroutine
 SET segnum = 1
 CALL echo(build(segnum," of 10)processing segment dfile..."))
 CALL echo("Processing...")
 SELECT INTO "ccldictmp"
  d.datarec
  FROM (dgeneric d  WITH access_code = "1")
  DETAIL
   buf = d.datarec,
   CALL swap(4,61),
   CALL swap(4,65),
   CALL swap(2,103), off = 106
   FOR (num = 1 TO 7)
     CALL swap(2,off),
     CALL swap(2,(off+ 2)), off += 5
   ENDFOR
   buf, row + 1
  WITH counter, noformfeed, maxrow = 1,
   maxcol = 851, format = binary
 ;end select
 CALL echo(build(">>>dfile=",curqual))
 IF (testmode=0)
  SET segnum += 1
  CALL echo(build(segnum," of 10)processing segment drectyp..."))
  CALL echo("Processing...")
  SELECT INTO "ccldictmp"
   d.datarec
   FROM (dgeneric d  WITH access_code = "2")
   DETAIL
    buf = d.datarec,
    CALL swap(4,65),
    CALL swap(4,69),
    CALL swap(2,73),
    CALL swap(2,75), off = 77
    FOR (num = 1 TO 10)
      CALL swap(2,(off+ 20)),
      CALL swap(2,(off+ 55)),
      CALL swap(2,(off+ 58)),
      CALL swap(2,(off+ 60)),
      CALL swap(2,(off+ 64)),
      CALL swap(2,(off+ 66)),
      CALL swap(2,(off+ 68)),
      CALL swap(2,(off+ 70)),
      CALL swap(2,(off+ 72)),
      CALL swap(2,(off+ 74)), off += 76
    ENDFOR
    buf, row + 1
   WITH counter, noformfeed, maxrow = 1,
    maxcol = 851, format = binary, append
  ;end select
  CALL echo(build(">>>drectyp=",curqual))
  SET segnum += 1
  CALL echo(build(segnum," of 10)processing segment dtable..."))
  CALL echo("Processing...")
  SELECT INTO "ccldictmp"
   d.datarec
   FROM (dgeneric d  WITH access_code = "3")
   DETAIL
    buf = d.datarec,
    CALL swap(4,41),
    CALL swap(4,45),
    CALL swap(2,49),
    CALL swap(2,88),
    CALL swap(2,617),
    off = 620
    FOR (num = 1 TO 10)
      CALL swap(2,(off+ 0)),
      CALL swap(2,(off+ 2)),
      CALL swap(2,(off+ 4)),
      CALL swap(2,(off+ 6)), off += 8
    ENDFOR
    buf, row + 1
   WITH counter, noformfeed, maxrow = 1,
    maxcol = 851, format = binary, append
  ;end select
  CALL echo(build(">>>dtable=",curqual))
  SET segnum += 1
  CALL echo(build(segnum," of 10)processing segment dtableattr..."))
  CALL echo("Processing...")
  SELECT INTO "ccldictmp"
   d.datarec
   FROM (dgeneric d  WITH access_code = "4")
   DETAIL
    buf = d.datarec, off = 41
    FOR (num = 1 TO 15)
      CALL swap(2,(off+ 31)),
      CALL swap(2,(off+ 33)),
      CALL swap(2,(off+ 37)),
      CALL swap(2,(off+ 47)),
      CALL swap(2,(off+ 49)), off += 52
    ENDFOR
    buf, row + 1
   WITH counter, noformfeed, maxrow = 1,
    maxcol = 851, format = binary, append
  ;end select
  CALL echo(build(">>>dtableattr=",curqual))
  SET segnum += 1
  CALL echo(build(segnum," of 10)processing segment dprotect..."))
  CALL echo("Processing...")
  SELECT INTO "ccldictmp"
   d.datarec
   FROM (dgeneric d  WITH access_code = "5")
   WHERE ichar(substring(32,1,d.rest)) != 99
   DETAIL
    buf = d.datarec,
    CALL swap(4,233),
    CALL swap(4,237),
    CALL swap(4,241),
    CALL swap(4,245),
    CALL swap(4,249),
    CALL swap(4,253),
    CALL swap(4,257),
    CALL swap(4,261),
    stat = movestring(fillstring(8,char(0)),1,buf,265,8), stat = movestring(fillstring(15," "),1,buf,
     273,15), buf,
    row + 1
   WITH counter, noformfeed, maxrow = 1,
    maxcol = 851, format = binary, append
  ;end select
  CALL echo(build(">>>dprotect=",curqual))
  SET segnum += 1
  CALL echo(build(segnum," of 10)processing segment duaf..."))
  CALL echo("Processing...")
  SELECT INTO "ccldictmp"
   d.datarec
   FROM (dgeneric d  WITH access_code = "6")
   DETAIL
    buf = d.datarec,
    CALL swap(4,54),
    CALL swap(4,58),
    CALL swap(4,62),
    CALL swap(4,66), buf,
    row + 1
   WITH counter, noformfeed, maxrow = 1,
    maxcol = 851, format = binary, append
  ;end select
  CALL echo(build(">>>duaf=",curqual))
  SET segnum += 1
  CALL echo(build(segnum," of 10)processing segment dtam..."))
  CALL echo("Processing...")
  SELECT INTO "ccldictmp"
   d.datarec
   FROM (dgeneric d  WITH access_code = "7")
   DETAIL
    buf = d.datarec, off = 416
    FOR (num = 1 TO 13)
     CALL swap(2,off),off += 2
    ENDFOR
    buf, row + 1
   WITH counter, noformfeed, maxrow = 1,
    maxcol = 851, format = binary, append
  ;end select
  CALL echo(build(">>>dtam=",curqual))
  SET segnum += 1
  CALL echo(build(segnum," of 10)processing segment dgen..."))
  CALL echo("Processing...")
  SELECT INTO "ccldictmp"
   d.datarec
   FROM (dgeneric d  WITH access_code = "8")
   DETAIL
    buf = d.datarec,
    CALL swap(4,41), buf,
    row + 1
   WITH counter, noformfeed, maxrow = 1,
    maxcol = 851, format = binary, append
  ;end select
 ENDIF
 CALL echo(build(">>>dgen=",curqual))
 DECLARE xcnt = i4
 DECLARE binary_cnt_begin = i4
 DECLARE binary_cnt_end = i4
 FOR (xcnt = 1 TO 2)
   SET segnum += 1
   CASE (xcnt)
    OF 1:
     SET binary_cnt_begin = 0
     SET binary_cnt_end = 255
    OF 2:
     SET binary_cnt_begin = 256
     SET binary_cnt_end = 1000000
   ENDCASE
   CALL echo(build(segnum," of 10)processing segment dcompile",xcnt,"..."))
   CALL echo("Processing...")
   SELECT
    IF (xcnt=2
     AND (g_vmsrec->source_endian=0))
     ORDER BY grp, ichar(substring(40,1,d.key1)), ichar(substring(39,1,d.key1))
    ELSE
    ENDIF
    INTO "ccldictmp"
    grp = concat(substring(1,37,d.key1),format(p.group,"###;rp0")), d.datarec
    FROM (dgeneric d  WITH access_code = "9"),
     dprotect p
    PLAN (p
     WHERE p.object IN ("E", "M", "P", "V")
      AND p.object_name="*"
      AND p.group != 99
      AND p.binary_cnt BETWEEN binary_cnt_begin AND binary_cnt_end)
     JOIN (d
     WHERE concat("H00009P",substring(8,30,p.key1),substring(38,1,p.key1),char(0),char(0)) <= d.key1
      AND concat("H00009P",substring(8,30,p.key1),substring(38,1,p.key1),char(255),char(255)) >= d
     .key1
      AND ichar(substring(38,1,d.key1))=p.group)
    HEAD grp
     num = 0, overflow = 0
    DETAIL
     num += 1
     IF (num < bufmax)
      rec1->qual[num].buf = d.datarec
     ELSE
      overflow = 1
     ENDIF
    FOOT  grp
     IF (overflow=1)
      CALL echo(build("Object:",p.object_name," exceeds ",bufmax," records, will be skipped"))
     ELSEIF (num != p.binary_cnt)
      CALL echo(build("Object:",p.object_name," dcompile=",num," does not match dprotect=",
       p.binary_cnt,", will be skipped"))
     ELSEIF ((g_vmsrec->target_endian != g_vmsrec->source_endian))
      stat = uar_ccldicutil_vmstounix(rec1,num,show_object)
      IF (stat)
       FOR (num2 = 1 TO num)
         buf = rec1->qual[num2].buf,
         CALL swap(2,39), buf,
         row + 1
       ENDFOR
      ELSE
       CALL echo(build("Object:",p.object_name," corrupt and will be skipped"))
      ENDIF
     ELSE
      FOR (num2 = 1 TO num)
        buf = rec1->qual[num2].buf, buf, row + 1
      ENDFOR
     ENDIF
    WITH counter, noformfeed, maxrow = 1,
     maxcol = 851, format = binary, append,
     filesort
   ;end select
   CALL echo(build(">>>dcompile",xcnt,"=",curqual))
 ENDFOR
END GO
