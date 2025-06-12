CREATE PROGRAM ccldic_vms_unix_pre_merge:dba
 PROMPT
  "Show object names     (N): " = "N",
  "Converting dictionary to platform (AIX,AXP,HPX,LNX,WIN) : " = "AIX",
  "Filename with list of custom programs to export from : " = " "
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
 SET stat = remove("ccldictmp2.dat")
 SET testmode = 0
 SUBROUTINE swap(p_len,p_off)
   IF ((g_vmsrec->target_endian != g_vmsrec->source_endian))
    SET tmp = substring(p_off,p_len,buf)
    FOR (p_num = 1 TO p_len)
      SET stat = movestring(tmp,p_num,buf,(p_off+ (p_len - p_num)),1)
    ENDFOR
   ENDIF
 END ;Subroutine
 SET logical "CCLINFILE" value( $3)
 FREE DEFINE rtl
 DEFINE rtl "cclinfile"
 CALL echo(build("processing segment dprotect..."))
 SELECT INTO "ccldictmp2"
  d.datarec
  FROM (dgeneric d  WITH access_code = "5"),
   dprotect p,
   rtlt r
  PLAN (r
   WHERE substring(1,1,r.line) IN ("P", "E"))
   JOIN (p
   WHERE substring(1,1,r.line)=p.object
    AND substring(3,30,r.line)=p.object_name
    AND cnvtint(substring(34,2,r.line))=p.group
    AND p.group != 99)
   JOIN (d
   WHERE p.key1=d.key1)
  HEAD REPORT
   CALL echo("Processing..."), rcnt = 0
  DETAIL
   IF (rcnt > 0)
    row + 1
   ENDIF
   rcnt += 1
   IF (show_object=1)
    CALL echo(build(p.object,":",p.object_name,":",p.group))
   ENDIF
   buf = d.datarec,
   CALL swap(4,233),
   CALL swap(4,237),
   CALL swap(4,241),
   CALL swap(4,245),
   CALL swap(4,249),
   CALL swap(4,253),
   CALL swap(4,257),
   CALL swap(4,261),
   buf
  WITH counter, noformfeed, maxrow = 1,
   maxcol = 851, format = binary, append
 ;end select
 CALL echo(build(">>>dprotect=",curqual))
 CALL echo(build("processing segment dcompile..."))
 SELECT
  IF ((g_vmsrec->source_endian=0))
   ORDER BY grp, ichar(substring(40,1,d.key1)), ichar(substring(39,1,d.key1))
  ELSE
   ORDER BY grp, ichar(substring(39,1,d.key1)), ichar(substring(40,1,d.key1))
  ENDIF
  INTO "ccldictmp2"
  grp = concat(substring(1,37,d.key1),format(p.group,"###;rp0")), d.datarec
  FROM (dgeneric d  WITH access_code = "9"),
   dprotect p,
   rtlt r
  PLAN (r
   WHERE substring(1,1,r.line) IN ("P", "E"))
   JOIN (p
   WHERE substring(1,1,r.line)=p.object
    AND substring(3,30,r.line)=p.object_name
    AND cnvtint(substring(34,2,r.line))=p.group
    AND p.group != 99)
   JOIN (d
   WHERE concat("H00009P",substring(8,30,p.key1),substring(38,1,p.key1),char(0),char(0)) <= d.key1
    AND concat("H00009P",substring(8,30,p.key1),substring(38,1,p.key1),char(255),char(255)) >= d.key1
    AND ichar(substring(38,1,d.key1))=p.group)
  HEAD REPORT
   CALL echo("Processing..."), rcnt = 0
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
       CALL swap(2,39)
       IF (rcnt > 0)
        row + 1
       ENDIF
       rcnt += 1, buf
     ENDFOR
    ELSE
     CALL echo(build("Object:",p.object_name," corrupt and will be skipped"))
    ENDIF
   ELSE
    FOR (num2 = 1 TO num)
      buf = rec1->qual[num2].buf
      IF (rcnt > 0)
       row + 1
      ENDIF
      rcnt += 1, buf
    ENDFOR
   ENDIF
  WITH counter, noformfeed, maxrow = 1,
   maxcol = 851, format = binary, append,
   filesort
 ;end select
 CALL echo(build(">>>dcompile=",curqual))
 FREE DEFINE rtl
END GO
