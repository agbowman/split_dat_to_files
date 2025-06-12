CREATE PROGRAM afc_load_gen_lab:dba
 EXECUTE cclseclogin
 SET message = nowindow
 FREE SET request
 RECORD request(
   1 nbr_of_recs = i4
   1 qual[*]
     2 action = i2
     2 ext_id = f8
     2 ext_contributor_cd = f8
     2 parent_qual_ind = f8
     2 ext_owner_cd = f8
     2 ext_description = vc
     2 ext_short_desc = c50
     2 careset_ind = i2
     2 workload_only_ind = i2
     2 price_qual = i2
     2 billcode_qual = i2
     2 child_qual = i2
     2 children[*]
       3 ext_id = f8
       3 ext_contributor_cd = f8
       3 ext_description = c100
       3 ext_short_desc = c50
       3 ext_owner_cd = f8
       3 ext_sub_owner_cd = f8
     2 ext_sub_owner_cd = f8
 )
 IF (validate(reqinfo->commit_ind,9)=9)
  FREE SET reqinfo
  RECORD reqinfo(
    1 commit_ind = i2
    1 updt_id = f8
    1 position_cd = f8
    1 updt_app = i4
    1 updt_task = i4
    1 updt_req = i4
    1 updt_applctx = i4
  )
  SET reqinfo->updt_id = 1111
  SET reqinfo->updt_applctx = 12
  SET reqinfo->updt_task = 999999
 ENDIF
 SET true = 0
 SET false = 1
 DECLARE codeset = i4
 DECLARE cdf_meaning = c12
 DECLARE cnt = i4
 DECLARE gl_cont_cd = f8
 DECLARE gl_child_cont_cd = f8
 SET gen_lab = 0.0
 SET gen_lab =  $1
 SET ownerdisp = fillstring(40," ")
 SET codeset = 13016
 SET cdf_meaning = "ORD CAT"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,gl_cont_cd)
 CALL echo(build("the ord cat code is : ",gl_cont_cd))
 SET codeset = 13016
 SET cdf_meaning = "TASK ASSAY"
 SET cnt = 1
 SET stat = uar_get_meaning_by_codeset(codeset,cdf_meaning,cnt,gl_child_cont_cd)
 CALL echo(build("the task assay code is : ",gl_child_cont_cd))
 SELECT INTO "NL:"
  a.display, ownerdisplay = trim(a.display,3)
  FROM code_value a
  WHERE a.code_set=106
   AND (a.code_value= $1)
  DETAIL
   ownerdisp = ownerdisplay
  WITH nocounter
 ;end select
 SET parent_ndx = 0
 SET child_ndx = 0
 SELECT INTO "nl:"
  a.catalog_cd, desc = trim(a.description), short_desc = trim(a.primary_mnemonic),
  a.catalog_type_cd, c.task_assay_cd, taskdesc = trim(c.description),
  mnem = trim(c.mnemonic), c.activity_type_cd
  FROM dummyt d1,
   dummyt d2,
   order_catalog a,
   profile_task_r b,
   discrete_task_assay c
  PLAN (a
   WHERE a.activity_type_cd=gen_lab
    AND a.active_ind=1)
   JOIN (d1)
   JOIN (b
   WHERE a.catalog_cd=b.catalog_cd
    AND b.active_ind=1)
   JOIN (d2)
   JOIN (c
   WHERE b.task_assay_cd=c.task_assay_cd
    AND c.active_ind=1)
  ORDER BY a.catalog_cd, c.task_assay_cd
  HEAD a.catalog_cd
   child_ndx = 0, parent_ndx += 1, stat = alterlist(request->qual,parent_ndx),
   request->qual[parent_ndx].child_qual = child_ndx, hold_parent_cd = a.catalog_cd, request->qual[
   parent_ndx].action = 1,
   request->qual[parent_ndx].ext_id = a.catalog_cd, request->qual[parent_ndx].ext_owner_cd = a
   .activity_type_cd, stat = assign(validate(request->qual[parent_ndx].ext_sub_owner_cd),a
    .activity_subtype_cd),
   request->qual[parent_ndx].ext_contributor_cd = gl_cont_cd, request->qual[parent_ndx].
   ext_description = desc, request->qual[parent_ndx].ext_short_desc = short_desc,
   request->qual[parent_ndx].parent_qual_ind = 1
  DETAIL
   IF (c.task_assay_cd > 0)
    child_ndx += 1, stat = alterlist(request->qual[parent_ndx].children,child_ndx), request->qual[
    parent_ndx].children[child_ndx].ext_id = c.task_assay_cd,
    request->qual[parent_ndx].children[child_ndx].ext_contributor_cd = gl_child_cont_cd, request->
    qual[parent_ndx].children[child_ndx].ext_description = taskdesc, request->qual[parent_ndx].
    children[child_ndx].ext_short_desc = mnem,
    request->qual[parent_ndx].children[child_ndx].ext_owner_cd = c.activity_type_cd
    IF (validate(request->qual[parent_ndx].ext_sub_owner_cd,0))
     request->qual[parent_ndx].children[child_ndx].ext_sub_owner_cd = request->qual[parent_ndx].
     ext_sub_owner_cd
    ENDIF
   ENDIF
   request->qual[parent_ndx].child_qual = child_ndx
  WITH nocounter, outerjoin = d1, outerjoin = d2
 ;end select
 EXECUTE afc_load_caresets gen_lab
 SET request->nbr_of_recs = parent_ndx
 IF (( $2=1))
  EXECUTE afc_add_reference_api
 ELSE
  SET dashline = fillstring(130,"-")
  SET parcnt = 0
  SET childcnt = 0
  SET totcnt = 0
  SET ownerdisp = trim(ownerdisp,3)
  SELECT
   d1.seq
   FROM (dummyt d1  WITH seq = value(request->nbr_of_recs))
   PLAN (d1)
   ORDER BY request->qual[d1.seq].ext_owner_cd, request->qual[d1.seq].ext_id
   HEAD REPORT
    col 01, "date: ", curdate,
    " ", curtime, col 40,
    "Missing ", ownerdisp, " Bill Item Report",
    row + 1
   HEAD PAGE
    col 01, "Par Id", col 10,
    "Child Id", col 20, "Description",
    col 50, "Child Activity Type", row + 1,
    col 01, dashline, row + 1
   DETAIL
    parcnt += 1, col 01, request->qual[d1.seq].ext_id"########",
    col 20, request->qual[d1.seq].ext_description
    FOR (y = 1 TO request->qual[d1.seq].child_qual)
      childcnt += 1, row + 1, col 10,
      request->qual[d1.seq].children[y].ext_id"########", col 20, request->qual[d1.seq].children[y].
      ext_description,
      col 45, request->qual[d1.seq].children[y].ext_owner_cd
    ENDFOR
    row + 2
   FOOT PAGE
    col 100, "Page: ", curpage"####"
   FOOT REPORT
    totcnt = (parcnt+ childcnt), col 50, "Parent Count: ",
    parcnt"#####", col 75, "Child Count: ",
    childcnt"#####", col 100, "Total: ",
    totcnt"########"
   WITH nocounter
  ;end select
 ENDIF
END GO
