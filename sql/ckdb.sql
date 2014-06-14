SET client_encoding = 'SQL_ASCII';
SET check_function_bodies = false;

SET SESSION AUTHORIZATION 'postgres';

REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;

COMMENT ON SCHEMA public IS 'ck';

SET SESSION AUTHORIZATION 'postgres';

SET search_path = public, pg_catalog;

CREATE TABLE users (
    userid bigint NOT NULL,
    username character varying(256) NOT NULL,
    emailaddress character varying(256) NOT NULL,
    joineddate timestamp with time zone NOT NULL,
    passwordhash character varying(256) NOT NULL,
    secondaryuserid character varying(64) NOT NULL,
    createdate timestamp with time zone NOT NULL,
    createby character varying(64) DEFAULT ''::character varying NOT NULL,
    createcode character varying(128) DEFAULT ''::character varying NOT NULL,
    createinet character varying(128) DEFAULT ''::character varying NOT NULL,
    expirydate timestamp with time zone DEFAULT '6666-06-06 06:06:06+00',
    PRIMARY KEY (userid, expirydate)
);
CREATE UNIQUE INDEX usersusername ON users USING btree (username, expirydate);


CREATE TABLE workers (
    workerid bigint NOT NULL, -- unique per record
    userid bigint NOT NULL,
    workername character varying(64) NOT NULL,
    difficultydefault integer DEFAULT 128 NOT NULL,
    idlenotificationenabled char DEFAULT 'n'::character varying NOT NULL,
    idlenotificationtime integer DEFAULT 10 NOT NULL,
    createdate timestamp with time zone NOT NULL,
    createby character varying(64) DEFAULT ''::character varying NOT NULL,
    createcode character varying(128) DEFAULT ''::character varying NOT NULL,
    createinet character varying(128) DEFAULT ''::character varying NOT NULL,
    expirydate timestamp with time zone DEFAULT '6666-06-06 06:06:06+00',
    PRIMARY KEY (workerid, expirydate)
);
CREATE UNIQUE INDEX workersuserid ON workers USING btree (userid, workername, expirydate);


CREATE TABLE paymentaddresses (
    paymentaddressid bigint NOT NULL, -- unique per record
    userid bigint NOT NULL,
    payaddress character varying(256) DEFAULT ''::character varying NOT NULL,
    payratio integer DEFAULT 1000000 NOT NULL,
    createdate timestamp with time zone NOT NULL,
    createby character varying(64) DEFAULT ''::character varying NOT NULL,
    createcode character varying(128) DEFAULT ''::character varying NOT NULL,
    createinet character varying(128) DEFAULT ''::character varying NOT NULL,
    expirydate timestamp with time zone DEFAULT '6666-06-06 06:06:06+00',
    PRIMARY KEY (paymentaddressid, expirydate)
);
CREATE UNIQUE INDEX payadduserid ON paymentaddresses USING btree (userid, payaddress, expirydate);


CREATE TABLE payments (
    paymentid bigint NOT NULL, -- unique per record
    userid bigint NOT NULL,
    paydate timestamp with time zone NOT NULL,
    payaddress character varying(256) DEFAULT ''::character varying NOT NULL,
    originaltxn character varying(256) DEFAULT ''::character varying NOT NULL,
    amount bigint NOT NULL, -- satoshis
    committxn character varying(256) DEFAULT ''::character varying NOT NULL,
    commitblockhash character varying(256) DEFAULT ''::character varying NOT NULL,
    createdate timestamp with time zone NOT NULL,
    createby character varying(64) DEFAULT ''::character varying NOT NULL,
    createcode character varying(128) DEFAULT ''::character varying NOT NULL,
    createinet character varying(128) DEFAULT ''::character varying NOT NULL,
    expirydate timestamp with time zone DEFAULT '6666-06-06 06:06:06+00',
    PRIMARY KEY (paymentid, expirydate)
);
CREATE UNIQUE INDEX payuserid ON payments USING btree (userid, payaddress, originaltxn, expirydate);


CREATE TABLE accountbalance ( -- summarised from miningpayouts and payments
    userid bigint NOT NULL,
    confirmedpaid bigint DEFAULT 0 NOT NULL, -- satoshis
    confirmedunpaid bigint DEFAULT 0 NOT NULL, -- satoshis
    pendingconfirm bigint DEFAULT 0 NOT NULL, -- satoshis
    heightupdate integer not NULL,
    createdate timestamp with time zone NOT NULL,
    createby character varying(64) DEFAULT ''::character varying NOT NULL,
    createcode character varying(128) DEFAULT ''::character varying NOT NULL,
    createinet character varying(128) DEFAULT ''::character varying NOT NULL,
    expirydate timestamp with time zone DEFAULT '6666-06-06 06:06:06+00',
    PRIMARY KEY (userid, expirydate)
);


CREATE TABLE idcontrol  (
    idname character varying(64) NOT NULL,
    lastid bigint DEFAULT 1 NOT NULL,
    createdate timestamp with time zone NOT NULL,
    createby character varying(64) DEFAULT ''::character varying NOT NULL,
    createcode character varying(128) DEFAULT ''::character varying NOT NULL,
    createinet character varying(128) DEFAULT ''::character varying NOT NULL,
    modifydate timestamp with time zone DEFAULT '6666-06-06 06:06:06+00',
    modifyby character varying(64) DEFAULT ''::character varying NOT NULL,
    modifycode character varying(128) DEFAULT ''::character varying NOT NULL,
    modifyinet character varying(128) DEFAULT ''::character varying NOT NULL,
    PRIMARY KEY (idname)
);


CREATE TABLE optioncontrol (
    optionname character varying(64) NOT NULL,
    optionvalue character varying(128) DEFAULT ''::character varying NOT NULL,
    activationdate timestamp with time zone DEFAULT '6666-06-06 06:06:06+00',
    activationheight integer DEFAULT 999999999,
    createdate timestamp with time zone NOT NULL,
    createby character varying(64) DEFAULT ''::character varying NOT NULL,
    createcode character varying(128) DEFAULT ''::character varying NOT NULL,
    createinet character varying(128) DEFAULT ''::character varying NOT NULL,
    expirydate timestamp with time zone DEFAULT '6666-06-06 06:06:06+00',
    PRIMARY KEY (optionname, activationdate, activationheight, expirydate)
);


CREATE TABLE workinfo (
    workinfoid bigint NOT NULL, -- unique per record
    poolinstance character varying(256) NOT NULL,
    transactiontree text DEFAULT ''::text NOT NULL,
    merklehash text DEFAULT ''::text NOT NULL,
    prevhash character varying(256) NOT NULL,
    coinbase1 character varying(256) NOT NULL,
    coinbase2 character varying(256) NOT NULL,
    version character varying(64) NOT NULL,
    bits character varying(64) NOT NULL,
    ntime character varying(64) NOT NULL,
    createdate timestamp with time zone NOT NULL,
    createby character varying(64) DEFAULT ''::character varying NOT NULL,
    createcode character varying(128) DEFAULT ''::character varying NOT NULL,
    createinet character varying(128) DEFAULT ''::character varying NOT NULL,
    expirydate timestamp with time zone DEFAULT '6666-06-06 06:06:06+00',
    PRIMARY KEY (workinfoid, expirydate)
);


CREATE TABLE shares (
    workinfoid bigint NOT NULL,
    userid bigint NOT NULL,
    workername character varying(64) NOT NULL,
    clientid integer NOT NULL,
    enonce1 character varying(64) NOT NULL,
    nonce2 character varying(256) NOT NULL,
    nonce character varying(64) NOT NULL,
    secondaryuserid character varying(64) NOT NULL,
    createdate timestamp with time zone NOT NULL,
    createby character varying(64) DEFAULT ''::character varying NOT NULL,
    createcode character varying(128) DEFAULT ''::character varying NOT NULL,
    createinet character varying(128) DEFAULT ''::character varying NOT NULL,
    expirydate timestamp with time zone DEFAULT '6666-06-06 06:06:06+00',
    PRIMARY KEY (workinfoid, userid, workername, enonce1, nonce2, nonce, expirydate)
);


-- memory only?
CREATE TABLE sharesummary ( -- per workinfo for each user+worker
    userid bigint NOT NULL,
    workername character varying(64) NOT NULL,
    workinfoid bigint NOT NULL,
    diff_acc bigint NOT NULL,
    diff_sta bigint NOT NULL,
    diff_dup bigint NOT NULL,
    diff_low bigint NOT NULL,
    diff_rej bigint NOT NULL,
    share_acc bigint NOT NULL,
    share_sta bigint NOT NULL,
    share_dup bigint NOT NULL,
    share_low bigint NOT NULL,
    share_rej bigint NOT NULL,
    first_share timestamp with time zone NOT NULL,
    last_share timestamp with time zone NOT NULL,
    complete char DEFAULT ''::char NOT NULL,
    createdate timestamp with time zone NOT NULL,
    createby character varying(64) DEFAULT ''::character varying NOT NULL,
    createcode character varying(128) DEFAULT ''::character varying NOT NULL,
    createinet character varying(128) DEFAULT ''::character varying NOT NULL,
    modifydate timestamp with time zone DEFAULT '6666-06-06 06:06:06+00',
    modifyby character varying(64) DEFAULT ''::character varying NOT NULL,
    modifycode character varying(128) DEFAULT ''::character varying NOT NULL,
    modifyinet character varying(128) DEFAULT ''::character varying NOT NULL,
    PRIMARY KEY (userid, workername, workinfoid)
);


CREATE TABLE blocksummary ( -- summation of sharesummary per block found for each user+worker
    height integer not NULL,
    blockhash character varying(256) NOT NULL,
    userid bigint NOT NULL,
    workername character varying(64) NOT NULL,
    diff_acc bigint NOT NULL,
    diff_sta bigint NOT NULL,
    diff_dup bigint NOT NULL,
    diff_low bigint NOT NULL,
    diff_rej bigint NOT NULL,
    share_acc bigint NOT NULL,
    share_sta bigint NOT NULL,
    share_dup bigint NOT NULL,
    share_low bigint NOT NULL,
    share_rej bigint NOT NULL,
    first_share timestamp with time zone NOT NULL,
    last_share timestamp with time zone NOT NULL,
    complete char DEFAULT ''::char NOT NULL,
    createdate timestamp with time zone NOT NULL,
    createby character varying(64) DEFAULT ''::character varying NOT NULL,
    createcode character varying(128) DEFAULT ''::character varying NOT NULL,
    createinet character varying(128) DEFAULT ''::character varying NOT NULL,
    modifydate timestamp with time zone DEFAULT '6666-06-06 06:06:06+00',
    modifyby character varying(64) DEFAULT ''::character varying NOT NULL,
    modifycode character varying(128) DEFAULT ''::character varying NOT NULL,
    modifyinet character varying(128) DEFAULT ''::character varying NOT NULL,
    PRIMARY KEY (userid, workername, height, blockhash)
);


-- shares will be a flat file only
-- so this needs all info from shares
CREATE TABLE blocks (
    height integer not NULL,
    blockhash character varying(256) NOT NULL,
    workinfoid bigint NOT NULL,
    userid bigint NOT NULL,
    workername character varying(64) NOT NULL,
    clientid integer NOT NULL,
    enonce1 character varying(64) NOT NULL,
    nonce2 character varying(256) NOT NULL,
    nonce character varying(64) NOT NULL,
    confirmed char DEFAULT '' NOT NULL, -- blank, 'c'onfirmed or 'o'rphan
    createdate timestamp with time zone NOT NULL,
    createby character varying(64) DEFAULT ''::character varying NOT NULL,
    createcode character varying(128) DEFAULT ''::character varying NOT NULL,
    createinet character varying(128) DEFAULT ''::character varying NOT NULL,
    expirydate timestamp with time zone DEFAULT '6666-06-06 06:06:06+00',
    PRIMARY KEY (height, blockhash, expirydate)
);


-- calculation for the given block - orphans will be here also (not deleted later)
-- rules for orphans/next block will be pool dependent
-- normally pay due would be related to sum of one height + for all blockhash
CREATE TABLE miningpayouts (
    miningpayoutid bigint NOT NULL, -- unique per record
    userid bigint NOT NULL,
    height integer not NULL,
    blockhash character varying(256) DEFAULT ''::character varying NOT NULL,
    amount bigint DEFAULT 0 NOT NULL,
    createdate timestamp with time zone NOT NULL,
    createby character varying(64) DEFAULT ''::character varying NOT NULL,
    createcode character varying(128) DEFAULT ''::character varying NOT NULL,
    createinet character varying(128) DEFAULT ''::character varying NOT NULL,
    expirydate timestamp with time zone DEFAULT '6666-06-06 06:06:06+00',
    PRIMARY KEY (miningpayoutid, expirydate)
);
CREATE UNIQUE INDEX minpayuserid ON miningpayouts USING btree (userid, blockhash, expirydate);


CREATE TABLE eventlog (
    eventlogid bigint NOT NULL,
    eventlogcode character varying(64) NOT NULL,
    eventlogdescription text NOT NULL,
    createdate timestamp with time zone NOT NULL,
    createby character varying(64) DEFAULT ''::character varying NOT NULL,
    createcode character varying(128) DEFAULT ''::character varying NOT NULL,
    createinet character varying(128) DEFAULT ''::character varying NOT NULL,
    expirydate timestamp with time zone DEFAULT '6666-06-06 06:06:06+00',
    PRIMARY KEY (eventlogid, expirydate)
);


CREATE TABLE auths (
    authid bigint NOT NULL, -- unique per record
    userid bigint NOT NULL,
    workername character varying(64) NOT NULL,
    clientid integer NOT NULL,
    enonce1 character varying(64) NOT NULL,
    useragent character varying(256) NOT NULL,
    createdate timestamp with time zone NOT NULL,
    createby character varying(64) DEFAULT ''::character varying NOT NULL,
    createcode character varying(128) DEFAULT ''::character varying NOT NULL,
    createinet character varying(128) DEFAULT ''::character varying NOT NULL,
    expirydate timestamp with time zone DEFAULT '6666-06-06 06:06:06+00',
    PRIMARY KEY (authid, expirydate)
);
