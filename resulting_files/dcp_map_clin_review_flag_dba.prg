CREATE PROGRAM dcp_map_clin_review_flag:dba
 SET modify = predeclare
 IF ( NOT (validate(reply,0)))
  RECORD reply(
    1 map_to_value = i2
  )
 ENDIF
 DECLARE mapordersclinreviewflag(needrxverifyind=i2) = i2
 DECLARE maporderactionclinreviewflag(needverifyind=i2) = i2
 DECLARE maporderactionneedsverifyindtoorderneedsverifyind(needverifyind=i2) = i2
 DECLARE last_mod = c3 WITH private, noconstant("")
 DECLARE mod_date = c10 WITH private, noconstant("")
 IF ((request->mapping_ind=1))
  SET reply->map_to_value = mapordersclinreviewflag(request->map_from_value)
 ELSEIF ((request->mapping_ind=2))
  SET reply->map_to_value = maporderactionclinreviewflag(request->map_from_value)
 ELSEIF ((request->mapping_ind=3))
  SET reply->map_to_value = maporderactionneedsverifyindtoorderneedsverifyind(request->map_from_value
   )
 ELSE
  SET reply->map_to_value = - (1)
 ENDIF
 SUBROUTINE mapordersclinreviewflag(needrxverifyind)
   DECLARE verified = i2 WITH protect, constant(0)
   DECLARE needs_review = i2 WITH protect, constant(1)
   DECLARE rejected = i2 WITH protect, constant(2)
   DECLARE clinreviewflag_unset = i2 WITH protect, constant(0)
   DECLARE clinreviewflag_needs_review = i2 WITH protect, constant(1)
   DECLARE clinreviewflag_reviewed = i2 WITH protect, constant(2)
   DECLARE clinreviewflag_rejected = i2 WITH protect, constant(3)
   DECLARE clinreviewflag_dna = i2 WITH protect, constant(4)
   CASE (needrxverifyind)
    OF verified:
     RETURN(clinreviewflag_reviewed)
    OF needs_review:
     RETURN(clinreviewflag_needs_review)
    OF rejected:
     RETURN(clinreviewflag_rejected)
   ENDCASE
   RETURN(clinreviewflag_needs_review)
 END ;Subroutine
 SUBROUTINE maporderactionclinreviewflag(needverifyind)
   DECLARE no_verify_needed = i2 WITH protect, constant(0)
   DECLARE needs_verify = i2 WITH protect, constant(1)
   DECLARE superceded = i2 WITH protect, constant(2)
   DECLARE verified = i2 WITH protect, constant(3)
   DECLARE rejected = i2 WITH protect, constant(4)
   DECLARE reviewed = i2 WITH protect, constant(5)
   DECLARE clinreviewflag_unset = i2 WITH protect, constant(0)
   DECLARE clinreviewflag_needs_review = i2 WITH protect, constant(1)
   DECLARE clinreviewflag_reviewed = i2 WITH protect, constant(2)
   DECLARE clinreviewflag_rejected = i2 WITH protect, constant(3)
   DECLARE clinreviewflag_dna = i2 WITH protect, constant(4)
   DECLARE clinreviewflag_superceded = i2 WITH protect, constant(5)
   CASE (needverifyind)
    OF no_verify_needed:
     RETURN(clinreviewflag_dna)
    OF needs_verify:
     RETURN(clinreviewflag_needs_review)
    OF superceded:
     RETURN(clinreviewflag_superceded)
    OF verified:
     RETURN(clinreviewflag_reviewed)
    OF rejected:
     RETURN(clinreviewflag_rejected)
    OF reviewed:
     RETURN(clinreviewflag_reviewed)
   ENDCASE
   RETURN(clinreviewflag_needs_review)
 END ;Subroutine
 SUBROUTINE maporderactionneedsverifyindtoorderneedsverifyind(needverifyind)
   DECLARE oa_no_verify_needed = i2 WITH protect, constant(0)
   DECLARE oa_needs_verify = i2 WITH protect, constant(1)
   DECLARE oa_superceded = i2 WITH protect, constant(2)
   DECLARE oa_verified = i2 WITH protect, constant(3)
   DECLARE oa_rejected = i2 WITH protect, constant(4)
   DECLARE oa_reviewed = i2 WITH protect, constant(5)
   DECLARE o_verified = i2 WITH protect, constant(0)
   DECLARE o_needs_review = i2 WITH protect, constant(1)
   DECLARE o_rejected = i2 WITH protect, constant(2)
   CASE (needverifyind)
    OF oa_no_verify_needed:
     RETURN(o_verified)
    OF oa_needs_verify:
     RETURN(o_needs_review)
    OF oa_superceded:
     RETURN(o_needs_review)
    OF oa_verified:
     RETURN(o_verified)
    OF oa_rejected:
     RETURN(o_rejected)
    OF oa_reviewed:
     RETURN(o_verified)
   ENDCASE
   RETURN(o_needs_review)
 END ;Subroutine
 SET last_mod = "002"
 SET mod_date = "11/15/2006"
 SET modify = nopredeclare
END GO
