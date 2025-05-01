#!/bin/bash

exec /usr/bin/setpriv --clear-groups --reuid etcd --regid etcd -- /usr/bin/etcd
