CREATE PROGRAM dm_common_data_foundation_imp
 RECORD dmrequest(
   1 code_set = i4
   1 cdf_meaning = c12
   1 display = c40
   1 definition = c255
 )
 SET dmrequest->code_set = cnvtint(requestin->list_0[1].code_set)
 SET dmrequest->cdf_meaning = substring(1,12,requestin->list_0[1].cdf_meaning)
 SET dmrequest->display = substring(1,40,requestin->list_0[1].display)
 SET dmrequest->definition = substring(1,255,requestin->list_0[1].definition)
 EXECUTE dm_common_data_foundation
END GO
