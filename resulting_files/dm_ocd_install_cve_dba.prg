CREATE PROGRAM dm_ocd_install_cve:dba
 SET fname = build("dm_ocd_install_cve_",cnvtstring(ocd_number),".dat")
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
       3 field_name = c32
       3 code_set = i4
       3 display = vc
       3 cdf_meaning = c12
       3 active_ind = i2
       3 cki = vc
       3 field_type = i4
       3 field_value = c100
     2 knt = i4
   1 count = i4
 )
 SET list->count = 0
 SET stat = alterlist(list->qual,10)
 SELECT DISTINCT INTO "nl:"
  dm.code_set
  FROM dm_afd_code_value_extension dm,
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
    dcv.code_set, dcv.code_value, dcv.field_name,
    dcv.field_type, dcv.field_value, dc.display,
    dc.cdf_meaning, dc.cki, dc.active_ind
    FROM dm_afd_code_value_extension dcv,
     dm_afd_code_value dc
    WHERE (dcv.code_set=list->qual[cnt].code_set)
     AND dcv.alpha_feature_nbr=anumber
     AND dc.code_value=dcv.code_value
     AND dc.alpha_feature_nbr=dcv.alpha_feature_nbr
     AND dc.code_set=dcv.code_set
    HEAD dcv.code_set
     list->qual[cnt].code_set = dcv.code_set, list->qual[cnt].knt = 0, kntt = 0
    DETAIL
     kntt = (kntt+ 1), stat = alterlist(list->qual[cnt].cs,kntt), list->qual[cnt].cs[kntt].cki = dc
     .cki,
     list->qual[cnt].cs[kntt].field_name = replace(dcv.field_name,'"',"'",0), list->qual[cnt].cs[kntt
     ].field_value = replace(dcv.field_value,'"',"'",0), list->qual[cnt].cs[kntt].field_type = dcv
     .field_type,
     list->qual[cnt].cs[kntt].display = replace(dc.display,'"',"'",0), list->qual[cnt].cs[kntt].
     cdf_meaning = replace(dc.cdf_meaning,'"',"'",0), list->qual[cnt].cs[kntt].active_ind = dc
     .active_ind
    FOOT REPORT
     list->qual[cnt].knt = kntt
    WITH nocounter
   ;end select
   SET i = 0
   FOR (i = 1 TO list->qual[cnt].knt)
     FREE SET dmrequest
     RECORD dmrequest(
       1 field_name = c32
       1 code_set = i4
       1 display = vc
       1 cdf_meaning = c12
       1 active_ind = i2
       1 cki = vc
       1 field_type = i4
       1 field_value = c100
     )
     SET dmrequest->code_set = list->qual[cnt].code_set
     SET dmrequest->cki = list->qual[cnt].cs[i].cki
     SET dmrequest->field_name = list->qual[cnt].cs[i].field_name
     SET dmrequest->field_value = list->qual[cnt].cs[i].field_value
     SET dmrequest->field_type = list->qual[cnt].cs[i].field_type
     SET dmrequest->display = list->qual[cnt].cs[i].display
     SET dmrequest->cdf_meaning = list->qual[cnt].cs[i].cdf_meaning
     SET dmrequest->active_ind = list->qual[cnt].cs[i].active_ind
     SET reqinfo->updt_id = 111
     SET reqinfo->updt_applctx = 111
     EXECUTE dm_code_value_extension
   ENDFOR
 ENDFOR
 COMMIT
#end_program
END GO
