CREATE PROGRAM afc_fix_default_owner_codes:dba
 DECLARE versionnbr = vc
 SET versionnbr = "001"
 CALL echo(build("AFC_FIX_DEFAULT_OWNER_CODES Version: ",versionnbr))
 RECORD def_items(
   1 qual[*]
     2 bi_id = f8
     2 ext_ref_id = f8
     2 ext_ref_cd = f8
     2 ext_desc = c100
     2 match_ind = f8
     2 ext_owner_cd = f8
 )
 SET count1 = 0
 SELECT INTO "nl:"
  b.ext_child_reference_id, b.ext_child_contributor_cd, b.bill_item_id
  FROM bill_item b
  WHERE b.active_ind=1
   AND b.ext_parent_reference_id=0
   AND b.ext_owner_cd=0
  ORDER BY b.ext_child_reference_id
  DETAIL
   count1 = (count1+ 1), stat = alterlist(def_items->qual,count1), def_items->qual[count1].bi_id = b
   .bill_item_id,
   def_items->qual[count1].ext_ref_id = b.ext_child_reference_id, def_items->qual[count1].ext_ref_cd
    = b.ext_child_contributor_cd, def_items->qual[count1].ext_desc = b.ext_description,
   def_items->qual[count1].ext_owner_cd = 0
  WITH nocounter
 ;end select
 CALL echo(count1,0)
 CALL echo(" default items with 0 owner code found...")
 IF (count1 > 0)
  SELECT INTO "nl:"
   b.*
   FROM bill_item b,
    (dummyt d1  WITH seq = value(size(def_items->qual,5)))
   PLAN (d1)
    JOIN (b
    WHERE (b.ext_child_reference_id=def_items->qual[d1.seq].ext_ref_id)
     AND (b.ext_child_contributor_cd=def_items->qual[d1.seq].ext_ref_cd)
     AND b.ext_parent_reference_id != 0
     AND b.active_ind=1)
   DETAIL
    def_items->qual[d1.seq].match_ind = 1, def_items->qual[d1.seq].ext_owner_cd = b.ext_owner_cd
   WITH maxqual(b,1), nocounter
  ;end select
  SELECT
   bi_id = def_items->qual[d1.seq].bi_id, desc = def_items->qual[d1.seq].ext_desc, match = def_items
   ->qual[d1.seq].match_ind,
   ext_owner_cd = def_items->qual[d1.seq].ext_owner_cd
   FROM (dummyt d1  WITH seq = value(size(def_items->qual,5)))
   PLAN (d1)
   ORDER BY match, ext_owner_cd, bi_id
   HEAD REPORT
    col 50, "This report shows default items with 0 owner code, and how they'll be updated", row + 1,
    col 05, "Created by:	", curuser,
    row + 1, col 05, "Time:		",
    curdate, " ", curtime,
    row + 1
   HEAD PAGE
    col 00, "bi id", col 10,
    "bi desc", col 79, "owner cd",
    row + 1
   HEAD match
    count1 = 0
    IF (match=0)
     col 00, "These items had no matching unique item."
    ELSE
     row + 1, col 00, "These items found unique item matches."
    ENDIF
    row + 1
   DETAIL
    count1 = (count1+ 1), col 00, bi_id"########",
    col 10, desc, col 79,
    " ", ext_owner_cd"########", row + 1
   FOOT  match
    col 10, "total: ", count1,
    row + 2
   WITH nocounter
  ;end select
  CALL echo("Updating default items' ext_owner_cd")
  UPDATE  FROM bill_item b,
    (dummyt d1  WITH seq = value(size(def_items->qual,5)))
   SET b.ext_owner_cd = def_items->qual[d1.seq].ext_owner_cd, b.updt_dt_tm = cnvtdatetime(curdate,
     curtime), b.updt_id = 2208,
    b.updt_task = 99999999
   PLAN (d1
    WHERE (def_items->qual[d1.seq].ext_owner_cd != 0))
    JOIN (b
    WHERE (b.bill_item_id=def_items->qual[d1.seq].bi_id))
   WITH nocounter
  ;end update
  CALL echo("done.  type commit go.")
 ENDIF
END GO
