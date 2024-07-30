#!/bin/bash
ab -l -c 15 -n 5000 http://127.0.0.1:80/en/blog/ 2>&1
