CREATE PROGRAM bhs_prax_alerts_write_output
 CALL echo(build("MOUTPUTDEVICE:",moutputdevice))
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
  DECLARE v23 = vc WITH protect, noconstant("")
  DECLARE v24 = vc WITH protect, noconstant("")
  DECLARE v25 = vc WITH protect, noconstant("")
  DECLARE v26 = vc WITH protect, noconstant("")
  DECLARE v27 = vc WITH protect, noconstant("")
  DECLARE v28 = vc WITH protect, noconstant("")
  DECLARE v29 = vc WITH protect, noconstant("")
  DECLARE v30 = vc WITH protect, noconstant("")
  DECLARE v31 = vc WITH protect, noconstant("")
  DECLARE v32 = vc WITH protect, noconstant("")
  DECLARE v33 = vc WITH protect, noconstant("")
  DECLARE v34 = vc WITH protect, noconstant("")
  DECLARE v35 = vc WITH protect, noconstant("")
  DECLARE v36 = vc WITH protect, noconstant("")
  DECLARE v37 = vc WITH protect, noconstant("")
  DECLARE v38 = vc WITH protect, noconstant("")
  IF (size(result->alerts,5) > 0)
   SELECT INTO value(moutputdevice)
    FROM (dummyt d  WITH seq = value(size(result->alerts,5)))
    PLAN (d
     WHERE d.seq > 0)
    HEAD REPORT
     html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
      '"',"UTF-8",'"'," ?>"), col 0, html_tag,
     row + 1, col + 1, "<ReplyMessage>",
     row + 1, v1 = build("<PersonId>",cnvtint(result->person_id),"</PersonId>"), col + 1,
     v1, row + 1, v2 = build("<EncounterId>",cnvtint(result->encntr_id),"</EncounterId>"),
     col + 1, v2, row + 1,
     v3 = build("<BirthDtTm>",format(result->birth_dt_tm,"MM/DD/YYYY;;D"),"</BirthDtTm>"), col + 1,
     v3,
     row + 1, v4 = build("<SexCd>",cnvtint(result->sex_cd),"</SexCd>"), col + 1,
     v4, row + 1, col + 1,
     "<Alerts>", row + 1
    DETAIL
     col + 1, "<Alert>", row + 1,
     v5 = build("<Title>",trim(replace(replace(replace(replace(replace(result->alerts[d.seq].title,
            "&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</Title>"),
     col + 1, v5,
     row + 1, v6 = build("<Text>",trim(replace(replace(replace(replace(replace(result->alerts[d.seq].
            text,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
      "</Text>"), col + 1,
     v6, row + 1, v7 = build("<ModuleName>",trim(replace(replace(replace(replace(replace(result->
            alerts[d.seq].module_name,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
        "&quot;",0),3),"</ModuleName>"),
     col + 1, v7, row + 1,
     v8 = build("<DefaultFirstOrder>",trim(replace(replace(replace(replace(replace(result->alerts[d
            .seq].defaultfirstorder,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
        "&quot;",0),3),"</DefaultFirstOrder>"), col + 1, v8,
     row + 1, col + 1, "<Orders>",
     row + 1
     FOR (idx = 1 TO size(result->alerts[d.seq].orders,5))
       col + 1, "<Order>", row + 1,
       v9 = build("<ActionFlag>",result->alerts[d.seq].orders[idx].actionflag,"</ActionFlag>"), col
        + 1, v9,
       row + 1, v10 = build("<Mnemonic>",trim(replace(replace(replace(replace(replace(result->alerts[
              d.seq].orders[idx].mnemonic,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
          '"',"&quot;",0),3),"</Mnemonic>"), col + 1,
       v10, row + 1, v11 = build("<CatalogCd>",cnvtint(result->alerts[d.seq].orders[idx].catalogcd),
        "</CatalogCd>"),
       col + 1, v11, row + 1,
       v12 = build("<SynonymId>",cnvtint(result->alerts[d.seq].orders[idx].synonymid),"</SynonymId>"),
       col + 1, v12,
       row + 1, v13 = build("<OEFormatID>",cnvtint(result->alerts[d.seq].orders[idx].oeformatid),
        "</OEFormatID>"), col + 1,
       v13, row + 1, v14 = build("<OrderSentenceId>",cnvtint(result->alerts[d.seq].orders[idx].
         ordersentenceid),"</OrderSentenceId>"),
       col + 1, v14, row + 1,
       v15 = build("<OrderSentenceDisplay>",trim(replace(replace(replace(replace(replace(result->
              alerts[d.seq].orders[idx].ordersentencedisplay,"&","&amp;",0),"<","&lt;",0),">","&gt;",
            0),"'","&apos;",0),'"',"&quot;",0),3),"</OrderSentenceDisplay>"), col + 1, v15,
       row + 1, v16 = build("<MultumDosingInd>",result->alerts[d.seq].orders[idx].multum_dosing_ind,
        "</MultumDosingInd>"), col + 1,
       v16, row + 1, v17 = build("<MultumDnum>",trim(replace(replace(replace(replace(replace(result->
              alerts[d.seq].orders[idx].multum_dnum,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
           "&apos;",0),'"',"&quot;",0),3),"</MultumDnum>"),
       col + 1, v17, row + 1,
       col + 1, "<OEDetails>", row + 1
       FOR (jdx = 1 TO size(result->alerts[d.seq].orders[idx].detaillist,5))
         col + 1, "<OEDetail>", row + 1,
         v25 = build("<OEFieldID>",cnvtint(result->alerts[d.seq].orders[idx].detaillist[jdx].
           oefieldid),"</OEFieldID>"), col + 1, v25,
         row + 1, v26 = build("<OEFieldValue>",cnvtint(result->alerts[d.seq].orders[idx].detaillist[
           jdx].oefieldvalue),"</OEFieldValue>"), col + 1,
         v26, row + 1, v27 = build("<OEFieldDisplayValue>",trim(replace(replace(replace(replace(
               replace(result->alerts[d.seq].orders[idx].detaillist[jdx].oefielddisplayvalue,"&",
                "&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
          "</OEFieldDisplayValue>"),
         col + 1, v27, row + 1,
         v28 = build("<OEFieldDtTmValue>",trim(replace(replace(replace(replace(replace(result->
                alerts[d.seq].orders[idx].detaillist[jdx].oefielddttmvalue,"&","&amp;",0),"<","&lt;",
               0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</OEFieldDtTmValue>"), col + 1,
         v28,
         row + 1, v29 = build("<OEFieldMeaning>",trim(replace(replace(replace(replace(replace(result
                ->alerts[d.seq].orders[idx].detaillist[jdx].oefieldmeaning,"&","&amp;",0),"<","&lt;",
               0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</OEFieldMeaning>"), col + 1,
         v29, row + 1, v30 = build("<OEFieldMeaningId>",cnvtint(result->alerts[d.seq].orders[idx].
           detaillist[jdx].oefieldmeaningid),"</OEFieldMeaningId>"),
         col + 1, v30, row + 1,
         col + 1, "</OEDetail>", row + 1
       ENDFOR
       col + 1, "</OEDetails>", row + 1,
       col + 1, "</Order>", row + 1
     ENDFOR
     col + 1, "</Orders>", row + 1,
     v18 = build("<CancelLabel1>",trim(replace(replace(replace(replace(replace(result->alerts[d.seq].
            cancellabel1,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3
       ),"</CancelLabel1>"), col + 1, v18,
     row + 1, v19 = build("<IgnoreLabel2>",trim(replace(replace(replace(replace(replace(result->
            alerts[d.seq].ignorelabel2,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
        "&quot;",0),3),"</IgnoreLabel2>"), col + 1,
     v19, row + 1, v20 = build("<ModifyLabel3>",trim(replace(replace(replace(replace(replace(result->
            alerts[d.seq].modifylabel3,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
        "&quot;",0),3),"</ModifyLabel3>"),
     col + 1, v20, row + 1,
     v21 = build("<DefaultLabel>",trim(replace(replace(replace(replace(replace(result->alerts[d.seq].
            defaultlabel,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3
       ),"</DefaultLabel>"), col + 1, v21,
     row + 1, v22 = build("<OverrideOther>",trim(replace(replace(replace(replace(replace(result->
            alerts[d.seq].overrideother,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
        '"',"&quot;",0),3),"</OverrideOther>"), col + 1,
     v22, row + 1, col + 1,
     "<Overrides>", row + 1
     FOR (idx = 1 TO size(result->alerts[d.seq].overrides,5))
       col + 1, "<Override>", row + 1,
       v23 = build("<ReasonCd>",cnvtint(result->alerts[d.seq].overrides[idx].reasoncd),"</ReasonCd>"),
       col + 1, v23,
       row + 1, v24 = build("<Display>",trim(replace(replace(replace(replace(replace(result->alerts[d
              .seq].overrides[idx].display,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
          '"',"&quot;",0),3),"</Display>"), col + 1,
       v24, row + 1, col + 1,
       "</Override>", row + 1
     ENDFOR
     col + 1, "</Overrides>", row + 1,
     v31 = build("<UrlButton>",trim(replace(replace(replace(replace(replace(result->alerts[d.seq].
            urlbutton,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),
      "</UrlButton>"), col + 1, v31,
     row + 1, v32 = build("<UrlAddress>",trim(replace(replace(replace(replace(replace(result->alerts[
            d.seq].urladdress,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",
        0),3),"</UrlAddress>"), col + 1,
     v32, row + 1, v33 = build("<OkButton>",trim(replace(replace(replace(replace(replace(result->
            alerts[d.seq].okbutton,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',
        "&quot;",0),3),"</OkButton>"),
     col + 1, v33, row + 1,
     v34 = build("<PowerFormId>",cnvtint(result->alerts[d.seq].powerformid),"</PowerFormId>"), col +
     1, v34,
     row + 1, v35 = build("<PowerFormName>",trim(replace(replace(replace(replace(replace(result->
            alerts[d.seq].powerformname,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),
        '"',"&quot;",0),3),"</PowerFormName>"), col + 1,
     v35, row + 1, v36 = build("<PowerFormButton>",trim(replace(replace(replace(replace(replace(
            result->alerts[d.seq].powerformbutton,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
         "&apos;",0),'"',"&quot;",0),3),"</PowerFormButton>"),
     col + 1, v36, row + 1,
     v37 = build("<PowerFormText>",trim(replace(replace(replace(replace(replace(result->alerts[d.seq]
            .powerformtext,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),
       3),"</PowerFormText>"), col + 1, v37,
     row + 1, v38 = build("<PowerFormInProgressStatusCd>",cnvtint(result->alerts[d.seq].
       powerforminprogressstatuscd),"</PowerFormInProgressStatusCd>"), col + 1,
     v38, row + 1, col + 1,
     "</Alert>", row + 1
    FOOT REPORT
     col + 1, "</Alerts>", row + 1,
     col + 1, "</ReplyMessage>", row + 1
    WITH maxcol = 32000, nocounter, nullreport,
     formfeed = none, format = variable, time = 30
   ;end select
  ELSE
   SELECT INTO value(moutputdevice)
    FROM dummyt d
    PLAN (d)
    HEAD REPORT
     html_tag = build("<html><?xml version=",'"',"1.0",'"'," encoding=",
      '"',"UTF-8",'"'," ?>"), col 0, html_tag,
     row + 1, col + 1, "<ReplyMessage>",
     row + 1, v1 = build("<PersonId>",cnvtint(result->person_id),"</PersonId>"), col + 1,
     v1, row + 1, v2 = build("<EncounterId>",cnvtint(result->encntr_id),"</EncounterId>"),
     col + 1, v2, row + 1,
     v3 = build("<BirthDtTm>",format(result->birth_dt_tm,"MM/DD/YYYY HH:MM;;D"),"</BirthDtTm>"), col
      + 1, v3,
     row + 1, v4 = build("<SexCd>",cnvtint(result->sex_cd),"</SexCd>"), col + 1,
     v4, row + 1, col + 1,
     "<Alerts>", row + 1
    FOOT REPORT
     col + 1, "</Alerts>", row + 1,
     col + 1, "</ReplyMessage>", row + 1
    WITH maxcol = 32000, nocounter, nullreport,
     formfeed = none, format = variable, time = 30
   ;end select
  ENDIF
 ENDIF
END GO
