CREATE PROGRAM ams_pft_get_entity_status:dba
 PROMPT
  "entity_type_code" = ""
  WITH inputentitytypecd
 DECLARE visibile_ind = i2 WITH protect, constant(1)
 DECLARE invisibile_ind = i2 WITH protect, constant(0)
 DECLARE meaning_claim = c5 WITH protect, constant("CLAIM")
 DECLARE meaning_encounter = c9 WITH protect, constant("PFTENCNTR")
 DECLARE meaning_trans_batch = c11 WITH protect, constant("TRANS BATCH")
 DECLARE meaning_issue_assess = c11 WITH protect, constant("ISSUEASSESS")
 DECLARE meaning_issue_resolut = c12 WITH protect, constant("ISSUERESOLUT")
 DECLARE meaning_issue_review = c11 WITH protect, constant("ISSUEREVIEW")
 DECLARE state_report_ready = f8 WITH protect, constant(uar_get_code_by("MEANING",29321,"REPORTREADY"
   ))
 DECLARE state_pend_review = f8 WITH protect, constant(uar_get_code_by("MEANING",29321,"PENDINGREV"))
 DECLARE state_late_chg_review = f8 WITH protect, constant(uar_get_code_by("MEANING",29321,
   "LATECHRGREV"))
 DECLARE state_variance = f8 WITH protect, constant(uar_get_code_by("MEANING",29321,"CONTVAR"))
 DECLARE state_rejected_837 = f8 WITH protect, constant(uar_get_code_by("MEANING",29321,"REJECTED837"
   ))
 DECLARE state_in_collect = f8 WITH protect, constant(uar_get_code_by("MEANING",29321,"INCOLL"))
 DECLARE state_in_collect_preview = f8 WITH protect, constant(uar_get_code_by("MEANING",29321,
   "INCOLLPREVW"))
 DECLARE state_in_precollect = f8 WITH protect, constant(uar_get_code_by("MEANING",29321,"INPRECOLL")
  )
 DECLARE state_demo_mods = f8 WITH protect, constant(uar_get_code_by("MEANING",29321,"DEMOMODS"))
 DECLARE state_encntr_except = f8 WITH protect, constant(uar_get_code_by("MEANING",29321,"ENCNTRCMB")
  )
 DECLARE state_encntr_updt = f8 WITH protect, constant(uar_get_code_by("MEANING",29321,"CODEUPT"))
 DECLARE state_referral = f8 WITH protect, constant(uar_get_code_by("MEANING",29321,"REFERRAL"))
 DECLARE state_diag_assoc_rev = f8 WITH protect, constant(uar_get_code_by("MEANING",29321,
   "DXASSOCREVW"))
 DECLARE state_batch_error = f8 WITH protect, constant(uar_get_code_by("MEANING",29321,"TRANS ERROR")
  )
 DECLARE state_batch_approved = f8 WITH protect, constant(uar_get_code_by("MEANING",29321,
   "TBATCHAPPROV"))
 DECLARE state_batch_out_bal = f8 WITH protect, constant(uar_get_code_by("MEANING",29321,"TRANSOOB"))
 DECLARE last_mod = vc WITH protect
 DECLARE disppos = i4 WITH protect
 DECLARE valuepos = i4 WITH protect
 DECLARE namepos = i4 WITH protect
 DECLARE entity_type_meaning = vc WITH protect, constant(uar_get_code_meaning( $INPUTENTITYTYPECD))
 EXECUTE ccl_prompt_api_dataset "AUTOSET", "DATASET", "ADVAPI"
 SET stat = makedataset(10)
 SET disppos = addstringfield("DISP","Display",visibile_ind,40)
 SET valuepos = addrealfield("VALUE","Value",invisibile_ind)
 SET namepos = addstringfield("NAME","Assigned To",visibile_ind,100)
 SET stat = setkeyfield(valuepos,1)
 IF (entity_type_meaning=meaning_claim)
  SET recordpos = getnextrecord(0)
  SET stat = setstringfield(recordpos,disppos,substring(1,40,uar_get_code_display(state_report_ready)
    ))
  SET stat = setrealfield(recordpos,valuepos,state_report_ready)
  SET recordpos = getnextrecord(0)
  SET stat = setstringfield(recordpos,disppos,substring(1,40,uar_get_code_display(state_pend_review))
   )
  SET stat = setrealfield(recordpos,valuepos,state_pend_review)
  SET recordpos = getnextrecord(0)
  SET stat = setstringfield(recordpos,disppos,substring(1,40,uar_get_code_display(
     state_late_chg_review)))
  SET stat = setrealfield(recordpos,valuepos,state_late_chg_review)
  SET recordpos = getnextrecord(0)
  SET stat = setstringfield(recordpos,disppos,substring(1,40,uar_get_code_display(state_variance)))
  SET stat = setrealfield(recordpos,valuepos,state_variance)
  SET recordpos = getnextrecord(0)
  SET stat = setstringfield(recordpos,disppos,substring(1,40,uar_get_code_display(state_rejected_837)
    ))
  SET stat = setrealfield(recordpos,valuepos,state_rejected_837)
 ELSEIF (entity_type_meaning=meaning_encounter)
  SET recordpos = getnextrecord(0)
  SET stat = setstringfield(recordpos,disppos,substring(1,40,uar_get_code_display(state_in_collect)))
  SET stat = setrealfield(recordpos,valuepos,state_in_collect)
  SET recordpos = getnextrecord(0)
  SET stat = setstringfield(recordpos,disppos,substring(1,40,uar_get_code_display(
     state_in_collect_preview)))
  SET stat = setrealfield(recordpos,valuepos,state_in_collect_preview)
  SET recordpos = getnextrecord(0)
  SET stat = setstringfield(recordpos,disppos,substring(1,40,uar_get_code_display(state_in_precollect
     )))
  SET stat = setrealfield(recordpos,valuepos,state_in_precollect)
  SET recordpos = getnextrecord(0)
  SET stat = setstringfield(recordpos,disppos,substring(1,40,uar_get_code_display(state_demo_mods)))
  SET stat = setrealfield(recordpos,valuepos,state_demo_mods)
  SET recordpos = getnextrecord(0)
  SET stat = setstringfield(recordpos,disppos,substring(1,40,uar_get_code_display(state_encntr_except
     )))
  SET stat = setrealfield(recordpos,valuepos,state_encntr_except)
  SET recordpos = getnextrecord(0)
  SET stat = setstringfield(recordpos,disppos,substring(1,40,uar_get_code_display(state_encntr_updt))
   )
  SET stat = setrealfield(recordpos,valuepos,state_encntr_updt)
  SET recordpos = getnextrecord(0)
  SET stat = setstringfield(recordpos,disppos,substring(1,40,uar_get_code_display(state_referral)))
  SET stat = setrealfield(recordpos,valuepos,state_referral)
  SET recordpos = getnextrecord(0)
  SET stat = setstringfield(recordpos,disppos,substring(1,40,uar_get_code_display(
     state_diag_assoc_rev)))
  SET stat = setrealfield(recordpos,valuepos,state_diag_assoc_rev)
 ELSEIF (entity_type_meaning=meaning_trans_batch)
  SET recordpos = getnextrecord(0)
  SET stat = setstringfield(recordpos,disppos,substring(1,40,uar_get_code_display(state_batch_error))
   )
  SET stat = setrealfield(recordpos,valuepos,state_batch_error)
  SET recordpos = getnextrecord(0)
  SET stat = setstringfield(recordpos,disppos,substring(1,40,uar_get_code_display(
     state_batch_approved)))
  SET stat = setrealfield(recordpos,valuepos,state_batch_approved)
  SET recordpos = getnextrecord(0)
  SET stat = setstringfield(recordpos,disppos,substring(1,40,uar_get_code_display(state_batch_out_bal
     )))
  SET stat = setrealfield(recordpos,valuepos,state_batch_out_bal)
 ELSE
  SELECT INTO "nl:"
   cvg.child_code_value
   FROM code_value cv,
    code_value_extension cve,
    code_value cv2,
    code_value_group cvg,
    code_value_extension cve2,
    code_value cv3
   PLAN (cv
    WHERE (cv.code_value= $INPUTENTITYTYPECD)
     AND cv.code_set=29320
     AND cv.active_ind=1)
    JOIN (cve
    WHERE cve.code_set=4002254
     AND cve.field_value=cv.cdf_meaning)
    JOIN (cv2
    WHERE cv2.code_value=cve.code_value
     AND  NOT (cv2.cdf_meaning IN (meaning_issue_assess, meaning_issue_resolut, meaning_issue_review)
    )
     AND cv2.active_ind=1)
    JOIN (cvg
    WHERE cvg.parent_code_value=cv2.code_value)
    JOIN (cve2
    WHERE cve2.code_value=cvg.child_code_value
     AND cve2.code_set=29321
     AND cve2.field_name="SEQUENCE")
    JOIN (cv3
    WHERE cv3.code_value=cvg.child_code_value
     AND cv3.active_ind=1
     AND cv3.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
     AND cv3.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3))
   ORDER BY cnvtint(cve2.field_value), cve2.code_value
   DETAIL
    recordpos = getnextrecord(0), stat = setstringfield(recordpos,disppos,uar_get_code_display(cvg
      .child_code_value)), stat = setrealfield(recordpos,valuepos,cvg.child_code_value),
    stat = setstringfield(recordpos,namepos,"Tibbs, Adam")
   WITH nocounter
  ;end select
 ENDIF
 SET stat = closedataset(0)
 SET last_mod = "000"
END GO
