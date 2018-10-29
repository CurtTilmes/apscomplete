# apscomplete

a little script to store completion of a run back to Origin

```
apscomplete.p6 [success|fail] <runid>
```

e.g.

```
apscomplete.p6 success d80700fb-032e-427b-99cf-87a0cc551d6c
or
apscomplete.p6 fail d80700fb-032e-427b-99cf-87a0cc551d6c
```

Reads the job description from `/tis/aps/<runid>.input`.

If `success`:

Copy each file in the current directory to `/tis/<project>/data`.

Look for the file `output` in the current directory.  It is a YAML format
file describing the files in the current directory.

```
<filename>:
  esdt: <someesdt>
  datatime: <somedate>
  key: <somekey>
```

If `key` is missing, and `datatime` is present, it will use the
`datatime` as the `key`, but often they will be different.

For example:
```
myfile.hdf:
  esdt: DATATYPEFOO
  datatime: 2018-10-01 01:45
  key: 27
```

The run will then be updated in *Origin*.

All files in the current directory will be listed as output files for
the `run`.  If the are listed properly in the `output` file, it will
also create `granule`s for them.

If there are any problems archiving the files in the current
directory, the run will be marked as `FAIL`.
