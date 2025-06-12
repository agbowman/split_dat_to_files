CREATE PROGRAM dm_get_tbl_ocd_indx:dba
 RECORD reply(
   1 qual[*]
     2 index_name = vc
     2 ind_status = c1
   1 count = i4
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 SET tname = fillstring(40," ")
 SET reply->status_data.status = "F"
 SET onumber = request->ocd_number
 SET tname = request->table_name
 SET reply->count = 0
 SET sch_version = request->rev_number
 SET ocd_flag = 0
 FREE SET r1
 RECORD r1(
   1 rev_date = dq8
   1 ocd_date = dq8
 )
 SET r1->rev_date = 0
 SET r1->ocd_date = 0
 SELECT INTO "nl:"
  b.schema_date
  FROM dm_schema_version b
  WHERE b.schema_version=sch_version
  DETAIL
   r1->rev_date = b.schema_date
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  b.schema_date
  FROM dm_afd_tables b,
   dm_alpha_features a
  WHERE b.table_name=tname
   AND b.alpha_feature_nbr != onumber
   AND a.alpha_feature_nbr=b.alpha_feature_nbr
   AND a.rev_number=sch_version
  DETAIL
   IF ((b.schema_date > r1->rev_date))
    r1->rev_date = b.schema_date
   ENDIF
   ocd_flag = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  b.schema_date
  FROM dm_afd_tables b
  WHERE b.alpha_feature_nbr=onumber
   AND b.table_name=tname
  DETAIL
   IF ((b.schema_date > r1->ocd_date))
    r1->ocd_date = b.schema_date
   ENDIF
  WITH nocounter
 ;end select
 IF (ocd_flag=1)
  SELECT DISTINCT INTO "nl:"
   d.index_name
   FROM dm_afd_indexes d,
    dm_afd_tables a
   WHERE a.table_name=tname
    AND datetimediff(a.schema_date,cnvtdatetime(r1->rev_date))=0
    AND d.alpha_feature_nbr=a.alpha_feature_nbr
    AND d.table_name=a.table_name
   ORDER BY d.index_name
   DETAIL
    reply->count = (reply->count+ 1), stat = alterlist(reply->qual,reply->count), reply->qual[reply->
    count].index_name = d.index_name,
    reply->qual[reply->count].ind_status = "N"
   WITH nocounter
  ;end select
 ELSE
  SELECT DISTINCT INTO "nl:"
   d.index_name
   FROM dm_indexes d
   WHERE d.table_name=tname
    AND datetimediff(d.schema_date,cnvtdatetime(r1->rev_date))=0
   ORDER BY d.index_name
   DETAIL
    reply->count = (reply->count+ 1), stat = alterlist(reply->qual,reply->count), reply->qual[reply->
    count].index_name = d.index_name,
    reply->qual[reply->count].ind_status = "N"
   WITH nocounter
  ;end select
 ENDIF
 IF ((r1->ocd_date > r1->rev_date))
  IF (ocd_flag=1)
   SELECT DISTINCT INTO "nl:"
    a.index_name
    FROM dm_afd_indexes a,
     dm_afd_tables b
    WHERE b.alpha_feature_nbr=onumber
     AND b.table_name=tname
     AND datetimediff(b.schema_date,cnvtdatetime(r1->ocd_date))=0
     AND a.alpha_feature_nbr=b.alpha_feature_nbr
     AND a.table_name=b.table_name
     AND  NOT ( EXISTS (
    (SELECT
     "X"
     FROM dm_afd_indexes d,
      dm_afd_tables c
     WHERE c.table_name=tname
      AND datetimediff(c.schema_date,cnvtdatetime(r1->rev_date))=0
      AND c.alpha_feature_nbr != onumber
      AND d.alpha_feature_nbr=c.alpha_feature_nbr
      AND d.table_name=c.table_name
      AND d.index_name=a.index_name)))
    ORDER BY a.index_name
    DETAIL
     reply->count = (reply->count+ 1), stat = alterlist(reply->qual,reply->count), reply->qual[reply
     ->count].index_name = a.index_name,
     reply->qual[reply->count].ind_status = "Y"
    WITH nocounter
   ;end select
  ELSE
   SELECT DISTINCT INTO "nl:"
    a.index_name
    FROM dm_afd_indexes a,
     dm_afd_tables b
    WHERE b.table_name=tname
     AND datetimediff(b.schema_date,cnvtdatetime(r1->ocd_date))=0
     AND b.alpha_feature_nbr=onumber
     AND a.table_name=b.table_name
     AND a.alpha_feature_nbr=b.alpha_feature_nbr
     AND  NOT ( EXISTS (
    (SELECT
     "X"
     FROM dm_indexes d
     WHERE d.table_name=tname
      AND datetimediff(d.schema_date,cnvtdatetime(r1->rev_date))=0
      AND d.index_name=a.index_name)))
    ORDER BY a.index_name
    DETAIL
     reply->count = (reply->count+ 1), stat = alterlist(reply->qual,reply->count), reply->qual[reply
     ->count].index_name = a.index_name,
     reply->qual[reply->count].ind_status = "Y"
    WITH nocounter
   ;end select
  ENDIF
 ENDIF
 SET reply->status_data.status = "S"
END GO
