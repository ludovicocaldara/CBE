[server]
The foo certificates in the directory "server" are copied in PGDATA by pge_cluster_create to setup SSL authentication.

[client]
The directory "client" contains the client certificates to connect as user postgres using the foo certificate.
They must be copied on the client in $HOME/.postgresql in order to work.
Make sure to keep directory permissions 700 and file permissions 400 or 600.


ATTENTION: all the certificates provided in CBE are not intended for production usage.
Make sure to use your own certificates to avoid malicious connections to your database!
