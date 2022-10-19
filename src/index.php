<?php

$r = new Redis(); 
$r->connect('172.19.0.1', 6382); 
if ( $r->ping() ) {
    echo 'Connection is ok' ;
    $r->set("name", "kordel"); 
    echo " Stored string in redis:: " .$r->get("name"); 
}

phpinfo();