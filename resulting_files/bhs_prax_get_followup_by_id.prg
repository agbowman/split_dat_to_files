CREATE PROGRAM bhs_prax_get_followup_by_id
 FREE RECORD result
 RECORD result(
   1 person_id = f8
   1 encntr_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req4250783
 RECORD req4250783(
   1 encntr_id = f8
   1 person_id = f8
   1 pat_ed_domain_cd = f8
   1 fetch_all = i2
 ) WITH protect
 FREE RECORD rep4250783
 RECORD rep4250783(
   1 pat_ed_doc_id = f8
   1 follow_up[*]
     2 pat_ed_followup_id = f8
     2 prov_id = f8
     2 prov_name = cv
     2 followup_dt_tm = dq8
     2 custom_id = i2
     2 cmt_long_text_id = f8
     2 long_text = cv
     2 add_long_text_id = f8
     2 add_long_text = vc
     2 fol_within_range = vc
     2 fol_days = i2
     2 day_or_week = i2
     2 active_ind = i2
     2 organization_id = f8
     2 address_type_cd = f8
     2 location_cd = f8
     2 quick_pick_cd = f8
     2 followup_needed_ind = i2
     2 recipient_long_text_id = f8
     2 recipient_long_text = vc
     2 encntr_id = f8
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callgetfollowuplist(null) = i2
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 SET result->status_data.status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID ENCOUNTER ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET result->encntr_id =  $2
 SELECT INTO "NL:"
  FROM encounter e
  PLAN (e
   WHERE (e.encntr_id=result->encntr_id)
    AND e.active_ind=1
    AND e.beg_effective_dt_tm < sysdate
    AND e.end_effective_dt_tm > sysdate)
  ORDER BY e.person_id
  HEAD e.person_id
   result->person_id = e.person_id
  WITH nocounter, time = 30
 ;end select
 SET stat = callgetfollowuplist(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET result->status_data.status = "S"
#exit_script
 CALL echorecord(result)
 IF (size(trim(moutputdevice,3)) > 0)
  DECLARE v1 = vc WITH protect, noconstant("")
  DECLARE v2 = vc WITH protect, noconstant("")
  DECLARE v3 = vc WITH protect, noconstant("")
  DECLARE v4 = vc WITH protect, noconstant("")
  DECLARE v5 = vc WITH protect, noconstant("")
  DECLARE v6 = vc WITH protect, noconstant("")
  DECLARE v7 = vc WITH protect, noconstant("")
  DECLARE v8 = vc WITH protect, noconstant("")
  DECLARE v9 = vc WITH protect, noconstant("")
  DECLARE v10 = vc WITH protect, noconstant("")
  DECLARE v11 = vc WITH protect, noconstant("")
  DECLARE v12 = vc WITH protect, noconstant("")
  DECLARE v13 = vc WITH protect, noconstant("")
  DECLARE v14 = vc WITH protect, noconstant("")
  DECLARE v15 = vc WITH protect, noconstant("")
  DECLARE v16 = vc WITH protect, noconstant("")
  DECLARE v17 = vc WITH protect, noconstant("")
  DECLARE v18 = vc WITH protect, noconstant("")
  DECLARE v19 = vc WITH protect, noconstant("")
  DECLARE v20 = vc WITH protect, noconstant("")
  DECLARE v21 = vc WITH protect, noconstant("")
  DECLARE v22 = vc WITH protect, noconstant("")
  IF ((rep4250783->status_data.status="S"))
   SELECT INTO value(moutputdevice)
    FROM dummyt d
    PLAN (d
     WHERE d.seq > 0)
    HEAD REPORT
     html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
      '"',"UTF-8",'"'," ?>"), col 0, html_tag,
     row + 1, col + 1, "<ReplyMessage>",
     row + 1, v1 = build("<PatEdDocId>",cnvtint(rep4250783->pat_ed_doc_id),"</PatEdDocId>"), col + 1,
     v1, row + 1, col + 1,
     "<FollowUps>", row + 1
     FOR (idx = 1 TO size(rep4250783->follow_up,5))
       IF ((rep4250783->follow_up[idx].pat_ed_followup_id= $3))
        col + 1, "<FollowUp>", row + 1,
        v2 = build("<PatEdFollowUpId>",cnvtint(rep4250783->follow_up[idx].pat_ed_followup_id),
         "</PatEdFollowUpId>"), col + 1, v2,
        row + 1, v3 = build("<ProvId>",cnvtint(rep4250783->follow_up[idx].prov_id),"</ProvId>"), col
         + 1,
        v3, row + 1, v4 = build("<ProvName>",trim(replace(replace(replace(replace(replace(rep4250783
               ->follow_up[idx].prov_name,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
           '"',"&quot;",0),3),"</ProvName>"),
        col + 1, v4, row + 1,
        v5 = build("<FollowUpDtTm>",format(rep4250783->follow_up[idx].followup_dt_tm,"MM/DD/YYYY;;D"),
         "</FollowUpDtTm>"), col + 1, v5,
        row + 1, v6 = build("<CustomID>",cnvtint(rep4250783->follow_up[idx].custom_id),"</CustomID>"),
        col + 1,
        v6, row + 1, v7 = build("<CommentLongTextId>",cnvtint(rep4250783->follow_up[idx].
          cmt_long_text_id),"</CommentLongTextId>"),
        col + 1, v7, row + 1,
        v8 = build("<Comment>",trim(replace(replace(replace(replace(replace(rep4250783->follow_up[idx
               ].long_text,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),
          3),"</Comment>"), col + 1, v8,
        row + 1, v9 = build("<AddressLongTextId>",cnvtint(rep4250783->follow_up[idx].add_long_text_id
          ),"</AddressLongTextId>"), col + 1,
        v9, row + 1, v10 = build("<Address>",trim(replace(replace(replace(replace(replace(rep4250783
               ->follow_up[idx].add_long_text,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",
            0),'"',"&quot;",0),3),"</Address>"),
        col + 1, v10, row + 1,
        v11 = build("<WithinRange>",trim(replace(replace(replace(replace(replace(rep4250783->
               follow_up[idx].fol_within_range,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
            "&apos;",0),'"',"&quot;",0),3),"</WithinRange>"), col + 1, v11,
        row + 1, v12 = build("<Days>",rep4250783->follow_up[idx].fol_days,"</Days>"), col + 1,
        v12, row + 1, v13 = build("<DayOrWeek>",rep4250783->follow_up[idx].day_or_week,"</DayOrWeek>"
         ),
        col + 1, v13, row + 1,
        v14 = build("<ActiveInd>",rep4250783->follow_up[idx].active_ind,"</ActiveInd>"), col + 1, v14,
        row + 1, v15 = build("<OrganizationId>",cnvtint(rep4250783->follow_up[idx].organization_id),
         "</OrganizationId>"), col + 1,
        v15, row + 1, v16 = build("<AddressTypeCd>",cnvtint(rep4250783->follow_up[idx].
          address_type_cd),"</AddressTypeCd>"),
        col + 1, v16, row + 1,
        v17 = build("<LocationCd>",cnvtint(rep4250783->follow_up[idx].location_cd),"</LocationCd>"),
        col + 1, v17,
        row + 1, v18 = build("<QuickPickCd>",cnvtint(rep4250783->follow_up[idx].quick_pick_cd),
         "</QuickPickCd>"), col + 1,
        v18, row + 1, v19 = build("<FollowupNeededInd>",rep4250783->follow_up[idx].
         followup_needed_ind,"</FollowupNeededInd>"),
        col + 1, v19, row + 1,
        v20 = build("<RecipientLongTextId>",cnvtint(rep4250783->follow_up[idx].recipient_long_text_id
          ),"</RecipientLongTextId>"), col + 1, v20,
        row + 1, v21 = build("<Recipient>",trim(replace(replace(replace(replace(replace(rep4250783->
               follow_up[idx].recipient_long_text,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
            "&apos;",0),'"',"&quot;",0),3),"</Recipient>"), col + 1,
        v21, row + 1, v22 = build("<EncounterId>",cnvtint(rep4250783->follow_up[idx].encntr_id),
         "</EncounterId>"),
        col + 1, v22, row + 1,
        col + 1, "</FollowUp>", row + 1
       ENDIF
     ENDFOR
     col + 1, "</FollowUps>", row + 1,
     col + 1, "</ReplyMessage>", row + 1
    WITH maxcol = 32000, nocounter, nullreport,
     formfeed = none, format = variable, time = 30
   ;end select
  ENDIF
 ENDIF
 FREE RECORD result
 FREE RECORD req4250783
 FREE RECORD rep4250783
 SUBROUTINE callgetfollowuplist(null)
   SET req4250783->encntr_id = result->encntr_id
   SET req4250783->person_id = result->person_id
   SET req4250783->fetch_all = 1
   CALL echorecord(req4250783)
   EXECUTE fndis_get_followup_list  WITH replace("REQUEST","REQ4250783"), replace("REPLY",
    "REP4250783")
   CALL echorecord(rep4250783)
   IF ((rep4250783->status_data.status="S"))
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
END GO
