Day 8, SQL
=========

Solved with PlPgsql.

The input is very large, so downlad it and save it as file called ```input```.
Then run:

```bash
INP=`cat input` && sed "s/\${INPUT}/${INP}/" solution.sql | psql -U postgres
```