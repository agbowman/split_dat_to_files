CREATE PROGRAM bed_get_pharm_5_4_matches:dba
 FREE SET reply
 RECORD reply(
   1 legacy[*]
     2 facility
       3 code_value = f8
       3 display = vc
     2 ndc = vc
     2 description = vc
     2 mill[*]
       3 ndc = vc
       3 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c15
       3 operationstatus = c1
       3 targetobjectname = c15
       3 targetobjectvalue = vc
 )
 SET reply->status_data.status = "F"
 RECORD temp(
   1 legacy[*]
     2 facility_cd = f8
     2 facility_display = vc
     2 ndc = vc
     2 description = vc
     2 ndc_match = vc
 )
 SET tcnt = 0
 SET alterlist_tcnt = 0
 SET stat = alterlist(temp->legacy,100)
 IF ((request->return_dup_ndc_ind=1))
  SELECT INTO "NL:"
   b.facility_cd, b.ndc, b.description
   FROM br_pharm_product_work b,
    code_value cv
   PLAN (b
    WHERE b.match_ind=0)
    JOIN (cv
    WHERE cv.code_value=outerjoin(b.facility_cd))
   ORDER BY b.facility_cd, b.ndc, b.description
   DETAIL
    tcnt = (tcnt+ 1), alterlist_tcnt = (alterlist_tcnt+ 1)
    IF (alterlist_tcnt > 100)
     stat = alterlist(temp->legacy,(tcnt+ 100)), alterlist_tcnt = 1
    ENDIF
    temp->legacy[tcnt].facility_cd = b.facility_cd
    IF (b.facility_cd > 0)
     temp->legacy[tcnt].facility_display = cv.display
    ENDIF
    temp->legacy[tcnt].ndc = b.ndc, temp->legacy[tcnt].description = b.description, temp->legacy[tcnt
    ].ndc_match = concat(substring(1,9,b.ndc),"*")
   WITH nocounter
  ;end select
 ELSE
  SELECT DISTINCT INTO "NL:"
   b.facility_cd, b.ndc
   FROM br_pharm_product_work b,
    code_value cv
   PLAN (b
    WHERE b.match_ind=0)
    JOIN (cv
    WHERE cv.code_value=outerjoin(b.facility_cd))
   ORDER BY b.facility_cd, b.ndc
   HEAD b.facility_cd
    tcnt = tcnt
   HEAD b.ndc
    tcnt = (tcnt+ 1), alterlist_tcnt = (alterlist_tcnt+ 1)
    IF (alterlist_tcnt > 100)
     stat = alterlist(temp->legacy,(tcnt+ 100)), alterlist_tcnt = 1
    ENDIF
    temp->legacy[tcnt].facility_cd = b.facility_cd
    IF (b.facility_cd > 0)
     temp->legacy[tcnt].facility_display = cv.display
    ENDIF
    temp->legacy[tcnt].ndc = b.ndc, temp->legacy[tcnt].description = b.description, temp->legacy[tcnt
    ].ndc_match = concat(substring(1,9,b.ndc),"*")
   WITH nocounter
  ;end select
 ENDIF
 SET stat = alterlist(temp->legacy,tcnt)
 IF (tcnt=0)
  GO TO exit_script
 ENDIF
 SET vocab_cd = 0.0
 SELECT INTO "NL:"
  FROM code_value cv
  WHERE cv.code_set=400
   AND cv.cdf_meaning="MUL.MMDC"
  DETAIL
   vocab_cd = cv.code_value
  WITH nocounter
 ;end select
 DECLARE search_string = vc
 DECLARE ndc_parse = vc
 SET lcnt = 0
 SET alterlist_lcnt = 0
 SET stat = alterlist(reply->legacy,100)
 FOR (t = 1 TO tcnt)
   SET search_string = temp->legacy[t].ndc_match
   SET ndc_parse = concat("m.ndc_code = '",search_string,"'")
   SELECT INTO "NL:"
    FROM mltm_ndc_core_description m,
     nomenclature n,
     br_auto_multum a
    PLAN (m
     WHERE parser(ndc_parse))
     JOIN (n
     WHERE n.source_identifier=cnvtstring(m.main_multum_drug_code)
      AND n.source_vocabulary_cd=vocab_cd
      AND n.primary_vterm_ind=1
      AND n.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
      AND n.active_ind=1)
     JOIN (a
     WHERE a.mmdc=outerjoin(concat("MUL.FRMLTN!",trim(cnvtstring(m.main_multum_drug_code)))))
    HEAD REPORT
     lcnt = (lcnt+ 1), alterlist_lcnt = (alterlist_lcnt+ 1)
     IF (alterlist_lcnt > 100)
      stat = alterlist(reply->legacy,(lcnt+ 100)), alterlist_lcnt = 1
     ENDIF
     reply->legacy[lcnt].facility.code_value = temp->legacy[t].facility_cd, reply->legacy[lcnt].
     facility.display = temp->legacy[t].facility_display, reply->legacy[lcnt].ndc = temp->legacy[t].
     ndc,
     reply->legacy[lcnt].description = temp->legacy[t].description, mcnt = 0, alterlist_mcnt = 0,
     stat = alterlist(reply->legacy[lcnt].mill,100)
    DETAIL
     mcnt = (mcnt+ 1), alterlist_mcnt = (alterlist_mcnt+ 1)
     IF (alterlist_mcnt > 100)
      stat = alterlist(reply->legacy[lcnt].mill,(mcnt+ 100)), alterlist_mcnt = 1
     ENDIF
     reply->legacy[lcnt].mill[mcnt].ndc = m.ndc_code
     IF (a.label_description > " ")
      reply->legacy[lcnt].mill[mcnt].description = a.label_description
     ELSE
      reply->legacy[lcnt].mill[mcnt].description = n.source_string
     ENDIF
    FOOT REPORT
     IF (mcnt > 1)
      stat = alterlist(reply->legacy[lcnt].mill,0)
     ELSE
      stat = alterlist(reply->legacy[lcnt].mill,mcnt)
     ENDIF
    WITH nocounter
   ;end select
 ENDFOR
 SET stat = alterlist(reply->legacy,lcnt)
#exit_script
 SET reply->status_data.status = "S"
 CALL echorecord(reply)
END GO
