CREATE PROGRAM dcp_get_dtawizard_codesets:dba
 SET modify = predeclare
 SUBROUTINE (reportfailure(opname=vc,opstatus=vc,targetname=vc,targetvalue=vc) =null)
  SET reply->status_data.status = "F"
  CALL fillsubeventstatus(opname,opstatus,targetname,targetvalue)
 END ;Subroutine
 SUBROUTINE (fillsubeventstatus(opname=vc,opstatus=vc,objname=vc,objvalue=vc) =null)
   DECLARE dcp_substatus_cnt = i4 WITH protect, noconstant(size(reply->status_data.subeventstatus,5))
   SET dcp_substatus_cnt += 1
   IF (dcp_substatus_cnt != 1)
    SET stat = alter(reply->status_data.subeventstatus,dcp_substatus_cnt)
   ENDIF
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationname = trim(opname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].operationstatus = trim(opstatus)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectname = trim(objname)
   SET reply->status_data.subeventstatus[dcp_substatus_cnt].targetobjectvalue = trim(objvalue)
 END ;Subroutine
 FREE RECORD reply
 RECORD reply(
   1 codesetlist1count = i4
   1 codesetlist2count = i4
   1 codesetlist3count = i4
   1 codesetlist4count = i4
   1 codesetlist1[*]
     2 code_value = f8
     2 description = vc
   1 codesetlist2[*]
     2 code_value = f8
     2 description = vc
   1 codesetlist3[*]
     2 code_value = f8
     2 description = vc
   1 codesetlist4[*]
     2 code_value = f8
     2 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 DECLARE fail_ind = i2 WITH protect, noconstant(0)
 DECLARE nomenclature_cnt = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE serrormsg = vc WITH protect, noconstant("")
 DECLARE ierrorcode = i2 WITH protect, noconstant(0)
 DECLARE ptcarecd = f8 WITH protect, constant(uar_get_code_by("MEANING",400,"PTCARE"))
 DECLARE icounter1 = i4 WITH noconstant(0.0)
 DECLARE icounter2 = i4 WITH noconstant(0.0)
 DECLARE icounter3 = i4 WITH noconstant(0.0)
 DECLARE icounter4 = i4 WITH noconstant(0.0)
 DECLARE itotalcount = i4 WITH noconstant(0.0)
 DECLARE ilistlimit = i4 WITH noconstant(0.0)
 DECLARE imaxlimit = i4 WITH noconstant(0.0)
 IF (ptcarecd < 1)
  CALL echo("Failed to retrieve the patcare cd from codeset 400.")
  CALL fillsubeventstatus("SELECT","F","dcp_get_dtawizard_codesets",
   "Failed to retrieve the patcare cd from codeset 400.")
  SET fail_ind = 1
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  n.nomenclature_id
  FROM nomenclature n
  WHERE n.source_vocabulary_cd=ptcarecd
   AND trim(n.short_string) > ""
   AND n.active_ind=1
 ;end select
 IF (curqual=0)
  CALL echo("No Nomenclatures with Patcare code value found.")
  CALL fillsubeventstatus("SELECT","Z","dcp_get_dtawizard_codesets",
   "No Nomenclatures with Patcare code value found.")
  GO TO exit_script
 ELSE
  SET itotalcount = curqual
  SET ilistlimit = 65535
  SET imaxlimit = (4 * ilistlimit)
 ENDIF
 IF (itotalcount > imaxlimit)
  SET itotalcount = imaxlimit
  SET reply->status_data.subeventstatus[1].targetobjectvalue = build2("Script fetch only - ",
   itotalcount," DTAs but DB has ",curqual,".")
 ENDIF
 IF (itotalcount > ilistlimit)
  SET reply->codesetlist1count = ilistlimit
  SET stat = alterlist(reply->codesetlist1,reply->codesetlist1count)
  SET itotalcount -= ilistlimit
 ELSE
  IF (itotalcount > 0)
   SET reply->codesetlist1count = itotalcount
   SET stat = alterlist(reply->codesetlist1,reply->codesetlist1count)
   SET itotalcount = 0
  ELSE
   SET reply->status_data[1].status = "Z"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (itotalcount > ilistlimit)
  SET reply->codesetlist2count = ilistlimit
  SET stat = alterlist(reply->codesetlist2,reply->codesetlist2count)
  SET itotalcount -= ilistlimit
 ELSE
  IF (itotalcount > 0)
   SET reply->codesetlist2count = itotalcount
   SET stat = alterlist(reply->codesetlist2,reply->codesetlist2count)
   SET itotalcount = 0
  ENDIF
 ENDIF
 IF (itotalcount > ilistlimit)
  SET reply->codesetlist3count = ilistlimit
  SET stat = alterlist(reply->codesetlist3,reply->codesetlist3count)
  SET itotalcount -= ilistlimit
 ELSE
  IF (itotalcount > 0)
   SET reply->codesetlist3count = itotalcount
   SET stat = alterlist(reply->codesetlist3,reply->codesetlist3count)
   SET itotalcount = 0
  ENDIF
 ENDIF
 IF (itotalcount > ilistlimit)
  SET reply->codesetlist4count = ilistlimit
  SET stat = alterlist(reply->codesetlist4,reply->codesetlist4count)
  SET itotalcount -= ilistlimit
 ELSE
  IF (itotalcount > 0)
   SET reply->codesetlist4count = itotalcount
   SET stat = alterlist(reply->codesetlist4,reply->codesetlist4count)
   SET itotalcount = 0
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  n.nomenclature_id
  FROM nomenclature n
  WHERE n.source_vocabulary_cd=ptcarecd
   AND trim(n.short_string) > ""
   AND n.active_ind=1
  DETAIL
   icounter1 += 1
   IF (icounter1 > 0
    AND icounter1 <= ilistlimit)
    reply->codesetlist1[icounter1].code_value = n.nomenclature_id, reply->codesetlist1[icounter1].
    description = n.source_string
   ELSEIF (icounter1 > ilistlimit
    AND (icounter1 <= (2 * ilistlimit)))
    icounter2 += 1, reply->codesetlist2[icounter2].code_value = n.nomenclature_id, reply->
    codesetlist2[icounter2].description = n.source_string
   ELSEIF ((icounter1 > (2 * ilistlimit))
    AND (icounter1 <= (3 * ilistlimit)))
    icounter3 += 1, reply->codesetlist3[icounter3].code_value = n.nomenclature_id, reply->
    codesetlist3[icounter3].description = n.source_string
   ELSEIF ((icounter1 > (3 * ilistlimit))
    AND icounter1 <= imaxlimit)
    icounter4 += 1, reply->codesetlist4[icounter4].code_value = n.nomenclature_id, reply->
    codesetlist4[icounter4].description = n.source_string
   ENDIF
  WITH nocounter, maxrec = 262140
 ;end select
 CALL echorecord(reply)
#exit_script
 SET ierrorcode = error(serrormsg,1)
 IF (ierrorcode != 0)
  CALL echo("*********************************")
  CALL echo(build("ERROR MESSAGE : ",serrormsg))
  CALL echo("*********************************")
  CALL reportfailure("ERROR","F","dcp_get_dtawizard_codesets",serrormsg)
 ELSEIF (fail_ind=1)
  CALL echo("Failure reported.  Exiting.")
  SET reply->status_data.status = "F"
 ELSEIF (size(reply->codesetlist1,5)=0)
  SET reply->status_data.status = "Z"
 ELSE
  CALL echo("******** Success ********")
  SET reply->status_data.status = "S"
 ENDIF
 CALL echo("MOD 004 - 11/14/11")
 SET modify = nopredeclare
END GO
