-- accounts-contacts-drop.sql
--
-- @ported from sql-ledger and combined with parts from OpenACS ecommerce package
-- OpenACS core integration

select acs_object__delete(object_id) from qal_contact_object_id_map;
select acs_object_type__drop_type('qal_grps_contact','t');
drop index qal_contact_object_id_map_contact_id_idx;
drop index qal_contact_object_id_map_instance_id_idx;
DROP TABLE qal_contact_object_id_map;


drop index qal_other_address_map_trashed_p_idx;
drop index qal_other_address_map_address_id_idx;
drop index qal_other_address_map_record_type_idx;
drop index qal_other_address_map_instance_id_idx;
drop index qal_other_address_map_contact_id_idx;

DROP TABLE qal_other_address_map;

drop index qal_address_address_type_idx;
drop index qal_address_id_idx;
drop index qal_address_instance_id_idx;

DROP TABLE qal_address;

drop index qal_contact_user_map_trashed_p_idx;
drop index qal_contact_user_map_user_id_idx;
drop index qal_contact_user_map_contact_id_idx;
drop index qal_contact_user_map_instance_id_idx;

DROP TABLE qal_contact_user_map;

drop index qal_contact_label_idx;
drop index qal_contact_rev_id_idx;
drop index qal_contact_trashed_p_idx;
drop index qal_contact_instance_id_idx;
drop index qal_contact_id_idx;

DROP TABLE qal_contact;

