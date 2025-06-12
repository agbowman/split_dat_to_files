CREATE PROGRAM ccl_rtl_memcost:dba
 PROMPT
  "Enter output device= " = "MINE",
  "Enter input rtl file= " = "",
  "Begin datestamp on cost line= " = "180101",
  "End datestamp on cost line= " = "180102"
  WITH outdev, infile, begindate,
  enddate
 DECLARE inputfile = vc
 DECLARE _datestamp = c7
 DECLARE _datestamp2 = c7
 DECLARE _begindate = c6 WITH constant( $BEGINDATE)
 DECLARE _enddate = c6 WITH constant( $ENDDATE)
 DECLARE _beginmonth = c4 WITH constant(substring(1,4,_begindate))
 DECLARE _endmonth = c4 WITH constant(substring(1,4,_enddate))
 SET inputfile = cnvtlower(trim( $2))
 SET _datestamp = concat(trim(_begindate),":")
 SET _datestamp2 = concat(trim(_enddate),":")
 CALL echo(build("inputfile= ",inputfile,", Begin date= ",_begindate,", End date= ",
   _enddate))
 DECLARE min_freepages_diff = i4 WITH constant(50)
 DECLARE max_freepages_diff = i4 WITH constant(1000000)
 DECLARE freepages_curr = w8
 DECLARE freepages_last = w8
 DECLARE nprogs = i4 WITH noconstant(0)
 DECLARE nprogcnt = i4 WITH noconstant(0)
 DECLARE nprogs_fp = i4 WITH noconstant(0)
 DECLARE nfind = i4
 DECLARE nfindcomma = i4
 DECLARE nfindparen = i4
 DECLARE elapsed_str = vc
 DECLARE slastprogs = vc
 DECLARE sprogram = vc
 DECLARE nmemdiff = i4
 RECORD progs_fp(
   1 qual[*]
     2 progstr = vc
     2 freepages_curr = w8
     2 freepages_diff = i4
     2 prg_cnt = i4
     2 rng_cnt = i4
 )
 RECORD progs(
   1 qual[*]
     2 progstr = vc
     2 num_exec = i4
     2 total_ela = f8
     2 freepages_diff_sum = i4
     2 freepages_diff_max = i4
     2 freepages_list = vc
 )
 RECORD progs_mem(
   1 freepages_begin = w8
   1 freepages_end = w8
   1 qual[*]
     2 progstr = vc
     2 num_exec = i4
     2 total_ela = f8
     2 freepages_diff_sum = i4
     2 freepages_diff_max = i4
     2 freepages_list = vc
 )
 FREE DEFINE rtl
 SET logical costfile value( $INFILE)
 DEFINE rtl "COSTFILE"
 SELECT INTO  $OUTDEV
  r.line
  FROM rtlt r
  HEAD REPORT
   fpcnt = 0, x = 0, nprogexists = 0
  DETAIL
   nfind = 0, nmatch = 0, x = 0,
   baddprog = 0
   IF (substring(1,14,r.line)="CCLSET_DBRESET")
    slastprogs = " ", nmemdiff = 0
   ENDIF
   IF (((substring(1,7,r.line)=_datestamp) OR (((substring(1,7,r.line)=_datestamp2) OR (((substring(1,
    4,r.line)=_beginmonth) OR (substring(1,4,r.line)=_endmonth)) )) )) )
    sprogram = trim(substring(15,30,r.line))
    IF (((sprogram="REPORTRTL") OR (((sprogram="CPM_CREATE_FILE_NAME") OR (((sprogram=
    "CCL_TOKENSCANNER") OR (((sprogram="CCL_CREATECPC") OR (((sprogram="MSGRTL") OR (sprogram=
    "CCLAUDIT")) )) )) )) )) )
     baddprog = 0
    ELSE
     baddprog = 1
    ENDIF
    IF (baddprog=1)
     nfind = findstring(sprogram,slastprogs,1,0)
     IF (nfind=0)
      IF (textlen(slastprogs) > 1)
       slastprogs = build(slastprogs,", ",sprogram)
      ELSE
       slastprogs = sprogram
      ENDIF
     ENDIF
    ENDIF
   ENDIF
   IF (((substring(1,10,r.line)="FreePages2") OR (substring(1,10,r.line)="FreePages1")) )
    fpcnt += 1
    IF (mod(fpcnt,100)=1)
     stat = alterlist(progs_fp->qual,(fpcnt+ 99))
    ENDIF
    progs_fp->qual[fpcnt].progstr = slastprogs, nfindcomma = findstring(",",r.line,1,0), nfindparen
     = findstring(")",r.line,1,0),
    freepages_curr = cnvtint(substring(12,(nfindcomma - 12),r.line))
    IF (fpcnt=1)
     progs_mem->freepages_begin = freepages_curr
    ENDIF
    progs_fp->qual[fpcnt].freepages_curr = freepages_curr, freepages_last = freepages_curr
    IF (nfindcomma > 0
     AND nfindparen > 0)
     nmemdiff = cnvtint(substring((nfindcomma+ 1),((nfindparen - nfindcomma) - 1),r.line))
     IF (nmemdiff > 0)
      progs_fp->qual[fpcnt].freepages_diff = nmemdiff
     ENDIF
    ENDIF
    nfind = findstring("Prg(",r.line,1,0)
    IF (nfind > 0)
     nfindparen = findstring(")",r.line,nfind,0)
    ENDIF
   ENDIF
  FOOT REPORT
   stat = alterlist(progs_fp->qual,fpcnt)
  WITH nocounter
 ;end select
 SET progs_mem->freepages_end = freepages_last
 CALL echorecord(progs_fp)
 SET nprogs_fp = size(progs_fp->qual,5)
 FOR (x = 1 TO nprogs_fp)
   IF ((progs_fp->qual[x].freepages_diff > min_freepages_diff))
    IF ((progs_fp->qual[x].freepages_curr < progs_fp->qual[(x+ 1)].freepages_curr)
     AND (progs_fp->qual[x].freepages_curr < progs_fp->qual[(x+ 2)].freepages_curr))
     CALL echo(build("For loop (EXCLUDE PRG), progstr= ",progs_fp->qual[x].progstr,
       ", freepages_diff= ",progs_fp->qual[x].freepages_diff,", freepages_curr= ",
       progs_fp->qual[x].freepages_curr,", [x+1].freepages_curr= ",progs_fp->qual[(x+ 1)].
       freepages_curr,", [x+2].freepages_curr= ",progs_fp->qual[(x+ 2)].freepages_curr))
    ELSE
     CALL echo(build("For loop (ADD PRG), progstr= ",progs_fp->qual[x].progstr,", freepages_diff= ",
       progs_fp->qual[x].freepages_diff,", freepages_curr= ",
       progs_fp->qual[x].freepages_curr,", progs_fp->qual[x + 1].freepages_curr= ",progs_fp->qual[(x
       + 1)].freepages_curr))
     SET nprogs = size(progs->qual,5)
     SET bprogexists = 0
     FOR (z = 1 TO nprogs)
       IF ((progs->qual[z].progstr=progs_fp->qual[x].progstr))
        SET progs->qual[z].num_exec += 1
        SET progs->qual[z].freepages_diff_sum += progs_fp->qual[x].freepages_diff
        IF ((progs->qual[z].num_exec=1))
         SET progs->qual[z].freepages_list = build(progs_fp->qual[x].freepages_diff)
        ELSE
         SET progs->qual[z].freepages_list = build(progs->qual[z].freepages_list,",",progs_fp->qual[x
          ].freepages_diff)
        ENDIF
        SET bprogexists = 1
        IF ((progs_fp->qual[x].freepages_diff > progs->qual[z].freepages_diff_max))
         SET progs->qual[z].freepages_diff_max = progs_fp->qual[x].freepages_diff
        ENDIF
       ENDIF
     ENDFOR
    ENDIF
    IF (bprogexists=0)
     SET nprogcnt += 1
     SET stat = alterlist(progs->qual,nprogcnt)
     SET z = nprogcnt
     SET progs->qual[z].progstr = progs_fp->qual[x].progstr
     SET progs->qual[z].num_exec = 1
     SET progs->qual[z].freepages_diff_sum = progs_fp->qual[x].freepages_diff
     SET progs->qual[z].freepages_diff_max = progs_fp->qual[x].freepages_diff
    ENDIF
   ENDIF
 ENDFOR
 SET nprogs = size(progs->qual,5)
 FOR (x = 1 TO nprogs)
   IF ((progs->qual[x].num_exec > 1)
    AND (progs->qual[x].freepages_diff_sum > min_freepages_diff))
    SET stat = movereclist(progs->qual,progs_mem->qual,x,size(progs_mem->qual,5),1,
     true)
   ENDIF
 ENDFOR
 CALL echo("Summary of transactions and FreePages usage...")
 CALL echorecord(progs)
 CALL echo("Summary of transactions with > 1 execution...")
 CALL echorecord(progs_mem)
 SELECT INTO "noforms"
  numexec = progs_mem->qual[d1.seq].num_exec, freepages_diff_total = progs_mem->qual[d1.seq].
  freepages_diff_sum, freepages_diff_max = progs_mem->qual[d1.seq].freepages_diff_max,
  prog_names = substring(1,80,progs_mem->qual[d1.seq].progstr)
  FROM (dummyt d1  WITH seq = value(size(progs_mem->qual,5)))
  WHERE (progs_mem->qual[d1.seq].num_exec > 1)
  ORDER BY progs_mem->qual[d1.seq].freepages_diff_sum DESC
  WITH nocounter
 ;end select
 CALL echo(build("Freepages begin: ",progs_mem->freepages_begin))
 CALL echo(build("Freepages end  : ",progs_mem->freepages_end))
 CALL echo(build("Freepages diff : ",(progs_mem->freepages_begin - progs_mem->freepages_end)))
END GO
