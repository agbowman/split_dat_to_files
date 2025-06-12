CREATE PROGRAM dcp_get_dta_list:dba
 RECORD reply(
   1 list1count = i4
   1 list2count = i4
   1 list3count = i4
   1 list4count = i4
   1 list1[*]
     2 task_assay_cd = f8
     2 mnemonic = vc
     2 description = vc
     2 result_type_cd = f8
   1 list2[*]
     2 task_assay_cd = f8
     2 mnemonic = vc
     2 description = vc
     2 result_type_cd = f8
   1 list3[*]
     2 task_assay_cd = f8
     2 mnemonic = vc
     2 description = vc
     2 result_type_cd = f8
   1 list4[*]
     2 task_assay_cd = f8
     2 mnemonic = vc
     2 description = vc
     2 result_type_cd = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 DECLARE icounter = i4 WITH noconstant(0.0)
 DECLARE icounter2 = i4 WITH noconstant(0.0)
 DECLARE icounter3 = i4 WITH noconstant(0.0)
 DECLARE icounter4 = i4 WITH noconstant(0.0)
 DECLARE itotalcount = i4 WITH noconstant(0.0)
 SET reply->status_data.status = "F"
 SET beg_res_type_cd = 0.0
 SET end_res_type_cd = 999999999
 IF ((request->result_type_cd > 0))
  SET beg_res_type_cd = request->result_type_cd
  SET end_res_type_cd = request->result_type_cd
 ELSE
  SELECT INTO "nl:"
   end_res_type_cd = max(default_result_type_cd)
   FROM discrete_task_assay
   WHERE (((activity_type_cd=request->activity_type_cd)) OR ((request->activity_type_cd=0)))
   WITH nocounter
  ;end select
  SET end_res_type_cd += 1
 ENDIF
 SELECT INTO "nl:"
  d.task_assay_cd
  FROM discrete_task_assay d
  PLAN (d
   WHERE (((d.activity_type_cd=request->activity_type_cd)) OR ((request->activity_type_cd=0)))
    AND d.default_result_type_cd BETWEEN beg_res_type_cd AND end_res_type_cd
    AND d.active_ind=1
    AND ((d.beg_effective_dt_tm=null) OR (d.beg_effective_dt_tm != null
    AND d.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ((d.end_effective_dt_tm=null) OR (d.end_effective_dt_tm != null
    AND d.end_effective_dt_tm >= cnvtdatetime(sysdate))) )) )
 ;end select
 SET itotalcount = curqual
 SET ilistlimit = 65535
 SET imaxlimit = (4 * ilistlimit)
 IF (itotalcount > imaxlimit)
  SET itotalcount = imaxlimit
  SET reply->status_data.subeventstatus[1].targetobjectvalue = build2("Script fetch only - ",
   itotalcount," DTAs but DB has ",curqual,".")
 ENDIF
 IF (itotalcount > ilistlimit)
  SET reply->list1count = ilistlimit
  SET stat = alterlist(reply->list1,reply->list1count)
  SET itotalcount -= ilistlimit
 ELSE
  IF (itotalcount > 0)
   SET reply->list1count = itotalcount
   SET stat = alterlist(reply->list1,reply->list1count)
   SET itotalcount = 0
  ELSE
   SET reply->status_data[1].status = "Z"
   GO TO exit_script
  ENDIF
 ENDIF
 IF (itotalcount > ilistlimit)
  SET reply->list2count = ilistlimit
  SET stat = alterlist(reply->list2,reply->list2count)
  SET itotalcount -= ilistlimit
 ELSE
  IF (itotalcount > 0)
   SET reply->list2count = itotalcount
   SET stat = alterlist(reply->list2,reply->list2count)
   SET itotalcount = 0
  ENDIF
 ENDIF
 IF (itotalcount > ilistlimit)
  SET reply->list3count = ilistlimit
  SET stat = alterlist(reply->list3,reply->list3count)
  SET itotalcount -= ilistlimit
 ELSE
  IF (itotalcount > 0)
   SET reply->list3count = itotalcount
   SET stat = alterlist(reply->list3,reply->list3count)
   SET itotalcount = 0
  ENDIF
 ENDIF
 IF (itotalcount > ilistlimit)
  SET reply->list4count = ilistlimit
  SET stat = alterlist(reply->list4,reply->list4count)
  SET itotalcount -= ilistlimit
 ELSE
  IF (itotalcount > 0)
   SET reply->list4count = itotalcount
   SET stat = alterlist(reply->list4,reply->list4count)
   SET itotalcount = 0
  ENDIF
 ENDIF
 SELECT INTO "nl:"
  d.task_assay_cd
  FROM discrete_task_assay d
  PLAN (d
   WHERE (((d.activity_type_cd=request->activity_type_cd)) OR ((request->activity_type_cd=0)))
    AND d.default_result_type_cd BETWEEN beg_res_type_cd AND end_res_type_cd
    AND d.active_ind=1
    AND ((d.beg_effective_dt_tm=null) OR (d.beg_effective_dt_tm != null
    AND d.beg_effective_dt_tm <= cnvtdatetime(sysdate)
    AND ((d.end_effective_dt_tm=null) OR (d.end_effective_dt_tm != null
    AND d.end_effective_dt_tm >= cnvtdatetime(sysdate))) )) )
  ORDER BY cnvtupper(d.mnemonic)
  DETAIL
   icounter += 1
   IF (icounter > 0
    AND icounter <= ilistlimit)
    reply->list1[icounter].task_assay_cd = d.task_assay_cd, reply->list1[icounter].mnemonic = d
    .mnemonic, reply->list1[icounter].description = d.description,
    reply->list1[icounter].result_type_cd = d.default_result_type_cd
   ELSEIF (icounter > ilistlimit
    AND (icounter <= (2 * ilistlimit)))
    icounter2 += 1, reply->list2[icounter2].task_assay_cd = d.task_assay_cd, reply->list2[icounter2].
    mnemonic = d.mnemonic,
    reply->list2[icounter2].description = d.description, reply->list2[icounter2].result_type_cd = d
    .default_result_type_cd
   ELSEIF ((icounter > (2 * ilistlimit))
    AND (icounter <= (3 * ilistlimit)))
    icounter3 += 1, reply->list3[icounter3].task_assay_cd = d.task_assay_cd, reply->list3[icounter3].
    mnemonic = d.mnemonic,
    reply->list3[icounter3].description = d.description, reply->list3[icounter3].result_type_cd = d
    .default_result_type_cd
   ELSEIF ((icounter > (3 * ilistlimit))
    AND icounter <= imaxlimit)
    icounter4 += 1, reply->list4[icounter4].task_assay_cd = d.task_assay_cd, reply->list4[icounter4].
    mnemonic = d.mnemonic,
    reply->list4[icounter4].description = d.description, reply->list4[icounter4].result_type_cd = d
    .default_result_type_cd
   ENDIF
  WITH nocounter, maxrec = 262140
 ;end select
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
#exit_script
END GO
