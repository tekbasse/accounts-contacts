-- accounts-contacts-create.sql
--
-- @ported from sql-ledger and combined with parts from OpenACS ecommerce package
-- @license GNU GENERAL PUBLIC LICENSE, Version 2, June 1991
-- @cvs-id

-- pgsql for supporting integration with acs_objects.
-- Integration is auxiliary to the data model and code features.
-- It is made available to help support integration with deployments that rely on standard
-- OpenACS features.

CREATE SEQUENCE qal_id start 10000;
SELECT nextval ('qal_id');


CREATE TABLE qal_contact_object_id_map (
       -- contact is a party of type group
       object_id integer unique not null,
       instance_id integer,

       -- For now, contact_id is the same as object_id.
       -- This prevents id collision between qal_id, qc_id and object_id,
       -- since id's of contact_id may be mixed with instance_id and
       -- group_id and other parts of OpenACS object_id system.
       -- This also should simplify any translation of q-control
       -- permissions to translate into and use the more scalable
       -- OpenACS permissions.
       --See qal_contact table.
       -- acs_object_type__create_type needs an external table.
       contact_id integer,
       -- A contact party has a subgroup that contact users are assigned to.
       -- This helps to separate user membership from contacts that have memberships to other contacts etc.
       contact_grp_id integer
);       

create index qal_contact_object_id_map_contact_id_idx on qal_contact_object_id_map(contact_id);
create index qal_contact_object_id_map_instance_id_idx on qal_contact_object_id_map(instance_id);

select acs_object_type__create_type(
   'qal_grps_contact',           -- content_type
   'qal Contact Group',          -- pretty_name 
   'qal Contact Groups',         -- pretty_plural
   'acs_object',                 -- supertype
   'qal_contact_object_id_map',  -- table_name
   'object_id',                  -- id_column 
   'qal_groups_contact',         -- package_name
   'f',                          -- abstract_p
   NULL,                         -- type_extension_table
   NULL                          -- name_method
);


-- Primary Data Model
-- data model summary:
-- contact is the base organization or entity.
-- A user may have multiple entities, 1 or more of their own, and maybe some roles of others
-- A contact can have multiple addresses
-- A user is mapped to their own personal contact record, and maybe others

--part of company_dates, company_details
CREATE TABLE qal_contact (
       -- id ie party_id ie object_id.
       -- This is to avoid id collision with inter-package use cases,
       -- such as with contact-support package and this one.
       -- In general,
       -- it is a good idea to link an object_id to each contact anyway,
       -- in case conventional openacs group permissions are used.
       -- set id group::new -context_id $instance_id -group_name $label -pretty_name $name
       -- aka contact_id
       id                  integer not null,
       -- revision_id. Updates create new record and trash old
       -- same id, new rev_id 
       rev_id              integer default nextval('qal_id'),
       instance_id         integer not null,
       -- for some aggregate reporting, a parent_id may be useful. 
       -- However,
       -- each contact is considered a separate entity for permissions etc.
       parent_id           integer,
       -- label is expected to be unique to an instance_id
       label               varchar(40),
       name                varchar(80),
       -- preferred qal_other_address_map.addrs_id
       -- is based on sort_order
       -- lowest number first.
       street_addrs_id     integer,
       mailing_addrs_id    integer,
       billing_addrs_id    integer,
       -- business_id is qal_vendor.vendor_id
       vendor_id           integer,
       -- customer_id is qal_customer.customer_id
       customer_id         integer,
       taxnumber           varchar(32),
       sic_code            varchar(15),
       -- country code using ISO 3166-1 alpha-2 - char(2)
       -- check digits - char(2)
       -- account number varchar(30)
       -- no spaces
       -- yet expressed in groups of four characters separated by a space
       iban                varchar(34),
       -- business identifier code aka swift etc
       -- institution code char(4)
       -- iso 3166-1 alpha-2 country code char(2)
       -- location code char(2)
       -- branch code char(3), optional.
       -- logical terminal code char(1) not part of formal bic. 
       bic                 varchar(12),
       language_code       varchar(6),
       currency            varchar(3),
       -- default is from user_preferences.timezone
       timezone            varchar(100),
       time_start          timestamptz,
       time_end            timestamptz,
       url                 varchar(200),
       user_id             integer,
       created             timestamptz not null DEFAULT now(),
       created_by          integer,
       trashed_p           integer,
       trashed_by          integer,
       trashed_ts          timestamptz,
       notes               text
);

create index qal_contact_id_idx on qal_contact (id);
create index qal_contact_instance_id_idx on qal_contact (instance_id);
create index qal_contact_trashed_p_idx on qal_contact (trashed_p);
create index qal_contact_rev_id_idx on qal_contact (rev_id);
create index qal_contact_label_idx on qal_contact (label);

-- was qal_contact_group ( or contact_group in SL)
-- mainly gets used in packages that depend on accounts-ledger
-- Deprecated. See qc_user_ids_of_contact_id, and qc_user_role_add
CREATE TABLE qal_contact_user_map (
       instance_id         integer,
       contact_id          integer,
       user_id             integer,
       created             timestamptz not null DEFAULT now(),
       created_by          integer,
       trashed_p           integer,
       trashed_by          integer,
       trashed_ts          timestamptz
);

create index qal_contact_user_map_instance_id_idx on qal_contact_user_map (instance_id);
create index qal_contact_user_map_contact_id_idx on qal_contact_user_map (contact_id);
create index qal_contact_user_map_user_id_idx on qal_contact_user_map (user_id);
create index qal_contact_user_map_trashed_p_idx on qal_contact_user_map (trashed_p);

-- Plenty of cases do not fit traditional norms. Allow for more cases with this model.
CREATE TABLE qal_other_address_map (
       contact_id          integer,
       instance_id         integer,
       -- unique id of a means of contact
       -- If record_type is address, address_id is same as qal_address.id
       addrs_id            integer default nextval('qal_id'),
       -- address, other..
       -- If record_type does not match *address* as in for use with qal_address, 
       -- it may be YIM,AIM etc
       record_type         varchar(30),
       -- If this is an address, this references qal_address.id
       -- If null, this is a contact method (skype,aim,yim,jabber etc)
       -- Address_id doubles as rev_id integer default nextval('qal_id'),
       address_id          integer,
       sort_order          integer,
       created             timestamptz not null DEFAULT now(),
       created_by          integer,
       trashed_p           integer,
       trashed_by          integer,
       trashed_ts          timestamptz,
       -- if record_type is not address, refer to account_name
       -- YIM username etc. or maybe runner..
       -- text allows for anything
       account_name        text,
       notes               text
);

create index qal_other_address_map_contact_id_idx on qal_other_address_map (contact_id);
create index qal_other_address_map_instance_id_idx on qal_other_address_map (instance_id);
create index qal_other_address_map_record_type_idx on qal_other_address_map (record_type);
create index qal_other_address_map_address_id_idx on qal_other_address_map (address_id);
create index qal_other_address_map_trashed_p_idx on qal_other_address_map (trashed_p);

CREATE TABLE qal_address (
        id                 integer default nextval('qal_id'),
        instance_id        integer,
        -- rev_id is redundant. Use qal_other_address_map paradigm
        -- rev_id             integer default nextval('qal_id')

        -- address_type is redundant too, but useful for integrity checks.
        -- e.g., billing_address, shipping.. etc  see: qal_other_address_map.record_type
        address_type       varchar(20) not null default 'street_address',  
        address0           varchar(40),
        address1           varchar(40),
        address2           varchar(40),
        city               varchar(40),
        state              varchar(32),
        postal_code        varchar(20),
        -- references countries(iso)
        country_code       varchar(3),
        attn               varchar(64),
        phone              varchar(30),
        phone_time         varchar(10),
        fax                varchar(30),
        -- text type allows multiple entries
        email              text,
        cc                 text,
        bcc                text
);

create index qal_address_instance_id_idx on qal_address (instance_id);
create index qal_address_id_idx on qal_address (id);
create index qal_address_address_type_idx on qal_address (address_type);


 -- a contact manager style should have an additional table and map for
 -- multiple with:
 -- contact_id 
 -- contact_method (skype etc)
 -- userid
 -- notes 
 -- See q-control package.

