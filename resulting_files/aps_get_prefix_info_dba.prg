CREATE PROGRAM aps_get_prefix_info:dba
 RECORD reply(
   1 prefix_cd = f8
   1 prefix_name = c2
   1 prefix_desc = c50
   1 site_cd = f8
   1 unformatted_site_disp = c40
   1 accession_format_cd = f8
   1 order_catalog_cd = f8
   1 case_type_cd = f8
   1 case_type_disp = c40
   1 case_type_desc = vc
   1 case_type_mean = c12
   1 specimen_meaning_qual[1]
     2 specimen_meaning = c12
   1 group_cd = f8
   1 specimen_grouping_cd = f8
   1 tag_group_cnt = i2
   1 tag_group_qual[1]
     2 tag_type_flag = i2
     2 tag_separator = c1
     2 tag_group_cd = f8
     2 primary_ind = i2
     2 tag_cnt = i2
     2 tag_qual[*]
       3 tag_cd = f8
       3 tag_display = c7
       3 tag_sequence = i4
   1 site_disp = c40
   1 status_data
     2 status = c1
     2 subeventstatus[1]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
#script
 SET reply->status_data.status = "F"
 DECLARE tag_defined = c1 WITH private, noconstant("F")
 DECLARE tag_where = vc WITH protect, noconstant(" ")
 DECLARE prefix_where = vc WITH protect, noconstant(" ")
 IF ((request->tag_type_bitmap=0))
  SET tag_where = "0 = 0"
 ELSE
  SET tag_where = "tg.tag_type_flag IN ("
  IF (band(request->tag_type_bitmap,1)=1)
   SET tag_defined = "T"
   SET tag_where = concat(trim(tag_where),"1")
  ENDIF
  IF (band(request->tag_type_bitmap,2)=2)
   IF (tag_defined="F")
    SET tag_defined = "T"
    SET tag_where = concat(trim(tag_where),"2")
   ELSE
    SET tag_where = concat(trim(tag_where),",2")
   ENDIF
  ENDIF
  IF (band(request->tag_type_bitmap,4)=4)
   IF (tag_defined="F")
    SET tag_defined = "T"
    SET tag_where = concat(trim(tag_where),"3")
   ELSE
    SET tag_where = concat(trim(tag_where),",3")
   ENDIF
  ENDIF
  IF (tag_defined="F")
   SET tag_where = "0 = 0"
  ELSE
   SET tag_where = concat(trim(tag_where),")")
  ENDIF
 ENDIF
 IF ((request->prefix_cd != 0))
  SET prefix_where = build(request->prefix_cd," = P.PREFIX_ID")
 ELSE
  SET prefix_where = concat("'",trim(request->prefix_name),"' = P.PREFIX_NAME")
 ENDIF
 EXECUTE aps_get_prefix_info1 parser(trim(prefix_where)), parser(trim(tag_where))
END GO
