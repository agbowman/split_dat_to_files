CREATE PROGRAM dm_ocd_install_cva:dba
 FREE RECORD doic_contrib_source
 RECORD doic_contrib_source(
   1 cv_cnt = i4
   1 cv_qual[*]
     2 code_value = f8
     2 cki = vc
 )
 SET doic_contrib_source->cv_cnt = 0
 FREE SET list
 RECORD list(
   1 qual[*]
     2 code_set = f8
     2 cs[*]
       3 alias = vc
       3 display = vc
       3 cdf_meaning = c12
       3 cki = vc
       3 active_ind = i2
       3 alias_type_meaning = vc
       3 contributor_source_cki = vc
     2 knt = i4
   1 count = i4
 )
 SET list->count = 0
 SET stat = alterlist(list->qual,10)
 SET fname = build("dm_ocd_install_cva_",cnvtstring(ocd_number),".dat")
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
 SELECT INTO "nl:"
  cv.code_value, cv.display
  FROM dm_afd_code_value cv
  WHERE cv.code_set=73
  ORDER BY cv.code_value, cv.updt_dt_tm DESC, cv.alpha_feature_nbr DESC
  HEAD cv.code_value
   doic_contrib_source->cv_cnt = (doic_contrib_source->cv_cnt+ 1)
   IF (mod(doic_contrib_source->cv_cnt,10)=1)
    stat = alterlist(doic_contrib_source->cv_qual,(doic_contrib_source->cv_cnt+ 9))
   ENDIF
   doic_contrib_source->cv_qual[doic_contrib_source->cv_cnt].code_value = cv.code_value,
   doic_contrib_source->cv_qual[doic_contrib_source->cv_cnt].cki = cv.cki
  FOOT REPORT
   stat = alterlist(doic_contrib_source->cv_qual,doic_contrib_source->cv_cnt)
  WITH nocounter
 ;end select
 SELECT DISTINCT INTO "nl:"
  dm.code_set
  FROM dm_afd_code_value_alias dm,
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
    dcv.code_set, dcv.code_value, dcv.alias,
    dcv.contributor_source_cd, dcv.alias_type_meaning, dc.cdf_meaning,
    dc.display, dc.active_ind, dc.cki,
    dca.display
    FROM dm_afd_code_value_alias dcv,
     dm_afd_code_value dc,
     (dummyt d  WITH seq = doic_contrib_source->cv_cnt)
    PLAN (dcv
     WHERE (dcv.code_set=list->qual[cnt].code_set)
      AND dcv.alpha_feature_nbr=anumber)
     JOIN (dc
     WHERE dc.code_value=dcv.code_value
      AND dc.code_set=dcv.code_set
      AND dc.alpha_feature_nbr=dcv.alpha_feature_nbr)
     JOIN (d
     WHERE (dcv.contributor_source_cd=doic_contrib_source->cv_qual[d.seq].code_value))
    HEAD dcv.code_set
     list->qual[cnt].code_set = dcv.code_set, list->qual[cnt].knt = 0, kntt = 0
    DETAIL
     kntt = (kntt+ 1), stat = alterlist(list->qual[cnt].cs,kntt), list->qual[cnt].cs[kntt].cki = dc
     .cki,
     list->qual[cnt].cs[kntt].alias = replace(dcv.alias,'"',"'",0), list->qual[cnt].cs[kntt].
     alias_type_meaning = replace(dcv.alias_type_meaning,'"',"'",0), list->qual[cnt].cs[kntt].
     contributor_source_cki = doic_contrib_source->cv_qual[d.seq].cki,
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
       1 alias = vc
       1 code_set = i4
       1 display = vc
       1 cdf_meaning = c12
       1 cki = vc
       1 active_ind = i2
       1 alias_type_meaning = vc
       1 contributor_source_cki = vc
     )
     SET dmrequest->code_set = list->qual[cnt].code_set
     SET dmrequest->cki = list->qual[cnt].cs[i].cki
     SET dmrequest->alias = list->qual[cnt].cs[i].alias
     SET dmrequest->alias_type_meaning = list->qual[cnt].cs[i].alias_type_meaning
     SET dmrequest->contributor_source_cki = list->qual[cnt].cs[i].contributor_source_cki
     SET dmrequest->display = list->qual[cnt].cs[i].display
     SET dmrequest->cdf_meaning = list->qual[cnt].cs[i].cdf_meaning
     SET dmrequest->active_ind = list->qual[cnt].cs[i].active_ind
     SET reqinfo->updt_id = 111
     SET reqinfo->updt_applctx = 111
     EXECUTE dm_code_value_alias
   ENDFOR
 ENDFOR
 COMMIT
#end_program
END GO
