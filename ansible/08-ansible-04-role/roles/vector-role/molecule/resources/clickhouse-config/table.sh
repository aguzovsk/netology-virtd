#!/bin/bash
set -e

clickhouse-client -q "CREATE TABLE logs.datadog (
    appname String NOT NULL,
    facility String NOT NULL,
    hostname String NOT NULL,
    message String NOT NULL,
    msgid String NOT NULL,
    procid UInt32 NOT NULL,
    severity Enum8('debug' = 1, 'info', 'notice', 'warning', 'err', 'crit', 'alert', 'emerg'),
    timestamp DateTime64 NOT NULL,
    version UInt8 NOT NULL
  ) ENGINE Log"
