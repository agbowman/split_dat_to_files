CREATE PROGRAM bhs_ma_script_scanner:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE"
  WITH outdev
 FREE RECORD rpt_data
 RECORD rpt_data(
   1 qual[*]
     2 object_name = vc
     2 group = i2
     2 user_name = vc
 )
 FREE RECORD found_dcl
 RECORD found_dcl(
   1 qual[*]
     2 object_name = vc
     2 group = i2
     2 line = vc
     2 user_name = vc
     2 skip = i2
 )
 DECLARE cnt = i4 WITH protect, noconstant(0)
 DECLARE cntd = i4 WITH protect, noconstant(0)
 DECLARE cntf = i4 WITH protect, noconstant(0)
 DECLARE cntm = i4 WITH protect, noconstant(0)
 DECLARE cntr = i4 WITH protect, noconstant(0)
 DECLARE cntn = i4 WITH protect, noconstant(0)
 DECLARE my_file = vc WITH protect, constant("ccluserdir:temp_file.ccl")
 DECLARE object_exists = i2 WITH protect, noconstant(0)
 DECLARE temp_string = vc WITH protect, noconstant("")
 DECLARE search_string = vc WITH protect, noconstant("")
 DECLARE previous_line = vc WITH protect, noconstant("")
 DECLARE ocnt = i4 WITH protect, noconstant(0)
 DECLARE ecnt = i4 WITH protect, noconstant(0)
 DECLARE errcode = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect
 DECLARE tempfile2 = vc WITH protect, constant(build(concat("ccluserdir:uc_review_list_translated"),
   ".dat"))
 DECLARE object_name = vc WITH protect, noconstant("")
 SELECT DISTINCT INTO "nl:"
  dp.object_name
  FROM dprotect dp
  PLAN (dp
   WHERE dp.object="P"
    AND dp.object_name="BHS*")
  HEAD REPORT
   cnt = 0
  DETAIL
   cnt += 1
   IF (mod(cnt,100)=1)
    stat = alterlist(rpt_data->qual,(cnt+ 99))
   ENDIF
   rpt_data->qual[cnt].object_name = dp.object_name, rpt_data->qual[cnt].group = dp.group, rpt_data->
   qual[cnt].user_name = dp.user_name
  FOOT REPORT
   stat = alterlist(rpt_data->qual,cnt)
  WITH nocounter
 ;end select
 SET cnt = 0
 SET cntd = 0
 SET cntm = 0
 SET cntf = 0
 SET cntr = 0
 SET cntn = 0
 SET oknt = 0
 FOR (fidx = 1 TO size(rpt_data->qual,5))
   SET object_name = rpt_data->qual[fidx].object_name
   SET object_exists = checkdic(value(object_name),"P",0)
   IF (object_exists=2)
    IF (subcompilecheckmatch(object_name,rpt_data->qual[fidx].group))
     TRANSLATE INTO value(my_file) value(object_name)
     SET errcode = error(errmsg,1)
     IF (errcode != 0)
      SET ecnt += 1
      IF (ecnt > size(rdatalocked->qual,5))
       SET stat = alterlist(rdatalocked->qual,ecnt)
      ENDIF
      SET rdatalocked->qual[ecnt].errmsg = concat("Failed to translate"," ",value(object_name),":",
       errmsg)
      SET rdatalocked->qual[ecnt].object_name = object_name
     ELSE
      FREE DEFINE rtl2
      SET logical cclfilein value(my_file)
      DEFINE rtl2 "cclfilein"
      SELECT INTO "nl:"
       FROM rtl2t r2
       HEAD REPORT
        temp_string = "", search_string = "", previous_line = ""
       DETAIL
        temp_string = r2.line, search_string = concat(previous_line,temp_string)
        IF (findstring(".birth_dt_tm",cnvtlower(search_string))
         AND  NOT (findstring("CNVTDATETIMEUTC",cnvtupper(search_string))))
         stat = alterlist(found_dcl->qual,(cntd+ 1)), cntd += 1, found_dcl->qual[cntd].object_name =
         rpt_data->qual[fidx].object_name,
         found_dcl->qual[cntd].group = rpt_data->qual[fidx].group, found_dcl->qual[cntd].line =
         search_string, found_dcl->qual[cntd].user_name = rpt_data->qual[fidx].user_name,
         found_dcl->qual[cntd].skip = 0
        ENDIF
        previous_line = temp_string
       WITH nocounter
      ;end select
     ENDIF
    ELSE
     SET ecnt += 1
     IF (ecnt > size(rdatalocked->qual,5))
      SET stat = alterlist(rdatalocked->qual,(ecnt+ 9))
     ENDIF
     SET rdatalocked->qual[ecnt].errmsg = concat("Failed to translate"," ",value(object_name),": ",
      "Binary Count and Compile Count Do Not Match")
     SET rdatalocked->qual[ecnt].object_name = object_name
    ENDIF
   ENDIF
 ENDFOR
 SELECT INTO  $OUTDEV
  object_name = substring(1,40,found_dcl->qual[d.seq].object_name), found_line = substring(1,200,
   found_dcl->qual[d.seq].line)
  FROM (dummyt d  WITH seq = size(found_dcl->qual,5))
  PLAN (d)
  WITH format, separator = " "
 ;end select
 SUBROUTINE (subcompilecheckmatch(stheobject=vc,ithegroup=i2) =i2)
   DECLARE ibinarycnt = i4 WITH protect, noconstant(0)
   DECLARE icompilecnt = i4 WITH protect, noconstant(0)
   SELECT INTO "nl:"
    brk = concat(p.object,p.object_name,format(p.group,"##;rp0")), p.object, p.object_name,
    p.binary_cnt
    FROM dprotect p,
     dcompile c
    PLAN (p
     WHERE p.object="P"
      AND p.object_name=cnvtupper(stheobject)
      AND p.group=ithegroup)
     JOIN (c
     WHERE "P"=c.object
      AND p.object_name=c.object_name
      AND p.group=c.group)
    ORDER BY brk, c.qual
    HEAD REPORT
     icompilecnt = 0, ibinarycnt = 0
    HEAD brk
     icompilecnt = 0
    DETAIL
     icompilecnt += 1
    FOOT  brk
     ibinarycnt = p.binary_cnt
    WITH counter, outerjoin = p, filesort
   ;end select
   IF (ibinarycnt=icompilecnt)
    RETURN(1)
   ELSE
    RETURN(0)
   ENDIF
 END ;Subroutine
#exit_script
 SET last_mod = "002 06/03/16 Handle Translate Core Dump"
END GO
