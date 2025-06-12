CREATE PROGRAM cmt_extent_readme:dba
 IF ( NOT (validate(readme_data,0)))
  FREE SET readme_data
  RECORD readme_data(
    1 ocd = i4
    1 readme_id = f8
    1 instance = i4
    1 readme_type = vc
    1 description = vc
    1 script = vc
    1 check_script = vc
    1 data_file = vc
    1 par_file = vc
    1 blocks = i4
    1 log_rowid = vc
    1 status = vc
    1 message = c255
    1 options = vc
    1 driver = vc
    1 batch_dt_tm = dq8
  )
 ENDIF
 DECLARE total_ext_num = i4
 DECLARE err_msg = c132
 DECLARE parse_str = c150
 DECLARE kia_version = c8 WITH public, noconstant(fillstring(8," "))
 SET total_ext_num = 0
 SET err_msg = fillstring(132," ")
 SET readme_data->status = "F"
 FREE RECORD extents
 RECORD extents(
   1 list[25]
     2 name = vc
     2 type = c5
     2 ext_size = i4
     2 upd_ind = i2
 )
 SET extents->list[1].name = "CMT_CONCEPT"
 SET extents->list[1].type = "TABLE"
 SET extents->list[1].ext_size = 2048
 SET extents->list[2].name = "XPKCMT_CONCEPT"
 SET extents->list[2].type = "INDEX"
 SET extents->list[2].ext_size = 128
 SET extents->list[3].name = "XIE1CMT_CONCEPT"
 SET extents->list[3].type = "INDEX"
 SET extents->list[3].ext_size = 128
 SET extents->list[4].name = "CMT_CONCEPT_EXPLODE"
 SET extents->list[4].type = "TABLE"
 SET extents->list[4].ext_size = 2048
 SET extents->list[5].name = "XPKCMT_CONCEPT_EXPLODE"
 SET extents->list[5].type = "INDEX"
 SET extents->list[5].ext_size = 512
 SET extents->list[6].name = "XIE1CMT_CONCEPT_EXPLODE"
 SET extents->list[6].type = "INDEX"
 SET extents->list[6].ext_size = 512
 SET extents->list[7].name = "CMT_CONCEPT_RELTN"
 SET extents->list[7].type = "TABLE"
 SET extents->list[7].ext_size = 5120
 SET extents->list[8].name = "XPKCMT_CONCEPT_RELTN"
 SET extents->list[8].type = "INDEX"
 SET extents->list[8].ext_size = 1024
 SET extents->list[9].name = "XIE1CMT_CONCEPT_RELTN"
 SET extents->list[9].type = "INDEX"
 SET extents->list[9].ext_size = 512
 SET extents->list[10].name = "NOMENCLATURE"
 SET extents->list[10].type = "TABLE"
 SET extents->list[10].ext_size = 2048
 SET extents->list[11].name = "XAK6NOMENCLATURE"
 SET extents->list[11].type = "INDEX"
 SET extents->list[11].ext_size = 1024
 SET extents->list[12].name = "XIE1NOMENCLATURE"
 SET extents->list[12].type = "INDEX"
 SET extents->list[12].ext_size = 1024
 SET extents->list[13].name = "XAK2NOMENCLATURE"
 SET extents->list[13].type = "INDEX"
 SET extents->list[13].ext_size = 512
 SET extents->list[14].name = "XAK5NOMENCLATURE"
 SET extents->list[14].type = "INDEX"
 SET extents->list[14].ext_size = 512
 SET extents->list[15].name = "XAK3NOMENCLATURE"
 SET extents->list[15].type = "INDEX"
 SET extents->list[15].ext_size = 512
 SET extents->list[16].name = "XIF2NOMENCLATURE"
 SET extents->list[16].type = "INDEX"
 SET extents->list[16].ext_size = 512
 SET extents->list[17].name = "XAK1NOMENCLATURE"
 SET extents->list[17].type = "INDEX"
 SET extents->list[17].ext_size = 512
 SET extents->list[18].name = "XAK4NOMENCLATURE"
 SET extents->list[18].type = "INDEX"
 SET extents->list[18].ext_size = 256
 SET extents->list[19].name = "XIE5NOMENCLATURE"
 SET extents->list[19].type = "INDEX"
 SET extents->list[19].ext_size = 256
 SET extents->list[20].name = "XIF5_NOMENCLATURE"
 SET extents->list[20].type = "INDEX"
 SET extents->list[20].ext_size = 256
 SET extents->list[21].name = "XIF1NOMENCLATURE"
 SET extents->list[21].type = "INDEX"
 SET extents->list[21].ext_size = 256
 SET extents->list[22].name = "XPKNOMENCLATURE"
 SET extents->list[22].type = "INDEX"
 SET extents->list[22].ext_size = 256
 SET extents->list[23].name = "XIE3NOMENCLATURE"
 SET extents->list[23].type = "INDEX"
 SET extents->list[23].ext_size = 256
 SET extents->list[24].name = "XIE2NOMENCLATURE"
 SET extents->list[24].type = "INDEX"
 SET extents->list[24].ext_size = 256
 SET extents->list[25].name = "XIE4NOMENCLATURE"
 SET extents->list[25].type = "INDEX"
 SET extents->list[25].ext_size = 128
 SET total_ext_num = size(extents->list,5)
 SELECT INTO "nl:"
  FROM user_tables ut,
   (dummyt d  WITH seq = value(total_ext_num))
  PLAN (d
   WHERE (extents->list[d.seq].type="TABLE"))
   JOIN (ut
   WHERE (ut.table_name=extents->list[d.seq].name))
  DETAIL
   IF (((ut.next_extent/ 1024) < extents->list[d.seq].ext_size))
    extents->list[d.seq].upd_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (error(err_msg,0) > 0)
  SET readme_data->message = err_msg
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM user_indexes ui,
   (dummyt d  WITH seq = value(total_ext_num))
  PLAN (d
   WHERE (extents->list[d.seq].type="INDEX"))
   JOIN (ui
   WHERE (ui.index_name=extents->list[d.seq].name))
  DETAIL
   IF (((ui.next_extent/ 1024) < extents->list[d.seq].ext_size))
    extents->list[d.seq].upd_ind = 1
   ENDIF
  WITH nocounter
 ;end select
 IF (error(err_msg,0) > 0)
  SET readme_data->message = err_msg
  GO TO exit_script
 ENDIF
 FOR (ext_cnt = 1 TO total_ext_num)
   IF ((extents->list[ext_cnt].upd_ind=1))
    SET parse_str = concat("rdb alter ",extents->list[ext_cnt].type," ",extents->list[ext_cnt].name,
     " storage (NEXT ",
     trim(cnvtstring(extents->list[ext_cnt].ext_size)),"K) go")
    CALL parser(parse_str)
    IF (error(err_msg,0) > 0)
     ROLLBACK
     SET readme_data->message = err_msg
     GO TO exit_script
    ENDIF
   ENDIF
 ENDFOR
 SET readme_data->status = "S"
 SET readme_data->message = "Extents updated successfully."
 COMMIT
#exit_script
 SET kia_version = "03/17/03"
 EXECUTE dm_readme_status
 FREE RECORD extents
END GO
