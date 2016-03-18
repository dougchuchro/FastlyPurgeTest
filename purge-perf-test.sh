#!/bin/bash

# URL to test with
declare -r test_url="http://www.wptestjapan.com.global.prod.fastly.net/wp-content/uploads/2015/07/logo.png"

# Fastly cache node where our cached object resides
declare -r nrt_cache_node="cache-nrt6121"

# Array of Fastly nodes where we will issue purge requests
declare -a cache_nodes=(	\
 "cache-ams4120" \
 "cache-atl6220" \
 "cache-bma7020" \
 "cache-dfw1820" \
 "cache-fra1220" \
 "cache-hkg6820" \
 "cache-iad2120" \
 "cache-jfk1020" \
 "cache-lax1420" \
 "cache-lhr6320" \
 "cache-sjc3120" \
 "cache-syd1620" \
	)

##  loop through the above array
for cache_node in "${cache_nodes[@]}"
do
   echo TESTING "$cache_node"
   # Warm the cache on the local cache node in NRT
	echo Warming the cache node "$cache_node"
	curl -svo /dev/nulll ${test_url} -x $nrt_cache_node.hosts.fastly.net:80 2>&1 >/dev/null | grep X-
	echo Warming the cache node "$cache_node" again, should see \"X-Cache: HIT\"
	curl -svo /dev/nulll ${test_url} -x $nrt_cache_node.hosts.fastly.net:80 2>&1 >/dev/null | grep X-

	# Send Purge request from the cache node in the arrary of global cache node
	curl -svo /dev/null ${test_url} -XPURGE -x $cache_node.hosts.fastly.net:80 2>&1 >/dev/null | grep PURGE
	
	# Wait 1 second for purge to compelte
	sleep 1
	
	# Confirm that local cache has been cleared
	echo "Confirming cache is cleared; should see X-Cache: MISS"
	curl -svo /dev/nulll ${test_url} -x $nrt_cache_node.hosts.fastly.net:80 2>&1 >/dev/null | grep X-
	echo END TESTING "$cache_node"
	echo  "===================="
done