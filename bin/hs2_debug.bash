#!/bin/bash

HADOOP_CLIENT_OPTS+=" -agentlib:jdwp=transport=dt_socket,server=y,address=8000,suspend=n"
hiveserver2