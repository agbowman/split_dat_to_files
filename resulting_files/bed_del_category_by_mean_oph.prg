CREATE PROGRAM bed_del_category_by_mean_oph
 PROMPT
  "Enter the category_mean from the br_datamart_category table you wish to delete: " = ""
  WITH category_mean
 DECLARE cat_mean_to_del = vc WITH protect, constant( $CATEGORY_MEAN)
 DECLARE delete_category_id = f8 WITH protect, noconstant(- (1.0))
 SELECT INTO "nl:"
  FROM br_datamart_category c
  PLAN (c
   WHERE c.category_mean=cat_mean_to_del)
  DETAIL
   delete_category_id = c.br_datamart_category_id
  WITH nocounter
 ;end select
 DELETE  FROM br_datamart_report_filter_r b
  WHERE (b.br_datamart_filter_id=
  (SELECT
   b2.br_datamart_filter_id
   FROM br_datamart_filter b2
   WHERE b2.br_datamart_category_id=delete_category_id))
 ;end delete
 DELETE  FROM br_datamart_default b
  WHERE (b.br_datamart_filter_id=
  (SELECT
   b2.br_datamart_filter_id
   FROM br_datamart_filter b2
   WHERE b2.br_datamart_category_id=delete_category_id))
 ;end delete
 DELETE  FROM br_datamart_value b
  WHERE b.br_datamart_category_id=delete_category_id
 ;end delete
 DELETE  FROM br_datamart_text b
  WHERE b.br_datamart_category_id=delete_category_id
 ;end delete
 DELETE  FROM br_datam_report_layout b
  WHERE b.br_datamart_report_id IN (
  (SELECT
   b2.br_datamart_report_id
   FROM br_datamart_report b2
   WHERE b2.br_datamart_category_id=delete_category_id))
 ;end delete
 DELETE  FROM br_datamart_report_default b
  WHERE b.br_datamart_report_id IN (
  (SELECT
   b2.br_datamart_report_id
   FROM br_datamart_report b2
   WHERE b2.br_datamart_category_id=delete_category_id))
 ;end delete
 DELETE  FROM br_datamart_report b
  WHERE b.br_datamart_category_id=delete_category_id
 ;end delete
 DELETE  FROM br_datamart_filter_detail b3
  WHERE (b3.br_datamart_filter_id=
  (SELECT
   b3.br_datamart_filter_id
   FROM br_datamart_filter b3
   WHERE b3.br_datamart_category_id=delete_category_id))
 ;end delete
 DELETE  FROM br_datam_val_set_item_meas
  WHERE br_datam_val_set_item_id IN (
  (SELECT
   br_datam_val_set_item_id
   FROM br_datam_val_set_item
   WHERE br_datam_val_set_id IN (
   (SELECT
    br_datam_val_set_id
    FROM br_datam_val_set
    WHERE br_datamart_category_id=delete_category_id))))
 ;end delete
 DELETE  FROM br_datam_val_set_item
  WHERE br_datam_val_set_id IN (
  (SELECT
   br_datam_val_set_id
   FROM br_datam_val_set
   WHERE br_datamart_category_id=delete_category_id))
 ;end delete
 DELETE  FROM br_datamart_filter b
  WHERE b.br_datamart_category_id=delete_category_id
 ;end delete
 DELETE  FROM br_datam_val_set
  WHERE br_datamart_category_id=delete_category_id
 ;end delete
 DELETE  FROM mp_viewpoint_reltn b
  WHERE b.br_datamart_category_id=delete_category_id
 ;end delete
 DELETE  FROM br_datam_mapping_type b
  WHERE b.br_datamart_category_id=delete_category_id
 ;end delete
 DELETE  FROM br_datamart_category
  WHERE br_datamart_category_id=delete_category_id
 ;end delete
END GO
