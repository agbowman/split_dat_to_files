CREATE PROGRAM da_get_logical_domain_list:dba
 DECLARE cvcount = i4 WITH protect
 DECLARE stat = i4 WITH protect
 SELECT INTO "nl:"
  ld.mnemonic, ld.logical_domain_id
  FROM logical_domain ld
  WHERE ld.active_ind=1
  ORDER BY cnvtupper(ld.mnemonic)
  HEAD REPORT
   cvcount = 0
  DETAIL
   cvcount = (cvcount+ 1)
   IF (mod(cvcount,100)=1)
    stat = alterlist(reply->datacoll,(cvcount+ 99))
   ENDIF
   reply->datacoll[cvcount].currcv = trim(build2(ld.logical_domain_id),3), reply->datacoll[cvcount].
   description = ld.mnemonic
  FOOT REPORT
   stat = alterlist(reply->datacoll,cvcount)
  WITH nocounter
 ;end select
END GO
