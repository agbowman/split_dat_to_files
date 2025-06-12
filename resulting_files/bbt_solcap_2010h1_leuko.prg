CREATE PROGRAM bbt_solcap_2010h1_leuko
 DECLARE lmultiresleucnt = i4 WITH protect, noconstant(0)
 DECLARE lmultiwashcnt = i4 WITH protect, noconstant(0)
 DECLARE lnegantigencnt = i4 WITH protect, noconstant(0)
 SET stat = alterlist(reply->solcap,1)
 SET stat = alterlist(reply->solcap[1].other,1)
 SET stat = alterlist(reply->solcap[1].other[1].value,2)
 SET reply->solcap[1].identifier = "2010.1.00091.2"
 SET reply->solcap[1].degree_of_use_str = "No"
 SET reply->solcap[1].other[1].value[1].display = "Mulitple ISBT Attributes"
 SET reply->solcap[1].other[1].value[1].value_str = "No"
 SET reply->solcap[1].other[1].value[2].display = "Trans Req/Antigen Validation"
 SET reply->solcap[1].other[1].value[2].value_str = "No"
 SELECT INTO "nl:"
  FROM transfusion_requirements tr,
   trans_req_r trr,
   bb_isbt_attribute_r biar,
   bb_isbt_attribute bia
  PLAN (tr
   WHERE tr.requirement_cd > 0.0
    AND tr.codeset=1611
    AND tr.active_ind=1)
   JOIN (trr
   WHERE trr.requirement_cd=tr.requirement_cd
    AND trr.active_ind=1)
   JOIN (biar
   WHERE biar.attribute_cd=outerjoin(trr.special_testing_cd)
    AND biar.active_ind=outerjoin(1))
   JOIN (bia
   WHERE bia.bb_isbt_attribute_id=outerjoin(biar.bb_isbt_attribute_id)
    AND bia.active_ind=outerjoin(1))
  ORDER BY tr.requirement_cd
  HEAD tr.requirement_cd
   lmultiresleucnt = 0, lmultiwashcnt = 0, lnegantigencnt = 0
  DETAIL
   IF (findstring(cnvtupper("ResLeu"),cnvtupper(bia.standard_display),1,0))
    lmultiresleucnt = (lmultiresleucnt+ 1)
   ENDIF
   IF (findstring(cnvtupper("Washed"),cnvtupper(bia.standard_display),1,0))
    lmultiwashcnt = (lmultiwashcnt+ 1)
   ENDIF
   IF (uar_get_code_meaning(trr.special_testing_cd)="-")
    lnegantigencnt = (lnegantigencnt+ 1)
   ENDIF
  FOOT  tr.requirement_cd
   IF (((lmultiresleucnt >= 2) OR (lmultiwashcnt >= 2)) )
    reply->solcap[1].degree_of_use_str = "Yes", reply->solcap[1].other[1].value[1].display =
    "Mulitple ISBT Attributes", reply->solcap[1].other[1].value[1].value_str = "Yes"
   ENDIF
   IF (lnegantigencnt >= 1)
    reply->solcap[1].degree_of_use_str = "Yes", reply->solcap[1].other[1].value[2].display =
    "Trans Req/Antigen Validation", reply->solcap[1].other[1].value[2].value_str = "Yes"
   ENDIF
  WITH nocounter
 ;end select
END GO
