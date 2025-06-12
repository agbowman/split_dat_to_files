CREATE PROGRAM bhs_athn_get_severity_items
 FREE RECORD result
 RECORD result(
   1 severity_class[*]
     2 code_value = f8
     2 display = vc
     2 meaning = vc
     2 severity[*]
       3 code_value = f8
       3 display = vc
       3 meaning = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req963007
 RECORD req963007(
   1 vocab[*]
     2 source_vocabulary_cd = f8
     2 code_set = f8
 ) WITH protect
 FREE RECORD rep963007
 RECORD rep963007(
   1 vocab_qual = i2
   1 vocab[*]
     2 source_vocabulary_cd = f8
     2 group_qual = i2
     2 group[*]
       3 child_code_value = f8
       3 child_cd = f8
       3 child_disp = vc
       3 child_mean = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callgetnomenaxis(null) = i4
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE jdx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE errmsg = vc WITH protect, noconstant("")
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 SET result->status_data.status = "F"
 DECLARE class_cnt = i4 WITH protect, noconstant(0)
 SELECT INTO "NL:"
  FROM code_value cv
  PLAN (cv
   WHERE cv.code_set=29743
    AND cv.active_ind=1)
  ORDER BY cv.display
  HEAD cv.code_value
   class_cnt = (class_cnt+ 1), stat = alterlist(result->severity_class,class_cnt), result->
   severity_class[class_cnt].code_value = cv.code_value,
   result->severity_class[class_cnt].display = cv.display, result->severity_class[class_cnt].meaning
    = cv.cdf_meaning
  WITH nocounter, time = 30
 ;end select
 SET stat = callgetnomenaxis(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v0 = vc WITH protect, noconstant("")
  DECLARE v1 = vc WITH protect, noconstant("")
  DECLARE v2 = vc WITH protect, noconstant("")
  DECLARE v3 = vc WITH protect, noconstant("")
  DECLARE v4 = vc WITH protect, noconstant("")
  DECLARE v5 = vc WITH protect, noconstant("")
  DECLARE v6 = vc WITH protect, noconstant("")
  SELECT INTO value(moutputdevice)
   FROM (dummyt d  WITH seq = value(1))
   PLAN (d
    WHERE d.seq > 0)
   HEAD REPORT
    html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
     '"',"UTF-8",'"'," ?>"), col 0, html_tag,
    row + 1, col + 1, "<ReplyMessage>",
    row + 1, v0 = build("<Status>",result->status_data.status,"</Status>"), col + 1,
    v0, row + 1
   DETAIL
    col + 1, "<SeverityClasses>", row + 1
    FOR (idx = 1 TO size(result->severity_class,5))
      col + 1, "<SeverityClass>", row + 1,
      v1 = build("<SeverityClassCd>",cnvtint(result->severity_class[idx].code_value),
       "</SeverityClassCd>"), col + 1, v1,
      row + 1, v2 = build("<SeverityClassDisp>",trim(replace(replace(replace(replace(replace(result->
             severity_class[idx].display,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
         '"',"&quot;",0),3),"</SeverityClassDisp>"), col + 1,
      v2, row + 1, v3 = build("<SeverityClassMean>",trim(replace(replace(replace(replace(replace(
             result->severity_class[idx].meaning,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
          "&apos;",0),'"',"&quot;",0),3),"</SeverityClassMean>"),
      col + 1, v3, row + 1,
      col + 1, "<Severities>", row + 1
      FOR (jdx = 1 TO size(result->severity_class[idx].severity,5))
        col + 1, "<Severity>", row + 1,
        v4 = build("<SeverityCd>",cnvtint(result->severity_class[idx].severity[jdx].code_value),
         "</SeverityCd>"), col + 1, v4,
        row + 1, v5 = build("<SeverityDisp>",trim(replace(replace(replace(replace(replace(result->
               severity_class[idx].severity[jdx].display,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),
            "'","&apos;",0),'"',"&quot;",0),3),"</SeverityDisp>"), col + 1,
        v5, row + 1, v6 = build("<SeverityMean>",trim(replace(replace(replace(replace(replace(result
               ->severity_class[idx].severity[jdx].meaning,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),
            "'","&apos;",0),'"',"&quot;",0),3),"</SeverityMean>"),
        col + 1, v6, row + 1,
        col + 1, "</Severity>", row + 1
      ENDFOR
      col + 1, "</Severities>", row + 1,
      col + 1, "</SeverityClass>", row + 1
    ENDFOR
    col + 1, "</SeverityClasses>", row + 1
   FOOT REPORT
    col + 1, "</ReplyMessage>", row + 1
   WITH maxcol = 32000, nocounter, nullreport,
    formfeed = none, format = variable, time = 30
  ;end select
 ENDIF
 FREE RECORD result
 FREE RECORD req963007
 FREE RECORD rep963007
 SUBROUTINE callgetnomenaxis(null)
   DECLARE applicationid = i4 WITH protect, constant(600005)
   DECLARE taskid = i4 WITH protect, constant(4170104)
   DECLARE requestid = i4 WITH protect, constant(963007)
   DECLARE itemcnt = i4 WITH protect, noconstant(0)
   SET stat = alterlist(req963007->vocab,size(result->severity_class,5))
   FOR (idx = 1 TO size(result->severity_class,5))
    SET req963007->vocab[idx].source_vocabulary_cd = result->severity_class[idx].code_value
    SET req963007->vocab[idx].code_set = 12022
   ENDFOR
   CALL echorecord(req963007)
   CALL echo(build("TDBEXECUTE FOR ",requestid))
   SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req963007,
    "REC",rep963007,1)
   IF (stat > 0)
    SET errcode = error(errmsg,1)
    CALL echo(build("TDBEXECUTE ",requestid," - ERROR CODE: ",errcode," - ERROR MESSAGE: ",
      errmsg))
    RETURN(fail)
   ENDIF
   CALL echorecord(rep963007)
   IF ((rep963007->status_data.status != "F"))
    FOR (idx = 1 TO size(rep963007->vocab,5))
     SET pos = locateval(locidx,1,size(result->severity_class,5),rep963007->vocab[idx].
      source_vocabulary_cd,result->severity_class[locidx].code_value)
     IF (pos > 0)
      SET itemcnt = 0
      SET stat = alterlist(result->severity_class[pos].severity,size(rep963007->vocab[idx].group,5))
      SELECT INTO "NL:"
       sortkey = cnvtupper(rep963007->vocab[idx].group[d.seq].child_disp)
       FROM (dummyt d  WITH seq = size(rep963007->vocab[idx].group,5))
       PLAN (d
        WHERE d.seq > 0)
       ORDER BY sortkey
       DETAIL
        itemcnt = (itemcnt+ 1), result->severity_class[pos].severity[itemcnt].code_value = rep963007
        ->vocab[idx].group[d.seq].child_cd, result->severity_class[pos].severity[itemcnt].display =
        rep963007->vocab[idx].group[d.seq].child_disp,
        result->severity_class[pos].severity[itemcnt].meaning = rep963007->vocab[idx].group[d.seq].
        child_mean
       WITH nocounter, time = 30
      ;end select
     ENDIF
    ENDFOR
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
