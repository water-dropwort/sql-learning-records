#!/bin/sh

# This script is for building a postgresql environment without using docker.
# OWNER is an username for postgres.
# CSVROOT is a path to the csv files.
OWNER="test"
CSVROOT="$HOME/projects/100knocks-preprocess/docker/work/data"

sudo -u postgres psql <<-EOSQL
     create database dsdojo_db with owner = $OWNER;
     GRANT ALL ON DATABASE dsdojo_db TO $OWNER;
     GRANT pg_read_server_files TO $OWNER;
     GRANT pg_write_server_files TO $OWNER;
     ALTER DATABASE dsdojo_db OWNER TO $OWNER;
EOSQL

psql -v ON_ERROR_STOP=1 --username $OWNER --dbname dsdojo_db <<-EOSQL
    -- customer
    DROP TABLE IF EXISTS customer;
    CREATE TABLE customer(
      customer_id            VARCHAR(14),
      customer_name          VARCHAR(20),
      gender_cd              VARCHAR(1),
      gender                 VARCHAR(2),
      birth_day              DATE,
      age                    INTEGER,
      postal_cd              VARCHAR(8),
      address                VARCHAR(128),
      application_store_cd   VARCHAR(6),
      application_date       VARCHAR(8),
      status_cd              VARCHAR(12),
      PRIMARY KEY (customer_id)
    );

    -- category
    DROP TABLE IF EXISTS category;
    CREATE TABLE category(
      category_major_cd     VARCHAR(2),
      category_major_name   VARCHAR(32),
      category_medium_cd    VARCHAR(4),
      category_medium_name  VARCHAR(32),
      category_small_cd     VARCHAR(6),
      category_small_name   VARCHAR(32),
      PRIMARY KEY (category_small_cd)
    );

    -- product
    DROP TABLE IF EXISTS product;
    CREATE TABLE product(
      product_cd            VARCHAR(10),
      category_major_cd     VARCHAR(2),
      category_medium_cd    VARCHAR(4),
      category_small_cd     VARCHAR(6),
      unit_price            INTEGER,
      unit_cost             INTEGER,
      PRIMARY KEY (product_cd)
    );

    -- store
    DROP TABLE IF EXISTS store;
    CREATE TABLE store(
      store_cd      VARCHAR(6),
      store_name    VARCHAR(128),
      prefecture_cd VARCHAR(2),
      prefecture    VARCHAR(5),
      address       VARCHAR(128),
      address_kana  VARCHAR(128),
      tel_no        VARCHAR(20),
      longitude     NUMERIC,
      latitude      NUMERIC,
      floor_area    NUMERIC,
      PRIMARY KEY (store_cd)
    );

    -- receipt
    DROP TABLE IF EXISTS receipt;
    CREATE TABLE receipt(
      sales_ymd       INTEGER,
      sales_epoch     INTEGER,
      store_cd        VARCHAR(6),
      receipt_no      SMALLINT,
      receipt_sub_no  SMALLINT,
      customer_id     VARCHAR(14),
      product_cd      VARCHAR(10),
      quantity        INTEGER,
      amount          INTEGER,
      PRIMARY KEY (sales_ymd, store_cd, receipt_no, receipt_sub_no)
    );

    -- geocode
    DROP TABLE IF EXISTS geocode;
    CREATE TABLE geocode(
      postal_cd       VARCHAR(8),
      prefecture      VARCHAR(4),
      city            VARCHAR(30),
      town            VARCHAR(30),
      street          VARCHAR(30),
      address         VARCHAR(30),
      full_address    VARCHAR(80),
      longitude       NUMERIC,
      latitude        NUMERIC
    );

    -- customer
    COPY customer FROM '$CSVROOT/customer.csv'
    WITH CSV HEADER
    ;

    -- category
    COPY category FROM '$CSVROOT/category.csv'
    WITH CSV HEADER
    ;

    -- product
    COPY product FROM '$CSVROOT/product.csv'
    WITH CSV HEADER
    ;

    -- receipt
    COPY receipt FROM '$CSVROOT/receipt.csv'
    WITH CSV HEADER
    ;

    -- store
    COPY store FROM '$CSVROOT/store.csv'
    WITH CSV HEADER
    ;

    -- geocode
    COPY geocode FROM '$CSVROOT/geocode.csv'
    WITH CSV HEADER
    ;
EOSQL
