CREATE PROGRAM bed_get_iview_nonalias_units:dba
 FREE SET reply
 RECORD reply(
   1 units[*]
     2 code_value = f8
     2 display = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 SET ccnt = 0
 SET acnt = 0
 SET cl_found = 0
 SET cal_found = 0
 DECLARE contrib_cd = f8 WITH public, noconstant(0.0)
 SET contrib_cd = uar_get_code_by("MEANING",73,"MULTUM")
 SELECT INTO "nl:"
  FROM dtable t
  PLAN (t
   WHERE t.table_name IN ("CMT_CODE_VALUE_LOAD", "CMT_CODE_VALUE_ALIAS_LOAD"))
  DETAIL
   IF (t.table_name="CMT_CODE_VALUE_LOAD")
    cl_found = 1
   ENDIF
   IF (t.table_name="CMT_CODE_VALUE_ALIAS_LOAD")
    cal_found = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (((cl_found=0) OR (cal_found=0)) )
  GO TO exit_script
 ENDIF
 FREE SET temp
 RECORD temp(
   1 cqual[*]
     2 cd = f8
     2 disp = vc
     2 invalid_ind = i2
     2 aqual[*]
       3 alias = vc
       3 found_ind = i2
 )
 SELECT INTO "nl:"
  FROM code_value c,
   cmt_code_value_load cl,
   cmt_code_value_alias_load cal
  PLAN (c
   WHERE c.code_set=54
    AND c.active_ind=1)
   JOIN (cl
   WHERE cl.cki=c.cki)
   JOIN (cal
   WHERE cal.code_value_uuid=cl.code_value_uuid
    AND cal.contributor_source_mean="MULTUM")
  HEAD c.code_value
   acnt = 0, ccnt = (ccnt+ 1), stat = alterlist(temp->cqual,ccnt),
   temp->cqual[ccnt].cd = c.code_value, temp->cqual[ccnt].disp = c.display
  HEAD cal.alias
   acnt = (acnt+ 1), stat = alterlist(temp->cqual[ccnt].aqual,acnt), temp->cqual[ccnt].aqual[acnt].
   alias = cal.alias
  WITH nocounter
 ;end select
 IF (ccnt=0)
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d  WITH seq = value(ccnt)),
   code_value_alias c
  PLAN (d)
   JOIN (c
   WHERE (c.code_value=temp->cqual[d.seq].cd)
    AND c.contributor_source_cd=contrib_cd)
  ORDER BY d.seq
  HEAD d.seq
   acnt = size(temp->cqual[d.seq].aqual,5)
  DETAIL
   FOR (x = 1 TO acnt)
     IF ((c.alias=temp->cqual[d.seq].aqual[x].alias))
      temp->cqual[d.seq].aqual[x].found_ind = 1
     ENDIF
   ENDFOR
  WITH nocounter
 ;end select
 SET cnt = 0
 FOR (x = 1 TO ccnt)
   SET acnt = size(temp->cqual[x].aqual,5)
   FOR (y = 1 TO acnt)
     IF ((temp->cqual[x].aqual[y].found_ind=0))
      SET temp->cqual[x].invalid_ind = 1
     ENDIF
   ENDFOR
   IF ((temp->cqual[x].invalid_ind=1))
    SET cnt = (cnt+ 1)
    SET stat = alterlist(reply->units,cnt)
    SET reply->units[cnt].code_value = temp->cqual[x].cd
    SET reply->units[cnt].display = temp->cqual[x].disp
   ENDIF
 ENDFOR
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
