CREATE PROGRAM bhs_athn_get_followup_favs
 FREE RECORD result
 RECORD result(
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 FREE RECORD req4250043
 RECORD req4250043(
   1 prsnl_id = f8
 ) WITH protect
 FREE RECORD rep4250043
 RECORD rep4250043(
   1 favorites[*]
     2 favorite_id = f8
     2 who_name = vc
     2 who_id = f8
     2 who_string = vc
     2 when_dt_tm = dq8
     2 when_within_cd = f8
     2 when_in_val = i4
     2 when_in_type_flag = i2
     2 when_needed_ind = i2
     2 where_txt_id = f8
     2 where_txt = vc
     2 comment_txt_id = f8
     2 comment_txt = vc
     2 invalid_ind = i2
     2 recipient_txt_id = f8
     2 recipient_txt = vc
   1 status_data
     2 status = c1
     2 subeventstatus[*]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) WITH protect
 DECLARE callgetfollowupfavorites(null) = i2
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE locidx = i4 WITH protect, noconstant(0)
 DECLARE pos = i4 WITH protect, noconstant(0)
 DECLARE success = i2 WITH protect, constant(0)
 DECLARE fail = i2 WITH protect, constant(1)
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 SET result->status_data.status = "F"
 IF (( $2 <= 0.0))
  CALL echo("INVALID PERSONNEL ID PARAMETER...EXITING")
  GO TO exit_script
 ENDIF
 SET stat = callgetfollowupfavorites(null)
 IF (stat=fail)
  GO TO exit_script
 ENDIF
 SET stat = getprovidernames(null)
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
  DECLARE v41 = vc WITH protect, noconstant("")
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
  IF ((rep4250043->status_data.status="S"))
   SELECT INTO value(moutputdevice)
    FROM dummyt d
    PLAN (d
     WHERE d.seq > 0)
    HEAD REPORT
     html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
      '"',"UTF-8",'"'," ?>"), col 0, html_tag,
     row + 1, col + 1, "<ReplyMessage>",
     row + 1, col + 1, "<Favorites>",
     row + 1
     FOR (idx = 1 TO size(rep4250043->favorites,5))
       col + 1, "<Favorite>", row + 1,
       v1 = build("<FavoriteId>",cnvtint(rep4250043->favorites[idx].favorite_id),"</FavoriteId>"),
       col + 1, v1,
       row + 1, v2 = build("<WhoName>",trim(replace(replace(replace(replace(replace(rep4250043->
              favorites[idx].who_name,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
          "&quot;",0),3),"</WhoName>"), col + 1,
       v2, row + 1, v3 = build("<WhoId>",cnvtint(rep4250043->favorites[idx].who_id),"</WhoId>"),
       col + 1, v3, row + 1,
       v3 = build("<WhoString>",trim(replace(replace(replace(replace(replace(rep4250043->favorites[
              idx].who_string,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
          0),3),"</WhoString>"), col + 1, v3,
       row + 1, v4 = build("<WhenDt>",format(rep4250043->favorites[idx].when_dt_tm,"MM/DD/YYYY;;D"),
        "</WhenDt>"), col + 1,
       v4, row + 1, v41 = build("<WhenTm>",format(rep4250043->favorites[idx].when_dt_tm,"HH:MM;;D"),
        "</WhenTm>"),
       col + 1, v41, row + 1,
       v5 = build("<WhenWithinCd>",cnvtint(rep4250043->favorites[idx].when_within_cd),
        "</WhenWithinCd>"), col + 1, v5,
       row + 1, v6 = build("<WhenInVal>",rep4250043->favorites[idx].when_in_val,"</WhenInVal>"), col
        + 1,
       v6, row + 1, v7 = build("<WhenInTypeFlag>",rep4250043->favorites[idx].when_in_type_flag,
        "</WhenInTypeFlag>"),
       col + 1, v7, row + 1,
       v8 = build("<WhenNeededInd>",rep4250043->favorites[idx].when_needed_ind,"</WhenNeededInd>"),
       col + 1, v8,
       row + 1, v9 = build("<WhereTxtId>",cnvtint(rep4250043->favorites[idx].where_txt_id),
        "</WhereTxtId>"), col + 1,
       v9, row + 1, v10 = build("<WhereTxt>",trim(replace(replace(replace(replace(replace(rep4250043
              ->favorites[idx].where_txt,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
          '"',"&quot;",0),3),"</WhereTxt>"),
       col + 1, v10, row + 1,
       v11 = build("<CommentTxtId>",cnvtint(rep4250043->favorites[idx].comment_txt_id),
        "</CommentTxtId>"), col + 1, v11,
       row + 1, v12 = build("<CommentTxt>",trim(replace(replace(replace(replace(replace(rep4250043->
              favorites[idx].comment_txt,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
          '"',"&quot;",0),3),"</CommentTxt>"), col + 1,
       v12, row + 1, v13 = build("<InvalidInd>",rep4250043->favorites[idx].invalid_ind,
        "</InvalidInd>"),
       col + 1, v13, row + 1,
       v14 = build("<RecipientTxtId>",cnvtint(rep4250043->favorites[idx].recipient_txt_id),
        "</RecipientTxtId>"), col + 1, v14,
       row + 1, v15 = build("<RecipientTxt>",trim(replace(replace(replace(replace(replace(rep4250043
              ->favorites[idx].recipient_txt,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",
           0),'"',"&quot;",0),3),"</RecipientTxt>"), col + 1,
       v15, row + 1, col + 1,
       "</Favorite>", row + 1
     ENDFOR
     col + 1, "</Favorites>", row + 1,
     col + 1, "</ReplyMessage>", row + 1
    WITH maxcol = 32000, nocounter, nullreport,
     formfeed = none, format = variable, time = 30
   ;end select
  ENDIF
 ENDIF
 FREE RECORD result
 FREE RECORD req4250043
 FREE RECORD rep4250043
 SUBROUTINE callgetfollowupfavorites(null)
   SET req4250043->prsnl_id =  $2
   CALL echorecord(req4250043)
   EXECUTE fn_get_followup_favorites  WITH replace("REQUEST","REQ4250043"), replace("REPLY",
    "REP4250043")
   CALL echorecord(rep4250043)
   IF ((rep4250043->status_data.status="S"))
    RETURN(success)
   ENDIF
   RETURN(fail)
 END ;Subroutine
 SUBROUTINE getprovidernames(null)
  IF ((rep4250043->status_data.status="S"))
   DECLARE prsnl_cnt = i4 WITH protect, noconstant(0)
   DECLARE org_cnt = i4 WITH protect, noconstant(0)
   FREE RECORD prsnl
   RECORD prsnl(
     1 list[*]
       2 prsnl_id = f8
       2 prsnl_name = vc
       2 ref = i4
   ) WITH protect
   FREE RECORD org
   RECORD org(
     1 list[*]
       2 org_id = f8
       2 org_name = vc
       2 ref = i4
   ) WITH protect
   SET stat = alterlist(prsnl->list,size(rep4250043->favorites,5))
   SET stat = alterlist(org->list,size(rep4250043->favorites,5))
   FOR (idx = 1 TO size(rep4250043->favorites,5))
     IF ((rep4250043->favorites[idx].who_name="PRSNL"))
      SET prsnl_cnt = (prsnl_cnt+ 1)
      SET prsnl->list[prsnl_cnt].prsnl_id = rep4250043->favorites[idx].who_id
      SET prsnl->list[prsnl_cnt].ref = idx
     ELSEIF ((rep4250043->favorites[idx].who_name="ORGANIZATION"))
      SET org_cnt = (org_cnt+ 1)
      SET org->list[org_cnt].org_id = rep4250043->favorites[idx].who_id
      SET org->list[org_cnt].ref = idx
     ELSEIF ((rep4250043->favorites[idx].who_name="CODE_VALUE"))
      SET rep4250043->favorites[idx].who_string = uar_get_code_description(rep4250043->favorites[idx]
       .who_id)
     ENDIF
   ENDFOR
   SET stat = alterlist(prsnl->list,prsnl_cnt)
   SET stat = alterlist(org->list,org_cnt)
   IF (prsnl_cnt > 0)
    SELECT INTO "NL:"
     p.name_full_formatted
     FROM prsnl p
     WHERE expand(idx,1,prsnl_cnt,p.person_id,prsnl->list[idx].prsnl_id)
     HEAD p.person_id
      pos = locateval(locidx,1,prsnl_cnt,p.person_id,prsnl->list[locidx].prsnl_id)
      WHILE (pos > 0)
       prsnl->list[pos].prsnl_name = trim(p.name_full_formatted),pos = locateval(locidx,(pos+ 1),
        prsnl_cnt,p.person_id,prsnl->list[locidx].prsnl_id)
      ENDWHILE
     WITH nocounter, time = 30
    ;end select
    FOR (idx = 1 TO prsnl_cnt)
     SET pos = prsnl->list[idx].ref
     SET rep4250043->favorites[pos].who_string = prsnl->list[idx].prsnl_name
    ENDFOR
   ENDIF
   IF (org_cnt > 0)
    SELECT INTO "NL:"
     o.org_name
     FROM organization o
     WHERE expand(idx,1,org_cnt,o.organization_id,org->list[idx].org_id)
     HEAD o.organization_id
      pos = locateval(locidx,1,org_cnt,o.organization_id,org->list[locidx].org_id)
      WHILE (pos > 0)
       org->list[pos].org_name = trim(o.org_name),pos = locateval(locidx,(pos+ 1),org_cnt,o
        .organization_id,org->list[locidx].org_id)
      ENDWHILE
     WITH nocounter, time = 30
    ;end select
    FOR (idx = 1 TO org_cnt)
     SET pos = org->list[idx].ref
     SET rep4250043->favorites[pos].who_string = org->list[idx].org_name
    ENDFOR
   ENDIF
   CALL echorecord(rep4250043)
  ENDIF
  RETURN(success)
 END ;Subroutine
END GO
