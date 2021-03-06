## API info

Most of our endpoints have a corresponding 'info' with some extra information
and links to relevant docs and specifications.
For example: the endpoint has a `/info`, `/schemas` has a `/schemas/info` and so forth.

Below we provide a list of the 'info' endpoints and the expected response they will show

- `/info`

```
{
  metadata_communities: [ object with metadata_communities and their urls ],
  postman: 'url to postman docs',
  swagger: 'url to swagger docs',
  readme: 'url for readme',
  docs: 'url for docs folder'
}
```

- `/schemas/info`

```
{
  available_schemas: [ list of available schema urls ],
  specification: 'http://json-schema.org/'
}
```

- `/<community_name>/info`

```
{
    "backup_item": "ce-registry-test",
    "total_envelopes": 1024
}
```

- `/<community_name>/envelopes/info`

```
{
    "POST": {
        "accepted_schemas": [ list of resource schemas for this community ]
    },
    "PUT": {
        "accepted_schemas": ["http://localhost:9292/schemas/delete_envelope"]
    }
}
```

- `/<community_name>/envelopes/<id>/info`

```
{
    "PATCH": {
        "accepted_schemas": [ list of resource schemas for this community ]
    },
    "DELETE": {
        "accepted_schemas": ["http://localhost:9292/schemas/delete_envelope"]
    }
}
```
