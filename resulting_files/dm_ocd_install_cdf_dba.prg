CREATE PROGRAM dm_ocd_install_cdf:dba
 SET fname = build("dm_ocd_install_cdf_",cnvtstring(ocd_number),".dat")
 SELECT INTO value(fname)
  d.*
  FROM dual d
  DETAIL
   "set trace noreflog go"
  WITH nocounter, maxrow = 1, maxcol = 80,
   format = variable, formfeed = none
 ;end select
 SET envid = 0.0
 SET anumber = ocd_number
 SELECT INTO "nl:"
  d.environment_id
  FROM dm_environment d
  WHERE d.environment_name=env_name
  DETAIL
   envid = d.environment_id
  WITH nocounter
 ;end select
 IF (curqual=0)
  CALL echo("Invalid Environment Name")
  GO TO end_program
 ENDIF
 FREE SET list
 RECORD list(
   1 qual[*]
     2 code_set = f8
     2 cs[*]
       3 display = c40
       3 cdf_meaning = c12
       3 definition = vc
     2 knt = i4
   1 count = i4
 )
 SET list->count = 0
 SET stat = alterlist(list->qual,10)
 SELECT DISTINCT INTO "nl:"
  dm.code_set
  FROM dm_afd_common_data_foundation dm,
   dm_alpha_features_env da
  WHERE dm.alpha_feature_nbr=anumber
   AND dm.alpha_feature_nbr=da.alpha_feature_nbr
   AND da.status != "SUCCESS"
   AND da.environment_id=envid
  ORDER BY dm.code_set
  DETAIL
   list->count = (list->count+ 1)
   IF (mod(list->count,10)=1)
    stat = alterlist(list->qual,(list->count+ 9))
   ENDIF
   list->qual[list->count].code_set = dm.code_set
  WITH nocounter
 ;end select
 SET cnt = 0
 FOR (cnt = 1 TO list->count)
   SELECT INTO "nl:"
    dcv.code_set, dcv.cdf_meaning, dcv.display,
    dcv.definition
    FROM dm_afd_common_data_foundation dcv
    WHERE (dcv.code_set=list->qual[cnt].code_set)
     AND dcv.alpha_feature_nbr=anumber
    HEAD dcv.code_set
     list->qual[cnt].code_set = dcv.code_set, list->qual[cnt].knt = 0, kntt = 0
    DETAIL
     kntt = (kntt+ 1), stat = alterlist(list->qual[cnt].cs,kntt), list->qual[cnt].cs[kntt].display =
     replace(dcv.display,'"',"'",0),
     list->qual[cnt].cs[kntt].cdf_meaning = replace(dcv.cdf_meaning,'"',"'",0), list->qual[cnt].cs[
     kntt].definition = replace(dcv.definition,'"',"'",0)
    FOOT REPORT
     list->qual[cnt].knt = kntt
    WITH nocounter
   ;end select
   SET i = 0
   FOR (i = 1 TO list->qual[cnt].knt)
     FREE SET dmrequest
     RECORD dmrequest(
       1 code_set = i4
       1 display = c40
       1 cdf_meaning = c12
       1 definition = vc
     )
     SET dmrequest->code_set = list->qual[cnt].code_set
     SET dmrequest->display = list->qual[cnt].cs[i].display
     SET dmrequest->cdf_meaning = list->qual[cnt].cs[i].cdf_meaning
     SET dmrequest->definition = list->qual[cnt].cs[i].definition
     SET reqinfo->updt_id = 111
     SET reqinfo->updt_applctx = 111
     EXECUTE dm_common_data_foundation
   ENDFOR
 ENDFOR
 COMMIT
#end_program
END GO
