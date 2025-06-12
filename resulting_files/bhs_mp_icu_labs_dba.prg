CREATE PROGRAM bhs_mp_icu_labs:dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE",
  "Person Id:" = 0,
  "Encounter Id:" = 0
  WITH outdev, personid, encntrid
 DECLARE inerrorcd = f8 WITH public, constant(uar_get_code_by("MEANING",8,"INERROR"))
 DECLARE grpcd = f8 WITH public, constant(uar_get_code_by("MEANING",53,"GRP"))
 FREE RECORD json
 RECORD json(
   1 data = vc
 )
 SELECT INTO "nl:"
  evtdate = trim(format(ce.event_end_dt_tm,"mm/dd/yyyy hh:mm;;dq"),3), shortevtdate = trim(format(ce
    .event_end_dt_tm,"mm/dd/yy hh:mm;;dq"),3), evttitle = trim(cv.display,3),
  evtresult = trim(ce.result_val,3), normalcydisp = trim(uar_get_code_display(ce.normalcy_cd),3),
  unitofmeasure = trim(uar_get_code_display(ce.result_units_cd),3)
  FROM bhs_event_cd_list becl,
   code_value cv,
   clinical_event ce
  PLAN (becl
   WHERE becl.active_ind=1
    AND becl.listkey IN ("MP ICU - MPAGE"))
   JOIN (cv
   WHERE cv.code_value=becl.event_cd)
   JOIN (ce
   WHERE (ce.person_id= $PERSONID)
    AND ce.event_cd=cv.code_value
    AND ce.valid_until_dt_tm > sysdate
    AND ce.event_end_dt_tm >= cnvtlookbehind("3 M",cnvtdatetime(curdate,curtime3))
    AND ce.result_status_cd != inerrorcd
    AND ce.event_class_cd != grpcd)
  ORDER BY cv.display_key, ce.event_end_dt_tm DESC
  HEAD REPORT
   json->data = "{"
  HEAD cv.display_key
   detailcnt = 0, json->data = concat(json->data,'"',trim(evttitle),'":[')
  DETAIL
   IF (detailcnt != 0)
    json->data = concat(json->data,",")
   ENDIF
   json->data = concat(json->data,"{"), json->data = concat(json->data,'"lab_result":"',trim(replace(
      evtresult,"<"," ",0)),'",')
   IF (evtdate > " ")
    json->data = concat(json->data,'"lab_date":"',evtdate,'",')
   ELSE
    json->data = concat(json->data,'"lab_date":"DND",')
   ENDIF
   IF (evtdate > " ")
    json->data = concat(json->data,'"shortlab_date":"',shortevtdate,'",')
   ELSE
    json->data = concat(json->data,'"shortlab_date":"DND",')
   ENDIF
   IF (unitofmeasure > " ")
    json->data = concat(json->data,'"lab_uom":"',trim(unitofmeasure),'",')
   ELSE
    json->data = concat(json->data,'"lab_uom":"DND",')
   ENDIF
   IF (normalcydisp IN ("CRIT"))
    json->data = concat(json->data,'"lab_normalcy_color":"red",'), json->data = concat(json->data,
     '"lab_normalcy":"critical"')
   ELSEIF (normalcydisp IN (">HHI", "HHI", "HH", "HI", "H"))
    json->data = concat(json->data,'"lab_normalcy_color":"orange",'), json->data = concat(json->data,
     '"lab_normalcy":"high"')
   ELSEIF (normalcydisp IN ("<LLOW", "LLOW", "LL", "LOW", "L"))
    json->data = concat(json->data,'"lab_normalcy_color":"blue",'), json->data = concat(json->data,
     '"lab_normalcy":"low"')
   ELSE
    json->data = concat(json->data,'"lab_normalcy_color":"black",'), json->data = concat(json->data,
     '"lab_normalcy":"normal"')
   ENDIF
   json->data = concat(json->data,"}"), detailcnt = 1
  FOOT  cv.display_key
   json->data = concat(json->data,"],")
  FOOT REPORT
   json->data = substring(0,(textlen(json->data) - 1),json->data), json->data = concat(json->data,"}"
    )
  WITH nocounter
 ;end select
 IF (curqual=0)
  SET json->data = "{}"
 ENDIF
 RECORD putrequest(
   1 source_dir = vc
   1 source_filename = vc
   1 nbrlines = i4
   1 line[*]
     2 linedata = vc
   1 overflowpage[*]
     2 ofr_qual[*]
       3 ofr_line = vc
   1 isblob = c1
   1 document_size = i4
   1 document = gvc
 )
 SET putrequest->source_dir =  $OUTDEV
 SET putrequest->isblob = "1"
 SET putrequest->document = json->data
 SET putrequest->document_size = size(putrequest->document)
 EXECUTE eks_put_source  WITH replace(request,putrequest), replace(reply,putreply)
END GO
