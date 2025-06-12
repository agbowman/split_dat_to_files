CREATE PROGRAM dm_ocd_install_cvg:dba
 DECLARE doic_err_msg = c132
 DECLARE doic_err_ind = i2
 SET fname = build("dm_ocd_install_cvg_",cnvtstring(ocd_number),".dat")
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
   1 count = i4
   1 qual[*]
     2 code_set = f8
     2 cs[*]
       3 parent_code_value = f8
       3 child_code_value = f8
       3 collation_seq = i4
       3 child_code_set = f8
       3 p_cki = vc
       3 c_cki = vc
       3 delete_ind = i2
     2 knt = i4
 )
 SET list->count = 0
 SELECT DISTINCT INTO "nl:"
  dm.code_set
  FROM dm_afd_code_value_group dm,
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
 SET doic_cnt = 0
 FOR (doic_cnt = 1 TO list->count)
   SELECT INTO "nl:"
    dcv.code_set, dcv.parent_code_value, dcv.child_code_value,
    dcv.collation_seq, dcv.child_code_set, dc.cki,
    dc.active_ind
    FROM dm_afd_code_value_group dcv,
     dm_afd_code_value dc
    WHERE (dcv.code_set=list->qual[doic_cnt].code_set)
     AND dcv.alpha_feature_nbr=anumber
     AND dc.code_value=dcv.parent_code_value
     AND dc.alpha_feature_nbr=dcv.alpha_feature_nbr
     AND dc.code_set=dcv.code_set
    HEAD dcv.code_set
     list->qual[doic_cnt].knt = 0, kntt = 0
    DETAIL
     kntt = (kntt+ 1), stat = alterlist(list->qual[doic_cnt].cs,kntt), list->qual[doic_cnt].cs[kntt].
     parent_code_value = dcv.parent_code_value,
     list->qual[doic_cnt].cs[kntt].child_code_value = dcv.child_code_value, list->qual[doic_cnt].cs[
     kntt].collation_seq = dcv.collation_seq, list->qual[doic_cnt].cs[kntt].child_code_set = dcv
     .child_code_set,
     list->qual[doic_cnt].cs[kntt].p_cki = dc.cki, list->qual[doic_cnt].cs[kntt].delete_ind = 0
    FOOT REPORT
     list->qual[doic_cnt].knt = kntt
    WITH nocounter
   ;end select
   SELECT INTO "nl:"
    dcv.code_set, dcv.parent_code_value, dcv.child_code_value,
    dcv.collation_seq, dcv.child_code_set, dc.cki,
    dc.active_ind
    FROM dm_afd_code_value dc,
     (dummyt d  WITH seq = value(list->qual[doic_cnt].knt))
    PLAN (d)
     JOIN (dc
     WHERE (dc.code_set=list->qual[doic_cnt].cs[d.seq].child_code_set)
      AND (dc.code_value=list->qual[doic_cnt].cs[d.seq].child_code_value))
    DETAIL
     list->qual[doic_cnt].cs[d.seq].c_cki = dc.cki
    WITH nocounter
   ;end select
   SET doic_i = 0
   FOR (doic_i = 1 TO list->qual[doic_cnt].knt)
     FREE SET dmrequest
     RECORD dmrequest(
       1 code_set = f8
       1 parent_code_value = f8
       1 child_code_value = f8
       1 collation_seq = i4
       1 child_code_set = f8
       1 delete_ind = i2
       1 p_cki = vc
       1 c_cki = vc
     )
     SET dmrequest->code_set = list->qual[doic_cnt].code_set
     SET dmrequest->parent_code_value = list->qual[doic_cnt].cs[doic_i].parent_code_value
     SET dmrequest->child_code_value = list->qual[doic_cnt].cs[doic_i].child_code_value
     SET dmrequest->collation_seq = list->qual[doic_cnt].cs[doic_i].collation_seq
     SET dmrequest->child_code_set = list->qual[doic_cnt].cs[doic_i].child_code_set
     SET dmrequest->p_cki = list->qual[doic_cnt].cs[doic_i].p_cki
     SET dmrequest->c_cki = list->qual[doic_cnt].cs[doic_i].c_cki
     SET dmrequest->delete_ind = list->qual[doic_cnt].cs[doic_i].delete_ind
     SET reqinfo->updt_id = 111
     SET reqinfo->updt_applctx = 111
     EXECUTE dm_code_value_group
   ENDFOR
 ENDFOR
 COMMIT
#end_program
END GO
