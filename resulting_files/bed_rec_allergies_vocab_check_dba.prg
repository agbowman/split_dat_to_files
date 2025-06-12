CREATE PROGRAM bed_rec_allergies_vocab_check:dba
 IF ( NOT (validate(request,0)))
  RECORD request(
    1 program_name = vc
  )
 ENDIF
 IF ( NOT (validate(reply,0)))
  FREE SET reply
  RECORD reply(
    1 run_status_flag = i2
    1 status_data
      2 status = c1
      2 subeventstatus[1]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 FREE SET tempreply
 RECORD tempreply(
   1 rowlist[*]
     2 celllist[*]
       3 date_value = dq8
       3 nbr_value = i4
       3 double_value = f8
       3 string_value = vc
       3 display_flag = i2
 )
 FREE SET valuearray
 RECORD valuearray(
   1 values[3]
     2 value = i4
 )
 FREE SET prefarray
 RECORD prefarray(
   1 values[3]
     2 value = i4
 )
 FREE SET actualvalues
 RECORD actualvalues(
   1 values[3]
     2 value = vc
 )
 FREE SET poshash
 RECORD poshash(
   1 keys[*]
     2 value = f8
 )
 DECLARE reportfailure(varpref=vc,varevalue=vc,varcvalue=vc,varlevel=vc,vardesc=vc,
  vardet=vc,varpriv=vc,varprivval=vc) = null
 DECLARE copytoreply(dest_index=i4,src_index=i4) = null
 DECLARE cleanvaluearray(var=i2) = null
 DECLARE getnextavailablevalue(var=i2) = vc
 DECLARE getactualvalueofthenextavailablepref(var=i2) = vc
 DECLARE getnextavailablepref(var=i2) = vc
 DECLARE celllist_size = i4 WITH constant(15)
 DECLARE detailed_cnt = i4 WITH noconstant(0), protect
 DECLARE row_index = i4
 DECLARE resolution_txt = vc
 DECLARE short_desc = vc
 DECLARE powerchart_app_desc = vc
 DECLARE surginet_app_desc = vc
 DECLARE firstnet_app_desc = vc
 DECLARE pharmacy_app_desc = vc
 DECLARE retail_app_desc = vc
 DECLARE allergy_vocab0 = vc
 DECLARE allergy_vocab1 = vc
 DECLARE allergy_vocab2 = vc
 DECLARE app_desc = vc
 DECLARE poshashcnt = i4
 DECLARE num = i4 WITH noconstant(0), public
 SET detail_mode = validate(request->detail_mode)
 SET reply->run_status_flag = 1
 SET serrmsg = fillstring(132," ")
 SET resolution_txt = ""
 SET short_desc = ""
 SET dummy = ""
 SET stat = alterlist(poshash->keys,1)
 SET poshash->keys.value = 0.0
 SET poshashcnt = 1
 SELECT INTO "nl:"
  FROM br_rec b,
   br_long_text bl
  PLAN (b
   WHERE b.rec_mean="ALLERGYVOCABCHECK")
   JOIN (bl
   WHERE bl.long_text_id=b.resolution_txt_id)
  DETAIL
   resolution_txt = trim(bl.long_text), short_desc = trim(b.short_desc)
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM application a
  WHERE a.application_number IN (600005, 820000, 4250111, 380000, 385000)
   AND a.active_ind=1
  DETAIL
   IF (a.application_number=600005)
    powerchart_app_desc = a.description
   ELSEIF (a.application_number=820000)
    surginet_app_desc = a.description
   ELSEIF (a.application_number=4250111)
    firstnet_app_desc = a.description
   ELSEIF (a.application_number=380000)
    pharmacy_app_desc = a.description
   ELSEIF (a.application_number=385000)
    retail_app_desc = a.description
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "NL:"
  FROM app_prefs app,
   name_value_prefs nvp,
   application a,
   code_value cv,
   prsnl p
  PLAN (app
   WHERE app.application_number IN (600005, 820000, 4250111, 380000, 385000)
    AND app.active_ind=1)
   JOIN (nvp
   WHERE nvp.parent_entity_id=outerjoin(app.app_prefs_id)
    AND nvp.parent_entity_name=outerjoin("APP_PREFS")
    AND nvp.pvc_name=outerjoin("ALLERGY_VOCAB*"))
   JOIN (a
   WHERE a.application_number=outerjoin(app.application_number))
   JOIN (cv
   WHERE cv.code_value=outerjoin(app.position_cd)
    AND cv.active_ind=outerjoin(1))
   JOIN (p
   WHERE p.position_cd=outerjoin(cv.code_value)
    AND p.active_ind=outerjoin(1))
  ORDER BY a.description, app.position_cd, app.prsnl_id
  HEAD a.description
   loc_prefs_count = 0, app_desc = a.description, all_allergy_vocabs = 0,
   CALL cleanvaluearray(0)
  DETAIL
   loc_allergy = 0, loc_value = 0
   IF (app.position_cd=0
    AND app.prsnl_id=0)
    IF (nvp.pvc_name="ALLERGY_VOCAB0")
     loc_allergy = 1
    ELSEIF (nvp.pvc_name="ALLERGY_VOCAB1")
     loc_allergy = 2
    ELSEIF (nvp.pvc_name="ALLERGY_VOCAB2")
     loc_allergy = 3
    ENDIF
    IF (nvp.pvc_value="ALLERGY")
     loc_value = 1
    ELSEIF (nvp.pvc_value="MUL.DRUG")
     loc_value = 2
    ELSEIF (nvp.pvc_value="MUL.ALGCAT")
     loc_value = 3
    ENDIF
    IF (loc_allergy > 0
     AND loc_value > 0)
     IF ((prefarray->values[loc_allergy].value=0)
      AND (valuearray->values[loc_value].value=0))
      prefarray->values[loc_allergy].value = 1, valuearray->values[loc_value].value = 1,
      loc_prefs_count = (loc_prefs_count+ 1)
     ENDIF
    ENDIF
    IF (loc_allergy > 0)
     actualvalues->values[loc_allergy].value = nvp.pvc_value
    ENDIF
    IF (nvp.name_value_prefs_id > 0
     AND nvp.pvc_name != "ALLERGY_VOCAB_COUNT")
     all_allergy_vocabs = (all_allergy_vocabs+ 1)
    ENDIF
   ELSE
    locpositioncd = p.position_cd
    IF (((nvp.pvc_name="ALLERGY_VOCAB0") OR (((nvp.pvc_name="ALLERGY_VOCAB1") OR (nvp.pvc_name=
    "ALLERGY_VOCAB2")) ))
     AND locateval(num,1,poshashcnt,locpositioncd,poshash->keys[num].value)=0)
     poshashcnt = (poshashcnt+ 1), stat = alterlist(poshash->keys,poshashcnt), poshash->keys[
     poshashcnt].value = locpositioncd
     IF (detail_mode=1)
      loc_pos_display = cv.display, loc_app_desc = a.description,
      CALL reportfailure("ALLERGY_VOCAB*","Not defined at the position level",
      "Defined at Position level","Position",loc_app_desc,loc_pos_display,"","")
     ELSE
      reply->run_status_flag = 3
     ENDIF
    ENDIF
   ENDIF
  FOOT  a.description
   IF (all_allergy_vocabs > 0
    AND loc_prefs_count < 3)
    IF (detail_mode=1)
     for_count = (3 - loc_prefs_count)
     FOR (ind = 1 TO for_count)
       actual_value = getactualvalueofthenextavailablepref(0), next_pref = getnextavailablepref(0),
       required_value = getnextavailablevalue(0),
       CALL reportfailure(next_pref,required_value,actual_value,"Application",app_desc,"","","")
     ENDFOR
    ELSE
     reply->run_status_flag = 3
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 SET ierrcode = error(serrmsg,1)
 IF (ierrcode > 0)
  SET reply->status_data.subeventstatus[1].targetobjectname =
  "Error generating a detailed report for Allergy Check"
  SET reply->status_data.subeventstatus[1].targetobjectvalue = serrmsg
 ENDIF
 IF (detailed_cnt > 0)
  SET index = 0
  SET reply_size = detailed_cnt
  SET stat = alterlist(reply->rowlist,reply_size)
  SELECT INTO "NL:"
   FROM (dummyt d  WITH seq = value(reply_size))
   ORDER BY tempreply->rowlist[d.seq].celllist[5].string_value, tempreply->rowlist[d.seq].celllist[6]
    .string_value
   DETAIL
    index = (index+ 1), stat = alterlist(reply->rowlist[index].celllist,celllist_size),
    CALL copytoreply(index,d.seq)
   WITH nocounter
  ;end select
 ENDIF
 SUBROUTINE reportfailure(varpref,varevalue,varcvalue,varlevel,vardesc,vardet,varpriv,varprivval)
   SET detailed_cnt = (detailed_cnt+ 1)
   SET stat = alterlist(tempreply->rowlist,detailed_cnt)
   SET stat = alterlist(tempreply->rowlist[detailed_cnt].celllist,celllist_size)
   SET tempreply->rowlist[detailed_cnt].celllist[1].string_value = short_desc
   SET tempreply->rowlist[detailed_cnt].celllist[2].string_value = varpref
   SET tempreply->rowlist[detailed_cnt].celllist[3].string_value = varevalue
   SET tempreply->rowlist[detailed_cnt].celllist[4].string_value = varcvalue
   SET tempreply->rowlist[detailed_cnt].celllist[5].string_value = varlevel
   SET tempreply->rowlist[detailed_cnt].celllist[6].string_value = vardesc
   SET tempreply->rowlist[detailed_cnt].celllist[7].string_value = vardet
   SET tempreply->rowlist[detailed_cnt].celllist[8].string_value = varpriv
   SET tempreply->rowlist[detailed_cnt].celllist[9].string_value = varprivval
   SET tempreply->rowlist[detailed_cnt].celllist[14].string_value = "Cernerpracticewizard"
   SET tempreply->rowlist[detailed_cnt].celllist[15].string_value = resolution_txt
 END ;Subroutine
 SUBROUTINE cleanvaluearray(var)
   FOR (index = 1 TO 3)
     SET valuearray->values[index].value = 0
     SET prefarray->values[index].value = 0
     SET actualvalues->values[index].value = ""
   ENDFOR
 END ;Subroutine
 SUBROUTINE getnextavailablevalue(var)
  FOR (index = 1 TO 3)
    IF ((valuearray->values[index].value=0))
     SET valuearray->values[index].value = 1
     IF (index=1)
      RETURN("ALLERGY")
     ELSEIF (index=2)
      RETURN("MUL.DRUG")
     ELSEIF (index=3)
      RETURN("MUL.ALGCAT")
     ENDIF
    ENDIF
  ENDFOR
  RETURN("")
 END ;Subroutine
 SUBROUTINE getactualvalueofthenextavailablepref(var)
  FOR (index = 1 TO 3)
    IF ((prefarray->values[index].value=0))
     RETURN(actualvalues->values[index].value)
    ENDIF
  ENDFOR
  RETURN("")
 END ;Subroutine
 SUBROUTINE getnextavailablepref(var)
  FOR (index = 1 TO 3)
    IF ((prefarray->values[index].value=0))
     SET prefarray->values[index].value = 1
     IF (index=1)
      RETURN("ALLERGY_VOCAB0")
     ELSEIF (index=2)
      RETURN("ALLERGY_VOCAB1")
     ELSEIF (index=3)
      RETURN("ALLERGY_VOCAB2")
     ENDIF
    ENDIF
  ENDFOR
  RETURN("")
 END ;Subroutine
 SUBROUTINE copytoreply(dest_index,src_index)
   SET reply->rowlist[dest_index].celllist[1].string_value = tempreply->rowlist[src_index].celllist[1
   ].string_value
   SET reply->rowlist[dest_index].celllist[2].string_value = tempreply->rowlist[src_index].celllist[2
   ].string_value
   SET reply->rowlist[dest_index].celllist[3].string_value = tempreply->rowlist[src_index].celllist[3
   ].string_value
   SET reply->rowlist[dest_index].celllist[4].string_value = tempreply->rowlist[src_index].celllist[4
   ].string_value
   SET reply->rowlist[dest_index].celllist[5].string_value = tempreply->rowlist[src_index].celllist[5
   ].string_value
   SET reply->rowlist[dest_index].celllist[6].string_value = tempreply->rowlist[src_index].celllist[6
   ].string_value
   SET reply->rowlist[dest_index].celllist[7].string_value = tempreply->rowlist[src_index].celllist[7
   ].string_value
   SET reply->rowlist[dest_index].celllist[8].string_value = tempreply->rowlist[src_index].celllist[8
   ].string_value
   SET reply->rowlist[dest_index].celllist[9].string_value = tempreply->rowlist[src_index].celllist[9
   ].string_value
   SET reply->rowlist[dest_index].celllist[10].string_value = tempreply->rowlist[src_index].celllist[
   10].string_value
   SET reply->rowlist[dest_index].celllist[11].string_value = tempreply->rowlist[src_index].celllist[
   11].string_value
   SET reply->rowlist[dest_index].celllist[12].string_value = tempreply->rowlist[src_index].celllist[
   12].string_value
   SET reply->rowlist[dest_index].celllist[13].string_value = tempreply->rowlist[src_index].celllist[
   13].string_value
   SET reply->rowlist[dest_index].celllist[14].string_value = tempreply->rowlist[src_index].celllist[
   14].string_value
   SET reply->rowlist[dest_index].celllist[15].string_value = tempreply->rowlist[src_index].celllist[
   15].string_value
 END ;Subroutine
END GO
