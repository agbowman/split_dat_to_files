CREATE PROGRAM bhs_athn_get_custom_list
 DECLARE moutputdevice = vc WITH protect, constant( $1)
 DECLARE json = vc WITH protect, noconstant(" ")
 DECLARE idx = i4 WITH protect, noconstant(0)
 DECLARE idx1 = i4 WITH protect, noconstant(0)
 DECLARE stat = i4 WITH protect, noconstant(0)
 DECLARE stat1 = i4 WITH protect, noconstant(0)
 FREE RECORD req600142
 RECORD req600142(
   1 prsnl_id = f8
 ) WITH protect
 FREE RECORD rep600142
 RECORD rep600142(
   1 patient_lists[*]
     2 patient_list_id = f8
     2 name = vc
     2 description = vc
     2 patient_list_type_cd = f8
     2 owner_id = f8
     2 list_access_cd = f8
     2 arguments[*]
       3 argument_name = vc
       3 argument_value = vc
       3 parent_entity_name = vc
       3 parent_entity_id = f8
     2 encntr_type_filters[*]
     2 proxies[*]
   1 status_data
     2 status = c1
 ) WITH protect
 FREE RECORD rep3200136
 RECORD rep3200136(
   1 patient_list_ids[*]
     2 patient_list_id = vc
   1 status_data
     2 status = c1
 ) WITH protect
 DECLARE applicationid = i4 WITH protect, constant(600005)
 DECLARE taskid = i4 WITH protect, constant(3200100)
 DECLARE requestid = i4 WITH protect, constant(600142)
 DECLARE requestid1 = i4 WITH protect, constant(3200136)
 SET req600142->prsnl_id =  $2
 CALL echorecord(req600142)
 CALL echo(build("TDBEXECUTE FOR ",requestid))
 SET stat = tdbexecute(applicationid,taskid,requestid,"REC",req600142,
  "REC",rep600142,1)
 IF ((rep600142->status_data.status="S"))
  CALL echo(build("TDBEXECUTE FOR ",requestid1))
  SET stat1 = tdbexecute(applicationid,taskid,requestid1,"REC",req600142,
   "REC",rep3200136,1)
 ENDIF
 CALL echo(rep600142)
 CALL echo(rep3200136)
 DECLARE v1 = vc WITH protect, noconstant(" ")
 DECLARE v2 = vc WITH protect, noconstant(" ")
 DECLARE v3 = vc WITH protect, noconstant(" ")
 DECLARE v4 = vc WITH protect, noconstant(" ")
 DECLARE v5 = vc WITH protect, noconstant(" ")
 DECLARE v6 = vc WITH protect, noconstant(" ")
 DECLARE v7 = vc WITH protect, noconstant(" ")
 DECLARE v8 = vc WITH protect, noconstant(" ")
 DECLARE v9 = vc WITH protect, noconstant(" ")
 DECLARE v10 = vc WITH protect, noconstant(" ")
 DECLARE v11 = vc WITH protect, noconstant(" ")
 DECLARE v12 = vc WITH protect, noconstant(" ")
 DECLARE v13 = vc WITH protect, noconstant(" ")
 DECLARE v14 = vc WITH protect, noconstant(" ")
 DECLARE v15 = vc WITH protect, noconstant(" ")
 DECLARE v16 = vc WITH protect, noconstant(" ")
 SELECT INTO value(moutputdevice)
  FROM (dummyt d  WITH seq = value(1))
  PLAN (d
   WHERE d.seq > 0)
  HEAD REPORT
   html_tag = build('<?xml version="1.0" encoding="UTF-8" ?>'), col 0, html_tag,
   row + 1, col + 1, "<ReplyMessage>",
   row + 1, col + 1, "<Payload>",
   row + 1, v0 = build("<Status>",rep600142->status_data.status,"</Status>"), col + 1,
   v0, row + 1
  DETAIL
   col + 1, "<CustomPatientLists>", row + 1
   IF ((rep600142->status_data.status="S"))
    FOR (idx = 1 TO size(rep600142->patient_lists,5))
      IF ((rep600142->patient_lists[idx].patient_list_id > 0.00))
       pos = locateval(stat1,1,size(rep3200136->patient_list_ids,5),cnvtstring(rep600142->
         patient_lists[idx].patient_list_id),trim(rep3200136->patient_list_ids[stat1].patient_list_id,
         3))
       IF (pos > 0)
        col + 1, "<CustomPatientList>", row + 1,
        v1 = build("<Id>",cnvtint(rep600142->patient_lists[idx].patient_list_id),"</Id>"), col + 1,
        v1,
        row + 1, v2 = build("<PrsnlId>",cnvtint(rep600142->patient_lists[idx].owner_id),"</PrsnlId>"),
        col + 1,
        v2, row + 1, v3 = build("<Name>",trim(replace(replace(replace(replace(replace(trim(rep600142
                ->patient_lists[idx].name,3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'","&apos;",
            0),'"',"&quot;",0),3),"</Name>"),
        col + 1, v3, row + 1,
        v4 = build("<Description>",trim(replace(replace(replace(replace(replace(trim(rep600142->
                patient_lists[idx].description,3),"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
            "&apos;",0),'"',"&quot;",0),3),"</Description>"), col + 1, v4,
        row + 1, col + 1, "<Type>",
        row + 1, v5 = build("<Display>",trim(replace(replace(replace(replace(replace(
               uar_get_code_display(rep600142->patient_lists[idx].patient_list_type_cd),"&","&amp;",0
               ),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</Display>"), col +
        1,
        v5, row + 1, v6 = build("<Meaning>",trim(replace(replace(replace(replace(replace(
               uar_get_code_meaning(rep600142->patient_lists[idx].patient_list_type_cd),"&","&amp;",0
               ),"<","&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</Meaning>"),
        col + 1, v6, row + 1,
        v7 = build("<Value>",cnvtint(rep600142->patient_lists[idx].patient_list_type_cd),"</Value>"),
        col + 1, v7,
        row + 1, col + 1, "</Type>",
        row + 1, col + 1, "<ListAccess>",
        row + 1, v8 = build("<Display>",trim(replace(replace(replace(replace(replace(
               uar_get_code_display(rep600142->patient_lists[idx].list_access_cd),"&","&amp;",0),"<",
              "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</Display>"), col + 1,
        v8, row + 1, v9 = build("<Meaning>",trim(replace(replace(replace(replace(replace(
               uar_get_code_meaning(rep600142->patient_lists[idx].list_access_cd),"&","&amp;",0),"<",
              "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</Meaning>"),
        col + 1, v9, row + 1,
        v10 = build("<Value>",cnvtint(rep600142->patient_lists[idx].list_access_cd),"</Value>"), col
         + 1, v10,
        row + 1, col + 1, "</ListAccess>",
        row + 1, col + 1, "<PatientListFilters>",
        row + 1
        FOR (idx1 = 1 TO size(rep600142->patient_lists[idx].arguments,5))
          col + 1, "<PatientListFilter>", row + 1,
          v11 = build("<Name>",trim(replace(replace(replace(replace(replace(rep600142->patient_lists[
                 idx].arguments[idx1].argument_name,"&","&amp;",0),"<","&lt;",0),">","&gt;",0),"'",
              "&apos;",0),'"',"&quot;",0),3),"</Name>"), col + 1, v11,
          row + 1, v12 = build("<Value>",trim(replace(replace(replace(replace(replace(rep600142->
                 patient_lists[idx].arguments[idx1].argument_value,"&","&amp;",0),"<","&lt;",0),">",
               "&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</Value>"), col + 1,
          v12, row + 1, v13 = build("<ParentEntityName>",trim(replace(replace(replace(replace(replace
                (rep600142->patient_lists[idx].arguments[idx1].parent_entity_name,"&","&amp;",0),"<",
                "&lt;",0),">","&gt;",0),"'","&apos;",0),'"',"&quot;",0),3),"</ParentEntityName>"),
          col + 1, v13, row + 1,
          v14 = build("<ParentEntityId>",cnvtint(rep600142->patient_lists[idx].arguments[idx1].
            parent_entity_id),"</ParentEntityId>"), col + 1, v14,
          row + 1, col + 1, "</PatientListFilter>",
          row + 1
        ENDFOR
        col + 1, "</PatientListFilters>", row + 1
        IF (pos=0)
         v15 = build("<ActiveIndicator>","false","</ActiveIndicator>")
        ELSE
         v15 = build("<ActiveIndicator>","true","</ActiveIndicator>")
        ENDIF
        col + 1, v15, row + 1,
        col + 1, "</CustomPatientList>", row + 1
       ENDIF
      ENDIF
    ENDFOR
   ENDIF
  FOOT REPORT
   col + 1, "</CustomPatientLists>", row + 1,
   col + 1, "</Payload>", row + 1,
   col + 1, "</ReplyMessage>", row + 1
  WITH maxcol = 32000, nocounter, nullreport,
   formfeed = none, format = variable, time = 20
 ;end select
 FREE RECORD req600142
 FREE RECORD rep600142
 FREE RECORD rep3200136
END GO
