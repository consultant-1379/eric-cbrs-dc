#!/bin/sh

exec 1>/ericsson/cbrs-dc-sa/entrypoint.log
exec 2>/ericsson/cbrs-dc-sa/entrypoint.err

exec "$@"
